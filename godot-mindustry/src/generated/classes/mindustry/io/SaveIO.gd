# Generated from Mindustry upstream.
# Source: mindustry/io/SaveIO.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.io"
const JAVA_KIND := "class"
const JAVA_NAME := "SaveIO"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "header", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "versions", "type": "IntMap"}, {"modifiers": ["final", "public", "static"], "name": "versionArray", "type": "Seq"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "getSaveWriter", "parameters": [], "return_type": "SaveVersion"}, {"modifiers": ["public", "static"], "name": "getSaveWriter", "parameters": [{"name": "version", "type": "int", "varargs": false}], "return_type": "SaveVersion"}, {"modifiers": ["public", "static"], "name": "save", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "save", "parameters": [{"name": "file", "type": "Fi", "varargs": false}, {"name": "options", "type": "SaveOptions", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "getStream", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": "DataInputStream"}, {"modifiers": ["public", "static"], "name": "getBackupStream", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": "DataInputStream"}, {"modifiers": ["public", "static"], "name": "isSaveValid", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private", "static"], "name": "isSaveFileValid", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "isSaveValid", "parameters": [{"name": "stream", "type": "DataInputStream", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "getMeta", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": "SaveMeta"}, {"modifiers": ["public", "static"], "name": "getMeta", "parameters": [{"name": "stream", "type": "DataInputStream", "varargs": false}], "return_type": "SaveMeta"}, {"modifiers": ["public", "static"], "name": "fileFor", "parameters": [{"name": "slot", "type": "int", "varargs": false}], "return_type": "Fi"}, {"modifiers": ["public", "static"], "name": "backupFileFor", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": "Fi"}, {"modifiers": ["public", "static"], "name": "write", "parameters": [{"name": "file", "type": "Fi", "varargs": false}, {"name": "options", "type": "SaveOptions", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "write", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "write", "parameters": [{"name": "os", "type": "OutputStream", "varargs": false}, {"name": "options", "type": "SaveOptions", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "load", "parameters": [{"name": "saveName", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "load", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "load", "parameters": [{"name": "file", "type": "Fi", "varargs": false}, {"name": "context", "type": "WorldContext", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "load", "parameters": [{"name": "is", "type": "InputStream", "varargs": false}, {"name": "context", "type": "WorldContext", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "getVersion", "parameters": [], "return_type": "SaveVersion"}, {"modifiers": ["public", "static"], "name": "readHeader", "parameters": [{"name": "input", "type": "DataInput", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getSaveWriter_0(_args: Array = []) -> Variant:
	return null

func java_method_getSaveWriter_1(_args: Array = []) -> Variant:
	return null

func java_method_save_2(_args: Array = []) -> Variant:
	return null

func java_method_save_3(_args: Array = []) -> Variant:
	return null

func java_method_getStream_4(_args: Array = []) -> Variant:
	return null

func java_method_getBackupStream_5(_args: Array = []) -> Variant:
	return null

func java_method_isSaveValid_6(_args: Array = []) -> Variant:
	return null

func java_method_isSaveFileValid_7(_args: Array = []) -> Variant:
	return null

func java_method_isSaveValid_8(_args: Array = []) -> Variant:
	return null

func java_method_getMeta_9(_args: Array = []) -> Variant:
	return null

func java_method_getMeta_10(_args: Array = []) -> Variant:
	return null

func java_method_fileFor_11(_args: Array = []) -> Variant:
	return null

func java_method_backupFileFor_12(_args: Array = []) -> Variant:
	return null

func java_method_write_13(_args: Array = []) -> Variant:
	return null

func java_method_write_14(_args: Array = []) -> Variant:
	return null

func java_method_write_15(_args: Array = []) -> Variant:
	return null

func java_method_load_16(_args: Array = []) -> Variant:
	return null

func java_method_load_17(_args: Array = []) -> Variant:
	return null

func java_method_load_18(_args: Array = []) -> Variant:
	return null

func java_method_load_19(_args: Array = []) -> Variant:
	return null

func java_method_getVersion_20(_args: Array = []) -> Variant:
	return null

func java_method_readHeader_21(_args: Array = []) -> Variant:
	return null
