# Generated from Mindustry upstream.
# Source: mindustry/ai/ItemUnitStance.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ai"
const JAVA_KIND := "class"
const JAVA_NAME := "ItemUnitStance"
const JAVA_EXTENDS := "UnitStance"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private", "static"], "name": "itemToStance", "type": "ObjectMap"}, {"modifiers": ["private", "static"], "name": "all", "type": "Seq"}, {"modifiers": ["final", "public"], "name": "item", "type": "Item"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ItemUnitStance", "parameters": [{"name": "item", "type": "Item", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "getByItem", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "ItemUnitStance"}, {"modifiers": ["public", "static"], "name": "all", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "localized", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "getIcon", "parameters": [], "return_type": "TextureRegionDrawable"}]
const JAVA_ENUM_CONSTANTS := []
