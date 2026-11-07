# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/units/UnitAssembler.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.units"
const JAVA_KIND := "class"
const JAVA_NAME := "UnitAssembler"
const JAVA_EXTENDS := "PayloadBlock"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "sideRegion1", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "sideRegion2", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "areaSize", "type": "int"}, {"modifiers": ["public"], "name": "droneType", "type": "UnitType"}, {"modifiers": ["public"], "name": "dronesCreated", "type": "int"}, {"modifiers": ["public"], "name": "droneConstructTime", "type": "float"}, {"modifiers": ["public"], "name": "capacities", "type": "int"}, {"modifiers": ["public"], "name": "plans", "type": "Seq"}, {"modifiers": ["public"], "name": "createSound", "type": "Sound"}, {"modifiers": ["public"], "name": "createSoundVolume", "type": "float"}, {"modifiers": ["protected"], "name": "consPayload", "type": "ConsumePayloadDynamic"}, {"modifiers": ["protected"], "name": "consItem", "type": "ConsumeItemDynamic"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "UnitAssembler", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getRect", "parameters": [{"name": "rect", "type": "Rect", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "Rect"}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "canPlaceOn", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterPatch", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "initCapacities", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "checkContentArrayCapacity", "parameters": [{"name": "items", "type": "int", "varargs": false}, {"name": "liquids", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "assemblerUnitSpawned", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "assemblerDroneSpawned", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "id", "type": "int", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getRect_0(_args: Array = []) -> Variant:
	return null

func java_method_drawPlace_1(_args: Array = []) -> Variant:
	return null

func java_method_canPlaceOn_2(_args: Array = []) -> Variant:
	return null

func java_method_setBars_3(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanRegion_4(_args: Array = []) -> Variant:
	return null

func java_method_icons_5(_args: Array = []) -> Variant:
	return null

func java_method_init_6(_args: Array = []) -> Variant:
	return null

func java_method_afterPatch_7(_args: Array = []) -> Variant:
	return null

func java_method_initCapacities_8(_args: Array = []) -> Variant:
	return null

func java_method_checkContentArrayCapacity_9(_args: Array = []) -> Variant:
	return null

func java_method_setStats_10(_args: Array = []) -> Variant:
	return null

func java_method_assemblerUnitSpawned_11(_args: Array = []) -> Variant:
	return null

func java_method_assemblerDroneSpawned_12(_args: Array = []) -> Variant:
	return null

func java_inner_class_UnitAssemblerBuild_method_getCommandPosition_24(_args: Array = []) -> Variant:
	var command_position: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "port_game.source_unit_building_get_command_position_state", "source": "core/src/mindustry/world/blocks/units/UnitAssembler.java", "inner_class": "public class UnitAssemblerBuild extends PayloadBlockBuild<Payload>{", "method": "public Vec2 getCommandPosition(){", "return_expr": "return commandPos;", "command_position": command_position}

func java_inner_class_UnitAssemblerBuild_method_onCommand_25(_args: Array = []) -> Variant:
	var target: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "port_game.source_unit_building_on_command_state", "source": "core/src/mindustry/world/blocks/units/UnitAssembler.java", "inner_class": "public class UnitAssemblerBuild extends PayloadBlockBuild<Payload>{", "method": "public void onCommand(Vec2 target){", "assignment_expr": "commandPos = target;", "target": target, "command_position": target}
