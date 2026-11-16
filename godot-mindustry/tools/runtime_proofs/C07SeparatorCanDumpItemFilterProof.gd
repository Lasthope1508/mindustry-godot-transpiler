extends Node

const main_scene := preload("res://scenes/Main.tscn")
const separator_build_state := preload("res://src/game/SourceSeparatorBuildState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var item_catalog: Dictionary = content_registry_state.source_item_catalog_state(catalog)
	var item_order: Array = item_catalog.get("item_names_by_id", [])
	var scrap_id: int = item_order.find("scrap")
	var copper_id: int = item_order.find("copper")
	var lead_id: int = item_order.find("lead")
	var silicon_id: int = item_order.find("silicon")

	# --- Separator canDump itemFilter model (N2395):
	# SeparatorBuild.canDump() (Separator.java:175-177).
	# `public boolean canDump(Building to, Item item){`
	# + `return !consumesItem(item);` -- a separator can
	# dump any item it does not consume. consumesItem is
	# Block.itemFilter[item.id] (Block.java:774-776,
	# `public boolean consumesItem(Item item){` +
	# `return itemFilter[item.id];`), computed through
	# the generic Block.consumesItem pure (SourceBlock
	# QueryFilterState.consumes_item_state) -- NOT
	# re-modeled here. The filter is built by Block.
	# afterPatch (`itemFilter = new boolean[content.
	# items().size];`, Block.java:764) plus ConsumeItems.
	# apply (`block.itemFilter[stack.item.id] = true;`,
	# ConsumeItems.java:25-28). The separator def has NO
	# consumeItem (Blocks.java:1231-1246, so consItems
	# is null) -> all-false filter -> canDump always
	# true; the disassembler consumes scrap
	# (`consumeItem(Items.scrap);`, Blocks.java:1263)
	# -> scrap-only filter -> canDump false for scrap,
	# true for anything else. The def id resolves to
	# its consume rows through the catalog (block.
	# properties.get("consumeItem", []), the N2349
	# driver path), so an unknown def yields no rows
	# and an all-false filter. item_order is the
	# catalog item_names_by_id (content-id order, index
	# IS the id -- Items.load() order: copper 0 ...
	# scrap 8 ... dormant-cyst 21, 22 items). Pure-only,
	# the N2333/N2336 accept-gate precedent: canDump is
	# called BY neighbours' dump/offload (BuildingComp.
	# java:1001-1016, `if(other.acceptItem(self(), item)
	# && canDump(other, item)){`), and the neighbour
	# fills use defaults this wave -- the tick never
	# calls canDump, so there is no tick call site here.

	# --- Separator filter all-false: the separator def
	# carries no consumeItem rows in the catalog, so
	# the filter is all false over all 22 content
	# items and no item id is consumed.
	var separator_rows: Array = blocks_by_id["separator"].properties.get("consumeItem", [])
	var separator_filter: Dictionary = separator_build_state.source_separator_item_filter_state(separator_rows, item_order)
	var separator_item_filter: Array = separator_filter.get("item_filter", [])
	var separator_all_false: bool = separator_item_filter.size() == 22
	for bit in separator_item_filter:
		separator_all_false = separator_all_false and not bool(bit)
	proof["filter_separator_all_false"] = separator_rows.is_empty() and separator_all_false and Array(separator_filter.get("consumed_item_ids", [-1])).is_empty()

	# --- Disassembler filter scrap-only: the
	# disassembler def carries one consumeItem row
	# (scrap, amount 1), so only the scrap bit (id 8,
	# Items.load() order) is true and the consumed ids
	# are exactly [8].
	var disassembler_rows: Array = blocks_by_id["disassembler"].properties.get("consumeItem", [])
	var disassembler_filter: Dictionary = separator_build_state.source_separator_item_filter_state(disassembler_rows, item_order)
	var disassembler_item_filter: Array = disassembler_filter.get("item_filter", [])
	var disassembler_scrap_only: bool = disassembler_item_filter.size() == 22 and scrap_id == 8
	for index in range(disassembler_item_filter.size()):
		var expected: bool = index == scrap_id
		disassembler_scrap_only = disassembler_scrap_only and bool(disassembler_item_filter[index]) == expected
	proof["filter_disassembler_scrap_only"] = disassembler_rows.size() == 1 and str(disassembler_rows[0].get("item", "")) == "scrap" and int(disassembler_rows[0].get("amount", 0)) == 1 and disassembler_scrap_only and Array(disassembler_filter.get("consumed_item_ids", [])).size() == 1 and int(disassembler_filter.get("consumed_item_ids", [-1])[0]) == 8

	# --- canDump separator always true: the all-false
	# filter consumes nothing, so the separator can
	# dump scrap, copper, lead and silicon alike --
	# consumes_item false and can_dump true for every
	# item, including the scrap the disassembler eats.
	var dump_scrap: Dictionary = separator_build_state.source_separator_can_dump_state(separator_item_filter, scrap_id, "scrap")
	var dump_copper: Dictionary = separator_build_state.source_separator_can_dump_state(separator_item_filter, copper_id, "copper")
	var dump_lead: Dictionary = separator_build_state.source_separator_can_dump_state(separator_item_filter, lead_id, "lead")
	var dump_silicon: Dictionary = separator_build_state.source_separator_can_dump_state(separator_item_filter, silicon_id, "silicon")
	proof["candump_separator_always_true"] = bool(dump_scrap.get("can_dump", false)) and not bool(dump_scrap.get("consumes_item", true)) and bool(dump_copper.get("can_dump", false)) and bool(dump_lead.get("can_dump", false)) and bool(dump_silicon.get("can_dump", false))

	# --- canDump disassembler scrap false: the
	# scrap-only filter consumes scrap, so the
	# disassembler canNOT dump scrap (can_dump false,
	# consumes_item true) but CAN dump copper, lead
	# and silicon (can_dump true, consumes_item false).
	var no_dump_scrap: Dictionary = separator_build_state.source_separator_can_dump_state(disassembler_item_filter, scrap_id, "scrap")
	var dump_other_copper: Dictionary = separator_build_state.source_separator_can_dump_state(disassembler_item_filter, copper_id, "copper")
	var dump_other_lead: Dictionary = separator_build_state.source_separator_can_dump_state(disassembler_item_filter, lead_id, "lead")
	var dump_other_silicon: Dictionary = separator_build_state.source_separator_can_dump_state(disassembler_item_filter, silicon_id, "silicon")
	proof["candump_disassembler_scrap_false"] = not bool(no_dump_scrap.get("can_dump", true)) and bool(no_dump_scrap.get("consumes_item", false)) and bool(dump_other_copper.get("can_dump", false)) and not bool(dump_other_copper.get("consumes_item", true)) and bool(dump_other_lead.get("can_dump", false)) and bool(dump_other_silicon.get("can_dump", false))

	# --- Unknown def edge: a def with no catalog rows
	# yields an all-false filter (the empty-stacks
	# case -- what the driver reads for an unknown def
	# id), so canDump is true even for scrap; and a
	# consume row naming an item outside the content
	# order is skipped (Java cannot hold a
	# non-content item, the N2333 precedent), so the
	# filter stays all-false and no id is consumed.
	var unknown_filter: Dictionary = separator_build_state.source_separator_item_filter_state([], item_order)
	var unknown_item_filter: Array = unknown_filter.get("item_filter", [])
	var unknown_all_false: bool = unknown_item_filter.size() == 22
	for bit in unknown_item_filter:
		unknown_all_false = unknown_all_false and not bool(bit)
	var unknown_dump: Dictionary = separator_build_state.source_separator_can_dump_state(unknown_item_filter, scrap_id, "scrap")
	var bogus_filter: Dictionary = separator_build_state.source_separator_item_filter_state([{"item": "not_an_item", "amount": 1}], item_order)
	var bogus_item_filter: Array = bogus_filter.get("item_filter", [])
	var bogus_all_false: bool = bogus_item_filter.size() == 22
	for bit in bogus_item_filter:
		bogus_all_false = bogus_all_false and not bool(bit)
	proof["filter_unknown_def_edge"] = unknown_all_false and Array(unknown_filter.get("consumed_item_ids", [-1])).is_empty() and bool(unknown_dump.get("can_dump", false)) and bogus_all_false and Array(bogus_filter.get("consumed_item_ids", [-1])).is_empty()

	# --- Live frame values: a placed separator and a
	# placed disassembler, bound live -- the filters
	# are built from the LIVE catalog rows of the
	# placed blocks' defs (the driver path, block.
	# properties.get("consumeItem", [])), and the
	# canDump verdicts follow: the live separator
	# dumps scrap, the live disassembler does not.
	# canDump is pure-only (no tick call site), so no
	# tick runs here -- the live path is the def rows
	# of placed blocks, not a frame key.
	var live_separator_cell := Vector2i(28, 21)
	var live_separator := Sprite2D.new()
	game.add_child(live_separator)
	game.call("record_placed_block", live_separator, blocks_by_id["separator"], live_separator_cell)
	separator_build_state.source_separator_bind_frame_state(live_separator, blocks_by_id["separator"])
	var live_disassembler_cell := Vector2i(32, 21)
	var live_disassembler := Sprite2D.new()
	game.add_child(live_disassembler)
	game.call("record_placed_block", live_disassembler, blocks_by_id["disassembler"], live_disassembler_cell)
	separator_build_state.source_separator_bind_frame_state(live_disassembler, blocks_by_id["disassembler"])
	var live_separator_frame: Dictionary = live_separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var live_disassembler_frame: Dictionary = live_disassembler.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var live_separator_rows: Array = blocks_by_id["separator"].properties.get("consumeItem", [])
	var live_disassembler_rows: Array = blocks_by_id["disassembler"].properties.get("consumeItem", [])
	var live_separator_filter: Dictionary = separator_build_state.source_separator_item_filter_state(live_separator_rows, item_order)
	var live_disassembler_filter: Dictionary = separator_build_state.source_separator_item_filter_state(live_disassembler_rows, item_order)
	var live_separator_dump: Dictionary = separator_build_state.source_separator_can_dump_state(live_separator_filter.get("item_filter", []), scrap_id, "scrap")
	var live_disassembler_dump: Dictionary = separator_build_state.source_separator_can_dump_state(live_disassembler_filter.get("item_filter", []), scrap_id, "scrap")
	proof["candump_live_frame_values"] = live_separator_frame.has("items") and live_disassembler_frame.has("items") and live_separator_rows.is_empty() and live_disassembler_rows.size() == 1 and bool(live_separator_dump.get("can_dump", false)) and not bool(live_disassembler_dump.get("can_dump", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SeparatorCanDumpItemFilterProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
