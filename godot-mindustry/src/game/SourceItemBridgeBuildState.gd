extends RefCounted
class_name SourceItemBridgeBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")
const source_building_item_state := preload("res://src/game/SourceBuildingItemState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")
const source_placed_power_graph_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")

# The ItemBridge implementation (ItemBridge.java:24, `public class ItemBridge extends Block{`): phase-conveyor (consumePower 0.30f, Blocks.java:2125, `consumePower(0.30f);`; size 1, range 12, transportTime 2f, phase-fabric 5 / silicon 7 / lead 10 / graphite 10, Blocks.java:2116-2125). ItemBridge extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_item_bridge_building", the radar precedent), and this slice adds the item-bridge key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceItemBridge* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTransport charge (ItemBridge.java:356, `transportCounter += edelta();`) charges its transport counter by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a phase-conveyor with no power would never advance its transport counter and never move items across the bridge -- its transport counter would sit frozen as if power.status were 1.0.
const SOURCE_ITEM_BRIDGE_BUILD_IMPLEMENTATIONS := ["ItemBridge"]
const SOURCE_ITEM_BRIDGE_BUILDING_META_KEY := "source_item_bridge_building"
# The transport def constants (phase-conveyor only, Blocks.java:2116-2125):
# `transportTime = 2f;` (Blocks.java:2119) with `range = 12;` (Blocks.java:2118),
# and `itemCapacity = 10;` (ItemBridge.java:49, also the Block class default,
# `public int itemCapacity = 10;`, Block.java:75). The approach rates are the
# updateTile literals: timeSpeed approaches at 1/60f (ItemBridge.java:326) and
# warmup at 1/30f (ItemBridge.java:345).
const SOURCE_ITEM_BRIDGE_TRANSPORT_TIME := 2.0
const SOURCE_ITEM_BRIDGE_ITEM_CAPACITY := 10
const SOURCE_ITEM_BRIDGE_TIME_SPEED_RATE := 1.0 / 60.0
const SOURCE_ITEM_BRIDGE_WARMUP_RATE := 1.0 / 30.0
# The timerCheckMoved snapshot interval: the literal 30f in `if(timer(timerCheckMoved, 30f)){` (ItemBridge.java:320), NOT divided by timeScale (the N2290 literal-20 precedent -- Java passes a literal, unlike the dump timers).
const SOURCE_ITEM_BRIDGE_TIMER_CHECK_MOVED_DURATION := 30.0

static func _is_item_bridge_build_implementation(implementation: String) -> bool:
	return SOURCE_ITEM_BRIDGE_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_item_bridge_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The item-bridge tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (ItemBridge.java:24, `public class ItemBridge extends Block{`; ItemBridgeBuild, ItemBridge.java:197, `public class ItemBridgeBuild extends Building{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# item bridge skips consumption like Java's updateConsumption
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
	# for this item bridge (N2125); the tick preserves a disabled
	# item bridge instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	# The link frame state (ItemBridge.java:198, `public int link
	# = -1;` and :202, `public boolean wasMoved, moved,
	# hadValidLink;`): the tick preserves a configured link
	# instead of resetting it, the enabled pattern above -- the
	# driver recomputes had_valid_link every tick
	# (ItemBridge.java:332-333).
	frame["link"] = int(frame.get("link", -1))
	frame["had_valid_link"] = bool(frame.get("had_valid_link", false))
	return frame

static func _initial_frame() -> Dictionary:
	# A new ItemBridgeBuild starts unlinked: `public int link = -1;` (ItemBridge.java:198)
	# and `public boolean wasMoved, moved, hadValidLink;` (ItemBridge.java:202, hadValidLink
	# defaults false); the driver recomputes had_valid_link every tick (ItemBridge.java:332-333).
	# The transport advance (N2225) carries the rest of the build fields with their Java
	# defaults: `public IntSeq incoming = new IntSeq(false, 4);` (ItemBridge.java:199),
	# `public float warmup;` (ItemBridge.java:200), `public float time = -8f, timeSpeed;`
	# (ItemBridge.java:201 -- time starts at -8f, NOT 0), `public float transportCounter;`
	# (ItemBridge.java:203), the Building.items ItemModule (frame["items"], Dictionary keyed
	# by item name, the factory precedent), and the ItemModule take rotation (`protected int
	# takeRotation;`, ItemModule.java:26, default 0). The dump fields (N2288) carry their
	# Java defaults too: `private transient float dumpAccum;` (BuildingComp.java:99, 0f)
	# and `transient int cdump;` (BuildingComp.java:68, 0).
	return {"link": -1, "had_valid_link": false, "transport_counter": 0.0, "warmup": 0.0, "time": -8.0, "time_speed": 0.0, "moved": false, "was_moved": false, "incoming": [], "items": {}, "take_rotation": 0, "dump_accum": 0.0, "cdump": 0}

static func source_item_bridge_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the item-bridge frame meta key
	# ("source_item_bridge_building"). An ItemBridge sprite gets a
	# frame bound with the Java field defaults (link -1,
	# had_valid_link false); the live-loop tick fills its other
	# keys every tick. Any other block, or an already-bound sprite,
	# binds nothing.
	if block == null or not _is_item_bridge_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_ITEM_BRIDGE_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_ITEM_BRIDGE_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_item_bridge_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a phase-conveyor does not take the early return. The item bridge's power draw is STATIC, not conditional: `consumePower(0.30f);` (Blocks.java:2125) registers a plain ConsumePower, so the catalog consumePower 0.3 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The updateTransport charge follows the folded efficiency: the transport charge (ItemBridge.java:356, `transportCounter += edelta();`) charges by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a phase-conveyor with no power would never advance its transport counter and never move items across the bridge. ItemBridgeBuild overrides shouldConsume (ItemBridge.java:495, `public boolean shouldConsume(){` with `return hadValidLink && enabled;`, ItemBridge.java:496); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). N2188 wires the gate (N2197 supplied the link frame state first: frame link/had_valid_link + pure configure + pure linkValid + the driver recompute every tick after the consumption fold): the pure source_item_bridge_should_consume_state gate is the override exactly (`return hadValidLink && enabled;`), the driver reads should_consume through it, and the machinery folds efficiency to 0 when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();`, with BuildingComp.java:1992-1994, `if(!update){` / `efficiency = optionalEfficiency = 0f;`). The gate reads the previous tick's had_valid_link -- the recompute runs after the fold, the Java order (BuildingComp.java:2274-2277) -- so a freshly linked bridge consumes from the next tick. The link gate itself is `hadValidLink = linkValid(tile, other);` (ItemBridge.java:333). The item bridge is its own family (ItemBridge.java:24, `public class ItemBridge extends Block{`; ItemBridgeBuild, ItemBridge.java:197, `public class ItemBridgeBuild extends Building{`), a distribution block, NOT related to any factory / turret / defense family. Class fields: `public final int timerCheckMoved = timers ++;` (ItemBridge.java:25), `public int range;` (ItemBridge.java:27), `public float transportTime;` (ItemBridge.java:28), `public boolean fadeIn = true;` (ItemBridge.java:34), `public boolean moveArrows = true;` (ItemBridge.java:35), `public boolean pulse = false;` (ItemBridge.java:36), `public float arrowSpacing = 4f, arrowOffset = 2f, arrowPeriod = 0.4f;` (ItemBridge.java:37), `public float arrowTimeScl = 6.2f;` (ItemBridge.java:38), `public float bridgeWidth = 6.5f;` (ItemBridge.java:39); constructor `update = true;` (ItemBridge.java:45), `solid = true;` (ItemBridge.java:46), `underBullets = true;` (ItemBridge.java:47), `hasPower = true;` (ItemBridge.java:48), `itemCapacity = 10;` (ItemBridge.java:49), `configurable = true;` (ItemBridge.java:50), `hasItems = true;` (ItemBridge.java:51). Build fields: `public int link = -1;` (ItemBridge.java:198), `public IntSeq incoming = new IntSeq(false, 4);` (ItemBridge.java:199), `public float warmup;` (ItemBridge.java:200), `public float time = -8f, timeSpeed;` (ItemBridge.java:201), `public boolean wasMoved, moved, hadValidLink;` (ItemBridge.java:202), `public float transportCounter;` (ItemBridge.java:203). The warmup approach (ItemBridge.java:345, `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);`) also follows the folded efficiency when a valid link exists; without a link `warmup = 0f` (ItemBridge.java:337). draw() uses `float warmup = hasPower ? this.warmup : 1f;` (ItemBridge.java:387) -- the bridge-conveyor (hasPower false) always draws warmup 1f, another reason the two defs must not share one driver row. BufferedItemBridge extends ItemBridge (BufferedItemBridge.java:9, `public class BufferedItemBridge extends ItemBridge{`) with `hasPower = false;` (BufferedItemBridge.java:18) and `bufferCapacity = 50` class default (def overrides to 14, Blocks.java:2113) and `speed = 74f` (def, Blocks.java:2112). canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) are the surrounding gates. The single def carries `consumePower(0.30f);` (Blocks.java:2125) with `range = 12;` (Blocks.java:2118) and `transportTime = 2f;` (Blocks.java:2119). Single def -- phase-conveyor only (size 1, range 12, transportTime 2f, phase-fabric 5 / silicon 7 / lead 10 / graphite 10, Blocks.java:2116-2125). bridge-conveyor (BufferedItemBridge, no power def) is explicitly OUT of scope.
	# Documented limits: (1) power-only first pass -- the phase-conveyor's static power consumer (consumePower 0.30f, Blocks.java:2125) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); phase-conveyor has no second consumer. (2) shouldConsume gate LIVE (N2188) -- ItemBridgeBuild.shouldConsume() (`return hadValidLink && enabled;`, ItemBridge.java:495-496) is the pure source_item_bridge_should_consume_state gate over the N2197 link frame state (frame link/had_valid_link + pure configure + pure linkValid + the driver recompute every tick after the consumption fold); the driver reads should_consume through it and the machinery folds efficiency to 0 when the gate is false (BuildingComp.java:1960/:1992-1994). The gate reads the previous tick's had_valid_link -- the Java order, updateConsumption before updateTile (BuildingComp.java:2274-2277) -- so a freshly linked bridge consumes from the next tick. (3) updateTile transport advance live (N2225) -- checkIncoming prune / incoming registration / transportCounter charge / item handoff / warmup approach / time + timeSpeed advance (ItemBridge.java:319-368) run every enabled tick after the consumption fold through the pure source_item_bridge_update_transport_state function; doDump live (N2288) -- dumpAccumulate (ItemBridge.java:350-353, BuildingComp.java:1048-1061) through the pure source_item_bridge_do_dump_state function, wired in the unlinked branch only after the transport advance, with the neighbour acceptItem/canDump arrays as frame inputs (default [] -- the dump neighbour live fill is live since N2404: the tick fills the arrays from the live proximity before the doDump, supplied arrays win) and doDump neighbour write-back live since N2362 (the advance exposes dump_deliveries, one {neighbour_index, item} per successful attempt, and the tick lands each dumped item in the neighbour store through the N2353 helper); the timerCheckMoved snapshot live (N2321) -- the frame-local Interval-equivalent pure source_item_bridge_timer_check_moved_state (ItemBridge.java:320-323, 30f, no timeScale division) runs in the driver before the advance call and stamps frame was_moved/moved/timer_check_moved_elapsed, so the advance reads the snapshot values (first-fire deviation: Java fires nearly immediately after placement, the frame clock delays the first fire by a full 30-tick interval), and checkAccept facing (ItemBridge.java:441-463) defers for non-linked sources -- the transport path takes the linked() shortcut (ItemBridge.java:464-466), so acceptItem there is the capacity gate only. The power proof carries no transport/warmup keys; the transport charge (ItemBridge.java:356) is what the efficiency keys prove, and the N2225 proof carries the transport keys. (4) No sense/warmup modeling -- `warmup()` has no override here (draw-only warmup, :387) and sense waits for its own slice. (5) Single def -- phase-conveyor only (size 1, range 12, transportTime 2f, phase-fabric 5 / silicon 7 / lead 10 / graphite 10); bridge-conveyor (BufferedItemBridge, no power def) is explicitly OUT of scope; per-def stat values wait for their own verification slice. (6) Draw rows live (N2429) -- the pure source_item_bridge_draw_state models draw() (ItemBridge.java:371-420: super.draw + Layer.power z + the linkValid / bridgeOpacity early returns + the relativeTo direction + the pulse color (live for the phase-conveyor, pulse = true, Blocks.java:2124) + the draw warmup `float warmup = hasPower ? this.warmup : 1f;` (:387) + the fadeIn 0.25f alpha floor + the endRegion rects + the bridgeRegion line + dist + the Lod.l1 moving arrows) + drawSelect (:223-231) / drawInput (:233-266: the pulsing alpha + the lerp arrow at rel * 90 + the gray background + place/accent foreground) / drawConfigure (:269-281: the self select + one select per linkValid candidate, linked ? Pal.place : Pal.breakInvalid). The warmup approach (:345) is updateTile logic, already live since N2225 -- NOT part of this slice. ItemBridge has NO icons() override and moveArrows is a dead field (declared :34, never read). Pure-only: the tick never calls draw -- draw is called by the renderer, drawSelect/drawConfigure by the UI, and the call sites wait for renderer/UI slices. The pure configure covers the config handlers (ItemBridge.java:64/66); placement auto-link is LIVE (N2199: pure findLink + playerPlaced + game lastBuild store + player-path driver, ItemBridge.java:41, 167-173, 211-220); handlePlacementLine / pickedUp wait for their own slices. (7) DrawPlace rows live (N2456) -- the pures source_item_bridge_draw_place_state + source_item_bridge_draw_plan_config_top_state model drawPlace (ItemBridge.java:118-142: super.drawPlace recorded + the findLink caller-supplied link + the 4 Pal.placing dash lines in d4 order + the Manhattan > 1 link rect + the bridge-arrow at rot * 90) + drawPlanConfigTop (:82-96: the Point2 config gate + the caller-supplied findPlan result) + drawBridge (:98-115: the Mathf.zero opacity gate + the bridgeRegion line 4px short of each end + the arrowRegion arrow at the midpoint, Angles.angle + flip 0). Pure-only: the tick never calls drawPlace/drawPlanConfigTop -- the placement UI calls them, and the call sites wait for UI slices.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func _to_short(value: int) -> int:
	# The Java (short) cast: truncate to the low 16 bits, then sign-extend (Point2.pack/unpack cast through short, arc Point2.java:35-42); GDScript ints are 64-bit, so the wrap is explicit.
	var truncated: int = value & 0xFFFF
	if truncated >= 0x8000:
		return truncated - 0x10000
	return truncated

static func _point2_pack(x: int, y: int) -> int:
	# Point2.pack (arc Point2.java:40-42, `return (((short)x) << 16) | (((short)y) & 0xFFFF);`).
	return (_to_short(x) << 16) | (_to_short(y) & 0xFFFF)

static func _point2_unpack(pos: int) -> Vector2i:
	# Point2.unpack (arc Point2.java:35-37, `return new Point2((short)(pos >>> 16), (short)(pos & 0xFFFF));`).
	return Vector2i(_to_short(pos >> 16), _to_short(pos & 0xFFFF))

static func source_item_bridge_configure_state(frame: Dictionary, config: Variant, tile_x: int, tile_y: int) -> Dictionary:
	# The ItemBridge config handlers (ItemBridge.java:64, `config(Point2.class, (ItemBridgeBuild tile, Point2 i) -> tile.link = Point2.pack(i.x + tile.tileX(), i.y + tile.tileY()));` and :66, `config(Integer.class, (ItemBridgeBuild tile, Integer i) -> tile.link = i);`): a Point2 config is RELATIVE -- its x/y add the tile position before packing -- while an Integer config is the packed absolute position. Building.configured dispatches by the config's class through block.configurations (BuildingComp.java:1414-1439); a config of any other type matches no handler and leaves the link unchanged. The pack is arc Point2.pack (arc Point2.java:40-42, `return (((short)x) << 16) | (((short)y) & 0xFFFF);`), via the private _point2_pack helper (the N2191 slerpDelta local precedent -- no separate symbol). Returns {"link": ...}; the caller writes it back onto the frame. The config() getter (ItemBridge.java:500-502, `return Point2.unpack(link).sub(tile.x, tile.y);`) and write/read (ItemBridge.java:510-512, `write.i(link);`) wait for their own rebuild slice.
	if config is int:
		return {"link": int(config)}
	if config is Dictionary:
		var dx: int = int(config.get("x", 0))
		var dy: int = int(config.get("y", 0))
		return {"link": _point2_pack(dx + tile_x, dy + tile_y)}
	return {"link": int(frame.get("link", -1))}

static func source_item_bridge_link_valid_state(tile_x: int, tile_y: int, other_x: int, other_y: int, range: int, blocks_match: bool, teams_match: bool, other_link: int, this_pos: int, other_exists: bool, check_double: bool) -> Dictionary:
	# linkValid (ItemBridge.java:145-156, `public boolean linkValid(Tile tile, Tile other){` with `return linkValid(tile, other, true);`, and `public boolean linkValid(Tile tile, Tile other, boolean checkDouble){`): `if(other == null || tile == null || !positionsValid(tile.x, tile.y, other.x, other.y)) return false;` -- a missing other tile is never valid -- then `return ((other.block() == tile.block() && tile.block() == this) || (!(tile.block() instanceof ItemBridge) && other.block() == this))` and `&& (other.team() == tile.team() || tile.block() != this)` and `&& (!checkDouble || ((ItemBridgeBuild)other.build).link != tile.pos());`. The driver ticks ItemBridge builds only, so tile.block() is always this: the block clause reduces to the other block being an ItemBridge (blocks_match, gathered by the driver) and the team clause to the teams matching (teams_match). positionsValid (ItemBridge.java:157-166, `public boolean positionsValid(int x1, int y1, int x2, int y2){`): same column `return Math.abs(y1 - y2) <= range;`, same row `return Math.abs(x1 - x2) <= range;`, else false. updateTile calls the two-arg form, so check_double is true on the live tick (ItemBridge.java:332-333, `Tile other = world.tile(link);` / `hadValidLink = linkValid(tile, other);`); checkIncoming calls it with false (ItemBridge.java:310), which waits for its own slice.
	if not other_exists:
		return {"had_valid_link": false}
	var positions_valid: bool = false
	if tile_x == other_x:
		positions_valid = abs(tile_y - other_y) <= range
	elif tile_y == other_y:
		positions_valid = abs(tile_x - other_x) <= range
	if not positions_valid:
		return {"had_valid_link": false}
	var double_ok: bool = (not check_double) or (other_link != this_pos)
	return {"had_valid_link": bool(blocks_match and teams_match and double_ok)}

static func source_item_bridge_should_consume_state(frame: Dictionary) -> Dictionary:
	# ItemBridgeBuild.shouldConsume() (ItemBridge.java:495, `public boolean shouldConsume(){` with `return hadValidLink && enabled;`, ItemBridge.java:496): the bridge consumes only while its link is valid AND it is enabled. The override INCLUDES the enabled check -- unlike the LaunchPad (N2186) and ShockwaveTower (N2187) overrides, whose enabled handling lives in updateConsumption (BuildingComp.java:1954-1957, the disabled early return) -- so this pure function reads both frame keys: had_valid_link (ItemBridge.java:202, `public boolean wasMoved, moved, hadValidLink;`, recomputed every tick by the N2197 driver, ItemBridge.java:332-333, `Tile other = world.tile(link);` / `hadValidLink = linkValid(tile, other);`) and enabled (BuildingComp.java:77, `transient boolean enabled = true;`, the BuildingComp default shouldConsume, BuildingComp.java:755-756, `return enabled;`). A missing link validity reads false (fresh build, unlinked); a missing enabled reads true (the Java field default). The gate reads the previous tick's had_valid_link: the N2197 recompute runs AFTER the consumption fold -- updateConsumption runs before updateTile (BuildingComp.java:2274-2277, `updateConsumption();` then `if(enabled || !block.noUpdateDisabled){` / `updateTile();`) -- and only when enabled (ItemBridge `noUpdateDisabled = true;`, ItemBridge.java:54, so a disabled bridge freezes its had_valid_link instead of clearing it). When the gate is false, updateConsumption folds efficiency to 0 (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();`, with BuildingComp.java:1992-1994, `if(!update){` / `efficiency = optionalEfficiency = 0f;`), so an unlinked bridge draws no power. LiquidBridge inherits this gate (LiquidBridgeBuild extends ItemBridgeBuild) but is its own slice, N2198.
	var had_valid_link: bool = bool(frame.get("had_valid_link", false))
	var enabled: bool = bool(frame.get("enabled", true))
	return {"should_consume": had_valid_link and enabled, "had_valid_link": had_valid_link}

static func _item_bridge_absolute_relative_to(self_x: int, self_y: int, other_x: int, other_y: int, size_value: int) -> int:
	# Tile.absoluteRelativeTo (Tile.java:114, `public byte absoluteRelativeTo(int cx, int cy){`): called ON the self tile with the OTHER tile coords -- 0 = other east (+x), 1 = other north (+y), 2 = other west (-x), 3 = other south (-y), the Geometry.d4x/d4y order ({1, 0, -1, 0} / {0, 1, 0, -1}, Geometry.java:23-24, arc), else -1. The odd-size branch (`if(block.size % 2 == 1){`) compares the raw tile coords; the even-size branch offsets the self coords by +0.5f. Building.relativeTo delegates here (`public byte relativeTo(int cx, int cy){` / `return tile.absoluteRelativeTo(cx, cy);`, BuildingComp.java:545-546). A private helper (the N2191 slerpDelta local precedent -- no separate symbol).
	if size_value % 2 == 1:
		if abs(self_x - other_x) > abs(self_y - other_y):
			if self_x <= other_x - 1:
				return 0
			if self_x >= other_x + 1:
				return 2
		else:
			if self_y <= other_y - 1:
				return 1
			if self_y >= other_y + 1:
				return 3
	else:
		if absf(float(self_x) - float(other_x) + 0.5) > absf(float(self_y) - float(other_y) + 0.5):
			if float(self_x) + 0.5 <= float(other_x) - 1.0:
				return 0
			if float(self_x) + 0.5 >= float(other_x) + 1.0:
				return 2
		else:
			if float(self_y) + 0.5 <= float(other_y) - 1.0:
				return 1
			if float(self_y) + 0.5 >= float(other_y) + 1.0:
				return 3
	return -1

static func _item_bridge_draw_input_call(tx: float, ty: float, tile_x: int, tile_y: int, other_tile_x: int, other_tile_y: int, other_drawx: float, other_drawy: float, linked: bool, time_value: float, size_value: int) -> Dictionary:
	# drawInput (ItemBridge.java:233-266), one input arrow + line + square (each exact expr on ONE comment line, the N2148 lesson):
	# `private void drawInput(Tile other){`
	# `boolean linked = other.pos() == link;`
	# `Tmp.v2.trns(tile.angleTo(other), 2f);`
	# `float tx = tile.drawx(), ty = tile.drawy();`
	# `float ox = other.drawx(), oy = other.drawy();`
	# `float alpha = Math.abs((linked ? 100 : 0)-(Time.time * 2f) % 100f) / 100f;`
	# `float x = Mathf.lerp(ox, tx, alpha);`
	# `float y = Mathf.lerp(oy, ty, alpha);`
	# `Tile otherLink = linked ? other : tile;`
	# `int rel = (linked ? tile : other).absoluteRelativeTo(otherLink.x, otherLink.y);`
	# `Draw.color(Pal.gray);`
	# `Lines.stroke(2.5f);`
	# `Lines.square(ox, oy, 2f, 45f);`
	# `Lines.line(tx + Tmp.v2.x, ty + Tmp.v2.y, ox - Tmp.v2.x, oy - Tmp.v2.y);`
	# `float color = (linked ? Pal.place : Pal.accent).toFloatBits();`
	# `Lines.stroke(1f);`
	# `Draw.mixcol(color);`
	# `Draw.color();`
	# `Draw.rect(arrowRegion, x, y, rel * 90);`
	# `Draw.mixcol();`
	# The caller (source_item_bridge_draw_state) already applied the `if(!linkValid(tile, other, false)) return;` gate and computed linked from the packed pos, so this helper takes linked as an input. tile.angleTo(other) is Angles.angle over the draw positions (Position.java:12-14, arc) -- the port's source_angles_angle, then cos/sin of deg_to_rad for the trns offset (the N2373 precedent). Java % on non-negative floats == GDScript fmod (the N2191 precedent). rel is this tile relative to the other when linked, else the other tile relative to this. Colors are symbolic tokens (the N2415 precedent -- the port never draws for real). A private helper (the N2191 slerpDelta local precedent -- no separate symbol).
	var input_angle: float = source_math_state.source_angles_angle(tx, ty, other_drawx, other_drawy)
	var offset_x: float = 2.0 * cos(deg_to_rad(input_angle))
	var offset_y: float = 2.0 * sin(deg_to_rad(input_angle))
	var input_alpha: float = absf((100.0 if linked else 0.0) - fmod(time_value * 2.0, 100.0)) / 100.0
	var arrow_x: float = lerpf(other_drawx, tx, input_alpha)
	var arrow_y: float = lerpf(other_drawy, ty, input_alpha)
	var input_rel: int = 0
	if linked:
		input_rel = _item_bridge_absolute_relative_to(tile_x, tile_y, other_tile_x, other_tile_y, size_value)
	else:
		input_rel = _item_bridge_absolute_relative_to(other_tile_x, other_tile_y, tile_x, tile_y, size_value)
	var input_color: String = "Pal.place" if linked else "Pal.accent"
	return {
		"tile_x": other_tile_x,
		"tile_y": other_tile_y,
		"drawx": other_drawx,
		"drawy": other_drawy,
		"linked": linked,
		"alpha": input_alpha,
		"arrow_x": arrow_x,
		"arrow_y": arrow_y,
		"arrow_rotation": float(input_rel * 90),
		"color": input_color,
		"line": {"x1": tx + offset_x, "y1": ty + offset_y, "x2": other_drawx - offset_x, "y2": other_drawy - offset_y},
		"square": {"x": other_drawx, "y": other_drawy, "radius": 2.0, "rotation": 45.0},
		"background": {"color": "Pal.gray", "stroke": 2.5},
		"foreground": {"color": input_color, "stroke": 1.0},
		"mixcol_color": input_color,
	}

static func source_item_bridge_draw_state(x_value: float, y_value: float, tile_x: int, tile_y: int, has_power: bool, warmup: float, time: float, time_value: float, link_valid: bool, other_tile_x: int, other_tile_y: int, other_drawx: float, other_drawy: float, bridge_opacity: float, fade_in: bool, pulse: bool, bridge_width: float, arrow_spacing: float, arrow_offset: float, arrow_period: float, arrow_time_scl: float, lod_l1: bool, lod_alpha1: float, size_value: int, link_pos: int, incoming_tiles: Array, configure_candidates: Array) -> Dictionary:
	# The draw rows (ItemBridgeBuild.draw(), ItemBridge.java:371-420 + drawSelect, :223-231 + drawInput, :233-266 + drawConfigure, :269-281), the pure draw-call dict -- the port never draws for real (the N2396 MassDriver precedent: the pure returns the draw calls as data). Java draws, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public void draw(){`
	# `super.draw();`
	# `Draw.z(Layer.power);`
	# `Tile other = world.tile(link);`
	# `if(!linkValid(tile, other)) return;`
	# `if(Mathf.zero(Renderer.bridgeOpacity)) return;`
	# `int i = relativeTo(other.x, other.y);`
	# `if(pulse){`
	# `Draw.color(Color.white, Color.black, Mathf.absin(Time.time, 6f, 0.07f));`
	# `float warmup = hasPower ? this.warmup : 1f;`
	# `Draw.alpha((fadeIn ? Math.max(warmup, 0.25f) : 1f) * Renderer.bridgeOpacity);`
	# `Draw.rect(endRegion, x, y, i * 90 + 90);`
	# `Draw.rect(endRegion, other.drawx(), other.drawy(), i * 90 + 270);`
	# `Lines.stroke(bridgeWidth);`
	# `Tmp.v1.set(x, y).sub(other.worldx(), other.worldy()).setLength(tilesize/2f).scl(-1f);`
	# `Lines.line(bridgeRegion,`
	# `int dist = Math.max(Math.abs(other.x - tile.x), Math.abs(other.y - tile.y)) - 1;`
	# `Draw.color();`
	# `if(Lod.l1){`
	# `int arrows = (int)(dist * tilesize / arrowSpacing), dx = Geometry.d4x(i), dy = Geometry.d4y(i);`
	# `Draw.alpha(Mathf.absin(a - time / arrowTimeScl, arrowPeriod, 1f) * warmup * Renderer.bridgeOpacity * Lod.alpha1);`
	# `Draw.rect(arrowRegion,`
	# `x + dx * (tilesize / 2f + a * arrowSpacing + arrowOffset),`
	# `y + dy * (tilesize / 2f + a * arrowSpacing + arrowOffset),`
	# `i * 90f);`
	# `public void drawSelect(){`
	# `if(linkValid(tile, world.tile(link))){`
	# `drawInput(world.tile(link));`
	# `incoming.each(pos -> drawInput(world.tile(pos)));`
	# `Draw.reset();`
	# `public void drawConfigure(){`
	# `Drawf.select(x, y, tile.block().size * tilesize / 2f + 2f, Pal.accent);`
	# `for(int i = 1; i <= range; i++){`
	# `for(int j = 0; j < 4; j++){`
	# `Tile other = tile.nearby(Geometry.d4[j].x * i, Geometry.d4[j].y * i);`
	# `if(linkValid(tile, other)){`
	# `Drawf.select(other.drawx(), other.drawy(),`
	# `other.block().size * tilesize / 2f + 2f + (linked ? 0f : Mathf.absin(Time.time, 4f, 1f)), linked ? Pal.place : Pal.breakInvalid);`
	# The def fields (ItemBridge.java:27-38): `public int range;` / `public @Load("@-end") TextureRegion endRegion;` / `public @Load("@-bridge") TextureRegion bridgeRegion;` / `public @Load("@-arrow") TextureRegion arrowRegion;` / `public boolean fadeIn = true;` / `public boolean pulse = false;` / `public float arrowSpacing = 4f, arrowOffset = 2f, arrowPeriod = 0.4f;` / `public float arrowTimeScl = 6.2f;` / `public float bridgeWidth = 6.5f;`, with `hasPower = true;` (:48) and the phase-conveyor overrides `range = 12;` / `arrowPeriod = 0.9f;` / `arrowTimeScl = 2.75f;` / `pulse = true;` (Blocks.java:2118-2124 -- pulse is LIVE for this def). The build fields are `public float warmup;` (:200) and `public float time = -8f, timeSpeed;` (:201), both tracked by the N2225 advance. The warmup approach `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);` (:345) is updateTile logic, already live since N2225 -- NOT ported here; only the draw warmup (:387) is. ItemBridge has NO icons() override (no "icon" line in ItemBridge.java at all) and moveArrows (`public boolean moveArrows = true;`, :34) is a dead field, declared but never read in draw(). relativeTo delegates to Tile.absoluteRelativeTo (`public byte relativeTo(int cx, int cy){` / `return tile.absoluteRelativeTo(cx, cy);`, BuildingComp.java:545-546; `public byte absoluteRelativeTo(int cx, int cy){`, Tile.java:114) -- the private _item_bridge_absolute_relative_to helper, odd branch for the size-1 bridge, even branch with the +0.5f offsets for completeness. Lod is the zoom-detail gate (`public static boolean l1 = true;` / `public static float alpha1 = 1f;`, Lod.java:17-18): lod_l1 / lod_alpha1 are caller-supplied (the MendProjector precedent -- the port has no live camera zoom at the driver layer). Mathf.zero is |value| <= 1e-6 (Mathf.java:522-524, arc). absin is Java-exact through the shared helper: Java absin is `return (sin(in, scl * 2f, mag) + mag) / 2f;` (Mathf.java:78-80, arc), while the helper is `(sin(value / scl) * 0.5 + 0.5) * mag` (SourceMathState.source_absin), i.e. helper(v, s) == Java absin(v, s / 2f) -- so the pure passes the DOUBLED scale (12f for the 6f pulse, arrowPeriod * 2f for the arrows, 8f for the 4f configure pulse), the N2372 lesson. other.worldx() == other.drawx() for the size-1 bridge because the Block offset is 0 (`offset = ((size + 1) % 2) * tilesize / 2f;`, Block.java:761). tilesize is the Java constant 8.0 (`public static final int tilesize = 8;`, Vars.java:135 -- NEVER the game tile_size 32, the N2375 lesson). The link verdict + the incoming / configure candidates are caller-evaluated (the pure cannot query the world): link_valid comes from the N2197 linkValid pure, each incoming entry carries its own linkValid(..., false) verdict (invalid entries are skipped, mirroring the drawInput early return), and the configure candidates arrive already linkValid-filtered in scan order. Time.time is caller-supplied as time_value (the N2396/N2372 convention -- draw never runs in the tick, so the tick never stamps it); `time` is the FRAME time field, not Time.time. Pure-only: the tick never calls draw -- draw is called by the renderer, drawSelect/drawConfigure by the UI, and the call sites wait for renderer/UI slices.
	var tile_size: float = 8.0
	var warmup_value: float = warmup if has_power else 1.0
	var draw_skipped_reason: String = ""
	if not link_valid:
		draw_skipped_reason = "unlinked"
	elif absf(bridge_opacity) <= 0.000001:
		draw_skipped_reason = "zero_opacity"
	var drawn: bool = draw_skipped_reason.is_empty()
	var draw_call: Variant = null
	var pulse_call: Variant = null
	var arrow_calls: Array = []
	if drawn:
		var link_direction: int = _item_bridge_absolute_relative_to(tile_x, tile_y, other_tile_x, other_tile_y, size_value)
		var draw_dist: int = maxi(absi(other_tile_x - tile_x), absi(other_tile_y - tile_y)) - 1
		var draw_alpha: float = (maxf(warmup_value, 0.25) if fade_in else 1.0) * bridge_opacity
		var delta_x: float = x_value - other_drawx
		var delta_y: float = y_value - other_drawy
		var delta_len: float = sqrt(delta_x * delta_x + delta_y * delta_y)
		var v1_x: float = 0.0
		var v1_y: float = 0.0
		if delta_len > 0.0:
			v1_x = -delta_x * (tile_size / 2.0) / delta_len
			v1_y = -delta_y * (tile_size / 2.0) / delta_len
		draw_call = {
			"base": "super.draw();",
			"z": "Layer.power",
			"direction": link_direction,
			"dist": draw_dist,
			"alpha": draw_alpha,
			"end_a": {"region": "endRegion", "x": x_value, "y": y_value, "rotation": float(link_direction * 90 + 90)},
			"end_b": {"region": "endRegion", "x": other_drawx, "y": other_drawy, "rotation": float(link_direction * 90 + 270)},
			"line": {"region": "bridgeRegion", "stroke": bridge_width, "x1": x_value + v1_x, "y1": y_value + v1_y, "x2": other_drawx - v1_x, "y2": other_drawy - v1_y},
		}
		if pulse:
			pulse_call = {"from": "Color.white", "to": "Color.black", "t": source_math_state.source_absin(time_value, 12.0, 0.07)}
		if lod_l1:
			var arrow_count: int = int(float(draw_dist) * tile_size / arrow_spacing)
			var dir_x: int = [1, 0, -1, 0][posmod(link_direction, 4)]
			var dir_y: int = [0, 1, 0, -1][posmod(link_direction, 4)]
			for a in range(arrow_count):
				var arrow_alpha: float = source_math_state.source_absin(float(a) - time / arrow_time_scl, arrow_period * 2.0, 1.0) * warmup_value * bridge_opacity * lod_alpha1
				arrow_calls.append({"x": x_value + float(dir_x) * (tile_size / 2.0 + float(a) * arrow_spacing + arrow_offset), "y": y_value + float(dir_y) * (tile_size / 2.0 + float(a) * arrow_spacing + arrow_offset), "rotation": float(link_direction * 90), "alpha": arrow_alpha})
	var input_calls: Array = []
	var link_input_drawn: bool = false
	if link_valid:
		input_calls.append(_item_bridge_draw_input_call(x_value, y_value, tile_x, tile_y, other_tile_x, other_tile_y, other_drawx, other_drawy, true, time_value, size_value))
		link_input_drawn = true
	var incoming_drawn: int = 0
	for incoming_entry in incoming_tiles:
		if not (incoming_entry is Dictionary):
			continue
		var incoming_dict: Dictionary = incoming_entry
		if not bool(incoming_dict.get("valid", false)):
			continue
		var incoming_linked: bool = int(incoming_dict.get("pos", -1)) == link_pos
		input_calls.append(_item_bridge_draw_input_call(x_value, y_value, tile_x, tile_y, int(incoming_dict.get("tile_x", 0)), int(incoming_dict.get("tile_y", 0)), float(incoming_dict.get("drawx", 0.0)), float(incoming_dict.get("drawy", 0.0)), incoming_linked, time_value, size_value))
		incoming_drawn += 1
	var select_call: Dictionary = {"link_input_drawn": link_input_drawn, "incoming_drawn": incoming_drawn, "reset_call": "Draw.reset();"}
	var candidate_selects: Array = []
	for candidate_entry in configure_candidates:
		if not (candidate_entry is Dictionary):
			continue
		var candidate_dict: Dictionary = candidate_entry
		var candidate_linked: bool = int(candidate_dict.get("pos", -1)) == link_pos
		var candidate_size: int = int(candidate_dict.get("size", 1))
		var candidate_radius: float = float(candidate_size) * tile_size / 2.0 + 2.0
		if not candidate_linked:
			candidate_radius += source_math_state.source_absin(time_value, 8.0, 1.0)
		candidate_selects.append({"x": float(candidate_dict.get("drawx", 0.0)), "y": float(candidate_dict.get("drawy", 0.0)), "radius": candidate_radius, "color": "Pal.place" if candidate_linked else "Pal.breakInvalid", "linked": candidate_linked})
	var configure_call: Dictionary = {
		"self_select": {"x": x_value, "y": y_value, "radius": float(size_value) * tile_size / 2.0 + 2.0, "color": "Pal.accent"},
		"candidates": candidate_selects,
	}
	return {
		"warmup_value": warmup_value,
		"draw_call": draw_call,
		"arrow_calls": arrow_calls,
		"pulse_call": pulse_call,
		"select_call": select_call,
		"input_call": input_calls,
		"configure_call": configure_call,
		"draw_skipped_reason": draw_skipped_reason,
	}

static func source_item_bridge_draw_place_state(tile_x: int, tile_y: int, range: int, link: Variant) -> Dictionary:
	# The draw-place rows (ItemBridge.drawPlace(), ItemBridge.java:118-142), the pure draw-call dict -- the port never draws for real (the N2429 draw precedent: the pure returns the draw calls as data). Java, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public void drawPlace(int x, int y, int rotation, boolean valid){`
	# `super.drawPlace(x, y, rotation, valid);`
	# `Tile link = findLink(x, y);`
	# `for(int i = 0; i < 4; i++){`
	# `Drawf.dashLine(Pal.placing,`
	# `x * tilesize + Geometry.d4[i].x * (tilesize / 2f + 2),`
	# `y * tilesize + Geometry.d4[i].y * (tilesize / 2f + 2),`
	# `x * tilesize + Geometry.d4[i].x * (range) * tilesize,`
	# `y * tilesize + Geometry.d4[i].y * (range) * tilesize);`
	# `Draw.reset();`
	# `Draw.color(Pal.placing);`
	# `Lines.stroke(1f);`
	# `if(link != null && Math.abs(link.x - x) + Math.abs(link.y - y) > 1){`
	# `int rot = link.absoluteRelativeTo(x, y);`
	# `float w = (link.x == x ? tilesize : Math.abs(link.x - x) * tilesize - tilesize);`
	# `float h = (link.y == y ? tilesize : Math.abs(link.y - y) * tilesize - tilesize);`
	# `Lines.rect((x + link.x) / 2f * tilesize - w / 2f, (y + link.y) / 2f * tilesize - h / 2f, w, h);`
	# `Draw.rect("bridge-arrow", link.x * tilesize + Geometry.d4(rot).x * tilesize, link.y * tilesize + Geometry.d4(rot).y * tilesize, link.absoluteRelativeTo(x, y) * 90);`
	# `public Tile findLink(int x, int y){`
	# `public byte absoluteRelativeTo(int cx, int cy){`
	# `public int range;`
	# `public static void dashLine(Color color, float x, float y, float x2, float y2){`
	# `dashLine(color, x, y, x2, y2, (int)(Math.max(Math.abs(x - x2), Math.abs(y - y2)) / tilesize * 2));`
	# `placing = accent,`
	# `public static final int tilesize = 8;`
	# `range = 12;`
	# `public final static Point2[] d4 = {`
	# `new Point2(1, 0),`
	# `new Point2(0, 1),`
	# `new Point2(-1, 0),`
	# `new Point2(0, -1)`
	# `public final static int[] d4x = {1, 0, -1, 0};`
	# `public final static int[] d4y = {0, 1, 0, -1};`
	# `return d4[Mathf.mod(i, 4)];`
	# super.drawPlace is Block.drawPlace (drawPotentialLinks + drawOverlay, SourceBlockDrawState) and is NOT modeled here: the pure records that the super call happens, not its content (the N2374 precedent -- super is recorded, not a symbol). rotation / valid pass through to super only, so the pure takes neither. findLink is already live since N2199 (`public Tile findLink(int x, int y){`, ItemBridge.java:167-173, the pure source_item_bridge_find_link_state): the pure takes its output caller-supplied as link ({x, y} Dict, or null when nothing was found) and does NOT port findLink again. The link tile is always the same ItemBridge def -- findLink only returns linkValid tiles, and linkValid requires the same block def (ItemBridge.java:152) -- so the link block is size 1 and absoluteRelativeTo takes the odd branch (Tile.java:117). absoluteRelativeTo is called ON the link tile with the placement coords (`public byte absoluteRelativeTo(int cx, int cy){`, Tile.java:114): rot 0 means the placement tile is EAST of the link, so an EAST link has rot 2 (the placement tile is west of it) -- the arrow sits on the link tile's edge facing the placement tile at rot * 90. Geometry.d4 order is 0 east (+x), 1 north (+y), 2 west (-x), 3 south (-y) (Geometry.java:10-14, arc -- the comment "starting at the left" is wrong, the values win); Geometry.d4(rot) wraps with Mathf.mod (the draw pure's posmod pattern). Pal.placing IS the accent color (`placing = accent,`, Pal.java:95). The dash segments come from the Drawf 4-arg overload (`public static void dashLine(Color color, float x, float y, float x2, float y2){` / `dashLine(color, x, y, x2, y2, (int)(Math.max(Math.abs(x - x2), Math.abs(y - y2)) / tilesize * 2));`, Drawf.java:223-224, mindustry -- the underlay is gray stroke 3f + the overlay is the color stroke 1f, Drawf.java:227-234, recorded in the comment, not per-dash). tilesize is the Java constant 8.0 (`public static final int tilesize = 8;`, Vars.java:135 -- NEVER the game tile_size 32, the N2375 lesson). The single ItemBridge def is the phase-conveyor (`range = 12;`, Blocks.java:2118 -- there is NO separate "item-bridge" def in Blocks.java, only phase-conveyor carries `new ItemBridge(`). The Manhattan gate is STRICTLY greater than 1: an adjacent link (dist 1) draws the dashes but no rect and no arrow. A diagonal link passes the gate (Manhattan 2) and gets the degenerate zero-size rect Java draws (w = h = |1| * tilesize - tilesize = 0). Pure-only: drawPlace never runs in the tick -- it is called by the placement UI, and the call site waits for a UI slice. DrawPlace rows live (N2456).
	var tile_size: float = 8.0
	var d4_x: Array = [1, 0, -1, 0]
	var d4_y: Array = [0, 1, 0, -1]
	var super_place_call: Dictionary = {
		"call": "super.drawPlace(x, y, rotation, valid);",
		"tile_x": tile_x,
		"tile_y": tile_y,
	}
	var dash_calls: Array = []
	for i in 4:
		var dir_x: int = int(d4_x[i])
		var dir_y: int = int(d4_y[i])
		var dash_x1: float = float(tile_x) * tile_size + float(dir_x) * (tile_size / 2.0 + 2.0)
		var dash_y1: float = float(tile_y) * tile_size + float(dir_y) * (tile_size / 2.0 + 2.0)
		var dash_x2: float = float(tile_x) * tile_size + float(dir_x) * float(range) * tile_size
		var dash_y2: float = float(tile_y) * tile_size + float(dir_y) * float(range) * tile_size
		var dash_segments: int = int(maxf(absf(dash_x1 - dash_x2), absf(dash_y1 - dash_y2)) / tile_size * 2.0)
		dash_calls.append({"call": "Drawf.dashLine(Pal.placing, x1, y1, x2, y2);", "direction": i, "color": "Pal.placing", "x1": dash_x1, "y1": dash_y1, "x2": dash_x2, "y2": dash_y2, "segments": dash_segments})
	var link_rect: Variant = null
	var arrow_call: Variant = null
	if link is Dictionary:
		var link_dict: Dictionary = link
		var link_x: int = int(link_dict.get("x", 0))
		var link_y: int = int(link_dict.get("y", 0))
		var link_manhattan: int = absi(link_x - tile_x) + absi(link_y - tile_y)
		if link_manhattan > 1:
			var link_rot: int = _item_bridge_absolute_relative_to(link_x, link_y, tile_x, tile_y, 1)
			var rect_w: float = tile_size if link_x == tile_x else float(absi(link_x - tile_x)) * tile_size - tile_size
			var rect_h: float = tile_size if link_y == tile_y else float(absi(link_y - tile_y)) * tile_size - tile_size
			var rect_x: float = float(tile_x + link_x) / 2.0 * tile_size - rect_w / 2.0
			var rect_y: float = float(tile_y + link_y) / 2.0 * tile_size - rect_h / 2.0
			link_rect = {"x": rect_x, "y": rect_y, "w": rect_w, "h": rect_h, "rotation": link_rot, "stroke": 1.0, "color": "Pal.placing"}
			var arrow_dir_x: int = int(d4_x[posmod(link_rot, 4)])
			var arrow_dir_y: int = int(d4_y[posmod(link_rot, 4)])
			arrow_call = {"region": "bridge-arrow", "x": float(link_x) * tile_size + float(arrow_dir_x) * tile_size, "y": float(link_y) * tile_size + float(arrow_dir_y) * tile_size, "rotation_degrees": float(link_rot * 90)}
	return {
		"super_place_call": super_place_call,
		"dash_calls": dash_calls,
		"link_rect": link_rect,
		"arrow_call": arrow_call,
	}

static func source_item_bridge_draw_plan_config_top_state(plan_x: int, plan_y: int, plan_config: Variant, range: int, other_req: Variant, bridge_opacity: float, bridge_width: float) -> Dictionary:
	# The draw-plan-config-top rows (ItemBridge.drawPlanConfigTop(), ItemBridge.java:82-96 + drawBridge(), :98-115), the pure draw-call dict -- the port never draws for real (the N2429 draw precedent). Java, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public void drawPlanConfigTop(BuildPlan plan, Eachable<BuildPlan> list){`
	# `if(plan.config instanceof Point2 p && (Math.abs(p.x) <= range && Math.abs(p.y) <= range && (p.x == 0 || p.y == 0))){`
	# `currentFindX = plan.x + p.x;`
	# `currentFindY = plan.y + p.y;`
	# `var otherReq = findPlan(list, currentFindX, currentFindY, planFinder);`
	# `if(otherReq != null){`
	# `drawBridge(plan, otherReq.drawx(), otherReq.drawy(), 0);`
	# `public void drawBridge(BuildPlan req, float ox, float oy, float flip){`
	# `if(Mathf.zero(Renderer.bridgeOpacity)) return;`
	# `Draw.alpha(Renderer.bridgeOpacity);`
	# `Lines.stroke(bridgeWidth);`
	# `Tmp.v1.set(ox, oy).sub(req.drawx(), req.drawy()).setLength(tilesize/2f);`
	# `Lines.line(`
	# `bridgeRegion,`
	# `req.drawx() + Tmp.v1.x,`
	# `req.drawy() + Tmp.v1.y,`
	# `ox - Tmp.v1.x,`
	# `oy - Tmp.v1.y, false`
	# `Draw.rect(arrowRegion, (req.drawx() + ox) / 2f, (req.drawy() + oy) / 2f,`
	# `Angles.angle(req.drawx(), req.drawy(), ox, oy) + flip);`
	# `Draw.reset();`
	# `public @Load("@-bridge") TextureRegion bridgeRegion;`
	# `public @Load("@-arrow") TextureRegion arrowRegion;`
	# `public float bridgeWidth = 6.5f;`
	# `public static BuildPlan findPlan(Eachable<BuildPlan> list, int x, int y, Boolf<BuildPlan> predicate){`
	# `offset = ((size + 1) % 2) * tilesize / 2f;`
	# `return x*tilesize + (block == null ? 0 : block.offset);`
	# `return y*tilesize + (block == null ? 0 : block.offset);`
	# `public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits`
	# `return Math.abs(value) <= FLOAT_ROUNDING_ERROR;`
	# `float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;`
	# `if(ang < 0) ang += 360f;`
	# `return (oldLen2 == 0 || oldLen2 == len2) ? this : scl((float)Math.sqrt(len2 / oldLen2));`
	# The plan config is the relative Point2 (the Point2 config handler is the relative one, ItemBridge.java:64): a non-Dict config (the Integer handler, :66, or null) fails the instanceof gate, and so does a diagonal or out-of-range Point2 -- (0, 0) PASSES (both |p| <= range and p.x == 0), it just finds nothing unless another plan sits on the same tile. The findPlan scan is the caller's: the pure cannot query the plan list, so other_req arrives caller-supplied ({draw_x, draw_y} Dict, or null when findPlan found nothing -- the N2429 caller-supplied precedent: link_valid / the incoming tiles / the configure candidates are caller-evaluated the same way; the planFinder predicate itself -- same block def, not the current plan, coords match, ItemBridge.java:79 -- is evaluated by the caller). The req draw pos is plan * tilesize: BuildPlan.drawx() adds the Block offset (`return x*tilesize + (block == null ? 0 : block.offset);`, BuildPlan.java:142-144), which is 0 for the size-1 bridge (`offset = ((size + 1) % 2) * tilesize / 2f;`, Block.java:761). Mathf.zero is |value| <= 1e-6 (`public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits` / `return Math.abs(value) <= FLOAT_ROUNDING_ERROR;`, Mathf.java:522-524, arc -- the draw pure's 0.000001 pattern). Angles.angle is atan2(dy, dx) degrees normalized to [0, 360) (`float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;` / `if(ang < 0) ang += 360f;`, Angles.java:56-60, arc -- arc's atan2(x, y) is Math.atan2(y, x), Mathf.java:151) through the shared source_angles_angle helper, + flip 0 (drawPlanConfigTop always passes flip 0). A zero-length v1 STAYS zero (`return (oldLen2 == 0 || oldLen2 == len2) ? this : scl((float)Math.sqrt(len2 / oldLen2));`, Vec2.setLength2, arc -- the (0, 0)-config same-tile case), so the line runs req-to-o with no inset. Pure-only: drawPlanConfigTop never runs in the tick -- the placement UI calls it, and the call site waits for a UI slice.
	var tile_size: float = 8.0
	var config_valid: bool = false
	var config_dx: int = 0
	var config_dy: int = 0
	if plan_config is Dictionary:
		var plan_config_dict: Dictionary = plan_config
		config_dx = int(plan_config_dict.get("x", 0))
		config_dy = int(plan_config_dict.get("y", 0))
		config_valid = absi(config_dx) <= range and absi(config_dy) <= range and (config_dx == 0 or config_dy == 0)
	var find_x: Variant = null
	var find_y: Variant = null
	var skipped_reason: String = ""
	if not config_valid:
		skipped_reason = "invalid_config"
	elif not (other_req is Dictionary):
		skipped_reason = "no_other_req"
	elif absf(bridge_opacity) <= 0.000001:
		skipped_reason = "zero_opacity"
	var bridge_call: Variant = null
	if config_valid:
		find_x = plan_x + config_dx
		find_y = plan_y + config_dy
	if skipped_reason.is_empty():
		var other_dict: Dictionary = other_req
		var req_x: float = float(plan_x) * tile_size
		var req_y: float = float(plan_y) * tile_size
		var other_x: float = float(other_dict.get("draw_x", 0.0))
		var other_y: float = float(other_dict.get("draw_y", 0.0))
		var delta_x: float = other_x - req_x
		var delta_y: float = other_y - req_y
		var delta_len: float = sqrt(delta_x * delta_x + delta_y * delta_y)
		var v1_x: float = 0.0
		var v1_y: float = 0.0
		if delta_len > 0.0:
			v1_x = delta_x * (tile_size / 2.0) / delta_len
			v1_y = delta_y * (tile_size / 2.0) / delta_len
		var bridge_angle: float = source_math_state.source_angles_angle(req_x, req_y, other_x, other_y)
		bridge_call = {
			"line": {"region": "bridgeRegion", "stroke": bridge_width, "x1": req_x + v1_x, "y1": req_y + v1_y, "x2": other_x - v1_x, "y2": other_y - v1_y},
			"arrow": {"region": "arrowRegion", "x": (req_x + other_x) / 2.0, "y": (req_y + other_y) / 2.0, "angle_degrees": bridge_angle},
			"alpha": bridge_opacity,
			"flip": 0.0,
		}
	return {
		"bridge_call": bridge_call,
		"config_valid": config_valid,
		"find_x": find_x,
		"find_y": find_y,
		"skipped_reason": skipped_reason,
	}

static func _item_bridge_take_item(items: Dictionary, take_rotation: int, item_order: Array) -> Dictionary:
	# ItemModule.take() (ItemModule.java:191-204, `public @Nullable Item take(){`):
	# `for(int i = 0; i < items.length; i++){` scans the item slots from the take rotation,
	# `int index = (i + takeRotation);` with the wrap `if(index >= items.length) index -= items.length;`,
	# takes the first slot with `items[index] > 0`, decrements it, and records
	# `takeRotation = index + 1;` (`protected int takeRotation;`, ItemModule.java:26).
	# The port's items dict is keyed by item name (the factory precedent), so the scan runs
	# over item_order -- the catalog item_names_by_id, the content-id order Java iterates --
	# and the take / remove reuse the shared drill inventory helpers (item_count /
	# remove_item_state, clamped the same way as ItemModule.remove, ItemModule.java:258-262).
	# An item name outside the order is never taken: Java cannot hold a non-content item.
	# Returns {"item": ..., "items": ..., "take_rotation": ...}; item is "" when nothing is held.
	var next_items: Dictionary = items.duplicate(true)
	var next_rotation: int = take_rotation
	var taken_item := ""
	if not item_order.is_empty():
		var order_size: int = item_order.size()
		var rotation: int = posmod(take_rotation, order_size)
		for i in range(order_size):
			var index: int = (rotation + i) % order_size
			var candidate: String = str(item_order[index])
			if inventory.item_count(next_items, candidate) > 0:
				var removed: Dictionary = inventory.remove_item_state(next_items, candidate, 1)
				next_items = removed.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, next_items)
				next_rotation = index + 1
				taken_item = candidate
				break
	return {"item": taken_item, "items": next_items, "take_rotation": next_rotation}

static func source_item_bridge_timer_check_moved_state(elapsed: float, was_moved: bool, moved: bool, source_delta: float, time_scale: float, duration: float) -> Dictionary:
	# The frame-local Interval-equivalent for the timerCheckMoved
	# snapshot (TimerComp.timer, TimerComp.java:10-13, each
	# exact expr on ONE comment line, the N2148 lesson):
	# `if(Float.isInfinite(time)) return false;`
	# `return timer.get(index, time);`
	# Interval.get resets times[id] = Time.time on fire
	# (arc Interval.java:20-26):
	# `boolean got = check(id, time);`
	# `if(got) times[id] = Time.time;`
	# and check compares Time.time - times[id] >= time (arc
	# Interval.java:28-30):
	# `return Time.time - times[id] >= time || Time.time < times[id];`
	# Time.time counts TICKS (arc Time.java:69-80):
	# `timeRaw += delta;`
	# The port has no global tick clock at the driver layer, so
	# the elapsed clock is frame-local (frame["timer_check_moved_
	# elapsed"], accumulated by the tick delta every enabled tick,
	# unconditionally -- mirroring Time.time, which grows even
	# while the gate is closed): elapsed += source_delta
	# unconditionally (source_delta is the UNSCALED Time.delta in
	# ticks -- game_source_delta is seconds * 60, never scaled by
	# timeScale -- so the frame clock mirrors the global Time.time
	# exactly); fired = elapsed >= duration (the LITERAL duration,
	# no timeScale division -- Java passes a literal 30f, unlike
	# the dump timers that divide by timeScale, the N2290
	# literal-20 lesson); timer_elapsed_after RESETS to 0.0 on
	# fire (a reset, not a subtraction like the Fracker
	# accumulator); a non-positive time_scale is a defensive guard
	# (fired false -- see below). The Java call is
	# (ItemBridge.java:320-323):
	# `if(timer(timerCheckMoved, 30f)){`
	# `wasMoved = moved;`
	# `moved = false;`
	# with `public final int timerCheckMoved = timers ++;`
	# (ItemBridge.java:25) and `public boolean wasMoved, moved, hadValidLink;`
	# (ItemBridge.java:202). When the timer fires the snapshot
	# runs: was_moved takes the OLD moved and moved resets to
	# false; when it does not fire both keep their values. The
	# snapshot runs BEFORE the timeSpeed advance
	# (`timeSpeed = Mathf.approachDelta(timeSpeed, wasMoved ? 1f : 0f, 1f / 60f);`,
	# ItemBridge.java:326) and transport (`transportCounter += edelta();`,
	# ItemBridge.java:356, with `moved = true;` on handoff,
	# ItemBridge.java:361), so the driver runs this pure BEFORE
	# the N2225 advance call and stamps the frame from its
	# result -- the advance reads the already-snapshotted
	# was_moved/moved, and a moved=true the advance sets this
	# tick survives until the next snapshot fire. time_scale
	# stays a parameter (signature stability -- the contract,
	# call sites, and tests keep it) and is still read: a
	# non-positive time_scale never fires, a defensive port
	# guard for a corrupt frame input -- Java timeScale is
	# always positive in practice (the default,
	# BuildingComp.java:98, is
	# `private transient float timeScale = 1f, timeScaleDuration;`;
	# applyBoost / applySlowdown take positive intensities,
	# BuildingComp.java:461-478; decay resets it to 1f,
	# BuildingComp.java:2265-2266), so the guard is
	# unreachable in Java-exact play and the threshold is
	# Java-exact at every reachable time_scale. Note the
	# clock still ACCUMULATES at time_scale 0 (source_delta
	# is unscaled) -- only the fire is guarded. Documented
	# deviation (first fire): Java fires (nearly) immediately
	# after placement (the global Time.time is already large
	# vs a fresh Interval times[id] = 0); the frame-local
	# clock delays the first fire by a full interval (30
	# ticks). It cannot be fixed without a global clock --
	# it waits for a timer-infra slice if exact first-fire
	# timing is ever needed.
	var threshold: float = INF if time_scale <= 0.0 else duration
	var accumulated: float = elapsed + source_delta
	var fired: bool = accumulated >= threshold
	var elapsed_after: float = 0.0 if fired else accumulated
	var next_was_moved: bool = moved if fired else was_moved
	var next_moved: bool = false if fired else moved
	return {"fired": fired, "timer_elapsed_after": elapsed_after, "was_moved": next_was_moved, "moved": next_moved}

static func source_item_bridge_update_transport_state(frame: Dictionary, source_delta: float, time_scale: float, transport_time: float, item_capacity: int, had_valid_link: bool, tile_pos: int, partner: Dictionary, incoming_valid: Dictionary, item_order: Array) -> Dictionary:
	# The updateTile transport advance (ItemBridgeBuild.updateTile(), ItemBridge.java:319-348,
	# `public void updateTile(){`, + updateTransport(), ItemBridge.java:355-368), on
	# `public class ItemBridge extends Block{` (ItemBridge.java:24) /
	# `public class ItemBridgeBuild extends Building{` (ItemBridge.java:197).
	# Build fields: `public int link = -1;` (ItemBridge.java:198),
	# `public IntSeq incoming = new IntSeq(false, 4);` (ItemBridge.java:199),
	# `public float warmup;` (ItemBridge.java:200),
	# `public float time = -8f, timeSpeed;` (ItemBridge.java:201 -- time starts at -8f, NOT 0),
	# `public boolean wasMoved, moved, hadValidLink;` (ItemBridge.java:202),
	# `public float transportCounter;` (ItemBridge.java:203).
	# Class fields: `public final int timerCheckMoved = timers ++;` (ItemBridge.java:25),
	# `public float transportTime;` (ItemBridge.java:28, def `transportTime = 2f;`, Blocks.java:2119),
	# `itemCapacity = 10;` (ItemBridge.java:49, also the Block default `public int itemCapacity = 10;`, Block.java:75),
	# `hasItems = true;` (ItemBridge.java:51), `noUpdateDisabled = true;` (ItemBridge.java:54,
	# against the Block default `public boolean noUpdateDisabled = false;`, Block.java:170).
	# Java order, step by step. The timer snapshot is live since N2321 -- the driver
	# runs source_item_bridge_timer_check_moved_state before this advance and stamps
	# the snapshot onto the frame, so this pure reads the already-snapshotted
	# was_moved/moved (the first-fire deviation is documented on the timer pure):
	# `if(timer(timerCheckMoved, 30f)){` / `wasMoved = moved;` / `moved = false;` (ItemBridge.java:320-323).
	# `timeSpeed = Mathf.approachDelta(timeSpeed, wasMoved ? 1f : 0f, 1f / 60f);` (ItemBridge.java:326).
	# `time += timeSpeed * delta();` (ItemBridge.java:328, with the NEW timeSpeed).
	# `checkIncoming();` (ItemBridge.java:330): `int i = incoming.items[idx];` then
	# `if(!linkValid(tile, other, false) || ((ItemBridgeBuild)other.build).link != tile.pos()){`
	# with `incoming.removeIndex(idx);` (ItemBridge.java:305-317) -- the driver gathers the
	# per-entry validity (linkValid with checkDouble=false AND the other build linking back).
	# `Tile other = world.tile(link);` / `hadValidLink = linkValid(tile, other);` (ItemBridge.java:332-333)
	# is N2197's recompute, NOT redone here: the driver passes the fresh value in, the Java
	# order (updateConsumption before updateTile, BuildingComp.java:2274-2277, `updateConsumption();`
	# then `if(enabled || !block.noUpdateDisabled){` / `updateTile();`).
	# `if(!hadValidLink){` (ItemBridge.java:335): `doDump();` (ItemBridge.java:336, live since
	# N2288 through source_item_bridge_do_dump_state, wired in the unlinked branch after this
	# advance -- `dumpAccumulate();` (ItemBridge.java:352) / `dumpAccum += delta();` /
	# `while(dumpAccum >= 1f){` (BuildingComp.java:1053-1060), with the neighbour
	# acceptItem/canDump arrays as frame inputs) and `warmup = 0f;` (ItemBridge.java:337).
	# Else: `var inc = ((ItemBridgeBuild)other.build).incoming;` / `int pos = tile.pos();` /
	# `if(!inc.contains(pos)){` / `inc.add(pos);` (ItemBridge.java:339-344, registration on the
	# PARTNER frame, written back by the driver), then
	# `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);` (ItemBridge.java:345) and
	# `updateTransport(other.build);` (ItemBridge.java:346).
	# updateTransport (ItemBridge.java:355-368): `transportCounter += edelta();` (ItemBridge.java:356),
	# `while(transportCounter >= transportTime){` (ItemBridge.java:357), `Item item = items.take();`
	# (ItemBridge.java:358), `if(item != null && other.acceptItem(this, item)){` (ItemBridge.java:359),
	# `other.handleItem(this, item);` (ItemBridge.java:360, `public void handleItem(Building source, Item item){`
	# with `items.add(item, 1);`, BuildingComp.java:860-862), `moved = true;` (ItemBridge.java:361),
	# else `items.add(item, 1);` / `items.undoFlow(item);` (ItemBridge.java:363-364),
	# `transportCounter -= transportTime;` (ItemBridge.java:366, unconditional -- the counter is
	# spent even when the take is null or the partner rejects).
	# acceptItem (ItemBridge.java:424-426):
	# `return hasItems && team == source.team && items.total() < itemCapacity && checkAccept(source, world.tile(link));`
	# -- hasItems is true, the team match is part of linkValid, and checkAccept
	# (ItemBridge.java:441-463) returns true through the linked() shortcut:
	# `if(tile == null || linked(source)) return true;` (ItemBridge.java:442) with
	# `return source instanceof ItemBridgeBuild && linkValid(source.tile, tile) && ((ItemBridgeBuild)source).link == pos();`
	# (ItemBridge.java:465). linked() is ALWAYS true when hadValidLink holds: linkValid(this, partner)
	# with checkDouble is the same condition both ways, and source.link == partner pos by
	# construction -- so acceptItem in the transport path is the capacity gate only, and the
	# facing path (`int rel = relativeTo(link);` / `var facing = Edges.getFacingEdge(source, this);` /
	# `return rel != rel2;`, ItemBridge.java:445-458) defers for non-linked sources.
	# `items.undoFlow(item);` is a port no-op: `public void undoFlow(Item item){` only touches the
	# flow cacheSums (`cacheSums[item.id] -= 1;`, ItemModule.java:252-256) and the port models no
	# flow state. delta() is `return Time.delta * timeScale;` (BuildingComp.java:1922-1924) and
	# edelta() is `return efficiency * delta();` (BuildingComp.java:1927-1929); source_delta is
	# Time.delta in ticks (seconds * 60 through game_source_delta, arc Time.java:26), never raw
	# seconds; timeScale reads `private transient float timeScale = 1f, timeScaleDuration;`
	# (BuildingComp.java:98). approachDelta scales by RAW Time.delta (arc Mathf.java:420-422,
	# approach(from, to, Time.delta * speed)), never by delta() -- so the timeSpeed and warmup
	# steps use the unscaled source delta through SourceMathState.source_approach_delta, while
	# time and the transport counter use delta() with timeScale. efficiency is
	# `transient float efficiency;` (BuildingComp.java:85), default 0.0. The transport loop
	# guards transport_time > 0 (Java would spin on a 0 transportTime; the def const is 2f).
	# Returns the advanced self values plus the partner updates (partner_items /
	# partner_incoming); the driver writes both back. was_moved is NOT returned --
	# only the timer snapshot changes it, and the driver stamps it from the timer
	# pure before this advance, so it stays the (already snapshotted) frame input.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var warmup: float = float(frame.get("warmup", 0.0))
	var time_value: float = float(frame.get("time", -8.0))
	var time_speed: float = float(frame.get("time_speed", 0.0))
	var was_moved: bool = bool(frame.get("was_moved", false))
	var moved: bool = bool(frame.get("moved", false))
	var transport_counter: float = float(frame.get("transport_counter", 0.0))
	var take_rotation: int = int(frame.get("take_rotation", 0))
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var incoming: Array = (frame.get("incoming", []) as Array).duplicate(true)
	var partner_exists: bool = bool(partner.get("exists", false))
	var partner_pos: int = int(partner.get("pos", -1))
	var partner_items: Dictionary = (partner.get("items", {}) as Dictionary).duplicate(true)
	var partner_incoming: Array = (partner.get("incoming", []) as Array).duplicate(true)
	var delta: float = source_delta * time_scale
	time_speed = source_math_state.source_approach_delta(time_speed, 1.0 if was_moved else 0.0, SOURCE_ITEM_BRIDGE_TIME_SPEED_RATE, source_delta)
	time_value += time_speed * delta
	var pruned: Array = []
	for entry in incoming:
		var entry_pos: int = int(entry)
		if bool(incoming_valid.get(entry_pos, false)):
			pruned.append(entry_pos)
	incoming = pruned
	if not had_valid_link:
		warmup = 0.0
	else:
		if partner_exists and not partner_incoming.has(tile_pos):
			partner_incoming.append(tile_pos)
		warmup = source_math_state.source_approach_delta(warmup, efficiency, SOURCE_ITEM_BRIDGE_WARMUP_RATE, source_delta)
		transport_counter += efficiency * delta
		var linked: bool = had_valid_link and partner_exists and int(frame.get("link", -1)) == partner_pos
		while transport_time > 0.0 and transport_counter >= transport_time:
			var taken: Dictionary = _item_bridge_take_item(items, take_rotation, item_order)
			items = taken.get("items", items)
			take_rotation = int(taken.get("take_rotation", take_rotation))
			var taken_item: String = str(taken.get("item", ""))
			if taken_item != "" and linked and inventory.items_total(partner_items) < item_capacity:
				var handled: Dictionary = inventory.add_item_state(partner_items, taken_item, 1)
				partner_items = handled.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, partner_items)
				moved = true
			elif taken_item != "":
				var returned: Dictionary = inventory.add_item_state(items, taken_item, 1)
				items = returned.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, items)
			transport_counter -= transport_time
	return {"transport_counter": transport_counter, "warmup": warmup, "time": time_value, "time_speed": time_speed, "moved": moved, "incoming": incoming, "items": items, "take_rotation": take_rotation, "partner_items": partner_items, "partner_incoming": partner_incoming}

static func source_item_bridge_dump_neighbour_live_fill_state(game: Object, cell: Vector2i, size: int, frame: Dictionary, item_order: Array) -> Dictionary:
	# The doDump neighbour live fill (N2404, DEFERRED #238):
	# the N2288 doDump reads the neighbour acceptItem /
	# canDump arrays as frame inputs (default [] -- no
	# neighbours, the Java proximity.size == 0 outcome), so
	# a live bridge with no fill read an empty proximity
	# and never dumped. This fill scans the live proximity
	# BEFORE the doDump and fills the two arrays from the
	# live neighbour frames, in ring order (index i is ring
	# cell i, the N2353 convention -- the ring comes from
	# source_block_proximity_cells_state, the sprite from
	# block_sprite_at_cell, the frame from the first
	# SOURCE_CONSUMER_FRAME_META_KEYS meta on the sprite,
	# the N2353 resolution path -- the N2394 pattern, item
	# half only):
	# `Building other = proximity.get((i + dump) % proximity.size);`
	# The accepts/canDump arrays come from the DEFAULT
	# BuildingComp gates -- acceptItem REQUIRES consumesItem,
	# not just capacity:
	# `public boolean acceptItem(Building source, Item item){`
	# `return block.consumesItem(item) && items.get(item) < getMaximumAccepted(item);`
	# `public int getMaximumAccepted(Item item){`
	# `return block.itemCapacity;`
	# `public int itemCapacity = 10;`
	# and the canDump default is true:
	# `public boolean canDump(Building to, Item item){`
	# and the item routing gates on both:
	# `if(other.acceptItem(self(), item) && canDump(other, item)){`
	# The consumes read is the itemFilter:
	# `public boolean consumesItem(Item item){`
	# `return itemFilter[item.id];`
	# which the port represents as the catalog consumeItem
	# rows. The item gate answers for the FIRST held item in
	# content order -- the item the dump pure offers (its
	# accepts array is per-neighbour, not per-item, so a
	# per-item answer would misdeliver: Java tries later held
	# items against the same neighbour, and that per-item
	# routing waits for a dump-shape slice). Per-block
	# overrides are OUT of scope: a neighbour with a modeled
	# override is evaluated with the DEFAULT gate here (the
	# override dispatch is a follow-through note). A neighbour
	# with no frame (no sprite / unknown def / conduit / no
	# meta-key frame) reports the no-frame outcome -- false /
	# false -- the N2353/N2371 no-frame precedent (a routed
	# item to a frameless neighbour drops, so the fill closes
	# the gates and nothing routes there). A conduit is
	# no-frame because its acceptLiquid is a per-block
	# override (Conduit.java:242-244, out of scope) and the
	# DEFAULT item gate would reject it anyway (a conduit
	# consumes no items). A belt neighbour reports accepts
	# false too -- the fill does not model the belt queue
	# (the N2394 precedent: either no frame, or a frame with
	# no items store), so nothing routes onto a belt from the
	# fill; the belt accept path waits for its own slice. Two
	# ring-model notes: Java updateProximity dedupes
	# multi-cell neighbours (`//using a set to prevent
	# duplicates`, BuildingComp.java:1879-1900) and keeps
	# same-team buildings only (`other.team != team` skips),
	# while the ring reports a multi-cell neighbour at each
	# of its ring cells with no team filter -- the N2353 /
	# N2371 ring convention this fill mirrors (a delivery to
	# either index lands in the same frame). Dedup + the team
	# filter wait for a shared ring-geometry slice.
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

static func source_item_bridge_do_dump_state(frame: Dictionary, had_valid_link: bool, source_delta: float, time_scale: float, content_item_ids: Array, neighbour_accepts_item: Array, neighbour_can_dump: Array) -> Dictionary:
	# The unlinked-branch doDump (ItemBridgeBuild.updateTile(), ItemBridge.java:319-348,
	# `public void updateTile(){`, on `public class ItemBridge extends Block{`
	# (ItemBridge.java:24) / `public class ItemBridgeBuild extends Building{`
	# (ItemBridge.java:197): `Tile other = world.tile(link);` /
	# `hadValidLink = linkValid(tile, other);` (ItemBridge.java:332-333) is N2197's
	# recompute, passed in fresh by the driver -- then `if(!hadValidLink){`
	# (ItemBridge.java:335): `doDump();` (ItemBridge.java:336) and `warmup = 0f;`
	# (ItemBridge.java:337). The N2225 advance already zeroes warmup in the unlinked
	# branch and leaves the store untouched; this pure is the doDump half, wired after
	# the advance in the same tick. The linked branch NEVER dumps -- Java calls doDump
	# only when !hadValidLink, so the pure returns the store, the accumulator, and the
	# cursor untouched when had_valid_link holds.
	# doDump (ItemBridge.java:350-353):
	# `public void doDump(){`
	# `//allow dumping multiple times per frame`
	# `dumpAccumulate();`
	# -- the base ItemBridge doDump is an ITEM dump. The LiquidBridge override
	# (`dumpLiquid(liquids.current(), 1f);`, LiquidBridge.java:29-31) is a different
	# slice, N2287. dumpAccumulate (BuildingComp.java:1047-1061):
	# `public boolean dumpAccumulate(){`
	# `return dumpAccumulate(null);`
	# `public boolean dumpAccumulate(Item item){`
	# `boolean res = false;`
	# `dumpAccum += delta();`
	# `while(dumpAccum >= 1f){`
	# `res |= dump(item);`
	# `dumpAccum -=1f;`
	# -- the accumulator grows by delta() EVERY call and the while loop can dump
	# MULTIPLE times per frame; the 1f subtraction is unconditional, even when the
	# dump fails. There is NO items.total() > 0 gate around the accumulator here
	# (unlike the PayloadDeconstructor, PayloadDeconstructor.java:111) -- the
	# accumulator advances even with an empty store and the dumps simply fail.
	# delta() is `return Time.delta * timeScale;` (BuildingComp.java:1922-1924) --
	# NOT edelta(), so the dump cadence ignores efficiency; source_delta is
	# Time.delta in ticks (seconds * 60 through game_source_delta, arc Time.java:26),
	# never raw seconds; timeScale reads `private transient float timeScale = 1f, timeScaleDuration;`
	# (BuildingComp.java:98). dump() (BuildingComp.java:1064-1066):
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
	# -- neighbours outer, content items inner: for each neighbour from the cdump
	# cursor, the first held item in content order an accepting neighbour takes is
	# handed over, 1 leaves the store, and the cursor advances once per neighbour
	# checked (incrementDump, BuildingComp.java:1116-1120):
	# `public void incrementDump(int prox){`
	# `if(prox != 0){`
	# `cdump = ((cdump + 1) % prox);`
	# The dump fields are Building fields at their Java defaults:
	# `private transient float dumpAccum;` (BuildingComp.java:99, 0f) and
	# `transient int cdump;` (BuildingComp.java:68, 0). The bridge has items
	# (`hasItems = true;`, ItemBridge.java:51; `itemCapacity = 10;`,
	# ItemBridge.java:49), so the hasItems guard always passes. canDump defaults to
	# true (`public boolean canDump(Building to, Item item){`,
	# BuildingComp.java:1124-1126); the neighbour arrays carry the live
	# per-neighbour answers as frame inputs (default [] -- no neighbours, the Java
	# proximity.size == 0 outcome). The attempt count + remainder come from the
	# shared accumulator step (SourceBuildingItemDumpState.dump_accumulate_state --
	# the static the PortBridge source_dump_accumulate_attempt_state delegates to,
	# SourceBuildingItemDumpPortBridge.gd:57-58; the driver is all-static, so it
	# calls the static directly, the N2276 dump_item_state precedent), and each
	# attempt runs through the shared dump(null) port
	# (SourceBuildingItemDumpState.dump_item_state) -- NOT the putItem gate
	# game_put_item_state, which dumps one SPECIFIC item and needs a game object
	# for its increment callbacks, while dumpAccumulate calls dump(null). Counting
	# the attempts up front is Java-exact: the while loop calls dump() exactly once
	# per whole unit of (dumpAccum + delta), and the subtraction is unconditional
	# either way. The shared port reports the handled neighbour (handled_index)
	# and the handled item (handled_item) per attempt; the advance collects them
	# into dump_deliveries -- one {"neighbour_index": ..., "item": ...} dict per
	# successful attempt, in attempt order (empty when nothing dumped) -- so the
	# tick can land each dumped item in its neighbour store through the N2353
	# helper (other.handleItem(self(), item), BuildingComp.java:1089). A scalar
	# routed index + item would drop every delivery but one: dumpAccumulate can
	# dump MULTIPLE times per frame ("allow dumping multiple times per frame",
	# ItemBridge.java:351). Index i is ring cell i (the N2353 convention): the
	# helper resolves the index through the source_block_proximity_cells_state
	# ring, so the live fill must fill the frame neighbour inputs in ring order.
	# dump_deliveries is UNREGISTERED API shape (the N2353 offload precedent --
	# the schema-sync slice folds it into
	# source_item_bridge_do_dump_state_result later); the contract keeps its
	# five return keys.
	# Returns {"dump_accum_after": ..., "dumped": ..., "dump_attempts": ...,
	# "items_after": ..., "cursor_after": ..., "dump_deliveries": ...}.
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var dump_accum: float = float(frame.get("dump_accum", 0.0))
	var cursor: int = int(frame.get("cdump", 0))
	var dumped := false
	var dump_attempts := 0
	var dump_deliveries: Array = []
	if not had_valid_link:
		var delta: float = source_delta * time_scale
		var accumulated: Dictionary = source_building_item_dump_state.dump_accumulate_state(dump_accum, delta)
		dump_accum = float(accumulated.get("dump_accum", dump_accum))
		dump_attempts = int(accumulated.get("dump_attempts", 0))
		for _attempt in range(dump_attempts):
			var amounts: Array = []
			for item_id in content_item_ids:
				amounts.append(int(items.get(str(item_id), 0)))
			var result: Dictionary = source_building_item_dump_state.dump_item_state(true, inventory.items_total(items), neighbour_accepts_item.size(), null, false, content_item_ids, amounts, neighbour_accepts_item, neighbour_can_dump, cursor)
			cursor = int(result.get("cdump", cursor))
			if bool(result.get("dumped", false)):
				dumped = true
				dump_deliveries.append({"neighbour_index": int(result.get("handled_index", -1)), "item": str(result.get("handled_item", ""))})
				var amounts_after: Array = result.get("item_amounts_by_index", amounts)
				for j in range(content_item_ids.size()):
					if j < amounts_after.size():
						items[str(content_item_ids[j])] = int(amounts_after[j])
	return {"dump_accum_after": dump_accum, "dumped": dumped, "dump_attempts": dump_attempts, "items_after": items, "cursor_after": cursor, "dump_deliveries": dump_deliveries}

static func source_item_bridge_find_link_state(tile_x: int, tile_y: int, tile_exists: bool, last_build_cell: Vector2i, last_build_exists: bool, last_build_link: int, range: int, blocks_match: bool, teams_match: bool) -> Dictionary:
	# findLink (ItemBridge.java:167-173, `public Tile findLink(int x, int y){` with `Tile tile = world.tile(x, y);` and `if(tile != null && lastBuild != null && linkValid(tile, lastBuild.tile) && lastBuild.tile != tile && lastBuild.link == -1){` / `return lastBuild.tile;` / `return null;`): the lastBuild tile is a link candidate only when the tile exists, a lastBuild exists for this block def, linkValid holds with checkDouble=true (`return linkValid(tile, other, true);`, ItemBridge.java:147), the lastBuild tile is not this tile, and the lastBuild link is still -1 (`public int link = -1;`, ItemBridge.java:198, the fresh-build default). The check order is Java's (tile, lastBuild, linkValid, tile inequality, link == -1); the linkValid call is the N2197 pure function. lastBuild is a field on the Block (ItemBridge.java:41-42, `//for autolink` / `public @Nullable ItemBridgeBuild lastBuild;`) -- one per block def, never cleared on removal, overwritten by the next placement of the same def. Returns {"found": ..., "link_cell": ...}; link_cell is Vector2i.ZERO when nothing was found.
	if not tile_exists:
		return {"found": false, "link_cell": Vector2i.ZERO}
	if not last_build_exists:
		return {"found": false, "link_cell": Vector2i.ZERO}
	var this_pos: int = _point2_pack(tile_x, tile_y)
	var valid: Dictionary = source_item_bridge_link_valid_state(tile_x, tile_y, last_build_cell.x, last_build_cell.y, range, blocks_match, teams_match, last_build_link, this_pos, true, true)
	if not bool(valid.get("had_valid_link", false)):
		return {"found": false, "link_cell": Vector2i.ZERO}
	if last_build_cell == Vector2i(tile_x, tile_y):
		return {"found": false, "link_cell": Vector2i.ZERO}
	if last_build_link != -1:
		return {"found": false, "link_cell": Vector2i.ZERO}
	return {"found": true, "link_cell": last_build_cell}

static func source_item_bridge_player_placed_state(tile_x: int, tile_y: int, tile_exists: bool, this_link: int, last_build_cell: Vector2i, last_build_exists: bool, last_build_link: int, range: int, blocks_match: bool, teams_match: bool, is_adjacent: bool) -> Dictionary:
	# playerPlaced (ItemBridge.java:210-219, `public void playerPlaced(Object config){` with `super.playerPlaced(config);` -- the super is a no-op, BuildingComp.java:1350-1352, `@CallSuper public void playerPlaced(Object config){ }` -- `Tile link = findLink(tile.x, tile.y);`, `if(linkValid(tile, link) && this.link != link.pos() && !proximity.contains(link.build)){`, `link.build.configure(tile.pos());`, and `lastBuild = this;`): the found partner is configured with this tile's packed position only when linkValid holds on the re-check (Java re-checks linkValid on the found link even though findLink already checked it -- mirrored here), this link does not already point at the partner (`this.link != link.pos()`, with `public int link = -1;`, ItemBridge.java:198, the fresh-build default), and the partner is not in proximity. proximity is the 4 orthogonal same-team neighbours for a size-1 block (updateProximity, BuildingComp.java:1879-1896, `Point2[] nearby = Edges.getEdges(block.size);` with `if(other == null || other.team != team) continue;`; Edges.java:25, `edges[i] = new Point2[(i + 1) * 4];`, gives (0,-1),(0,1),(-1,0),(1,0) for size 1), so the driver gathers is_adjacent as a Manhattan-distance-1 test once linkValid has required the team match. The config is the Integer handler (`config(Integer.class, (ItemBridgeBuild tile, Integer i) -> tile.link = i);`, ItemBridge.java:66) -- the packed absolute position, applied by the driver through the N2197 pure configure. lastBuild is recorded unconditionally (`lastBuild = this;`), even when nothing is configured. Returns {"configure_other": ..., "other_cell": ..., "config_value": ..., "new_last_build_cell": ...}; other_cell is Vector2i.ZERO and config_value is -1 when nothing is configured. The block clause (`return ((other.block() == tile.block() && tile.block() == this) || (!(tile.block() instanceof ItemBridge) && other.block() == this))`, ItemBridge.java:152) requires the SAME block def, so the driver gathers a strict def match (other block id == this block id) -- unlike the N2198 tick driver, which accepts any LiquidBridge implementation and therefore validates a cross-def phase-conduit / bridge-conduit pair; that tick deviation waits for its own fix slice. handlePlacementLine (`public void handlePlacementLine(Seq<BuildPlan> plans){`, ItemBridge.java:185, with `cur.config = new Point2(next.x - cur.x, next.y - cur.y);`, :190) and pickedUp (`public void pickedUp(){`, ItemBridge.java:206, `link = -1;`) wait for their own slices -- the port has no placement lines, and the bridge-specific pickup link reset is not wired yet.
	var found: Dictionary = source_item_bridge_find_link_state(tile_x, tile_y, tile_exists, last_build_cell, last_build_exists, last_build_link, range, blocks_match, teams_match)
	var new_last_build_cell := Vector2i(tile_x, tile_y)
	if not bool(found.get("found", false)):
		return {"configure_other": false, "other_cell": Vector2i.ZERO, "config_value": -1, "new_last_build_cell": new_last_build_cell}
	var other_cell: Vector2i = found.get("link_cell", Vector2i.ZERO)
	var this_pos: int = _point2_pack(tile_x, tile_y)
	var valid: Dictionary = source_item_bridge_link_valid_state(tile_x, tile_y, other_cell.x, other_cell.y, range, blocks_match, teams_match, last_build_link, this_pos, true, true)
	if not bool(valid.get("had_valid_link", false)):
		return {"configure_other": false, "other_cell": Vector2i.ZERO, "config_value": -1, "new_last_build_cell": new_last_build_cell}
	if this_link == _point2_pack(other_cell.x, other_cell.y):
		return {"configure_other": false, "other_cell": Vector2i.ZERO, "config_value": -1, "new_last_build_cell": new_last_build_cell}
	if is_adjacent:
		return {"configure_other": false, "other_cell": Vector2i.ZERO, "config_value": -1, "new_last_build_cell": new_last_build_cell}
	return {"configure_other": true, "other_cell": other_cell, "config_value": this_pos, "new_last_build_cell": new_last_build_cell}

static func source_item_bridge_auto_link_placement_state(game: Object, sprite: Sprite2D, block, cell: Vector2i) -> Dictionary:
	# The placement auto-link driver (N2199): runs the playerPlaced decision when an ItemBridge build is placed by the player (the PortGame hook calls this from place_selected_block_at_world only -- Java calls playerPlaced only when the builder is the local player unit, ConstructBlock.java:106-109, `if(!headless && builder == player.unit()){` / `tile.build.playerPlaced(config);`). The driver binds this frame if the tick has not bound it yet (the N2149 pattern: the driver binds on its first tick, but placement runs first), reads the game lastBuild store (`source_item_bridge_last_build_by_block`, keyed by block id -- lastBuild is a field on the Block, ItemBridge.java:41-42, one per def; Java keeps the Building reference, the port keeps the origin cell and resolves the sprite through placed_blocks, the N2197 driver precedent), gathers the partner (strict def match: other block id == this block id, ItemBridge.java:152; team match the same way as the tick driver; adjacency = Manhattan distance 1 -- proximity for a size-1 block, BuildingComp.java:1879-1896 + Edges.java:20-37), calls the pure playerPlaced, applies the Integer configure to the partner frame through the N2197 pure configure (`source_item_bridge_configure_state(` -- int config sets link directly, ItemBridge.java:66), and records this cell as the new lastBuild for the def (`lastBuild = this;`, ItemBridge.java:218). A missing partner sprite, a replaced partner cell, or a non-bridge partner fails the match and configures nothing -- the lastBuild update still happens. Returns {"applied": ..., "configure_other": ..., "other_cell": ..., "new_last_build_cell": ...}.
	if game == null or block == null or sprite == null or not is_instance_valid(sprite):
		return {"applied": false, "configure_other": false, "other_cell": Vector2i.ZERO, "new_last_build_cell": cell}
	if not _is_item_bridge_build_implementation(str(block.implementation)):
		return {"applied": false, "configure_other": false, "other_cell": Vector2i.ZERO, "new_last_build_cell": cell}
	var bound: Dictionary = source_item_bridge_bind_frame_state(sprite, block)
	var frame: Dictionary = bound.get("frame", {})
	var this_link: int = int(frame.get("link", -1))
	var last_builds_value: Variant = game.get("source_item_bridge_last_build_by_block")
	var last_builds: Dictionary = last_builds_value if last_builds_value is Dictionary else {}
	var block_id: String = str(block.id)
	var last_build_exists: bool = last_builds.has(block_id)
	var last_build_cell: Vector2i = last_builds.get(block_id, Vector2i.ZERO)
	var last_build_link: int = -1
	var blocks_match: bool = false
	var teams_match: bool = false
	var is_adjacent: bool = false
	var partner_frame: Dictionary = {}
	var partner_cell: Vector2i = Vector2i.ZERO
	if last_build_exists:
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var placed_blocks_value: Variant = game.get("placed_blocks")
		var placed_blocks: Dictionary = placed_blocks_value if placed_blocks_value is Dictionary else {}
		var partner_sprite: Variant = placed_blocks.get(game.call("cell_key", last_build_cell))
		if partner_sprite != null and is_instance_valid(partner_sprite) and partner_sprite is Sprite2D:
			var other_block_id: String = str(partner_sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
			blocks_match = other_block_id == block_id
			var other_team_id: int = int(partner_sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
			teams_match = other_team_id == team_id
			is_adjacent = abs(cell.x - last_build_cell.x) + abs(cell.y - last_build_cell.y) == 1
			if blocks_match:
				var catalog = game.get("content_catalog")
				if catalog != null:
					var other_block = catalog.get_by_id(other_block_id)
					if other_block != null:
						var partner_bound: Dictionary = source_item_bridge_bind_frame_state(partner_sprite, other_block)
						partner_frame = partner_bound.get("frame", {})
						last_build_link = int(partner_frame.get("link", -1))
						partner_cell = last_build_cell
	var link_range: int = int(block.properties.get("range", 0))
	var decision: Dictionary = source_item_bridge_player_placed_state(cell.x, cell.y, true, this_link, last_build_cell, last_build_exists, last_build_link, link_range, blocks_match, teams_match, is_adjacent)
	var configure_other: bool = bool(decision.get("configure_other", false))
	var other_cell: Vector2i = decision.get("other_cell", Vector2i.ZERO)
	if configure_other and not partner_frame.is_empty():
		var configured: Dictionary = source_item_bridge_configure_state(partner_frame, int(decision.get("config_value", -1)), partner_cell.x, partner_cell.y)
		partner_frame["link"] = int(configured.get("link", -1))
	last_builds[block_id] = cell
	game.set("source_item_bridge_last_build_by_block", last_builds)
	return {"applied": true, "configure_other": configure_other, "other_cell": other_cell, "new_last_build_cell": cell}

@warning_ignore("unused_parameter")
static func source_item_bridge_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the item-bridge tick wiring every
	# tick (ItemBridgeBuild.updateTile(), ItemBridge.java:319,
	# charges the transport counter by the transport charge (ItemBridge.java:356, `transportCounter += edelta();`), so the transport charge follows the folded efficiency; no placed-buildings driver ticks ItemBridge blocks, so this driver is the placed-item-bridge tick): each placed ItemBridge build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_item_bridge_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_item_bridge_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_item_bridge_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# an item bridge with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the transport charge (ItemBridge.java:356, `transportCounter += edelta();`)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a phase-conveyor does not take the early return. The item bridge's power draw is STATIC: `consumePower(0.30f);` (Blocks.java:2125) registers a plain ConsumePower, so the catalog consumePower 0.3 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. An item bridge with no power consumer is untouched: the tick models no other consumers yet (the updateTile transport advance is live since N2225 and runs below, after the link recompute), and ItemBridgeBuild overrides shouldConsume (ItemBridge.java:495, `public boolean shouldConsume(){` with `return hadValidLink && enabled;`, ItemBridge.java:496) -- N2188 wires the gate through the pure source_item_bridge_should_consume_state function (the N2186/N2187 gate precedent), which is the override exactly, over the N2197 link frame state (frame link/had_valid_link + pure configure + pure linkValid + the driver recompute every tick after the consumption fold). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_item_bridge_should_consume_state(frame)
			var should_consume: bool = bool(gate.get("should_consume", false))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_item_bridge_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		# The updateTile link recompute (ItemBridge.java:332-333, `Tile other = world.tile(link);` / `hadValidLink = linkValid(tile, other);`): updateConsumption runs BEFORE updateTile (BuildingComp.java:2274-2277, `updateConsumption();` then `if(enabled || !block.noUpdateDisabled){` / `updateTile();`), so this recompute runs AFTER the consumption fold above -- and only when enabled (ItemBridge `noUpdateDisabled = true;`, ItemBridge.java:54: a disabled bridge never runs updateTile, so its had_valid_link freezes instead of clearing). The partner sprite is looked up through placed_blocks by the unpacked link cell (Point2.unpack, arc Point2.java:35-37, `return new Point2((short)(pos >>> 16), (short)(pos & 0xFFFF));`); a missing sprite or a partner that is not an ItemBridge fails the block match, and the partner's team is read the same way as this sprite's (SOURCE_BUILD_TEAM_META_KEY, default derelict). The gate reads the value this recompute set on the PREVIOUS tick -- N2188 wires `should_consume = had_valid_link && enabled` (ItemBridge.java:495-496, `return hadValidLink && enabled;`) through the pure source_item_bridge_should_consume_state function in the consumption fold above, which runs BEFORE this recompute, the Java order (BuildingComp.java:2274-2277) -- so a freshly linked bridge consumes from the next tick, and a freshly unlinked bridge consumes for one more tick.
		if bool(frame.get("enabled", true)):
			var link_value: int = int(frame.get("link", -1))
			var other_cell: Vector2i = _point2_unpack(link_value)
			var placed_blocks_value: Variant = game.get("placed_blocks")
			var placed_blocks: Dictionary = placed_blocks_value if placed_blocks_value is Dictionary else {}
			var other_sprite: Variant = placed_blocks.get(game.call("cell_key", other_cell))
			var other_exists: bool = other_sprite != null and is_instance_valid(other_sprite) and other_sprite is Sprite2D
			var other_blocks_match: bool = false
			var other_teams_match: bool = false
			var other_link: int = -1
			if other_exists:
				var other_block_id: String = str(other_sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
				if blocks_by_id.has(other_block_id):
					var other_block = blocks_by_id[other_block_id]
					other_blocks_match = _is_item_bridge_build_implementation(str(other_block.implementation))
				var other_team_id: int = int(other_sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
				other_teams_match = other_team_id == team_id
				var other_frame: Variant = other_sprite.get_meta(SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
				if other_frame is Dictionary:
					other_link = int(other_frame.get("link", -1))
			var link_range: int = int(block.properties.get("range", 0))
			var this_pos: int = _point2_pack(cell.x, cell.y)
			frame["had_valid_link"] = bool(source_item_bridge_link_valid_state(cell.x, cell.y, other_cell.x, other_cell.y, link_range, other_blocks_match, other_teams_match, other_link, this_pos, other_exists, true).get("had_valid_link", false))
			# The updateTile transport advance (N2225, ItemBridge.java:319-368): runs after the
			# recompute above -- Java recomputes hadValidLink inside updateTile before the branch
			# (ItemBridge.java:332-333), and the timeSpeed / time / checkIncoming steps do not
			# depend on it, so the order is equivalent -- and only when enabled (ItemBridge
			# `noUpdateDisabled = true;`, ItemBridge.java:54: a disabled bridge freezes its
			# transport state). The driver gathers the partner snapshot (the partner frame, bound
			# through the N2199 precedent when the tick has not bound it yet; the frame dict is a
			# reference to the sprite meta, so the write-back below lands on the partner), the
			# per-incoming-entry validity for checkIncoming (linkValid with checkDouble=false
			# plus the other build linking back at this tile, ItemBridge.java:310), and the
			# catalog item order (item_names_by_id, the content-id order ItemModule.take()
			# rotates over). The source delta is Time.delta in ticks: game_source_delta(game,
			# seconds) is seconds * 60 (arc Time.java:26), never raw seconds; timeScale reads
			# live from the sprite meta, default 1.0 (BuildingComp.java:98 `private transient float
			# timeScale = 1f, timeScaleDuration;`). The pure advance returns the advanced self
			# values plus the partner updates, which the driver writes back to both frames.
			var partner: Dictionary = {"exists": false, "pos": link_value, "items": {}, "incoming": []}
			var partner_frame: Dictionary = {}
			if other_exists:
				var partner_block_id: String = str(other_sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
				if blocks_by_id.has(partner_block_id):
					var partner_block = blocks_by_id[partner_block_id]
					if _is_item_bridge_build_implementation(str(partner_block.implementation)):
						var partner_bound: Dictionary = source_item_bridge_bind_frame_state(other_sprite, partner_block)
						partner_frame = partner_bound.get("frame", {})
						partner = {"exists": true, "pos": link_value, "items": (partner_frame.get("items", {}) as Dictionary).duplicate(true), "incoming": (partner_frame.get("incoming", []) as Array).duplicate(true)}
			var incoming_valid: Dictionary = {}
			for incoming_pos in frame.get("incoming", []):
				var incoming_cell: Vector2i = _point2_unpack(int(incoming_pos))
				var incoming_sprite: Variant = placed_blocks.get(game.call("cell_key", incoming_cell))
				var incoming_exists: bool = incoming_sprite != null and is_instance_valid(incoming_sprite) and incoming_sprite is Sprite2D
				var incoming_blocks_match: bool = false
				var incoming_teams_match: bool = false
				var incoming_other_link: int = -1
				if incoming_exists:
					var incoming_block_id: String = str(incoming_sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
					if blocks_by_id.has(incoming_block_id):
						incoming_blocks_match = _is_item_bridge_build_implementation(str(blocks_by_id[incoming_block_id].implementation))
					var incoming_team_id: int = int(incoming_sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
					incoming_teams_match = incoming_team_id == team_id
					var incoming_frame: Variant = incoming_sprite.get_meta(SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
					if incoming_frame is Dictionary:
						incoming_other_link = int(incoming_frame.get("link", -1))
				var incoming_link_valid: bool = bool(source_item_bridge_link_valid_state(cell.x, cell.y, incoming_cell.x, incoming_cell.y, link_range, incoming_blocks_match, incoming_teams_match, incoming_other_link, this_pos, incoming_exists, false).get("had_valid_link", false))
				incoming_valid[int(incoming_pos)] = incoming_link_valid and incoming_other_link == this_pos
			var item_order: Array = source_content_registry_runtime_state.source_item_catalog_state(catalog).get("item_names_by_id", [])
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			# The timerCheckMoved snapshot (N2321, ItemBridge.java:320-323, `if(timer(timerCheckMoved, 30f)){` / `wasMoved = moved;` / `moved = false; }`): runs BEFORE the advance call below -- Java snapshots before the timeSpeed advance (:326) and transport (:356) -- so the advance reads the snapshotted was_moved/moved. The frame-local Interval-equivalent pure accumulates the UNSCALED source delta every enabled tick, fires at 30f (no timeScale division, the N2290 literal-20 precedent), and resets the clock to 0 on fire; a moved=true the advance sets this tick (handoff, :361) survives until the next snapshot fire. First-fire deviation: Java fires nearly immediately after placement; the frame clock delays the first fire by a full 30-tick interval.
			var timer_snapshot: Dictionary = source_item_bridge_timer_check_moved_state(float(frame.get("timer_check_moved_elapsed", 0.0)), bool(frame.get("was_moved", false)), bool(frame.get("moved", false)), source_delta, time_scale, SOURCE_ITEM_BRIDGE_TIMER_CHECK_MOVED_DURATION)
			frame["timer_check_moved_elapsed"] = timer_snapshot["timer_elapsed_after"]
			frame["was_moved"] = timer_snapshot["was_moved"]
			frame["moved"] = timer_snapshot["moved"]
			var advanced: Dictionary = source_item_bridge_update_transport_state(frame, source_delta, time_scale, SOURCE_ITEM_BRIDGE_TRANSPORT_TIME, SOURCE_ITEM_BRIDGE_ITEM_CAPACITY, bool(frame.get("had_valid_link", false)), this_pos, partner, incoming_valid, item_order)
			frame["transport_counter"] = advanced["transport_counter"]
			frame["warmup"] = advanced["warmup"]
			frame["time"] = advanced["time"]
			frame["time_speed"] = advanced["time_speed"]
			frame["moved"] = advanced["moved"]
			frame["incoming"] = advanced["incoming"]
			frame["items"] = advanced["items"]
			frame["take_rotation"] = advanced["take_rotation"]
			if not partner_frame.is_empty():
				partner_frame["items"] = advanced["partner_items"]
				partner_frame["incoming"] = advanced["partner_incoming"]
			# The unlinked-branch doDump (N2288, ItemBridge.java:335-337, `if(!hadValidLink){
			# doDump(); warmup = 0f; }`): runs after the transport advance above -- Java calls
			# doDump() in the unlinked branch of the same updateTile, and the advance already
			# zeroed warmup and left the store untouched when unlinked, so the dump sees the
			# post-advance store. The pure gates on the freshly recomputed had_valid_link, so
			# the linked branch never dumps. The neighbour acceptItem/canDump arrays are frame
			# inputs (the N2281 / N2276 precedent, default []); the dump neighbour live
			# fill is live since N2404 (the fill below, before the reads -- supplied
			# arrays win, the N2381 precedent); the dumped store + accumulator + cursor
			# persist to the frame. The dump cadence uses delta() (source_delta *
			# time_scale), NOT edelta(), so it ignores efficiency.
			# N2404: the doDump neighbour live fill -- the tick
			# fills the two neighbour arrays from the live
			# proximity BEFORE the doDump reads them. Supplied
			# arrays WIN (the N2381 precedent): the fill runs
			# only when the frame carries NEITHER key -- the
			# N2288/N2362 proofs seed the arrays by hand, so a
			# fill there would overwrite the seed. A frame the
			# fill already stamped (dump_neighbour_live -- port
			# bookkeeping, not Java state) refreshes every
			# tick, so a later-placed neighbour joins the
			# arrays and a removed one leaves them. The fill
			# runs in the enabled block regardless of the link
			# gate -- the doDump pure gates on had_valid_link,
			# so a linked tick stamps arrays the dump never
			# reads -- and it reads the post-advance store, the
			# same store the dump sees. cell is bound before
			# the enabled block in this driver, so no inline
			# origin_cell read is needed (unlike the N2394
			# N2363 note).
			var has_supplied_dump_neighbour_arrays: bool = frame.has("dump_neighbour_accepts") or frame.has("dump_neighbour_can_dump")
			if not has_supplied_dump_neighbour_arrays or bool(frame.get("dump_neighbour_live", false)):
				var filled: Dictionary = source_item_bridge_dump_neighbour_live_fill_state(game, cell, int(block.properties.get("size", 1)), frame, item_order)
				frame["dump_neighbour_accepts"] = filled.get("dump_neighbour_accepts", [])
				frame["dump_neighbour_can_dump"] = filled.get("dump_neighbour_can_dump", [])
				frame["dump_neighbour_live"] = true
			var dump_neighbour_accepts: Array = frame.get("dump_neighbour_accepts", [])
			var dump_neighbour_can_dump: Array = frame.get("dump_neighbour_can_dump", [])
			var dumped: Dictionary = source_item_bridge_do_dump_state(frame, bool(frame.get("had_valid_link", false)), source_delta, time_scale, item_order, dump_neighbour_accepts, dump_neighbour_can_dump)
			frame["items"] = dumped["items_after"]
			frame["dump_accum"] = dumped["dump_accum_after"]
			frame["cdump"] = dumped["cursor_after"]
			# N2362: the doDump neighbour write-back -- the
			# advance exposed one delivery per successful dump
			# attempt (dump_deliveries, in attempt order), so
			# the tick lands each dumped item in its neighbour
			# store through the shared helper
			# (other.handleItem(self(), item),
			# BuildingComp.java:1089), right after the advance
			# write-back above (Java order: handleItem runs
			# inside dump(), :1089, before the next attempt).
			# A failed write-back (no sprite / no frame / no
			# items store / full belt) drops the item -- the
			# routing already decided, so there is no fallback
			# to the bridge's own store (the N2353 precedent).
			for delivery in dumped.get("dump_deliveries", []):
				var delivery_entry: Dictionary = delivery
				var delivery_index: int = int(delivery_entry.get("neighbour_index", -1))
				var delivery_item: String = str(delivery_entry.get("item", ""))
				if delivery_index >= 0 and not delivery_item.is_empty():
					source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), delivery_index, delivery_item, 1)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
