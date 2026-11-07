extends RefCounted
class_name SourceBulletRemovedRuntimeState

static func removed_trail_fade_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var trail_length := int(update_type_state.get("trailLength", -1))
	var trail_width := float(update_type_state.get("trailWidth", 2.0))
	var trail_color: Variant = update_type_state.get("trailColor", "Pal.missileYellowBack")
	var bullet_x: Variant = update_bullet_state.get("x", null)
	var bullet_y: Variant = update_bullet_state.get("y", null)
	var trail_state: Variant = update_bullet_state.get("trail", null)
	var trail_exists := trail_state != null
	var trail_size: Variant = null
	var trail_copy: Variant = null
	if trail_state is Dictionary:
		trail_size = trail_state.get("size", null)
	var gate_passed := trail_length > 0 and trail_exists and trail_size != null and int(trail_size) > 0
	var trail_fade_call: Variant = null
	if gate_passed:
		if trail_state is Dictionary:
			trail_copy = (trail_state as Dictionary).duplicate(true)
		else:
			trail_copy = trail_state
		trail_fade_call = {
			"call": "Fx.trailFade.at(b.x, b.y, trailWidth, trailColor, b.trail.copy())",
			"x": bullet_x,
			"y": bullet_y,
			"width": trail_width,
			"color": trail_color,
			"trailCopy": trail_copy,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"trailLength": trail_length,
		"trailWidth": trail_width,
		"trailColor": trail_color,
		"trailExists": trail_exists,
		"trailSize": trail_size,
		"gatePassed": gate_passed,
		"trailFadeCall": trail_fade_call,
		"gateSource": "if(trailLength > 0 && b.trail != null && b.trail.size() > 0){",
		"trailFadeCallSource": "Fx.trailFade.at(b.x, b.y, trailWidth, trailColor, b.trail.copy());",
		"trailCopySource": "public Trail copy(){ Trail out = new Trail(length); out.points.addAll(points); return out; }",
		"trailSizeSource": "public int size(){ return points.size/3; }",
		"fragBoundarySource": "if(b.frags == 0 && fragOnDespawn && fragBullet != null){",
	}

static func removed_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_removed_trail_fade_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_removed_trail_fade_state: Dictionary = incoming_removed_trail_fade_state.duplicate(true)
	var bullet_frags := int(update_bullet_state.get("frags", 0))
	var frag_on_despawn := bool(update_type_state.get("fragOnDespawn", true))
	var frag_bullet: Variant = update_type_state.get("fragBullet", null)
	var frag_bullet_exists := frag_bullet != null
	var bullet_x: Variant = update_bullet_state.get("x", null)
	var bullet_y: Variant = update_bullet_state.get("y", null)
	var frag_gate_passed := bullet_frags == 0 and frag_on_despawn and frag_bullet_exists
	var create_frags_call := {}
	if frag_gate_passed:
		create_frags_call = {
			"call": "createFrags(b, b.x, b.y)",
			"x": bullet_x,
			"y": bullet_y,
			"called": true,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"removedTrailFade": update_removed_trail_fade_state,
		"bulletFrags": bullet_frags,
		"fragOnDespawn": frag_on_despawn,
		"fragBullet": frag_bullet,
		"fragBulletExists": frag_bullet_exists,
		"fragGatePassed": frag_gate_passed,
		"createFragsCall": create_frags_call,
		"fragGateSource": "if(b.frags == 0 && fragOnDespawn && fragBullet != null){",
		"createFragsCallSource": "createFrags(b, b.x, b.y);",
		"buildingDamageBoundarySource": "public float buildingDamage(Bullet b){",
	}
