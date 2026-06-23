# Generated from Mindustry upstream.
# Source: mindustry/editor/BannedContentDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.editor"
const JAVA_KIND := "class"
const JAVA_NAME := "BannedContentDialog"
const JAVA_EXTENDS := "BaseDialog"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private"], "name": "type", "type": "ContentType"}, {"modifiers": ["private"], "name": "selectedTable", "type": "Table"}, {"modifiers": ["private"], "name": "deselectedTable", "type": "Table"}, {"modifiers": ["private"], "name": "contentSet", "type": "ObjectSet"}, {"modifiers": ["final", "private"], "name": "pred", "type": "Boolf"}, {"modifiers": ["private"], "name": "contentSearch", "type": "String"}, {"modifiers": ["private"], "name": "selectedCategory", "type": "Category"}, {"modifiers": ["private"], "name": "filteredContent", "type": "Seq"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "BannedContentDialog", "parameters": [{"name": "title", "type": "String", "varargs": false}, {"name": "type", "type": "ContentType", "varargs": false}, {"name": "pred", "type": "Boolf", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "show", "parameters": [{"name": "contentSet", "type": "ObjectSet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "build", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "rebuildTables", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "rebuildTable", "parameters": [{"name": "table", "type": "Table", "varargs": false}, {"name": "isSelected", "type": "boolean", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_show_0(_args: Array = []) -> Variant:
	return null

func java_method_build_1(_args: Array = []) -> Variant:
	return null

func java_method_rebuildTables_2(_args: Array = []) -> Variant:
	return null

func java_method_rebuildTable_3(_args: Array = []) -> Variant:
	return null
