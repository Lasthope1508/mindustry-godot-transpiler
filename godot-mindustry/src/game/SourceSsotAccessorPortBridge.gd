extends "res://src/game/SourceTurretRuntimePortBridge.gd"

const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func playable_content_block_state(block_id: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.playable_content_block_state(block_id)

func playable_content_item_state(item_id: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.playable_content_item_state(item_id)

func playable_content_skin_override_state(skin_id: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.playable_content_skin_override_state(skin_id)

func source_symbol_registry_state(symbol: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.source_symbol_registry_state(symbol)

func source_root_policy_state(policy_name: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.source_root_policy_state(policy_name)

func ssot_symbol_registry_symbol_state(symbol: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.ssot_symbol_registry_symbol_state(symbol)

func source_symbol_audit_state() -> Dictionary:
	return source_ssot_accessor_runtime_state.audit_summary_state()

func ssot_audit_registered_owner_state(owner_index: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.ssot_audit_registered_owner_state(owner_index)

func ssot_audit_function_state(function_index: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.ssot_audit_function_state(function_index)

func ssot_audit_exempt_owner_state(owner_index: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.ssot_audit_exempt_owner_state(owner_index)

func ssot_audit_legacy_unregistered_owner_state(owner_index: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.ssot_audit_legacy_unregistered_owner_state(owner_index)

func source_slice_ledger_state(slice_id: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.source_slice_ledger_state(slice_id)

func ssot_slice_ledger_state(slice_id: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.ssot_slice_ledger_state(slice_id)

func source_api_contract_state(contract_owner: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.source_api_contract_state(contract_owner)

func ssot_api_contract_state(contract_owner: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.ssot_api_contract_state(contract_owner)

func source_state_schema_state(schema_name: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.source_state_schema_state(schema_name)

func ssot_state_schema_state(schema_name: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.ssot_state_schema_state(schema_name)

func helper_state_schema_state(schema_name: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.helper_state_schema_state(schema_name)

func ssot_modules_state(module_name: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.ssot_modules_state(module_name)

func ssot_headquarter_registry_state(module_name: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.canonical_headquarter_registry_state(module_name)

func ssot_headquarter_lookup_state(alias_name: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.canonical_headquarter_lookup_state(alias_name)

func ssot_module_entry_state(module_name: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.ssot_module_entry_state(module_name)

func asset_manifest_state() -> Dictionary:
	return source_ssot_accessor_runtime_state.asset_manifest_state()

func asset_manifest_asset_state(target_path: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.asset_manifest_asset_state(target_path)

func source_manifest_state() -> Dictionary:
	return source_ssot_accessor_runtime_state.source_manifest_state()

func source_manifest_file_state(file_path: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.source_manifest_file_state(file_path)

func ast_manifest_state() -> Dictionary:
	return source_ssot_accessor_runtime_state.ast_manifest_state()

func ast_manifest_file_state(file_path: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.ast_manifest_file_state(file_path)

func ast_manifest_failure_state(file_path: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.ast_manifest_failure_state(file_path)

func content_registry_state() -> Dictionary:
	return source_ssot_accessor_runtime_state.content_registry_state()

func content_registry_item_state(item_id: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.content_registry_item_state(item_id)

func content_registry_liquid_state(liquid_id: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.content_registry_liquid_state(liquid_id)

func content_registry_unit_state(unit_id: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.content_registry_unit_state(unit_id)

func content_registry_block_state(block_id: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.content_registry_block_state(block_id)

func content_registry_count_state(count_name: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.content_registry_count_state(count_name)

func content_registry_wave_group_state(group_index: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.content_registry_wave_group_state(group_index)

func emitted_classes_state() -> Dictionary:
	return source_ssot_accessor_runtime_state.emitted_classes_state()

func emitted_class_file_state(file_path: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.emitted_class_file_state(file_path)

func emitted_class_failure_state(failure_index: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.emitted_class_failure_state(failure_index)

func port_report_state() -> Dictionary:
	return source_ssot_accessor_runtime_state.port_report_state()

func port_report_unsupported_state(unsupported_index: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.port_report_unsupported_state(unsupported_index)

func port_report_unsupported_feature_state(feature_index: String = "") -> Dictionary:
	return source_ssot_accessor_runtime_state.port_report_unsupported_feature_state(feature_index)
