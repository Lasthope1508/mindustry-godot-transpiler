# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/payloads/BuildPayload.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.payloads"
const JAVA_KIND := "class"
const JAVA_NAME := "BuildPayload"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Payload"]
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "build", "type": "Building"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "BuildPayload", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}]}, {"modifiers": ["public"], "name": "BuildPayload", "parameters": [{"name": "build", "type": "Building", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "block", "parameters": [], "return_type": "Block"}, {"modifiers": ["public"], "name": "place", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "place", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "contentEquals", "parameters": [{"name": "other", "type": "Payload", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "content", "parameters": [], "return_type": "UnlockableContent"}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "unitHolder", "type": "Unit", "varargs": false}, {"name": "buildingHolder", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "destroyed", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "requirements", "parameters": [], "return_type": "ItemStack"}, {"modifiers": ["public"], "name": "buildTime", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "x", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "y", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "size", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "remove", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "write", "type": "Writes", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "set", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawShadow", "parameters": [{"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "icon", "parameters": [], "return_type": "TextureRegion"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_block_0(_args: Array = []) -> Variant:
	var build_block: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_build_payload_block_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "method": "public Block block(){", "return_expr": "return build.block;", "build_block": build_block}

func java_method_place_1(_args: Array = []) -> Variant:
	return null

func java_method_place_2(_args: Array = []) -> Variant:
	return null

func java_method_contentEquals_3(_args: Array = []) -> Variant:
	return null

func java_method_content_4(_args: Array = []) -> Variant:
	return null

func java_method_update_5(_args: Array = []) -> Variant:
	return null

func java_method_destroyed_6(_args: Array = []) -> Variant:
	return null

func java_method_requirements_7(_args: Array = []) -> Variant:
	return null

func java_method_buildTime_8(_args: Array = []) -> Variant:
	return null

func java_method_x_9(_args: Array = []) -> Variant:
	return null

func java_method_y_10(_args: Array = []) -> Variant:
	return null

func java_method_size_11(_args: Array = []) -> Variant:
	return null

func java_method_remove_12(_args: Array = []) -> Variant:
	return null

func java_method_write_13(_args: Array = []) -> Variant:
	return null

func java_method_set_14(_args: Array = []) -> Variant:
	return null

func java_method_drawShadow_15(_args: Array = []) -> Variant:
	return null

func java_method_draw_16(_args: Array = []) -> Variant:
	return null

func java_method_icon_17(_args: Array = []) -> Variant:
	return null
