extends RefCounted
class_name SourceTractorBeamTurretBuildDrawState

const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS := "res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd"
const SOURCE_TRACTOR_BEAM_DRAW_ROTATION_OFFSET_DEGREES := source_turret_defaults.TRACTOR_BEAM_DRAW_ROTATION_OFFSET_DEGREES

static func _tractor_beam_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)


static func draw_state(base_region: Variant, region: Variant, x: float, y: float, rotation_value: float, size: float, any_state: bool, is_payload: bool, last_x: float, last_y: float, laser_color: Variant, mathf_absin_4_0_6: float, laser: Variant, laser_start: Variant, laser_end: Variant, shoot_length: float, strength: float, efficiency: float, laser_width: float) -> Dictionary:
	var draw_rotation: float = rotation_value - SOURCE_TRACTOR_BEAM_DRAW_ROTATION_OFFSET_DEGREES
	var shadow_rotation: float = rotation_value - SOURCE_TRACTOR_BEAM_DRAW_ROTATION_OFFSET_DEGREES
	var base_rect_call: Dictionary = {"call": "Draw.rect(baseRegion, x, y);", "region": base_region, "x": x, "y": y}
	var shadow_call: Dictionary = {"call": "Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);", "region": region, "x": x - size / 2.0, "y": y - size / 2.0, "rotation": shadow_rotation}
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
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_DRAW_STATE,
		"inner_class": "public class TractorBeamBuild extends BaseTurretBuild{",
		"method": "public void draw(){",
		"override_expr": "@Override",
		"base_rect_expr": "Draw.rect(baseRegion, x, y);",
		"shadow_expr": "Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);",
		"region_rect_expr": "Draw.rect(region, x, y, rotation - 90);",
		"laser_guard_expr": "if(any && !isPayload()){",
		"draw_z_expr": "Draw.z(Layer.bullet);",
		"angle_expr": "float ang = angleTo(lastX, lastY);",
		"mixcol_expr": "Draw.mixcol(laserColor, Mathf.absin(4f, 0.6f));",
		"laser_expr": "Drawf.laser(laser, laserStart, laserEnd, x + Angles.trnsx(ang, shootLength), y + Angles.trnsy(ang, shootLength), lastX, lastY, strength * efficiency * laserWidth);",
		"mixcol_reset_expr": "Draw.mixcol();",
		"base_region": base_region,
		"region": region,
		"x": x,
		"y": y,
		"rotation": rotation_value,
		"size": size,
		"any_state": any_state,
		"is_payload": is_payload,
		"last_x": last_x,
		"last_y": last_y,
		"laser_color": laser_color,
		"mathf_absin_4_0_6": mathf_absin_4_0_6,
		"laser": laser,
		"laser_start": laser_start,
		"laser_end": laser_end,
		"shoot_length": shoot_length,
		"strength": strength,
		"efficiency": efficiency,
		"laser_width": laser_width,
		"draw_rotation": draw_rotation,
		"shadow_rotation": shadow_rotation,
		"base_rect_call": base_rect_call,
		"shadow_call": shadow_call,
		"region_rect_call": region_rect_call,
		"laser_guard": laser_guard,
		"angle_to_last": angle_to_last,
		"laser_start_x": laser_start_x,
		"laser_start_y": laser_start_y,
		"laser_width_value": laser_width_value,
		"draw_z_call": draw_z_call,
		"mixcol_call": mixcol_call,
		"laser_call": laser_call,
		"mixcol_reset_called": mixcol_reset_called,
	}


static func generated_draw_bridge_state(base_region: Variant, region: Variant, x: float, y: float, rotation_value: float, size: float, any_state: bool, is_payload: bool, last_x: float, last_y: float, laser_color: Variant, mathf_absin_4_0_6: float, laser: Variant, laser_start: Variant, laser_end: Variant, shoot_length: float, strength: float, efficiency: float, laser_width: float) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_draw_3", [base_region, region, x, y, rotation_value, size, any_state, is_payload, last_x, last_y, laser_color, mathf_absin_4_0_6, laser, laser_start, laser_end, shoot_length, strength, efficiency, laser_width])
	var canonical = draw_state(base_region, region, x, y, rotation_value, size, any_state, is_payload, last_x, last_y, laser_color, mathf_absin_4_0_6, laser, laser_start, laser_end, shoot_length, strength, efficiency, laser_width)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_DRAW_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.draw",
		"result": result,
		"canonical": canonical,
		"matches": result.get("base_rect_call", null) == canonical.get("base_rect_call", null) and result.get("shadow_call", null) == canonical.get("shadow_call", null),
	}
