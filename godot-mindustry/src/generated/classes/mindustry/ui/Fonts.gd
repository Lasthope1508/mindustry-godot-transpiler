# Generated from Mindustry upstream.
# Source: mindustry/ui/Fonts.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui"
const JAVA_KIND := "class"
const JAVA_NAME := "Fonts"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "mainFont", "type": "String"}, {"modifiers": ["final", "private", "static"], "name": "unscaled", "type": "ObjectSet"}, {"modifiers": ["private", "static"], "name": "unicodeIcons", "type": "ObjectIntMap"}, {"modifiers": ["private", "static"], "name": "unicodeToName", "type": "IntMap"}, {"modifiers": ["private", "static"], "name": "stringIcons", "type": "ObjectMap"}, {"modifiers": ["private", "static"], "name": "largeIcons", "type": "ObjectMap"}, {"modifiers": ["public", "static"], "name": "def", "type": "Font"}, {"modifiers": ["public", "static"], "name": "outline", "type": "Font"}, {"modifiers": ["public", "static"], "name": "icon", "type": "Font"}, {"modifiers": ["public", "static"], "name": "iconLarge", "type": "Font"}, {"modifiers": ["public", "static"], "name": "tech", "type": "Font"}, {"modifiers": ["public", "static"], "name": "logic", "type": "Font"}, {"modifiers": ["public", "static"], "name": "monospace", "type": "Font"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "getUnicode", "parameters": [{"name": "content", "type": "String", "varargs": false}], "return_type": "int"}, {"modifiers": ["public", "static"], "name": "getUnicodeStr", "parameters": [{"name": "content", "type": "String", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "hasUnicodeStr", "parameters": [{"name": "content", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "loadSystemCursors", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "cursorScale", "parameters": [], "return_type": "int"}, {"modifiers": ["public", "static"], "name": "loadFonts", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "loadExtraFonts", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "unicodeToName", "parameters": [{"name": "unicode", "type": "int", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "getLargeIcon", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "TextureRegion"}, {"modifiers": ["public", "static"], "name": "registerIcon", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "regionName", "type": "String", "varargs": false}, {"name": "ch", "type": "int", "varargs": false}, {"name": "region", "type": "TextureRegion", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "loadContentIcons", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "loadContentIconsHeadless", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "loadDefaultFont", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "mergeFontAtlas", "parameters": [{"name": "atlas", "type": "TextureAtlas", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "getGlyph", "parameters": [{"name": "font", "type": "Font", "varargs": false}, {"name": "glyph", "type": "char", "varargs": false}], "return_type": "TextureRegionDrawable"}, {"modifiers": ["static"], "name": "fontParameter", "parameters": [], "return_type": "FreeTypeFontParameter"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getUnicode_0(_args: Array = []) -> Variant:
	return null

func java_method_getUnicodeStr_1(_args: Array = []) -> Variant:
	return null

func java_method_hasUnicodeStr_2(_args: Array = []) -> Variant:
	return null

func java_method_loadSystemCursors_3(_args: Array = []) -> Variant:
	return null

func java_method_cursorScale_4(_args: Array = []) -> Variant:
	return null

func java_method_loadFonts_5(_args: Array = []) -> Variant:
	return null

func java_method_loadExtraFonts_6(_args: Array = []) -> Variant:
	return null

func java_method_unicodeToName_7(_args: Array = []) -> Variant:
	return null

func java_method_getLargeIcon_8(_args: Array = []) -> Variant:
	return null

func java_method_registerIcon_9(_args: Array = []) -> Variant:
	return null

func java_method_loadContentIcons_10(_args: Array = []) -> Variant:
	return null

func java_method_loadContentIconsHeadless_11(_args: Array = []) -> Variant:
	return null

func java_method_loadDefaultFont_12(_args: Array = []) -> Variant:
	return null

func java_method_mergeFontAtlas_13(_args: Array = []) -> Variant:
	return null

func java_method_getGlyph_14(_args: Array = []) -> Variant:
	return null

func java_method_fontParameter_15(_args: Array = []) -> Variant:
	return null
