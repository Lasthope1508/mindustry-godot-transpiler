extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
const adjacent_build_state := preload("res://src/game/SourceAdjacentFactoryBuildState.gd")
const reinitialize_state := preload("res://src/game/SourceBlockReinitializeConsumersState.gd")
const placed_state := preload("res://src/game/SourcePlacedBlockState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
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
	proof["gate_smelter_is_generic_crafter"] = String(blocks_by_id["silicon-smelter"].implementation) == "GenericCrafter"
	proof["gate_press_is_generic_crafter"] = String(blocks_by_id["graphite-press"].implementation) == "GenericCrafter"
	proof["gate_separator_is_separator"] = String(blocks_by_id["separator"].implementation) == "Separator"
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var slag_id: int = int(liquid_catalog["liquid_id_by_name"].get("slag", -1))

	# --- lifecycle replacement: a silicon smelter is placed live and
	# bound on placement (Block.newBuilding(), Block.java:1002), then
	# the SAME sprite is re-recorded with a graphite press at the
	# same cell — Tile.changeBuild (Tile.java:636-657) removes the
	# old Building and inits a brand-new one, so the replaced
	# building gets fresh consumers from
	# Block.reinitializeConsumers() (Block.java:1481-1497). The
	# smelter consumes coal 1 + sand 2 (Blocks.java:1081, one
	# ConsumeItems row per stack); the press consumes coal 2
	# (Blocks.java:1050). ---
	var replace_cell := Vector2i(30, 7)
	var replace_sprite := Sprite2D.new()
	game.add_child(replace_sprite)
	game.call("record_placed_block", replace_sprite, blocks_by_id["silicon-smelter"], replace_cell)
	var replace_frame: Dictionary = replace_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	replace_frame["items"] = {"coal": 5, "sand": 5}
	factory_build_state.source_factory_tick_buildings_state(game, 1.0 / 60.0)
	replace_frame = replace_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["gate_smelter_binds_two_actors"] = Array(replace_frame.get("consumers", [])).size() == 2
	proof["gate_smelter_efficiency_one"] = is_equal_approx(float(replace_frame.get("efficiency", -1.0)), 1.0)
	proof["gate_smelter_stamped_smelter"] = String(replace_frame.get("block_id", "")) == "silicon-smelter"
	var smelter_reinit: Dictionary = factory_build_state.source_factory_reinitialize_consumers_state(replace_frame, blocks_by_id["silicon-smelter"], catalog, {})
	var smelter_rows_check: Array = Array(smelter_reinit.get("rows", []))
	proof["gate_smelter_rows_coal_sand"] = bool(smelter_reinit.get("reinitialized", true)) == false and smelter_rows_check.size() == 2 and String(smelter_rows_check[0].get("item", "")) == "coal" and int(smelter_rows_check[0].get("amount", -1)) == 1 and String(smelter_rows_check[1].get("item", "")) == "sand" and int(smelter_rows_check[1].get("amount", -1)) == 2
	var old_actors: Array = Array(replace_frame.get("consumers", [])).duplicate()
	game.call("record_placed_block", replace_sprite, blocks_by_id["graphite-press"], replace_cell)
	proof["gate_replacement_sprite_keeps_frame"] = replace_sprite.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)
	proof["gate_replacement_block_id_meta_updated"] = String(replace_sprite.get_meta(placed_state.SOURCE_BLOCK_ID_META_KEY, "")) == "graphite-press"
	replace_frame = replace_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["gate_replacement_stale_items_before_tick"] = Dictionary(replace_frame.get("items", {})).get("coal", -1) == 5
	proof["gate_replacement_stale_stamp_before_tick"] = String(replace_frame.get("block_id", "")) == "silicon-smelter"
	factory_build_state.source_factory_tick_buildings_state(game, 1.0 / 60.0)
	replace_frame = replace_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	var new_actors: Array = Array(replace_frame.get("consumers", []))
	proof["gate_replacement_rebinds_one_actor"] = new_actors.size() == 1
	proof["gate_replacement_actor_is_new"] = new_actors.size() == 1 and old_actors.size() == 2 and not is_same(new_actors[0], old_actors[0]) and not is_same(new_actors[0], old_actors[1])
	proof["gate_replacement_stamped_press"] = String(replace_frame.get("block_id", "")) == "graphite-press"
	proof["gate_replacement_items_cleared"] = Dictionary(replace_frame.get("items", {})).is_empty()
	proof["gate_replacement_efficiency_zero_empty"] = is_equal_approx(float(replace_frame.get("efficiency", -1.0)), 0.0)
	var press_items: Dictionary = replace_frame.get("items", {})
	press_items["coal"] = 1
	factory_build_state.source_factory_tick_buildings_state(game, 1.0 / 60.0)
	replace_frame = replace_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["gate_press_one_coal_efficiency_zero"] = is_equal_approx(float(replace_frame.get("efficiency", -1.0)), 0.0)
	press_items = replace_frame.get("items", {})
	press_items["coal"] = 2
	factory_build_state.source_factory_tick_buildings_state(game, 1.0 / 60.0)
	replace_frame = replace_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["gate_press_two_coal_efficiency_one"] = is_equal_approx(float(replace_frame.get("efficiency", -1.0)), 1.0)
	proof["gate_press_items_not_drained_per_tick"] = Dictionary(replace_frame.get("items", {})).get("coal", -1) == 2
	var press_reinit: Dictionary = factory_build_state.source_factory_reinitialize_consumers_state(replace_frame, blocks_by_id["graphite-press"], catalog, {})
	var press_rows_check: Array = Array(press_reinit.get("rows", []))
	proof["gate_press_rows_coal_two"] = bool(press_reinit.get("reinitialized", true)) == false and press_rows_check.size() == 1 and String(press_rows_check[0].get("item", "")) == "coal" and int(press_rows_check[0].get("amount", -1)) == 2

	# --- storage independence: two silicon smelters side by side,
	# each with its own ItemModule (BuildingComp.java:145-146, init
	# creates a fresh ItemModule per Building) — seeding or draining
	# one never
	# touches the other. ---
	var smelter_a_cell := Vector2i(12, 7)
	var smelter_b_cell := Vector2i(16, 7)
	var smelter_a := Sprite2D.new()
	game.add_child(smelter_a)
	game.call("record_placed_block", smelter_a, blocks_by_id["silicon-smelter"], smelter_a_cell)
	var smelter_b := Sprite2D.new()
	game.add_child(smelter_b)
	game.call("record_placed_block", smelter_b, blocks_by_id["silicon-smelter"], smelter_b_cell)
	var smelter_a_frame: Dictionary = smelter_a.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	smelter_a_frame["items"] = {"coal": 5, "sand": 5}
	var smelter_b_frame: Dictionary = smelter_b.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	factory_build_state.source_factory_tick_buildings_state(game, 1.0 / 60.0)
	smelter_a_frame = smelter_a.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	smelter_b_frame = smelter_b.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["gate_smelter_a_efficiency_one"] = is_equal_approx(float(smelter_a_frame.get("efficiency", -1.0)), 1.0)
	proof["gate_smelter_b_efficiency_zero_empty"] = is_equal_approx(float(smelter_b_frame.get("efficiency", -1.0)), 0.0)
	proof["gate_smelter_b_items_still_empty"] = Dictionary(smelter_b_frame.get("items", {})).is_empty()
	var smelter_a_items: Dictionary = smelter_a_frame.get("items", {})
	smelter_a_items["coal"] = 0
	factory_build_state.source_factory_tick_buildings_state(game, 1.0 / 60.0)
	smelter_a_frame = smelter_a.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	smelter_b_frame = smelter_b.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["gate_smelter_a_no_coal_efficiency_zero"] = is_equal_approx(float(smelter_a_frame.get("efficiency", -1.0)), 0.0)
	proof["gate_smelter_b_untouched_by_a_drain"] = Dictionary(smelter_b_frame.get("items", {})).is_empty() and is_equal_approx(float(smelter_b_frame.get("efficiency", -1.0)), 0.0)
	smelter_a_items = smelter_a_frame.get("items", {})
	smelter_a_items["coal"] = 5
	var smelter_b_items: Dictionary = smelter_b_frame.get("items", {})
	smelter_b_items["coal"] = 5
	smelter_b_items["sand"] = 5
	factory_build_state.source_factory_tick_buildings_state(game, 1.0 / 60.0)
	smelter_a_frame = smelter_a.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	smelter_b_frame = smelter_b.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["gate_both_smelters_efficiency_one"] = is_equal_approx(float(smelter_a_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(smelter_b_frame.get("efficiency", -1.0)), 1.0)
	proof["gate_smelter_a_items_unchanged_by_ticks"] = Dictionary(smelter_a_frame.get("items", {})).get("coal", -1) == 5 and Dictionary(smelter_a_frame.get("items", {})).get("sand", -1) == 5

	# --- storage independence, liquids: two separators side by side
	# with their own LiquidModules — each drains only its own slag
	# (ConsumeLiquid.update, ConsumeLiquid.java:38-40: 4/60 per
	# tick at efficiency 1.0). ---
	var separator_a_cell := Vector2i(36, 7)
	var separator_b_cell := Vector2i(41, 7)
	var separator_a := Sprite2D.new()
	game.add_child(separator_a)
	game.call("record_placed_block", separator_a, blocks_by_id["separator"], separator_a_cell)
	var separator_b := Sprite2D.new()
	game.add_child(separator_b)
	game.call("record_placed_block", separator_b, blocks_by_id["separator"], separator_b_cell)
	var separator_a_frame: Dictionary = separator_a.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	var separator_a_module: Dictionary = separator_a.get_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_add_state(separator_a_module, slag_id, 10.0, [])
	var separator_b_module: Dictionary = separator_b.get_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	adjacent_build_state.source_adjacent_factory_tick_buildings_state(game, 1.0 / 60.0)
	for iteration in range(3):
		game.call("simulate_factory", 1.0 / 60.0)
	separator_a_frame = separator_a.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	var separator_b_frame: Dictionary = separator_b.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	proof["gate_separator_a_slag_drops_four_ticks"] = is_equal_approx(float(liquid_module_state.source_get_state(separator_a_module, slag_id).get("amount", -1.0)), 10.0 - 4.0 * (4.0 / 60.0))
	proof["gate_separator_b_slag_stays_zero"] = is_equal_approx(float(liquid_module_state.source_get_state(separator_b_module, slag_id).get("amount", -1.0)), 0.0)
	proof["gate_separator_a_efficiency_one"] = is_equal_approx(float(separator_a_frame.get("efficiency", -1.0)), 1.0)
	proof["gate_separator_b_efficiency_zero_empty"] = is_equal_approx(float(separator_b_frame.get("efficiency", -1.0)), 0.0)
	liquid_module_state.source_add_state(separator_b_module, slag_id, 10.0, [])
	adjacent_build_state.source_adjacent_factory_tick_buildings_state(game, 1.0 / 60.0)
	for iteration in range(3):
		game.call("simulate_factory", 1.0 / 60.0)
	separator_a_frame = separator_a.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	separator_b_frame = separator_b.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	proof["gate_separator_a_slag_drops_eight_ticks"] = is_equal_approx(float(liquid_module_state.source_get_state(separator_a_module, slag_id).get("amount", -1.0)), 10.0 - 8.0 * (4.0 / 60.0))
	proof["gate_separator_b_slag_drops_four_ticks"] = is_equal_approx(float(liquid_module_state.source_get_state(separator_b_module, slag_id).get("amount", -1.0)), 10.0 - 4.0 * (4.0 / 60.0))
	proof["gate_both_separators_efficiency_one"] = is_equal_approx(float(separator_a_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(separator_b_frame.get("efficiency", -1.0)), 1.0)
	var separator_reinit: Dictionary = adjacent_build_state.source_adjacent_factory_reinitialize_consumers_state(separator_a_frame, blocks_by_id["separator"], catalog, separator_a_module)
	var separator_rows_check: Array = Array(separator_reinit.get("rows", []))
	proof["gate_separator_rows_slag"] = bool(separator_reinit.get("reinitialized", true)) == false and separator_rows_check.size() == 1 and int(separator_rows_check[0].get("liquid", -1)) == slag_id

	# --- consumer classification: Block.reinitializeConsumers()
	# (Block.java:1481-1497) partitions the consumeBuilder into
	# consumers / consPower / optionalConsumers /
	# nonOptionalConsumers / updateConsumers (Consume.java:12
	# optional, :16 update defaults true, :43 ignore); the live
	# loop reads those classes every tick
	# (BuildingComp.java:1969, 1980, 2000). A required row gates
	# efficiency, an optional row does not, an update:false row is
	# checked but never drained, and an ignored row is in none of
	# the classes. ---
	var classify_rows: Array = [
		{"item": "coal", "amount": 1},
		{"item": "sand", "amount": 2, "optional": true},
		{"liquid": slag_id, "amount": 0.12, "update": false},
		{"item": "scrap", "amount": 1, "ignored": true},
		{"liquid": -1, "amount": 0.5, "is_consume_power": true},
	]
	var classified: Dictionary = reinitialize_state.arrays_state(classify_rows)
	proof["gate_classify_all_consumers"] = Array(classified.get("consumers", [])).size() == 5
	proof["gate_classify_optional_one"] = Array(classified.get("optional_consumers", [])).size() == 1 and String(Array(classified.get("optional_consumers", []))[0].get("item", "")) == "sand"
	proof["gate_classify_non_optional_three"] = Array(classified.get("non_optional_consumers", [])).size() == 3
	proof["gate_classify_update_three"] = Array(classified.get("update_consumers", [])).size() == 3 and not Array(classified.get("update_consumers", [])).has(classify_rows[2]) and not Array(classified.get("update_consumers", [])).has(classify_rows[3])
	proof["gate_classify_cons_power"] = Dictionary(classified.get("cons_power", {})).get("is_consume_power", false) == true
	proof["gate_classify_has_consumers"] = bool(classified.get("has_consumers", false)) == true
	var reactor_liquid_rows: Array = Array(blocks_by_id["thorium-reactor"].properties.get("consumeLiquid", []))
	var reactor_item_rows: Array = Array(blocks_by_id["thorium-reactor"].properties.get("consumeItem", []))
	proof["gate_reactor_cryofluid_update_false"] = reactor_liquid_rows.size() == 1 and String(reactor_liquid_rows[0].get("liquid", "")) == "cryofluid" and is_equal_approx(float(reactor_liquid_rows[0].get("amount", -1.0)), 0.04) and bool(reactor_liquid_rows[0].get("update", true)) == false
	proof["gate_reactor_thorium_required"] = reactor_item_rows.size() == 1 and String(reactor_item_rows[0].get("item", "")) == "thorium" and int(reactor_item_rows[0].get("amount", -1)) == 1 and bool(reactor_item_rows[0].get("optional", false)) == false
	var smelter_rows: Array = Array(blocks_by_id["silicon-smelter"].properties.get("consumeItem", []))
	proof["gate_smelter_rows_required"] = smelter_rows.size() == 2 and bool(smelter_rows[0].get("optional", false)) == false and bool(smelter_rows[1].get("optional", false)) == false
	var separator_rows: Array = Array(blocks_by_id["separator"].properties.get("consumeLiquid", []))
	proof["gate_separator_row_updates"] = separator_rows.size() == 1 and bool(separator_rows[0].get("update", true)) == true

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C05GateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
