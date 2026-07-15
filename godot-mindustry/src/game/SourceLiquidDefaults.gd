extends RefCounted
class_name SourceLiquidDefaults

var catalog: Variant

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog

func primary_liquid_id() -> String:
	var registry_document: Dictionary = catalog.load_document("content_registry")
	var liquids_document: Dictionary = catalog.load_document("content_registry_liquids")
	if not bool(registry_document.get("loaded", false)) or not bool(liquids_document.get("loaded", false)):
		return ""
	var registry_data: Dictionary = registry_document.get("data", {})
	var liquids_data: Dictionary = liquids_document.get("data", {})
	var registry_liquids: Array = registry_data.get("liquids", [])
	var liquid_entries: Dictionary = liquids_data.get("liquids", {})
	for entry_value in registry_liquids:
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = entry_value
		var liquid_id := str(entry.get("id", ""))
		if liquid_id == "" or not liquid_entries.has(liquid_id):
			continue
		var shard_entry_value = liquid_entries.get(liquid_id, {})
		if typeof(shard_entry_value) != TYPE_DICTIONARY:
			continue
		var shard_entry: Dictionary = shard_entry_value
		if str(shard_entry.get("canonical_liquid", "")) != "content_registry.liquids.%s" % liquid_id:
			continue
		return str(entry.get("id", ""))
	return ""
