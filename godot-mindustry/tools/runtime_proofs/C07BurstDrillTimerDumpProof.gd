extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
const drill_build_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
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

	# --- Pure timer dump (N2282): the timerDump check
	# (BurstDrill.java:83-84) runs at the TOP of updateTile --
	# after the dominantItem null return (:77-79) and the
	# invertTime decay (:81), BEFORE the drillTime /
	# smoothProgress / gate / offload advance (:87+) -- so the
	# dump drains the store the advance filled LAST tick.
	# dumpTime is 5 (Block.java:438, no override in upstream)
	# and the timer is TimerComp.timer (TimerComp.java:10-13):
	# false for an infinite interval, otherwise Interval.get
	# (arc Interval.java:20-26), which resets times[id] =
	# Time.time on fire; check compares Time.time - times[id]
	# >= time (arc Interval.java:28-30), and Time.time counts
	# TICKS (arc Time.java:69-80). The port has no global tick
	# clock at the driver layer, so the elapsed clock is
	# frame-local (the N2266/N2269/N2273/N2280 precedent):
	# elapsed += source_delta unconditionally; fired = elapsed
	# >= 5f / time_scale; elapsed_after RESETS to 0.0 on fire;
	# a non-positive time_scale never fires. When the timer
	# fires, the dump is dump(dominantItem) if the store holds
	# a positive amount of it (ItemSeq.java:79-81) else
	# dump(null). dump(Item todump)
	# (BuildingComp.java:1072-1113) guards on hasItems /
	# non-empty store / non-empty proximity, scans proximity
	# from the cdump cursor, and hands the first held item an
	# accepting neighbour takes (acceptItem && canDump) over,
	# removing 1 from the store and advancing the cursor once
	# per neighbour checked (incrementDump,
	# BuildingComp.java:1116-1120, guarded on prox != 0).
	# source_delta is Time.delta in ticks (1.0 = one tick).
	# The content item order here is [copper, lead], the
	# catalog order Java iterates (content.items()).
	var content_item_ids: Array = ["copper", "lead"]
	var accepting: Array = [true]
	var can_dump: Array = [true]

	# Fires at five ticks: an elapsed of 4.0 plus delta 1.0
	# reaches exactly 5f, so the timer fires, the clock resets
	# to 0.0, and the dominant copper dumps (5 -> 4) to the
	# single accepting neighbour (cursor (0 + 1) % 1 = 0). At
	# a doubled timeScale the threshold halves to 2.5 ticks,
	# so an elapsed of 2.0 plus delta 1.0 fires too.
	var fire_frame: Dictionary = {"items": {"copper": 5}, "timer_dump_elapsed": 4.0, "cdump": 0}
	var fired: Dictionary = burst_drill_build_state.source_burst_drill_timer_dump_state(fire_frame, 1.0, 1.0, "copper", content_item_ids, accepting, can_dump)
	var fired_items: Dictionary = fired.get("items_after", {})
	var scaled_frame: Dictionary = {"items": {"copper": 5}, "timer_dump_elapsed": 2.0, "cdump": 0}
	var scaled: Dictionary = burst_drill_build_state.source_burst_drill_timer_dump_state(scaled_frame, 1.0, 2.0, "copper", content_item_ids, accepting, can_dump)
	var scaled_items: Dictionary = scaled.get("items_after", {})
	proof["timer_fires_at_five_ticks"] = bool(fired.get("fired", false)) and is_equal_approx(float(fired.get("elapsed_after", -1.0)), 0.0) and bool(fired.get("dumped", false)) and int(fired_items.get("copper", -1)) == 4 and int(fired.get("cursor_after", -1)) == 0 and bool(scaled.get("fired", false)) and is_equal_approx(float(scaled.get("elapsed_after", -1.0)), 0.0) and int(scaled_items.get("copper", -1)) == 4

	# No fire below the threshold: an elapsed of 3.0 plus
	# delta 1.0 reaches only 4.0 < 5f, so nothing fires, the
	# clock keeps the accumulated 4.0, the store and the
	# cursor are untouched. A zero time_scale is the
	# infinite-time branch (TimerComp.java:11): even an
	# elapsed of 4.9 plus delta 1.0 never fires, and the clock
	# keeps growing to 5.9.
	var below_frame: Dictionary = {"items": {"copper": 5}, "timer_dump_elapsed": 3.0, "cdump": 0}
	var below: Dictionary = burst_drill_build_state.source_burst_drill_timer_dump_state(below_frame, 1.0, 1.0, "copper", content_item_ids, accepting, can_dump)
	var below_items: Dictionary = below.get("items_after", {})
	var zero_frame: Dictionary = {"items": {"copper": 5}, "timer_dump_elapsed": 4.9, "cdump": 0}
	var zeroed: Dictionary = burst_drill_build_state.source_burst_drill_timer_dump_state(zero_frame, 1.0, 0.0, "copper", content_item_ids, accepting, can_dump)
	var zeroed_items: Dictionary = zeroed.get("items_after", {})
	proof["timer_no_fire_below_threshold"] = bool(below.get("fired", true)) == false and is_equal_approx(float(below.get("elapsed_after", -1.0)), 4.0) and bool(below.get("dumped", true)) == false and int(below_items.get("copper", -1)) == 5 and int(below.get("cursor_after", -1)) == 0 and bool(zeroed.get("fired", true)) == false and is_equal_approx(float(zeroed.get("elapsed_after", -1.0)), 5.9) and int(zeroed_items.get("copper", -1)) == 5

	# Prefers the dominant item: with copper and lead held and
	# lead dominant, the timer fires and dumps LEAD (2 -> 1),
	# leaving copper at 5 -- the dump takes the dominant item,
	# not the first item in content order.
	var prefer_frame: Dictionary = {"items": {"copper": 5, "lead": 2}, "timer_dump_elapsed": 4.0, "cdump": 0}
	var preferred: Dictionary = burst_drill_build_state.source_burst_drill_timer_dump_state(prefer_frame, 1.0, 1.0, "lead", content_item_ids, accepting, can_dump)
	var preferred_items: Dictionary = preferred.get("items_after", {})
	proof["dump_prefers_dominant_item"] = bool(preferred.get("fired", false)) and bool(preferred.get("dumped", false)) and int(preferred_items.get("lead", -1)) == 1 and int(preferred_items.get("copper", -1)) == 5 and is_equal_approx(float(preferred.get("elapsed_after", -1.0)), 0.0)

	# Falls back to null: with copper held and beryllium
	# dominant but NOT held, the dump is dump(null) -- the
	# neighbour-outer / item-inner scan takes the first held
	# item in content order, copper (5 -> 4). A zero-count
	# dominant entry is NOT held either (ItemSeq.java:79-81,
	# has means amount > 0): with lead at 0 and copper at 5,
	# a lead-dominant drill still dumps copper.
	var fallback_frame: Dictionary = {"items": {"copper": 5}, "timer_dump_elapsed": 4.0, "cdump": 0}
	var fallback: Dictionary = burst_drill_build_state.source_burst_drill_timer_dump_state(fallback_frame, 1.0, 1.0, "beryllium", content_item_ids, accepting, can_dump)
	var fallback_items: Dictionary = fallback.get("items_after", {})
	var zero_count_frame: Dictionary = {"items": {"copper": 5, "lead": 0}, "timer_dump_elapsed": 4.0, "cdump": 0}
	var zero_count: Dictionary = burst_drill_build_state.source_burst_drill_timer_dump_state(zero_count_frame, 1.0, 1.0, "lead", content_item_ids, accepting, can_dump)
	var zero_count_items: Dictionary = zero_count.get("items_after", {})
	proof["dump_falls_back_to_null"] = bool(fallback.get("fired", false)) and bool(fallback.get("dumped", false)) and int(fallback_items.get("copper", -1)) == 4 and bool(zero_count.get("dumped", false)) and int(zero_count_items.get("copper", -1)) == 4 and int(zero_count_items.get("lead", -1)) == 0

	# No dump without a dominant item: dominantItem == null
	# returns from updateTile before the timer check
	# (BurstDrill.java:77-79), so the timer never fires and
	# nothing dumps -- NOT dump(null). The clock still
	# accumulates (Time.time grows regardless), so an elapsed
	# of 4.0 plus delta 1.0 reaches 5.0 unfired; and when a
	# dominant item appears on the NEXT tick, the pending
	# elapsed fires immediately (5.0 + 1.0 >= 5f), like Java's
	# Interval whose times[id] stayed 0 while updateTile
	# returned early.
	var nodom_frame: Dictionary = {"items": {"copper": 5}, "timer_dump_elapsed": 4.0, "cdump": 0}
	var nodom: Dictionary = burst_drill_build_state.source_burst_drill_timer_dump_state(nodom_frame, 1.0, 1.0, "", content_item_ids, accepting, can_dump)
	var nodom_items: Dictionary = nodom.get("items_after", {})
	var appears_frame: Dictionary = {"items": {"copper": 5}, "timer_dump_elapsed": 5.0, "cdump": 0}
	var appears: Dictionary = burst_drill_build_state.source_burst_drill_timer_dump_state(appears_frame, 1.0, 1.0, "copper", content_item_ids, accepting, can_dump)
	var appears_items: Dictionary = appears.get("items_after", {})
	proof["no_dump_without_dominant_item"] = bool(nodom.get("fired", true)) == false and is_equal_approx(float(nodom.get("elapsed_after", -1.0)), 5.0) and bool(nodom.get("dumped", true)) == false and int(nodom_items.get("copper", -1)) == 5 and int(nodom.get("cursor_after", -1)) == 0 and bool(appears.get("fired", false)) and bool(appears.get("dumped", false)) and int(appears_items.get("copper", -1)) == 4

	# Cursor advances: with 3 neighbours where only neighbour
	# 1 accepts, the dump checks neighbour 0 (refused, cursor
	# 0 -> 1) then neighbour 1 (dumped, cursor 1 -> 2), and
	# copper drops 5 -> 4. A neighbour that accepts but
	# canDump-blocks takes nothing: with canDump false
	# everywhere, nothing dumps, the store is untouched, and
	# the cursor stays 0 over the single-neighbour proximity
	# -- but the TIMER still fired and reset (Interval.get
	# resets on fire whether or not the dump succeeded).
	var cursor_frame: Dictionary = {"items": {"copper": 5}, "timer_dump_elapsed": 4.0, "cdump": 0}
	var cursor: Dictionary = burst_drill_build_state.source_burst_drill_timer_dump_state(cursor_frame, 1.0, 1.0, "copper", content_item_ids, [false, true, false], [true, true, true])
	var cursor_items: Dictionary = cursor.get("items_after", {})
	var blocked: Dictionary = burst_drill_build_state.source_burst_drill_timer_dump_state(cursor_frame, 1.0, 1.0, "copper", content_item_ids, [true], [false])
	var blocked_items: Dictionary = blocked.get("items_after", {})
	proof["dump_cursor_advances"] = bool(cursor.get("dumped", false)) and int(cursor_items.get("copper", -1)) == 4 and int(cursor.get("cursor_after", -1)) == 2 and bool(blocked.get("fired", false)) and is_equal_approx(float(blocked.get("elapsed_after", -1.0)), 0.0) and bool(blocked.get("dumped", true)) == false and int(blocked_items.get("copper", -1)) == 5 and int(blocked.get("cursor_after", -1)) == 0

	# --- Live tick: the eruption-drill is a BurstDrill with a
	# power consumer (consumePower 6f, itemCapacity 60),
	# placed live on copper ore; the tick driver is called
	# directly (as the N2149/N2203/N2219 proofs do), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. One 1/60s tick is
	# one source tick: the timerDump dump runs BEFORE the
	# advance (Java order: BurstDrill.java:83-84 before :87+),
	# so with an elapsed of 4.0 and an accepting neighbour the
	# tick dumps 1 dominant copper (5 -> 4) and the clock
	# resets to 0.0. The dump is efficiency-independent (a
	# timer, not edelta), so no efficiency value is asserted
	# here -- the N2257 liquid rows fold the starved hydrogen
	# row into the min efficiency, and the dump runs either
	# way. The neighbour arrays are frame inputs (default []),
	# stamped here like the N2276 precedent.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var eruption_cell := Vector2i(28, 20)
	var eruption := Sprite2D.new()
	game.add_child(eruption)
	var terrain := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
	for occupied in game.call("occupied_cells", eruption_cell, blocks_by_id["eruption-drill"]):
		terrain.source_set_world_overlay_state(game, occupied.x, occupied.y, catalog.get_by_id("ore-copper"), false)
	game.call("record_placed_block", eruption, blocks_by_id["eruption-drill"], eruption_cell)
	# Bind the frame + dominant item from the ore under the
	# footprint: the overlay mutation binds proximity only when a
	# sprite is already on the cell, and the overlays were set
	# before placement, so bind explicitly here (the N2149
	# pattern; BurstDrillBuild extends DrillBuild, so the drill
	# proximity path binds the shared "source_drill_building"
	# frame and sets dominant_items from the ore count).
	drill_build_state.source_on_proximity_update_state(game, eruption, blocks_by_id["eruption-drill"])
	var eruption_frame: Dictionary = eruption.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})

	eruption_frame["items"] = {"copper": 5}
	eruption_frame["timer_dump_elapsed"] = 4.0
	eruption_frame["dump_neighbour_accepts"] = [true]
	eruption_frame["dump_neighbour_can_dump"] = [true]
	eruption_frame["power_status"] = 0.5
	burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)
	eruption_frame = eruption.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	var live_items: Dictionary = eruption_frame.get("items", {})
	proof["live_tick_dumps_item"] = int(live_items.get("copper", -1)) == 4 and is_equal_approx(float(eruption_frame.get("timer_dump_elapsed", -1.0)), 0.0) and int(eruption_frame.get("cdump", -1)) == 0 and int(eruption_frame.get("dominant_items", 0)) > 0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillTimerDumpProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
