extends RefCounted
class_name SourceAttributesSourceTextState

const GENERATED_SCRIPT := "res://src/generated/classes/mindustry/world/blocks/Attributes.gd"

const SOURCE := "core/src/mindustry/world/blocks/Attributes.java"
const METHOD_CLEAR := "public void clear(){"
const METHOD_GET := "public float get(Attribute attr){"
const METHOD_SET := "public void set(Attribute attr, float value){"
const METHOD_ADD := "public void add(Attributes other){"
const METHOD_ADD_SCALED := "public void add(Attributes other, float scl){"
const METHOD_WRITE := "public void write(Json json){"
const METHOD_READ := "public void read(Json json, JsonValue data){"
const METHOD_CHECK := "private void check(){"
const METHOD_TO_STRING := "public String toString(){"
const CHECK_RESIZE := "arr = new float[Attribute.all.length];"
const CHECK_COPY := "System.arraycopy(last, 0, arr, 0, Math.min(last.length, arr.length));"
const WRITE_NONZERO := "if(arr[at.id] != 0){"
const READ_DEFAULT := "arr[at.id] = data.getFloat(at.name, 0);"
const OWNER := "port_game.source_attributes_state"
