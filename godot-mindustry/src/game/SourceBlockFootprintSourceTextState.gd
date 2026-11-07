extends RefCounted
class_name SourceBlockFootprintSourceTextState

const SOURCE_BLOCK_SIZE_OFFSET_EXPR := "sizeOffset = -((size - 1) / 2);"
const SOURCE_BLOCK_ITERATE_TAKEN_OFFSET_EXPR := "int offsetx = -(size - 1) / 2;"
const SOURCE_BLOCK_ITERATE_TAKEN_LOOP_EXPR := "placer.get(dx + offsetx + x, dy + offsety + y);"
