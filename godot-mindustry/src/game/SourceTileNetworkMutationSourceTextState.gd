extends RefCounted
class_name SourceTileNetworkMutationSourceTextState

const SOURCE_TILE_NETWORK_MUTATION_SOURCE := "core/src/mindustry/world/Tile.java"
const SOURCE_TILE_REMOVE_NET_METHOD := "public void removeNet(){"
const SOURCE_TILE_REMOVE_NET_EXPR := "Call.removeTile(this);"
const SOURCE_TILE_SET_NET_METHOD := "public void setNet(Block block){"
const SOURCE_TILE_SET_NET_DEFAULT_EXPR := "Call.setTile(this, block, Team.derelict, 0);"
const SOURCE_TILE_SET_NET_ROTATED_METHOD := "public void setNet(Block block, Team team, int rotation){"
const SOURCE_TILE_SET_NET_ROTATED_EXPR := "Call.setTile(this, block, team, rotation);"
const SOURCE_TILE_SET_FLOOR_NET_METHOD := "public void setFloorNet(Block floor, Block overlay){"
const SOURCE_TILE_SET_FLOOR_NET_EXPR := "Call.setFloor(this, floor, overlay);"
const SOURCE_TILE_SET_FLOOR_NET_DEFAULT_METHOD := "public void setFloorNet(Block floor){"
const SOURCE_TILE_SET_FLOOR_NET_DEFAULT_EXPR := "setFloorNet(floor, Blocks.air);"
const SOURCE_TILE_SET_OVERLAY_NET_METHOD := "public void setOverlayNet(Block overlay){"
const SOURCE_TILE_SET_OVERLAY_NET_EXPR := "Call.setOverlay(this, overlay);"
