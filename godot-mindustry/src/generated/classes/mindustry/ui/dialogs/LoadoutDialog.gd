# Generated from Mindustry upstream.
# Source: mindustry/ui/dialogs/LoadoutDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.dialogs"
const JAVA_KIND := "class"
const JAVA_NAME := "LoadoutDialog"
const JAVA_EXTENDS := "BaseDialog"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "hider", "type": "Runnable"}, {"modifiers": ["private"], "name": "resetter", "type": "Runnable"}, {"modifiers": ["private"], "name": "updater", "type": "Runnable"}, {"modifiers": ["private"], "name": "stacks", "type": "Seq"}, {"modifiers": ["private"], "name": "originalStacks", "type": "Seq"}, {"modifiers": ["private"], "name": "validator", "type": "Boolf"}, {"modifiers": ["private"], "name": "items", "type": "Table"}, {"modifiers": ["private"], "name": "capacity", "type": "int"}, {"modifiers": ["private"], "name": "total", "type": "ItemSeq"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "LoadoutDialog", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "maxItems", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "show", "parameters": [{"name": "capacity", "type": "int", "varargs": false}, {"name": "stacks", "type": "Seq", "varargs": false}, {"name": "validator", "type": "Boolf", "varargs": false}, {"name": "reseter", "type": "Runnable", "varargs": false}, {"name": "updater", "type": "Runnable", "varargs": false}, {"name": "hider", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "show", "parameters": [{"name": "capacity", "type": "int", "varargs": false}, {"name": "total", "type": "ItemSeq", "varargs": false}, {"name": "stacks", "type": "Seq", "varargs": false}, {"name": "validator", "type": "Boolf", "varargs": false}, {"name": "reseter", "type": "Runnable", "varargs": false}, {"name": "updater", "type": "Runnable", "varargs": false}, {"name": "hider", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "setup", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "reseed", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "step", "parameters": [{"name": "amount", "type": "int", "varargs": false}], "return_type": "int"}]
const JAVA_ENUM_CONSTANTS := []
