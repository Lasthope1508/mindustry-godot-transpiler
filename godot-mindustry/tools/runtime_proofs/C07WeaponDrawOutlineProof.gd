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

	# --- Weapon drawOutline() (N2537): `public void drawOutline(Unit unit, WeaponMount mount){` /
	# `if(!outlineRegion.found()) return;` /
	# `rotation = unit.rotation - 90,` /
	# `realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil,` /
	# `weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),` /
	# `wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),` /
	# `wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);` /
	# `Draw.xscl = -Mathf.sign(flipSprite);` /
	# `Draw.rect(outlineRegion, wx, wy, weaponRotation);`
	# (Weapon.java:196-213). `outline_found` is a bool param
	# (the guard is first in Java; the draw_team_top_state
	# precedent returns `{"visible": false}` when the region
	# is not found). `xscl` is -Mathf.sign(flipSprite); arc
	# Mathf.sign(boolean) is 1 if true else -1, so xscl is
	# -1.0 when flip_sprite is true and +1.0 otherwise.
	# The proof drives the pure function through the Weapon
	# facade on exact legs (all with Java defaults unless
	# noted: unit_rotation 90, unit 0,0, mount_recoil 0,
	# mount_rotation 0, rotate false, base_rotation 0,
	# recoil 1.5, recoil_pow 1.8, weapon x 5, y 0,
	# flip_sprite false, outline_found true):
	# 1 Java defaults -> wx 5.0, wy 0.0, weapon_rotation
	# 0.0, xscl 1.0, visible true; 2 outline not found ->
	# visible false; 3 flip_sprite true -> xscl -1.0;
	# 4 rotate true, mount_rotation 30 -> weapon_rotation
	# 30.0; 5 mount_recoil 1.0 -> realRecoil 1.5, wy -1.5;
	# 6 unit_rotation 180 -> wx 0.0, wy 5.0; 7 rotate
	# false, base_rotation 45 -> weapon_rotation 45.0;
	# 8 fractional unit_rotation 45 -> wx ~3.5355,
	# wy ~-3.5355.

	# Phase 1: Java defaults -> wx 5.0, wy 0.0, weapon_rotation 0.0, xscl 1.0, visible true.
	var outline: Dictionary = weapons_state.source_weapon_draw_outline_state(true, 90.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, 1.5, 1.8, 5.0, 0.0, false)
	proof["outline_java_defaults"] = bool(outline.get("visible", false)) and is_equal_approx(float(outline.get("outline_x", -1.0)), 5.0) and is_equal_approx(float(outline.get("outline_y", -1.0)), 0.0) and is_equal_approx(float(outline.get("weapon_rotation", -1.0)), 0.0) and is_equal_approx(float(outline.get("xscl", 0.0)), 1.0)

	# Phase 2: outline not found -> visible false.
	outline = weapons_state.source_weapon_draw_outline_state(false, 90.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, 1.5, 1.8, 5.0, 0.0, false)
	proof["outline_not_found"] = not bool(outline.get("visible", true))

	# Phase 3: flip_sprite true -> xscl -1.0, wx 5.0, wy 0.0.
	outline = weapons_state.source_weapon_draw_outline_state(true, 90.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, 1.5, 1.8, 5.0, 0.0, true)
	proof["outline_flip_sprite"] = bool(outline.get("visible", false)) and is_equal_approx(float(outline.get("xscl", 0.0)), -1.0) and is_equal_approx(float(outline.get("outline_x", -1.0)), 5.0) and is_equal_approx(float(outline.get("outline_y", -1.0)), 0.0)

	# Phase 4: rotate true, mount_rotation 30 -> weapon_rotation 30.0, wx 5.0, wy 0.0.
	outline = weapons_state.source_weapon_draw_outline_state(true, 90.0, 0.0, 0.0, 0.0, 30.0, true, 0.0, 1.5, 1.8, 5.0, 0.0, false)
	proof["outline_rotate_mount"] = is_equal_approx(float(outline.get("weapon_rotation", -1.0)), 30.0) and is_equal_approx(float(outline.get("outline_x", -1.0)), 5.0) and is_equal_approx(float(outline.get("outline_y", -1.0)), 0.0)

	# Phase 5: mount_recoil 1.0 -> realRecoil 1.5, wx 5.0, wy -1.5.
	outline = weapons_state.source_weapon_draw_outline_state(true, 90.0, 0.0, 0.0, 1.0, 0.0, false, 0.0, 1.5, 1.8, 5.0, 0.0, false)
	proof["outline_recoil"] = is_equal_approx(float(outline.get("outline_x", -1.0)), 5.0) and is_equal_approx(float(outline.get("outline_y", -1.0)), -1.5) and is_equal_approx(float(outline.get("weapon_rotation", -1.0)), 0.0)

	# Phase 6: unit_rotation 180 -> rotation 90, wx 0.0, wy 5.0.
	outline = weapons_state.source_weapon_draw_outline_state(true, 180.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, 1.5, 1.8, 5.0, 0.0, false)
	proof["outline_unit_rot_180"] = is_equal_approx(float(outline.get("outline_x", -1.0)), 0.0) and is_equal_approx(float(outline.get("outline_y", -1.0)), 5.0) and is_equal_approx(float(outline.get("weapon_rotation", -1.0)), 90.0)

	# Phase 7: rotate false, base_rotation 45 -> weapon_rotation 45.0, wx 5.0, wy 0.0.
	outline = weapons_state.source_weapon_draw_outline_state(true, 90.0, 0.0, 0.0, 0.0, 30.0, false, 45.0, 1.5, 1.8, 5.0, 0.0, false)
	proof["outline_base_rotation"] = is_equal_approx(float(outline.get("weapon_rotation", -1.0)), 45.0) and is_equal_approx(float(outline.get("outline_x", -1.0)), 5.0) and is_equal_approx(float(outline.get("outline_y", -1.0)), 0.0)

	# Phase 8: fractional unit_rotation 45 -> rotation -45, wx ~3.5355, wy ~-3.5355.
	outline = weapons_state.source_weapon_draw_outline_state(true, 45.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, 1.5, 1.8, 5.0, 0.0, false)
	proof["outline_fractional"] = is_equal_approx(float(outline.get("outline_x", -1.0)), 3.5355339) and is_equal_approx(float(outline.get("outline_y", -1.0)), -3.5355339) and is_equal_approx(float(outline.get("weapon_rotation", -1.0)), -45.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WeaponDrawOutlineProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
