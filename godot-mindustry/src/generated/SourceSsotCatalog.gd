extends RefCounted
class_name SourceSsotCatalog

const MODULE_NAMES := ["registry", "audit_report", "slice_ledger", "api_contracts", "state_schema"]
const MODULES := {
	"registry": {
		"path": "res://src/generated/source_symbol_registry.json",
		"root_key": "symbols",
		"label": "symbol",
	},
	"audit_report": {
		"path": "res://src/generated/source_symbol_audit_report.json",
		"root_key": "",
		"label": "",
	},
	"slice_ledger": {
		"path": "res://src/generated/source_slice_ledger.json",
		"root_key": "slices",
		"label": "sliceId",
	},
	"api_contracts": {
		"path": "res://src/generated/source_api_contracts.json",
		"root_key": "contracts",
		"label": "owner",
	},
	"state_schema": {
		"path": "res://src/generated/source_state_schema.json",
		"root_key": "schemas",
		"label": "schemaName",
	},
}

static func module_names() -> Array:
	return MODULE_NAMES.duplicate()

static func module_metadata(module_name: String) -> Dictionary:
	return MODULES.get(module_name, {})

static func load_document(module_name: String) -> Dictionary:
	var metadata := module_metadata(module_name)
	if metadata.is_empty():
		return {"loaded": false, "module": module_name, "data": {}}
	var text := FileAccess.get_file_as_string(str(metadata.get("path", "")))
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"loaded": false, "module": module_name, "data": {}}
	return {"loaded": true, "module": module_name, "data": parsed}

static func lookup_state(module_name: String, key_value: String = "") -> Dictionary:
	var metadata := module_metadata(module_name)
	var label := str(metadata.get("label", "key"))
	var root_key := str(metadata.get("root_key", ""))
	var document := load_document(module_name)
	if not bool(document.get("loaded", false)):
		return {"loaded": false, "count": 0, label: key_value, "entry": {}}
	var parsed: Dictionary = document.get("data", {})
	var collection_value = parsed.get(root_key, {})
	var collection: Dictionary = collection_value if typeof(collection_value) == TYPE_DICTIONARY else {}
	var entry: Dictionary = {}
	if key_value != "":
		entry = collection.get(key_value, {})
	return {
		"loaded": true,
		"version": int(parsed.get("version", 0)),
		"count": collection.size(),
		label: key_value,
		"entry": entry,
		"policy": parsed.get("policy", {}),
	}

static func audit_summary_state() -> Dictionary:
	var document := load_document("audit_report")
	if not bool(document.get("loaded", false)):
		return {"loaded": false, "totalSourceFunctions": 0, "legacyUnregisteredOwnerCount": 0}
	var parsed: Dictionary = document.get("data", {})
	return {
		"loaded": true,
		"version": int(parsed.get("version", 0)),
		"totalSourceFunctions": int(parsed.get("totalSourceFunctions", 0)),
		"registeredSourceOwnerCount": int(parsed.get("registeredSourceOwnerCount", 0)),
		"exemptSourceOwnerCount": int(parsed.get("exemptSourceOwnerCount", 0)),
		"legacyUnregisteredOwnerCount": int(parsed.get("legacyUnregisteredOwnerCount", 0)),
		"policy": parsed.get("policy", {}),
	}
