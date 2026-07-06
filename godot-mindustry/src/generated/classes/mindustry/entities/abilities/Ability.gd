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
	return null

func java_method_abilityStat_8(_args: Array = []) -> Variant:
	return null

func java_method_copy_9(_args: Array = []) -> Variant:
	return null

func java_method_localized_10(_args: Array = []) -> Variant:
	return null

func java_method_getBundle_11(_args: Array = []) -> Variant:
	return null
