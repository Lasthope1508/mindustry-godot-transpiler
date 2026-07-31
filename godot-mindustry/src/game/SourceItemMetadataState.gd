extends RefCounted
class_name SourceItemMetadataState

const source_item_defaults := preload("res://src/game/SourceItemDefaults.gd")

const SOURCE_ITEM_BUILDABLE_DEFAULT := source_item_defaults.BUILDABLE_DEFAULT

static func item_properties(item) -> Dictionary:
	if item == null:
		return {}
	if item is Dictionary:
		var dictionary: Dictionary = item
		if dictionary.has("properties") and dictionary.get("properties") is Dictionary:
			return dictionary.get("properties", {}).duplicate(true)
		return dictionary.duplicate(true)
	if item is Object:
		var properties = item.get("properties")
		if properties is Dictionary:
			return properties.duplicate(true)
	return {}

static func item_buildable(item_id: String, content_catalog) -> bool:
	var item = content_catalog.get_by_id(item_id) if content_catalog != null else null
	var properties := item_properties(item)
	return bool(properties.get("buildable", SOURCE_ITEM_BUILDABLE_DEFAULT))
