extends Node

const wave_spawn_runtime_state := preload("res://src/game/SourceWaveSpawnRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- SpawnGroup.getShield(int) (N2452):
	# SpawnGroup.getShield(int wave) (SpawnGroup.java:76-78).
	# One method slice (batch 43 slot 1): exactly the 1 body expr
	# `return Math.max(shields + shieldScaling*(wave - begin),
	# 0);` (:77). Unlike getSpawned (N2449, registration-only),
	# the formula was NOT live in GD, so this slice writes the new
	# GD func source_spawn_group_get_shield_state. Java
	# `Math.max(float, int 0)` becomes GD `maxf(shields +
	# shield_scaling * float(wave - begin), 0.0)` (maxf, not maxi,
	# because the left side is a float; wave - begin may be
	# negative -- the clamp to 0 is correct in that case too).
	# The proof drives the new pure function with synthetic frame
	# inputs (no live tick, no spawner).

	# shields 0 + scaling 0 -> 0.
	var zero: Dictionary = wave_spawn_runtime_state.source_spawn_group_get_shield_state(0.0, 0.0, 5, 0)
	proof["get_shield_zero_when_no_shields_no_scaling"] = float(zero.get("shield", -1.0)) == 0.0

	# wave == begin -> shields (scaling term is 0).
	var at_begin: Dictionary = wave_spawn_runtime_state.source_spawn_group_get_shield_state(10.0, 2.0, 3, 3)
	proof["get_shield_returns_shields_when_wave_equals_begin"] = float(at_begin.get("shield", -1.0)) == 10.0

	# wave > begin with positive scaling -> formula: 5 + 3 * (7
	# - 2) = 20.
	var formula: Dictionary = wave_spawn_runtime_state.source_spawn_group_get_shield_state(5.0, 3.0, 7, 2)
	proof["get_shield_formula_when_wave_after_begin"] = float(formula.get("shield", -1.0)) == 20.0

	# wave < begin with positive scaling -> clamp 0: 5 + 2 * (0
	# - 10) = -15 -> 0.
	var clamped: Dictionary = wave_spawn_runtime_state.source_spawn_group_get_shield_state(5.0, 2.0, 0, 10)
	proof["get_shield_clamps_to_zero_when_wave_before_begin"] = float(clamped.get("shield", -1.0)) == 0.0

	# scaling 0 -> shields regardless of wave: 8 + 0 * 99 = 8.
	var no_scaling: Dictionary = wave_spawn_runtime_state.source_spawn_group_get_shield_state(8.0, 0.0, 99, 0)
	proof["get_shield_returns_shields_when_scaling_zero"] = float(no_scaling.get("shield", -1.0)) == 8.0

	# Exactly 1 result key: shield.
	proof["get_shield_returns_one_key"] = formula.size() == 1

	# A second call on the same inputs yields the same value:
	# getShield is a pure function of its inputs, with no hidden
	# state.
	var second: Dictionary = wave_spawn_runtime_state.source_spawn_group_get_shield_state(5.0, 3.0, 7, 2)
	proof["get_shield_idempotent_second_call"] = float(second.get("shield", -1.0)) == 20.0 and second.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SpawnGroupGetShieldProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
