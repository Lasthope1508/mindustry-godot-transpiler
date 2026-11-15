extends RefCounted
class_name SourceWallCrafterBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")

# The WallCrafter implementation (WallCrafter.java:25, `public class WallCrafter extends Block{`): cliff-crusher (consumePower 11 / 60f, Blocks.java:3004, `consumePower(11 / 60f);`; size 2, drillTime 110f, Blocks.java:3006-3007) and large-cliff-crusher (consumePower 1f, Blocks.java:3018, `consumePower(1f);`; size 3, drillTime 48f, Blocks.java:3020-3021). WallCrafter extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_wall_crafter_building", the separator precedent), and this slice adds the wall-crafter key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceWallCrafter* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile warmup fold (WallCrafter.java:193, `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 40f);`) gates on efficiency > 0, so a wall crafter with no power would warm up as if power.status were 1.0.
const SOURCE_WALL_CRAFTER_BUILD_IMPLEMENTATIONS := ["WallCrafter"]
const SOURCE_WALL_CRAFTER_BUILDING_META_KEY := "source_wall_crafter_building"
# WallCrafter.java:193 warmup speed `1f / 40f` in
# `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 40f);`
# -- the approachDelta rate.
const SOURCE_WALL_CRAFTER_WARMUP_SPEED := 1.0 / 40.0
# WallCrafter.java:35, `public float liquidBoostIntensity = 1.6f;`
# and WallCrafter.java:47, `public float itemBoostIntensity = 1.6f;`
# -- the class boost intensities; neither def overrides them.
const SOURCE_WALL_CRAFTER_LIQUID_BOOST_INTENSITY := 1.6
const SOURCE_WALL_CRAFTER_ITEM_BOOST_INTENSITY := 1.6
# WallCrafter.java:33, `public float drillTime = 150f;` -- the
# class drillTime default; the defs override it (110f / 48f,
# Blocks.java:3006/:3020), so the driver reads drillTime from
# the catalog per def and uses this only when the catalog
# carries no drillTime.
const SOURCE_WALL_CRAFTER_DRILL_TIME_DEFAULT := 150.0
# WallCrafter.java:45, `public float boostItemUseTime = 120f;` -- the
# class timer duration for the booster consume; the large def
# overrides it (`boostItemUseTime = 60f / 0.75f;`,
# Blocks.java:3032, = 80f), so the driver resolves the per-def
# duration through _wall_crafter_boost_item_use_time_for_block
# and uses this only for a def that keeps the class default.
const SOURCE_WALL_CRAFTER_BOOST_ITEM_USE_TIME_DEFAULT := 120.0
# Block.java:438, `public int dumpTime = 5;` -- the class
# dump interval in ticks for the timerDump timer
# (WallCrafter.java:220-221,
# `if(timer(timerDump, dumpTime / timeScale)){ dump(output); }`);
# no def overrides dumpTime anywhere in upstream
# (grep-verified), so both defs fire at 5f / timeScale.
const SOURCE_WALL_CRAFTER_DUMP_TIME := 5.0
# The large-cliff-crusher's required liquid is hydrogen
# (`consumeLiquid(Liquids.hydrogen, 1f / 60f);`, Blocks.java:3028);
# the cliff-crusher has no liquid row. The catalog consumeLiquid
# rows carry the liquid name + per-frame amount, so the driver
# matches the row by this name (the separator slag precedent).
const SOURCE_WALL_CRAFTER_HYDROGEN_LIQUID := "hydrogen"

static func _is_wall_crafter_build_implementation(implementation: String) -> bool:
	return SOURCE_WALL_CRAFTER_BUILD_IMPLEMENTATIONS.has(implementation)

static func _wall_crafter_boost_item_use_time_for_block(block_id: String) -> float:
	# The per-def timer duration for the booster consume (the
	# MendProjector per-def helper precedent): the class
	# default is `public float boostItemUseTime = 120f;`
	# (WallCrafter.java:45), kept by the cliff-crusher, while
	# the large-cliff-crusher overrides it to
	# `boostItemUseTime = 60f / 0.75f;` (Blocks.java:3032, =
	# 80f). The catalog carries no boostItemUseTime property,
	# so the driver resolves it here by block id; an unknown
	# block id keeps the class default. The cliff-crusher's
	# duration never matters live: it has no item consumer,
	# so itemValid is always false and the timer gate never
	# opens for it.
	if block_id == "large-cliff-crusher":
		return 60.0 / 0.75
	return SOURCE_WALL_CRAFTER_BOOST_ITEM_USE_TIME_DEFAULT

static func source_wall_crafter_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The wall-crafter tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (WallCrafter.java:25, `public class WallCrafter extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# wall crafter skips consumption like Java's updateConsumption
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
	# for this wall crafter (N2125); the tick preserves a disabled
	# wall crafter instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# The frame carries the Building.items ItemModule
	# (frame["items"], a Dictionary keyed by item name, the
	# drill/factory precedent): WallCrafter has items
	# (WallCrafter.java:56, `hasItems = true;`), and the
	# shouldConsume gate reads the output count from it
	# (WallCrafter.java:227, `return items.get(output) < itemCapacity;`).
	# The offload intake is live (N2223, the updateTile advance,
	# WallCrafter.java:213-215); the timerDump dump is live
	# since N2283 (WallCrafter.java:220-221, frame-local
	# Interval-equivalent, frame key timer_dump_elapsed).
	# The frame also carries the Building.liquids LiquidModule
	# (frame["liquids"], the live sprite store synced each tick
	# before the fold, the Fracker:361 precedent): the
	# large-cliff-crusher's required hydrogen row (N2264) reads
	# the held hydrogen from it; the cliff-crusher has no liquid
	# row and leaves it empty.
	return {"items": {}, "liquids": {}}

static func source_wall_crafter_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the wall-crafter frame meta key
	# ("source_wall_crafter_building"). A WallCrafter sprite gets a
	# frame bound with the items key ({} by default); the live-loop
	# tick fills its other keys every tick. Any other block, or an
	# already-bound sprite, binds nothing.
	if block == null or not _is_wall_crafter_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_WALL_CRAFTER_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_WALL_CRAFTER_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_WALL_CRAFTER_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_wall_crafter_should_consume_state(frame: Dictionary, output_item: String, item_capacity: int) -> Dictionary:
	# WallCrafterBuild overrides shouldConsume (WallCrafter.java:226, `public boolean shouldConsume(){` with `return items.get(output) < itemCapacity;`, WallCrafter.java:227): the wall crafter consumes only while its output store holds less than the item capacity. WallCrafter extends Block (WallCrafter.java:25, `public class WallCrafter extends Block{`) and WallCrafterBuild extends Building (WallCrafter.java:183, `public class WallCrafterBuild extends Building{`), so the default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`) does NOT apply here. Unlike the Separator/Drill gates this one has NO `&& enabled` -- Java returns the bare capacity comparison, so the pure gate does NOT read frame["enabled"] at all (the driver already runs the machinery only when enabled). The output item is sand for both defs (the Java field default, `public Item output = Items.sand;`, WallCrafter.java:43, set explicitly by both defs, `output = Items.sand;`, Blocks.java:3009/:3024) and the capacity is the catalog itemCapacity (10 for the cliff-crusher, the Java field default, `public int itemCapacity = 10;`, Block.java:75; 20 for the large-cliff-crusher, `itemCapacity = 20;`, Blocks.java:3031) -- both arrive as parameters from the driver, which reads them from the catalog. The count comes from the shared inventory helper (SourceDrillInventoryRuntimeState.item_count, reused through a preload, NOT re-implemented) over the frame items key (a Dictionary keyed by item name, default {} for a frame bound before this slice). When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`).
	var items: Dictionary = frame.get("items", {})
	var output_count: int = inventory.item_count(items, output_item)
	return {"should_consume": output_count < item_capacity, "output_count": output_count}

static func source_wall_crafter_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a wall crafter does not take the early return. The updateTile advance follows the folded efficiency (WallCrafter.java:193, `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 40f);` with `lastEfficiency = eff * timeScale * efficiency;`, WallCrafter.java:211) and the shouldConsume override (WallCrafter.java:226, `public boolean shouldConsume(){` with `return items.get(output) < itemCapacity;`, WallCrafter.java:227; default BuildingComp.java:755, `public boolean shouldConsume(){`) -- WallCrafterBuild (WallCrafter.java:183, `public class WallCrafterBuild extends Building{`) overrides shouldConsume() to return items.get(output) < itemCapacity, so the default does not apply here; the shouldConsume gate is live (N2201) -- the pure gate (source_wall_crafter_should_consume_state) feeds should_consume to the machinery from the frame items count and the catalog output/capacity. The cliff-crusher (consumePower 11 / 60f, Blocks.java:3004, `consumePower(11 / 60f);`; large-cliff-crusher consumePower 1f, Blocks.java:3018, `consumePower(1f);`) also consumes liquid hydrogen as a REQUIRED row on the large def (`consumeLiquid(Liquids.hydrogen, 1f / 60f);`, Blocks.java:3028 -- NOT .boost(), so hasLiquidBooster stays false, WallCrafter.java:106) and a graphite item booster (Blocks.java:3030; itemBoostIntensity 1.6f, WallCrafter.java:47; boostItemUseTime 60f/0.75f, Blocks.java:3032) -- both rows live since N2264 (source_wall_crafter_liquid_consumer_row_state + source_wall_crafter_item_consumer_row_state), so the folded efficiency is the min over the *modeled* consumers (power + hydrogen), with the graphite row folded into optionalEfficiency only.
	# Documented limits: (1) hydrogen + graphite rows live (N2264) -- the large-cliff-crusher consumes liquid hydrogen as a REQUIRED row (1f/60f, Blocks.java:3028; NOT .boost(), so hasLiquidBooster stays false and the liquid multiplier term is 1.0) and a graphite item booster (Blocks.java:3030), folded by the pure rows (source_wall_crafter_liquid_consumer_row_state, ConsumeLiquid.efficiency, ConsumeLiquid.java:42-47; source_wall_crafter_item_consumer_row_state, ConsumeItems.efficiency, ConsumeItems.java:51-53) with the second-pass hydrogen removal (ConsumeLiquid.update, ConsumeLiquid.java:37-39); the folded efficiency is the min over the *modeled* consumers (power + hydrogen), with the graphite row in the optional pass only. The timer-gated consume() of the graphite booster is live since N2273 (WallCrafter.java:207-209): the tick accumulates frame["timer_use_elapsed"] every tick and, after the N2223 advance, removes 1 graphite when item_valid holds and eff * efficiency > 0 and the timer fires at the per-def boostItemUseTime (120f class default, WallCrafter.java:45; the large def overrides it to 60f/0.75f = 80f, Blocks.java:3032). Documented deviation: the frame-local clock delays the first fire by a full interval after placement (Java fires nearly at once -- the global Time.time is already large vs a fresh Interval times[id] = 0, arc Interval.java:20-26); the cliff-crusher has no booster item, so nothing is removed for it; no live intake fills frame["items"] yet, so the removal reads the frame as-is. (2) shouldConsume gate live (N2201) -- WallCrafterBuild overrides shouldConsume() to return items.get(output) < itemCapacity (WallCrafter.java:226-228, `return items.get(output) < itemCapacity;`); the pure gate reads the frame items count via the shared inventory helper, with the output item and capacity from the catalog; the offload intake is live (N2223) and the timerDump dump is live since N2283 (WallCrafter.java:220-221, frame-local Interval-equivalent at 5f/time_scale, dump(output) through the shared dump_item_state routing). (3) updateTile advance live (N2223) -- warmup / eff / lastEfficiency / time / totalTime / offload advance each tick (WallCrafter.java:193-218); the timerUse booster consume is live since N2273 (WallCrafter.java:207-209, checked after the advance -- order-equivalent for the tick, since consume only removes 1 graphite); the timerDump dump is live since N2283 (WallCrafter.java:220-221, checked after the timerUse consume -- the Java order, :207-209 then :220-221): when the timer fires at 5f/time_scale it dumps 1 sand (the output item, WallCrafter.java:43) through the shared dump_item_state routing, with the neighbour acceptItem/canDump arrays as frame inputs (default []); documented deviation: the frame-local clock delays the first fire by a full interval after placement (Java fires nearly at once -- the global Time.time is already large vs a fresh Interval times[id] = 0, arc Interval.java:20-26); still deferred: the live getEfficiency fill (WallCrafter.java:141-180, the advance reads the frame input efficiency_factor, default 0.0), the offload neighbor routing (BuildingComp.java:1001-1013, the port offloads to own inventory only), the updateEffect chance (WallCrafter.java:196-205), and the disabled early return (BuildingComp.java:1954-1957, the advance runs only when enabled). Until the getEfficiency fill lands a live cliff-crusher never accumulates time. (4) No attribute-efficiency / setBars / draw / icons / drawPlanRegion / drawPlace rows -- see DEFERRED. (5) Large-cliff-crusher variant verification pending -- the same driver covers both defs via the catalog consumePower.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_wall_crafter_liquid_consumer_row_state(frame: Dictionary, has_liquid_consumer: bool, liquid_id: int, amount: float, source_delta: float, time_scale: float, efficiency_scale: float, multiplier: float = 1.0) -> Dictionary:
	# ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47, `float ed = build.edelta() * build.efficiencyScale();` / `if(ed <= 0.00000001f) return 0f;` / `return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);`): the liquid consumer's efficiency is the held liquid over the per-frame demand, capped at 1, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`); a starved non-power row also stops power draw (`if(cons != block.consPower && result <= 0.0000001f){`, BuildingComp.java:1972, folded by the shared machinery). In the first pass efficiency is assumed 1f (BuildingComp.java:1965, `efficiency = optionalEfficiency = 1f;`), so edelta() is delta() = source_delta * time_scale (BuildingComp.java:1922-1929, `return Time.delta * timeScale;` / `return efficiency * delta();`). The multiplier defaults to 1f (Consume.java:18, `public Floatf<Building> multiplier = b -> 1f;`); the large def sets none (Blocks.java:3028 is a bare consumeLiquid call -- NOT .boost(), so this is a REQUIRED row, and hasLiquidBooster stays false, WallCrafter.java:106). The amount is per def and arrives from the catalog consumeLiquid row (large-cliff-crusher `consumeLiquid(Liquids.hydrogen, 1f / 60f);`, Blocks.java:3028; the cliff-crusher has no consumeLiquid row, so its has_liquid_row is false). The held amount comes from the shared liquid module helper (SourceLiquidModuleState.source_get_state, reused through a preload, NOT re-implemented) over the frame liquids key (the Building.liquids LiquidModule dict, default {} for a frame bound before this slice, amount 0.0 when the store has no entry for the liquid -- Java's liquids.get returns 0.0 for a liquid never added), with the Fracker guard (SourceFrackerBuildState.gd:221, `liquids.has("liquids")` + bounds check). The second pass removes the consumed hydrogen (ConsumeLiquid.update, ConsumeLiquid.java:37-39, `build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));`, only when `if(update && efficiency > 0){`, BuildingComp.java:1999) -- the tick does that after the fold, with edelta from the folded efficiency.
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

static func source_wall_crafter_item_consumer_row_state(frame: Dictionary, has_item_consumer: bool, stacks: Array, multiplier: float = 1.0) -> Dictionary:
	# ConsumeItems.efficiency (ConsumeItems.java:51-53, `return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;`): BINARY 1/0, not a ratio -- 1 when the building is burning a trigger consumer or its item module holds every stack, 0 otherwise. consumeTriggerValid() is false at the base (BuildingComp.java:764-766, `public boolean consumeTriggerValid(){` with `return false;`) and no WallCrafter build overrides it, so the trigger term is always false here. items.has (ItemModule.java:153-156, `if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;`) requires EVERY stack to hold round(amount * multiplier), with has(item, amount) = get(item) >= amount (ItemModule.java:126-128, `return get(item) >= amount;`); the port's item module is a Dictionary keyed by item name, so an unknown item reads 0 through the shared inventory helper (SourceDrillInventoryRuntimeState.item_count, reused through a preload, NOT re-implemented), the same outcome as the id-out-of-range branch. The multiplier defaults to 1f (Consume.java:18, `public Floatf<Building> multiplier = b -> 1f;`); the large def sets none. The booster is optional(true, true) (Consume.java:33-35, `public Consume boost(){` with `return optional(true, true);`), so the row folds the OPTIONAL pass only (BuildingComp.java:1980-1981, `for(var cons : block.optionalConsumers){` / `optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));`), capped by the min efficiency (`optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);`, BuildingComp.java:1986) -- it never lowers the folded efficiency itself. The stacks arrive explicit from the driver (the large def's assigned `itemConsumer = consumeItem(Items.graphite).boost();`, Blocks.java:3030, is one stack of 1: consumeItem(item) returns consumeItem(item, 1), Block.java:1167-1168; the catalog captures it as boosterItem, not a consumeItem row, the N2115 precedent); the cliff-crusher has no item consumer, so its has_item_row is false and item_valid is false. itemValid is the updateTile read (`boolean itemValid = itemConsumer != null && itemConsumer.efficiency(this) > 0;`, WallCrafter.java:191), so the row reports it alongside: item_valid is result > 0. No removal here: Consume.update is empty (Consume.java:52, `public void update(Building build){}`), so the second pass never removes items -- the graphite is only removed by consume() on the timer gate (WallCrafter.java:207-209), which is live since N2273 (the tick checks the gate after the N2223 advance and removes 1 graphite directly through the shared inventory helper, clamped to the held count).
	if not has_item_consumer:
		return {"has_item_row": false, "row": {}, "item_valid": false}
	var items: Dictionary = frame.get("items", {})
	var result := 1.0
	for stack in stacks:
		var item_name: String = str(stack.get("item", ""))
		var needed: int = int(round(float(stack.get("amount", 0)) * multiplier))
		if inventory.item_count(items, item_name) < needed:
			result = 0.0
	if result <= 0.0:
		return {"has_item_row": true, "row": {"result": 0.0, "is_power": false}, "item_valid": false}
	return {"has_item_row": true, "row": {"result": 1.0, "is_power": false}, "item_valid": true}

static func source_wall_crafter_timer_use_state(elapsed: float, duration: float, time_scale: float) -> Dictionary:
	# The frame-local Interval-equivalent for the booster
	# timer (TimerComp.timer, TimerComp.java:10-13, each
	# exact expr on ONE comment line, the N2148 lesson):
	# `if(Float.isInfinite(time)) return false;`
	# `return timer.get(index, time);`
	# Interval.get resets times[id] = Time.time on fire
	# (arc Interval.java:20-26, `boolean got = check(id,
	# time);` / `if(got) times[id] = Time.time;`) and
	# check compares Time.time - times[id] >= time (arc
	# Interval.java:28-30); Time.time counts TICKS (arc
	# Time.java:69-80, `timeRaw += delta;`). The port has
	# no global tick clock at the driver layer, so the
	# elapsed clock is frame-local (frame["timer_use_
	# elapsed"], accumulated by the tick delta every tick,
	# unconditionally -- mirroring Time.time, which grows
	# even while the gate is closed): threshold = duration
	# / time_scale, the Java threshold in
	# `if(itemValid && eff * efficiency > 0 && timer(timerUse, boostItemUseTime / timeScale)){`
	# (WallCrafter.java:207-209). The duration is per def:
	# `public float boostItemUseTime = 120f;`
	# (WallCrafter.java:45, the class default, kept by the
	# cliff-crusher) and
	# `boostItemUseTime = 60f / 0.75f;`
	# (Blocks.java:3032, = 80f, the large-cliff-crusher
	# override -- the only def with a booster item, so the
	# live timer fires at 80f); the driver resolves it
	# through _wall_crafter_boost_item_use_time_for_block.
	# itemValid is (WallCrafter.java:191):
	# `boolean itemValid = itemConsumer != null && itemConsumer.efficiency(this) > 0;`
	# stamped live by N2264 (from the graphite item row;
	# false for the cliff-crusher, which has no item row).
	# A non-positive time_scale is the infinite-time branch
	# (fired false); fired = elapsed >= threshold;
	# elapsed_after RESETS to 0.0 on fire (a reset, not a
	# subtraction like the Fracker accumulator). Documented
	# deviation: Java fires (nearly) immediately after
	# placement when the gate first opens (the global
	# Time.time is already large vs a fresh Interval
	# times[id] = 0); the frame-local clock delays the
	# first fire by a full interval. It cannot be fixed
	# without a global clock -- it waits for a timer-infra
	# slice if exact first-fire timing is ever needed.
	# consume() itself (`for(Consume cons : block.consumers){` /
	# `cons.trigger(self());`, BuildingComp.java:1911-1915)
	# removes 1 graphite on the large def only:
	# `itemConsumer = consumeItem(Items.graphite).boost();`
	# (Blocks.java:3030; consumeItem(item) is a stack of 1,
	# Block.java:1167-1168):
	# `public ConsumeItems consumeItem(Item item){`
	# `return consumeItem(item, 1);`
	# via ConsumeItems.trigger (ConsumeItems.java:44-48):
	# `build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));`
	# clamped by ItemModule.remove (ItemModule.java:258-263):
	# `amount = Math.min(amount, items[item.id]);`
	# The cliff-crusher has no ConsumeItems, and ConsumePower
	# / ConsumeLiquid do not override trigger (Consume.java:
	# 50, `public void trigger(Building build){}`), so
	# consume() removes nothing for it. timeScale defaults
	# 1f (BuildingComp.java:98):
	# `private transient float timeScale = 1f, timeScaleDuration;`
	var threshold: float = INF if time_scale <= 0.0 else duration / time_scale
	var fired: bool = elapsed >= threshold
	var elapsed_after: float = 0.0 if fired else elapsed
	return {"fired": fired, "elapsed_after": elapsed_after, "threshold": threshold}

static func source_wall_crafter_timer_dump_state(elapsed: float, time_scale: float, frame: Dictionary, output_item: String, content_item_ids: Array, neighbour_accepts_item: Array, neighbour_can_dump: Array) -> Dictionary:
	# The frame-local Interval-equivalent for the timerDump
	# dump (TimerComp.timer, TimerComp.java:10-13, each
	# exact expr on ONE comment line, the N2148 lesson):
	# `if(Float.isInfinite(time)) return false;`
	# `return timer.get(index, time);`
	# Interval.get resets times[id] = Time.time on fire
	# (arc Interval.java:20-26, `boolean got = check(id,
	# time);` / `if(got) times[id] = Time.time;`) and
	# check compares Time.time - times[id] >= time (arc
	# Interval.java:28-30); Time.time counts TICKS (arc
	# Time.java:69-80, `timeRaw += delta;`). The port has
	# no global tick clock at the driver layer, so the
	# elapsed clock is frame-local (frame["timer_dump_
	# elapsed"], accumulated by the tick delta every tick,
	# unconditionally -- mirroring Time.time, which grows
	# even while the gate is closed): threshold = dumpTime
	# / time_scale, the Java threshold in
	# `if(timer(timerDump, dumpTime / timeScale)){`
	# (WallCrafter.java:220-221) with
	# `dump(output);`
	# on fire. dumpTime is
	# `public int dumpTime = 5;`
	# (Block.java:438 -- no def overrides it anywhere in
	# upstream, grep-verified, so both defs fire at 5f /
	# timeScale) and timerDump is
	# `protected final int timerDump = timers++;`
	# (Block.java:436). The output item is sand for both
	# defs (`public Item output = Items.sand;`,
	# WallCrafter.java:43, set explicitly by both defs,
	# `output = Items.sand;`, Blocks.java:3009/:3023).
	# dump(output) (BuildingComp.java:1072-1113):
	# `public boolean dump(Item todump){`
	# `if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;`
	# `int dump = this.cdump;`
	# `var allItems = content.items();`
	# `int itemSize = allItems.size;`
	# -- the todump branch (else, :1100-1111):
	# `if(other.acceptItem(self(), todump) && canDump(other, todump)){`
	# `other.handleItem(self(), todump);`
	# `items.remove(todump, 1);`
	# `incrementDump(proximity.size);`
	# -- the first accepting neighbour (from the cdump
	# cursor, `transient int cdump;`, BuildingComp.java:68)
	# takes 1 output item and the cursor advances once per
	# neighbour checked (incrementDump,
	# BuildingComp.java:1116-1120):
	# `public void incrementDump(int prox){`
	# `if(prox != 0){`
	# `cdump = ((cdump + 1) % prox);`
	# canDump defaults to true
	# (`public boolean canDump(Building to, Item item){`,
	# BuildingComp.java:1124-1126); the neighbour arrays
	# carry the live per-neighbour answers as frame inputs
	# (the N2276 precedent). The dump runs through the
	# shared dump(output) port
	# (SourceBuildingItemDumpState.dump_item_state) --
	# the WallCrafter has items (`hasItems = true;`,
	# WallCrafter.java:56), so the hasItems guard always
	# passes; content_item_ids is the catalog order Java
	# iterates (it always includes the output item). A
	# non-positive time_scale is the infinite-time branch
	# (fired false); fired = elapsed >= threshold;
	# elapsed_after RESETS to 0.0 on fire -- even when the
	# dump itself fails (Java resets the Interval on
	# timer() returning true, whatever dump() then does).
	# Documented deviation: Java fires (nearly)
	# immediately after placement (the global Time.time is
	# already large vs a fresh Interval times[id] = 0);
	# the frame-local clock delays the first fire by a
	# full interval. It cannot be fixed without a global
	# clock -- it waits for a timer-infra slice if exact
	# first-fire timing is ever needed. The dumped item is
	# not written into the neighbour frame yet (no
	# neighbour write-back -- the N2276 precedent).
	var threshold: float = INF if time_scale <= 0.0 else SOURCE_WALL_CRAFTER_DUMP_TIME / time_scale
	var fired: bool = elapsed >= threshold
	var elapsed_after: float = 0.0 if fired else elapsed
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var cursor: int = int(frame.get("cdump", 0))
	var dumped := false
	if fired:
		var amounts: Array = []
		for item_id in content_item_ids:
			amounts.append(int(items.get(str(item_id), 0)))
		var result: Dictionary = source_building_item_dump_state.dump_item_state(true, inventory.items_total(items), neighbour_accepts_item.size(), output_item, inventory.item_count(items, output_item) > 0, content_item_ids, amounts, neighbour_accepts_item, neighbour_can_dump, cursor)
		cursor = int(result.get("cdump", cursor))
		dumped = bool(result.get("dumped", false))
		if dumped:
			var amounts_after: Array = result.get("item_amounts_by_index", amounts)
			for j in range(content_item_ids.size()):
				if j < amounts_after.size():
					items[str(content_item_ids[j])] = int(amounts_after[j])
	return {"fired": fired, "elapsed_after": elapsed_after, "dumped": dumped, "items_after": items, "cursor_after": cursor}

static func source_wall_crafter_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, drill_time: float, output_item: String, item_capacity: int) -> Dictionary:
	# The updateTile advance (WallCrafterBuild.updateTile(),
	# WallCrafter.java:187-223):
	# `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 40f);`
	# (WallCrafter.java:193), `float eff = getEfficiency(tile.x, tile.y, rotation, dest -> {`
	# (WallCrafter.java:196) with `Mathf.lerp(1f, liquidBoostIntensity, hasLiquidBooster ? optionalEfficiency : 0f)`
	# and `(itemValid ? itemBoostIntensity : 1f)` (WallCrafter.java:205),
	# `boolean itemValid = itemConsumer != null && itemConsumer.efficiency(this) > 0;`
	# (WallCrafter.java:191), `lastEfficiency = eff * timeScale * efficiency;`
	# (WallCrafter.java:211), `if(cons && (time += edelta() * eff) >= drillTime){`
	# (WallCrafter.java:213) with `offload(output);` and `time %= drillTime;`
	# (WallCrafter.java:214-215), `totalTime += edelta() * warmup * (eff <= 0f ? 0f : 1f);`
	# (WallCrafter.java:218). The build fields are
	# `public float time, warmup, totalTime, lastEfficiency;`
	# (WallCrafter.java:184); the class drillTime is
	# `public float drillTime = 150f;` (WallCrafter.java:33) while the
	# defs override it (110f / 48f, Blocks.java:3006/:3020), so
	# drill_time arrives as a parameter from the driver, which
	# reads it from the catalog. The boost intensities are the
	# class defaults `public float liquidBoostIntensity = 1.6f;`
	# (WallCrafter.java:35) and `public float itemBoostIntensity = 1.6f;`
	# (WallCrafter.java:47); neither def overrides them. The Arc
	# formulas, not guesses: approachDelta(from, to, speed) =
	# approach(from, to, Time.delta * speed) with approach =
	# from + clamp(to - from, -speed, speed), lerp = from +
	# (to - from) * progress, num(b) = b ? 1 : 0
	# (Mathf.java:208, 415-425). source_delta is Time.delta in
	# ticks (seconds * 60 through game_source_delta, arc
	# Time.java:26); edelta() = efficiency * delta() with
	# delta() = Time.delta * timeScale (BuildingComp.java:1922-1929).
	# efficiency and optionalEfficiency default 0.0, the Java
	# field defaults (BuildingComp.java:85 `transient float
	# efficiency;` / :87 `transient float optionalEfficiency;`);
	# warmup / time / totalTime default 0.0, the Java
	# build-field defaults (WallCrafter.java:184). The live
	# getEfficiency scan (WallCrafter.java:141-180) has no
	# helper in the port, so the base efficiency arrives as
	# the frame input efficiency_factor (default 0.0, the scan
	# result with no adjacent solid tiles); item_valid is
	# stamped live by the tick since N2264 (from the graphite
	# item row; false for the cliff-crusher, which has no item
	# row) and has_liquid_booster (default false) is a frame
	# input too. hasLiquidBooster is false for both
	# defs: `hasLiquidBooster = findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) != null;`
	# (WallCrafter.java:106) and the large def's hydrogen
	# consumer is not .boost() (Blocks.java:3028), so the
	# liquid lerp term is 1.0 live. cons is the N2201 pure
	# gate over the frame items (WallCrafter.java:227,
	# `return items.get(output) < itemCapacity;`); Java
	# short-circuits the time advance on cons, so with a full
	# store time does NOT advance at all, while totalTime
	# still advances (no cons guard) using the already-updated
	# warmup. Live since N2273/N2283 (not in this pure
	# function): the timerUse booster consume
	# (WallCrafter.java:207-209, live since N2273) and the
	# timerDump dump (WallCrafter.java:220-221, live since
	# N2283, frame-local Interval-equivalent at 5f/time_scale).
	# Deferred, not done here: the offload neighbor routing (BuildingComp.java:1001-1013
	# -- the shared inventory helper falls back to the own
	# inventory, the handleItem path, BuildingComp.java:1014/
	# :860-861), the updateEffect chance (WallCrafter.java:
	# 196-205), and the disabled early return
	# (BuildingComp.java:1954-1957, the driver gates the
	# advance on enabled). Until the getEfficiency fill lands
	# a live cliff-crusher never accumulates time.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var optional_efficiency: float = float(frame.get("optional_efficiency", 0.0))
	var efficiency_factor: float = float(frame.get("efficiency_factor", 0.0))
	var item_valid: bool = bool(frame.get("item_valid", false))
	var has_liquid_booster: bool = bool(frame.get("has_liquid_booster", false))
	var warmup: float = float(frame.get("warmup", 0.0))
	var time: float = float(frame.get("time", 0.0))
	var total_time: float = float(frame.get("total_time", 0.0))
	var items: Dictionary = frame.get("items", {})
	var target: float = 1.0 if efficiency > 0.0 else 0.0
	var step: float = source_delta * SOURCE_WALL_CRAFTER_WARMUP_SPEED
	var next_warmup: float = warmup + clampf(target - warmup, -step, step)
	var liquid_multiplier: float = lerpf(1.0, SOURCE_WALL_CRAFTER_LIQUID_BOOST_INTENSITY, optional_efficiency if has_liquid_booster else 0.0)
	var item_multiplier: float = SOURCE_WALL_CRAFTER_ITEM_BOOST_INTENSITY if item_valid else 1.0
	var eff: float = efficiency_factor * liquid_multiplier * item_multiplier
	var edelta: float = efficiency * source_delta * time_scale
	var last_efficiency: float = eff * time_scale * efficiency
	var gate: Dictionary = source_wall_crafter_should_consume_state(frame, output_item, item_capacity)
	var cons: bool = bool(gate.get("should_consume", true))
	var next_time: float = time
	var next_items: Dictionary = items
	var offloaded: bool = false
	if cons:
		next_time = time + edelta * eff
		if next_time >= drill_time:
			var offload_state: Dictionary = inventory.offload_item_state(items, output_item)
			next_items = offload_state.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, items)
			next_time = fmod(next_time, drill_time)
			offloaded = true
	var next_total_time: float = total_time + edelta * next_warmup * (0.0 if eff <= 0.0 else 1.0)
	return {"warmup": next_warmup, "eff": eff, "last_efficiency": last_efficiency, "time": next_time, "total_time": next_total_time, "offloaded": offloaded, "items": next_items}

@warning_ignore("unused_parameter")
static func source_wall_crafter_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the wall-crafter tick wiring every
	# tick (WallCrafterBuild.updateTile(), WallCrafter.java:187,
	# gates on the warmup fold (WallCrafter.java:193, `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 40f);`), so the warmup advance follows the folded efficiency; no placed-buildings driver ticks WallCrafter blocks, so this driver is the placed-wall-crafter tick): each placed WallCrafter build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_wall_crafter_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_wall_crafter_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_wall_crafter_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The frame carries the Building.liquids LiquidModule
		# (frame["liquids"]): the live store lives on the
		# sprite meta (source_building_liquids, initialized
		# at placement), so the driver syncs the reference
		# into the frame each tick BEFORE the fold, and the
		# pure liquid row reads the held hydrogen from it (the
		# Fracker:361 precedent).
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# N2264: the graphite booster row is computed here --
		# outside the consumption guard -- because itemValid
		# (WallCrafter.java:191, `boolean itemValid =
		# itemConsumer != null && itemConsumer.efficiency(this)
		# > 0;`) is a live updateTile read, not a machinery
		# input: the advance (N2223) reads frame["item_valid"]
		# every enabled tick, so the stamp must be live even
		# when the machinery skips (a cheating team). The
		# assigned `itemConsumer = consumeItem(Items.graphite).
		# boost();` (Blocks.java:3030) is captured by the
		# catalog as boosterItem, not a consumeItem row (the
		# N2115 precedent), so the driver reads it through the
		# block-metadata helper; the cliff-crusher has no
		# boosterItem and stamps false. consumeItem(item) is
		# one stack of 1 (Block.java:1167-1168). The row
		# itself folds into the optional pass inside the guard
		# below.
		var booster_item: String = source_block_metadata_state.block_booster_item(block)
		var has_item_consumer: bool = booster_item != ""
		var item_stacks: Array = [{"item": booster_item, "amount": 1}] if has_item_consumer else []
		var item_row: Dictionary = source_wall_crafter_item_consumer_row_state(frame, has_item_consumer, item_stacks)
		frame["item_valid"] = bool(item_row.get("item_valid", false))
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a wall crafter with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the warmup fold (WallCrafter.java:193)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a wall crafter does not take the early return. A wall crafter with no power consumer is untouched: the hydrogen row (N2264) folds in the same block, the graphite booster row folds the optional pass, and WallCrafterBuild overrides shouldConsume() to return items.get(output) < itemCapacity (WallCrafter.java:226-228) -- N2201 feeds the live gate to the machinery (the pure gate is source_wall_crafter_should_consume_state, fed the frame plus the catalog output item and itemCapacity); the N2170 RED decision is resolved. The gate has no enabled term (Java returns the bare capacity comparison); the outer guard below already runs the machinery only when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var output_item: String = str(block.properties.get("output", "sand"))
			var item_capacity: int = int(block.properties.get("itemCapacity", 10))
			var gate: Dictionary = source_wall_crafter_should_consume_state(frame, output_item, item_capacity)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_wall_crafter_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			# N2264: the hydrogen row folds in the same first
			# pass (ConsumeLiquid.efficiency,
			# ConsumeLiquid.java:42-47). The amount is per
			# def, read from the catalog consumeLiquid row
			# (large-cliff-crusher hydrogen 1f/60f,
			# Blocks.java:3028; the cliff-crusher has no
			# consumeLiquid row and contributes no row). The
			# hydrogen id resolves through the catalog
			# liquid_id_by_name (the Fracker precedent). In
			# the first pass efficiency is assumed 1f
			# (BuildingComp.java:1965), so the row's edelta
			# is source_delta * time_scale. The hydrogen
			# consumer is REQUIRED (not .boost()), so it
			# folds the min -- and a starved row stops power
			# draw (BuildingComp.java:1972).
			var tick_source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var tick_time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var hydrogen_amount := 0.0
			var has_liquid_consumer := false
			for row in block.properties.get("consumeLiquid", []):
				if str(row.get("liquid", "")) == SOURCE_WALL_CRAFTER_HYDROGEN_LIQUID:
					hydrogen_amount = float(row.get("amount", 0.0))
					has_liquid_consumer = true
			var hydrogen_id: int = int(liquid_id_by_name.get(SOURCE_WALL_CRAFTER_HYDROGEN_LIQUID, -1))
			var liquid_row: Dictionary = source_wall_crafter_liquid_consumer_row_state(frame, has_liquid_consumer, hydrogen_id, hydrogen_amount, tick_source_delta, tick_time_scale, float(frame.get("efficiency_scale", 1.0)))
			if bool(liquid_row.get("has_liquid_row", false)):
				required_results.append(liquid_row.get("row", {}))
			# N2264: the graphite booster row folds into the
			# OPTIONAL pass only (Consume.java:33-35, boost()
			# is optional(true, true); BuildingComp.java:
			# 1980-1981), capped by the min efficiency (:1986)
			# by the shared machinery -- it never lowers the
			# folded efficiency itself. The row was computed
			# above the guard (for the item_valid stamp), so
			# the fold reuses it.
			var optional_consumer_results: Array = []
			if bool(item_row.get("has_item_row", false)):
				optional_consumer_results.append(item_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, optional_consumer_results, [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# N2264 second pass (ConsumeLiquid.update,
			# ConsumeLiquid.java:37-39, `build.liquids.
			# remove(liquid, amount * build.edelta() *
			# multiplier.get(build));`): only when update &&
			# efficiency > 0 (BuildingComp.java:1999,
			# `if(update && efficiency > 0){`), with edelta
			# from the FOLDED efficiency (frame["efficiency"]
			# after the apply), not the assumed 1f. The
			# multiplier is the 1f default (Consume.java:18),
			# so it drops out of the removal amount. The
			# AdjacentFactory updates-array precedent
			# (SourceAdjacentFactoryBuildState.gd:382) needs
			# consumer actor objects with an update(self_state)
			# method built by reinitialize_consumers_state --
			# the wall-crafter driver has no such actor
			# infrastructure, so the removal is direct here,
			# through the shared liquid module helper
			# (SourceLiquidModuleState.source_remove_state,
			# clamped at the held amount like Java's
			# LiquidModule.remove, with a fresh cache_sums
			# sized to the store, the PayloadLoader
			# precedent). frame["liquids"] is the live sprite
			# store by reference, so the removal lands on it.
			# NO graphite removal here: Consume.update is empty
			# (`public void update(Building build){}`, Consume.java:52), so the second pass
			# never removes items -- the graphite is only
			# removed by consume() on the timer gate
			# (WallCrafter.java:207-209), which is live
			# since N2273 (the timer check runs after the
			# advance below).
			if has_liquid_consumer and bool(setup.get("update", false)) and float(frame.get("efficiency", 0.0)) > 0.0:
				var folded_edelta: float = float(frame.get("efficiency", 0.0)) * tick_source_delta * tick_time_scale
				var liquid_store: Dictionary = frame.get("liquids", {})
				if liquid_store.has("liquids") and hydrogen_id >= 0 and hydrogen_id < int(liquid_store["liquids"].size()):
					var cache_sums: Array = []
					cache_sums.resize(int(liquid_store["liquids"].size()))
					cache_sums.fill(0.0)
					source_liquid_module_state.source_remove_state(liquid_store, hydrogen_id, hydrogen_amount * folded_edelta, cache_sums)
		# N2223: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277; noUpdateDisabled defaults
		# false, Block.java:170, so Java runs updateTile even
		# when disabled -- in Java a disabled wall crafter's
		# warmup DECAYS toward 0 (efficiency is zeroed by the
		# disabled early return, BuildingComp.java:1954-1957)
		# and time freezes (edelta() is 0). The port keeps the
		# enabled gate below as a pragmatic choice (the N2195
		# coordinator-fix precedent): the driver skips the
		# consumption fold when disabled, so the frame
		# efficiency goes stale and running the advance on it
		# would charge warmup/time from a stale efficiency.
		# The driver-wide disabled-early-return slice
		# (deferred in the N2223 register) removes this gate
		# for all families. super.updateTile() is an empty
		# no-op (BuildingComp.java:2010-2012), so the driver
		# owes it nothing. The source delta is Time.delta in
		# ticks: game_source_delta(game, seconds) is seconds *
		# 60 (arc Time.java:26), never raw seconds. timeScale
		# reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`). drillTime /
		# output / itemCapacity come from the catalog per def
		# (cliff-crusher 110f / sand / 10, large 48f / sand /
		# 20; Blocks.java:3006/:3020/:3009/:3023/:3031).
		# The frame-local timer clock (N2273) accumulates
		# the tick delta EVERY tick, unconditionally --
		# mirroring Time.time, which grows even while the
		# gate is closed (arc Time.java:69-80, `timeRaw +=
		# delta;`), so the timer fires at once when the
		# gate reopens. It sits outside the enabled gate
		# below on purpose: a disabled wall crafter's
		# Interval keeps its old stamp in Java too.
		var timer_source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
		frame["timer_use_elapsed"] = float(frame.get("timer_use_elapsed", 0.0)) + timer_source_delta
		# N2283: the timerDump clock accumulates the same
		# tick delta, unconditionally, next to the timerUse
		# clock -- the two timers are independent
		# frame-local Interval-equivalents (timerDump,
		# Block.java:436; timerUse, WallCrafter.java:45),
		# and Java's Time.time grows even while the
		# building is disabled, so both clocks sit outside
		# the enabled gate below on purpose.
		frame["timer_dump_elapsed"] = float(frame.get("timer_dump_elapsed", 0.0)) + timer_source_delta
		if bool(frame.get("enabled", true)):
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var drill_time: float = float(block.properties.get("drillTime", SOURCE_WALL_CRAFTER_DRILL_TIME_DEFAULT))
			var advance_output_item: String = str(block.properties.get("output", "sand"))
			var advance_item_capacity: int = int(block.properties.get("itemCapacity", 10))
			var advanced: Dictionary = source_wall_crafter_update_tile_advance_state(frame, source_delta, time_scale, drill_time, advance_output_item, advance_item_capacity)
			frame["warmup"] = advanced["warmup"]
			frame["eff"] = advanced["eff"]
			frame["last_efficiency"] = advanced["last_efficiency"]
			frame["time"] = advanced["time"]
			frame["total_time"] = advanced["total_time"]
			frame["offloaded"] = advanced["offloaded"]
			frame["items"] = advanced["items"]
			# N2273: the timer-gated consume()
			# `if(itemValid && eff * efficiency > 0 && timer(timerUse, boostItemUseTime / timeScale)){`
			# (WallCrafter.java:207-209) runs AFTER the
			# advance: Java order is consume (:207-209)
			# BEFORE lastEfficiency/offload (:211-215), but
			# consume only removes 1 graphite (booster) --
			# it does not affect the offload (output item)
			# or this tick's eff (which uses the pre-tick
			# item_valid, stamped live by N2264 from the
			# item row outside the consumption guard) -- so
			# the post-advance check is order-equivalent
			# for this tick. eff is read from the advance
			# return dict; the advance function itself is
			# untouched. The duration is per def
			# (class default 120f, WallCrafter.java:45;
			# large-cliff-crusher 60f/0.75f = 80f,
			# Blocks.java:3032) through the family helper.
			# consume() removes 1 graphite DIRECTLY through
			# the shared inventory helper (clamped to the
			# held count, ItemModule.java:258-263) and the
			# elapsed clock resets to 0.0 (Interval.get
			# resets times[id] = Time.time on fire, arc
			# Interval.java:20-26). The cliff-crusher has
			# no booster item (booster_item is ""), so
			# nothing is removed for it -- but the elapsed
			# reset still applies on fire. The elapsed clock
			# is NOT reset when the gate is closed -- Java
			# short-circuits before calling timer(), so the
			# Interval keeps its old stamp and fires at once
			# when the gate reopens.
			var boost_item_use_time: float = _wall_crafter_boost_item_use_time_for_block(block_id)
			var timer_use: Dictionary = source_wall_crafter_timer_use_state(float(frame.get("timer_use_elapsed", 0.0)), boost_item_use_time, time_scale)
			if bool(frame.get("item_valid", false)) and float(advanced.get("eff", 0.0)) * float(frame.get("efficiency", 0.0)) > 0.0 and bool(timer_use.get("fired", false)):
				if booster_item != "":
					var timer_items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
					var timer_removed: Dictionary = inventory.remove_item_state(timer_items, booster_item, 1)
					frame["items"] = timer_removed.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, timer_items)
				frame["timer_use_elapsed"] = 0.0
			# N2283: the timerDump dump
			# `if(timer(timerDump, dumpTime / timeScale)){ dump(output); }`
			# (WallCrafter.java:220-221) runs AFTER the
			# advance and the timerUse consume -- the Java
			# order (:207-209 then :220-221): the dump
			# drains the store the advance filled, and the
			# timer fires at dumpTime / timeScale (5f /
			# timeScale, Block.java:438, no def overrides
			# it). The output item is sand for both defs
			# (WallCrafter.java:43; Blocks.java:3009/:3023).
			# The content item ids are the catalog order
			# Java iterates (content.items()), through the
			# payload-loader / payload-unloader precedent
			# (SourceContentRegistryRuntimeState.
			# source_item_catalog_state); the neighbour
			# acceptItem / canDump arrays are frame inputs
			# (default [] -- no neighbours, the Java
			# proximity.size == 0 outcome) until a live
			# proximity fill lands. The elapsed clock
			# resets to 0.0 on fire even when the dump
			# itself fails (Java resets the Interval on
			# timer() returning true, whatever dump()
			# then does); the items store and the cdump
			# cursor persist back into the frame.
			var content_item_ids: Array = source_content_registry_runtime_state.source_item_catalog_state(catalog).get("item_names_by_id", [])
			var dump_neighbour_accepts: Array = frame.get("dump_neighbour_accepts", [])
			var dump_neighbour_can_dump: Array = frame.get("dump_neighbour_can_dump", [])
			var dumped: Dictionary = source_wall_crafter_timer_dump_state(float(frame.get("timer_dump_elapsed", 0.0)), time_scale, frame, advance_output_item, content_item_ids, dump_neighbour_accepts, dump_neighbour_can_dump)
			frame["timer_dump_elapsed"] = dumped["elapsed_after"]
			frame["items"] = dumped["items_after"]
			frame["cdump"] = dumped["cursor_after"]
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
