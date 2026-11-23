extends Node

const wave_spawner_state := preload("res://src/game/SourceWaveSpawnerState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- WaveSpawner.playerNear() (N2451):
	# WaveSpawner.playerNear() (WaveSpawner.java:58-60). One method
	# slice (batch 42 slot 3): exactly the 1 body expr -- the full
	# return line (:59). `tilesize` is Vars.tilesize = 8
	# (Vars.java:135; SourceWorldDefaults.TILESIZE), NOT 32 -- the
	# batch 42 draft said 32, which is wrong; verified from upstream
	# Vars.java:135 + SourceWorldSourceTextState.gd:6. `spawns` is the
	# WaveSpawner field `private Seq<Tile> spawns = new Seq<>(false);`
	# (WaveSpawner.java:26); each element is a tile dict with "x"/"y"
	# TILE coords (precedent SourceBeamDrillBuildState.gd:664), so GD
	# multiplies by TILESIZE to get pixels before the dst check.
	# `has_spawns` is a bool input (precedent spawn_knockback_state).
	# The proof calls the pure function with synthetic frame inputs
	# (no live tick, no spawner): hasSpawns=false -> false; player
	# dead -> false; spawn near + other team -> true; spawn far ->
	# false; same wave team -> false; exactly 1 result key, and a
	# second call on the same inputs yields the same value.
	# Player at pixel (80, 80) = tile (10, 10); drop zone radius 100.

	# hasSpawns=false -> false (even with a spawn on the player).
	proof["player_near_false_when_no_spawns"] = bool(wave_spawner_state.source_wave_spawner_player_near_state(false, false, [{"x": 10, "y": 10}], Vector2(80, 80), 100.0, 1, 2).get("player_near", true)) == false

	# player dead -> false (even with a spawn on the player).
	proof["player_near_false_when_player_dead"] = bool(wave_spawner_state.source_wave_spawner_player_near_state(true, true, [{"x": 10, "y": 10}], Vector2(80, 80), 100.0, 1, 2).get("player_near", true)) == false

	# Spawn near (tile (10, 10) -> pixel (80, 80), dst 0 < 100) and
	# player team (1) != wave team (2) -> true.
	proof["player_near_true_when_spawn_near_and_other_team"] = bool(wave_spawner_state.source_wave_spawner_player_near_state(true, false, [{"x": 10, "y": 10}], Vector2(80, 80), 100.0, 1, 2).get("player_near", false)) == true

	# Spawn far (tile (100, 100) -> pixel (800, 800), dst ~1018 > 100)
	# -> false, even with a near spawn absent and teams differing.
	proof["player_near_false_when_spawn_far"] = bool(wave_spawner_state.source_wave_spawner_player_near_state(true, false, [{"x": 100, "y": 100}], Vector2(80, 80), 100.0, 1, 2).get("player_near", true)) == false

	# Same wave team (player team 2 == wave team 2) -> false, even
	# with a spawn on the player.
	proof["player_near_false_when_same_wave_team"] = bool(wave_spawner_state.source_wave_spawner_player_near_state(true, false, [{"x": 10, "y": 10}], Vector2(80, 80), 100.0, 2, 2).get("player_near", true)) == false

	# Exactly 1 result key: player_near.
	proof["player_near_returns_one_key"] = wave_spawner_state.source_wave_spawner_player_near_state(true, false, [{"x": 10, "y": 10}], Vector2(80, 80), 100.0, 1, 2).size() == 1

	# A second call on the same inputs yields the same value:
	# playerNear is a pure function of its inputs, with no
	# hidden state.
	var second: Dictionary = wave_spawner_state.source_wave_spawner_player_near_state(true, false, [{"x": 10, "y": 10}], Vector2(80, 80), 100.0, 1, 2)
	proof["player_near_idempotent_second_call"] = bool(second.get("player_near", false)) == true and second.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WaveSpawnerPlayerNearProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
