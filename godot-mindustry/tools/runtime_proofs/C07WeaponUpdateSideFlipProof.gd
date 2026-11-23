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

	# --- Weapon.update() leg 4 (N2543): side-flip for
	# alternating weapons (Weapon.java:418-423).
	# `//flip weapon shoot side for alternating weapons` /
	# `boolean wasFlipped = mount.side;` /
	# `if(otherSide >= 0 && alternate && mount.side == flipSprite && otherSide < unit.mounts.length && mount.reload <= reload / 2f && lastReload > reload / 2f){` /
	# `unit.mounts[otherSide].side = !unit.mounts[otherSide].side;` /
	# `mount.side = !mount.side;` /
	# `}`.
	# Defaults unless noted: otherSide 1, alternate true,
	# mount_side false, flip_sprite false, other_mount_side
	# false, mounts_count 2, mount_reload 10.0, weapon_reload
	# 60.0 (half 30.0), last_reload 40.0. The proof drives
	# the pure function through the Weapon facade on exact
	# legs; each key asserts the full triple
	# (mount_side, other_side_side, was_flipped):

	# Phase 1: flip: guard passes (1 >= 0, alternate,
	# false == false, 1 < 2, 10 <= 30, 40 > 30) -> both
	# sides flip false -> true, was_flipped false (the
	# pre-flip mount side).
	var side_flip_state: Dictionary = weapons_state.source_weapon_update_side_flip_state(1, true, false, false, false, 2, 10.0, 60.0, 40.0)
	proof["flip"] = bool(side_flip_state.get("mount_side", false)) == true and bool(side_flip_state.get("other_side_side", false)) == true and bool(side_flip_state.get("was_flipped", true)) == false

	# Phase 2: no flip when reload has not crossed half:
	# mount_reload 40.0, last_reload 50.0, both above half
	# 30.0 -> sides unchanged, was_flipped false.
	side_flip_state = weapons_state.source_weapon_update_side_flip_state(1, true, false, false, false, 2, 40.0, 60.0, 50.0)
	proof["no_flip_reload_not_crossed"] = bool(side_flip_state.get("mount_side", true)) == false and bool(side_flip_state.get("other_side_side", true)) == false and bool(side_flip_state.get("was_flipped", true)) == false

	# Phase 3: boundary: last_reload exactly at half
	# (30.0 == 30.0) fails the STRICT > check -> no flip,
	# even though mount_reload 30.0 <= half passes <=.
	side_flip_state = weapons_state.source_weapon_update_side_flip_state(1, true, false, false, false, 2, 30.0, 60.0, 30.0)
	proof["no_flip_last_reload_at_half"] = bool(side_flip_state.get("mount_side", true)) == false and bool(side_flip_state.get("other_side_side", true)) == false and bool(side_flip_state.get("was_flipped", true)) == false

	# Phase 4: no flip when mount side mismatches
	# flipSprite: mount_side true, flip_sprite false ->
	# guard fails, was_flipped true (the pre-flip side).
	side_flip_state = weapons_state.source_weapon_update_side_flip_state(1, true, true, false, false, 2, 10.0, 60.0, 40.0)
	proof["no_flip_side_mismatch"] = bool(side_flip_state.get("mount_side", false)) == true and bool(side_flip_state.get("other_side_side", true)) == false and bool(side_flip_state.get("was_flipped", false)) == true

	# Phase 5: no flip when otherSide is -1 (no mirror
	# mount).
	side_flip_state = weapons_state.source_weapon_update_side_flip_state(-1, true, false, false, false, 2, 10.0, 60.0, 40.0)
	proof["no_flip_other_side_negative"] = bool(side_flip_state.get("mount_side", true)) == false and bool(side_flip_state.get("other_side_side", true)) == false and bool(side_flip_state.get("was_flipped", true)) == false

	# Phase 6: no flip when otherSide is out of range:
	# other_side 2, mounts_count 2 -> 2 < 2 fails.
	side_flip_state = weapons_state.source_weapon_update_side_flip_state(2, true, false, false, false, 2, 10.0, 60.0, 40.0)
	proof["no_flip_other_side_out_of_range"] = bool(side_flip_state.get("mount_side", true)) == false and bool(side_flip_state.get("other_side_side", true)) == false and bool(side_flip_state.get("was_flipped", true)) == false

	# Phase 7: no flip when alternate is false.
	side_flip_state = weapons_state.source_weapon_update_side_flip_state(1, false, false, false, false, 2, 10.0, 60.0, 40.0)
	proof["no_flip_alternate_false"] = bool(side_flip_state.get("mount_side", true)) == false and bool(side_flip_state.get("other_side_side", true)) == false and bool(side_flip_state.get("was_flipped", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WeaponUpdateSideFlipProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
