extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_projector_boost_state := preload("res://src/game/SourceProjectorBoostState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")
const source_world_grid := preload("res://src/game/SourceWorldGrid.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	game.placed_blocks = {}
	game.core_items = {"phase-fabric": 2}
	game.core_inventory = 2
	var _mend_sprite := _projector_sprite(game, Vector2i(3, 4), "mend-projector")
	var _overdrive_sprite := _projector_sprite(game, Vector2i(7, 8), "overdrive-projector")
	var mend_key := game.cell_key(Vector2i(3, 4))
	var overdrive_key := game.cell_key(Vector2i(7, 8))
	var mend_booster_items: Dictionary = {}
	var mend_optional_efficiency: Dictionary = {}
	var overdrive_booster_items: Dictionary = {}
	var overdrive_optional_efficiency: Dictionary = {}
	var mend_applied := source_projector_boost_state.apply_projector_boost_at_cell(game, 3, 4, source_projector_boost_state.PROJECTOR_KIND_MEND, mend_booster_items, mend_optional_efficiency)
	var overdrive_applied := source_projector_boost_state.apply_projector_boost_at_cell(game, 7, 8, source_projector_boost_state.PROJECTOR_KIND_OVERDRIVE, overdrive_booster_items, overdrive_optional_efficiency)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "PROJECTOR_BOOST_RUNTIME_MODULE_PROOF",
		"mend_applied": mend_applied,
		"overdrive_applied": overdrive_applied,
		"mend_stock_consumed": int(game.core_items.get("phase-fabric", 0)) == 0,
		"mend_booster_stock": int(mend_booster_items.get(mend_key, 0)),
		"overdrive_booster_stock": int(overdrive_booster_items.get(overdrive_key, 0)),
		"mend_optional_efficiency": float(mend_optional_efficiency.get(mend_key, 0.0)),
		"overdrive_optional_efficiency": float(overdrive_optional_efficiency.get(overdrive_key, 0.0)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["mend_applied"] and proof["overdrive_applied"] and proof["mend_stock_consumed"] and proof["mend_booster_stock"] == 1 and proof["overdrive_booster_stock"] == 1 and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("PROJECTOR_BOOST_RUNTIME_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/ProjectorBoostRuntimeModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func _projector_sprite(game: Node, cell: Vector2i, block_id: String) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.set_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, block_id)
	sprite.set_meta("origin_cell", cell)
	sprite.set_meta(source_placed_block_state.SOURCE_BLOCK_CELL_KEY_META_KEY, source_world_grid.cell_key(cell))
	game.placed_blocks[game.cell_key(cell)] = sprite
	return sprite
