# Generated from Mindustry upstream.
# Source: mindustry/type/Planet.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.type"
const JAVA_KIND := "class"
const JAVA_NAME := "Planet"
const JAVA_EXTENDS := "UnlockableContent"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "intersectResult", "type": "Vec3"}, {"modifiers": ["final", "private", "static"], "name": "mat", "type": "Mat3D"}, {"modifiers": ["final", "private", "static"], "name": "points", "type": "Seq"}, {"modifiers": ["final", "private", "static"], "name": "tmpNormal", "type": "Vec3"}, {"modifiers": ["public"], "name": "mesh", "type": "GenericMesh"}, {"modifiers": ["public"], "name": "cloudMesh", "type": "GenericMesh"}, {"modifiers": ["public"], "name": "gridMesh", "type": "Mesh"}, {"modifiers": ["public"], "name": "position", "type": "Vec3"}, {"modifiers": ["public"], "name": "grid", "type": "PlanetGrid"}, {"modifiers": ["public"], "name": "generator", "type": "PlanetGenerator"}, {"modifiers": ["public"], "name": "sectors", "type": "Seq"}, {"modifiers": ["public"], "name": "orbitSpacing", "type": "float"}, {"modifiers": ["public"], "name": "radius", "type": "float"}, {"modifiers": ["public"], "name": "camRadius", "type": "float"}, {"modifiers": ["public"], "name": "minZoom", "type": "float"}, {"modifiers": ["public"], "name": "maxZoom", "type": "float"}, {"modifiers": ["public"], "name": "drawOrbit", "type": "boolean"}, {"modifiers": ["public"], "name": "atmosphereRadIn", "type": "float"}, {"modifiers": ["public"], "name": "atmosphereRadOut", "type": "float"}, {"modifiers": ["public"], "name": "clipRadius", "type": "float"}, {"modifiers": ["public"], "name": "orbitRadius", "type": "float"}, {"modifiers": ["public"], "name": "totalRadius", "type": "float"}, {"modifiers": ["public"], "name": "orbitTime", "type": "float"}, {"modifiers": ["public"], "name": "rotateTime", "type": "float"}, {"modifiers": ["public"], "name": "orbitOffset", "type": "float"}, {"modifiers": ["public"], "name": "sectorApproxRadius", "type": "float"}, {"modifiers": ["public"], "name": "tidalLock", "type": "boolean"}, {"modifiers": ["public"], "name": "accessible", "type": "boolean"}, {"modifiers": ["public"], "name": "defaultEnv", "type": "int"}, {"modifiers": ["public"], "name": "defaultAttributes", "type": "Attributes"}, {"modifiers": ["public"], "name": "updateLighting", "type": "boolean"}, {"modifiers": ["public"], "name": "lightSrcFrom", "type": "float"}, {"modifiers": ["public"], "name": "lightSrcTo", "type": "float"}, {"modifiers": ["public"], "name": "lightDstFrom", "type": "float"}, {"modifiers": ["public"], "name": "lightDstTo", "type": "float"}, {"modifiers": ["public"], "name": "startSector", "type": "int"}, {"modifiers": ["public"], "name": "sectorSeed", "type": "int"}, {"modifiers": ["public"], "name": "launchCapacityMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "bloom", "type": "boolean"}, {"modifiers": ["public"], "name": "visible", "type": "boolean"}, {"modifiers": ["public"], "name": "landCloudColor", "type": "Color"}, {"modifiers": ["public"], "name": "lightColor", "type": "Color"}, {"modifiers": ["public"], "name": "atmosphereColor", "type": "Color"}, {"modifiers": ["public"], "name": "iconColor", "type": "Color"}, {"modifiers": ["public"], "name": "hasAtmosphere", "type": "boolean"}, {"modifiers": ["public"], "name": "allowLaunchSchematics", "type": "boolean"}, {"modifiers": ["public"], "name": "allowLaunchLoadout", "type": "boolean"}, {"modifiers": ["public"], "name": "allowSectorInvasion", "type": "boolean"}, {"modifiers": ["public"], "name": "allowLegacyLaunchPads", "type": "boolean"}, {"modifiers": ["public"], "name": "clearSectorOnLose", "type": "boolean"}, {"modifiers": ["public"], "name": "enemyBuildSpeedMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "enemyFactoryActivationDelay", "type": "float"}, {"modifiers": ["public"], "name": "enemyInfiniteItems", "type": "boolean"}, {"modifiers": ["public"], "name": "enemyCoreSpawnReplace", "type": "boolean"}, {"modifiers": ["public"], "name": "prebuildBase", "type": "boolean"}, {"modifiers": ["public"], "name": "allowWaves", "type": "boolean"}, {"modifiers": ["public"], "name": "allowLaunchToNumbered", "type": "boolean"}, {"modifiers": ["public"], "name": "allowCampaignRules", "type": "boolean"}, {"modifiers": ["public"], "name": "icon", "type": "String"}, {"modifiers": ["public"], "name": "launchMusic", "type": "Music"}, {"modifiers": ["public"], "name": "ambientMusic", "type": "Seq"}, {"modifiers": ["public"], "name": "darkMusic", "type": "Seq"}, {"modifiers": ["public"], "name": "alwaysPlayMusic", "type": "boolean"}, {"modifiers": ["public"], "name": "defaultCore", "type": "Block"}, {"modifiers": ["public"], "name": "parent", "type": "Planet"}, {"modifiers": ["public"], "name": "solarSystem", "type": "Planet"}, {"modifiers": ["public"], "name": "children", "type": "Seq"}, {"modifiers": ["public"], "name": "techTree", "type": "TechNode"}, {"modifiers": ["public"], "name": "launchCandidates", "type": "Seq"}, {"modifiers": ["public"], "name": "allowSelfSectorLaunch", "type": "boolean"}, {"modifiers": ["public"], "name": "autoAssignPlanet", "type": "boolean"}, {"modifiers": ["public"], "name": "unlockedOnLand", "type": "Seq"}, {"modifiers": ["public"], "name": "meshLoader", "type": "Prov"}, {"modifiers": ["public"], "name": "cloudMeshLoader", "type": "Prov"}, {"modifiers": ["public"], "name": "gridMeshLoader", "type": "Prov"}, {"modifiers": ["public"], "name": "statParent", "type": "Planet"}, {"modifiers": ["public"], "name": "updateGroup", "type": "ObjectSet"}, {"modifiers": ["public"], "name": "campaignRules", "type": "CampaignRules"}, {"modifiers": ["public"], "name": "campaignRuleDefaults", "type": "CampaignRules"}, {"modifiers": ["public"], "name": "ruleSetter", "type": "Cons"}, {"modifiers": ["public"], "name": "sectorCaptureReplacements", "type": "ObjectMap"}, {"modifiers": ["public"], "name": "showRtsAIRule", "type": "boolean"}, {"modifiers": ["public"], "name": "loadPlanetData", "type": "boolean"}, {"modifiers": ["public"], "name": "data", "type": "PlanetData"}, {"modifiers": ["private"], "name": "campaignStats", "type": "CampaignStats"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Planet", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "parent", "type": "Planet", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "Planet", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "parent", "type": "Planet", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "sectorSize", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "removeContent", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "saveRules", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "loadRules", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "stats", "parameters": [], "return_type": "CampaignStats"}, {"modifiers": ["public"], "name": "loadStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "saveStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "clearStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getStartSector", "parameters": [], "return_type": "Sector"}, {"modifiers": ["public"], "name": "applyRules", "parameters": [{"name": "rules", "type": "Rules", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "applyRules", "parameters": [{"name": "rules", "type": "Rules", "varargs": false}, {"name": "customGame", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "applyDefaultRules", "parameters": [{"name": "rules", "type": "CampaignRules", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getLastSector", "parameters": [], "return_type": "Sector"}, {"modifiers": ["public"], "name": "setLastSector", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "preset", "parameters": [{"name": "index", "type": "int", "varargs": false}, {"name": "preset", "type": "SectorPreset", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "hasGrid", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isLandable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "updateTotalRadius", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getLightNormal", "parameters": [], "return_type": "Vec3"}, {"modifiers": ["public"], "name": "getOrbitAngle", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getRotation", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "addParentOffset", "parameters": [{"name": "in", "type": "Vec3", "varargs": false}], "return_type": "Vec3"}, {"modifiers": ["public"], "name": "getWorldPosition", "parameters": [{"name": "in", "type": "Vec3", "varargs": false}], "return_type": "Vec3"}, {"modifiers": ["public"], "name": "updateBaseCoverage", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getTransform", "parameters": [{"name": "mat", "type": "Mat3D", "varargs": false}], "return_type": "Mat3D"}, {"modifiers": ["public"], "name": "reloadMesh", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "reloadMeshAsync", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getData", "parameters": [], "return_type": "PlanetData"}, {"modifiers": ["public"], "name": "getSector", "parameters": [{"name": "tile", "type": "Ptile", "varargs": false}], "return_type": "Sector"}, {"modifiers": ["public"], "name": "getSector", "parameters": [{"name": "ray", "type": "Ray", "varargs": false}], "return_type": "Sector"}, {"modifiers": ["public"], "name": "getSector", "parameters": [{"name": "ray", "type": "Ray", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}], "return_type": "Sector"}, {"modifiers": ["public"], "name": "intersect", "parameters": [{"name": "ray", "type": "Ray", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}], "return_type": "Vec3"}, {"modifiers": ["public"], "name": "isHidden", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getContentType", "parameters": [], "return_type": "ContentType"}, {"modifiers": ["public"], "name": "visible", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "params", "type": "PlanetParams", "varargs": false}, {"name": "projection", "type": "Mat3D", "varargs": false}, {"name": "transform", "type": "Mat3D", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawAtmosphere", "parameters": [{"name": "atmosphere", "type": "Mesh", "varargs": false}, {"name": "cam", "type": "Camera3D", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawClouds", "parameters": [{"name": "params", "type": "PlanetParams", "varargs": false}, {"name": "projection", "type": "Mat3D", "varargs": false}, {"name": "transform", "type": "Mat3D", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawBorders", "parameters": [{"name": "batch", "type": "VertexBatch3D", "varargs": false}, {"name": "sector", "type": "Sector", "varargs": false}, {"name": "base", "type": "Color", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "fill", "parameters": [{"name": "batch", "type": "VertexBatch3D", "varargs": false}, {"name": "sector", "type": "Sector", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "offset", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawSelection", "parameters": [{"name": "batch", "type": "VertexBatch3D", "varargs": false}, {"name": "sector", "type": "Sector", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "stroke", "type": "float", "varargs": false}, {"name": "length", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "renderSectors", "parameters": [{"name": "batch", "type": "VertexBatch3D", "varargs": false}, {"name": "cam", "type": "Camera3D", "varargs": false}, {"name": "params", "type": "PlanetParams", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawArc", "parameters": [{"name": "batch", "type": "VertexBatch3D", "varargs": false}, {"name": "a", "type": "Vec3", "varargs": false}, {"name": "b", "type": "Vec3", "varargs": false}, {"name": "from", "type": "Color", "varargs": false}, {"name": "to", "type": "Color", "varargs": false}, {"name": "length", "type": "float", "varargs": false}, {"name": "timeScale", "type": "float", "varargs": false}, {"name": "pointCount", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawArcLine", "parameters": [{"name": "batch", "type": "VertexBatch3D", "varargs": false}, {"name": "a", "type": "Vec3", "varargs": false}, {"name": "b", "type": "Vec3", "varargs": false}, {"name": "from", "type": "Color", "varargs": false}, {"name": "to", "type": "Color", "varargs": false}, {"name": "length", "type": "float", "varargs": false}, {"name": "timeScale", "type": "float", "varargs": false}, {"name": "pointCount", "type": "int", "varargs": false}, {"name": "stroke", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "lookAt", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}, {"name": "out", "type": "Vec3", "varargs": false}], "return_type": "Vec3"}, {"modifiers": ["public"], "name": "project", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}, {"name": "cam", "type": "Camera3D", "varargs": false}, {"name": "out", "type": "Vec3", "varargs": false}], "return_type": "Vec3"}, {"modifiers": ["public"], "name": "setPlane", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}, {"name": "projector", "type": "PlaneBatch3D", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_removeContent_0(_args: Array = []) -> Variant:
	return null

func java_method_saveRules_1(_args: Array = []) -> Variant:
	return null

func java_method_loadRules_2(_args: Array = []) -> Variant:
	return null

func java_method_stats_3(_args: Array = []) -> Variant:
	return null

func java_method_loadStats_4(_args: Array = []) -> Variant:
	return null

func java_method_saveStats_5(_args: Array = []) -> Variant:
	return null

func java_method_clearStats_6(_args: Array = []) -> Variant:
	return null

func java_method_getStartSector_7(_args: Array = []) -> Variant:
	return null

func java_method_applyRules_8(_args: Array = []) -> Variant:
	return null

func java_method_applyRules_9(_args: Array = []) -> Variant:
	return null

func java_method_applyDefaultRules_10(_args: Array = []) -> Variant:
	return null

func java_method_getLastSector_11(_args: Array = []) -> Variant:
	return null

func java_method_setLastSector_12(_args: Array = []) -> Variant:
	return null

func java_method_preset_13(_args: Array = []) -> Variant:
	return null

func java_method_hasGrid_14(_args: Array = []) -> Variant:
	return null

func java_method_isLandable_15(_args: Array = []) -> Variant:
	return null

func java_method_updateTotalRadius_16(_args: Array = []) -> Variant:
	return null

func java_method_getLightNormal_17(_args: Array = []) -> Variant:
	return null

func java_method_getOrbitAngle_18(_args: Array = []) -> Variant:
	return null

func java_method_getRotation_19(_args: Array = []) -> Variant:
	return null

func java_method_addParentOffset_20(_args: Array = []) -> Variant:
	return null

func java_method_getWorldPosition_21(_args: Array = []) -> Variant:
	return null

func java_method_updateBaseCoverage_22(_args: Array = []) -> Variant:
	return null

func java_method_getTransform_23(_args: Array = []) -> Variant:
	return null

func java_method_reloadMesh_24(_args: Array = []) -> Variant:
	return null

func java_method_reloadMeshAsync_25(_args: Array = []) -> Variant:
	return null

func java_method_load_26(_args: Array = []) -> Variant:
	return null

func java_method_init_27(_args: Array = []) -> Variant:
	return null

func java_method_getData_28(_args: Array = []) -> Variant:
	return null

func java_method_getSector_29(_args: Array = []) -> Variant:
	return null

func java_method_getSector_30(_args: Array = []) -> Variant:
	return null

func java_method_getSector_31(_args: Array = []) -> Variant:
	return null

func java_method_intersect_32(_args: Array = []) -> Variant:
	return null

func java_method_isHidden_33(_args: Array = []) -> Variant:
	return null

func java_method_getContentType_34(_args: Array = []) -> Variant:
	return null

func java_method_visible_35(_args: Array = []) -> Variant:
	return null

func java_method_draw_36(_args: Array = []) -> Variant:
	return null

func java_method_drawAtmosphere_37(_args: Array = []) -> Variant:
	return null

func java_method_drawClouds_38(_args: Array = []) -> Variant:
	return null

func java_method_drawBorders_39(_args: Array = []) -> Variant:
	return null

func java_method_fill_40(_args: Array = []) -> Variant:
	return null

func java_method_drawSelection_41(_args: Array = []) -> Variant:
	return null

func java_method_renderSectors_42(_args: Array = []) -> Variant:
	return null

func java_method_drawArc_43(_args: Array = []) -> Variant:
	return null

func java_method_drawArcLine_44(_args: Array = []) -> Variant:
	return null

func java_method_lookAt_45(_args: Array = []) -> Variant:
	return null

func java_method_project_46(_args: Array = []) -> Variant:
	return null

func java_method_setPlane_47(_args: Array = []) -> Variant:
	return null
