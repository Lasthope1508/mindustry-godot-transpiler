# Generated from Mindustry upstream.
# Source: mindustry/ctype/Content.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ctype"
const JAVA_KIND := "class"
const JAVA_NAME := "Content"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Comparable"]
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "id", "type": "short"}, {"modifiers": ["public"], "name": "minfo", "type": "ModContentInfo"}, {"modifiers": ["public"], "name": "removed", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Content", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["abstract", "public"], "name": "getContentType", "parameters": [], "return_type": "ContentType"}, {"modifiers": ["public"], "name": "removeContent", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "postInit", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterPatch", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "loadIcon", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "hasErrored", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isVanilla", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isModded", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "compareTo", "parameters": [{"name": "c", "type": "Content", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []
