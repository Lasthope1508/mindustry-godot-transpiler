extends RefCounted
class_name SourceAbilityState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

static func update_state(unit: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_UPDATE_STATE,
		"source": "core/src/mindustry/entities/abilities/Ability.java",
		"method": "public void update(Unit unit){}",
		"unit": unit,
		"no_op": true,
	}

static func draw_state(unit: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_DRAW_STATE,
		"source": "core/src/mindustry/entities/abilities/Ability.java",
		"method": "public void draw(Unit unit){}",
		"unit": unit,
		"no_op": true,
	}

static func death_state(unit: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_DEATH_STATE,
		"source": "core/src/mindustry/entities/abilities/Ability.java",
		"method": "public void death(Unit unit){}",
		"unit": unit,
		"no_op": true,
	}

static func created_state(unit: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_CREATED_STATE,
		"source": "core/src/mindustry/entities/abilities/Ability.java",
		"method": "public void created(Unit unit){}",
		"unit": unit,
		"no_op": true,
	}

static func init_state(type_value: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_INIT_STATE,
		"source": "core/src/mindustry/entities/abilities/Ability.java",
		"method": "public void init(UnitType type){}",
		"type": type_value,
		"no_op": true,
	}

static func display_bars_state(unit: Variant, bars: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_DISPLAY_BARS_STATE,
		"source": "core/src/mindustry/entities/abilities/Ability.java",
		"method": "public void displayBars(Unit unit, Table bars){}",
		"unit": unit,
		"bars": bars,
		"no_op": true,
	}

static func display_state(table_state: Variant, localized_value: String) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_DISPLAY_STATE,
		"source": "core/src/mindustry/entities/abilities/Ability.java",
		"method": "public void display(Table t){",
		"table": table_state,
		"localized_value": localized_value,
		"style_expr": "Styles.grayPanel",
		"localized_call": "localized()",
		"title_text": "[accent]" + localized_value,
		"add_stats_call": "addStats(a);",
		"table_mutation": true,
	}

static func add_stats_state(table_state: Variant, get_bundle_value: String, bundle_has_description: bool, bundle_description: String) -> Dictionary:
	var add_description_call := "table.add(bundle_description)"
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_ADD_STATS_STATE,
		"source": "core/src/mindustry/entities/abilities/Ability.java",
		"method": "public void addStats(Table t){",
		"table": table_state,
		"get_bundle_value": get_bundle_value,
		"bundle_has_description": bundle_has_description,
		"bundle_description": bundle_description,
		"field_expr": "protected static final float descriptionWidth = 350f;",
		"description_width": 350.0,
		"guard_expr": "if(Core.bundle.has(getBundle() + \".description\")){",
		"guard_passed": bundle_has_description,
		"add_description_call": add_description_call,
	}

static func ability_stat_state(stat_value: String, values: Array, formatted_value: String) -> Dictionary:
	var bundle_key := "ability.stat." + stat_value
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_ABILITY_STAT_STATE,
		"source": "core/src/mindustry/entities/abilities/Ability.java",
		"method": "public String abilityStat(String stat, Object... values){",
		"stat_value": stat_value,
		"values": values.duplicate(),
		"formatted_value": formatted_value,
		"bundle_key_expr": "\"ability.stat.\" + stat",
		"bundle_key": bundle_key,
		"format_call": "Core.bundle.format(\"ability.stat.\" + stat, values)",
		"return_value": formatted_value,
	}

static func copy_state(clone_supported: bool, clone_value: Variant, exception_value: Variant) -> Dictionary:
	var return_value = clone_value if clone_supported else null
	var thrown_exception = null if clone_supported else exception_value
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_COPY_STATE,
		"source": "core/src/mindustry/entities/abilities/Ability.java",
		"method": "public Ability copy(){",
		"clone_supported": clone_supported,
		"clone_value": clone_value,
		"exception_value": exception_value,
		"try_expr": "try{",
		"clone_return_expr": "return (Ability)clone();",
		"catch_expr": "}catch(CloneNotSupportedException e){",
		"runtime_exception_expr": "throw new RuntimeException(\"java sucks\", e);",
		"return_value": return_value,
		"thrown_exception": thrown_exception,
	}

static func localized_state(get_bundle_value: String, bundle_value: String) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_LOCALIZED_STATE,
		"source": "core/src/mindustry/entities/abilities/Ability.java",
		"comment": "/** @return localized ability name; mods should override this. */",
		"method": "public String localized(){",
		"get_bundle_call": "getBundle()",
		"get_bundle_value": get_bundle_value,
		"bundle_get_call": "Core.bundle.get(getBundle())",
		"return_expr": "return Core.bundle.get(getBundle());",
		"bundle_value": bundle_value,
		"return_value": bundle_value,
	}

static func get_bundle_state(class_simple_name: String, is_anonymous_class: bool, superclass_simple_name: String) -> Dictionary:
	var selected_simple_name := superclass_simple_name if is_anonymous_class else class_simple_name
	var stripped_name := class_simple_name if is_anonymous_class else class_simple_name.replace(superclass_simple_name, "")
	var return_value := selected_simple_name if selected_simple_name != "" else stripped_name
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_GET_BUNDLE_STATE,
		"source": "core/src/mindustry/entities/abilities/Ability.java",
		"method": "public String getBundle(){",
		"class_simple_name": class_simple_name,
		"is_anonymous_class": is_anonymous_class,
		"superclass_simple_name": superclass_simple_name,
		"selected_simple_name": selected_simple_name,
		"stripped_name": stripped_name,
		"type_assignment": "var type = getClass();",
		"return_value": return_value,
	}

static func generated_update_bridge_state(unit: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/abilities/Ability.gd", "java_method_update_0", [unit], null)
	var canonical = update_state(unit)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var matches: bool = result.get("no_op", null) == canonical.get("no_op", null) and result.get("unit", null) == canonical.get("unit", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_UPDATE_STATE,
		"generated_owner": "ability.java_method_update_0",
		"result": result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_draw_bridge_state(unit: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/abilities/Ability.gd", "java_method_draw_1", [unit], null)
	var ability_draw_result = result
	var canonical = draw_state(unit)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var matches: bool = ability_draw_result.get("no_op", null) == canonical.get("no_op", null) and ability_draw_result.get("unit", null) == canonical.get("unit", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_DRAW_STATE,
		"generated_owner": "ability.java_method_draw_1",
		"result": ability_draw_result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_death_bridge_state(unit: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/abilities/Ability.gd", "java_method_death_2", [unit], null)
	var ability_death_result = result
	var canonical = death_state(unit)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var matches: bool = ability_death_result.get("no_op", null) == canonical.get("no_op", null) and ability_death_result.get("unit", null) == canonical.get("unit", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_DEATH_STATE,
		"generated_owner": "ability.java_method_death_2",
		"result": ability_death_result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_created_bridge_state(unit: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/abilities/Ability.gd", "java_method_created_3", [unit], null)
	var ability_created_result = result
	var canonical = created_state(unit)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var matches: bool = ability_created_result.get("no_op", null) == canonical.get("no_op", null) and ability_created_result.get("unit", null) == canonical.get("unit", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_CREATED_STATE,
		"generated_owner": "ability.java_method_created_3",
		"result": ability_created_result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_init_bridge_state(type_value: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/abilities/Ability.gd", "java_method_init_4", [type_value], null)
	var ability_init_result = result
	var canonical = init_state(type_value)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var matches: bool = ability_init_result.get("no_op", null) == canonical.get("no_op", null) and ability_init_result.get("type", null) == canonical.get("type", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_INIT_STATE,
		"generated_owner": "ability.java_method_init_4",
		"result": ability_init_result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_display_bars_bridge_state(unit: Variant, bars: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/abilities/Ability.gd", "java_method_displayBars_5", [unit, bars], null)
	var ability_display_bars_result = result
	var canonical = display_bars_state(unit, bars)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var matches: bool = ability_display_bars_result.get("no_op", null) == canonical.get("no_op", null) and ability_display_bars_result.get("unit", null) == canonical.get("unit", null) and ability_display_bars_result.get("bars", null) == canonical.get("bars", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_DISPLAY_BARS_STATE,
		"generated_owner": "ability.java_method_displayBars_5",
		"result": ability_display_bars_result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_display_bridge_state(table_state: Variant, localized_value: String) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/abilities/Ability.gd", "java_method_display_6", [table_state, localized_value], null)
	var canonical = display_state(table_state, localized_value)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_DISPLAY_STATE,
		"generated_owner": "ability.java_method_display_6",
		"result": result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_add_stats_bridge_state(table_state: Variant, get_bundle_value: String, bundle_has_description: bool, bundle_description: String) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/abilities/Ability.gd", "java_method_addStats_7", [table_state, get_bundle_value, bundle_has_description, bundle_description], null)
	var canonical = add_stats_state(table_state, get_bundle_value, bundle_has_description, bundle_description)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_ADD_STATS_STATE,
		"generated_owner": "ability.java_method_addStats_7",
		"result": result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_ability_stat_bridge_state(stat_value: String, values: Array, formatted_value: String) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/abilities/Ability.gd", "java_method_abilityStat_8", [stat_value, values, formatted_value], null)
	var canonical = ability_stat_state(stat_value, values, formatted_value)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_ABILITY_STAT_STATE,
		"generated_owner": "ability.java_method_abilityStat_8",
		"result": result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_copy_bridge_state(clone_supported: bool, clone_value: Variant, exception_value: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/abilities/Ability.gd", "java_method_copy_9", [clone_supported, clone_value, exception_value], null)
	var canonical = copy_state(clone_supported, clone_value, exception_value)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_COPY_STATE,
		"generated_owner": "ability.java_method_copy_9",
		"result": result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_localized_bridge_state(get_bundle_value: String, bundle_value: String) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/abilities/Ability.gd", "java_method_localized_10", [get_bundle_value, bundle_value], null)
	var canonical = localized_state(get_bundle_value, bundle_value)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_LOCALIZED_STATE,
		"generated_owner": "ability.java_method_localized_10",
		"result": result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_get_bundle_bridge_state(class_simple_name: String, is_anonymous_class: bool, superclass_simple_name: String) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/abilities/Ability.gd", "java_method_getBundle_11", [class_simple_name, is_anonymous_class, superclass_simple_name], null)
	var canonical = get_bundle_state(class_simple_name, is_anonymous_class, superclass_simple_name)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_GET_BUNDLE_STATE,
		"generated_owner": "ability.java_method_getBundle_11",
		"result": result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
