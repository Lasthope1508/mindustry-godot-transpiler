extends Node

const main_scene := preload("res://scenes/Main.tscn")
const state := preload("res://src/game/SourceBeamDrillBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _tick(last_item: Variant, boost_warmup: float, optional_efficiency: float, time: float, time_delta: float, facing: Array, items_total: int, item_capacity: int, dump_ready: bool, get_drill_time: Callable, items_add: Callable, produced: Callable, dump: Callable) -> Dictionary:
	return state.source_beam_drill_update_tile_state({}, last_item, boost_warmup, optional_efficiency, time, time_delta, facing, items_total, item_capacity, dump_ready, get_drill_time, items_add, produced, dump)


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

	# --- BeamDrillBuild.updateTile() facing-harvest + dump
	# (N2398):
	# BeamDrillBuild.updateTile() (BeamDrill.java:237-265)
	# -- this slice is the facing-harvest + dump half:
	# `float drillTime = getDrillTime(lastItem);` (:247),
	# `boostWarmup = Mathf.lerpDelta(boostWarmup,
	# optionalEfficiency, 0.1f);` (:248), the harvest gate
	# `if(time >= drillTime){` (:253) with the facing loop
	# `for(Tile tile : facing){` (:254), `Item drop = tile
	# == null ? null : tile.wallDrop();` (:255), the
	# capacity gate `if(items.total() < itemCapacity &&
	# drop != null){` (:256), `items.add(drop, 1);`
	# (:257), `produced(drop);` (:258), `time %=
	# drillTime;` (:261), and the dump `dump();` (:264)
	# behind the timer gate (N691 generic -- arrives as
	# dump_ready). The proof drives the pure function
	# with synthetic frames (no live tick): plasma-bore
	# drillTime 200f class default (BeamDrill.java:39),
	# itemCapacity 10 (Block default), tiles copper/lead
	# as facing tile Dictionaries {"wall_drop": ...}
	# (the N2379 updateFacing precedent). NOT this slice:
	# `super.updateTile();`, `if(lasers[0] == null)
	# updateLasers();` / `updateFacing();` (N2379), the
	# warmup gate / multiplier / lastDrillSpeed / `time +=
	# edelta() * multiplier;` (all N2155), the timer gate
	# itself (N691 generic).

	# drillTime comes from the get_drill_time Callable,
	# invoked with the last item.
	var drill_seen: Array = []
	var drill_time_callable: Callable = func(item: Variant) -> float:
		drill_seen.append(item)
		return 200.0
	var no_op: Callable = Callable()
	var drilled: Dictionary = _tick("copper", 0.0, 1.0, 0.0, 1.0, [], 0, 10, false, drill_time_callable, no_op, no_op, no_op)
	proof["drill_time_from_get_drill_time"] = bool(drilled.get("get_drill_time_called", false)) and drill_seen == ["copper"] and is_equal_approx(float(drilled.get("drill_time", -1.0)), 200.0)

	# boostWarmup lerps toward optionalEfficiency at 0.1
	# per delta: lerp(0.0, 1.0, clamp(1.0 * 0.1)) = 0.1.
	proof["boost_warmup_lerp_delta"] = is_equal_approx(float(drilled.get("boost_warmup", -1.0)), 0.1)

	# Below the harvest gate nothing is harvested and
	# time is unchanged.
	var add_seen: Array = []
	var add_callable: Callable = func(item: Variant, amount: int) -> void:
		add_seen.append([item, amount])
	var produced_seen: Array = []
	var produced_callable: Callable = func(item: Variant) -> void:
		produced_seen.append(item)
	var below: Dictionary = _tick("copper", 0.0, 1.0, 100.0, 1.0, [{"wall_drop": "copper"}], 0, 10, false, drill_time_callable, add_callable, produced_callable, no_op)
	proof["harvest_below_gate_no_add"] = (below.get("harvested", ["x"]) as Array).is_empty() and is_equal_approx(float(below.get("time", -1.0)), 100.0) and add_seen.is_empty() and produced_seen.is_empty()

	# At the gate each facing drop is added once and
	# produced once, in facing order.
	add_seen.clear()
	produced_seen.clear()
	var harvested: Dictionary = _tick("copper", 0.0, 1.0, 200.0, 1.0, [{"wall_drop": "copper"}, {"wall_drop": "lead"}], 0, 10, false, drill_time_callable, add_callable, produced_callable, no_op)
	proof["harvest_adds_drop_and_produces"] = harvested.get("harvested", []) == ["copper", "lead"] and add_seen == [["copper", 1], ["lead", 1]] and produced_seen == ["copper", "lead"] and bool(harvested.get("items_add_called", false)) and bool(harvested.get("produced_called", false))

	# Null tiles and null drops are skipped, but time
	# still wraps by modulo.
	add_seen.clear()
	produced_seen.clear()
	var skipped: Dictionary = _tick("copper", 0.0, 1.0, 200.0, 1.0, [null, {"wall_drop": null}], 0, 10, false, drill_time_callable, add_callable, produced_callable, no_op)
	proof["harvest_skips_null_tile_and_null_drop"] = (skipped.get("harvested", ["x"]) as Array).is_empty() and is_equal_approx(float(skipped.get("time", -1.0)), 0.0) and add_seen.is_empty() and produced_seen.is_empty()

	# A full item store blocks adds, but time still wraps
	# (the %= sits outside the capacity gate).
	var full: Dictionary = _tick("copper", 0.0, 1.0, 200.0, 1.0, [{"wall_drop": "copper"}], 10, 10, false, drill_time_callable, add_callable, produced_callable, no_op)
	proof["harvest_blocked_when_items_full"] = (full.get("harvested", ["x"]) as Array).is_empty() and is_equal_approx(float(full.get("time", -1.0)), 0.0) and not bool(full.get("items_add_called", true))

	# time wraps by modulo after harvest: 450 % 200 = 50.
	var wrapped: Dictionary = _tick("copper", 0.0, 1.0, 450.0, 1.0, [{"wall_drop": "copper"}], 0, 10, false, drill_time_callable, add_callable, produced_callable, no_op)
	proof["time_modulo_after_harvest"] = is_equal_approx(float(wrapped.get("time", -1.0)), 50.0) and wrapped.get("harvested", []) == ["copper"]

	# dump fires only when the timer gate is ready.
	var dump_seen: Array = []
	var dump_callable: Callable = func() -> void:
		dump_seen.append(true)
	var dumped: Dictionary = _tick("copper", 0.0, 1.0, 0.0, 1.0, [], 0, 10, true, drill_time_callable, no_op, no_op, dump_callable)
	proof["dump_called_when_ready"] = bool(dumped.get("dump_called", false)) and dump_seen == [true]

	dump_seen.clear()
	var not_dumped: Dictionary = _tick("copper", 0.0, 1.0, 0.0, 1.0, [], 0, 10, false, drill_time_callable, no_op, no_op, dump_callable)
	proof["dump_not_called_when_not_ready"] = not bool(not_dumped.get("dump_called", true)) and dump_seen.is_empty()

	# The result carries ONLY its own keys.
	proof["returns_only_expected_keys"] = drilled.size() == 8 and harvested.size() == 8 and dumped.size() == 8

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
