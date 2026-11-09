extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceContinuousLiquidTurretBuildState.gd")
const consume_state := preload("res://src/game/SourceConsumeState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_state := preload("res://src/game/SourcePlacedBlockState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var turret_impl: String = String(blocks_by_id["sublimate"].implementation)
	proof["turret_is_continuous_liquid_turret"] = turret_impl == "ContinuousLiquidTurret"

	# Sublimate's ammo map (Blocks.java:4604-4631): ozone fires a
	# ContinuousFlameBulletType with ammoMultiplier = 1.2f
	# (Blocks.java:4608); cyanogen fires one with no ammoMultiplier set,
	# so it keeps the BulletType default 2f (BulletType.java:95).
	var sublimate_ammo: Dictionary = {"ozone": {"ammoMultiplier": 1.2}, "cyanogen": {"ammoMultiplier": 2.0}}

	# Content liquid names indexed by liquid id (Java resolves a liquid
	# by id through content.liquid(id); LiquidModule.java:24 seeds the
	# module's current with content.liquid(0), the first liquid).
	var liquid_names_by_id: Array = []
	for liquid in catalog.get_many("liquid"):
		liquid_names_by_id.append(String(liquid.id))
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog["liquid_id_by_name"]
	var ozone_id: int = int(liquid_id_by_name.get("ozone", -1))
	var cyanogen_id: int = int(liquid_id_by_name.get("cyanogen", -1))
	var water_id: int = int(liquid_id_by_name.get("water", -1))

	# --- the turret is placed live on the real Main scene. ---
	var turret_cell := Vector2i(30, 7)
	var turret := Sprite2D.new()
	game.add_child(turret)
	game.call("record_placed_block", turret, blocks_by_id["sublimate"], turret_cell)
	proof["turret_placed_live_sprite"] = turret != null and str(turret.get_meta("source_block_id", "")) == "sublimate"
	var turret_tile: Dictionary = game.call("source_world_tile", turret_cell.x, turret_cell.y)
	proof["turret_tile_build_is_sprite"] = turret_tile.get("build") == turret and turret_tile.get("block") == blocks_by_id["sublimate"]
	proof["turret_module_attached"] = turret.has_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY)
	var module: Dictionary = turret.get_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var frame: Dictionary = {}

	# --- the tick wires the frame keys from the live liquid module:
	# a fresh module's current is the first liquid (water,
	# Liquids.java:7; LiquidModule.java:24), which has no ammo type,
	# so the turret pays the 1.0 default. ---
	var wired: Dictionary = turret_build_state.source_tick_frame_state(frame, turret_impl, module, liquid_names_by_id, sublimate_ammo)
	proof["tick_frame_fresh_current"] = str(wired.get("current_liquid", "")) == str(liquid_names_by_id[int(module.get("current", -1))])
	proof["tick_frame_keys"] = str(wired.get("block_implementation", "")) == "ContinuousLiquidTurret" and wired.get("ammo_types", {}) == sublimate_ammo
	proof["tick_frame_fresh_multiplier"] = is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(wired).get("multiplier", -1.0)), 1.0)

	# --- ozone reaches the turret: the tick refreshes the frame and
	# the multiplier is actually paid live, 1 / 1.2. ---
	liquid_module_state.source_add_state(module, ozone_id, 5.0, [])
	wired = turret_build_state.source_tick_frame_state(frame, turret_impl, module, liquid_names_by_id, sublimate_ammo)
	proof["tick_frame_ozone"] = str(wired.get("current_liquid", "")) == "ozone"
	proof["tick_frame_ozone_multiplier"] = is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(wired).get("multiplier", -1.0)), 1.0 / 1.2)

	# --- cyanogen pays 1 / 2, water (no ammo type) pays 1.0. ---
	liquid_module_state.source_add_state(module, cyanogen_id, 5.0, [])
	wired = turret_build_state.source_tick_frame_state(frame, turret_impl, module, liquid_names_by_id, sublimate_ammo)
	proof["tick_frame_cyanogen"] = str(wired.get("current_liquid", "")) == "cyanogen"
	proof["tick_frame_cyanogen_multiplier"] = is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(wired).get("multiplier", -1.0)), 0.5)
	liquid_module_state.source_add_state(module, water_id, 5.0, [])
	wired = turret_build_state.source_tick_frame_state(frame, turret_impl, module, liquid_names_by_id, sublimate_ammo)
	proof["tick_frame_water"] = str(wired.get("current_liquid", "")) == "water"
	proof["tick_frame_water_multiplier"] = is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(wired).get("multiplier", -1.0)), 1.0)

	# --- the keys refresh, they do not go stale: ozone again pays
	# 1 / 1.2 after water. ---
	liquid_module_state.source_add_state(module, ozone_id, 5.0, [])
	wired = turret_build_state.source_tick_frame_state(frame, turret_impl, module, liquid_names_by_id, sublimate_ammo)
	proof["tick_frame_refresh_ozone"] = str(wired.get("current_liquid", "")) == "ozone" and is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(wired).get("multiplier", -1.0)), 1.0 / 1.2)

	# --- a module without a current id, or an id with no content
	# name, leaves current_liquid null and pays the 1.0 default. ---
	var no_current: Dictionary = turret_build_state.source_tick_frame_state({}, turret_impl, {}, liquid_names_by_id, sublimate_ammo)
	proof["tick_frame_no_current"] = no_current.get("current_liquid", "set") == null and is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(no_current).get("multiplier", -1.0)), 1.0)
	var unknown_id: Dictionary = turret_build_state.source_tick_frame_state({}, turret_impl, {"current": 9999}, liquid_names_by_id, sublimate_ammo)
	proof["tick_frame_unknown_id"] = unknown_id.get("current_liquid", "set") == null and is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(unknown_id).get("multiplier", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("ContinuousLiquidTurretTickFrameProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
