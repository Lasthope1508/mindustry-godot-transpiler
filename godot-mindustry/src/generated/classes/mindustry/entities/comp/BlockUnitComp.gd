# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/BlockUnitComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "BlockUnitComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Unitc"]
const JAVA_FIELDS := [{"modifiers": [], "name": "team", "type": "Team"}, {"modifiers": ["transient"], "name": "tile", "type": "Building"}, {"modifiers": ["transient"], "name": "ammo", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "tile", "parameters": [{"name": "tile", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "icon", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "ammof", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "killed", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "damage", "parameters": [{"name": "v", "type": "float", "varargs": false}, {"name": "b", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "dead", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isValid", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isAdded", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "team", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_tile_0(_args: Array = []) -> Variant:
	return null

func java_method_add_1(_args: Array = []) -> Variant:
	return null

func java_method_update_2(_args: Array = []) -> Variant:
	return null

func java_method_icon_3(_args: Array = []) -> Variant:
	var tile_block_ui_icon: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_block_unit_icon_state", "method": "public TextureRegion icon(){", "return_expr": "return tile.block.uiIcon;", "tile_block_ui_icon": tile_block_ui_icon}

func java_method_ammof_4(_args: Array = []) -> Variant:
	var ammo: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "PortGame.source_block_unit_ammof_state", "method": "public float ammof(){", "return_expr": "return ammo;", "ammo": ammo}

func java_method_killed_5(_args: Array = []) -> Variant:
	return null

func java_method_damage_6(_args: Array = []) -> Variant:
	return null

func java_method_dead_7(_args: Array = []) -> Variant:
	return null

func java_method_isValid_8(_args: Array = []) -> Variant:
	return null

func java_method_isAdded_9(_args: Array = []) -> Variant:
	return null

func java_method_team_10(_args: Array = []) -> Variant:
	return null
