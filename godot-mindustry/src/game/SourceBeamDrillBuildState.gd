extends RefCounted
class_name SourceBeamDrillBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_block_plan_geometry_state := preload("res://src/game/SourceBlockPlanGeometryState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

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

static func _beam_drill_rand_xorshift_next_long(rand_state: Dictionary) -> int:
	# arc Rand xorshift128+ step (Rand.java: `public long nextLong(){` /
	# `long s1 = this.seed0;` / `final long s0 = this.seed1;` /
	# `this.seed0 = s0;` / `s1 ^= s1 << 23;` / `return (this.seed1 =
	# (s1 ^ s0 ^ (s1 >>> 17) ^ (s0 >>> 26))) + s0;`): seed1 stores the
	# XOR value WITHOUT the + s0 -- the + s0 is only in the return.
	# The logical shifts are emulated by masking (>>> 17 keeps 47
	# bits, >>> 26 keeps 38 bits). Copied from the
	# RepairTurret-proven helper
	# (SourceRepairTurretBuildState.source_arc_rand_xorshift_next_long,
	# N2289/N2290, live-probed there) -- re-implemented here file-local
	# instead of calling across families, so this file does not depend
	# on the Windows line's RepairTurret file.
	var s1: int = int(rand_state.get("seed0", 0))
	var s0: int = int(rand_state.get("seed1", 0))
	rand_state["seed0"] = s0
	s1 = int(s1 ^ (s1 << 23))
	var next_seed1: int = int(s1 ^ s0 ^ ((s1 >> 17) & 0x7FFFFFFFFFFF) ^ ((s0 >> 26) & 0x3FFFFFFFFF))
	rand_state["seed1"] = next_seed1
	return int(next_seed1 + s0)

static func _beam_drill_rand_xorshift_next_float(rand_state: Dictionary) -> float:
	# arc Rand nextFloat (Rand.java: `public float nextFloat(){` /
	# `return (float)((nextLong() >>> 40) * NORM_FLOAT);`, NORM_FLOAT =
	# 1.0 / (1L << 24)): the top 24 bits of the next long, scaled to
	# [0, 1).
	return float((_beam_drill_rand_xorshift_next_long(rand_state) >> 40) & 0xFFFFFF) * SourceMathState.SOURCE_RAND_NORM_FLOAT

static func _beam_drill_rand_random_max(rand_state: Dictionary, max_value: float) -> float:
	# arc Rand.random(float max) (Rand.java: `public float
	# random(float max){` / `return nextFloat() * max;`).
	return _beam_drill_rand_xorshift_next_float(rand_state) * max_value

static func _beam_drill_rand_range(rand_state: Dictionary, range_value: float) -> float:
	# arc Rand.range(float range) (Rand.java: `public float
	# range(float range){` / `return (nextFloat() * 2f - 1f) *
	# range;`): a symmetric draw in [-range, +range].
	return (_beam_drill_rand_xorshift_next_float(rand_state) * 2.0 - 1.0) * range_value

static func source_beam_drill_draw_state(x: float, y: float, region: Variant, top_region: Variant, laser: Variant, laser_end: Variant, laser_center: Variant, laser_boost: Variant, laser_end_boost: Variant, laser_center_boost: Variant, glow_region: Variant, glow_region_found: bool, rotation: int, size: int, build_id: int, warmup: float, boost_warmup: float, is_payload: bool, facing: Array, lasers: Array, laser_width: float, glow_scl: float, pulse_intensity: float, glow_color: Variant, glow_intensity: float, spark_color: Variant, boost_heat_color: Variant, heat_color: Variant, heat_pulse: float, heat_pulse_scl: float, sparks: int, spark_life: float, spark_recurrence: float, spark_range: float, spark_spread: float, spark_size: float, time_ticks: float, lod_l2: bool, lod_alpha2: float, tilesize: float) -> Dictionary:
	# BeamDrillBuild.draw() (BeamDrill.java:275-361):
	# `public void draw(){`
	# `Draw.rect(block.region, x, y);`
	# `Draw.rect(topRegion, x, y, rotdeg());`
	# ``
	# `if(isPayload()) return;`
	# ``
	# `var dir = Geometry.d4(rotation);`
	# `int ddx = Geometry.d4x(rotation + 1), ddy = Geometry.d4y(rotation + 1);`
	# ``
	# `for(int i = 0; i < size; i++){`
	# `Tile face = facing[i];`
	# `if(face != null){`
	# `Item drop = face.wallDrop();`
	# ``
	# `if(drop == null) continue;`
	# `Point2 p = lasers[i];`
	# `float lx = face.worldx() - (dir.x/2f)*tilesize, ly = face.worldy() - (dir.y/2f)*tilesize;`
	# ``
	# `float width = (laserWidth + Mathf.absin(Time.time + i*5 + (id % 9)*9, glowScl, pulseIntensity)) * warmup;`
	# ``
	# `Draw.z(Layer.power - 1);`
	# `Draw.mixcol(glowColor, Mathf.absin(Time.time + i*5 + id*9, glowScl, glowIntensity));`
	# `if(Math.abs(p.x - face.x) + Math.abs(p.y - face.y) == 0){`
	# `Draw.scl(width);`
	# ``
	# `if(boostWarmup < 0.99f){`
	# `Draw.alpha(1f - boostWarmup);`
	# `Draw.rect(laserCenter, lx, ly);`
	# `}`
	# ``
	# `if(boostWarmup > 0.01f){`
	# `Draw.alpha(boostWarmup);`
	# `Draw.rect(laserCenterBoost, lx, ly);`
	# `}`
	# ``
	# `Draw.scl();`
	# `}else{`
	# `float lsx = (p.x - dir.x/2f) * tilesize, lsy = (p.y - dir.y/2f) * tilesize;`
	# ``
	# `if(boostWarmup < 0.99f){`
	# `Draw.alpha(1f - boostWarmup);`
	# `Drawf.laser(laser, laserEnd, lsx, lsy, lx, ly, width);`
	# `}`
	# ``
	# `if(boostWarmup > 0.001f){`
	# `Draw.alpha(boostWarmup);`
	# `Drawf.laser(laserBoost, laserEndBoost, lsx, lsy, lx, ly, width);`
	# `}`
	# `}`
	# `Draw.color();`
	# `Draw.mixcol();`
	# ``
	# `if(Lod.l2){`
	# `Draw.z(Layer.effect);`
	# `Lines.stroke(warmup);`
	# `rand.setState(i, id);`
	# `Color col = drop.color;`
	# `Color spark = Tmp.c3.set(sparkColor).lerp(boostHeatColor, boostWarmup);`
	# `for(int j = 0; j < sparks; j++){`
	# `float fin = (Time.time / sparkLife + rand.random(sparkRecurrence + 1f)) % sparkRecurrence;`
	# `float or = rand.range(2f);`
	# `Tmp.v1.set(sparkRange * fin, 0).rotate(rotdeg() + rand.range(sparkSpread));`
	# ``
	# `Color result = Tmp.c1.set(spark).lerp(col, fin);`
	# `Draw.color(result.r, result.g, result.b, result.a * Lod.alpha2);`
	# `float px = Tmp.v1.x, py = Tmp.v1.y;`
	# `if(fin <= 1f) Lines.lineAngle(lx + px + or * ddx, ly + py + or * ddy, Angles.angle(px, py), Mathf.slope(fin) * sparkSize);`
	# `}`
	# `Draw.reset();`
	# `}`
	# `}`
	# `}`
	# ``
	# `if(glowRegion.found()){`
	# `Draw.z(Layer.blockAdditive);`
	# `Draw.blend(Blending.additive);`
	# `Draw.color(Tmp.c1.set(heatColor).lerp(boostHeatColor, boostWarmup), warmup * (heatColor.a * (1f - heatPulse + Mathf.absin(heatPulseScl, heatPulse))));`
	# `Draw.rect(glowRegion, x, y, rotdeg());`
	# `Draw.blend();`
	# `Draw.color();`
	# `}`
	# ``
	# `Draw.blend();`
	# `Draw.reset();`
	# `}`
	# on `public class BeamDrillBuild extends Building{`
	# (BeamDrill.java:220) inside `public class BeamDrill
	# extends Block{` (BeamDrill.java:25). Pure function:
	# returns the computed draw state (rects, laser
	# endpoints, spark lines, glow) and does NOT touch real
	# Draw / Drawf / Lines playback (the N2314/N2325 draw
	# precedent). NO driver tick line: draw() is per-frame
	# render state, not per-tick state.
	# Fields: facing / lasers / lastItem (BeamDrill.java:
	# 221-223), warmup / boostWarmup (BeamDrill.java:226),
	# laserWidth 0.65f / glowScl 3f / glowIntensity 0.2f /
	# pulseIntensity 0.07f / sparks 7 / sparkRange 10f /
	# sparkLife 27f / sparkRecurrence 4f / sparkSpread 45f /
	# sparkSize 3.5f / sparkColor "fd9e81" / glowColor white
	# / boostHeatColor sky*0.87 / heatColor (1, 0.35, 0.35,
	# 0.9) / heatPulse 0.3f / heatPulseScl 7f
	# (BeamDrill.java:28-64). Per-def: plasma-bore
	# (Blocks.java:3038-3051) uses class defaults (tier 3,
	# size 2, range 5); large-plasma-bore
	# (Blocks.java:3052-3065) overrides laserWidth 0.7f
	# (tier 5, size 3, range 6). The caller passes the
	# per-def values explicitly (the N2212/N2248
	# per-def-param precedent).
	# Semantics kept: Tile.worldx() = x * tilesize
	# (Tile.java:166-168, no +tilesize/2); rotdeg() =
	# rotation * 90; Geometry.d4(rotation) is the (d4x,
	# d4y) unit vector (Geometry.java:23-24, 47-51, read
	# with posmod); the centered branch is taken exactly
	# when the laser point sits ON the face tile
	# (|p.x-face.x| + |p.y-face.y| == 0); the two boost
	# gates differ per branch (center 0.99/0.01, beam
	# 0.99/0.001); Drawf.laser draws from the laser point
	# (lsx, lsy) to the face point (lx, ly); the spark
	# loop runs only under Lod.l2 (Lod.java: l2 default
	# true, alpha2 default 1f -- live zoom values arrive
	# as explicit params); rand.setState(i, id) seeds the
	# arc xorshift Rand directly with the two longs (no
	# murmur hash -- setState(seed0, seed1) is a direct
	# assignment, Rand.java), and each spark draws THREE
	# values in order -- random(sparkRecurrence + 1f),
	# range(2f), range(sparkSpread) -- from the one
	# shared state, so the state threads through the
	# loop; fin is fmod of a non-negative sum, matching
	# Java float %; the line is drawn only when
	# fin <= 1f, with length Mathf.slope(fin) * sparkSize
	# (slope is the triangle 0 at 0, 1 at 0.5, 0 at 1:
	# 2f below 0.5, 2(1-f) above -- no slice owns slope
	# yet, so it is computed inline here and NOT
	# registered as a math slice); Angles.angle(px, py)
	# is atan2 normalized to [0, 360) (the port's
	# source_vec2_angle); Tmp.c1/c3/v1 are scratch only.
	# absin goes through the port helper
	# SourceMathState.source_absin with the original scl
	# (the MendProjector / RepairTower draw precedent):
	# the arc formula (N485: (sin(in, scl*2f, mag) +
	# mag) / 2f) differs from the helper by a 2x period
	# factor, and the deviation is documented here, not
	# worked around with a *2.0 -- fixing the helper
	# belongs to a math slice of its own. Time.time is
	# the explicit time_ticks param (pin in proof frame);
	# the known phase deviation is documented: the
	# per-building clock starts at 0.0 at the first tick
	# after placement while Java Time.time is global, so
	# pulse phase differs between buildings and from
	# Java -- speed and period are exact, render is
	# outside gameplay per the user boundary, and if the
	# port ever gains a global clock the driver changes
	# its time source while the pure function (time
	# already a param) does not change. Layers:
	# Layer.power - 1 = 69 (power = 70, Layer.java:57),
	# Layer.effect = 110 (Layer.java:75),
	# Layer.blockAdditive = 31 (Layer.java:36). The
	# payload early return (`if(isPayload()) return;`,
	# BeamDrill.java:281) leaves the base/top rects
	# drawn and skips lasers + glow: the pure function
	# always returns the full shape with is_payload set,
	# an empty lasers list and glow_visible false when
	# payload (the RepairTower draw visible-flag
	# precedent). A face with no drop is skipped
	# (`if(drop == null) continue;`); a missing laser
	# point leaves its face skipped -- Java would throw
	# there; the guard is documented, not a behavior
	# change for any frame updateLasers built (the N2379
	# guard precedent). The glow alpha returned is the
	# Draw.color second argument (warmup * (heatColor.a
	# * (1 - heatPulse + absin))), the lerped glow color
	# carries its own .a separately (the RepairTower
	# glow precedent).
	var rotdeg: float = float(rotation) * 90.0
	var dir_x: int = SOURCE_BEAM_DRILL_D4X[posmod(rotation, 4)]
	var dir_y: int = SOURCE_BEAM_DRILL_D4Y[posmod(rotation, 4)]
	var ddx: int = SOURCE_BEAM_DRILL_D4X[posmod(rotation + 1, 4)]
	var ddy: int = SOURCE_BEAM_DRILL_D4Y[posmod(rotation + 1, 4)]
	var base_rect: Dictionary = {"region": region, "x": x, "y": y}
	var top_rect: Dictionary = {"region": top_region, "x": x, "y": y, "rotation_deg": rotdeg}
	var laser_entries: Array = []
	var glow_col: Color = Color(heat_color).lerp(Color(boost_heat_color), boost_warmup)
	var glow_alpha: float = warmup * (Color(heat_color).a * (1.0 - heat_pulse + source_math_state.source_absin(time_ticks, heat_pulse_scl, heat_pulse)))
	var glow_visible: bool = glow_region_found and not is_payload
	var glow_rect: Variant = {"region": glow_region, "x": x, "y": y, "rotation_deg": rotdeg} if glow_visible else null
	if not is_payload:
		for i in range(size):
			var face: Variant = facing[i] if i < facing.size() else null
			if face == null:
				continue
			var face_tile: Dictionary = face
			var drop: Variant = face_tile.get("wall_drop", null)
			if drop == null:
				continue
			var point: Variant = lasers[i] if i < lasers.size() else null
			if point == null:
				continue
			var face_x: int = int(face_tile.get("x", 0))
			var face_y: int = int(face_tile.get("y", 0))
			var lx: float = float(face_x) * tilesize - (float(dir_x) / 2.0) * tilesize
			var ly: float = float(face_y) * tilesize - (float(dir_y) / 2.0) * tilesize
			var width: float = (laser_width + source_math_state.source_absin(time_ticks + float(i) * 5.0 + float(build_id % 9) * 9.0, glow_scl, pulse_intensity)) * warmup
			var mix_amount: float = source_math_state.source_absin(time_ticks + float(i) * 5.0 + float(build_id) * 9.0, glow_scl, glow_intensity)
			var centered: bool = absi(int(point.x) - face_x) + absi(int(point.y) - face_y) == 0
			var entry: Dictionary = {"index": i, "drop": drop, "lx": lx, "ly": ly, "width": width, "mix_amount": mix_amount, "z_layer": 69.0, "centered": centered}
			if centered:
				entry["center_scale"] = width
				entry["center_rect"] = {"region": laser_center, "x": lx, "y": ly, "scale": width, "alpha": 1.0 - boost_warmup} if boost_warmup < 0.99 else null
				entry["center_boost_rect"] = {"region": laser_center_boost, "x": lx, "y": ly, "scale": width, "alpha": boost_warmup} if boost_warmup > 0.01 else null
			else:
				var lsx: float = (float(point.x) - float(dir_x) / 2.0) * tilesize
				var lsy: float = (float(point.y) - float(dir_y) / 2.0) * tilesize
				entry["lsx"] = lsx
				entry["lsy"] = lsy
				entry["laser"] = {"region": laser, "end_region": laser_end, "x1": lsx, "y1": lsy, "x2": lx, "y2": ly, "width": width, "alpha": 1.0 - boost_warmup} if boost_warmup < 0.99 else null
				entry["laser_boost"] = {"region": laser_boost, "end_region": laser_end_boost, "x1": lsx, "y1": lsy, "x2": lx, "y2": ly, "width": width, "alpha": boost_warmup} if boost_warmup > 0.001 else null
			var spark_list: Array = []
			if lod_l2:
				var rand_state: Dictionary = {"seed0": i, "seed1": build_id}
				var spark_col: Color = Color(spark_color).lerp(Color(boost_heat_color), boost_warmup)
				var drop_col: Color = face_tile.get("drop_color", Color.WHITE)
				for j in range(sparks):
					var fin: float = fmod(time_ticks / spark_life + _beam_drill_rand_random_max(rand_state, spark_recurrence + 1.0), spark_recurrence)
					var or_value: float = _beam_drill_rand_range(rand_state, 2.0)
					var spread_draw: float = _beam_drill_rand_range(rand_state, spark_spread)
					var offset: Vector2 = Vector2(spark_range * fin, 0.0).rotated(deg_to_rad(rotdeg + spread_draw))
					var px: float = offset.x
					var py: float = offset.y
					var result_col: Color = spark_col.lerp(drop_col, fin)
					var line: Variant = null
					if fin <= 1.0:
						var slope_fin: float = fin * 2.0 if fin <= 0.5 else (1.0 - fin) * 2.0
						line = {"x": lx + px + or_value * float(ddx), "y": ly + py + or_value * float(ddy), "angle_deg": source_math_state.source_vec2_angle(px, py), "length": slope_fin * spark_size}
					spark_list.append({"fin": fin, "or": or_value, "px": px, "py": py, "color": result_col, "alpha": result_col.a * lod_alpha2, "line": line})
			entry["sparks"] = spark_list
			entry["spark_stroke"] = warmup
			entry["spark_z_layer"] = 110.0
			laser_entries.append(entry)
	return {"base_rect": base_rect, "top_rect": top_rect, "is_payload": is_payload, "lasers": laser_entries, "glow_visible": glow_visible, "glow_alpha": glow_alpha, "glow_color": glow_col, "glow_rect": glow_rect}

static func source_beam_drill_draw_place_state(x: int, y: int, rotation: int, valid: bool, size: int, range_value: int, tier: int, blocked_items: Variant, world_tile: Callable, get_drill_time: Callable, item_icon: Callable, offset: float, tilesize: float, icon_small: float, text_width: float) -> Dictionary:
	# BeamDrillBuild.drawPlace() (BeamDrill.java:138-197):
	# `public void drawPlace(int x, int y, int rotation, boolean valid){`
	# `Item item = null, invalidItem = null;`
	# `boolean multiple = false;`
	# `int count = 0;`
	# `for(int i = 0; i < size; i++){`
	# `nearbySide(x, y, rotation, i, Tmp.p1);`
	# `int j = 0;`
	# `Item found = null;`
	# `for(; j < range; j++){`
	# `int rx = Tmp.p1.x + Geometry.d4x(rotation)*j, ry = Tmp.p1.y + Geometry.d4y(rotation)*j;`
	# `Tile other = world.tile(rx, ry);`
	# `if(other != null && other.solid()){`
	# `Item drop = other.wallDrop();`
	# `if(drop != null){`
	# `if(drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){`
	# `found = drop;`
	# `count++;`
	# `}else{`
	# `invalidItem = drop;`
	# `}`
	# `break;`
	# `}`
	# `}`
	# `if(found != null){`
	# `if(item != found && item != null){`
	# `multiple = true;`
	# `}`
	# `item = found;`
	# `}`
	# `int len = Math.min(j, range - 1);`
	# `Drawf.dashLine(found == null ? Pal.remove : Pal.placing,`
	# `Tmp.p1.x * tilesize,`
	# `Tmp.p1.y *tilesize,`
	# `(Tmp.p1.x + Geometry.d4x(rotation)*len) * tilesize,`
	# `(Tmp.p1.y + Geometry.d4y(rotation)*len) * tilesize`
	# `);`
	# `}`
	# `if(item != null){`
	# `float width = drawPlaceText(Core.bundle.formatFloat("bar.drillspeed", 60f / getDrillTime(item) * count, 2), x, y, valid);`
	# `if(!multiple){`
	# `float dx = x * tilesize + offset - width/2f - 4f, dy = y * tilesize + offset + size * tilesize / 2f + 5, s = iconSmall / 4f;`
	# `Draw.mixcol(Color.darkGray, 1f);`
	# `Draw.rect(item.fullIcon, dx, dy - 1, s, s);`
	# `Draw.reset();`
	# `Draw.rect(item.fullIcon, dx, dy, s, s);`
	# `}`
	# `}else if(invalidItem != null){`
	# `drawPlaceText(Core.bundle.get("bar.drilltierreq"), x, y, false);`
	# `}`
	# `}`
	# on `public class BeamDrillBuild extends Building{`
	# (BeamDrill.java:220) inside `public class BeamDrill
	# extends Block{` (BeamDrill.java:25). Placement UI,
	# not per-tick state: it scans one ray per footprint
	# side (nearbySide + world.tile, the N2379 scan
	# precedent), draws one dash line per side, and shows
	# the drillspeed text plus the found item's icon (or
	# the tier-requirement text when only an unmineable
	# drop was found). The 28 distinguishing exprs are
	# the 0-hit lines re-probed at base 1047fc24 in both
	# ledgers; the 12 HIT lines are evidence/context only
	# and are NOT in EXACT_EXPRS: `boolean multiple =
	# false;` / `for(int i = 0; i < size; i++){` /
	# `Tile other = world.tile(rx, ry);` /
	# `Item drop = other.wallDrop();` / `multiple = true;`
	# (all N2379 updateFacing), `if(item != null){`
	# (N1465/N2351), the dx/dy/s line (N2351
	# DrillBuild.drawPlace, same formula),
	# `Draw.mixcol(Color.darkGray, 1f);` (N570/N2341),
	# `public void drawPlace(int x, int y, int rotation,
	# boolean valid){` (11 drawPlace slices),
	# `}else{` / `break;` / `Draw.reset();` (generic).
	# nearbySide is the N1762 callee
	# (PortGame.source_block_nearby_side_state,
	# Block.java:936), reached here through its static
	# geometry form (the N2379 updateLasers precedent),
	# NOT re-ported. world.tile arrives as the explicit
	# world_tile Callable (the N2379 param precedent):
	# world_tile.call(rx, ry) returns null or a tile
	# Dictionary {"solid", "wall_drop",
	# "wall_drop_hardness"}; item identity is by name
	# (the N2379 singleton-name precedent). getDrillTime
	# is BeamDrill's own method (BeamDrill.java:216-217,
	# `public float getDrillTime(Item item){` /
	# `return drillTime / drillMultipliers.get(item, 1f);`),
	# NOT N2344's BurstDrill.getDrillTime (different
	# class, same formula shape): it arrives as the
	# explicit get_drill_time Callable (item name ->
	# drill time), and the proof drives it with the
	# N2344 pure function applied to BeamDrill's own
	# per-def drillTime. drawPlaceText is the already-live
	# N1779/N1780 helper (PortGame
	# source_block_draw_place_text_simple_state): this
	# function returns the text as a command dict (the
	# N2351 commands precedent) instead of rendering it,
	# and the text width arrives as the explicit
	# text_width param (the N2351 width precedent --
	# the caller computes it via the N1779 helper; the
	# proof pins a fixed width and asserts dx against
	# it). The i18n keys "bar.drillspeed" /
	# "bar.drilltierreq" are kept verbatim, never
	# translated. The drillspeed text color is
	# "Pal.accent" when valid else "Pal.remove" (the
	# 4-arg drawPlaceText overload, Block.java:532); the
	# tier-req text always passes false, so "Pal.remove".
	# The icon rects follow the N2351 formula exactly:
	# dx = x * tilesize + offset - width/2 - 4, dy = y *
	# tilesize + offset + size * tilesize/2 + 5, s =
	# iconSmall/4, shadow rect at dy - 1. The dash line
	# length is len = min(j, range - 1) where j is the
	# scan step that stopped the ray (range when no
	# solid tile was found): the inner scan is a while
	# loop so j keeps Java's post-loop value (a GDScript
	# for loop would leave j at range - 1). A null tile
	# or a non-solid tile does NOT stop the ray (the
	# break sits inside `if(other.solid()){`); the first
	# solid tile stops it whether or not its drop is
	# mineable. `other.solid()` is Tile.java:457;
	# `other.wallDrop()` is Tile.java:575. Fields:
	# `public float drillTime = 200f;`
	# (BeamDrill.java:39), `public int range = 5;` (:40),
	# `public int tier = 1;` (:41), `public
	# ObjectFloatMap<Item> drillMultipliers = new
	# ObjectFloatMap<>();` (:47), `public @Nullable
	# Seq<Item> blockedItems;` (:51), `public float
	# offset = 0f;` (Block.java:217), tilesize 8
	# (Vars.java:135, `public static final int tilesize
	# = 8;`), iconSmall 24 (Vars.java:139, `iconSmall =
	# 8*3f;`). Per-def: plasma-bore drillTime 160f, tier
	# 3, size 2, range 5; large-plasma-bore drillTime
	# 100f, tier 5, size 3, range 6
	# (Blocks.java:3038-3065). NO driver tick line:
	# drawPlace is placement UI, not per-tick state (the
	# accessor precedent N2311/N2321/N2342/N2351).
	var item: Variant = null
	var invalid_item: Variant = null
	var multiple := false
	var count := 0
	var dash_lines: Array = []
	var commands: Array = []
	var ddx: int = SOURCE_BEAM_DRILL_D4X[posmod(rotation, 4)]
	var ddy: int = SOURCE_BEAM_DRILL_D4Y[posmod(rotation, 4)]
	for i in range(size):
		var side: Dictionary = source_block_plan_geometry_state.nearby_side_state(x, y, rotation, i, size, Vector2i.ZERO)
		var side_point: Dictionary = side.get("nearby_side", {})
		var px: int = int(side_point.get("x", 0))
		var py: int = int(side_point.get("y", 0))
		var j := 0
		var found: Variant = null
		while j < range_value:
			var rx: int = px + ddx * j
			var ry: int = py + ddy * j
			var other: Variant = world_tile.call(rx, ry)
			if other != null:
				var other_tile: Dictionary = other
				if bool(other_tile.get("solid", false)):
					var drop: Variant = other_tile.get("wall_drop", null)
					if drop != null:
						if float(other_tile.get("wall_drop_hardness", 0.0)) <= float(tier) and (blocked_items == null or not (drop in blocked_items)):
							found = drop
							count += 1
						else:
							invalid_item = drop
					break
			j += 1
		if found != null:
			if item != found and item != null:
				multiple = true
			item = found
		var dash_len: int = mini(j, range_value - 1)
		var dash_color: String = "Pal.remove" if found == null else "Pal.placing"
		var dash_line: Dictionary = {"color": dash_color, "x1": float(px) * tilesize, "y1": float(py) * tilesize, "x2": float(px + ddx * dash_len) * tilesize, "y2": float(py + ddy * dash_len) * tilesize}
		dash_lines.append(dash_line)
		commands.append({"action": "dash_line", "color": dash_color, "x1": dash_line["x1"], "y1": dash_line["y1"], "x2": dash_line["x2"], "y2": dash_line["y2"]})
	var drill_speed: Variant = null
	var drill_speed_text: Variant = null
	var icon_rect: Variant = null
	var icon_shadow_rect: Variant = null
	var branch := "none"
	if item != null:
		branch = "item"
		drill_speed = 60.0 / float(get_drill_time.call(item)) * float(count)
		drill_speed_text = {"key": "bar.drillspeed", "value": drill_speed, "decimals": 2}
		var text_color: String = "Pal.accent" if valid else "Pal.remove"
		commands.append({"action": "draw_place_text", "text_key": "bar.drillspeed", "value": drill_speed, "decimals": 2, "x": x, "y": y, "valid": valid, "color": text_color})
		if not multiple:
			var icon_dx: float = float(x) * tilesize + offset - text_width / 2.0 - 4.0
			var icon_dy: float = float(y) * tilesize + offset + float(size) * tilesize / 2.0 + 5.0
			var icon_s: float = icon_small / 4.0
			var icon_region: Variant = item_icon.call(item)
			icon_shadow_rect = {"region": icon_region, "x": icon_dx, "y": icon_dy - 1.0, "w": icon_s, "h": icon_s}
			icon_rect = {"region": icon_region, "x": icon_dx, "y": icon_dy, "w": icon_s, "h": icon_s}
			commands.append({"action": "mixcol", "color": "darkGray", "alpha": 1.0})
			commands.append({"action": "rect", "region": icon_region, "x": icon_dx, "y": icon_dy - 1.0, "w": icon_s, "h": icon_s})
			commands.append({"action": "reset"})
			commands.append({"action": "rect", "region": icon_region, "x": icon_dx, "y": icon_dy, "w": icon_s, "h": icon_s})
	elif invalid_item != null:
		branch = "tier_req"
		commands.append({"action": "draw_place_text", "text_key": "bar.drilltierreq", "x": x, "y": y, "valid": false, "color": "Pal.remove"})
	return {"item": item, "invalid_item": invalid_item, "multiple": multiple, "count": count, "dash_lines": dash_lines, "drill_speed": drill_speed, "drill_speed_text": drill_speed_text, "icon_rect": icon_rect, "icon_shadow_rect": icon_shadow_rect, "commands": commands, "branch": branch}

@warning_ignore("unused_parameter")
static func source_beam_drill_set_stats_state(frame: Dictionary, drill_time: float, size: int, tier: int, drill_multipliers: Dictionary, blocked_items: Variant, optional_boost_intensity: float, booster_consumer_found: bool, booster_amount: float, booster_consumes: bool, drillables_filter: Callable) -> Dictionary:
	# BeamDrill.setStats() (BeamDrill.java:119-137):
	# public void setStats(){
	# super.setStats();
	#
	# stats.add(Stat.drillTier, StatValues.drillables(drillTime, 0f, size, drillMultipliers, b ->
	# (b instanceof Floor f && f.wallOre && f.itemDrop != null && f.itemDrop.hardness <= tier && (blockedItems == null || !blockedItems.contains(f.itemDrop))) ||
	# (b instanceof StaticWall w && w.itemDrop != null && w.itemDrop.hardness <= tier && (blockedItems == null || !blockedItems.contains(w.itemDrop)))
	# ));
	#
	# stats.add(Stat.drillSpeed, 60f / drillTime * size, StatUnit.itemsSecond);
	#
	# if(optionalBoostIntensity != 1 && findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) instanceof ConsumeLiquidBase consBase){
	# stats.replace(Stat.booster,
	# StatValues.speedBoosters("{0}" + StatUnit.timesSpeed.localized(),
	# consBase.amount, optionalBoostIntensity, false, consBase::consumes)
	# );
	# }
	# }
	# on `public class BeamDrillBuild extends Building{`
	# (BeamDrill.java:220) inside `public class BeamDrill
	# extends Block{` (BeamDrill.java:25). Stat display,
	# not per-tick state: it adds the drillTier row, the
	# drillSpeed row, and (when the guard holds) replaces
	# the booster row the super added. `super.setStats();`
	# (BeamDrill.java:120) is Drill.setStats, owned by
	# N2332 at SourceBurstDrillBuildState
	# (`SourceBurstDrillBuildState.source_drill_set_stats_state`),
	# NOT this slice: the super already added its own
	# drillTier / drillSpeed rows and its own booster row
	# with the SQUARED liquidBoostIntensity
	# (`liquidBoostIntensity * liquidBoostIntensity, false,
	# consBase::consumes)`, Drill.java:188). TWO traps vs
	# Drill.setStats: (1) BeamDrill passes the PLAIN `size`
	# to drillables (BeamDrill.java:122) and multiplies the
	# drillSpeed row by the PLAIN `size`
	# (BeamDrill.java:127) -- Drill passes `size * size`
	# in both places (Drill.java:178, :181); (2) the
	# BeamDrill booster row uses the PLAIN
	# optionalBoostIntensity (BeamDrill.java:133) and
	# REPLACES the super row (`stats.replace(Stat.booster,`,
	# BeamDrill.java:130) instead of remove-then-add --
	# the BurstDrill override (N2309) removes then re-adds
	# with the plain intensity, the Drill super row uses
	# the SQUARED intensity. The drillables call passes
	# `0f` as the drillMultiplier
	# (StatValues.java:413, `public static StatValue
	# drillables(float drillTime, float drillMultiplier,
	# float size, ObjectFloatMap<Item> multipliers,
	# Boolf<Block> filter){`): with a 0f multiplier the
	# per-ore rate `60f / (Math.max(drillTime +
	# drillMultiplier * block.itemDrop.hardness,
	# drillTime) / multipliers.get(block.itemDrop, 1f)) *
	# size` (StatValues.java:428) reduces to `60f /
	# (drillTime / multipliers.get(item, 1f)) * size`.
	# The filter's per-block evaluation (the two lambda
	# legs: a wall-ore Floor, or a StaticWall, whose drop
	# is hard enough for the tier and not blocked) and
	# the displayed per-ore table (`content.blocks()`
	# iteration, StatValues.java:413-437) are display-time,
	# NOT this slice: this function pins the args setStats
	# captures (the N2332 precedent) and carries the
	# filter as the explicit drillables_filter Callable
	# (the N2379 world_tile precedent) -- the caller
	# passes a predicate over block Dictionaries
	# {"kind", "wall_ore", "item_drop", "hardness"}.
	# findConsumer (`public <T extends Consume> T
	# findConsumer(Boolf<Consume> filter){`,
	# Block.java:1104) is NOT ported here: the caller
	# passes the already-found result
	# (booster_consumer_found / booster_amount /
	# booster_consumes) -- the N1688/N1753 findConsumer
	# precedent; the search order is deferred.
	# `consBase.amount` is the per-frame liquid amount
	# (`public float amount;`,
	# ConsumeLiquidBase.java:8);
	# `consBase::consumes` is the liquid filter (`public
	# abstract boolean consumes(Liquid liquid);`,
	# ConsumeLiquidBase.java:21). The `false` strength
	# arg (BeamDrill.java:133) means the displayed speed
	# is the plain intensity, not heatCapacity-scaled
	# (StatValues.java:522). The speedBoosters unit is
	# `"{0}" + StatUnit.timesSpeed.localized()`
	# (BeamDrill.java:131): `timesSpeed = new
	# StatUnit("timesSpeed", false),`
	# (StatUnit.java:34) and localized() reads bundle key
	# "unit.timesspeed" (StatUnit.java:61-62), English
	# value "x speed" (bundle.properties:1364), so the
	# format is "{0} x speed". The drillSpeed unit is
	# StatUnit.itemsSecond (`itemsSecond = new
	# StatUnit("itemsSecond"),`, StatUnit.java:20),
	# localized "items/second"
	# (bundle.properties:1354, `unit.itemssecond =
	# items/second`). The stats are `drillTier = new
	# Stat("drillTier", StatCat.crafting),` and
	# `drillSpeed = new Stat("drillSpeed",
	# StatCat.crafting),` (Stat.java:71-72) and `booster =
	# new Stat("booster", StatCat.optional),`
	# (Stat.java:104). The booster filter flag is `public
	# boolean booster;` (Consume.java:14). Fields:
	# `public float drillTime = 200f;`
	# (BeamDrill.java:39), `public int tier = 1;` (:41),
	# `public float optionalBoostIntensity = 2.5f;`
	# (:44, the class default -- NOT 1f), `public
	# ObjectFloatMap<Item> drillMultipliers = new
	# ObjectFloatMap<>();` (:47), `public @Nullable
	# Seq<Item> blockedItems;` (:51), `public int size =
	# 1;` (Block.java:215). Per-def: plasma-bore
	# drillTime 160f, tier 3, size 2, range 5, booster
	# `consumeLiquid(Liquids.hydrogen, 0.25f /
	# 60f).boost();` (Blocks.java:3038-3050);
	# large-plasma-bore drillTime 100f, tier 5, size 3,
	# range 6, booster `consumeLiquid(Liquids.nitrogen,
	# 3f / 60f).boost();` (Blocks.java:3052-3065 -- the
	# hydrogen 0.5f/60f line has NO .boost(), only
	# nitrogen is the booster). frame carries no live
	# keys for this block-level stat read -- drillTime,
	# tier, size, drillMultipliers, blockedItems,
	# optionalBoostIntensity and the booster consumer
	# are per-def static state, not live frame keys (the
	# N2212 / N2224 per-def-param precedent); frame is
	# the canonical first param of this family file.
	# There is NO driver tick line: setStats is a
	# stat-display read, not a per-tick write (the N2224
	# / N2246 setStats lifecycle precedent).
	var drill_tier_row: Dictionary = {"drill_time": drill_time, "drill_multiplier": 0.0, "size": size, "drill_multipliers": drill_multipliers, "tier": tier, "blocked_items": blocked_items, "filter": drillables_filter}
	var drill_speed_row: Dictionary = {"value": 60.0 / drill_time * float(size), "unit": "items/second"}
	var booster_row_replaced: bool = optional_boost_intensity != 1.0 and booster_consumer_found
	var booster_row: Variant = null
	if booster_row_replaced:
		booster_row = {"format": "{0} x speed", "amount": booster_amount, "intensity": optional_boost_intensity, "strength": false, "consumes": booster_consumes}
	return {"drill_tier_row": drill_tier_row, "drill_speed_row": drill_speed_row, "booster_row_replaced": booster_row_replaced, "booster_row": booster_row}

@warning_ignore("unused_parameter")
static func source_beam_drill_can_place_on_state(frame: Dictionary, tile_x: int, tile_y: int, rotation: int, size: int, range_value: int, tier: int, blocked_items: Variant, world_tile: Callable) -> Dictionary:
	# N2391 -- BeamDrill.canPlaceOn() (BeamDrill.java:198-214):
	# `public boolean canPlaceOn(Tile tile, Team team, int rotation){`
	# `for(int i = 0; i < size; i++){`
	# `nearbySide(tile.x, tile.y, rotation, i, Tmp.p1);`
	# `for(int j = 0; j < range; j++){`
	# `Tile other = world.tile(Tmp.p1.x + Geometry.d4x(rotation)*j, Tmp.p1.y + Geometry.d4y(rotation)*j);`
	# `if(other != null && other.solid()){`
	# `Item drop = other.wallDrop();`
	# `if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){`
	# `return true;`
	# `}`
	# `break;`
	# `}`
	# `}`
	# `}`
	# `return false;`
	# `}`
	# on `public class BeamDrill extends Block{`
	# (BeamDrill.java:25). Placement predicate, not
	# per-tick state: one scan ray per footprint side
	# (nearbySide + world.tile, the N2379 scan precedent),
	# true on the first mineable wall drop, false when no
	# side finds one. The 3 distinguishing exprs are the
	# 0-hit lines re-probed at base 3b90de35 in both
	# ledgers; the HIT lines are evidence/context only
	# and are NOT in EXACT_EXPRS: `if(other != null &&
	# other.solid()){` (N2385 drawPlace),
	# `for(int i = 0; i < size; i++){` / `Item drop =
	# other.wallDrop();` / the hardness check (all N2379
	# updateFacing), `return true;` / `return false;`
	# (generic). nearbySide is the N1762 callee
	# (PortGame.source_block_nearby_side_state,
	# Block.java:936), reached here through its static
	# geometry form (the N2379 updateLasers precedent),
	# NOT re-ported. world.tile arrives as the explicit
	# world_tile Callable (the N2379 param precedent):
	# world_tile.call(rx, ry) returns null or a tile
	# Dictionary {"solid", "wall_drop",
	# "wall_drop_hardness"}; item identity is by name
	# (the N2379 singleton-name precedent). A null tile
	# or a non-solid tile does NOT stop the ray (the
	# break sits inside `if(other.solid()){`); the first
	# solid tile stops it whether or not its drop is
	# mineable. `other.solid()` is Tile.java:457;
	# `other.wallDrop()` is Tile.java:575. Fields:
	# `public int range = 5;` (BeamDrill.java:40),
	# `public int tier = 1;` (:41), `public @Nullable
	# Seq<Item> blockedItems;` (:51). Per-def:
	# plasma-bore tier 3, size 2, range 5;
	# large-plasma-bore tier 5, size 3, range 6
	# (Blocks.java:3038-3065). The `team` param is
	# unused by the Java body (only tile/rotation/size/
	# range/tier/blockedItems are read), so it is not a
	# GD param. NO driver tick line: canPlaceOn is a
	# placement predicate, not per-tick state (the
	# accessor precedent N2311/N2321/N2342/N2351).
	var ddx: int = SOURCE_BEAM_DRILL_D4X[posmod(rotation, 4)]
	var ddy: int = SOURCE_BEAM_DRILL_D4Y[posmod(rotation, 4)]
	var can_place_on := false
	for i in range(size):
		var side: Dictionary = source_block_plan_geometry_state.nearby_side_state(tile_x, tile_y, rotation, i, size, Vector2i.ZERO)
		var side_point: Dictionary = side.get("nearby_side", {})
		var px: int = int(side_point.get("x", 0))
		var py: int = int(side_point.get("y", 0))
		for j in range(range_value):
			var rx: int = px + ddx * j
			var ry: int = py + ddy * j
			var other: Variant = world_tile.call(rx, ry)
			if other != null:
				var other_tile: Dictionary = other
				if bool(other_tile.get("solid", false)):
					var drop: Variant = other_tile.get("wall_drop", null)
					if drop != null and float(other_tile.get("wall_drop_hardness", 0.0)) <= float(tier) and (blocked_items == null or not (drop in blocked_items)):
						can_place_on = true
					break
		if can_place_on:
			break
	return {"can_place_on": can_place_on}

@warning_ignore("unused_parameter")
static func source_beam_drill_set_bars_state(frame: Dictionary, super_set_bars: Variant, last_drill_speed: float, warmup: float) -> Dictionary:
	# N2391 -- BeamDrill.setBars() (BeamDrill.java:90-97):
	# `public void setBars(){`
	# `super.setBars();`
	#
	# `addBar("drillspeed", (BeamDrillBuild e) ->`
	# `new Bar(() -> Core.bundle.format("bar.drillspeed", Strings.fixed(e.lastDrillSpeed * 60, 2)), () -> Pal.ammo, () -> e.warmup));`
	# `}`
	# `super.setBars();` is Block.setBars()
	# (Block.java:696-746) -- NOT this slice: the health
	# bar (`addBar("health", entity -> new Bar(
	# "stat.health", Pal.health, entity::healthf).blink(
	# Color.white));`, Block.java:697) plus power / items /
	# liquid bars are the caller-passed super_set_bars
	# (the N2317/N2323 super-as-param precedent); this
	# slice only adds the drillspeed bar spec. The bar is
	# registered by `public <T extends Building> void
	# addBar(String name, Func<T, Bar> sup){`
	# (Block.java:667). The bundle value is
	# `bar.drillspeed = Drill Speed: {0}/s`
	# (bundle.properties:1279). The fixed text is
	# Strings.fixed truncation at 2 decimals: `public
	# static String fixed(float d, int decimalPlaces){`
	# with `return fixedBuilder(d,
	# decimalPlaces).toString();` and `public static
	# StringBuilder fixedBuilder(float d, int
	# decimalPlaces){` over `boolean negative = d < 0;`,
	# `d = Math.abs(d);`, `dec.append((int)(float)(d *
	# Math.pow(10, decimalPlaces) + 0.0001f));` and `int
	# decimalPosition = len - decimalPlaces;` (arc
	# Strings.java:729-760) -- lastDrillSpeed is
	# non-negative (BeamDrillBuild.updateTile sets
	# `lastDrillSpeed = (facingAmount * multiplier *
	# timeScale) / drillTime * efficiency;`,
	# BeamDrill.java:249), so the negative branch never
	# fires and the fixed text is the truncated rate with
	# 2 decimals. NOTE the BeamDrill rate has NO
	# timeScale factor (unlike Drill.setBars N2330,
	# `lastDrillSpeed * 60 * e.timeScale()`): BeamDrill
	# folds timeScale into lastDrillSpeed itself
	# (BeamDrill.java:249). Pal.ammo is `ammo =
	# Color.valueOf("ff8947"),` (Pal.java:64). The Bar
	# constructor is `public Bar(Prov<CharSequence> name,
	# Prov<Color> color, Floatp fraction){` with
	# `lastValue = value = Mathf.clamp(fraction.get());`
	# (Bar.java:31-33) -- the fraction is clamped
	# Bar-side; this slice returns the warmup value.
	# `lastDrillSpeed` is the BeamDrillBuild field
	# (`public float lastDrillSpeed;`,
	# BeamDrill.java:227); `warmup` is the BeamDrillBuild
	# field (`public float warmup, boostWarmup;`,
	# BeamDrill.java:226). The classes are `public class
	# BeamDrill extends Block{` (BeamDrill.java:25) and
	# `public class BeamDrillBuild extends Building{`
	# (BeamDrill.java:220). Pure function: returns the
	# drillspeed bar spec (key, text, color, fraction)
	# and does NOT touch real Bar/UI playback. frame
	# carries no live keys for this block-level bar spec
	# -- lastDrillSpeed and warmup are live build state
	# passed explicitly (the N2212 / N2224 per-def-param
	# precedent); frame is the canonical first param of
	# this family file. There is NO driver tick line:
	# setBars is a load-time bar spec, not per-tick state.
	var rate: float = last_drill_speed * 60.0
	var scaled: int = int(rate * 100.0 + 0.0001)
	var fixed_text: String = "%d.%02d" % [scaled / 100, scaled % 100]
	var bar_text: String = "Drill Speed: " + fixed_text + "/s"
	var bar_color: Color = Color("ff8947")
	return {"bar_key": "drillspeed", "bar_text": bar_text, "bar_color": bar_color, "bar_fraction": warmup}

@warning_ignore("unused_parameter")
static func source_beam_drill_draw_select_state(frame: Dictionary, last_item: Variant, draw_item_selection: Callable) -> Dictionary:
	# N2394 -- BeamDrillBuild.drawSelect() (BeamDrill.java:231-234):
	# `public void drawSelect(){`
	# `drawItemSelection(lastItem);`
	# `}`
	# on `public class BeamDrillBuild extends Building{`
	# (BeamDrill.java:220). The whole method is one line: it
	# delegates the last mined item's selection icon to
	# drawItemSelection (`public void drawItemSelection(
	# @Nullable UnlockableContent selection){`,
	# BuildingComp.java:1249, which draws the item icon at
	# the top-left of the block when the selection is not
	# null and is a no-op otherwise). drawItemSelection is
	# the BuildingComp callee -- NOT re-ported here: it
	# arrives as the explicit draw_item_selection Callable
	# (the N2377 drawer precedent: guarded with is_valid(),
	# invoked with .call(last_item)); an invalid callable
	# is reported via draw_item_selection_called false and
	# the last_item key still reads its value. `lastItem`
	# is the BeamDrillBuild field (`public @Nullable Item
	# lastItem;`, BeamDrill.java:223), set by updateTile
	# (`lastItem = drop;`, BeamDrill.java:396) and cleared
	# when the facing changes (`lastItem = null;`,
	# BeamDrill.java:376, :409); it arrives as an explicit
	# param because it is live build state, not a frame
	# key. frame carries no live keys for this selection
	# UI -- it is the canonical first param of this family
	# file. NO driver tick line: drawSelect is selection
	# UI, not per-tick state (the accessor precedent
	# N2311/N2321/N2342/N2351). This is a different method
	# from BaseTurretBuild.drawSelect() (N2393, the range
	# dash circle) and from BeamDrillBuild.drawPlace()
	# (N2385) -- no overlap.
	var draw_item_selection_called: bool = false
	if draw_item_selection.is_valid():
		draw_item_selection.call(last_item)
		draw_item_selection_called = true
	return {"draw_item_selection_called": draw_item_selection_called, "last_item": last_item}

@warning_ignore("unused_parameter")
static func source_beam_drill_draw_plan_region_state(frame: Dictionary, plan_drawx: float, plan_drawy: float, plan_rotation: int, top_region: Variant, draw_rect: Callable) -> Dictionary:
	# N2394 -- BeamDrill.drawPlanRegion() (BeamDrill.java:113-117):
	# `public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){`
	# `Draw.rect(region, plan.drawx(), plan.drawy());`
	# `Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);`
	# `}`
	# on `public class BeamDrill extends Block{`
	# (BeamDrill.java:25). The plain region rect
	# (`Draw.rect(region, plan.drawx(), plan.drawy());`)
	# is N1411 (BlockProducer.drawPlanRegion) -- NOT this
	# slice: this function draws only the top region,
	# rotated by the plan rotation (`plan.rotation * 90`,
	# rotation 0-3 in quarter turns, so 0/90/180/270
	# degrees). Draw.rect is NOT ported here: it arrives
	# as the explicit draw_rect Callable (the N2377 drawer
	# precedent: guarded with is_valid(), invoked with
	# .call(top_region, plan_drawx, plan_drawy,
	# plan_rotation * 90)); an invalid callable is
	# reported via draw_rect_called false and the
	# top_region_rotation / plan_position keys still read
	# their values. `region` / `topRegion` are the block
	# TextureRegions (`region` is the Block base region;
	# `topRegion` is `public @Load("@-top") TextureRegion
	# topRegion;`, BeamDrill.java:36 -- the icons() pair,
	# `return new TextureRegion[]{region, topRegion};`,
	# BeamDrill.java:108); only top_region
	# is a param here because only its rect is drawn by
	# this slice. `plan` arrives as its explicit draw
	# coordinates (plan_drawx / plan_drawy from
	# `plan.drawx()` / `plan.drawy()`, plan_rotation from
	# `plan.rotation`), not as a live object. frame
	# carries no live keys for this placement UI -- it is
	# the canonical first param of this family file. NO
	# driver tick line: drawPlanRegion is placement UI,
	# not per-tick state.
	var top_region_rotation: float = float(plan_rotation * 90)
	var draw_rect_called: bool = false
	if draw_rect.is_valid():
		draw_rect.call(top_region, plan_drawx, plan_drawy, top_region_rotation)
		draw_rect_called = true
	return {"draw_rect_called": draw_rect_called, "top_region_rotation": top_region_rotation, "plan_position": Vector2(plan_drawx, plan_drawy)}

@warning_ignore("unused_parameter")
static func source_beam_drill_init_state(frame: Dictionary, range_value: int, tilesize: float, update_clip_radius: Callable) -> Dictionary:
	# N2394 -- BeamDrill.init() (BeamDrill.java:81-89):
	# `public void init(){`
	# `updateClipRadius((range + 2) * tilesize);`
	# `super.init();`
	# `if(blockedItems == null && blockedItem != null){`
	# `blockedItems = Seq.with(blockedItem);`
	# `}`
	# `}`
	# on `public class BeamDrill extends Block{`
	# (BeamDrill.java:25). Only the clip-radius line is
	# this slice: the drill must keep drawing its lasers
	# past the block bounds, so init widens the clip
	# radius to (range + 2) * tilesize world units.
	# updateClipRadius is the Block callee (`public void
	# updateClipRadius(float radiusInWorldUnits){`,
	# Block.java:1006, with `clipSize = Math.max(
	# clipSize, this.size * tilesize +
	# radiusInWorldUnits * 2f);`, Block.java:1007) --
	# NOT re-ported here: it arrives as the explicit
	# update_clip_radius Callable (the N2377 drawer
	# precedent: guarded with is_valid(), invoked with
	# .call(clip_radius)); an invalid callable is
	# reported via update_clip_radius_called false and
	# the clip_radius key still reads its value.
	# `super.init();` is generic (39 hits local) -- NOT
	# this slice. The blockedItems fill
	# (`if(blockedItems == null && blockedItem != null){`
	# / `blockedItems = Seq.with(blockedItem);`) is
	# N2012/N2302 -- NOT this slice. `range` is the
	# BeamDrill field (`public int range = 5;`,
	# BeamDrill.java:40; plasma-bore 5, large-plasma-bore
	# 6, Blocks.java:3049-3065) and `tilesize` is
	# (`public static final int tilesize = 8;`,
	# Vars.java:135) -- both arrive as explicit params
	# (the N2212 per-def-param precedent). frame carries
	# no live keys for this load-time setup -- it is the
	# canonical first param of this family file. NO
	# driver tick line: init is load-time clip setup, not
	# per-tick state.
	var clip_radius: float = float(range_value + 2) * tilesize
	var update_clip_radius_called: bool = false
	if update_clip_radius.is_valid():
		update_clip_radius.call(clip_radius)
		update_clip_radius_called = true
	return {"clip_radius": clip_radius, "update_clip_radius_called": update_clip_radius_called}

@warning_ignore("unused_parameter")
static func source_beam_drill_update_tile_state(frame: Dictionary, last_item: Variant, boost_warmup: float, optional_efficiency: float, time: float, time_delta: float, facing: Array, items_total: int, item_capacity: int, dump_ready: bool, get_drill_time: Callable, items_add: Callable, produced: Callable, dump: Callable) -> Dictionary:
	# N2398 -- BeamDrillBuild.updateTile() (BeamDrill.java:237-265):
	# `public void updateTile(){`
	# `super.updateTile();`
	# `if(lasers[0] == null) updateLasers();`
	# `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 60f);`
	# `updateFacing();`
	# `float multiplier = Mathf.lerp(1f, optionalBoostIntensity, optionalEfficiency);`
	# `float drillTime = getDrillTime(lastItem);`
	# `boostWarmup = Mathf.lerpDelta(boostWarmup, optionalEfficiency, 0.1f);`
	# `lastDrillSpeed = (facingAmount * multiplier * timeScale) / drillTime * efficiency;`
	# `time += edelta() * multiplier;`
	# `if(time >= drillTime){`
	# `for(Tile tile : facing){`
	# `Item drop = tile == null ? null : tile.wallDrop();`
	# `if(items.total() < itemCapacity && drop != null){`
	# `items.add(drop, 1);`
	# `produced(drop);`
	# `}`
	# `}`
	# `time %= drillTime;`
	# `}`
	# `if(timer(timerDump, dumpTime / timeScale)){`
	# `dump();`
	# `}`
	# `}`
	# on `public class BeamDrillBuild extends Building{`
	# (BeamDrill.java:220) inside `public class BeamDrill
	# extends Block{` (BeamDrill.java:25). This slice is
	# the facing-harvest + dump half (the 10 exprs above
	# from :247-248, :253-258, :261, :264). NOT this
	# slice: `super.updateTile();` (generic, 8 hits
	# local), `if(lasers[0] == null) updateLasers();` /
	# `updateFacing();` (N2379), the warmup gate
	# (`warmup = Mathf.approachDelta(...)`, :242), `float
	# multiplier = ...` (:246), `lastDrillSpeed = ...`
	# (:249), `time += edelta() * multiplier;` (:251)
	# (all N2155), and the timer gate
	# (`if(timer(timerDump, dumpTime / timeScale)){`,
	# :263 -- N691/N2068/N2072/N2073/N2294, generic -- it
	# arrives as the dump_ready bool, the timer result
	# computed by the caller, the TractorBeam
	# timer_target_ready precedent). getDrillTime is
	# BeamDrill's own method (BeamDrill.java:216-218,
	# `public float getDrillTime(Item item){` /
	# `return drillTime / drillMultipliers.get(item,
	# 1f);`, class default `public float drillTime =
	# 200f;`, BeamDrill.java:39; plasma-bore 160f,
	# large-plasma-bore 100f, Blocks.java:3038-3065) --
	# NOT N2344's BurstDrill.getDrillTime (different
	# class, same formula shape): it arrives as the
	# explicit get_drill_time Callable (item name ->
	# drill time), the drawPlace precedent. `Mathf.
	# lerpDelta` is arc (Mathf.java:430-432, `public
	# static float lerpDelta(float fromValue, float
	# toValue, float progress){` / `return lerp(
	# fromValue, toValue, clamp(progress * Time.delta));`
	# `}`) -- the ported SourceMathState.source_lerp_
	# delta helper (from, to, progress, delta) folds it,
	# so time_delta (Time.delta) arrives as an explicit
	# param. `wallDrop()` is Tile.java:575 (the block
	# itemDrop when solid, else the wall-ore overlay
	# drop, else null) -- the facing tiles arrive as the
	# explicit facing Array of tile Dictionaries
	# {"wall_drop": ...} or null (the N2379 updateFacing
	# precedent), and wallDrop reads "wall_drop". `items.
	# total()` / `items.add(drop, 1)` are the ItemModule
	# engine API: the current total arrives as the
	# explicit items_total int, the block capacity as
	# item_capacity, and the add arrives as the explicit
	# items_add Callable (the N2377 drawer precedent:
	# guarded with is_valid(), invoked with .call(drop,
	# 1)). The capacity gate is checked against a
	# running total, not the frozen input: Java re-reads
	# items.total() after each add inside the loop, so
	# the running total grows by 1 per harvested drop
	# and a drill that fills up mid-loop stops adding.
	# `produced(drop)` is BuildingComp.java:1035-1037
	# (`public void produced(Item item){` /
	# `produced(item, 1);`) -- it arrives as the explicit
	# produced Callable (guarded, .call(drop)). `dump()`
	# is BuildingComp.java:1064-1066 (`public boolean
	# dump(){` / `return dump(null);`) -- it arrives as
	# the explicit dump Callable (guarded, .call()).
	# `time` is the BeamDrillBuild field (`public float
	# time;`, BeamDrill.java:225) shared with N2155 --
	# taken in/out, NOT re-registered: the `time +=
	# edelta() * multiplier;` advance is N2155, this
	# slice only applies the `time %= drillTime;` wrap
	# (fmod) when the harvest gate fires. `boostWarmup`
	# is the field (`public float warmup, boostWarmup;`,
	# BeamDrill.java:226) and `optionalEfficiency` is
	# the BuildingComp field (`transient float
	# optionalEfficiency;`, BuildingComp.java:87).
	# An invalid get_drill_time Callable reports
	# drill_time 0.0 and the harvest gate does not fire
	# (no cadence source); an invalid items_add /
	# produced / dump Callable is not called but the
	# harvested drops still read through (the N2377
	# drawer precedent). frame carries no live keys for
	# this tick half -- it is the canonical first param
	# of this family file. THIS is the driver-tick state
	# function: the live loop drives it with synthetic
	# frames in the proof (no live tick).
	var get_drill_time_called: bool = false
	var drill_time: float = 0.0
	if get_drill_time.is_valid():
		drill_time = float(get_drill_time.call(last_item))
		get_drill_time_called = true
	var boost_warmup_after: float = source_math_state.source_lerp_delta(boost_warmup, optional_efficiency, 0.1, time_delta)
	var time_after: float = time
	var harvested: Array = []
	var items_add_called: bool = false
	var produced_called: bool = false
	var running_total: int = items_total
	if get_drill_time_called and time >= drill_time:
		for tile in facing:
			var drop: Variant = null
			if tile != null:
				var tile_dict: Dictionary = tile
				drop = tile_dict.get("wall_drop", null)
			if running_total < item_capacity and drop != null:
				if items_add.is_valid():
					items_add.call(drop, 1)
					items_add_called = true
				if produced.is_valid():
					produced.call(drop)
					produced_called = true
				harvested.append(drop)
				running_total += 1
		time_after = fmod(time, drill_time)
	var dump_called: bool = false
	if dump_ready:
		if dump.is_valid():
			dump.call()
			dump_called = true
	return {"drill_time": drill_time, "boost_warmup": boost_warmup_after, "time": time_after, "harvested": harvested, "get_drill_time_called": get_drill_time_called, "items_add_called": items_add_called, "produced_called": produced_called, "dump_called": dump_called}

@warning_ignore("unused_parameter")
static func source_beam_drill_default_constructor_state(frame: Dictionary, block_name: String, ambient_sound: Variant, block_flags: Variant) -> Dictionary:
	# N2401 -- BeamDrill(String name) (BeamDrill.java:63-80):
	# `public BeamDrill(String name){`
	# `super(name);`
	# `hasItems = true;`
	# `rotate = true;`
	# `update = true;`
	# `solid = true;`
	# `drawArrow = false;`
	# `regionRotated1 = 1;`
	# `ignoreLineRotation = true;`
	# `ambientSoundVolume = 0.05f;`
	# `ambientSound = Sounds.loopMineBeam;`
	# `envEnabled |= Env.space;`
	# `flags = EnumSet.of(BlockFlag.drill);`
	# `}`
	# on `public class BeamDrill extends Block{`
	# (BeamDrill.java:25). Only the six BeamDrill-only
	# defaults are this slice: the render flags
	# (`drawArrow = false;`, `regionRotated1 = 1;`,
	# `ignoreLineRotation = true;`) and the ambient sound
	# (`ambientSoundVolume = 0.05f;`, `ambientSound =
	# Sounds.loopMineBeam;`) plus the block flag (`flags =
	# EnumSet.of(BlockFlag.drill);`). NOT this slice:
	# `super(name);` (N2185), `hasItems = true;` /
	# `rotate = true;` / `update = true;` / `solid =
	# true;` (N2180-N2183 and friends) and `envEnabled
	# |= Env.space;` (N2185). The Block base defaults
	# the ctor overrides are `public boolean drawArrow
	# = true;` (Block.java:136), `public int
	# regionRotated1 = -1, regionRotated2 = -1;`
	# (Block.java:426), `public boolean
	# ignoreLineRotation = false;` (Block.java:130),
	# `public Sound ambientSound = Sounds.none;`
	# (Block.java:351) and `public EnumSet<BlockFlag>
	# flags = EnumSet.of();` (Block.java:251) -- while
	# `public float ambientSoundVolume = 0.05f;`
	# (Block.java:353) already equals the ctor value,
	# so the ctor line only re-asserts it. The three
	# render-flag strings also appear in the Turret
	# ctor (N2400, same strings, different class) --
	# both slices register them, but this func is
	# pinned to the BeamDrill ctor. `Sounds.loopMineBeam`
	# is the beam-mining loop sound asset ref
	# (core/assets/sounds/beams) -- it arrives as the
	# explicit ambient_sound Variant param, NOT
	# re-ported. `EnumSet.of(BlockFlag.drill)` is the
	# block-flag enum value (`drill` -- "Is a drill.",
	# BlockFlag.java) -- it arrives as the explicit
	# block_flags Variant param, NOT re-ported. This
	# is field defaults only: NOT ambient C (N2304
	# HELD -- the SoundControl updateLoops mixer), NO
	# driver tick line: the ctor is load-time block
	# definition setup, not per-tick state. frame
	# carries no live keys for this load-time setup --
	# it is the canonical first param of this family
	# file.
	var draw_arrow: bool = false
	var region_rotated_1: int = 1
	var ignore_line_rotation: bool = true
	var ambient_sound_volume: float = 0.05
	return {"name": block_name, "draw_arrow": draw_arrow, "region_rotated_1": region_rotated_1, "ignore_line_rotation": ignore_line_rotation, "ambient_sound_volume": ambient_sound_volume, "ambient_sound": ambient_sound, "flags": block_flags}
