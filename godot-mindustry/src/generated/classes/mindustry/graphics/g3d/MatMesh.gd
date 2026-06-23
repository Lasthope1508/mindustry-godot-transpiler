# Generated from Mindustry upstream.
# Source: mindustry/graphics/g3d/MatMesh.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.graphics.g3d"
const JAVA_KIND := "class"
const JAVA_NAME := "MatMesh"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["GenericMesh"]
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "tmp", "type": "Mat3D"}, {"modifiers": [], "name": "mesh", "type": "GenericMesh"}, {"modifiers": [], "name": "mat", "type": "Mat3D"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "MatMesh", "parameters": [{"name": "mesh", "type": "GenericMesh", "varargs": false}, {"name": "mat", "type": "Mat3D", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "render", "parameters": [{"name": "params", "type": "PlanetParams", "varargs": false}, {"name": "projection", "type": "Mat3D", "varargs": false}, {"name": "transform", "type": "Mat3D", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "dispose", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
