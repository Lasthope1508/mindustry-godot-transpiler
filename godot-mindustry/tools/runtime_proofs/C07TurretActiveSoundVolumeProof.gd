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

	# --- Turret activeSoundVolume() + shouldActiveSound() (N2346):
	# TurretBuild.activeSoundVolume() (Turret.java:822-824) echoes
	# the shootWarmup field:
	# `public float activeSoundVolume(){`
	# `return shootWarmup;`
	# `}`
	# and TurretBuild.shouldActiveSound() (Turret.java:826-829)
	# is the warmup threshold plus the loopSound check:
	# `public boolean shouldActiveSound(){`
	# `return shootWarmup > 0.01f && loopSound != Sounds.none;`
	# `}`
	# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
	# (Turret.java:277). shootWarmup is the TurretBuild field
	# (`public float shootWarmup, charge, warmupHold = 0f;`,
	# Turret.java:286) and arrives as the explicit float
	# shoot_warmup. loopSound is the Turret def field (`public
	# Sound loopSound = Sounds.none;`, Turret.java:128); the
	# `loopSound != Sounds.none` check arrives as the explicit
	# bool has_loop_sound. NO driver tick line: both are pure
	# accessors the updateTile() tick reads at :499. The proof
	# calls the pure functions with synthetic frames (no live
	# tick).

	# Volume echoes warmup: warmup 0.6 -> volume 0.6.
	var warm: Dictionary = turret_build_state.source_turret_active_sound_volume_state({}, 0.6)
	proof["active_sound_volume_echoes_warmup"] = is_equal_approx(float(warm.get("active_sound_volume", -1.0)), 0.6)

	# Volume zero when cold: warmup 0.0 -> volume 0.0.
	var cold: Dictionary = turret_build_state.source_turret_active_sound_volume_state({}, 0.0)
	proof["active_sound_volume_zero"] = is_equal_approx(float(cold.get("active_sound_volume", -1.0)), 0.0)

	# The volume result carries ONLY the one active_sound_volume key.
	proof["active_sound_volume_returns_only_one_key"] = warm.size() == 1

	# Warm with a loop sound sounds: warmup 0.5, loop sound set -> true.
	var sounding: Dictionary = turret_build_state.source_turret_should_active_sound_state({}, 0.5, true)
	proof["should_active_sound_true"] = bool(sounding.get("should_active_sound", false)) == true

	# Cold stays silent even with a loop sound: warmup 0.005 -> false.
	var too_cold: Dictionary = turret_build_state.source_turret_should_active_sound_state({}, 0.005, true)
	proof["should_active_sound_false_cold"] = bool(too_cold.get("should_active_sound", true)) == false

	# Warm without a loop sound stays silent: warmup 0.9, no loop sound -> false.
	var no_loop: Dictionary = turret_build_state.source_turret_should_active_sound_state({}, 0.9, false)
	proof["should_active_sound_false_no_loop"] = bool(no_loop.get("should_active_sound", true)) == false

	# Exactly 0.01 is silent: the Java `>` is strict, so the
	# boundary warmup does not sound.
	var boundary: Dictionary = turret_build_state.source_turret_should_active_sound_state({}, 0.01, true)
	proof["should_active_sound_boundary_0_01"] = bool(boundary.get("should_active_sound", true)) == false

	# The predicate result carries ONLY the one should_active_sound key.
	proof["should_active_sound_returns_only_one_key"] = sounding.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretActiveSoundVolumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
