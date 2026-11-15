extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
const drill_build_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
const placed_state := preload("res://src/game/SourcePlacedBlockState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	# --- Pure gate (N2203): BurstDrillBuild.shouldConsume()
	# (BurstDrill.java:128, `public boolean shouldConsume(){`
	# with `return items.total() <= itemCapacity -
	# dominantItems && enabled;`, BurstDrill.java:129) -- the
	# burst drill consumes only while its items total fits the
	# remaining capacity AFTER reserving the dominant-items
	# burst AND it is enabled. The `<=` (not `<`) and the `-
	# dominantItems` are the override's whole point -- the
	# base-Drill gate (Drill.java:247-249, `return items.
	# total() < itemCapacity && enabled && dominantItem !=
	# null;`) does NOT apply to BurstDrill: BurstDrill
	# extends Drill (BurstDrill.java:17) and BurstDrillBuild
	# extends DrillBuild (BurstDrill.java:70), so the override
	# wins. The gate reads the SHARED drill frame
	# ("source_drill_building"): the drill proximity path
	# binds it at placement with items/dominant_items/enabled
	# already present and sets dominant_items from the ore
	# count (Drill.java:277, `dominantItems = returnCount;`),
	# so the burst-drill bind in the tick returns
	# applied=false. itemCapacity comes from the block
	# properties (eruption 60, impact 40, Block.java default
	# 10). The pure calls below use the eruption capacity 60.
	var open_gate: Dictionary = burst_drill_build_state.source_burst_drill_should_consume_state({"items": {"copper": 10}, "dominant_items": 5, "enabled": true}, 60)
	proof["gate_open_below_threshold"] = bool(open_gate.get("should_consume", false)) and int(open_gate.get("items_total", -1)) == 10

	var over_gate: Dictionary = burst_drill_build_state.source_burst_drill_should_consume_state({"items": {"copper": 56}, "dominant_items": 5, "enabled": true}, 60)
	proof["gate_closed_when_over_threshold"] = bool(over_gate.get("should_consume", true)) == false and int(over_gate.get("items_total", -1)) == 56

	var boundary_gate: Dictionary = burst_drill_build_state.source_burst_drill_should_consume_state({"items": {"copper": 55}, "dominant_items": 5, "enabled": true}, 60)
	proof["gate_open_at_boundary"] = bool(boundary_gate.get("should_consume", false)) and int(boundary_gate.get("items_total", -1)) == 55

	var disabled_gate: Dictionary = burst_drill_build_state.source_burst_drill_should_consume_state({"items": {}, "dominant_items": 5, "enabled": false}, 60)
	proof["gate_closed_when_disabled"] = bool(disabled_gate.get("should_consume", true)) == false and int(disabled_gate.get("items_total", -1)) == 0

	# --- Live tick: the eruption-drill is a BurstDrill with a
	# power consumer (consumePower 6f, itemCapacity 60),
	# placed live on copper ore; the tick driver is called
	# directly (as the N2149/N2188 proofs do), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. The frame["items"]
	# are set directly (the live items fill waits for the
	# updateTile advance slice, like the N2188 proof sets the
	# link directly through the N2197 pure configure); the
	# proximity bind supplies the live dominant_items, so the
	# closed-gate tick proves the `capacity - dominantItems`
	# threshold with a real ore count, not a stubbed one.
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

	# Full inventory: 60 copper is over the 60 - dominant_items
	# threshold for any live dominant_items > 0, so the gate
	# closes and efficiency folds to 0 even at full power.
	eruption_frame["power_status"] = 1.0
	eruption_frame["items"] = {"copper": 60}
	burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)
	eruption_frame = eruption.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	proof["efficiency_zero_when_gate_closed"] = is_equal_approx(float(eruption_frame.get("efficiency", -1.0)), 0.0) and int(eruption_frame.get("dominant_items", 0)) > 0

	# Empty inventory: the gate opens and the old N2149 behavior
	# is kept -- half power folds efficiency to 0.5.
	eruption_frame["power_status"] = 0.5
	eruption_frame["items"] = {}
	burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)
	eruption_frame = eruption.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	proof["efficiency_kept_when_gate_open"] = is_equal_approx(float(eruption_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
