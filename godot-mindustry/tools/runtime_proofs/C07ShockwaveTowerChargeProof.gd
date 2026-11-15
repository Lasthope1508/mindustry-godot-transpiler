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

	# --- Pure charge (N2192): ShockwaveTowerBuild.updateTile
	# charges its reload counter by edelta() when it has
	# potential efficiency (ShockwaveTower.java:73,
	# `if(potentialEfficiency > 0 && (reloadCounter += edelta())
	# >= reload && timer(timerCheck, checkInterval)){`), and
	# edelta() is efficiency * delta (BuildingComp.java:1927-1929,
	# `return efficiency * delta();`). The gate reads the
	# potentialEfficiency stamped by THIS tick's updateConsumption
	# (BuildingComp.java:1989, `potentialEfficiency =
	# efficiency;`); the increment reads the stamped efficiency.
	# An absent `reload_counter` key starts from deterministic
	# 0.0 -- Java inits `reloadCounter = Mathf.random(reload);`
	# (ShockwaveTower.java:67), but the port takes the
	# deterministic 0.0 start, the N2190 precedent, never `randf`
	# in game code. There is NO clamp at reload: Java keeps
	# accumulating past reload until a successful fire resets the
	# counter to 0 (ShockwaveTower.java:83, `reloadCounter =
	# 0f;`), so a counter past reload stays, with no reset
	# without fire. The per-def reload is 80f (Blocks.java:2044).
	var full: Dictionary = shockwave_tower_build_state.source_shockwave_tower_charge_state({"reload_counter": 10.0, "potential_efficiency": 1.0, "efficiency": 1.0}, 1.0 / 60.0)
	proof["charge_advances_at_full_efficiency"] = is_equal_approx(float(full.get("reload_counter", -1.0)), 10.0 + 1.0 / 60.0)

	var frozen: Dictionary = shockwave_tower_build_state.source_shockwave_tower_charge_state({"reload_counter": 10.0, "potential_efficiency": 0.0, "efficiency": 0.0}, 1.0 / 60.0)
	proof["charge_frozen_without_power"] = is_equal_approx(float(frozen.get("reload_counter", -1.0)), 10.0)

	var partial: Dictionary = shockwave_tower_build_state.source_shockwave_tower_charge_state({"reload_counter": 10.0, "potential_efficiency": 0.5, "efficiency": 0.5}, 1.0 / 60.0)
	proof["charge_scales_with_partial_efficiency"] = is_equal_approx(float(partial.get("reload_counter", -1.0)), 10.0 + 0.5 / 60.0)

	# Past reload, no clamp, no reset: 79.0 + 1.0 * 2.0 = 81.0,
	# past the per-def reload 80f, and the counter stays 81.0
	# -- the fire reset (ShockwaveTower.java:83) is NOT this
	# slice, so no reset happens here.
	var past: Dictionary = shockwave_tower_build_state.source_shockwave_tower_charge_state({"reload_counter": 79.0, "potential_efficiency": 1.0, "efficiency": 1.0}, 2.0)
	proof["charge_accumulates_past_reload_without_fire"] = is_equal_approx(float(past.get("reload_counter", -1.0)), 81.0)

	# Absent counter starts zero: NO reload_counter key, full
	# efficiency, one 1/60s tick -- the counter is 0.0 + 1/60.
	var absent: Dictionary = shockwave_tower_build_state.source_shockwave_tower_charge_state({"potential_efficiency": 1.0, "efficiency": 1.0}, 1.0 / 60.0)
	proof["charge_absent_counter_starts_zero"] = is_equal_approx(float(absent.get("reload_counter", -1.0)), 1.0 / 60.0)

	# --- Live tick: the shockwave tower is a ShockwaveTower build
	# with a static power consumer (shockwave-tower,
	# consumePower 100f / 60f, Blocks.java:2042), placed live; the tick
	# driver is called directly (as the N2177/N2191 proofs do),
	# not simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is already
	# proven by N2142. The driver calls the pure charge AFTER
	# apply_update_consumption_state (the N2190 driver convention,
	# passing the tick's `seconds` as the delta) and stamps the
	# frame key `reload_counter`.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var shockwave_tower_cell := Vector2i(28, 21)
	var shockwave_tower := Sprite2D.new()
	game.add_child(shockwave_tower)
	game.call("record_placed_block", shockwave_tower, blocks_by_id["shockwave-tower"], shockwave_tower_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	shockwave_tower_build_state.source_shockwave_tower_bind_frame_state(shockwave_tower, blocks_by_id["shockwave-tower"])
	var shockwave_tower_frame: Dictionary = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})

	# Full power, counter 10.0, one 1/60s tick -- the driver
	# stamps efficiency 1.0, then the charge adds 1.0 * 1/60.
	shockwave_tower_frame["power_status"] = 1.0
	shockwave_tower_frame["reload_counter"] = 10.0
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	proof["charge_driver_stamps_counter"] = is_equal_approx(float(shockwave_tower_frame.get("reload_counter", -1.0)), 10.0 + 1.0 / 60.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerChargeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
