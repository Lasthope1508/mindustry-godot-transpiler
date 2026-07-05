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
