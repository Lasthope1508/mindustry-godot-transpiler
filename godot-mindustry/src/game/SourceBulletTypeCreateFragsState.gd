extends RefCounted
class_name SourceBulletTypeCreateFragsState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_geometry_callback_registry := preload("res://src/game/SourceGeometryCallbackRegistry.gd")
const SOURCE_BULLET_TYPE_CREATE_FRAGS_TRNS_VEC_KEY := source_geometry_callback_registry.TRNS_VEC_KEY
const SOURCE_BULLET_TYPE_CREATE_FRAGS_TRNS_VEC_FALLBACK := source_geometry_callback_registry.TRNS_VEC_FALLBACK

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_bullet_type_create_frags_method_names"):
		var names = game.call("_bullet_type_create_frags_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_BULLET_TYPE_CREATE_FRAGS_TRNS_VEC_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BULLET_TYPE_CREATE_FRAGS_TRNS_VEC_KEY, SOURCE_BULLET_TYPE_CREATE_FRAGS_TRNS_VEC_FALLBACK)),
	}

static func initial_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_frags_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_create_frags_state: Dictionary = create_frags_state.duplicate(true)
	var frag_bullet: Variant = update_type_state.get("fragBullet", null)
	var frag_bullet_exists := frag_bullet != null
	var frag_on_absorb := bool(update_type_state.get("fragOnAbsorb", true))
	var bullet_absorbed := bool(update_bullet_state.get("absorbed", false))
	var pierce_frag_cap := int(update_type_state.get("pierceFragCap", -1))
	var bullet_frags := int(update_bullet_state.get("frags", 0))
	var frag_gate_passed := frag_bullet_exists and (frag_on_absorb or not bullet_absorbed) and (pierce_frag_cap < 0 or bullet_frags < pierce_frag_cap)
	var frag_bullets := int(update_type_state.get("fragBullets", update_create_frags_state.get("fragBullets", 9)))
	var loop_iterations := frag_bullets if frag_gate_passed else 0
	var runtime_state := {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createFrags": update_create_frags_state,
		"x": float(update_create_frags_state.get("x", 0.0)),
		"y": float(update_create_frags_state.get("y", 0.0)),
		"fragBullet": frag_bullet,
		"fragBulletExists": frag_bullet_exists,
		"fragOnAbsorb": frag_on_absorb,
		"bulletAbsorbed": bullet_absorbed,
		"pierceFragCap": pierce_frag_cap,
		"bulletFrags": bullet_frags,
		"fragBullets": frag_bullets,
		"fragGatePassed": frag_gate_passed,
		"loopIterations": loop_iterations,
	}
	runtime_state["bulletType"] = update_type_state
	runtime_state["bullet"] = update_bullet_state
	runtime_state["createFragsState"] = update_create_frags_state
	runtime_state["fragGatePassed"] = frag_gate_passed
	runtime_state["fragBullets"] = frag_bullets
	runtime_state["loopIterations"] = loop_iterations
	var source_trace := {
		"fragGateSource": "if(fragBullet != null && (fragOnAbsorb || !b.absorbed) && (pierceFragCap < 0 || b.frags < pierceFragCap))",
		"loopBoundarySource": "for(int i = 0; i < fragBullets; i++){",
		"randomLenBoundarySource": "float len = Mathf.random(fragOffsetMin, fragOffsetMax);",
	}
	runtime_state["fragGateSource"] = source_trace.get("fragGateSource", "")
	runtime_state["loopBoundarySource"] = source_trace.get("loopBoundarySource", "")
	runtime_state["randomLenBoundarySource"] = source_trace.get("randomLenBoundarySource", "")
	return runtime_state

static func random_geometry_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_frags_initial_state: Dictionary, frag_random_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_initial_state: Dictionary = create_frags_initial_state.duplicate(true)
	var update_random_state: Dictionary = frag_random_state.duplicate(true)
	var len_samples: Array = update_random_state.get("lenSamples", [])
	var range_samples: Array = update_random_state.get("rangeSamples", [])
	var fragment_plans: Array = []
	var frag_gate_passed := bool(update_initial_state.get("fragGatePassed", false))
	var loop_iterations := int(update_initial_state.get("loopIterations", 0))
	var frag_bullets := int(update_type_state.get("fragBullets", update_initial_state.get("fragBullets", 9)))
	var frag_offset_min := float(update_type_state.get("fragOffsetMin", 1.0))
	var frag_offset_max := float(update_type_state.get("fragOffsetMax", 7.0))
	var frag_random_spread := float(update_type_state.get("fragRandomSpread", source_math_defaults.FULL_CIRCLE_DEGREES))
	var frag_angle := float(update_type_state.get("fragAngle", 0.0))
	var frag_spread := float(update_type_state.get("fragSpread", 0.0))
	var rotation_value := float(update_bullet_state.get("rotation", 0.0))
	var x_value := float(update_initial_state.get("x", 0.0))
	var y_value := float(update_initial_state.get("y", 0.0))
	var angle_value: Variant = null
	if frag_gate_passed:
		for i in loop_iterations:
			var len_sample: Variant = len_samples[i] if i < len_samples.size() else null
			var range_sample: Variant = range_samples[i] if i < range_samples.size() else null
			angle_value = null
			if range_sample != null:
				angle_value = rotation_value + float(range_sample) + frag_angle + frag_spread * float(i) - (float(frag_bullets) - 1.0) * frag_spread / 2.0
			fragment_plans.append({
				"index": i,
				"x": x_value,
				"y": y_value,
				"len": len_sample,
				"lenSampleProvided": len_sample != null,
				"lenRandomCall": {"call": "Mathf.random(fragOffsetMin, fragOffsetMax)", "min": frag_offset_min, "max": frag_offset_max, "value": len_sample},
				"rangeSample": range_sample,
				"rangeSampleProvided": range_sample != null,
				"angleRandomCall": {"call": "Mathf.range(fragRandomSpread / 2)", "range": frag_random_spread / 2.0, "value": range_sample},
				"angle": angle_value,
				"rotation": rotation_value,
				"fragAngle": frag_angle,
				"spreadOffset": frag_spread * float(i) - (float(frag_bullets) - 1.0) * frag_spread / 2.0,
			})
	var runtime_state := {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createFragsInitial": update_initial_state,
		"fragRandom": update_random_state,
		"fragGatePassed": frag_gate_passed,
		"loopIterations": loop_iterations,
		"fragOffsetMin": frag_offset_min,
		"fragOffsetMax": frag_offset_max,
		"fragRandomSpread": frag_random_spread,
		"fragAngle": frag_angle,
		"fragSpread": frag_spread,
		"rotation": rotation_value,
		"fragmentPlans": fragment_plans,
	}
	runtime_state["bulletType"] = update_type_state
	runtime_state["bullet"] = update_bullet_state
	runtime_state["createFragsInitial"] = update_initial_state
	runtime_state["fragRandom"] = update_random_state
	runtime_state["fragGatePassed"] = frag_gate_passed
	runtime_state["loopIterations"] = loop_iterations
	runtime_state["fragOffsetMin"] = frag_offset_min
	runtime_state["fragOffsetMax"] = frag_offset_max
	runtime_state["fragRandomSpread"] = frag_random_spread
	runtime_state["fragAngle"] = frag_angle
	runtime_state["fragSpread"] = frag_spread
	runtime_state["rotation"] = rotation_value
	runtime_state["fragmentPlans"] = fragment_plans
	var source_trace := {
		"randomLenSource": "float len = Mathf.random(fragOffsetMin, fragOffsetMax);",
		"angleFormulaSource": "float a = b.rotation() + Mathf.range(fragRandomSpread / 2) + fragAngle + fragSpread * i - (fragBullets - 1) * fragSpread / 2f;",
		"createCallBoundarySource": "fragBullet.create(b, x + Angles.trnsx(a, len), y + Angles.trnsy(a, len), a, Mathf.random(fragVelocityMin, fragVelocityMax), Mathf.random(fragLifeMin, fragLifeMax));",
	}
	runtime_state["randomLenSource"] = source_trace.get("randomLenSource", "")
	runtime_state["angleFormulaSource"] = source_trace.get("angleFormulaSource", "")
	runtime_state["createCallBoundarySource"] = source_trace.get("createCallBoundarySource", "")
	return runtime_state

static func create_call_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_frags_random_geometry_state: Dictionary, frag_random_state: Dictionary, trns_vec: Callable) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_geometry_state: Dictionary = create_frags_random_geometry_state.duplicate(true)
	var update_random_state: Dictionary = frag_random_state.duplicate(true)
	var velocity_samples: Array = update_random_state.get("velocitySamples", [])
	var life_samples: Array = update_random_state.get("lifeSamples", [])
	var fragment_plans: Array = update_geometry_state.get("fragmentPlans", [])
	var fragment_create_calls: Array = []
	var frag_gate_passed := bool(update_geometry_state.get("fragGatePassed", false))
	var frag_bullet: Variant = update_type_state.get("fragBullet", null)
	var frag_velocity_min := float(update_type_state.get("fragVelocityMin", 0.2))
	var frag_velocity_max := float(update_type_state.get("fragVelocityMax", 1.0))
	var frag_life_min := float(update_type_state.get("fragLifeMin", 1.0))
	var frag_life_max := float(update_type_state.get("fragLifeMax", 1.0))
	if frag_gate_passed:
		for fragment_plan in fragment_plans:
			var plan: Dictionary = fragment_plan
			var index := int(plan.get("index", fragment_create_calls.size()))
			var len_sample: Variant = plan.get("len", null)
			var angle_value: Variant = plan.get("angle", null)
			var base_x := float(plan.get("x", 0.0))
			var base_y := float(plan.get("y", 0.0))
			var velocity_sample: Variant = velocity_samples[index] if index < velocity_samples.size() else null
			var life_sample: Variant = life_samples[index] if index < life_samples.size() else null
			var frag_x: Variant = null
			var frag_y: Variant = null
			var trns_x: Variant = null
			var trnsy: Variant = null
			if len_sample != null and angle_value != null:
				var len_value := float(len_sample)
				var offset: Dictionary = trns_vec.call(angle_value, len_value, 0.0)
				trns_x = offset.get("x", null)
				trnsy = offset.get("y", null)
				frag_x = base_x + float(trns_x)
				frag_y = base_y + float(trnsy)
			fragment_create_calls.append({
				"index": index,
				"fragBullet": frag_bullet,
				"ownerBullet": update_bullet_state,
				"baseX": base_x,
				"baseY": base_y,
				"len": len_sample,
				"angle": angle_value,
				"trnsx": trns_x,
				"trnsy": trnsy,
				"x": frag_x,
				"y": frag_y,
				"velocity": velocity_sample,
				"velocitySampleProvided": velocity_sample != null,
				"velocityRandomCall": {"call": "Mathf.random(fragVelocityMin, fragVelocityMax)", "min": frag_velocity_min, "max": frag_velocity_max, "value": velocity_sample},
				"life": life_sample,
				"lifeSampleProvided": life_sample != null,
				"lifeRandomCall": {"call": "Mathf.random(fragLifeMin, fragLifeMax)", "min": frag_life_min, "max": frag_life_max, "value": life_sample},
				"call": "fragBullet.create(b, x + Angles.trnsx(a, len), y + Angles.trnsy(a, len), a, Mathf.random(fragVelocityMin, fragVelocityMax), Mathf.random(fragLifeMin, fragLifeMax))",
			})
	var runtime_state := {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createFragsRandomGeometry": update_geometry_state,
		"fragRandom": update_random_state,
		"fragGatePassed": frag_gate_passed,
		"fragBullet": frag_bullet,
		"fragVelocityMin": frag_velocity_min,
		"fragVelocityMax": frag_velocity_max,
		"fragLifeMin": frag_life_min,
		"fragLifeMax": frag_life_max,
		"fragmentCreateCalls": fragment_create_calls,
	}
	runtime_state["bulletType"] = update_type_state
	runtime_state["bullet"] = update_bullet_state
	runtime_state["createFragsRandomGeometry"] = update_geometry_state
	runtime_state["fragRandom"] = update_random_state
	runtime_state["fragGatePassed"] = frag_gate_passed
	runtime_state["fragBullet"] = frag_bullet
	runtime_state["fragVelocityMin"] = frag_velocity_min
	runtime_state["fragVelocityMax"] = frag_velocity_max
	runtime_state["fragLifeMin"] = frag_life_min
	runtime_state["fragLifeMax"] = frag_life_max
	runtime_state["fragmentCreateCalls"] = fragment_create_calls
	var source_trace := {
		"trnsxSource": "Angles.trnsx(a, len)",
		"trnsySource": "Angles.trnsy(a, len)",
		"velocityRandomSource": "Mathf.random(fragVelocityMin, fragVelocityMax)",
		"lifeRandomSource": "Mathf.random(fragLifeMin, fragLifeMax)",
		"createCallSource": "fragBullet.create(b, x + Angles.trnsx(a, len), y + Angles.trnsy(a, len), a, Mathf.random(fragVelocityMin, fragVelocityMax), Mathf.random(fragLifeMin, fragLifeMax));",
		"fragsIncrementBoundarySource": "b.frags++;",
	}
	runtime_state["trnsxSource"] = source_trace.get("trnsxSource", "")
	runtime_state["trnsySource"] = source_trace.get("trnsySource", "")
	runtime_state["velocityRandomSource"] = source_trace.get("velocityRandomSource", "")
	runtime_state["lifeRandomSource"] = source_trace.get("lifeRandomSource", "")
	runtime_state["createCallSource"] = source_trace.get("createCallSource", "")
	runtime_state["fragsIncrementBoundarySource"] = source_trace.get("fragsIncrementBoundarySource", "")
	return runtime_state

static func game_create_call_state(game: Object, bullet_type_state: Dictionary, bullet_state: Dictionary, create_frags_random_geometry_state: Dictionary, frag_random_state: Dictionary) -> Dictionary:
	return create_call_state(bullet_type_state, bullet_state, create_frags_random_geometry_state, frag_random_state, default_callbacks_state(game).get(SOURCE_BULLET_TYPE_CREATE_FRAGS_TRNS_VEC_KEY, Callable()))

static func increment_state(bullet_state: Dictionary, create_frags_create_call_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_create_call_state: Dictionary = create_frags_create_call_state.duplicate(true)
	var frag_gate_passed := bool(update_create_call_state.get("fragGatePassed", false))
	var bullet_frags_before := int(update_bullet_state.get("frags", 0))
	var bullet_frags_after := bullet_frags_before
	var frags_incremented := frag_gate_passed
	if frags_incremented:
		bullet_frags_after = bullet_frags_before + 1
	update_bullet_state["frags"] = bullet_frags_after
	var runtime_state := {
		"bullet": update_bullet_state,
		"createFragsCreateCall": update_create_call_state,
		"fragGatePassed": frag_gate_passed,
		"bulletFragsBefore": bullet_frags_before,
		"bulletFragsAfter": bullet_frags_after,
		"fragsIncremented": frags_incremented,
	}
	runtime_state["bullet"] = update_bullet_state
	runtime_state["createFragsCreateCall"] = update_create_call_state
	runtime_state["fragGatePassed"] = frag_gate_passed
	runtime_state["bulletFragsBefore"] = bullet_frags_before
	runtime_state["bulletFragsAfter"] = bullet_frags_after
	runtime_state["fragsIncremented"] = frags_incremented
	var source_trace := {"fragsIncrementSource": "b.frags++;"}
	runtime_state["fragsIncrementSource"] = source_trace.get("fragsIncrementSource", "")
	return runtime_state
