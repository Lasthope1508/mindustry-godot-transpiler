extends RefCounted
class_name SourceTractorBeamTurretLifecycleState

const SourceTimeDefaults := preload("res://src/game/SourceTimeDefaults.gd")
const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func icons_state(base_region: Variant, region: Variant) -> Dictionary:
	var icons: Array = [base_region, region]
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_icons_state",
		"method": "public TextureRegion[] icons(){",
		"override_expr": "@Override",
		"return_expr": "return new TextureRegion[]{baseRegion, region};",
		"base_region": base_region,
		"region": region,
		"icons": icons,
	}


static func generated_icons_bridge_state(base_region: Variant, region: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd", "java_method_icons_0", [base_region, region], null)
	var canonical = icons_state(base_region, region)
	return {
		"source_owner": "SourceTractorBeamTurretLifecycleState.icons_state",
		"generated_owner": "TractorBeamTurret.java_method_icons_0",
		"result": result,
		"canonical": canonical,
		"matches": SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical),
	}

static func init_state(range_value: float, source_tilesize: float) -> Dictionary:
	var clip_radius: float = range_value + source_tilesize
	var update_clip_radius_call: Dictionary = {"call": "updateClipRadius(range + tilesize);", "radius": clip_radius}
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_init_state",
		"method": "public void init(){",
		"override_expr": "@Override",
		"super_init_expr": "super.init();",
		"update_clip_radius_expr": "updateClipRadius(range + tilesize);",
		"range": range_value,
		"tilesize": source_tilesize,
		"clip_radius": clip_radius,
		"super_init_called": true,
		"update_clip_radius_called": true,
		"update_clip_radius_call": update_clip_radius_call,
	}


static func generated_init_bridge_state(range_value: float, source_tilesize: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd", "java_method_init_2", [range_value, source_tilesize], null)
	var canonical = init_state(range_value, source_tilesize)
	return {
		"source_owner": "SourceTractorBeamTurretLifecycleState.init_state",
		"generated_owner": "TractorBeamTurret.java_method_init_2",
		"result": result,
		"canonical": canonical,
		"matches": SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical),
	}

static func build_should_consume_state(super_should_consume: bool, target: Variant) -> Dictionary:
	var target_present: bool = target != null
	var should_consume: bool = super_should_consume and target_present
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_build_should_consume_state",
		"inner_class": "public class TractorBeamBuild extends BaseTurretBuild{",
		"field": "public @Nullable Unit target;",
		"method": "public boolean shouldConsume(){",
		"override_expr": "@Override",
		"return_expr": "return super.shouldConsume() && target != null;",
		"super_should_consume": super_should_consume,
		"target": target,
		"target_present": target_present,
		"should_consume": should_consume,
	}


static func generated_build_should_consume_bridge_state(super_should_consume: bool, target: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd", "java_inner_class_TractorBeamBuild_method_shouldConsume_1", [super_should_consume, target], null)
	var canonical = build_should_consume_state(super_should_consume, target)
	return {
		"source_owner": "SourceTractorBeamTurretLifecycleState.build_should_consume_state",
		"generated_owner": "TractorBeamTurret.TractorBeamBuild.shouldConsume",
		"result": result,
		"canonical": canonical,
		"matches": SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical),
	}

static func build_estimate_dps_state(any_state: bool, damage: float, efficiency: float, coolant_multiplier: float) -> Dictionary:
	var zero_guard: bool = (not any_state) or damage <= 0.0
	var estimate_dps: float = 0.0 if zero_guard else damage * SourceTimeDefaults.TICK_RATE * efficiency * coolant_multiplier
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_build_estimate_dps_state",
		"inner_class": "public class TractorBeamBuild extends BaseTurretBuild{",
		"method": "public float estimateDps(){",
		"override_expr": "@Override",
		"zero_guard_expr": "if(!any || damage <= 0) return 0f;",
		"return_expr": "return damage * 60f * efficiency * coolantMultiplier;",
		"any_state": any_state,
		"damage": damage,
		"efficiency": efficiency,
		"coolant_multiplier": coolant_multiplier,
		"zero_guard": zero_guard,
		"estimate_dps": estimate_dps,
	}


static func generated_build_estimate_dps_bridge_state(any_state: bool, damage: float, efficiency: float, coolant_multiplier: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd", "java_inner_class_TractorBeamBuild_method_estimateDps_2", [any_state, damage, efficiency, coolant_multiplier, SourceTimeDefaults.TICK_RATE], null)
	var canonical = build_estimate_dps_state(any_state, damage, efficiency, coolant_multiplier)
	return {
		"source_owner": "SourceTractorBeamTurretLifecycleState.build_estimate_dps_state",
		"generated_owner": "TractorBeamTurret.TractorBeamBuild.estimateDps",
		"result": result,
		"canonical": canonical,
		"matches": SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical),
	}

static func build_write_state(rotation_value: float) -> Dictionary:
	var write_f_call: Dictionary = {"call": "write.f(rotation);", "value": rotation_value}
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_build_write_state",
		"inner_class": "public class TractorBeamBuild extends BaseTurretBuild{",
		"method": "public void write(Writes write){",
		"override_expr": "@Override",
		"super_write_expr": "super.write(write);",
		"write_rotation_expr": "write.f(rotation);",
		"rotation": rotation_value,
		"super_write_called": true,
		"write_f_call": write_f_call,
	}


static func generated_build_write_bridge_state(rotation_value: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd", "java_inner_class_TractorBeamBuild_method_write_4", [rotation_value], null)
	var canonical = build_write_state(rotation_value)
	return {
		"source_owner": "SourceTractorBeamTurretLifecycleState.build_write_state",
		"generated_owner": "TractorBeamTurret.TractorBeamBuild.write",
		"result": result,
		"canonical": canonical,
		"matches": SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical),
	}

static func build_read_state(read_f_value: float, revision_value: int) -> Dictionary:
	var super_read_call: Dictionary = {"call": "super.read(read, revision);", "revision": revision_value}
	var read_f_call: Dictionary = {"call": "read.f();", "value": read_f_value}
	var rotation_after: float = read_f_value
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_build_read_state",
		"inner_class": "public class TractorBeamBuild extends BaseTurretBuild{",
		"method": "public void read(Reads read, byte revision){",
		"override_expr": "@Override",
		"super_read_expr": "super.read(read, revision);",
		"read_rotation_expr": "rotation = read.f();",
		"read_f_value": read_f_value,
		"revision_value": revision_value,
		"super_read_call": super_read_call,
		"read_f_call": read_f_call,
		"rotation_after": rotation_after,
	}


static func generated_build_read_bridge_state(read_f_value: float, revision_value: int) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd", "java_inner_class_TractorBeamBuild_method_read_5", [read_f_value, revision_value], null)
	var canonical = build_read_state(read_f_value, revision_value)
	return {
		"source_owner": "SourceTractorBeamTurretLifecycleState.build_read_state",
		"generated_owner": "TractorBeamTurret.TractorBeamBuild.read",
		"result": result,
		"canonical": canonical,
		"matches": SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical),
	}
