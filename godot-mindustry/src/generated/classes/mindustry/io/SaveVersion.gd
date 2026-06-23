# Generated from Mindustry upstream.
# Source: mindustry/io/SaveVersion.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.io"
const JAVA_KIND := "class"
const JAVA_NAME := "SaveVersion"
const JAVA_EXTENDS := "SaveFileReader"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["protected", "static"], "name": "customChunks", "type": "OrderedMap"}, {"modifiers": ["final", "public"], "name": "version", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "SaveVersion", "parameters": [{"name": "version", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "addCustomChunk", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "chunk", "type": "CustomChunk", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getMeta", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}], "return_type": "SaveMeta"}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "stream", "type": "DataInputStream", "varargs": false}, {"name": "counter", "type": "CounterInputStream", "varargs": false}, {"name": "context", "type": "WorldContext", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "stream", "type": "DataOutputStream", "varargs": false}, {"name": "options", "type": "SaveOptions", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "writeCustomChunks", "parameters": [{"name": "stream", "type": "DataOutput", "varargs": false}, {"name": "net", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "readCustomChunks", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "writeMeta", "parameters": [{"name": "stream", "type": "DataOutput", "varargs": false}, {"name": "tags", "type": "StringMap", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "readMeta", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}, {"name": "context", "type": "WorldContext", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "writeMap", "parameters": [{"name": "stream", "type": "DataOutput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "readMap", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}, {"name": "context", "type": "WorldContext", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "writeTeamBlocks", "parameters": [{"name": "stream", "type": "DataOutput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "writeWorldEntities", "parameters": [{"name": "stream", "type": "DataOutput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "writeEntityMapping", "parameters": [{"name": "stream", "type": "DataOutput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "writeEntities", "parameters": [{"name": "stream", "type": "DataOutput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "writeMarkers", "parameters": [{"name": "stream", "type": "DataOutput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "readMarkers", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "readTeamBlocks", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "readWorldEntities", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}, {"name": "mapping", "type": "Prov", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "readEntityMapping", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}], "return_type": "Prov"}, {"modifiers": ["public"], "name": "readEntities", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "readDataPatches", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "writeDataPatches", "parameters": [{"name": "stream", "type": "DataOutput", "varargs": false}, {"name": "forceEmbed", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "readContentHeader", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "writeContentHeader", "parameters": [{"name": "stream", "type": "DataOutput", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_addCustomChunk_0(_args: Array = []) -> Variant:
	return null

func java_method_getMeta_1(_args: Array = []) -> Variant:
	return null

func java_method_read_2(_args: Array = []) -> Variant:
	return null

func java_method_write_3(_args: Array = []) -> Variant:
	return null

func java_method_writeCustomChunks_4(_args: Array = []) -> Variant:
	return null

func java_method_readCustomChunks_5(_args: Array = []) -> Variant:
	return null

func java_method_writeMeta_6(_args: Array = []) -> Variant:
	return null

func java_method_readMeta_7(_args: Array = []) -> Variant:
	return null

func java_method_writeMap_8(_args: Array = []) -> Variant:
	return null

func java_method_readMap_9(_args: Array = []) -> Variant:
	return null

func java_method_writeTeamBlocks_10(_args: Array = []) -> Variant:
	return null

func java_method_writeWorldEntities_11(_args: Array = []) -> Variant:
	return null

func java_method_writeEntityMapping_12(_args: Array = []) -> Variant:
	return null

func java_method_writeEntities_13(_args: Array = []) -> Variant:
	return null

func java_method_writeMarkers_14(_args: Array = []) -> Variant:
	return null

func java_method_readMarkers_15(_args: Array = []) -> Variant:
	return null

func java_method_readTeamBlocks_16(_args: Array = []) -> Variant:
	return null

func java_method_readWorldEntities_17(_args: Array = []) -> Variant:
	return null

func java_method_readEntityMapping_18(_args: Array = []) -> Variant:
	return null

func java_method_readEntities_19(_args: Array = []) -> Variant:
	return null

func java_method_readDataPatches_20(_args: Array = []) -> Variant:
	return null

func java_method_writeDataPatches_21(_args: Array = []) -> Variant:
	return null

func java_method_readContentHeader_22(_args: Array = []) -> Variant:
	return null

func java_method_writeContentHeader_23(_args: Array = []) -> Variant:
	return null
