# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeLiquid.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeLiquid"
const JAVA_EXTENDS := "ConsumeLiquidBase"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "liquid", "type": "Liquid"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeLiquid", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}]}, {"modifiers": ["protected"], "name": "ConsumeLiquid", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "efficiency", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "consumes", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []
const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const source_consume_liquid_state := preload("res://src/game/SourceConsumeLiquidState.gd")
const SOURCE_CONSUME_LIQUID_DEFAULT_LIQUID := source_consumer_defaults.CONSUME_LIQUID_DEFAULT_LIQUID
const SOURCE_CONSUME_LIQUID_DEFAULT_AMOUNT := source_consumer_defaults.CONSUME_LIQUID_DEFAULT_AMOUNT
const SOURCE_CONSUME_EFFICIENCY_EPSILON := source_consumer_defaults.CONSUME_EFFICIENCY_EPSILON
const source_ui_defaults := preload("res://src/game/SourceUiDefaults.gd")
const SOURCE_UI_ICON_MED := source_ui_defaults.ICON_MED
const SOURCE_UI_PAD_RIGHT := source_ui_defaults.PAD_RIGHT
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const SOURCE_TICK_RATE := source_time_defaults.TICK_RATE

func java_method_apply_0(_args: Array = []) -> Variant:
	var block_has_liquids_before: bool = bool(_args[0] if _args.size() > 0 else false)
	var liquid_filter_before: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var liquid_id: int = int(_args[2] if _args.size() > 2 else 0)
	var base_apply_state: Dictionary = {"assignment_expr": "block.hasLiquids = true;", "block_has_liquids_before": block_has_liquids_before, "block_has_liquids_after": true, "method": "public void apply(Block block){", "source_owner": "port_game.source_consume_liquid_base_apply_state"}
	var liquid_filter_after: Array = liquid_filter_before.duplicate()
	liquid_filter_after[liquid_id] = true
	return {"source_owner": "port_game.source_consume_liquid_apply_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquid.java", "method": "public void apply(Block block){", "super_apply_expr": "super.apply(block);", "liquid_filter_assignment_expr": "block.liquidFilter[liquid.id] = true;", "block_has_liquids_before": block_has_liquids_before, "block_has_liquids_after": base_apply_state["block_has_liquids_after"], "base_apply_state": base_apply_state, "liquid_filter_before": liquid_filter_before, "liquid_id": liquid_id, "liquid_filter_after": liquid_filter_after}

func java_method_build_1(_args: Array = []) -> Variant:
	var liquid_id: int = int(_args[0] if _args.size() > 0 else 0)
	var build_liquids_get: float = float(_args[1] if _args.size() > 1 else 0.0)
	var source_ui_icon_med: float = float(_args[2] if _args.size() > 2 else SOURCE_UI_ICON_MED)
	var valid: bool = build_liquids_get > 0.0
	var req_image: Dictionary = {"liquid_id": liquid_id, "icon": "liquid.uiIcon", "valid": valid, "valid_expr": "build.liquids.get(liquid) > 0"}
	var table_image_size: float = source_ui_icon_med
	return {"source_owner": "port_game.source_consume_liquid_build_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquid.java", "method": "public void build(Building build, Table table){", "liquid_field": "public final Liquid liquid;", "req_image_expr": "table.add(new ReqImage(liquid.uiIcon, () -> build.liquids.get(liquid) > 0)).size(iconMed).top().left();", "liquid_ui_icon_expr": "liquid.uiIcon", "valid_expr": "build.liquids.get(liquid) > 0", "req_image_constructor": "public ReqImage(TextureRegion region, Boolp valid){", "req_image_valid": "public boolean valid(){", "vars_icon_med": "iconMed = 8*4f", "liquid_module_get": "public float get(Liquid liquid){", "cell_size_expr": "public Cell<T> size(float size){", "cell_top_expr": "public Cell<T> top(){", "cell_left_expr": "public Cell<T> left(){", "liquid_id": liquid_id, "build_liquids_get": build_liquids_get, "valid": valid, "req_image": req_image, "table_image_size": table_image_size, "table_top": true, "table_left": true}

func java_method_update_2(_args: Array = []) -> Variant:
	var liquid_id: int = int(_args[0] if _args.size() > 0 else 0)
	var amount: float = float(_args[1] if _args.size() > 1 else 0.0)
	var build_edelta: float = float(_args[2] if _args.size() > 2 else 0.0)
	var multiplier_get_build: float = float(_args[3] if _args.size() > 3 else 1.0)
	return source_consume_liquid_state.update_state(liquid_id, amount, build_edelta, multiplier_get_build)

func java_method_efficiency_3(_args: Array = []) -> Variant:
	var build_liquids_get: float = float(_args[0] if _args.size() > 0 else 0.0)
	var amount: float = float(_args[1] if _args.size() > 1 else 0.0)
	var build_edelta: float = float(_args[2] if _args.size() > 2 else 0.0)
	var build_efficiency_scale: float = float(_args[3] if _args.size() > 3 else 1.0)
	var multiplier_get_build: float = float(_args[4] if _args.size() > 4 else 1.0)
	return source_consume_liquid_state.efficiency_state(build_liquids_get, amount, build_edelta, build_efficiency_scale, multiplier_get_build)

func java_method_display_4(_args: Array = []) -> Variant:
	var booster: bool = bool(_args[0] if _args.size() > 0 else false)
	var liquid_id: int = int(_args[1] if _args.size() > 1 else 0)
	var amount: float = float(_args[2] if _args.size() > 2 else 0.0)
	var source_tick_rate: float = float(_args[3] if _args.size() > 3 else SOURCE_TICK_RATE)
	var selected_stat: String = "booster" if booster else "input"
	var display_amount_per_second: float = amount * source_tick_rate
	var stats_add_call: Dictionary = {"call": "stats.add", "stat": selected_stat, "liquid_id": liquid_id, "amount": display_amount_per_second, "per_second": true}
	return {"source_owner": "port_game.source_consume_liquid_display_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquid.java", "method": "public void display(Stats stats){", "liquid_field": "public final Liquid liquid;", "amount_field": "public float amount;", "booster_field": "public boolean booster;", "stats_add_expr": "stats.add(booster ? Stat.booster : Stat.input, liquid, amount * 60f, true);", "selected_stat_expr": "booster ? Stat.booster : Stat.input", "stat_input_expr": "input = new Stat(\"input\", StatCat.crafting),", "stat_booster_expr": "booster = new Stat(\"booster\", StatCat.optional),", "stats_add_liquid_method": "public void add(Stat stat, Liquid liquid, float amount, boolean perSecond){", "stat_values_liquid_expr": "StatValues.liquid(liquid, amount, perSecond)", "stat_values_liquid_method": "public static StatValue liquid(Liquid liquid, float amount, boolean perSecond){", "stat_values_display_expr": "return table -> table.add(displayLiquid(liquid, amount, perSecond)).left();", "booster": booster, "liquid_id": liquid_id, "amount": amount, "selected_stat": selected_stat, "display_amount_per_second": display_amount_per_second, "per_second": true, "stats_add_call": stats_add_call}

func java_method_consumes_5(_args: Array = []) -> Variant:
	var liquid_matches_self_liquid: bool = bool(_args[0] if _args.size() > 0 else false)
	var consumes_liquid: bool = liquid_matches_self_liquid
	return {"source_owner": "port_game.source_consume_liquid_consumes_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquid.java", "method": "public boolean consumes(Liquid liquid){", "liquid_matches_self_liquid": liquid_matches_self_liquid, "consumes_liquid": consumes_liquid, "return_expr": "return liquid == this.liquid;"}

func java_constructor_ConsumeLiquid_0(_args: Array = []) -> Variant:
	var liquid: Variant = _args[0] if _args.size() > 0 else null
	var amount: float = float(_args[1] if _args.size() > 1 else 0.0)
	var amount_after: float = amount
	var liquid_after: Variant = liquid
	return {"source_owner": "port_game.source_consume_liquid_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquid.java", "constructor": "public ConsumeLiquid(Liquid liquid, float amount){", "liquid_field": "public final Liquid liquid;", "super_call_expr": "super(amount);", "base_constructor_expr": "public ConsumeLiquidBase(float amount){", "amount_assignment_expr": "this.amount = amount;", "liquid_assignment_expr": "this.liquid = liquid;", "liquid": liquid, "amount": amount, "amount_after": amount_after, "liquid_after": liquid_after}

func java_constructor_ConsumeLiquid_1(_args: Array = []) -> Variant:
	var liquid: Variant = SOURCE_CONSUME_LIQUID_DEFAULT_LIQUID
	var amount: float = SOURCE_CONSUME_LIQUID_DEFAULT_AMOUNT
	var amount_after: float = amount
	var liquid_after: Variant = liquid
	return {"source_owner": "port_game.source_consume_liquid_default_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquid.java", "constructor": "protected ConsumeLiquid(){", "default_call_expr": "this(null, 0f);", "typed_constructor_expr": "public ConsumeLiquid(Liquid liquid, float amount){", "liquid_field": "public final Liquid liquid;", "super_call_expr": "super(amount);", "base_constructor_expr": "public ConsumeLiquidBase(float amount){", "amount_assignment_expr": "this.amount = amount;", "liquid_assignment_expr": "this.liquid = liquid;", "default_liquid": SOURCE_CONSUME_LIQUID_DEFAULT_LIQUID, "default_amount": SOURCE_CONSUME_LIQUID_DEFAULT_AMOUNT, "amount_after": amount_after, "liquid_after": liquid_after}
