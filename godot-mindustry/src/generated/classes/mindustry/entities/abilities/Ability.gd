# Generated from Mindustry upstream.
# Source: mindustry/entities/abilities/Ability.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.abilities"
const JAVA_KIND := "class"
const JAVA_NAME := "Ability"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Cloneable"]
const JAVA_FIELDS := [{"modifiers": ["final", "protected", "static"], "name": "descriptionWidth", "type": "float"}, {"modifiers": ["public"], "name": "display", "type": "boolean"}, {"modifiers": ["public"], "name": "data", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "update", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "death", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "created", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [{"name": "type", "type": "UnitType", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "displayBars", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "bars", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "t", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addStats", "parameters": [{"name": "t", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "abilityStat", "parameters": [{"name": "stat", "type": "String", "varargs": false}, {"name": "values", "type": "Object", "varargs": true}], "return_type": "String"}, {"modifiers": ["public"], "name": "copy", "parameters": [], "return_type": "Ability"}, {"modifiers": ["public"], "name": "localized", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "getBundle", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_update_0(_args: Array = []) -> Variant:
	var unit: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_ability_update_state", "source": "core/src/mindustry/entities/abilities/Ability.java", "method": "public void update(Unit unit){}", "unit": unit, "no_op": true}

func java_method_draw_1(_args: Array = []) -> Variant:
	var unit: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_ability_draw_state", "source": "core/src/mindustry/entities/abilities/Ability.java", "method": "public void draw(Unit unit){}", "unit": unit, "no_op": true}

func java_method_death_2(_args: Array = []) -> Variant:
	var unit: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_ability_death_state", "source": "core/src/mindustry/entities/abilities/Ability.java", "method": "public void death(Unit unit){}", "unit": unit, "no_op": true}

func java_method_created_3(_args: Array = []) -> Variant:
	var unit: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_ability_created_state", "source": "core/src/mindustry/entities/abilities/Ability.java", "method": "public void created(Unit unit){}", "unit": unit, "no_op": true}

func java_method_init_4(_args: Array = []) -> Variant:
	var type_value: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_ability_init_state", "source": "core/src/mindustry/entities/abilities/Ability.java", "method": "public void init(UnitType type){}", "type": type_value, "no_op": true}

func java_method_displayBars_5(_args: Array = []) -> Variant:
	var unit: Variant = _args[0] if _args.size() > 0 else null
	var bars: Variant = _args[1] if _args.size() > 1 else null
	return {"source_owner": "PortGame.source_ability_display_bars_state", "source": "core/src/mindustry/entities/abilities/Ability.java", "method": "public void displayBars(Unit unit, Table bars){}", "unit": unit, "bars": bars, "no_op": true}

func java_method_display_6(_args: Array = []) -> Variant:
	var table_state: Variant = _args[0] if _args.size() > 0 else null
	var localized_value: String = str(_args[1] if _args.size() > 1 else "")
	return {"source_owner": "PortGame.source_ability_display_state", "source": "core/src/mindustry/entities/abilities/Ability.java", "method": "public void display(Table t){", "table": table_state, "style_expr": "Styles.grayPanel", "table_call": "t.table(Styles.grayPanel, a -> {", "localized_call": "localized()", "title_expr": "\"[accent]\" + localized()", "localized_value": localized_value, "title_text": "[accent]" + localized_value, "add_call": "a.add(\"[accent]\" + localized()).padBottom(4).center().top().expandX();", "row_call": "a.row();", "defaults_call": "a.left().top().defaults().left();", "add_stats_call": "addStats(a);", "outer_chain": "}).pad(5).margin(10).growX().top().uniformX();", "table_mutation": true}

func java_method_addStats_7(_args: Array = []) -> Variant:
	var table_state: Variant = _args[0] if _args.size() > 0 else null
	var get_bundle_value: String = str(_args[1] if _args.size() > 1 else "")
	var bundle_has_description: bool = bool(_args[2] if _args.size() > 2 else false)
	var bundle_description: String = str(_args[3] if _args.size() > 3 else "")
	var description_key: String = get_bundle_value + ".description"
	var add_description_call: Variant = null
	var row_call: Variant = null
	if bundle_has_description:
		add_description_call = {"call": "t.add(Core.bundle.get(getBundle() + \".description\")).wrap().width(descriptionWidth);", "description": bundle_description, "width": 350.0}
		row_call = "t.row();"
	return {"source_owner": "PortGame.source_ability_add_stats_state", "source": "core/src/mindustry/entities/abilities/Ability.java", "method": "public void addStats(Table t){", "table": table_state, "field_expr": "protected static final float descriptionWidth = 350f;", "description_width": 350.0, "get_bundle_call": "getBundle()", "get_bundle_value": get_bundle_value, "description_key_expr": "getBundle() + \".description\"", "description_key": description_key, "guard_expr": "if(Core.bundle.has(getBundle() + \".description\")){", "guard_passed": bundle_has_description, "bundle_description": bundle_description, "add_description_call": add_description_call, "row_call": row_call}

func java_method_abilityStat_8(_args: Array = []) -> Variant:
	var stat_value: String = str(_args[0] if _args.size() > 0 else "")
	var values: Array = []
	if _args.size() > 1 and _args[1] is Array:
		values = _args[1]
	var formatted_value: String = str(_args[2] if _args.size() > 2 else "")
	var bundle_key: String = "ability.stat." + stat_value
	return {"source_owner": "PortGame.source_ability_ability_stat_state", "source": "core/src/mindustry/entities/abilities/Ability.java", "method": "public String abilityStat(String stat, Object... values){", "stat": stat_value, "values": values, "bundle_key_expr": "\"ability.stat.\" + stat", "bundle_key": bundle_key, "format_call": "Core.bundle.format(\"ability.stat.\" + stat, values)", "formatted_value": formatted_value, "return_expr": "return Core.bundle.format(\"ability.stat.\" + stat, values);", "return_value": formatted_value}

func java_method_copy_9(_args: Array = []) -> Variant:
	var clone_supported: bool = bool(_args[0] if _args.size() > 0 else true)
	var clone_value: Variant = _args[1] if _args.size() > 1 else null
	var exception_value: Variant = _args[2] if _args.size() > 2 else null
	var return_value: Variant = clone_value if clone_supported else null
	var thrown_exception: Variant = null
	if not clone_supported:
		thrown_exception = {"type": "RuntimeException", "message": "java sucks", "cause": exception_value}
	return {"source_owner": "PortGame.source_ability_copy_state", "source": "core/src/mindustry/entities/abilities/Ability.java", "method": "public Ability copy(){", "try_expr": "try{", "clone_return_expr": "return (Ability)clone();", "clone_supported": clone_supported, "clone_value": clone_value, "catch_expr": "}catch(CloneNotSupportedException e){", "comment_expr": "//I am disgusted", "runtime_exception_expr": "throw new RuntimeException(\"java sucks\", e);", "exception_value": exception_value, "return_value": return_value, "thrown_exception": thrown_exception}

func java_method_localized_10(_args: Array = []) -> Variant:
	var get_bundle_value: String = str(_args[0] if _args.size() > 0 else "")
	var bundle_value: String = str(_args[1] if _args.size() > 1 else "")
	return {"source_owner": "PortGame.source_ability_localized_state", "source": "core/src/mindustry/entities/abilities/Ability.java", "comment": "/** @return localized ability name; mods should override this. */", "method": "public String localized(){", "get_bundle_call": "getBundle()", "get_bundle_value": get_bundle_value, "bundle_get_call": "Core.bundle.get(getBundle())", "return_expr": "return Core.bundle.get(getBundle());", "return_value": bundle_value}

func java_method_getBundle_11(_args: Array = []) -> Variant:
	return null
