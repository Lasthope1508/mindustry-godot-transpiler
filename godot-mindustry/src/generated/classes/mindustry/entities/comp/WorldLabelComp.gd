# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/WorldLabelComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "WorldLabelComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Posc", "Drawc", "Syncc"]
const JAVA_FIELDS := [{"modifiers": [], "name": "id", "type": "int"}, {"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": ["final", "public", "static"], "name": "flagBackground", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "flagOutline", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "flagAlignLeft", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "flagAlignRight", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "flagAutoscale", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "flagOnlyParentVisible", "type": "byte"}, {"modifiers": ["public"], "name": "text", "type": "String"}, {"modifiers": ["public"], "name": "fontSize", "type": "float"}, {"modifiers": ["public"], "name": "z", "type": "float"}, {"modifiers": ["public"], "name": "flags", "type": "byte"}, {"modifiers": ["public"], "name": "parent", "type": "Posc"}, {"modifiers": ["public", "transient"], "name": "duration", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "clipSize", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "drawAt", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "layer", "type": "float", "varargs": false}, {"name": "flags", "type": "int", "varargs": false}, {"name": "fontSize", "type": "float", "varargs": false}, {"name": "align", "type": "int", "varargs": false}, {"name": "lineAlign", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "hide", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_clipSize_0(_args: Array = []) -> Variant:
	return null

func java_method_update_1(_args: Array = []) -> Variant:
	return null

func java_method_draw_2(_args: Array = []) -> Variant:
	return null

func java_method_drawAt_3(_args: Array = []) -> Variant:
	return null

func java_method_hide_4(_args: Array = []) -> Variant:
	return null
