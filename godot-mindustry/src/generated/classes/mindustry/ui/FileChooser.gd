# Generated from Mindustry upstream.
# Source: mindustry/ui/FileChooser.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui"
const JAVA_KIND := "class"
const JAVA_NAME := "FileChooser"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := []
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "export", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "extension", "type": "String", "varargs": false}, {"name": "writer", "type": "FileWriter", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "open", "parameters": [{"name": "extensions", "type": "String", "varargs": true}], "return_type": "FileChooserParams"}, {"modifiers": ["public", "static"], "name": "save", "parameters": [{"name": "extensions", "type": "String", "varargs": true}], "return_type": "FileChooserParams"}, {"modifiers": ["public", "static"], "name": "createFallbackFileChooser", "parameters": [{"name": "params", "type": "FileChooserParams", "varargs": false}], "return_type": "FileChooserDialog"}, {"modifiers": ["public", "static"], "name": "showFallbackFileChooser", "parameters": [{"name": "params", "type": "FileChooserParams", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
