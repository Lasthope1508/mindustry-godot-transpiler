extends RefCounted
class_name SourceBuildingItemSourceTextState

const SOURCE_MOVE_FORWARD_ACCEPT_METHOD := "public boolean moveForward(Item item){"
const SOURCE_MOVE_FORWARD_ACCEPT_FRONT := "Building other = front();"
const SOURCE_MOVE_FORWARD_ACCEPT_GATE := "if(other != null && other.team == team && other.acceptItem(self(), item)){"
const SOURCE_MOVE_FORWARD_ACCEPT_HANDLE_DEFERRED := "other.handleItem(self(), item);"
const SOURCE_MOVE_FORWARD_ACCEPT_RETURN_TRUE := "return true;"
const SOURCE_MOVE_FORWARD_ACCEPT_RETURN_FALSE := "return false;"
const SOURCE_MOVE_FORWARD_TO_CORE_ACCEPT_BRIDGE := "source_core_accept_item(item_id)"
const SOURCE_MOVE_FORWARD_TO_CORE_HANDLE_BRIDGE := "source_core_handle_item(item_id)"
const SOURCE_BUILDING_REMOVE_STACK_METHOD := "public int removeStack(Item item, int amount){"
const SOURCE_BUILDING_REMOVE_STACK_NULL_GUARD := "if(items == null) return 0;"
const SOURCE_BUILDING_REMOVE_STACK_MIN_ASSIGN := "amount = Math.min(amount, items.get(item));"
const SOURCE_BUILDING_REMOVE_STACK_NO_SLEEP_CALL := "noSleep();"
const SOURCE_BUILDING_REMOVE_STACK_ITEMS_REMOVE_CALL := "items.remove(item, amount);"
const SOURCE_BUILDING_REMOVE_STACK_RETURN_AMOUNT := "return amount;"
