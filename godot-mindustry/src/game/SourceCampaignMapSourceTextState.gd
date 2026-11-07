extends RefCounted
class_name SourceCampaignMapSourceTextState

const SOURCE_MAP_FILE_HEADER_SIZE := 8
const SOURCE_MAP_IO_CREATE_MAP := "public static Map createMap(Fi file, boolean custom) throws IOException{"
const SOURCE_MAP_IO_INFLATER_STREAM := "new InflaterInputStream(file.read(bufferSize))"
const SOURCE_MAP_SAVE_HEADER := "MSAV"
const SOURCE_MAP_SAVE_VERSION_READ_CONTENT_HEADER := "public void readContentHeader(DataInput stream) throws IOException{"
const SOURCE_MAP_READ_MAPPED := "int mapped = stream.readUnsignedByte();"
const SOURCE_MAP_CONTENT_TYPE_ALL := "ContentType type = ContentType.all[stream.readByte()];"
const SOURCE_MAP_READ_NAME := "String name = stream.readUTF();"
const SOURCE_MAP_SET_TEMPORARY_MAPPER := "content.setTemporaryMapper(map);"
const SOURCE_MAP_SAVE_VERSION_READ_MAP := "public void readMap(DataInput stream, WorldContext context) throws IOException{"
const SOURCE_MAP_READ_FLOOR := "short floorid = stream.readShort();"
const SOURCE_MAP_READ_BLOCK := "Block block = content.block(stream.readShort());"
const SOURCE_MAP_VERSION_11_PATCH_REGION := "readRegion(\"patches\", stream, counter, this::readDataPatches);"
const SOURCE_MAP_SET_BLOCK_CENTER_ONLY := "if(isCenter){"
const SOURCE_MAP_BLOCK_CONSECUTIVES := "int consecutives = stream.readUnsignedByte();"
const MAP_KEY_VALUES := "values"
const MAP_KEY_OFFSET := "offset"
const MAP_KEY_COUNT := "count"
const MAP_KEY_VALUE := "value"
