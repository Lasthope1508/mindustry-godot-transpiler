# Generated from Mindustry upstream.
# Source: mindustry/core/Renderer.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.core"
const JAVA_KIND := "class"
const JAVA_NAME := "Renderer"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["ApplicationListener"]
const JAVA_FIELDS := [{"modifiers": ["public", "static"], "name": "laserOpacity", "type": "float"}, {"modifiers": ["public", "static"], "name": "unitLaserOpacity", "type": "float"}, {"modifiers": ["public", "static"], "name": "bridgeOpacity", "type": "float"}, {"modifiers": ["final", "public"], "name": "blocks", "type": "BlockRenderer"}, {"modifiers": ["final", "public"], "name": "fog", "type": "FogRenderer"}, {"modifiers": ["final", "public"], "name": "minimap", "type": "MinimapRenderer"}, {"modifiers": ["final", "public"], "name": "overlays", "type": "OverlayRenderer"}, {"modifiers": ["final", "public"], "name": "lights", "type": "LightRenderer"}, {"modifiers": ["final", "public"], "name": "pixelator", "type": "Pixelator"}, {"modifiers": ["public"], "name": "planets", "type": "PlanetRenderer"}, {"modifiers": ["public"], "name": "bloom", "type": "Bloom"}, {"modifiers": ["public"], "name": "backgroundBuffer", "type": "FrameBuffer"}, {"modifiers": ["public"], "name": "effectBuffer", "type": "FrameBuffer"}, {"modifiers": ["public"], "name": "animateShields", "type": "boolean"}, {"modifiers": ["public"], "name": "animateWater", "type": "boolean"}, {"modifiers": ["public"], "name": "drawWeather", "type": "boolean"}, {"modifiers": ["public"], "name": "drawStatus", "type": "boolean"}, {"modifiers": ["public"], "name": "enableEffects", "type": "boolean"}, {"modifiers": ["public"], "name": "drawDisplays", "type": "boolean"}, {"modifiers": ["public"], "name": "drawLight", "type": "boolean"}, {"modifiers": ["public"], "name": "pixelate", "type": "boolean"}, {"modifiers": ["public"], "name": "showPings", "type": "boolean"}, {"modifiers": ["public"], "name": "showOtherBuildPlans", "type": "boolean"}, {"modifiers": ["public"], "name": "weatherAlpha", "type": "float"}, {"modifiers": ["public"], "name": "minZoom", "type": "float"}, {"modifiers": ["public"], "name": "maxZoom", "type": "float"}, {"modifiers": ["public"], "name": "minZoomInGame", "type": "float"}, {"modifiers": ["public"], "name": "maxZoomInGame", "type": "float"}, {"modifiers": ["public"], "name": "envRenderers", "type": "Seq"}, {"modifiers": ["public"], "name": "customBackgrounds", "type": "ObjectMap"}, {"modifiers": ["public"], "name": "bubbles", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "splashes", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "fluidFrames", "type": "TextureRegion"}, {"modifiers": ["private"], "name": "launchAnimator", "type": "LaunchAnimator"}, {"modifiers": ["private"], "name": "clearColor", "type": "Color"}, {"modifiers": ["public"], "name": "targetscale", "type": "float"}, {"modifiers": ["public"], "name": "camerascale", "type": "float"}, {"modifiers": ["public"], "name": "landTime", "type": "float"}, {"modifiers": ["public"], "name": "shakeIntensity", "type": "float"}, {"modifiers": ["public"], "name": "shakeReduction", "type": "float"}, {"modifiers": ["public"], "name": "shakeTime", "type": "float"}, {"modifiers": ["private"], "name": "launching", "type": "boolean"}, {"modifiers": ["private"], "name": "camShakeOffset", "type": "Vec2"}, {"modifiers": ["private"], "name": "glErrors", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Renderer", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "shake", "parameters": [{"name": "intensity", "type": "float", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addEnvRenderer", "parameters": [{"name": "mask", "type": "int", "varargs": false}, {"name": "render", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addCustomBackground", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "render", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "loadFluidFrames", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getFluidFrames", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateAllDarkness", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isCutscene", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "landScale", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "dispose", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "resume", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "setupBloom", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "toggleBloom", "parameters": [{"name": "enabled", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "drawBackground", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "scaleCamera", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "clampScale", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getDisplayScale", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "minScale", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "maxScale", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getScale", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "setScale", "parameters": [{"name": "scl", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isLaunching", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getLandTime", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getLandTimeIn", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "showLanding", "parameters": [{"name": "landCore", "type": "LaunchAnimator", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "showLaunch", "parameters": [{"name": "landCore", "type": "LaunchAnimator", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "takeMapScreenshot", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_shake_0(_args: Array = []) -> Variant:
	return null

func java_method_addEnvRenderer_1(_args: Array = []) -> Variant:
	return null

func java_method_addCustomBackground_2(_args: Array = []) -> Variant:
	return null

func java_method_init_3(_args: Array = []) -> Variant:
	return null

func java_method_loadFluidFrames_4(_args: Array = []) -> Variant:
	return null

func java_method_getFluidFrames_5(_args: Array = []) -> Variant:
	return null

func java_method_update_6(_args: Array = []) -> Variant:
	return null

func java_method_updateAllDarkness_7(_args: Array = []) -> Variant:
	return null

func java_method_isCutscene_8(_args: Array = []) -> Variant:
	return null

func java_method_landScale_9(_args: Array = []) -> Variant:
	return null

func java_method_dispose_10(_args: Array = []) -> Variant:
	return null

func java_method_resume_11(_args: Array = []) -> Variant:
	return null

func java_method_setupBloom_12(_args: Array = []) -> Variant:
	return null

func java_method_toggleBloom_13(_args: Array = []) -> Variant:
	return null

func java_method_draw_14(_args: Array = []) -> Variant:
	return null

func java_method_drawBackground_15(_args: Array = []) -> Variant:
	return null

func java_method_scaleCamera_16(_args: Array = []) -> Variant:
	return null

func java_method_clampScale_17(_args: Array = []) -> Variant:
	return null

func java_method_getDisplayScale_18(_args: Array = []) -> Variant:
	return null

func java_method_minScale_19(_args: Array = []) -> Variant:
	return null

func java_method_maxScale_20(_args: Array = []) -> Variant:
	return null

func java_method_getScale_21(_args: Array = []) -> Variant:
	return null

func java_method_setScale_22(_args: Array = []) -> Variant:
	return null

func java_method_isLaunching_23(_args: Array = []) -> Variant:
	return null

func java_method_getLandTime_24(_args: Array = []) -> Variant:
	return null

func java_method_getLandTimeIn_25(_args: Array = []) -> Variant:
	return null

func java_method_showLanding_26(_args: Array = []) -> Variant:
	return null

func java_method_showLaunch_27(_args: Array = []) -> Variant:
	return null

func java_method_takeMapScreenshot_28(_args: Array = []) -> Variant:
	return null
