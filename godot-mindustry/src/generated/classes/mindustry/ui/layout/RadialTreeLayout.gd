# Generated from Mindustry upstream.
# Source: mindustry/ui/layout/RadialTreeLayout.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.layout"
const JAVA_KIND := "class"
const JAVA_NAME := "RadialTreeLayout"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["TreeLayout"]
const JAVA_FIELDS := [{"modifiers": ["private", "static"], "name": "visited", "type": "ObjectSet"}, {"modifiers": ["private", "static"], "name": "queue", "type": "Queue"}, {"modifiers": ["public"], "name": "startRadius", "type": "float"}, {"modifiers": ["public"], "name": "delta", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "layout", "parameters": [{"name": "root", "type": "TreeNode", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "radialize", "parameters": [{"name": "root", "type": "TreeNode", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "from", "type": "float", "varargs": false}, {"name": "to", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "bfs", "parameters": [{"name": "node", "type": "TreeNode", "varargs": false}, {"name": "assign", "type": "boolean", "varargs": false}], "return_type": "int"}]
const JAVA_ENUM_CONSTANTS := []
