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

	# --- Pure fill (N2453): the live attribute-env fill that
	# fills frame["attribute_env"] (DEFERRED #216), which the
	# N2305 tick recomputes the fraction from each enabled
	# tick. Java: the fraction adds the attribute env
	# (`float fraction = Math.max(validTiles + boost +
	# (attribute == null ? 0 : attribute.env()), 0);`,
	# SolidPump.java:124), and Attribute.env() returns 0
	# when Vars.state is null and otherwise reads the
	# state's envAttrs (`if(Vars.state == null) return 0;`
	# / `return Vars.state.envAttrs.get(this);`,
	# Attribute.java:32-33). envAttrs is an Attributes
	# (`public Attributes envAttrs = new Attributes();`,
	# GameState.java:43) -- a float array indexed by
	# attribute id, NOT a map (`return arr[attr.id];`,
	# Attributes.java:18), so a missing / unset key reads
	# the array default 0.0, never null. The fracker
	# attribute is oil (`attribute = Attribute.oil;`,
	# Blocks.java:2972 -- the oil-extractor DEF sets it;
	# the Fracker CLASS sets none). The port has no
	# envAttrs model, so the pure's input contract is the
	# MINIMAL extension (the N2414 precedent): env_attrs is
	# a Dict keyed by attribute NAME (e.g. {"oil": 0.5}),
	# state_present is the Vars.state-null guard, and no
	# live producer stamps those frame inputs yet (the
	# producer gap is documented, not invented here).

	# Env present: the oil value reads through.
	var filled_present: float = fracker_build_state.source_fracker_attribute_env_live_fill_state({"oil": 0.5}, true).get("attribute_env", -1.0)
	proof["env_present"] = is_equal_approx(filled_present, 0.5)

	# A missing key reads 0.0: an empty map fills 0.0 (the
	# float-array default, Attributes.java:18), and a map
	# carrying only another attribute (heat) still reads
	# 0.0 for oil -- the fill reads the "oil" key only.
	var filled_empty: float = fracker_build_state.source_fracker_attribute_env_live_fill_state({}, true).get("attribute_env", -1.0)
	var filled_other: float = fracker_build_state.source_fracker_attribute_env_live_fill_state({"heat": 0.9}, true).get("attribute_env", -1.0)
	proof["env_missing_key"] = is_equal_approx(filled_empty, 0.0) and is_equal_approx(filled_other, 0.0)

	# No state reads 0.0 exact: state_present false is the
	# Vars.state == null branch (Attribute.java:32), so even
	# a map carrying oil 0.5 fills 0.0.
	var filled_no_state: float = fracker_build_state.source_fracker_attribute_env_live_fill_state({"oil": 0.5}, false).get("attribute_env", -1.0)
	proof["env_no_state"] = is_equal_approx(filled_no_state, 0.0)

	# The filled env enters the fraction: the N2305 fraction
	# pure with no linked tiles reads fraction 0.3 from env
	# 0.3 (max(0 + 0 + 0.3, 0)) and 0.0 from env 0.0 -- the
	# env is the only fraction term when the proximity is
	# empty (baseEfficiency 0f, so validTiles is always 0).
	var fraction_with_env: float = fracker_build_state.source_fracker_proximity_fraction_state([], 0.3).get("fraction", -1.0)
	var fraction_without_env: float = fracker_build_state.source_fracker_proximity_fraction_state([], 0.0).get("fraction", -1.0)
	proof["env_fraction_effect"] = is_equal_approx(fraction_with_env, 0.3) and is_equal_approx(fraction_without_env, 0.0)

	# --- Live tick: two oil-extractors placed live; the tick
	# driver is called directly (as the N2153/N2207 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. One 1/60s tick is one
	# source tick: efficiency folds the power min 0.5 (water
	# 0.3 seeded so the water row is 1.0, 1 sand seeded so
	# the sand row is 1.0), the fill runs BEFORE the N2305
	# recompute (Java order: onProximityUpdate stamps
	# validTiles / boost, SolidPump.java:150-159, and
	# updateTile reads them at :124). The first extractor
	# seeds env_attrs {"oil": 0.3} with state_present true
	# and NO attribute_env seed, so the fill stamps
	# attribute_env 0.3 live; with the tile map seeding oil
	# attribute values 0.9 / 0.45 / 0.45 (boost 0.2), a deep
	# tile excluded, the frame reads valid_tiles 0.0
	# (baseEfficiency 0f), boost 0.2, and fraction 0.5 after
	# one tick -- and the pump moves oil (max_pump 0.0625 =
	# 0.25 * 1 * 0.5 * 0.5). The second extractor seeds
	# attribute_env 0.7 by hand (the N2224/N2305 proof
	# pattern) with env_attrs {"oil": 0.3}: the supplied
	# value WINS (the N2381 precedent), so the frame keeps
	# 0.7 and carries no attribute_env_live flag.
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
	# the tile-map input on it).
	fracker_build_state.source_fracker_bind_frame_state(extractor, blocks_by_id["oil-extractor"])
	var extractor_frame: Dictionary = extractor.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	var extractor_liquids: Dictionary = extractor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(extractor_liquids, water_id, 0.3)

	extractor_frame["items"] = {"sand": 1}
	extractor_frame["power_status"] = 0.5
	extractor_frame["env_attrs"] = {"oil": 0.3}
	extractor_frame["state_present"] = true
	extractor_frame["world_tiles"] = {
		"27,19": {"floor_is_liquid": false, "oil_attribute": 0.9, "is_deep": false},
		"27,20": {"floor_is_liquid": false, "oil_attribute": 0.45, "is_deep": false},
		"27,21": {"floor_is_liquid": false, "oil_attribute": 0.45, "is_deep": false},
		"28,19": {"floor_is_liquid": false, "oil_attribute": 0.0, "is_deep": false},
		"28,20": {"floor_is_liquid": false, "oil_attribute": 1.0, "is_deep": true},
	}

	var seeded_cell := Vector2i(24, 20)
	var seeded := Sprite2D.new()
	game.add_child(seeded)
	game.call("record_placed_block", seeded, blocks_by_id["oil-extractor"], seeded_cell)
	fracker_build_state.source_fracker_bind_frame_state(seeded, blocks_by_id["oil-extractor"])
	var seeded_frame: Dictionary = seeded.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	var seeded_liquids: Dictionary = seeded.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(seeded_liquids, water_id, 0.3)

	seeded_frame["items"] = {"sand": 1}
	seeded_frame["power_status"] = 0.5
	seeded_frame["attribute_env"] = 0.7
	seeded_frame["env_attrs"] = {"oil": 0.3}
	seeded_frame["state_present"] = true

	fracker_build_state.source_fracker_tick_buildings_state(game, 1.0 / 60.0)
	extractor_frame = extractor.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	seeded_frame = seeded.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	proof["env_live_tick"] = extractor_frame.get("attribute_env_live", false) == true and is_equal_approx(float(extractor_frame.get("attribute_env", -1.0)), 0.3) and is_equal_approx(float(extractor_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(extractor_frame.get("valid_tiles", -1.0)), 0.0) and is_equal_approx(float(extractor_frame.get("boost", -1.0)), 0.2) and is_equal_approx(float(extractor_frame.get("fraction", -1.0)), 0.5) and float(extractor_frame.get("max_pump", 0.0)) > 0.0
	proof["env_supplied_wins"] = is_equal_approx(float(seeded_frame.get("attribute_env", -1.0)), 0.7) and seeded_frame.get("attribute_env_live", false) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07FrackerAttributeEnvLiveFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
