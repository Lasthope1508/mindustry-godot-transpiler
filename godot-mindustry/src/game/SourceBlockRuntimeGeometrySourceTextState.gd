extends RefCounted
class_name SourceBlockRuntimeGeometrySourceTextState

const SOURCE_BLOCK_RUNTIME_GEOMETRY_SOURCE := "core/src/mindustry/world/Block.java"

const SOURCE_BLOCK_RUNTIME_GEOMETRY_NEW_BUILDING_METHOD := "public final Building newBuilding(){"
const SOURCE_BLOCK_RUNTIME_GEOMETRY_NEW_BUILDING_RETURN_EXPR := "return buildType.get();"
const SOURCE_BLOCK_RUNTIME_GEOMETRY_NEW_BUILDING_JAVA_METHOD := "java_method_newBuilding_71"
const SOURCE_BLOCK_RUNTIME_GEOMETRY_NEW_BUILDING_GENERATED_OWNER := "block.java_method_newBuilding_71"

const SOURCE_BLOCK_RUNTIME_GEOMETRY_UPDATE_CLIP_RADIUS_METHOD := "public void updateClipRadius(float radiusInWorldUnits){"
const SOURCE_BLOCK_RUNTIME_GEOMETRY_UPDATE_CLIP_RADIUS_ASSIGNMENT_EXPR := "clipSize = Math.max(clipSize, this.size * tilesize + radiusInWorldUnits * 2f);"
const SOURCE_BLOCK_RUNTIME_GEOMETRY_UPDATE_CLIP_RADIUS_JAVA_METHOD := "java_method_updateClipRadius_72"
const SOURCE_BLOCK_RUNTIME_GEOMETRY_UPDATE_CLIP_RADIUS_GENERATED_OWNER := "block.java_method_updateClipRadius_72"

const SOURCE_BLOCK_RUNTIME_GEOMETRY_BOUNDS_METHOD := "public Rect bounds(int x, int y, Rect rect){"
const SOURCE_BLOCK_RUNTIME_GEOMETRY_BOUNDS_RETURN_EXPR := "return rect.setSize(size * tilesize).setCenter(x * tilesize + offset, y * tilesize + offset);"
const SOURCE_BLOCK_RUNTIME_GEOMETRY_BOUNDS_JAVA_METHOD := "java_method_bounds_73"
const SOURCE_BLOCK_RUNTIME_GEOMETRY_BOUNDS_GENERATED_OWNER := "block.java_method_bounds_73"
