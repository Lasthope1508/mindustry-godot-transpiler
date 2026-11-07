extends RefCounted
class_name SourceDisplayProfileSourceTextState

const SOURCE_CAMERA_CLAMP_EXPR := "camera.position.clamp(-camera.width/4f, -camera.height/4f, world.unitWidth() + camera.width/4f, world.unitHeight() + camera.height/4f);"
const SOURCE_CAMERA_CLAMP_VISIBLE_PADDING_EXPR := "camera.width/4f clamp slack + camera.width/2f viewport half extent"
const CAMERA_ZOOM_MIN_COMPONENT := 0.001
const SOURCE_RENDERER_CAMERA_WIDTH_EXPR := "camera.width = graphics.getWidth() / camerascale;"
const SOURCE_RENDERER_CAMERA_HEIGHT_EXPR := "camera.height = graphics.getHeight() / camerascale;"
const SOURCE_RENDERER_MIN_SCALE_EXPR := "public float minScale(){\n        if(control.input.logicCutscene) return Scl.scl(minZoom);\n        return Scl.scl(minZoomInGame);\n    }"
const SOURCE_RENDERER_MAX_SCALE_EXPR := "public float maxScale(){\n        if(control.input.logicCutscene) return Mathf.round(Scl.scl(maxZoom));\n        return Mathf.round(Scl.scl(maxZoomInGame));\n    }"
