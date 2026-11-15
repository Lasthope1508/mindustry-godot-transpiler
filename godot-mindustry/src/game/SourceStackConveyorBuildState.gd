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
	# Documented limits: (1) power-only first pass -- the surge-conveyor's static power consumer (consumePower 1f/60f, Blocks.java:2251) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); surge-conveyor has no second consumer. (2) NO shouldConsume gate to defer -- StackConveyorBuild has no shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-756) applies; the power-only fold is EXACT for this family. (3) updateTile advance LIVE (N2239) -- eff fold / cooldown reel / link gate / transfer branch / unload branch (StackConveyor.java:268-315) run every tick through the pure source_stack_conveyor_update_tile_advance_state; still deferred: the moveForward/dump application (BuildingComp.java:1129-1137 / 1072-1113, the driver passes move_forward_ok / dump_ok false), the live front() query (BuildingComp.java:550-554, the driver passes no-front), and the live items intake (acceptStack / handleStack, StackConveyor.java:344-363). (4) No sense modeling -- sense waits for its own slice. (5) Power row single def -- surge-conveyor only (size 1, speed 5f/60f, itemCapacity 10, health 130, surge-alloy 1 / tungsten 1); plastanium-conveyor (StackConveyor, no power def) has no power row, but the N2239 updateTile advance covers BOTH defs through the per-def tables (plastanium speed 4f/60f, outputRouter true, baseEfficiency 0f; surge speed 5f/60f, outputRouter false, baseEfficiency 1f). (6) No draw/config modeling -- draw / drawSelect / config wait for their own slices.
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
