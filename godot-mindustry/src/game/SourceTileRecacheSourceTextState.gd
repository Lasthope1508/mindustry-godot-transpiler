extends RefCounted
class_name SourceTileRecacheSourceTextState

const SOURCE_TILE_RECACHE_SOURCE := "core/src/mindustry/world/Tile.java"
const SOURCE_TILE_RECACHE_WALL_METHOD := "public void recacheWall(){"
const SOURCE_TILE_RECACHE_METHOD := "public void recache(){"
const SOURCE_TILE_RECACHE_GUARD_EXPR := "if(!headless && !world.isGenerating()){"
const SOURCE_TILE_RECACHE_WALL_EXPR := "renderer.blocks.recacheWall(this);"
const SOURCE_TILE_RECACHE_FLOOR_EXPR := "renderer.blocks.floor.recacheTile(this);"
const SOURCE_TILE_RECACHE_MINIMAP_EXPR := "renderer.minimap.update(this);"
const SOURCE_TILE_RECACHE_INVALIDATE_EXPR := "renderer.blocks.invalidateTile(this);"
const SOURCE_TILE_RECACHE_ADD_FLOOR_INDEX_EXPR := "renderer.blocks.addFloorIndex(this);"
const SOURCE_TILE_RECACHE_NEIGHBOR_LOOP_EXPR := "for(int i = 0; i < 8; i++){"
const SOURCE_TILE_RECACHE_NEIGHBOR_LOOKUP_EXPR := "Tile other = world.tile(x + Geometry.d8[i].x, y + Geometry.d8[i].y);"
const SOURCE_TILE_RECACHE_NEIGHBOR_GUARD_EXPR := "if(other != null){"
const SOURCE_TILE_RECACHE_NEIGHBOR_FLOOR_EXPR := "renderer.blocks.floor.recacheTile(other);"
