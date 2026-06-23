# Generated from Mindustry upstream.
# Source: mindustry/editor/MapGenerateDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.editor"
const JAVA_KIND := "class"
const JAVA_NAME := "MapGenerateDialog"
const JAVA_EXTENDS := "BaseDialog"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final"], "name": "applied", "type": "boolean"}, {"modifiers": [], "name": "pixmap", "type": "Pixmap"}, {"modifiers": [], "name": "texture", "type": "Texture"}, {"modifiers": [], "name": "input", "type": "GenerateInput"}, {"modifiers": [], "name": "filters", "type": "Seq"}, {"modifiers": [], "name": "scaling", "type": "int"}, {"modifiers": [], "name": "filterTable", "type": "Table"}, {"modifiers": [], "name": "result", "type": "Future"}, {"modifiers": [], "name": "generating", "type": "boolean"}, {"modifiers": [], "name": "buffer1", "type": "long"}, {"modifiers": [], "name": "buffer2", "type": "long"}, {"modifiers": [], "name": "applier", "type": "Cons"}, {"modifiers": [], "name": "ctile", "type": "CachedTile"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "MapGenerateDialog", "parameters": [{"name": "applied", "type": "boolean", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "show", "parameters": [{"name": "filters", "type": "Seq", "varargs": false}, {"name": "applier", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "show", "parameters": [{"name": "applier", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "applyToEditor", "parameters": [{"name": "filters", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "setup", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "create", "parameters": [], "return_type": "long"}, {"modifiers": [], "name": "rebuildFilters", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "showAdd", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "pack", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "long"}, {"modifiers": [], "name": "unpack", "parameters": [{"name": "tile", "type": "long", "varargs": false}], "return_type": "Tile"}, {"modifiers": [], "name": "apply", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "update", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
