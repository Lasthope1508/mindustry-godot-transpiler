extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_tractor_beam_turret_lifecycle_state := preload("res://src/game/SourceTractorBeamTurretLifecycleState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var target := {"id": 7, "team": "crux"}
	var icons_bridge := game.generated_tractor_beam_turret_icons_bridge_state("base-region", "beam-region")
	var init_bridge := game.generated_tractor_beam_turret_init_bridge_state(120.0, 8.0)
	var should_consume_bridge := game.generated_tractor_beam_turret_build_should_consume_bridge_state(true, target)
	var estimate_dps_bridge := game.generated_tractor_beam_turret_build_estimate_dps_bridge_state(true, 4.0, 0.75, 1.5)
	var write_bridge := game.generated_tractor_beam_turret_build_write_bridge_state(45.0)
	var read_bridge := game.generated_tractor_beam_turret_build_read_bridge_state(90.0, 2)
	var proof := {
		"module": "SourceTractorBeamTurretLifecycleState",
		"icons_bridge_matches": icons_bridge == source_tractor_beam_turret_lifecycle_state.generated_icons_bridge_state("base-region", "beam-region") and bool(icons_bridge.get("matches", false)),
		"init_bridge_matches": init_bridge == source_tractor_beam_turret_lifecycle_state.generated_init_bridge_state(120.0, 8.0) and bool(init_bridge.get("matches", false)),
		"should_consume_bridge_matches": should_consume_bridge == source_tractor_beam_turret_lifecycle_state.generated_build_should_consume_bridge_state(true, target) and bool(should_consume_bridge.get("matches", false)),
		"estimate_dps_bridge_matches": estimate_dps_bridge == source_tractor_beam_turret_lifecycle_state.generated_build_estimate_dps_bridge_state(true, 4.0, 0.75, 1.5) and bool(estimate_dps_bridge.get("matches", false)),
		"write_bridge_matches": write_bridge == source_tractor_beam_turret_lifecycle_state.generated_build_write_bridge_state(45.0) and bool(write_bridge.get("matches", false)),
		"read_bridge_matches": read_bridge == source_tractor_beam_turret_lifecycle_state.generated_build_read_bridge_state(90.0, 2) and bool(read_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["icons_bridge_matches"] and proof["init_bridge_matches"] and proof["should_consume_bridge_matches"] and proof["estimate_dps_bridge_matches"] and proof["write_bridge_matches"] and proof["read_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("TRACTOR_BEAM_LIFECYCLE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/TractorBeamLifecycleModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
