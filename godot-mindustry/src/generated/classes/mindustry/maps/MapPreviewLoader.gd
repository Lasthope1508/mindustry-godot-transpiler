# Generated from Mindustry upstream.
# Source: mindustry/maps/MapPreviewLoader.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.maps"
const JAVA_KIND := "class"
const JAVA_NAME := "MapPreviewLoader"
const JAVA_EXTENDS := "TextureLoader"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private", "static"], "name": "check", "type": "Runnable"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "MapPreviewLoader", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "loadAsync", "parameters": [{"name": "manager", "type": "AssetManager", "varargs": false}, {"name": "fileName", "type": "String", "varargs": false}, {"name": "file", "type": "Fi", "varargs": false}, {"name": "parameter", "type": "TextureParameter", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "loadSync", "parameters": [{"name": "manager", "type": "AssetManager", "varargs": false}, {"name": "fileName", "type": "String", "varargs": false}, {"name": "file", "type": "Fi", "varargs": false}, {"name": "parameter", "type": "TextureParameter", "varargs": false}], "return_type": "Texture"}, {"modifiers": ["public"], "name": "getDependencies", "parameters": [{"name": "fileName", "type": "String", "varargs": false}, {"name": "file", "type": "Fi", "varargs": false}, {"name": "parameter", "type": "TextureParameter", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public", "static"], "name": "setupLoaders", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "checkPreviews", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
