extends Node

const main_scene := preload("res://scenes/Main.tscn")
const fracker_build_state := preload("res://src/game/SourceFrackerBuildState.gd")
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

	# --- Pure fill (N2305): onProximityUpdate
	# (SolidPump.java:150-159), INHERITED by FrackerBuild --
	# Fracker does NOT override it (Fracker.java has no
	# onProximityUpdate; Fracker extends SolidPump,
	# Fracker.java:7). `boost = sumAttribute(attribute,
	# tile.x, tile.y) / size / size;` (:153) with the
	# deep-floor exclusion inside sumAttribute
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
	# oil-extractor def (Blocks.java:2964-2979) sets size 3,
	# attribute Attribute.oil (Blocks.java:2972 -- the
	# Fracker CLASS sets no attribute, but the DEF does),
	# and baseEfficiency 0f (Blocks.java:2973 -- overriding
	# the class default 1f), and leaves floating /
	# placeableLiquid at the Block class defaults false
	# (Block.java:212 / :152), so deep floors contribute 0
	# for it. Because baseEfficiency is 0f, validTiles is
	# ALWAYS 0 for the oil-extractor: the fraction is boost
	# + env only. Every case below uses size 3 and
	# baseEfficiency 0f, so size * size is 9 and each
	# pumpable tile contributes 0.0 to validTiles.

	# Valid tiles stay zero with zero baseEfficiency: all 9
	# pumpable gives 0.0, 3 of 9 pumpable gives 0.0, and
	# even pumpable tiles carrying nonzero oil attribute
	# values give 0.0 -- `validTiles += baseEfficiency /
	# (size * size);` adds 0.0 per tile when
	# baseEfficiency is 0f (Blocks.java:2973). The boost
	# still sums on the same tiles (key below).
	var all_tiles: Array = [
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
	]
	var all: Dictionary = fracker_build_state.source_fracker_proximity_fraction_state(all_tiles, 0.0)
	var three_tiles: Array = [
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
	]
	var three: Dictionary = fracker_build_state.source_fracker_proximity_fraction_state(three_tiles, 0.0)
	var valued_tiles: Array = [
		{"can_pump": true, "attribute_value": 0.9, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.45, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.45, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
	]
	var valued: Dictionary = fracker_build_state.source_fracker_proximity_fraction_state(valued_tiles, 0.0)
	proof["valid_tiles_zero_with_zero_base_efficiency"] = is_equal_approx(float(all.get("valid_tiles", -1.0)), 0.0) and is_equal_approx(float(three.get("valid_tiles", -1.0)), 0.0) and is_equal_approx(float(valued.get("valid_tiles", -1.0)), 0.0) and is_equal_approx(float(valued.get("boost", -1.0)), 0.2)

	# Boost sums the oil attributes: values 0.9 / 0.45 /
	# 0.45 sum to 1.8, divided by size * size (9) gives
	# 0.2. The attribute values add whether or not the
	# tile is pumpable -- the sumAttribute scan has no
	# canPump gate (Block.java:579-580) -- so the 0.45 on
	# the non-pumpable tile counts too. With no tiles the
	# boost is 0.0.
	var boost_tiles: Array = [
		{"can_pump": true, "attribute_value": 0.9, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.45, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.45, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
	]
	var boosted: Dictionary = fracker_build_state.source_fracker_proximity_fraction_state(boost_tiles, 0.0)
	var no_tiles: Dictionary = fracker_build_state.source_fracker_proximity_fraction_state([], 0.0)
	proof["boost_sums_oil_attributes"] = is_equal_approx(float(boosted.get("boost", -1.0)), 0.2) and is_equal_approx(float(no_tiles.get("boost", -1.0)), 0.0)

	# Deep floors are excluded when not floating: a deep
	# tile with attribute 0.9 contributes 0 when floating is
	# false and placeableLiquid is false (Block.java:580),
	# so the boost is 0.0. The same tile non-deep counts
	# (0.9 / 9 = 0.1). The oil-extractor def leaves both
	# flags false, so it takes the excluded branch; the
	# floating / placeable-liquid branches are proven by
	# the N2292 SolidPump proof, which the Fracker pure
	# delegates to.
	var deep_tiles: Array = [
		{"can_pump": true, "attribute_value": 0.9, "is_deep": true},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
	]
	var grounded: Dictionary = fracker_build_state.source_fracker_proximity_fraction_state(deep_tiles, 0.0)
	var shallow_tiles: Array = [
		{"can_pump": true, "attribute_value": 0.9, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
	]
	var shallow: Dictionary = fracker_build_state.source_fracker_proximity_fraction_state(shallow_tiles, 0.0)
	proof["deep_floor_excluded_when_not_floating"] = is_equal_approx(float(grounded.get("boost", -1.0)), 0.0) and is_equal_approx(float(shallow.get("boost", -1.0)), 0.1)

	# The fraction clamps at zero: with no tiles and a
	# negative env (-0.5) the sum is -0.5, so the fraction
	# is 0.0, not -0.5 (SolidPump.java:124, Math.max(...,
	# 0)). With boost 0.2 and env -2.0 the sum is -1.8, so
	# the fraction is again 0.0.
	var empty: Dictionary = fracker_build_state.source_fracker_proximity_fraction_state([], -0.5)
	var negative: Dictionary = fracker_build_state.source_fracker_proximity_fraction_state(boost_tiles, -2.0)
	proof["fraction_clamps_at_zero"] = is_equal_approx(float(empty.get("fraction", -1.0)), 0.0) and is_equal_approx(float(negative.get("fraction", -1.0)), 0.0)

	# The env adds when the attribute is present: boost
	# 0.2 plus env 0.3 gives fraction 0.5 (validTiles is
	# 0.0 -- baseEfficiency 0f). The same tiles with env
	# 0.0 give fraction 0.2. The oil attribute is present
	# for the oil-extractor def (`attribute =
	# Attribute.oil;`, Blocks.java:2972), so the env always
	# adds (SolidPump.java:124, `attribute == null ? 0 :
	# attribute.env()`); the null-attribute branch is
	# proven by the N2292 SolidPump proof.
	var with_env: Dictionary = fracker_build_state.source_fracker_proximity_fraction_state(boost_tiles, 0.3)
	var without_env: Dictionary = fracker_build_state.source_fracker_proximity_fraction_state(boost_tiles, 0.0)
	proof["env_adds_when_attribute_present"] = is_equal_approx(float(with_env.get("fraction", -1.0)), 0.5) and is_equal_approx(float(without_env.get("fraction", -1.0)), 0.2)

	# --- Live tick: an oil-extractor placed live; the tick
	# driver is called directly (as the N2153/N2207 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. One 1/60s tick is one
	# source tick: efficiency folds the power min 0.5 (water
	# 0.3 seeded so the water row is 1.0, 1 sand seeded so
	# the sand row is 1.0), the fill runs BEFORE the advance
	# (Java order: onProximityUpdate stamps validTiles /
	# boost, SolidPump.java:150-159, and updateTile reads
	# them at :124), so with oil attribute values 0.9 /
	# 0.45 / 0.45 (boost 0.2), a deep tile excluded, and env
	# 0.3, the frame reads valid_tiles 0.0 (baseEfficiency
	# 0f), boost 0.2, and fraction 0.5 after one tick. The
	# proximity tiles and the env are frame inputs, stamped
	# here like the N2228 targets precedent.
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_runtime_state.source_liquid_catalog_state(catalog)
	var water_id: int = int(liquid_catalog["liquid_id_by_name"].get("water", -1))
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var extractor_cell := Vector2i(28, 20)
	var extractor := Sprite2D.new()
	game.add_child(extractor)
	game.call("record_placed_block", extractor, blocks_by_id["oil-extractor"], extractor_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the proximity inputs on it).
	fracker_build_state.source_fracker_bind_frame_state(extractor, blocks_by_id["oil-extractor"])
	var extractor_frame: Dictionary = extractor.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	var extractor_liquids: Dictionary = extractor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(extractor_liquids, water_id, 0.3)

	extractor_frame["items"] = {"sand": 1}
	extractor_frame["power_status"] = 0.5
	extractor_frame["attribute_env"] = 0.3
	extractor_frame["proximity_linked_tiles"] = [
		{"can_pump": true, "attribute_value": 0.9, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.45, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.45, "is_deep": false},
		{"can_pump": true, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 1.0, "is_deep": true},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
		{"can_pump": false, "attribute_value": 0.0, "is_deep": false},
	]
	fracker_build_state.source_fracker_tick_buildings_state(game, 1.0 / 60.0)
	extractor_frame = extractor.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	proof["live_tick_fills_fraction"] = is_equal_approx(float(extractor_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(extractor_frame.get("valid_tiles", -1.0)), 0.0) and is_equal_approx(float(extractor_frame.get("boost", -1.0)), 0.2) and is_equal_approx(float(extractor_frame.get("fraction", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07FrackerFractionFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
