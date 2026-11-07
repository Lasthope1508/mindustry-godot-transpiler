extends RefCounted
class_name SourceBlockAttributeSourceTextState

const SOURCE_BLOCK_ATTRIBUTE_SOURCE := "core/src/mindustry/world/Block.java"
const SOURCE_BLOCK_SUM_ATTRIBUTE_METHOD := "public float sumAttribute(@Nullable Attribute attr, int x, int y){"
const SOURCE_BLOCK_SUM_ATTRIBUTE_NULL_ATTR_GUARD := "if(attr == null) return 0;"
const SOURCE_BLOCK_SUM_ATTRIBUTE_TILE_LOOKUP := "Tile tile = world.tile(x, y);"
const SOURCE_BLOCK_SUM_ATTRIBUTE_NULL_TILE_GUARD := "if(tile == null) return 0;"
const SOURCE_BLOCK_SUM_ATTRIBUTE_LINKED_TILES := ".sumf(other -> !floating && !placeableLiquid && other.floor().isDeep() ? 0 : other.floor().attributes.get(attr));"
const SOURCE_BLOCK_SUM_ATTRIBUTE_JAVA_METHOD := "java_method_sumAttribute_12"
const SOURCE_BLOCK_SUM_ATTRIBUTE_GENERATED_OWNER := "block.java_method_sumAttribute_12"
