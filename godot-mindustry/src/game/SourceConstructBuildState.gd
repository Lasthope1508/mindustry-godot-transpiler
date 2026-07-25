extends RefCounted
class_name SourceConstructBuildState

const CONSTRUCT_BUILD_COLOR_LERP_PROGRESS := 0.2
const CONSTRUCT_BUILD_CLASS_EXPR := "public class ConstructBuild extends Building{"

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"lerp_delta": Callable(game, "source_mathf_lerp_delta"),
	}

static func set_construct_state(previous_block: Variant, block: Variant, build_cost_multiplier: float) -> Dictionary:
	var block_is_null: bool = block == null
	var requirements: Array = []
	var build_time: float = 0.0
	if not block_is_null and block is Dictionary:
		requirements = block.get("requirements", [])
		build_time = float(block.get("buildTime", 0.0))
	var items_left: Array[int] = []
	var accumulator: Array[float] = []
	var total_accumulator: Array[float] = []
	for requirement in requirements:
		if requirement is Dictionary:
			items_left.append(int(round(float(requirement.get("amount", 0)) * build_cost_multiplier)))
		else:
			items_left.append(0)
		accumulator.append(0.0)
		total_accumulator.append(0.0)
	return {
		"source_owner": "PortGame.construct_build_set_construct_state",
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
		"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
		"set_construct_method": "public void setConstruct(Block previous, Block block){",
		"set_construct_null_guard_expr": "if(block == null) return;",
		"construct_color_expr": "this.constructColor = 0f;",
		"was_constructing_expr": "this.wasConstructing = true;",
		"current_expr": "this.current = block;",
		"previous_expr": "this.previous = previous;",
		"build_cost_expr": "this.buildCost = block.buildTime * state.rules.buildCostMultiplier;",
		"items_left_expr": "this.itemsLeft = new int[block.requirements.length];",
		"accumulator_expr": "this.accumulator = new float[block.requirements.length];",
		"total_accumulator_expr": "this.totalAccumulator = new float[block.requirements.length];",
		"requirements_loop_expr": "for(int i = 0; i < requirements.length; i++){",
		"items_left_round_expr": "this.itemsLeft[i] = Mathf.round(requirements[i].amount * state.rules.buildCostMultiplier);",
		"pathfinder_expr": "pathfinder.updateTile(tile);",
		"returned_early": block_is_null,
		"construct_color": 0.0,
		"was_constructing": true,
		"current": block,
		"previous": previous_block,
		"build_cost": build_time * build_cost_multiplier,
		"items_left": items_left,
		"accumulator": accumulator,
		"total_accumulator": total_accumulator,
		"pathfinder_update_tile_called": not block_is_null,
		"requirement_count": requirements.size(),
		"build_cost_multiplier": build_cost_multiplier,
	}

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
		"source_owner": "PortGame.construct_build_set_deconstruct_state",
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
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

static func check_required_state(requirements: Array, inventory: Dictionary, accumulator: Array, items_left: Array, amount: float, remove: bool, build_cost_multiplier: float, team_infinite_resources: bool, state_infinite_resources: bool) -> Dictionary:
	var max_progress: float = amount
	var infinite: bool = team_infinite_resources or state_infinite_resources
	var accumulator_after: Array = accumulator.duplicate()
	var items_left_after: Array = items_left.duplicate()
	var inventory_after: Dictionary = inventory.duplicate()
	var per_requirement: Array = []
	for i in range(requirements.size()):
		var requirement: Variant = requirements[i]
		var item: String = ""
		var requirement_amount: float = 0.0
		if requirement is Dictionary:
			item = str(requirement.get("item", ""))
			requirement_amount = float(requirement.get("amount", 0.0))
		var items_left_value: int = int(items_left_after[i]) if i < items_left_after.size() else 0
		if items_left_value == 0:
			per_requirement.append({"index": i, "item": item, "skipped_items_left_zero": true})
			continue
		var sclamount: int = int(round(build_cost_multiplier * requirement_amount))
		var required: int = int(accumulator_after[i]) if i < accumulator_after.size() else 0
		var inventory_amount: int = int(inventory_after.get(item, 0))
		var max_use_value: int = 0
		var fraction: float = 1.0
		var inventory_empty_blocked: bool = false
		var removed_from_inventory: bool = false
		if inventory_amount == 0 and sclamount != 0:
			max_progress = 0.0
			inventory_empty_blocked = true
		elif required > 0:
			var max_use: int = min(required, inventory_amount)
			max_use_value = max_use
			fraction = float(max_use) / float(required)
			max_progress = min(max_progress, max_progress * fraction)
			if i < accumulator_after.size():
				accumulator_after[i] = float(accumulator_after[i]) - float(max_use)
			if remove and not infinite:
				inventory_after[item] = inventory_amount - max_use
				if i < items_left_after.size():
					items_left_after[i] = int(items_left_after[i]) - max_use
				removed_from_inventory = true
		per_requirement.append({
			"index": i,
			"item": item,
			"sclamount": sclamount,
			"required": required,
			"inventory_amount": inventory_amount,
			"max_use": max_use_value,
			"fraction": fraction,
			"inventory_empty_blocked": inventory_empty_blocked,
			"removed_from_inventory": removed_from_inventory,
		})
	return {
		"source_owner": "PortGame.construct_build_check_required_state",
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
		"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
		"check_required_method": "private float checkRequired(ItemModule inventory, float amount, boolean remove){",
		"max_progress_expr": "float maxProgress = amount;",
		"infinite_expr": "boolean infinite = team.rules().infiniteResources || state.rules.infiniteResources;",
		"requirements_loop_expr": "for(int i = 0; i < current.requirements.length; i++){",
		"items_left_zero_guard_expr": "if(itemsLeft[i] == 0){",
		"continue_expr": "continue;",
		"sclamount_expr": "int sclamount = Math.round(state.rules.buildCostMultiplier * current.requirements[i].amount);",
		"required_expr": "int required = (int)(accumulator[i]);",
		"inventory_empty_guard_expr": "if(inventory.get(current.requirements[i].item) == 0 && sclamount != 0){",
		"max_progress_zero_expr": "maxProgress = 0f;",
		"positive_required_guard_expr": "}else if(required > 0){",
		"max_use_expr": "int maxUse = Math.min(required, inventory.get(current.requirements[i].item));",
		"fraction_expr": "float fraction = maxUse / (float)required;",
		"max_progress_fraction_expr": "maxProgress = Math.min(maxProgress, maxProgress * fraction);",
		"accumulator_subtract_expr": "accumulator[i] -= maxUse;",
		"remove_guard_expr": "if(remove && !infinite){",
		"inventory_remove_expr": "inventory.remove(current.requirements[i].item, maxUse);",
		"items_left_subtract_expr": "itemsLeft[i] -= maxUse;",
		"return_expr": "return maxProgress;",
		"requirements": requirements,
		"inventory": inventory,
		"inventory_after": inventory_after,
		"accumulator": accumulator,
		"accumulator_after": accumulator_after,
		"items_left": items_left,
		"items_left_after": items_left_after,
		"amount": amount,
		"remove": remove,
		"build_cost_multiplier": build_cost_multiplier,
		"team_infinite_resources": team_infinite_resources,
		"state_infinite_resources": state_infinite_resources,
		"infinite": infinite,
		"max_progress": max_progress,
		"per_requirement": per_requirement,
	}

static func construct_state(previous_block: Variant, current_block: Variant, builder_state: Variant, core_inventory: Dictionary, amount: float, config: Variant, progress_before: float, accumulator: Variant, total_accumulator: Variant, items_left: Variant, build_cost_multiplier: float, core_present: bool, team_infinite_resources: bool, state_infinite_resources: bool, builder_is_player: bool, last_builder_present: bool, net_client: bool, rotation_value: int) -> Dictionary:
	var requirements: Array = current_block.get("requirements", []) if current_block is Dictionary else []
	if accumulator == null or total_accumulator == null:
		return {
			"source_owner": "PortGame.construct_build_construct_state",
			"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
			"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
			"construct_method": "public void construct(Unit builder, @Nullable Building core, float amount, Object config){",
			"accumulator_null_guard_expr": "if(accumulator == null || totalAccumulator == null) return;",
			"returned_early": true,
		}
	var accumulator_after: Array = accumulator.duplicate()
	var total_accumulator_after: Array = total_accumulator.duplicate()
	var items_left_after: Array = items_left.duplicate() if items_left is Array else []
	var core_inventory_after: Dictionary = core_inventory.duplicate()
	var set_construct_called: bool = requirements.size() != accumulator_after.size() or total_accumulator_after.size() != requirements.size()
	var set_construct: Dictionary = {}
	if set_construct_called:
		set_construct = set_construct_state(previous_block, current_block, build_cost_multiplier)
		accumulator_after = set_construct.get("accumulator", [])
		total_accumulator_after = set_construct.get("total_accumulator", [])
		items_left_after = set_construct.get("items_left", [])
	var infinite: bool = team_infinite_resources or state_infinite_resources
	var first_check_required_state: Dictionary = {}
	var first_check_required_called: bool = core_present and not team_infinite_resources
	var max_progress: float = amount
	if first_check_required_called:
		var first_check_required := check_required_state(requirements, core_inventory_after, accumulator_after, items_left_after, amount, false, build_cost_multiplier, team_infinite_resources, state_infinite_resources)
		first_check_required_state = first_check_required
		max_progress = float(first_check_required.get("max_progress", max_progress))
		accumulator_after = first_check_required.get("accumulator_after", accumulator_after)
		items_left_after = first_check_required.get("items_left_after", items_left_after)
		core_inventory_after = first_check_required.get("inventory_after", core_inventory_after)
	var progress_steps: Array = []
	for i in range(requirements.size()):
		var requirement: Variant = requirements[i]
		var requirement_amount: float = float(requirement.get("amount", 0.0)) if requirement is Dictionary else 0.0
		var reqamount: int = int(round(build_cost_multiplier * requirement_amount))
		var current_total: float = float(total_accumulator_after[i]) if i < total_accumulator_after.size() else 0.0
		var current_accumulator: float = float(accumulator_after[i]) if i < accumulator_after.size() else 0.0
		var accumulator_delta: float = min(float(reqamount) * max_progress, float(reqamount) - current_total)
		if i < accumulator_after.size():
			accumulator_after[i] = current_accumulator + accumulator_delta
		if i < total_accumulator_after.size():
			total_accumulator_after[i] = min(current_total + float(reqamount) * max_progress, float(reqamount))
		progress_steps.append({
			"index": i,
			"reqamount": reqamount,
			"accumulator_delta": accumulator_delta,
			"accumulator_after": accumulator_after[i] if i < accumulator_after.size() else 0.0,
			"total_accumulator_after": total_accumulator_after[i] if i < total_accumulator_after.size() else 0.0,
		})
	var second_check_required_state: Dictionary = {}
	var second_check_required_called: bool = core_present and not team_infinite_resources
	if second_check_required_called:
		var second_check_required := check_required_state(requirements, core_inventory_after, accumulator_after, items_left_after, max_progress, true, build_cost_multiplier, team_infinite_resources, state_infinite_resources)
		second_check_required_state = second_check_required
		max_progress = float(second_check_required.get("max_progress", max_progress))
		accumulator_after = second_check_required.get("accumulator_after", accumulator_after)
		items_left_after = second_check_required.get("items_left_after", items_left_after)
		core_inventory_after = second_check_required.get("inventory_after", core_inventory_after)
	var progress_after: float = progress_before
	progress_after = clampf(progress_before + max_progress, 0.0, 1.0)
	var finish_gate: bool = progress_after >= 1.0 or state_infinite_resources
	var can_finish: bool = true
	var leftover_steps: Array = []
	if finish_gate and not infinite:
		for i in range(items_left_after.size()):
			var item_left: int = int(items_left_after[i])
			if item_left <= 0:
				leftover_steps.append({"index": i, "items_left": item_left, "skipped": true})
				continue
			var requirement: Variant = requirements[i] if i < requirements.size() else {}
			var item: String = str(requirement.get("item", "")) if requirement is Dictionary else ""
			var inventory_amount: int = int(core_inventory_after.get(item, 0))
			if core_present and inventory_amount >= item_left:
				core_inventory_after[item] = inventory_amount - item_left
				items_left_after[i] = 0
				leftover_steps.append({"index": i, "item": item, "removed": item_left, "can_finish": true})
			else:
				can_finish = false
				leftover_steps.append({"index": i, "item": item, "required": item_left, "available": inventory_amount, "can_finish": false})
				break
	var last_builder_after_present: bool = last_builder_present or builder_is_player or (finish_gate and can_finish)
	var constructed_called: bool = finish_gate and can_finish and not net_client
	var constructed_call: Variant = null
	if constructed_called:
		constructed_call = {"call": "constructed(tile, current, lastBuilder, (byte)rotation, builder.team, config);", "rotation": rotation_value, "config": config}
	return {
		"source_owner": "PortGame.construct_build_construct_state",
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
		"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
		"construct_method": "public void construct(Unit builder, @Nullable Building core, float amount, Object config){",
		"accumulator_null_guard_expr": "if(accumulator == null || totalAccumulator == null) return;",
		"was_constructing_expr": "wasConstructing = true;",
		"active_deconstruct_expr": "activeDeconstruct = false;",
		"builder_player_guard_expr": "if(builder.isPlayer()){",
		"last_builder_expr": "lastBuilder = builder;",
		"last_config_expr": "lastConfig = config;",
		"length_mismatch_guard_expr": "if(current.requirements.length != accumulator.length || totalAccumulator.length != current.requirements.length){",
		"set_construct_expr": "setConstruct(previous, current);",
		"infinite_expr": "boolean infinite = team.rules().infiniteResources || state.rules.infiniteResources;",
		"first_max_progress_expr": "float maxProgress = core == null || team.rules().infiniteResources ? amount : checkRequired(core.items, amount, false);",
		"progress_loop_expr": "for(int i = 0; i < current.requirements.length; i++){",
		"reqamount_expr": "int reqamount = Math.round(state.rules.buildCostMultiplier * current.requirements[i].amount);",
		"accumulator_progress_expr": "accumulator[i] += Math.min(reqamount * maxProgress, reqamount - totalAccumulator[i]);",
		"total_accumulator_progress_expr": "totalAccumulator[i] = Math.min(totalAccumulator[i] + reqamount * maxProgress, reqamount);",
		"second_max_progress_expr": "maxProgress = core == null || team.rules().infiniteResources ? maxProgress : checkRequired(core.items, maxProgress, true);",
		"progress_expr": "progress = Mathf.clamp(progress + maxProgress);",
		"finish_guard_expr": "if(progress >= 1f || state.rules.infiniteResources){",
		"can_finish_expr": "boolean canFinish = true;",
		"leftover_guard_expr": "if(itemsLeft[i] > 0){",
		"core_has_expr": "if(core != null && core.items.has(current.requirements[i].item, itemsLeft[i])){",
		"core_remove_expr": "core.items.remove(current.requirements[i].item, itemsLeft[i]);",
		"items_left_zero_expr": "itemsLeft[i] = 0;",
		"can_finish_false_expr": "canFinish = false;",
		"last_builder_fallback_expr": "if(lastBuilder == null) lastBuilder = builder;",
		"net_client_guard_expr": "if(!net.client()){",
		"constructed_expr": "constructed(tile, current, lastBuilder, (byte)rotation, builder.team, config);",
		"returned_early": false,
		"requirements": requirements,
		"previous_block": previous_block,
		"current_block": current_block,
		"builder_state": builder_state,
		"amount": amount,
		"config": config,
		"progress_before": progress_before,
		"progress_after": progress_after,
		"max_progress": max_progress,
		"was_constructing": true,
		"active_deconstruct": false,
		"builder_is_player": builder_is_player,
		"last_builder_present_before": last_builder_present,
		"last_builder_present_after": last_builder_after_present,
		"last_config": config,
		"set_construct_called": set_construct_called,
		"set_construct": set_construct,
		"infinite": infinite,
		"first_check_required_called": first_check_required_called,
		"first_check_required": first_check_required_state,
		"progress_steps": progress_steps,
		"second_check_required_called": second_check_required_called,
		"second_check_required": second_check_required_state,
		"accumulator_after": accumulator_after,
		"total_accumulator_after": total_accumulator_after,
		"items_left_after": items_left_after,
		"core_inventory_after": core_inventory_after,
		"finish_gate": finish_gate,
		"can_finish": can_finish,
		"leftover_steps": leftover_steps,
		"net_client": net_client,
		"constructed_called": constructed_called,
		"constructed_call": constructed_call,
	}

static func deconstruct_state(current_block: Variant, builder_state: Variant, core_inventory: Dictionary, amount: float, progress_before: float, accumulator: Variant, total_accumulator: Variant, items_left: Variant, build_cost_multiplier: float, deconstruct_refund_multiplier: float, core_present: bool, state_infinite_resources: bool, builder_is_player: bool, was_constructing: bool, last_builder_present: bool, core_storage_capacity: int) -> Dictionary:
	var requirements: Array = current_block.get("requirements", []) if current_block is Dictionary else []
	if accumulator == null or total_accumulator == null:
		return {
			"source_owner": "PortGame.construct_build_deconstruct_state",
			"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
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
		"source_owner": "PortGame.construct_build_deconstruct_state",
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
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

static func progress_state(progress_value: float) -> Dictionary:
	return {
		"source_owner": "PortGame.construct_build_progress_state",
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
		"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
		"progress_method": "public float progress(){",
		"progress_return_expr": "return progress;",
		"progress": progress_value,
	}

static func version_state() -> Dictionary:
	return {
		"source_owner": "PortGame.construct_build_version_state",
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
		"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
		"version_method": "public byte version(){",
		"version_return_expr": "return 1;",
		"version": 1,
	}

static func write_state(progress_value: float, previous_block_id: int, current_block_id: int, accumulator: Variant, total_accumulator: Variant, items_left: Variant) -> Dictionary:
	var write_calls: Array = []
	write_calls.append({"op": "super.write", "value": null})
	write_calls.append({"op": "f", "value": progress_value})
	write_calls.append({"op": "s", "value": previous_block_id})
	write_calls.append({"op": "s", "value": current_block_id})
	var accumulator_is_null: bool = accumulator == null
	var accumulator_length: int = -1
	var entry_writes: Array = []
	if accumulator_is_null:
		write_calls.append({"op": "b", "value": -1})
	else:
		accumulator_length = accumulator.size()
		write_calls.append({"op": "b", "value": accumulator_length})
		for i in range(accumulator_length):
			var accumulator_value: float = float(accumulator[i])
			var total_accumulator_value: float = float(total_accumulator[i]) if total_accumulator is Array and i < total_accumulator.size() else 0.0
			var items_left_value: int = int(items_left[i]) if items_left is Array and i < items_left.size() else 0
			write_calls.append({"op": "f", "value": float(accumulator[i])})
			write_calls.append({"op": "f", "value": total_accumulator_value})
			write_calls.append({"op": "i", "value": items_left_value})
			entry_writes.append({
				"index": i,
				"accumulator": accumulator_value,
				"total_accumulator": total_accumulator_value,
				"items_left": items_left_value,
			})
	return {
		"source_owner": "PortGame.construct_build_write_state",
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
		"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
		"write_method": "public void write(Writes write){",
		"super_write_expr": "super.write(write);",
		"write_progress_expr": "write.f(progress);",
		"write_previous_expr": "write.s(previous.id);",
		"write_current_expr": "write.s(current.id);",
		"accumulator_null_guard_expr": "if(accumulator == null){",
		"write_null_size_expr": "write.b(-1);",
		"write_size_expr": "write.b(accumulator.length);",
		"write_loop_expr": "for(int i = 0; i < accumulator.length; i++){",
		"write_accumulator_expr": "write.f(accumulator[i]);",
		"write_total_accumulator_expr": "write.f(totalAccumulator[i]);",
		"write_items_left_expr": "write.i(itemsLeft[i]);",
		"progress": progress_value,
		"previous_block_id": previous_block_id,
		"current_block_id": current_block_id,
		"accumulator_is_null": accumulator_is_null,
		"accumulator_length": accumulator_length,
		"entry_writes": entry_writes,
		"write_calls": write_calls,
	}

static func _lookup_content_block(content_blocks: Dictionary, block_id: int) -> Variant:
	if content_blocks.has(block_id):
		return content_blocks.get(block_id, null)
	return content_blocks.get(str(block_id), null)

static func read_state(progress_value: float, previous_block_id: int, current_block_id: int, accumulator_size: int, accumulator_values: Array, total_accumulator_values: Array, items_left_values: Array, revision_value: int, content_blocks: Dictionary, air_block: Variant, build_cost_multiplier: float) -> Dictionary:
	var accumulator_after: Variant = null
	var total_accumulator_after: Variant = null
	var items_left_after: Variant = null
	var entry_reads: Array = []
	if accumulator_size != -1:
		accumulator_after = []
		total_accumulator_after = []
		items_left_after = []
		for i in range(accumulator_size):
			var accumulator_value: float = float(accumulator_values[i]) if i < accumulator_values.size() else 0.0
			var total_accumulator_value: float = float(total_accumulator_values[i]) if i < total_accumulator_values.size() else 0.0
			var items_left_value: int = 0
			if revision_value >= 1:
				items_left_value = int(items_left_values[i]) if i < items_left_values.size() else 0
			accumulator_after.append(accumulator_value)
			total_accumulator_after.append(total_accumulator_value)
			items_left_after.append(items_left_value)
			entry_reads.append({
				"index": i,
				"accumulator": accumulator_value,
				"total_accumulator": total_accumulator_value,
				"items_left": items_left_value,
				"items_left_read": revision_value >= 1,
			})
	var previous_after: Variant = _lookup_content_block(content_blocks, previous_block_id) if previous_block_id != -1 else null
	var current_after: Variant = _lookup_content_block(content_blocks, current_block_id) if current_block_id != -1 else null
	var previous_defaulted_to_air: bool = previous_after == null
	var current_defaulted_to_air: bool = current_after == null
	if previous_defaulted_to_air:
		previous_after = air_block
	if current_defaulted_to_air:
		current_after = air_block
	var current_build_time: float = float(current_after.get("buildTime", 0.0)) if current_after is Dictionary else 0.0
	return {
		"source_owner": "PortGame.construct_build_read_state",
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
		"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
		"read_method": "public void read(Reads read, byte revision){",
		"super_read_expr": "super.read(read, revision);",
		"read_progress_expr": "progress = read.f();",
		"read_previous_expr": "short pid = read.s();",
		"read_current_expr": "short rid = read.s();",
		"read_accumulator_size_expr": "byte acsize = read.b();",
		"acsize_guard_expr": "if(acsize != -1){",
		"accumulator_alloc_expr": "accumulator = new float[acsize];",
		"total_accumulator_alloc_expr": "totalAccumulator = new float[acsize];",
		"items_left_alloc_expr": "itemsLeft = new int[acsize];",
		"read_loop_expr": "for(int i = 0; i < acsize; i++){",
		"read_accumulator_expr": "accumulator[i] = read.f();",
		"read_total_accumulator_expr": "totalAccumulator[i] = read.f();",
		"revision_items_left_guard_expr": "if(revision >= 1){",
		"read_items_left_expr": "itemsLeft[i] = read.i();",
		"previous_lookup_expr": "if(pid != -1) previous = content.block(pid);",
		"current_lookup_expr": "if(rid != -1) current = content.block(rid);",
		"previous_air_expr": "if(previous == null) previous = Blocks.air;",
		"current_air_expr": "if(current == null) current = Blocks.air;",
		"build_cost_expr": "buildCost = current.buildTime * state.rules.buildCostMultiplier;",
		"progress": progress_value,
		"previous_block_id": previous_block_id,
		"current_block_id": current_block_id,
		"accumulator_size": accumulator_size,
		"revision": revision_value,
		"accumulator_after": accumulator_after,
		"total_accumulator_after": total_accumulator_after,
		"items_left_after": items_left_after,
		"entry_reads": entry_reads,
		"previous": previous_after,
		"current": current_after,
		"previous_defaulted_to_air": previous_defaulted_to_air,
		"current_defaulted_to_air": current_defaulted_to_air,
		"build_cost": current_build_time * build_cost_multiplier,
		"build_cost_multiplier": build_cost_multiplier,
	}

static func _block_identity(block: Variant) -> Variant:
	if block is Dictionary:
		if block.has("id"):
			return block.get("id")
		if block.has("name"):
			return block.get("name")
	return block

static func _blocks_match(left_block: Variant, right_block: Variant) -> bool:
	return _block_identity(left_block) == _block_identity(right_block)

static func draw_state(current_block: Variant, previous_block: Variant, air_block: Variant, source_x: float, source_y: float, rotation_degrees: float, progress_value: float, construct_color: float, source_time: float) -> Dictionary:
	var current_is_air: bool = _blocks_match(current_block, air_block)
	var previous_full_icon: Variant = previous_block.get("fullIcon", null) if previous_block is Dictionary else null
	var previous_full_icon_found: bool = bool(previous_block.get("fullIconFound", false)) if previous_block is Dictionary else false
	var previous_rotate: bool = bool(previous_block.get("rotate", false)) if previous_block is Dictionary else false
	var previous_drawn: bool = not current_is_air and not _blocks_match(previous_block, current_block) and not _blocks_match(previous_block, air_block) and previous_full_icon_found
	var previous_rect_call: Dictionary = {}
	if previous_drawn:
		previous_rect_call = {
			"call": "Draw.rect(previous.fullIcon, x, y, previous.rotate ? rotdeg() : 0);",
			"region": previous_full_icon,
			"x": source_x,
			"y": source_y,
			"rotation": rotation_degrees if previous_rotate else 0.0,
		}
	var generated_icons: Array = current_block.get("generatedIcons", []) if current_block is Dictionary else []
	var region_rotated_1: int = int(current_block.get("regionRotated1", -1)) if current_block is Dictionary else -1
	var region_rotated_2: int = int(current_block.get("regionRotated2", -1)) if current_block is Dictionary else -1
	var current_rotate: bool = bool(current_block.get("rotate", false)) if current_block is Dictionary else false
	var visual_rotation_offset: float = float(current_block.get("visualRotationOffset", 0.0)) if current_block is Dictionary else 0.0
	var no_overrides: bool = region_rotated_1 == -1 and region_rotated_2 == -1
	var icon_draws: Array = []
	if not current_is_air:
		for i in range(generated_icons.size()):
			var region: Variant = generated_icons[i]
			var rotate_icon: bool = current_rotate and (no_overrides or region_rotated_2 == i or region_rotated_1 == i)
			var icon_rotation: float = rotation_degrees + visual_rotation_offset if rotate_icon else 0.0
			icon_draws.append({
				"index": i,
				"region": region,
				"shader_region": region,
				"shader_time": source_time,
				"shader_progress": progress_value,
				"rotate_icon": rotate_icon,
				"rect_call": {
					"call": "Draw.rect(region, x, y, current.rotate && (noOverrides || current.regionRotated2 == i || current.regionRotated1 == i) ? rotdeg() + current.visualRotationOffset : 0);",
					"region": region,
					"x": source_x,
					"y": source_y,
					"rotation": icon_rotation,
				},
				"flush_call": {"call": "Draw.flush();"},
			})
	return {
		"source_owner": "PortGame.construct_build_draw_state",
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
		"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
		"draw_method": "public void draw(){",
		"air_guard_comment": "//do not draw air",
		"air_guard_expr": "if(current == Blocks.air) return;",
		"previous_draw_guard_expr": "if(previous != current && previous != Blocks.air && previous.fullIcon.found()){",
		"previous_rect_expr": "Draw.rect(previous.fullIcon, x, y, previous.rotate ? rotdeg() : 0);",
		"draw_layer_expr": "Draw.draw(Layer.blockBuilding, () -> {",
		"draw_color_expr": "Draw.color(Pal.accent, Pal.remove, constructColor);",
		"no_overrides_expr": "boolean noOverrides = current.regionRotated1 == -1 && current.regionRotated2 == -1;",
		"icon_loop_expr": "for(TextureRegion region : current.getGeneratedIcons()){",
		"shader_region_expr": "Shaders.blockbuild.region = region;",
		"shader_time_expr": "Shaders.blockbuild.time = Time.time;",
		"shader_progress_expr": "Shaders.blockbuild.progress = progress;",
		"current_rect_expr": "Draw.rect(region, x, y, current.rotate && (noOverrides || current.regionRotated2 == i || current.regionRotated1 == i) ? rotdeg() + current.visualRotationOffset : 0);",
		"flush_expr": "Draw.flush();",
		"draw_color_reset_expr": "Draw.color();",
		"current_block": current_block,
		"previous_block": previous_block,
		"air_block": air_block,
		"current_is_air": current_is_air,
		"returned_early": current_is_air,
		"source_x": source_x,
		"source_y": source_y,
		"rotation_degrees": rotation_degrees,
		"progress": progress_value,
		"construct_color": construct_color,
		"source_time": source_time,
		"previous_full_icon_found": previous_full_icon_found,
		"previous_drawn": previous_drawn,
		"previous_rect_call": previous_rect_call,
		"draw_layer_called": not current_is_air,
		"draw_layer": "Layer.blockBuilding",
		"draw_color_call": {"from": "Pal.accent", "to": "Pal.remove", "t": construct_color} if not current_is_air else {},
		"region_rotated_1": region_rotated_1,
		"region_rotated_2": region_rotated_2,
		"no_overrides": no_overrides,
		"generated_icons": generated_icons,
		"icon_draws": icon_draws,
		"draw_color_reset_called": not current_is_air,
	}

static func inner_runtime_state(current_solid: bool, previous_solid: bool, interactable_with_player_team: bool, current_is_placeable: bool, player_is_builder: bool, build_was_auto_paused: bool, input_is_building: bool, tile_x: int, tile_y: int, rotation: int, current_block: Variant, last_config: Variant, sensor: String, progress: float, active_deconstruct: bool, super_sense_value: float, super_sense_object_value: Variant, floor_solid: bool, floor_has_surface: bool, source_x: float, source_y: float, block_size: int, current_is_air: bool, construct_color_before: float, source_delta: float, lerp_delta: Callable) -> Dictionary:
	var display_name_value: String = str(current_block.get("localizedName", "")) if current_block is Dictionary else ""
	var display_icon_value: Variant = current_block.get("fullIcon", "") if current_block is Dictionary else ""
	var check_solid_value: bool = current_solid or previous_solid
	var cursor_value: String = "hand" if interactable_with_player_team else "arrow"
	var tapped_called: bool = current_is_placeable and player_is_builder
	var input_is_building_after: bool = input_is_building
	if tapped_called and build_was_auto_paused and not input_is_building:
		input_is_building_after = true
	var add_build_called: bool = tapped_called
	var sense_value: float = super_sense_value
	if sensor == "progress":
		sense_value = clampf(progress, 0.0, 1.0)
	elif sensor == "breaking":
		sense_value = 1.0 if active_deconstruct else 0.0
	var sense_object_value: Variant = super_sense_object_value
	if sensor == "building":
		sense_object_value = current_block
	var on_destroyed_smoke_called: bool = true
	var on_destroyed_rubble_called: bool = not floor_solid and floor_has_surface
	var update_tile_remove_called: bool = current_is_air
	var construct_color_target: float = 1.0 if active_deconstruct else 0.0
	var construct_color_after: float = float(lerp_delta.call(construct_color_before, construct_color_target, CONSTRUCT_BUILD_COLOR_LERP_PROGRESS, source_delta))
	var update_tile_reset_called: bool = true
	return {
		"source_owner": "PortGame.construct_build_inner_runtime_state",
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
		"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
		"display_name_method": "public String getDisplayName(){",
		"display_icon_method": "public TextureRegion getDisplayIcon(){",
		"check_solid_method": "public boolean checkSolid(){",
		"check_solid_return_expr": "return current.solid || previous.solid;",
		"cursor_method": "public Cursor getCursor(){",
		"cursor_return_expr": "return interactable(player.team()) ? SystemCursor.hand : SystemCursor.arrow;",
		"tapped_method": "public void tapped(){",
		"tapped_guard_expr": "if(current.isPlaceable() && player.isBuilder()){",
		"autopause_guard_expr": "if(control.input.buildWasAutoPaused && !control.input.isBuilding){",
		"add_build_expr": "player.unit().addBuild(new BuildPlan(tile.x, tile.y, rotation, current, lastConfig), false);",
		"sense_method": "public double sense(LAccess sensor){",
		"progress_case_expr": "case progress -> Mathf.clamp(progress);",
		"breaking_case_expr": "case breaking -> activeDeconstruct ? 1 : 0;",
		"sense_object_method": "public Object senseObject(LAccess sensor){",
		"building_case_expr": "case building -> current;",
		"on_destroyed_method": "public void onDestroyed(){",
		"smoke_expr": "Fx.blockExplosionSmoke.at(tile);",
		"rubble_guard_expr": "if(!tile.floor().solid && tile.floor().hasSurface()){",
		"rubble_expr": "Effect.rubble(x, y, size);",
		"update_tile_method": "public void updateTile(){",
		"air_remove_guard_expr": "if(current == Blocks.air){",
		"remove_expr": "remove();",
		"construct_color_expr": "constructColor = Mathf.lerpDelta(constructColor, activeDeconstruct ? 1f : 0f, 0.2f);",
		"active_deconstruct_reset_expr": "activeDeconstruct = false;",
		"display_name": display_name_value,
		"display_icon": display_icon_value,
		"check_solid": check_solid_value,
		"cursor": cursor_value,
		"tapped_called": tapped_called,
		"input_is_building_after": input_is_building_after,
		"add_build_called": add_build_called,
		"sense_value": sense_value,
		"sense_object_value": sense_object_value,
		"on_destroyed_smoke_called": on_destroyed_smoke_called,
		"on_destroyed_rubble_called": on_destroyed_rubble_called,
		"update_tile_remove_called": update_tile_remove_called,
		"construct_color_before": construct_color_before,
		"construct_color_target": construct_color_target,
		"construct_color_after": construct_color_after,
		"update_tile_reset_called": update_tile_reset_called,
		"current_solid": current_solid,
		"previous_solid": previous_solid,
		"interactable_with_player_team": interactable_with_player_team,
		"current_is_placeable": current_is_placeable,
		"player_is_builder": player_is_builder,
		"build_was_auto_paused": build_was_auto_paused,
		"input_is_building": input_is_building,
		"tile_x": tile_x,
		"tile_y": tile_y,
		"rotation": rotation,
		"current_block": current_block,
		"last_config": last_config,
		"sensor": sensor,
		"progress": progress,
		"active_deconstruct": active_deconstruct,
		"super_sense_value": super_sense_value,
		"super_sense_object_value": super_sense_object_value,
		"floor_solid": floor_solid,
		"floor_has_surface": floor_has_surface,
		"source_x": source_x,
		"source_y": source_y,
		"block_size": block_size,
		"current_is_air": current_is_air,
		"source_delta": source_delta,
	}
