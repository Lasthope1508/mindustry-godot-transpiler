extends RefCounted
class_name SourceCoreInventoryRuntimeState

const source_core_defaults := preload("res://src/game/SourceCoreDefaults.gd")
const source_item_metadata_state := preload("res://src/game/SourceItemMetadataState.gd")

const SOURCE_INTEGER_MAX_VALUE_HALF := source_core_defaults.INTEGER_MAX_VALUE_HALF

const SOURCE_CORE_ACCEPT_ITEM_METHOD := "public boolean acceptItem(Building source, Item item){"
const SOURCE_CORE_ACCEPT_ITEM_RESULT := "return state.rules.coreIncinerates || items.get(item) < getMaximumAccepted(item);"
const SOURCE_CORE_ACCEPT_ITEM_MAXIMUM_METHOD := "public int getMaximumAccepted(Item item){"
const SOURCE_CORE_ACCEPT_ITEM_MAXIMUM_RESULT := "return state.rules.coreIncinerates ? Integer.MAX_VALUE/2 : storageCapacity;"
const SOURCE_CORE_ACCEPT_ITEM_RULES_CORE_INCINERATES_FIELD := "public boolean coreIncinerates = true;"

const SOURCE_CORE_HANDLE_ITEM_METHOD := "public void handleItem(Building source, Item item){"
const SOURCE_CORE_HANDLE_ITEM_INCINERATE := "boolean incinerate = incinerateNonBuildable && !item.buildable;"
const SOURCE_CORE_HANDLE_ITEM_FULL_OR_INCINERATE_GATE := "if(items.get(item) >= storageCapacity || incinerate){"
const SOURCE_CORE_HANDLE_ITEM_SUPER_HANDLE := "super.handleItem(source, item);"
const SOURCE_CORE_HANDLE_ITEM_BUILDING_HANDLE_ADD := "items.add(item, 1);"
const SOURCE_CORE_HANDLE_ITEM_INCINERATE_NON_BUILDABLE_FIELD := "public boolean incinerateNonBuildable = false;"
const SOURCE_CORE_HANDLE_ITEM_ITEM_BUILDABLE_FIELD := "public boolean buildable = true;"

static func clamp_item_amount(amount: int, storage_capacity: int) -> int:
	return mini(max(0, amount), storage_capacity)

static func sync_copper_inventory_alias_state(core_items: Dictionary, core_inventory: int, item_id: String, storage_capacity: int) -> Dictionary:
	var next_items := core_items.duplicate(true)
	next_items[item_id] = clamp_item_amount(max(int(next_items.get(item_id, 0)), core_inventory), storage_capacity)
	return {
		"core_items": next_items,
		"core_inventory": int(next_items.get(item_id, 0)),
		"item_id": item_id,
	}

static func sync_copper_inventory_runtime_state(game: Object) -> void:
	var state := sync_copper_inventory_alias_state(game.core_items, game.core_inventory, game.playable_core_item_id(), game.core_item_capacity)
	game.core_items = state.get("core_items", game.core_items)
	game.core_inventory = int(state.get("core_inventory", game.core_inventory))

static func set_item_count_state(core_items: Dictionary, item_id: String, amount: int, storage_capacity: int, playable_item_id: String, core_inventory: int) -> Dictionary:
	var next_items := core_items.duplicate(true)
	next_items[item_id] = clamp_item_amount(amount, storage_capacity)
	var next_inventory := int(next_items.get(playable_item_id, core_inventory)) if item_id == playable_item_id else core_inventory
	return {
		"core_items": next_items,
		"core_inventory": next_inventory,
		"item_id": item_id,
		"item_count": int(next_items.get(item_id, 0)),
	}

static func set_item_count_runtime_state(game: Object, item_id: String, amount: int) -> void:
	var state := set_item_count_state(game.core_items, item_id, amount, game.core_item_capacity, game.playable_core_item_id(), game.core_inventory)
	game.core_items = state.get("core_items", game.core_items)
	game.core_inventory = int(state.get("core_inventory", game.core_inventory))

static func add_item_state(core_items: Dictionary, item_id: String, amount: int, storage_capacity: int, playable_item_id: String, core_inventory: int) -> Dictionary:
	var current := int(core_items.get(item_id, core_inventory if item_id == playable_item_id else 0))
	return set_item_count_state(core_items, item_id, current + amount, storage_capacity, playable_item_id, core_inventory)

static func add_item_runtime_state(game: Object, item_id: String, amount: int) -> void:
	var state := add_item_state(game.core_items, item_id, amount, game.core_item_capacity, game.playable_core_item_id(), game.core_inventory)
	game.core_items = state.get("core_items", game.core_items)
	game.core_inventory = int(state.get("core_inventory", game.core_inventory))

static func item_count_state(core_items: Dictionary, core_inventory: int, item_id: String, playable_item_id: String) -> Dictionary:
	var next_items := core_items.duplicate(true)
	if item_id == playable_item_id and not next_items.has(item_id):
		next_items[item_id] = core_inventory
	return {
		"core_items": next_items,
		"itemCount": int(next_items.get(item_id, 0)),
		"item_id": item_id,
	}

static func item_count_runtime_state(game: Object, item_id: String) -> int:
	var state := item_count_state(game.core_items, game.core_inventory, item_id, game.playable_core_item_id())
	game.core_items = state.get("core_items", game.core_items)
	return int(state.get("itemCount", 0))

static func accept_item_state(core_incinerates: bool, item_count: int, storage_capacity: int, item_id: String) -> Dictionary:
	var maximum_accepted := SOURCE_INTEGER_MAX_VALUE_HALF if core_incinerates else storage_capacity
	var accept_item := core_incinerates or item_count < maximum_accepted
	return {
		"acceptItem": accept_item,
		"maximumAccepted": maximum_accepted,
		"item_id": item_id,
	}

static func handle_item_state(core_incinerate_non_buildable: bool, item_buildable: bool, item_count: int, storage_capacity: int, accept_item: bool, item_id: String) -> Dictionary:
	var incinerate := core_incinerate_non_buildable and not item_buildable
	var full_or_incinerate_gate := item_count >= storage_capacity or incinerate
	return {
		"handled": accept_item,
		"incinerate": incinerate,
		"fullOrIncinerateGate": full_or_incinerate_gate,
		"should_add": not full_or_incinerate_gate,
		"item_id": item_id,
	}

static func game_handle_item(game: Object, item_id: String) -> bool:
	if not game.source_core_accept_item(item_id):
		return false
	var item_buildable := source_item_metadata_state.item_buildable(item_id, game.content_catalog)
	var state := handle_item_state(game.core_incinerate_non_buildable, item_buildable, game.core_item_count(item_id), game.core_item_capacity, game.source_core_accept_item(item_id), item_id)
	if bool(state.get("should_add", false)):
		game.add_core_item(item_id, 1)
	return bool(state.get("handled", false))
