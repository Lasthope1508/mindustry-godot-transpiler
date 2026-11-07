extends Node

const source_input_event_runtime_state := preload("res://src/game/SourceInputEventRuntimeState.gd")
const source_input_defaults := preload("res://src/game/SourceInputDefaults.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

const PROOF_LABEL := "INPUT_EVENT_RUNTIME_STATE_MODULE_PROOF"

class FakeInputGame:
	extends RefCounted

	var selected_action := ""
	var touch_axis := Vector2.ZERO
	var placed_positions: Array = []

	func select_build_slot_action(canonical_action: String) -> void:
		selected_action = canonical_action

	func set_touch_move_axis(axis: Vector2) -> void:
		touch_axis = axis

	func source_input_viewport_screen_to_world_state(screen_position: Vector2) -> Dictionary:
		return {"x": screen_position.x + 10.0, "y": screen_position.y + 20.0}

	func place_selected_block_at_world(world_pos: Vector2) -> bool:
		placed_positions.append(world_pos)
		return true

func _ready() -> void:
	var fake := FakeInputGame.new()
	var key_event := InputEventKey.new()
	key_event.keycode = KEY_3
	key_event.pressed = true
	source_input_event_runtime_state.handle_unhandled_input(fake, key_event)

	var drag_event := InputEventScreenDrag.new()
	drag_event.relative = Vector2(source_input_defaults.control_input().touch_move_pixels_per_axis(), 0.0)
	source_input_event_runtime_state.handle_unhandled_input(fake, drag_event)
	var drag_axis := fake.touch_axis

	var touch_release := InputEventScreenTouch.new()
	touch_release.pressed = false
	source_input_event_runtime_state.handle_unhandled_input(fake, touch_release)

	var touch_press := InputEventScreenTouch.new()
	touch_press.pressed = true
	touch_press.position = Vector2(2.0, 3.0)
	source_input_event_runtime_state.handle_unhandled_input(fake, touch_press)

	var mouse_press := InputEventMouseButton.new()
	mouse_press.pressed = true
	mouse_press.button_index = MOUSE_BUTTON_LEFT
	mouse_press.position = Vector2(4.0, 5.0)
	source_input_event_runtime_state.handle_unhandled_input(fake, mouse_press)

	var pointer_world := source_input_event_runtime_state.pointer_world_position_state(fake, Vector2(7.0, 8.0))
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var first_place: Vector2 = fake.placed_positions[0] if fake.placed_positions.size() > 0 else Vector2.ZERO
	var second_place: Vector2 = fake.placed_positions[1] if fake.placed_positions.size() > 1 else Vector2.ZERO
	var proof := {
		"module": PROOF_LABEL,
		"key_event_selected_action": fake.selected_action == "build.slot.3",
		"drag_axis_matches": drag_axis == Vector2(1.0, 0.0),
		"touch_release_clears": fake.touch_axis == Vector2.ZERO,
		"touch_press_places": first_place == Vector2(12.0, 23.0),
		"mouse_place_matches": second_place == Vector2(14.0, 25.0),
		"pointer_world_position_matches": float(pointer_world.get("x", 0.0)) == 17.0 and float(pointer_world.get("y", 0.0)) == 28.0,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["key_event_selected_action"] and proof["drag_axis_matches"] and proof["touch_release_clears"] and proof["touch_press_places"] and proof["mouse_place_matches"] and proof["pointer_world_position_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("InputEventRuntimeStateModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

