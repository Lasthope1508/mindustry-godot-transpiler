extends Node

const main_scene := preload("res://scenes/Main.tscn")
const state := preload("res://src/game/SourceWeaponsCoreState.gd")
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

	# --- Weapon side-flip field defaults (N2543, trimmed at merge):
	# `otherSide = -1` (Weapon.java:125), `alternate = true`
	# (:43), `flipSprite = false` (:41), `side`
	# (WeaponMount.java:40, Java boolean default false). The
	# leg itself is owned by N856 (flip body) + N870
	# (`lastReload`); `reload = 1` is already claimed by
	# N2534 + N2535. This slice keeps the number N2543 with
	# the comment + 4 field decls (N2440 precedent, N2542
	# trim precedent).
	var defaults: Dictionary = state.source_weapon_side_flip_defaults_state()
	proof["defaults_other_side"] = int(defaults.get("other_side", 0)) == -1
	proof["defaults_alternate"] = bool(defaults.get("alternate", false)) == true
	proof["defaults_flip_sprite"] = bool(defaults.get("flip_sprite", true)) == false
	proof["defaults_side"] = bool(defaults.get("side", true)) == false

	# The result carries ONLY its own keys (4).
	proof["returns_only_expected_keys"] = defaults.size() == 4

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WeaponSideFlipDefaultsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
