extends RefCounted
class_name SourceMathSourceTextState

const SOURCE_MATHF_APPROACH_DELTA_METHOD := "public static float approachDelta(float from, float to, float speed){\n        return approach(from, to, Time.delta * speed);\n    }"
const SOURCE_MATHF_APPROACH_DELTA_APPROACH_METHOD := "public static float approach(float from, float to, float speed){\n        return from + Mathf.clamp(to - from, -speed, speed);\n    }"
const SOURCE_MATHF_APPROACH_DELTA_SCALED_SPEED := "Time.delta * speed"
const SOURCE_MATHF_DST_METHOD := "public static float dst(float x1, float y1, float x2, float y2){\n        final float xd = x2 - x1;\n        final float yd = y2 - y1;\n        return (float)Math.sqrt(xd * xd + yd * yd);\n    }"
const SOURCE_MATHF_DST_XD_EXPR := "final float xd = x2 - x1;"
const SOURCE_MATHF_DST_YD_EXPR := "final float yd = y2 - y1;"
const SOURCE_MATHF_DST_RETURN_EXPR := "return (float)Math.sqrt(xd * xd + yd * yd);"
const SOURCE_ARC_MATHF_NUM_METHOD := "public static int num(boolean b){"
const SOURCE_ANGLES_WITHIN_METHOD := "public static boolean within(float a, float b, float margin){\n        return angleDist(a, b) <= margin;\n    }"
