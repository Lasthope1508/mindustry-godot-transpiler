# Generated from Mindustry upstream.
# Source: mindustry/ui/fragments/MenuFragment.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.fragments"
const JAVA_KIND := "class"
const JAVA_NAME := "MenuFragment"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "container", "type": "Table"}, {"modifiers": ["private"], "name": "submenu", "type": "Table"}, {"modifiers": ["private"], "name": "currentMenu", "type": "Button"}, {"modifiers": ["private"], "name": "renderer", "type": "MenuRenderer"}, {"modifiers": ["private"], "name": "customButtons", "type": "Seq"}, {"modifiers": ["public"], "name": "desktopButtons", "type": "Seq"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "build", "parameters": [{"name": "parent", "type": "Group", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "buildMobile", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "buildDesktop", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "checkPlay", "parameters": [{"name": "run", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "fadeInMenu", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "fadeOutMenu", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "buttons", "parameters": [{"name": "t", "type": "Table", "varargs": false}, {"name": "buttons", "type": "MenuButton", "varargs": true}], "return_type": ""}, {"modifiers": ["public"], "name": "addButton", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "icon", "type": "Drawable", "varargs": false}, {"name": "callback", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addButton", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "callback", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addButton", "parameters": [{"name": "button", "type": "MenuButton", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
