extends Node

const main_scene := preload("res://scenes/Main.tscn")
const solid_pump_build_state := preload("res://src/game/SourceSolidPumpBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
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

	# --- Pure fill (N2292): onProximityUpdate
	# (SolidPump.java:150-159). `boost = sumAttribute(
	# attribute, tile.x, tile.y) / size / size;` (:153) with
	# the deep-floor exclusion inside sumAttribute
	# (Block.java:575-582: attr null -> 0, tile null -> 0,
	# else the sum of floor().attributes over the linked
	# tiles with 0 for deep floors when !floating &&
	# !placeableLiquid), then the canPump scan (:154-158):
	# `validTiles = 0f;` and `validTiles += baseEfficiency /
	# (size * size);` per pumpable linked tile (canPump
	# :80-83, `tile != null && !tile.floor().isLiquid`).
	# The fraction (:124) is `Math.max(validTiles + boost +
	# (attribute == null ? 0 : attribute.env()), 0)` with
	# env() (Attribute.java:31-34) reading
	# Vars.state.envAttrs, 0 when Vars.state is null. The
	# water-extractor def (Blocks.java:2920-2930) sets size
	# 2, attribute Attribute.water, and leaves floating /
	# placeableLiquid at the Block class defaults false
	# (Block.java:212 / :152), so deep floors contribute 0
	# for it. Every case below uses size 2 and
	# baseEfficiency 1f, so size * size is 4 and each
	# pumpable tile contributes 0.25 to validTiles.

	# Valid tiles count pumpable tiles: 3 of 4 pumpable
	# gives 3 * 1.0 / 4 = 0.75; all 4 pumpable gives 1.0;
	# none pumpable gives 0.0. A liquid-floor tile
	# (can_pump false) contributes nothing even with a
	# nonzero attribute value -- the validTiles scan only
	# counts canPump tiles.
	var three_tiles: Array = [
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 1.0, "is_deep": false},
	]
	var three: Dictionary = solid_pump_build_state.source_solid_pump_proximity_fraction_state(three_tiles, 2, 1.0, 0.0, false, false, true)
	var all_tiles: Array = [
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
	]
	var all: Dictionary = solid_pump_build_state.source_solid_pump_proximity_fraction_state(all_tiles, 2, 1.0, 0.0, false, false, true)
	var none_tiles: Array = [
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
	]
	var none: Dictionary = solid_pump_build_state.source_solid_pump_proximity_fraction_state(none_tiles, 2, 1.0, 0.0, false, false, true)
	proof["valid_tiles_counts_pumpable"] = is_equal_approx(float(three.get("valid_tiles", -1.0)), 0.75) and is_equal_approx(float(all.get("valid_tiles", -1.0)), 1.0) and is_equal_approx(float(none.get("valid_tiles", -1.0)), 0.0)

	# Boost sums the attributes: values 0.5 / 0.25 / 0.0 /
	# 1.0 sum to 1.75, divided by size * size (4) gives
	# 0.4375. The attribute values add whether or not the
	# tile is pumpable -- the sumAttribute scan has no
	# canPump gate (Block.java:579-580). With no attribute
	# (has_attribute false) the boost is 0 even with
	# nonzero values (Block.java:576, `if(attr == null)
	# return 0;`).
	var boost_tiles: Array = [
		{"can_pump": true, "attribute_value": 0.5, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.25, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 1.0, "is_deep": false},
	]
	var boosted: Dictionary = solid_pump_build_state.source_solid_pump_proximity_fraction_state(boost_tiles, 2, 1.0, 0.0, false, false, true)
	var no_attr: Dictionary = solid_pump_build_state.source_solid_pump_proximity_fraction_state(boost_tiles, 2, 1.0, 0.0, false, false, false)
	proof["boost_sums_attributes"] = is_equal_approx(float(boosted.get("boost", -1.0)), 0.4375) and is_equal_approx(float(no_attr.get("boost", -1.0)), 0.0)

	# Deep floors are excluded when not floating: a deep
	# tile with attribute 1.0 contributes 0 when floating is
	# false and placeableLiquid is false (Block.java:580),
	# so the boost is 0.0. A floating block counts it
	# (1.0 / 4 = 0.25), and a placeable-liquid block counts
	# it too (0.25). The water-extractor def leaves both
	# flags false, so it takes the excluded branch.
	var deep_tiles: Array = [
		{"can_pump": true, "attribute_value": 1.0, "is_deep": true},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
	]
	var grounded: Dictionary = solid_pump_build_state.source_solid_pump_proximity_fraction_state(deep_tiles, 2, 1.0, 0.0, false, false, true)
	var floating: Dictionary = solid_pump_build_state.source_solid_pump_proximity_fraction_state(deep_tiles, 2, 1.0, 0.0, true, false, true)
	var placeable: Dictionary = solid_pump_build_state.source_solid_pump_proximity_fraction_state(deep_tiles, 2, 1.0, 0.0, false, true, true)
	proof["deep_floor_excluded_when_not_floating"] = is_equal_approx(float(grounded.get("boost", -1.0)), 0.0) and is_equal_approx(float(floating.get("boost", -1.0)), 0.25) and is_equal_approx(float(placeable.get("boost", -1.0)), 0.25)

	# The fraction clamps at zero: with no tiles and a
	# negative env (-0.5) the sum is -0.5, so the fraction
	# is 0.0, not -0.5 (SolidPump.java:124, Math.max(...,
	# 0)). With validTiles 0.75 and env -2.0 the sum is
	# -1.25, so the fraction is again 0.0.
	var empty: Dictionary = solid_pump_build_state.source_solid_pump_proximity_fraction_state([], 2, 1.0, -0.5, false, false, true)
	var negative: Dictionary = solid_pump_build_state.source_solid_pump_proximity_fraction_state(three_tiles, 2, 1.0, -2.0, false, false, true)
	proof["fraction_clamps_at_zero"] = is_equal_approx(float(empty.get("fraction", -1.0)), 0.0) and is_equal_approx(float(negative.get("fraction", -1.0)), 0.0)

	# The env adds when the attribute is present: 2
	# pumpable tiles (validTiles 0.5) plus attribute values
	# summing to 1.0 (boost 0.25) plus env 0.3 gives
	# fraction 1.05. With no attribute the env is ignored
	# (SolidPump.java:124, `attribute == null ? 0 :
	# attribute.env()`), so the same tiles with env 0.3 give
	# fraction 0.5 -- validTiles alone, boost 0.
	var env_tiles: Array = [
		{"can_pump": true, "attribute_value": 0.5, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.5, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
	]
	var with_env: Dictionary = solid_pump_build_state.source_solid_pump_proximity_fraction_state(env_tiles, 2, 1.0, 0.3, false, false, true)
	var without_attr: Dictionary = solid_pump_build_state.source_solid_pump_proximity_fraction_state(env_tiles, 2, 1.0, 0.3, false, false, false)
	proof["env_adds_when_attribute_present"] = is_equal_approx(float(with_env.get("fraction", -1.0)), 1.05) and is_equal_approx(float(without_attr.get("fraction", -1.0)), 0.5) and is_equal_approx(float(without_attr.get("boost", -1.0)), 0.0)

	# --- Live tick: a water-extractor placed live; the tick
	# driver is called directly (as the N2150/N2206 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. One 1/60s tick is one
	# source tick: efficiency folds the power min 0.5, the
	# fill runs BEFORE the advance (Java order:
	# onProximityUpdate stamps validTiles / boost,
	# SolidPump.java:150-159, and updateTile reads them at
	# :124), so with 3 pumpable tiles (validTiles 0.75),
	# attribute values 0.5 / 0.25 / 0.0 plus a deep tile
	# excluded (boost 0.1875), and env 0.3, the frame reads
	# valid_tiles 0.75, boost 0.1875, and fraction 1.2375
	# after one tick. The proximity tiles and the env are
	# frame inputs, stamped here like the N2228 targets
	# precedent.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var extractor_cell := Vector2i(28, 20)
	var extractor := Sprite2D.new()
	game.add_child(extractor)
	game.call("record_placed_block", extractor, blocks_by_id["water-extractor"], extractor_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the proximity inputs on it).
	solid_pump_build_state.source_solid_pump_bind_frame_state(extractor, blocks_by_id["water-extractor"])
	var extractor_frame: Dictionary = extractor.get_meta(solid_pump_build_state.SOURCE_SOLID_PUMP_BUILDING_META_KEY, {})

	# Initialize the liquids meta explicitly (record_placed_block
	# already does this for hasLiquids blocks, but the proof
	# re-initializes to a known-empty store). The driver
	# refreshes frame["liquids"] from this meta each tick.
	placed_block_state.source_initialize_building_liquids_state(extractor, true, game.get("content_catalog"))

	extractor_frame["power_status"] = 0.5
	extractor_frame["attribute_env"] = 0.3
	extractor_frame["proximity_linked_tiles"] = [
		{"can_pump": true, "attribute_value": 0.5, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.25, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 1.0, "is_deep": true},
	]
	solid_pump_build_state.source_solid_pump_tick_buildings_state(game, 1.0 / 60.0)
	extractor_frame = extractor.get_meta(solid_pump_build_state.SOURCE_SOLID_PUMP_BUILDING_META_KEY, {})
	proof["live_tick_fills_fraction"] = is_equal_approx(float(extractor_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(extractor_frame.get("valid_tiles", -1.0)), 0.75) and is_equal_approx(float(extractor_frame.get("boost", -1.0)), 0.1875) and is_equal_approx(float(extractor_frame.get("fraction", -1.0)), 1.2375)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SolidPumpFractionFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
