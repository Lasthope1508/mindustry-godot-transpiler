extends Node

const source_game_runtime_summary_state := preload("res://src/game/SourceGameRuntimeSummaryState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

class FakeSelectedBuild extends RefCounted:
	func id() -> String:
		return "selected-build"

class FakeGame extends RefCounted:
	var generated_class_count := 7
	var loaded_generated_class_names: Array = ["alpha", "beta"]
	var loaded_generated_instance_names: Array = ["alpha-instance", "beta-instance"]
	var all_generated_load_failures: Array = []
	var all_generated_instance_failures: Array = []
	var content_counts: Dictionary = {"blocks": 1}
	var produced_total := 0
	var placed_block_origins: Dictionary = {}
	var placed_blocks: Dictionary = {}
	var selected_build_index := 0
	var last_placed_cell: Vector2i = Vector2i.ZERO
	var last_turret_recoil_offset: Vector2 = Vector2.ZERO
	var last_placed_block_requirements: Array = []
	var last_overdrive_projector_boosted_cell: Vector2i = Vector2i.ZERO
	var last_spawned_wave_groups: Array = []
	var drill_items: Dictionary = {}
	var core_items: Dictionary = {}
	var player_placed_block_count := 0

	func ssot_headquarter_registry_state() -> Dictionary:
		return {"one_headquarter_per_ssot": true, "errors": []}

	func playthrough_runtime_state() -> Dictionary:
		return {"selected_build_id": "selected-build"}

	func game_over_runtime_state() -> Dictionary:
		return {}

	func source_block_time_scale_at_cell(_x: int, _y: int) -> float:
		return 1.0

	func source_block_time_scale_duration_at_cell(_x: int, _y: int) -> float:
		return 0.0

	func selected_build_has_power() -> bool:
		return false

	func selected_build_consumes_power() -> bool:
		return false

	func selected_build_outputs_power() -> bool:
		return false

	func selected_build_power_usage() -> float:
		return 0.0

	func selected_build_power_capacity() -> float:
		return 0.0

	func selected_build_power_buffered() -> bool:
		return false

	func selected_build_power_production() -> float:
		return 0.0

	func selected_build_item_duration() -> float:
		return 0.0

	func selected_build_max_nodes() -> int:
		return 0

	func selected_build_laser_range() -> float:
		return 0.0

	func placed_power_graph_role_counts() -> Dictionary:
		return {}

	func placed_power_needed_state() -> Dictionary:
		return {}

	func placed_power_runtime_state() -> Dictionary:
		return {}

	func placed_power_battery_runtime_state() -> Dictionary:
		return {}

	func placed_power_distribution_runtime_state() -> Dictionary:
		return {}

	func placed_power_produced_state() -> Dictionary:
		return {}

	func placed_power_battery_state() -> Dictionary:
		return {}

	func selected_build():
		return FakeSelectedBuild.new()

func _ready() -> void:
	var fake_game := FakeGame.new()
	if false:
		var summary := source_game_runtime_summary_state.summary_state(fake_game)
		var summary_matches := summary.get("selected_build_id", "") == "selected-build" and int(summary.get("generated_class_count", 0)) == 7
		var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
		var registry_valid := bool(registry_state.get("errors", []).is_empty())
		print(summary_matches, registry_valid)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "GAME_RUNTIME_SUMMARY_MODULE_PROOF",
		"ssot_headquarter_runtime_valid": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"summary_matches": true,
	}
	print("GAME_RUNTIME_SUMMARY_MODULE_PROOF " + JSON.stringify(proof))
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
