extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")

var placed_block_origins: Dictionary = {}
var placed_blocks: Dictionary = {}
var last_overdrive_projector_boosted_block_id := "router"
var last_overdrive_projector_boosted_cell := Vector2i(1, 2)

func _placed_block_state_method_names() -> Dictionary:
	return {
		source_placed_block_state.SOURCE_PLACED_BLOCK_TIME_SCALE_DECAY_METHOD_KEY: "_proof_building_time_scale_decay_state",
		source_placed_block_state.SOURCE_PLACED_BLOCK_TIME_SCALE_AT_CELL_METHOD_KEY: "_proof_block_time_scale_at_cell",
		source_placed_block_state.SOURCE_PLACED_BLOCK_TIME_SCALE_DURATION_AT_CELL_METHOD_KEY: "_proof_block_time_scale_duration_at_cell",
	}

func _ready() -> void:
	var sprite := Sprite2D.new()
	sprite.set_meta(source_placed_block_state.SOURCE_BLOCK_HEALTH_META_KEY, 4.0)
	sprite.set_meta(source_placed_block_state.SOURCE_BLOCK_MAX_HEALTH_META_KEY, 5.0)
	sprite.set_meta(source_placed_block_state.SOURCE_BLOCK_TIME_SCALE_META_KEY, 2.0)
	sprite.set_meta(source_placed_block_state.SOURCE_BLOCK_TIME_SCALE_DURATION_META_KEY, 5.0)
	placed_block_origins = {"cell": sprite}
	var cell_sprite := Sprite2D.new()
	cell_sprite.set_meta(source_placed_block_state.SOURCE_BLOCK_HEALTH_META_KEY, 4.0)
	cell_sprite.set_meta(source_placed_block_state.SOURCE_BLOCK_MAX_HEALTH_META_KEY, 5.0)
	cell_sprite.set_meta(source_placed_block_state.SOURCE_BLOCK_TIME_SCALE_META_KEY, 2.0)
	cell_sprite.set_meta(source_placed_block_state.SOURCE_BLOCK_TIME_SCALE_DURATION_META_KEY, 5.0)
	placed_blocks = {Vector2i.ZERO: cell_sprite}
	var health := source_placed_block_state.health(sprite)
	var damaged := source_placed_block_state.damaged(sprite, source_block_defaults.HEALTH_DAMAGED_EPSILON)
	var damage_matches := source_placed_block_state.damage_sprite(sprite, 1.5) == 2.5 and source_placed_block_state.health(sprite) == 2.5
	var repair_matches := source_placed_block_state.repair_sprite(sprite, 10.0) == 2.5 and source_placed_block_state.health(sprite) == 5.0
	var initialized_sprite := Sprite2D.new()
	source_placed_block_state.game_initialize_sprite(self, initialized_sprite, {"id": "router", "properties": {"health": 12.0}}, Vector2i(2, 3), ["2,3"])
	var game_initialize_matches := source_placed_block_state.health(initialized_sprite) == 12.0 and source_placed_block_state.time_scale(initialized_sprite, source_block_defaults.TIME_SCALE_DEFAULT) == source_block_defaults.TIME_SCALE_DEFAULT and str(initialized_sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_CELL_KEY_META_KEY, "")) == "2,3"
	source_placed_block_state.game_simulate_time_scales(self, 1.0 / 60.0)
	var time_scale_decay_matches := source_placed_block_state.time_scale(sprite, source_block_defaults.TIME_SCALE_DEFAULT) == 2.0 and source_placed_block_state.time_scale_duration(sprite) == 4.0
	var step_state := source_placed_block_state.game_step_time_scales(self, 1.0 / 60.0)
	var step_matches := str(step_state.get("last_overdrive_projector_boosted_block_id", "")) == "router" and float(step_state.get("time_scale", 0.0)) == 2.0 and float(step_state.get("time_scale_duration", 0.0)) == 3.0
	var cell_health := source_placed_block_state.game_health_at_cell(self, 0, 0)
	var cell_time_scale := source_placed_block_state.game_time_scale_at_cell(self, 0, 0)
	var cell_time_scale_duration := source_placed_block_state.game_time_scale_duration_at_cell(self, 0, 0)
	var cell_damage := source_placed_block_state.game_damage_at_cell(self, 0, 0, 1.5)
	var cell_health_matches := cell_health == 4.0
	var cell_time_scale_matches := cell_time_scale == 2.0
	var cell_time_scale_duration_matches := cell_time_scale_duration == 5.0
	var cell_damage_matches := cell_damage == 2.5
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "PLACED_BLOCK_STATE_MODULE_PROOF",
		"health": health,
		"damaged": damaged,
		"damage_matches": damage_matches,
		"repair_matches": repair_matches,
		"game_initialize_matches": game_initialize_matches,
		"time_scale_decay_matches": time_scale_decay_matches,
		"step_matches": step_matches,
		"cell_health_matches": cell_health_matches,
		"cell_time_scale_matches": cell_time_scale_matches,
		"cell_time_scale_duration_matches": cell_time_scale_duration_matches,
		"cell_damage_matches": cell_damage_matches,
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = health == 4.0 and damaged and damage_matches and repair_matches and game_initialize_matches and time_scale_decay_matches and step_matches and cell_health_matches and cell_time_scale_matches and cell_time_scale_duration_matches and cell_damage_matches and proof["registry_valid"] and proof["one_headquarter_per_ssot"]
	runtime_proof_state.write_proof("PlacedBlockStateModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

func _proof_building_time_scale_decay_state(current_time_scale: float, current_duration: float, source_delta: float) -> Dictionary:
	return {
		"time_scale": current_time_scale,
		"time_scale_duration": current_duration - source_delta,
	}

func _proof_block_time_scale_at_cell(_x: int, _y: int) -> float:
	return source_placed_block_state.time_scale(placed_block_origins.get("cell"), source_block_defaults.TIME_SCALE_DEFAULT)

func _proof_block_time_scale_duration_at_cell(_x: int, _y: int) -> float:
	return source_placed_block_state.time_scale_duration(placed_block_origins.get("cell"))

func block_sprite_at_cell(cell: Vector2i):
	return placed_blocks.get(cell)

