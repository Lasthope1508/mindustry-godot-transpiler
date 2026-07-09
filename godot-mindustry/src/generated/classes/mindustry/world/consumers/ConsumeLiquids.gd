# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeLiquids.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeLiquids"
const JAVA_EXTENDS := "Consume"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "liquids", "type": "LiquidStack"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeLiquids", "parameters": [{"name": "liquids", "type": "LiquidStack", "varargs": false}]}, {"modifiers": ["protected"], "name": "ConsumeLiquids", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "efficiency", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_apply_0(_args: Array = []) -> Variant:
	var block_has_liquids_before: bool = bool(_args[0] if _args.size() > 0 else false)
	var liquid_filter_before: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var liquid_ids: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []
	var liquid_filter_after: Array = liquid_filter_before.duplicate()
	for liquid_id in liquid_ids:
		liquid_filter_after[int(liquid_id)] = true
	return {"source_owner": "PortGame.source_consume_liquids_apply_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquids.java", "method": "public void apply(Block block){", "has_liquids_assignment_expr": "block.hasLiquids = true;", "loop_expr": "for(var stack : liquids){", "liquid_filter_assignment_expr": "block.liquidFilter[stack.liquid.id] = true;", "block_has_liquids_before": block_has_liquids_before, "block_has_liquids_after": true, "liquid_filter_before": liquid_filter_before, "liquid_ids": liquid_ids, "liquid_filter_after": liquid_filter_after}

func java_method_build_1(_args: Array = []) -> Variant:
	var liquid_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
	var liquid_amounts: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var req_images: Array = []
	var row_calls: Array = []
	var icon_size: String = "Vars.iconMed"
	var pad_right: float = 8.0
	for index in range(liquid_ids.size()):
		var amount: float = float(liquid_amounts[index] if index < liquid_amounts.size() else 0.0)
		req_images.append({"liquid_id": liquid_ids[index], "amount": amount, "valid": amount > 0.0, "icon": "stack.liquid.uiIcon", "size": icon_size, "pad_right": pad_right})
		if (index + 1) % 4 == 0:
			row_calls.append(index + 1)
	return {"source_owner": "PortGame.source_consume_liquids_build_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquids.java", "method": "public void build(Building build, Table table){", "table_expr": "table.table(c -> {", "i_initial_expr": "int i = 0;", "loop_expr": "for(var stack : liquids){", "add_expr": "c.add(new ReqImage(stack.liquid.uiIcon,", "valid_expr": "() -> build.liquids.get(stack.liquid) > 0)).size(Vars.iconMed).padRight(8);", "row_expr": "if(++i % 4 == 0) c.row();", "table_left_expr": "}).left();", "req_image_constructor": "public ReqImage(TextureRegion region, Boolp valid){", "req_image_valid": "public boolean valid(){", "vars_icon_med": "iconMed = 8*4f", "liquid_ids": liquid_ids, "liquid_amounts": liquid_amounts, "req_images": req_images, "row_calls": row_calls, "table_left": true}

func java_method_update_2(_args: Array = []) -> Variant:
	return null

func java_method_efficiency_3(_args: Array = []) -> Variant:
	return null

func java_method_display_4(_args: Array = []) -> Variant:
	return null
