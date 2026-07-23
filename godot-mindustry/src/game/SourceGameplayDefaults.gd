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
		profile = {"unit": {}, "builder": {}, "liquid": {}, "source": {}}
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
	return catalog.first_registered_content_id("liquids", "content_registry_liquids")

func unit_warp_dst() -> float:
	var unit: Dictionary = profile.get("unit", {})
	return float(unit.get("warp_dst", 0.0))

func final_world_bounds() -> float:
	var unit: Dictionary = profile.get("unit", {})
	return float(unit.get("final_world_bounds", 0.0))

func building_range() -> float:
	var builder: Dictionary = profile.get("builder", {})
	return float(builder.get("building_range", 0.0))

func liquid() -> Dictionary:
	return profile.get("liquid", {})

func liquid_transfer_source_amount() -> float:
	return float(liquid().get("transfer_source_amount", 0.0))

func liquid_transfer_destination_amount() -> float:
	return float(liquid().get("transfer_destination_amount", 0.0))

func liquid_capacity() -> float:
	return float(liquid().get("capacity", 0.0))

func liquid_pressure() -> float:
	return float(liquid().get("pressure", 0.0))

func liquid_leak_amount() -> float:
	return float(liquid().get("leak_amount", 0.0))

func liquid_dump_scaling() -> float:
	return float(liquid().get("dump_scaling", 0.0))

func liquid_leak_divisor() -> float:
	return float(liquid().get("leak_divisor", 0.0))

func runtime_summary() -> Dictionary:
	return {
		"loaded": not profile.is_empty(),
		"unit_warp_dst": unit_warp_dst(),
		"final_world_bounds": final_world_bounds(),
		"building_range": building_range(),
		"liquid_transfer_source_amount": liquid_transfer_source_amount(),
		"liquid_transfer_destination_amount": liquid_transfer_destination_amount(),
		"liquid_capacity": liquid_capacity(),
		"liquid_pressure": liquid_pressure(),
		"liquid_leak_amount": liquid_leak_amount(),
		"liquid_dump_scaling": liquid_dump_scaling(),
		"liquid_leak_divisor": liquid_leak_divisor(),
	}
