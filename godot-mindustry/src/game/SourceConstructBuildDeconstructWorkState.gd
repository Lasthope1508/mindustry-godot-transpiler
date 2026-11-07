extends RefCounted
class_name SourceConstructBuildDeconstructWorkState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_construct_block_source_text_state := preload("res://src/game/SourceConstructBlockSourceTextState.gd")

const SOURCE_CONSTRUCT_BLOCK_SOURCE := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_SOURCE
const SOURCE_CONSTRUCT_BUILD_CLASS_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BUILD_CLASS_EXPR
const CONSTRUCT_BUILD_CLASS_EXPR := SOURCE_CONSTRUCT_BUILD_CLASS_EXPR

static func set_deconstruct_state(previous_block: Variant, build_cost_multiplier: float) -> Dictionary:
	var previous_is_null: bool = previous_block == null
	var requirements: Array = []
	var build_time: float = 0.0
	if not previous_is_null and previous_block is Dictionary:
		requirements = previous_block.get("requirements", [])
		build_time = float(previous_block.get("buildTime", 0.0))
	var items_left: Array[int] = []
	var accumulator: Array[float] = []
	var total_accumulator: Array[float] = []
	for _requirement in requirements:
		items_left.append(0)
		accumulator.append(0.0)
		total_accumulator.append(0.0)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BUILD_SET_DECONSTRUCT_STATE,
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
		"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
		"set_deconstruct_method": "public void setDeconstruct(Block previous){",
		"set_deconstruct_null_guard_expr": "if(previous == null) return;",
		"construct_color_expr": "this.constructColor = 1f;",
		"was_constructing_expr": "this.wasConstructing = false;",
		"previous_expr": "this.previous = previous;",
		"progress_expr": "this.progress = 1f;",
		"current_expr": "this.current = previous;",
		"build_cost_expr": "this.buildCost = previous.buildTime * state.rules.buildCostMultiplier;",
		"items_left_expr": "this.itemsLeft = new int[previous.requirements.length];",
		"accumulator_expr": "this.accumulator = new float[previous.requirements.length];",
		"total_accumulator_expr": "this.totalAccumulator = new float[previous.requirements.length];",
		"pathfinder_expr": "pathfinder.updateTile(tile);",
		"returned_early": previous_is_null,
		"construct_color": 1.0,
		"was_constructing": false,
		"previous": previous_block,
		"progress": 1.0,
		"current": previous_block,
		"build_cost": build_time * build_cost_multiplier,
		"items_left": items_left,
		"accumulator": accumulator,
		"total_accumulator": total_accumulator,
		"pathfinder_update_tile_called": not previous_is_null,
		"requirement_count": requirements.size(),
		"build_cost_multiplier": build_cost_multiplier,
	}
static func deconstruct_state(current_block: Variant, builder_state: Variant, core_inventory: Dictionary, amount: float, progress_before: float, accumulator: Variant, total_accumulator: Variant, items_left: Variant, build_cost_multiplier: float, deconstruct_refund_multiplier: float, core_present: bool, state_infinite_resources: bool, builder_is_player: bool, was_constructing: bool, last_builder_present: bool, core_storage_capacity: int) -> Dictionary:
	var requirements: Array = current_block.get("requirements", []) if current_block is Dictionary else []
	if accumulator == null or total_accumulator == null:
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BUILD_DECONSTRUCT_STATE,
			"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
			"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
			"deconstruct_method": "public void deconstruct(Unit builder, @Nullable CoreBuild core, float amount){",
			"accumulator_null_guard_expr": "if(accumulator == null || totalAccumulator == null) return;",
			"returned_early": true,
		}
	var accumulator_after: Array = accumulator.duplicate()
	var total_accumulator_after: Array = total_accumulator.duplicate()
	var items_left_after: Array = items_left.duplicate() if items_left is Array else []
	var core_inventory_after: Dictionary = core_inventory.duplicate()
	var mode_switch_reset_called: bool = was_constructing
	if was_constructing:
		for i in range(accumulator_after.size()):
			accumulator_after[i] = 0.0
		for i in range(total_accumulator_after.size()):
			total_accumulator_after[i] = 0.0
	var progress_start: float = progress_before
	var set_deconstruct_called: bool = requirements.size() != accumulator_after.size() or total_accumulator_after.size() != requirements.size()
	var set_deconstruct: Dictionary = {}
	if set_deconstruct_called:
		set_deconstruct = set_deconstruct_state(current_block, build_cost_multiplier)
		accumulator_after = set_deconstruct.get("accumulator", []).duplicate()
		total_accumulator_after = set_deconstruct.get("total_accumulator", []).duplicate()
		items_left_after = set_deconstruct.get("items_left", []).duplicate()
		progress_start = float(set_deconstruct.get("progress", progress_start))
	var clamped_amount: float = min(amount, progress_start)
	var per_requirement: Array = []
	for i in range(requirements.size()):
		var requirement: Variant = requirements[i]
		var item: String = str(requirement.get("item", "")) if requirement is Dictionary else ""
		var requirement_amount: float = float(requirement.get("amount", 0.0)) if requirement is Dictionary else 0.0
		var item_unlocked: bool = bool(requirement.get("unlocked", true)) if requirement is Dictionary else true
		var reqamount: int = int(round(build_cost_multiplier * requirement_amount))
		var current_total: float = float(total_accumulator_after[i]) if i < total_accumulator_after.size() else 0.0
		var current_accumulator: float = float(accumulator_after[i]) if i < accumulator_after.size() else 0.0
		var accumulator_delta: float = min(clamped_amount * deconstruct_refund_multiplier * float(reqamount), deconstruct_refund_multiplier * float(reqamount) - current_total)
		if i < accumulator_after.size():
			accumulator_after[i] = current_accumulator + accumulator_delta
		if i < total_accumulator_after.size():
			total_accumulator_after[i] = min(current_total + float(reqamount) * clamped_amount * deconstruct_refund_multiplier, float(reqamount))
		var accumulated: int = int(accumulator_after[i]) if i < accumulator_after.size() else 0
		var accepting: int = 0
		var accepted_to_core: bool = false
		var discarded_accumulated: bool = false
		if clamped_amount > 0.0 and accumulated > 0:
			if core_present and item_unlocked:
				var inventory_amount: int = int(core_inventory_after.get(item, 0))
				accepting = min(accumulated, core_storage_capacity - inventory_amount)
				if not state_infinite_resources:
					core_inventory_after[item] = inventory_amount + accepting
				if i < items_left_after.size():
					items_left_after[i] = int(items_left_after[i]) + accepting
				if i < accumulator_after.size():
					accumulator_after[i] = float(accumulator_after[i]) - float(accepting)
				accepted_to_core = true
			else:
				if i < accumulator_after.size():
					accumulator_after[i] = float(accumulator_after[i]) - float(accumulated)
				discarded_accumulated = true
		per_requirement.append({
			"index": i,
			"item": item,
			"unlocked": item_unlocked,
			"reqamount": reqamount,
			"accumulator_delta": accumulator_delta,
			"total_accumulator_after": total_accumulator_after[i] if i < total_accumulator_after.size() else 0.0,
			"accumulated": accumulated,
			"accepting": accepting,
			"accepted_to_core": accepted_to_core,
			"discarded_accumulated": discarded_accumulated,
		})
	var progress_after: float = clampf(progress_start - amount, 0.0, 1.0)
	var deconstruct_threshold: float = float(current_block.get("deconstructThreshold", 0.0)) if current_block is Dictionary else 0.0
	var finish_gate: bool = progress_after <= deconstruct_threshold or state_infinite_resources
	var leftover_steps: Array = []
	if finish_gate and core_present and not state_infinite_resources:
		for i in range(items_left_after.size()):
			var requirement: Variant = requirements[i] if i < requirements.size() else {}
			var item: String = str(requirement.get("item", "")) if requirement is Dictionary else ""
			var requirement_amount: float = float(requirement.get("amount", 0.0)) if requirement is Dictionary else 0.0
			var item_unlocked: bool = bool(requirement.get("unlocked", true)) if requirement is Dictionary else true
			var target: int = int(round(requirement_amount * build_cost_multiplier * deconstruct_refund_multiplier))
			var remaining: int = target - int(items_left_after[i])
			var added: int = 0
			if item_unlocked:
				var inventory_amount: int = int(core_inventory_after.get(item, 0))
				added = clampi(remaining, 0, core_storage_capacity - inventory_amount)
				core_inventory_after[item] = inventory_amount + added
			items_left_after[i] = target
			leftover_steps.append({
				"index": i,
				"item": item,
				"unlocked": item_unlocked,
				"target": target,
				"remaining": remaining,
				"added": added,
			})
	var last_builder_after_present: bool = last_builder_present or builder_is_player or finish_gate
	var deconstruct_finish_called: bool = finish_gate
	var deconstruct_finish_call: Variant = null
	if deconstruct_finish_called:
		deconstruct_finish_call = {"call": "Call.deconstructFinish(tile, this.current, lastBuilder);", "current": current_block}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BUILD_DECONSTRUCT_STATE,
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
		"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
		"deconstruct_method": "public void deconstruct(Unit builder, @Nullable CoreBuild core, float amount){",
		"accumulator_null_guard_expr": "if(accumulator == null || totalAccumulator == null) return;",
		"mode_switch_guard_expr": "if(wasConstructing){",
		"accumulator_reset_expr": "Arrays.fill(accumulator, 0);",
		"total_accumulator_reset_expr": "Arrays.fill(totalAccumulator, 0);",
		"was_constructing_expr": "wasConstructing = false;",
		"active_deconstruct_expr": "activeDeconstruct = true;",
		"deconstruct_multiplier_expr": "float deconstructMultiplier = state.rules.deconstructRefundMultiplier;",
		"builder_player_guard_expr": "if(builder.isPlayer()){",
		"last_builder_expr": "lastBuilder = builder;",
		"requirements_expr": "ItemStack[] requirements = current.requirements;",
		"length_mismatch_guard_expr": "if(requirements.length != accumulator.length || totalAccumulator.length != requirements.length){",
		"set_deconstruct_expr": "setDeconstruct(current);",
		"clamped_amount_expr": "float clampedAmount = Math.min(amount, progress);",
		"requirements_loop_expr": "for(int i = 0; i < requirements.length; i++){",
		"reqamount_expr": "int reqamount = Math.round(state.rules.buildCostMultiplier * requirements[i].amount);",
		"accumulator_deconstruct_expr": "accumulator[i] += Math.min(clampedAmount * deconstructMultiplier * reqamount, deconstructMultiplier * reqamount - totalAccumulator[i]);",
		"total_accumulator_deconstruct_expr": "totalAccumulator[i] = Math.min(totalAccumulator[i] + reqamount * clampedAmount * deconstructMultiplier, reqamount);",
		"accumulated_expr": "int accumulated = (int)(accumulator[i]);",
		"positive_accumulated_guard_expr": "if(clampedAmount > 0 && accumulated > 0){",
		"core_unlocked_guard_expr": "if(core != null && requirements[i].item.unlockedNowHost()){",
		"accepting_expr": "int accepting = Math.min(accumulated, core.storageCapacity - core.items.get(requirements[i].item));",
		"core_add_expr": "if(!state.rules.infiniteResources) core.items.add(requirements[i].item, accepting);",
		"items_left_add_expr": "itemsLeft[i] += accepting;",
		"accumulator_accepting_subtract_expr": "accumulator[i] -= accepting;",
		"accumulator_accumulated_subtract_expr": "accumulator[i] -= accumulated;",
		"progress_expr": "progress = Mathf.clamp(progress - amount);",
		"finish_guard_expr": "if(progress <= current.deconstructThreshold || state.rules.infiniteResources){",
		"leftover_guard_expr": "if(core != null && !state.rules.infiniteResources){",
		"target_expr": "int target = Mathf.round(requirements[i].amount * state.rules.buildCostMultiplier * state.rules.deconstructRefundMultiplier);",
		"remaining_expr": "int remaining = target - itemsLeft[i];",
		"leftover_core_add_expr": "core.items.add(requirements[i].item, Mathf.clamp(remaining, 0, core.storageCapacity - core.items.get(requirements[i].item)));",
		"items_left_target_expr": "itemsLeft[i] = target;",
		"last_builder_fallback_expr": "if(lastBuilder == null) lastBuilder = builder;",
		"deconstruct_finish_expr": "Call.deconstructFinish(tile, this.current, lastBuilder);",
		"returned_early": false,
		"requirements": requirements,
		"current_block": current_block,
		"builder_state": builder_state,
		"amount": amount,
		"progress_before": progress_before,
		"progress_start": progress_start,
		"progress_after": progress_after,
		"build_cost_multiplier": build_cost_multiplier,
		"deconstruct_refund_multiplier": deconstruct_refund_multiplier,
		"core_present": core_present,
		"state_infinite_resources": state_infinite_resources,
		"builder_is_player": builder_is_player,
		"last_builder_present_before": last_builder_present,
		"last_builder_present_after": last_builder_after_present,
		"was_constructing": false,
		"active_deconstruct": true,
		"mode_switch_reset_called": mode_switch_reset_called,
		"set_deconstruct_called": set_deconstruct_called,
		"set_deconstruct": set_deconstruct,
		"clamped_amount": clamped_amount,
		"per_requirement": per_requirement,
		"accumulator_after": accumulator_after,
		"total_accumulator_after": total_accumulator_after,
		"items_left_after": items_left_after,
		"core_inventory_after": core_inventory_after,
		"deconstruct_threshold": deconstruct_threshold,
		"finish_gate": finish_gate,
		"leftover_steps": leftover_steps,
		"deconstruct_finish_called": deconstruct_finish_called,
		"deconstruct_finish_call": deconstruct_finish_call,
	}
