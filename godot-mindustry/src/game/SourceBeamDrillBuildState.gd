extends RefCounted
class_name SourceBeamDrillBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_block_plan_geometry_state := preload("res://src/game/SourceBlockPlanGeometryState.gd")

# Geometry.d4x / d4y (arc-core Geometry.java:23-24,
# `public final static int[] d4x = {1, 0, -1, 0};` /
# `public final static int[] d4y = {0, 1, 0, -1};`,
# read through d4x(int) / d4y(int), Geometry.java:47-51,
# `return d4x[Mathf.mod(i, 4)];`): the four cardinal
# directions, indexed by rotation 0-3.
const SOURCE_BEAM_DRILL_D4X := [1, 0, -1, 0]
const SOURCE_BEAM_DRILL_D4Y := [0, 1, 0, -1]

# The BeamDrill implementation (BeamDrill.java:25, `public class
# BeamDrill extends Block{`): plasma-bore (consumePower 0.15f,
# drillTime 160f, tier 3, size 2, range 5, hydrogen 0.25f/60f
# booster) and large-plasma-bore (consumePower 0.8f, drillTime
# 100f, tier 5, size 3, range 6, hydrogen 0.5f/60f + nitrogen
# 3f/60f booster). Both havePower=true. BeamDrill extends Block,
# NOT Drill, so it cannot reuse the drill frame key
# ("source_drill_building", bound by the drill proximity path
# for DrillBuild); this driver uses its own family frame key
# ("source_beam_drill_building", the mechanical-pump precedent),
# and this slice adds the beam-drill key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it.
const SOURCE_BEAM_DRILL_BUILD_IMPLEMENTATIONS := ["BeamDrill"]
const SOURCE_BEAM_DRILL_BUILDING_META_KEY := "source_beam_drill_building"

static func _is_beam_drill_build_implementation(implementation: String) -> bool:
	return SOURCE_BEAM_DRILL_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_beam_drill_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The beam-drill tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (BeamDrill.java:25, `public class BeamDrill extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# beam drill skips consumption like Java's updateConsumption
	# (BuildingComp.java:1944-1945, "everything is valid when
	# cheating"). A team with no rule keeps the false default
	# (Rules.java:328 TeamRule.cheat, default false).
	frame["block_implementation"] = block_implementation
	frame["team_id"] = team_id
	frame["rules_state"] = rules_state
	frame["cheating"] = bool(source_rules_state.source_team_cheating_state(rules_state, team_id).get("cheating", false))
	# Building.enabled (BuildingComp.java:77, `transient boolean
	# enabled = true;`) is what shouldConsume() returns
	# (BuildingComp.java:755-757), so the power graph reads it live
	# for this beam drill (N2125); the tick preserves a disabled
	# beam drill instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_beam_drill_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the beam-drill frame meta key
	# ("source_beam_drill_building"). A BeamDrill sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_beam_drill_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_BEAM_DRILL_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_BEAM_DRILL_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_BEAM_DRILL_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_beam_drill_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40,
	# `return build.power.status;`): the power consumer's
	# efficiency is the building's live power.status, and the
	# first pass folds it into the min efficiency
	# (BuildingComp.java:1969-1976, `for(var cons : block.
	# nonOptionalConsumers){` / `minEfficiency = Math.min(
	# minEfficiency, result);`). The graph update stamps
	# frame["power_status"] each tick (N2142); a missing stamp
	# folds to 1.0 before the first graph update, the assembler
	# fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`).
	# A block with no power consumer contributes no row. The
	# power consumer counts toward hasConsumers
	# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
	# so a beam drill does not take the early return. The
	# beam-drill speed follows the folded efficiency
	# (BeamDrill.java:249, `lastDrillSpeed = (facingAmount * multiplier * timeScale) / drillTime * efficiency;`), with the warmup gate (BeamDrill.java:242, `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 60f);`) and the boost multiplier (BeamDrill.java:246, `float multiplier = Mathf.lerp(1f, optionalBoostIntensity, optionalEfficiency);`).
	# Documented limits: (1) power-only first pass -- the
	# plasma hydrogen booster and large hydrogen + nitrogen
	# booster liquid rows wait for their own slices, so the
	# folded efficiency is the min over the *modeled*
	# consumers (power only). (2) No shouldConsume gate --
	# BeamDrillBuild.shouldConsume() (BeamDrill.java:270-271,
	# `return items.total() < itemCapacity && facingAmount > 0 && enabled;`) needs items/facing state the tick
	# does not track yet; the machinery runs with
	# should_consume=true when enabled. (3) No updateTile
	# advance -- warmup / multiplier / lastDrillSpeed / time
	# / dump (BeamDrill.java:237-263) wait for their own
	# slices; the proof carries no progress keys, the
	# lastDrillSpeed fold (BeamDrill.java:249) is what the
	# efficiency keys prove.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_beam_drill_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the beam-drill tick wiring every
	# tick (BeamDrillBuild.updateTile(), BeamDrill.java:237,
	# gates on the warmup gate (BeamDrill.java:242,
	# `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 60f);`) and folds the
	# lastDrillSpeed (BeamDrill.java:249,
	# `lastDrillSpeed = (facingAmount * multiplier * timeScale) / drillTime * efficiency;`), so the
	# lastDrillSpeed fold follows the folded efficiency; no
	# placed-buildings driver ticks BeamDrill blocks, so this
	# driver is the placed-beam-drill tick): each placed
	# BeamDrill build gets its frame keys refreshed from the
	# live rules, so the frame's cheating flag tracks
	# team.rules().cheat and the consumption machinery skips
	# consumption for a cheating team. The frame is bound at
	# placement; a sprite that somehow lacks one gets it bound
	# here instead of crashing the loop.
	var results_by_cell := {}
	var ticked_count := 0
	if game == null:
		return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
	var catalog = game.get("content_catalog")
	if catalog == null:
		return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if not _is_beam_drill_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_beam_drill_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_beam_drill_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a beam drill with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the lastDrillSpeed fold (BeamDrill.java:249)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449,
		# `hasConsumers = consumers.length > 0;`), so a beam
		# drill does not take the early return. A beam drill with
		# no power consumer is untouched: the tick models no other
		# consumers yet (the plasma hydrogen booster and large
		# hydrogen + nitrogen booster liquid rows wait for their
		# own slices), and there is no shouldConsume gate yet
		# (BeamDrill.java:270-271 needs items/facing state the
		# tick does not track), so the machinery runs with
		# should_consume=true when enabled.
		# productionValid is the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_beam_drill_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}

static func source_beam_drill_version_write_read_state(time: float, warmup: float, revision: int, stored_time: float, stored_warmup: float) -> Dictionary:
	# BeamDrillBuild.version() (BeamDrill.java:414-416):
	# `public byte version(){`
	# `return 1;`
	# `}`
	# BeamDrillBuild.write() (BeamDrill.java:419-424):
	# `public void write(Writes write){`
	# `super.write(write);`
	# `write.f(time);`
	# `write.f(warmup);`
	# `}`
	# BeamDrillBuild.read() (BeamDrill.java:426-433):
	# `public void read(Reads read, byte revision){`
	# `super.read(read, revision);`
	# `if(revision >= 1){`
	# `time = read.f();`
	# `warmup = read.f();`
	# `}`
	# `}`
	# on `public class BeamDrillBuild extends Building{`
	# (BeamDrill.java:220) inside `public class BeamDrill
	# extends Block{` (BeamDrill.java:25). Each method is
	# `@Override`. version() stamps the save revision:
	# always 1. write() persists the two own fields time
	# (BeamDrill.java:225, `public float time;`) and warmup
	# (BeamDrill.java:226, `public float warmup, boostWarmup;`),
	# whatever the revision. read() restores
	# both only at revision >= 1; below 1 both keep their
	# current values. The super layer is DrillBuild.write/
	# read (N2286), a callee, not re-ported here. The port
	# has no save/load stream, so the values read.f() would
	# return arrive as the explicit stored_time /
	# stored_warmup params (the N2330 param precedent). NO
	# driver tick line: persistence is not a per-tick call.
	# Write order is time then warmup (BeamDrill.java:
	# 421-422), and read order is the same (:429-430).
	var version: int = 1
	var write_time: float = time
	var write_warmup: float = warmup
	var read_time: float = time
	var read_warmup: float = warmup
	if revision >= 1:
		read_time = stored_time
		read_warmup = stored_warmup
	return {"version": version, "write_time": write_time, "write_warmup": write_warmup, "time": read_time, "warmup": read_warmup}

static func source_beam_drill_on_proximity_update_state(frame: Dictionary, tile_x: int, tile_y: int, rotation: int, size: int, range_value: int, tier: int, blocked_items: Variant, world_tile: Callable) -> Dictionary:
	# BeamDrillBuild.onProximityUpdate() (BeamDrill.java:362-366):
	# `public void onProximityUpdate(){`
	# `//when rotated.`
	# `updateLasers();`
	# `updateFacing();`
	# `}`
	# on `public class BeamDrillBuild extends Building{`
	# (BeamDrill.java:220) inside `public class BeamDrill
	# extends Block{` (BeamDrill.java:25). The method only
	# calls the two facing helpers, in order, when the
	# build is rotated (or placed); the updateTile call
	# site (BeamDrill.java:239-240) is the same pair
	# guarded by the null check:
	# `if(lasers[0] == null) updateLasers();`
	# -- updateTile N2155 does not own that line. NO
	# driver tick line: proximity update runs at
	# placement / rotation, not per tick (the N2302
	# precedent).
	var lasers_result: Dictionary = source_beam_drill_update_lasers_state(frame, tile_x, tile_y, rotation, size)
	var facing_result: Dictionary = source_beam_drill_update_facing_state(frame, rotation, size, range_value, tier, blocked_items, world_tile)
	return {"lasers": lasers_result.get("lasers", []), "facing": facing_result.get("facing", []), "last_item": facing_result.get("last_item", null), "facing_amount": facing_result.get("facing_amount", 0)}

static func source_beam_drill_update_lasers_state(frame: Dictionary, tile_x: int, tile_y: int, rotation: int, size: int) -> Dictionary:
	# BeamDrillBuild.updateLasers() (BeamDrill.java:368-373):
	# `protected void updateLasers(){`
	# `for(int i = 0; i < size; i++){`
	# `if(lasers[i] == null) lasers[i] = new Point2();`
	# `nearbySide(tileX(), tileY(), rotation, i, lasers[i]);`
	# `}`
	# `}`
	# on the build fields (BeamDrill.java:221-222):
	# `public Tile[] facing = new Tile[size];`
	# `public Point2[] lasers = new Point2[size];`
	# The lasers are the side points of the drill footprint:
	# each entry is a Point2 (Vector2i here) on the side
	# the build faces, recomputed every call -- a null
	# entry is created first (`if(lasers[i] == null)`),
	# then nearbySide overwrites it unconditionally, so
	# an existing point is recomputed, not kept.
	# nearbySide is the N1762 callee
	# (PortGame.source_block_nearby_side_state,
	# Block.java:936, `public void nearbySide(int x, int
	# y, int rotation, int index, Point2 out){`), reached
	# here through its static geometry form; it is NOT
	# re-ported. tile_x / tile_y are tileX() / tileY(),
	# rotation is 0-3, size is the block size (plasma-bore
	# 2, large-plasma-bore 3, Blocks.java:3049-3065).
	var lasers: Array = []
	if frame.get("lasers", null) is Array:
		lasers = frame["lasers"]
	while lasers.size() < size:
		lasers.append(null)
	for i in range(size):
		if lasers[i] == null:
			lasers[i] = Vector2i.ZERO
		var side: Dictionary = source_block_plan_geometry_state.nearby_side_state(tile_x, tile_y, rotation, i, size, lasers[i])
		var point: Dictionary = side.get("nearby_side", {})
		lasers[i] = Vector2i(int(point.get("x", 0)), int(point.get("y", 0)))
	frame["lasers"] = lasers
	return {"lasers": lasers}

static func source_beam_drill_update_facing_state(frame: Dictionary, rotation: int, size: int, range_value: int, tier: int, blocked_items: Variant, world_tile: Callable) -> Dictionary:
	# BeamDrillBuild.updateFacing() (BeamDrill.java:375-412):
	# `protected void updateFacing(){`
	# `lastItem = null;`
	# `boolean multiple = false;`
	# `int dx = Geometry.d4x(rotation), dy = Geometry.d4y(rotation);`
	# `facingAmount = 0;`
	# `//update facing tiles`
	# `for(int p = 0; p < size; p++){`
	# `Point2 l = lasers[p];`
	# `Tile dest = null;`
	# `for(int i = 0; i < range; i++){`
	# `int rx = l.x + dx*i, ry = l.y + dy*i;`
	# `Tile other = world.tile(rx, ry);`
	# `if(other != null){`
	# `if(other.solid()){`
	# `Item drop = other.wallDrop();`
	# `if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){`
	# `facingAmount ++;`
	# `if(lastItem != drop && lastItem != null){`
	# `multiple = true;`
	# `}`
	# `lastItem = drop;`
	# `dest = other;`
	# `}`
	# `break;`
	# `}`
	# `}`
	# `}`
	# `facing[p] = dest;`
	# `}`
	# `//when multiple items are present, count that as no item`
	# `if(multiple){`
	# `lastItem = null;`
	# `}`
	# `}`
	# on the build fields (BeamDrill.java:221-223, 228):
	# `public Tile[] facing = new Tile[size];`
	# `public Point2[] lasers = new Point2[size];`
	# `public @Nullable Item lastItem;`
	# `public int facingAmount;`
	# with the class field (BeamDrill.java:40):
	# `public int range = 5;`
	# and the per-def tier (plasma-bore 3, large-plasma-bore 5,
	# Blocks.java:3049-3065; the class default `public int
	# tier = 1;` is shared with N2133/N2168, context only)
	# and the blocked list (BeamDrill.java:51, `public
	# @Nullable Seq<Item> blockedItems;`, shared with
	# N2013/N2302/N2332, context only). The scan reads
	# one ray per laser point, step by step out to range:
	# a null tile or a non-solid tile does NOT stop the
	# ray (the break sits inside `if(other.solid()){`);
	# the first solid tile stops it whether or not its
	# drop is mineable, and the break itself (`break;`)
	# is shared with N1152/N2313, context only. A drop
	# counts only when it exists, its
	# hardness is at most the tier, and it is not blocked.
	# `other.solid()` is Tile.java:457 (`return
	# block.solid || floor.solid || (build != null &&
	# build.checkSolid());`); `other.wallDrop()` is
	# Tile.java:575 (the block itemDrop when solid, else
	# the wall-ore overlay drop, else null). The live
	# world arrives as the explicit world_tile Callable
	# (the N2294 param precedent): world_tile.call(rx,
	# ry) returns null or a tile Dictionary {"solid",
	# "wall_drop", "wall_drop_hardness"}; facing[p]
	# stores that tile Dictionary (dest = other). Item
	# identity is by name here (items are singletons per
	# name in the synthetic contract), so `lastItem !=
	# drop` is a name comparison. A missing laser point
	# (frame built without updateLasers) leaves its
	# facing null -- Java would throw there; the guard
	# is documented, not a behavior change for any
	# frame updateLasers built. NO driver tick line:
	# updateFacing runs from onProximityUpdate only.
	var lasers: Array = []
	if frame.get("lasers", null) is Array:
		lasers = frame["lasers"]
	var last_item: Variant = null
	var multiple := false
	var dx: int = SOURCE_BEAM_DRILL_D4X[posmod(rotation, 4)]
	var dy: int = SOURCE_BEAM_DRILL_D4Y[posmod(rotation, 4)]
	var facing_amount := 0
	var facing: Array = []
	while facing.size() < size:
		facing.append(null)
	for p in range(size):
		var laser: Variant = lasers[p] if p < lasers.size() else null
		var dest: Variant = null
		if laser != null:
			var lx: int = int(laser.x)
			var ly: int = int(laser.y)
			for i in range(range_value):
				var rx: int = lx + dx * i
				var ry: int = ly + dy * i
				var other: Variant = world_tile.call(rx, ry)
				if other != null:
					var other_tile: Dictionary = other
					if bool(other_tile.get("solid", false)):
						var drop: Variant = other_tile.get("wall_drop", null)
						if drop != null and float(other_tile.get("wall_drop_hardness", 0.0)) <= float(tier) and (blocked_items == null or not (drop in blocked_items)):
							facing_amount += 1
							if last_item != drop and last_item != null:
								multiple = true
							last_item = drop
							dest = other
						break
		facing[p] = dest
	if multiple:
		last_item = null
	frame["facing"] = facing
	frame["last_item"] = last_item
	frame["facing_amount"] = facing_amount
	return {"facing": facing, "last_item": last_item, "facing_amount": facing_amount}
