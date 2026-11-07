extends RefCounted
class_name SourceBulletTypeCreateUnitsState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

const SOURCE_BULLET_DESPAWN_UNIT_RADIUS_DEFAULT := source_bullet_defaults.DESPAWN_UNIT_RADIUS_DEFAULT
const SOURCE_ARC_RAD_FULL := source_math_defaults.ARC_RAD_FULL

static func initial_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_state: Dictionary, create_units_random_state: Dictionary, net_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_create_units_state: Dictionary = create_units_state.duplicate(true)
	var update_random_state: Dictionary = create_units_random_state.duplicate(true)
	var update_net_state: Dictionary = net_state.duplicate(true)
	var unit_x := float(update_create_units_state.get("x", 0.0))
	var unit_y := float(update_create_units_state.get("y", 0.0))
	var net_client := bool(update_net_state.get("client", false))
	var despawn_unit: Variant = update_type_state.get("despawnUnit", null)
	var despawn_unit_chance := float(update_type_state.get("despawnUnitChance", 1.0))
	var despawn_unit_count := int(update_type_state.get("despawnUnitCount", 1))
	var despawn_unit_radius := float(update_type_state.get("despawnUnitRadius", SOURCE_BULLET_DESPAWN_UNIT_RADIUS_DEFAULT))
	var face_outwards := bool(update_type_state.get("faceOutwards", false))
	var bullet_team: Variant = update_bullet_state.get("team", null)
	var chance_passed: Variant = update_random_state.get("chancePassed", null)
	var create_units_gate_passed: bool = not net_client and despawn_unit != null and chance_passed == true
	var loop_iterations := despawn_unit_count if create_units_gate_passed else 0
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createUnits": update_create_units_state,
		"createUnitsRandom": update_random_state,
		"net": update_net_state,
		"x": unit_x,
		"y": unit_y,
		"netClient": net_client,
		"despawnUnit": despawn_unit,
		"despawnUnitChance": despawn_unit_chance,
		"despawnUnitCount": despawn_unit_count,
		"despawnUnitRadius": despawn_unit_radius,
		"faceOutwards": face_outwards,
		"bulletTeam": bullet_team,
		"chancePassed": chance_passed,
		"chancePassedProvided": chance_passed != null,
		"createUnitsGatePassed": create_units_gate_passed,
		"loopIterations": loop_iterations,
		"gateSource": "if(!net.client() && despawnUnit != null && Mathf.chance(despawnUnitChance)){",
		"loopBoundarySource": "for(int i = 0; i < despawnUnitCount; i++){",
		"randomOffsetBoundarySource": "Tmp.v1.rnd(Mathf.random(despawnUnitRadius));",
		"spawnBoundarySource": "var u = despawnUnit.spawn(b.team, x + Tmp.v1.x, y + Tmp.v1.y);",
		"rotationBoundarySource": "u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation();",
		"notifyBoundarySource": "Units.notifyUnitSpawn(u);",
	}

static func random_offset_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_initial_state: Dictionary, create_units_random_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_initial_state: Dictionary = create_units_initial_state.duplicate(true)
	var update_random_state: Dictionary = create_units_random_state.duplicate(true)
	var length_samples: Array = update_random_state.get("lengthSamples", [])
	var theta_samples: Array = update_random_state.get("thetaSamples", [])
	var unit_offset_plans: Array = []
	var create_units_gate_passed := bool(update_initial_state.get("createUnitsGatePassed", false))
	var loop_iterations := int(update_initial_state.get("loopIterations", 0))
	var despawn_unit_radius := float(update_type_state.get("despawnUnitRadius", update_initial_state.get("despawnUnitRadius", SOURCE_BULLET_DESPAWN_UNIT_RADIUS_DEFAULT)))
	var base_x := float(update_initial_state.get("x", 0.0))
	var base_y := float(update_initial_state.get("y", 0.0))
	if create_units_gate_passed:
		for i in loop_iterations:
			var length_sample: Variant = length_samples[i] if i < length_samples.size() else null
			var theta_sample: Variant = theta_samples[i] if i < theta_samples.size() else null
			var tmp_v1_x: Variant = null
			var tmp_v1_y: Variant = null
			if length_sample != null and theta_sample != null:
				var tmp_v1_state := source_math_state.source_vec2_rotate_radians(float(length_sample), 0.0, float(theta_sample))
				tmp_v1_x = float(tmp_v1_state.get("x", 0.0))
				tmp_v1_y = float(tmp_v1_state.get("y", 0.0))
			unit_offset_plans.append({
				"index": i,
				"baseX": base_x,
				"baseY": base_y,
				"length": length_sample,
				"lengthSampleProvided": length_sample != null,
				"lengthRandomCall": {"call": "Mathf.random(despawnUnitRadius)", "range": despawn_unit_radius, "value": length_sample},
				"theta": theta_sample,
				"thetaSampleProvided": theta_sample != null,
				"thetaRandomCall": {"call": "Mathf.random(0f, Mathf.PI2)", "start": 0.0, "end": SOURCE_ARC_RAD_FULL, "value": theta_sample},
				"tmpV1X": tmp_v1_x,
				"tmpV1Y": tmp_v1_y,
				"call": "Tmp.v1.rnd(Mathf.random(despawnUnitRadius))",
			})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createUnitsInitial": update_initial_state,
		"createUnitsRandom": update_random_state,
		"createUnitsGatePassed": create_units_gate_passed,
		"loopIterations": loop_iterations,
		"despawnUnitRadius": despawn_unit_radius,
		"x": base_x,
		"y": base_y,
		"unitOffsetPlans": unit_offset_plans,
		"randomLengthSource": "Mathf.random(despawnUnitRadius)",
		"vec2RndSource": "Tmp.v1.rnd(Mathf.random(despawnUnitRadius));",
		"randomDirectionSource": "float theta = Mathf.random(0f, Mathf.PI2);",
		"spawnBoundarySource": "var u = despawnUnit.spawn(b.team, x + Tmp.v1.x, y + Tmp.v1.y);",
	}

static func spawn_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_random_offset_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_random_offset_state: Dictionary = create_units_random_offset_state.duplicate(true)
	var unit_offset_plans: Array = update_random_offset_state.get("unitOffsetPlans", [])
	var spawn_calls: Array = []
	var despawn_unit: Variant = update_type_state.get("despawnUnit", update_random_offset_state.get("despawnUnit", null))
	var bullet_team: Variant = update_bullet_state.get("team", update_random_offset_state.get("bulletTeam", null))
	var create_units_gate_passed := bool(update_random_offset_state.get("createUnitsGatePassed", false))
	if create_units_gate_passed:
		for plan in unit_offset_plans:
			var base_x: Variant = plan.get("baseX", update_random_offset_state.get("x", null))
			var base_y: Variant = plan.get("baseY", update_random_offset_state.get("y", null))
			var tmp_v1_x: Variant = plan.get("tmpV1X", null)
			var tmp_v1_y: Variant = plan.get("tmpV1Y", null)
			var spawn_x: Variant = null
			var spawn_y: Variant = null
			if base_x != null and tmp_v1_x != null:
				spawn_x = float(base_x) + float(tmp_v1_x)
			if base_y != null and tmp_v1_y != null:
				spawn_y = float(base_y) + float(tmp_v1_y)
			spawn_calls.append({
				"index": int(plan.get("index", spawn_calls.size())),
				"despawnUnit": despawn_unit,
				"team": bullet_team,
				"x": spawn_x,
				"y": spawn_y,
				"baseX": base_x,
				"baseY": base_y,
				"tmpV1X": tmp_v1_x,
				"tmpV1Y": tmp_v1_y,
				"call": "despawnUnit.spawn(b.team, x + Tmp.v1.x, y + Tmp.v1.y)",
			})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createUnitsRandomOffset": update_random_offset_state,
		"createUnitsGatePassed": create_units_gate_passed,
		"despawnUnit": despawn_unit,
		"bulletTeam": bullet_team,
		"unitOffsetPlans": unit_offset_plans,
		"spawnCalls": spawn_calls,
		"spawnSource": "despawnUnit.spawn(b.team, x + Tmp.v1.x, y + Tmp.v1.y)",
		"rotationBoundarySource": "u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation();",
		"notifyBoundarySource": "Units.notifyUnitSpawn(u);",
	}

static func rotation_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_spawn_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_spawn_state: Dictionary = create_units_spawn_state.duplicate(true)
	var spawn_calls: Array = update_spawn_state.get("spawnCalls", [])
	var face_outwards := bool(update_type_state.get("faceOutwards", update_spawn_state.get("faceOutwards", false)))
	var bullet_rotation: Variant = update_bullet_state.get("rotation", null)
	var rotation_assignments: Array = []
	for spawn_call in spawn_calls:
		var tmp_v1_x: Variant = spawn_call.get("tmpV1X", null)
		var tmp_v1_y: Variant = spawn_call.get("tmpV1Y", null)
		var tmp_v1_angle: Variant = null
		if tmp_v1_x != null and tmp_v1_y != null:
			tmp_v1_angle = source_math_state.source_angles_angle(0.0, 0.0, float(tmp_v1_x), float(tmp_v1_y))
		var unit_rotation: Variant = tmp_v1_angle if face_outwards else bullet_rotation
		rotation_assignments.append({
			"index": int(spawn_call.get("index", rotation_assignments.size())),
			"faceOutwards": face_outwards,
			"bulletRotation": bullet_rotation,
			"tmpV1X": tmp_v1_x,
			"tmpV1Y": tmp_v1_y,
			"tmpV1Angle": tmp_v1_angle,
			"unitRotation": unit_rotation,
			"assignment": "u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation()",
		})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createUnitsSpawn": update_spawn_state,
		"faceOutwards": face_outwards,
		"bulletRotation": bullet_rotation,
		"spawnCalls": spawn_calls,
		"rotationAssignments": rotation_assignments,
		"rotationSource": "u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation();",
		"vec2AngleSource": "public float angle(){ float angle = Mathf.atan2(x, y) * Mathf.radiansToDegrees; if(angle < 0) angle += 360; return angle; }",
		"bulletRotationSource": "return vel.isZero(0.001f) ? rotation : vel.angle();",
		"notifyBoundarySource": "Units.notifyUnitSpawn(u);",
	}

static func notify_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_rotation_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_rotation_state: Dictionary = create_units_rotation_state.duplicate(true)
	var rotation_assignments: Array = update_rotation_state.get("rotationAssignments", [])
	var notify_calls: Array = []
	for rotation_assignment in rotation_assignments:
		notify_calls.append({
			"index": int(rotation_assignment.get("index", notify_calls.size())),
			"unitRotation": rotation_assignment.get("unitRotation", null),
			"call": "Units.notifyUnitSpawn(u)",
		})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createUnitsRotation": update_rotation_state,
		"rotationAssignments": rotation_assignments,
		"notifyCalls": notify_calls,
		"notifySource": "Units.notifyUnitSpawn(u);",
	}
