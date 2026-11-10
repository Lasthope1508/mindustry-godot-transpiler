extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var cryofluid_id: int = int(liquid_id_by_name.get("cryofluid", -1))
	var ozone_id: int = int(liquid_id_by_name.get("ozone", -1))
	var hydrogen_id: int = int(liquid_id_by_name.get("hydrogen", -1))

	# --- registry craftTime: the emitter captures the block
	# initializer's own assignment, else the class default 80
	# (GenericCrafter.java:40 `public float craftTime = 80;`):
	# silicon smelter 40 (Blocks.java:1073), graphite press 90
	# (Blocks.java:1045), cryofluid mixer 120 (Blocks.java:1181). ---
	proof["craft_smelter_is_generic_crafter"] = String(blocks_by_id["silicon-smelter"].implementation) == "GenericCrafter"
	proof["craft_smelter_craft_time_40"] = is_equal_approx(float(blocks_by_id["silicon-smelter"].properties.get("craftTime", -1.0)), 40.0)
	proof["craft_press_craft_time_90"] = is_equal_approx(float(blocks_by_id["graphite-press"].properties.get("craftTime", -1.0)), 90.0)
	proof["craft_mixer_craft_time_120"] = is_equal_approx(float(blocks_by_id["cryofluid-mixer"].properties.get("craftTime", -1.0)), 120.0)

	# --- base progress increase: BuildingComp.getProgressIncrease
	# (BuildingComp.java:1203-1205) is `1f / baseTime * edelta()`,
	# edelta() = efficiency * delta() (BuildingComp.java:1927-1929),
	# delta() = Time.delta * timeScale (BuildingComp.java:1922-1924).
	# The port frame delta is in seconds and the port edelta
	# convention (N2112) is seconds * TICK_RATE, so one tick at
	# efficiency 1.0 is edelta 1.0 and a smelter gains 1/40. ---
	var base: Dictionary = factory_build_state.source_factory_progress_increase_state(40.0, 1.0, 1.0 / 60.0, 1.0)
	proof["craft_base_edelta_one"] = is_equal_approx(float(base.get("edelta", -1.0)), 1.0)
	proof["craft_base_increase_smelter"] = is_equal_approx(float(base.get("progress_increase", -1.0)), 1.0 / 40.0)
	var zero_time: Dictionary = factory_build_state.source_factory_progress_increase_state(0.0, 1.0, 1.0 / 60.0, 1.0)
	proof["craft_base_zero_craft_time"] = is_equal_approx(float(zero_time.get("progress_increase", -1.0)), 0.0)
	var half: Dictionary = factory_build_state.source_factory_progress_increase_state(40.0, 0.5, 1.0 / 60.0, 1.0)
	proof["craft_base_half_efficiency"] = is_equal_approx(float(half.get("edelta", -1.0)), 0.5) and is_equal_approx(float(half.get("progress_increase", -1.0)), 0.5 / 40.0)

	# --- GenericCrafter override (GenericCrafter.java:266-285): a
	# block with no output liquids takes the base increase
	# unchanged; a liquid-output block scales by the output-liquid
	# headroom (liquidCapacity - held) / (amount * edelta()). ---
	var smelter_increase: Dictionary = factory_build_state.source_factory_crafter_progress_increase_state(blocks_by_id["silicon-smelter"], {}, liquid_id_by_name, 1.0, 1.0 / 60.0, 1.0)
	proof["craft_smelter_override_increase"] = is_equal_approx(float(smelter_increase.get("progress_increase", -1.0)), 1.0 / 40.0)
	proof["craft_smelter_override_scaling_one"] = is_equal_approx(float(smelter_increase.get("scaling", -1.0)), 1.0)
	var mixer_empty: Dictionary = factory_build_state.source_factory_crafter_progress_increase_state(blocks_by_id["cryofluid-mixer"], {}, liquid_id_by_name, 1.0, 1.0 / 60.0, 1.0)
	proof["craft_mixer_empty_increase"] = is_equal_approx(float(mixer_empty.get("progress_increase", -1.0)), 1.0 / 120.0)
	proof["craft_mixer_empty_scaling_one"] = is_equal_approx(float(mixer_empty.get("scaling", -1.0)), 1.0)
	var mixer_full: Dictionary = factory_build_state.source_factory_crafter_progress_increase_state(blocks_by_id["cryofluid-mixer"], {cryofluid_id: 36.0}, liquid_id_by_name, 1.0, 1.0 / 60.0, 1.0)
	proof["craft_mixer_full_increase_zero"] = is_equal_approx(float(mixer_full.get("progress_increase", -1.0)), 0.0)
	proof["craft_mixer_full_scaling_zero"] = is_equal_approx(float(mixer_full.get("scaling", -1.0)), 0.0)
	# The electrolyzer outputs two liquids (ozone + hydrogen), so
	# the dumpExtraLiquid branches split: ozone full (value 0) and
	# hydrogen empty (value 500) give min 0 / max 500 — dumping
	# excess takes min(max, 1f) = 1f, not dumping takes scaling 0.
	var electrolyzer = blocks_by_id["electrolyzer"]
	var electrolyzer_craft_time := float(electrolyzer.properties.get("craftTime", 80.0))
	var electrolyzer_base: Dictionary = factory_build_state.source_factory_progress_increase_state(electrolyzer_craft_time, 1.0, 1.0 / 60.0, 1.0)
	var split_liquids := {ozone_id: 50.0, hydrogen_id: 0.0}
	var split_dump: Dictionary = factory_build_state.source_factory_crafter_progress_increase_state(electrolyzer, split_liquids, liquid_id_by_name, 1.0, 1.0 / 60.0, 1.0)
	proof["craft_electrolyzer_dump_increase_base"] = is_equal_approx(float(split_dump.get("progress_increase", -1.0)), float(electrolyzer_base.get("progress_increase", -1.0)))
	proof["craft_electrolyzer_dump_scaling_one"] = is_equal_approx(float(split_dump.get("scaling", -1.0)), 1.0)
	electrolyzer.properties["dumpExtraLiquid"] = false
	var split_hold: Dictionary = factory_build_state.source_factory_crafter_progress_increase_state(electrolyzer, split_liquids, liquid_id_by_name, 1.0, 1.0 / 60.0, 1.0)
	electrolyzer.properties.erase("dumpExtraLiquid")
	proof["craft_electrolyzer_hold_increase_zero"] = is_equal_approx(float(split_hold.get("progress_increase", -1.0)), 0.0)
	proof["craft_electrolyzer_hold_scaling_zero"] = is_equal_approx(float(split_hold.get("scaling", -1.0)), 0.0)

	# --- consume: BuildingComp.consume() (BuildingComp.java:1911-1915)
	# triggers every consumer, but only the item rows remove
	# anything (ConsumeItems.trigger, ConsumeItems.java:45-48); the
	# cryofluid mixer binds one item row (titanium 1) and one
	# liquid row (water 12/60), so a craft trigger removes the
	# titanium and leaves the water alone. ---
	var mixer_frame: Dictionary = {"items": {"titanium": 3}}
	var mixer_bound: Dictionary = factory_build_state.source_bind_consumer_state(mixer_frame, blocks_by_id["cryofluid-mixer"], catalog, {})
	var mixer_consumers: Array = mixer_bound.get("consumers", [])
	var mixer_rows: Array = mixer_bound.get("rows", [])
	proof["craft_mixer_binds_two_rows"] = mixer_rows.size() == 2 and Array(mixer_frame.get("rows", [])).size() == 2
	var mixer_consumed: Dictionary = factory_build_state.source_factory_consume_state(mixer_frame, mixer_consumers, mixer_rows)
	proof["craft_mixer_consume_triggers_one"] = int(mixer_consumed.get("triggered", -1)) == 1
	proof["craft_mixer_consume_removes_titanium"] = int(Dictionary(mixer_consumed.get("removed", {})).get("titanium", -1)) == 1 and not Dictionary(mixer_consumed.get("removed", {})).has("water")
	proof["craft_mixer_titanium_left_two"] = int(Dictionary(mixer_frame.get("items", {})).get("titanium", -1)) == 2

	# --- craft, direct: GenericCrafterBuild.craft()
	# (GenericCrafter.java:301-315) consumes, offloads each output
	# item once per amount, and wraps progress %= 1f. A smelter
	# with no belt neighbor keeps its silicon in its own items. ---
	var direct_frame: Dictionary = {"items": {"coal": 5, "sand": 5}, "progress": 1.0}
	factory_build_state.source_bind_consumer_state(direct_frame, blocks_by_id["silicon-smelter"], catalog, {})
	var direct: Dictionary = factory_build_state.source_factory_craft_state(game, direct_frame, Vector2i(44, 7), blocks_by_id["silicon-smelter"])
	proof["craft_direct_crafted"] = bool(direct.get("crafted", false)) == true
	proof["craft_direct_consumed"] = int(Dictionary(Dictionary(direct.get("consumed", {})).get("removed", {})).get("coal", -1)) == 1 and int(Dictionary(Dictionary(direct.get("consumed", {})).get("removed", {})).get("sand", -1)) == 2
	proof["craft_direct_offloaded_one"] = Array(direct.get("offloaded", [])).size() == 1
	proof["craft_direct_progress_wrapped"] = is_equal_approx(float(direct.get("progress_after", -1.0)), 0.0)
	proof["craft_direct_silicon_kept"] = int(Dictionary(direct_frame.get("items", {})).get("silicon", -1)) == 1
	var null_craft: Dictionary = factory_build_state.source_factory_craft_state(game, {"progress": 0.5}, Vector2i(44, 7), null)
	proof["craft_null_block_crafts_nothing"] = bool(null_craft.get("crafted", true)) == false and is_equal_approx(float(null_craft.get("progress_after", -1.0)), 0.5)

	# --- craft, live: a smelter (craftTime 40) and a graphite press
	# (craftTime 90) tick through simulate_factory; each craft
	# consumes its inputs and keeps its output until a belt takes
	# it (dumpOutputs is a later slice). ---
	var smelter_cell := Vector2i(20, 7)
	var smelter_sprite := Sprite2D.new()
	game.add_child(smelter_sprite)
	game.call("record_placed_block", smelter_sprite, blocks_by_id["silicon-smelter"], smelter_cell)
	var smelter_frame: Dictionary = smelter_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	smelter_frame["items"] = {"coal": 5, "sand": 5}
	var press_cell := Vector2i(30, 7)
	var press_sprite := Sprite2D.new()
	game.add_child(press_sprite)
	game.call("record_placed_block", press_sprite, blocks_by_id["graphite-press"], press_cell)
	var press_frame: Dictionary = press_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	press_frame["items"] = {"coal": 6}
	for iteration in range(41):
		game.call("simulate_factory", 1.0 / 60.0)
	smelter_frame = smelter_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["craft_live_smelter_first_coal"] = int(Dictionary(smelter_frame.get("items", {})).get("coal", -1)) == 4
	proof["craft_live_smelter_first_sand"] = int(Dictionary(smelter_frame.get("items", {})).get("sand", -1)) == 3
	proof["craft_live_smelter_first_silicon"] = int(Dictionary(smelter_frame.get("items", {})).get("silicon", -1)) == 1
	proof["craft_live_smelter_first_progress_small"] = float(smelter_frame.get("progress", -1.0)) < 0.05
	for iteration in range(50):
		game.call("simulate_factory", 1.0 / 60.0)
	smelter_frame = smelter_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	press_frame = press_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["craft_live_smelter_second_coal"] = int(Dictionary(smelter_frame.get("items", {})).get("coal", -1)) == 3
	proof["craft_live_smelter_second_sand"] = int(Dictionary(smelter_frame.get("items", {})).get("sand", -1)) == 1
	proof["craft_live_smelter_second_silicon"] = int(Dictionary(smelter_frame.get("items", {})).get("silicon", -1)) == 2
	proof["craft_live_smelter_sand_out_efficiency_zero"] = is_equal_approx(float(smelter_frame.get("efficiency", -1.0)), 0.0)
	proof["craft_live_press_coal"] = int(Dictionary(press_frame.get("items", {})).get("coal", -1)) == 4
	proof["craft_live_press_graphite"] = int(Dictionary(press_frame.get("items", {})).get("graphite", -1)) == 1
	proof["craft_live_press_efficiency_one"] = is_equal_approx(float(press_frame.get("efficiency", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06FactoryCraftProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
