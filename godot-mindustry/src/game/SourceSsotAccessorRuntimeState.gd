extends RefCounted
class_name SourceSsotAccessorRuntimeState

const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

static func lookup_state(module_name: String, key_value: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state(module_name, key_value)

static func document_data(module_name: String) -> Dictionary:
	return source_ssot_catalog.document_data(module_name)

static func document_root_data(module_name: String, root_key: String) -> Dictionary:
	return source_ssot_catalog.document_root_data(module_name, root_key)

static func audit_summary_state() -> Dictionary:
	return source_ssot_catalog.audit_summary_state()

static func ssot_modules_state(module_name: String = "") -> Dictionary:
	return source_ssot_catalog.ssot_modules_state(module_name)

static func canonical_headquarter_registry_state(module_name: String = "") -> Dictionary:
	return source_ssot_catalog.canonical_headquarter_registry_state(module_name)

static func canonical_headquarter_lookup_state(alias_name: String = "") -> Dictionary:
	return source_ssot_catalog.canonical_headquarter_lookup_state(alias_name)

static func manifest_summary_state(module_name: String, int_fields: Array, string_fields: Array, array_key: String, first_key: String) -> Dictionary:
	return source_ssot_catalog.manifest_summary_state(module_name, int_fields, string_fields, array_key, first_key)

static func collection_summary_state(module_name: String, string_fields: Array, counts_key: String, collection_names: Array) -> Dictionary:
	return source_ssot_catalog.collection_summary_state(module_name, string_fields, counts_key, collection_names)

static func array_summary_state(module_name: String, int_fields: Array, string_fields: Array, array_keys: Array, first_keys: Array) -> Dictionary:
	return source_ssot_catalog.array_summary_state(module_name, int_fields, string_fields, array_keys, first_keys)

static func playable_content_document_state() -> Dictionary:
	return source_ssot_catalog.load_document("playable_content")

static func playable_content_block_state(block_id: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("playable_content_blocks", block_id)

static func playable_content_item_state(item_id: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("playable_content_items", item_id)

static func playable_content_skin_override_state(skin_id: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("playable_content_skin_overrides", skin_id)

static func source_symbol_registry_state(symbol: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("registry", symbol)

static func source_root_policy_state(policy_name: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("source_root_policies", policy_name)

static func ssot_symbol_registry_symbol_state(symbol: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("source_symbol_registry_symbols", symbol)

static func ssot_audit_registered_owner_state(owner_index: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("source_audit_registered_owners", owner_index)

static func ssot_audit_function_state(function_index: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("source_audit_functions", function_index)

static func ssot_audit_exempt_owner_state(owner_index: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("source_audit_exempt_owners", owner_index)

static func ssot_audit_legacy_unregistered_owner_state(owner_index: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("source_audit_legacy_unregistered_owners", owner_index)

static func source_slice_ledger_state(slice_id: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("slice_ledger", slice_id)

static func ssot_slice_ledger_state(slice_id: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("source_slice_ledger_slices", slice_id)

static func source_api_contract_state(contract_owner: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("api_contracts", contract_owner)

static func ssot_api_contract_state(contract_owner: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("source_api_contracts_contracts", contract_owner)

static func source_state_schema_state(schema_name: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("state_schema", schema_name)

static func ssot_state_schema_state(schema_name: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("source_state_schema_schemas", schema_name)

static func helper_state_schema_state(schema_name: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("helper_state_schema", schema_name)

static func ssot_module_entry_state(module_name: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("source_ssot_module_entries", module_name)

static func asset_manifest_state() -> Dictionary:
	return source_ssot_catalog.manifest_summary_state("asset_manifest", ["asset_count", "total_bytes"], [], "assets", "first_asset")

static func asset_manifest_asset_state(target_path: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("asset_manifest_assets", target_path)

static func source_manifest_state() -> Dictionary:
	return source_ssot_catalog.manifest_summary_state("source_manifest", ["java_file_count"], ["source_root"], "files", "first_file")

static func source_manifest_file_state(file_path: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("source_manifest_files", file_path)

static func ast_manifest_state() -> Dictionary:
	return source_ssot_catalog.manifest_summary_state("ast_manifest", ["parsed_file_count", "failed_file_count"], ["source_root"], "files", "first_file")

static func ast_manifest_file_state(file_path: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("ast_manifest_files", file_path)

static func ast_manifest_failure_state(file_path: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("ast_manifest_failures", file_path)

static func content_registry_state() -> Dictionary:
	return source_ssot_catalog.collection_summary_state("content_registry", ["upstream_commit"], "counts", ["items", "liquids", "blocks", "units"])

static func content_registry_item_state(item_id: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("content_registry_items", item_id)

static func content_registry_liquid_state(liquid_id: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("content_registry_liquids", liquid_id)

static func content_registry_unit_state(unit_id: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("content_registry_units", unit_id)

static func content_registry_block_state(block_id: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("content_registry_blocks", block_id)

static func content_registry_count_state(count_name: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("content_registry_counts", count_name)

static func content_registry_wave_group_state(group_index: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("content_registry_wave_groups", group_index)

static func emitted_classes_state() -> Dictionary:
	return source_ssot_catalog.manifest_summary_state("emitted_classes", ["emitted_file_count", "skipped_failure_count"], ["source_root", "output_root", "registry"], "files", "first_file")

static func emitted_class_file_state(file_path: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("emitted_class_files", file_path)

static func emitted_class_failure_state(failure_index: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("emitted_class_failures", failure_index)

static func port_report_state() -> Dictionary:
	return source_ssot_catalog.array_summary_state("port_report", ["asset_count", "asset_total_bytes", "failed_file_count", "java_file_count", "parsed_file_count"], [], ["unsupported", "unsupported_features"], ["first_unsupported", "first_unsupported_feature"])

static func port_report_unsupported_state(unsupported_index: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("port_report_unsupported", unsupported_index)

static func port_report_unsupported_feature_state(feature_index: String = "") -> Dictionary:
	return source_ssot_catalog.lookup_state("port_report_unsupported_features", feature_index)
