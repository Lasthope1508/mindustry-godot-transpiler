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

	# --- Weapon draw() (N2538): `public void draw(Unit unit, WeaponMount mount){` /
	# `float z = Draw.z();` /
	# `Draw.z(z + layerOffset);` /
	# `rotation = unit.rotation - 90,` /
	# `realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil,` /
	# `weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),` /
	# `wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),` /
	# `wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);` /
	# `if(shadow > 0){` / `Drawf.shadow(wx, wy, shadow);` /
	# `if(top){` / `drawOutline(unit, mount);` /
	# `if(parts.size > 0){` /
	# `Draw.xscl *= -Mathf.sign(flipSprite);` /
	# `if(region.found()) Draw.rect(region, wx, wy, weaponRotation);` /
	# `if(cellRegion.found()){` /
	# `if(heatRegion.found() && mount.heat > 0){` /
	# `Draw.z(z);`
	# (Weapon.java:214-286). draw() has NO early return (unlike
	# drawOutline): every branch returns all thirteen keys.
	# `z_draw` is z + layerOffset; `shadow_drawn` is shadow > 0;
	# `outline_called` is top; `has_parts` is parts_count > 0;
	# `region_drawn` is region_found; `cell_drawn` is
	# cell_region_found; `heat_drawn` is heat_region_found AND
	# mount_heat > 0. The proof drives the pure function through
	# the Weapon facade on exact legs (all with Java defaults
	# unless noted: z 0, unit_rotation 90, unit 0,0,
	# mount_recoil 0, mount_rotation 0, rotate false,
	# base_rotation 0, recoil 1.5, recoil_pow 1.8, weapon x 5,
	# y 0, flip_sprite false, shadow -1, top true,
	# region_found true, cell_region_found false,
	# heat_region_found false, mount_heat 0, layer_offset 0,
	# parts_count 0):
	# 1 Java defaults -> rotation 0.0, real_recoil 0.0,
	# weapon_rotation 0.0, wx 5.0, wy 0.0, xscl 1.0,
	# z_draw 0.0, shadow_drawn false, outline_called true,
	# has_parts false, region_drawn true, cell_drawn false,
	# heat_drawn false; 2 shadow 10 -> shadow_drawn true;
	# 3 top false -> outline_called false; 4 region not
	# found -> region_drawn false; 5 cell_region_found true
	# -> cell_drawn true; 6 heat_region_found true,
	# mount_heat 0 -> heat_drawn false; 7
	# heat_region_found true, mount_heat 0.5 ->
	# heat_drawn true; 8 unit_rotation 180 -> rotation
	# 90.0, wx 0.0, wy 5.0, weapon_rotation 90.0.

	# Phase 1: Java defaults -> rotation 0.0, real_recoil 0.0, weapon_rotation 0.0, wx 5.0, wy 0.0, xscl 1.0, z_draw 0.0, shadow_drawn false, outline_called true, has_parts false, region_drawn true, cell_drawn false, heat_drawn false.
	var draw: Dictionary = weapons_state.source_weapon_draw_state(0.0, 90.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, 1.5, 1.8, 5.0, 0.0, false, -1.0, true, true, false, false, 0.0, 0.0, 0)
	proof["draw_java_defaults"] = is_equal_approx(float(draw.get("rotation", -1.0)), 0.0) and is_equal_approx(float(draw.get("real_recoil", -1.0)), 0.0) and is_equal_approx(float(draw.get("weapon_rotation", -1.0)), 0.0) and is_equal_approx(float(draw.get("wx", -1.0)), 5.0) and is_equal_approx(float(draw.get("wy", -1.0)), 0.0) and is_equal_approx(float(draw.get("xscl", 0.0)), 1.0) and is_equal_approx(float(draw.get("z_draw", -1.0)), 0.0) and not bool(draw.get("shadow_drawn", true)) and bool(draw.get("outline_called", false)) and not bool(draw.get("has_parts", true)) and bool(draw.get("region_drawn", false)) and not bool(draw.get("cell_drawn", true)) and not bool(draw.get("heat_drawn", true))

	# Phase 2: shadow 10 -> shadow_drawn true, wx 5.0, wy 0.0.
	draw = weapons_state.source_weapon_draw_state(0.0, 90.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, 1.5, 1.8, 5.0, 0.0, false, 10.0, true, true, false, false, 0.0, 0.0, 0)
	proof["draw_shadow"] = bool(draw.get("shadow_drawn", false)) and is_equal_approx(float(draw.get("wx", -1.0)), 5.0) and is_equal_approx(float(draw.get("wy", -1.0)), 0.0)

	# Phase 3: top false -> outline_called false.
	draw = weapons_state.source_weapon_draw_state(0.0, 90.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, 1.5, 1.8, 5.0, 0.0, false, -1.0, false, true, false, false, 0.0, 0.0, 0)
	proof["draw_top_false"] = not bool(draw.get("outline_called", true))

	# Phase 4: region not found -> region_drawn false (geometry still computed: wx 5.0, wy 0.0).
	draw = weapons_state.source_weapon_draw_state(0.0, 90.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, 1.5, 1.8, 5.0, 0.0, false, -1.0, true, false, false, false, 0.0, 0.0, 0)
	proof["draw_region_not_found"] = not bool(draw.get("region_drawn", true)) and is_equal_approx(float(draw.get("wx", -1.0)), 5.0) and is_equal_approx(float(draw.get("wy", -1.0)), 0.0)

	# Phase 5: cell_region_found true -> cell_drawn true.
	draw = weapons_state.source_weapon_draw_state(0.0, 90.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, 1.5, 1.8, 5.0, 0.0, false, -1.0, true, true, true, false, 0.0, 0.0, 0)
	proof["draw_cell"] = bool(draw.get("cell_drawn", false))

	# Phase 6: heat_region_found true, mount_heat 0 -> heat_drawn false.
	draw = weapons_state.source_weapon_draw_state(0.0, 90.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, 1.5, 1.8, 5.0, 0.0, false, -1.0, true, true, false, true, 0.0, 0.0, 0)
	proof["draw_heat_zero"] = not bool(draw.get("heat_drawn", true))

	# Phase 7: heat_region_found true, mount_heat 0.5 -> heat_drawn true.
	draw = weapons_state.source_weapon_draw_state(0.0, 90.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, 1.5, 1.8, 5.0, 0.0, false, -1.0, true, true, false, true, 0.5, 0.0, 0)
	proof["draw_heat_positive"] = bool(draw.get("heat_drawn", false))

	# Phase 8: unit_rotation 180 -> rotation 90, wx 0.0, wy 5.0, weapon_rotation 90.0.
	draw = weapons_state.source_weapon_draw_state(0.0, 180.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, 1.5, 1.8, 5.0, 0.0, false, -1.0, true, true, false, false, 0.0, 0.0, 0)
	proof["draw_unit_rot_180"] = is_equal_approx(float(draw.get("rotation", -1.0)), 90.0) and is_equal_approx(float(draw.get("wx", -1.0)), 0.0) and is_equal_approx(float(draw.get("wy", -1.0)), 5.0) and is_equal_approx(float(draw.get("weapon_rotation", -1.0)), 90.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WeaponDrawProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
