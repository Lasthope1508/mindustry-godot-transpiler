# Generated from Mindustry upstream.
# Source: tests/src/test/java/power/ConsumeGeneratorTests.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "power"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeGeneratorTests"
const JAVA_EXTENDS := "PowerTestFixture"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "build", "type": "ConsumeGeneratorBuild"}, {"modifiers": ["final", "private"], "name": "fakeItemDuration", "type": "float"}, {"modifiers": ["final", "private"], "name": "maximumLiquidUsage", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "createGenerator", "parameters": [{"name": "inputType", "type": "InputType", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "generatorWorksProperlyWithLiquidInput", "parameters": [], "return_type": "DynamicTest"}, {"modifiers": [], "name": "simulateLiquidConsumption", "parameters": [{"name": "delta", "type": "float", "varargs": false}, {"name": "inputType", "type": "InputType", "varargs": false}, {"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "availableLiquidAmount", "type": "float", "varargs": false}, {"name": "parameterDescription", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "generatorWorksProperlyWithItemInput", "parameters": [], "return_type": "DynamicTest"}, {"modifiers": [], "name": "simulateItemConsumption", "parameters": [{"name": "inputType", "type": "InputType", "varargs": false}, {"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}, {"name": "parameterDescription", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "efficiencyRemainsConstantWithinItemDuration_ItemsOnly", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "testItemDuration", "parameters": [{"name": "inputType", "type": "InputType", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_createGenerator_0(_args: Array = []) -> Variant:
	return null

func java_method_generatorWorksProperlyWithLiquidInput_1(_args: Array = []) -> Variant:
	return null

func java_method_simulateLiquidConsumption_2(_args: Array = []) -> Variant:
	return null

func java_method_generatorWorksProperlyWithItemInput_3(_args: Array = []) -> Variant:
	return null

func java_method_simulateItemConsumption_4(_args: Array = []) -> Variant:
	return null

func java_method_efficiencyRemainsConstantWithinItemDuration_ItemsOnly_5(_args: Array = []) -> Variant:
	return null

func java_method_testItemDuration_6(_args: Array = []) -> Variant:
	return null
