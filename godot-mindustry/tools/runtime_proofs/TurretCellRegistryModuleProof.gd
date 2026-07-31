extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_turret_cell_registry_state := preload("res://src/game/SourceTurretCellRegistryState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var block = game.selected_playable_turret()
	var cell := Vector2i(13, 17)
	var key := str(game.call("cell_key", cell))
	source_turret_cell_registry_state.register_turret_cell(game, cell, block)
	var register_matches: bool = game.get("turret_cells").has(cell) and float(game.get("turret_cooldowns").get(key, -1.0)) == 0.0 and int(game.get("turret_total_ammo").get(key, -1)) == 0 and int(game.get("turret_barrel_counters").get(key, -1)) == 0 and float(game.get("turret_rotations").get(key, -1.0)) == 0.0 and float(game.get("turret_recoils").get(key, -1.0)) == 0.0 and bool(game.get("turret_ammo_stacks").has(key))
	source_turret_cell_registry_state.unregister_turret_cell(game, cell)
	var unregister_matches: bool = not game.get("turret_cells").has(cell) and not game.get("turret_cooldowns").has(key) and not game.get("turret_total_ammo").has(key) and not game.get("turret_barrel_counters").has(key) and not game.get("turret_rotations").has(key) and not game.get("turret_recoils").has(key) and not game.get("turret_ammo_stacks").has(key)
	var proof := {
		"module": "SourceTurretCellRegistryState",
		"register_matches": register_matches,
		"unregister_matches": unregister_matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("valid", false)),
	}
	proof["matches"] = proof["register_matches"] and proof["unregister_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("TURRET_CELL_REGISTRY_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/TurretCellRegistryModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
