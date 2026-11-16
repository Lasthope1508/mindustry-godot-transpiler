extends RefCounted
class_name SourceBeamDrillBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_drill_inventory_runtime_state := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")

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
# BeamDrill.java:44, `public float optionalBoostIntensity = 2.5f;`
# -- the class boost intensity; neither def overrides it
# (Blocks.java:3038-3061 only override drillTime, 160f /
# 100f), so both plasma-bore and large-plasma-bore share 2.5.
const SOURCE_BEAM_DRILL_OPTIONAL_BOOST_INTENSITY := 2.5
# BeamDrill.java:242 warmup speed `1f / 60f` and BeamDrill.java:248
# boost-warmup rate `0.1f`, the approachDelta / lerpDelta rates.
const SOURCE_BEAM_DRILL_WARMUP_SPEED := 1.0 / 60.0
const SOURCE_BEAM_DRILL_BOOST_WARMUP_RATE := 0.1
# BeamDrill.java:264 passes dumpTime / timeScale to the
# timer; dumpTime is the Block default 5 (Block.java:438,
# `public int dumpTime = 5;`, NO def overrides it anywhere
# in upstream, grep-verified).
const SOURCE_BEAM_DRILL_DUMP_TIME := 5.0

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
	# The shouldConsume gate inputs (N2202): the item store
	# (frame["items"], the Building.items ItemModule, a
	# Dictionary keyed by item name, the factory precedent
	# SourceFactoryBuildState.gd:89-101) and the facing wall-ore
	# count (frame["facing_amount"], BeamDrill.java:228,
	# `public int facingAmount;`, Java default 0). The tick
	# preserves both instead of resetting them: the production
	# advance fills items (still waiting for its own slice)
	# and the facing scan fills facing_amount since N2339
	# (source_beam_drill_facing_scan_state over the frame
	# facing_tiles, stamped each enabled tick before the
	# advance) -- the gate reads the current frame, which is
	# the previous tick's count (Java order,
	# BuildingComp.java:2274-2277).
	var stored_items: Variant = frame.get("items", {})
	frame["items"] = stored_items if stored_items is Dictionary else {}
	frame["facing_amount"] = int(frame.get("facing_amount", 0))
	return frame

static func _initial_frame() -> Dictionary:
	# The lasers origins (N2346): the frame starts with no
	# origins computed (lasers [], the Java `public Point2[]
	# lasers = new Point2[size];` slots before updateLasers
	# fills them) and lasers_last_change -2 (the N2277
	# sentinel, `public int lastChange = -2;`,
	# RegenProjector.java:110), so the first tick always
	# refreshes the origins.
	return {"items": {}, "facing_amount": 0, "liquids": {}, "lasers": [], "lasers_last_change": -2}

static func source_beam_drill_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the beam-drill frame meta key
	# ("source_beam_drill_building"). A BeamDrill sprite gets a
	# frame bound with the Java field defaults (items {},
	# facing_amount 0); the live-loop tick fills its other keys
	# every tick. Any other block, or an already-bound sprite,
	# binds nothing.
	if block == null or not _is_beam_drill_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_BEAM_DRILL_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_BEAM_DRILL_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_BEAM_DRILL_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_beam_drill_should_consume_state(frame: Dictionary, item_capacity: int) -> Dictionary:
	# BeamDrillBuild.shouldConsume (BeamDrill.java:270, `public boolean shouldConsume(){` with `return items.total() < itemCapacity && facingAmount > 0 && enabled;`, BeamDrill.java:271): the beam drill consumes only while its item store is under capacity AND at least one facing tile holds mineable wall ore AND it is enabled. BeamDrill extends Block (BeamDrill.java:25, `public class BeamDrill extends Block{`), NOT Drill, and BeamDrillBuild extends Building (BeamDrill.java:220, `public class BeamDrillBuild extends Building{`), so the gate lives on this family driver, not the drill frame. facingAmount is a plain int field (BeamDrill.java:228, `public int facingAmount;`, Java default 0), recomputed by `updateFacing();` (BeamDrill.java:375-411, called from updateTile :244 and onProximityUpdate :365): `facingAmount = 0;` then `facingAmount ++;` per mineable facing tile, where mineable is `if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){` (BeamDrill.java:391) -- for each of the size facing lasers it walks range tiles along the rotation, takes the first solid tile, and counts it when its wallDrop passes that check. The facing scan is live since N2339 (source_beam_drill_facing_scan_state over the frame facing_tiles, stamped each enabled tick before the advance); this gate reads frame["facing_amount"], which the tick recomputes after the fold -- the gate reads the previous tick's count (see below). The items total reuses the drill inventory helper (SourceDrillInventoryRuntimeState.items_total over frame["items"], the Building.items ItemModule); the production advance that fills the store (BeamDrill.java:253-261) waits for its own slice, so the gate reads the current frame. item_capacity comes from the catalog (block.properties["itemCapacity"]): 10 for plasma-bore (the Block.java:75 field default, `public int itemCapacity = 10;`) and 20 for large-plasma-bore (Blocks.java:3062, `itemCapacity = 20;`). When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The gate reads the previous tick's facingAmount -- updateConsumption runs before updateTile (BuildingComp.java:2274-2277, `updateConsumption();` then `if(enabled || !block.noUpdateDisabled){` / `updateTile();`), so the updateFacing recompute lands after the fold; correct per Java, not a bug.
	var stored_items: Variant = frame.get("items", {})
	var items: Dictionary = stored_items if stored_items is Dictionary else {}
	var items_total: int = source_drill_inventory_runtime_state.items_total(items)
	var facing_amount: int = int(frame.get("facing_amount", 0))
	var enabled: bool = bool(frame.get("enabled", true))
	return {"should_consume": items_total < item_capacity and facing_amount > 0 and enabled, "items_total": items_total, "facing_amount": facing_amount}

static func source_beam_drill_facing_scan_state(facing_tiles: Array, size: int, beam_range: int, tier: int, blocked_items: Variant) -> Dictionary:
	# The updateFacing count (BeamDrillBuild.updateFacing,
	# BeamDrill.java:375-411 -- the range is :375-411, NOT
	# :375-410 (the old driver cite, off by one: the
	# closing brace is :411) and NOT :368-411 (the old
	# DEFERRED cite: :368-373 is updateLasers):
	# `protected void updateFacing(){`
	# `lastItem = null;`
	# `boolean multiple = false;`
	# `int dx = Geometry.d4x(rotation), dy = Geometry.d4y(rotation);`
	# `facingAmount = 0;`
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
	# `lastItem = drop;`
	# `dest = other;`
	# `break;`
	# `facing[p] = dest;`
	# `if(multiple){`
	# `lastItem = null;`
	# facingAmount is a plain int field
	# (`public int facingAmount;`, BeamDrill.java:228,
	# Java default 0), recomputed by `updateFacing();`
	# (called from updateTile :244 and onProximityUpdate
	# :365): for each of the size facing lasers it walks
	# range tiles along the rotation from the laser
	# origin, takes the FIRST solid tile, and counts it
	# when its wallDrop passes the mineable check
	# (:391). The first solid tile BREAKS the ray even
	# when its drop is unmineable (the `break;` sits
	# inside `if(other.solid()){`, after the drop
	# check), while a null tile (out of the world) does
	# NOT break it (the `if(other != null){` guard
	# skips it and the walk continues) and a non-solid
	# tile does not break it either. The lasers
	# (`public Point2[] lasers = new Point2[size];`,
	# BeamDrill.java:222) are computed by updateLasers
	# (`protected void updateLasers(){`,
	# BeamDrill.java:368-373,
	# `nearbySide(tileX(), tileY(), rotation, i, lasers[i]);`)
	# from the tile position and rotation -- the port
	# has no live world, so the pure does NOT compute
	# laser origins or tile coordinates: the caller
	# supplies the facing rays as frame inputs (the
	# N2301 WallCrafter getEfficiency precedent), one
	# Array per laser in laser order (p = 0..size-1),
	# one Dict per tile in walk order (i = 0..range-1)
	# {solid, wall_drop} carrying the `other != null
	# && other.solid()` answer and the wallDrop item
	# {id, hardness} (null when the tile drops
	# nothing). A null or non-Dict tile entry is a null
	# world tile (the walk continues past it); a
	# missing or short ray contributes 0 for the
	# missing lasers / tiles, and rays past `size` and
	# tiles past `beam_range` are ignored (Java reads
	# exactly `size` lasers and `range` tiles per
	# laser). size / range / tier read from the catalog
	# per def: plasma-bore `tier = 3;` / `size = 2;` /
	# `range = 5;` (Blocks.java:3043-3045) and
	# large-plasma-bore `tier = 5;` / `size = 3;` /
	# `range = 6;` (Blocks.java:3057-3059); the class
	# defaults are `public int range = 5;` /
	# `public int tier = 1;` (BeamDrill.java:35-36)
	# and `public int size = 1;` (Block.java:215).
	# blockedItems is the Seq<Item> exemption list
	# (BeamDrill.java:40), promoted from the single
	# blockedItem (BeamDrill.java:38) by init
	# (BeamDrill.java:78-83, the Drill init
	# precedent):
	# `public @Nullable Seq<Item> blockedItems;`
	# `public @Nullable Item blockedItem;`
	# `if(blockedItems == null && blockedItem != null){`
	# `blockedItems = Seq.with(blockedItem);`
	# -- the port carries item ids (the drill
	# source_can_mine_state precedent), null when no
	# def exempts anything (neither BeamDrill def sets
	# blockedItem / blockedItems, catalog-verified).
	# This pure returns ONLY the count: lastItem
	# (`public @Nullable Item lastItem;`,
	# BeamDrill.java:223, cleared to null when multiple
	# distinct drops face the drill) and the facing
	# tiles (`public Tile[] facing = new Tile[size];`,
	# BeamDrill.java:221) are what the drop loop reads
	# (BeamDrill.java:247, 253-262), and they wait for
	# the drop-loop slice (entry 190) -- the count is
	# what the shouldConsume gate reads (BeamDrill.
	# java:271):
	# `return items.total() < itemCapacity && facingAmount > 0 && enabled;`
	# The parameter
	# is beam_range, not `range` (GDScript's range()
	# builtin -- the pure loops `range(size)` /
	# `range(beam_range)`); it is the BeamDrill.java:35
	# `range` field.
	var facing_amount := 0
	for p in range(size):
		if p >= facing_tiles.size():
			break
		var ray: Variant = facing_tiles[p]
		if not (ray is Array):
			continue
		for i in range(beam_range):
			if i >= ray.size():
				break
			var tile: Variant = ray[i]
			if tile == null or not (tile is Dictionary):
				continue
			if not bool(tile.get("solid", false)):
				continue
			var drop: Variant = tile.get("wall_drop", null)
			if drop != null and drop is Dictionary:
				var drop_id: String = str(drop.get("id", ""))
				var drop_hardness: int = int(drop.get("hardness", 0))
				if drop_hardness <= tier and (blocked_items == null or not (blocked_items is Array and blocked_items.has(drop_id))):
					facing_amount += 1
			break
	return {"facing_amount": facing_amount}

static func source_beam_drill_laser_origins_state(tile_x: int, tile_y: int, rotation: int, size: int) -> Dictionary:
	# The updateLasers origins (BeamDrillBuild.updateLasers,
	# BeamDrill.java:368-373 -- called from onProximityUpdate
	# :362-366, `public void onProximityUpdate(){` /
	# `updateLasers();` / `updateFacing();`, when the drill
	# is placed or rotated, NOT every tick, plus the lazy
	# first-tick call `if(lasers[0] == null) updateLasers();`
	# (BeamDrill.java:240)):
	# `protected void updateLasers(){`
	# `for(int i = 0; i < size; i++){`
	# `if(lasers[i] == null) lasers[i] = new Point2();`
	# `nearbySide(tileX(), tileY(), rotation, i, lasers[i]);`
	# The lasers (`public Point2[] lasers = new Point2[size];`,
	# BeamDrill.java:222) are the origins updateFacing walks
	# from (`Point2 l = lasers[p];`, BeamDrill.java:383,
	# `int rx = l.x + dx*i, ry = l.y + dy*i;`, :387).
	# nearbySide (Block.java:936-944 -- NOT :936-947, the
	# brief cite: :946-948 is getEdges):
	# `public void nearbySide(int x, int y, int rotation, int index, Point2 out){`
	# `int cornerX = x - (size-1)/2, cornerY = y - (size-1)/2, s = size;`
	# `switch(rotation){`
	# `case 0 -> out.set(cornerX + s, cornerY + index);`
	# `case 1 -> out.set(cornerX + index, cornerY + s);`
	# `case 2 -> out.set(cornerX - 1, cornerY + index);`
	# `case 3 -> out.set(cornerX + index, cornerY - 1);`
	# tileX()/tileY() are the building tile (`public int tileX(){`
	# / `return tile.x;`, BuildingComp.java:166-168;
	# `public int tileY(){` / `return tile.y;`, :172-174),
	# rotation is the placement rotation (`transient int rotation;`,
	# BuildingComp.java:69), and size is the block size
	# (`public int size = 1;`, Block.java:215; `size = 2;`
	# plasma-bore / `size = 3;` large-plasma-bore,
	# Blocks.java:3044/3058). The corner is tile - (size-1)/2
	# with JAVA integer division (truncated toward zero --
	# GDScript int/int divides the same way, so (size-1)/2
	# matches for every size >= 1): size 2 corners ON the
	# tile ((2-1)/2 = 0), size 3 one tile back ((3-1)/2 =
	# 1). The geometry is driver-local (a helper inside this
	# pure) -- nearbySide has no other caller in the port, so
	# it does NOT belong in the shared SourceBlockGeometry.gd.
	# The switch has NO default in Java: an out-of-range
	# rotation leaves `out` unchanged, and updateLasers
	# creates a fresh `new Point2()` (`public Point2(){`,
	# arc Point2.java:12, x = 0, y = 0, the field defaults)
	# when the slot is null, so a fresh laser under an
	# unmatched rotation reads (0, 0) -- the pure seeds each
	# origin at (0, 0) and only the four rotation cases move
	# it. The tick refreshes the origins only when
	# tile_changes moves (the N2277 pattern:
	# `if(lastChange != world.tileChanges){` /
	# `lastChange = world.tileChanges;`,
	# RegenProjector.java:122-125, against the sentinel
	# `public int lastChange = -2;`, RegenProjector.java:110;
	# the counter starts at `public int tileChanges = 1, floorChanges = 1;`, World.java:35).
	# The pure returns one origin per laser, size origins,
	# each {x, y} in tile coordinates, in laser order
	# (i = 0..size-1).
	var corner_x: int = tile_x - (size - 1) / 2
	var corner_y: int = tile_y - (size - 1) / 2
	var lasers: Array = []
	for i in range(size):
		var origin := {"x": 0, "y": 0}
		match rotation:
			0:
				origin = {"x": corner_x + size, "y": corner_y + i}
			1:
				origin = {"x": corner_x + i, "y": corner_y + size}
			2:
				origin = {"x": corner_x - 1, "y": corner_y + i}
			3:
				origin = {"x": corner_x + i, "y": corner_y - 1}
		lasers.append(origin)
	return {"lasers": lasers}

static func source_beam_drill_facing_tiles_fill_state(lasers: Array, world_tiles: Dictionary, size: int, beam_range: int, rotation: int) -> Dictionary:
	# The facing-tile fill (BeamDrillBuild.updateFacing,
	# BeamDrill.java:375-411 -- called from
	# onProximityUpdate :362-366 (`public void onProximityUpdate(){` /
	# `updateLasers();` / `updateFacing();`, when the drill
	# is placed or rotated) and from updateTile :244):
	# `protected void updateFacing(){`
	# `int dx = Geometry.d4x(rotation), dy = Geometry.d4y(rotation);`
	# `for(int p = 0; p < size; p++){`
	# `Point2 l = lasers[p];`
	# `for(int i = 0; i < range; i++){`
	# `int rx = l.x + dx*i, ry = l.y + dy*i;`
	# `Tile other = world.tile(rx, ry);`
	# `if(other != null){`
	# `if(other.solid()){`
	# `Item drop = other.wallDrop();`
	# `facing[p] = dest;`
	# -- for each of the size facing lasers it walks
	# range tiles along the rotation from the laser
	# origin, takes the FIRST solid tile, and counts it
	# when its wallDrop passes the mineable check
	# (BeamDrill.java:391). The direction comes from
	# Geometry.d4x/d4y (arc Geometry.java:23-24,
	# `public final static int[] d4x = {1, 0, -1, 0};`
	# `public final static int[] d4y = {0, 1, 0, -1};`,
	# indexed through `public static int d4x(int i){`
	# `return d4x[Mathf.mod(i, 4)];`
	# `public static int d4y(int i){`
	# `return d4y[Mathf.mod(i, 4)];`
	# -- rotation is normalized mod 4, so the pure uses
	# posmod). world.tile is `public Tile tile(int x, int y){`
	# (World.java:122); solid() is `public boolean solid(){`
	# (Tile.java:457) and the drop is `public @Nullable Item wallDrop(){`
	# (Tile.java:575). The lasers (`public Point2[] lasers = new Point2[size];`,
	# BeamDrill.java:222) are the N2346 origins, read
	# from frame["lasers"]; the facing tiles
	# (`public Tile[] facing = new Tile[size];`,
	# BeamDrill.java:221) are what the drop loop reads,
	# and they wait for the drop-loop slice -- this pure
	# returns the RAYS the scan reads, not the facing[]
	# dest array. The port has no live world, so the
	# caller supplies the world tiles as a frame input
	# (the N2301 WallCrafter getEfficiency precedent):
	# world_tiles is a Dict keyed "x,y" to {solid,
	# wall_drop} carrying the `other != null &&
	# other.solid()` answer and the wallDrop item {id,
	# hardness} (null when the tile drops nothing). A
	# missing key (or a null / non-Dict entry) is a null
	# world tile (the walk continues past it); the fill
	# emits the FULL ray -- one entry per tile in walk
	# order -- and the N2339 scan does the breaking (the
	# first solid tile breaks the ray, a null or
	# non-solid tile does not). A missing or short
	# lasers array gives an empty ray for the missing
	# lasers, and rays past `size` and tiles past
	# `beam_range` are ignored (Java reads exactly
	# `size` lasers and `range` tiles per laser, the
	# N2339 precedent). size / range read from the
	# catalog per def: plasma-bore `size = 2;` /
	# `range = 5;` (Blocks.java:3044-3045) and
	# large-plasma-bore `size = 3;` / `range = 6;`
	# (Blocks.java:3058-3059); the class defaults are
	# `public int range = 5;` / `public int tier = 1;`
	# (BeamDrill.java:35-36) and `public int size = 1;`
	# (Block.java:215). The parameter is beam_range,
	# not `range` (GDScript's range() builtin -- the
	# pure loops `range(size)` / `range(beam_range)`);
	# it is the BeamDrill.java:35 `range` field. The
	# tick stamps the result onto frame["facing_tiles"]
	# each enabled tick BEFORE the facing scan (Java
	# order: updateFacing inside updateTile,
	# BeamDrill.java:244, before the advance), whenever
	# world_tiles is supplied -- a tick with no
	# world_tiles keeps the previous facing_tiles (the
	# N2339 frame-input path, preserved for the N2339
	# proof, which seeds facing_tiles directly). The
	# LIVE world-tile query still waits (no live world
	# query exists in the port).
	var d4x: Array = [1, 0, -1, 0]
	var d4y: Array = [0, 1, 0, -1]
	var direction: int = posmod(rotation, 4)
	var dx: int = int(d4x[direction])
	var dy: int = int(d4y[direction])
	var facing_tiles: Array = []
	for p in range(size):
		if p >= lasers.size():
			facing_tiles.append([])
			continue
		var laser: Variant = lasers[p]
		if not (laser is Dictionary):
			facing_tiles.append([])
			continue
		var origin_x: int = int(laser.get("x", 0))
		var origin_y: int = int(laser.get("y", 0))
		var ray: Array = []
		for i in range(beam_range):
			var rx: int = origin_x + dx * i
			var ry: int = origin_y + dy * i
			var tile: Variant = world_tiles.get(str(rx) + "," + str(ry), null)
			if tile == null or not (tile is Dictionary):
				ray.append(null)
				continue
			ray.append({"solid": bool(tile.get("solid", false)), "wall_drop": tile.get("wall_drop", null)})
		facing_tiles.append(ray)
	return {"facing_tiles": facing_tiles}

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
	# Documented limits: (1) liquid rows live (N2256) -- the
	# plasma-bore consumes hydrogen 0.25f/60f as a booster
	# (`consumeLiquid(Liquids.hydrogen, 0.25f / 60f).boost();`,
	# Blocks.java:3049, no required liquid row) and the
	# large-plasma-bore consumes hydrogen 0.5f/60f REQUIRED
	# (`consumeLiquid(Liquids.hydrogen, 0.5f / 60f);`,
	# Blocks.java:3064) + nitrogen 3f/60f as a booster
	# (`consumeLiquid(Liquids.nitrogen, 3f / 60f).boost();`,
	# Blocks.java:3065), folded by the pure liquid row
	# (source_beam_drill_liquid_consumer_row_state,
	# ConsumeLiquid.efficiency, ConsumeLiquid.java:42-47) with
	# the second-pass removal (ConsumeLiquid.update,
	# ConsumeLiquid.java:37-39); the folded efficiency is the
	# min over the *modeled* consumers (power + liquid), which
	# is every consumer either def declares. Still deferred:
	# the drillMultipliers / blockedItem rows (BeamDrill.java:
	# 36-40, drill-time multipliers, not consumers) and live
	# liquid intake (no conduit/bridge delivery fills
	# frame["liquids"] yet; the rows read the store as-is).
	# (2) shouldConsume gate live (N2202)
	# -- BeamDrillBuild.shouldConsume() (BeamDrill.java:270-271,
	# `return items.total() < itemCapacity && facingAmount > 0 && enabled;`) feeds the pure gate to the machinery, so a
	# full store, no facing ore, or a disabled drill folds
	# efficiency to 0; the facing scan is live since N2339
	# (facing scan live (N2339)) and the production advance
	# that fills items waits for its own slice, so the gate
	# reads the current frame (the previous tick's count).
	# (3) Partial updateTile
	# advance (N2195) -- warmup / boostWarmup / multiplier /
	# time advance each tick (BeamDrill.java:242-251); the
	# timerDump dump is live since N2289
	# (source_beam_drill_timer_dump_state, the frame-local
	# Interval-equivalent, dumpTime 5f / timeScale,
	# BeamDrill.java:264-266, dump(null) through the shared
	# dump_item_state routing; first-fire deviation: Java
	# fires nearly at once after placement, the frame clock
	# delays the first fire by one interval, 5 ticks); the
	# facing scan is live since N2339 (facing scan live
	# (N2339): source_beam_drill_facing_scan_state counts
	# mineable facing tiles from the frame facing_tiles and
	# stamps facing_amount each enabled tick before the
	# advance); updateLasers geometry live since N2346
	# (source_beam_drill_laser_origins_state computes the
	# nearbySide laser origins and stamps frame["lasers"]
	# when tile_changes moves, the N2277 pattern, with a
	# first-tick refresh covering the lazy BeamDrill.java:240
	# call); the facing-tile fill is live since N2352
	# (facing-tile fill live since N2352:
	# source_beam_drill_facing_tiles_fill_state walks each
	# laser ray from frame["lasers"] through the frame
	# input world_tiles and stamps frame["facing_tiles"]
	# each enabled tick before the facing scan whenever
	# world_tiles is supplied; the LIVE world-tile query
	# still waits, so a live beam drill with no supplied
	# world_tiles keeps its previous facing_tiles); still
	# deferred: lastItem / facing[] + the drop
	# loop + `time %= drillTime;` reset +
	# lastDrillSpeed (BeamDrill.java:249, 253-262, needs
	# lastItem / facing / items state the tick does not
	# track), and the dump neighbour live fill + write-back
	# (the neighbour acceptItem / canDump arrays are frame
	# inputs, default [], and the dumped item is not written
	# into the neighbour frame yet). Until the reset slice
	# lands, time grows unbounded.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_beam_drill_liquid_consumer_row_state(frame: Dictionary, has_liquid_consumer: bool, liquid_id: int, amount: float, source_delta: float, time_scale: float, efficiency_scale: float, multiplier: float = 1.0) -> Dictionary:
	# ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47, `float ed = build.edelta() * build.efficiencyScale();` / `if(ed <= 0.00000001f) return 0f;` / `return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);`): the liquid consumer's efficiency is the held liquid over the per-frame demand, capped at 1. ONE pure function serves both the required row and the booster row: the efficiency formula is identical for both, and Java distinguishes them only by which consumer list they join -- the required row folds the first pass (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`), with a starved non-power row also stopping power draw (`if(cons != block.consPower && result <= 0.0000001f){`, BuildingComp.java:1972, folded by the shared machinery), while the booster row folds the optional pass (BuildingComp.java:1980-1981, `for(var cons : block.optionalConsumers){` / `optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));`), capped by minEfficiency (`optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);`, BuildingComp.java:1986) -- boost() is optional(true, true) (Consume.java:33-35, `return optional(true, true);`), so the booster never touches minEfficiency. The tick routes each catalog consumeLiquid row by its optional flag: plasma-bore hydrogen 0.25f/60f booster (`consumeLiquid(Liquids.hydrogen, 0.25f / 60f).boost();`, Blocks.java:3049) has NO required row, large-plasma-bore hydrogen 0.5f/60f REQUIRED (`consumeLiquid(Liquids.hydrogen, 0.5f / 60f);`, Blocks.java:3064) + nitrogen 3f/60f booster (`consumeLiquid(Liquids.nitrogen, 3f / 60f).boost();`, Blocks.java:3065). In the first pass efficiency is assumed 1f (BuildingComp.java:1965, `efficiency = optionalEfficiency = 1f;`), so edelta() is delta() = source_delta * time_scale (BuildingComp.java:1922-1929, `return Time.delta * timeScale;` / `return efficiency * delta();`). The multiplier defaults to 1f (Consume.java:18, `public Floatf<Building> multiplier = b -> 1f;`); no BeamDrill def sets one (Blocks.java:3049/3064-3065 are bare consumeLiquid calls, boost() only). The amount is per def and arrives from the catalog consumeLiquid row, so the driver reads no per-def constant here. The held amount comes from the shared liquid module helper (SourceLiquidModuleState.source_get_state, reused through a preload, NOT re-implemented) over the frame liquids key (the Building.liquids LiquidModule dict, default {} for a frame bound before this slice, amount 0.0 when the store has no entry for the liquid -- Java's liquids.get returns 0.0 for a liquid never added), with the Fracker guard (SourceFrackerBuildState.gd:221, `liquids.has("liquids")` + bounds check). A block with no liquid consumer contributes no row. The second pass removes the consumed liquid for BOTH rows (ConsumeLiquid.update, ConsumeLiquid.java:37-39, `build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));`, only when `if(update && efficiency > 0){`, BuildingComp.java:1999) -- both rows have update=true (Consume.java:16, `public boolean update = true;`), so both are second-pass consumers; the tick does that after the fold, with edelta from the folded efficiency.
	if not has_liquid_consumer:
		return {"has_liquid_row": false, "row": {}}
	var liquids: Dictionary = frame.get("liquids", {})
	var liquid_amount := 0.0
	if liquids.has("liquids") and liquid_id >= 0 and liquid_id < int(liquids["liquids"].size()):
		liquid_amount = float(source_liquid_module_state.source_get_state(liquids, liquid_id).get("amount", 0.0))
	var ed: float = source_delta * time_scale * efficiency_scale
	if ed <= 0.00000001:
		return {"has_liquid_row": true, "row": {"result": 0.0, "is_power": false}}
	var result: float = min(liquid_amount / (amount * ed * multiplier), 1.0)
	return {"has_liquid_row": true, "row": {"result": result, "is_power": false}}

static func source_beam_drill_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float) -> Dictionary:
	# The updateTile advance, internal part
	# (BeamDrillBuild.updateTile(), BeamDrill.java:237-263):
	# `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 60f);`
	# (BeamDrill.java:242), `float multiplier = Mathf.lerp(1f, optionalBoostIntensity, optionalEfficiency);`
	# (BeamDrill.java:246), `boostWarmup = Mathf.lerpDelta(boostWarmup, optionalEfficiency, 0.1f);`
	# (BeamDrill.java:248), `time += edelta() * multiplier;`
	# (BeamDrill.java:251). The Arc formulas, not guesses:
	# approachDelta(from, to, speed) = approach(from, to,
	# Time.delta * speed) with approach = from + clamp(to -
	# from, -speed, speed), lerpDelta(from, to, progress) =
	# lerp(from, to, clamp(progress * Time.delta)) with lerp
	# = from + (to - from) * progress and clamp(value) =
	# clamp(value, 0, 1), num(b) = b ? 1 : 0
	# (Mathf.java:208-210, 402-404, 415-432). source_delta is
	# Time.delta in ticks (seconds * 60 through
	# game_source_delta, arc Time.java:26); edelta() =
	# efficiency * delta() with delta() = Time.delta *
	# timeScale (BuildingComp.java:1922-1929). efficiency and
	# optionalEfficiency default 0.0, the Java field defaults
	# (BuildingComp.java:85 `transient float efficiency;` /
	# :87 `transient float optionalEfficiency;`); warmup /
	# boostWarmup / time default 0.0, the Java build-field
	# defaults (BeamDrill.java:225-226). optionalEfficiency
	# is folded by the shared machinery before this runs
	# (apply_update_consumption_state stamps
	# frame["optional_efficiency"]; with the N2256 booster rows
	# modeled it is min(booster row, minEfficiency),
	# BuildingComp.java:1965/1986). The facing count is
	# live since N2339 (the facing scan pure, stamped
	# before this advance each enabled tick). The
	# updateLasers origins are live since N2346
	# (BeamDrill.java:368-373, stamped when tile_changes
	# moves; the :240 lazy first-tick call is covered by
	# the first-tick refresh). The facing-tile fill is
	# live since N2352 (facing-tile fill live since N2352:
	# the fill pure walks each laser ray from
	# frame["lasers"] through the frame input world_tiles,
	# stamped onto frame["facing_tiles"] before the
	# facing scan each enabled tick whenever world_tiles
	# is supplied; the LIVE world-tile query still waits).
	# Deferred, not done here: lastItem
	# (BeamDrill.java:376-411, which updateFacing
	# sets), the drop loop + `time %= drillTime;`
	# reset + lastDrillSpeed (BeamDrill.java:249,
	# 253-262); until the reset slice lands, time grows
	# unbounded. The dump timer
	# (BeamDrill.java:264-266) is live since N2289
	# (source_beam_drill_timer_dump_state, wired after this
	# advance in the tick).
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var optional_efficiency: float = float(frame.get("optional_efficiency", 0.0))
	var warmup: float = float(frame.get("warmup", 0.0))
	var boost_warmup: float = float(frame.get("boost_warmup", 0.0))
	var time: float = float(frame.get("time", 0.0))
	var target: float = 1.0 if efficiency > 0.0 else 0.0
	var step: float = source_delta * SOURCE_BEAM_DRILL_WARMUP_SPEED
	var next_warmup: float = warmup + clampf(target - warmup, -step, step)
	var multiplier: float = lerpf(1.0, SOURCE_BEAM_DRILL_OPTIONAL_BOOST_INTENSITY, optional_efficiency)
	var next_boost_warmup: float = lerpf(boost_warmup, optional_efficiency, clampf(SOURCE_BEAM_DRILL_BOOST_WARMUP_RATE * source_delta, 0.0, 1.0))
	var next_time: float = time + efficiency * source_delta * time_scale * multiplier
	return {"warmup": next_warmup, "boost_warmup": next_boost_warmup, "multiplier": multiplier, "time": next_time}

static func source_beam_drill_timer_dump_state(frame: Dictionary, source_delta: float, time_scale: float, content_item_ids: Array, neighbour_accepts_item: Array, neighbour_can_dump: Array) -> Dictionary:
	# The timerDump dump at the END of updateTile
	# (BeamDrillBuild.updateTile(), BeamDrill.java:237-267),
	# after the drop loop (:253-262):
	# `if(timer(timerDump, dumpTime / timeScale)){`
	# `dump();`
	# -- the dump runs AFTER the advance in the same tick, so
	# it sees the store the advance just filled, and the dump
	# owns the frame cdump (no offload shares it on this
	# driver). The timer id is
	# `protected final int timerDump = timers++;`
	# (Block.java:436) and the interval is
	# `public int dumpTime = 5;`
	# (Block.java:438, 5 ticks = 12 times/sec; NO def
	# overrides it anywhere in upstream, grep-verified). The
	# timer is TimerComp.timer (TimerComp.java:10-13):
	# `public boolean timer(int index, float time){`
	# `if(Float.isInfinite(time)) return false;`
	# `return timer.get(index, time);`
	# Interval.get resets times[id] = Time.time on fire (arc
	# Interval.java:20-26):
	# `boolean got = check(id, time);`
	# `if(got) times[id] = Time.time;`
	# and check compares Time.time - times[id] >= time (arc
	# Interval.java:28-30):
	# `return Time.time - times[id] >= time || Time.time < times[id];`
	# Time.time counts TICKS (arc Time.java:69-80):
	# `timeRaw += delta;`
	# The port has no global tick clock at the driver layer, so
	# the elapsed clock is frame-local (frame["timer_dump_
	# elapsed"], the N2266/N2269/N2273/N2280/N2281 precedent):
	# elapsed += source_delta unconditionally every tick the
	# advance runs -- mirroring Time.time, which grows even
	# while the gate is closed; fired = elapsed >= dumpTime /
	# time_scale; elapsed_after RESETS to 0.0 on fire (a reset,
	# not a subtraction like the Fracker accumulator); a
	# non-positive time_scale is the infinite-time branch
	# (fired false). Unlike the N2280 RepairTurret literal-20
	# timer, this Java call DOES divide by timeScale
	# (`dumpTime / timeScale`, BeamDrill.java:264), so the
	# port threshold is Java-exact at every time_scale, not
	# just 1f. The live timeScale reads from the sprite meta,
	# default 1.0:
	# `private transient float timeScale = 1f, timeScaleDuration;`
	# (BuildingComp.java:98). First-fire deviation
	# (documented): Java fires (nearly) immediately after
	# placement (the global Time.time is already large vs a
	# fresh Interval times[id] = 0); the frame-local clock
	# delays the first fire by a full interval (5 ticks). It
	# cannot be fixed without a global clock -- it waits for
	# a timer-infra slice if exact first-fire timing is ever
	# needed. dump() (BuildingComp.java:1064-1066):
	# `public boolean dump(){`
	# `return dump(null);`
	# delegates to dump(null) (BuildingComp.java:1072-1113):
	# `public boolean dump(Item todump){`
	# `if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;`
	# `int dump = this.cdump;`
	# `var allItems = content.items();`
	# `int itemSize = allItems.size;`
	# `if(todump == null){`
	# `Building other = proximity.get((i + dump) % proximity.size);`
	# `if(!items.has(ii)) continue;`
	# `Item item = (Item)itemArray[ii];`
	# `if(other.acceptItem(self(), item) && canDump(other, item)){`
	# `other.handleItem(self(), item);`
	# `items.remove(item, 1);`
	# `incrementDump(proximity.size);`
	# -- neighbours outer, content items inner: for each
	# neighbour from the cdump cursor, the first held item in
	# content order an accepting neighbour takes is handed
	# over, 1 leaves the store, and the cursor advances once
	# per neighbour checked (incrementDump,
	# BuildingComp.java:1116-1120):
	# `public void incrementDump(int prox){`
	# `if(prox != 0){`
	# `cdump = ((cdump + 1) % prox);`
	# The cursor is a Building field at its Java default:
	# `transient int cdump;`
	# (BuildingComp.java:68, 0). The beam drill has items
	# (`hasItems = true;`, BeamDrill.java:66), so the hasItems
	# guard always passes. canDump defaults to true
	# (`public boolean canDump(Building to, Item item){`,
	# BuildingComp.java:1124-1126); the neighbour arrays carry
	# the live per-neighbour answers as frame inputs. The dump
	# itself runs through the shared dump(null) port
	# (SourceBuildingItemDumpState.dump_item_state) -- NOT the
	# putItem gate game_put_item_state, which dumps one
	# SPECIFIC item and needs a game object for its increment
	# callbacks, while the timer block calls dump(). The
	# shared port reports the handled neighbour but does not
	# write the item into the neighbour frame -- the
	# write-back waits for its own slice. The timer is called
	# unconditionally in Java and dump() guards internally,
	# so a fired timer with an empty store still resets the
	# clock and dumps nothing.
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var elapsed: float = float(frame.get("timer_dump_elapsed", 0.0))
	var cursor: int = int(frame.get("cdump", 0))
	var threshold: float = INF if time_scale <= 0.0 else SOURCE_BEAM_DRILL_DUMP_TIME / time_scale
	var accumulated: float = elapsed + source_delta
	var fired: bool = accumulated >= threshold
	var elapsed_after: float = 0.0 if fired else accumulated
	var dumped := false
	if fired:
		var amounts: Array = []
		for item_id in content_item_ids:
			amounts.append(int(items.get(str(item_id), 0)))
		var result: Dictionary = source_building_item_dump_state.dump_item_state(true, source_drill_inventory_runtime_state.items_total(items), neighbour_accepts_item.size(), null, false, content_item_ids, amounts, neighbour_accepts_item, neighbour_can_dump, cursor)
		cursor = int(result.get("cdump", cursor))
		if bool(result.get("dumped", false)):
			dumped = true
			var amounts_after: Array = result.get("item_amounts_by_index", amounts)
			for j in range(content_item_ids.size()):
				if j < amounts_after.size():
					items[str(content_item_ids[j])] = int(amounts_after[j])
	return {"fired": fired, "elapsed_after": elapsed_after, "dumped": dumped, "items_after": items, "cursor_after": cursor}

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
	var liquid_id_by_name: Dictionary = source_content_registry_runtime_state.source_liquid_catalog_state(catalog).get("liquid_id_by_name", {})
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
		# The frame carries the Building.liquids LiquidModule
		# (frame["liquids"]): the live store lives on the
		# sprite meta (source_building_liquids, initialized
		# at placement), so the driver syncs the reference
		# into the frame each tick BEFORE the fold, and the
		# pure liquid row reads the held hydrogen / nitrogen
		# from it (the Fracker:361 precedent).
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# N2346: the updateLasers origins (BeamDrill.java:
		# 368-373) -- updateLasers runs in onProximityUpdate
		# (BeamDrill.java:362-366, when the drill is placed
		# or rotated), NOT every tick, so the origins
		# refresh only when tile_changes moves (the N2277
		# RegenProjector pattern: `if(lastChange != world.
		# tileChanges){` / `lastChange = world.tileChanges;`
		# / `updateTargets();`, RegenProjector.java:122-125;
		# tile_changes is the frame input, default 1,
		# `public int tileChanges = 1, floorChanges = 1;`,
		# World.java:35, and lasers_last_change starts at
		# -2, the N2277 sentinel `public int lastChange =
		# -2;`, RegenProjector.java:110, so the first tick
		# always refreshes -- covering the lazy
		# `if(lasers[0] == null) updateLasers();`,
		# BeamDrill.java:240), plus the direct :240 analog
		# (an empty lasers array refreshes even without a
		# tile_changes move). The refresh is NOT gated on
		# enabled -- onProximityUpdate fires on placement /
		# rotation regardless of enabled -- and it runs
		# BEFORE the consumption fold and the facing scan
		# (Java order: updateLasers :364 before updateFacing
		# :365 in onProximityUpdate). tileX/tileY come from
		# the sprite origin_cell (the building tile,
		# `return tile.x;` / `return tile.y;`,
		# BuildingComp.java:167/173), rotation from the
		# sprite rotation meta (SourceBlockGeometry.
		# SOURCE_BUILD_ROTATION_META_KEY, default 0, the
		# placement rotation `transient int rotation;`,
		# BuildingComp.java:69), size from the catalog per
		# def (2 plasma-bore / 3 large-plasma-bore). The
		# origins land on frame["lasers"] for the facing
		# scan's live fill to read (N2352 -- the scan
		# still reads frame["facing_tiles"], N2339
		# untouched).
		if int(frame.get("tile_changes", 1)) != int(frame.get("lasers_last_change", -2)) or (frame.get("lasers", []) as Array).is_empty():
			var laser_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
			var laser_rotation: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))
			var laser_size: int = int(block.properties.get("size", 1))
			var laser_origins: Dictionary = source_beam_drill_laser_origins_state(laser_cell.x, laser_cell.y, laser_rotation, laser_size)
			frame["lasers"] = laser_origins.get("lasers", [])
			frame["lasers_last_change"] = int(frame.get("tile_changes", 1))
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
		# no power consumer is untouched: the liquid rows (N2256)
		# fold in the same block, required into the min and
		# booster into the optional pass. BeamDrillBuild.shouldConsume
		# (BeamDrill.java:270-271) is live since N2202: the pure
		# gate (source_beam_drill_should_consume_state, fed the
		# frame's items/facing_amount/enabled and the catalog
		# itemCapacity) feeds should_consume to the machinery, so
		# a full store, no facing ore, or a disabled drill folds
		# efficiency to 0 like Java.
		# productionValid is the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_beam_drill_should_consume_state(frame, int(block.properties.get("itemCapacity", 10)))
			var should_consume: bool = bool(frame.get("enabled", true)) and bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_beam_drill_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			# N2256: the liquid rows fold in the same tick
			# (ConsumeLiquid.efficiency, ConsumeLiquid.java:
			# 42-47). Each catalog consumeLiquid row is routed
			# by its optional flag (boost() is optional(true,
			# true), Consume.java:33-35): a required row appends
			# to required_results (the min fold), a booster row
			# to optional_results (the optional pass, capped by
			# minEfficiency, BuildingComp.java:1986). Plasma-bore
			# has only the hydrogen booster row (Blocks.java:
			# 3049, no required liquid row); large-plasma-bore
			# has the required hydrogen row (Blocks.java:3064)
			# + the nitrogen booster row (Blocks.java:3065).
			# The amounts are per def, read from the catalog
			# consumeLiquid rows; the liquid ids resolve
			# through the catalog liquid_id_by_name (the
			# Fracker precedent). In the first pass efficiency
			# is assumed 1f (BuildingComp.java:1965), so the
			# rows' edelta is source_delta * time_scale.
			# liquid_rows records every folded row for the
			# second-pass removal below (both rows have
			# update=true, Consume.java:16).
			var tick_source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var tick_time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var optional_results: Array = []
			var liquid_rows: Array = []
			for row in block.properties.get("consumeLiquid", []):
				var liquid_name: String = str(row.get("liquid", ""))
				var liquid_id: int = int(liquid_id_by_name.get(liquid_name, -1))
				var liquid_amount: float = float(row.get("amount", 0.0))
				var liquid_row: Dictionary = source_beam_drill_liquid_consumer_row_state(frame, true, liquid_id, liquid_amount, tick_source_delta, tick_time_scale, float(frame.get("efficiency_scale", 1.0)))
				if bool(liquid_row.get("has_liquid_row", false)):
					if bool(row.get("optional", false)):
						optional_results.append(liquid_row.get("row", {}))
					else:
						required_results.append(liquid_row.get("row", {}))
					liquid_rows.append({"liquid_id": liquid_id, "amount": liquid_amount})
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, optional_results, [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# N2256 second pass (ConsumeLiquid.update,
			# ConsumeLiquid.java:37-39, `build.liquids.
			# remove(liquid, amount * build.edelta() *
			# multiplier.get(build));`): only when update &&
			# efficiency > 0 (BuildingComp.java:1999,
			# `if(update && efficiency > 0){`), with edelta
			# from the FOLDED efficiency (frame["efficiency"]
			# after the apply), not the assumed 1f. BOTH rows
			# are removed -- the booster row too: the second
			# pass updates every updateConsumer (BuildingComp.
			# java:1999-2000), and boosters keep update=true
			# (Consume.java:16). The multiplier is the 1f
			# default (Consume.java:18), so it drops out of
			# the removal amount. The AdjacentFactory
			# updates-array precedent
			# (SourceAdjacentFactoryBuildState.gd:382) needs
			# consumer actor objects with an update(self_state)
			# method built by reinitialize_consumers_state --
			# the beam-drill driver has no such actor
			# infrastructure, so the removal is direct here,
			# through the shared liquid module helper
			# (SourceLiquidModuleState.source_remove_state,
			# clamped at the held amount like Java's
			# LiquidModule.remove, with a fresh cache_sums
			# sized to the store, the PayloadLoader
			# precedent). frame["liquids"] is the live sprite
			# store by reference, so the removal lands on it.
			if not liquid_rows.is_empty() and bool(setup.get("update", false)) and float(frame.get("efficiency", 0.0)) > 0.0:
				var folded_edelta: float = float(frame.get("efficiency", 0.0)) * tick_source_delta * tick_time_scale
				var liquid_store: Dictionary = frame.get("liquids", {})
				if liquid_store.has("liquids"):
					var cache_sums: Array = []
					cache_sums.resize(int(liquid_store["liquids"].size()))
					cache_sums.fill(0.0)
					for liquid_row in liquid_rows:
						var removal_id: int = int(liquid_row.get("liquid_id", -1))
						if removal_id >= 0 and removal_id < int(liquid_store["liquids"].size()):
							source_liquid_module_state.source_remove_state(liquid_store, removal_id, float(liquid_row.get("amount", 0.0)) * folded_edelta, cache_sums)
		# N2195: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2275
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2277-2279; noUpdateDisabled defaults
		# false, Block.java:170, so Java runs updateTile even
		# when disabled -- in Java a disabled beam drill's
		# warmup DECAYS toward 0 (efficiency is zeroed by the
		# disabled early return, BuildingComp.java:1954-1957)
		# and time freezes (edelta() is 0). The port keeps the
		# enabled gate below as a pragmatic choice: the driver
		# skips the consumption fold when disabled, so the
		# frame efficiency goes stale and running the advance
		# on it would charge warmup/time from a stale
		# efficiency. The driver-wide disabled-early-return
		# slice (deferred in the N2195 register) removes this
		# gate for all families. super.updateTile() is an
		# empty no-op (BuildingComp.java:2010-2012), so the
		# driver owes it nothing. The source delta is
		# Time.delta in ticks: game_source_delta(game, seconds)
		# is seconds * 60 (arc Time.java:26), never raw seconds.
		# timeScale reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`).
		if bool(frame.get("enabled", true)):
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			# N2339: the updateFacing facing scan
			# (BeamDrill.java:375-411) runs BEFORE the
			# advance: Java recomputes facingAmount
			# inside updateTile (`updateFacing();`,
			# BeamDrill.java:244, between the warmup
			# approach :242 and the multiplier :246) --
			# and AFTER the consumption fold above, so
			# the shouldConsume gate reads the PREVIOUS
			# tick's facingAmount (Java order,
			# BuildingComp.java:2274-2277, updateConsumption
			# before updateTile). The facing rays are
			# frame inputs (frame["facing_tiles"],
			# default [] -- no tiles, the Java
			# no-facing-wall outcome); since N2352 the
			# fill stamps frame["facing_tiles"] from
			# frame["lasers"] + the frame input
			# world_tiles each enabled tick before the
			# scan whenever world_tiles is supplied,
			# and a tick with no world_tiles keeps the
			# previous facing_tiles (the N2339
			# frame-input path, preserved for the N2339
			# proof, which seeds facing_tiles directly).
			# size / range / tier read from
			# the catalog per def (2/5/3 plasma-bore,
			# 3/6/5 large-plasma-bore; the class
			# defaults are size 1 Block.java:215, range
			# 5 / tier 1 BeamDrill.java:35-36).
			# blockedItems resolve through the shared
			# Drill bind (SourceDrillRuntimeState.
			# source_bind_ore_items_state, the
			# BeamDrill.java:78-83 init promotion),
			# loaded with load() instead of preload()
			# -- a preload would cycle (the BurstDrill
			# precedent: SourceFactoryRuntimeState
			# preloads this file and
			# SourceDrillRuntimeState preloads
			# Factory), and guarded -- neither
			# BeamDrill def carries the keys in the
			# catalog, so the bind is skipped and the
			# scan runs unblocked. The
			# scan stamps facing_amount onto the frame;
			# a disabled drill keeps its previous count
			# (Java recomputes it -- the driver-wide
			# disabled-early-return slice removes this
			# gate for all families). The item catalog
			# is fetched once here and reused by the
			# timerDump dump below.
			var beam_size: int = int(block.properties.get("size", 1))
			var beam_range: int = int(block.properties.get("range", 5))
			var beam_tier: int = int(block.properties.get("tier", 1))
			# N2352: the facing-tile fill
			# (BeamDrill.java:375-411) walks each laser
			# ray from frame["lasers"] (the N2346
			# origins) through the frame input
			# world_tiles (a Dict keyed "x,y" to {solid,
			# wall_drop}, default {} -- no world data)
			# and stamps frame["facing_tiles"] BEFORE
			# the scan below (Java order: updateFacing
			# inside updateTile, BeamDrill.java:244,
			# before the advance). The stamp runs ONLY
			# when world_tiles is supplied (non-empty):
			# a tick with no world_tiles keeps the
			# previous facing_tiles, so the N2339
			# frame-input path -- and the N2339 proof,
			# which seeds facing_tiles directly -- is
			# preserved. Rotation comes from the sprite
			# rotation meta (the same meta the N2346
			# origins refresh reads); the LIVE
			# world-tile query still waits (no live
			# world query exists in the port).
			var world_tiles: Dictionary = frame.get("world_tiles", {})
			if not world_tiles.is_empty():
				var fill_rotation: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))
				var filled: Dictionary = source_beam_drill_facing_tiles_fill_state(frame.get("lasers", []), world_tiles, beam_size, beam_range, fill_rotation)
				frame["facing_tiles"] = filled.get("facing_tiles", [])
			var facing_tiles: Array = frame.get("facing_tiles", [])
			var item_catalog: Dictionary = source_content_registry_runtime_state.source_item_catalog_state(catalog)
			var beam_blocked_items: Variant = null
			if block.properties.has("blockedItems") and block.properties.has("blockedItem"):
				var drill_runtime_state = load("res://src/game/SourceDrillRuntimeState.gd")
				beam_blocked_items = drill_runtime_state.source_bind_ore_items_state(block, item_catalog).get("blocked_items", null)
			var scanned: Dictionary = source_beam_drill_facing_scan_state(facing_tiles, beam_size, beam_range, beam_tier, beam_blocked_items)
			frame["facing_amount"] = scanned.get("facing_amount", 0)
			var advanced: Dictionary = source_beam_drill_update_tile_advance_state(frame, source_delta, time_scale)
			frame["warmup"] = advanced["warmup"]
			frame["boost_warmup"] = advanced["boost_warmup"]
			frame["multiplier"] = advanced["multiplier"]
			frame["time"] = advanced["time"]
			# N2289: the timerDump dump (BeamDrill.java:264-266,
			# `if(timer(timerDump, dumpTime / timeScale)){ dump(); }`)
			# runs AFTER the advance in the same tick (Java order:
			# the timer check sits after the drop loop,
			# BeamDrill.java:253-262), so the dump sees the store
			# the advance just filled -- the pure function reads
			# the frame AFTER the write-back above, and persists
			# its items/cdump back the same way. The frame-local
			# clock (frame["timer_dump_elapsed"]) accumulates the
			# tick delta every tick the advance runs, and when it
			# fires the dump hands one held item to an accepting
			# neighbour through the shared dump_item_state routing;
			# the neighbour acceptItem / canDump arrays are frame
			# inputs (default [] -- no neighbours, the Java
			# proximity.size == 0 outcome) until a live proximity
			# fill lands, and the dumped item is not written into
			# the neighbour frame yet (no neighbour write-back).
			# The clock runs only while enabled (the same pragmatic
			# gate as the advance itself -- Java runs updateTile
			# even when disabled, BuildingComp.java:2276-2277); the
			# driver-wide disabled-early-return slice removes this
			# gate for all families. First-fire deviation: Java
			# fires nearly at once after placement; the frame clock
			# delays the first fire by a full interval (5 ticks).
			var content_item_ids: Array = item_catalog.get("item_names_by_id", [])
			var neighbour_accepts: Array = frame.get("dump_neighbour_accepts", [])
			var neighbour_can_dump: Array = frame.get("dump_neighbour_can_dump", [])
			var timer_dump: Dictionary = source_beam_drill_timer_dump_state(frame, source_delta, time_scale, content_item_ids, neighbour_accepts, neighbour_can_dump)
			frame["timer_dump_elapsed"] = timer_dump.get("elapsed_after", 0.0)
			frame["items"] = timer_dump.get("items_after", frame.get("items", {}))
			frame["cdump"] = timer_dump.get("cursor_after", frame.get("cdump", 0))
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
