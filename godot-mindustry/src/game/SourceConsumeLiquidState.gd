extends RefCounted
class_name SourceConsumeLiquidState

const SourceConsumerDefaults := preload("res://src/game/SourceConsumerDefaults.gd")
const SourceTimeDefaults := preload("res://src/game/SourceTimeDefaults.gd")
const SourceUiDefaults := preload("res://src/game/SourceUiDefaults.gd")
const SOURCE_UI_ICON_MED := SourceUiDefaults.ICON_MED

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"base_apply_state": Callable(game, "source_consume_liquid_base_apply_state"),
	}

static func constructor_state(liquid: Variant, amount: float) -> Dictionary:
	return {
		"source_owner": "PortGame.source_consume_liquid_constructor_state",
		"source": "core/src/mindustry/world/consumers/ConsumeLiquid.java",
		"constructor": "public ConsumeLiquid(Liquid liquid, float amount){",
		"liquid_field": "public final Liquid liquid;",
		"super_call_expr": "super(amount);",
		"base_constructor_expr": "public ConsumeLiquidBase(float amount){",
		"amount_assignment_expr": "this.amount = amount;",
		"liquid_assignment_expr": "this.liquid = liquid;",
		"liquid": liquid,
		"amount": amount,
		"amount_after": amount,
		"liquid_after": liquid,
	}

static func default_constructor_state(default_liquid: Variant, default_amount: float) -> Dictionary:
	return {
		"source_owner": "PortGame.source_consume_liquid_default_constructor_state",
		"source": "core/src/mindustry/world/consumers/ConsumeLiquid.java",
		"constructor": "protected ConsumeLiquid(){",
		"default_call_expr": "this(null, 0f);",
		"typed_constructor_expr": "public ConsumeLiquid(Liquid liquid, float amount){",
		"liquid_field": "public final Liquid liquid;",
		"super_call_expr": "super(amount);",
		"base_constructor_expr": "public ConsumeLiquidBase(float amount){",
		"amount_assignment_expr": "this.amount = amount;",
		"liquid_assignment_expr": "this.liquid = liquid;",
		"default_liquid": default_liquid,
		"default_amount": default_amount,
		"amount_after": default_amount,
		"liquid_after": default_liquid,
	}

static func apply_state(block_has_liquids_before: bool, liquid_filter_before: Array, liquid_id: int, base_apply_state_provider: Callable) -> Dictionary:
	var base_apply_state: Dictionary = base_apply_state_provider.call(block_has_liquids_before)
	var liquid_filter_after := liquid_filter_before.duplicate()
	liquid_filter_after[liquid_id] = true
	return {
		"source_owner": "PortGame.source_consume_liquid_apply_state",
		"source": "core/src/mindustry/world/consumers/ConsumeLiquid.java",
		"method": "public void apply(Block block){",
		"super_apply_expr": "super.apply(block);",
		"liquid_filter_assignment_expr": "block.liquidFilter[liquid.id] = true;",
		"block_liquid_filter_field": "public boolean[] itemFilter = {}, liquidFilter = {};",
		"block_has_liquids_before": block_has_liquids_before,
		"block_has_liquids_after": base_apply_state.get("block_has_liquids_after", null),
		"base_apply_state": base_apply_state,
		"liquid_filter_before": liquid_filter_before,
		"liquid_id": liquid_id,
		"liquid_filter_after": liquid_filter_after,
	}

static func build_state(liquid_id: int, build_liquids_get: float, _source_ui_icon_med: float) -> Dictionary:
	var valid: bool = build_liquids_get > 0.0
	var req_image: Dictionary = {"liquid_id": liquid_id, "icon": "liquid.uiIcon", "valid": valid, "valid_expr": "build.liquids.get(liquid) > 0"}
	var table_image_size: float = SOURCE_UI_ICON_MED
	return {
		"source_owner": "PortGame.source_consume_liquid_build_state",
		"source": "core/src/mindustry/world/consumers/ConsumeLiquid.java",
		"method": "public void build(Building build, Table table){",
		"liquid_field": "public final Liquid liquid;",
		"req_image_expr": "table.add(new ReqImage(liquid.uiIcon, () -> build.liquids.get(liquid) > 0)).size(iconMed).top().left();",
		"liquid_ui_icon_expr": "liquid.uiIcon",
		"valid_expr": "build.liquids.get(liquid) > 0",
		"req_image_constructor": "public ReqImage(TextureRegion region, Boolp valid){",
		"req_image_valid": "public boolean valid(){",
		"vars_icon_med": "iconMed = 8*4f",
		"liquid_module_get": "public float get(Liquid liquid){",
		"cell_size_expr": "public Cell<T> size(float size){",
		"cell_top_expr": "public Cell<T> top(){",
		"cell_left_expr": "public Cell<T> left(){",
		"liquid_id": liquid_id,
		"build_liquids_get": build_liquids_get,
		"valid": valid,
		"req_image": req_image,
		"table_image_size": table_image_size,
		"table_top": true,
		"table_left": true,
	}

static func display_state(booster: bool, liquid_id: int, amount: float) -> Dictionary:
	var selected_stat: String = "booster" if booster else "input"
	var display_amount_per_second: float = amount * SourceTimeDefaults.TICK_RATE
	var stats_add_call: Dictionary = {"call": "stats.add", "stat": selected_stat, "liquid_id": liquid_id, "amount": display_amount_per_second, "per_second": true}
	return {
		"source_owner": "PortGame.source_consume_liquid_display_state",
		"source": "core/src/mindustry/world/consumers/ConsumeLiquid.java",
		"method": "public void display(Stats stats){",
		"liquid_field": "public final Liquid liquid;",
		"amount_field": "public float amount;",
		"booster_field": "public boolean booster;",
		"stats_add_expr": "stats.add(booster ? Stat.booster : Stat.input, liquid, amount * 60f, true);",
		"selected_stat_expr": "booster ? Stat.booster : Stat.input",
		"stat_input_expr": "input = new Stat(\"input\", StatCat.crafting),",
		"stat_booster_expr": "booster = new Stat(\"booster\", StatCat.optional),",
		"stats_add_liquid_method": "public void add(Stat stat, Liquid liquid, float amount, boolean perSecond){",
		"stat_values_liquid_expr": "StatValues.liquid(liquid, amount, perSecond)",
		"stat_values_liquid_method": "public static StatValue liquid(Liquid liquid, float amount, boolean perSecond){",
		"stat_values_display_expr": "return table -> table.add(displayLiquid(liquid, amount, perSecond)).left();",
		"booster": booster,
		"liquid_id": liquid_id,
		"amount": amount,
		"selected_stat": selected_stat,
		"display_amount_per_second": display_amount_per_second,
		"per_second": true,
		"stats_add_call": stats_add_call,
	}

static func update_state(liquid_id: int, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	var remove_amount: float = amount * build_edelta * multiplier_get_build
	return {
		"source_owner": "PortGame.source_consume_liquid_update_state",
		"source": "core/src/mindustry/world/consumers/ConsumeLiquid.java",
		"method": "public void update(Building build){",
		"remove_expr": "build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));",
		"liquid_field": "public final Liquid liquid;",
		"amount_field": "public float amount;",
		"multiplier_field": "public Floatf<Building> multiplier = b -> 1f;",
		"building_liquids_field": "@Nullable LiquidModule liquids;",
		"building_edelta_method": "public float edelta(){",
		"liquid_id": liquid_id,
		"amount": amount,
		"build_edelta": build_edelta,
		"multiplier_get_build": multiplier_get_build,
		"remove_amount": remove_amount,
	}

static func efficiency_state(build_liquids_get: float, amount: float, build_edelta: float, build_efficiency_scale: float, multiplier_get_build: float) -> Dictionary:
	var ed: float = build_edelta * build_efficiency_scale
	var ed_guard: bool = ed <= SourceConsumerDefaults.CONSUME_EFFICIENCY_EPSILON
	var required_liquid_amount: float = amount * ed * multiplier_get_build
	var raw_efficiency: float = build_liquids_get / required_liquid_amount if not ed_guard else 0.0
	var efficiency: float = 0.0 if ed_guard else min(raw_efficiency, 1.0)
	return {
		"source_owner": "PortGame.source_consume_liquid_efficiency_state",
		"source": "core/src/mindustry/world/consumers/ConsumeLiquid.java",
		"method": "public float efficiency(Building build){",
		"liquid_field": "public final Liquid liquid;",
		"ed_expr": "float ed = build.edelta() * build.efficiencyScale();",
		"ed_guard_expr": "if(ed <= 0.00000001f) return 0f;",
		"cap_comment": "//there can be more liquid than necessary, so cap at 1",
		"return_expr": "return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);",
		"build_liquids_get_expr": "build.liquids.get(liquid)",
		"amount_expr": "amount",
		"build_edelta_expr": "build.edelta()",
		"build_efficiency_scale_expr": "build.efficiencyScale()",
		"multiplier_get_build_expr": "multiplier.get(build)",
		"amount_field": "public float amount;",
		"multiplier_field": "public Floatf<Building> multiplier = b -> 1f;",
		"build_liquids_get": build_liquids_get,
		"amount": amount,
		"build_edelta": build_edelta,
		"build_efficiency_scale": build_efficiency_scale,
		"multiplier_get_build": multiplier_get_build,
		"ed": ed,
		"ed_guard": ed_guard,
		"required_liquid_amount": required_liquid_amount,
		"raw_efficiency": raw_efficiency,
		"efficiency": efficiency,
	}

static func consumes_state(liquid_matches_self_liquid: bool) -> Dictionary:
	return {
		"source_owner": "PortGame.source_consume_liquid_consumes_state",
		"source": "core/src/mindustry/world/consumers/ConsumeLiquid.java",
		"method": "public boolean consumes(Liquid liquid){",
		"liquid_field": "public final Liquid liquid;",
		"liquid_matches_self_liquid": liquid_matches_self_liquid,
		"consumes_liquid": liquid_matches_self_liquid,
		"return_expr": "return liquid == this.liquid;",
	}

static func generated_constructor_bridge_state(liquid: Variant, amount: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquid.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeLiquid_0([liquid, amount])
	var canonical = constructor_state(liquid, amount)
	return {
		"source_owner": "SourceConsumeLiquidState.constructor_state",
		"generated_owner": "ConsumeLiquid.constructor",
		"result": result,
		"canonical": canonical,
		"matches": result.get("amount_after", null) == canonical.get("amount_after", null) and result.get("liquid_after", null) == canonical.get("liquid_after", null),
	}

static func generated_default_constructor_bridge_state(default_liquid: Variant, default_amount: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquid.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeLiquid_1([])
	var canonical = default_constructor_state(default_liquid, default_amount)
	return {
		"source_owner": "SourceConsumeLiquidState.default_constructor_state",
		"generated_owner": "ConsumeLiquid.default_constructor",
		"result": result,
		"canonical": canonical,
		"matches": result.get("amount_after", null) == canonical.get("amount_after", null) and result.get("liquid_after", null) == canonical.get("liquid_after", null),
	}

static func generated_apply_bridge_state(block_has_liquids_before: bool, liquid_filter_before: Array, liquid_id: int, base_apply_state_provider: Callable) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquid.gd")
	var instance = script.new()
	var result = instance.java_method_apply_0([block_has_liquids_before, liquid_filter_before, liquid_id])
	var canonical = apply_state(block_has_liquids_before, liquid_filter_before, liquid_id, base_apply_state_provider)
	return {
		"source_owner": "SourceConsumeLiquidState.apply_state",
		"generated_owner": "ConsumeLiquid.apply",
		"result": result,
		"canonical": canonical,
		"matches": result.get("block_has_liquids_after", null) == canonical.get("block_has_liquids_after", null) and result.get("liquid_filter_after", []) == canonical.get("liquid_filter_after", []),
	}

static func generated_build_bridge_state(liquid_id: int, build_liquids_get: float, source_ui_icon_med: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquid.gd")
	var instance = script.new()
	var result = instance.java_method_build_1([liquid_id, build_liquids_get, source_ui_icon_med])
	var canonical = build_state(liquid_id, build_liquids_get, source_ui_icon_med)
	return {
		"source_owner": "SourceConsumeLiquidState.build_state",
		"generated_owner": "ConsumeLiquid.build",
		"result": result,
		"canonical": canonical,
		"matches": result.get("req_image", {}) == canonical.get("req_image", {}) and result.get("table_image_size", null) == canonical.get("table_image_size", null) and result.get("table_top", null) == canonical.get("table_top", null) and result.get("table_left", null) == canonical.get("table_left", null),
	}

static func generated_display_bridge_state(booster: bool, liquid_id: int, amount: float, source_tick_rate: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquid.gd")
	var instance = script.new()
	var result = instance.java_method_display_4([booster, liquid_id, amount, source_tick_rate])
	var canonical = display_state(booster, liquid_id, amount)
	return {
		"source_owner": "SourceConsumeLiquidState.display_state",
		"generated_owner": "ConsumeLiquid.display",
		"result": result,
		"canonical": canonical,
		"matches": result.get("selected_stat", null) == canonical.get("selected_stat", null) and result.get("display_amount_per_second", null) == canonical.get("display_amount_per_second", null) and result.get("stats_add_call", {}) == canonical.get("stats_add_call", {}),
	}

static func generated_update_bridge_state(liquid_id: int, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquid.gd")
	var instance = script.new()
	var result = instance.java_method_update_2([liquid_id, amount, build_edelta, multiplier_get_build])
	var canonical = update_state(liquid_id, amount, build_edelta, multiplier_get_build)
	return {
		"source_owner": "SourceConsumeLiquidState.update_state",
		"generated_owner": "ConsumeLiquid.update",
		"result": result,
		"canonical": canonical,
		"matches": result.get("remove_amount", null) == canonical.get("remove_amount", null),
	}

static func generated_efficiency_bridge_state(build_liquids_get: float, amount: float, build_edelta: float, build_efficiency_scale: float, multiplier_get_build: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquid.gd")
	var instance = script.new()
	var result = instance.java_method_efficiency_3([build_liquids_get, amount, build_edelta, build_efficiency_scale, multiplier_get_build])
	var canonical = efficiency_state(build_liquids_get, amount, build_edelta, build_efficiency_scale, multiplier_get_build)
	return {
		"source_owner": "SourceConsumeLiquidState.efficiency_state",
		"generated_owner": "ConsumeLiquid.efficiency",
		"result": result,
		"canonical": canonical,
		"matches": result.get("efficiency", null) == canonical.get("efficiency", null) and result.get("raw_efficiency", null) == canonical.get("raw_efficiency", null) and result.get("ed_guard", null) == canonical.get("ed_guard", null),
	}

static func generated_consumes_bridge_state(liquid_matches_self_liquid: bool) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquid.gd")
	var instance = script.new()
	var result = instance.java_method_consumes_5([liquid_matches_self_liquid])
	var canonical = consumes_state(liquid_matches_self_liquid)
	return {
		"source_owner": "SourceConsumeLiquidState.consumes_state",
		"generated_owner": "ConsumeLiquid.consumes",
		"result": result,
		"canonical": canonical,
		"matches": result.get("consumes_liquid", null) == canonical.get("consumes_liquid", null),
	}
