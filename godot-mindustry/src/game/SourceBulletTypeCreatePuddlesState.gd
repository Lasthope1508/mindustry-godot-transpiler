extends RefCounted
class_name SourceBulletTypeCreatePuddlesState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_bullet_runtime := preload("res://src/game/SourceBulletRuntime.gd")

static func initial_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_puddles_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_create_puddles_state: Dictionary = create_puddles_state.duplicate(true)
	var puddle_x := float(update_create_puddles_state.get("x", 0.0))
	var puddle_y := float(update_create_puddles_state.get("y", 0.0))
	var puddle_liquid: Variant = update_type_state.get("puddleLiquid", "water")
	var puddles := int(update_type_state.get("puddles", 0))
	var puddle_range := float(update_type_state.get("puddleRange", 0.0))
	var puddle_amount := float(update_type_state.get("puddleAmount", source_bullet_defaults.PUDDLE_AMOUNT_DEFAULT))
	var puddle_gate_passed := puddle_liquid != null and puddles > 0
	var loop_iterations := puddles if puddle_gate_passed else 0
	var runtime_state := source_bullet_runtime.create_puddles_initial_state(bullet_type_state, bullet_state, create_puddles_state)
	runtime_state["bulletType"] = update_type_state
	runtime_state["bullet"] = update_bullet_state
	runtime_state["createPuddles"] = update_create_puddles_state
	runtime_state["x"] = puddle_x
	runtime_state["y"] = puddle_y
	runtime_state["puddleLiquid"] = puddle_liquid
	runtime_state["puddles"] = puddles
	runtime_state["puddleRange"] = puddle_range
	runtime_state["puddleAmount"] = puddle_amount
	runtime_state["puddleGatePassed"] = puddle_gate_passed
	runtime_state["loopIterations"] = loop_iterations
	var source_trace := {
		"puddleGateSource": "if(puddleLiquid != null && puddles > 0){",
		"loopBoundarySource": "for(int i = 0; i < puddles; i++){",
		"tileBoundarySource": "Tile tile = world.tileWorld(x + Mathf.range(puddleRange), y + Mathf.range(puddleRange));",
		"depositBoundarySource": "Puddles.deposit(tile, puddleLiquid, puddleAmount);",
	}
	runtime_state["puddleGateSource"] = source_trace.get("puddleGateSource", "")
	runtime_state["loopBoundarySource"] = source_trace.get("loopBoundarySource", "")
	runtime_state["tileBoundarySource"] = source_trace.get("tileBoundarySource", "")
	runtime_state["depositBoundarySource"] = source_trace.get("depositBoundarySource", "")
	return runtime_state

static func tile_world_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_puddles_initial_state: Dictionary, puddle_random_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_initial_state: Dictionary = create_puddles_initial_state.duplicate(true)
	var update_random_state: Dictionary = puddle_random_state.duplicate(true)
	var x_range_samples: Array = update_random_state.get("xRangeSamples", [])
	var y_range_samples: Array = update_random_state.get("yRangeSamples", [])
	var tile_world_calls: Array = []
	var puddle_gate_passed := bool(update_initial_state.get("puddleGatePassed", false))
	var loop_iterations := int(update_initial_state.get("loopIterations", 0))
	var puddle_range := float(update_type_state.get("puddleRange", update_initial_state.get("puddleRange", 0.0)))
	var base_x := float(update_initial_state.get("x", 0.0))
	var base_y := float(update_initial_state.get("y", 0.0))
	if puddle_gate_passed:
		for i in loop_iterations:
			var x_range_sample: Variant = x_range_samples[i] if i < x_range_samples.size() else null
			var y_range_sample: Variant = y_range_samples[i] if i < y_range_samples.size() else null
			var tile_x: Variant = null
			var tile_y: Variant = null
			if x_range_sample != null:
				tile_x = base_x + float(x_range_sample)
			if y_range_sample != null:
				tile_y = base_y + float(y_range_sample)
			tile_world_calls.append({
				"index": i,
				"baseX": base_x,
				"baseY": base_y,
				"xRangeSample": x_range_sample,
				"xRangeSampleProvided": x_range_sample != null,
				"xRangeCall": {"call": "Mathf.range(puddleRange)", "range": puddle_range, "value": x_range_sample},
				"yRangeSample": y_range_sample,
				"yRangeSampleProvided": y_range_sample != null,
				"yRangeCall": {"call": "Mathf.range(puddleRange)", "range": puddle_range, "value": y_range_sample},
				"tileWorldX": tile_x,
				"tileWorldY": tile_y,
				"call": "world.tileWorld(x + Mathf.range(puddleRange), y + Mathf.range(puddleRange))",
			})
	var runtime_state := source_bullet_runtime.create_puddles_tile_world_state(bullet_type_state, bullet_state, create_puddles_initial_state, puddle_random_state)
	runtime_state["bulletType"] = update_type_state
	runtime_state["bullet"] = update_bullet_state
	runtime_state["createPuddlesInitial"] = update_initial_state
	runtime_state["puddleRandom"] = update_random_state
	runtime_state["puddleGatePassed"] = puddle_gate_passed
	runtime_state["loopIterations"] = loop_iterations
	runtime_state["puddleRange"] = puddle_range
	runtime_state["x"] = base_x
	runtime_state["y"] = base_y
	runtime_state["tileWorldCalls"] = tile_world_calls
	var source_trace := {
		"tileWorldSource": "Tile tile = world.tileWorld(x + Mathf.range(puddleRange), y + Mathf.range(puddleRange));",
		"depositBoundarySource": "Puddles.deposit(tile, puddleLiquid, puddleAmount);",
	}
	runtime_state["tileWorldSource"] = source_trace.get("tileWorldSource", "")
	runtime_state["depositBoundarySource"] = source_trace.get("depositBoundarySource", "")
	return runtime_state

static func deposit_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_puddles_tile_world_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_tile_world_state: Dictionary = create_puddles_tile_world_state.duplicate(true)
	var tile_world_calls: Array = update_tile_world_state.get("tileWorldCalls", [])
	var deposit_calls: Array = []
	var puddle_gate_passed := bool(update_tile_world_state.get("puddleGatePassed", false))
	var puddle_liquid: Variant = update_type_state.get("puddleLiquid", update_tile_world_state.get("puddleLiquid", "water"))
	var puddle_amount := float(update_type_state.get("puddleAmount", update_tile_world_state.get("puddleAmount", source_bullet_defaults.PUDDLE_AMOUNT_DEFAULT)))
	if puddle_gate_passed:
		for tile_call in tile_world_calls:
			var tile_world_call: Dictionary = tile_call
			deposit_calls.append({
				"index": int(tile_world_call.get("index", deposit_calls.size())),
				"tile": tile_world_call,
				"puddleLiquid": puddle_liquid,
				"puddleAmount": puddle_amount,
				"call": "Puddles.deposit(tile, puddleLiquid, puddleAmount)",
			})
	var runtime_state := source_bullet_runtime.create_puddles_deposit_state(bullet_type_state, bullet_state, create_puddles_tile_world_state)
	runtime_state["bulletType"] = update_type_state
	runtime_state["bullet"] = update_bullet_state
	runtime_state["createPuddlesTileWorld"] = update_tile_world_state
	runtime_state["puddleGatePassed"] = puddle_gate_passed
	runtime_state["puddleLiquid"] = puddle_liquid
	runtime_state["puddleAmount"] = puddle_amount
	runtime_state["tileWorldCalls"] = tile_world_calls
	runtime_state["depositCalls"] = deposit_calls
	var source_trace := {"depositSource": "Puddles.deposit(tile, puddleLiquid, puddleAmount);"}
	runtime_state["depositSource"] = source_trace.get("depositSource", "")
	return runtime_state
