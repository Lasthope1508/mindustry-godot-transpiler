extends Node

const source_enemy_unit_runtime_state := preload("res://src/game/SourceEnemyUnitRuntimeState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

class FakeContentCatalog:
	func get_by_id(id: String):
		return {"id": id}

	func get_many(kind: String) -> Array:
		return [{"id": "dagger"}] if kind == "unit" else []

var tile_size := 10.0
var core_pos := Vector2i(5, 0)
var core_health := 20.0
var core_damage_taken_total := 0.0
var wave_cooldown := 3.0
var wave_index := 0
var last_spawned_wave_index := 0
var last_spawned_wave_count := 0
var spawn_calls := 0
var enemy_units: Array = []
var last_applied_damage := 0.0
var textures: Dictionary = {}
var content_catalog = FakeContentCatalog.new()

func _ready() -> void:
	var world := Node2D.new()
	world.name = "World"
	add_child(world)
	var unit_layer := Node2D.new()
	unit_layer.name = "UnitLayer"
	world.add_child(unit_layer)
	enemy_units = [
		{"sprite": _make_sprite(Vector2(0.0, 0.0)), "type": {"id": "dagger"}},
		{"sprite": _make_sprite(Vector2(15.0, 0.0)), "type": {"id": "dagger"}},
	]
	source_enemy_unit_runtime_state.simulate_units(self, 1.0)
	var spawn_state := source_enemy_unit_runtime_state.spawn_unit(self, selected_enemy_unit(), 2)
	var wave_state := source_enemy_unit_runtime_state.spawn_wave_state(wave_index, "dagger")
	source_enemy_unit_runtime_state.spawn_wave(self)
	var summary := source_enemy_unit_runtime_state.runtime_summary_state(self)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceEnemyUnitRuntimeState",
		"enemy_count_after": enemy_units.size(),
		"spawn_calls": spawn_calls,
		"wave_index": wave_index,
		"wave_cooldown": wave_cooldown,
		"core_health": core_health,
		"core_damage_taken_total": core_damage_taken_total,
		"last_applied_damage": last_applied_damage,
		"spawn_source_owner": str(spawn_state.get("source_owner", "")),
		"spawn_health": float(spawn_state.get("health", 0.0)),
		"wave_source_owner": str(wave_state.get("source_owner", "")),
		"last_spawned_wave_count": last_spawned_wave_count,
		"last_spawned_wave_index": last_spawned_wave_index,
		"unit_layer_child_count": unit_layer.get_child_count(),
		"summary_source_owner": str(summary.get("source_owner", "")),
		"summary_enemy_count": int(summary.get("enemy_count", -1)),
		"summary_selected_enemy_weapon_damage": float(summary.get("selected_enemy_weapon_damage", 0.0)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("ENEMY_UNIT_RUNTIME_MODULE_PROOF " + JSON.stringify(proof))
	await get_tree().create_timer(20.0).timeout
	get_tree().quit(0)

func grid_to_world(cell: Vector2i) -> Vector2:
	return Vector2(float(cell.x) * tile_size, float(cell.y) * tile_size)

func selected_enemy_unit():
	return source_enemy_unit_runtime_state.selected_enemy_unit(self)

func proof_unit_world_speed(unit_type) -> float:
	return 6.0

func proof_unit_weapon_damage(unit_type) -> float:
	return 8.0

func proof_unit_hit_size(unit_type) -> float:
	return 10.0

func proof_unit_health(unit_type) -> float:
	return 20.0

func proof_wave_timing_runtime_state(seconds: float) -> Dictionary:
	return {"wavetime": 1.5, "should_spawn": true}

func apply_core_damage(amount: float) -> Dictionary:
	last_applied_damage = amount
	core_damage_taken_total += amount
	core_health = max(0.0, core_health - amount)
	return {"applied": amount, "core_health": core_health, "core_damage_taken_total": core_damage_taken_total}

func spawn_enemy_wave() -> void:
	spawn_calls += 1

func spawn_enemy_unit(unit_type, index: int) -> void:
	source_enemy_unit_runtime_state.spawn_unit(self, unit_type, index)

func _make_sprite(position: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.position = position
	return sprite
