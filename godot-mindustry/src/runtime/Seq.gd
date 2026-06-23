extends RefCounted
class_name Seq

var items: Array = []

func _init(initial: Array = []) -> void:
	items = initial.duplicate()

func add(value: Variant) -> Seq:
	items.append(value)
	return self

func get(index: int) -> Variant:
	return items[index]

func size() -> int:
	return items.size()

func is_empty() -> bool:
	return items.is_empty()

func to_array() -> Array:
	return items.duplicate()
