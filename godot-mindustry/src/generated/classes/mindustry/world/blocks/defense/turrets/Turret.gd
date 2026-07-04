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

func java_method_outputsItems_0(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_turret_outputs_items_state", "method": "public boolean outputsItems(){", "override_expr": "@Override", "return_expr": "return false;", "outputs_items": false}

func java_method_setStats_1(_args: Array = []) -> Variant:
	return null

func java_method_setBars_2(_args: Array = []) -> Variant:
	return null

func java_method_init_3(_args: Array = []) -> Variant:
	var shoot_y: float = float(_args[0] if _args.size() > 0 else 0.0)
	var shoot_y_is_negative_infinity: bool = bool(_args[1] if _args.size() > 1 else false)
	var size: float = float(_args[2] if _args.size() > 2 else 0.0)
	var source_tilesize: float = float(_args[3] if _args.size() > 3 else 0.0)
	var elevation: float = float(_args[4] if _args.size() > 4 else 0.0)
	var recoil_time: float = float(_args[5] if _args.size() > 5 else 0.0)
	var reload: float = float(_args[6] if _args.size() > 6 else 0.0)
	var cooldown_time: float = float(_args[7] if _args.size() > 7 else 0.0)
	var new_target_interval: float = float(_args[8] if _args.size() > 8 else 0.0)
	var target_interval: float = float(_args[9] if _args.size() > 9 else 0.0)
	var target_ground: bool = bool(_args[10] if _args.size() > 10 else true)
	var disable_overlap_check: bool = bool(_args[11] if _args.size() > 11 else false)
	var range_value: float = float(_args[12] if _args.size() > 12 else 0.0)
	var tracking_range: float = float(_args[13] if _args.size() > 13 else 0.0)
	var shoot_y_after: float = size * source_tilesize / 2.0 if shoot_y_is_negative_infinity else shoot_y
	var elevation_after: float = size / 2.0 if elevation < 0.0 else elevation
	var recoil_time_after: float = reload if recoil_time < 0.0 else recoil_time
	var cooldown_time_after: float = reload if cooldown_time < 0.0 else cooldown_time
	var new_target_interval_after: float = target_interval if new_target_interval <= 0.0 else new_target_interval
	var disable_overlap_check_after: bool = true if not target_ground else disable_overlap_check
	var tracking_range_after: float = max(range_value, tracking_range)
	return {"source_owner": "PortGame.source_turret_init_state", "method": "public void init(){", "override_expr": "@Override", "shoot_y_guard_expr": "if(shootY == Float.NEGATIVE_INFINITY) shootY = size * tilesize / 2f;", "shoot_y_expr": "shootY = size * tilesize / 2f", "elevation_guard_expr": "if(elevation < 0) elevation = size / 2f;", "elevation_expr": "elevation = size / 2f", "recoil_time_guard_expr": "if(recoilTime < 0f) recoilTime = reload;", "recoil_time_expr": "recoilTime = reload", "cooldown_time_guard_expr": "if(cooldownTime < 0f) cooldownTime = reload;", "cooldown_time_expr": "cooldownTime = reload", "new_target_interval_guard_expr": "if(newTargetInterval <= 0f) newTargetInterval = targetInterval;", "new_target_interval_expr": "newTargetInterval = targetInterval", "target_ground_guard_expr": "if(!targetGround){", "disable_overlap_check_expr": "disableOverlapCheck = true;", "super_init_expr": "super.init();", "tracking_range_expr": "trackingRange = Math.max(range, trackingRange);", "shoot_y": shoot_y, "shoot_y_is_negative_infinity": shoot_y_is_negative_infinity, "size": size, "source_tilesize": source_tilesize, "elevation": elevation, "recoil_time": recoil_time, "reload": reload, "cooldown_time": cooldown_time, "new_target_interval": new_target_interval, "target_interval": target_interval, "target_ground": target_ground, "disable_overlap_check": disable_overlap_check, "range": range_value, "tracking_range": tracking_range, "shoot_y_after": shoot_y_after, "elevation_after": elevation_after, "recoil_time_after": recoil_time_after, "cooldown_time_after": cooldown_time_after, "new_target_interval_after": new_target_interval_after, "disable_overlap_check_after": disable_overlap_check_after, "tracking_range_after": tracking_range_after}

func java_method_load_4(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_turret_load_state", "method": "public void load(){", "override_expr": "@Override", "super_load_expr": "super.load();", "drawer_load_expr": "drawer.load(this);", "super_load_called": true, "drawer_load_called": true}

func java_method_drawPlanRegion_5(_args: Array = []) -> Variant:
	var plan: Variant = _args[0] if _args.size() > 0 else null
	var list: Variant = _args[1] if _args.size() > 1 else null
	var drawer_draw_plan_call: Dictionary = {"call": "drawer.drawPlan(this, plan, list);", "plan": plan, "list": list}
	return {"source_owner": "PortGame.source_turret_draw_plan_region_state", "method": "public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){", "override_expr": "@Override", "drawer_draw_plan_expr": "drawer.drawPlan(this, plan, list);", "plan": plan, "list": list, "drawer_draw_plan_call": drawer_draw_plan_call, "drawer_draw_plan_called": true}

func java_method_icons_6(_args: Array = []) -> Variant:
	var drawer_final_icons_return: Array = ["drawer.finalIcons(this)"]
	return {"source_owner": "PortGame.source_turret_icons_state", "method": "public TextureRegion[] icons(){", "override_expr": "@Override", "drawer_final_icons_expr": "return drawer.finalIcons(this);", "drawer_final_icons_called": true, "icons": drawer_final_icons_return}

func java_method_getRegionsToOutline_7(_args: Array = []) -> Variant:
	var out: Variant = _args[0] if _args.size() > 0 else null
	var drawer_get_regions_to_outline_call: Dictionary = {"call": "drawer.getRegionsToOutline(this, out);", "out": out}
	return {"source_owner": "PortGame.source_turret_get_regions_to_outline_state", "method": "public void getRegionsToOutline(Seq<TextureRegion> out){", "override_expr": "@Override", "drawer_get_regions_to_outline_expr": "drawer.getRegionsToOutline(this, out);", "out": out, "drawer_get_regions_to_outline_call": drawer_get_regions_to_outline_call, "drawer_get_regions_to_outline_called": true}

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
	return {"source_owner": "PortGame.source_turret_limit_range_state", "method": "public void limitRange(BulletType bullet, float margin){", "real_range_expr": "float realRange = bullet.rangeChange + range;", "drag_comment": "//doesn't handle drag", "lifetime_expr": "bullet.lifetime = (realRange + margin + bullet.extraRangeMargin + 10f) / bullet.speed;", "bullet": bullet, "margin": margin, "turret_range": turret_range, "bullet_range_change": bullet_range_change, "real_range": real_range, "bullet_extra_range_margin": bullet_extra_range_margin, "bullet_speed": bullet_speed, "bullet_lifetime": bullet_lifetime, "updated_bullet": bullet}

func java_method_drawPlace_9(_args: Array = []) -> Variant:
	var tile_x: int = int(_args[0] if _args.size() > 0 else 0)
	var tile_y: int = int(_args[1] if _args.size() > 1 else 0)
	var rotation: int = int(_args[2] if _args.size() > 2 else 0)
	var valid: bool = bool(_args[3] if _args.size() > 3 else false)
	var draw_min_range: bool = bool(_args[4] if _args.size() > 4 else false)
	var source_tilesize: float = float(_args[5] if _args.size() > 5 else 0.0)
	var block_offset: float = float(_args[6] if _args.size() > 6 else 0.0)
	var min_range: float = float(_args[7] if _args.size() > 7 else 0.0)
	var dash_circle_x: float = float(tile_x) * source_tilesize + block_offset
	var dash_circle_y: float = float(tile_y) * source_tilesize + block_offset
	var dash_circle_called: bool = draw_min_range
	var dash_circle_call: Dictionary = {}
	if dash_circle_called:
		dash_circle_call = {"call": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, minRange, Pal.placing);", "x": dash_circle_x, "y": dash_circle_y, "radius": min_range, "color": "Pal.placing"}
	return {"source_owner": "PortGame.source_turret_draw_place_state", "method": "public void drawPlace(int x, int y, int rotation, boolean valid){", "override_expr": "@Override", "super_draw_place_expr": "super.drawPlace(x, y, rotation, valid);", "draw_min_range_gate": "if(drawMinRange){", "dash_circle_expr": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, minRange, Pal.placing);", "tile_x": tile_x, "tile_y": tile_y, "rotation": rotation, "valid": valid, "draw_min_range": draw_min_range, "source_tilesize": source_tilesize, "block_offset": block_offset, "min_range": min_range, "dash_circle_x": dash_circle_x, "dash_circle_y": dash_circle_y, "dash_circle_called": dash_circle_called, "dash_circle_call": dash_circle_call}

func java_method_rotatedOutput_10(_args: Array = []) -> Variant:
	var tile_x: int = int(_args[0] if _args.size() > 0 else 0)
	var tile_y: int = int(_args[1] if _args.size() > 1 else 0)
	return {"source_owner": "PortGame.source_turret_rotated_output_state", "method": "public boolean rotatedOutput(int x, int y){", "override_expr": "@Override", "return_expr": "return false;", "tile_x": tile_x, "tile_y": tile_y, "rotated_output": false}

func java_method_placeEnded_11(_args: Array = []) -> Variant:
	return null
