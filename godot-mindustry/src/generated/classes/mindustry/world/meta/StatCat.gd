# Generated from Mindustry upstream.
# Source: mindustry/world/meta/StatCat.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.meta"
const JAVA_KIND := "class"
const JAVA_NAME := "StatCat"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Comparable"]
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "all", "type": "Seq"}, {"modifiers": ["final", "public", "static"], "name": "general", "type": "StatCat"}, {"modifiers": ["final", "public", "static"], "name": "power", "type": "StatCat"}, {"modifiers": ["final", "public", "static"], "name": "liquids", "type": "StatCat"}, {"modifiers": ["final", "public", "static"], "name": "items", "type": "StatCat"}, {"modifiers": ["final", "public", "static"], "name": "crafting", "type": "StatCat"}, {"modifiers": ["final", "public", "static"], "name": "function", "type": "StatCat"}, {"modifiers": ["final", "public", "static"], "name": "optional", "type": "StatCat"}, {"modifiers": ["final", "public"], "name": "name", "type": "String"}, {"modifiers": ["final", "public"], "name": "id", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "StatCat", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "localized", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "compareTo", "parameters": [{"name": "o", "type": "StatCat", "varargs": false}], "return_type": "int"}]
const JAVA_ENUM_CONSTANTS := []
