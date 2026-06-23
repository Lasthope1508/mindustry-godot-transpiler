# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/ItemsComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "ItemsComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Posc"]
const JAVA_FIELDS := [{"modifiers": [], "name": "stack", "type": "ItemStack"}, {"modifiers": ["transient"], "name": "itemTime", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["abstract"], "name": "itemCapacity", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "item", "parameters": [], "return_type": "Item"}, {"modifiers": [], "name": "clearItem", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "acceptsItem", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "hasItem", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "addItem", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "addItem", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "maxAccepted", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "int"}]
const JAVA_ENUM_CONSTANTS := []
