# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/units/Reconstructor.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.units"
const JAVA_KIND := "class"
const JAVA_NAME := "Reconstructor"
const JAVA_EXTENDS := "UnitBlock"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "constructTime", "type": "float"}, {"modifiers": ["public"], "name": "upgrades", "type": "Seq"}, {"modifiers": ["public"], "name": "capacities", "type": "int"}, {"modifiers": ["public"], "name": "createSound", "type": "Sound"}, {"modifiers": ["public"], "name": "createSoundVolume", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Reconstructor", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterPatch", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "initCapacities", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "checkContentArrayCapacity", "parameters": [{"name": "items", "type": "int", "varargs": false}, {"name": "liquids", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addUpgrade", "parameters": [{"name": "from", "type": "UnitType", "varargs": false}, {"name": "to", "type": "UnitType", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_drawPlanRegion_0(_args: Array = []) -> Variant:
	return null

func java_method_icons_1(_args: Array = []) -> Variant:
	return null

func java_method_setBars_2(_args: Array = []) -> Variant:
	return null

func java_method_setStats_3(_args: Array = []) -> Variant:
	return null

func java_method_init_4(_args: Array = []) -> Variant:
	return null

func java_method_afterPatch_5(_args: Array = []) -> Variant:
	return null

func java_method_initCapacities_6(_args: Array = []) -> Variant:
	return null

func java_method_checkContentArrayCapacity_7(_args: Array = []) -> Variant:
	return null

func java_method_addUpgrade_8(_args: Array = []) -> Variant:
	return null

func java_inner_class_ReconstructorBuild_method_getCommandPosition_1(_args: Array = []) -> Variant:
	var command_position: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "port_game.source_unit_building_get_command_position_state", "source": "core/src/mindustry/world/blocks/units/Reconstructor.java", "inner_class": "public class ReconstructorBuild extends UnitBuild{", "method": "public Vec2 getCommandPosition(){", "return_expr": "return commandPos;", "command_position": command_position}

func java_inner_class_ReconstructorBuild_method_onCommand_2(_args: Array = []) -> Variant:
	var target: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "port_game.source_unit_building_on_command_state", "source": "core/src/mindustry/world/blocks/units/Reconstructor.java", "inner_class": "public class ReconstructorBuild extends UnitBuild{", "method": "public void onCommand(Vec2 target){", "assignment_expr": "commandPos = target;", "target": target, "command_position": target}
