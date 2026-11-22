extends Node

const main_scene := preload("res://scenes/Main.tscn")
const bridge := preload("res://src/game/SourceLaserTurretBuildPortBridge.gd")
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

	# --- LaserTurretBuild.placed() (N2422):
	# LaserTurretBuild.placed()
	# (LaserTurret.java:59-64) runs the super call once at
	# build placement:
	# `@Override`
	# `public void placed(){`
	# `super.placed();`
	# `reloadCounter = reload;`
	# `}`
	# on `public class LaserTurretBuild extends PowerTurretBuild{`
	# (LaserTurret.java:44). `reloadCounter = reload;` is
	# already owned at N2364 and is NOT re-registered. The GD
	# function records that placed() ran, returning a frame
	# with `placed: true` (the N2318 canPickup precedent).
	# NO driver tick line: placed() runs once, not per-tick.
	# The proof calls the pure function with no inputs (no
	# live tick).

	# placed() ran: the frame records it.
	var placed: Dictionary = bridge.source_laser_turret_build_placed_state()
	proof["placed_is_true"] = bool(placed.get("placed", false)) == true

	# The result carries ONLY the one key.
	proof["placed_returns_only_one_key"] = placed.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaserTurretPlacedProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
