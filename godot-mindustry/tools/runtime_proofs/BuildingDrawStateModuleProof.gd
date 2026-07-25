extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBuildingDrawState := preload("res://src/game/SourceBuildingDrawState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := SourceBuildingDrawState.default_callbacks_state(game)
	var expected_callbacks := {
		"random_seed_int": Callable(game, "source_arc_random_seed_int"),
		"lerp_delta": Callable(game, "source_arc_lerp_delta"),
	}
	var draw_wrapper := game.source_building_draw_state(3, true, 4, 7, 64.0, 80.0, true, true, 1)
	var draw_module := SourceBuildingDrawState.draw_state(3, true, 4, 7, 64.0, 80.0, true, true, 1, callbacks.get("random_seed_int", Callable()))
	var cached_wrapper := game.source_building_draw_cached_state(3, true, 4, 7, 64.0, 80.0, true, true, 1)
	var cached_module := SourceBuildingDrawState.draw_cached_state(3, true, 4, 7, 64.0, 80.0, true, true, 1, callbacks.get("random_seed_int", Callable()))
	var payload_wrapper := game.source_building_payload_draw_state(true, true, 12.0, 15.0, 3, true, 4, 7, 64.0, 80.0, true, true, 1)
	var payload_module := SourceBuildingDrawState.payload_draw_state(true, true, 12.0, 15.0, 3, true, 4, 7, 64.0, 80.0, true, true, 1, callbacks.get("random_seed_int", Callable()))
	var light_wrapper := game.source_building_draw_light_state(true, true, true, "current", 0.9, "light", 0.7, 0.2, 0.25, 0.5, 64.0, 80.0, 3)
	var light_module := SourceBuildingDrawState.draw_light_state(true, true, true, "current", 0.9, "light", 0.7, 0.2, 0.25, 0.5, 64.0, 80.0, 3, callbacks.get("lerp_delta", Callable()))
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingDrawState",
		"default_callbacks_match": callbacks == expected_callbacks,
		"draw_state_matches": draw_wrapper == draw_module,
		"draw_cached_matches": cached_wrapper == cached_module,
		"payload_draw_matches": payload_wrapper == payload_module,
		"draw_light_matches": light_wrapper == light_module,
		"module_matches": draw_wrapper == draw_module and cached_wrapper == cached_module and payload_wrapper == payload_module and light_wrapper == light_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	print("BUILDING_DRAW_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
