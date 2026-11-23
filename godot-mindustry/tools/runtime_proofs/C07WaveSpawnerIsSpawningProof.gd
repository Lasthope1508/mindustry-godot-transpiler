extends Node

const wave_spawner_state := preload("res://src/game/SourceWaveSpawnerState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- WaveSpawner.isSpawning() (N2444):
	# WaveSpawner.isSpawning() (WaveSpawner.java:213-215). One method
	# slice (batch 40 slot 2): exactly the 1 body expr
	# `return spawning && !net.client();` (:214). `spawning` is the
	# WaveSpawner field `private boolean spawning = false;`
	# (WaveSpawner.java:27); GD takes it as a bool input and
	# `net.client()` as the frame input is_client, never resolved
	# here (precedent N2438 checkCampaignStats, same
	# `... && !net.client()` shape). The proof calls the pure
	# function with synthetic frame inputs (no live tick, no
	# spawner): spawning + not client -> true; not spawning ->
	# false; client -> false; exactly 1 result key, and a
	# second call on the same inputs yields the same value.

	# Spawning + not client -> true.
	proof["spawning_true_when_spawning_and_not_client"] = bool(wave_spawner_state.source_wave_spawner_is_spawning_state(true, false).get("spawning", false)) == true

	# Not spawning -> false.
	proof["spawning_false_when_not_spawning"] = bool(wave_spawner_state.source_wave_spawner_is_spawning_state(false, false).get("spawning", true)) == false

	# Client -> false (even while spawning).
	proof["spawning_false_when_client"] = bool(wave_spawner_state.source_wave_spawner_is_spawning_state(true, true).get("spawning", true)) == false

	# Exactly 1 result key: spawning.
	proof["spawning_returns_one_key"] = wave_spawner_state.source_wave_spawner_is_spawning_state(true, false).size() == 1

	# A second call on the same inputs yields the same value:
	# isSpawning is a pure function of its inputs, with no
	# hidden state.
	var second: Dictionary = wave_spawner_state.source_wave_spawner_is_spawning_state(true, false)
	proof["spawning_idempotent_second_call"] = bool(second.get("spawning", false)) == true and second.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WaveSpawnerIsSpawningProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
