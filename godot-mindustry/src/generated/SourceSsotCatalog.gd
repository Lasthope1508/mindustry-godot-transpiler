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

static func canonical_headquarter_registry_state(module_name: String = "") -> Dictionary:
	var manifest := load_extension_manifest()
	var modules := extension_modules()
	var policy_value = manifest.get("policy", {})
	var policy: Dictionary = policy_value if typeof(policy_value) == TYPE_DICTIONARY else {}
	var registry: Dictionary = {}
	var headquarters: Dictionary = {}
	var seen_headquarters: Dictionary = {}
	var features: Dictionary = {}
	var alias_registry: Dictionary = {}
	var module_registry: Dictionary = {}
	var duplicate_headquarters: Array = []
	var duplicate_features: Array = []
	var duplicate_aliases: Array = []
	var complete_mirrors_by_key: Dictionary = {}
	var errors: Array = []
	for current_module_name in modules.keys():
		var entry: Dictionary = modules.get(current_module_name, {})
		var managed_module_name := str(current_module_name)
		var managed_key := _canonical_managed_module_key(current_module_name, entry)
		var headquarter := _canonical_headquarter_module_name(current_module_name, entry)
		var canonical_feature := _canonical_feature_key(current_module_name, entry, managed_key)
		var canonical_key := managed_key
		if not registry.has(managed_key):
			registry[managed_key] = []
		registry[managed_key].append(current_module_name)
		if not complete_mirrors_by_key.has(managed_key):
			complete_mirrors_by_key[managed_key] = []
		complete_mirrors_by_key[managed_key].append(current_module_name)
		if features.has(canonical_feature):
			duplicate_features.append({"canonical_feature": canonical_feature, "first": features[canonical_feature], "duplicate": current_module_name})
		features[canonical_feature] = managed_key
		if headquarters.has(managed_key) and str(headquarters.get(managed_key, "")) != headquarter:
			errors.append("module_manifest: canonical HQ %s points to %s, found %s" % [managed_key, headquarters.get(managed_key, ""), headquarter])
		headquarters[managed_key] = headquarter
		if headquarter == "":
			errors.append("module_manifest: canonical HQ %s missing runtime headquarter" % managed_key)
		elif seen_headquarters.has(headquarter) and str(seen_headquarters.get(headquarter, "")) != managed_key:
			duplicate_headquarters.append({"headquarter": headquarter, "first": seen_headquarters[headquarter], "duplicate": managed_key})
			errors.append("module_manifest: canonical HQ runtime headquarter %s duplicates %s at %s" % [headquarter, seen_headquarters[headquarter], managed_key])
		else:
			seen_headquarters[headquarter] = managed_key
		var feature_entry := {
			"canonical_key": managed_key,
			"canonical_feature": canonical_feature,
			"headquarter": headquarter,
			"managed_module": managed_module_name,
			"entry": entry.duplicate(true),
		}
		module_registry[managed_module_name] = {
			"canonical_key": managed_key,
			"canonical_feature": canonical_feature,
			"canonical_aliases": _canonical_policy_aliases(canonical_key, feature_entry, alias_registry, policy),
			"headquarter": headquarter,
			"module": managed_module_name,
		}
		var aliases_for_key: Array = _canonical_policy_aliases(managed_key, feature_entry, alias_registry, policy)
		for alias_value in aliases_for_key:
			var alias_key := _normalized_policy_alias(str(alias_value))
			if alias_key == "":
				errors.append("module_manifest: canonical alias registry %s contains an empty alias" % managed_key)
				continue
			if alias_registry.has(alias_key) and str(alias_registry.get(alias_key, {}).get("canonical_key", "")) != managed_key:
				duplicate_aliases.append({"alias": alias_key, "first": alias_registry[alias_key], "duplicate": feature_entry})
				errors.append("module_manifest: canonical feature runtime alias %s duplicates %s at %s" % [alias_key, alias_registry[alias_key].get("canonical_key", ""), managed_key])
				continue
			alias_registry[alias_key] = feature_entry
	var canonical_headquarters := _canonical_headquarters_policy(headquarters, policy)
	for canonical_key in headquarters.keys():
		var modules_for_key: Array = registry.get(canonical_key, [])
		if modules_for_key.size() != 1:
			errors.append("module_manifest: canonical managed module %s must have exactly one module, found %s" % [canonical_key, modules_for_key.size()])
		var complete_mirrors: Array = complete_mirrors_by_key.get(canonical_key, [])
		if complete_mirrors.size() != 1:
			errors.append("module_manifest: canonical HQ %s must have exactly one complete mirror, found %s" % [canonical_key, complete_mirrors.size()])
		if not canonical_headquarters.has(canonical_key):
			errors.append("module_manifest: canonical feature registry %s has no canonicalHeadquarters entry" % canonical_key)
	var canonical_feature_registry_value = policy.get("canonicalFeatureRegistry", {})
	if policy.has("canonicalFeatureRegistry") and typeof(canonical_feature_registry_value) != TYPE_DICTIONARY:
		errors.append("module_manifest: canonical feature registry missing %s" % module_name)
	var canonical_aliases_value = policy.get("canonicalAliases", {})
	if policy.has("canonicalAliases") and typeof(canonical_aliases_value) != TYPE_DICTIONARY:
		errors.append("module_manifest: canonical alias registry missing %s" % module_name)
	var canonical_aliases: Dictionary = canonical_aliases_value if typeof(canonical_aliases_value) == TYPE_DICTIONARY else {}
	for alias_key in canonical_aliases.keys():
		if not canonical_headquarters.has(alias_key):
			errors.append("module_manifest: canonical alias registry %s has no canonicalHeadquarters entry" % alias_key)
		var aliases_value = canonical_aliases.get(alias_key, [])
		if typeof(aliases_value) != TYPE_ARRAY:
			errors.append("module_manifest: canonical alias registry %s must be a list" % alias_key)
			continue
		var aliases: Array = aliases_value
		if aliases.is_empty():
			errors.append("module_manifest: canonical alias registry %s must be non-empty" % alias_key)
		for alias_value in aliases:
			if str(alias_value) == "":
				errors.append("module_manifest: canonical alias registry %s contains an empty alias" % alias_key)
	var selected_entry: Dictionary = {}
	if module_name != "":
		var lookup := canonical_headquarter_lookup_state(module_name)
		selected_entry = lookup.get("entry", {})
	return {
		"loaded": int(manifest.get("version", 0)) > 0,
		"version": int(manifest.get("version", 0)),
		"module": module_name,
		"valid": errors.is_empty(),
		"errors": errors.duplicate(),
		"managed_ssot_count": registry.size(),
		"canonical_key_count": headquarters.size(),
		"headquarter_count": seen_headquarters.size(),
		"headquarter_count_matches_canonical_keys": seen_headquarters.size() == headquarters.size(),
		"canonical_feature_count": features.size(),
		"alias_count": alias_registry.size(),
		"module_registry_count": module_registry.size(),
		"module_registry": module_registry,
		"registry": registry,
		"headquarters": headquarters,
		"features": features,
		"aliases": alias_registry,
		"duplicate_headquarters": duplicate_headquarters.duplicate(true),
		"duplicate_features": duplicate_features.duplicate(true),
		"duplicate_aliases": duplicate_aliases.duplicate(true),
		"one_headquarter_per_ssot": seen_headquarters.size() == headquarters.size() and errors.is_empty(),
		"entry": selected_entry,
		"policy": policy,
	}

static func canonical_headquarter_lookup_state(alias_name: String = "") -> Dictionary:
	var registry_state := canonical_headquarter_registry_state("")
	var alias_registry: Dictionary = registry_state.get("aliases", {})
	var entry: Dictionary = {}
	var canonical_key := ""
	for candidate_key in [alias_name, _normalized_policy_alias(alias_name)]:
		var normalized_candidate := _normalized_policy_alias(str(candidate_key))
		if normalized_candidate == "":
			continue
		if alias_registry.has(normalized_candidate):
			entry = alias_registry.get(normalized_candidate, {})
			canonical_key = str(entry.get("canonical_key", ""))
			break
	if entry.is_empty():
		for candidate_key in _canonical_headquarter_lookup_candidates(alias_name):
			var normalized_candidate := _normalized_policy_alias(str(candidate_key))
			if alias_registry.has(normalized_candidate):
				entry = alias_registry.get(normalized_candidate, {})
				canonical_key = str(entry.get("canonical_key", ""))
				break
	if entry.is_empty() and _is_source_symbol_registry_headquarter_alias(alias_name):
		var policy_entry := _policy_headquarter_entry(alias_name, registry_state.get("policy", {}))
		entry = policy_entry
		canonical_key = str(entry.get("canonical_key", ""))
	return {
		"loaded": bool(registry_state.get("loaded", false)),
		"valid": bool(registry_state.get("valid", false)),
		"alias": alias_name,
		"canonical_key": canonical_key,
		"headquarter": str(entry.get("headquarter", "")),
		"entry": entry,
		"errors": registry_state.get("errors", []),
	}

static func _is_source_symbol_registry_headquarter_alias(alias_name: String) -> bool:
	return not _policy_headquarter_entry(alias_name, load_extension_manifest().get("policy", {})).is_empty()

static func _policy_headquarter_entry(alias_name: String, policy: Dictionary) -> Dictionary:
	var canonical_aliases := _canonical_alias_policy(policy)
	var canonical_headquarters_value = policy.get("canonicalHeadquarters", {})
	var canonical_headquarters: Dictionary = canonical_headquarters_value if typeof(canonical_headquarters_value) == TYPE_DICTIONARY else {}
	var normalized_alias := _normalized_policy_alias(alias_name)
	for canonical_key_value in canonical_aliases.keys():
		var canonical_key := str(canonical_key_value)
		for alias_value in _policy_aliases_for_key(canonical_key, policy):
			if _normalized_policy_alias(str(alias_value)) != normalized_alias:
				continue
			var metadata := module_metadata(canonical_key)
			return {
				"canonical_key": canonical_key,
				"canonical_feature": canonical_key,
				"canonical_aliases": _policy_aliases_for_key(canonical_key, policy),
				"headquarter": str(canonical_headquarters.get(canonical_key, canonical_key)),
				"managed_module": canonical_key,
				"module": canonical_key,
				"entry": metadata.duplicate(true),
			}
	return {}

static func _canonical_managed_module_key(current_module_name: String, entry: Dictionary) -> String:
	var canonical_module := str(entry.get("canonical_module", ""))
	var collection_key := str(entry.get("canonical_collection_key", ""))
	if canonical_module == "":
		return _canonical_root_module_key(current_module_name, entry)
	if collection_key != "":
		return "%s.%s" % [canonical_module, collection_key]
	var domain := _canonical_module_domain(current_module_name)
	if domain != "":
		return "%s.%s" % [domain, canonical_module]
	return canonical_module

static func _canonical_root_module_key(current_module_name: String, entry: Dictionary) -> String:
	var root_key := str(entry.get("root_key", ""))
	if current_module_name == "source_symbol_registry_symbols":
		return "registry"
	if current_module_name == "source_api_contracts_contracts":
		return "api_contracts"
	if current_module_name == "source_state_schema_schemas":
		return "state_schema"
	if current_module_name == "source_slice_ledger_slices":
		return "slice_ledger"
	if current_module_name.begins_with("source_audit_"):
		return "audit_report.%s" % root_key
	return current_module_name

static func _canonical_headquarter_module_name(current_module_name: String, entry: Dictionary) -> String:
	return current_module_name if str(entry.get("status", "")) == "active" else ""

static func _canonical_feature_key(current_module_name: String, entry: Dictionary, canonical_key: String) -> String:
	var _current_module_name := current_module_name
	var collection_key := str(entry.get("canonical_collection_key", ""))
	if collection_key != "":
		return "%s.%s" % [canonical_key, collection_key]
	return canonical_key

static func _canonical_module_domain(current_module_name: String) -> String:
	var suffixes := ["_slices", "_api_contracts", "_state_schema", "_symbols"]
	for suffix in suffixes:
		if current_module_name.ends_with(suffix):
			return current_module_name.substr(0, current_module_name.length() - suffix.length())
	return ""

static func _canonical_headquarter_lookup_candidates(alias_name: String) -> Array:
	var normalized := _normalized_policy_alias(alias_name)
	var candidates: Array = [alias_name, normalized]
	if normalized.find(".") >= 0:
		candidates.append(normalized.replace(".", "_"))
		candidates.append(normalized.replace(".", " "))
	if normalized.find("_") >= 0:
		candidates.append(normalized.replace("_", "."))
		candidates.append(normalized.replace("_", " "))
	return _unique_strings(candidates)

static func _canonical_policy_aliases(canonical_key: String, feature_entry: Dictionary, alias_registry: Dictionary, policy: Dictionary) -> Array:
	var _alias_registry := alias_registry
	var aliases: Array = [canonical_key]
	var canonical_feature := str(feature_entry.get("canonical_feature", ""))
	var managed_module_name := str(feature_entry.get("managed_module", ""))
	var headquarter := str(feature_entry.get("headquarter", ""))
	aliases.append(canonical_feature)
	aliases.append(managed_module_name)
	aliases.append(headquarter)
	for source_value in [canonical_key, canonical_feature, managed_module_name, headquarter]:
		var normalized := _normalized_policy_alias(str(source_value))
		if normalized == "":
			continue
		aliases.append(normalized)
		aliases.append(normalized.replace(".", " "))
		aliases.append(normalized.replace(".", "_"))
	aliases.append_array(_policy_aliases_for_key(canonical_key, policy))
	return _unique_strings(aliases)

static func _canonical_alias_policy(policy: Dictionary) -> Dictionary:
	var canonical_aliases_value = policy.get("canonicalAliases", {})
	return canonical_aliases_value if typeof(canonical_aliases_value) == TYPE_DICTIONARY else {}

static func _canonical_headquarters_policy(headquarters: Dictionary, policy: Dictionary) -> Dictionary:
	var result := headquarters.duplicate()
	var canonical_headquarters_value = policy.get("canonicalHeadquarters", {})
	var canonical_headquarters: Dictionary = canonical_headquarters_value if typeof(canonical_headquarters_value) == TYPE_DICTIONARY else {}
	for canonical_key in canonical_headquarters.keys():
		result[str(canonical_key)] = str(canonical_headquarters.get(canonical_key, ""))
	return result

static func _policy_aliases_for_key(canonical_key: String, policy: Dictionary) -> Array:
	var canonical_aliases := _canonical_alias_policy(policy)
	var aliases_value = canonical_aliases.get(canonical_key, [])
	return aliases_value if typeof(aliases_value) == TYPE_ARRAY else []

static func _normalized_policy_alias(alias_name: String) -> String:
	var lowered := alias_name.strip_edges().to_lower()
	var parts: Array = []
	var token := ""
	for index in range(lowered.length()):
		var codepoint := lowered.unicode_at(index)
		if _is_ascii_policy_alias_character(codepoint):
			token += lowered.substr(index, 1)
		elif token != "":
			parts.append(token)
			token = ""
	if token != "":
		parts.append(token)
	return ".".join(parts)

static func _is_ascii_policy_alias_character(codepoint: int) -> bool:
	return (codepoint >= 48 and codepoint <= 57) or (codepoint >= 97 and codepoint <= 122)

static func _unique_strings(values: Array) -> Array:
	var seen: Dictionary = {}
	var result: Array = []
	for value in values:
		var text := str(value)
		if text == "" or seen.has(text):
			continue
		seen[text] = true
		result.append(text)
	return result

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
