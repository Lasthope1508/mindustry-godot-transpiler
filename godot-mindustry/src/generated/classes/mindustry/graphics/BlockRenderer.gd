# Generated from Mindustry upstream.
# Source: mindustry/graphics/BlockRenderer.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.graphics"
const JAVA_KIND := "class"
const JAVA_NAME := "BlockRenderer"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "crackRegions", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "maxCrackSize", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "chunkSize", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "maxSpritesPerCacheTile", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "drawQuadtreeDebug", "type": "boolean"}, {"modifiers": ["final", "public", "static"], "name": "blockDrawCountDebug", "type": "boolean"}, {"modifiers": ["final", "public", "static"], "name": "shadowColor", "type": "Color"}, {"modifiers": ["final", "public", "static"], "name": "blendShadowColor", "type": "Color"}, {"modifiers": ["final", "private", "static"], "name": "initialRequests", "type": "int"}, {"modifiers": ["final", "public"], "name": "floor", "type": "FloorRenderer"}, {"modifiers": ["public"], "name": "cracks", "type": "TextureRegion"}, {"modifiers": ["private"], "name": "chunksToDraw", "type": "IntSeq"}, {"modifiers": ["private"], "name": "chunksToDrawSet", "type": "IntSet"}, {"modifiers": ["private"], "name": "tileview", "type": "Seq"}, {"modifiers": ["private"], "name": "tileExtraCachedView", "type": "Seq"}, {"modifiers": ["private"], "name": "tileWithConsumerView", "type": "Seq"}, {"modifiers": ["private"], "name": "lightview", "type": "Seq"}, {"modifiers": ["private"], "name": "updateFloors", "type": "Seq"}, {"modifiers": ["private"], "name": "hadMapLimit", "type": "boolean"}, {"modifiers": ["private"], "name": "lastCamX", "type": "int"}, {"modifiers": ["private"], "name": "lastCamY", "type": "int"}, {"modifiers": ["private"], "name": "lastRangeX", "type": "int"}, {"modifiers": ["private"], "name": "lastRangeY", "type": "int"}, {"modifiers": ["private"], "name": "lastTeam", "type": "Team"}, {"modifiers": ["private"], "name": "brokenFade", "type": "float"}, {"modifiers": ["private"], "name": "shadows", "type": "FrameBuffer"}, {"modifiers": ["private"], "name": "dark", "type": "FrameBuffer"}, {"modifiers": ["private"], "name": "outArray2", "type": "Seq"}, {"modifiers": ["private"], "name": "shadowEvents", "type": "Seq"}, {"modifiers": ["private"], "name": "darkEvents", "type": "IntSet"}, {"modifiers": ["private"], "name": "procLinks", "type": "IntSet"}, {"modifiers": ["private"], "name": "procLights", "type": "IntSet"}, {"modifiers": ["private"], "name": "blockTree", "type": "BlockQuadtree"}, {"modifiers": ["private"], "name": "blockCachedTree", "type": "BlockQuadtree"}, {"modifiers": ["private"], "name": "blockLightTree", "type": "BlockLightQuadtree"}, {"modifiers": ["private"], "name": "overlayTree", "type": "OverlayQuadtree"}, {"modifiers": ["private"], "name": "floorTree", "type": "FloorQuadtree"}, {"modifiers": ["private"], "name": "cacheChunks", "type": "CacheChunk"}, {"modifiers": ["private"], "name": "cbatch", "type": "CacheBatch"}, {"modifiers": ["private"], "name": "caches", "type": "Seq"}, {"modifiers": ["private"], "name": "queuedCacheDraws", "type": "Seq"}, {"modifiers": ["private"], "name": "queuedCacheIndices", "type": "IntSeq"}, {"modifiers": ["private"], "name": "dirtyChunks", "type": "IntSet"}, {"modifiers": ["private"], "name": "blockDrawSprites", "type": "ObjectIntMap"}, {"modifiers": ["private"], "name": "blockDrawTotal", "type": "ObjectIntMap"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "BlockRenderer", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "recacheBuilding", "parameters": [{"name": "layer", "type": "BuildingCacheLayer", "varargs": false}, {"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "cacheChunk", "parameters": [{"name": "layer", "type": "int", "varargs": false}, {"name": "cx", "type": "int", "varargs": false}, {"name": "cy", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "reload", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateShadows", "parameters": [{"name": "ignoreBuildings", "type": "boolean", "varargs": false}, {"name": "ignoreTerrain", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateDarkness", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "invalidateTile", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getShadowBuffer", "parameters": [], "return_type": "FrameBuffer"}, {"modifiers": ["public"], "name": "removeFloorIndex", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addFloorIndex", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "removeOverlayIndex", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addOverlayIndex", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "indexBlock", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "indexBlockCached", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "indexOverlay", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "indexFloor", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "recordIndex", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "recacheWall", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "checkChanges", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawDarkness", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawDestroyed", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "processShadows", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "processShadows", "parameters": [{"name": "ignoreBuildings", "type": "boolean", "varargs": false}, {"name": "ignoreTerrain", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawShadows", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "processBlocks", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "drawTree", "parameters": [{"name": "tree", "type": "QuadTree", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawBlocks", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateShadow", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateShadowTile", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_recacheBuilding_0(_args: Array = []) -> Variant:
	return null

func java_method_cacheChunk_1(_args: Array = []) -> Variant:
	return null

func java_method_reload_2(_args: Array = []) -> Variant:
	return null

func java_method_updateShadows_3(_args: Array = []) -> Variant:
	return null

func java_method_updateDarkness_4(_args: Array = []) -> Variant:
	return null

func java_method_invalidateTile_5(_args: Array = []) -> Variant:
	return null

func java_method_getShadowBuffer_6(_args: Array = []) -> Variant:
	return null

func java_method_removeFloorIndex_7(_args: Array = []) -> Variant:
	return null

func java_method_addFloorIndex_8(_args: Array = []) -> Variant:
	return null

func java_method_removeOverlayIndex_9(_args: Array = []) -> Variant:
	return null

func java_method_addOverlayIndex_10(_args: Array = []) -> Variant:
	return null

func java_method_indexBlock_11(_args: Array = []) -> Variant:
	return null

func java_method_indexBlockCached_12(_args: Array = []) -> Variant:
	return null

func java_method_indexOverlay_13(_args: Array = []) -> Variant:
	return null

func java_method_indexFloor_14(_args: Array = []) -> Variant:
	return null

func java_method_recordIndex_15(_args: Array = []) -> Variant:
	return null

func java_method_recacheWall_16(_args: Array = []) -> Variant:
	return null

func java_method_checkChanges_17(_args: Array = []) -> Variant:
	return null

func java_method_drawDarkness_18(_args: Array = []) -> Variant:
	return null

func java_method_drawDestroyed_19(_args: Array = []) -> Variant:
	return null

func java_method_processShadows_20(_args: Array = []) -> Variant:
	return null

func java_method_processShadows_21(_args: Array = []) -> Variant:
	return null

func java_method_drawShadows_22(_args: Array = []) -> Variant:
	return null

func java_method_processBlocks_23(_args: Array = []) -> Variant:
	return null

func java_method_drawTree_24(_args: Array = []) -> Variant:
	return null

func java_method_drawBlocks_25(_args: Array = []) -> Variant:
	return null

func java_method_updateShadow_26(_args: Array = []) -> Variant:
	return null

func java_method_updateShadowTile_27(_args: Array = []) -> Variant:
	return null
