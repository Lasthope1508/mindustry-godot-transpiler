extends RefCounted
class_name SourceGameStatsRuntimeState

# GameStats.getPlaced(Block) (N2460).
# GameStats.getPlaced(Block block) (GameStats.java:30-32): `return
# placedBlockCount.get(block, 0);` (:31). placedBlockCount is an
# ObjectIntMap<Block> (:21) recording blocks placed, by count.
# GD takes the stats as a Dictionary plus the block as a String
# name (option (A) data-driven, precedent N2453/N2455/N2456/N2457);
# it does not build GameStats objects itself. The lookup is
# `.get(block, 0)` on the placed map -- a missing block returns 0
# (the default of `get(block, 0)`), never KeyError or null.
static func source_game_stats_get_placed_state(stats_state: Dictionary, block: String) -> Dictionary:
	var placed: Dictionary = stats_state.get("placedBlockCount", {})
	return {"placed": int(placed.get(block, 0))}

# GameStats.getDestroyed(Block) (N2460).
# GameStats.getDestroyed(Block block) (GameStats.java:34-36):
# `return destroyedBlockCount.get(block, 0);` (:35).
# destroyedBlockCount is a separate ObjectIntMap<Block> (:24)
# recording enemy blocks destroyed, by count. TRAP: the two maps
# are independent -- getDestroyed reads ONLY the destroyed map,
# never the placed map, and is never derived from placed counts
# (no `placed - destroyed`, no cross-map read): a block present
# in the placed map only still returns 0 here.
static func source_game_stats_get_destroyed_state(stats_state: Dictionary, block: String) -> Dictionary:
	var destroyed: Dictionary = stats_state.get("destroyedBlockCount", {})
	return {"destroyed": int(destroyed.get(block, 0))}
