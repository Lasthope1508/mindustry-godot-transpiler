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
const source_building_item_state := preload("res://src/game/SourceBuildingItemState.gd")
const source_placed_power_graph_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")
const source_building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

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
# BeamDrill.java:39, `public float drillTime = 200f;`
# -- the class drillTime default; the defs override it
# (160f plasma-bore / 100f large-plasma-bore,
# Blocks.java:3042/3055) through the catalog.
const SOURCE_BEAM_DRILL_DRILL_TIME_DEFAULT := 200.0
# BeamDrill.java:264 passes dumpTime / timeScale to the
# timer; dumpTime is the Block default 5 (Block.java:438,
# `public int dumpTime = 5;`, NO def overrides it anywhere
# in upstream, grep-verified).
const SOURCE_BEAM_DRILL_DUMP_TIME := 5.0
# BeamDrill.java:53-61 draw-field class defaults -- NO def
# overrides any of them (Blocks.java:3038-3071 sets only
# laserWidth 0.7f on large-plasma-bore, :3061), so they ride
# driver constants; laserWidth itself is a caller-supplied
# pure input instead (0.65f plasma-bore / 0.7f
# large-plasma-bore). heatColor.a is 0.9f (`public Color
# heatColor = new Color(1f, 0.35f, 0.35f, 0.9f);`, :60).
const SOURCE_BEAM_DRILL_GLOW_SCL := 3.0
const SOURCE_BEAM_DRILL_PULSE_INTENSITY := 0.07
const SOURCE_BEAM_DRILL_GLOW_INTENSITY := 0.2
const SOURCE_BEAM_DRILL_SPARKS := 7
const SOURCE_BEAM_DRILL_SPARK_RANGE := 10.0
const SOURCE_BEAM_DRILL_SPARK_LIFE := 27.0
const SOURCE_BEAM_DRILL_SPARK_RECURRENCE := 4.0
const SOURCE_BEAM_DRILL_SPARK_SPREAD := 45.0
const SOURCE_BEAM_DRILL_SPARK_SIZE := 3.5
const SOURCE_BEAM_DRILL_HEAT_COLOR_ALPHA := 0.9

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
	# advance fills items (live since N2477 -- the drop-loop
	# pure, tick-wired after the advance)
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
	# BeamDrillBuild.shouldConsume (BeamDrill.java:270, `public boolean shouldConsume(){` with `return items.total() < itemCapacity && facingAmount > 0 && enabled;`, BeamDrill.java:271): the beam drill consumes only while its item store is under capacity AND at least one facing tile holds mineable wall ore AND it is enabled. BeamDrill extends Block (BeamDrill.java:25, `public class BeamDrill extends Block{`), NOT Drill, and BeamDrillBuild extends Building (BeamDrill.java:220, `public class BeamDrillBuild extends Building{`), so the gate lives on this family driver, not the drill frame. facingAmount is a plain int field (BeamDrill.java:228, `public int facingAmount;`, Java default 0), recomputed by `updateFacing();` (BeamDrill.java:375-411, called from updateTile :244 and onProximityUpdate :365): `facingAmount = 0;` then `facingAmount ++;` per mineable facing tile, where mineable is `if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){` (BeamDrill.java:391) -- for each of the size facing lasers it walks range tiles along the rotation, takes the first solid tile, and counts it when its wallDrop passes that check. The facing scan is live since N2339 (source_beam_drill_facing_scan_state over the frame facing_tiles, stamped each enabled tick before the advance); this gate reads frame["facing_amount"], which the tick recomputes after the fold -- the gate reads the previous tick's count (see below). The items total reuses the drill inventory helper (SourceDrillInventoryRuntimeState.items_total over frame["items"], the Building.items ItemModule); the production advance that fills the store (BeamDrill.java:253-261) is live since N2477 (the drop-loop pure, tick-wired after the advance), so the gate reads the current frame. item_capacity comes from the catalog (block.properties["itemCapacity"]): 10 for plasma-bore (the Block.java:75 field default, `public int itemCapacity = 10;`) and 20 for large-plasma-bore (Blocks.java:3062, `itemCapacity = 20;`). When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The gate reads the previous tick's facingAmount -- updateConsumption runs before updateTile (BuildingComp.java:2274-2277, `updateConsumption();` then `if(enabled || !block.noUpdateDisabled){` / `updateTile();`), so the updateFacing recompute lands after the fold; correct per Java, not a bug.
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
	# `public int tier = 1;` (BeamDrill.java:40-41 -- NOT
	# :35-36 as this docstring used to cite; :35-36 are
	# the top/glow region lines, the N2473 :36-40 lesson)
	# and `public int size = 1;` (Block.java:215).
	# blockedItems is the Seq<Item> exemption list
	# (BeamDrill.java:51 -- NOT :40, the old cite),
	# promoted from the single
	# blockedItem (BeamDrill.java:49 -- NOT :38) by init
	# (BeamDrill.java:81-87 -- NOT :78-83, the old cite;
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
	# (BeamDrill.java:247, 253-262), and the drop-loop pure
	# (N2477) derives them by re-walking the same rays
	# -- the count is
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

static func source_beam_drill_blocked_items_state(blocked_item: Variant, blocked_items: Variant) -> Dictionary:
	# The init promotion (BeamDrill.init, BeamDrill.java:81-87):
	# `if(blockedItems == null && blockedItem != null){`
	# `blockedItems = Seq.with(blockedItem);`
	# The fields are
	# `public @Nullable Item blockedItem;`
	# (BeamDrill.java:49 -- NOT :38, the old facing-scan
	# docstring cite) and
	# `public @Nullable Seq<Item> blockedItems;`
	# (BeamDrill.java:51 -- NOT :40, the old docstring
	# cite, and NOT :36-40, the old DEFERRED cite:
	# :36-40 are the top/glow regions + drillTime +
	# range). When the def sets only the single
	# blockedItem, init wraps it into the one-element
	# list; when blockedItems is already set (even an
	# empty Seq) or blockedItem is null, init leaves
	# blockedItems untouched. The port carries item
	# ids (the N2225 precedent, Java compares Item
	# references): blocked_item is an item-name String
	# or null, blocked_items is an Array of item names
	# or null, and the result is the list AFTER init
	# (null stays null, a set list passes through
	# unchanged -- the pure never mutates its input).
	# The promoted list is what the three drill gates
	# read: the updateFacing gate
	# `if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){`
	# (BeamDrill.java:391, live since N2339 as the
	# facing-scan pure's blocked_items input), the
	# drawPlace gate (BeamDrill.java:154, in
	# `public void drawPlace(int x, int y, int rotation, boolean valid){`)
	# and the canPlaceOn gate (BeamDrill.java:205, in
	# `public boolean canPlaceOn(Tile tile, Team team, int rotation){`)
	# -- drawPlace / canPlaceOn are NOT ported (their
	# rows wait for their own slice); this pure
	# supplies the input they would read. Neither
	# BeamDrill def sets blockedItem / blockedItems
	# (Blocks.java:3038-3068, catalog-verified), so
	# both defs read null here; the thorium value in
	# the proof is the impact-drill def
	# (`blockedItem = Items.thorium;`, Blocks.java:3080,
	# a BurstDrill def) used as a caller-supplied
	# input. Pure-only (N2473): the tick keeps the
	# shared Drill bind for the scan and never calls
	# this pure -- the init transition is a def-time
	# row, not a tick row.
	if blocked_items == null and blocked_item != null:
		return {"blocked_items_after": [blocked_item]}
	return {"blocked_items_after": blocked_items}

static func source_beam_drill_drill_multiplier_state(item: Variant, drill_multipliers: Dictionary) -> Dictionary:
	# The drill-time multiplier lookup (BeamDrill.
	# getDrillTime, BeamDrill.java:216-218):
	# `public float getDrillTime(Item item){`
	# `return drillTime / drillMultipliers.get(item, 1f);`
	# The map is
	# `public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();`
	# (BeamDrill.java:47 -- NOT :36-40, the old
	# DEFERRED cite), and the lookup IS drill-time,
	# not setStats-only: updateTile calls it every
	# tick (`float drillTime = getDrillTime(lastItem);`,
	# BeamDrill.java:247) and the result drives the
	# drill speed
	# `lastDrillSpeed = (facingAmount * multiplier * timeScale) / drillTime * efficiency;`
	# (:249), the drop threshold
	# `if(time >= drillTime){`
	# (:253) and the reset
	# `time %= drillTime;`
	# (:261); drawPlace reads it too for the placement
	# speed text
	# `float width = drawPlaceText(Core.bundle.formatFloat("bar.drillspeed", 60f / getDrillTime(item) * count, 2), x, y, valid);`
	# (:183). setStats is only the OTHER use
	# (`stats.add(Stat.drillTier, StatValues.drillables(drillTime, 0f, size, drillMultipliers, b ->`,
	# :122). The default is 1f, twice over: the call
	# site passes it (`drillMultipliers.get(item, 1f)`)
	# and arc honours it
	# (`public float get(K key, float defaultValue){`,
	# ObjectFloatMap.java:286, returns defaultValue
	# when the key is absent) -- including a null item
	# (`if(key == null) return defaultValue;`, :287),
	# which is the updateTile case when lastItem is
	# null (no facing item or multiple items,
	# BeamDrill.java:376/408-410). The base drillTime
	# is `public float drillTime = 200f;` (:39) at the
	# class default, `drillTime = 160f;` for the
	# plasma-bore (Blocks.java:3042) and
	# `drillTime = 100f;` for the large-plasma-bore
	# (Blocks.java:3055) -- this pure returns ONLY the
	# multiplier; dividing the base by it is the
	# drop-loop slice's wiring (the N2195 advance
	# tracks no drillTime yet). The map is
	# caller-supplied (the N2435 precedent): a Dict
	# item-name -> float, the ObjectFloatMap by item
	# id. Neither BeamDrill def sets an entry
	# (Blocks.java:3038-3068), so both defs read the
	# default 1.0 for every item; the beryllium 2f
	# value in the proof is the BurstDrill def
	# (`drillMultipliers.put(Items.beryllium, 2f);`,
	# Blocks.java:3083/3114, impact-drill /
	# eruption-drill) used as a caller-supplied map
	# entry. Pure-only (N2473): no tick wiring.
	if item == null:
		return {"multiplier": 1.0}
	return {"multiplier": float(drill_multipliers.get(item, 1.0))}

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
	# BeamDrill.java:244, before the advance) -- every
	# enabled tick (N2366: the is_empty gate is gone;
	# the N2339 proof seeds world_tiles now, so no
	# proof seeds facing_tiles directly anymore). A
	# tick with no world_tiles fills all-null rays
	# (no solid tiles anywhere, the Java
	# no-facing-wall outcome). The LIVE world-tile
	# query still waits (no live world query exists
	# in the port).
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
	# is every consumer either def declares. The
	# drillMultipliers / blockedItem rows are live since
	# N2473 (pure-only: source_beam_drill_blocked_items_state,
	# the init promotion BeamDrill.java:84-85, +
	# source_beam_drill_drill_multiplier_state, the
	# getDrillTime lookup BeamDrill.java:216-218 -- the
	# fields are :47/:49/:51, NOT :36-40 as the old
	# DEFERRED cite said, and the lookup IS drill-time:
	# updateTile :247/:249/:253/:261, not setStats-only;
	# the drop-loop pure (N2477) wires getDrillTime
	# into the tick -- the lookup is inlined there (the
	# N2473 test pins the pure's call count, so the
	# drop loop divides by the looked-up multiplier
	# itself). Still deferred:
	# live liquid intake (no conduit/bridge delivery fills
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
	# each enabled tick before the facing scan (N2366:
	# every enabled tick, no is_empty gate -- a tick
	# with no world_tiles fills all-null rays); the
	# LIVE world-tile query still waits); the
	# drop loop + `time %= drillTime;` reset +
	# lastDrillSpeed are live since N2477
	# (BeamDrill.java:249, 253-262: the drop-loop pure
	# re-walks the facing rays for lastItem / facing[],
	# wires getDrillTime through the N2473 lookup,
	# runs the capacity-gated drop loop and resets
	# time -- the pre-N2477 note said time grows unbounded
	# until the reset slice lands; N2477 IS that reset slice,
	# so the note is closed); the dump neighbour live fill is live since N2405
	# (the fill pure fills the neighbour acceptItem /
	# canDump arrays from the live proximity before the
	# timerDump dump, the N2394 pattern -- supplied arrays
	# win); the dump neighbour write-back is live since
	# N2363 (the dumped item lands in the neighbour
	# frame through the shared helper).
	# (4) Draw rows live (N2436) -- the draw pure
	# (source_beam_drill_draw_state) models drawSelect()
	# (:231-234, the recorded drawItemSelection(lastItem)
	# call) + draw() (:275-357: base + top rects, the
	# per-laser width / mixcol absins, the centered
	# laserCenter branch vs the Drawf.laser branch with
	# the asymmetric boost gates, the Lod.l2 sparks with
	# caller-supplied rolls, the glow additive) + icons()
	# (:108-115, {region, topRegion}). Pure-only: the
	# tick never calls draw/drawSelect -- draw is called
	# by the renderer, and the renderer call site waits
	# for a renderer slice.
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
	# facing scan each enabled tick (N2366: every
	# enabled tick, no is_empty gate); the LIVE
	# world-tile query still waits).
	# The drop loop + `time %= drillTime;` reset +
	# lastDrillSpeed (BeamDrill.java:249, 253-262) are
	# NOT done here: they live in the drop-loop pure
	# (N2477), tick-wired right after this advance --
	# the advance keeps exactly its four N2195 keys
	# (a neighbour test pins the return dict), and
	# the drop pure reads the advanced time from the
	# frame. The dump timer
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

static func source_beam_drill_drop_loop_state(frame: Dictionary, time_scale: float, drill_time_base: float, drill_multipliers: Dictionary, item_capacity: int, size: int, beam_range: int, tier: int, blocked_items: Variant) -> Dictionary:
	# The drop loop + time reset + lastDrillSpeed
	# (BeamDrillBuild.updateTile(), BeamDrill.java:237-267),
	# in Java order, after the N2195 advance (:251 moves
	# time) and before the timerDump dump (:264-266):
	# `float drillTime = getDrillTime(lastItem);`
	# (BeamDrill.java:247; getDrillTime :216-218,
	# `public float getDrillTime(Item item){`
	# `return drillTime / drillMultipliers.get(item, 1f);`
	# (:217), over the map
	# `public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();`
	# (BeamDrill.java:47) with the 1f default honoured
	# by arc (`public float get(K key, float defaultValue){`,
	# ObjectFloatMap.java:286, including a null item,
	# `if(key == null) return defaultValue;`, :287 -- the
	# lastItem-null case),
	# `lastDrillSpeed = (facingAmount * multiplier * timeScale) / drillTime * efficiency;`
	# (:249),
	# `if(time >= drillTime){`
	# (:253),
	# `for(Tile tile : facing){`
	# (:254),
	# `Item drop = tile == null ? null : tile.wallDrop();`
	# (:255; `public @Nullable Item wallDrop(){`,
	# Tile.java:575),
	# `if(items.total() < itemCapacity && drop != null){`
	# (:256 -- the capacity gate sits INSIDE the loop, so
	# items.total() is re-checked PER tile: a store at
	# 9/10 takes exactly one more item),
	# `items.add(drop, 1);`
	# (:257),
	# `produced(drop);`
	# (:258; `public void produced(Item item){`,
	# BuildingComp.java:1035, the sector stats + unlock
	# -- reported here as counts per item, not written:
	# no sector stats exist in the port, the WallCrafter
	# N2398 precedent),
	# `time %= drillTime;`
	# (:261 -- a reset, not a subtraction: the loop runs
	# ONCE per tick even when time exceeds 2x drillTime).
	# The facing[] dests + lastItem come from updateFacing
	# (BeamDrill.java:375-411 -- NOT :376-411, the body
	# range: the method opens :375):
	# `public Tile[] facing = new Tile[size];`
	# (BeamDrill.java:221),
	# `public @Nullable Item lastItem;`
	# (:223), the multiple detection
	# `if(lastItem != drop && lastItem != null){`
	# / `multiple = true;` (:393-394),
	# `facing[p] = dest;` (:404), the null-out
	# `if(multiple){` / `lastItem = null;` (:408-409),
	# over the mineable gate
	# `if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){`
	# (:391). The pure re-walks the facing rays for them
	# -- the N2339 scan returns ONLY the count and has no
	# last_item / facing key to read (amending it would
	# break the N2339 test's pinned symbols), so the walk
	# is duplicated here deliberately: the first solid
	# tile breaks the ray even when unmineable, a null /
	# non-solid tile does not, rays past `size` and tiles
	# past `beam_range` are ignored (the N2339 precedent).
	# The multiplier lookup is INLINED, not called: the
	# N2473 test pins the multiplier pure's call count at
	# 1 (the definition alone), so the pure divides by
	# the looked-up multiplier itself (null item -> 1.0,
	# absent key -> 1.0 -- the same two arc rules). The
	# base drillTime is
	# `public float drillTime = 200f;`
	# (:39), `drillTime = 160f;` plasma-bore /
	# `drillTime = 100f;` large-plasma-bore
	# (Blocks.java:3042/3055); itemCapacity is
	# `public int itemCapacity = 10;`
	# (Block.java:75), `itemCapacity = 20;`
	# large-plasma-bore (Blocks.java:3062). The class
	# range / tier are :40/:41 (NOT :35-36 as the old
	# scan docstring cited -- :35-36 are the top/glow
	# region lines, the N2473 :36-40 lesson). The frame
	# carries the facing rays, the items store, the
	# ADVANCED time, facing_amount, the multiplier
	# (stamped by the advance just before this runs)
	# and the folded efficiency; lastDrillSpeed is
	# computed EVERY tick, before the threshold check.
	# last_item is the item id (the N2225 precedent,
	# Java compares Item references) or null; facing is
	# the dest tile Dict per laser or null; produced is
	# the per-item count of produced() calls.
	var facing_tiles: Array = frame.get("facing_tiles", [])
	var stored_items: Variant = frame.get("items", {})
	var items: Dictionary = stored_items if stored_items is Dictionary else {}
	var time: float = float(frame.get("time", 0.0))
	var facing_amount: int = int(frame.get("facing_amount", 0))
	var multiplier: float = float(frame.get("multiplier", 1.0))
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var facing: Array = []
	var last_item: Variant = null
	var multiple := false
	for p in range(size):
		var dest: Variant = null
		if p < facing_tiles.size():
			var ray: Variant = facing_tiles[p]
			if ray is Array:
				for i in range(beam_range):
					if i >= ray.size():
						break
					var ray_tile: Variant = ray[i]
					if ray_tile == null or not (ray_tile is Dictionary):
						continue
					if not bool(ray_tile.get("solid", false)):
						continue
					var ray_drop: Variant = ray_tile.get("wall_drop", null)
					if ray_drop != null and ray_drop is Dictionary:
						var ray_drop_id: String = str(ray_drop.get("id", ""))
						var ray_drop_hardness: int = int(ray_drop.get("hardness", 0))
						if ray_drop_hardness <= tier and (blocked_items == null or not (blocked_items is Array and blocked_items.has(ray_drop_id))):
							if last_item != null and str(last_item) != ray_drop_id:
								multiple = true
							last_item = ray_drop_id
							dest = ray_tile
					break
		facing.append(dest)
	if multiple:
		last_item = null
	var drill_multiplier: float = 1.0
	if last_item != null:
		drill_multiplier = float(drill_multipliers.get(last_item, 1.0))
	var drill_time: float = drill_time_base / drill_multiplier
	var last_drill_speed: float = (float(facing_amount) * multiplier * time_scale) / drill_time * efficiency
	var next_items: Dictionary = items.duplicate(true)
	var produced: Dictionary = {}
	if time >= drill_time:
		for face_tile in facing:
			var face_drop: Variant = null
			if face_tile != null and face_tile is Dictionary:
				face_drop = face_tile.get("wall_drop", null)
			if source_drill_inventory_runtime_state.items_total(next_items) < item_capacity and face_drop != null and face_drop is Dictionary:
				var face_drop_id: String = str(face_drop.get("id", ""))
				var added: Dictionary = source_drill_inventory_runtime_state.add_item_state(next_items, face_drop_id, 1)
				next_items = added.get("drill_items", next_items)
				produced[face_drop_id] = int(produced.get(face_drop_id, 0)) + 1
		time = fmod(time, drill_time)
	return {"last_item": last_item, "facing": facing, "drill_time": drill_time, "last_drill_speed": last_drill_speed, "time": time, "items": next_items, "produced": produced}

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
	# shared port reports the handled neighbour index + item
	# (handled_index / handled_item, -1 / null when nothing
	# dumps); since N2363 the advance exposes them as
	# dump_neighbour_index / dumped_item (-1 / "" when
	# nothing dumps) and the tick wires the shared neighbour
	# write-back helper after the advance (the handleItem
	# call, `other.handleItem(self(), item);`,
	# BuildingComp.java:1089), so the dumped item lands in
	# the neighbour frame -- the dump neighbour write-back
	# live since N2363. The two new keys are UNREGISTERED
	# API shape (the N2353 offload_neighbour_index /
	# offload_routed precedent): the schema-sync slice folds
	# them into source_beam_drill_timer_dump_state_result.
	# The timer is called
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
	var dump_neighbour_index := -1
	var dumped_item := ""
	if fired:
		var amounts: Array = []
		for item_id in content_item_ids:
			amounts.append(int(items.get(str(item_id), 0)))
		var result: Dictionary = source_building_item_dump_state.dump_item_state(true, source_drill_inventory_runtime_state.items_total(items), neighbour_accepts_item.size(), null, false, content_item_ids, amounts, neighbour_accepts_item, neighbour_can_dump, cursor)
		cursor = int(result.get("cdump", cursor))
		if bool(result.get("dumped", false)):
			dumped = true
			dump_neighbour_index = int(result.get("handled_index", -1))
			dumped_item = str(result.get("handled_item", ""))
			var amounts_after: Array = result.get("item_amounts_by_index", amounts)
			for j in range(content_item_ids.size()):
				if j < amounts_after.size():
					items[str(content_item_ids[j])] = int(amounts_after[j])
	return {"fired": fired, "elapsed_after": elapsed_after, "dumped": dumped, "items_after": items, "cursor_after": cursor, "dump_neighbour_index": dump_neighbour_index, "dumped_item": dumped_item}

static func source_beam_drill_dump_neighbour_live_fill_state(game: Object, cell: Vector2i, size: int, frame: Dictionary, item_order: Array) -> Dictionary:
	# The dump neighbour live fill (N2405, DEFERRED #240,
	# the N2394 pattern for the BeamDrill driver): the
	# N2289 timerDump dump reads the neighbour acceptItem /
	# canDump arrays as frame inputs (default [] -- no
	# neighbours, the Java proximity.size == 0 outcome), so
	# a live beam drill with no fill never dumped. This
	# fill scans the live proximity BEFORE the dump pure
	# and fills the two arrays from the live neighbour
	# frames, in ring order (index i is ring cell i, the
	# N2353 convention -- the ring comes from
	# source_block_proximity_cells_state, the sprite from
	# block_sprite_at_cell, the frame from the first
	# SOURCE_CONSUMER_FRAME_META_KEYS meta on the sprite,
	# the N2353 resolution path):
	# `Building other = proximity.get((i + dump) % proximity.size);`
	# Java builds the proximity in updateProximity
	# (BuildingComp.java:1879-1900):
	# `Point2[] nearby = Edges.getEdges(block.size);`
	# `Building other = world.build(tile.x + point.x, tile.y + point.y);`
	# The accepts/canDump arrays come from the DEFAULT
	# BuildingComp gates -- acceptItem REQUIRES consumesItem,
	# not just capacity:
	# `public boolean acceptItem(Building source, Item item){`
	# `return block.consumesItem(item) && items.get(item) < getMaximumAccepted(item);`
	# `public int getMaximumAccepted(Item item){`
	# `return block.itemCapacity;`
	# `public int itemCapacity = 10;`
	# and canDump defaults to true:
	# `public boolean canDump(Building to, Item item){`
	# and the dump routing gates on both:
	# `if(other.acceptItem(self(), item) && canDump(other, item)){`
	# The consumes read is the itemFilter:
	# `public boolean consumesItem(Item item){`
	# `return itemFilter[item.id];`
	# which the port represents as the catalog consumeItem
	# rows. The item gate answers for the FIRST held item
	# in content order -- the item the dump pure offers
	# (its accepts array is per-neighbour, not per-item, so
	# a per-item answer would misdeliver: Java tries later
	# held items against the same neighbour, and that
	# per-item routing waits for a dump-shape slice):
	# `var allItems = content.items();`
	# Per-block overrides are OUT of scope: a neighbour with
	# a modeled override is evaluated with the DEFAULT gate
	# here (the override dispatch is a follow-through note).
	# A neighbour with no frame (no sprite / unknown def /
	# conduit / no meta-key frame) reports the no-frame
	# outcome -- false / false -- the N2353/N2371 no-frame
	# precedent (a routed item to a frameless neighbour
	# drops, so the fill closes the gates and nothing routes
	# there). A conduit is no-frame because its acceptLiquid
	# is a per-block override (Conduit.java:242-244, out of
	# scope) and the DEFAULT item gate would reject it
	# anyway (a conduit consumes no item). Two ring-model
	# notes: Java updateProximity dedupes multi-cell
	# neighbours (`//using a set to prevent duplicates`,
	# BuildingComp.java:1879-1900) and keeps same-team
	# buildings only (`other.team != team` skips), while
	# the ring reports a multi-cell neighbour at each of
	# its ring cells with no team filter -- the N2353
	# ring convention this fill mirrors (a delivery to
	# either index lands in the same frame). Dedup + the
	# team filter wait for a shared ring-geometry slice.
	var ring: Array = source_block_geometry.source_block_proximity_cells_state(size, cell.x, cell.y).get("cells", [])
	var blocks_by_id: Dictionary = {}
	if game != null:
		var catalog: Variant = game.get("content_catalog")
		if catalog != null:
			for registered_block in catalog.get_many("block"):
				blocks_by_id[registered_block.id] = registered_block
	var held_variant: Variant = frame.get("items", {})
	var held_items: Dictionary = held_variant if held_variant is Dictionary else {}
	var offered_item: String = ""
	for item_id in item_order:
		if int(held_items.get(str(item_id), 0)) > 0:
			offered_item = str(item_id)
			break
	var neighbour_accepts: Array = []
	var neighbour_can_dump: Array = []
	for neighbour_cell in ring:
		var accepts_item := false
		var can_dump_item := false
		var sprite: Variant = null
		if game != null:
			sprite = game.call("block_sprite_at_cell", neighbour_cell)
		if sprite != null:
			var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
			var is_conduit: bool = sprite.has_meta(source_building_liquid_state.SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY) or source_building_liquid_state.SOURCE_NEIGHBOUR_CONDUIT_BLOCK_IDS.has(block_id)
			if not is_conduit and blocks_by_id.has(block_id):
				var neighbour_block = blocks_by_id[block_id]
				var neighbour_frame: Dictionary = {}
				var has_neighbour_frame := false
				for meta_key in source_placed_power_graph_state.SOURCE_CONSUMER_FRAME_META_KEYS:
					if not sprite.has_meta(meta_key):
						continue
					var candidate: Variant = sprite.get_meta(meta_key)
					if candidate is Dictionary:
						neighbour_frame = candidate
						has_neighbour_frame = true
						break
				if has_neighbour_frame:
					var neighbour_properties = neighbour_block.properties
					can_dump_item = true
					if not offered_item.is_empty():
						var neighbour_items: Variant = neighbour_frame.get("items", null)
						if neighbour_items is Dictionary:
							var consumes_item := false
							for row in neighbour_properties.get("consumeItem", []):
								if not (row is Dictionary):
									continue
								if str(row.get("item", "")) == offered_item:
									consumes_item = true
									break
							accepts_item = consumes_item and int((neighbour_items as Dictionary).get(offered_item, 0)) < int(neighbour_properties.get("itemCapacity", 10))
		neighbour_accepts.append(accepts_item)
		neighbour_can_dump.append(can_dump_item)
	return {"dump_neighbour_accepts": neighbour_accepts, "dump_neighbour_can_dump": neighbour_can_dump}

static func source_beam_drill_draw_state(x_value: float, y_value: float, rotation: int, size_value: int, id_value: int, warmup: float, boost_warmup: float, time_value: float, lod_l2: bool, lod_alpha2: float, is_payload: bool, facing: Array, lasers: Array, last_item: Variant, glow_found: bool, heat_color: String, boost_heat_color: String, heat_pulse: float, heat_pulse_scl: float, spark_rolls: Array, laser_width: float) -> Dictionary:
	# The draw rows (BeamDrillBuild.drawSelect(),
	# BeamDrill.java:231-234 + BeamDrillBuild.draw(),
	# BeamDrill.java:275-357), the pure draw-call dict
	# -- the port never draws for real (the N2430/N2431
	# precedent: the pure returns the draw calls as
	# data). Java draws, in order (each exact expr on
	# ONE comment line, the N2148 lesson):
	# `public void drawSelect(){`
	# `drawItemSelection(lastItem);`
	# `public void draw(){`
	# `Draw.rect(block.region, x, y);`
	# `Draw.rect(topRegion, x, y, rotdeg());`
	# `if(isPayload()) return;`
	# `var dir = Geometry.d4(rotation);`
	# `int ddx = Geometry.d4x(rotation + 1), ddy = Geometry.d4y(rotation + 1);`
	# `Tile face = facing[i];`
	# `if(face != null){`
	# `Item drop = face.wallDrop();`
	# `if(drop == null) continue;`
	# `Point2 p = lasers[i];`
	# `float lx = face.worldx() - (dir.x/2f)*tilesize, ly = face.worldy() - (dir.y/2f)*tilesize;`
	# `float width = (laserWidth + Mathf.absin(Time.time + i*5 + (id % 9)*9, glowScl, pulseIntensity)) * warmup;`
	# `Draw.z(Layer.power - 1);`
	# `Draw.mixcol(glowColor, Mathf.absin(Time.time + i*5 + id*9, glowScl, glowIntensity));`
	# `if(Math.abs(p.x - face.x) + Math.abs(p.y - face.y) == 0){`
	# `Draw.scl(width);`
	# `if(boostWarmup < 0.99f){`
	# `Draw.alpha(1f - boostWarmup);`
	# `Draw.rect(laserCenter, lx, ly);`
	# `if(boostWarmup > 0.01f){`
	# `Draw.alpha(boostWarmup);`
	# `Draw.rect(laserCenterBoost, lx, ly);`
	# `Draw.scl();`
	# `float lsx = (p.x - dir.x/2f) * tilesize, lsy = (p.y - dir.y/2f) * tilesize;`
	# `Drawf.laser(laser, laserEnd, lsx, lsy, lx, ly, width);`
	# `if(boostWarmup > 0.001f){`
	# `Drawf.laser(laserBoost, laserEndBoost, lsx, lsy, lx, ly, width);`
	# `Draw.color();`
	# `Draw.mixcol();`
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
	# `Color result = Tmp.c1.set(spark).lerp(col, fin);`
	# `Draw.color(result.r, result.g, result.b, result.a * Lod.alpha2);`
	# `float px = Tmp.v1.x, py = Tmp.v1.y;`
	# `if(fin <= 1f) Lines.lineAngle(lx + px + or * ddx, ly + py + or * ddy, Angles.angle(px, py), Mathf.slope(fin) * sparkSize);`
	# `Draw.reset();`
	# `if(glowRegion.found()){`
	# `Draw.z(Layer.blockAdditive);`
	# `Draw.blend(Blending.additive);`
	# `Draw.color(Tmp.c1.set(heatColor).lerp(boostHeatColor, boostWarmup), warmup * (heatColor.a * (1f - heatPulse + Mathf.absin(heatPulseScl, heatPulse))));`
	# `Draw.rect(glowRegion, x, y, rotdeg());`
	# `Draw.blend();`
	# The fields (BeamDrill.java:221-226, 42, 53-61):
	# `public Tile[] facing = new Tile[size];`
	# `public Point2[] lasers = new Point2[size];`
	# `public @Nullable Item lastItem;`
	# `public float warmup, boostWarmup;`
	# `public float laserWidth = 0.65f;`
	# `public Color sparkColor = Color.valueOf("fd9e81"), glowColor = Color.white;`
	# `public float glowIntensity = 0.2f, pulseIntensity = 0.07f;`
	# `public float glowScl = 3f;`
	# `public int sparks = 7;`
	# `public float sparkRange = 10f, sparkLife = 27f, sparkRecurrence = 4f, sparkSpread = 45f, sparkSize = 3.5f;`
	# `public Color boostHeatColor = Color.sky.cpy().mul(0.87f);`
	# `public Color heatColor = new Color(1f, 0.35f, 0.35f, 0.9f);`
	# `public float heatPulse = 0.3f, heatPulseScl = 7f;`
	# The regions (BeamDrill.java:27-37):
	# `public @Load(value = "@-beam", fallback = "drill-laser") TextureRegion laser;`
	# `public @Load(value = "@-beam-end", fallback = "drill-laser-end") TextureRegion laserEnd;`
	# `public @Load(value = "@-beam-center", fallback = "drill-laser-center") TextureRegion laserCenter;`
	# `public @Load(value = "@-beam-boost", fallback = "drill-laser-boost") TextureRegion laserBoost;`
	# `public @Load(value = "@-beam-boost-end", fallback = "drill-laser-boost-end") TextureRegion laserEndBoost;`
	# `public @Load(value = "@-beam-boost-center", fallback = "drill-laser-boost-center") TextureRegion laserCenterBoost;`
	# `public @Load("@-top") TextureRegion topRegion;`
	# `public @Load("@-glow") TextureRegion glowRegion;`
	# icons() (BeamDrill.java:108-115) is a REAL override:
	# `public TextureRegion[] icons(){`
	# `return new TextureRegion[]{region, topRegion};`
	# The loop bound (BeamDrill.java:285):
	# `for(int i = 0; i < size; i++){`
	# The Drawf.laser overload (Drawf.java:509-511):
	# `public static void laser(TextureRegion line, TextureRegion edge, float x, float y, float x2, float y2, float scale){`
	# The defs (Blocks.java:3038-3071):
	# `plasmaBore = new BeamDrill("plasma-bore"){{`
	# `largePlasmaBore = new BeamDrill("large-plasma-bore"){{`
	# `laserWidth = 0.7f;`
	# `size = 2;`
	# `size = 3;`
	# The BuildingComp callees (BuildingComp.java:1249-1257,
	# 582-584):
	# `public void drawItemSelection(@Nullable UnlockableContent selection){`
	# `float dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * selection.fullIcon.ratio(), h = iconSmall / 4f;`
	# `public float rotdeg(){`
	# `return rotation * 90;`
	# The Tile world coords (Tile.java:166-172) and the
	# tile size (Vars.java:135):
	# `public float worldx(){`
	# `return x * tilesize;`
	# `public float worldy(){`
	# `return y * tilesize;`
	# `public static final int tilesize = 8;`
	# The Lod flags (Lod.java:16-17):
	# `public static boolean l2 = true;`
	# `public static float alpha2 = 1f;`
	# The arc math (Mathf.java:78-80, 594-596):
	# `public static float absin(float in, float scl, float mag){`
	# `return (sin(in, scl * 2f, mag) + mag) / 2f;`
	# `public static float slope(float fin){`
	# `return 1f - Math.abs(fin - 0.5f) * 2f;`
	# The arc geometry (Geometry.java:23-24, 43-53):
	# `public static Point2 d4(int i){`
	# `public static int d4x(int i){`
	# `public static int d4y(int i){`
	# `public final static int[] d4x = {1, 0, -1, 0};`
	# `public final static int[] d4y = {0, 1, 0, -1};`
	# The arc angle + rand (Angles.java:52-54, Rand.java:190-196, 221-224):
	# `public static float angle(float x, float y){`
	# `public void setState(final long seed0, final long seed1){`
	# `public float random(float max){`
	# `return nextFloat() * max;`
	# `public float range(float amount){`
	# `return nextFloat() * amount * 2 - amount;`
	# Design notes. The base + top rects draw at the
	# default z (both rects draw before any Draw.z call,
	# so neither carries a z key, the N2431 shape). The
	# payload early return skips the lasers AND the glow,
	# but NOT the base/top rects, the select call or
	# icons(). The width absin reads (id % 9) * 9 while
	# the mixcol absin reads id * 9 -- NOT the same
	# offset. The absin calls land Java-exact through the
	# shared helper at the DOUBLED scale (the N2372/N2382
	# precedent: Java absin is (sin(in, scl*2, mag) + mag)
	# / 2 while the helper is (sin(v/scl)*0.5+0.5)*mag, so
	# the pure passes 2 * scl). Mathf.slope is the
	# triangle 1 - |fin - 0.5| * 2 (0 -> 1 -> 0), computed
	# inline -- SourceMathState has no slope helper. The
	# boost gates are asymmetric: the center boost gate
	# is > 0.01 while the laser boost gate is > 0.001.
	# Drawf.laser is RECORDED as a call + params, not
	# ported (the N2396 callee-geometry precedent), and
	# so is drawItemSelection (the pure records the call
	# with the item; the callee dx/dy/s/h geometry stays
	# in BuildingComp). NO RNG in the pure (the N2421
	# precedent): the three spark draws per spark ride
	# caller-supplied rolls in Java order -- per spark j:
	# [random(sparkRecurrence+1), range(2),
	# range(spread)] -- where each roll is the
	# ALREADY-DRAWN value (random(max) is nextFloat() *
	# max, range(amount) is nextFloat() * amount * 2 -
	# amount); `rand.setState(i, id);` is the
	# deterministic per-laser seed the rolls replace, so
	# spark_rolls is one Array per laser; a missing or
	# short roll reads 0.0. The facing input carries
	# tile_x / tile_y AND world_x / world_y per entry:
	# the centered check needs TILE coords while lx/ly
	# need WORLD coords (the brief shape carried world
	# coords only -- tile coords were added, a finding,
	# not a guess). The lasers input is the N2346 origins
	# shape ({x, y} tile coords); a missing or short
	# entry reads (0, 0), the fresh Point2 default.
	# laserWidth is a caller-supplied INPUT because
	# large-plasma-bore overrides it to 0.7f over the
	# 0.65f class default -- every other draw field takes
	# the class default (no def overrides it) and rides a
	# driver constant, except heat_pulse / heat_pulse_scl
	# / heat_color / boost_heat_color which arrive as
	# caller-supplied inputs per the brief (class
	# defaults 0.3f / 7f / heatColor / boostHeatColor).
	# icons() rides the pure as icon_regions (the
	# N2396/N2430 precedent: a zero-arg icons() pure
	# cannot register). Pure-only: the tick never calls
	# draw/drawSelect -- draw is called by the renderer,
	# and the renderer call site waits for a renderer
	# slice.
	var tile_size := 8.0
	var draw_rotation: float = float(rotation * 90)
	var d4x: Array = [1, 0, -1, 0]
	var d4y: Array = [0, 1, 0, -1]
	var direction: int = posmod(rotation, 4)
	var dir_x: int = int(d4x[direction])
	var dir_y: int = int(d4y[direction])
	var side: int = posmod(rotation + 1, 4)
	var ddx: int = int(d4x[side])
	var ddy: int = int(d4y[side])
	var base_call: Dictionary = {
		"call": "Draw.rect(block.region, x, y);",
		"region": "region",
		"x": x_value,
		"y": y_value,
	}
	var top_call: Dictionary = {
		"call": "Draw.rect(topRegion, x, y, rotdeg());",
		"region": "topRegion",
		"x": x_value,
		"y": y_value,
		"rotation": draw_rotation,
	}
	var laser_calls: Array = []
	var glow_call: Variant = null
	if not is_payload:
		for i in range(size_value):
			if i >= facing.size():
				break
			var face: Variant = facing[i]
			if face == null or not (face is Dictionary):
				continue
			var drop: Variant = face.get("drop", null)
			if drop == null or not (drop is Dictionary):
				continue
			var laser_origin: Dictionary = {"x": 0, "y": 0}
			if i < lasers.size() and lasers[i] is Dictionary:
				laser_origin = lasers[i]
			var laser_x: int = int(laser_origin.get("x", 0))
			var laser_y: int = int(laser_origin.get("y", 0))
			var face_tile_x: int = int(face.get("tile_x", 0))
			var face_tile_y: int = int(face.get("tile_y", 0))
			var face_world_x: float = float(face.get("world_x", 0.0))
			var face_world_y: float = float(face.get("world_y", 0.0))
			var lx: float = face_world_x - (float(dir_x) / 2.0) * tile_size
			var ly: float = face_world_y - (float(dir_y) / 2.0) * tile_size
			var width_absin: float = source_math_state.source_absin(time_value + float(i) * 5.0 + float(id_value % 9) * 9.0, SOURCE_BEAM_DRILL_GLOW_SCL * 2.0, SOURCE_BEAM_DRILL_PULSE_INTENSITY)
			var width: float = (laser_width + width_absin) * warmup
			var mix_amount: float = source_math_state.source_absin(time_value + float(i) * 5.0 + float(id_value) * 9.0, SOURCE_BEAM_DRILL_GLOW_SCL * 2.0, SOURCE_BEAM_DRILL_GLOW_INTENSITY)
			var centered: bool = abs(laser_x - face_tile_x) + abs(laser_y - face_tile_y) == 0
			var center_calls: Variant = null
			var branch_laser_calls: Variant = null
			if centered:
				center_calls = []
				if boost_warmup < 0.99:
					center_calls.append({
						"call": "Draw.rect(laserCenter, lx, ly);",
						"region": "laserCenter",
						"x": lx,
						"y": ly,
						"alpha": 1.0 - boost_warmup,
						"scl": width,
					})
				if boost_warmup > 0.01:
					center_calls.append({
						"call": "Draw.rect(laserCenterBoost, lx, ly);",
						"region": "laserCenterBoost",
						"x": lx,
						"y": ly,
						"alpha": boost_warmup,
						"scl": width,
					})
			else:
				var lsx: float = (float(laser_x) - float(dir_x) / 2.0) * tile_size
				var lsy: float = (float(laser_y) - float(dir_y) / 2.0) * tile_size
				branch_laser_calls = []
				if boost_warmup < 0.99:
					branch_laser_calls.append({
						"call": "Drawf.laser(laser, laserEnd, lsx, lsy, lx, ly, width);",
						"line": "laser",
						"edge": "laserEnd",
						"x1": lsx,
						"y1": lsy,
						"x2": lx,
						"y2": ly,
						"scale": width,
						"alpha": 1.0 - boost_warmup,
					})
				if boost_warmup > 0.001:
					branch_laser_calls.append({
						"call": "Drawf.laser(laserBoost, laserEndBoost, lsx, lsy, lx, ly, width);",
						"line": "laserBoost",
						"edge": "laserEndBoost",
						"x1": lsx,
						"y1": lsy,
						"x2": lx,
						"y2": ly,
						"scale": width,
						"alpha": boost_warmup,
					})
			var spark_calls: Array = []
			var spark_stroke: Variant = null
			if lod_l2:
				spark_stroke = warmup
				var rolls: Array = []
				if i < spark_rolls.size() and spark_rolls[i] is Array:
					rolls = spark_rolls[i]
				var drop_color: String = str(drop.get("color", ""))
				for j in range(SOURCE_BEAM_DRILL_SPARKS):
					var roll_random: float = float(rolls[j * 3]) if j * 3 < rolls.size() else 0.0
					var roll_or: float = float(rolls[j * 3 + 1]) if j * 3 + 1 < rolls.size() else 0.0
					var roll_spread: float = float(rolls[j * 3 + 2]) if j * 3 + 2 < rolls.size() else 0.0
					var fin: float = fmod(time_value / SOURCE_BEAM_DRILL_SPARK_LIFE + roll_random, SOURCE_BEAM_DRILL_SPARK_RECURRENCE)
					var rotated: Dictionary = source_math_state.source_angles_trns_vec(draw_rotation + roll_spread, SOURCE_BEAM_DRILL_SPARK_RANGE * fin, 0.0)
					var px: float = float(rotated.get("x", 0.0))
					var py: float = float(rotated.get("y", 0.0))
					if fin <= 1.0:
						spark_calls.append({
							"fin": fin,
							"x": lx + px + roll_or * float(ddx),
							"y": ly + py + roll_or * float(ddy),
							"angle": source_math_state.source_vec2_angle(px, py),
							"length": (1.0 - absf(fin - 0.5) * 2.0) * SOURCE_BEAM_DRILL_SPARK_SIZE,
							"color": {"from": {"from": "sparkColor", "to": "boostHeatColor", "t": boost_warmup}, "to": drop_color, "t": fin},
							"alpha_scale": lod_alpha2,
							"z": "Layer.effect",
						})
			laser_calls.append({
				"index": i,
				"centered": centered,
				"width": width,
				"mixcol": {"color": "glowColor", "amount": mix_amount},
				"lx": lx,
				"ly": ly,
				"z": "Layer.power - 1",
				"center_calls": center_calls,
				"laser_calls": branch_laser_calls,
				"spark_calls": spark_calls,
				"spark_stroke": spark_stroke,
			})
		if glow_found:
			var glow_absin: float = source_math_state.source_absin(time_value, heat_pulse_scl * 2.0, heat_pulse)
			var glow_alpha: float = warmup * (SOURCE_BEAM_DRILL_HEAT_COLOR_ALPHA * (1.0 - heat_pulse + glow_absin))
			glow_call = {
				"call": "Draw.rect(glowRegion, x, y, rotdeg());",
				"region": "glowRegion",
				"color": {"from": heat_color, "to": boost_heat_color, "t": boost_warmup},
				"alpha": glow_alpha,
				"x": x_value,
				"y": y_value,
				"rotation": draw_rotation,
				"z": "Layer.blockAdditive",
				"blend": "Blending.additive",
			}
	var select_call: Variant = null
	if last_item != null:
		select_call = {
			"call": "drawItemSelection(lastItem);",
			"item": last_item,
		}
	var icon_regions: Array = ["region", "topRegion"]
	return {
		"x": x_value,
		"y": y_value,
		"rotation": rotation,
		"size_value": size_value,
		"id_value": id_value,
		"warmup": warmup,
		"boost_warmup": boost_warmup,
		"time_value": time_value,
		"lod_l2": lod_l2,
		"lod_alpha2": lod_alpha2,
		"is_payload": is_payload,
		"glow_found": glow_found,
		"heat_color": heat_color,
		"boost_heat_color": boost_heat_color,
		"heat_pulse": heat_pulse,
		"heat_pulse_scl": heat_pulse_scl,
		"laser_width": laser_width,
		"base_call": base_call,
		"top_call": top_call,
		"laser_calls": laser_calls,
		"glow_call": glow_call,
		"select_call": select_call,
		"icon_regions": icon_regions,
		"draw_rotation": draw_rotation,
		"payload_return": is_payload,
	}

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
		# from it (the Fracker:623 precedent).
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
			# scan (N2366: every enabled tick, no
			# is_empty gate -- a tick with no
			# world_tiles fills all-null rays, the
			# Java no-facing-wall outcome; the N2339
			# proof seeds world_tiles now).
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
			# before the advance). The stamp runs EVERY
			# enabled tick (N2366: the is_empty gate is
			# gone -- it only preserved the N2339 proof,
			# which seeded facing_tiles directly, and
			# the N2339 proof seeds world_tiles now):
			# a tick with no world_tiles fills
			# all-null rays (no solid tiles anywhere,
			# the Java no-facing-wall outcome) and the
			# scan stamps facing_amount 0. Rotation
			# comes from the sprite rotation meta (the
			# same meta the N2346 origins refresh
			# reads); the LIVE world-tile query still
			# waits (no live world query exists in the
			# port).
			var world_tiles: Dictionary = frame.get("world_tiles", {})
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
			# N2477: the drop loop + time reset + lastDrillSpeed
			# (BeamDrill.java:249, 253-262) -- after the advance
			# (:251 moves time) and before the timerDump dump
			# (:264-266), the Java order inside updateTile.
			# The pure re-walks the facing rays for lastItem /
			# facing[], wires getDrillTime through the N2473
			# lookup, runs the capacity-gated drop loop and
			# resets time. drillTime reads the catalog per def
			# (160f plasma-bore / 100f large-plasma-bore,
			# Blocks.java:3042/3055) with the 200f class
			# default (BeamDrill.java:39); the multiplier map
			# is empty for both defs (neither sets an entry,
			# Blocks.java:3038-3068, the N2473 verification),
			# so the tick passes {} and the effective
			# drillTime is the base; itemCapacity reads the
			# catalog (10 default, Block.java:75; 20
			# large-plasma-bore, Blocks.java:3062). The scan
			# locals (size / range / tier / blockedItems) are
			# reused. The pure reports the produced counts
			# per item; the sector stats write + unlock
			# (BuildingComp.java:1039-1046) wait -- no sector
			# stats exist in the port.
			var beam_drill_time: float = float(block.properties.get("drillTime", SOURCE_BEAM_DRILL_DRILL_TIME_DEFAULT))
			var dropped: Dictionary = source_beam_drill_drop_loop_state(frame, time_scale, beam_drill_time, {}, int(block.properties.get("itemCapacity", 10)), beam_size, beam_range, beam_tier, beam_blocked_items)
			frame["last_item"] = dropped.get("last_item", null)
			frame["facing"] = dropped.get("facing", [])
			frame["drill_time"] = dropped.get("drill_time", beam_drill_time)
			frame["last_drill_speed"] = dropped.get("last_drill_speed", 0.0)
			frame["time"] = dropped.get("time", frame.get("time", 0.0))
			frame["items"] = dropped.get("items", frame.get("items", {}))
			frame["produced"] = dropped.get("produced", {})
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
			# fill lands -- the fill is live since N2405 (the
			# tick fills them from the live proximity below
			# when the frame carries neither key); the dumped
			# item lands in the neighbour
			# frame through the shared write-back helper since
			# N2363 (dump neighbour write-back live since N2363).
			# The clock runs only while enabled (the same pragmatic
			# gate as the advance itself -- Java runs updateTile
			# even when disabled, BuildingComp.java:2276-2277); the
			# driver-wide disabled-early-return slice removes this
			# gate for all families. First-fire deviation: Java
			# fires nearly at once after placement; the frame clock
			# delays the first fire by a full interval (5 ticks).
			var content_item_ids: Array = item_catalog.get("item_names_by_id", [])
			# N2405: the dump neighbour live fill -- the tick
			# fills the two neighbour arrays from the live
			# proximity BEFORE the timerDump dump reads them
			# (the N2394 pattern: ring order, index i is ring
			# cell i, the N2353 convention; accepts from the
			# DEFAULT acceptItem gate, canDump default true).
			# Supplied arrays WIN (the N2381 precedent): the
			# fill runs only when the frame carries NEITHER
			# key -- the N2289/N2363 proofs seed the arrays
			# by hand, so a fill there would overwrite the
			# seed. A frame the fill already stamped
			# (dump_neighbour_live -- port bookkeeping, not
			# Java state) refreshes every tick, so a
			# later-placed neighbour joins the arrays and a
			# removed one leaves them. The tick reads the
			# origin_cell meta inline as fill_cell (cell is
			# bound after the enabled block, the N2363 note)
			# and the catalog size.
			var has_supplied_dump_neighbour_arrays: bool = frame.has("dump_neighbour_accepts") or frame.has("dump_neighbour_can_dump")
			if not has_supplied_dump_neighbour_arrays or bool(frame.get("dump_neighbour_live", false)):
				var fill_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
				var dump_filled: Dictionary = source_beam_drill_dump_neighbour_live_fill_state(game, fill_cell, int(block.properties.get("size", 1)), frame, content_item_ids)
				frame["dump_neighbour_accepts"] = dump_filled.get("dump_neighbour_accepts", [])
				frame["dump_neighbour_can_dump"] = dump_filled.get("dump_neighbour_can_dump", [])
				frame["dump_neighbour_live"] = true
			var neighbour_accepts: Array = frame.get("dump_neighbour_accepts", [])
			var neighbour_can_dump: Array = frame.get("dump_neighbour_can_dump", [])
			var timer_dump: Dictionary = source_beam_drill_timer_dump_state(frame, source_delta, time_scale, content_item_ids, neighbour_accepts, neighbour_can_dump)
			frame["timer_dump_elapsed"] = timer_dump.get("elapsed_after", 0.0)
			frame["items"] = timer_dump.get("items_after", frame.get("items", {}))
			frame["cdump"] = timer_dump.get("cursor_after", frame.get("cdump", 0))
			# N2363: the timerDump dump neighbour write-back --
			# the advance exposed the routed neighbour index +
			# dumped item (dump_neighbour_index / dumped_item,
			# -1 / "" when nothing dumps), so the tick lands
			# the dumped item in the neighbour store through
			# the shared helper (other.handleItem(self(), item),
			# BuildingComp.java:1089 -- the handleItem call is
			# `other.handleItem(self(), item);`), right after
			# the timerDump write-back above (the N2353
			# Separator offload precedent: index i is ring
			# cell i, amount 1, one handleItem per dump). A
			# failed write-back (no sprite / no frame / no
			# items store / full belt) drops the item -- the
			# routing already decided, so there is no fallback
			# to the drill's own store.
			if bool(timer_dump.get("dumped", false)):
				var dump_index: int = int(timer_dump.get("dump_neighbour_index", -1))
				if dump_index >= 0:
					var dump_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
					source_building_item_state.source_neighbour_item_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), dump_index, str(timer_dump.get("dumped_item", "")), 1)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
