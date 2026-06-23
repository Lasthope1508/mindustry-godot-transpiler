# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/VelComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "VelComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Posc"]
const JAVA_FIELDS := [{"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "vel", "type": "Vec2"}, {"modifiers": ["transient"], "name": "drag", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "solidity", "parameters": [], "return_type": "SolidPred"}, {"modifiers": [], "name": "ignoreSolids", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "canPass", "parameters": [{"name": "tileX", "type": "int", "varargs": false}, {"name": "tileY", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "canPassOn", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "moving", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "move", "parameters": [{"name": "v", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "move", "parameters": [{"name": "cx", "type": "float", "varargs": false}, {"name": "cy", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "velAddNet", "parameters": [{"name": "v", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "velAddNet", "parameters": [{"name": "vx", "type": "float", "varargs": false}, {"name": "vy", "type": "float", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
