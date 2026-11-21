extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
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

	# --- Turret ammo-items stamp (N2521): the live tick stamps
	# the item inventory into the frame, so the N2519-wired
	# dispatch `source_building_comp_sense_state` stops
	# reporting handled:false for the totalItems leg when a live
	# turret ticks (BuildingComp.sense() is `public double
	# sense(LAccess sensor){`, BuildingComp.java:2093-2126).
	# The tick is TurretBuild.updateTile() (`public void
	# updateTile(){`, Turret.java:490). The stamp writes exactly
	# two keys: `items_is_null` is `not has_items` -- only
	# ItemTurret has an item module (`if(block.hasItems) items
	# = new ItemModule();`, BuildingComp.java:145; `hasItems =
	# true;`, ItemTurret.java:28, the ONLY hasItems set among
	# the 5 ticked implementations); `items_total` is the
	# constant 0 -- the `items` module is NEVER written for an
	# ItemTurretBuild: `ItemTurretBuild.handleItem`
	# (ItemTurret.java:155-185) overrides
	# `BuildingComp.handleItem` (:860-862, `items.add(item,
	# 1);`) WITHOUT calling super, so it only updates
	# `totalAmmo` (`totalAmmo += type.ammoMultiplier;`, :168)
	# and the ammo-weighted `ammo` entries; `handleStack`
	# (:141-147) loops `handleItem` and `read()` restores
	# `ammo` + `totalAmmo`, never `items`. The module exists
	# but stays empty, so `items.total()` is 0 always (`case
	# totalItems -> items == null ? 0 : items.total();`,
	# :2107; `public int total(){`, ItemModule.java:174-176).
	# The port's `turret_ammo_stacks` are the Java `ammo` Seq
	# (ammo-weighted entries), NOT the `items` module -- summing
	# them would invent behavior (a duo with copper 5 +
	# graphite 3 stacks would read 8.0 while Java reads 0.0),
	# so the tick reads NO stacks dict for this stamp. The
	# stamp OVERWRITES any stale `items_total` already on the
	# frame. It does NOT touch the 4 graph keys, so the
	# dispatch keeps handled:false for powerNet* exactly as
	# N2519/N2520 left them. The proof calls the stamp directly
	# with synthetic has_items, then the dispatch, end to end.
	# Duo catalog values unless noted: solid true, size 1,
	# maxHealth 250, range 160, itemCapacity 10, hasLiquids
	# false, no consumePower, timeScale 1.0, not
	# player-controlled, payloadCount 0.

	var sharded := Color.html("ffd37f")

	# ItemTurret: the module exists but is empty (Java never
	# writes it), so totalItems reads 0.0 handled:true (`case
	# totalItems -> items == null ? 0 : items.total();`,
	# BuildingComp.java:2107).
	var item_frame: Dictionary = turret_build_state.source_turret_ammo_items_stamp_state({}, true)
	var total_items: Dictionary = turret_build_state.source_building_comp_sense_state(item_frame, "totalItems", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["stamp_item_turret_total_items_zero_num"] = bool(total_items.get("handled", false)) and is_equal_approx(float(total_items.get("sense_value", 1.0)), 0.0) and not bool(total_items.get("sense_value_is_nan", true))

	# Non-ItemTurret: items is null, so the leg reads 0.0
	# handled:true (the first branch of the :2107 ternary).
	var no_items_frame: Dictionary = turret_build_state.source_turret_ammo_items_stamp_state({}, false)
	var total_items_no_items: Dictionary = turret_build_state.source_building_comp_sense_state(no_items_frame, "totalItems", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["stamp_no_items_total_items_zero_num"] = bool(total_items_no_items.get("handled", false)) and is_equal_approx(float(total_items_no_items.get("sense_value", 1.0)), 0.0) and not bool(total_items_no_items.get("sense_value_is_nan", true))

	# A stale items_total already on the frame is overwritten
	# to 0.0 by the stamp (the stamp writes the key, it does
	# not preserve a previous value).
	var stale_frame: Dictionary = {"items_is_null": false, "items_total": 99}
	var stale_stamped: Dictionary = turret_build_state.source_turret_ammo_items_stamp_state(stale_frame, true)
	var total_items_stale: Dictionary = turret_build_state.source_building_comp_sense_state(stale_stamped, "totalItems", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["stamp_overwrites_stale_items_total_num"] = bool(total_items_stale.get("handled", false)) and is_equal_approx(float(total_items_stale.get("sense_value", 1.0)), 0.0) and not bool(total_items_stale.get("sense_value_is_nan", true))

	# The sense stamp (N2520) and the ammo-items stamp compose
	# on one frame: health 250.0, dead 0.0, cameraX 0.0, and
	# totalItems 0.0 all read handled:true from the same frame.
	var composed_frame: Dictionary = turret_build_state.source_turret_sense_frame_stamp_state({}, 250.0, 0.0)
	composed_frame = turret_build_state.source_turret_ammo_items_stamp_state(composed_frame, true)
	var health_composed: Dictionary = turret_build_state.source_building_comp_sense_state(composed_frame, "health", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["stamp_composed_health_num"] = bool(health_composed.get("handled", false)) and is_equal_approx(float(health_composed.get("sense_value", 0.0)), 250.0) and not bool(health_composed.get("sense_value_is_nan", true))
	var dead_composed: Dictionary = turret_build_state.source_building_comp_sense_state(composed_frame, "dead", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["stamp_composed_dead_num"] = bool(dead_composed.get("handled", false)) and is_equal_approx(float(dead_composed.get("sense_value", 1.0)), 0.0) and not bool(dead_composed.get("sense_value_is_nan", true))
	var camera_x_composed: Dictionary = turret_build_state.source_building_comp_sense_state(composed_frame, "cameraX", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["stamp_composed_camera_x_num"] = bool(camera_x_composed.get("handled", false)) and is_equal_approx(float(camera_x_composed.get("sense_value", 1.0)), 0.0) and not bool(camera_x_composed.get("sense_value_is_nan", true))

	# Killed duo: health 0.0 reads dead 1.0 (N2520) and still
	# reads totalItems 0.0 handled:true -- death does not
	# change the (empty) item module.
	var killed_frame: Dictionary = turret_build_state.source_turret_sense_frame_stamp_state({}, 0.0, 0.0)
	killed_frame = turret_build_state.source_turret_ammo_items_stamp_state(killed_frame, true)
	var total_items_killed: Dictionary = turret_build_state.source_building_comp_sense_state(killed_frame, "totalItems", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["stamp_killed_total_items_zero_num"] = bool(total_items_killed.get("handled", false)) and is_equal_approx(float(total_items_killed.get("sense_value", 1.0)), 0.0) and not bool(total_items_killed.get("sense_value_is_nan", true))

	# PowerNetIn still handled:false with power present: the
	# stamp does not write the graph keys (graph last-values
	# not tracked), so the N2519 absent-key fallback is
	# preserved.
	var power_net_in: Dictionary = turret_build_state.source_building_comp_sense_state(composed_frame, "powerNetIn", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	proof["stamp_power_net_in_absent_fallback"] = not bool(power_net_in.get("handled", true)) and power_net_in.get("sense_value", 0.0) == null and bool(power_net_in.get("sense_value_is_nan", false))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretAmmoItemsStampProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
