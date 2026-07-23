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
		var mirror_fields_value = entry.get("mirror_fields", [])
		var mirror_fields: Array = mirror_fields_value if typeof(mirror_fields_value) == TYPE_ARRAY else []
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
			"canonical_module": str(entry.get("canonical_module", "")),
			"canonical_collection_key": str(entry.get("canonical_collection_key", "")),
			"canonical_key_field": str(entry.get("canonical_key_field", "")),
			"canonical_value_field": str(entry.get("canonical_value_field", "")),
			"canonical_reference_key": str(entry.get("canonical_reference_key", "")),
			"canonical_reference_prefix": str(entry.get("canonical_reference_prefix", "")),
			"mirror_fields": mirror_fields.duplicate(),
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

static func document_loaded(module_name: String) -> bool:
	return bool(load_document(module_name).get("loaded", false))

static func document_data(module_name: String) -> Dictionary:
	var document := load_document(module_name)
	if not bool(document.get("loaded", false)):
		return {}
	var data = document.get("data", {})
	return data if typeof(data) == TYPE_DICTIONARY else {}

static func document_root_data(module_name: String, root_key: String) -> Dictionary:
	var data := document_data(module_name)
	var root_value = data.get(root_key, {})
	return root_value if typeof(root_value) == TYPE_DICTIONARY else {}

static func first_nested_array_value(module_name: String, parent_key: String, array_key: String) -> Variant:
	var data := document_data(module_name)
	var parent_value = data.get(parent_key, {})
	var parent: Dictionary = parent_value if typeof(parent_value) == TYPE_DICTIONARY else {}
	var values_value = parent.get(array_key, [])
	var values: Array = values_value if typeof(values_value) == TYPE_ARRAY else []
	if values.is_empty():
		return null
	return values[0]

static func first_registered_content_id(collection_key: String, shard_module_name: String) -> String:
	var registry_document := load_document("content_registry")
	var shard_document := load_document(shard_module_name)
	if not bool(registry_document.get("loaded", false)) or not bool(shard_document.get("loaded", false)):
		return ""
	var registry_data: Dictionary = registry_document.get("data", {})
	var shard_data: Dictionary = shard_document.get("data", {})
	var registry_entries_value = registry_data.get(collection_key, [])
	var registry_entries: Array = registry_entries_value if typeof(registry_entries_value) == TYPE_ARRAY else []
	var shard_entries_value = shard_data.get(collection_key, {})
	var shard_entries: Dictionary = shard_entries_value if typeof(shard_entries_value) == TYPE_DICTIONARY else {}
	var metadata := module_metadata(shard_module_name)
	var canonical_reference_key := str(metadata.get("canonical_reference_key", ""))
	var canonical_reference_prefix := str(metadata.get("canonical_reference_prefix", ""))
	for entry_value in registry_entries:
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = entry_value
		var content_id := str(entry.get("id", ""))
		if content_id == "" or not shard_entries.has(content_id):
			continue
		var shard_entry_value = shard_entries.get(content_id, {})
		if typeof(shard_entry_value) != TYPE_DICTIONARY:
			continue
		var shard_entry: Dictionary = shard_entry_value
		if canonical_reference_key != "" and str(shard_entry.get(canonical_reference_key, "")) != "%s%s" % [canonical_reference_prefix, content_id]:
			continue
		return content_id
	return ""

static func ordered_shard_nested_entries(module_name: String, root_key: String, nested_key: String) -> Array:
	var document := load_document(module_name)
	if not bool(document.get("loaded", false)):
		return []
	var data: Dictionary = document.get("data", {})
	var entries_value = data.get(root_key, {})
	var entries: Dictionary = entries_value if typeof(entries_value) == TYPE_DICTIONARY else {}
	var indexes: Array = []
	for index_key in entries.keys():
		indexes.append(int(str(index_key)))
	indexes.sort()
	var result: Array = []
	for index in indexes:
		var entry_value = entries.get(str(index), {})
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = entry_value
		var nested_value = entry.get(nested_key, {})
		if typeof(nested_value) != TYPE_DICTIONARY:
			continue
		result.append(nested_value)
	return result

static func keyed_array_lookup_state(module_name: String, array_key: String, key_field: String, label: String, key_value: String = "") -> Dictionary:
	var document := load_document(module_name)
	if not bool(document.get("loaded", false)):
		return {"loaded": false, "count": 0, label: key_value, "entry": {}}
	var parsed: Dictionary = document.get("data", {})
	var entries_value = parsed.get(array_key, [])
	var entries: Array = entries_value if typeof(entries_value) == TYPE_ARRAY else []
	var entry: Dictionary = {}
	if key_value != "":
		for candidate in entries:
			if typeof(candidate) != TYPE_DICTIONARY:
				continue
			if str(candidate.get(key_field, "")) == key_value:
				entry = candidate
				break
	return {
		"loaded": true,
		"version": int(parsed.get("version", 0)),
		"count": entries.size(),
		label: key_value,
		"entry": entry,
		"policy": parsed.get("policy", {}),
	}

static func indexed_array_lookup_state(module_name: String, array_key: String, label: String, key_value: String = "") -> Dictionary:
	var document := load_document(module_name)
	if not bool(document.get("loaded", false)):
		return {"loaded": false, "count": 0, label: key_value, "entry": {}}
	var parsed: Dictionary = document.get("data", {})
	var entries_value = parsed.get(array_key, [])
	var entries: Array = entries_value if typeof(entries_value) == TYPE_ARRAY else []
	var entry: Dictionary = {}
	if key_value != "" and key_value.is_valid_int():
		var index := int(key_value)
		if index >= 0 and index < entries.size():
			var entry_value = entries[index]
			entry = entry_value if typeof(entry_value) == TYPE_DICTIONARY else {"value": entry_value}
	return {
		"loaded": true,
		"version": int(parsed.get("version", 0)),
		"count": entries.size(),
		label: key_value,
		"entry": entry,
		"policy": parsed.get("policy", {}),
	}

static func indexed_array_value_lookup_state(module_name: String, array_key: String, label: String, value_field: String, canonical_reference_key: String, canonical_reference_prefix: String, key_value: String = "") -> Dictionary:
	var document := load_document(module_name)
	if not bool(document.get("loaded", false)):
		return {"loaded": false, "count": 0, label: key_value, "entry": {}}
	var parsed: Dictionary = document.get("data", {})
	var entries_value = parsed.get(array_key, [])
	var entries: Array = entries_value if typeof(entries_value) == TYPE_ARRAY else []
	var entry: Dictionary = {}
	if key_value != "" and key_value.is_valid_int():
		var index := int(key_value)
		if index >= 0 and index < entries.size():
			var entry_value = entries[index]
			var is_dictionary_entry := typeof(entry_value) == TYPE_DICTIONARY
			entry = entry_value.duplicate(true) if is_dictionary_entry else {}
			entry["index"] = index
			entry[value_field] = entry_value
			if canonical_reference_key != "":
				entry[canonical_reference_key] = "%s%s" % [canonical_reference_prefix, str(index)]
	return {
		"loaded": true,
		"version": int(parsed.get("version", 0)),
		"count": entries.size(),
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

static func module_manifest_entry_state(module_name: String = "") -> Dictionary:
	var manifest := load_extension_manifest()
	var modules_value = manifest.get("modules", {})
	var modules: Dictionary = modules_value if typeof(modules_value) == TYPE_DICTIONARY else {}
	var entry: Dictionary = {}
	if module_name != "":
		var raw_entry = modules.get(module_name, {})
		if typeof(raw_entry) == TYPE_DICTIONARY:
			var mirror_fields_value = raw_entry.get("mirror_fields", [])
			var mirror_fields: Array = mirror_fields_value if typeof(mirror_fields_value) == TYPE_ARRAY else []
			entry = {
				"canonical_manifest_entry": "source_ssot_modules.modules.%s" % module_name,
				"path": raw_entry.get("path", ""),
				"root_key": raw_entry.get("root_key", ""),
				"label": raw_entry.get("label", ""),
				"status": raw_entry.get("status", ""),
				"rule": raw_entry.get("rule", ""),
				"canonical_module": raw_entry.get("canonical_module", ""),
				"canonical_reference_key": raw_entry.get("canonical_reference_key", ""),
				"canonical_reference_prefix": raw_entry.get("canonical_reference_prefix", ""),
				"mirror_fields": mirror_fields.duplicate(),
				"entry": raw_entry.duplicate(true),
			}
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
