extends Node

const main_scene := preload("res://scenes/Main.tscn")
const beam_drill_build_state := preload("res://src/game/SourceBeamDrillBuildState.gd")
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

	# --- Blocked-item init + drill multipliers (N2473):
	# BeamDrill.init (BeamDrill.java:81-87) promotes the
	# single blockedItem into the blockedItems list
	# (`if(blockedItems == null && blockedItem != null){`
	# / `blockedItems = Seq.with(blockedItem);`, :84-85)
	# and BeamDrill.getDrillTime (BeamDrill.java:216-218)
	# divides the base drillTime by the mapped multiplier
	# (`return drillTime / drillMultipliers.get(item, 1f);`,
	# :217). The fields are drillMultipliers :47,
	# blockedItem :49, blockedItems :51 -- NOT :36-40 as
	# the old DEFERRED cite said (:36-40 are the top/glow
	# regions + drillTime + range). The lookup IS
	# drill-time, not setStats-only: updateTile calls it
	# every tick (`float drillTime = getDrillTime(lastItem);`,
	# :247) and the result drives lastDrillSpeed (:249),
	# the drop threshold (:253) and the reset (:261).
	# The default is 1f twice over: the call site passes
	# it and arc honours it (ObjectFloatMap.get(key,
	# defaultValue), ObjectFloatMap.java:286, returns the
	# default when the key is absent -- including a null
	# item, `if(key == null) return defaultValue;`, :287,
	# the updateTile case when lastItem is null). Neither
	# BeamDrill def sets drillMultipliers / blockedItem /
	# blockedItems (Blocks.java:3038-3068), so both defs
	# read the default 1.0 for every item and a null
	# blocked list; the thorium / beryllium-2f values
	# below are BurstDrill def values (`blockedItem =
	# Items.thorium;`, Blocks.java:3080, and
	# `drillMultipliers.put(Items.beryllium, 2f);`,
	# Blocks.java:3083/3114, impact-drill /
	# eruption-drill) used as caller-supplied inputs.
	# Pure-only: no tick wiring -- the drop-loop slice
	# wires getDrillTime into the advance, and the tick
	# keeps the shared Drill bind for the facing scan.

	# --- Init sets: a lone blockedItem promotes to the
	# one-element list (thorium, the impact-drill def
	# value); a null list with a null item stays null.
	var sets: Dictionary = beam_drill_build_state.source_beam_drill_blocked_items_state("thorium", null)
	var sets_list: Variant = sets.get("blocked_items_after", null)
	proof["blocked_init_sets"] = sets_list is Array and (sets_list as Array) == ["thorium"]

	# --- Init keeps: an already-set list passes through
	# unchanged even when a blockedItem is also set (the
	# Seq.with branch never runs); an empty list stays
	# empty (Java checks null, not emptiness).
	var keeps: Dictionary = beam_drill_build_state.source_beam_drill_blocked_items_state("thorium", ["copper", "lead"])
	var keeps_list: Variant = keeps.get("blocked_items_after", null)
	var keeps_empty: Dictionary = beam_drill_build_state.source_beam_drill_blocked_items_state("thorium", [])
	var keeps_empty_list: Variant = keeps_empty.get("blocked_items_after", null)
	proof["blocked_init_keeps"] = keeps_list is Array and (keeps_list as Array) == ["copper", "lead"] and keeps_empty_list is Array and (keeps_empty_list as Array).is_empty()

	# --- Init null: both null stays null (the case for
	# both BeamDrill defs -- neither sets either field);
	# a null item with a set list leaves the list alone.
	var both_null: Dictionary = beam_drill_build_state.source_beam_drill_blocked_items_state(null, null)
	var null_item: Dictionary = beam_drill_build_state.source_beam_drill_blocked_items_state(null, ["lead"])
	var null_item_list: Variant = null_item.get("blocked_items_after", null)
	proof["blocked_init_null"] = both_null.get("blocked_items_after", []) == null and null_item_list is Array and (null_item_list as Array) == ["lead"]

	# --- Multiplier hit: the mapped value comes back
	# (beryllium 2.0, the BurstDrill def value, in a
	# caller-supplied map); a second entry reads its own
	# value (tungsten 0.5) -- the lookup is per item.
	var hit: Dictionary = beam_drill_build_state.source_beam_drill_drill_multiplier_state("beryllium", {"beryllium": 2.0, "tungsten": 0.5})
	var hit_other: Dictionary = beam_drill_build_state.source_beam_drill_drill_multiplier_state("tungsten", {"beryllium": 2.0, "tungsten": 0.5})
	proof["multiplier_hit"] = is_equal_approx(float(hit.get("multiplier", -1.0)), 2.0) and is_equal_approx(float(hit_other.get("multiplier", -1.0)), 0.5)

	# --- Multiplier default: an unmapped item reads 1.0
	# (copper in a beryllium-only map); an empty map
	# reads 1.0 for any item; a null item reads 1.0
	# (the ObjectFloatMap null-key early return -- the
	# updateTile lastItem-null case).
	var miss: Dictionary = beam_drill_build_state.source_beam_drill_drill_multiplier_state("copper", {"beryllium": 2.0})
	var empty_map: Dictionary = beam_drill_build_state.source_beam_drill_drill_multiplier_state("copper", {})
	var null_item_mult: Dictionary = beam_drill_build_state.source_beam_drill_drill_multiplier_state(null, {"beryllium": 2.0})
	proof["multiplier_default"] = is_equal_approx(float(miss.get("multiplier", -1.0)), 1.0) and is_equal_approx(float(empty_map.get("multiplier", -1.0)), 1.0) and is_equal_approx(float(null_item_mult.get("multiplier", -1.0)), 1.0)

	# --- Multiplier def: the BeamDrill def map is empty
	# (neither plasma-bore nor large-plasma-bore sets a
	# drillMultipliers entry, Blocks.java:3038-3068), so
	# every item -- beryllium included, despite the
	# BurstDrill defs mapping it to 2f -- reads the
	# default 1.0, and the per-def drillTime (160f /
	# 100f, Blocks.java:3042/3055) divides by 1.0.
	var def_beryllium: Dictionary = beam_drill_build_state.source_beam_drill_drill_multiplier_state("beryllium", {})
	var def_copper: Dictionary = beam_drill_build_state.source_beam_drill_drill_multiplier_state("copper", {})
	proof["multiplier_def"] = is_equal_approx(float(def_beryllium.get("multiplier", -1.0)), 1.0) and is_equal_approx(float(def_copper.get("multiplier", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillMultipliersBlockedItemRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
