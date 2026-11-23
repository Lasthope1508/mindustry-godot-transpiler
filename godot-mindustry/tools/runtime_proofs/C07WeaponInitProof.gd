extends Node

const main_scene := preload("res://scenes/Main.tscn")
const weapons_state := preload("res://src/game/SourceWeaponsState.gd")
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

	# --- Weapon.init() (N2544): always-continuous implies
	# continuous (Weapon.java:561-566).
	# `@CallSuper` /
	# `public void init(){` /
	# `if(alwaysContinuous){` /
	# `continuous = true;` /
	# `}`.
	# Defaults unless noted: always_continuous false,
	# continuous false. The proof drives the pure function
	# through the Weapon facade on exact legs; each key
	# asserts the single return key `continuous`:

	# Phase 1: sets_continuous: always_continuous true,
	# continuous false -> continuous true.
	var init_state: Dictionary = weapons_state.source_weapon_init_state(true, false)
	proof["sets_continuous"] = bool(init_state.get("continuous", false)) == true

	# Phase 2: keeps_continuous_true: always_continuous
	# true, continuous true -> continuous stays true.
	init_state = weapons_state.source_weapon_init_state(true, true)
	proof["keeps_continuous_true"] = bool(init_state.get("continuous", false)) == true

	# Phase 3: keeps_continuous_false: always_continuous
	# false, continuous false -> continuous stays false.
	init_state = weapons_state.source_weapon_init_state(false, false)
	proof["keeps_continuous_false"] = bool(init_state.get("continuous", true)) == false

	# Phase 4: keeps_continuous_true_when_not_always:
	# always_continuous false, continuous true -> the
	# current true value is kept, not cleared.
	init_state = weapons_state.source_weapon_init_state(false, true)
	proof["keeps_continuous_true_when_not_always"] = bool(init_state.get("continuous", false)) == true

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WeaponInitProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
