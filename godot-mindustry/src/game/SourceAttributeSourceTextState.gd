extends RefCounted
class_name SourceAttributeSourceTextState

const SOURCE := "core/src/mindustry/world/meta/Attribute.java"
const GENERATED_SCRIPT := "res://src/generated/classes/mindustry/world/meta/Attribute.gd"
const METHOD_ENV := "public float env(){"
const METHOD_TO_STRING := "public String toString(){"
const METHOD_GET := "public static Attribute get(String name){"
const METHOD_GET_OR_NULL := "public static @Nullable Attribute getOrNull(String name){"
const METHOD_EXISTS := "public static boolean exists(String name){"
const METHOD_ADD := "public static Attribute add(String name){"
const ENV_GUARD := "if(Vars.state == null) return 0;"
const GET_THROW := "return map.getThrow(name, () -> new IllegalArgumentException(\"Unknown Attribute type: \" + name));"
const ADD_ID := "new Attribute(all.length, name)"
const ADD_MAP := "map.put(name, a);"
