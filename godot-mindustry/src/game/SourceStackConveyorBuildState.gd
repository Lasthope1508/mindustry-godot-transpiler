extends RefCounted
class_name SourceStackConveyorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_drill_inventory_runtime_state := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")

# The StackConveyor implementation (StackConveyor.java:24, `public class StackConveyor extends Block implements Autotiler{`): surge-conveyor (consumePower 1f/60f, Blocks.java:2251, `consumePower(1f / 60f);`; size 1, speed 5f/60f, itemCapacity 10, health 130, surge-alloy 1 / tungsten 1, Blocks.java:2237-2253). StackConveyor extends Block, NOT a factory or crafter or bridge, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_stack_conveyor_building", the radar precedent), and this slice adds the stack-conveyor key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceStackConveyor* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the StackConveyorBuild.updateTile reels items in at a rate that follows the folded efficiency (StackConveyor.java:270, `float eff = enabled ? (efficiency + baseEfficiency) : 1f;` with StackConveyor.java:273, `if(cooldown > 0f) cooldown = Mathf.clamp(cooldown - speed * eff * delta(), 0f, recharge);`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) -- so a surge-conveyor with no power would reel slower and draw no glow, as if power.status were 1.0. The surge def carries `baseEfficiency = 1f;` (Blocks.java:2250), so at efficiency 0 the belt STILL reels at eff 1f -- power raises eff toward 2f and lights the glow (StackConveyor.java:156, `if(glowRegion.found() && power != null && power.status > 0f){` with StackConveyor.java:158, `Draw.color(glowColor, glowAlpha * power.status);`); the glow is the only hard power gate on this family.
const SOURCE_STACK_CONVEYOR_BUILD_IMPLEMENTATIONS := ["StackConveyor"]
const SOURCE_STACK_CONVEYOR_BUILDING_META_KEY := "source_stack_conveyor_building"
# StackConveyor.java:25, `protected static final int stateMove = 0, stateLoad = 1, stateUnload = 2;` -- the
# state machine values (set by onProximityUpdate, StackConveyor.java:217-261, deferred; the advance reads
# state as a frame input and never writes it).
const SOURCE_STACK_CONVEYOR_STATE_MOVE := 0
const SOURCE_STACK_CONVEYOR_STATE_LOAD := 1
const SOURCE_STACK_CONVEYOR_STATE_UNLOAD := 2
# StackConveyor.java:41, `public float recharge = 2f;` -- the cooldown clamp ceiling and the cooldown set
# on transfer (StackConveyor.java:311, `cooldown = recharge;`); StackConveyor.java:52, `itemCapacity = 10;`
# -- getMaximumAccepted(lastItem) is block.itemCapacity (BuildingComp.java:781-783), the transfer gate
# when state == stateLoad. Both are class defaults shared by both defs.
const SOURCE_STACK_CONVEYOR_RECHARGE := 2.0
const SOURCE_STACK_CONVEYOR_ITEM_CAPACITY := 10
# The per-def speed / baseEfficiency / outputRouter (Blocks.java): plastanium-conveyor `speed = 4f / 60f;`
# (:2087), outputRouter true (class default, StackConveyor.java:39), baseEfficiency 0f (class default,
# StackConveyor.java:37); surge-conveyor `speed = 5f / 60f;` (:2241), `outputRouter = false;` (:2244),
# `baseEfficiency = 1f;` (:2250). The catalog carries NEITHER def's speed / baseEfficiency / outputRouter
# (content_registry.json holds only consumePower / hasPower / itemCapacity / health / requirements for
# surge/plastanium-conveyor), so the driver reads these tables (the N2219 BurstDrill precedent), falling
# back to the class defaults (speed 0f, baseEfficiency 0f, outputRouter true).
const SOURCE_STACK_CONVEYOR_SPEED := {"plastanium-conveyor": 4.0 / 60.0, "surge-conveyor": 5.0 / 60.0}
const SOURCE_STACK_CONVEYOR_BASE_EFFICIENCY := {"plastanium-conveyor": 0.0, "surge-conveyor": 1.0}
const SOURCE_STACK_CONVEYOR_OUTPUT_ROUTER := {"plastanium-conveyor": true, "surge-conveyor": false}

static func _is_stack_conveyor_build_implementation(implementation: String) -> bool:
	return SOURCE_STACK_CONVEYOR_BUILD_IMPLEMENTATIONS.has(implementation)

static func _to_short(value: int) -> int:
	# The Java (short) cast: truncate to the low 16 bits, then sign-extend (Point2.pack/unpack cast through short, arc Point2.java:35-42); GDScript ints are 64-bit, so the wrap is explicit (the N2197 ItemBridge precedent).
	var truncated: int = value & 0xFFFF
	if truncated >= 0x8000:
		return truncated - 0x10000
	return truncated

static func _point2_pack(x: int, y: int) -> int:
	# Point2.pack (arc Point2.java:40-42, `return (((short)x) << 16) | (((short)y) & 0xFFFF);`).
	return (_to_short(x) << 16) | (_to_short(y) & 0xFFFF)

static func source_stack_conveyor_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The stack-conveyor tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (StackConveyor.java:24, `public class StackConveyor extends Block implements Autotiler{`; StackConveyorBuild, StackConveyor.java:114, `public class StackConveyorBuild extends Building{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# stack conveyor skips consumption like Java's updateConsumption
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
	# for this stack conveyor (N2125); the tick preserves a disabled
	# stack conveyor instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# The Java build-field defaults (StackConveyor.java:115-119): state 0 = stateMove (the Java int
	# default), link -1, cooldown 0f, lastItem null, items {} (the N2180 driver bound an empty frame and
	# had NO items frame key; the N2239 advance reads and writes all five).
	return {"state": 0, "link": -1, "cooldown": 0.0, "last_item": null, "items": {}}

static func source_stack_conveyor_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the stack-conveyor frame meta key
	# ("source_stack_conveyor_building"). A StackConveyor sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_stack_conveyor_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_STACK_CONVEYOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_STACK_CONVEYOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_STACK_CONVEYOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_stack_conveyor_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a surge-conveyor does not take the early return. The stack conveyor's power draw is STATIC, not conditional: `consumePower(1f / 60f);` (Blocks.java:2251) registers a plain ConsumePower, so the catalog consumePower 0.0167 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The stack conveyor's updateTile (StackConveyor.java:270, `float eff = enabled ? (efficiency + baseEfficiency) : 1f;` with StackConveyor.java:273, `if(cooldown > 0f) cooldown = Mathf.clamp(cooldown - speed * eff * delta(), 0f, recharge);`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) reels items at a rate that follows the folded efficiency -- and because the surge def sets `baseEfficiency = 1f;` (Blocks.java:2250), the belt still reels at eff 1f with no power; power raises eff toward 2f and lights the glow (StackConveyor.java:156, `if(glowRegion.found() && power != null && power.status > 0f){` with StackConveyor.java:158, `Draw.color(glowColor, glowAlpha * power.status);`). The glow is the only hard power gate on this family.
	# StackConveyorBuild has NO shouldConsume override, so the BuildingComp default applies (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). There is NO gate to defer here (unlike the ItemBridge / LiquidBridge link gates): the power-only fold is EXACT, because the only gate is `enabled`, which the driver already checks. canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and edelta (BuildingComp.java:1927-1929, `return efficiency * delta();`) are the surrounding gates. The single def carries `consumePower(1f / 60f);` (Blocks.java:2251) with `baseEfficiency = 1f;` (Blocks.java:2250), `outputRouter = false;` (Blocks.java:2244), `speed = 5f / 60f;` (Blocks.java:2241), `health = 130;` (Blocks.java:2239), `hasPower = true;` (Blocks.java:2245), `consumesPower = true;` (Blocks.java:2246) and `conductivePower = true;` (Blocks.java:2247).
	# The stack conveyor is its own family (StackConveyor.java:24, `public class StackConveyor extends Block implements Autotiler{`; StackConveyorBuild, StackConveyor.java:114, `public class StackConveyorBuild extends Building{`), a distribution block, NOT related to any factory / turret / defense / bridge family. Class fields: `protected static final int stateMove = 0, stateLoad = 1, stateUnload = 2;` (StackConveyor.java:25), `public float glowAlpha = 1f;` (StackConveyor.java:34), `public Color glowColor = Pal.redLight;` (StackConveyor.java:35), `public float baseEfficiency = 0f;` (StackConveyor.java:37), `public float speed = 0f;` (StackConveyor.java:38), `public boolean outputRouter = true;` (StackConveyor.java:39), `public float recharge = 2f;` (StackConveyor.java:41), `public Effect loadEffect = Fx.conveyorPoof;` (StackConveyor.java:42), `public Effect unloadEffect = Fx.conveyorPoof;` (StackConveyor.java:43); constructor `rotate = true;` (StackConveyor.java:48), `update = true;` (StackConveyor.java:49), `group = BlockGroup.transportation;` (StackConveyor.java:50), `hasItems = true;` (StackConveyor.java:51), `itemCapacity = 10;` (StackConveyor.java:52), `conveyorPlacement = true;` (StackConveyor.java:53), `underBullets = true;` (StackConveyor.java:54), `priority = TargetPriority.transport;` (StackConveyor.java:55), `drawCached = true;` (StackConveyor.java:56), `buildingCacheLayer = BuildingCacheLayer.under;` (StackConveyor.java:57), `ambientSound = Sounds.loopConveyor;` (StackConveyor.java:59), `ambientSoundVolume = 0.004f;` (StackConveyor.java:60). Build fields: `public int state, blendprox;` (StackConveyor.java:115), `public int link = -1;` (StackConveyor.java:117), `public float cooldown;` (StackConveyor.java:118), `public Item lastItem;` (StackConveyor.java:119), `boolean proxUpdating = false;` (StackConveyor.java:121). The transfer branch (StackConveyor.java:276, `if(link == -1) return;` with StackConveyor.java:287, `if(!enabled) return;`) returns early without a link or when disabled, and the handoff sets `cooldown = recharge;` (StackConveyor.java:311) with `e.cooldown = 1;` (StackConveyor.java:312).
	# Single def -- surge-conveyor only (size 1, speed 5f/60f, itemCapacity 10, health 130, surge-alloy 1 / tungsten 1, Blocks.java:2237-2253). plastanium-conveyor (StackConveyor, no power def, NO hasPower line, Blocks.java:2084) is explicitly OUT of scope. No sense / read / write overrides exist on StackConveyorBuild -- those wait for their own slices only if a later Java line needs them.
	# Documented limits: (1) power-only first pass -- the surge-conveyor's static power consumer (consumePower 1f/60f, Blocks.java:2251) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); surge-conveyor has no second consumer. (2) NO shouldConsume gate to defer -- StackConveyorBuild has no shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-756) applies; the power-only fold is EXACT for this family. (3) updateTile advance LIVE (N2239) -- eff fold / cooldown reel / link gate / transfer branch / unload branch (StackConveyor.java:268-315) run every tick through the pure source_stack_conveyor_update_tile_advance_state; still deferred: the moveForward/dump application (BuildingComp.java:1129-1137 / 1072-1113, the driver passes move_forward_ok / dump_ok false), the live front() query (BuildingComp.java:550-554, the driver passes no-front), and the live items intake (acceptStack / handleStack, StackConveyor.java:344-363). (4) No sense modeling -- sense waits for its own slice. (5) Power row single def -- surge-conveyor only (size 1, speed 5f/60f, itemCapacity 10, health 130, surge-alloy 1 / tungsten 1); plastanium-conveyor (StackConveyor, no power def) has no power row, but the N2239 updateTile advance covers BOTH defs through the per-def tables (plastanium speed 4f/60f, outputRouter true, baseEfficiency 0f; surge speed 5f/60f, outputRouter false, baseEfficiency 1f). (6) Draw rows live (N2434) -- the draw pure (source_stack_conveyor_draw_state) models drawCached() + draw() (StackConveyor.java:124-192: cached base rect + edge rects + load/unload input slices + glow by power.status + interpolated stack + sized item). Pure-only: the tick never calls draw -- draw is called by the renderer, and the renderer call site waits for a renderer slice. drawSelect / config wait for their own slices. (7) Blends / plan / rotatedOutput rows live (N2448) -- the blends pure (source_stack_conveyor_blends_state) models blends() (StackConveyor.java:71-88) with every geometry / indexer predicate caller-supplied, the plan pure (source_stack_conveyor_draw_plan_state) models drawPlanRegion() (StackConveyor.java:90-104) with the getTiling bits caller-supplied, and the rotated-output pure (source_stack_conveyor_rotated_output_state) models rotatedOutput() (StackConveyor.java:106-112). Pure-only: the tick never calls blends / drawPlanRegion / rotatedOutput -- the blending / placement-renderer call sites wait for their own slices. setStats (:64-68) -- see (8). (8) SetStats rows live (N2457) -- the stats pure (source_stack_conveyor_stats_state) models setStats() (StackConveyor.java:64-68: stats.add(Stat.itemsMoved, Mathf.round(itemCapacity * speed * 60), StatUnit.itemsSecond), round(10*0*60) = 0 at the class defaults, 40 for plastanium-conveyor, 50 for surge-conveyor; Mathf.round is floor(v + 0.5) for non-negative v, arc Mathf.java:500-502). Pure-only: the tick never calls setStats -- the stats UI call site waits for its own slice.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_stack_conveyor_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, speed: float, base_efficiency: float, output_router: bool, recharge: float, item_capacity: int, tile_pos: int, front: Dictionary, move_forward_ok: bool, dump_ok: bool, item_order: Array) -> Dictionary:
	# The updateTile advance (StackConveyorBuild.updateTile(), StackConveyor.java:268-315,
	# `public void updateTile(){`), on `public class StackConveyor extends Block implements Autotiler{` (StackConveyor.java:24) /
	# `public class StackConveyorBuild extends Building{` (StackConveyor.java:114).
	# Class fields: `protected static final int stateMove = 0, stateLoad = 1, stateUnload = 2;` (StackConveyor.java:25),
	# `public float baseEfficiency = 0f;` (StackConveyor.java:37), `public float speed = 0f;` (StackConveyor.java:38),
	# `public boolean outputRouter = true;` (StackConveyor.java:39), `public float recharge = 2f;` (StackConveyor.java:41),
	# `itemCapacity = 10;` (StackConveyor.java:52). Build fields: `public int state, blendprox;` (StackConveyor.java:115),
	# `public int link = -1;` (StackConveyor.java:117), `public float cooldown;` (StackConveyor.java:118),
	# `public Item lastItem;` (StackConveyor.java:119). Defs (Blocks.java): plastanium-conveyor `speed = 4f / 60f;` (:2087),
	# outputRouter true (class default), baseEfficiency 0f (class default); surge-conveyor `speed = 5f / 60f;` (:2241),
	# `outputRouter = false;` (:2244), `baseEfficiency = 1f;` (:2250), `consumePower(1f / 60f);` (:2251).
	# Java order, step by step. `float eff = enabled ? (efficiency + baseEfficiency) : 1f;` (StackConveyor.java:270) --
	# disabled STILL reels at eff 1f ("the item still needs to be reeled in when disabled"). efficiency is
	# `transient float efficiency;` (BuildingComp.java:85); a missing frame value defaults to the no-consumers branch:
	# `if(!block.hasConsumers || cheating()){` / `potentialEfficiency = enabled && productionValid() ? 1f : 0f;` /
	# `efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;` (BuildingComp.java:1944-1946), so a
	# plastanium-conveyor (no consumers) reads 1f when enabled, 0f when disabled (and the fold uses 1f anyway when disabled).
	# `if(cooldown > 0f) cooldown = Mathf.clamp(cooldown - speed * eff * delta(), 0f, recharge);` (StackConveyor.java:273)
	# reels with RAW delta() -- `return Time.delta * timeScale;` (BuildingComp.java:1922-1924), NOT edelta; source_delta is
	# Time.delta in ticks (seconds * 60 through game_source_delta, arc Time.java:26), never raw seconds; timeScale reads
	# `private transient float timeScale = 1f, timeScaleDuration;` (BuildingComp.java:98). The reel runs BEFORE the gates,
	# so it reels even with link == -1 or when disabled. `if(link == -1) return;` (StackConveyor.java:276) and
	# `if(cooldown > 0f) return;` (StackConveyor.java:279) are the early returns. `if(lastItem == null || !items.has(lastItem)){`
	# / `lastItem = items.first();` (StackConveyor.java:282-284): `public @Nullable Item first(){` iterates
	# `for(int i = 0; i < items.length; i++){` in content-id order (ItemModule.java:182-188), so the driver passes the
	# catalog item_names_by_id; with no catalog order the pure falls back to dict order (documented deviation).
	# `public boolean has(Item item){` (ItemModule.java:122) / `public int total(){` (ItemModule.java:174) are the
	# inventory reads. `if(!enabled) return;` (StackConveyor.java:287) -- AFTER the pick, so a disabled conveyor still
	# picks its lastItem. `if(state == stateUnload){ //unload` (StackConveyor.java:289): the loop condition is
	# `while(lastItem != null && !outputRouter ? moveForward(lastItem) : dump(lastItem)){` (StackConveyor.java:290) --
	# `&&` binds tighter than `?:`, so it is (lastItem != null && !outputRouter) ? moveForward : dump: outputRouter=true
	# ALWAYS dumps, even when lastItem is null -- but the pick guarantees lastItem null iff items is empty, and dump(null)
	# on empty items returns false (BuildingComp.java:1072-1074), so the pure guards on last_item != null with no behavior
	# change. `public boolean moveForward(Item item){` (BuildingComp.java:1129-1137 -- NOT in StackConveyor.java, grep at
	# RED): `Building other = front();` / `if(other != null && other.team == team && other.acceptItem(self(), item)){` /
	# `other.handleItem(self(), item);`. `public boolean dump(Item todump){` (BuildingComp.java:1072-1113) removes 1 itself
	# (`items.remove(todump, 1);`, BuildingComp.java:1106), while the moveForward path removes via the explicit
	# `if(!outputRouter){` / `items.remove(lastItem, 1);` (StackConveyor.java:291-293) in the loop body. Both are live
	# neighbour operations -- the application defers; the pure takes explicit move_forward_ok / dump_ok bools (the
	# per-tick live answers, assumed stable within the tick) and drains through the shared inventory helpers
	# (`public void remove(Item item, int amount){` / `amount = Math.min(amount, items[item.id]);`, ItemModule.java:258-261).
	# `if(!items.has(lastItem)){` / `poofOut();` / `lastItem = null;` (StackConveyor.java:295-298): poofOut sets
	# `link = -1;` (StackConveyor.java:342, `unloadEffect.at(this);` is presentation and defers under the existing entry).
	# `}else{ //transfer` (StackConveyor.java:301): `if(state != stateLoad || (items.total() >= getMaximumAccepted(lastItem))){`
	# (StackConveyor.java:302) with `public int getMaximumAccepted(Item item){` / `return block.itemCapacity;`
	# (BuildingComp.java:781-783); `if(front() instanceof StackConveyorBuild e && e.team == team && e.link == -1){`
	# (StackConveyor.java:303) with `public @Nullable Building front(){` (BuildingComp.java:550-554, live -- the pure takes
	# an explicit front dict, the N2225 partner precedent); `e.items.add(items);` (StackConveyor.java:304,
	# `public void add(ItemModule items){`, ItemModule.java:228-232, NO capacity cap in Java, so the pure caps nothing) /
	# `e.lastItem = lastItem;` / `e.link = tile.pos();` / `link = -1;` / `items.clear();` (`public void clear(){`,
	# ItemModule.java:281-284) / `cooldown = recharge;` / `e.cooldown = 1;` (StackConveyor.java:305-312). The transfer fires
	# even with empty items when state != stateLoad (stateMove) -- Java does not check total in that branch. The advance
	# runs after consumption, like Java's Building.update() (`updateConsumption();` then `if(enabled || !block.noUpdateDisabled){`
	# / `updateTile();`, BuildingComp.java:2274-2277; `public boolean noUpdateDisabled = false;`, Block.java:170), so a
	# disabled stack conveyor still reels. state is a frame input (set by onProximityUpdate, StackConveyor.java:217-261,
	# deferred) -- the advance reads it as-is and never writes it. Returns the advanced self values plus the front
	# updates (front_items / front_last_item / front_link / front_cooldown); the driver writes the self values back,
	# and the front write-back waits on the live front() query.
	var enabled: bool = bool(frame.get("enabled", true))
	var efficiency: float = float(frame.get("efficiency", 1.0 if enabled else 0.0))
	var state_value: int = int(frame.get("state", 0))
	var link_value: int = int(frame.get("link", -1))
	var cooldown_value: float = float(frame.get("cooldown", 0.0))
	var last_item: Variant = frame.get("last_item", null)
	var next_items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var front_items: Dictionary = (front.get("items", {}) as Dictionary).duplicate(true)
	var front_last_item: Variant = front.get("last_item", null)
	var front_link: int = int(front.get("link", -1))
	var front_cooldown: float = float(front.get("cooldown", 0.0))
	var unloaded := 0
	var transferred := false
	var eff: float = (efficiency + base_efficiency) if enabled else 1.0
	var scaled_delta: float = source_delta * time_scale
	if cooldown_value > 0.0:
		cooldown_value = clampf(cooldown_value - speed * eff * scaled_delta, 0.0, recharge)
	if link_value != -1 and cooldown_value <= 0.0:
		if last_item == null or int(next_items.get(str(last_item), 0)) <= 0:
			last_item = null
			for candidate in item_order:
				if int(next_items.get(str(candidate), 0)) > 0:
					last_item = str(candidate)
					break
			if last_item == null:
				for key in next_items.keys():
					if int(next_items.get(key, 0)) > 0:
						last_item = str(key)
						break
		if enabled:
			if state_value == SOURCE_STACK_CONVEYOR_STATE_UNLOAD:
				while last_item != null and (move_forward_ok if not output_router else dump_ok):
					var removed_state: Dictionary = source_drill_inventory_runtime_state.remove_item_state(next_items, str(last_item), 1)
					next_items = removed_state.get("drill_items", next_items)
					unloaded += 1
					if int(next_items.get(str(last_item), 0)) <= 0:
						link_value = -1
						last_item = null
						break
			else:
				var items_total: int = source_drill_inventory_runtime_state.items_total(next_items)
				if state_value != SOURCE_STACK_CONVEYOR_STATE_LOAD or items_total >= item_capacity:
					var front_is_stack_conveyor: bool = bool(front.get("is_stack_conveyor", false))
					var front_same_team: bool = bool(front.get("same_team", false))
					if front_is_stack_conveyor and front_same_team and front_link == -1:
						for item_name in next_items.keys():
							var amount: int = int(next_items.get(item_name, 0))
							if amount > 0:
								var added_state: Dictionary = source_drill_inventory_runtime_state.add_item_state(front_items, str(item_name), amount)
								front_items = added_state.get("drill_items", front_items)
						front_last_item = last_item
						front_link = tile_pos
						link_value = -1
						next_items = {}
						cooldown_value = recharge
						front_cooldown = 1.0
						transferred = true
	return {"cooldown": cooldown_value, "link": link_value, "last_item": last_item, "items": next_items, "unloaded": unloaded, "transferred": transferred, "front_items": front_items, "front_last_item": front_last_item, "front_link": front_link, "front_cooldown": front_cooldown}

@warning_ignore("unused_parameter")
static func source_stack_conveyor_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the stack-conveyor tick wiring every
	# tick (StackConveyorBuild.updateTile(), StackConveyor.java:268,
	# reels items in at a rate that follows the folded efficiency
	# (StackConveyor.java:270, `float eff = enabled ? (efficiency + baseEfficiency) : 1f;`, with StackConveyor.java:273, `if(cooldown > 0f) cooldown = Mathf.clamp(cooldown - speed * eff * delta(), 0f, recharge);`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test), so the reel rate follows the folded efficiency; no placed-buildings driver ticks StackConveyor blocks, so this driver is the placed-stack-conveyor tick): each placed StackConveyor build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_stack_conveyor_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_stack_conveyor_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_stack_conveyor_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a stack conveyor with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the reel rate (StackConveyor.java:270-273)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a surge-conveyor does not take the early return. The stack conveyor's power draw is STATIC: `consumePower(1f / 60f);` (Blocks.java:2251) registers a plain ConsumePower, so the catalog consumePower 0.0167 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. A stack conveyor with no power consumer folds no power row: the tick models no other consumers yet, and the updateTile advance (N2239) runs below for both defs. StackConveyorBuild has NO shouldConsume override, so the BuildingComp default applies (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) -- there is NO gate to defer here, the power-only fold is EXACT, because the only gate is `enabled`, which the driver already checks. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_stack_conveyor_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		# N2239: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2278; noUpdateDisabled defaults
		# false, Block.java:170), so a disabled stack conveyor
		# still reels (StackConveyor.java:270, `float eff =
		# enabled ? (efficiency + baseEfficiency) : 1f;` --
		# disabled eff is 1f). The advance runs for BOTH defs
		# and even when disabled: plastanium has no power
		# consumer, so no consumption fold stamps its
		# efficiency -- the pure defaults to the no-consumers
		# branch (BuildingComp.java:1944-1946, efficiency 1f
		# when enabled). The source delta is Time.delta in
		# ticks: game_source_delta(game, seconds) is seconds *
		# 60 (arc Time.java:26), never raw seconds; timeScale
		# reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`). The per-def
		# speed / baseEfficiency / outputRouter come from the
		# per-def tables (the catalog carries none of them, the
		# N2219 precedent); itemCapacity comes from the catalog
		# (10 for both defs). The item order is the catalog
		# item_names_by_id (the content-id order
		# ItemModule.first() iterates, ItemModule.java:182-188).
		# The driver passes the no-front default,
		# move_forward_ok false and dump_ok false -- the live
		# front() query and the neighbour application defer
		# (N2239 DEFERRED entries), so a live stack conveyor
		# reels and picks but never transfers or unloads until
		# those queries land. The advance writes the frame keys
		# back, including the reeled cooldown and the picked
		# lastItem (the live items fill waits on intake).
		var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
		var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
		var block_speed: float = float(SOURCE_STACK_CONVEYOR_SPEED.get(block_id, 0.0))
		var block_base_efficiency: float = float(SOURCE_STACK_CONVEYOR_BASE_EFFICIENCY.get(block_id, 0.0))
		var block_output_router: bool = bool(SOURCE_STACK_CONVEYOR_OUTPUT_ROUTER.get(block_id, true))
		var item_order: Array = source_content_registry_runtime_state.source_item_catalog_state(catalog).get("item_names_by_id", [])
		var this_pos: int = _point2_pack(cell.x, cell.y)
		var advanced: Dictionary = source_stack_conveyor_update_tile_advance_state(frame, source_delta, time_scale, block_speed, block_base_efficiency, block_output_router, SOURCE_STACK_CONVEYOR_RECHARGE, int(block.properties.get("itemCapacity", SOURCE_STACK_CONVEYOR_ITEM_CAPACITY)), this_pos, {}, false, false, item_order)
		frame["cooldown"] = advanced["cooldown"]
		frame["link"] = advanced["link"]
		frame["last_item"] = advanced["last_item"]
		frame["items"] = advanced["items"]
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}

static func source_stack_conveyor_draw_state(x_value: float, y_value: float, rotation_value: int, state_value: int, blendprox: int, near_square: Array, front_square: Variant, link: int, from_world: Variant, from_build_null: bool, last_item: Variant, power_status: float, glow_found: bool, glow_color: String, glow_alpha: float, cooldown: float, items_total: int, item_capacity: int, item_size: float) -> Dictionary:
	# The draw rows (StackConveyorBuild.drawCached(),
	# StackConveyor.java:124-149 + draw(),
	# StackConveyor.java:151-192), the pure draw-call dict
	# -- the port never draws for real (the N2415
	# UnitCargoLoader precedent: the pure returns the
	# draw calls as data). Java draws, in order (each
	# exact expr on ONE comment line, the N2148 lesson):
	# `protected static final int stateMove = 0, stateLoad = 1, stateUnload = 2;`
	# `public @Load(value = "@-#", length = 3) TextureRegion[] regions;`
	# `public @Load("@-edge") TextureRegion edgeRegion;`
	# `public @Load("@-stack") TextureRegion stackRegion;`
	# `public @Load(value = "@-glow") TextureRegion glowRegion;`
	# `public @Load(value = "@-edge-glow", fallback = "@-glow") TextureRegion edgeGlowRegion;`
	# `public float glowAlpha = 1f;`
	# `public Color glowColor = Pal.redLight;`
	# `public void drawCached(){`
	# `Draw.rect(regions[state], x, y, rotdeg());`
	# `if((blendprox & (1 << i)) == 0){`
	# `Draw.rect(edgeRegion, x, y, (rotation - i) * 90);`
	# `if(state == stateLoad){`
	# `int dir = Mathf.mod(rotation - i, 4);`
	# `var near = nearby(dir);`
	# `if((blendprox & (1 << i)) != 0 && i != 0 && near != null && !near.block.squareSprite){`
	# `Draw.rect(sliced(regions[0], SliceMode.bottom), x + Geometry.d4x(dir) * tilesize*0.75f, y + Geometry.d4y(dir) * tilesize*0.75f, (float)(dir*90));`
	# `}else if(state == stateUnload){ //front unload`
	# `if((blendprox & (1)) != 0 && front() != null && !front().block.squareSprite){`
	# `Draw.rect(sliced(regions[0], SliceMode.top), x + Geometry.d4x(rotation) * tilesize*0.75f, y + Geometry.d4y(rotation) * tilesize*0.75f, rotation * 90f);`
	# `public void draw(){`
	# `Draw.z(Layer.block - 0.1f);`
	# `Tile from = world.tile(link);`
	# `if(glowRegion.found() && power != null && power.status > 0f){`
	# `Draw.color(glowColor, glowAlpha * power.status);`
	# `Draw.rect(state == stateLoad ? edgeGlowRegion : glowRegion, x, y, rotation * 90);`
	# `if(link == -1 || from == null || lastItem == null) return;`
	# `int fromRot = from.build == null ? rotation : from.build.rotation;`
	# `Tmp.v1.interpolate(Tmp.v2, 1f - cooldown, Interp.linear);`
	# `float a = (fromRot%4) * 90;`
	# `float b = (rotation%4) * 90;`
	# `if((fromRot%4) == 3 && (rotation%4) == 0) a = -1 * 90;`
	# `if((fromRot%4) == 0 && (rotation%4) == 3) a =  4 * 90;`
	# `if(glowRegion.found()){`
	# `Draw.z(Layer.blockAdditive + 0.01f);`
	# `Draw.rect(stackRegion, Tmp.v1.x, Tmp.v1.y, Mathf.lerp(a, b, Interp.smooth.apply(1f - Mathf.clamp(cooldown * 2, 0f, 1f))));`
	# `float size = itemSize * Mathf.lerp(Math.min((float)items.total() / itemCapacity, 1), 1f, 0.4f);`
	# `Draw.rect(lastItem.fullIcon, Tmp.v1.x, Tmp.v1.y, size, size, 0);`
	# `public int state, blendprox;`
	# `public int link = -1;`
	# `public float cooldown;`
	# `public Item lastItem;`
	# The state constants are stateMove 0 / stateLoad 1 /
	# stateUnload 2; regions[state] is the `@-#`
	# length-3 array. The def constants are glowAlpha 1f
	# / glowColor Pal.redLight (no def override --
	# neither
	# `plastaniumConveyor = new StackConveyor("plastanium-conveyor"){{`
	# nor
	# `surgeConveyor = new StackConveyor("surge-conveyor"){{`
	# sets them; the defs set only
	# `speed = 4f / 60f;`
	# and
	# `speed = 5f / 60f;`
	# plus health / itemCapacity / outputRouter /
	# baseEfficiency / power, Blocks.java:2084/2237).
	# itemSize is
	# `public static final float itemSize = 5f;`
	# (Vars.java:115) and tilesize is
	# `public static final int tilesize = 8;`
	# (Vars.java:135 -- NEVER the game tile_size 32,
	# the N2375 lesson). rotdeg() is
	# `public float rotdeg(){`
	# `return rotation * 90;`
	# (BuildingComp.java:582-584). sliced is
	# `default TextureRegion sliced(TextureRegion input, SliceMode mode){`
	# `return mode == SliceMode.none ? input : mode == SliceMode.bottom ? botHalf(input) : topHalf(input);`
	# (Autotiler.java:55-57, the interface
	# StackConveyor implements). Interp.smooth is
	# `Interp smooth = a -> a * a * (3 - 2 * a);`
	# and Interp.linear is
	# `Interp linear = a -> a;`
	# (arc Interp.java:11/8, verified verbatim, not
	# guessed). d4x / d4y are
	# `public final static int[] d4x = {1, 0, -1, 0};`
	# `public final static int[] d4y = {0, 1, 0, -1};`
	# (arc Geometry.java:24-25) and Mathf.mod is
	# `public static int mod(int x, int n){`
	# `return ((x % n) + n) % n;`
	# (arc Mathf.java:579-581), so GDScript posmod is
	# the exact match. StackConveyor has NO icons()
	# override (Block.java:976 is the default), so
	# there is no icons() pure to register -- and a
	# zero-arg pure cannot register (the SSOT schema
	# validator requires non-empty input keys, the
	# N2396 precedent); the region tokens ride this
	# pure as symbolic strings. blendprox is a
	# caller-supplied input: the N2239 advance never
	# tracks it (onProximityUpdate, StackConveyor.
	# java:217-261, is deferred) and the pure NEVER
	# reads the frame. near_square is an Array of 4
	# Variants indexed by absolute dir (0 right, 1 up,
	# 2 left, 3 down, per Geometry.d4): null means no
	# neighbour building at that dir, a bool is that
	# neighbour's block.squareSprite -- the null-ness
	# carries the `near != null` half of the Java
	# gate; front_square is the same shape for front().
	# power_status is -1 when power is null (the
	# sentinel folds into the single `> 0f` check,
	# since Java requires power != null AND status >
	# 0f). The glow draws BEFORE the early return, so
	# glow_call can be non-null while stack_call /
	# item_call are null. The stack/item z lifts to
	# Layer.blockAdditive + 0.01f when the glow region
	# is found (:182-184) and stays at Layer.block -
	# 0.1f otherwise. The interpolate t is 1 - cooldown
	# UNCLAMPED like Java -- cooldown runs to recharge
	# 2f, so the lerp extrapolates when cooldown > 1.
	# Pure-only: the tick never calls draw -- draw is
	# called by the renderer, and the renderer call
	# site waits for a renderer slice.
	var d4x: Array = [1, 0, -1, 0]
	var d4y: Array = [0, 1, 0, -1]
	var tile_size: float = 8.0
	var rot_deg: float = float(rotation_value) * 90.0
	var base_call: Dictionary = {
		"call": "Draw.rect(regions[state], x, y, rotdeg());",
		"region": "regions[" + str(state_value) + "]",
		"x": x_value,
		"y": y_value,
		"rotation": rot_deg,
	}
	var edge_calls: Array = []
	for i in range(4):
		if (blendprox & (1 << i)) == 0:
			edge_calls.append({
				"call": "Draw.rect(edgeRegion, x, y, (rotation - i) * 90);",
				"region": "edgeRegion",
				"x": x_value,
				"y": y_value,
				"rotation": float(rotation_value - i) * 90.0,
				"side": i,
			})
	var input_calls: Array = []
	if state_value == SOURCE_STACK_CONVEYOR_STATE_LOAD:
		for k in range(4):
			var dir_value: int = posmod(rotation_value - k, 4)
			var near_value: Variant = near_square[dir_value] if dir_value < near_square.size() else null
			if (blendprox & (1 << k)) != 0 and k != 0 and near_value != null and not bool(near_value):
				input_calls.append({
					"call": "Draw.rect(sliced(regions[0], SliceMode.bottom), x + Geometry.d4x(dir) * tilesize*0.75f, y + Geometry.d4y(dir) * tilesize*0.75f, (float)(dir*90));",
					"region": "sliced(regions[0], bottom)",
					"x": x_value + float(d4x[dir_value]) * tile_size * 0.75,
					"y": y_value + float(d4y[dir_value]) * tile_size * 0.75,
					"rotation": float(dir_value * 90),
					"side": k,
					"dir": dir_value,
				})
	elif state_value == SOURCE_STACK_CONVEYOR_STATE_UNLOAD:
		if (blendprox & 1) != 0 and front_square != null and not bool(front_square):
			var front_dir: int = posmod(rotation_value, 4)
			input_calls.append({
				"call": "Draw.rect(sliced(regions[0], SliceMode.top), x + Geometry.d4x(rotation) * tilesize*0.75f, y + Geometry.d4y(rotation) * tilesize*0.75f, rotation * 90f);",
				"region": "sliced(regions[0], top)",
				"x": x_value + float(d4x[front_dir]) * tile_size * 0.75,
				"y": y_value + float(d4y[front_dir]) * tile_size * 0.75,
				"rotation": rot_deg,
				"side": 0,
				"dir": front_dir,
			})
	var cached_call: Dictionary = {"base": base_call, "edge_calls": edge_calls, "input_calls": input_calls}
	var glow_call: Variant = null
	if glow_found and power_status > 0.0:
		glow_call = {
			"call": "Draw.rect(state == stateLoad ? edgeGlowRegion : glowRegion, x, y, rotation * 90);",
			"region": "edgeGlowRegion" if state_value == SOURCE_STACK_CONVEYOR_STATE_LOAD else "glowRegion",
			"color": glow_color,
			"alpha": glow_alpha * power_status,
			"x": x_value,
			"y": y_value,
			"rotation": rot_deg,
			"z": "Layer.blockAdditive",
		}
	var stack_call: Variant = null
	var item_call: Variant = null
	var stack_x: float = 0.0
	var stack_y: float = 0.0
	var stack_angle: float = 0.0
	var item_size_value: float = 0.0
	if link != -1 and from_world != null and last_item != null:
		var from_dict: Dictionary = from_world
		var from_rot: int = rotation_value if from_build_null else int(from_dict.get("rotation", rotation_value))
		var t_value: float = 1.0 - cooldown
		stack_x = lerpf(float(from_dict.get("x", x_value)), x_value, t_value)
		stack_y = lerpf(float(from_dict.get("y", y_value)), y_value, t_value)
		var from_mod: int = posmod(from_rot, 4)
		var rot_mod: int = posmod(rotation_value, 4)
		var a_value: float = float(from_mod) * 90.0
		var b_value: float = float(rot_mod) * 90.0
		if from_mod == 3 and rot_mod == 0:
			a_value = -90.0
		if from_mod == 0 and rot_mod == 3:
			a_value = 360.0
		var smooth_t: float = 1.0 - clampf(cooldown * 2.0, 0.0, 1.0)
		var smooth_value: float = smooth_t * smooth_t * (3.0 - 2.0 * smooth_t)
		stack_angle = lerpf(a_value, b_value, smooth_value)
		var stack_z: String = "Layer.blockAdditive + 0.01f" if glow_found else "Layer.block - 0.1f"
		stack_call = {
			"call": "Draw.rect(stackRegion, Tmp.v1.x, Tmp.v1.y, Mathf.lerp(a, b, Interp.smooth.apply(1f - Mathf.clamp(cooldown * 2, 0f, 1f))));",
			"region": "stackRegion",
			"x": stack_x,
			"y": stack_y,
			"rotation": stack_angle,
			"z": stack_z,
		}
		var fill_value: float = minf(float(items_total) / float(item_capacity), 1.0)
		item_size_value = item_size * lerpf(fill_value, 1.0, 0.4)
		item_call = {
			"call": "Draw.rect(lastItem.fullIcon, Tmp.v1.x, Tmp.v1.y, size, size, 0);",
			"icon": str((last_item as Dictionary).get("icon", "")),
			"x": stack_x,
			"y": stack_y,
			"size": item_size_value,
			"rotation": 0.0,
			"z": stack_z,
		}
	return {
		"cached_call": cached_call,
		"glow_call": glow_call,
		"stack_call": stack_call,
		"item_call": item_call,
		"stack_x": stack_x,
		"stack_y": stack_y,
		"stack_angle": stack_angle,
		"item_size": item_size_value,
	}

static func source_stack_conveyor_blends_state(state: Variant, output_router: bool, other_outputs_items: bool, other_accepts_items: bool, other_no_side_blend: bool, looking_at_either: bool, not_looking_at: bool, other_facing: bool, other_build_unload: bool, other_build_move_not_facing: bool, blends_armored: bool, other_is_stack_conveyor: bool) -> Dictionary:
	# The blends rows (StackConveyor.blends(),
	# StackConveyor.java:71-88), the pure blend
	# predicate -- the port never blends for
	# real (the N2435 precedent: every
	# geometry / indexer predicate is a
	# caller-supplied bool and the pure NEVER
	# reads world / tile). Java, in order
	# (each exact expr on ONE comment line,
	# the N2148 lesson):
	# `public class StackConveyor extends Block implements Autotiler{`
	# `protected static final int stateMove = 0, stateLoad = 1, stateUnload = 2;`
	# `public boolean outputRouter = true;`
	# `public boolean blends(Tile tile, int rotation, int otherx, int othery, int otherrot, Block otherblock){`
	# `if(tile.build instanceof StackConveyorBuild b){`
	# `int state = b.state;`
	# `if(state == stateLoad){ //standard conveyor mode`
	# `return otherblock.outputsItems() && lookingAtEither(tile, rotation, otherx, othery, otherrot, otherblock);`
	# `}else if(state == stateUnload && !outputRouter){ //router mode`
	# `return otherblock.acceptsItems &&`
	# `(!otherblock.noSideBlend || lookingAtEither(tile, rotation, otherx, othery, otherrot, otherblock)) &&`
	# `(notLookingAt(tile, rotation, otherx, othery, otherrot, otherblock) ||`
	# `(otherblock instanceof StackConveyor && facing(otherx, othery, otherrot, tile.x, tile.y))) &&`
	# `!(world.build(otherx, othery) instanceof StackConveyorBuild s && s.state == stateUnload) &&`
	# `!(world.build(otherx, othery) instanceof StackConveyorBuild s2 && s2.state == stateMove &&`
	# `!facing(otherx, othery, otherrot, tile.x, tile.y));`
	# `return otherblock.outputsItems() && blendsArmored(tile, rotation, otherx, othery, otherrot, otherblock) && otherblock instanceof StackConveyor;`
	# `public class StackConveyorBuild extends Building{`
	# The state constants are stateMove 0 /
	# stateLoad 1 / stateUnload 2 -- the brief
	# mislabels stateLoad as 0, Java wins.
	# The `state` input is a Variant: null
	# means the tile build is NOT a
	# StackConveyorBuild (the instanceof gate,
	# the N2434 Variant-null precedent), an
	# int 0/1/2 is the build state. The load
	# branch needs outputsItems() AND
	# lookingAtEither; the router branch
	# (unload && !outputRouter) needs all five
	# conjuncts -- acceptsItems, the
	# noSideBlend / lookingAtEither half, the
	# notLookingAt / facing half, NOT the other
	# build unloading, NOT the other build
	# moving away; anything else (not a stack
	# build, stateMove, unload with
	# outputRouter) falls through to the
	# outputsItems && blendsArmored &&
	# instanceof StackConveyor fallback. The
	# Autotiler defaults are NOT ported --
	# their signatures ride here for the
	# caller-supplied contract:
	# `default boolean facing(int x, int y, int rotation, int x2, int y2){`
	# `default boolean blendsArmored(Tile tile, int rotation, int otherx, int othery, int otherrot, Block otherblock){`
	# `default boolean notLookingAt(Tile tile, int rotation, int otherx, int othery, int otherrot, Block otherblock){`
	# `default boolean lookingAtEither(Tile tile, int rotation, int otherx, int othery, int otherrot, Block otherblock){`
	# The Block fields behind the bool inputs:
	# `public boolean acceptsItems = false;`
	# `public boolean noSideBlend = false;`
	# `public boolean outputsItems(){`
	# (Block.java:67 / 84 / 601-603, outputsItems
	# returns hasItems). outputRouter is the
	# class default true (StackConveyor.
	# java:39); plastanium-conveyor keeps it,
	# surge-conveyor sets false (Blocks.
	# java:2244) -- only a surge-conveyor ever
	# takes the router branch. Pure-only: the
	# tick never calls blends -- the blending
	# call site waits for its own slice.
	var blends := false
	if state != null:
		var state_value: int = int(state)
		if state_value == SOURCE_STACK_CONVEYOR_STATE_LOAD:
			blends = other_outputs_items and looking_at_either
		elif state_value == SOURCE_STACK_CONVEYOR_STATE_UNLOAD and not output_router:
			blends = other_accepts_items and (not other_no_side_blend or looking_at_either) and (not_looking_at or (other_is_stack_conveyor and other_facing)) and not other_build_unload and not other_build_move_not_facing
		else:
			blends = other_outputs_items and blends_armored and other_is_stack_conveyor
	else:
		blends = other_outputs_items and blends_armored and other_is_stack_conveyor
	return {"blends": blends}

static func source_stack_conveyor_draw_plan_state(bits: Variant, plan_x: float, plan_y: float, rotation: int) -> Dictionary:
	# The drawPlan rows (StackConveyor.
	# drawPlanRegion(), StackConveyor.
	# java:90-104), the pure plan draw-call
	# dict -- the port never draws for real
	# (the N2419 plan-pure precedent: the pure
	# returns the plan calls as data). Java, in
	# order (each exact expr on ONE comment
	# line, the N2148 lesson):
	# `public @Load(value = "@-#", length = 3) TextureRegion[] regions;`
	# `public @Load("@-edge") TextureRegion edgeRegion;`
	# `public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){`
	# `int[] bits = getTiling(plan, list);`
	# `if(bits == null) return;`
	# `TextureRegion region = regions[0];`
	# `Draw.rect(region, plan.drawx(), plan.drawy(), plan.rotation * 90);`
	# `for(int i = 0; i < 4; i++){`
	# `if((bits[3] & (1 << i)) == 0){`
	# `Draw.rect(edgeRegion, plan.drawx(), plan.drawy(), (plan.rotation - i) * 90);`
	# getTiling is a CALL record, NOT ported:
	# `default @Nullable int[] getTiling(BuildPlan plan, Eachable<BuildPlan> list){`
	# (Autotiler.java:77-86, null when
	# plan.tile() is null). The bits ride
	# caller-supplied as null or an Array of 4
	# ints and the pure reads ONLY bits[3] --
	# the edge bitmask, the same bit the N2434
	# drawCached edge loop reads (StackConveyor.
	# java:133-136). bits null -> BOTH result
	# keys null (the early return draws
	# nothing). The base rect region token is
	# "regions[0]" (the `@-#` length-3 array)
	# and the edge region token is "edgeRegion";
	# the rect dicts use the "rotation" key
	# (the N2438/N2442 plan convention).
	# Pure-only: the tick never calls
	# drawPlanRegion -- the placement renderer
	# call site waits for its own slice.
	if bits == null:
		return {"base_call": null, "edge_calls": null}
	var bits_array: Array = bits
	var base_call: Dictionary = {
		"call": "Draw.rect(region, plan.drawx(), plan.drawy(), plan.rotation * 90);",
		"region": "regions[0]",
		"x": plan_x,
		"y": plan_y,
		"rotation": float(rotation) * 90.0,
	}
	var edge_calls: Array = []
	for i in range(4):
		if (int(bits_array[3]) & (1 << i)) == 0:
			edge_calls.append({
				"call": "Draw.rect(edgeRegion, plan.drawx(), plan.drawy(), (plan.rotation - i) * 90);",
				"region": "edgeRegion",
				"x": plan_x,
				"y": plan_y,
				"rotation": float(rotation - i) * 90.0,
				"side": i,
			})
	return {"base_call": base_call, "edge_calls": edge_calls}

static func source_stack_conveyor_rotated_output_state(other_is_stack_build: bool, other_state: int, super_rotated_output: bool) -> Dictionary:
	# The rotated-output rows (StackConveyor.
	# rotatedOutput(), StackConveyor.
	# java:106-112), the pure rotated-output
	# predicate. Java, in order (each exact
	# expr on ONE comment line, the N2148
	# lesson):
	# `public boolean rotatedOutput(int x, int y){`
	# `Building tile = world.build(x, y);`
	# `if(tile instanceof StackConveyorBuild s){`
	# `return s.state != stateUnload;`
	# `return super.rotatedOutput(x, y);`
	# The super default is
	# `return rotate;`
	# (Block.java:615-617) and StackConveyor
	# sets rotate = true (:48), but the pure
	# takes the super value caller-supplied so
	# the def flag stays out of the pure. The
	# world.build indexer query rides as the
	# other_is_stack_build bool (the N2435
	# caller-supplied precedent); other_state
	# is read only when it is true. Pure-only:
	# the tick never calls rotatedOutput.
	if other_is_stack_build:
		return {"rotated_output": other_state != SOURCE_STACK_CONVEYOR_STATE_UNLOAD}
	return {"rotated_output": super_rotated_output}

static func source_stack_conveyor_stats_state(item_capacity: int, speed: float) -> Dictionary:
	# The setStats rows (StackConveyor.setStats(), StackConveyor.java:64-68), the pure stats dict. Java, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public void setStats(){`
	# `super.setStats();`
	# `stats.add(Stat.itemsMoved, Mathf.round(itemCapacity * speed * 60), StatUnit.itemsSecond);`
	# `public float speed = 0f;`
	# `itemCapacity = 10;`
	# `public class StackConveyor extends Block implements Autotiler{`
	# `itemsMoved = new Stat("itemsMoved", StatCat.items),`
	# `itemsSecond = new StatUnit("itemsSecond"),`
	# `plastaniumConveyor = new StackConveyor("plastanium-conveyor"){{`
	# `speed = 4f / 60f;`
	# `surgeConveyor = new StackConveyor("surge-conveyor"){{`
	# `speed = 5f / 60f;`
	# `public static int round(float value){`
	# `return (int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT;`
	# The float math is Java-exact: itemCapacity * speed FIRST, then times 60 (left-assoc), then Mathf.round. The class defaults are speed 0f (StackConveyor.java:38) and itemCapacity 10 (StackConveyor.java:52), so the class-default rate is round(10 * 0 * 60) = 0. The plastanium-conveyor def (Blocks.java:2084) sets speed 4f/60f (:2087) with itemCapacity 10 (:2088), so its rate is round(10 * 4/60 * 60) = 40; the surge-conveyor def (Blocks.java:2237) sets speed 5f/60f (:2241) with itemCapacity 10 (:2242), so its rate is round(10 * 5/60 * 60) = 50. There is NO "stack-conveyor" or "large-stack-conveyor" def in Blocks.java -- plastanium-conveyor and surge-conveyor are the only two StackConveyor defs. Mathf.round(float) (arc Mathf.java:500-502) adds BIG_ENOUGH_ROUND (16384.5f, Mathf.java:36) and truncates, which is floor(v + 0.5) for the non-negative values here, so the .5 edge rounds UP; GDScript round() rounds half away from zero and agrees for non-negative values, but the port uses int(floor(v + 0.5)) explicitly (the SourceBlockRequirementsState precedent) so the Java-exact rounding is visible in the code. The tokens are exact: itemsMoved (Stat.java:52) and itemsSecond (StatUnit.java:20). The pure returns the TOKENS, not localized strings (the N2450 precedent: labels compose at UI; stats values here are raw numbers). Pure-only: the tick never calls setStats -- the stats UI calls it, and the call site waits for its own slice.
	var raw_value: float = float(item_capacity) * speed * 60.0
	var items_moved_per_second: int = int(floor(raw_value + 0.5))
	return {
		"set_stats_expr": "stats.add(Stat.itemsMoved, Mathf.round(itemCapacity * speed * 60), StatUnit.itemsSecond);",
		"item_capacity": item_capacity,
		"speed": speed,
		"items_moved_per_second": items_moved_per_second,
		"stat_key": "itemsMoved",
		"stat_unit": "itemsSecond",
	}
