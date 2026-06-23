# Generated from Mindustry upstream.
# Source: mindustry/ui/dialogs/ResearchDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.dialogs"
const JAVA_KIND := "class"
const JAVA_NAME := "ResearchDialog"
const JAVA_EXTENDS := "BaseDialog"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public", "static"], "name": "debugShowRequirements", "type": "boolean"}, {"modifiers": ["final", "public"], "name": "nodeSize", "type": "float"}, {"modifiers": ["public"], "name": "nodes", "type": "ObjectSet"}, {"modifiers": ["public"], "name": "root", "type": "TechTreeNode"}, {"modifiers": ["public"], "name": "lastNode", "type": "TechNode"}, {"modifiers": ["public"], "name": "bounds", "type": "Rect"}, {"modifiers": ["public"], "name": "itemDisplay", "type": "ItemsDisplay"}, {"modifiers": ["public"], "name": "view", "type": "View"}, {"modifiers": ["public"], "name": "items", "type": "ItemSeq"}, {"modifiers": ["final", "private"], "name": "rootPlanets", "type": "Seq"}, {"modifiers": ["private"], "name": "showTechSelect", "type": "boolean"}, {"modifiers": ["private"], "name": "needsRebuild", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ResearchDialog", "parameters": []}]
const JAVA_METHODS := [{"modifiers": [], "name": "checkMargin", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "rebuildItems", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getPrefRoot", "parameters": [], "return_type": "TechNode"}, {"modifiers": ["public"], "name": "switchTree", "parameters": [{"name": "node", "type": "TechNode", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "rebuildTree", "parameters": [{"name": "node", "type": "TechNode", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "treeLayout", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "shift", "parameters": [{"name": "children", "type": "LayoutNode", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "copyInfo", "parameters": [{"name": "node", "type": "LayoutNode", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "checkNodes", "parameters": [{"name": "node", "type": "TechTreeNode", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "selectable", "parameters": [{"name": "node", "type": "TechNode", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "locked", "parameters": [{"name": "node", "type": "TechNode", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_checkMargin_0(_args: Array = []) -> Variant:
	return null

func java_method_rebuildItems_1(_args: Array = []) -> Variant:
	return null

func java_method_getPrefRoot_2(_args: Array = []) -> Variant:
	return null

func java_method_switchTree_3(_args: Array = []) -> Variant:
	return null

func java_method_rebuildTree_4(_args: Array = []) -> Variant:
	return null

func java_method_treeLayout_5(_args: Array = []) -> Variant:
	return null

func java_method_shift_6(_args: Array = []) -> Variant:
	return null

func java_method_copyInfo_7(_args: Array = []) -> Variant:
	return null

func java_method_checkNodes_8(_args: Array = []) -> Variant:
	return null

func java_method_selectable_9(_args: Array = []) -> Variant:
	return null

func java_method_locked_10(_args: Array = []) -> Variant:
	return null
