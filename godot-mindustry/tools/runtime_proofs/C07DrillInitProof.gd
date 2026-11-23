extends Node

const main_scene := preload("res://scenes/Main.tscn")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _tick(game: PortGame, drill_effect_rnd: float, size: float) -> Dictionary:
	return game.source_drill_init_state(drill_effect_rnd, size)


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

	# --- Drill.init() (N2424):
	# Drill.init() (Drill.java:91-97) -- this slice is ONLY
	# the `if(drillEffectRnd < 0) drillEffectRnd = size;`
	# line (:96). NOT this slice: `super.init();` (:92)
	# and the blockedItems guard (:93-95), both already
	# owned. The Drill field default is
	# `public float drillEffectRnd = -1f;` (Drill.java:55,
	# "Block size by default"): a negative value means
	# "use the block size". The proof drives the pure
	# function with synthetic frames (no live tick).

	# The default -1f resolves to the block size.
	var defaulted: Dictionary = _tick(game, -1.0, 2.0)
	proof["negative_rnd_defaults_to_size"] = is_equal_approx(float(defaulted.get("drill_effect_rnd", -99.0)), 2.0)

	# A negative fraction also resolves to size.
	var fraction: Dictionary = _tick(game, -0.5, 3.0)
	proof["negative_fraction_defaults_to_size"] = is_equal_approx(float(fraction.get("drill_effect_rnd", -99.0)), 3.0)

	# Zero is not negative, so it is kept as-is.
	var zero: Dictionary = _tick(game, 0.0, 2.0)
	proof["zero_rnd_kept"] = is_equal_approx(float(zero.get("drill_effect_rnd", -99.0)), 0.0)

	# A positive value is kept as-is.
	var positive: Dictionary = _tick(game, 4.0, 2.0)
	proof["positive_rnd_kept"] = is_equal_approx(float(positive.get("drill_effect_rnd", -99.0)), 4.0)

	# The result carries ONLY its own key.
	proof["returns_only_expected_keys"] = defaulted.size() == 1 and fraction.size() == 1 and zero.size() == 1 and positive.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DrillInitProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
