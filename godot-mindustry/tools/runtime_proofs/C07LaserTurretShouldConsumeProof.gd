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

	# --- LaserTurretBuild.shouldConsume() (N2360):
	# LaserTurretBuild.shouldConsume()
	# (LaserTurret.java:53-58) still consumes power while a
	# bullet is around or while active, and otherwise only
	# while shooting:
	# `@Override`
	# `public boolean shouldConsume(){`
	# `//still consumes power when bullet is around`
	# `if(bullets.any() || isActive()) return true;`
	# `return isShooting;`
	# `}`
	# on `public class LaserTurretBuild extends PowerTurretBuild{`
	# (LaserTurret.java:44). The bullets seq / isActive() /
	# isShooting arrive as explicit params (the N2330 param
	# precedent; isActive() owned at N2328, isShooting at
	# N2343). NO driver tick line: a pure predicate the power
	# graph reads. The proof calls the pure function with
	# synthetic scalar inputs (no live tick).

	# A bullet around consumes power even when idle.
	var bullets_around: Dictionary = bridge.source_laser_turret_build_should_consume_state(true, false, false)
	proof["should_consume_bullets_around"] = bool(bullets_around.get("should_consume", false)) == true

	# Active consumes power even with no bullet and no shot.
	var active: Dictionary = bridge.source_laser_turret_build_should_consume_state(false, true, false)
	proof["should_consume_active"] = bool(active.get("should_consume", false)) == true

	# Shooting consumes power even with no bullet and inactive.
	var shooting: Dictionary = bridge.source_laser_turret_build_should_consume_state(false, false, true)
	proof["should_consume_shooting"] = bool(shooting.get("should_consume", false)) == true

	# Idle (no bullet, inactive, not shooting) consumes nothing.
	var idle: Dictionary = bridge.source_laser_turret_build_should_consume_state(false, false, false)
	proof["should_consume_idle"] = bool(idle.get("should_consume", true)) == false

	# The result carries ONLY the one should_consume key.
	proof["should_consume_returns_only_one_key"] = bullets_around.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaserTurretShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
