extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
const drill_runtime_state := preload("res://src/game/SourceDrillRuntimeState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _tile(drop: Variant) -> Dictionary:
	return {"drop": drop, "is_static": false}


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

	# --- Pure BurstDrill-owned ore / dominant-item binding (N2262):
	# DrillBuild.onProximityUpdate (Drill.java:266-277,
	# `public void onProximityUpdate(){` with
	# `super.onProximityUpdate();` / `countOre(tile);` /
	# `dominantItem = returnItem;` / `dominantItems =
	# returnCount;`) is inherited whole by BurstDrillBuild
	# (BurstDrill.java:17, `public class BurstDrill
	# extends Drill{`, with BurstDrillBuild,
	# BurstDrill.java:70, `public class BurstDrillBuild
	# extends DrillBuild{`) -- BurstDrill does not override
	# it. countOre (Drill.java:198-229, `protected void
	# countOre(Tile tile){`) counts the drop of every linked
	# tile canMine accepts and peeks the last item after
	# the low-priority / count / id sort
	# (`returnItem = itemArray.peek();` /
	# `returnCount = oreCount.get(itemArray.peek(), 0);`).
	# canMine (Drill.java:230-235) requires a drop whose
	# hardness is at most the tier and which is not blocked
	# (`return drops != null && drops.hardness <= tier &&
	# (blockedItems == null ||
	# !blockedItems.contains(drops));`). Drill.init
	# (Drill.java:93-94) turns a lone blockedItem into the
	# list (`if(blockedItems == null && blockedItem !=
	# null){` / `blockedItems = Seq.with(blockedItem);`).
	# The gate delegates to the N2010/N2020 core
	# (SourceDrillRuntimeState.
	# source_on_proximity_update_state) instead of porting
	# countOre again -- one pure function, one owner. The
	# per-def tier / blockedItem are explicit params (the
	# N2212 / N2248 per-def-param precedent): impact-drill
	# tier 6 (`tier = 6;`, Blocks.java:3076) with
	# blockedItem thorium (`blockedItem = Items.thorium;`,
	# Blocks.java:3080); eruption-drill tier 7 (`tier =
	# 7;`, Blocks.java:3097) with no blocked item. The
	# live driver already stamps the frame: the placement
	# callback (SourceWorldTerrainRuntimeState.gd:116)
	# calls SourceDrillConsumptionRuntimeState.
	# source_on_proximity_update_state for every placed
	# build, and that driver stamps frame["dominant_item"]
	# / frame["dominant_items"] under the shared meta key
	# "source_drill_building" -- the same key as
	# SOURCE_BURST_DRILL_BUILDING_META_KEY -- so the
	# burst-drill frame IS the drill frame. The driver
	# gate is the catalog key, not the value: it returns
	# {"applied": false} only when block.properties lacks
	# "blockedItems", and the catalog carries that key
	# (null-valued) for BOTH defs, so applied is true for
	# both. The proof calls the pure function
	# source_burst_drill_on_proximity_update_state(
	# linked_tiles, tier, blocked_items) directly with
	# tiles built from the real catalog item facts, and
	# reads the real catalog block properties for the
	# gate. There is no pickedUp key and no placed-sprite
	# live-run key: the pickedUp reset and the
	# placed-sprite run wait for their own slices.

	# Real catalog (the same script the game loads at
	# startup): the item facts carry the real ids and
	# hardnesses (copper id 0 hardness 1, titanium id 6
	# hardness 3, thorium id 7 hardness 4, sand id 4
	# hardness 0 low_priority true).
	var catalog = content_registry_state.content_catalog_script.new()
	var items: Dictionary = content_registry_state.source_item_catalog_state(catalog)
	var impact = catalog.get_by_id("impact-drill")
	var eruption = catalog.get_by_id("eruption-drill")
	var fields: Dictionary = items["item_facts_by_field"]
	var thorium: Dictionary = fields["thorium"]
	var copper: Dictionary = fields["copper"]
	var titanium: Dictionary = fields["titanium"]
	var sand: Dictionary = fields["sand"]

	# Impact-drill catalog properties carry the blockedItems
	# key (the live driver's applied gate): blockedItem is
	# thorium, tier is 6.
	proof["catalog_impact_blocked_items_key"] = impact != null and bool(impact.properties.has("blockedItems")) and str(impact.properties.get("blockedItem", "")) == "thorium" and int(impact.properties.get("tier", -1)) == 6

	# Eruption-drill catalog properties carry the blockedItems
	# key too -- null-valued, like blockedItem -- so the
	# driver's has() gate passes and applied is true; tier
	# is 7.
	proof["catalog_eruption_blocked_items_key"] = eruption != null and bool(eruption.properties.has("blockedItems")) and eruption.properties.get("blockedItem", "x") == null and eruption.properties.get("blockedItems", "x") == null and int(eruption.properties.get("tier", -1)) == 7

	# Bind resolution (the exact helper the live driver calls
	# right after the gate): impact resolves to blocked_items
	# [thorium], eruption to blocked_items null -- no assert
	# trips, because both defs carry both keys.
	var impact_blocked: Dictionary = drill_runtime_state.source_bind_ore_items_state(impact, items)
	proof["bind_impact_thorium_blocked"] = impact_blocked.get("blocked_items") != null and (impact_blocked.get("blocked_items") as Array) == [int(thorium.get("id", -1))]
	var eruption_blocked: Dictionary = drill_runtime_state.source_bind_ore_items_state(eruption, items)
	proof["bind_eruption_null_blocked"] = eruption_blocked.get("blocked_items", "x") == null

	# Impact excludes thorium: tier 6 with blocked [thorium]
	# over thorium x3 + copper x2 + titanium x1 -- thorium
	# (hardness 4 <= 6) would dominate unblocked with count
	# 3, but blocked it is excluded, so copper wins with
	# count 2 over titanium count 1.
	var impact_tiles: Array = [_tile(thorium), _tile(thorium), _tile(thorium), _tile(copper), _tile(copper), _tile(titanium)]
	var impact_bound: Dictionary = burst_drill_build_state.source_burst_drill_on_proximity_update_state(impact_tiles, 6, [int(thorium.get("id", -1))])
	var impact_dominant: Variant = impact_bound.get("dominant_item")
	proof["delegate_impact_excludes_thorium"] = impact_dominant != null and int(impact_dominant.get("id", -1)) == int(copper.get("id", -2)) and int(impact_bound.get("dominant_items", -1)) == 2

	# Eruption counts thorium: tier 7 with blocked null over
	# thorium x3 + copper x2 -- thorium (hardness 4 <= 7)
	# dominates with count 3.
	var eruption_tiles: Array = [_tile(thorium), _tile(thorium), _tile(thorium), _tile(copper), _tile(copper)]
	var eruption_bound: Dictionary = burst_drill_build_state.source_burst_drill_on_proximity_update_state(eruption_tiles, 7, null)
	var eruption_dominant: Variant = eruption_bound.get("dominant_item")
	proof["delegate_eruption_counts_thorium"] = eruption_dominant != null and int(eruption_dominant.get("id", -1)) == int(thorium.get("id", -2)) and int(eruption_bound.get("dominant_items", -1)) == 3

	# Empty, tie-break and low-priority: no tiles gives
	# null / 0; a count tie between copper (id 0) and
	# titanium (id 6) goes to the higher id; a count tie
	# between low-priority sand and copper goes to copper.
	var empty_bound: Dictionary = burst_drill_build_state.source_burst_drill_on_proximity_update_state([], 6, null)
	var tie_bound: Dictionary = burst_drill_build_state.source_burst_drill_on_proximity_update_state([_tile(copper), _tile(titanium)], 6, null)
	var tie_dominant: Variant = tie_bound.get("dominant_item")
	var low_bound: Dictionary = burst_drill_build_state.source_burst_drill_on_proximity_update_state([_tile(sand), _tile(copper)], 6, null)
	var low_dominant: Variant = low_bound.get("dominant_item")
	proof["delegate_empty_tiebreak_low_priority"] = empty_bound.get("dominant_item") == null and int(empty_bound.get("dominant_items", -1)) == 0 and tie_dominant != null and int(tie_dominant.get("id", -1)) == int(titanium.get("id", -2)) and int(tie_bound.get("dominant_items", -1)) == 1 and low_dominant != null and int(low_dominant.get("id", -1)) == int(copper.get("id", -2)) and int(low_bound.get("dominant_items", -1)) == 1

	# Round-trip into the N2294 updateTile advance: a frame
	# stamped with the bound dominant (copper, count 2)
	# advances instead of taking the early return -- the
	# same numbers as the N2294 lerp case (drillTime 720f,
	# multiplier 2f, progress 100.0 -> 101.75).
	var stamped: Dictionary = {"dominant_item": impact_bound.get("dominant_item"), "dominant_items": impact_bound.get("dominant_items", 0), "invert_time": 0.0, "smooth_progress": 0.0, "progress": 100.0, "warmup": 0.0, "time_drilled": 0.0, "last_drill_speed": 0.0, "efficiency": 1.0, "optional_efficiency": 1.0, "items_total": 0.0, "dump_timer": 0.0}
	var advanced: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_state(stamped, 1.0, 720.0, 2.0, 200.0, 1.75, 40.0, 5.0)
	proof["roundtrip_update_tile_advances"] = is_equal_approx(float(advanced.get("smooth_progress", -1.0)), 0.0294118) and is_equal_approx(float(advanced.get("warmup", -1.0)), 0.01) and is_equal_approx(float(advanced.get("time_drilled", -1.0)), 0.13503086) and is_equal_approx(float(advanced.get("last_drill_speed", -1.0)), 0.00972222) and is_equal_approx(float(advanced.get("progress", -1.0)), 101.75) and bool(advanced.get("invert_fired", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillOnProximityUpdateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
