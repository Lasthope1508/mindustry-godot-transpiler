extends RefCounted
class_name SourceTurretStatsBarsState

const SourceTimeDefaults := preload("res://src/game/SourceTimeDefaults.gd")
const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

const SOURCE_TURRET_SET_STATS_METHOD := "public void setStats(){"
const SOURCE_TURRET_SET_STATS_SUPER_EXPR := "super.setStats();"
const SOURCE_TURRET_SET_BARS_METHOD := "public void setBars(){"
const SOURCE_TURRET_SET_BARS_SUPER_EXPR := "super.setBars();"
const SOURCE_BASE_TURRET_SET_STATS_SHOOT_RANGE_EXPR := "stats.add(Stat.shootRange, range / tilesize, StatUnit.blocks);"
const SOURCE_BASE_TURRET_SET_STATS_ACTIVATION_TIME_GUARD := "if(activationTime > 0)"
const SOURCE_BASE_TURRET_SET_STATS_ACTIVATION_TIME_EXPR := "stats.add(Stat.activationTime, activationTime / 60f, StatUnit.seconds);"
const SOURCE_BASE_TURRET_SET_BARS_ACTIVATION_TIME_GUARD := "if(activationTime > 0){"
const SOURCE_BASE_TURRET_SET_BARS_ADD_BAR_EXPR := "addBar(\"activationtimer\", (BaseTurretBuild entity) ->"
const SOURCE_BASE_TURRET_SET_BARS_TEXT_FORMAT_EXPR := "Core.bundle.format(\"bar.activationtimer\", Mathf.ceil(entity.activationTimer / 60f))"
const SOURCE_BASE_TURRET_SET_BARS_TEXT_GET_EXPR := "Core.bundle.get(\"bar.activated\")"
const SOURCE_BASE_TURRET_SET_BARS_COLOR_EXPR := "() -> (entity.activationTimer > 0)?  Pal.lightOrange : Pal.techBlue"
const SOURCE_BASE_TURRET_SET_BARS_PROGRESS_EXPR := "() -> 1 - entity.activationTimer / activationTime"
const SOURCE_RELOAD_TURRET_SET_STATS_COOLANT_GATE := "if(coolant != null){"
const SOURCE_RELOAD_TURRET_SET_STATS_BOOSTER_EXPR := "stats.replace(Stat.booster, StatValues.boosters(reload, coolant.amount, coolantMultiplier, true, coolant::consumes));"
const SOURCE_TRACTOR_BEAM_TURRET_SET_STATS_DAMAGE_EXPR := "if(damage > 0) stats.add(Stat.damage, damage * 60f, StatUnit.perSecond);"
const SOURCE_TRACTOR_BEAM_TURRET_SET_STATS_DAMAGE_ADD_EXPR := "stats.add(Stat.damage, damage * 60f, StatUnit.perSecond);"
const SOURCE_POWER_TURRET_SET_STATS_ADD_EXPR := "stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));"
const SOURCE_POWER_TURRET_SET_STATS_VALUES_EXPR := "StatValues.ammo(ObjectMap.of(this, shootType))"
const SOURCE_POWER_TURRET_SET_STATS_OBJECT_MAP_EXPR := "ObjectMap.of(this, shootType)"
const SOURCE_CONTINUOUS_TURRET_SET_STATS_REMOVE_RELOAD_EXPR := "stats.remove(Stat.reload);"
const SOURCE_CONTINUOUS_TURRET_SET_STATS_REMOVE_INACCURACY_EXPR := "stats.remove(Stat.inaccuracy);"
const SOURCE_ITEM_TURRET_SET_STATS_REMOVE_EXPR := "stats.remove(Stat.itemCapacity);"
const SOURCE_NAMED_AMMO_TYPES_VALUES_EXPR := "StatValues.ammo(ammoTypes, name)"
const SOURCE_NAMED_AMMO_TYPES_STATS_ADD_EXPR := "stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));"
const SOURCE_ITEM_TURRET_SET_STATS_AMMO_CAPACITY_ADD_EXPR := "stats.add(Stat.ammoCapacity, maxAmmo / Math.max(ammoPerShot, 1), StatUnit.shots);"
const SOURCE_ITEM_TURRET_SET_BARS_ADD_BAR_EXPR := "addBar(\"ammo\", (ItemTurretBuild entity) -> new Bar(\"stat.ammo\", Pal.ammo, () -> (float)entity.totalAmmo / maxAmmo));"
const SOURCE_ITEM_TURRET_SET_BARS_FRACTION_EXPR := "() -> (float)entity.totalAmmo / maxAmmo"
const SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_MIRROR_COMMENT := "//mirror stats onto each bullet (purely visual)"
const SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_STAT_LIQUID_CONSUMED_EXPR := "ammoTypes.each((l, b) -> b.statLiquidConsumed = liquidConsumed);"
const SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_STAT_LIQUID_CONSUMED_ASSIGN_EXPR := "b.statLiquidConsumed = liquidConsumed"
const SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_AMMO_VALUES_EXPR := "StatValues.ammo(ammoTypes)"
const SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_REPLACE_EXPR := "stats.replace(Stat.ammo, StatValues.ammo(ammoTypes));"


static func base_turret_set_stats_state(range_value: float, source_tilesize: float, activation_time: float, tick_rate: float) -> Dictionary:
	var shoot_range_stat_call := {
		"call": SOURCE_BASE_TURRET_SET_STATS_SHOOT_RANGE_EXPR,
		"stat": "Stat.shootRange",
		"value": range_value / source_tilesize,
		"unit": "StatUnit.blocks",
	}
	var activation_time_stat_called: bool = activation_time > 0.0
	var activation_time_stat_call := {
		"call": SOURCE_BASE_TURRET_SET_STATS_ACTIVATION_TIME_EXPR,
		"stat": "Stat.activationTime",
		"value": activation_time / tick_rate,
		"unit": "StatUnit.seconds",
	}
	return {
		"source_owner": "PortGame.source_base_turret_set_stats_state",
		"method": SOURCE_TURRET_SET_STATS_METHOD,
		"override_expr": "@Override",
		"super_set_stats_expr": SOURCE_TURRET_SET_STATS_SUPER_EXPR,
		"super_set_stats_called": true,
		"activation_time_stat_called": activation_time_stat_called,
		"shoot_range_stat_expr": SOURCE_BASE_TURRET_SET_STATS_SHOOT_RANGE_EXPR,
		"activation_time_guard_expr": SOURCE_BASE_TURRET_SET_STATS_ACTIVATION_TIME_GUARD,
		"activation_time_stat_expr": SOURCE_BASE_TURRET_SET_STATS_ACTIVATION_TIME_EXPR,
		"range": range_value,
		"tilesize": source_tilesize,
		"activation_time": activation_time,
		"shoot_range_blocks": range_value / source_tilesize,
		"shoot_range_stat_call": shoot_range_stat_call,
		"activation_time_stat_call": activation_time_stat_call,
	}


static func generated_base_turret_set_stats_bridge_state(range_value: float, source_tilesize: float, activation_time: float, tick_rate: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/BaseTurret.gd", "java_method_setStats_4", [range_value, source_tilesize, activation_time, tick_rate], null)
	var canonical = base_turret_set_stats_state(range_value, source_tilesize, activation_time, tick_rate)
	return {
		"source_owner": "SourceTurretStatsBarsState.base_turret_set_stats_state",
		"generated_owner": "BaseTurret.java_method_setStats_4",
		"result": result,
		"canonical": canonical,
		"matches": SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical),
	}


static func base_turret_set_bars_state(activation_time: float, entity_activation_timer: float, tick_rate: float) -> Dictionary:
	var activation_bar_added: bool = activation_time > 0.0
	var activation_bar_call := {
		"seconds": ceil(entity_activation_timer / tick_rate),
		"progress": 1.0 - entity_activation_timer / activation_time if activation_time > 0.0 else 1.0,
	}
	return {
		"source_owner": "PortGame.source_base_turret_set_bars_state",
		"method": SOURCE_TURRET_SET_BARS_METHOD,
		"super_set_bars_expr": SOURCE_TURRET_SET_BARS_SUPER_EXPR,
		"super_set_bars_called": true,
		"activation_time_guard_expr": SOURCE_BASE_TURRET_SET_BARS_ACTIVATION_TIME_GUARD,
		"add_bar_expr": SOURCE_BASE_TURRET_SET_BARS_ADD_BAR_EXPR,
		"bar_text_format_expr": SOURCE_BASE_TURRET_SET_BARS_TEXT_FORMAT_EXPR,
		"bar_text_get_expr": SOURCE_BASE_TURRET_SET_BARS_TEXT_GET_EXPR,
		"bar_color_expr": SOURCE_BASE_TURRET_SET_BARS_COLOR_EXPR,
		"bar_progress_expr": SOURCE_BASE_TURRET_SET_BARS_PROGRESS_EXPR,
		"activation_bar_added": activation_bar_added,
		"activation_bar_call": activation_bar_call,
	}


static func generated_base_turret_set_bars_bridge_state(activation_time: float, entity_activation_timer: float, tick_rate: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/BaseTurret.gd", "java_method_setBars_5", [activation_time, entity_activation_timer, tick_rate], null)
	var canonical = base_turret_set_bars_state(activation_time, entity_activation_timer, tick_rate)
	return {
		"source_owner": "SourceTurretStatsBarsState.base_turret_set_bars_state",
		"generated_owner": "BaseTurret.java_method_setBars_5",
		"result": result,
		"canonical": canonical,
		"matches": result.get("activation_bar_call", null) == canonical.get("activation_bar_call", null) and result.get("activation_bar_added", null) == canonical.get("activation_bar_added", null) and result.get("super_set_bars_called", null) == canonical.get("super_set_bars_called", null),
	}


static func set_stats_state(inaccuracy_value: float, reload_value: float, reload_while_charging: bool, shoot_first_shot_delay: float, shoot_shots: float, target_air: bool, target_ground: bool, ammo_per_shot: int, heat_requirement: float, max_heat_efficiency: float, tick_rate: float) -> Dictionary:
	var reload_stat_denominator: float = reload_value + (shoot_first_shot_delay if not reload_while_charging else 0.0)
	var reload_stat_rate: float = tick_rate / reload_stat_denominator * shoot_shots
	var inaccuracy_stat_call: Dictionary = {"call": "stats.add(Stat.inaccuracy, (int)inaccuracy, StatUnit.degrees);", "stat": "Stat.inaccuracy", "value": int(inaccuracy_value), "unit": "StatUnit.degrees"}
	var reload_stat_call: Dictionary = {"call": "stats.add(Stat.reload, 60f / (reload + (!reloadWhileCharging ? shoot.firstShotDelay : 0f)) * shoot.shots, StatUnit.perSecond);", "stat": "Stat.reload", "value": reload_stat_rate, "unit": "StatUnit.perSecond", "denominator": reload_stat_denominator}
	var targets_air_stat_call: Dictionary = {"call": "stats.add(Stat.targetsAir, targetAir);", "stat": "Stat.targetsAir", "value": target_air}
	var targets_ground_stat_call: Dictionary = {"call": "stats.add(Stat.targetsGround, targetGround);", "stat": "Stat.targetsGround", "value": target_ground}
	var ammo_use_stat_called: bool = ammo_per_shot != 1
	var ammo_use_stat_call: Dictionary = {}
	if ammo_use_stat_called:
		ammo_use_stat_call = {"call": "stats.add(Stat.ammoUse, ammoPerShot, StatUnit.perShot);", "stat": "Stat.ammoUse", "value": ammo_per_shot, "unit": "StatUnit.perShot"}
	var input_heat_stat_called: bool = heat_requirement > 0.0
	var input_heat_stat_call: Dictionary = {}
	if input_heat_stat_called:
		input_heat_stat_call = {"call": "stats.add(Stat.input, heatRequirement, StatUnit.heatUnits);", "stat": "Stat.input", "value": heat_requirement, "unit": "StatUnit.heatUnits"}
	var max_efficiency_stat_called: bool = heat_requirement > 0.0 and max_heat_efficiency > 0.0
	var max_efficiency_stat_call: Dictionary = {}
	if max_efficiency_stat_called:
		max_efficiency_stat_call = {"call": "stats.add(Stat.maxEfficiency, (int)(maxHeatEfficiency * 100f), StatUnit.percent);", "stat": "Stat.maxEfficiency", "value": int(max_heat_efficiency * 100.0), "unit": "StatUnit.percent"}
	return {
		"source_owner": "PortGame.source_turret_set_stats_state",
		"method": "public void setStats(){",
		"override_expr": "@Override",
		"super_set_stats_expr": "super.setStats();",
		"inaccuracy_stat_expr": "stats.add(Stat.inaccuracy, (int)inaccuracy, StatUnit.degrees);",
		"reload_stat_expr": "stats.add(Stat.reload, 60f / (reload + (!reloadWhileCharging ? shoot.firstShotDelay : 0f)) * shoot.shots, StatUnit.perSecond);",
		"targets_air_stat_expr": "stats.add(Stat.targetsAir, targetAir);",
		"targets_ground_stat_expr": "stats.add(Stat.targetsGround, targetGround);",
		"ammo_use_guard_expr": "if(ammoPerShot != 1)",
		"ammo_use_stat_expr": "stats.add(Stat.ammoUse, ammoPerShot, StatUnit.perShot);",
		"input_heat_guard_expr": "if(heatRequirement > 0)",
		"input_heat_stat_expr": "stats.add(Stat.input, heatRequirement, StatUnit.heatUnits);",
		"max_efficiency_guard_expr": "if(heatRequirement > 0 && maxHeatEfficiency > 0)",
		"max_efficiency_stat_expr": "stats.add(Stat.maxEfficiency, (int)(maxHeatEfficiency * 100f), StatUnit.percent);",
		"inaccuracy_value": inaccuracy_value,
		"reload_value": reload_value,
		"reload_while_charging": reload_while_charging,
		"shoot_first_shot_delay": shoot_first_shot_delay,
		"shoot_shots": shoot_shots,
		"target_air": target_air,
		"target_ground": target_ground,
		"ammo_per_shot": ammo_per_shot,
		"heat_requirement": heat_requirement,
		"max_heat_efficiency": max_heat_efficiency,
		"reload_stat_denominator": reload_stat_denominator,
		"reload_stat_rate": reload_stat_rate,
		"super_set_stats_called": true,
		"inaccuracy_stat_call": inaccuracy_stat_call,
		"reload_stat_call": reload_stat_call,
		"targets_air_stat_call": targets_air_stat_call,
		"targets_ground_stat_call": targets_ground_stat_call,
		"ammo_use_stat_called": ammo_use_stat_called,
		"ammo_use_stat_call": ammo_use_stat_call,
		"input_heat_stat_called": input_heat_stat_called,
		"input_heat_stat_call": input_heat_stat_call,
		"max_efficiency_stat_called": max_efficiency_stat_called,
		"max_efficiency_stat_call": max_efficiency_stat_call,
	}


static func generated_turret_set_stats_bridge_state(inaccuracy_value: float, reload_value: float, reload_while_charging: bool, shoot_first_shot_delay: float, shoot_shots: float, target_air: bool, target_ground: bool, ammo_per_shot: int, heat_requirement: float, max_heat_efficiency: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/Turret.gd", "java_method_setStats_1", [inaccuracy_value, reload_value, reload_while_charging, shoot_first_shot_delay, shoot_shots, target_air, target_ground, ammo_per_shot, heat_requirement, max_heat_efficiency], null)
	var canonical = set_stats_state(inaccuracy_value, reload_value, reload_while_charging, shoot_first_shot_delay, shoot_shots, target_air, target_ground, ammo_per_shot, heat_requirement, max_heat_efficiency, SourceTimeDefaults.TICK_RATE)
	return {
		"source_owner": "SourceTurretStatsBarsState.set_stats_state",
		"generated_owner": "Turret.java_method_setStats_1",
		"result": result,
		"canonical": canonical,
		"matches": result.get("reload_stat_call", null) == canonical.get("reload_stat_call", null) and result.get("ammo_use_stat_call", null) == canonical.get("ammo_use_stat_call", null) and result.get("max_efficiency_stat_call", null) == canonical.get("max_efficiency_stat_call", null),
	}


static func set_bars_state(heat_requirement: float, entity_heat_req: float, max_heat_efficiency: float) -> Dictionary:
	var heat_bar_added: bool = heat_requirement > 0.0
	var heat_bar_percent: int = 0
	var heat_bar_fraction: float = 0.0
	var heat_bar_text_call: Dictionary = {}
	var heat_bar_color: String = ""
	var heat_bar_call: Dictionary = {}
	if heat_bar_added:
		heat_bar_percent = int(min(entity_heat_req / heat_requirement, max_heat_efficiency) * 100.0)
		heat_bar_fraction = entity_heat_req / heat_requirement
		heat_bar_text_call = {"call": "Core.bundle.format(\"bar.heatpercent\", (int)entity.heatReq, (int)(Math.min(entity.heatReq / heatRequirement, maxHeatEfficiency) * 100))", "key": "bar.heatpercent", "heat_req": int(entity_heat_req), "percent": heat_bar_percent}
		heat_bar_color = "Pal.lightOrange"
		heat_bar_call = {"call": "addBar(\"heat\", (TurretBuild entity) -> new Bar(...));", "name": "heat", "text_call": heat_bar_text_call, "color": heat_bar_color, "fraction": heat_bar_fraction}
	return {
		"source_owner": "PortGame.source_turret_set_bars_state",
		"method": "public void setBars(){",
		"override_expr": "@Override",
		"super_set_bars_expr": "super.setBars();",
		"heat_requirement_guard_expr": "if(heatRequirement > 0){",
		"add_bar_expr": "addBar(\"heat\", (TurretBuild entity) ->",
		"bar_new_expr": "new Bar(() ->",
		"bar_text_format_expr": "Core.bundle.format(\"bar.heatpercent\", (int)entity.heatReq, (int)(Math.min(entity.heatReq / heatRequirement, maxHeatEfficiency) * 100))",
		"bar_color_expr": "() -> Pal.lightOrange",
		"bar_progress_expr": "() -> entity.heatReq / heatRequirement",
		"heat_requirement": heat_requirement,
		"entity_heat_req": entity_heat_req,
		"max_heat_efficiency": max_heat_efficiency,
		"super_set_bars_called": true,
		"heat_bar_added": heat_bar_added,
		"heat_bar_percent": heat_bar_percent,
		"heat_bar_fraction": heat_bar_fraction,
		"heat_bar_text_call": heat_bar_text_call,
		"heat_bar_color": heat_bar_color,
		"heat_bar_call": heat_bar_call,
	}


static func generated_turret_set_bars_bridge_state(heat_requirement: float, entity_heat_req: float, max_heat_efficiency: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/Turret.gd", "java_method_setBars_2", [heat_requirement, entity_heat_req, max_heat_efficiency], null)
	var canonical = set_bars_state(heat_requirement, entity_heat_req, max_heat_efficiency)
	return {
		"source_owner": "SourceTurretStatsBarsState.set_bars_state",
		"generated_owner": "Turret.java_method_setBars_2",
		"result": result,
		"canonical": canonical,
		"matches": result.get("heat_bar_call", null) == canonical.get("heat_bar_call", null) and result.get("heat_bar_added", null) == canonical.get("heat_bar_added", null),
	}


static func tractor_beam_turret_set_stats_state(target_air: bool, target_ground: bool, damage: float, tick_rate: float) -> Dictionary:
	var damage_per_second: float = damage * tick_rate
	var damage_stat_added: bool = damage > 0.0
	var damage_stat_call := {
		"call": SOURCE_TRACTOR_BEAM_TURRET_SET_STATS_DAMAGE_ADD_EXPR,
		"value": damage_per_second,
		"added": damage_stat_added,
	}
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_set_stats_state",
		"method": "public void setStats(){",
		"super_set_stats_expr": "super.setStats();",
		"targets_air_stat_expr": "stats.add(Stat.targetsAir, targetAir);",
		"targets_ground_stat_expr": "stats.add(Stat.targetsGround, targetGround);",
		"damage_stat_expr": SOURCE_TRACTOR_BEAM_TURRET_SET_STATS_DAMAGE_EXPR,
		"targets_air_stat_call": {"value": target_air},
		"targets_ground_stat_call": {"value": target_ground},
		"damage_stat_added": damage_stat_added,
		"damage_stat_call": damage_stat_call,
	}


static func generated_tractor_beam_turret_set_stats_bridge_state(target_air: bool, target_ground: bool, damage: float, tick_rate: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd", "java_method_setStats_1", [target_air, target_ground, damage, tick_rate], null)
	var canonical = tractor_beam_turret_set_stats_state(target_air, target_ground, damage, tick_rate)
	return {
		"source_owner": "SourceTurretStatsBarsState.tractor_beam_turret_set_stats_state",
		"generated_owner": "TractorBeamTurret.java_method_setStats_1",
		"result": result,
		"canonical": canonical,
		"matches": result.get("targets_air_stat_call", null) == canonical.get("targets_air_stat_call", null) and result.get("targets_ground_stat_call", null) == canonical.get("targets_ground_stat_call", null) and result.get("damage_stat_added", null) == canonical.get("damage_stat_added", null) and result.get("damage_stat_call", null) == canonical.get("damage_stat_call", null),
	}


static func reload_turret_set_stats_state(coolant_present: bool, reload_value: float, coolant_amount: float, coolant_multiplier: float) -> Dictionary:
	var booster_replace_called: bool = coolant_present
	var booster_replace_call: Dictionary = {}
	if booster_replace_called:
		booster_replace_call = {"call": SOURCE_RELOAD_TURRET_SET_STATS_BOOSTER_EXPR, "stat": "Stat.booster", "reload": reload_value, "coolant_amount": coolant_amount, "coolant_multiplier": coolant_multiplier, "base": true, "consumes": "coolant::consumes"}
	return {
		"source_owner": "PortGame.source_reload_turret_set_stats_state",
		"method": SOURCE_TURRET_SET_STATS_METHOD,
		"override_expr": "@Override",
		"super_set_stats_expr": SOURCE_TURRET_SET_STATS_SUPER_EXPR,
		"coolant_gate": SOURCE_RELOAD_TURRET_SET_STATS_COOLANT_GATE,
		"booster_replace_expr": SOURCE_RELOAD_TURRET_SET_STATS_BOOSTER_EXPR,
		"coolant_present": coolant_present,
		"reload_value": reload_value,
		"coolant_amount": coolant_amount,
		"coolant_multiplier": coolant_multiplier,
		"super_set_stats_called": true,
		"booster_replace_called": booster_replace_called,
		"booster_replace_call": booster_replace_call,
	}


static func generated_reload_turret_set_stats_bridge_state(coolant_present: bool, reload_value: float, coolant_amount: float, coolant_multiplier: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ReloadTurret.gd", "java_method_setStats_0", [coolant_present, reload_value, coolant_amount, coolant_multiplier], null)
	var canonical = reload_turret_set_stats_state(coolant_present, reload_value, coolant_amount, coolant_multiplier)
	return {
		"source_owner": "SourceTurretStatsBarsState.reload_turret_set_stats_state",
		"generated_owner": "ReloadTurret.java_method_setStats_0",
		"result": result,
		"canonical": canonical,
		"matches": result.get("booster_replace_called", null) == canonical.get("booster_replace_called", null) and result.get("booster_replace_call", null) == canonical.get("booster_replace_call", null),
	}


static func point_defense_set_stats_state(bullet_damage: float, reload_value: float, tick_rate: float) -> Dictionary:
	var reload_stat_rate: float = tick_rate / reload_value
	var reload_stat_call: Dictionary = {"call": "stats.add(Stat.reload, 60f / reload, StatUnit.perSecond);", "stat": "Stat.reload", "value": reload_stat_rate, "unit": "StatUnit.perSecond"}
	var damage_stat_call: Dictionary = {"call": "stats.add(Stat.damage, bulletDamage, StatUnit.none);", "stat": "Stat.damage", "value": bullet_damage, "unit": "StatUnit.none"}
	return {
		"source_owner": "PortGame.source_point_defense_turret_set_stats_state",
		"method": "public void setStats(){",
		"override_expr": "@Override",
		"super_set_stats_expr": "super.setStats();",
		"reload_stat_expr": "stats.add(Stat.reload, 60f / reload, StatUnit.perSecond);",
		"damage_stat_expr": "stats.add(Stat.damage, bulletDamage, StatUnit.none);",
		"bullet_damage": bullet_damage,
		"reload": reload_value,
		"reload_stat_rate": reload_stat_rate,
		"super_set_stats_called": true,
		"reload_stat_call": reload_stat_call,
		"damage_stat_call": damage_stat_call,
	}


static func generated_point_defense_turret_set_stats_default_bridge_state(bullet_damage: float, reload_value: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/PointDefenseTurret.gd", "java_method_setStats_1", [], null)
	var canonical = point_defense_set_stats_state(bullet_damage, reload_value, SourceTimeDefaults.TICK_RATE)
	return {
		"source_owner": "SourceTurretStatsBarsState.point_defense_set_stats_state",
		"generated_owner": "PointDefenseTurret.java_method_setStats_1",
		"defaulted_args": ["bullet_damage", "reload"],
		"bullet_damage": bullet_damage,
		"reload": reload_value,
		"result": result,
		"canonical": canonical,
		"matches": result.get("reload_stat_call", null) == canonical.get("reload_stat_call", null) and result.get("damage_stat_call", null) == canonical.get("damage_stat_call", null),
	}


static func power_turret_set_stats_state(shoot_type: Variant) -> Dictionary:
	var object_map_call: Dictionary = {"call": SOURCE_POWER_TURRET_SET_STATS_OBJECT_MAP_EXPR, "owner": "this", "shoot_type": shoot_type}
	var ammo_values_call: Dictionary = {"call": SOURCE_POWER_TURRET_SET_STATS_VALUES_EXPR, "object_map_call": object_map_call}
	var stats_add_call: Dictionary = {"call": SOURCE_POWER_TURRET_SET_STATS_ADD_EXPR, "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	return {
		"source_owner": "PortGame.source_power_turret_set_stats_state",
		"method": SOURCE_TURRET_SET_STATS_METHOD,
		"override_expr": "@Override",
		"super_set_stats_expr": SOURCE_TURRET_SET_STATS_SUPER_EXPR,
		"stats_add_expr": SOURCE_POWER_TURRET_SET_STATS_ADD_EXPR,
		"shoot_type": shoot_type,
		"super_set_stats_called": true,
		"stats_add_called": true,
		"object_map_call": object_map_call,
		"ammo_values_call": ammo_values_call,
		"stats_add_call": stats_add_call,
	}


static func generated_power_turret_set_stats_bridge_state(shoot_type: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/PowerTurret.gd", "java_method_setStats_0", [shoot_type], null)
	var canonical = power_turret_set_stats_state(shoot_type)
	return {
		"source_owner": "SourceTurretStatsBarsState.power_turret_set_stats_state",
		"generated_owner": "PowerTurret.java_method_setStats_0",
		"result": result,
		"canonical": canonical,
		"matches": result.get("stats_add_call", null) == canonical.get("stats_add_call", null) and result.get("shoot_type", null) == canonical.get("shoot_type", null),
	}


static func continuous_turret_set_stats_state(shoot_type: Variant) -> Dictionary:
	var object_map_call: Dictionary = {"call": SOURCE_POWER_TURRET_SET_STATS_OBJECT_MAP_EXPR, "this": "ContinuousTurret", "shoot_type": shoot_type}
	var ammo_values_call: Dictionary = {"call": SOURCE_POWER_TURRET_SET_STATS_VALUES_EXPR, "object_map_call": object_map_call}
	var stats_add_call: Dictionary = {"call": SOURCE_POWER_TURRET_SET_STATS_ADD_EXPR, "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	return {
		"source_owner": "PortGame.source_continuous_turret_set_stats_state",
		"method": SOURCE_TURRET_SET_STATS_METHOD,
		"override_expr": "@Override",
		"super_set_stats_expr": SOURCE_TURRET_SET_STATS_SUPER_EXPR,
		"stats_add_expr": SOURCE_POWER_TURRET_SET_STATS_ADD_EXPR,
		"remove_reload_expr": SOURCE_CONTINUOUS_TURRET_SET_STATS_REMOVE_RELOAD_EXPR,
		"remove_inaccuracy_expr": SOURCE_CONTINUOUS_TURRET_SET_STATS_REMOVE_INACCURACY_EXPR,
		"shoot_type": shoot_type,
		"super_set_stats_called": true,
		"stats_add_called": true,
		"remove_reload_called": true,
		"remove_inaccuracy_called": true,
		"object_map_call": object_map_call,
		"ammo_values_call": ammo_values_call,
		"stats_add_call": stats_add_call,
	}


static func generated_continuous_turret_set_stats_bridge_state(shoot_type: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousTurret.gd", "java_method_setStats_0", [shoot_type], null)
	var canonical = continuous_turret_set_stats_state(shoot_type)
	return {
		"source_owner": "SourceTurretStatsBarsState.continuous_turret_set_stats_state",
		"generated_owner": "ContinuousTurret.java_method_setStats_0",
		"result": result,
		"canonical": canonical,
		"matches": result.get("stats_add_call", null) == canonical.get("stats_add_call", null) and result.get("remove_reload_called", null) == canonical.get("remove_reload_called", null),
	}


static func item_turret_set_stats_state(ammo_types: Variant, name_value: String, max_ammo: float, ammo_per_shot: float) -> Dictionary:
	var ammo_capacity_divisor: float = maxf(ammo_per_shot, 1.0)
	var ammo_capacity: float = max_ammo / ammo_capacity_divisor
	var stats_item_capacity_remove_call: Dictionary = {"call": SOURCE_ITEM_TURRET_SET_STATS_REMOVE_EXPR, "stat": "Stat.itemCapacity"}
	var ammo_values_call: Dictionary = {"call": SOURCE_NAMED_AMMO_TYPES_VALUES_EXPR, "ammo_types": ammo_types, "name": name_value}
	var stats_ammo_add_call: Dictionary = {"call": SOURCE_NAMED_AMMO_TYPES_STATS_ADD_EXPR, "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	var stats_ammo_capacity_add_call: Dictionary = {"call": SOURCE_ITEM_TURRET_SET_STATS_AMMO_CAPACITY_ADD_EXPR, "stat": "Stat.ammoCapacity", "value": ammo_capacity, "unit": "StatUnit.shots"}
	return {
		"source_owner": "PortGame.source_item_turret_set_stats_state",
		"method": SOURCE_TURRET_SET_STATS_METHOD,
		"override_expr": "@Override",
		"super_set_stats_expr": SOURCE_TURRET_SET_STATS_SUPER_EXPR,
		"stats_remove_expr": SOURCE_ITEM_TURRET_SET_STATS_REMOVE_EXPR,
		"stats_ammo_add_expr": SOURCE_NAMED_AMMO_TYPES_STATS_ADD_EXPR,
		"stats_ammo_capacity_add_expr": SOURCE_ITEM_TURRET_SET_STATS_AMMO_CAPACITY_ADD_EXPR,
		"ammo_types": ammo_types,
		"name_value": name_value,
		"max_ammo": max_ammo,
		"ammo_per_shot": ammo_per_shot,
		"ammo_capacity_divisor": ammo_capacity_divisor,
		"ammo_capacity": ammo_capacity,
		"super_set_stats_called": true,
		"stats_item_capacity_removed": true,
		"stats_ammo_added": true,
		"stats_ammo_capacity_added": true,
		"stats_item_capacity_remove_call": stats_item_capacity_remove_call,
		"ammo_values_call": ammo_values_call,
		"stats_ammo_add_call": stats_ammo_add_call,
		"stats_ammo_capacity_add_call": stats_ammo_capacity_add_call,
	}


static func generated_item_turret_set_stats_bridge_state(ammo_types: Variant, name_value: String, max_ammo: float, ammo_per_shot: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_method_setStats_3", [ammo_types, name_value, max_ammo, ammo_per_shot], null)
	var canonical = item_turret_set_stats_state(ammo_types, name_value, max_ammo, ammo_per_shot)
	return {
		"source_owner": "SourceTurretStatsBarsState.item_turret_set_stats_state",
		"generated_owner": "ItemTurret.java_method_setStats_3",
		"result": result,
		"canonical": canonical,
		"matches": result.get("stats_ammo_capacity_add_call", null) == canonical.get("stats_ammo_capacity_add_call", null) and result.get("stats_ammo_add_call", null) == canonical.get("stats_ammo_add_call", null) and result.get("stats_item_capacity_remove_call", null) == canonical.get("stats_item_capacity_remove_call", null),
	}


static func generated_item_turret_set_stats_default_bridge_state(max_ammo: float, ammo_per_shot: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_method_setStats_3", [], null)
	var canonical = item_turret_set_stats_state(null, "", max_ammo, ammo_per_shot)
	return {
		"source_owner": "SourceTurretStatsBarsState.item_turret_set_stats_state",
		"generated_owner": "ItemTurret.java_method_setStats_3",
		"result": result,
		"canonical": canonical,
		"defaulted_args": ["max_ammo", "ammo_per_shot"],
		"max_ammo": max_ammo,
		"ammo_per_shot": ammo_per_shot,
		"ammo_capacity": max_ammo / maxf(ammo_per_shot, 1.0),
		"matches": result.get("stats_ammo_capacity_add_call", null) == canonical.get("stats_ammo_capacity_add_call", null),
	}


static func item_turret_set_bars_state(total_ammo: float, max_ammo: float) -> Dictionary:
	var ammo_bar_fraction: float = total_ammo / max_ammo
	var bar_call: Dictionary = {"call": "addBar(\"ammo\", (ItemTurretBuild entity) -> new Bar(...));", "name": "ammo", "bar_text": "stat.ammo", "color": "Pal.ammo", "fraction": ammo_bar_fraction}
	return {
		"source_owner": "PortGame.source_item_turret_set_bars_state",
		"method": SOURCE_TURRET_SET_BARS_METHOD,
		"override_expr": "@Override",
		"super_set_bars_expr": SOURCE_TURRET_SET_BARS_SUPER_EXPR,
		"add_bar_expr": SOURCE_ITEM_TURRET_SET_BARS_ADD_BAR_EXPR,
		"bar_fraction_expr": SOURCE_ITEM_TURRET_SET_BARS_FRACTION_EXPR,
		"total_ammo": total_ammo,
		"max_ammo": max_ammo,
		"ammo_bar_fraction": ammo_bar_fraction,
		"super_set_bars_called": true,
		"bar_added": true,
		"bar_call": bar_call,
	}


static func generated_item_turret_set_bars_bridge_state(total_ammo: float, max_ammo: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_method_setBars_4", [total_ammo, max_ammo], null)
	var canonical = item_turret_set_bars_state(total_ammo, max_ammo)
	return {
		"source_owner": "SourceTurretStatsBarsState.item_turret_set_bars_state",
		"generated_owner": "ItemTurret.java_method_setBars_4",
		"result": result,
		"canonical": canonical,
		"matches": result.get("bar_call", null) == canonical.get("bar_call", null) and result.get("ammo_bar_fraction", null) == canonical.get("ammo_bar_fraction", null),
	}


static func generated_item_turret_set_bars_default_bridge_state(total_ammo: float, max_ammo: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_method_setBars_4", [total_ammo], null)
	var canonical = item_turret_set_bars_state(total_ammo, max_ammo)
	return {
		"source_owner": "SourceTurretStatsBarsState.item_turret_set_bars_state",
		"generated_owner": "ItemTurret.java_method_setBars_4",
		"result": result,
		"canonical": canonical,
		"defaulted_args": ["max_ammo"],
		"max_ammo": max_ammo,
		"ammo_bar_fraction": total_ammo / max_ammo,
		"matches": result.get("bar_call", null) == canonical.get("bar_call", null) and result.get("ammo_bar_fraction", null) == canonical.get("ammo_bar_fraction", null),
	}


static func continuous_liquid_turret_set_stats_state(ammo_types: Array, liquid_consumed: float) -> Dictionary:
	var stat_liquid_consumed_updates: Array = []
	for entry in ammo_types:
		var entry_dict: Dictionary = entry if entry is Dictionary else {}
		stat_liquid_consumed_updates.append({"call": SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_STAT_LIQUID_CONSUMED_ASSIGN_EXPR, "liquid": entry_dict.get("liquid", null), "bullet": entry_dict.get("bullet", null), "stat_liquid_consumed": liquid_consumed})
	var ammo_values_call: Dictionary = {"call": SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_AMMO_VALUES_EXPR, "ammo_types": ammo_types}
	var stats_replace_call: Dictionary = {"call": SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_REPLACE_EXPR, "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_set_stats_state",
		"method": SOURCE_TURRET_SET_STATS_METHOD,
		"override_expr": "@Override",
		"super_set_stats_expr": SOURCE_TURRET_SET_STATS_SUPER_EXPR,
		"mirror_comment": SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_MIRROR_COMMENT,
		"stat_liquid_consumed_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_STAT_LIQUID_CONSUMED_EXPR,
		"stats_replace_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_REPLACE_EXPR,
		"ammo_types": ammo_types,
		"liquid_consumed": liquid_consumed,
		"super_set_stats_called": true,
		"stat_liquid_consumed_updates": stat_liquid_consumed_updates,
		"stats_replace_called": true,
		"ammo_values_call": ammo_values_call,
		"stats_replace_call": stats_replace_call,
	}


static func generated_continuous_liquid_turret_set_stats_bridge_state(ammo_types: Array, liquid_consumed: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_method_setStats_1", [ammo_types, liquid_consumed], null)
	var canonical = continuous_liquid_turret_set_stats_state(ammo_types, liquid_consumed)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_set_stats_state",
		"generated_owner": "ContinuousLiquidTurret.setStats",
		"result": result,
		"canonical": canonical,
		"matches": result.get("stat_liquid_consumed_updates", []) == canonical.get("stat_liquid_consumed_updates", []) and result.get("stats_replace_call", {}) == canonical.get("stats_replace_call", {}),
	}


static func liquid_turret_set_stats_state(ammo_types: Variant, name_value: String) -> Dictionary:
	var ammo_values_call: Dictionary = {"call": SOURCE_NAMED_AMMO_TYPES_VALUES_EXPR, "ammo_types": ammo_types, "name": name_value}
	var stats_add_call: Dictionary = {"call": SOURCE_NAMED_AMMO_TYPES_STATS_ADD_EXPR, "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	return {
		"source_owner": "PortGame.source_liquid_turret_set_stats_state",
		"method": SOURCE_TURRET_SET_STATS_METHOD,
		"override_expr": "@Override",
		"super_set_stats_expr": SOURCE_TURRET_SET_STATS_SUPER_EXPR,
		"stats_add_expr": SOURCE_NAMED_AMMO_TYPES_STATS_ADD_EXPR,
		"ammo_types": ammo_types,
		"name_value": name_value,
		"super_set_stats_called": true,
		"stats_added": true,
		"ammo_values_call": ammo_values_call,
		"stats_add_call": stats_add_call,
	}


static func generated_liquid_turret_set_stats_bridge_state(ammo_types: Variant, name_value: String) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_method_setStats_1", [ammo_types, name_value], null)
	var canonical = liquid_turret_set_stats_state(ammo_types, name_value)
	return {
		"source_owner": "PortGame.source_liquid_turret_set_stats_state",
		"generated_owner": "LiquidTurret.setStats",
		"result": result,
		"canonical": canonical,
		"matches": result.get("stats_add_call", {}) == canonical.get("stats_add_call", {}),
	}
