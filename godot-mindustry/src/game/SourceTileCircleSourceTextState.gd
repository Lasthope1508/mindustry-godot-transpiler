extends RefCounted
class_name SourceTileCircleSourceTextState

const SOURCE_TILE_CIRCLE_SOURCE := "core/src/mindustry/world/Tile.java"
const SOURCE_TILE_CIRCLE_GEOMETRY_SOURCE := "arc-core/src/arc/math/geom/Geometry.java"
const SOURCE_TILE_CIRCLE_INT_METHOD := "public void circle(int radius, Intc2 cons){"
const SOURCE_TILE_CIRCLE_INT_EXPR := "Geometry.circle(x, y, world.width(), world.height(), radius, cons);"
const SOURCE_TILE_CIRCLE_TILE_METHOD := "public void circle(int radius, Cons<Tile> cons){"
const SOURCE_TILE_CIRCLE_TILE_EXPR := "circle(radius, (x, y) -> cons.get(world.rawTile(x, y)));"
const SOURCE_TILE_CIRCLE_LOOP_EXPR := "for(int dx = Math.max(x - radius, 0); dx <= Math.min(x + radius, width - 1); dx++){"
const SOURCE_TILE_CIRCLE_INNER_LOOP_EXPR := "for(int dy = Math.max(y - radius, 0); dy <= Math.min(y + radius, height - 1); dy++){"
const SOURCE_TILE_CIRCLE_GUARD_EXPR := "if(Mathf.within(dx, dy, x, y, radius)){"
const SOURCE_TILE_CIRCLE_CONSUME_EXPR := "cons.get(dx, dy);"
const SOURCE_TILE_CIRCLE_RAW_TILE_EXPR := "world.rawTile(x, y)"
