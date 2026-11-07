extends RefCounted
class_name SourceAttributesState

const source_text := preload("res://src/game/SourceAttributesSourceTextState.gd")
const owner_registry := preload("res://src/game/SourceRuntimeOwnerBlockRegistry.gd")
const generated_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

const GENERATED_SCRIPT := source_text.GENERATED_SCRIPT

static func _checked(values: Array, attribute_all: Array) -> Array:
	var resized: Array = []
	resized.resize(attribute_all.size())
	for index in range(mini(values.size(), resized.size())):
		resized[index] = float(values[index])
	for index in range(resized.size()):
		if resized[index] == null:
			resized[index] = 0.0
	return resized

static func _base(owner: String, method: String, attribute_all: Array, arr: Array) -> Dictionary:
	return {"source_owner": owner, "source": source_text.SOURCE, "method": method, "attribute_all": attribute_all, "arr": arr}

static func clear_state(attribute_all: Array, arr: Array) -> Dictionary:
	var result_arr := _checked(arr, attribute_all)
	for index in range(result_arr.size()):
		result_arr[index] = 0.0
	var result := _base(owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_CLEAR_STATE, source_text.METHOD_CLEAR, attribute_all, result_arr)
	result["clear_expr"] = "Arrays.fill(arr, 0);"
	return result

static func get_state(attribute_all: Array, arr: Array, attr_id: int) -> Dictionary:
	var checked := _checked(arr, attribute_all)
	var value := float(checked[attr_id]) if attr_id >= 0 and attr_id < checked.size() else 0.0
	var result := _base(owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_GET_STATE, source_text.METHOD_GET, attribute_all, checked)
	result["attr_id"] = attr_id
	result["value"] = value
	result["check_expr"] = "check();"
	result["return_expr"] = "return arr[attr.id];"
	return result

static func set_state(attribute_all: Array, arr: Array, attr_id: int, value: float) -> Dictionary:
	var result_arr := _checked(arr, attribute_all)
	if attr_id >= 0 and attr_id < result_arr.size():
		result_arr[attr_id] = value
	var result := _base(owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_SET_STATE, source_text.METHOD_SET, attribute_all, result_arr)
	result["attr_id"] = attr_id
	result["value"] = value
	result["check_expr"] = "check();"
	result["assignment_expr"] = "arr[attr.id] = value;"
	return result

static func add_state(attribute_all: Array, arr: Array, other_arr: Array, scale: float = 1.0) -> Dictionary:
	var result_arr := _checked(arr, attribute_all)
	var checked_other := _checked(other_arr, attribute_all)
	for index in range(result_arr.size()):
		result_arr[index] = float(result_arr[index]) + float(checked_other[index]) * scale
	var method := source_text.METHOD_ADD if is_equal_approx(scale, 1.0) else source_text.METHOD_ADD_SCALED
	var owner := owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_ADD_STATE if is_equal_approx(scale, 1.0) else owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_ADD_SCALED_STATE
	var result := _base(owner, method, attribute_all, result_arr)
	result["other_arr"] = checked_other
	result["scale"] = scale
	result["check_expr"] = "check(); other.check();"
	result["loop_expr"] = "for(int i = 0; i < arr.length; i++){"
	result["assignment_expr"] = "arr[i] += other.arr[i] * scl;" if not is_equal_approx(scale, 1.0) else "arr[i] += other.arr[i];"
	return result

static func write_state(attribute_all: Array, arr: Array) -> Dictionary:
	var checked := _checked(arr, attribute_all)
	var data := {}
	for index in range(mini(attribute_all.size(), checked.size())):
		var attribute: Dictionary = attribute_all[index] if attribute_all[index] is Dictionary else {}
		var value := float(checked[index])
		if value != 0.0:
			data[str(attribute.get("name", ""))] = value
	var result := _base(owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_WRITE_STATE, source_text.METHOD_WRITE, attribute_all, checked)
	result["data"] = data
	result["write_expr"] = source_text.WRITE_NONZERO
	return result

static func read_state(attribute_all: Array, arr: Array, data: Dictionary) -> Dictionary:
	var result_arr := _checked(arr, attribute_all)
	for index in range(attribute_all.size()):
		var attribute: Dictionary = attribute_all[index] if attribute_all[index] is Dictionary else {}
		result_arr[index] = float(data.get(str(attribute.get("name", "")), 0.0))
	var result := _base(owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_READ_STATE, source_text.METHOD_READ, attribute_all, result_arr)
	result["data"] = data
	result["read_expr"] = source_text.READ_DEFAULT
	return result

static func check_state(attribute_all: Array, arr: Array) -> Dictionary:
	var result := _base(owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_CHECK_STATE, source_text.METHOD_CHECK, attribute_all, _checked(arr, attribute_all))
	result["resize_expr"] = source_text.CHECK_RESIZE
	result["copy_expr"] = source_text.CHECK_COPY
	return result

static func to_string_state(attribute_all: Array, arr: Array) -> Dictionary:
	var entries: Array = []
	for index in range(arr.size()):
		var value := float(arr[index])
		if value != 0.0:
			var attribute: Dictionary = attribute_all[index] if attribute_all[index] is Dictionary else {}
			entries.append({"name": str(attribute.get("name", "")), "value": value})
	var text := "Attributes{"
	for entry in entries:
		if text != "Attributes{":
			text += ", "
		text += str(entry["name"]) + ": " + (str(entry["value"]) if not float(entry["value"]) == floor(float(entry["value"])) else str(int(entry["value"])) + ".0")
	text += "}"
	var result := _base(owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_TO_STRING_STATE, source_text.METHOD_TO_STRING, attribute_all, arr)
	result["entries"] = entries
	result["text"] = text
	return result

static func generated_state(method: String, args: Array) -> Dictionary:
	return generated_runtime.call_java_method(GENERATED_SCRIPT, method, args)

static func _generated_bridge(owner: String, method: String, args: Array, canonical: Dictionary) -> Dictionary:
	var result := generated_state(method, args)
	return {"source_owner": owner, "generated_owner": "attributes." + method, "result": result, "canonical": canonical, "matches": generated_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_clear_bridge_state(attribute_all: Array, arr: Array) -> Dictionary:
	return _generated_bridge(owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_CLEAR_STATE, "java_method_clear_0", [attribute_all, arr], clear_state(attribute_all, arr))

static func generated_get_bridge_state(attribute_all: Array, arr: Array, attr_id: int) -> Dictionary:
	return _generated_bridge(owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_GET_STATE, "java_method_get_1", [attribute_all, arr, attr_id], get_state(attribute_all, arr, attr_id))

static func generated_set_bridge_state(attribute_all: Array, arr: Array, attr_id: int, value: float) -> Dictionary:
	return _generated_bridge(owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_SET_STATE, "java_method_set_2", [attribute_all, arr, attr_id, value], set_state(attribute_all, arr, attr_id, value))

static func generated_add_bridge_state(attribute_all: Array, arr: Array, other_arr: Array) -> Dictionary:
	return _generated_bridge(owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_ADD_STATE, "java_method_add_3", [attribute_all, arr, other_arr], add_state(attribute_all, arr, other_arr))

static func generated_add_scaled_bridge_state(attribute_all: Array, arr: Array, other_arr: Array, scale: float) -> Dictionary:
	return _generated_bridge(owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_ADD_SCALED_STATE, "java_method_add_4", [attribute_all, arr, other_arr, scale], add_state(attribute_all, arr, other_arr, scale))

static func generated_write_bridge_state(attribute_all: Array, arr: Array) -> Dictionary:
	return _generated_bridge(owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_WRITE_STATE, "java_method_write_5", [attribute_all, arr], write_state(attribute_all, arr))

static func generated_read_bridge_state(attribute_all: Array, arr: Array, data: Dictionary) -> Dictionary:
	return _generated_bridge(owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_READ_STATE, "java_method_read_6", [attribute_all, arr, data], read_state(attribute_all, arr, data))

static func generated_check_bridge_state(attribute_all: Array, arr: Array) -> Dictionary:
	return _generated_bridge(owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_CHECK_STATE, "java_method_check_7", [attribute_all, arr], check_state(attribute_all, arr))

static func generated_to_string_bridge_state(attribute_all: Array, arr: Array) -> Dictionary:
	return _generated_bridge(owner_registry.PORT_GAME_SOURCE_ATTRIBUTES_TO_STRING_STATE, "java_method_toString_8", [attribute_all, arr], to_string_state(attribute_all, arr))
