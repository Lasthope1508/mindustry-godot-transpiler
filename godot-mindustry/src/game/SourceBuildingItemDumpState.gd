extends RefCounted
class_name SourceBuildingItemDumpState

const SOURCE_INCREMENT_DUMP_CURSOR_METHOD := "public void incrementDump(int prox){"
const SOURCE_INCREMENT_DUMP_CURSOR_COMMENT := "//this is possible if transferring an item changed a block"
const SOURCE_INCREMENT_DUMP_CURSOR_NONZERO_GUARD := "if(prox != 0){"
const SOURCE_INCREMENT_DUMP_CURSOR_ASSIGNMENT := "cdump = ((cdump + 1) % prox);"

const SOURCE_DUMP_ACCUMULATE_ATTEMPT_FIELD := "private transient float dumpAccum;"
const SOURCE_DUMP_ACCUMULATE_ATTEMPT_ADD_DELTA := "dumpAccum += delta();"
const SOURCE_DUMP_ACCUMULATE_ATTEMPT_WHILE_GATE := "while(dumpAccum >= 1f){"
const SOURCE_DUMP_ACCUMULATE_ATTEMPT_DUMP_CALL := "res |= dump(item);"
const SOURCE_DUMP_ACCUMULATE_ATTEMPT_SUBTRACT_ONE := "dumpAccum -=1f;"
const SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY := "increment_dump_cursor"
const SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_FALLBACK := "source_increment_dump_cursor"

static func runtime_method_names(game: Object) -> Dictionary:
	if game == null:
		return {}
	if game.has_method("_building_item_dump_state_method_names"):
		var names = game.call("_building_item_dump_state_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	return str(method_names.get(key, fallback_name))

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	var increment_dump_cursor_method := runtime_method_name(method_names, SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY, SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_FALLBACK)
	return {
		SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY: Callable(game, increment_dump_cursor_method),
	}

static func increment_dump_cursor_state(current_dump: int, proximity_size: int) -> int:
	if proximity_size != 0:
		return (current_dump + 1) % proximity_size
	return current_dump

static func increment_dump_cursor_runtime_state(game: Object, proximity_size: int) -> int:
	var next_dump := increment_dump_cursor_state(game.drill_dump_cursor, proximity_size)
	game.drill_dump_cursor = next_dump
	return next_dump

static func game_put_item_state(game: Object, item: Variant, proximity_size: int, dump_cursor: int, accepts_item_by_index: Array, can_dump_by_index: Array) -> Dictionary:
	return put_item_state(
		item,
		proximity_size,
		dump_cursor,
		accepts_item_by_index,
		can_dump_by_index,
		default_callbacks_state(game).get(SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable())
	)

static func can_dump_item_default_state(to_state: Variant, item: Variant) -> Dictionary:
	return {
		"method": "public boolean canDump(Building to, Item item){",
		"return_true": "return true;",
		"to_state": to_state,
		"item": item,
		"can_dump_item": true,
	}

static func put_item_state(item: Variant, proximity_size: int, dump_cursor: int, accepts_item_by_index: Array, can_dump_by_index: Array, increment_dump_cursor: Callable) -> Dictionary:
	var next_dump := dump_cursor
	var handled_index := -1
	var put_success := false
	var checked_indices: Array = []
	for i in range(proximity_size):
		next_dump = int(increment_dump_cursor.call(next_dump, proximity_size))
		var other_index := (i + dump_cursor) % proximity_size
		checked_indices.append(other_index)
		var accepts_item := other_index >= 0 and other_index < accepts_item_by_index.size() and bool(accepts_item_by_index[other_index])
		var can_dump := other_index >= 0 and other_index < can_dump_by_index.size() and bool(can_dump_by_index[other_index])
		if accepts_item and can_dump:
			handled_index = other_index
			put_success = true
			break
	return {
		"comment": " * Tries to put this item into a nearby container. Returns success. Unlike #offload(), this method does not change the block inventory.",
		"method": "public boolean put(Item item){",
		"dump_assign": "int dump = this.cdump;",
		"loop": "for(int i = 0; i < proximity.size; i++){",
		"increment_dump": "incrementDump(proximity.size);",
		"proximity_get": "Building other = proximity.get((i + dump) % proximity.size);",
		"accept_can_dump_guard": "if(other.acceptItem(self(), item) && canDump(other, item)){",
		"handle_item": "other.handleItem(self(), item);",
		"return_true": "return true;",
		"return_false": "return false;",
		"item": item,
		"proximity_size": proximity_size,
		"dump_cursor": dump_cursor,
		"cdump": next_dump,
		"checked_indices": checked_indices,
		"handled_index": handled_index,
		"handle_item_called": handled_index != -1,
		"put": put_success,
		"return_value": put_success,
	}

static func produced_item_default_state(item: Variant) -> Dictionary:
	return {
		"method": "public void produced(Item item){",
		"delegate": "produced(item, 1);",
		"item": item,
		"amount": 1,
		"delegates_to_amount_overload": true,
	}

static func produced_item_amount_state(item: Variant, amount: int, sector_present: bool, team_is_default_team: bool, net_client: bool) -> Dictionary:
	var production_recorded := sector_present and team_is_default_team
	var unlock_called := production_recorded and not net_client
	return {
		"method": "public void produced(Item item, int amount){",
		"production_guard": "if(Vars.state.rules.sector != null && team == state.rules.defaultTeam){",
		"handle_production": "Vars.state.rules.sector.info.handleProduction(item, amount);",
		"unlock_guard": "if(!net.client()) item.unlock();",
		"item": item,
		"amount": amount,
		"sector_present": sector_present,
		"team_is_default_team": team_is_default_team,
		"net_client": net_client,
		"production_recorded": production_recorded,
		"unlock_called": unlock_called,
	}

static func dump_accumulate_default_state() -> Dictionary:
	return {
		"comment": "/** Dumps any item with an accumulator. May dump multiple times per frame. Use with care. */",
		"method": "public boolean dumpAccumulate(){",
		"delegate": "return dumpAccumulate(null);",
		"item": null,
		"delegates_to_item_overload": true,
	}

static func dump_accumulate_state(current_accum: float, source_delta: float) -> Dictionary:
	var next_accum := current_accum + source_delta
	var dump_attempts := 0
	while next_accum >= 1.0:
		dump_attempts += 1
		next_accum -= 1.0
	return {"dump_attempts": dump_attempts, "dump_accum": next_accum}

static func dump_accumulate_runtime_state(game: Object, source_delta: float) -> Dictionary:
	var state := dump_accumulate_state(game.building_dump_accum, source_delta)
	game.building_dump_accum = float(state["dump_accum"])
	return state

static func dump_default_state() -> Dictionary:
	return {
		"comment": "/** Try dumping any item near the building. */",
		"method": "public boolean dump(){",
		"delegate": "return dump(null);",
		"todump": null,
		"delegates_to_item_overload": true,
	}

static func dump_null_item_scan_state(item_ids: Array, item_present_by_index: Array) -> Dictionary:
	var present_item_indices := []
	var present_items := []
	for ii in range(item_ids.size()):
		if not bool(item_present_by_index[ii]):
			continue
		present_item_indices.append(ii)
		present_items.append(item_ids[ii])
	return {
		"method": "public boolean dump(Item todump){",
		"all_items": "var allItems = content.items();",
		"item_size_source": "int itemSize = allItems.size;",
		"item_array": "Object[] itemArray = allItems.items;",
		"null_branch": "if(todump == null){",
		"item_loop": "for(int ii = 0; ii < itemSize; ii++){",
		"has_item_skip": "if(!items.has(ii)) continue;",
		"item_cast": "Item item = (Item)itemArray[ii];",
		"item_ids": item_ids,
		"item_present_by_index": item_present_by_index,
		"item_size": item_ids.size(),
		"present_item_indices": present_item_indices,
		"present_items": present_items,
	}

static func dump_null_proximity_scan_state(proximity_size: int, dump_cursor: int, increment_dump_cursor: Callable) -> Dictionary:
	var checked_indices := []
	var next_dump := dump_cursor
	for i in range(proximity_size):
		checked_indices.append((i + dump_cursor) % proximity_size)
		next_dump = int(increment_dump_cursor.call(next_dump, proximity_size))
	return {
		"method": "public boolean dump(Item todump){",
		"dump_assign": "int dump = this.cdump;",
		"null_branch": "if(todump == null){",
		"proximity_loop": "for(int i = 0; i < proximity.size; i++){",
		"proximity_get": "Building other = proximity.get((i + dump) % proximity.size);",
		"increment_dump_call": "incrementDump(proximity.size);",
		"proximity_size": proximity_size,
		"dump_cursor": dump_cursor,
		"checked_indices": checked_indices,
		"cdump": next_dump,
	}

static func game_dump_null_proximity_scan_state(game: Object, proximity_size: int, dump_cursor: int) -> Dictionary:
	return dump_null_proximity_scan_state(
		proximity_size,
		dump_cursor,
		default_callbacks_state(game).get(SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable())
	)

static func dump_null_remove_item_state(item: Variant, item_amount_before: int) -> Dictionary:
	return {
		"source_method": "dump(Item todump) null remove item",
		"null_branch": "if(todump == null){",
		"accept_can_dump_guard": "if(other.acceptItem(self(), item) && canDump(other, item)){",
		"remove_item_call": "items.remove(item, 1);",
		"item": item,
		"item_amount_before": item_amount_before,
		"remove_amount": 1,
		"item_amount_after": item_amount_before - 1,
	}

static func dump_null_success_handoff_state(item: Variant, accepts_item: bool, can_dump: bool) -> Dictionary:
	return {
		"source_method": "dump(Item todump) null success handoff",
		"null_branch": "if(todump == null){",
		"accept_can_dump_guard": "if(other.acceptItem(self(), item) && canDump(other, item)){",
		"handle_item_call": "other.handleItem(self(), item);",
		"return_true": "return true;",
		"item": item,
		"accepts_item": accepts_item,
		"can_dump": can_dump,
		"handle_item_called": accepts_item and can_dump,
		"dumped": accepts_item and can_dump,
		"return_value": accepts_item and can_dump,
	}

static func dump_specific_proximity_scan_state(todump: Variant, proximity_size: int, dump_cursor: int) -> Dictionary:
	var checked_indices := []
	for i in range(proximity_size):
		checked_indices.append((i + dump_cursor) % proximity_size)
	return {
		"source_method": "dump(Item todump) specific proximity scan",
		"else_branch": "}else{",
		"proximity_loop": "for(int i = 0; i < proximity.size; i++){",
		"proximity_get": "Building other = proximity.get((i + dump) % proximity.size);",
		"todump": todump,
		"proximity_size": proximity_size,
		"dump_cursor": dump_cursor,
		"checked_indices": checked_indices,
	}

static func dump_terminal_failure_state() -> Dictionary:
	return {
		"source_method": "dump(Item todump) terminal failure",
		"terminal_return": "return false;",
		"dumped": false,
		"return_value": false,
	}
