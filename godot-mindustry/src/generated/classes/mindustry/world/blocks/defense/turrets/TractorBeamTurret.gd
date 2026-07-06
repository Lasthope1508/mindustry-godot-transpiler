# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/turrets/TractorBeamTurret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense.turrets"
const JAVA_KIND := "class"
const JAVA_NAME := "TractorBeamTurret"
const JAVA_EXTENDS := "BaseTurret"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "timerTarget", "type": "int"}, {"modifiers": ["public"], "name": "retargetTime", "type": "float"}, {"modifiers": ["public"], "name": "shootCone", "type": "float"}, {"modifiers": ["public"], "name": "shootLength", "type": "float"}, {"modifiers": ["public"], "name": "laserWidth", "type": "float"}, {"modifiers": ["public"], "name": "force", "type": "float"}, {"modifiers": ["public"], "name": "scaledForce", "type": "float"}, {"modifiers": ["public"], "name": "damage", "type": "float"}, {"modifiers": ["public"], "name": "targetAir", "type": "boolean"}, {"modifiers": ["public"], "name": "targetGround", "type": "boolean"}, {"modifiers": ["public"], "name": "laserColor", "type": "Color"}, {"modifiers": ["public"], "name": "status", "type": "StatusEffect"}, {"modifiers": ["public"], "name": "statusDuration", "type": "float"}, {"modifiers": ["public"], "name": "shootSound", "type": "Sound"}, {"modifiers": ["public"], "name": "shootSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "baseRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laser", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserStart", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserEnd", "type": "TextureRegion"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "TractorBeamTurret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_icons_0(_args: Array = []) -> Variant:
	var base_region: Variant = _args[0] if _args.size() > 0 else null
	var region: Variant = _args[1] if _args.size() > 1 else null
	var icons: Array = [base_region, region]
	return {"source_owner": "PortGame.source_tractor_beam_turret_icons_state", "method": "public TextureRegion[] icons(){", "override_expr": "@Override", "return_expr": "return new TextureRegion[]{baseRegion, region};", "base_region": base_region, "region": region, "icons": icons}

func java_method_setStats_1(_args: Array = []) -> Variant:
	var target_air: bool = bool(_args[0] if _args.size() > 0 else true)
	var target_ground: bool = bool(_args[1] if _args.size() > 1 else false)
	var damage: float = float(_args[2] if _args.size() > 2 else 0.0)
	var targets_air_stat_call: Dictionary = {"call": "stats.add(Stat.targetsAir, targetAir);", "stat": "Stat.targetsAir", "value": target_air}
	var targets_ground_stat_call: Dictionary = {"call": "stats.add(Stat.targetsGround, targetGround);", "stat": "Stat.targetsGround", "value": target_ground}
	var damage_per_second: float = damage * 60.0
	var damage_stat_added: bool = damage > 0.0
	var damage_stat_call: Dictionary = {}
	if damage_stat_added:
		damage_stat_call = {"call": "stats.add(Stat.damage, damage * 60f, StatUnit.perSecond);", "stat": "Stat.damage", "value": damage_per_second, "unit": "StatUnit.perSecond"}
	return {"source_owner": "PortGame.source_tractor_beam_turret_set_stats_state", "method": "public void setStats(){", "override_expr": "@Override", "super_set_stats_expr": "super.setStats();", "targets_air_stat_expr": "stats.add(Stat.targetsAir, targetAir);", "targets_ground_stat_expr": "stats.add(Stat.targetsGround, targetGround);", "damage_stat_expr": "if(damage > 0) stats.add(Stat.damage, damage * 60f, StatUnit.perSecond);", "target_air": target_air, "target_ground": target_ground, "damage": damage, "super_set_stats_called": true, "targets_air_stat_call": targets_air_stat_call, "targets_ground_stat_call": targets_ground_stat_call, "damage_per_second": damage_per_second, "damage_stat_added": damage_stat_added, "damage_stat_call": damage_stat_call}

func java_method_init_2(_args: Array = []) -> Variant:
	var range_value: float = float(_args[0] if _args.size() > 0 else 0.0)
	var source_tilesize: float = float(_args[1] if _args.size() > 1 else 8.0)
	var clip_radius: float = range_value + source_tilesize
	var update_clip_radius_call: Dictionary = {"call": "updateClipRadius(range + tilesize);", "radius": clip_radius}
	return {"source_owner": "PortGame.source_tractor_beam_turret_init_state", "method": "public void init(){", "override_expr": "@Override", "super_init_expr": "super.init();", "update_clip_radius_expr": "updateClipRadius(range + tilesize);", "range": range_value, "tilesize": source_tilesize, "clip_radius": clip_radius, "super_init_called": true, "update_clip_radius_called": true, "update_clip_radius_call": update_clip_radius_call}

func java_inner_class_TractorBeamBuild_method_updateTile_0(_args: Array = []) -> Variant:
	var activation_timer: float = float(_args[0] if _args.size() > 0 else 0.0)
	var time_delta: float = float(_args[1] if _args.size() > 1 else 0.0)
	var activation_guard: bool = activation_timer > 0.0
	var activation_timer_after: float = activation_timer - time_delta if activation_guard else activation_timer
	var returned_early: bool = activation_guard
	return {"source_owner": "PortGame.source_tractor_beam_turret_build_update_tile_activation_state", "inner_class": "public class TractorBeamBuild extends BaseTurretBuild{", "method": "public void updateTile(){", "override_expr": "@Override", "activation_guard_expr": "if(activationTimer > 0){", "activation_decrement_expr": "activationTimer -= Time.delta;", "return_expr": "return;", "next_expr": "float eff = efficiency * coolantMultiplier, edelta = eff * delta();", "activation_timer": activation_timer, "time_delta": time_delta, "activation_guard": activation_guard, "activation_timer_after": activation_timer_after, "returned_early": returned_early}

func java_inner_class_TractorBeamBuild_method_shouldConsume_1(_args: Array = []) -> Variant:
	var super_should_consume: bool = bool(_args[0] if _args.size() > 0 else false)
	var target: Variant = _args[1] if _args.size() > 1 else null
	var target_present: bool = target != null
	var should_consume: bool = super_should_consume and target_present
	return {"source_owner": "PortGame.source_tractor_beam_turret_build_should_consume_state", "inner_class": "public class TractorBeamBuild extends BaseTurretBuild{", "field": "public @Nullable Unit target;", "method": "public boolean shouldConsume(){", "override_expr": "@Override", "return_expr": "return super.shouldConsume() && target != null;", "super_should_consume": super_should_consume, "target": target, "target_present": target_present, "should_consume": should_consume}

func java_inner_class_TractorBeamBuild_method_estimateDps_2(_args: Array = []) -> Variant:
	var any_state: bool = bool(_args[0] if _args.size() > 0 else false)
	var damage: float = float(_args[1] if _args.size() > 1 else 0.0)
	var efficiency: float = float(_args[2] if _args.size() > 2 else 0.0)
	var coolant_multiplier: float = float(_args[3] if _args.size() > 3 else 1.0)
	var zero_guard: bool = (not any_state) or damage <= 0.0
	var estimate_dps: float = 0.0 if zero_guard else damage * 60.0 * efficiency * coolant_multiplier
	return {"source_owner": "PortGame.source_tractor_beam_turret_build_estimate_dps_state", "inner_class": "public class TractorBeamBuild extends BaseTurretBuild{", "method": "public float estimateDps(){", "override_expr": "@Override", "zero_guard_expr": "if(!any || damage <= 0) return 0f;", "return_expr": "return damage * 60f * efficiency * coolantMultiplier;", "any_state": any_state, "damage": damage, "efficiency": efficiency, "coolant_multiplier": coolant_multiplier, "zero_guard": zero_guard, "estimate_dps": estimate_dps}

func java_inner_class_TractorBeamBuild_method_draw_3(_args: Array = []) -> Variant:
	var base_region: Variant = _args[0] if _args.size() > 0 else null
	var region: Variant = _args[1] if _args.size() > 1 else null
	var x: float = float(_args[2] if _args.size() > 2 else 0.0)
	var y: float = float(_args[3] if _args.size() > 3 else 0.0)
	var rotation_value: float = float(_args[4] if _args.size() > 4 else 0.0)
	var size: float = float(_args[5] if _args.size() > 5 else 0.0)
	var any_state: bool = bool(_args[6] if _args.size() > 6 else false)
	var is_payload: bool = bool(_args[7] if _args.size() > 7 else false)
	var last_x: float = float(_args[8] if _args.size() > 8 else 0.0)
	var last_y: float = float(_args[9] if _args.size() > 9 else 0.0)
	var laser_color: Variant = _args[10] if _args.size() > 10 else null
	var mathf_absin_4_0_6: float = float(_args[11] if _args.size() > 11 else 0.0)
	var laser: Variant = _args[12] if _args.size() > 12 else null
	var laser_start: Variant = _args[13] if _args.size() > 13 else null
	var laser_end: Variant = _args[14] if _args.size() > 14 else null
	var shoot_length: float = float(_args[15] if _args.size() > 15 else 0.0)
	var strength: float = float(_args[16] if _args.size() > 16 else 0.0)
	var efficiency: float = float(_args[17] if _args.size() > 17 else 0.0)
	var laser_width: float = float(_args[18] if _args.size() > 18 else 0.0)
	var draw_rotation: float = rotation_value - 90.0
	var base_rect_call: Dictionary = {"call": "Draw.rect(baseRegion, x, y);", "region": base_region, "x": x, "y": y}
	var shadow_call: Dictionary = {"call": "Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);", "region": region, "x": x - size / 2.0, "y": y - size / 2.0, "rotation": draw_rotation}
	var region_rect_call: Dictionary = {"call": "Draw.rect(region, x, y, rotation - 90);", "region": region, "x": x, "y": y, "rotation": draw_rotation}
	var laser_guard: bool = any_state and not is_payload
	var angle_to_last: float = rad_to_deg(atan2(last_y - y, last_x - x))
	var laser_start_x: float = x + cos(deg_to_rad(angle_to_last)) * shoot_length
	var laser_start_y: float = y + sin(deg_to_rad(angle_to_last)) * shoot_length
	var laser_width_value: float = strength * efficiency * laser_width
	var draw_z_call: Dictionary = {}
	var mixcol_call: Dictionary = {}
	var laser_call: Dictionary = {}
	var mixcol_reset_called: bool = false
	if laser_guard:
		draw_z_call = {"call": "Draw.z(Layer.bullet);", "layer": "Layer.bullet"}
		mixcol_call = {"call": "Draw.mixcol(laserColor, Mathf.absin(4f, 0.6f));", "color": laser_color, "alpha": mathf_absin_4_0_6}
		laser_call = {"call": "Drawf.laser(laser, laserStart, laserEnd, x + Angles.trnsx(ang, shootLength), y + Angles.trnsy(ang, shootLength), lastX, lastY, strength * efficiency * laserWidth);", "laser": laser, "laser_start": laser_start, "laser_end": laser_end, "start_x": laser_start_x, "start_y": laser_start_y, "end_x": last_x, "end_y": last_y, "width": laser_width_value}
		mixcol_reset_called = true
	return {"source_owner": "PortGame.source_tractor_beam_turret_build_draw_state", "inner_class": "public class TractorBeamBuild extends BaseTurretBuild{", "method": "public void draw(){", "override_expr": "@Override", "base_rect_expr": "Draw.rect(baseRegion, x, y);", "shadow_expr": "Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);", "region_rect_expr": "Draw.rect(region, x, y, rotation - 90);", "laser_guard_expr": "if(any && !isPayload()){", "draw_z_expr": "Draw.z(Layer.bullet);", "angle_expr": "float ang = angleTo(lastX, lastY);", "mixcol_expr": "Draw.mixcol(laserColor, Mathf.absin(4f, 0.6f));", "laser_expr": "Drawf.laser(laser, laserStart, laserEnd, x + Angles.trnsx(ang, shootLength), y + Angles.trnsy(ang, shootLength), lastX, lastY, strength * efficiency * laserWidth);", "mixcol_reset_expr": "Draw.mixcol();", "base_region": base_region, "region": region, "x": x, "y": y, "rotation": rotation_value, "size": size, "any_state": any_state, "is_payload": is_payload, "last_x": last_x, "last_y": last_y, "laser_color": laser_color, "mathf_absin_4_0_6": mathf_absin_4_0_6, "laser": laser, "laser_start": laser_start, "laser_end": laser_end, "shoot_length": shoot_length, "strength": strength, "efficiency": efficiency, "laser_width": laser_width, "draw_rotation": draw_rotation, "base_rect_call": base_rect_call, "shadow_call": shadow_call, "region_rect_call": region_rect_call, "laser_guard": laser_guard, "angle_to_last": angle_to_last, "laser_start_x": laser_start_x, "laser_start_y": laser_start_y, "laser_width_value": laser_width_value, "draw_z_call": draw_z_call, "mixcol_call": mixcol_call, "laser_call": laser_call, "mixcol_reset_called": mixcol_reset_called}

func java_inner_class_TractorBeamBuild_method_write_4(_args: Array = []) -> Variant:
	var rotation: float = float(_args[0] if _args.size() > 0 else 0.0)
	var write_f_call: Dictionary = {"call": "write.f(rotation);", "value": rotation}
	return {"source_owner": "PortGame.source_tractor_beam_turret_build_write_state", "inner_class": "public class TractorBeamBuild extends BaseTurretBuild{", "method": "public void write(Writes write){", "override_expr": "@Override", "super_write_expr": "super.write(write);", "write_rotation_expr": "write.f(rotation);", "rotation": rotation, "super_write_called": true, "write_f_call": write_f_call}

func java_inner_class_TractorBeamBuild_method_read_5(_args: Array = []) -> Variant:
	var read_f_value: float = float(_args[0] if _args.size() > 0 else 0.0)
	var revision_value: int = int(_args[1] if _args.size() > 1 else 0)
	var super_read_call: Dictionary = {"call": "super.read(read, revision);", "revision": revision_value}
	var read_f_call: Dictionary = {"call": "read.f();", "value": read_f_value}
	var rotation_after: float = read_f_value
	return {"source_owner": "PortGame.source_tractor_beam_turret_build_read_state", "inner_class": "public class TractorBeamBuild extends BaseTurretBuild{", "method": "public void read(Reads read, byte revision){", "override_expr": "@Override", "super_read_expr": "super.read(read, revision);", "read_rotation_expr": "rotation = read.f();", "read_f_value": read_f_value, "revision_value": revision_value, "super_read_call": super_read_call, "read_f_call": read_f_call, "rotation_after": rotation_after}
