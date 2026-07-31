extends RefCounted
class_name SourceGeneratedClassRuntime

static func java_key_for_entry(entry: Dictionary) -> String:
	return "%s.%s" % [str(entry.get("java_package", "")), str(entry.get("java_name", ""))]

static func _empty_load_state() -> Dictionary:
	return {
		"scripts": {},
		"instances": {},
		"load_failures": [],
		"instance_failures": [],
		"class_names": [],
		"instance_names": [],
		"missing_classes": [],
	}

static func _load_entry_into_state(state: Dictionary, entry: Dictionary, key: String, track_name: String, expose_track_name: bool) -> void:
	var script = ResourceLoader.load(str(entry.get("gdscript_path", "")))
	if script == null:
		state["load_failures"].append(key)
		return
	state["scripts"][key] = script
	if expose_track_name:
		state["class_names"].append(track_name)
	var instance = script.new()
	if instance == null:
		state["instance_failures"].append(key)
		return
	state["instances"][key] = instance
	if expose_track_name:
		state["instance_names"].append(track_name)

static func load_all_classes(entries: Array) -> Dictionary:
	var state := _empty_load_state()
	for entry in entries:
		_load_entry_into_state(state, entry, java_key_for_entry(entry), str(entry.get("java_name", "")), false)
	return state

static func load_selected_classes(selected_java_names: Array[String], entries: Array) -> Dictionary:
	var state := _empty_load_state()
	var registry_by_java_name: Dictionary = {}
	for entry in entries:
		registry_by_java_name[str(entry.get("java_name", ""))] = entry
	for java_name in selected_java_names:
		var entry: Dictionary = registry_by_java_name.get(java_name, {})
		if entry.is_empty():
			state["missing_classes"].append(java_name)
			continue
		_load_entry_into_state(state, entry, java_name, java_name, true)
	return state

static func call_java_method(gdscript_path: String, generated_method: String, generated_args: Array, fallback: Variant = null, metadata: Dictionary = {}) -> Variant:
	var script = ResourceLoader.load(gdscript_path)
	if script == null:
		return fallback
	var instance = script.new()
	if instance == null or not instance.has_method(generated_method):
		return fallback
	for meta_key in metadata.keys():
		instance.set_meta(str(meta_key), metadata[meta_key])
	return instance.call(generated_method, generated_args)

static func generated_state_matches_generated_subset(result: Variant, canonical: Variant) -> bool:
	if (result is Dictionary) != (canonical is Dictionary):
		return false
	if (result is Array) != (canonical is Array):
		return false
	if result is Dictionary and canonical is Dictionary:
		for key in result.keys():
			if not canonical.has(key):
				return false
			if not generated_state_matches_generated_subset(result.get(key), canonical.get(key)):
				return false
		return true
	if result is Array and canonical is Array:
		if result.size() != canonical.size():
			return false
		for index in range(result.size()):
			if not generated_state_matches_generated_subset(result[index], canonical[index]):
				return false
		return true
	return result == canonical

static func generated_state_matches_canonical_subset(result: Variant, canonical: Variant, ignored_keys: Array = []) -> bool:
	if (result is Dictionary) != (canonical is Dictionary):
		return false
	if (result is Array) != (canonical is Array):
		return false
	if result is Dictionary and canonical is Dictionary:
		for key in canonical.keys():
			if ignored_keys.has(key):
				continue
			if not result.has(key):
				return false
			if not generated_state_matches_canonical_subset(result.get(key), canonical.get(key), []):
				return false
		return true
	if result is Array and canonical is Array:
		if result.size() != canonical.size():
			return false
		for index in range(canonical.size()):
			if not generated_state_matches_canonical_subset(result[index], canonical[index], []):
				return false
		return true
	return result == canonical

static func generated_state_matches_canonical_subset_or_nan(result: Variant, canonical: Variant, nan_key: String, identity_key: String, ignored_keys: Array = []) -> bool:
	if generated_state_matches_canonical_subset(result, canonical, ignored_keys):
		return true
	if not result is Dictionary:
		return false
	var result_nan: bool = bool(result.get(nan_key, false))
	var canonical_nan: bool = bool(canonical.get(nan_key, false))
	return result_nan and canonical_nan and result.get(identity_key, "") == canonical.get(identity_key, "")

static func generated_subset_ignored_keys(ignored_keys: Array = []) -> Array:
	var runtime_ignored_keys := ["source_owner"]
	runtime_ignored_keys.append_array(ignored_keys)
	return runtime_ignored_keys

static func generated_state_matches_generated_subset_ignoring_source_owner(result: Variant, canonical: Variant, ignored_keys: Array = []) -> bool:
	return generated_state_matches_canonical_subset(result, canonical, generated_subset_ignored_keys(ignored_keys))

static func generated_state_matches_generated_subset_or_nan_ignoring_source_owner(result: Variant, canonical: Variant, nan_key: String, identity_key: String, ignored_keys: Array = []) -> bool:
	return generated_state_matches_canonical_subset_or_nan(result, canonical, nan_key, identity_key, generated_subset_ignored_keys(ignored_keys))
