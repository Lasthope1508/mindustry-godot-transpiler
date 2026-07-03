# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/PosComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "PosComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Position"]
const JAVA_FIELDS := [{"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": [], "name": "set", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "set", "parameters": [{"name": "pos", "type": "Position", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "trns", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "trns", "parameters": [{"name": "pos", "type": "Position", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "tileX", "parameters": [], "return_type": "int"}, {"modifiers": [], "name": "tileY", "parameters": [], "return_type": "int"}, {"modifiers": [], "name": "floorOn", "parameters": [], "return_type": "Floor"}, {"modifiers": [], "name": "blockOn", "parameters": [], "return_type": "Block"}, {"modifiers": [], "name": "buildOn", "parameters": [], "return_type": "Building"}, {"modifiers": [], "name": "tileOn", "parameters": [], "return_type": "Tile"}, {"modifiers": [], "name": "onSolid", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getX", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getY", "parameters": [], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_set_0(_args: Array = []) -> Variant:
	var x_value: float = float(_args[0] if _args.size() > 0 else 0.0)
	var y_value: float = float(_args[1] if _args.size() > 1 else 0.0)
	return {"source_owner": "PortGame.source_pos_set_state", "method": "void set(float x, float y){", "x_assign_expr": "this.x = x;", "y_assign_expr": "this.y = y;", "x": x_value, "y": y_value}

func java_method_set_1(_args: Array = []) -> Variant:
	return null

func java_method_trns_2(_args: Array = []) -> Variant:
	return null

func java_method_trns_3(_args: Array = []) -> Variant:
	return null

func java_method_tileX_4(_args: Array = []) -> Variant:
	return null

func java_method_tileY_5(_args: Array = []) -> Variant:
	return null

func java_method_floorOn_6(_args: Array = []) -> Variant:
	return null

func java_method_blockOn_7(_args: Array = []) -> Variant:
	return null

func java_method_buildOn_8(_args: Array = []) -> Variant:
	return null

func java_method_tileOn_9(_args: Array = []) -> Variant:
	return null

func java_method_onSolid_10(_args: Array = []) -> Variant:
	return null

func java_method_getX_11(_args: Array = []) -> Variant:
	return null

func java_method_getY_12(_args: Array = []) -> Variant:
	return null
