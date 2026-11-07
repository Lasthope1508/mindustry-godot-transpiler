extends RefCounted
class_name SourceTileSetFloorSourceTextState

const SOURCE_TILE_SET_FLOOR_SOURCE := "core/src/mindustry/world/Tile.java"
const SOURCE_TILE_SET_FLOOR_METHOD := "public void setFloor(Floor type){"
const SOURCE_TILE_SET_FLOOR_SAME_GUARD_EXPR := "if(this.floor == type) return;"
const SOURCE_TILE_SET_FLOOR_PREVIOUS_FLOOR_EXPR := "var prev = this.floor;"
const SOURCE_TILE_SET_FLOOR_ASSIGN_EXPR := "this.floor = type;"
const SOURCE_TILE_SET_FLOOR_REMOVE_INDEX_EXPR := "renderer.blocks.removeFloorIndex(this);"
const SOURCE_TILE_SET_FLOOR_RECACHE_EXPR := "recache();"
const SOURCE_TILE_SET_FLOOR_BUILD_PROXIMITY_EXPR := "build.onProximityUpdate();"
const SOURCE_TILE_SET_FLOOR_PATHFINDER_EXPR := "pathfinder.updateTile(this);"
const SOURCE_TILE_SET_FLOOR_EVENT_EXPR := "Events.fire(floorChange.set(this, prev, type));"
const SOURCE_TILE_SET_FLOOR_CHANGED_EXPR := "this.floor.floorChanged(this);"
