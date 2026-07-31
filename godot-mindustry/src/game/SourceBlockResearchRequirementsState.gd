extends RefCounted
class_name SourceBlockResearchRequirementsState

const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_ui_defaults := preload("res://src/game/SourceUiDefaults.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const BLOCK_GENERATED_CLASS := "res://src/generated/classes/mindustry/world/Block.gd"
const SOURCE_BLOCK_RESEARCH_REQUIREMENTS_BASE_QUANTITY := source_block_defaults.RESEARCH_REQUIREMENTS_BASE_QUANTITY
const SOURCE_BLOCK_RESEARCH_REQUIREMENTS_AMOUNT_EXPONENT := source_block_defaults.RESEARCH_REQUIREMENTS_AMOUNT_EXPONENT
const SOURCE_BLOCK_RESEARCH_REQUIREMENTS_AMOUNT_SCALE := source_block_defaults.RESEARCH_REQUIREMENTS_AMOUNT_SCALE
const SOURCE_BLOCK_RESEARCH_REQUIREMENTS_ROUND_STEP := source_block_defaults.RESEARCH_REQUIREMENTS_ROUND_STEP
const SOURCE_UI_ROUND_AMOUNT_BILLION_THRESHOLD := source_ui_defaults.ROUND_AMOUNT_BILLION_THRESHOLD
const SOURCE_UI_ROUND_AMOUNT_BILLION_STEP := source_ui_defaults.ROUND_AMOUNT_BILLION_STEP
const SOURCE_UI_ROUND_AMOUNT_MILLION_THRESHOLD := source_ui_defaults.ROUND_AMOUNT_MILLION_THRESHOLD
const SOURCE_UI_ROUND_AMOUNT_MILLION_STEP := source_ui_defaults.ROUND_AMOUNT_MILLION_STEP
const SOURCE_UI_ROUND_AMOUNT_TEN_THOUSAND_THRESHOLD := source_ui_defaults.ROUND_AMOUNT_TEN_THOUSAND_THRESHOLD
const SOURCE_UI_ROUND_AMOUNT_TEN_THOUSAND_STEP := source_ui_defaults.ROUND_AMOUNT_TEN_THOUSAND_STEP
const SOURCE_UI_ROUND_AMOUNT_THOUSAND_THRESHOLD := source_ui_defaults.ROUND_AMOUNT_THOUSAND_THRESHOLD
const SOURCE_UI_ROUND_AMOUNT_THOUSAND_STEP := source_ui_defaults.ROUND_AMOUNT_THOUSAND_STEP
const SOURCE_UI_ROUND_AMOUNT_HUNDRED_THRESHOLD := source_ui_defaults.ROUND_AMOUNT_HUNDRED_THRESHOLD
const SOURCE_UI_ROUND_AMOUNT_HUNDRED_STEP := source_ui_defaults.ROUND_AMOUNT_HUNDRED_STEP
const SOURCE_UI_ROUND_AMOUNT_TEN_THRESHOLD := source_ui_defaults.ROUND_AMOUNT_TEN_THRESHOLD
const SOURCE_UI_ROUND_AMOUNT_TEN_STEP := source_ui_defaults.ROUND_AMOUNT_TEN_STEP

static func research_cost_state(research_cost: Variant) -> Dictionary:
	var returned_early: bool = research_cost != null
	var returned_requirements: Variant = research_cost if returned_early else null
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_RESEARCH_REQUIREMENTS_RESEARCH_COST_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public ItemStack[] researchRequirements(){", "override_expr": "@Override", "research_cost_guard_expr": "if(researchCost != null) return researchCost;", "return_expr": "return researchCost;", "research_cost": research_cost, "returned_requirements": returned_requirements, "returned_early": returned_early}

static func empty_state(research_cost: Variant, research_cost_multiplier: float) -> Dictionary:
	var returned_early: bool = research_cost != null
	var returned_requirements: Variant = research_cost if returned_early else null
	var returned_empty: bool = research_cost == null and research_cost_multiplier <= 0.0
	var returned_requirements_after_multiplier: Variant = "ItemStack.empty" if returned_empty else returned_requirements
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_RESEARCH_REQUIREMENTS_EMPTY_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public ItemStack[] researchRequirements(){", "override_expr": "@Override", "research_cost_guard_expr": "if(researchCost != null) return researchCost;", "empty_guard_expr": "if(researchCostMultiplier <= 0f) return ItemStack.empty;", "empty_return_expr": "return ItemStack.empty;", "research_cost": research_cost, "research_cost_multiplier": research_cost_multiplier, "returned_requirements": returned_requirements_after_multiplier, "returned_empty": returned_empty}

static func loop_shape_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array) -> Dictionary:
	var allocation_reached: bool = research_cost == null and research_cost_multiplier > 0.0
	var allocated_out_length: int = requirements.size() if allocation_reached else 0
	var loop_indices: Array = []
	for i in range(allocated_out_length):
		loop_indices.append(i)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_RESEARCH_REQUIREMENTS_LOOP_SHAPE_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public ItemStack[] researchRequirements(){", "override_expr": "@Override", "research_cost_guard_expr": "if(researchCost != null) return researchCost;", "empty_guard_expr": "if(researchCostMultiplier <= 0f) return ItemStack.empty;", "out_alloc_expr": "ItemStack[] out = new ItemStack[requirements.length];", "loop_expr": "for(int i = 0; i < out.length; i++){", "return_out_expr": "return out;", "research_cost": research_cost, "research_cost_multiplier": research_cost_multiplier, "requirements": requirements, "allocation_reached": allocation_reached, "allocated_out_length": allocated_out_length, "loop_indices": loop_indices}

static func quantity_formula_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	var allocation_reached: bool = research_cost == null and research_cost_multiplier > 0.0
	var quantity_values: Array = []
	var multiplier_values: Array = []
	var amount_power_values: Array = []
	for requirement in requirements:
		if not allocation_reached:
			continue
		var item_key: String = str(requirement.get("item", ""))
		var cost_multiplier: float = float(research_cost_multipliers.get(item_key, 1.0))
		var amount_power: float = pow(float(requirement.get("amount", 0.0)), SOURCE_BLOCK_RESEARCH_REQUIREMENTS_AMOUNT_EXPONENT)
		var quantity_float: float = SOURCE_BLOCK_RESEARCH_REQUIREMENTS_BASE_QUANTITY * research_cost_multiplier + amount_power * SOURCE_BLOCK_RESEARCH_REQUIREMENTS_AMOUNT_SCALE * research_cost_multiplier * cost_multiplier
		var quantity: int = int(quantity_float / SOURCE_BLOCK_RESEARCH_REQUIREMENTS_ROUND_STEP) * int(SOURCE_BLOCK_RESEARCH_REQUIREMENTS_ROUND_STEP)
		multiplier_values.append(cost_multiplier)
		amount_power_values.append(amount_power)
		quantity_values.append(quantity)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_RESEARCH_REQUIREMENTS_QUANTITY_FORMULA_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public ItemStack[] researchRequirements(){", "quantity_expr": "int quantity = Mathf.round(60 * researchCostMultiplier + Mathf.pow(requirements[i].amount, 1.11f) * 20 * researchCostMultiplier * researchCostMultipliers.get(requirements[i].item, 1f), 10);", "mathf_round_expr": "Mathf.round(value, 10)", "mathf_round_step_expr": "return (int)(value / step) * step;", "research_cost": research_cost, "research_cost_multiplier": research_cost_multiplier, "requirements": requirements, "research_cost_multipliers": research_cost_multipliers, "quantity_values": quantity_values, "multiplier_values": multiplier_values, "amount_power_values": amount_power_values}

static func round_amount_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	var quantity_values: Array = quantity_formula_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers).get("quantity_values", [])
	var rounded_amount_values: Array = []
	for quantity in quantity_values:
		rounded_amount_values.append(_round_amount(int(quantity)))
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_RESEARCH_REQUIREMENTS_ROUND_AMOUNT_STATE, "source": "core/src/mindustry/world/Block.java", "ui_source": "core/src/mindustry/core/UI.java", "method": "public ItemStack[] researchRequirements(){", "round_amount_expr": "UI.roundAmount(quantity)", "ui_round_amount_method": "public static int roundAmount(int number){", "mathf_round_int_step_expr": "return (value / step) * step;", "quantity_values": quantity_values, "rounded_amount_values": rounded_amount_values}

static func output_fill_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	var round_state := round_amount_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)
	var quantity_values: Array = round_state.get("quantity_values", [])
	var rounded_amount_values: Array = round_state.get("rounded_amount_values", [])
	var output_requirements: Array = []
	for i in range(rounded_amount_values.size()):
		var requirement: Dictionary = requirements[i] if i < requirements.size() else {}
		output_requirements.append({"item": requirement.get("item"), "amount": rounded_amount_values[i]})
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_RESEARCH_REQUIREMENTS_OUTPUT_FILL_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public ItemStack[] researchRequirements(){", "itemstack_fill_expr": "out[i] = new ItemStack(requirements[i].item, UI.roundAmount(quantity));", "return_out_expr": "return out;", "quantity_values": quantity_values, "rounded_amount_values": rounded_amount_values, "output_requirements": output_requirements, "returned_requirements": output_requirements}

static func generated_block_research_requirements_research_cost_bridge_state(research_cost: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(BLOCK_GENERATED_CLASS, "java_method_researchRequirements_118", [research_cost], null)
	var canonical = research_cost_state(research_cost)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_RESEARCH_REQUIREMENTS_RESEARCH_COST_STATE, "generated_owner": "block.java_method_researchRequirements_118", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_research_requirements_empty_bridge_state(research_cost: Variant, research_cost_multiplier: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(BLOCK_GENERATED_CLASS, "java_method_researchRequirements_118", [research_cost, research_cost_multiplier], null)
	var canonical = empty_state(research_cost, research_cost_multiplier)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_RESEARCH_REQUIREMENTS_EMPTY_STATE, "generated_owner": "block.java_method_researchRequirements_118", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_research_requirements_loop_shape_bridge_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(BLOCK_GENERATED_CLASS, "java_method_researchRequirements_118", [research_cost, research_cost_multiplier, requirements], null)
	var canonical = loop_shape_state(research_cost, research_cost_multiplier, requirements)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_RESEARCH_REQUIREMENTS_LOOP_SHAPE_STATE, "generated_owner": "block.java_method_researchRequirements_118", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_research_requirements_quantity_formula_bridge_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(BLOCK_GENERATED_CLASS, "java_method_researchRequirements_118", [research_cost, research_cost_multiplier, requirements, research_cost_multipliers], null)
	var canonical = quantity_formula_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_RESEARCH_REQUIREMENTS_QUANTITY_FORMULA_STATE, "generated_owner": "block.java_method_researchRequirements_118", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_research_requirements_round_amount_bridge_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(BLOCK_GENERATED_CLASS, "java_method_researchRequirements_118", [research_cost, research_cost_multiplier, requirements, research_cost_multipliers, true], null)
	var canonical = round_amount_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_RESEARCH_REQUIREMENTS_ROUND_AMOUNT_STATE, "generated_owner": "block.java_method_researchRequirements_118", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_research_requirements_output_fill_bridge_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(BLOCK_GENERATED_CLASS, "java_method_researchRequirements_118", [research_cost, research_cost_multiplier, requirements, research_cost_multipliers, true, true], null)
	var canonical = output_fill_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_RESEARCH_REQUIREMENTS_OUTPUT_FILL_STATE, "generated_owner": "block.java_method_researchRequirements_118", "result": result, "canonical": canonical, "matches": matches}

static func _round_amount(number: int) -> int:
	if number >= SOURCE_UI_ROUND_AMOUNT_BILLION_THRESHOLD:
		return _round_step_int(number, SOURCE_UI_ROUND_AMOUNT_BILLION_STEP)
	elif number >= SOURCE_UI_ROUND_AMOUNT_MILLION_THRESHOLD:
		return _round_step_int(number, SOURCE_UI_ROUND_AMOUNT_MILLION_STEP)
	elif number >= SOURCE_UI_ROUND_AMOUNT_TEN_THOUSAND_THRESHOLD:
		return _round_step_int(number, SOURCE_UI_ROUND_AMOUNT_TEN_THOUSAND_STEP)
	elif number >= SOURCE_UI_ROUND_AMOUNT_THOUSAND_THRESHOLD:
		return _round_step_int(number, SOURCE_UI_ROUND_AMOUNT_THOUSAND_STEP)
	elif number >= SOURCE_UI_ROUND_AMOUNT_HUNDRED_THRESHOLD:
		return _round_step_int(number, SOURCE_UI_ROUND_AMOUNT_HUNDRED_STEP)
	elif number >= SOURCE_UI_ROUND_AMOUNT_TEN_THRESHOLD:
		return _round_step_int(number, SOURCE_UI_ROUND_AMOUNT_TEN_STEP)
	return number

static func _round_step_int(value: int, step: int) -> int:
	return int(float(value) / float(step)) * step
