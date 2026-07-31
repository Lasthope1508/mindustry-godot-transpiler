# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/turrets/Turret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense.turrets"
const JAVA_KIND := "class"
const JAVA_NAME := "Turret"
const JAVA_EXTENDS := "ReloadTurret"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "logicControlCooldown", "type": "float"}, {"modifiers": ["final", "public"], "name": "timerTarget", "type": "int"}, {"modifiers": ["public"], "name": "targetInterval", "type": "float"}, {"modifiers": ["public"], "name": "newTargetInterval", "type": "float"}, {"modifiers": ["public"], "name": "maxAmmo", "type": "int"}, {"modifiers": ["public"], "name": "ammoPerShot", "type": "int"}, {"modifiers": ["public"], "name": "consumeAmmoOnce", "type": "boolean"}, {"modifiers": ["public"], "name": "heatRequirement", "type": "float"}, {"modifiers": ["public"], "name": "maxHeatEfficiency", "type": "float"}, {"modifiers": ["public"], "name": "inaccuracy", "type": "float"}, {"modifiers": ["public"], "name": "velocityRnd", "type": "float"}, {"modifiers": ["public"], "name": "scaleLifetimeOffset", "type": "float"}, {"modifiers": ["public"], "name": "shootCone", "type": "float"}, {"modifiers": ["public"], "name": "shootX", "type": "float"}, {"modifiers": ["public"], "name": "shootY", "type": "float"}, {"modifiers": ["public"], "name": "xRand", "type": "float"}, {"modifiers": ["public"], "name": "drawMinRange", "type": "boolean"}, {"modifiers": ["public"], "name": "trackingRange", "type": "float"}, {"modifiers": ["public"], "name": "minRange", "type": "float"}, {"modifiers": ["public"], "name": "minWarmup", "type": "float"}, {"modifiers": ["public"], "name": "accurateDelay", "type": "boolean"}, {"modifiers": ["public"], "name": "moveWhileCharging", "type": "boolean"}, {"modifiers": ["public"], "name": "reloadWhileCharging", "type": "boolean"}, {"modifiers": ["public"], "name": "warmupMaintainTime", "type": "float"}, {"modifiers": ["public"], "name": "shoot", "type": "ShootPattern"}, {"modifiers": ["public"], "name": "targetAir", "type": "boolean"}, {"modifiers": ["public"], "name": "targetGround", "type": "boolean"}, {"modifiers": ["public"], "name": "targetBlocks", "type": "boolean"}, {"modifiers": ["public"], "name": "targetHealing", "type": "boolean"}, {"modifiers": ["public"], "name": "playerControllable", "type": "boolean"}, {"modifiers": ["public"], "name": "displayAmmoMultiplier", "type": "boolean"}, {"modifiers": ["public"], "name": "targetUnderBlocks", "type": "boolean"}, {"modifiers": ["public"], "name": "alwaysShooting", "type": "boolean"}, {"modifiers": ["public"], "name": "predictTarget", "type": "boolean"}, {"modifiers": ["public"], "name": "unitSort", "type": "Sortf"}, {"modifiers": ["public"], "name": "unitFilter", "type": "Boolf"}, {"modifiers": ["public"], "name": "buildingFilter", "type": "Boolf"}, {"modifiers": ["public"], "name": "heatColor", "type": "Color"}, {"modifiers": ["public"], "name": "shootEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "smokeEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "ammoUseEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "shootSound", "type": "Sound"}, {"modifiers": ["public"], "name": "shootSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "chargeSound", "type": "Sound"}, {"modifiers": ["public"], "name": "loopSound", "type": "Sound"}, {"modifiers": ["public"], "name": "loopSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "soundPitchMin", "type": "float"}, {"modifiers": ["public"], "name": "soundPitchMax", "type": "float"}, {"modifiers": ["public"], "name": "ammoEjectBack", "type": "float"}, {"modifiers": ["public"], "name": "shootWarmupSpeed", "type": "float"}, {"modifiers": ["public"], "name": "linearWarmup", "type": "boolean"}, {"modifiers": ["public"], "name": "recoil", "type": "float"}, {"modifiers": ["public"], "name": "recoils", "type": "int"}, {"modifiers": ["public"], "name": "recoilTime", "type": "float"}, {"modifiers": ["public"], "name": "recoilPow", "type": "float"}, {"modifiers": ["public"], "name": "cooldownTime", "type": "float"}, {"modifiers": ["public"], "name": "elevation", "type": "float"}, {"modifiers": ["public"], "name": "shake", "type": "float"}, {"modifiers": ["public"], "name": "drawer", "type": "DrawBlock"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Turret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "outputsItems", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "getRegionsToOutline", "parameters": [{"name": "out", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "limitRange", "parameters": [{"name": "bullet", "type": "BulletType", "varargs": false}, {"name": "margin", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "rotatedOutput", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "placeEnded", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "builder", "type": "Unit", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "config", "type": "Object", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const SOURCE_TICK_RATE := source_time_defaults.TICK_RATE
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const SOURCE_TILESIZE := source_world_defaults.TILESIZE
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const SOURCE_BLOCK_SIZE_DEFAULT := source_block_defaults.SIZE_DEFAULT
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const SOURCE_TURRET_INACCURACY_DEFAULT := source_turret_defaults.INACCURACY_DEFAULT
const SOURCE_TURRET_SHOOT_Y_IS_NEGATIVE_INFINITY_DEFAULT := source_turret_defaults.SHOOT_Y_IS_NEGATIVE_INFINITY_DEFAULT
const SOURCE_TURRET_RELOAD_DEFAULT := source_turret_defaults.RELOAD_DEFAULT
const SOURCE_TURRET_RECOIL_TIME_DEFAULT := source_turret_defaults.RECOIL_TIME_DEFAULT
const SOURCE_TURRET_COOLDOWN_TIME_DEFAULT := source_turret_defaults.COOLDOWN_TIME_DEFAULT
const SOURCE_TURRET_NEW_TARGET_INTERVAL_DEFAULT := source_turret_defaults.NEW_TARGET_INTERVAL_DEFAULT
const SOURCE_TURRET_TARGET_INTERVAL_DEFAULT := source_turret_defaults.TARGET_INTERVAL_DEFAULT
const SOURCE_TURRET_ELEVATION_DEFAULT := source_turret_defaults.ELEVATION_DEFAULT
const SOURCE_TURRET_RELOAD_WHILE_CHARGING_DEFAULT := source_turret_defaults.RELOAD_WHILE_CHARGING_DEFAULT
const SOURCE_TURRET_TARGET_AIR_DEFAULT := source_turret_defaults.TARGET_AIR_DEFAULT
const SOURCE_TURRET_TARGET_GROUND_DEFAULT := source_turret_defaults.TARGET_GROUND_DEFAULT
const SOURCE_TURRET_DISABLE_OVERLAP_CHECK_DEFAULT := source_turret_defaults.DISABLE_OVERLAP_CHECK_DEFAULT
const SOURCE_TURRET_RANGE_DEFAULT := source_turret_defaults.RANGE_DEFAULT
const SOURCE_TURRET_TRACKING_RANGE_DEFAULT := source_turret_defaults.TRACKING_RANGE_DEFAULT
const SOURCE_TURRET_AMMO_PER_SHOT_DEFAULT := source_turret_defaults.AMMO_PER_SHOT_DEFAULT
const SOURCE_TURRET_HEAT_REQUIREMENT_DEFAULT := source_turret_defaults.HEAT_REQUIREMENT_DEFAULT
const SOURCE_TURRET_MAX_HEAT_EFFICIENCY_DEFAULT := source_turret_defaults.MAX_HEAT_EFFICIENCY_DEFAULT
const source_shoot_pattern_defaults := preload("res://src/game/SourceShootPatternDefaults.gd")
const SOURCE_SHOOT_PATTERN_SHOTS_DEFAULT := source_shoot_pattern_defaults.SHOTS_DEFAULT
const SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT := source_shoot_pattern_defaults.FIRST_SHOT_DELAY_DEFAULT

func java_method_outputsItems_0(_args: Array = []) -> Variant:
	return {"source_owner": "port_game.source_turret_outputs_items_state", "method": "public boolean outputsItems(){", "override_expr": "@Override", "return_expr": "return false;", "outputs_items": false}

func java_method_setStats_1(_args: Array = []) -> Variant:
	var inaccuracy_value: float = float(_args[0] if _args.size() > 0 else SOURCE_TURRET_INACCURACY_DEFAULT)
	var reload_value: float = float(_args[1] if _args.size() > 1 else SOURCE_TURRET_RELOAD_DEFAULT)
	var reload_while_charging: bool = bool(_args[2] if _args.size() > 2 else SOURCE_TURRET_RELOAD_WHILE_CHARGING_DEFAULT)
	var shoot_first_shot_delay: float = float(_args[3] if _args.size() > 3 else SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT)
	var shoot_shots: float = float(_args[4] if _args.size() > 4 else SOURCE_SHOOT_PATTERN_SHOTS_DEFAULT)
	var target_air: bool = bool(_args[5] if _args.size() > 5 else SOURCE_TURRET_TARGET_AIR_DEFAULT)
	var target_ground: bool = bool(_args[6] if _args.size() > 6 else SOURCE_TURRET_TARGET_GROUND_DEFAULT)
	var ammo_per_shot: int = int(_args[7] if _args.size() > 7 else SOURCE_TURRET_AMMO_PER_SHOT_DEFAULT)
	var heat_requirement: float = float(_args[8] if _args.size() > 8 else SOURCE_TURRET_HEAT_REQUIREMENT_DEFAULT)
	var max_heat_efficiency: float = float(_args[9] if _args.size() > 9 else SOURCE_TURRET_MAX_HEAT_EFFICIENCY_DEFAULT)
	var reload_stat_denominator: float = reload_value + (shoot_first_shot_delay if not reload_while_charging else 0.0)
	var reload_stat_rate: float = SOURCE_TICK_RATE / reload_stat_denominator * shoot_shots
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
	return {"source_owner": "port_game.source_turret_set_stats_state", "method": "public void setStats(){", "override_expr": "@Override", "super_set_stats_expr": "super.setStats();", "inaccuracy_stat_expr": "stats.add(Stat.inaccuracy, (int)inaccuracy, StatUnit.degrees);", "reload_stat_expr": "stats.add(Stat.reload, 60f / (reload + (!reloadWhileCharging ? shoot.firstShotDelay : 0f)) * shoot.shots, StatUnit.perSecond);", "targets_air_stat_expr": "stats.add(Stat.targetsAir, targetAir);", "targets_ground_stat_expr": "stats.add(Stat.targetsGround, targetGround);", "ammo_use_guard_expr": "if(ammoPerShot != 1)", "ammo_use_stat_expr": "stats.add(Stat.ammoUse, ammoPerShot, StatUnit.perShot);", "input_heat_guard_expr": "if(heatRequirement > 0)", "input_heat_stat_expr": "stats.add(Stat.input, heatRequirement, StatUnit.heatUnits);", "max_efficiency_guard_expr": "if(heatRequirement > 0 && maxHeatEfficiency > 0)", "max_efficiency_stat_expr": "stats.add(Stat.maxEfficiency, (int)(maxHeatEfficiency * 100f), StatUnit.percent);", "inaccuracy_value": inaccuracy_value, "reload_value": reload_value, "reload_while_charging": reload_while_charging, "shoot_first_shot_delay": shoot_first_shot_delay, "shoot_shots": shoot_shots, "target_air": target_air, "target_ground": target_ground, "ammo_per_shot": ammo_per_shot, "heat_requirement": heat_requirement, "max_heat_efficiency": max_heat_efficiency, "reload_stat_denominator": reload_stat_denominator, "reload_stat_rate": reload_stat_rate, "super_set_stats_called": true, "inaccuracy_stat_call": inaccuracy_stat_call, "reload_stat_call": reload_stat_call, "targets_air_stat_call": targets_air_stat_call, "targets_ground_stat_call": targets_ground_stat_call, "ammo_use_stat_called": ammo_use_stat_called, "ammo_use_stat_call": ammo_use_stat_call, "input_heat_stat_called": input_heat_stat_called, "input_heat_stat_call": input_heat_stat_call, "max_efficiency_stat_called": max_efficiency_stat_called, "max_efficiency_stat_call": max_efficiency_stat_call}

func java_method_setBars_2(_args: Array = []) -> Variant:
	var heat_requirement: float = float(_args[0] if _args.size() > 0 else SOURCE_TURRET_HEAT_REQUIREMENT_DEFAULT)
	var entity_heat_req: float = float(_args[1] if _args.size() > 1 else 0.0)
	var max_heat_efficiency: float = float(_args[2] if _args.size() > 2 else SOURCE_TURRET_MAX_HEAT_EFFICIENCY_DEFAULT)
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
	return {"source_owner": "port_game.source_turret_set_bars_state", "method": "public void setBars(){", "override_expr": "@Override", "super_set_bars_expr": "super.setBars();", "heat_requirement_guard_expr": "if(heatRequirement > 0){", "add_bar_expr": "addBar(\"heat\", (TurretBuild entity) ->", "bar_new_expr": "new Bar(() ->", "bar_text_format_expr": "Core.bundle.format(\"bar.heatpercent\", (int)entity.heatReq, (int)(Math.min(entity.heatReq / heatRequirement, maxHeatEfficiency) * 100))", "bar_color_expr": "() -> Pal.lightOrange", "bar_progress_expr": "() -> entity.heatReq / heatRequirement", "heat_requirement": heat_requirement, "entity_heat_req": entity_heat_req, "max_heat_efficiency": max_heat_efficiency, "super_set_bars_called": true, "heat_bar_added": heat_bar_added, "heat_bar_percent": heat_bar_percent, "heat_bar_fraction": heat_bar_fraction, "heat_bar_text_call": heat_bar_text_call, "heat_bar_color": heat_bar_color, "heat_bar_call": heat_bar_call}

func java_method_init_3(_args: Array = []) -> Variant:
	var shoot_y: float = float(_args[0] if _args.size() > 0 else 0.0)
	var shoot_y_is_negative_infinity: bool = bool(_args[1] if _args.size() > 1 else SOURCE_TURRET_SHOOT_Y_IS_NEGATIVE_INFINITY_DEFAULT)
	var size: float = float(_args[2] if _args.size() > 2 else SOURCE_BLOCK_SIZE_DEFAULT)
	var source_tilesize: float = float(_args[3] if _args.size() > 3 else SOURCE_TILESIZE)
	var elevation: float = float(_args[4] if _args.size() > 4 else SOURCE_TURRET_ELEVATION_DEFAULT)
	var recoil_time: float = float(_args[5] if _args.size() > 5 else SOURCE_TURRET_RECOIL_TIME_DEFAULT)
	var reload: float = float(_args[6] if _args.size() > 6 else SOURCE_TURRET_RELOAD_DEFAULT)
	var cooldown_time: float = float(_args[7] if _args.size() > 7 else SOURCE_TURRET_COOLDOWN_TIME_DEFAULT)
	var new_target_interval: float = float(_args[8] if _args.size() > 8 else SOURCE_TURRET_NEW_TARGET_INTERVAL_DEFAULT)
	var target_interval: float = float(_args[9] if _args.size() > 9 else SOURCE_TURRET_TARGET_INTERVAL_DEFAULT)
	var target_ground: bool = bool(_args[10] if _args.size() > 10 else SOURCE_TURRET_TARGET_GROUND_DEFAULT)
	var disable_overlap_check: bool = bool(_args[11] if _args.size() > 11 else SOURCE_TURRET_DISABLE_OVERLAP_CHECK_DEFAULT)
	var range_value: float = float(_args[12] if _args.size() > 12 else SOURCE_TURRET_RANGE_DEFAULT)
	var tracking_range: float = float(_args[13] if _args.size() > 13 else SOURCE_TURRET_TRACKING_RANGE_DEFAULT)
	var shoot_y_after: float = size * source_tilesize / 2.0 if shoot_y_is_negative_infinity else shoot_y
	var elevation_after: float = size / 2.0 if elevation < 0.0 else elevation
	var recoil_time_after: float = reload if recoil_time < 0.0 else recoil_time
	var cooldown_time_after: float = reload if cooldown_time < 0.0 else cooldown_time
	var new_target_interval_after: float = target_interval if new_target_interval <= 0.0 else new_target_interval
	var disable_overlap_check_after: bool = true if not target_ground else disable_overlap_check
	var tracking_range_after: float = max(range_value, tracking_range)
	return {"source_owner": "port_game.source_turret_init_state", "method": "public void init(){", "override_expr": "@Override", "shoot_y_guard_expr": "if(shootY == Float.NEGATIVE_INFINITY) shootY = size * tilesize / 2f;", "shoot_y_expr": "shootY = size * tilesize / 2f", "elevation_guard_expr": "if(elevation < 0) elevation = size / 2f;", "elevation_expr": "elevation = size / 2f", "recoil_time_guard_expr": "if(recoilTime < 0f) recoilTime = reload;", "recoil_time_expr": "recoilTime = reload", "cooldown_time_guard_expr": "if(cooldownTime < 0f) cooldownTime = reload;", "cooldown_time_expr": "cooldownTime = reload", "new_target_interval_guard_expr": "if(newTargetInterval <= 0f) newTargetInterval = targetInterval;", "new_target_interval_expr": "newTargetInterval = targetInterval", "target_ground_guard_expr": "if(!targetGround){", "disable_overlap_check_expr": "disableOverlapCheck = true;", "super_init_expr": "super.init();", "tracking_range_expr": "trackingRange = Math.max(range, trackingRange);", "shoot_y": shoot_y, "shoot_y_is_negative_infinity": shoot_y_is_negative_infinity, "size": size, "source_tilesize": source_tilesize, "elevation": elevation, "recoil_time": recoil_time, "reload": reload, "cooldown_time": cooldown_time, "new_target_interval": new_target_interval, "target_interval": target_interval, "target_ground": target_ground, "disable_overlap_check": disable_overlap_check, "range": range_value, "tracking_range": tracking_range, "shoot_y_after": shoot_y_after, "elevation_after": elevation_after, "recoil_time_after": recoil_time_after, "cooldown_time_after": cooldown_time_after, "new_target_interval_after": new_target_interval_after, "disable_overlap_check_after": disable_overlap_check_after, "tracking_range_after": tracking_range_after}

func java_method_load_4(_args: Array = []) -> Variant:
	return {"source_owner": "port_game.source_turret_load_state", "method": "public void load(){", "override_expr": "@Override", "super_load_expr": "super.load();", "drawer_load_expr": "drawer.load(this);", "super_load_called": true, "drawer_load_called": true}

func java_method_drawPlanRegion_5(_args: Array = []) -> Variant:
	var plan: Variant = _args[0] if _args.size() > 0 else null
	var list: Variant = _args[1] if _args.size() > 1 else null
	var drawer_draw_plan_call: Dictionary = {"call": "drawer.drawPlan(this, plan, list);", "plan": plan, "list": list}
	return {"source_owner": "port_game.source_turret_draw_plan_region_state", "method": "public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){", "override_expr": "@Override", "drawer_draw_plan_expr": "drawer.drawPlan(this, plan, list);", "plan": plan, "list": list, "drawer_draw_plan_call": drawer_draw_plan_call, "drawer_draw_plan_called": true}

func java_method_icons_6(_args: Array = []) -> Variant:
	var drawer_final_icons_return: Array = ["drawer.finalIcons(this)"]
	return {"source_owner": "port_game.source_turret_icons_state", "method": "public TextureRegion[] icons(){", "override_expr": "@Override", "drawer_final_icons_expr": "return drawer.finalIcons(this);", "drawer_final_icons_called": true, "icons": drawer_final_icons_return}

func java_method_getRegionsToOutline_7(_args: Array = []) -> Variant:
	var out: Variant = _args[0] if _args.size() > 0 else null
	var drawer_get_regions_to_outline_call: Dictionary = {"call": "drawer.getRegionsToOutline(this, out);", "out": out}
	return {"source_owner": "port_game.source_turret_get_regions_to_outline_state", "method": "public void getRegionsToOutline(Seq<TextureRegion> out){", "override_expr": "@Override", "drawer_get_regions_to_outline_expr": "drawer.getRegionsToOutline(this, out);", "out": out, "drawer_get_regions_to_outline_call": drawer_get_regions_to_outline_call, "drawer_get_regions_to_outline_called": true}

func java_method_limitRange_8(_args: Array = []) -> Variant:
	var bullet: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	var margin: float = float(_args[1] if _args.size() > 1 else 0.0)
	var turret_range: float = float(_args[2] if _args.size() > 2 else 0.0)
	var bullet_range_change: float = float(bullet.get("rangeChange", 0.0))
	var real_range: float = bullet_range_change + turret_range
	var bullet_extra_range_margin: float = float(bullet.get("extraRangeMargin", 0.0))
	var bullet_speed: float = float(bullet.get("speed", 1.0))
	var bullet_lifetime: float = (real_range + margin + bullet_extra_range_margin + 10.0) / bullet_speed
	bullet["lifetime"] = bullet_lifetime
	return {"source_owner": "port_game.source_turret_limit_range_state", "method": "public void limitRange(BulletType bullet, float margin){", "real_range_expr": "float realRange = bullet.rangeChange + range;", "drag_comment": "//doesn't handle drag", "lifetime_expr": "bullet.lifetime = (realRange + margin + bullet.extraRangeMargin + 10f) / bullet.speed;", "bullet": bullet, "margin": margin, "turret_range": turret_range, "bullet_range_change": bullet_range_change, "real_range": real_range, "bullet_extra_range_margin": bullet_extra_range_margin, "bullet_speed": bullet_speed, "bullet_lifetime": bullet_lifetime, "updated_bullet": bullet}

func java_method_drawPlace_9(_args: Array = []) -> Variant:
	var tile_x: int = int(_args[0] if _args.size() > 0 else 0)
	var tile_y: int = int(_args[1] if _args.size() > 1 else 0)
	var rotation: int = int(_args[2] if _args.size() > 2 else 0)
	var valid: bool = bool(_args[3] if _args.size() > 3 else false)
	var draw_min_range: bool = bool(_args[4] if _args.size() > 4 else false)
	var source_tilesize: float = float(_args[5] if _args.size() > 5 else SOURCE_TILESIZE)
	var block_offset: float = float(_args[6] if _args.size() > 6 else 0.0)
	var min_range: float = float(_args[7] if _args.size() > 7 else 0.0)
	var dash_circle_x: float = float(tile_x) * source_tilesize + block_offset
	var dash_circle_y: float = float(tile_y) * source_tilesize + block_offset
	var dash_circle_called: bool = draw_min_range
	var dash_circle_call: Dictionary = {}
	if dash_circle_called:
		dash_circle_call = {"call": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, minRange, Pal.placing);", "x": dash_circle_x, "y": dash_circle_y, "radius": min_range, "color": "Pal.placing"}
	return {"source_owner": "port_game.source_turret_draw_place_state", "method": "public void drawPlace(int x, int y, int rotation, boolean valid){", "override_expr": "@Override", "super_draw_place_expr": "super.drawPlace(x, y, rotation, valid);", "draw_min_range_gate": "if(drawMinRange){", "dash_circle_expr": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, minRange, Pal.placing);", "tile_x": tile_x, "tile_y": tile_y, "rotation": rotation, "valid": valid, "draw_min_range": draw_min_range, "source_tilesize": source_tilesize, "block_offset": block_offset, "min_range": min_range, "dash_circle_x": dash_circle_x, "dash_circle_y": dash_circle_y, "dash_circle_called": dash_circle_called, "dash_circle_call": dash_circle_call}

func java_method_rotatedOutput_10(_args: Array = []) -> Variant:
	var tile_x: int = int(_args[0] if _args.size() > 0 else 0)
	var tile_y: int = int(_args[1] if _args.size() > 1 else 0)
	return {"source_owner": "port_game.source_turret_rotated_output_state", "method": "public boolean rotatedOutput(int x, int y){", "override_expr": "@Override", "return_expr": "return false;", "tile_x": tile_x, "tile_y": tile_y, "rotated_output": false}

func java_method_placeEnded_11(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	var builder: Variant = _args[1] if _args.size() > 1 else null
	var rotation: int = int(_args[2] if _args.size() > 2 else 0)
	var config: Variant = _args[3] if _args.size() > 3 else null
	var rotate: bool = bool(_args[4] if _args.size() > 4 else false)
	var tile_build_is_turret_build: bool = bool(_args[5] if _args.size() > 5 else false)
	var turret_rotation: float = float(_args[6] if _args.size() > 6 else 0.0)
	var tile_build_rotdeg: float = float(_args[7] if _args.size() > 7 else 0.0)
	var rotation_assigned: bool = rotate and tile_build_is_turret_build
	var turret_rotation_after: float = tile_build_rotdeg if rotation_assigned else turret_rotation
	return {"source_owner": "port_game.source_turret_place_ended_state", "method": "public void placeEnded(Tile tile, @Nullable Unit builder, int rotation, @Nullable Object config){", "override_expr": "@Override", "super_place_ended_expr": "super.placeEnded(tile, builder, rotation, config);", "place_ended_gate": "if(rotate && tile.build instanceof TurretBuild turret){", "rotation_assign_expr": "turret.rotation = tile.build.rotdeg();", "tile": tile, "builder": builder, "rotation": rotation, "config": config, "rotate": rotate, "tile_build_is_turret_build": tile_build_is_turret_build, "turret_rotation": turret_rotation, "tile_build_rotdeg": tile_build_rotdeg, "super_place_ended_called": true, "rotation_assigned": rotation_assigned, "turret_rotation_after": turret_rotation_after}
