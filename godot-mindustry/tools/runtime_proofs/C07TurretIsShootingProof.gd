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

	# --- Turret isShooting() shooting-state accessor (N2343):
	# TurretBuild.isShooting() (Turret.java:429-432) echoes the
	# isShooting field:
	# `public boolean isShooting(){`
	# `return isShooting;`
	# `}`
	# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
	# (Turret.java:277). The field is the TurretBuild field
	# (`public boolean wasShooting, isShooting;`,
	# Turret.java:292) and arrives as the explicit bool
	# is_shooting (the shouldConsume :364 / sense :413 /
	# warmup :502 precedent -- the field name collides with
	# the method name, so the GD param is is_shooting). The
	# field is written by updateTile :492 (not ported here).
	# NO driver tick line: isShooting() is a read accessor
	# its callers read, not a per-tick write. The proof calls
	# the pure function with synthetic frames (no live tick:
	# isShooting is a pure accessor over one input).

	# Shooting echoes true: the field is true -> the result is true.
	var shooting: Dictionary = turret_build_state.source_turret_is_shooting_state({}, true)
	proof["is_shooting_true"] = bool(shooting.get("is_shooting", false)) == true

	# Not shooting echoes false: the field is false -> the result is false.
	var idle: Dictionary = turret_build_state.source_turret_is_shooting_state({}, false)
	proof["is_shooting_false"] = bool(idle.get("is_shooting", true)) == false

	# The explicit param wins over a same-named frame key: the frame
	# carries no tracked key for this accessor (the minRange :593
	# precedent), so a frame holding is_shooting=true with param
	# false still returns false.
	var param_wins: Dictionary = turret_build_state.source_turret_is_shooting_state({"is_shooting": true}, false)
	proof["is_shooting_param_wins_over_frame"] = bool(param_wins.get("is_shooting", true)) == false

	# The result carries ONLY the one is_shooting key: no frame echo,
	# no extra state.
	proof["returns_only_one_key"] = shooting.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretIsShootingProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
