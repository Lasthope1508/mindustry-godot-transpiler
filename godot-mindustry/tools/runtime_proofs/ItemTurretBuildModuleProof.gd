extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_item_turret_build_state := preload("res://src/game/SourceItemTurretBuildState.gd")
const source_item_turret_build_io_state := preload("res://src/game/SourceItemTurretBuildIoState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var wrapper := game.source_item_turret_build_on_proximity_added_state(false, true, 1, "copper")
	var module := source_item_turret_build_state.on_proximity_added_state(false, true, 1, "copper")
	var sense := game.source_item_turret_build_sense_object_state("currentAmmoType", 1, "copper", null)
	var on_proximity_bridge := game.generated_item_turret_build_on_proximity_added_bridge_state(false, true, 1, "copper")
	var sense_bridge := game.generated_item_turret_build_sense_object_bridge_state("currentAmmoType", 1, "copper", null)
	var ammo_content_bridge := game.generated_item_turret_build_get_ammo_content_bridge_state(1, "copper")
	var ammo_fraction_bridge := game.generated_item_turret_build_get_ammo_fraction_bridge_state(15.0, 30.0)
	var ammo_fraction_default_bridge := game.generated_item_turret_build_get_ammo_fraction_default_bridge_state(15.0)
	var accept_stack_bridge := game.generated_item_turret_build_accept_stack_bridge_state("copper", 5, 30.0, 10.0, 1.0, false)
	var accept_stack_default_bridge := game.generated_item_turret_build_accept_stack_default_bridge_state("copper", 5)
	var handle_stack_bridge := game.generated_item_turret_build_handle_stack_bridge_state("copper", 2)
	var remove_stack_bridge := game.generated_item_turret_build_remove_stack_bridge_state("copper", 1)
	var handle_item_bridge := game.generated_item_turret_build_handle_item_bridge_state("copper", false, 0, 2.0, false, [])
	var accept_item_bridge := game.generated_item_turret_build_accept_item_bridge_state("copper", 10, 30.0, 1.0, false)
	var accept_item_default_bridge := game.generated_item_turret_build_accept_item_default_bridge_state("copper")
	var read_state := game.source_item_turret_build_read_state(2, 40, [{"item": "copper", "amount": 6, "ammo_type_valid": true}])
	var io_write_facade := source_item_turret_build_state.write_state([{"item_id": 1, "amount": 6}])
	var io_write_direct := source_item_turret_build_io_state.write_state([{"item_id": 1, "amount": 6}])
	var io_read_facade := source_item_turret_build_state.read_state(2, 40, [{"item": "copper", "amount": 6, "ammo_type_valid": true}])
	var io_read_direct := source_item_turret_build_io_state.read_state(2, 40, [{"item": "copper", "amount": 6, "ammo_type_valid": true}])
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceItemTurretBuildState",
		"matches": wrapper == module and bool(read_state.get("total_ammo_after", 0) == 6),
		"io_module_direct_matches": io_write_facade == io_write_direct and io_read_facade == io_read_direct,
		"on_proximity_bridge_matches": on_proximity_bridge == source_item_turret_build_state.generated_item_turret_build_on_proximity_added_bridge_state(false, true, 1, "copper"),
		"sense_bridge_matches": sense_bridge == source_item_turret_build_state.generated_item_turret_build_sense_object_bridge_state("currentAmmoType", 1, "copper", null),
		"ammo_content_bridge_matches": ammo_content_bridge == source_item_turret_build_state.generated_item_turret_build_get_ammo_content_bridge_state(1, "copper"),
		"ammo_fraction_bridge_matches": ammo_fraction_bridge == source_item_turret_build_state.generated_item_turret_build_get_ammo_fraction_bridge_state(15.0, 30.0),
		"ammo_fraction_default_bridge_matches": ammo_fraction_default_bridge == source_item_turret_build_state.generated_item_turret_build_get_ammo_fraction_default_bridge_state(15.0),
		"accept_stack_bridge_matches": accept_stack_bridge == source_item_turret_build_state.generated_item_turret_build_accept_stack_bridge_state("copper", 5, 30.0, 10.0, 1.0, false),
		"accept_stack_default_bridge_matches": accept_stack_default_bridge == source_item_turret_build_state.generated_item_turret_build_accept_stack_default_bridge_state("copper", 5),
		"handle_stack_bridge_matches": handle_stack_bridge == source_item_turret_build_state.generated_item_turret_build_handle_stack_bridge_state("copper", 2),
		"remove_stack_bridge_matches": remove_stack_bridge == source_item_turret_build_state.generated_item_turret_build_remove_stack_bridge_state("copper", 1),
		"handle_item_bridge_matches": handle_item_bridge == source_item_turret_build_state.generated_item_turret_build_handle_item_bridge_state("copper", false, 0, 2.0, false, []),
		"accept_item_bridge_matches": accept_item_bridge == source_item_turret_build_state.generated_item_turret_build_accept_item_bridge_state("copper", 10, 30.0, 1.0, false),
		"accept_item_default_bridge_matches": accept_item_default_bridge == source_item_turret_build_state.generated_item_turret_build_accept_item_default_bridge_state("copper"),
		"source": wrapper,
		"sense": sense,
		"on_proximity_bridge": on_proximity_bridge,
		"sense_bridge": sense_bridge,
		"ammo_content_bridge": ammo_content_bridge,
		"ammo_fraction_bridge": ammo_fraction_bridge,
		"ammo_fraction_default_bridge": ammo_fraction_default_bridge,
		"accept_stack_bridge": accept_stack_bridge,
		"accept_stack_default_bridge": accept_stack_default_bridge,
		"handle_stack_bridge": handle_stack_bridge,
		"remove_stack_bridge": remove_stack_bridge,
		"handle_item_bridge": handle_item_bridge,
		"accept_item_bridge": accept_item_bridge,
		"accept_item_default_bridge": accept_item_default_bridge,
		"read": read_state,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["matches"] and proof["io_module_direct_matches"] and proof["on_proximity_bridge_matches"] and proof["sense_bridge_matches"] and proof["ammo_content_bridge_matches"] and proof["ammo_fraction_bridge_matches"] and proof["ammo_fraction_default_bridge_matches"] and proof["accept_stack_bridge_matches"] and proof["accept_stack_default_bridge_matches"] and proof["handle_stack_bridge_matches"] and proof["remove_stack_bridge_matches"] and proof["handle_item_bridge_matches"] and proof["accept_item_bridge_matches"] and proof["accept_item_default_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("ITEM_TURRET_BUILD_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ItemTurretBuildModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

