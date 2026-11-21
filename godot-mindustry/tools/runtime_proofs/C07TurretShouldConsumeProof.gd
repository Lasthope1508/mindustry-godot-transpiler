extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
const efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
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

	# --- Turret shouldConsume() gate (N2524):
	# `public boolean shouldConsume(){` /
	# `return isShooting || reloadCounter < reload; }`
	# (Turret.java:364-366), the one-line predicate on the
	# turret build's own two fields. Both inputs are already
	# live on the frame: `isShooting` (Turret.java:492, ported
	# N2277 -- the tick stamps `frame["is_shooting"]` in the
	# duo branch) and `reloadCounter` (ReloadTurret.java:26,
	# ported N2240 -- the aim call stamps
	# `frame["reload_counter"]` in the duo branch). The driver
	# tick's consumption branch ran the machinery with
	# should_consume=true whenever enabled; this slice ports
	# the predicate as a pure function and wires it into the
	# consumption branch, so a power turret stops consuming
	# when it is neither shooting nor reloading. Java order is
	# updateConsumption() BEFORE updateTile()
	# (BuildingComp.java:2274 vs :2277), so the gate reads the
	# PREVIOUS tick's frame values (the N2270 heat fold
	# precedent). When the gate is false,
	# update_consumption_setup_state returns `update =
	# should_consume and production_valid`
	# (SourceBuildingEfficiencyState.gd:106-107) and
	# update_consumption_efficiency_state folds
	# `efficiency = 0.0` (:127-134) -- exactly Java
	# (BuildingComp.java:1947, `efficiency = ...
	# shouldConsume() ? potentialEfficiency : 0f;`).
	# `reload` is per def, read from the catalog
	# (`block.properties`, the N2270 precedent), class
	# default 10f (ReloadTurret.java:10); lancer reads 80f
	# (Blocks.java). LIVE CONSEQUENCE: the gate is DORMANT
	# live today -- duo has no consumePower so the branch
	# never runs for duo, and the six power defs have no
	# aim/shoot branch stamping the two frame keys, so the
	# gate reads the absent defaults (false / 0.0 < reload)
	# and stays true on every live frame.

	# The direct pure-function calls pin the predicate on a
	# lancer frame (reload 80f): shooting -> true, reloading
	# (reload_counter < reload) -> true, idle + reloaded
	# (reload_counter == reload, not shooting) -> false.
	var shooting: Dictionary = turret_build_state.source_turret_should_consume_state({"enabled": true, "is_shooting": true, "reload_counter": 80.0}, 80.0)
	var reloading: Dictionary = turret_build_state.source_turret_should_consume_state({"enabled": true, "is_shooting": false, "reload_counter": 40.0}, 80.0)
	var idle_reloaded: Dictionary = turret_build_state.source_turret_should_consume_state({"enabled": true, "is_shooting": false, "reload_counter": 80.0}, 80.0)
	proof["should_consume_shooting"] = bool(shooting.get("should_consume", false)) == true
	proof["should_consume_reloading"] = bool(reloading.get("should_consume", false)) == true
	proof["should_consume_idle_reloaded"] = bool(idle_reloaded.get("should_consume", true)) == false

	# The efficiency fold composes the gate with the exact
	# downstream calls the tick makes: gate false -> setup
	# update false -> the full consumption state folds
	# efficiency to 0.0 (the power row is 1.0, so only the
	# gate can zero it); gate true -> efficiency kept at 1.0.
	var setup_false: Dictionary = efficiency_state.update_consumption_setup_state(bool(idle_reloaded.get("should_consume", true)), true)
	var fold_zero: Dictionary = efficiency_state.update_consumption_efficiency_state(1.0, 1.0, bool(setup_false.get("update", true)))
	var full_zero: Dictionary = efficiency_state.update_consumption_state(true, false, true, true, bool(idle_reloaded.get("should_consume", true)), 1.0, [{"result": 1.0, "is_power": true}], [], [], {})
	proof["should_consume_efficiency_fold_zero"] = float(fold_zero.get("efficiency", -1.0)) == 0.0 and float(full_zero.get("efficiency", -1.0)) == 0.0
	var setup_true: Dictionary = efficiency_state.update_consumption_setup_state(bool(reloading.get("should_consume", false)), true)
	var fold_kept: Dictionary = efficiency_state.update_consumption_efficiency_state(1.0, 1.0, bool(setup_true.get("update", false)))
	var full_kept: Dictionary = efficiency_state.update_consumption_state(true, false, true, true, bool(reloading.get("should_consume", false)), 1.0, [{"result": 1.0, "is_power": true}], [], [], {})

	# One lancer segment, live on the driver: the consumption
	# branch runs for a power turret, and the gate reads the
	# absent defaults (is_shooting false, reload_counter 0.0
	# < 80) so it stays true -- the live frame keeps
	# efficiency 1.0 after a single tick, proving the call
	# site runs inside the real tick, not just the pure
	# function.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cell := Vector2i(28, 21)
	var segment := Sprite2D.new()
	game.add_child(segment)
	game.call("record_placed_block", segment, blocks_by_id["lancer"], cell)
	# The raw Sprite2D node never passes through the texture
	# path (SourceTextureRuntimeState.configure_block_sprite),
	# which is what assigns a placed block its world position
	# (`sprite.position = game.source_block_sprite_base_position(block, cell)`),
	# so without this the segment sits at the origin (0, 0)
	# and the turret-centred query cannot be distinguished
	# from an origin-centred one. Seed the position exactly
	# the way the game does (the N2211 proof lesson).
	segment.position = game.source_block_sprite_base_position(blocks_by_id["lancer"], cell)
	turret_build_state.source_turret_bind_frame_state(segment, blocks_by_id["lancer"])

	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	var frame: Dictionary = segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	proof["should_consume_efficiency_kept"] = float(fold_kept.get("efficiency", -1.0)) == 1.0 and float(full_kept.get("efficiency", -1.0)) == 1.0 and float(frame.get("efficiency", -1.0)) == 1.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
