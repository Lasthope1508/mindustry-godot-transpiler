# Generated from Mindustry upstream.
# Source: mindustry/ClientLauncher.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry"
const JAVA_KIND := "class"
const JAVA_NAME := "ClientLauncher"
const JAVA_EXTENDS := "ApplicationCore"
const JAVA_IMPLEMENTS := ["Platform"]
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "loadingFPS", "type": "int"}, {"modifiers": ["private"], "name": "nextFrame", "type": "long"}, {"modifiers": ["private"], "name": "beginTime", "type": "long"}, {"modifiers": ["private"], "name": "lastTargetFps", "type": "long"}, {"modifiers": ["private"], "name": "finished", "type": "boolean"}, {"modifiers": ["private"], "name": "loader", "type": "LoadRenderer"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setup", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "module", "type": "ApplicationListener", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "resize", "parameters": [{"name": "width", "type": "int", "varargs": false}, {"name": "height", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "exit", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "resume", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "pause", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "fileDropped", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
