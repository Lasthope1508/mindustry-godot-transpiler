extends RefCounted
class_name SourceConstructBuildWorkState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_construct_block_source_text_state := preload("res://src/game/SourceConstructBlockSourceTextState.gd")
const source_construct_build_deconstruct_work_state := preload("res://src/game/SourceConstructBuildDeconstructWorkState.gd")

const SOURCE_CONSTRUCT_BLOCK_SOURCE := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_SOURCE
const SOURCE_CONSTRUCT_BUILD_CLASS_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BUILD_CLASS_EXPR
const CONSTRUCT_BUILD_CLASS_EXPR := SOURCE_CONSTRUCT_BUILD_CLASS_EXPR

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
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BUILD_SET_CONSTRUCT_STATE,
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
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
	return source_construct_build_deconstruct_work_state.set_deconstruct_state(previous_block, build_cost_multiplier)

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
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BUILD_CHECK_REQUIRED_STATE,
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
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
			"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BUILD_CONSTRUCT_STATE,
			"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
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
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BUILD_CONSTRUCT_STATE,
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
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
	return source_construct_build_deconstruct_work_state.deconstruct_state(current_block, builder_state, core_inventory, amount, progress_before, accumulator, total_accumulator, items_left, build_cost_multiplier, deconstruct_refund_multiplier, core_present, state_infinite_resources, builder_is_player, was_constructing, last_builder_present, core_storage_capacity)
