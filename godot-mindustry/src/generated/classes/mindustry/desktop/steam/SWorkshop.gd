# Generated from Mindustry upstream.
# Source: desktop/src/mindustry/desktop/steam/SWorkshop.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.desktop.steam"
const JAVA_KIND := "class"
const JAVA_NAME := "SWorkshop"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["SteamUGCCallback"]
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "ugc", "type": "SteamUGC"}, {"modifiers": ["private"], "name": "workshopFiles", "type": "ObjectMap"}, {"modifiers": ["private"], "name": "detailHandlers", "type": "ObjectMap"}, {"modifiers": ["private"], "name": "itemHandlers", "type": "Seq"}, {"modifiers": ["private"], "name": "updatedHandlers", "type": "ObjectMap"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "SWorkshop", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getWorkshopFiles", "parameters": [{"name": "type", "type": "Class", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "publish", "parameters": [{"name": "p", "type": "Publishable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "viewListing", "parameters": [{"name": "p", "type": "Publishable", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "viewListingID", "parameters": [{"name": "id", "type": "SteamPublishedFileID", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "update", "parameters": [{"name": "p", "type": "Publishable", "varargs": false}, {"name": "id", "type": "SteamPublishedFileID", "varargs": false}, {"name": "changelog", "type": "String", "varargs": false}, {"name": "updateDescription", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "showPublish", "parameters": [{"name": "published", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "query", "parameters": [{"name": "query", "type": "SteamUGCQuery", "varargs": false}, {"name": "handler", "type": "Cons2", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "updateItem", "parameters": [{"name": "publishedFileID", "type": "SteamPublishedFileID", "varargs": false}, {"name": "tagger", "type": "Cons", "varargs": false}, {"name": "updated", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onUGCQueryCompleted", "parameters": [{"name": "query", "type": "SteamUGCQuery", "varargs": false}, {"name": "numResultsReturned", "type": "int", "varargs": false}, {"name": "totalMatchingResults", "type": "int", "varargs": false}, {"name": "isCachedData", "type": "boolean", "varargs": false}, {"name": "result", "type": "SteamResult", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onSubscribeItem", "parameters": [{"name": "publishedFileID", "type": "SteamPublishedFileID", "varargs": false}, {"name": "result", "type": "SteamResult", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onUnsubscribeItem", "parameters": [{"name": "publishedFileID", "type": "SteamPublishedFileID", "varargs": false}, {"name": "result", "type": "SteamResult", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onCreateItem", "parameters": [{"name": "publishedFileID", "type": "SteamPublishedFileID", "varargs": false}, {"name": "needsToAcceptWLA", "type": "boolean", "varargs": false}, {"name": "result", "type": "SteamResult", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onSubmitItemUpdate", "parameters": [{"name": "publishedFileID", "type": "SteamPublishedFileID", "varargs": false}, {"name": "needsToAcceptWLA", "type": "boolean", "varargs": false}, {"name": "result", "type": "SteamResult", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onDownloadItemResult", "parameters": [{"name": "appID", "type": "int", "varargs": false}, {"name": "publishedFileID", "type": "SteamPublishedFileID", "varargs": false}, {"name": "result", "type": "SteamResult", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onDeleteItem", "parameters": [{"name": "publishedFileID", "type": "SteamPublishedFileID", "varargs": false}, {"name": "result", "type": "SteamResult", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getWorkshopFiles_0(_args: Array = []) -> Variant:
	return null

func java_method_publish_1(_args: Array = []) -> Variant:
	return null

func java_method_viewListing_2(_args: Array = []) -> Variant:
	return null

func java_method_viewListingID_3(_args: Array = []) -> Variant:
	return null

func java_method_update_4(_args: Array = []) -> Variant:
	return null

func java_method_showPublish_5(_args: Array = []) -> Variant:
	return null

func java_method_query_6(_args: Array = []) -> Variant:
	return null

func java_method_updateItem_7(_args: Array = []) -> Variant:
	return null

func java_method_onUGCQueryCompleted_8(_args: Array = []) -> Variant:
	return null

func java_method_onSubscribeItem_9(_args: Array = []) -> Variant:
	return null

func java_method_onUnsubscribeItem_10(_args: Array = []) -> Variant:
	return null

func java_method_onCreateItem_11(_args: Array = []) -> Variant:
	return null

func java_method_onSubmitItemUpdate_12(_args: Array = []) -> Variant:
	return null

func java_method_onDownloadItemResult_13(_args: Array = []) -> Variant:
	return null

func java_method_onDeleteItem_14(_args: Array = []) -> Variant:
	return null
