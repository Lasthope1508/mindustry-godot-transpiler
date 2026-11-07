class_name SourceBuildPayloadDrawSourceTextState
extends RefCounted

const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_METHOD := "public void drawShadow(float alpha){"
const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_EXPR := "Drawf.squareShadow(build.x, build.y, build.block.size * tilesize * 1.85f, alpha);"
const SOURCE_BUILD_PAYLOAD_DRAW_METHOD := "public void draw(){"
const SOURCE_BUILD_PAYLOAD_DRAW_PREV_Z_EXPR := "float prevZ = Draw.z();"
const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_Z_EXPR := "Draw.z(prevZ - 0.001f);"
const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_CALL_EXPR := "drawShadow(1f);"
const SOURCE_BUILD_PAYLOAD_DRAW_Z_RESTORE_EXPR := "Draw.z(prevZ);"
const SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_EXPR := "Draw.zTransform(z ->"
const SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_RETURN_EXPR := "z >= Layer.flyingUnitLow + 1f ? z : 0.0011f + Math.min(Mathf.clamp((z - prevZ)/100f, -0.0009f, 0.9f) + prevZ, Layer.flyingUnitLow - 1f)"
const SOURCE_BUILD_PAYLOAD_DRAW_PAYLOAD_DRAW_EXPR := "build.payloadDraw();"
const SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_RESET_EXPR := "Draw.zTransform();"
const SOURCE_BUILD_PAYLOAD_ICON_METHOD := "public TextureRegion icon(){"
const SOURCE_BUILD_PAYLOAD_ICON_RETURN_EXPR := "return block().fullIcon;"

const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_JAVA_METHOD := "java_method_drawShadow_15"
const SOURCE_BUILD_PAYLOAD_DRAW_JAVA_METHOD := "java_method_draw_16"
const SOURCE_BUILD_PAYLOAD_ICON_JAVA_METHOD := "java_method_icon_17"

const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_GENERATED_OWNER := "build_payload.java_method_drawShadow_15"
const SOURCE_BUILD_PAYLOAD_DRAW_GENERATED_OWNER := "build_payload.java_method_draw_16"
const SOURCE_BUILD_PAYLOAD_ICON_GENERATED_OWNER := "build_payload.java_method_icon_17"
