extends RefCounted
class_name SourceUnitBuildingCommandSourceTextState

const SOURCE_UNIT_BUILDING_COMMAND_POSITION_METHOD := "public Vec2 getCommandPosition(){"
const SOURCE_UNIT_BUILDING_COMMAND_POSITION_RETURN_EXPR := "return commandPos;"
const SOURCE_UNIT_BUILDING_ON_COMMAND_METHOD := "public void onCommand(Vec2 target){"
const SOURCE_UNIT_BUILDING_ON_COMMAND_ASSIGNMENT_EXPR := "commandPos = target;"
const SOURCE_UNIT_BUILDING_SOURCE_PATHS := {
	"UnitFactory": "core/src/mindustry/world/blocks/units/UnitFactory.java",
	"UnitAssembler": "core/src/mindustry/world/blocks/units/UnitAssembler.java",
	"Reconstructor": "core/src/mindustry/world/blocks/units/Reconstructor.java",
}
const SOURCE_UNIT_BUILDING_INNER_CLASS_DECLARATIONS := {
	"UnitFactory": "public class UnitFactoryBuild extends UnitBuild{",
	"UnitAssembler": "public class UnitAssemblerBuild extends PayloadBlockBuild<Payload>{",
	"Reconstructor": "public class ReconstructorBuild extends UnitBuild{",
}
const SOURCE_UNIT_BUILDING_COMMAND_POSITION_GENERATED_METHODS := {
	"UnitFactory": "java_inner_class_UnitFactoryBuild_method_getCommandPosition_4",
	"UnitAssembler": "java_inner_class_UnitAssemblerBuild_method_getCommandPosition_24",
	"Reconstructor": "java_inner_class_ReconstructorBuild_method_getCommandPosition_1",
}
const SOURCE_UNIT_BUILDING_ON_COMMAND_GENERATED_METHODS := {
	"UnitFactory": "java_inner_class_UnitFactoryBuild_method_onCommand_5",
	"UnitAssembler": "java_inner_class_UnitAssemblerBuild_method_onCommand_25",
	"Reconstructor": "java_inner_class_ReconstructorBuild_method_onCommand_2",
}
const SOURCE_UNIT_BUILDING_CLASS_NAMES := ["UnitFactory", "UnitAssembler", "Reconstructor"]
const SOURCE_UNIT_BUILDING_VARIANTS := {
	"UnitFactory": {
		"source": "core/src/mindustry/world/blocks/units/UnitFactory.java",
		"inner_class": "public class UnitFactoryBuild extends UnitBuild{",
	},
	"UnitAssembler": {
		"source": "core/src/mindustry/world/blocks/units/UnitAssembler.java",
		"inner_class": "public class UnitAssemblerBuild extends PayloadBlockBuild<Payload>{",
	},
	"Reconstructor": {
		"source": "core/src/mindustry/world/blocks/units/Reconstructor.java",
		"inner_class": "public class ReconstructorBuild extends UnitBuild{",
	},
}
