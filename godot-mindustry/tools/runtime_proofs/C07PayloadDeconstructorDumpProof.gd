extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_deconstructor_build_state := preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")
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

	# --- Pure dump (N2276): the updateTile dump block
	# (PayloadDeconstructor.java:111-115) runs dumpRate 4 x
	# dumpAccumulate() when items.total() > 0 -- BEFORE the
	# deconstructing progress block (:117+). dumpAccumulate()
	# (BuildingComp.java:1048-1050) delegates to
	# dumpAccumulate(null) (BuildingComp.java:1053-1061):
	# dumpAccum += delta(), then while dumpAccum >= 1f dump
	# and subtract 1f -- the subtraction is UNCONDITIONAL, it
	# runs even when dump() returns false. dump(null)
	# (BuildingComp.java:1072-1113) guards on hasItems /
	# non-empty store / non-empty proximity, scans proximity
	# from the cdump cursor and, for each neighbour, the
	# content items in order, handing the first held item an
	# accepting neighbour takes (acceptItem && canDump),
	# removing 1 from the store and advancing the cursor once
	# per neighbour checked (incrementDump,
	# BuildingComp.java:1116-1120, guarded on prox != 0).
	# source_delta is Time.delta in ticks (1.0 = one tick);
	# delta() is Time.delta * timeScale
	# (BuildingComp.java:1922-1924) -- NOT edelta(), so the
	# dump cadence ignores efficiency. The content item order
	# here is [copper, lead], the catalog order Java iterates
	# (content.items()).
	var content_item_ids: Array = ["copper", "lead"]
	var accepting: Array = [true]
	var can_dump: Array = [true]

	# Accumulate: with delta 0.1 the accum grows 0.1 per
	# dumpAccumulate call and no dump fires in 4 calls (0.4 <
	# 1f); at a doubled timeScale the delta doubles, so 4
	# calls reach 0.8 -- still no dump. The store and the
	# cursor are untouched.
	var accum_frame: Dictionary = {"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}
	var accumulated: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(accum_frame, 0.1, 1.0, content_item_ids, accepting, can_dump)
	var scaled: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(accum_frame, 0.1, 2.0, content_item_ids, accepting, can_dump)
	var accumulated_items: Dictionary = accumulated.get("items_after", {})
	var scaled_items: Dictionary = scaled.get("items_after", {})
	proof["dump_accumulates_with_delta"] = is_equal_approx(float(accumulated.get("dump_accum_after", -1.0)), 0.4) and bool(accumulated.get("dumped", true)) == false and int(accumulated_items.get("copper", -1)) == 5 and int(accumulated.get("cursor_after", -1)) == 0 and is_equal_approx(float(scaled.get("dump_accum_after", -1.0)), 0.8) and bool(scaled.get("dumped", true)) == false and int(scaled_items.get("copper", -1)) == 5

	# Fires at 1f: an accum of 0.9 plus delta 1.0 reaches 1.9
	# on the first call, so the dump fires and the accum drops
	# back to 0.9 -- four times in one tick, draining 4
	# copper. A dump that finds NO accepting neighbour still
	# subtracts: with every neighbour refusing, 4 calls at
	# delta 1.0 leave the accum at 0.0 (not 4.0), nothing
	# dumped, the store untouched, and the cursor back at 0
	# after 12 full-scan increments over 3 neighbours.
	var fire_frame: Dictionary = {"items": {"copper": 5}, "dump_accum": 0.9, "cdump": 0}
	var fired: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(fire_frame, 1.0, 1.0, content_item_ids, accepting, can_dump)
	var fired_items: Dictionary = fired.get("items_after", {})
	var refused_frame: Dictionary = {"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}
	var refused: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(refused_frame, 1.0, 1.0, content_item_ids, [false, false, false], [true, true, true])
	var refused_items: Dictionary = refused.get("items_after", {})
	proof["dump_fires_when_accum_reaches_one"] = bool(fired.get("dumped", false)) and int(fired_items.get("copper", -1)) == 1 and is_equal_approx(float(fired.get("dump_accum_after", -1.0)), 0.9) and bool(refused.get("dumped", true)) == false and int(refused_items.get("copper", -1)) == 5 and is_equal_approx(float(refused.get("dump_accum_after", -1.0)), 0.0) and int(refused.get("cursor_after", -1)) == 0

	# Rate four per tick: from a zero accum at delta 1.0 each
	# of the 4 dumpAccumulate calls reaches exactly 1f, so all
	# 4 dump -- copper 5 -> 1, accum back to 0.0. At delta
	# 0.5 only every second call reaches 1f, so 2 dump --
	# copper 5 -> 3, accum back to 0.0.
	var rate_frame: Dictionary = {"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}
	var rated: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(rate_frame, 1.0, 1.0, content_item_ids, accepting, can_dump)
	var rated_items: Dictionary = rated.get("items_after", {})
	var half: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(rate_frame, 0.5, 1.0, content_item_ids, accepting, can_dump)
	var half_items: Dictionary = half.get("items_after", {})
	proof["dump_rate_four_per_tick"] = bool(rated.get("dumped", false)) and int(rated_items.get("copper", -1)) == 1 and is_equal_approx(float(rated.get("dump_accum_after", -1.0)), 0.0) and int(half_items.get("copper", -1)) == 3 and is_equal_approx(float(half.get("dump_accum_after", -1.0)), 0.0)

	# Empty store: the whole dump block is skipped when
	# items.total() == 0, so the accum does NOT grow -- it
	# stays 0.9, the cursor stays 2, nothing dumps. A store
	# holding only a zero count is empty the same way.
	var empty_frame: Dictionary = {"items": {}, "dump_accum": 0.9, "cdump": 2}
	var emptied: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(empty_frame, 1.0, 1.0, content_item_ids, accepting, can_dump)
	var zero_frame: Dictionary = {"items": {"copper": 0}, "dump_accum": 0.9, "cdump": 2}
	var zeroed: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(zero_frame, 1.0, 1.0, content_item_ids, accepting, can_dump)
	proof["no_dump_when_items_empty"] = bool(emptied.get("dumped", true)) == false and is_equal_approx(float(emptied.get("dump_accum_after", -1.0)), 0.9) and int(emptied.get("cursor_after", -1)) == 2 and (emptied.get("items_after", {}) as Dictionary).is_empty() and bool(zeroed.get("dumped", true)) == false and is_equal_approx(float(zeroed.get("dump_accum_after", -1.0)), 0.9)

	# Removes from the store: the dump takes the first held
	# item in CONTENT order, so with copper and lead held it
	# drains copper 5 -> 1 over 4 dumps and leaves lead at 2.
	# A store that runs dry mid-tick stops dumping: 2 copper
	# drain to 0 after 2 dumps, and the remaining calls hit
	# the empty-store guard (dump() returns false) while the
	# accum still subtracts to 0.0.
	var store_frame: Dictionary = {"items": {"copper": 5, "lead": 2}, "dump_accum": 0.0, "cdump": 0}
	var stored: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(store_frame, 1.0, 1.0, content_item_ids, accepting, can_dump)
	var stored_items: Dictionary = stored.get("items_after", {})
	var dry_frame: Dictionary = {"items": {"copper": 2}, "dump_accum": 0.0, "cdump": 0}
	var dried: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(dry_frame, 1.0, 1.0, content_item_ids, accepting, can_dump)
	var dried_items: Dictionary = dried.get("items_after", {})
	proof["dump_removes_item_from_store"] = int(stored_items.get("copper", -1)) == 1 and int(stored_items.get("lead", -1)) == 2 and bool(dried.get("dumped", false)) and int(dried_items.get("copper", -1)) == 0 and is_equal_approx(float(dried.get("dump_accum_after", -1.0)), 0.0)

	# Cursor advances: with 3 neighbours where only neighbour
	# 1 accepts, the first dump checks neighbour 0 (refused,
	# cursor 0 -> 1) then neighbour 1 (dumped, cursor 1 -> 2);
	# the next dumps scan from 2 (refused, refused, dumped at
	# 1) and the cursor ends at 2 with 4 copper dumped. A
	# neighbour that accepts but canDump-blocks takes nothing:
	# with canDump false everywhere, nothing dumps and the
	# cursor stays 0 over the single-neighbour proximity.
	var cursor_frame: Dictionary = {"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}
	var cursor: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(cursor_frame, 1.0, 1.0, content_item_ids, [false, true, false], [true, true, true])
	var cursor_items: Dictionary = cursor.get("items_after", {})
	var blocked: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(cursor_frame, 1.0, 1.0, content_item_ids, [true], [false])
	var blocked_items: Dictionary = blocked.get("items_after", {})
	proof["dump_cursor_advances"] = bool(cursor.get("dumped", false)) and int(cursor_items.get("copper", -1)) == 1 and int(cursor.get("cursor_after", -1)) == 2 and bool(blocked.get("dumped", true)) == false and int(blocked_items.get("copper", -1)) == 5 and int(blocked.get("cursor_after", -1)) == 0

	# --- Live tick: the payload-deconstructor is a PayloadDeconstructor build
	# with a power consumer (consumePower 3f), placed live; the
	# tick driver is called directly (as the N2147/N2148/N2149/
	# N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/
	# N2162/N2163/N2164/N2165/N2166/N2167/N2168/N2169/N2200/N2210
	# proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. One 1/60s
	# tick is one source tick: efficiency folds the power min
	# 0.5, and the dump runs BEFORE the progress advance (Java
	# order: PayloadDeconstructor.java:111-115 before :117+),
	# so with an accum of 0.9 and an accepting neighbour the
	# tick dumps 4 copper (5 -> 1) and the accum ends at 0.9
	# -- the dump cadence is delta(), not edelta(), so half
	# power does not slow it. The neighbour arrays are frame
	# inputs (default []), stamped here like the N2228 targets
	# precedent.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var payload_deconstructor_cell := Vector2i(28, 21)
	var payload_deconstructor := Sprite2D.new()
	game.add_child(payload_deconstructor)
	game.call("record_placed_block", payload_deconstructor, blocks_by_id["deconstructor"], payload_deconstructor_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the dump inputs on it).
	payload_deconstructor_build_state.source_payload_deconstructor_bind_frame_state(payload_deconstructor, blocks_by_id["deconstructor"])
	var payload_deconstructor_frame: Dictionary = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})

	# Keep the later shouldConsume gate open, as in the existing gate proof.
	payload_deconstructor_frame["deconstructing"] = {"block": "conveyor"}
	payload_deconstructor_frame["items"] = {"copper": 5}
	payload_deconstructor_frame["dump_accum"] = 0.9
	payload_deconstructor_frame["dump_neighbour_accepts"] = [true]
	payload_deconstructor_frame["dump_neighbour_can_dump"] = [true]
	payload_deconstructor_frame["power_status"] = 0.5
	payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)
	payload_deconstructor_frame = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	var live_items: Dictionary = payload_deconstructor_frame.get("items", {})
	proof["live_tick_dumps_item"] = is_equal_approx(float(payload_deconstructor_frame.get("efficiency", -1.0)), 0.5) and int(live_items.get("copper", -1)) == 1 and is_equal_approx(float(payload_deconstructor_frame.get("dump_accum", -1.0)), 0.9) and int(payload_deconstructor_frame.get("cdump", -1)) == 0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadDeconstructorDumpProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
