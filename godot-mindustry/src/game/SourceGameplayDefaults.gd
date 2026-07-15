extends RefCounted
class_name SourceGameplayDefaults

var catalog: Variant
var profile: Dictionary = {}

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog
	load_gameplay_profile()

func load_gameplay_profile() -> void:
	var document: Dictionary = catalog.load_document("gameplay_profile")
	if not bool(document.get("loaded", false)):
		profile = {"unit": {}, "builder": {}, "source": {}}
		return
	var data: Dictionary = document.get("data", {})
	profile = data.get("gameplay", {})

func first_pinned_build_block_id() -> String:
	var document: Dictionary = catalog.load_document("playable_content")
	if not bool(document.get("loaded", false)):
		return ""
	var data: Dictionary = document.get("data", {})
	var palette: Dictionary = data.get("build_palette", {})
	var pinned_block_ids: Array = palette.get("pinned_block_ids", [])
	if pinned_block_ids.is_empty():
		return ""
	return str(pinned_block_ids[0])

func first_pinned_payload(content_catalog: Variant) -> Dictionary:
	var block_id := first_pinned_build_block_id()
	if block_id == "" or content_catalog == null:
		return {}
	var block = content_catalog.get_by_id(block_id)
	if block == null:
		return {}
	return {"kind": "block", "content": block_id, "size": max(1, int(block.properties.get("size", 1)))}

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

func unit_warp_dst() -> float:
	var unit: Dictionary = profile.get("unit", {})
	return float(unit.get("warp_dst", 0.0))

func final_world_bounds() -> float:
	var unit: Dictionary = profile.get("unit", {})
	return float(unit.get("final_world_bounds", 0.0))

func building_range() -> float:
	var builder: Dictionary = profile.get("builder", {})
	return float(builder.get("building_range", 0.0))

func runtime_summary() -> Dictionary:
	return {
		"loaded": not profile.is_empty(),
		"unit_warp_dst": unit_warp_dst(),
		"final_world_bounds": final_world_bounds(),
		"building_range": building_range(),
	}
