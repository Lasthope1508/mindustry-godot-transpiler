extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mass_driver_build_state := preload("res://src/game/SourceMassDriverBuildState.gd")
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

	# --- Pure advance (N2237): MassDriverBuild.updateTile()
	# (MassDriver.java:133-221) + fire() (MassDriver.java:290-317):
	# the link refresh (hasLink = linkValid, :134-139), the reload
	# decay regardless of state (:142-144), the currentShooter
	# cleanup (:146-151), the idle -> accepting / shooting switch
	# (:153-163), the no-power skip (:169-171), the accepting align
	# (:173-182), the shooting register + align + fire gate
	# (:182-217), and fire() (:290-317, items leave the self frame
	# the moment they fire, bullet damage = totalUsed/2f).
	# source_delta is Time.delta in ticks (1.0 = one tick);
	# itemCapacity is the def constant 120 (Blocks.java:2170),
	# reload the def constant 200f (Blocks.java:2171, beating the
	# class 100f), rotateSpeed 5f, minDistribute 10, bulletSpeed
	# 5.5f, bulletLifetime 200f. Positions are Point2-packed
	# (arc Point2.java:40-42): this tile (3, 5), the partner
	# (3, 10), a shooter (3, 0), another driver (5, 5). World
	# coords are cell * tilesize 8: self (0, 0), the partner
	# (80, 0) due east (angleTo 0), the shooter (80, 0) too.
	var this_pos: int = (3 << 16) | 5
	var partner_pos: int = (3 << 16) | 10
	var shooter_pos: int = (3 << 16) | 0
	var other_pos: int = (5 << 16) | 5
	var item_order: Array = ["copper", "lead"]
	var unlinked: Dictionary = {"exists": false, "pos": -1, "is_mass_driver": false, "same_block": false, "same_team": false, "within_range": false, "item_capacity": 120, "items_total": 0, "state": "idle", "rotation": 90.0, "waiting_shooters": [], "x": 0.0, "y": 0.0}

	# reloadCounter = Mathf.clamp(reloadCounter - edelta() / reload)
	# (MassDriver.java:143), "reload regardless of state": at
	# efficiency 0.5 one tick drains 0.5 / 200 = 0.0025 (1.0 ->
	# 0.9975); a near-empty counter clamps at 0 (0.001 - 1/200
	# would go negative); at efficiency 0 edelta is 0 and the
	# counter holds; a shooting driver with no link still decays
	# (and bails to idle in the same tick).
	var decay_frame: Dictionary = {"efficiency": 0.5, "link": -1, "rotation": 90.0, "reload_counter": 1.0, "state": "idle", "waiting_shooters": [], "items": {}}
	var decayed: Dictionary = mass_driver_build_state.source_mass_driver_update_tile_advance_state(decay_frame, 1.0, 1.0, 120, 200.0, 5.0, 10, 5.5, 200.0, this_pos, 0.0, 0.0, unlinked, {}, item_order)
	var clamp_frame: Dictionary = {"efficiency": 1.0, "link": -1, "rotation": 90.0, "reload_counter": 0.001, "state": "idle", "waiting_shooters": [], "items": {}}
	var clamped: Dictionary = mass_driver_build_state.source_mass_driver_update_tile_advance_state(clamp_frame, 1.0, 1.0, 120, 200.0, 5.0, 10, 5.5, 200.0, this_pos, 0.0, 0.0, unlinked, {}, item_order)
	var zero_frame: Dictionary = {"efficiency": 0.0, "link": -1, "rotation": 90.0, "reload_counter": 1.0, "state": "idle", "waiting_shooters": [], "items": {}}
	var zeroed: Dictionary = mass_driver_build_state.source_mass_driver_update_tile_advance_state(zero_frame, 1.0, 1.0, 120, 200.0, 5.0, 10, 5.5, 200.0, this_pos, 0.0, 0.0, unlinked, {}, item_order)
	var shooting_frame: Dictionary = {"efficiency": 0.5, "link": -1, "rotation": 90.0, "reload_counter": 1.0, "state": "shooting", "waiting_shooters": [], "items": {}}
	var shooting_decayed: Dictionary = mass_driver_build_state.source_mass_driver_update_tile_advance_state(shooting_frame, 1.0, 1.0, 120, 200.0, 5.0, 10, 5.5, 200.0, this_pos, 0.0, 0.0, unlinked, {}, item_order)
	proof["reload_counter_decays"] = is_equal_approx(float(decayed.get("reload_counter", -1.0)), 0.9975) and str(decayed.get("state", "")) == "idle" and is_equal_approx(float(clamped.get("reload_counter", -1.0)), 0.0) and is_equal_approx(float(zeroed.get("reload_counter", -1.0)), 1.0) and is_equal_approx(float(shooting_decayed.get("reload_counter", -1.0)), 0.9975) and str(shooting_decayed.get("state", "")) == "idle"

	# Idle accepts a waiting shooter (MassDriver.java:156-157):
	# waiting non-empty with space >= minDistribute switches to
	# accepting, and the rotation aligns toward the shooter
	# (MassDriver.java:181): angleTo (80, 0) is 0, so rotation
	# 90 moves 5 toward it (90 -> 85). An invalid shooter
	# (efficiency 0) is cleaned first (MassDriver.java:149-150)
	# and idle holds with an empty list; a full driver (115/120,
	# space 5 < 10) stays idle with the shooter still waiting.
	var shooter_record: Dictionary = {"is_mass_driver": true, "is_valid": true, "efficiency": 1.0, "same_block": true, "link_equals_self": true, "within_range": true, "x": 80.0, "y": 0.0}
	var accept_frame: Dictionary = {"efficiency": 1.0, "link": -1, "rotation": 90.0, "reload_counter": 0.0, "state": "idle", "waiting_shooters": [shooter_pos], "items": {}}
	var accepted: Dictionary = mass_driver_build_state.source_mass_driver_update_tile_advance_state(accept_frame, 1.0, 1.0, 120, 200.0, 5.0, 10, 5.5, 200.0, this_pos, 0.0, 0.0, unlinked, {shooter_pos: shooter_record}, item_order)
	var dead_record: Dictionary = {"is_mass_driver": true, "is_valid": true, "efficiency": 0.0, "same_block": true, "link_equals_self": true, "within_range": true, "x": 80.0, "y": 0.0}
	var invalid_frame: Dictionary = {"efficiency": 1.0, "link": -1, "rotation": 90.0, "reload_counter": 0.0, "state": "idle", "waiting_shooters": [shooter_pos], "items": {}}
	var invalidated: Dictionary = mass_driver_build_state.source_mass_driver_update_tile_advance_state(invalid_frame, 1.0, 1.0, 120, 200.0, 5.0, 10, 5.5, 200.0, this_pos, 0.0, 0.0, unlinked, {shooter_pos: dead_record}, item_order)
	var full_frame: Dictionary = {"efficiency": 1.0, "link": -1, "rotation": 90.0, "reload_counter": 0.0, "state": "idle", "waiting_shooters": [shooter_pos], "items": {"copper": 115}}
	var full: Dictionary = mass_driver_build_state.source_mass_driver_update_tile_advance_state(full_frame, 1.0, 1.0, 120, 200.0, 5.0, 10, 5.5, 200.0, this_pos, 0.0, 0.0, unlinked, {shooter_pos: shooter_record}, item_order)
	proof["idle_accepts_waiting_shooter"] = str(accepted.get("state", "")) == "accepting" and is_equal_approx(float(accepted.get("rotation", -1.0)), 85.0) and (accepted.get("waiting_shooters", []) as Array) == [shooter_pos] and str(invalidated.get("state", "")) == "idle" and (invalidated.get("waiting_shooters", []) as Array) == [] and str(full.get("state", "")) == "idle" and (full.get("waiting_shooters", []) as Array) == [shooter_pos]

	# Shooting registers on the link (MassDriver.java:159 +
	# :195-196): idle with a valid link switches to shooting,
	# and with stock (20 >= 10) and link space (120 >= 10) this
	# driver is added to the partner waitingShooters -- the
	# cross-building write-back the driver lands on the linked
	# frame. The reload counter is still high (1.0 - 1/200 =
	# 0.995 > 0.0001), so no rotation and no fire yet.
	# Re-registration adds no duplicate, and without stock
	# (5 < 10) nothing registers.
	var linked_idle: Dictionary = {"exists": true, "pos": partner_pos, "is_mass_driver": true, "same_block": true, "same_team": true, "within_range": true, "item_capacity": 120, "items_total": 0, "state": "idle", "rotation": 90.0, "waiting_shooters": [], "x": 80.0, "y": 0.0}
	var shoot_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "rotation": 90.0, "reload_counter": 1.0, "state": "idle", "waiting_shooters": [], "items": {"copper": 20}}
	var shooting: Dictionary = mass_driver_build_state.source_mass_driver_update_tile_advance_state(shoot_frame, 1.0, 1.0, 120, 200.0, 5.0, 10, 5.5, 200.0, this_pos, 0.0, 0.0, linked_idle, {}, item_order)
	var linked_registered: Dictionary = {"exists": true, "pos": partner_pos, "is_mass_driver": true, "same_block": true, "same_team": true, "within_range": true, "item_capacity": 120, "items_total": 0, "state": "idle", "rotation": 90.0, "waiting_shooters": [this_pos], "x": 80.0, "y": 0.0}
	var re_registered: Dictionary = mass_driver_build_state.source_mass_driver_update_tile_advance_state(shoot_frame, 1.0, 1.0, 120, 200.0, 5.0, 10, 5.5, 200.0, this_pos, 0.0, 0.0, linked_registered, {}, item_order)
	var poor_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "rotation": 90.0, "reload_counter": 1.0, "state": "idle", "waiting_shooters": [], "items": {"copper": 5}}
	var poor: Dictionary = mass_driver_build_state.source_mass_driver_update_tile_advance_state(poor_frame, 1.0, 1.0, 120, 200.0, 5.0, 10, 5.5, 200.0, this_pos, 0.0, 0.0, linked_idle, {}, item_order)
	proof["shooting_registers_on_link"] = str(shooting.get("state", "")) == "shooting" and (shooting.get("partner_waiting_shooters", []) as Array) == [this_pos] and bool(shooting.get("fired", true)) == false and is_equal_approx(float(shooting.get("rotation", -1.0)), 90.0) and is_equal_approx(float(shooting.get("reload_counter", -1.0)), 0.995) and (re_registered.get("partner_waiting_shooters", []) as Array) == [this_pos] and (poor.get("partner_waiting_shooters", []) as Array) == []

	# Fire (MassDriver.java:198-216 + :290-317): reloaded, first
	# in the partner queue, partner accepting, both angles near
	# (self 0 vs target 0, partner 180 vs target+180) -- fire()
	# resets reloadCounter to 1f, moves ALL items out in
	# content-id order (copper 15 + lead 5 = 20, damage 20/2f =
	# 10.0, speed 5.5 * 1.0, lifetime 200 / 1.0), and the driver
	# is immediately idle. The fire caps at the self
	# itemCapacity: 130 copper fires 120 and keeps 10
	# (damage 60.0).
	var linked_accepting: Dictionary = {"exists": true, "pos": partner_pos, "is_mass_driver": true, "same_block": true, "same_team": true, "within_range": true, "item_capacity": 120, "items_total": 0, "state": "accepting", "rotation": 180.0, "waiting_shooters": [this_pos], "x": 80.0, "y": 0.0}
	var fire_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "rotation": 0.0, "reload_counter": 0.0, "state": "shooting", "waiting_shooters": [], "items": {"copper": 15, "lead": 5}}
	var fired: Dictionary = mass_driver_build_state.source_mass_driver_update_tile_advance_state(fire_frame, 1.0, 1.0, 120, 200.0, 5.0, 10, 5.5, 200.0, this_pos, 0.0, 0.0, linked_accepting, {}, item_order)
	var fired_items: Dictionary = fired.get("fired_items", {})
	var fired_left: Dictionary = fired.get("items", {})
	var cap_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "rotation": 0.0, "reload_counter": 0.0, "state": "shooting", "waiting_shooters": [], "items": {"copper": 130}}
	var capped: Dictionary = mass_driver_build_state.source_mass_driver_update_tile_advance_state(cap_frame, 1.0, 1.0, 120, 200.0, 5.0, 10, 5.5, 200.0, this_pos, 0.0, 0.0, linked_accepting, {}, item_order)
	var capped_left: Dictionary = capped.get("items", {})
	proof["fire_transfers_items_and_resets_reload"] = bool(fired.get("fired", false)) == true and str(fired.get("state", "")) == "idle" and is_equal_approx(float(fired.get("reload_counter", -1.0)), 1.0) and int(fired_items.get("copper", -1)) == 15 and int(fired_items.get("lead", -1)) == 5 and int(fired.get("fired_total", -1)) == 20 and is_equal_approx(float(fired.get("bullet_damage", -1.0)), 10.0) and is_equal_approx(float(fired.get("bullet_speed", -1.0)), 5.5) and is_equal_approx(float(fired.get("bullet_lifetime", -1.0)), 200.0) and int(fired_left.get("copper", -1)) == 0 and int(fired_left.get("lead", -1)) == 0 and int(capped.get("fired_total", -1)) == 120 and int(capped_left.get("copper", -1)) == 10 and is_equal_approx(float(capped.get("bullet_damage", -1.0)), 60.0)

	# No fire without alignment (MassDriver.java:204-206): a
	# misaligned self rotation (90, moving to 85, still far from
	# target 0) holds fire and keeps shooting; a partner that is
	# not accepting holds fire; a driver that is not first in
	# the partner queue (another driver ahead) holds fire --
	# though it still registers behind it. Items stay put and
	# reload stays 0 in all three cases.
	var misaligned_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "rotation": 90.0, "reload_counter": 0.0, "state": "shooting", "waiting_shooters": [], "items": {"copper": 15, "lead": 5}}
	var misaligned: Dictionary = mass_driver_build_state.source_mass_driver_update_tile_advance_state(misaligned_frame, 1.0, 1.0, 120, 200.0, 5.0, 10, 5.5, 200.0, this_pos, 0.0, 0.0, linked_accepting, {}, item_order)
	var misaligned_left: Dictionary = misaligned.get("items", {})
	var not_accepting: Dictionary = mass_driver_build_state.source_mass_driver_update_tile_advance_state(fire_frame, 1.0, 1.0, 120, 200.0, 5.0, 10, 5.5, 200.0, this_pos, 0.0, 0.0, linked_idle, {}, item_order)
	var linked_queued: Dictionary = {"exists": true, "pos": partner_pos, "is_mass_driver": true, "same_block": true, "same_team": true, "within_range": true, "item_capacity": 120, "items_total": 0, "state": "accepting", "rotation": 180.0, "waiting_shooters": [other_pos], "x": 80.0, "y": 0.0}
	var queued: Dictionary = mass_driver_build_state.source_mass_driver_update_tile_advance_state(fire_frame, 1.0, 1.0, 120, 200.0, 5.0, 10, 5.5, 200.0, this_pos, 0.0, 0.0, linked_queued, {}, item_order)
	proof["no_fire_without_alignment"] = bool(misaligned.get("fired", true)) == false and str(misaligned.get("state", "")) == "shooting" and is_equal_approx(float(misaligned.get("rotation", -1.0)), 85.0) and int(misaligned_left.get("copper", -1)) == 15 and is_equal_approx(float(misaligned.get("reload_counter", -1.0)), 0.0) and bool(not_accepting.get("fired", true)) == false and str(not_accepting.get("state", "")) == "shooting" and bool(queued.get("fired", true)) == false and (queued.get("partner_waiting_shooters", []) as Array) == [other_pos, this_pos]

	# --- Live tick: the mass driver is a MassDriver build with a
	# power consumer (consumePower 1.75f), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/
	# N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/
	# N2162/N2163/N2164/N2165/N2166/N2167/N2168/N2169/N2170/N2171
	# proofs do), not simulate_factory, so the graph update does
	# not overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. Half power: efficiency
	# folds the power min 0.5, so one tick (source_delta 1.0)
	# drains the reload counter 1.0 -> 1.0 - 0.5/200 = 0.9975,
	# and the frame carries the advance keys (link -1, rotation
	# 90, state idle, empty waiting_shooters, empty items). No
	# power: efficiency 0, the counter holds at 0.9975.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var mass_driver_cell := Vector2i(28, 21)
	var mass_driver := Sprite2D.new()
	game.add_child(mass_driver)
	game.call("record_placed_block", mass_driver, blocks_by_id["mass-driver"], mass_driver_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	mass_driver_build_state.source_mass_driver_bind_frame_state(mass_driver, blocks_by_id["mass-driver"])
	var mass_driver_frame: Dictionary = mass_driver.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	mass_driver_frame["power_status"] = 0.5
	mass_driver_frame["reload_counter"] = 1.0
	mass_driver_build_state.source_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	mass_driver_frame = mass_driver.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	var half_tick_ok: bool = is_equal_approx(float(mass_driver_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(mass_driver_frame.get("reload_counter", -1.0)), 0.9975) and int(mass_driver_frame.get("link", 0)) == -1 and is_equal_approx(float(mass_driver_frame.get("rotation", -1.0)), 90.0) and str(mass_driver_frame.get("state", "")) == "idle" and (mass_driver_frame.get("waiting_shooters", [-1]) as Array) == [] and (mass_driver_frame.get("items", {"x": 1}) as Dictionary) == {}
	mass_driver_frame["power_status"] = 0.0
	mass_driver_build_state.source_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	mass_driver_frame = mass_driver.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	proof["live_tick_writes_advance_frame_keys"] = half_tick_ok and is_equal_approx(float(mass_driver_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(mass_driver_frame.get("reload_counter", -1.0)), 0.9975)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MassDriverUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
