extends RefCounted
class_name SourceBulletTypeDrawState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")

static func draw_state(bullet_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var draw_calls := ["drawTrail(b)", "drawParts(b)"]
	return {
		"bullet": update_bullet_state,
		"drawCalls": draw_calls,
		"drawTrailCalled": true,
		"drawPartsCalled": true,
		"drawReturnSource": "drawTrail(b); drawParts(b);",
	}

static func draw_trail_state(bullet_type_state: Dictionary, bullet_state: Dictionary, current_draw_z: float) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var trail_length := int(update_type_state.get("trailLength", -1))
	var trail_exists := update_bullet_state.get("trail", null) != null
	var gate_passed := trail_length > 0 and trail_exists
	var draw_z_below := current_draw_z - 0.0001
	var trail_width := float(update_type_state.get("trailWidth", source_bullet_defaults.TRAIL_WIDTH_DEFAULT))
	var trail_color := str(update_type_state.get("trailColor", "Pal.missileYellowBack"))
	var trail_draw_call: Variant = null
	if gate_passed:
		trail_draw_call = {"call": "b.trail.draw(trailColor, trailWidth)", "color": trail_color, "width": trail_width}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"currentDrawZ": current_draw_z,
		"trailLength": trail_length,
		"trailExists": trail_exists,
		"trailWidth": trail_width,
		"trailColor": trail_color,
		"gatePassed": gate_passed,
		"drawZBelow": draw_z_below,
		"trailDrawCall": trail_draw_call,
		"drawZBelowSource": "Draw.z(z - 0.0001f)",
		"drawZRestoreSource": "Draw.z(z)",
	}

static func draw_parts_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var parts: Array = update_type_state.get("parts", [])
	var gate_passed := parts.size() > 0
	var fin := float(update_bullet_state.get("fin", 0.0))
	var part_params := {
		"warmup": fin,
		"life": fin,
		"x": float(update_bullet_state.get("x", 0.0)),
		"y": float(update_bullet_state.get("y", 0.0)),
		"rotation": float(update_bullet_state.get("rotation", 0.0)),
		"reload": 0,
		"smoothReload": 0,
		"heat": 0,
		"recoil": 0,
		"charge": 0,
	}
	var part_draw_calls: Array = []
	if gate_passed:
		for i in range(parts.size()):
			part_draw_calls.append({"part": parts[i], "params": part_params.duplicate(true), "call": "parts.get(i).draw(DrawPart.params)"})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"parts": parts,
		"gatePassed": gate_passed,
		"fin": fin,
		"partParams": part_params,
		"partDrawCalls": part_draw_calls,
		"paramsSetSource": "DrawPart.params.set(b.fin(), 0f, 0f, 0f, 0f, 0f, b.x, b.y, b.rotation())",
	}

static func draw_light_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var light_opacity := float(update_type_state.get("lightOpacity", 0.3))
	var light_radius := float(update_type_state.get("lightRadius", -1.0))
	var light_color := str(update_type_state.get("lightColor", "Pal.powerLight"))
	var gate_passed := light_opacity > 0.0 and light_radius > 0.0
	var drawf_light_call: Variant = null
	if gate_passed:
		drawf_light_call = {"call": "Drawf.light(b, lightRadius, lightColor, lightOpacity)", "radius": light_radius, "color": light_color, "opacity": light_opacity}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"lightRadius": light_radius,
		"lightColor": light_color,
		"lightOpacity": light_opacity,
		"gatePassed": gate_passed,
		"lightDrawn": gate_passed,
		"drawfLightCall": drawf_light_call,
		"earlyReturnSource": "if(lightOpacity <= 0f || lightRadius <= 0f) return",
	}
