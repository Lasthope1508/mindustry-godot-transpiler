# Generated from Mindustry upstream.
# Source: mindustry/graphics/g3d/PlanetRenderer.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.graphics.g3d"
const JAVA_KIND := "class"
const JAVA_NAME := "PlanetRenderer"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Disposable"]
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "outlineRad", "type": "float"}, {"modifiers": ["final", "public", "static"], "name": "camLength", "type": "float"}, {"modifiers": ["final", "public", "static"], "name": "outlineColor", "type": "Color"}, {"modifiers": ["final", "public", "static"], "name": "hoverColor", "type": "Color"}, {"modifiers": ["final", "public", "static"], "name": "borderColor", "type": "Color"}, {"modifiers": ["final", "public", "static"], "name": "shadowColor", "type": "Color"}, {"modifiers": ["final", "public"], "name": "cam", "type": "Camera3D"}, {"modifiers": ["final", "public"], "name": "batch", "type": "VertexBatch3D"}, {"modifiers": ["final", "public"], "name": "projector", "type": "PlaneBatch3D"}, {"modifiers": ["final", "public"], "name": "mat", "type": "Mat3D"}, {"modifiers": ["final", "public"], "name": "bloom", "type": "Bloom"}, {"modifiers": ["final", "public"], "name": "atmosphere", "type": "Mesh"}, {"modifiers": ["final", "public"], "name": "skybox", "type": "CubemapMesh"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "PlanetRenderer", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "render", "parameters": [{"name": "params", "type": "PlanetParams", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "renderPlanet", "parameters": [{"name": "planet", "type": "Planet", "varargs": false}, {"name": "params", "type": "PlanetParams", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "renderTransparent", "parameters": [{"name": "planet", "type": "Planet", "varargs": false}, {"name": "params", "type": "PlanetParams", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "renderOrbit", "parameters": [{"name": "planet", "type": "Planet", "varargs": false}, {"name": "params", "type": "PlanetParams", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "renderSectors", "parameters": [{"name": "planet", "type": "Planet", "varargs": false}, {"name": "params", "type": "PlanetParams", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawArcLine", "parameters": [{"name": "planet", "type": "Planet", "varargs": false}, {"name": "a", "type": "Vec3", "varargs": false}, {"name": "b", "type": "Vec3", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawArc", "parameters": [{"name": "planet", "type": "Planet", "varargs": false}, {"name": "a", "type": "Vec3", "varargs": false}, {"name": "b", "type": "Vec3", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawArc", "parameters": [{"name": "planet", "type": "Planet", "varargs": false}, {"name": "a", "type": "Vec3", "varargs": false}, {"name": "b", "type": "Vec3", "varargs": false}, {"name": "from", "type": "Color", "varargs": false}, {"name": "to", "type": "Color", "varargs": false}, {"name": "length", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawArc", "parameters": [{"name": "planet", "type": "Planet", "varargs": false}, {"name": "a", "type": "Vec3", "varargs": false}, {"name": "b", "type": "Vec3", "varargs": false}, {"name": "from", "type": "Color", "varargs": false}, {"name": "to", "type": "Color", "varargs": false}, {"name": "length", "type": "float", "varargs": false}, {"name": "timeScale", "type": "float", "varargs": false}, {"name": "pointCount", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawArcLine", "parameters": [{"name": "planet", "type": "Planet", "varargs": false}, {"name": "a", "type": "Vec3", "varargs": false}, {"name": "b", "type": "Vec3", "varargs": false}, {"name": "from", "type": "Color", "varargs": false}, {"name": "to", "type": "Color", "varargs": false}, {"name": "length", "type": "float", "varargs": false}, {"name": "timeScale", "type": "float", "varargs": false}, {"name": "pointCount", "type": "int", "varargs": false}, {"name": "stroke", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawBorders", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}, {"name": "base", "type": "Color", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlane", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}, {"name": "run", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setPlane", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "fill", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "offset", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawSelection", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawSelection", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "stroke", "type": "float", "varargs": false}, {"name": "length", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawSpecialSelection", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "stroke", "type": "float", "varargs": false}, {"name": "length", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "dispose", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_render_0(_args: Array = []) -> Variant:
	return null

func java_method_renderPlanet_1(_args: Array = []) -> Variant:
	return null

func java_method_renderTransparent_2(_args: Array = []) -> Variant:
	return null

func java_method_renderOrbit_3(_args: Array = []) -> Variant:
	return null

func java_method_renderSectors_4(_args: Array = []) -> Variant:
	return null

func java_method_drawArcLine_5(_args: Array = []) -> Variant:
	return null

func java_method_drawArc_6(_args: Array = []) -> Variant:
	return null

func java_method_drawArc_7(_args: Array = []) -> Variant:
	return null

func java_method_drawArc_8(_args: Array = []) -> Variant:
	return null

func java_method_drawArcLine_9(_args: Array = []) -> Variant:
	return null

func java_method_drawBorders_10(_args: Array = []) -> Variant:
	return null

func java_method_drawPlane_11(_args: Array = []) -> Variant:
	return null

func java_method_setPlane_12(_args: Array = []) -> Variant:
	return null

func java_method_fill_13(_args: Array = []) -> Variant:
	return null

func java_method_drawSelection_14(_args: Array = []) -> Variant:
	return null

func java_method_drawSelection_15(_args: Array = []) -> Variant:
	return null

func java_method_drawSpecialSelection_16(_args: Array = []) -> Variant:
	return null

func java_method_dispose_17(_args: Array = []) -> Variant:
	return null
