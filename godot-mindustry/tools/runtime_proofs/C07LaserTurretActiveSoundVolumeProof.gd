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

	# --- LaserTurretBuild.activeSoundVolume() + shouldActiveSound() (N2418):
	# LaserTurretBuild.activeSoundVolume()
	# (LaserTurret.java:147-149) always returns 1f, and
	# LaserTurretBuild.shouldActiveSound()
	# (LaserTurret.java:152-154) returns bullets.any():
	# `@Override`
	# `public float activeSoundVolume(){`
	# `return 1f;`
	# `}`
	# `@Override`
	# `public boolean shouldActiveSound(){`
	# `return bullets.any();`
	# `}`
	# on `public class LaserTurretBuild extends PowerTurretBuild{`
	# (LaserTurret.java:44). The bullets seq arrives as the
	# explicit has_bullets param (the N2330 param precedent).
	# NO driver tick line: pure read accessors the tick
	# reads. The proof calls the pure function with
	# synthetic scalar inputs (no live tick).

	# The volume is always 1f, with or without bullets.
	var with_bullets: Dictionary = bridge.source_laser_turret_build_active_sound_state(true)
	proof["active_sound_volume_is_one"] = float(with_bullets.get("active_sound_volume", 0.0)) == 1.0

	# A bullet around means the loop sound should play.
	proof["should_active_sound_bullets_around"] = bool(with_bullets.get("should_active_sound", false)) == true

	# No bullets around means silence.
	var no_bullets: Dictionary = bridge.source_laser_turret_build_active_sound_state(false)
	proof["should_active_sound_no_bullets"] = bool(no_bullets.get("should_active_sound", true)) == false

	# The result carries ONLY the two keys.
	proof["active_sound_returns_only_two_keys"] = with_bullets.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaserTurretActiveSoundVolumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
