extends RefCounted
class_name SourceSsotCatalog

const MODULE_NAMES := ["registry", "audit_report", "slice_ledger", "api_contracts", "state_schema", "playable_content", "asset_manifest", "source_manifest", "ast_manifest", "content_registry", "emitted_classes", "port_report"]
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
	"playable_content": {
		"path": "res://src/generated/playable_content.json",
		"root_key": "",
		"label": "",
	},
	"asset_manifest": {
		"path": "res://src/generated/asset_manifest.json",
		"root_key": "",
		"label": "",
	},
	"source_manifest": {
		"path": "res://src/generated/source_manifest.json",
		"root_key": "",
		"label": "",
	},
	"ast_manifest": {
		"path": "res://src/generated/ast_manifest.json",
		"root_key": "",
		"label": "",
	},
	"content_registry": {
		"path": "res://src/generated/content_registry.json",
		"root_key": "",
		"label": "",
	},
	"emitted_classes": {
		"path": "res://src/generated/emitted_classes.json",
		"root_key": "",
		"label": "",
	},
	"port_report": {
		"path": "res://src/generated/port_report.json",
		"root_key": "",
		"label": "",
	},
}
const EXTENSION_MANIFEST_PATH := "res://src/generated/source_ssot_modules.json"

static func module_names() -> Array:
	return MODULE_NAMES.duplicate()

static func load_extension_manifest() -> Dictionary:
	var text := FileAccess.get_file_as_string(EXTENSION_MANIFEST_PATH)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"version": 0, "modules": {}}
	return parsed

static func extension_modules() -> Dictionary:
	var manifest := load_extension_manifest()
	var modules_value = manifest.get("modules", {})
	var modules: Dictionary = modules_value if typeof(modules_value) == TYPE_DICTIONARY else {}
	var result: Dictionary = {}
	for module_name in modules.keys():
		var entry_value = modules.get(module_name, {})
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = entry_value
		var relative_path := str(entry.get("path", ""))
		var resource_path := relative_path
		if not resource_path.begins_with("res://"):
			resource_path = "res://" + resource_path
		result[str(module_name)] = {
			"path": resource_path,
			"root_key": str(entry.get("root_key", "")),
			"label": str(entry.get("label", "")),
			"status": str(entry.get("status", "")),
			"rule": str(entry.get("rule", "")),
		}
	return result

static func extension_module_names() -> Array:
	return extension_modules().keys()

static func registered_module_names() -> Array:
	var names := module_names()
	names.append("module_manifest")
	names.append_array(extension_module_names())
	return names

static func module_metadata(module_name: String) -> Dictionary:
	if module_name == "module_manifest":
		return {"path": EXTENSION_MANIFEST_PATH, "root_key": "modules", "label": "module"}
	if MODULES.has(module_name):
		return MODULES.get(module_name, {})
	return extension_modules().get(module_name, {})

static func load_document(module_name: String) -> Dictionary:
	var metadata := module_metadata(module_name)
	if metadata.is_empty():
		return {"loaded": false, "module": module_name, "data": {}}
	var text := FileAccess.get_file_as_string(str(metadata.get("path", "")))
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"loaded": false, "module": module_name, "data": {}}
	return {"loaded": true, "module": module_name, "data": parsed}

static func manifest_summary_state(module_name: String, int_fields: Array, string_fields: Array, array_key: String, first_key: String) -> Dictionary:
	var document := load_document(module_name)
	var result := {"loaded": false}
	for field in int_fields:
		result[str(field)] = 0
	for field in string_fields:
		result[str(field)] = ""
	result[first_key] = {}
	if not bool(document.get("loaded", false)):
		return result
	var parsed: Dictionary = document.get("data", {})
	result["loaded"] = true
	for field in int_fields:
		result[str(field)] = int(parsed.get(str(field), 0))
	for field in string_fields:
		result[str(field)] = str(parsed.get(str(field), ""))
	var entries_value = parsed.get(array_key, [])
	var entries: Array = entries_value if typeof(entries_value) == TYPE_ARRAY else []
	var first_entry: Variant = {}
	if not entries.is_empty():
		first_entry = entries[0]
	result[first_key] = first_entry
	return result

static func collection_summary_state(module_name: String, string_fields: Array, counts_key: String, collection_names: Array) -> Dictionary:
	var document := load_document(module_name)
	var result := {"loaded": false, "counts": {}}
	for field in string_fields:
		result[str(field)] = ""
	for collection_name_value in collection_names:
		var collection_name := str(collection_name_value)
		var first_key := "first_" + collection_name.substr(0, collection_name.length() - 1)
		result[first_key] = {}
	if not bool(document.get("loaded", false)):
		return result
	var parsed: Dictionary = document.get("data", {})
	result["loaded"] = true
	for field in string_fields:
		result[str(field)] = str(parsed.get(str(field), ""))
	var counts_value = parsed.get(counts_key, {})
	result["counts"] = counts_value if typeof(counts_value) == TYPE_DICTIONARY else {}
	for collection_name_value in collection_names:
		var collection_name := str(collection_name_value)
		var entries_value = parsed.get(collection_name, [])
		var entries: Array = entries_value if typeof(entries_value) == TYPE_ARRAY else []
		var first_entry: Dictionary = {}
		if not entries.is_empty() and typeof(entries[0]) == TYPE_DICTIONARY:
			first_entry = entries[0]
		result["first_" + collection_name.substr(0, collection_name.length() - 1)] = first_entry
	return result

static func array_summary_state(module_name: String, int_fields: Array, string_fields: Array, array_keys: Array, first_keys: Array) -> Dictionary:
	var document := load_document(module_name)
	var result := {"loaded": false, "counts": {}}
	for field in int_fields:
		result[str(field)] = 0
	for field in string_fields:
		result[str(field)] = ""
	for first_key_value in first_keys:
		result[str(first_key_value)] = {}
	if not bool(document.get("loaded", false)):
		return result
	var parsed: Dictionary = document.get("data", {})
	result["loaded"] = true
	for field in int_fields:
		result[str(field)] = int(parsed.get(str(field), 0))
	for field in string_fields:
		result[str(field)] = str(parsed.get(str(field), ""))
	for i in range(array_keys.size()):
		var array_key := str(array_keys[i])
		var first_key := str(first_keys[i]) if i < first_keys.size() else "first_" + array_key
		var entries_value = parsed.get(array_key, [])
		var entries: Array = entries_value if typeof(entries_value) == TYPE_ARRAY else []
		var first_entry: Variant = {}
		if not entries.is_empty():
			first_entry = entries[0]
		result["counts"][array_key] = entries.size()
		result[first_key] = first_entry
	return result

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

static func ssot_modules_state(module_name: String = "") -> Dictionary:
	var manifest := load_extension_manifest()
	var modules := extension_modules()
	var entry: Dictionary = {}
	if module_name != "":
		entry = modules.get(module_name, {})
	return {
		"loaded": int(manifest.get("version", 0)) > 0,
		"version": int(manifest.get("version", 0)),
		"module": module_name,
		"core_modules": module_names(),
		"extension_modules": modules.keys(),
		"registered_modules": registered_module_names(),
		"count": modules.size(),
		"entry": entry,
		"policy": manifest.get("policy", {}),
	}
