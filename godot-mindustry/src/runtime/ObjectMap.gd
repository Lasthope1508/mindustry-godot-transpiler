extends RefCounted
class_name ObjectMap

var data: Dictionary = {}

func put(key: Variant, value: Variant) -> void:
	data[key] = value

func get_value(key: Variant, default_value: Variant = null) -> Variant:
	return data.get(key, default_value)

func contains_key(key: Variant) -> bool:
	return data.has(key)

func keys() -> Array:
	return data.keys()
