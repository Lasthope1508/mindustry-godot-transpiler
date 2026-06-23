# Generated from Mindustry upstream.
# Source: mindustry/content/TechTree.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.content"
const JAVA_KIND := "class"
const JAVA_NAME := "TechTree"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private", "static"], "name": "context", "type": "TechNode"}, {"modifiers": ["public", "static"], "name": "all", "type": "Seq"}, {"modifiers": ["public", "static"], "name": "roots", "type": "Seq"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "nodeRoot", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "content", "type": "UnlockableContent", "varargs": false}, {"name": "children", "type": "Runnable", "varargs": false}], "return_type": "TechNode"}, {"modifiers": ["public", "static"], "name": "nodeRoot", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "content", "type": "UnlockableContent", "varargs": false}, {"name": "requireUnlock", "type": "boolean", "varargs": false}, {"name": "children", "type": "Runnable", "varargs": false}], "return_type": "TechNode"}, {"modifiers": ["public", "static"], "name": "node", "parameters": [{"name": "content", "type": "UnlockableContent", "varargs": false}, {"name": "children", "type": "Runnable", "varargs": false}], "return_type": "TechNode"}, {"modifiers": ["public", "static"], "name": "node", "parameters": [{"name": "content", "type": "UnlockableContent", "varargs": false}, {"name": "requirements", "type": "ItemStack", "varargs": false}, {"name": "children", "type": "Runnable", "varargs": false}], "return_type": "TechNode"}, {"modifiers": ["public", "static"], "name": "node", "parameters": [{"name": "content", "type": "UnlockableContent", "varargs": false}, {"name": "requirements", "type": "ItemStack", "varargs": false}, {"name": "objectives", "type": "Seq", "varargs": false}, {"name": "children", "type": "Runnable", "varargs": false}], "return_type": "TechNode"}, {"modifiers": ["public", "static"], "name": "node", "parameters": [{"name": "content", "type": "UnlockableContent", "varargs": false}, {"name": "objectives", "type": "Seq", "varargs": false}, {"name": "children", "type": "Runnable", "varargs": false}], "return_type": "TechNode"}, {"modifiers": ["public", "static"], "name": "node", "parameters": [{"name": "block", "type": "UnlockableContent", "varargs": false}], "return_type": "TechNode"}, {"modifiers": ["public", "static"], "name": "nodeProduce", "parameters": [{"name": "content", "type": "UnlockableContent", "varargs": false}, {"name": "objectives", "type": "Seq", "varargs": false}, {"name": "children", "type": "Runnable", "varargs": false}], "return_type": "TechNode"}, {"modifiers": ["public", "static"], "name": "nodeProduce", "parameters": [{"name": "content", "type": "UnlockableContent", "varargs": false}, {"name": "children", "type": "Runnable", "varargs": false}], "return_type": "TechNode"}, {"modifiers": ["public", "static"], "name": "context", "parameters": [], "return_type": "TechNode"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_nodeRoot_0(_args: Array = []) -> Variant:
	return null

func java_method_nodeRoot_1(_args: Array = []) -> Variant:
	return null

func java_method_node_2(_args: Array = []) -> Variant:
	return null

func java_method_node_3(_args: Array = []) -> Variant:
	return null

func java_method_node_4(_args: Array = []) -> Variant:
	return null

func java_method_node_5(_args: Array = []) -> Variant:
	return null

func java_method_node_6(_args: Array = []) -> Variant:
	return null

func java_method_nodeProduce_7(_args: Array = []) -> Variant:
	return null

func java_method_nodeProduce_8(_args: Array = []) -> Variant:
	return null

func java_method_context_9(_args: Array = []) -> Variant:
	return null
