extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- Turret controlled() (N2324): the TurretBuild player-control
	# read accessor (Turret.java:441-443):
	# `public boolean controlled(){`
	# `return unit.isPlayer();`
	# `}`
	# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
	# (Turret.java:277). unit is the TurretBuild field (`public BlockUnitc
	# unit = (BlockUnitc)UnitTypes.block.create(team);`, Turret.java:291),
	# synced by unit() (N2307). isPlayer() (`return controller instanceof
	# Player;`, UnitComp.java:949-951) is NOT re-ported here: its result
	# arrives as the explicit is_player param. NO driver tick line: a
	# read accessor its callers read (validateTarget Turret.java:632,
	# updateTile :494), not a per-tick write. The proof calls the pure
	# function with synthetic frames (no live tick).

	# The building frame (`this`) -- controlled() does not read frame fields.
	var frame: Dictionary = {"marker": "turret-frame", "x": 5, "y": 7}

	# A player-controlled unit is true (unit.isPlayer() true).
	var player_result: Dictionary = turret_build_state.source_turret_controlled_state(frame, true)
	proof["controlled_player_true"] = player_result.get("controlled", false) == true

	# A non-player unit is false (unit.isPlayer() false).
	var ai_result: Dictionary = turret_build_state.source_turret_controlled_state(frame, false)
	proof["controlled_player_false"] = ai_result.get("controlled", true) == false

	# The result carries ONLY its one key: no frame echo, no extra state.
	proof["returns_only_one_key"] = player_result.size() == 1 and ai_result.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretControlledProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
