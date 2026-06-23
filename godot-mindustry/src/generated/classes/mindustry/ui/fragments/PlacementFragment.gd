# Generated from Mindustry upstream.
# Source: mindustry/ui/fragments/PlacementFragment.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.fragments"
const JAVA_KIND := "class"
const JAVA_NAME := "PlacementFragment"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final"], "name": "rowWidth", "type": "int"}, {"modifiers": ["public"], "name": "currentCategory", "type": "Category"}, {"modifiers": [], "name": "returnArray", "type": "Seq"}, {"modifiers": [], "name": "returnArray2", "type": "Seq"}, {"modifiers": [], "name": "returnCatArray", "type": "Seq"}, {"modifiers": [], "name": "categoryEmpty", "type": "boolean"}, {"modifiers": [], "name": "selectedBlocks", "type": "ObjectMap"}, {"modifiers": [], "name": "scrollPositions", "type": "ObjectFloatMap"}, {"modifiers": [], "name": "menuHoverBlock", "type": "Block"}, {"modifiers": [], "name": "hover", "type": "Displayable"}, {"modifiers": [], "name": "lastFlowBuild", "type": "Building"}, {"modifiers": [], "name": "nextFlowBuild", "type": "Building"}, {"modifiers": [], "name": "lastDisplayState", "type": "Object"}, {"modifiers": [], "name": "lastTeam", "type": "Team"}, {"modifiers": [], "name": "wasHovered", "type": "boolean"}, {"modifiers": [], "name": "blockTable", "type": "Table"}, {"modifiers": [], "name": "toggler", "type": "Table"}, {"modifiers": [], "name": "topTable", "type": "Table"}, {"modifiers": [], "name": "blockCatTable", "type": "Table"}, {"modifiers": [], "name": "commandTable", "type": "Table"}, {"modifiers": [], "name": "mainStack", "type": "Stack"}, {"modifiers": [], "name": "blockPane", "type": "ScrollPane"}, {"modifiers": [], "name": "rebuildCommand", "type": "Runnable"}, {"modifiers": [], "name": "blockSelectEnd", "type": "boolean"}, {"modifiers": [], "name": "wasCommandMode", "type": "boolean"}, {"modifiers": [], "name": "blockSelectSeq", "type": "int"}, {"modifiers": [], "name": "blockSelectSeqMillis", "type": "long"}, {"modifiers": [], "name": "blockSelect", "type": "KeyBind"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "PlacementFragment", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "hover", "parameters": [], "return_type": "Displayable"}, {"modifiers": ["public"], "name": "rebuild", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "updatePick", "parameters": [{"name": "input", "type": "InputHandler", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "gridUpdate", "parameters": [{"name": "input", "type": "InputHandler", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "parent", "type": "Group", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "getCategories", "parameters": [], "return_type": "Seq"}, {"modifiers": [], "name": "getByCategory", "parameters": [{"name": "cat", "type": "Category", "varargs": false}], "return_type": "Seq"}, {"modifiers": [], "name": "getUnlockedByCategory", "parameters": [{"name": "cat", "type": "Category", "varargs": false}], "return_type": "Seq"}, {"modifiers": [], "name": "getSelectedBlock", "parameters": [{"name": "cat", "type": "Category", "varargs": false}], "return_type": "Block"}, {"modifiers": [], "name": "unlocked", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "hasInfoBox", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "hovered", "parameters": [], "return_type": "Displayable"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_hover_0(_args: Array = []) -> Variant:
	return null

func java_method_rebuild_1(_args: Array = []) -> Variant:
	return null

func java_method_updatePick_2(_args: Array = []) -> Variant:
	return null

func java_method_gridUpdate_3(_args: Array = []) -> Variant:
	return null

func java_method_build_4(_args: Array = []) -> Variant:
	return null

func java_method_getCategories_5(_args: Array = []) -> Variant:
	return null

func java_method_getByCategory_6(_args: Array = []) -> Variant:
	return null

func java_method_getUnlockedByCategory_7(_args: Array = []) -> Variant:
	return null

func java_method_getSelectedBlock_8(_args: Array = []) -> Variant:
	return null

func java_method_unlocked_9(_args: Array = []) -> Variant:
	return null

func java_method_hasInfoBox_10(_args: Array = []) -> Variant:
	return null

func java_method_hovered_11(_args: Array = []) -> Variant:
	return null
