extends Node

const main_scene := preload("res://scenes/Main.tscn")
const shockwave_tower_build_state := preload("res://src/game/SourceShockwaveTowerBuildState.gd")
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

	# --- Per-def stat rows (N2492): the VERIFICATION
	# slice -- the values are already constants in
	# the driver header (the N2304 / N2442 / N2490
	# precedent). The single ShockwaveTower def
	# shockwave-tower (Blocks.java:2038-2044)
	# sets size 3, range 170f, reload 80f and
	# requirements surge-alloy 50 / silicon 150 /
	# oxide 30 / tungsten 100. An unknown def id
	# falls back to the CLASS defaults (the N2304
	# fallback precedent): size 1 (Block.java:215),
	# range 110f (ShockwaveTower.java:25), reload
	# 60f * 1.5f = 90f (ShockwaveTower.java:26)
	# and NO requirements (the Block default is the
	# empty array, Block.java:356). Pure-only: the
	# caller reads it; the advance + shouldConsume +
	# sense pures take these values as
	# caller-supplied inputs and are unchanged.

	# --- Def row: shockwave-tower -- size 3,
	# range 170f, reload 80f, requirements
	# surge-alloy 50 / silicon 150 / oxide 30 /
	# tungsten 100.
	var tower: Dictionary = shockwave_tower_build_state.source_shockwave_tower_per_def_stats_state("shockwave-tower")
	var tower_requirements: Dictionary = tower.get("requirements", {})
	proof["stats_tower"] = int(tower.get("size", -1)) == 3 and is_equal_approx(float(tower.get("range_value", -1.0)), 170.0) and is_equal_approx(float(tower.get("reload_value", -1.0)), 80.0) and int(tower_requirements.get("surge-alloy", -1)) == 50 and int(tower_requirements.get("silicon", -1)) == 150 and int(tower_requirements.get("oxide", -1)) == 30 and int(tower_requirements.get("tungsten", -1)) == 100

	# --- Size / range: the def is size 3 over
	# 170f while the class defaults are size 1
	# over 110f -- the def overrides BOTH class
	# fields.
	var fallback: Dictionary = shockwave_tower_build_state.source_shockwave_tower_per_def_stats_state("no-such-def")
	proof["stats_size_range"] = int(tower.get("size", -1)) == 3 and is_equal_approx(float(tower.get("range_value", -1.0)), 170.0) and int(fallback.get("size", -1)) == 1 and is_equal_approx(float(fallback.get("range_value", -1.0)), 110.0)

	# --- Reload: the def reloads in 80f while the
	# class default is 60f * 1.5f = 90f.
	proof["stats_reload"] = is_equal_approx(float(tower.get("reload_value", -1.0)), 80.0) and is_equal_approx(float(fallback.get("reload_value", -1.0)), 90.0)

	# --- Requirements: the def dict carries
	# exactly the four items (surge-alloy 50,
	# silicon 150, oxide 30, tungsten 100); the
	# class fallback carries none.
	var fallback_requirements: Dictionary = fallback.get("requirements", {"x": 1})
	proof["stats_requirements"] = tower_requirements.size() == 4 and int(tower_requirements.get("surge-alloy", -1)) == 50 and int(tower_requirements.get("silicon", -1)) == 150 and int(tower_requirements.get("oxide", -1)) == 30 and int(tower_requirements.get("tungsten", -1)) == 100 and fallback_requirements.is_empty()

	# --- Class fallback: an unknown def id (and
	# the empty id) returns the CLASS defaults --
	# size 1, range 110f, reload 90f, and NO
	# requirements.
	var empty_fallback: Dictionary = shockwave_tower_build_state.source_shockwave_tower_per_def_stats_state("")
	var empty_requirements: Dictionary = empty_fallback.get("requirements", {"x": 1})
	proof["stats_class_fallback"] = int(fallback.get("size", -1)) == 1 and is_equal_approx(float(fallback.get("range_value", -1.0)), 110.0) and is_equal_approx(float(fallback.get("reload_value", -1.0)), 90.0) and fallback_requirements.is_empty() and int(empty_fallback.get("size", -1)) == 1 and is_equal_approx(float(empty_fallback.get("range_value", -1.0)), 110.0) and is_equal_approx(float(empty_fallback.get("reload_value", -1.0)), 90.0) and empty_requirements.is_empty()

	# --- Live input: the per-def rows feed the
	# N2390 sense pure as its caller-supplied
	# reload input -- a counter of 45 reads
	# 45 / 80 = 0.5625 progress at the def reload
	# and 45 / 90 = 0.5 at the class fallback
	# reload (the BARE ratio, no clamp,
	# ShockwaveTower.java:110).
	var tower_sense: Dictionary = shockwave_tower_build_state.source_shockwave_tower_sense_state("progress", 45.0, float(tower.get("reload_value", 0.0)))
	var fallback_sense: Dictionary = shockwave_tower_build_state.source_shockwave_tower_sense_state("progress", 45.0, float(fallback.get("reload_value", 0.0)))
	proof["stats_live_input"] = is_equal_approx(float(tower_sense.get("value", -1.0)), 0.5625) and is_equal_approx(float(fallback_sense.get("value", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerPerDefStatRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
