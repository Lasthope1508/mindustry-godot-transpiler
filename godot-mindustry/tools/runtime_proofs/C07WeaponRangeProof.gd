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

	# --- Weapon range() (N2539): `public float range(){` /
	# `return bullet.range;` /
	# `}` (Weapon.java:288-290). `bullet` is the weapon bullet
	# type (`public BulletType bullet = Bullets.placeholder;`,
	# Weapon.java:33); `bullet.range` is the BulletType range
	# field (`public float range = 0f;`, BulletType.java:161),
	# computed by calculateRange() at init
	# (BulletType.java:854) and afterPatch
	# (BulletType.java:402) -- calculateRange() itself is
	# already ported (SourceBulletTypeInitRangeState.gd), so
	# this slice takes the catalog `bullet.range` as its one
	# input and returns it unchanged. The proof drives the
	# pure function through the Weapon facade on exact legs
	# (bullet_range is the catalog BulletType.range value):
	# 1 zero -> range 0.0 (BulletType.range field default,
	# BulletType.java:161); 2 placeholder 150.0 -> range
	# 150.0 (Bullets.placeholder is BasicBulletType(2.5f, 9,
	# "ohno") with lifetime 60f, so calculateRange() gives
	# speed * lifetime = 2.5 * 60 = 150, drag 0f, maxRange
	# -1f); 3 fractional 37.5 -> range 37.5; 4 large 1000.0
	# -> range 1000.0.

	# Phase 1: zero -> range 0.0.
	var range_state: Dictionary = weapons_state.source_weapon_range_state(0.0)
	proof["range_zero"] = is_equal_approx(float(range_state.get("range", -1.0)), 0.0)

	# Phase 2: placeholder 150.0 -> range 150.0.
	range_state = weapons_state.source_weapon_range_state(150.0)
	proof["range_placeholder"] = is_equal_approx(float(range_state.get("range", -1.0)), 150.0)

	# Phase 3: fractional 37.5 -> range 37.5.
	range_state = weapons_state.source_weapon_range_state(37.5)
	proof["range_fractional"] = is_equal_approx(float(range_state.get("range", -1.0)), 37.5)

	# Phase 4: large 1000.0 -> range 1000.0.
	range_state = weapons_state.source_weapon_range_state(1000.0)
	proof["range_large"] = is_equal_approx(float(range_state.get("range", -1.0)), 1000.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WeaponRangeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
