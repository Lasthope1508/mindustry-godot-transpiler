# Generated from Mindustry upstream.
# Source: mindustry/mod/ModClassLoader.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.mod"
const JAVA_KIND := "class"
const JAVA_NAME := "ModClassLoader"
const JAVA_EXTENDS := "ClassLoader"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "children", "type": "Seq"}, {"modifiers": ["private"], "name": "inChild", "type": "ThreadLocal"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ModClassLoader", "parameters": [{"name": "parent", "type": "ClassLoader", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "addChild", "parameters": [{"name": "child", "type": "ClassLoader", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "findClass", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "Class"}]
const JAVA_ENUM_CONSTANTS := []
