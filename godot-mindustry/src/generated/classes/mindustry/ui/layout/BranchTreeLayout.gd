# Generated from Mindustry upstream.
# Source: mindustry/ui/layout/BranchTreeLayout.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.layout"
const JAVA_KIND := "class"
const JAVA_NAME := "BranchTreeLayout"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["TreeLayout"]
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "rootLocation", "type": "TreeLocation"}, {"modifiers": ["public"], "name": "alignment", "type": "TreeAlignment"}, {"modifiers": ["public"], "name": "gapBetweenLevels", "type": "float"}, {"modifiers": ["public"], "name": "gapBetweenNodes", "type": "float"}, {"modifiers": ["final", "private"], "name": "sizeOfLevel", "type": "FloatSeq"}, {"modifiers": ["private"], "name": "boundsLeft", "type": "float"}, {"modifiers": ["private"], "name": "boundsRight", "type": "float"}, {"modifiers": ["private"], "name": "boundsTop", "type": "float"}, {"modifiers": ["private"], "name": "boundsBottom", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "layout", "parameters": [{"name": "root", "type": "TreeNode", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "getWidthOrHeightOfNode", "parameters": [{"name": "treeNode", "type": "TreeNode", "varargs": false}, {"name": "returnWidth", "type": "boolean", "varargs": false}], "return_type": "float"}, {"modifiers": ["private"], "name": "getNodeThickness", "parameters": [{"name": "treeNode", "type": "TreeNode", "varargs": false}], "return_type": "float"}, {"modifiers": ["private"], "name": "getNodeSize", "parameters": [{"name": "treeNode", "type": "TreeNode", "varargs": false}], "return_type": "float"}, {"modifiers": ["private"], "name": "isLevelChangeInYAxis", "parameters": [], "return_type": "boolean"}, {"modifiers": ["private"], "name": "getLevelChangeSign", "parameters": [], "return_type": "int"}, {"modifiers": ["private"], "name": "updateBounds", "parameters": [{"name": "node", "type": "TreeNode", "varargs": false}, {"name": "centerX", "type": "float", "varargs": false}, {"name": "centerY", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getBounds", "parameters": [], "return_type": "Rect"}, {"modifiers": ["private"], "name": "calcSizeOfLevels", "parameters": [{"name": "node", "type": "TreeNode", "varargs": false}, {"name": "level", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getLevelCount", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "getGapBetweenNodes", "parameters": [{"name": "a", "type": "TreeNode", "varargs": false}, {"name": "b", "type": "TreeNode", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "getSizeOfLevel", "parameters": [{"name": "level", "type": "int", "varargs": false}], "return_type": "float"}, {"modifiers": ["private"], "name": "getAncestor", "parameters": [{"name": "node", "type": "TreeNode", "varargs": false}], "return_type": "TreeNode"}, {"modifiers": ["private"], "name": "getDistance", "parameters": [{"name": "v", "type": "TreeNode", "varargs": false}, {"name": "w", "type": "TreeNode", "varargs": false}], "return_type": "float"}, {"modifiers": ["private"], "name": "nextLeft", "parameters": [{"name": "v", "type": "TreeNode", "varargs": false}], "return_type": "TreeNode"}, {"modifiers": ["private"], "name": "nextRight", "parameters": [{"name": "v", "type": "TreeNode", "varargs": false}], "return_type": "TreeNode"}, {"modifiers": ["private"], "name": "getNumber", "parameters": [{"name": "node", "type": "TreeNode", "varargs": false}, {"name": "parentNode", "type": "TreeNode", "varargs": false}], "return_type": "int"}, {"modifiers": ["private"], "name": "ancestor", "parameters": [{"name": "vIMinus", "type": "TreeNode", "varargs": false}, {"name": "parentOfV", "type": "TreeNode", "varargs": false}, {"name": "defaultAncestor", "type": "TreeNode", "varargs": false}], "return_type": "TreeNode"}, {"modifiers": ["private"], "name": "moveSubtree", "parameters": [{"name": "wMinus", "type": "TreeNode", "varargs": false}, {"name": "wPlus", "type": "TreeNode", "varargs": false}, {"name": "parent", "type": "TreeNode", "varargs": false}, {"name": "shift", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "apportion", "parameters": [{"name": "v", "type": "TreeNode", "varargs": false}, {"name": "defaultAncestor", "type": "TreeNode", "varargs": false}, {"name": "leftSibling", "type": "TreeNode", "varargs": false}, {"name": "parentOfV", "type": "TreeNode", "varargs": false}], "return_type": "TreeNode"}, {"modifiers": ["private"], "name": "executeShifts", "parameters": [{"name": "v", "type": "TreeNode", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "firstWalk", "parameters": [{"name": "v", "type": "TreeNode", "varargs": false}, {"name": "leftSibling", "type": "TreeNode", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "secondWalk", "parameters": [{"name": "v", "type": "TreeNode", "varargs": false}, {"name": "m", "type": "float", "varargs": false}, {"name": "level", "type": "int", "varargs": false}, {"name": "levelStart", "type": "float", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_layout_0(_args: Array = []) -> Variant:
	return null

func java_method_getWidthOrHeightOfNode_1(_args: Array = []) -> Variant:
	return null

func java_method_getNodeThickness_2(_args: Array = []) -> Variant:
	return null

func java_method_getNodeSize_3(_args: Array = []) -> Variant:
	return null

func java_method_isLevelChangeInYAxis_4(_args: Array = []) -> Variant:
	return null

func java_method_getLevelChangeSign_5(_args: Array = []) -> Variant:
	return null

func java_method_updateBounds_6(_args: Array = []) -> Variant:
	return null

func java_method_getBounds_7(_args: Array = []) -> Variant:
	return null

func java_method_calcSizeOfLevels_8(_args: Array = []) -> Variant:
	return null

func java_method_getLevelCount_9(_args: Array = []) -> Variant:
	return null

func java_method_getGapBetweenNodes_10(_args: Array = []) -> Variant:
	return null

func java_method_getSizeOfLevel_11(_args: Array = []) -> Variant:
	return null

func java_method_getAncestor_12(_args: Array = []) -> Variant:
	return null

func java_method_getDistance_13(_args: Array = []) -> Variant:
	return null

func java_method_nextLeft_14(_args: Array = []) -> Variant:
	return null

func java_method_nextRight_15(_args: Array = []) -> Variant:
	return null

func java_method_getNumber_16(_args: Array = []) -> Variant:
	return null

func java_method_ancestor_17(_args: Array = []) -> Variant:
	return null

func java_method_moveSubtree_18(_args: Array = []) -> Variant:
	return null

func java_method_apportion_19(_args: Array = []) -> Variant:
	return null

func java_method_executeShifts_20(_args: Array = []) -> Variant:
	return null

func java_method_firstWalk_21(_args: Array = []) -> Variant:
	return null

func java_method_secondWalk_22(_args: Array = []) -> Variant:
	return null
