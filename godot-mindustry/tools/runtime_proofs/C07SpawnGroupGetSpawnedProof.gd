extends Node

const wave_spawn_runtime_state := preload("res://src/game/SourceWaveSpawnRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- SpawnGroup.getSpawned(int) (N2449):
	# SpawnGroup.getSpawned(int wave) (SpawnGroup.java:67-73).
	# Registration-only slice (precedent N2427/N2430/N2432-N2434):
	# the formula is already LIVE in
	# SourceWaveSpawnRuntimeState.spawned_for_wave_state (:16-40),
	# so the proof drives the existing pure function with synthetic
	# frame inputs (no live tick, no spawner). The 3 registered
	# exprs are :68 `if(spacing == 0) spacing = 1;`, :69
	# `if(wave < begin || wave > end || (wave - begin) % spacing
	# != 0){`, :72 `return Math.min(unitAmount + (int)(((wave -
	# begin) / spacing) / unitScaling), max);`. `:70`
	# `return 0;` is a generic literal already owned elsewhere
	# and is NOT registered here. The GD func takes wave_zero
	# (the wave argument after the call-site's `state.wave - 1`,
	# see SOURCE_WAVE_SPAWNER_WAVE_ZERO_EXPR) plus the group
	# Dictionary carrying begin/end/spacing/unitAmount/unitScaling/
	# max, and returns eligible + spawned.

	# wave < begin -> eligible false, spawned 0.
	var below_begin: Dictionary = wave_spawn_runtime_state.spawned_for_wave_state({"begin": 5, "end": 10, "spacing": 1, "unitAmount": 1, "unitScaling": 1.0, "max": 60}, 3)
	proof["get_spawned_zero_when_wave_below_begin"] = bool(below_begin.get("eligible", true)) == false and int(below_begin.get("spawned", -1)) == 0

	# wave > end -> eligible false, spawned 0.
	var above_end: Dictionary = wave_spawn_runtime_state.spawned_for_wave_state({"begin": 5, "end": 10, "spacing": 1, "unitAmount": 1, "unitScaling": 1.0, "max": 60}, 11)
	proof["get_spawned_zero_when_wave_above_end"] = bool(above_end.get("eligible", true)) == false and int(above_end.get("spawned", -1)) == 0

	# (wave - begin) % spacing != 0 -> eligible false, spawned 0.
	var not_multiple: Dictionary = wave_spawn_runtime_state.spawned_for_wave_state({"begin": 0, "end": 10, "spacing": 2, "unitAmount": 1, "unitScaling": 1.0, "max": 60}, 3)
	proof["get_spawned_zero_when_wave_not_multiple"] = bool(not_multiple.get("eligible", true)) == false and int(not_multiple.get("spawned", -1)) == 0

	# spacing == 0 is treated as spacing 1 (:68): wave 3 is
	# eligible and spawned = min(1 + int(3 / 1 / 1.0), 60) = 4.
	var spacing_zero: Dictionary = wave_spawn_runtime_state.spawned_for_wave_state({"begin": 0, "end": 10, "spacing": 0, "unitAmount": 1, "unitScaling": 1.0, "max": 60}, 3)
	proof["get_spawned_spacing_zero_treated_as_one"] = bool(spacing_zero.get("eligible", false)) == true and int(spacing_zero.get("spawned", -1)) == 4

	# Valid wave -> formula :72: begin 0, spacing 1, wave 4,
	# unitAmount 2, unitScaling 2.0 -> spawned = min(2 + int(4 /
	# 1 / 2.0), 60) = 4, and eligible is true.
	var valid_wave: Dictionary = wave_spawn_runtime_state.spawned_for_wave_state({"begin": 0, "end": 10, "spacing": 1, "unitAmount": 2, "unitScaling": 2.0, "max": 60}, 4)
	proof["get_spawned_valid_wave_formula"] = int(valid_wave.get("spawned", -1)) == 4
	proof["get_spawned_eligible_true_when_valid"] = bool(valid_wave.get("eligible", false)) == true

	# max clamp: unitAmount 50, wave 10, spacing 1, unitScaling
	# 1.0 -> min(50 + 10, 60) = 60.
	var max_clamp: Dictionary = wave_spawn_runtime_state.spawned_for_wave_state({"begin": 0, "end": 99, "spacing": 1, "unitAmount": 50, "unitScaling": 1.0, "max": 60}, 10)
	proof["get_spawned_max_clamp"] = int(max_clamp.get("spawned", -1)) == 60

	# unitScaling: begin 2, spacing 3, wave 8, unitAmount 1,
	# unitScaling 0.5 -> (8 - 2) / 3 = 2, 2 / 0.5 = 4 ->
	# spawned = 1 + 4 = 5.
	var unit_scaling: Dictionary = wave_spawn_runtime_state.spawned_for_wave_state({"begin": 2, "end": 99, "spacing": 3, "unitAmount": 1, "unitScaling": 0.5, "max": 60}, 8)
	proof["get_spawned_unit_scaling"] = int(unit_scaling.get("spawned", -1)) == 5

	# The returned spacing is the effective spacing after :68
	# (spacing 0 in -> 1 out); the input Dictionary is not
	# mutated by the pure function.
	proof["get_spawned_returns_effective_spacing"] = int(spacing_zero.get("spacing", -1)) == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SpawnGroupGetSpawnedProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
