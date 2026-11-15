extends RefCounted
class_name SourceLiquidBridgeBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_item_bridge_build_state := preload("res://src/game/SourceItemBridgeBuildState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

# The LiquidBridge implementation (LiquidBridge.java:7, `public class LiquidBridge extends ItemBridge{`): phase-conduit (consumePower 0.30f, Blocks.java:2396, `consumePower(0.30f);`; size 1, range 12, liquidCapacity 100f, phase-fabric 5 / silicon 7 / metaglass 20 / titanium 10, Blocks.java:2385-2397). LiquidBridge extends ItemBridge, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_liquid_bridge_building", the radar precedent), and this slice adds the liquid-bridge key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceLiquidBridge* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the warmup gate (LiquidBridge.java:23, `if(warmup >= 0.25f){`) blocks ALL liquid movement until warmup reaches 0.25f, and warmup itself follows the folded efficiency through the inherited ItemBridge updateTile (ItemBridge.java:345, `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);`) -- so a phase-conduit with no power would never warm up and never move liquid across the bridge, as if power.status were 1.0.
const SOURCE_LIQUID_BRIDGE_BUILD_IMPLEMENTATIONS := ["LiquidBridge"]
const SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY := "source_liquid_bridge_building"

# The transport def constants (phase-conduit only, Blocks.java:2385-2397):
# `liquidCapacity = 100f;` (Blocks.java:2395, shared by bridge-conduit, Blocks.java:2381)
# with `range = 12;` (Blocks.java:2388). liquidPressure is the Block default
# `public float liquidPressure = 1f;` (Block.java:79) -- the phase-conduit def
# does not override it. The catalog carries no liquidCapacity / liquidPressure
# properties (the N2190 fogRadius / N2199 transportTime def-constant precedent),
# so the driver resolves both from these constants and passes them to the pure
# advance as parameters (the N2220 pump_amount precedent).
const SOURCE_LIQUID_BRIDGE_LIQUID_CAPACITY := 100.0
const SOURCE_LIQUID_BRIDGE_LIQUID_PRESSURE := 1.0
const SOURCE_LIQUID_BRIDGE_WARMUP_RATE := 1.0 / 30.0

static func _is_liquid_bridge_build_implementation(implementation: String) -> bool:
	return SOURCE_LIQUID_BRIDGE_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_liquid_bridge_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The liquid-bridge tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (LiquidBridge.java:7, `public class LiquidBridge extends ItemBridge{`; LiquidBridgeBuild, LiquidBridge.java:19, `public class LiquidBridgeBuild extends ItemBridgeBuild{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# liquid bridge skips consumption like Java's updateConsumption
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
	# for this liquid bridge (N2125); the tick preserves a disabled
	# liquid bridge instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	# The link frame state (ItemBridge.java:198, `public int link
	# = -1;` and :202, `public boolean wasMoved, moved,
	# hadValidLink;`, inherited by LiquidBridgeBuild,
	# LiquidBridge.java:19): the tick preserves a configured link
	# instead of resetting it, the enabled pattern above -- the
	# driver recomputes had_valid_link every tick
	# (ItemBridge.java:332-333).
	frame["link"] = int(frame.get("link", -1))
	frame["had_valid_link"] = bool(frame.get("had_valid_link", false))
	return frame

static func _initial_frame() -> Dictionary:
	# A new LiquidBridgeBuild starts unlinked: `public int link = -1;` (ItemBridge.java:198)
	# and `public boolean wasMoved, moved, hadValidLink;` (ItemBridge.java:202, hadValidLink
	# defaults false), inherited by LiquidBridgeBuild (LiquidBridge.java:19); the driver
	# recomputes had_valid_link every tick (ItemBridge.java:332-333).
	# The transport advance (N2275) carries the warmup / moved fields with their Java
	# defaults: `public float warmup;` (ItemBridge.java:200) and `moved` (ItemBridge.java:202).
	return {"link": -1, "had_valid_link": false, "warmup": 0.0, "moved": false}

static func source_liquid_bridge_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the liquid-bridge frame meta key
	# ("source_liquid_bridge_building"). A LiquidBridge sprite gets a
	# frame bound with the Java field defaults (link -1,
	# had_valid_link false); the live-loop tick fills its other
	# keys every tick. Any other block, or an already-bound sprite,
	# binds nothing.
	if block == null or not _is_liquid_bridge_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_liquid_bridge_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a phase-conduit does not take the early return. The liquid bridge's power draw is STATIC, not conditional: `consumePower(0.30f);` (Blocks.java:2396) registers a plain ConsumePower, so the catalog consumePower 0.3 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The liquid bridge's updateTransport (LiquidBridge.java:23-24, `if(warmup >= 0.25f){` with `moved |= moveLiquid(other, liquids.current()) > 0.05f;`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) moves liquid only once warmup reaches 0.25f, and warmup follows the folded efficiency through the inherited ItemBridge updateTile (ItemBridge.java:345, `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);`; ItemBridge.java:356, `transportCounter += edelta();`, and edelta() is efficiency * delta (BuildingComp.java:1927-1929, `return efficiency * delta();`)). doDump dumps the current liquid (LiquidBridge.java:30, `dumpLiquid(liquids.current(), 1f);`). draw() uses `float warmup = hasPower ? this.warmup : 1f;` (ItemBridge.java:387) -- the bridge-conduit (hasPower false) always draws warmup 1f, another reason the two defs must not share one driver row.
	# LiquidBridgeBuild inherits ItemBridgeBuild.shouldConsume (ItemBridge.java:495, `public boolean shouldConsume(){` with `return hadValidLink && enabled;`, ItemBridge.java:496); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). N2198 makes the gate live (resolving the N2179 RED decision, the PointDefenseTurret N2151 precedent and the RepairTurret N2174 / RepairTower N2176 / ShockwaveTower N2177 / ItemBridge N2178 precedents): the LiquidBridge frame tracks its own link/had_valid_link keys (Java field defaults, ItemBridge.java:198/:202), the driver recomputes had_valid_link every tick through N2197's pure linkValid, and the pure gate (source_liquid_bridge_should_consume_state) feeds `should_consume = had_valid_link && enabled` to the machinery -- when unlinked efficiency folds to 0 like Java. The link gate itself is `hadValidLink = linkValid(tile, other);` (ItemBridge.java:333).
	# The liquid bridge is its own family (LiquidBridge.java:7, `public class LiquidBridge extends ItemBridge{`; LiquidBridgeBuild, LiquidBridge.java:19, `public class LiquidBridgeBuild extends ItemBridgeBuild{`), a liquid block, NOT related to any factory / turret / defense family. Constructor: `hasItems = false;` (LiquidBridge.java:11), `hasLiquids = true;` (LiquidBridge.java:12), `outputsLiquid = true;` (LiquidBridge.java:13), `canOverdrive = false;` (LiquidBridge.java:14), `group = BlockGroup.liquids;` (LiquidBridge.java:15), `envEnabled = Env.any;` (LiquidBridge.java:16). It inherits the ItemBridge class (ItemBridge.java:24, `public class ItemBridge extends Block{`; ItemBridgeBuild, ItemBridge.java:197, `public class ItemBridgeBuild extends Building{`), a distribution block. Class fields: `public final int timerCheckMoved = timers ++;` (ItemBridge.java:25), `public int range;` (ItemBridge.java:27), `public float transportTime;` (ItemBridge.java:28), `public boolean fadeIn = true;` (ItemBridge.java:34), `public boolean moveArrows = true;` (ItemBridge.java:35), `public boolean pulse = false;` (ItemBridge.java:36), `public float arrowSpacing = 4f, arrowOffset = 2f, arrowPeriod = 0.4f;` (ItemBridge.java:37), `public float arrowTimeScl = 6.2f;` (ItemBridge.java:38), `public float bridgeWidth = 6.5f;` (ItemBridge.java:39); constructor `update = true;` (ItemBridge.java:45), `solid = true;` (ItemBridge.java:46), `underBullets = true;` (ItemBridge.java:47), `hasPower = true;` (ItemBridge.java:48), `itemCapacity = 10;` (ItemBridge.java:49), `configurable = true;` (ItemBridge.java:50), `hasItems = true;` (ItemBridge.java:51). Build fields: `public int link = -1;` (ItemBridge.java:198), `public IntSeq incoming = new IntSeq(false, 4);` (ItemBridge.java:199), `public float warmup;` (ItemBridge.java:200), `public float time = -8f, timeSpeed;` (ItemBridge.java:201), `public boolean wasMoved, moved, hadValidLink;` (ItemBridge.java:202), `public float transportCounter;` (ItemBridge.java:203). canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) are the surrounding gates. The single def carries `consumePower(0.30f);` (Blocks.java:2396) with `range = 12;` (Blocks.java:2388) and `liquidCapacity = 100f;` (Blocks.java:2395). No sense / read / write overrides exist on LiquidBridgeBuild -- those wait for their own slices only if a later Java line needs them.
	# Single def -- phase-conduit only (size 1, range 12, liquidCapacity 100f, phase-fabric 5 / silicon 7 / metaglass 20 / titanium 10, Blocks.java:2385-2397). bridge-conduit (LiquidBridge, no power def, `hasPower = false;`, Blocks.java:2380) is explicitly OUT of scope; reinforced-bridge-conduit (DirectionLiquidBridge, Blocks.java:2432, different class, hasPower false) is explicitly OUT of scope.
	# Documented limits: (1) power-only first pass -- the phase-conduit's static power consumer (consumePower 0.30f, Blocks.java:2396) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); phase-conduit has no second consumer. (2) shouldConsume gate live (N2198) -- LiquidBridgeBuild inherits ItemBridgeBuild.shouldConsume (`return hadValidLink && enabled;`, ItemBridge.java:495-496); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the pure gate feeds had_valid_link && enabled to the machinery, and the driver recomputes had_valid_link every tick after the consumption fold through N2197's pure linkValid. (3) updateTransport advance live (N2275) -- warmup gate / moveLiquid / moved flag (LiquidBridge.java:22-26) run every enabled tick after the consumption fold through the pure source_liquid_bridge_update_transport_state function; the moveLiquid reaction branch (BuildingComp.java:954-976) and doDump (LiquidBridge.java:29-31) defer (Java itself TODOs the reaction as wrong for multi-liquid blocks; no neighbor dump wiring), and the timerCheckMoved snapshot (ItemBridge.java:320-323) defers (no timer infra), so moved is set by the transfer but never snapshots into wasMoved. The power proof carries no transport/warmup/move keys; the N2275 proof carries the transport keys. (4) No sense/warmup modeling -- `warmup()` has no override here (draw-only warmup, ItemBridge.java:387) and sense waits for its own slice. (5) Single def -- phase-conduit only (size 1, range 12, liquidCapacity 100f, phase-fabric 5 / silicon 7 / metaglass 20 / titanium 10); bridge-conduit (LiquidBridge, no power def) and reinforced-bridge-conduit (DirectionLiquidBridge, different class) are explicitly OUT of scope; per-def stat values wait for their own verification slice. (6) No draw/config-UI modeling -- the config handlers (ItemBridge.java:64/66) are covered by N2197's pure configure (reused, not copied), but bridge draw / drawSelect / drawConfigure (ItemBridge.java:216-296, 375-394, inherited) and placement auto-link (playerPlaced / findLink / lastBuild, ItemBridge.java:167-173, 211) wait for their own slices (N2199).
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func _to_short(value: int) -> int:
	# The Java (short) cast: truncate to the low 16 bits, then sign-extend (Point2.pack/unpack cast through short, arc Point2.java:35-42); GDScript ints are 64-bit, so the wrap is explicit. A private copy of the N2197 helper (the N2191 slerpDelta local precedent): the ItemBridge copies are private, and this slice must not touch the ItemBridge file (N2188 edits it in parallel) -- the arc Point2 primitives are duplicated, the linkValid/configure logic is reused, not copied.
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

static func source_liquid_bridge_should_consume_state(frame: Dictionary) -> Dictionary:
	# LiquidBridgeBuild inherits ItemBridgeBuild.shouldConsume (ItemBridge.java:495, `public boolean shouldConsume(){` with `return hadValidLink && enabled;`, ItemBridge.java:496): the liquid bridge consumes only while its link is valid and it is enabled. LiquidBridge extends ItemBridge (LiquidBridge.java:7, `public class LiquidBridge extends ItemBridge{`) and LiquidBridgeBuild extends ItemBridgeBuild (LiquidBridge.java:19, `public class LiquidBridgeBuild extends ItemBridgeBuild{`), overriding only updateTransport and doDump (LiquidBridge.java:22-31) -- the gate is inherited verbatim, so the pure gate reads the same two frame keys Java reads: had_valid_link (the driver recompute, ItemBridge.java:332-333, `Tile other = world.tile(link);` / `hadValidLink = linkValid(tile, other);`) and enabled (Building.enabled, BuildingComp.java:77, default true). When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The gate reads the previous tick's had_valid_link -- updateConsumption runs before updateTile (BuildingComp.java:2274-2277), so the recompute lands after the fold; correct per Java, not a bug.
	var had_valid_link: bool = bool(frame.get("had_valid_link", false))
	var enabled: bool = bool(frame.get("enabled", true))
	return {"should_consume": had_valid_link and enabled, "had_valid_link": had_valid_link}

static func source_liquid_bridge_update_transport_state(frame: Dictionary, source_delta: float, liquid_capacity: float, liquid_pressure: float, had_valid_link: bool, liquids: Dictionary, partner: Dictionary) -> Dictionary:
	# The updateTile transport advance (LiquidBridgeBuild.updateTransport(), LiquidBridge.java:22-26,
	# `public void updateTransport(Building other){` with `if(warmup >= 0.25f){` and
	# `moved |= moveLiquid(other, liquids.current()) > 0.05f;`, over the inherited ItemBridgeBuild.updateTile(),
	# `public void updateTile(){`, ItemBridge.java:319-348), on `public class LiquidBridge extends ItemBridge{`
	# (LiquidBridge.java:7) / `public class LiquidBridgeBuild extends ItemBridgeBuild{` (LiquidBridge.java:19).
	# Constructor: `hasItems = false;` (LiquidBridge.java:11), `hasLiquids = true;` (LiquidBridge.java:12).
	# Build fields: `public float warmup;` (ItemBridge.java:200), `public boolean wasMoved, moved, hadValidLink;`
	# (ItemBridge.java:202), `public int link = -1;` (ItemBridge.java:198).
	# Java order, step by step. `Tile other = world.tile(link);` / `hadValidLink = linkValid(tile, other);`
	# (ItemBridge.java:332-333) is N2197's recompute, NOT redone here: the driver passes the fresh value in, the Java
	# order (updateConsumption before updateTile, BuildingComp.java:2274-2277, `updateConsumption();`
	# then `if(enabled || !block.noUpdateDisabled){` / `updateTile();`).
	# `if(!hadValidLink){` (ItemBridge.java:335): `doDump();` (ItemBridge.java:336, deferred --
	# `public void doDump(){` / `dumpLiquid(liquids.current(), 1f);`, LiquidBridge.java:29-31, needs proximity +
	# neighbor liquid transfer the bridge driver does not gather) and `warmup = 0f;` (ItemBridge.java:337).
	# Else: `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);` (ItemBridge.java:345) and
	# `updateTransport(other.build);` (ItemBridge.java:346). The timer snapshot defers (no timer helper in the port):
	# `if(timer(timerCheckMoved, 30f)){` / `wasMoved = moved;` / `moved = false;` (ItemBridge.java:320-323);
	# the timeSpeed / time / checkIncoming / incoming-registration steps (ItemBridge.java:326-344) also defer --
	# time/timeSpeed are draw-only, and incoming is never read by the liquid updateTransport override (it feeds only
	# the item handoff and the checkAccept facing path, ItemBridge.java:445-458, which the transport path skips via
	# the linked() shortcut below).
	# moveLiquid (BuildingComp.java:938-978): `public float moveLiquid(Building next, Liquid liquid){`,
	# `if(next == null) return 0;` (BuildingComp.java:939), `next = next.getLiquidDestination(self(), liquid);`
	# (BuildingComp.java:941) -- `public Building getLiquidDestination(Building from, Liquid liquid){` with
	# `return self();` (BuildingComp.java:980-982), the default; no override exists on ItemBridge or LiquidBridge,
	# so the destination is the partner itself. `if(next.team == team && next.block.hasLiquids && liquids.get(liquid) > 0f){`
	# (BuildingComp.java:943): `float ofract = next.liquids.get(liquid) / next.block.liquidCapacity;`
	# (BuildingComp.java:944), `float fract = liquids.get(liquid) / block.liquidCapacity * block.liquidPressure;`
	# (BuildingComp.java:945), `float flow = Math.min(Mathf.clamp((fract - ofract)) * (block.liquidCapacity), liquids.get(liquid));`
	# (BuildingComp.java:946), `flow = Math.min(flow, next.block.liquidCapacity - next.liquids.get(liquid));`
	# (BuildingComp.java:947). `if(flow > 0f && ofract <= fract && next.acceptLiquid(self(), liquid)){`
	# (BuildingComp.java:949): `next.handleLiquid(self(), liquid, flow);` (BuildingComp.java:950),
	# `liquids.remove(liquid, flow);` (BuildingComp.java:951), `return flow;` (BuildingComp.java:952).
	# The reaction branch defers: `}else if(!next.block.consumesLiquid(liquid) && next.liquids.currentAmount() / next.block.liquidCapacity > 0.1f && fract > 0.1f){`
	# (BuildingComp.java:954) -- Java itself TODOs it as wrong for multi-liquid blocks, so the advance returns 0 on
	# the else-if path, exactly as Java falls through to `return 0;` (BuildingComp.java:977) when the branch does
	# not transfer. `public void handleLiquid(Building source, Liquid liquid, float amount){` with
	# `liquids.add(liquid, amount);` (BuildingComp.java:872-874).
	# acceptLiquid here is the ItemBridge OVERRIDE (ItemBridge.java:434-439), NOT the BuildingComp default
	# (`public boolean acceptLiquid(Building source, Liquid liquid){` with `return block.hasLiquids && block.consumesLiquid(liquid);`,
	# BuildingComp.java:868-870): `hasLiquids && team == source.team &&` (ItemBridge.java:435),
	# `(liquids.current() == liquid || liquids.get(liquids.current()) < 0.2f) &&` (ItemBridge.java:436),
	# `checkAccept(source, world.tile(link));` (ItemBridge.java:437). checkAccept returns true through the linked()
	# shortcut: `if(tile == null || linked(source)) return true;` (ItemBridge.java:442) with
	# `return source instanceof ItemBridgeBuild && linkValid(source.tile, tile) && ((ItemBridgeBuild)source).link == pos();`
	# (ItemBridge.java:465). linked() is ALWAYS true when hadValidLink holds: linkValid(this, partner) with checkDouble
	# is the same condition both ways, and source.link == partner pos by construction -- so acceptLiquid in the
	# transport path is the current-liquid gate only (partner current == liquid, or partner current amount < 0.2f),
	# and the facing path (`int rel = relativeTo(link);` / `var facing = Edges.getFacingEdge(source, this);` /
	# `return rel != rel2;`, ItemBridge.java:445-458) defers for non-linked sources.
	# The liquid store is the sprite liquids meta (SourceLiquidModuleState: amounts array by liquid id + current id):
	# `private Liquid current = content.liquid(0);` (LiquidModule.java:24), `public Liquid current(){`
	# (LiquidModule.java:81-83), `public float get(Liquid liquid){` with `return liquids[liquid.id];`
	# (LiquidModule.java:102-104), `public void add(Liquid liquid, float amount){` with `liquids[liquid.id] += amount;`
	# and `current = liquid;` (LiquidModule.java:110-113), `public void remove(Liquid liquid, float amount){` with
	# `add(liquid, Math.max(-amount, -liquids[liquid.id]));` (LiquidModule.java:124-127), `public float currentAmount(){`
	# with `return liquids[current.id];` (LiquidModule.java:98-100). The pure mirrors add/remove exactly on
	# DUPLICATED stores (the PayloadUnloader N2232 precedent): the remove caps at the stored amount (flow is already
	# capped by have, so no negative), the add sets the partner current to the moved liquid, and the self current is
	# unchanged (remove goes through add with the same liquid). The flow cache is untouched: flow is null in the
	# port's initial state, so cacheSums never apply (LiquidModule.java:114-116).
	# approachDelta scales by RAW Time.delta (arc Mathf.java:420-422, `return approach(from, to, Time.delta * speed);`),
	# never by delta() -- so the warmup step uses the unscaled source delta through
	# SourceMathState.source_approach_delta. Mathf.clamp(value) clamps to [0, 1] (arc Mathf.java:402-404,
	# `return Math.max(Math.min(value, 1f), 0f);`). efficiency is `transient float efficiency;`
	# (BuildingComp.java:85), default 0.0. The capacity guards mirror the N2225 transport_time guard (Java would
	# divide by zero on a 0 capacity; the def consts are 100f / 1f). `liquidCapacity = 100f;`
	# (Blocks.java:2395, shared by bridge-conduit, Blocks.java:2381) with `range = 12;` (Blocks.java:2388);
	# `public float liquidPressure = 1f;` (Block.java:79, the phase-conduit def does not override it).
	# Returns the advanced warmup / moved / flow plus the two liquid stores after the transfer; the driver writes
	# both stores back to their sprite metas. was_moved is NOT returned -- only the deferred timer branch changes
	# it, so it stays out of the frame entirely.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var warmup: float = float(frame.get("warmup", 0.0))
	var moved: bool = bool(frame.get("moved", false))
	var flow: float = 0.0
	var liquids_after: Dictionary = (liquids as Dictionary).duplicate(true)
	var partner_liquids: Dictionary = partner.get("liquids", {})
	var partner_liquids_after: Dictionary = (partner_liquids as Dictionary).duplicate(true)
	if not had_valid_link:
		warmup = 0.0
	else:
		warmup = source_math_state.source_approach_delta(warmup, efficiency, SOURCE_LIQUID_BRIDGE_WARMUP_RATE, source_delta)
		if warmup >= 0.25 and bool(partner.get("exists", false)):
			var partner_team_matches: bool = bool(partner.get("team_matches", false))
			var partner_has_liquids: bool = bool(partner.get("has_liquids", false))
			var partner_capacity: float = float(partner.get("liquid_capacity", 0.0))
			var self_amounts: Array = liquids_after.get("liquids", [])
			var partner_amounts: Array = partner_liquids_after.get("liquids", [])
			var liquid_id: int = int(liquids_after.get("current", -1))
			var have: float = 0.0
			if liquid_id >= 0 and liquid_id < self_amounts.size():
				have = float(self_amounts[liquid_id])
			if partner_team_matches and partner_has_liquids and have > 0.0 and liquid_capacity > 0.0 and partner_capacity > 0.0 and liquid_id < partner_amounts.size():
				var partner_have: float = float(partner_amounts[liquid_id])
				var ofract: float = partner_have / partner_capacity
				var fract: float = have / liquid_capacity * liquid_pressure
				flow = minf(clampf(fract - ofract, 0.0, 1.0) * liquid_capacity, have)
				flow = minf(flow, partner_capacity - partner_have)
				var partner_current: int = int(partner_liquids_after.get("current", -1))
				var partner_current_amount: float = 0.0
				if partner_current >= 0 and partner_current < partner_amounts.size():
					partner_current_amount = float(partner_amounts[partner_current])
				var accepts: bool = partner_current == liquid_id or partner_current_amount < 0.2
				if flow > 0.0 and ofract <= fract and accepts:
					self_amounts[liquid_id] = have - flow
					partner_amounts[liquid_id] = partner_have + flow
					partner_liquids_after["current"] = liquid_id
				else:
					flow = 0.0
			if flow > 0.05:
				moved = true
	return {"warmup": warmup, "moved": moved, "flow": flow, "liquids_after": liquids_after, "partner_liquids_after": partner_liquids_after}

static func source_liquid_bridge_auto_link_placement_state(game: Object, sprite: Sprite2D, block, cell: Vector2i) -> Dictionary:
	# The liquid-bridge placement auto-link driver (N2199): LiquidBridgeBuild extends ItemBridgeBuild with no playerPlaced override (LiquidBridge.java:19, `public class LiquidBridgeBuild extends ItemBridgeBuild{`; LiquidBridge.java:7, `public class LiquidBridge extends ItemBridge{`), so the liquid twin reuses the item-bridge pures (source_item_bridge_find_link_state / source_item_bridge_player_placed_state / source_item_bridge_configure_state) through the preload, the N2198 precedent -- no new liquid symbols. The driver mirrors the item driver exactly: it binds this liquid frame if the tick has not bound it yet, reads the same game lastBuild store (`source_item_bridge_last_build_by_block`, keyed by block id -- the liquid defs get their own per-def entries, phase-conduit and bridge-conduit never share a lastBuild), gathers the partner with the STRICT def match (other block id == this block id, ItemBridge.java:152 -- a phase-conduit must not auto-link to a bridge-conduit), calls the pure playerPlaced, applies the Integer configure to the partner liquid frame through the N2197 pure configure (`config(Integer.class, (ItemBridgeBuild tile, Integer i) -> tile.link = i);`, ItemBridge.java:66), and records this cell as the new lastBuild for the def (`lastBuild = this;`, ItemBridge.java:218). The partner frame is bound through the liquid bind (the partner of a liquid bridge is a liquid bridge of the same def); a missing or replaced partner fails the match and configures nothing -- the lastBuild update still happens. Returns {"applied": ..., "configure_other": ..., "other_cell": ..., "new_last_build_cell": ...}.
	if game == null or block == null or sprite == null or not is_instance_valid(sprite):
		return {"applied": false, "configure_other": false, "other_cell": Vector2i.ZERO, "new_last_build_cell": cell}
	if not _is_liquid_bridge_build_implementation(str(block.implementation)):
		return {"applied": false, "configure_other": false, "other_cell": Vector2i.ZERO, "new_last_build_cell": cell}
	var bound: Dictionary = source_liquid_bridge_bind_frame_state(sprite, block)
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
						var partner_bound: Dictionary = source_liquid_bridge_bind_frame_state(partner_sprite, other_block)
						partner_frame = partner_bound.get("frame", {})
						last_build_link = int(partner_frame.get("link", -1))
						partner_cell = last_build_cell
	var link_range: int = int(block.properties.get("range", 0))
	var decision: Dictionary = source_item_bridge_build_state.source_item_bridge_player_placed_state(cell.x, cell.y, true, this_link, last_build_cell, last_build_exists, last_build_link, link_range, blocks_match, teams_match, is_adjacent)
	var configure_other: bool = bool(decision.get("configure_other", false))
	var other_cell: Vector2i = decision.get("other_cell", Vector2i.ZERO)
	if configure_other and not partner_frame.is_empty():
		var configured: Dictionary = source_item_bridge_build_state.source_item_bridge_configure_state(partner_frame, int(decision.get("config_value", -1)), partner_cell.x, partner_cell.y)
		partner_frame["link"] = int(configured.get("link", -1))
	last_builds[block_id] = cell
	game.set("source_item_bridge_last_build_by_block", last_builds)
	return {"applied": true, "configure_other": configure_other, "other_cell": other_cell, "new_last_build_cell": cell}

@warning_ignore("unused_parameter")
static func source_liquid_bridge_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the liquid-bridge tick wiring every
	# tick (LiquidBridgeBuild.updateTransport(), LiquidBridge.java:22,
	# moves liquid only once the warmup gate (LiquidBridge.java:23, `if(warmup >= 0.25f){`) passes, and warmup follows the folded efficiency through the inherited ItemBridge updateTile (ItemBridge.java:345, `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);`), so the warmup gate follows the folded efficiency; no placed-buildings driver ticks LiquidBridge blocks, so this driver is the placed-liquid-bridge tick): each placed LiquidBridge build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_liquid_bridge_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_liquid_bridge_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_liquid_bridge_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a liquid bridge with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the warmup gate (LiquidBridge.java:23, `if(warmup >= 0.25f){`)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a phase-conduit does not take the early return. The liquid bridge's power draw is STATIC: `consumePower(0.30f);` (Blocks.java:2396) registers a plain ConsumePower, so the catalog consumePower 0.3 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. A liquid bridge with no power consumer is untouched: the tick models no other consumers yet (the updateTransport advance is live since N2275 and runs below, after the link recompute), and LiquidBridgeBuild inherits ItemBridgeBuild.shouldConsume (ItemBridge.java:495, `public boolean shouldConsume(){` with `return hadValidLink && enabled;`, ItemBridge.java:496) -- N2198 feeds the live gate to the machinery (the pure gate is source_liquid_bridge_should_consume_state, fed the frame's had_valid_link and enabled); the N2179 RED decision is resolved. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_liquid_bridge_should_consume_state(frame)
			var should_consume: bool = bool(frame.get("enabled", true)) and bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_liquid_bridge_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		# The updateTile link recompute (ItemBridge.java:332-333, `Tile other = world.tile(link);` / `hadValidLink = linkValid(tile, other);`), inherited by LiquidBridgeBuild (LiquidBridge.java:19): updateConsumption runs BEFORE updateTile (BuildingComp.java:2274-2277, `updateConsumption();` then `if(enabled || !block.noUpdateDisabled){` / `updateTile();`), so this recompute runs AFTER the consumption fold above -- and only when enabled (ItemBridge `noUpdateDisabled = true;`, ItemBridge.java:54, inherited through the super constructor: a disabled bridge never runs updateTile, so its had_valid_link freezes instead of clearing). The linkValid evaluation is N2197's pure function, reused through the ItemBridge preload -- the LiquidBridge driver gathers the inputs (the partner must be a LiquidBridge: the block clause, ItemBridge.java:152, with `this` the LiquidBridge block; the partner's link comes from its own liquid-bridge frame) and the pure function decides. The partner sprite is looked up through placed_blocks by the unpacked link cell (Point2.unpack, arc Point2.java:35-37, `return new Point2((short)(pos >>> 16), (short)(pos & 0xFFFF));`); a missing sprite or a partner that is not a LiquidBridge fails the block match, and the partner's team is read the same way as this sprite's (SOURCE_BUILD_TEAM_META_KEY, default derelict).
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
					other_blocks_match = _is_liquid_bridge_build_implementation(str(other_block.implementation))
				var other_team_id: int = int(other_sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
				other_teams_match = other_team_id == team_id
				var other_frame: Variant = other_sprite.get_meta(SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})
				if other_frame is Dictionary:
					other_link = int(other_frame.get("link", -1))
			var link_range: int = int(block.properties.get("range", 0))
			var this_pos: int = _point2_pack(cell.x, cell.y)
			frame["had_valid_link"] = bool(source_item_bridge_build_state.source_item_bridge_link_valid_state(cell.x, cell.y, other_cell.x, other_cell.y, link_range, other_blocks_match, other_teams_match, other_link, this_pos, other_exists, true).get("had_valid_link", false))
			# The updateTile transport advance (N2275, LiquidBridge.java:22-26 over ItemBridge.java:319-348):
			# runs after the recompute above -- Java recomputes hadValidLink inside updateTile before the branch
			# (ItemBridge.java:332-333), and the warmup approach + updateTransport follow it (ItemBridge.java:345-346)
			# -- and only when enabled (ItemBridge `noUpdateDisabled = true;`, ItemBridge.java:54: a disabled bridge
			# freezes its transport state). The driver gathers the liquid stores (the sprite liquids meta, bound at
			# placement by PortGame through source_initialize_building_liquids_state; a sprite that somehow lacks one
			# gets it bound here instead of crashing the loop, the N2149 pattern) and the partner snapshot (the
			# placed_blocks lookup the recompute already did: the partner exists and is a LiquidBridge, its team
			# matches, it hasLiquids by construction -- `hasLiquids = true;`, LiquidBridge.java:12 -- and its
			# capacity is the same def constant, both LiquidBridge defs carrying `liquidCapacity = 100f;`,
			# Blocks.java:2381/2395). The source delta is Time.delta in ticks: game_source_delta(game, seconds) is
			# seconds * 60 (arc Time.java:26), never raw seconds. The pure advance returns the advanced warmup /
			# moved plus both liquid stores after the transfer, which the driver writes back to the frame and to
			# both sprite metas (the PayloadUnloader N2232 precedent: the pure returns duplicates, it does not
			# mutate the synced store in place). The partner frame is NOT written -- only its liquids meta moves.
			var liquids: Dictionary = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
			if liquids.is_empty():
				liquids = source_placed_block_state.source_initialize_building_liquids_state(sprite, true, catalog).get("liquids", {})
			var partner_liquids: Dictionary = {}
			if other_exists:
				partner_liquids = other_sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
				if partner_liquids.is_empty() and other_blocks_match:
					partner_liquids = source_placed_block_state.source_initialize_building_liquids_state(other_sprite, true, catalog).get("liquids", {})
			var partner: Dictionary = {"exists": other_exists and other_blocks_match, "team_matches": other_teams_match, "has_liquids": other_blocks_match, "liquid_capacity": SOURCE_LIQUID_BRIDGE_LIQUID_CAPACITY, "liquids": partner_liquids}
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var advanced: Dictionary = source_liquid_bridge_update_transport_state(frame, source_delta, SOURCE_LIQUID_BRIDGE_LIQUID_CAPACITY, SOURCE_LIQUID_BRIDGE_LIQUID_PRESSURE, bool(frame.get("had_valid_link", false)), liquids, partner)
			frame["warmup"] = advanced["warmup"]
			frame["moved"] = advanced["moved"]
			sprite.set_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, advanced["liquids_after"])
			if other_exists and other_blocks_match:
				other_sprite.set_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, advanced["partner_liquids_after"])
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
