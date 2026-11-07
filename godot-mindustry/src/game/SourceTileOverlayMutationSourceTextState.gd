extends RefCounted
class_name SourceTileOverlayMutationSourceTextState

const SOURCE_TILE_OVERLAY_MUTATION_SOURCE := "core/src/mindustry/world/Tile.java"
const SOURCE_TILE_SET_OVERLAY_METHOD := "public void setOverlay(Block block){"
const SOURCE_TILE_SET_OVERLAY_SAME_GUARD_EXPR := "if(this.overlay == block) return;"
const SOURCE_TILE_SET_OVERLAY_PREVIOUS_EXPR := "var prev = this.overlay;"
const SOURCE_TILE_SET_OVERLAY_ASSIGN_EXPR := "this.overlay = (Floor)block;"
const SOURCE_TILE_SET_OVERLAY_RECACHE_EXPR := "recache();"
const SOURCE_TILE_SET_OVERLAY_EVENT_GUARD_EXPR := "if(!world.isGenerating()){"
const SOURCE_TILE_SET_OVERLAY_EVENT_EXPR := "Events.fire(overlayChange.set(this, prev, this.overlay));"
const SOURCE_TILE_SET_OVERLAY_PROXIMITY_GUARD_EXPR := "if(!world.isGenerating() && build != null){"
const SOURCE_TILE_SET_OVERLAY_PROXIMITY_EXPR := "build.onProximityUpdate();"
const SOURCE_TILE_SET_OVERLAY_QUIET_METHOD := "public void setOverlayQuiet(Block block){"
const SOURCE_TILE_SET_OVERLAY_QUIET_ASSIGN_EXPR := "this.overlay = (Floor)block;"
const SOURCE_TILE_CLEAR_OVERLAY_METHOD := "public void clearOverlay(){"
const SOURCE_TILE_CLEAR_OVERLAY_DELEGATE_EXPR := "setOverlay(Blocks.air);"
