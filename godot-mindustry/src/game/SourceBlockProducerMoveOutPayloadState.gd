extends RefCounted
class_name SourceBlockProducerMoveOutPayloadState

const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_block_producer_state := preload("res://src/game/SourceBlockProducerState.gd")
const source_block_producer_build_update_state := preload("res://src/game/SourceBlockProducerBuildUpdateState.gd")
const source_block_producer_move_out_payload_source_text_state := preload("res://src/game/SourceBlockProducerMoveOutPayloadSourceTextState.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const SOURCE_PAYLOAD_ARRIVAL_EPSILON := source_world_defaults.PAYLOAD_ARRIVAL_EPSILON
const SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_ARC_SOURCE := source_block_producer_move_out_payload_source_text_state.SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_ARC_SOURCE
const SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_MOVE_OUT_PAYLOAD_EXPR := source_block_producer_move_out_payload_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_MOVE_OUT_PAYLOAD_EXPR
const SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_METHOD := source_block_producer_move_out_payload_source_text_state.SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_METHOD
const SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_NULL_GUARD := source_block_producer_move_out_payload_source_text_state.SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_NULL_GUARD
const SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_UPDATE_PAYLOAD_EXPR := source_block_producer_move_out_payload_source_text_state.SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_UPDATE_PAYLOAD_EXPR
const SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_DEST_EXPR := source_block_producer_move_out_payload_source_text_state.SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_DEST_EXPR
const SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_PAY_ROTATION_EXPR := source_block_producer_move_out_payload_source_text_state.SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_PAY_ROTATION_EXPR
const SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_PAY_VECTOR_EXPR := source_block_producer_move_out_payload_source_text_state.SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_PAY_VECTOR_EXPR
const SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_FRONT_EXPR := source_block_producer_move_out_payload_source_text_state.SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_FRONT_EXPR
const SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_CAN_DUMP_EXPR := source_block_producer_move_out_payload_source_text_state.SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_CAN_DUMP_EXPR
const SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_CAN_MOVE_EXPR := source_block_producer_move_out_payload_source_text_state.SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_CAN_MOVE_EXPR
const SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_PUSH_OUTPUT_EXPR := source_block_producer_move_out_payload_source_text_state.SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_PUSH_OUTPUT_EXPR
const SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_ARRIVED_GUARD := source_block_producer_move_out_payload_source_text_state.SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_ARRIVED_GUARD
const SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_CLAMP_EXPR := source_block_producer_move_out_payload_source_text_state.SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_CLAMP_EXPR
const SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_MOVE_PAYLOAD_EXPR := source_block_producer_move_out_payload_source_text_state.SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_MOVE_PAYLOAD_EXPR
const SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_PAYLOAD_CLEAR_EXPR := source_block_producer_move_out_payload_source_text_state.SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_PAYLOAD_CLEAR_EXPR
const SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_DUMP_PAYLOAD_EXPR := source_block_producer_move_out_payload_source_text_state.SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_DUMP_PAYLOAD_EXPR

static func _block_producer_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(source_block_producer_state.SOURCE_BLOCK_PRODUCER_GENERATED_CLASS, generated_method, generated_args, null)

static func source_payload_move_out_dest(rotdeg_value: float, half_extent: float) -> Dictionary:
	return source_math_state.source_angles_trns_vec(rotdeg_value, half_extent, 0.0)

static func source_vec2_approach(from_x: float, from_y: float, target_x: float, target_y: float, amount: float) -> Dictionary:
	var dx_approach: float = from_x - target_x
	var dy_approach: float = from_y - target_y
	var approach_alpha2: float = amount * amount
	var approach_len2: float = dx_approach * dx_approach + dy_approach * dy_approach
	if approach_len2 > approach_alpha2:
		var scl: float = sqrt(approach_alpha2 / approach_len2)
		return {"x": from_x - dx_approach * scl, "y": from_y - dy_approach * scl}
	return {"x": target_x, "y": target_y}

static func source_vec2_clamp_rect(x_value: float, y_value: float, min_x: float, min_y: float, max_x: float, max_y: float) -> Dictionary:
	return {"x": clampf(x_value, min_x, max_x), "y": clampf(y_value, min_y, max_y)}

static func move_out_payload_state(payload_present: bool, pay_vector_x: float, pay_vector_y: float, pay_rotation_before: float, rotdeg_value: float, size_value: float, tilesize: float, payload_rotate_speed: float, payload_speed: float, time_delta: float, front_present: bool, front_solid: bool, front_outputs_payload: bool, front_accepts_payload: bool, move_payload_result: bool) -> Dictionary:
	var half_extent: float = size_value * tilesize / 2.0
	var dest: Variant = null
	var pay_vector_after: Dictionary = {"x": pay_vector_x, "y": pay_vector_y}
	var pay_rotation_after: float = pay_rotation_before
	var update_payload_called: bool = false
	var can_dump := false
	var can_move := false
	var distance_to_dest: float = 0.0
	var distance_to_dest2: float = 0.0
	var pushed_output_fraction: Variant = null
	var arrived: bool = false
	var move_payload_called: bool = false
	var dump_payload_called: bool = false
	var payload_after_present: bool = payload_present
	if payload_present:
		update_payload_called = true
		dest = source_payload_move_out_dest(rotdeg_value, half_extent)
		pay_rotation_after = source_math_state.source_angles_move_toward(pay_rotation_before, rotdeg_value, payload_rotate_speed * time_delta)
		pay_vector_after = source_vec2_approach(pay_vector_x, pay_vector_y, float(dest.get("x", 0.0)), float(dest.get("y", 0.0)), payload_speed * time_delta)
		can_dump = (not front_present) or (not front_solid)
		can_move = front_present and (front_outputs_payload or front_accepts_payload)
		var dx: float = float(dest.get("x", 0.0)) - float(pay_vector_after.get("x", 0.0))
		var dy: float = float(dest.get("y", 0.0)) - float(pay_vector_after.get("y", 0.0))
		distance_to_dest2 = dx * dx + dy * dy
		distance_to_dest = sqrt(distance_to_dest2)
		if can_dump and not can_move:
			pushed_output_fraction = 1.0 - (distance_to_dest / half_extent)
		arrived = distance_to_dest2 < SOURCE_PAYLOAD_ARRIVAL_EPSILON * SOURCE_PAYLOAD_ARRIVAL_EPSILON
		if arrived:
			pay_vector_after = source_vec2_clamp_rect(float(pay_vector_after.get("x", 0.0)), float(pay_vector_after.get("y", 0.0)), -half_extent, -half_extent, half_extent, half_extent)
			if can_move:
				move_payload_called = true
				payload_after_present = not move_payload_result
			elif can_dump:
				dump_payload_called = true
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_MOVE_OUT_PAYLOAD_STATE, "source": source_block_producer_state.SOURCE_BLOCK_PRODUCER_SOURCE, "parent_source": source_block_producer_build_update_state.SOURCE_PAYLOAD_BLOCK_SOURCE, "arc_source": SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_ARC_SOURCE, "inner_class": source_block_producer_state.SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR, "override_expr": "@Override", "update_tile_method": source_block_producer_build_update_state.SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_METHOD, "move_out_payload_expr": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_MOVE_OUT_PAYLOAD_EXPR, "method": SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_METHOD, "payload_null_guard": SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_NULL_GUARD, "update_payload_expr": SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_UPDATE_PAYLOAD_EXPR, "dest_expr": SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_DEST_EXPR, "pay_rotation_expr": SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_PAY_ROTATION_EXPR, "pay_vector_expr": SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_PAY_VECTOR_EXPR, "front_expr": SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_FRONT_EXPR, "can_dump_expr": SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_CAN_DUMP_EXPR, "can_move_expr": SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_CAN_MOVE_EXPR, "push_output_expr": SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_PUSH_OUTPUT_EXPR, "arrived_guard": SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_ARRIVED_GUARD, "clamp_expr": SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_CLAMP_EXPR, "move_payload_expr": SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_MOVE_PAYLOAD_EXPR, "payload_clear_expr": SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_PAYLOAD_CLEAR_EXPR, "dump_payload_expr": SOURCE_PAYLOAD_BLOCK_MOVE_OUT_PAYLOAD_DUMP_PAYLOAD_EXPR, "payload_present": payload_present, "pay_vector_x": pay_vector_x, "pay_vector_y": pay_vector_y, "pay_rotation_before": pay_rotation_before, "rotdeg_value": rotdeg_value, "size_value": size_value, "tilesize": tilesize, "payload_rotate_speed": payload_rotate_speed, "payload_speed": payload_speed, "time_delta": time_delta, "front_present": front_present, "front_solid": front_solid, "front_outputs_payload": front_outputs_payload, "front_accepts_payload": front_accepts_payload, "move_payload_result": move_payload_result, "half_extent": half_extent, "dest": dest, "update_payload_called": update_payload_called, "pay_rotation_after": pay_rotation_after, "pay_vector_after": pay_vector_after, "can_dump": can_dump, "can_move": can_move, "distance_to_dest": distance_to_dest, "distance_to_dest2": distance_to_dest2, "pushed_output_fraction": pushed_output_fraction, "arrived": arrived, "move_payload_called": move_payload_called, "dump_payload_called": dump_payload_called, "payload_after_present": payload_after_present}

static func generated_block_producer_build_update_tile_move_out_payload_bridge_state(payload_present: bool, pay_vector_x: float, pay_vector_y: float, pay_rotation_before: float, rotdeg_value: float, size_value: float, tilesize: float, payload_rotate_speed: float, payload_speed: float, time_delta: float, front_present: bool, front_solid: bool, front_outputs_payload: bool, front_accepts_payload: bool, move_payload_result: bool) -> Dictionary:
	var result = _block_producer_call("java_inner_class_BlockProducerBuild_method_updateTile_move_out_payload_5", [payload_present, pay_vector_x, pay_vector_y, pay_rotation_before, rotdeg_value, size_value, tilesize, payload_rotate_speed, payload_speed, time_delta, front_present, front_solid, front_outputs_payload, front_accepts_payload, move_payload_result])
	var canonical = move_out_payload_state(payload_present, pay_vector_x, pay_vector_y, pay_rotation_before, rotdeg_value, size_value, tilesize, payload_rotate_speed, payload_speed, time_delta, front_present, front_solid, front_outputs_payload, front_accepts_payload, move_payload_result)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_MOVE_OUT_PAYLOAD_STATE, "generated_owner": "block_producer.BlockProducerBuild.updateTile.moveOutPayload", "result": result, "canonical": canonical, "matches": matches}
