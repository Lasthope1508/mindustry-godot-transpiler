extends RefCounted
class_name SourceSeparatorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")
const source_building_item_state := preload("res://src/game/SourceBuildingItemState.gd")
const source_block_query_filter_state := preload("res://src/game/SourceBlockQueryFilterState.gd")
const source_placed_power_graph_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")
const source_building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")

# The Separator implementation (Separator.java:19, `public class Separator extends Block{`): separator (consumePower 1.1f, Blocks.java:1243, `consumePower(1.1f);`; size 2, craftTime 35f, Blocks.java:1231-1246) and disassembler (consumePower 4f, Blocks.java:1262, `consumePower(4f);`; size 3, craftTime 15f, itemCapacity 20, Blocks.java:1248-1266). Separator extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_separator_building", the payload-deconstructor / unit-assembler-module precedent), and this slice adds the separator key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceSeparator* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile progress advance (Separator.java:133, `if(efficiency > 0){` with `progress += getProgressIncrease(craftTime);`) gates on efficiency > 0, so a separator with no power would advance progress as if power.status were 1.0.
const SOURCE_SEPARATOR_BUILD_IMPLEMENTATIONS := ["Separator"]
const SOURCE_SEPARATOR_BUILDING_META_KEY := "source_separator_building"
# Separator.java:23 `public float craftTime;` -- the per-def
# craft time: separator 35f (Blocks.java:1240, `craftTime = 35f;`),
# disassembler 15f (Blocks.java:1258, `craftTime = 15f;`). The
# catalog parses craftTime only for the GenericCrafter family,
# so the driver reads these constants.
const SOURCE_SEPARATOR_CRAFT_TIME := 35.0
const SOURCE_DISASSEMBLER_CRAFT_TIME := 15.0
# Separator.java:135/137, the warmup lerpDelta rate
# (`warmup = Mathf.lerpDelta(warmup, 1f, 0.02f);` /
# `warmup = Mathf.lerpDelta(warmup, 0f, 0.02f);`).
const SOURCE_SEPARATOR_WARMUP_RATE := 0.02
# Separator.java:83, the created() seed bound
# (`seed = Mathf.randomSeed(tile.pos(), 0, Integer.MAX_VALUE - 1);`):
# Integer.MAX_VALUE - 1.
const SOURCE_SEPARATOR_CREATED_SEED_MAX := 2147483646
# The ConsumeLiquid liquid (Blocks.java:1244/1264, `consumeLiquid(
# Liquids.slag, ...);`): the def constant the driver resolves
# through the catalog liquid_id_by_name (the Fracker oil
# precedent, SourceFrackerBuildState.gd:42).
const SOURCE_SEPARATOR_LIQUID := "slag"
# Block.java:438 `public int dumpTime = 5;` -- how often to try
# dumping items, in ticks (5 = 12 times/sec, Block.java:437);
# NO def overrides it anywhere in upstream (grep-verified: the
# only dumpTime hits are the Block.java:438 definition and the
# timer call sites), so the driver reads one constant. The
# timer id is `protected final int timerDump = timers++;`
# (Block.java:436).
const SOURCE_SEPARATOR_DUMP_TIME := 5.0
# The DrawRegion("-spinner", 3, true) rotate speed (Blocks.java:1246/1266,
# the DrawMulti def drawer shared by both defs): the spinner region
# rotates at totalProgress * rotateSpeed (DrawRegion.java:49).
const SOURCE_SEPARATOR_SPINNER_ROTATE_SPEED := 3.0
# BuildingComp.java:1313, the drawLight visualLiquid lerpDelta rate
# (`visualLiquid = Mathf.lerpDelta(visualLiquid, liquids.get(liq)>= 0.01f ? 1f : 0f, 0.06f);`).
const SOURCE_SEPARATOR_DRAW_LIGHT_RATE := 0.06
# BuildingComp.java:1326, the Drawf.light radius factor
# (`Drawf.light(x, y, block.size * 30f * fract, color, opacity * amount);`, fract = 1f).
const SOURCE_SEPARATOR_DRAW_LIGHT_RADIUS := 30.0

static func _is_separator_build_implementation(implementation: String) -> bool:
	return SOURCE_SEPARATOR_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_separator_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The separator tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (Separator.java:19, `public class Separator extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# separator skips consumption like Java's updateConsumption
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
	# for this separator (N2125); the tick preserves a disabled
	# separator instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	# The frame carries the Building.items ItemModule
	# (frame["items"], Dictionary keyed by item name, the factory
	# precedent SourceFactoryBuildState.gd:89-101); the tick
	# preserves the held items instead of resetting them -- no
	# live intake fills them yet (the intake slice), so the
	# shouldConsume gate reads the frame as-is.
	if not frame.has("items"):
		frame["items"] = {}
	return frame

static func _initial_frame() -> Dictionary:
	# A new SeparatorBuild starts with an empty item module (the
	# Building.items ItemModule, the factory precedent
	# SourceFactoryBuildState.gd:89-101, `frame["items"] = {}`):
	# the shouldConsume gate (Separator.java:92-101) reads
	# items.total() minus the consItems buffer, so the frame
	# carries the items Dictionary keyed by item name. The
	# frame also carries the Building.liquids LiquidModule
	# (frame["liquids"], the Fracker precedent): the liquid
	# consumer row (N2252) reads the held slag from it, and
	# the tick syncs the live sprite store into it each tick.
	return {"items": {}, "liquids": {}}

static func source_separator_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the separator frame meta key
	# ("source_separator_building"). A Separator sprite gets a
	# frame bound with an empty items module (frame["items"] =
	# {}, the Building.items ItemModule); the live-loop tick
	# fills its other keys every tick. Any other block, or an
	# already-bound sprite, binds nothing.
	if block == null or not _is_separator_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_SEPARATOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_SEPARATOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_SEPARATOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_separator_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a separator does not take the early return. The progress advance follows the folded efficiency (Separator.java:133, `if(efficiency > 0){` with `progress += getProgressIncrease(craftTime);`) and the shouldConsume override (Separator.java:92, `public boolean shouldConsume(){` with `return total < itemCapacity && enabled;`, Separator.java:100; default BuildingComp.java:755, `public boolean shouldConsume(){`) -- SeparatorBuild (Separator.java:75, `public class SeparatorBuild extends Building{`) overrides shouldConsume() to return total < itemCapacity && enabled, so the default does not apply here; the gate is live since N2200 (the pure gate source_separator_should_consume_state feeds total-minus-consItems-buffer < itemCapacity && enabled to the machinery; when the gate is false updateConsumption forces efficiency to 0, BuildingComp.java:1960 + 1992). The separator (consumePower 1.1f, Blocks.java:1243, `consumePower(1.1f);`; disassembler consumePower 4f, Blocks.java:1262, `consumePower(4f);`) also consumes liquid slag (separator `consumeLiquid(Liquids.slag, 4f / 60f);`, Blocks.java:1244; disassembler `consumeLiquid(Liquids.slag, 0.12f);`, Blocks.java:1264) -- the liquid row is live since N2252 (source_separator_liquid_consumer_row_state) and the disassembler scrap item row is live since N2349 (source_separator_disassembler_scrap_row_state), so the folded efficiency is the min over the *modeled* consumers (power + liquid + item).
	# Documented limits: (1) liquid row live (N2252) -- the separator consumes liquid slag (separator 4f/60f, Blocks.java:1244; disassembler 0.12f per frame, Blocks.java:1264), folded by the pure liquid row (source_separator_liquid_consumer_row_state, ConsumeLiquid.efficiency, ConsumeLiquid.java:42-47) with the second-pass removal (ConsumeLiquid.update, ConsumeLiquid.java:37-39); the folded efficiency is the min over the *modeled* consumers (power + liquid + item). The disassembler scrap item row is live since N2349 (item row live (N2349), source_separator_disassembler_scrap_row_state, ConsumeItems.efficiency, ConsumeItems.java:51-53, binary 1/0 on items.has(scrap, 1)) -- the scrap is only removed by consume() in the updateTile advance (N2222), and a disassembler with no scrap now folds efficiency 0 on the item row; the separator def has no consumeItem, so it contributes no row. (2) shouldConsume gate live (N2200) -- SeparatorBuild overrides shouldConsume() to return total < itemCapacity && enabled (Separator.java:92-100, `return total < itemCapacity && enabled;`); the pure gate reads the frame items Dictionary (minus the consItems buffer from the catalog consumeItem rows) and feeds should_consume to the machinery; when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994). No live intake fills frame["items"] yet -- the gate reads the frame as-is, and intake waits for its own slice. (3) Partial updateTile advance (N2222) -- progress / warmup / totalProgress / seed / consume() / the offload random result pick (Separator.java:130-167) advance each tick, and a fresh frame is seeded from its tile position like created() (Separator.java:82-84); the timerDump dump is live since N2281 (source_separator_timer_dump_state, the frame-local Interval-equivalent, dumpTime 5f / timeScale, Separator.java:165-166, dump(null) through the shared dump_item_state routing; first-fire deviation: Java fires nearly at once after placement, the frame clock delays the first fire by one interval, 5 ticks); the offload neighbor routing live since N2343 (the tick builds the routing context from the shared dump neighbour frame inputs and passes it into the advance, so the picked result routes to the first accepting neighbour from the cdump cursor, BuildingComp.java:1001-1016; the offload neighbour write-back live since N2353 (the advance exposes the routed neighbour index and the tick calls the shared neighbour write-back helper, so the routed item lands in the neighbour frame or belt queue)); the timerDump dump neighbour write-back live since N2361 (the advance exposes the routed neighbour index + dumped item and the tick calls the shared neighbour write-back helper, so the dumped item lands in the neighbour frame or belt queue); the dump neighbour live fill is live since N2402 (the tick fills the neighbour acceptItem / canDump arrays from the live proximity before the timerDump dump reads them, the N2394 precedent: supplied arrays win, a live-filled frame refreshes every tick). (4) Sense rows live (N2388) -- the sense pure (source_separator_sense_state) models sense() (:169-172): progress returns the frame progress as-is, NO clamp, and other sensors return the caller-supplied super_value (null = the Float.NaN default branch); canDump live since N2395 (source_separator_can_dump_state + source_separator_item_filter_state, pure-only: the def filter is built from the catalog consumeItem rows, all-false for the separator, scrap-only for the disassembler; the N2388 'canDump still waits' deferral is resolved, DEFERRED #300). Draw rows live (N2419) -- draw / drawLight / icons / drawPlanRegion are live as pure-only draw pures (source_separator_draw_state + source_separator_draw_plan_state, the DrawMulti def drawer, Blocks.java:1246/1266, NOT the DrawDefault class default, Separator.java:25); read/write (Separator.java:180-194) and shouldAmbientSound (Separator.java:87-89) still defer (serialization / lifecycle, not tick state); created() (Separator.java:82-84) is live since N2222 (the driver seeds a fresh frame from its tile position). (5) Disassembler variant verification pending -- the same driver covers both defs via the catalog consumePower.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_separator_liquid_consumer_row_state(frame: Dictionary, has_liquid_consumer: bool, liquid_id: int, amount: float, source_delta: float, time_scale: float, efficiency_scale: float, multiplier: float = 1.0) -> Dictionary:
	# ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47, `float ed = build.edelta() * build.efficiencyScale();` / `if(ed <= 0.00000001f) return 0f;` / `return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);`): the liquid consumer's efficiency is the held liquid over the per-frame demand, capped at 1, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`); a starved non-power row also stops power draw (`if(cons != block.consPower && result <= 0.0000001f){`, BuildingComp.java:1972, folded by the shared machinery). In the first pass efficiency is assumed 1f (BuildingComp.java:1965, `efficiency = optionalEfficiency = 1f;`), so edelta() is delta() = source_delta * time_scale (BuildingComp.java:1922-1929, `return Time.delta * timeScale;` / `return efficiency * delta();`). The multiplier defaults to 1f (Consume.java:18, `public Floatf<Building> multiplier = b -> 1f;`); neither def sets one (Blocks.java:1244/1264 are bare consumeLiquid calls). The amount is per def (separator `consumeLiquid(Liquids.slag, 4f / 60f);`, Blocks.java:1244; disassembler `consumeLiquid(Liquids.slag, 0.12f);`, Blocks.java:1264 -- 0.12f PER FRAME, 7.2/s, not /60f) and arrives from the catalog consumeLiquid row, so the driver reads no per-def constant here. The held amount comes from the shared liquid module helper (SourceLiquidModuleState.source_get_state, reused through a preload, NOT re-implemented) over the frame liquids key (the Building.liquids LiquidModule dict, default {} for a frame bound before this slice, amount 0.0 when the store has no entry for the liquid -- Java's liquids.get returns 0.0 for a liquid never added), with the Fracker guard (SourceFrackerBuildState.gd:279, `liquids.has("liquids")` + bounds check). A block with no liquid consumer contributes no row (the LaunchPad precedent: launch-pad has no liquid consumer, so its has_liquid_row is false). The second pass removes the consumed slag (ConsumeLiquid.update, ConsumeLiquid.java:37-39, `build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));`, only when `if(update && efficiency > 0){`, BuildingComp.java:1999) -- the tick does that after the fold, with edelta from the folded efficiency.
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

static func source_separator_disassembler_scrap_row_state(frame: Dictionary, has_item_consumer: bool, stacks: Array, multiplier: float = 1.0) -> Dictionary:
	# ConsumeItems.efficiency (ConsumeItems.java:51-53, `return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;`): BINARY 1/0, not a ratio -- 1 when the building is burning a trigger consumer or its item module holds every stack, 0 otherwise. consumeTriggerValid() is false at the base (BuildingComp.java:764-766, `public boolean consumeTriggerValid(){` with `return false;`) and no Separator build overrides it (Separator.java has no consumeTriggerValid; only ConsumeGeneratorBuild overrides it, ConsumeGenerator.java:152), so the trigger term is always false here. items.has (ItemModule.java:153-156, `if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;`) requires EVERY stack to hold round(amount * multiplier), with has(item, amount) = get(item) >= amount (ItemModule.java:126-128, `return get(item) >= amount;`); the port's item module is a Dictionary keyed by item name, so an unknown item reads 0 through the shared inventory helper (SourceDrillInventoryRuntimeState.item_count, reused through a preload, NOT re-implemented), the same outcome as the id-out-of-range branch. The multiplier defaults to 1f (Consume.java:18, `public Floatf<Building> multiplier = b -> 1f;`); the disassembler def sets none (`consumeItem(Items.scrap);`, Blocks.java:1263, is one stack of 1: `return consumeItem(item, 1);`, Block.java:1167-1168). The row is REQUIRED (non-optional) -- the def never calls .boost() -- so it folds the FIRST pass (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`) and the shared fold sets shouldConsumePower=false when the row is <= 1e-7 (BuildingComp.java:1972-1973, `if(cons != block.consPower && result <= 0.0000001f){` / `shouldConsumePower = false;`). The stacks arrive explicit from the driver (the catalog consumeItem rows, [{"item": "scrap", "amount": 1}] for the disassembler); the separator def has no consumeItem (Blocks.java:1231-1246), so it contributes no row. No removal here: Consume.update is empty (Consume.java:52, `public void update(Building build){}`), so the second pass never removes items -- the scrap is only removed by consume() in the updateTile advance (Separator.java:158, live since N2222, `build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));`, ConsumeItems.java:44-48). No live intake fills frame["items"] yet (the "Separator items intake rows" DEFERRED entry stays), so a live disassembler reads the frame as-is.
	if not has_item_consumer:
		return {"has_item_row": false, "row": {}}
	var items: Dictionary = frame.get("items", {})
	var result := 1.0
	for stack in stacks:
		var item_name: String = str(stack.get("item", ""))
		var needed: int = int(round(float(stack.get("amount", 0)) * multiplier))
		if inventory.item_count(items, item_name) < needed:
			result = 0.0
	if result <= 0.0:
		return {"has_item_row": true, "row": {"result": 0.0, "is_power": false}}
	return {"has_item_row": true, "row": {"result": 1.0, "is_power": false}}

static func source_separator_should_consume_state(frame: Dictionary, cons_item_names: Array, item_capacity: int) -> Dictionary:
	# SeparatorBuild.shouldConsume() (Separator.java:92-101, `public boolean shouldConsume(){` with `return total < itemCapacity && enabled;`, Separator.java:100): `int total = items.total();` (Separator.java:93), then -- when the block has a ConsumeItems consumer -- the consItems buffer is subtracted (`for(ItemStack stack : consItems.items){` / `total -= items.get(stack.item);`, Separator.java:96-97; consItems is found by init(), `consItems = findConsumer(c -> c instanceof ConsumeItems);`, Separator.java:58, from `protected @Nullable ConsumeItems consItems;`, Separator.java:21, so it is null on a def with no consumeItem). The separator def has no consumeItem (Blocks.java:1231-1246), so its consItems is null and nothing is subtracted; the disassembler consumes scrap (`consumeItem(Items.scrap);`, Blocks.java:1263), so the held scrap is subtracted. The capacity is the catalog itemCapacity (`public int itemCapacity = 10;`, Block.java:75, the default; disassembler `itemCapacity = 20;`, Blocks.java:1260). The total is the drill inventory total (SourceDrillInventoryRuntimeState.items_total, reused through the inventory preload, not recomputed) minus the held count of each cons item (item_count); the frame carries the Building.items ItemModule (frame["items"], Dictionary keyed by item name, the factory precedent SourceFactoryBuildState.gd:89-101). When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). SeparatorBuild overrides shouldConsume (Separator.java:75, `public class SeparatorBuild extends Building{`; Separator.java:19, `public class Separator extends Block{`), so the default (`return enabled;`, BuildingComp.java:755-756) does not apply here. The updateTile progress advance (Separator.java:133, `if(efficiency > 0){` with `progress += getProgressIncrease(craftTime);`) follows the folded efficiency and is live since N2222 (source_separator_update_tile_advance_state).
	var items: Dictionary = frame.get("items", {})
	var total: int = inventory.items_total(items)
	for cons_item_name in cons_item_names:
		total -= inventory.item_count(items, str(cons_item_name))
	var enabled: bool = bool(frame.get("enabled", true))
	return {"should_consume": total < item_capacity and enabled, "total": total}

static func _separator_rand_unsigned_shift_right(value: int, shift: int) -> int:
	# Java `>>>` (logical shift right) has no GDScript
	# operator: an arithmetic >> plus a mask to the surviving
	# bits gives the same value. Rand.java uses >>> 33
	# (murmurHash3), >>> 17 / >>> 26 (nextLong) and >>> 1
	# (nextLong(n)); each branch masks to 64 - shift bits.
	if shift == 1:
		return (value >> 1) & 0x7FFFFFFFFFFFFFFF
	if shift == 17:
		return (value >> 17) & 0x7FFFFFFFFFFF
	if shift == 26:
		return (value >> 26) & 0x3FFFFFFFFF
	return (value >> 33) & 0x7FFFFFFF

static func _separator_rand_murmur_hash3(value: int) -> int:
	# Rand.java murmurHash3 (Rand.java:52-60): `x ^= x >>> 33;`
	# `x *= 0xff51afd7ed558ccdL;` `x ^= x >>> 33;`
	# `x *= 0xc4ceb9fe1a85ec53L;` `x ^= x >>> 33;`. The
	# constants are the signed forms from SourceMathDefaults
	# (RAND_MURMUR_CONST1 / RAND_MURMUR_CONST2); int64
	# arithmetic wraps (the SourceMathState murmur precedent).
	var h: int = value
	h = h ^ _separator_rand_unsigned_shift_right(h, 33)
	h = h * source_math_defaults.RAND_MURMUR_CONST1
	h = h ^ _separator_rand_unsigned_shift_right(h, 33)
	h = h * source_math_defaults.RAND_MURMUR_CONST2
	h = h ^ _separator_rand_unsigned_shift_right(h, 33)
	return h

static func _separator_rand_set_seed(seed_value: int) -> Dictionary:
	# Rand.java setSeed (Rand.java:181-184):
	# `long seed0 = murmurHash3(seed == 0 ? Long.MIN_VALUE : seed);`
	# `setState(seed0, murmurHash3(seed0));`. The state is the
	# two xorshift128+ halves; a Dictionary carries them
	# (GDScript has no out-params on a pure static).
	var seed0: int = _separator_rand_murmur_hash3(source_math_defaults.INT64_MIN if seed_value == 0 else seed_value)
	return {"seed0": seed0, "seed1": _separator_rand_murmur_hash3(seed0)}

static func _separator_rand_next_long(rand_state: Dictionary) -> int:
	# Rand.java nextLong (Rand.java:65-77, xorshift128+):
	# `s1 ^= s1 << 23;`
	# `return (this.seed1 = (s1 ^ s0 ^ (s1 >>> 17) ^ (s0 >>> 26))) + s0;`
	# with s1 = seed0, s0 = seed1, seed0 = s0 first.
	var s1: int = int(rand_state.get("seed0", 0))
	var s0: int = int(rand_state.get("seed1", 0))
	rand_state["seed0"] = s0
	s1 = s1 ^ (s1 << 23)
	var next: int = s1 ^ s0 ^ _separator_rand_unsigned_shift_right(s1, 17) ^ _separator_rand_unsigned_shift_right(s0, 26)
	rand_state["seed1"] = next
	return next + s0

static func _separator_rand_next_long_bound(rand_state: Dictionary, bound: int) -> int:
	# Rand.java nextLong(n) (Rand.java:115-122), which
	# nextInt(n) calls: rejection sampling --
	# `final long bits = nextLong() >>> 1;`
	# `if(bits - value + (n - 1) >= 0) return value;` with
	# value = bits % n.
	var accepted := false
	var value := 0
	while not accepted:
		var bits: int = _separator_rand_unsigned_shift_right(_separator_rand_next_long(rand_state), 1)
		value = bits % bound
		accepted = bits - value + (bound - 1) >= 0
	return value

static func _separator_random_seed_int(source_seed: int, min_value: int, max_value: int) -> int:
	# Arc Mathf.randomSeed(long seed, int min, int max)
	# (Mathf.java:297-302), inclusive:
	# `public static int randomSeed(long seed, int min, int max){`
	# `seedr.setSeed(seed);`
	# `if(isPowerOfTwo(max)){`
	# `return seedr.nextInt(max - min + 1) + min;`
	# NOTE: this is NOT SourceMathState.random_seed_int --
	# that helper seeds a single-state murmur chain with seed *
	# 99999 (the float-overload seeding) and masks on the
	# power-of-two path, so it draws different values than
	# Arc's two-state xorshift128+ Rand; the separator's
	# weighted pick needs the Arc values, so this slice ports
	# Rand faithfully here (the N2191 local-helper precedent,
	# no separate symbol). A Python reference implementation
	# of Rand.java + Mathf.java:297-302 agrees with this
	# GDScript line for line (1030 seed/bound cases); the
	# proof pins its exact picks.
	var rand_state: Dictionary = _separator_rand_set_seed(source_seed)
	if max_value != 0 and (max_value & (max_value - 1)) == 0:
		_separator_rand_next_long(rand_state)
	return _separator_rand_next_long_bound(rand_state, max_value - min_value + 1) + min_value

static func _separator_to_short(value: int) -> int:
	# The Java (short) cast: truncate to the low 16 bits, then
	# sign-extend (Point2.pack/unpack cast through short, arc
	# Point2.java:35-42); GDScript ints are 64-bit, so the wrap
	# is explicit (the ItemBridge _to_short precedent).
	var truncated: int = value & 0xFFFF
	if truncated >= 0x8000:
		return truncated - 0x10000
	return truncated

static func _separator_point2_pack(x: int, y: int) -> int:
	# Point2.pack (arc Point2.java:40-42, `return (((short)x) << 16) | (((short)y) & 0xFFFF);`).
	return (_separator_to_short(x) << 16) | (_separator_to_short(y) & 0xFFFF)

static func _separator_craft_time_for_block(block_id: String) -> float:
	# craftTime is a per-def field (Separator.java:23
	# `public float craftTime;`): separator 35f
	# (Blocks.java:1240, `craftTime = 35f;`), disassembler 15f
	# (Blocks.java:1258, `craftTime = 15f;`). The catalog
	# parses craftTime only for the GenericCrafter family, so
	# the driver reads these constants; an unknown Separator
	# id falls back to the separator def.
	if block_id == "disassembler":
		return SOURCE_DISASSEMBLER_CRAFT_TIME
	return SOURCE_SEPARATOR_CRAFT_TIME

static func _separator_results_for_block(block_id: String) -> Array:
	# results = with(...) per def (Separator.java:22
	# `public ItemStack[] results;`): separator copper 5 /
	# lead 3 / graphite 2 / titanium 2 (Blocks.java:1233-1239,
	# `results = with(`, `Items.copper, 5,`), disassembler sand
	# 2 / graphite 1 / titanium 1 / thorium 1
	# (Blocks.java:1251-1257, `Items.sand, 2,`). Built fresh
	# per call: a const Array of Dictionaries would be shared
	# state.
	if block_id == "disassembler":
		return [{"item": "sand", "amount": 2}, {"item": "graphite", "amount": 1}, {"item": "titanium", "amount": 1}, {"item": "thorium", "amount": 1}]
	return [{"item": "copper", "amount": 5}, {"item": "lead", "amount": 3}, {"item": "graphite", "amount": 2}, {"item": "titanium", "amount": 2}]

static func source_separator_offload_routing_context_state(neighbour_accepts: Array, neighbour_can_dump: Array, dump_cursor: int) -> Dictionary:
	# The routing context for the offload in the updateTile
	# advance (Separator.java:160-161, `if(item != null && items.get(item) < itemCapacity){`
	# with `offload(item);`): offload()
	# (`public void offload(Item item){`,
	# BuildingComp.java:1001-1016) scans proximity from the
	# saved cdump -- `produced(item, 1);` (:1002),
	# `int dump = this.cdump;` (:1003), then
	# `for(int i = 0; i < proximity.size; i++){` (:1005)
	# with `incrementDump(proximity.size);` BEFORE the check
	# (:1006) and `Building other = proximity.get((i + dump) % proximity.size);`
	# (:1007) -- rotate the cursor, then inspect from its
	# saved value (the offload_item_state order,
	# SourceDrillInventoryRuntimeState.gd:115-143) -- handing
	# the item to the first neighbour where
	# `if(other.acceptItem(self(), item) && canDump(other, item)){`
	# (:1008) holds, via `other.handleItem(self(), item);`
	# (:1009), and falling back to `handleItem(self(), item);`
	# (:1014) when no neighbour takes it. incrementDump
	# (`public void incrementDump(int prox){`,
	# BuildingComp.java:1116-1120, guarded on prox != 0) is
	# `cdump = ((cdump + 1) % prox);`, so a routed pick leaves
	# the cursor past the handling neighbour and a full
	# refused scan returns it to its start (the N2286
	# full-cycle invariant); the cursor is the Building field
	# `transient int cdump;` (BuildingComp.java:68, 0). This
	# pure builds the context the shared offload_item_state
	# port reads: the neighbors array [{accepts_item,
	# can_dump, item_count}] plus the dump cursor
	# (SOURCE_DRILL_INVENTORY_NEIGHBORS_KEY /
	# SOURCE_DRILL_INVENTORY_DUMP_CURSOR_KEY, "neighbors" /
	# "dump_cursor"), from the frame neighbour inputs -- the
	# SAME arrays the N2281 dump reads
	# (dump_neighbour_accepts / dump_neighbour_can_dump,
	# default []): Java has ONE proximity list, and offload()
	# and dump() scan the same neighbours with the same
	# acceptItem/canDump answers, so the port keeps one pair
	# of frame inputs instead of adding a synonym pair. The
	# cursor passes through unchanged -- offload_item_state
	# normalizes it via modulo, like incrementDump -- and
	# item_count starts at 0 (the port bumps it on the
	# handled neighbour). A missing answer in one array reads
	# false (the dump_item_state bounds-checked precedent),
	# so a mismatched pair still scans the longer proximity
	# with the missing side refusing. With empty inputs the
	# context carries an empty neighbors array, the Java
	# proximity.size == 0 outcome, and the offload falls back
	# to the building's own items. Still deferred: the live
	# fill of the shared frame inputs (the N2281 dump entry)
	# and the offload neighbour write-back (a routed item
	# leaves the separator without landing in a neighbour
	# store -- the shared port only bumps the ephemeral
	# neighbour dict item_count).
	var neighbors: Array = []
	var count: int = maxi(neighbour_accepts.size(), neighbour_can_dump.size())
	for index in range(count):
		var accepts_item: bool = index < neighbour_accepts.size() and bool(neighbour_accepts[index])
		var can_dump: bool = index < neighbour_can_dump.size() and bool(neighbour_can_dump[index])
		neighbors.append({"accepts_item": accepts_item, "can_dump": can_dump, "item_count": 0})
	return {
		inventory.SOURCE_DRILL_INVENTORY_NEIGHBORS_KEY: neighbors,
		inventory.SOURCE_DRILL_INVENTORY_DUMP_CURSOR_KEY: dump_cursor,
	}

static func source_separator_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, craft_time: float, results: Array, cons_items: Array, item_capacity: int, routing_context: Dictionary = {}) -> Dictionary:
	# The updateTile advance (SeparatorBuild.updateTile(),
	# Separator.java:130-167): `totalProgress += warmup * delta();`
	# (Separator.java:131), `if(efficiency > 0){` with
	# `progress += getProgressIncrease(craftTime);`
	# (Separator.java:133-134), `warmup = Mathf.lerpDelta(warmup, 1f, 0.02f);`
	# (Separator.java:135) else `warmup = Mathf.lerpDelta(warmup, 0f, 0.02f);`
	# (Separator.java:137), `if(progress >= 1f){` with
	# `progress %= 1f;` (Separator.java:140-141), the weighted
	# pick `int i = Mathf.randomSeed(seed++, 0, sum - 1);`
	# (Separator.java:145) over `for(ItemStack stack : results){`
	# (Separator.java:150) with `if(i >= count && i < count + stack.amount){`
	# (Separator.java:151) and `item = stack.item;`
	# (Separator.java:152), `consume();` (Separator.java:158),
	# and `if(item != null && items.get(item) < itemCapacity){`
	# with `offload(item);` (Separator.java:160-161).
	# getProgressIncrease is the BuildingComp base
	# (BuildingComp.java:1203-1205, `return 1f / baseTime * edelta();`)
	# -- Separator extends Block, not GenericCrafter, so no
	# override applies. delta() is `return Time.delta * timeScale;`
	# (BuildingComp.java:1922-1924), edelta() is
	# `return efficiency * delta();` (BuildingComp.java:1927-1929);
	# source_delta is Time.delta in ticks (seconds * 60 through
	# game_source_delta, arc Time.java:26), never raw seconds.
	# lerpDelta scales by Time.delta, not delta()
	# (Mathf.java:430-432), so the warmup lerp uses the
	# unscaled source delta. The frame fields default to 0 /
	# 0.0 / {} (Separator.java:76-79, `public float progress;`
	# `public float totalProgress;` `public float warmup;`
	# `public int seed;`; BuildingComp.java:85
	# `transient float efficiency;`). consume() triggers every
	# consumer (`for(Consume cons : block.consumers){`
	# `cons.trigger(self());`, BuildingComp.java:1911-1915)
	# but only ConsumeItems removes anything
	# (`build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));`,
	# ConsumeItems.java:44-48, at the default
	# `public Floatf<Building> multiplier = b -> 1f;`,
	# Consume.java:18), clamped at what the module holds
	# (`amount = Math.min(amount, items[item.id]);`,
	# ItemModule.java:258-262) -- the port removes through
	# inventory.remove_item_state, clamped the same way. The
	# offload (`public void offload(Item item){`,
	# BuildingComp.java:1001-1016, `produced(item, 1);`,
	# `int dump = this.cdump;`, `handleItem(self(), item);`)
	# runs through inventory.offload_item_state with the
	# routing context -- live since N2343, the tick builds
	# the context from the shared dump neighbour frame inputs
	# (dump_neighbour_accepts / dump_neighbour_can_dump,
	# default []) plus the frame cdump and passes it in, so
	# the picked result routes to the first accepting
	# neighbour from the saved cursor; with no neighbours
	# (the default [] inputs) it falls back to the building's
	# own items, the Java no-neighbor-accepts outcome. The
	# advance exposes the offload outcome
	# (offload_neighbour_index / offload_routed) so the tick
	# can write the routed item into the neighbour store
	# (N2353). A
	# context without a dump cursor defaults it from the
	# frame cdump (offload() reads `this.cdump`,
	# BuildingComp.java:1003), so a context-less craft no
	# longer clobbers the frame cursor to 0 on the fallback
	# path. The timerDump dump is live since N2281
	# (source_separator_timer_dump_state, wired after this
	# advance in the tick:
	# `if(timer(timerDump, dumpTime / timeScale)){ dump(); }`,
	# Separator.java:165-166). The offload neighbour
	# write-back is live since N2353 (the advance exposes
	# offload_neighbour_index / offload_routed and the tick
	# calls the shared neighbour write-back helper); the
	# live fill of the shared neighbour frame inputs still
	# waits (the N2281 dump entry). With empty results there is no
	# pick (sum <= 0): Java would throw in randomSeed, so the
	# branch skips pick/consume/offload -- unreachable for
	# both defs, which always carry results.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var progress: float = float(frame.get("progress", 0.0))
	var warmup: float = float(frame.get("warmup", 0.0))
	var total_progress: float = float(frame.get("total_progress", 0.0))
	var seed: int = int(frame.get("seed", 0))
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var cdump: int = int(frame.get("cdump", 0))
	var delta: float = source_delta * time_scale
	total_progress += warmup * delta
	if efficiency > 0.0:
		progress += (1.0 / craft_time) * efficiency * delta
		warmup = lerpf(warmup, 1.0, clampf(SOURCE_SEPARATOR_WARMUP_RATE * source_delta, 0.0, 1.0))
	else:
		warmup = lerpf(warmup, 0.0, clampf(SOURCE_SEPARATOR_WARMUP_RATE * source_delta, 0.0, 1.0))
	var crafted := false
	var picked_item := ""
	var offload_neighbour_index := -1
	var offload_routed := false
	if progress >= 1.0:
		crafted = true
		progress = fposmod(progress, 1.0)
		var sum := 0
		for stack in results:
			var stack_dict: Dictionary = stack
			sum += int(stack_dict.get("amount", 0))
		if sum > 0:
			var pick_seed: int = seed
			seed += 1
			var picked_index: int = _separator_random_seed_int(pick_seed, 0, sum - 1)
			var count := 0
			for stack in results:
				var stack_dict: Dictionary = stack
				var amount: int = int(stack_dict.get("amount", 0))
				if picked_index >= count and picked_index < count + amount:
					picked_item = str(stack_dict.get("item", ""))
					break
				count += amount
			for cons in cons_items:
				var cons_dict: Dictionary = cons
				var removed: Dictionary = inventory.remove_item_state(items, str(cons_dict.get("item", "")), int(cons_dict.get("amount", 1)))
				items = removed.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, items)
			if picked_item != "" and inventory.item_count(items, picked_item) < item_capacity:
				var offload_context: Dictionary = routing_context.duplicate(true)
				if not offload_context.has(inventory.SOURCE_DRILL_INVENTORY_DUMP_CURSOR_KEY):
					offload_context[inventory.SOURCE_DRILL_INVENTORY_DUMP_CURSOR_KEY] = cdump
				var offloaded: Dictionary = inventory.offload_item_state(items, picked_item, offload_context)
				items = offloaded.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, items)
				cdump = int(offloaded.get(inventory.SOURCE_DRILL_INVENTORY_C_DUMP_KEY, cdump))
				offload_routed = bool(offloaded.get("routed", false))
				offload_neighbour_index = int(offloaded.get(inventory.SOURCE_DRILL_INVENTORY_HANDLED_INDEX_KEY, -1))
	return {"progress": progress, "warmup": warmup, "total_progress": total_progress, "seed": seed, "items": items, "cdump": cdump, "picked_item": picked_item, "crafted": crafted, "offload_neighbour_index": offload_neighbour_index, "offload_routed": offload_routed}

static func source_separator_dump_neighbour_live_fill_state(game: Object, cell: Vector2i, size: int, frame: Dictionary, item_order: Array) -> Dictionary:
	# The dump neighbour live fill (N2402, DEFERRED #226):
	# the N2281 timerDump dump reads the two neighbour arrays
	# as frame inputs (default [] -- no neighbours, the Java
	# proximity.size == 0 outcome), so a live separator with
	# no fill never dumped. This fill scans the live
	# proximity BEFORE the timerDump dump reads the frame
	# arrays and fills the two arrays from the live neighbour
	# frames, in ring order (index i is ring cell i, the
	# N2353 convention -- the ring comes from
	# source_block_proximity_cells_state, the sprite from
	# block_sprite_at_cell, the frame from the first
	# SOURCE_CONSUMER_FRAME_META_KEYS meta on the sprite,
	# the N2353/N2371 resolution path):
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
	# and the dump routing gates on both:
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
	# override dispatch is a follow-through note). The
	# Separator's OWN canDump model is live (N2395) but this
	# fill judges NEIGHBOURS -- the Separator's own canDump
	# matters when OTHER blocks dump INTO the separator. A
	# neighbour with no frame (no sprite / unknown def /
	# conduit / no meta-key frame) reports the no-frame
	# outcome -- false / false -- the N2353/N2371 no-frame
	# precedent (a routed item to a frameless neighbour
	# drops, so the fill closes the gates and nothing routes
	# there). A conduit is no-frame because its acceptItem is
	# a per-block override (out of scope) and the DEFAULT
	# gate would reject it anyway (a conduit consumes no
	# item). Two ring-model notes: Java updateProximity
	# dedupes multi-cell neighbours (`//using a set to
	# prevent duplicates`, BuildingComp.java:1879-1900) and
	# keeps same-team buildings only (`other.team != team`
	# skips), while the ring reports a multi-cell neighbour
	# at each of its ring cells with no team filter -- the
	# N2353 / N2371 ring convention this fill mirrors (a
	# delivery to either index lands in the same frame).
	# Dedup + the team filter wait for a shared ring-geometry
	# slice.
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
					can_dump_item = true
					if not offered_item.is_empty():
						var neighbour_items: Variant = neighbour_frame.get("items", null)
						if neighbour_items is Dictionary:
							var consumes_item := false
							for row in neighbour_block.properties.get("consumeItem", []):
								if not (row is Dictionary):
									continue
								if str(row.get("item", "")) == offered_item:
									consumes_item = true
									break
							accepts_item = consumes_item and int((neighbour_items as Dictionary).get(offered_item, 0)) < int(neighbour_block.properties.get("itemCapacity", 10))
		neighbour_accepts.append(accepts_item)
		neighbour_can_dump.append(can_dump_item)
	return {"dump_neighbour_accepts": neighbour_accepts, "dump_neighbour_can_dump": neighbour_can_dump}

static func source_separator_timer_dump_state(frame: Dictionary, source_delta: float, time_scale: float, content_item_ids: Array, neighbour_accepts_item: Array, neighbour_can_dump: Array) -> Dictionary:
	# The timerDump dump at the END of updateTile
	# (SeparatorBuild.updateTile(), Separator.java:130-167),
	# after the progress/offload block (:140-163):
	# `if(timer(timerDump, dumpTime / timeScale)){`
	# `dump();`
	# -- the dump runs AFTER the advance in the same tick, so
	# it sees the store the advance just offloaded into, and
	# it shares the frame cdump with the offload (Java uses
	# the same `this.cdump` for both). The timer id is
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
	# elapsed"], the N2266/N2269/N2273/N2280 precedent):
	# elapsed += source_delta unconditionally every tick the
	# advance runs -- mirroring Time.time, which grows even
	# while the gate is closed; fired = elapsed >= dumpTime /
	# time_scale; elapsed_after RESETS to 0.0 on fire (a reset,
	# not a subtraction like the Fracker accumulator); a
	# non-positive time_scale is the infinite-time branch
	# (fired false). Unlike the N2280 RepairTurret literal-20
	# timer, this Java call DOES divide by timeScale
	# (`dumpTime / timeScale`, Separator.java:165), so the
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
	# (BuildingComp.java:68, 0). The separator has items
	# (`hasItems = true;`, Separator.java:31), so the hasItems
	# guard always passes. canDump defaults to true
	# (`public boolean canDump(Building to, Item item){`,
	# BuildingComp.java:1124-1126); the neighbour arrays carry
	# the live per-neighbour answers as frame inputs. The dump
	# itself runs through the shared dump(null) port
	# (SourceBuildingItemDumpState.dump_item_state) -- NOT the
	# putItem gate game_put_item_state, which dumps one
	# SPECIFIC item and needs a game object for its increment
	# callbacks, while the timer block calls dump(). The
	# shared port reports the handled neighbour (handled_index)
	# and the handed item (handled_item); the advance exposes
	# both as dump_neighbour_index / dumped_item (-1 / "" when
	# nothing dumped) so the tick can land the dumped item in
	# the neighbour store through the shared neighbour
	# write-back helper (N2361; the write-back IS
	# `other.handleItem(self(), item);`,
	# BuildingComp.java:1089, with handleItem
	# `public void handleItem(Building source, Item item){`
	# doing `items.add(item, 1);`, BuildingComp.java:860-862).
	# The timer is called
	# unconditionally in Java and dump() guards internally,
	# so a fired timer with an empty store still resets the
	# clock and dumps nothing.
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var elapsed: float = float(frame.get("timer_dump_elapsed", 0.0))
	var cursor: int = int(frame.get("cdump", 0))
	var threshold: float = INF if time_scale <= 0.0 else SOURCE_SEPARATOR_DUMP_TIME / time_scale
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
		var result: Dictionary = source_building_item_dump_state.dump_item_state(true, inventory.items_total(items), neighbour_accepts_item.size(), null, false, content_item_ids, amounts, neighbour_accepts_item, neighbour_can_dump, cursor)
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

static func source_separator_sense_state(sensor: String, progress: float, super_value: Variant = null) -> Dictionary:
	# The sense rows (SeparatorBuild.sense(), Separator.java:169-172), the pure logic-sense dispatch -- Java senses, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public double sense(LAccess sensor){`
	# `if(sensor == LAccess.progress) return progress;`
	# `return super.sense(sensor);`
	# progress is the frame value the N2222 advance tracks
	# (`public float progress;`, Separator.java:76, advanced by `progress += getProgressIncrease(craftTime);`, Separator.java:134) -- and Java returns it AS-IS, with NO clamp (unlike the MendProjector, which clamps charge / reload to [0, 1], MendProjector.java:127): the pure uses NO clampf -- a progress past 1.0 reads past 1.0, a negative progress reads negative. super.sense is VERIFIED, not guessed: the BuildingComp switch (BuildingComp.java:2094-2123):
	# `return switch(sensor){`
	# `case health -> health;`
	# `case efficiency -> efficiency;`
	# `default -> Float.NaN; //gets converted to null in logic`
	# covers x / y / color / dead / solid / team / health / maxHealth / efficiency / timescale / range / rotation / totalItems / totalLiquids / totalPower / itemCapacity / liquidCapacity / powerCapacity / powerNetIn / powerNetOut / powerNetStored / powerNetCapacity / enabled / controlled / payloadCount / size / cameraX, cameraY, cameraWidth, cameraHeight, and the default branch is Float.NaN (converted to null in logic). The port ALREADY models that switch (SourceBuildingSenseState: sense_position_state, sense_health_process_state, sense_totals_state, sense_capacity_power_net_state, sense_enabled_controlled_state, sense_payload_size_state, sense_camera_default_state), so the pure takes the caller's super.sense result as super_value (default null = the default branch) instead of re-modeling the switch. canDump is NOT modeled here: `public boolean canDump(Building to, Item item){` + `return !consumesItem(item);` (Separator.java:175-177) needs consumesItem(item), which is Block.itemFilter[item.id] (Block.java:774-776), and no Separator itemFilter is modeled -- the generic Block.consumesItem pure (SourceBlockQueryFilterState.consumes_item_state) takes a caller-supplied item_filter, and neither the Separator driver nor the catalog supplies the separator/disassembler def filter (the separator def has no consumeItem, Blocks.java:1231-1246, so consItems is null; the disassembler consumes scrap, Blocks.java:1263); building the def filter is live since N2395 (source_separator_item_filter_state + source_separator_can_dump_state, pure-only; DEFERRED #300 resolved). senseObject / sense(Content) are separate overloads (BuildingComp.java:2128+) and are NOT modeled here. Pure-only, like the N2383 sense pures: the tick never calls sense (verified: grep `sense` in this driver finds only the documented-limits comment) -- sense is called by logic, not the tick, and the logic call site waits for a logic-executor slice (a port-wide concern, not a Separator deferral).
	var is_progress: bool = sensor == "progress"
	var value: Variant = progress if is_progress else super_value
	return {
		"progress_expr": "if(sensor == LAccess.progress) return progress;",
		"super_expr": "return super.sense(sensor);",
		"sensor": sensor,
		"progress": progress,
		"super_value": super_value,
		"is_progress": is_progress,
		"value": value,
	}

static func source_separator_item_filter_state(consume_stacks: Array, item_order: Array) -> Dictionary:
	# The def itemFilter (Block.afterPatch, Block.java:764-771): `itemFilter = new boolean[content.items().size];` allocates one boolean per content item, all false, and then every consumer applies (`for(var consume : consumeBuilder){` / `consume.apply(this);`) -- ConsumeItems.apply (ConsumeItems.java:25-28) sets the bits: `for(var stack : items){` / `block.itemFilter[stack.item.id] = true;`. The separator def has NO consumeItem (Blocks.java:1231-1246, so consItems is null), so its filter stays all-false; the disassembler consumes scrap (`consumeItem(Items.scrap);`, Blocks.java:1263, is one stack of 1: `return consumeItem(item, 1);`, Block.java:1167-1168), so only the scrap bit is true. The stacks arrive explicit from the driver (the catalog consumeItem rows, the N2349 precedent: block.properties.get("consumeItem", []) -- [] for the separator, [{"item": "scrap", "amount": 1}] for the disassembler); the def id resolves to its rows through the catalog (content_registry blocks by id), so an unknown def yields no rows and an all-false filter. item_order is the catalog item_names_by_id (SourceContentRegistryRuntimeState.source_item_catalog_state, the content-id order -- index IS the id, Items.load() order: copper 0 ... scrap 8 ... dormant-cyst 21, 22 items); a stack naming an item outside the order is skipped (Java cannot hold a non-content item, the N2333 precedent). A duplicated stack id is recorded once.
	var item_filter: Array = []
	for index in range(item_order.size()):
		item_filter.append(false)
	var consumed_item_ids: Array = []
	var consumed_item_names: Array = []
	for stack in consume_stacks:
		var item_name: String = str(stack.get("item", ""))
		var item_id: int = item_order.find(item_name)
		if item_id < 0:
			continue
		item_filter[item_id] = true
		if not consumed_item_ids.has(item_id):
			consumed_item_ids.append(item_id)
			consumed_item_names.append(item_name)
	return {"item_filter": item_filter, "consumed_item_ids": consumed_item_ids, "consumed_item_names": consumed_item_names}

static func source_separator_can_dump_state(item_filter: Array, item_id: int, item: Variant) -> Dictionary:
	# SeparatorBuild.canDump (Separator.java:175-177): `public boolean canDump(Building to, Item item){` with `return !consumesItem(item);` -- a separator can dump any item it does not consume. consumesItem is Block.itemFilter[item.id] (Block.java:774-776, `public boolean consumesItem(Item item){` with `return itemFilter[item.id];`), computed through the generic Block.consumesItem pure (SourceBlockQueryFilterState.consumes_item_state, caller-supplied item_filter) -- NOT re-modeled here. The `to` Building parameter is unused by the Java body, so the pure takes only the item (by id + value, the generic pure's signature). The filter comes from source_separator_item_filter_state (the def filter: all-false for the separator, scrap-only for the disassembler). Pure-only, the N2333/N2336 accept-gate precedent: canDump is called BY neighbours' dump/offload (BuildingComp.java:1001-1016, `if(other.acceptItem(self(), item) && canDump(other, item)){`), and the neighbour fills use defaults this wave -- the tick never calls canDump, so there is no tick call site here; the gate exposes the verdict only.
	var consumed: Dictionary = source_block_query_filter_state.consumes_item_state(item_filter, item_id, item)
	var consumes_item: bool = bool(consumed.get("consumes_item", false))
	return {"can_dump": not consumes_item, "consumes_item": consumes_item, "item_id": item_id, "item": item}

static func source_separator_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the separator tick wiring every
	# tick (SeparatorBuild.updateTile(), Separator.java:128,
	# gates on the progress advance (Separator.java:133, `if(efficiency > 0){` with `progress += getProgressIncrease(craftTime);`), so the progress advance follows the folded efficiency; no placed-buildings driver ticks Separator blocks, so this driver is the placed-separator tick): each placed Separator build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_separator_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_separator_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_separator_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The frame carries the Building.liquids LiquidModule
		# (frame["liquids"]): the live store lives on the
		# sprite meta (source_building_liquids, initialized
		# at placement), so the driver syncs the reference
		# into the frame each tick BEFORE the fold, and the
		# pure liquid row reads the held slag from it (the
		# Fracker:327 precedent).
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a separator with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the progress advance (Separator.java:133)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a separator does not take the early return. A separator with no power consumer is untouched: the liquid slag row (N2252) folds in the same block, and SeparatorBuild overrides shouldConsume() to return total < itemCapacity && enabled (Separator.java:92-100) -- N2200 feeds the live gate to the machinery (the pure gate is source_separator_should_consume_state, fed the frame items, the catalog consumeItem names, and the catalog itemCapacity); the N2169 RED decision is resolved. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var cons_item_names: Array = []
			for row in block.properties.get("consumeItem", []):
				cons_item_names.append(str(row.get("item", "")))
			var item_capacity: int = int(block.properties.get("itemCapacity", 10))
			var gate: Dictionary = source_separator_should_consume_state(frame, cons_item_names, item_capacity)
			var should_consume: bool = bool(frame.get("enabled", true)) and bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_separator_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			# N2252: the liquid slag row folds in the same
			# first pass (ConsumeLiquid.efficiency,
			# ConsumeLiquid.java:42-47). The amount is per
			# def, read from the catalog consumeLiquid row
			# (separator slag 4f/60f, Blocks.java:1244;
			# disassembler slag 0.12f per frame,
			# Blocks.java:1264) -- the cons-items precedent
			# above reads the catalog consumeItem rows the
			# same way; a def with no slag row contributes
			# no row. The slag id resolves through the
			# catalog liquid_id_by_name (the Fracker
			# precedent). In the first pass efficiency is
			# assumed 1f (BuildingComp.java:1965), so the
			# row's edelta is source_delta * time_scale.
			var tick_source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var tick_time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var slag_amount := 0.0
			var has_liquid_consumer := false
			for row in block.properties.get("consumeLiquid", []):
				if str(row.get("liquid", "")) == SOURCE_SEPARATOR_LIQUID:
					slag_amount = float(row.get("amount", 0.0))
					has_liquid_consumer = true
			var slag_id: int = int(liquid_id_by_name.get(SOURCE_SEPARATOR_LIQUID, -1))
			var liquid_row: Dictionary = source_separator_liquid_consumer_row_state(frame, has_liquid_consumer, slag_id, slag_amount, tick_source_delta, tick_time_scale, float(frame.get("efficiency_scale", 1.0)))
			if bool(liquid_row.get("has_liquid_row", false)):
				required_results.append(liquid_row.get("row", {}))
			# N2349: the disassembler scrap item row folds in
			# the same first pass (ConsumeItems.efficiency,
			# ConsumeItems.java:51-53, binary 1/0). The stacks
			# come from the catalog consumeItem rows
			# ([{"item": "scrap", "amount": 1}] for the
			# disassembler, `consumeItem(Items.scrap);`,
			# Blocks.java:1263 -- consumeItem(item) is one
			# stack of 1, Block.java:1167-1168); the separator
			# def has no consumeItem (Blocks.java:1231-1246),
			# so it contributes no row. No removal here:
			# Consume.update is empty (Consume.java:52), so
			# the second pass never removes items -- the scrap
			# is only removed by consume() in the updateTile
			# advance (Separator.java:158, live since N2222).
			var has_item_consumer: bool = bool(block.properties.has("consumeItem"))
			var item_stacks: Array = block.properties.get("consumeItem", [])
			var item_row: Dictionary = source_separator_disassembler_scrap_row_state(frame, has_item_consumer, item_stacks)
			if bool(item_row.get("has_item_row", false)):
				required_results.append(item_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# N2252 second pass (ConsumeLiquid.update,
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
			# the separator driver has no such actor
			# infrastructure, so the removal is direct here,
			# through the shared liquid module helper
			# (SourceLiquidModuleState.source_remove_state,
			# clamped at the held amount like Java's
			# LiquidModule.remove, with a fresh cache_sums
			# sized to the store, the PayloadLoader
			# precedent). frame["liquids"] is the live sprite
			# store by reference, so the removal lands on it.
			if has_liquid_consumer and bool(setup.get("update", false)) and float(frame.get("efficiency", 0.0)) > 0.0:
				var folded_edelta: float = float(frame.get("efficiency", 0.0)) * tick_source_delta * tick_time_scale
				var liquid_store: Dictionary = frame.get("liquids", {})
				if liquid_store.has("liquids") and slag_id >= 0 and slag_id < int(liquid_store["liquids"].size()):
					var cache_sums: Array = []
					cache_sums.resize(int(liquid_store["liquids"].size()))
					cache_sums.fill(0.0)
					source_liquid_module_state.source_remove_state(liquid_store, slag_id, slag_amount * folded_edelta, cache_sums)
		# N2222: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277; noUpdateDisabled defaults
		# false, Block.java:170, `public boolean noUpdateDisabled = false;`),
		# so a disabled separator freezes its progress /
		# warmup. A fresh frame is seeded from its tile
		# position like created() (Separator.java:82-84,
		# `seed = Mathf.randomSeed(tile.pos(), 0, Integer.MAX_VALUE - 1);`)
		# -- tile.pos() is Point2.pack(x, y), computed from the
		# sprite's origin cell. The source delta is Time.delta
		# in ticks: game_source_delta(game, seconds) is seconds
		# * 60 (arc Time.java:26), never raw seconds.
		# timeScale reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float timeScale = 1f, timeScaleDuration;`).
		# craftTime / results are the per-def constants
		# (separator 35f / disassembler 15f); the cons items
		# come from the catalog consumeItem rows with their
		# amounts, the capacity from the catalog itemCapacity.
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		if not frame.has("seed"):
			frame["seed"] = _separator_random_seed_int(_separator_point2_pack(cell.x, cell.y), 0, SOURCE_SEPARATOR_CREATED_SEED_MAX)
		if bool(frame.get("enabled", true)):
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var craft_time: float = _separator_craft_time_for_block(block_id)
			var results: Array = _separator_results_for_block(block_id)
			var cons_items: Array = []
			for row in block.properties.get("consumeItem", []):
				var row_dict: Dictionary = row
				cons_items.append({"item": str(row_dict.get("item", "")), "amount": int(row_dict.get("amount", 1))})
			var item_capacity: int = int(block.properties.get("itemCapacity", 10))
			var content_item_ids: Array = source_content_registry_runtime_state.source_item_catalog_state(catalog).get("item_names_by_id", [])
			# N2402: the dump neighbour live fill -- the tick
			# fills the two neighbour arrays from the live
			# proximity BEFORE the offload routing-context
			# build below (hoisted here by N2413, so the
			# offload reads the CURRENT tick's live-filled
			# arrays instead of the previous tick's) and
			# before the timerDump dump reads them (the fill
			# answers for the first held item in content
			# order, the item the dump offers). The fill runs
			# ONCE per tick -- the timerDump reads below read
			# the same frame keys afterwards.
			# Supplied arrays WIN (the N2381 precedent): the
			# fill runs only when the frame carries NEITHER
			# of the two keys -- the N2281/N2343/N2361 proofs
			# seed the arrays by hand, so a fill there would
			# overwrite the seed. A frame the fill already
			# stamped (dump_neighbour_live -- port
			# bookkeeping, not Java state) refreshes every
			# tick, so a later-placed neighbour joins the
			# arrays and a removed one leaves them. The cell
			# is bound before the enabled block in this
			# driver, and the catalog size is read inline.
			var has_supplied_dump_neighbour_arrays: bool = frame.has("dump_neighbour_accepts") or frame.has("dump_neighbour_can_dump")
			if not has_supplied_dump_neighbour_arrays or bool(frame.get("dump_neighbour_live", false)):
				var filled: Dictionary = source_separator_dump_neighbour_live_fill_state(game, cell, int(block.properties.get("size", 1)), frame, content_item_ids)
				frame["dump_neighbour_accepts"] = filled.get("dump_neighbour_accepts", [])
				frame["dump_neighbour_can_dump"] = filled.get("dump_neighbour_can_dump", [])
				frame["dump_neighbour_live"] = true
			# N2343: the offload neighbor routing -- the
			# advance's routing context is built from the
			# SAME frame neighbour inputs the N2281 dump
			# reads below (Java has ONE proximity list;
			# offload() and dump() scan the same neighbours
			# with the same acceptItem/canDump answers,
			# BuildingComp.java:1001-1016 / :1072-1113) plus
			# the frame cdump (the shared `this.cdump` Java
			# reads at BuildingComp.java:1003), so a crafted
			# pick in this tick already routes to the first
			# accepting neighbour from the saved cursor
			# instead of always falling back to the own
			# items. The inputs default [] (no neighbours,
			# the Java proximity.size == 0 outcome); the
			# live fill lands BEFORE the advance (N2413),
			# so the offload reads the CURRENT tick's
			# live-filled arrays (Java order: the offload at
			# Separator.java:160-161 precedes the dump at
			# :165-166, so the offload sees the same current
			# proximity the timerDump dump does). Judgment
			# call (N2413): the offload routing uses the
			# fill's FIRST-held-item accepts (the same
			# approximation the timerDump dump uses -- the
			# fill answers for the first held item in
			# content order). Per-item routing for the PICKED
			# item (Java's offload(item) checks acceptItem
			# for the picked item specifically) waits for the
			# per-item dump routing slice. The routed item
			# lands in the neighbour
			# frame or belt queue through the shared
			# write-back helper (N2353), called after the
			# advance below.
			var offload_neighbour_accepts: Array = frame.get("dump_neighbour_accepts", [])
			var offload_neighbour_can_dump: Array = frame.get("dump_neighbour_can_dump", [])
			var routing_context: Dictionary = source_separator_offload_routing_context_state(offload_neighbour_accepts, offload_neighbour_can_dump, int(frame.get("cdump", 0)))
			var advanced: Dictionary = source_separator_update_tile_advance_state(frame, source_delta, time_scale, craft_time, results, cons_items, item_capacity, routing_context)
			frame["progress"] = advanced["progress"]
			frame["warmup"] = advanced["warmup"]
			frame["total_progress"] = advanced["total_progress"]
			frame["seed"] = advanced["seed"]
			frame["items"] = advanced["items"]
			frame["cdump"] = advanced["cdump"]
			# N2353: the offload neighbour write-back -- the
			# advance exposed the routed neighbour index
			# (offload_neighbour_index, -1 when no offload
			# ran or it fell back), so the tick lands the
			# picked item in the neighbour store through the
			# shared helper (other.handleItem(self(), item),
			# BuildingComp.java:1009), right after the
			# advance and before the timerDump dump (Java
			# order: the offload at Separator.java:160-161
			# precedes the dump at :165-166). A failed
			# write-back (no sprite / no frame / no items
			# store / full belt) drops the item -- the
			# routing already decided, so there is no
			# fallback to the separator's own store.
			if bool(advanced.get("offload_routed", false)):
				var offload_index: int = int(advanced.get("offload_neighbour_index", -1))
				if offload_index >= 0:
					source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), offload_index, str(advanced.get("picked_item", "")), 1)
			# N2281: the timerDump dump (Separator.java:165-166,
			# `if(timer(timerDump, dumpTime / timeScale)){ dump(); }`)
			# runs AFTER the advance in the same tick (Java order:
			# the timer check sits after the progress/offload block,
			# Separator.java:140-163), so the dump sees the store the
			# advance just offloaded into -- the pure function reads
			# the frame AFTER the write-back above, and persists its
			# items/cdump back the same way. The frame-local clock
			# (frame["timer_dump_elapsed"]) accumulates the tick
			# delta every tick the advance runs, and when it fires
			# the dump hands one held item to an accepting neighbour
			# through the shared dump_item_state routing; the
			# neighbour acceptItem / canDump arrays are frame inputs
			# (default [] -- no neighbours, the Java
			# proximity.size == 0 outcome), live-filled since N2402
			# (the fill runs above, before the routing-context
			# build (N2413); supplied
			# arrays win, the N2394 precedent); the dumped item
			# lands in the neighbour
			# frame or belt queue through the shared neighbour
			# write-back helper (N2361), called after the
			# timerDump persist below.
			# The clock runs only while enabled (the same pragmatic
			# gate as the advance itself -- Java runs updateTile
			# even when disabled, BuildingComp.java:2276-2277); the
			# driver-wide disabled-early-return slice removes this
			# gate for all families. First-fire deviation: Java
			# fires nearly at once after placement; the frame clock
			# delays the first fire by a full interval (5 ticks).
			var neighbour_accepts: Array = frame.get("dump_neighbour_accepts", [])
			var neighbour_can_dump: Array = frame.get("dump_neighbour_can_dump", [])
			var timer_dump: Dictionary = source_separator_timer_dump_state(frame, source_delta, time_scale, content_item_ids, neighbour_accepts, neighbour_can_dump)
			frame["timer_dump_elapsed"] = timer_dump.get("elapsed_after", 0.0)
			frame["items"] = timer_dump.get("items_after", frame.get("items", {}))
			frame["cdump"] = timer_dump.get("cursor_after", frame.get("cdump", 0))
			# N2361: the timerDump dump neighbour write-back --
			# the advance exposed the routed neighbour index +
			# the dumped item (dump_neighbour_index /
			# dumped_item, -1 / "" when nothing dumped), so the
			# tick lands the dumped item in the neighbour store
			# through the shared helper (other.handleItem(self(),
			# item), BuildingComp.java:1089), right after the
			# timerDump persist (Java order: the dump at
			# Separator.java:165-166 is the last step of
			# updateTile). Index i is ring cell i (the N2353
			# convention). A failed write-back (no sprite / no
			# frame / no items store / full belt) drops the item
			# -- the routing already decided, so there is no
			# fallback to the separator's own store (the N2353
			# offload precedent).
			if bool(timer_dump.get("dumped", false)):
				var dump_index: int = int(timer_dump.get("dump_neighbour_index", -1))
				if dump_index >= 0:
					source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), dump_index, str(timer_dump.get("dumped_item", "")), 1)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}

static func source_separator_draw_state(x_value: float, y_value: float, rotation_value: int, total_progress: float, liquid_gas: bool, liquid_color: String, liquid_light_alpha: float, liquid_amount: float, liquid_capacity: float, animation_frame: int, visual_liquid: float, source_delta: float, size_value: int) -> Dictionary:
	# The draw / drawLight / icons rows (SeparatorBuild.draw(),
	# Separator.java:104-106, `drawer.draw(this);`;
	# drawLight(), :109-112; icons(), :71-73), the pure
	# draw-call dict -- the port never draws
	# for real (the N2396 MassDriver precedent: the pure
	# returns the draw calls as data). Verify-first finding
	# (N2419): the class default drawer is DrawDefault
	# (`public DrawBlock drawer = new DrawDefault();`,
	# Separator.java:25), but BOTH defs override it with the
	# SAME DrawMulti (Blocks.java:1246 separator /
	# Blocks.java:1266 disassembler):
	# `drawer = new DrawMulti(new DrawRegion("-bottom"), new DrawLiquidTile(), new DrawRegion("-spinner", 3, true), new DrawDefault());`
	# so the live draw is the DrawMulti composition, in
	# drawer order (DrawMulti.java:33-36, `for(var draw : drawers){`):
	# (1) DrawRegion("-bottom") -- a plain region rect
	# (`Draw.rect(region, build.x + x, build.y + y, build.totalProgress() * rotateSpeed + rotation + (buildingRotate ? build.rotdeg() : 0));`,
	# DrawRegion.java:51) with rotateSpeed 0, rotation 0,
	# buildingRotate false, x/y 0, color null, layer -1, so
	# the rotation folds to 0; the region loads as
	# block.name + suffix (`region = Core.atlas.find(name != null ? name : block.name + suffix);`,
	# DrawRegion.java:74), token "block.name-bottom".
	# (2) DrawLiquidTile() -- the current liquid tiled over
	# the block (`Liquid drawn = drawLiquid != null ? drawLiquid : build.liquids.current();`,
	# DrawLiquidTile.java:28, drawLiquid null, so the drawn
	# liquid is liquids.current())
	# `LiquidBlock.drawTiledFrames(build.block.size, build.x, build.y, padLeft, padRight, padTop, padBottom, drawn, build.liquids.get(drawn) / build.block.liquidCapacity * alpha);`
	# (DrawLiquidTile.java:29) with pads all 0 (padding 0,
	# load() fills padLeft/padRight/padTop/padBottom from
	# padding) and alpha 1f, so the fill fraction is
	# amount / liquidCapacity (separator 40f, disassembler
	# 72f, Block.java:1406-1419, round(10 * max(1,
	# amount * 60)) -- 4f/60f -> 40, 0.12f -> 72). The
	# frames tile size*size (`TextureRegion region = renderer.fluidFrames[liquid.gas ? 1 : 0][liquid.getAnimationFrame()];`,
	# LiquidBlock.java:41; `float leftBounds = size/2f * tilesize - padRight;`,
	# :44), one Drawf.liquid per tile at x + relx * tilesize
	# (`Drawf.liquid(toDraw, x + rightBorder + ox, y + topBorder + oy, alpha, color);`,
	# :77; `Color color = Tmp.c1.set(liquid.color).a(1f);`,
	# :46), with NO truncation at zero padding (squish <= 0
	# for every tile) and the Drawf.liquid gate
	# (`if(alpha < 1f/255f) return;`, Drawf.java:392) -- an
	# empty tank draws no tiles. tilesize is the Java
	# constant 8.0 (`public static final int tilesize = 8;`,
	# Vars.java:135 -- NEVER the game tile_size 32, the
	# N2375 lesson). The animation frame is
	# liquid.getAnimationFrame(), a Time.time value, so it
	# arrives caller-supplied like time_value (the
	# N2396/N2372 convention).
	# (3) DrawRegion("-spinner", 3, true) -- a spinning
	# sprite (`Drawf.spinSprite(region, build.x + x, build.y + y, build.totalProgress() * rotateSpeed + rotation + (buildingRotate ? build.rotdeg() : 0));`,
	# DrawRegion.java:49) at totalProgress * 3 + 0 + 0;
	# totalProgress is the frame value the N2222 advance
	# tracks (`public float totalProgress;`,
	# Separator.java:77). Drawf.spinSprite (Drawf.java:602-608)
	# draws TWO rects: `r = Mathf.mod(r, 90f);`
	# `Draw.rect(region, x, y, r);`
	# `Draw.alpha(r / 90f*a);`
	# `Draw.rect(region, x, y, r - 90f);`
	# -- the second rect fades in as the first rotates
	# toward 90. Mathf.mod is the positive mod
	# (`return ((f % n) + n) % n;`, arc Mathf.java:574-576);
	# totalProgress never goes negative (the N2222 advance
	# only adds warmup * delta), so GDScript fmod matches.
	# (4) DrawDefault -- the base region rect
	# (`Draw.rect(build.block.region, build.x, build.y, build.drawrot());`,
	# DrawDefault.java:13) at drawrot()
	# (`return block.rotate && block.rotateDraw ? rotation * 90 : 0f;`,
	# BuildingComp.java:587-589), which folds to 0:
	# Separator sets no rotate (`public boolean rotate;`,
	# Block.java:120, default false). The rotation input is
	# still taken so the drawrot formula is explicit.
	# drawLight() (Separator.java:109-112) is super.drawLight()
	# (`super.drawLight();` + `drawer.drawLight(this);`)
	# plus the drawer light -- and the drawer adds NOTHING:
	# DrawMulti.drawLight iterates (DrawMulti.java:47-50)
	# but NO member overrides drawLight (the base is the
	# no-op `public void drawLight(Building build){}`,
	# DrawBlock.java:31-33). The super light is the
	# BuildingComp liquid light (BuildingComp.java:1309-1317):
	# `Liquid liq = block.hasLiquids && block.lightLiquid == null ? liquids.current() : block.lightLiquid;`
	# (lightLiquid null, so the current liquid) and
	# `if(block.hasLiquids && block.drawLiquidLight && liq.lightColor.a > 0.001f){`
	# (hasLiquids true, `public boolean drawLiquidLight = true;`,
	# Block.java:276; slag lightColor alpha 0.4,
	# `lightColor = Color.valueOf("f0511d").a(0.4f);`,
	# Liquids.java:25, so the gate passes for slag), then
	# `visualLiquid = Mathf.lerpDelta(visualLiquid, liquids.get(liq)>= 0.01f ? 1f : 0f, 0.06f);`
	# -- lerpDelta is the arc form
	# (`return lerp(fromValue, toValue, clamp(progress * Time.delta));`,
	# arc Mathf.java:430-432; clamp to [0, 1],
	# `return Math.max(Math.min(value, 1f), 0f);`,
	# arc Mathf.java:402-404), so the step is
	# clamp(0.06 * delta) toward 1 when the tank holds >=
	# 0.01, else toward 0 -- and drawLiquidLight
	# (BuildingComp.java:1319-1327):
	# `if(amount > 0.01f){`
	# `Drawf.light(x, y, block.size * 30f * fract, color, opacity * amount);`
	# with fract 1f, opacity = lightColor.a, radius
	# size * 30 (60 separator, 90 disassembler). The pure
	# returns the light call as data (empty when the gate
	# fails or the visual amount is <= 0.01) plus the new
	# visualLiquid -- visualLiquid is transient draw state
	# the tick never tracks, so the caller supplies the
	# previous value and reads the new one back.
	# The icons ride this pure: icons() returns
	# `drawer.finalIcons(this);` (Separator.java:72);
	# finalIcons (DrawBlock.java:50-59) takes the
	# iconOverride branch only when iconOverride != null
	# (`if(iconOverride != null){`, DrawBlock.java:51 --
	# null here, neither def sets it), else the drawer
	# icons, falling back to the error region only when
	# empty. DrawMulti.icons concatenates in drawer order
	# (`result.addAll(draw.icons(block));`,
	# DrawMulti.java:63): "-bottom" gives its region
	# (`return new TextureRegion[]{region};`,
	# DrawRegion.java:69), DrawLiquidTile gives NOTHING
	# (no icons() override, the base
	# `return new TextureRegion[]{};`, DrawBlock.java:47),
	# "-spinner" gives its region, DrawDefault gives
	# (`return new TextureRegion[]{block.region};`,
	# DrawDefault.java:23). A zero-arg icons() pure cannot
	# register (the SSOT schema validator requires
	# non-empty input keys, the N2396 precedent), so the
	# three regions ride the draw pure as icon_regions.
	# Pure-only: the tick never calls draw -- draw is
	# called by the renderer, and the renderer call site
	# waits for a renderer slice.
	var tile_size: float = 8.0
	var draw_rotation: float = 0.0
	var bottom_call: Dictionary = {
		"call": "Draw.rect(region, build.x + x, build.y + y, build.totalProgress() * rotateSpeed + rotation + (buildingRotate ? build.rotdeg() : 0));",
		"region": "block.name-bottom",
		"x": x_value,
		"y": y_value,
		"rotation": 0.0,
	}
	var liquid_alpha: float = liquid_amount / liquid_capacity * 1.0
	var liquid_tiles: Array = []
	for tile_sx in range(size_value):
		for tile_sy in range(size_value):
			var rel_x: float = float(tile_sx) - (float(size_value) - 1.0) / 2.0
			var rel_y: float = float(tile_sy) - (float(size_value) - 1.0) / 2.0
			liquid_tiles.append({"x": x_value + rel_x * tile_size, "y": y_value + rel_y * tile_size})
	var frame_row: int = 1 if liquid_gas else 0
	var frame_token: String = "fluidFrames[" + str(frame_row) + "][" + str(animation_frame) + "]"
	var liquid_call: Dictionary = {}
	if liquid_alpha >= 1.0 / 255.0:
		liquid_call = {
			"call": "LiquidBlock.drawTiledFrames(build.block.size, build.x, build.y, padLeft, padRight, padTop, padBottom, drawn, build.liquids.get(drawn) / build.block.liquidCapacity * alpha);",
			"tiles": liquid_tiles,
			"tile_count": size_value * size_value,
			"alpha": liquid_alpha,
			"color": liquid_color,
			"frame": frame_token,
			"gas": liquid_gas,
			"animation_frame": animation_frame,
		}
	var spinner_raw: float = total_progress * SOURCE_SEPARATOR_SPINNER_ROTATE_SPEED
	var spinner_rotation: float = fmod(spinner_raw, 90.0)
	var spinner_call: Dictionary = {
		"call": "Drawf.spinSprite(region, build.x + x, build.y + y, build.totalProgress() * rotateSpeed + rotation + (buildingRotate ? build.rotdeg() : 0));",
		"region": "block.name-spinner",
		"x": x_value,
		"y": y_value,
		"rotation": spinner_rotation,
		"second_rotation": spinner_rotation - 90.0,
		"second_alpha_factor": spinner_rotation / 90.0,
		"raw_rotation": spinner_raw,
	}
	var base_call: Dictionary = {
		"call": "Draw.rect(build.block.region, build.x, build.y, build.drawrot());",
		"region": "block.region",
		"x": x_value,
		"y": y_value,
		"rotation": draw_rotation,
	}
	var light_target: float = 1.0 if liquid_amount >= 0.01 else 0.0
	var light_lerp: float = clampf(SOURCE_SEPARATOR_DRAW_LIGHT_RATE * source_delta, 0.0, 1.0)
	var visual_after: float = visual_liquid + (light_target - visual_liquid) * light_lerp
	var light_opacity: float = liquid_light_alpha * 1.0
	var light_drawn: bool = liquid_light_alpha > 0.001 and visual_after > 0.01 and light_opacity > 0.001
	var draw_light_call: Dictionary = {}
	if light_drawn:
		draw_light_call = {
			"call": "Drawf.light(x, y, block.size * 30f * fract, color, opacity * amount);",
			"x": x_value,
			"y": y_value,
			"radius": float(size_value) * SOURCE_SEPARATOR_DRAW_LIGHT_RADIUS,
			"color": "liquid.lightColor",
			"opacity": light_opacity * visual_after,
			"light_alpha": liquid_light_alpha,
			"visual_liquid": visual_after,
			"fract": 1.0,
		}
	var icon_regions: Array = ["block.name-bottom", "block.name-spinner", "block.region"]
	return {
		"bottom_expr": "Draw.rect(region, build.x + x, build.y + y, build.totalProgress() * rotateSpeed + rotation + (buildingRotate ? build.rotdeg() : 0));",
		"liquid_expr": "LiquidBlock.drawTiledFrames(build.block.size, build.x, build.y, padLeft, padRight, padTop, padBottom, drawn, build.liquids.get(drawn) / build.block.liquidCapacity * alpha);",
		"spinner_expr": "Drawf.spinSprite(region, build.x + x, build.y + y, build.totalProgress() * rotateSpeed + rotation + (buildingRotate ? build.rotdeg() : 0));",
		"base_expr": "Draw.rect(build.block.region, build.x, build.y, build.drawrot());",
		"light_expr": "Drawf.light(x, y, block.size * 30f * fract, color, opacity * amount);",
		"icons_expr": "return drawer.finalIcons(this);",
		"x": x_value,
		"y": y_value,
		"rotation": rotation_value,
		"total_progress": total_progress,
		"liquid_gas": liquid_gas,
		"liquid_color": liquid_color,
		"liquid_light_alpha": liquid_light_alpha,
		"liquid_amount": liquid_amount,
		"liquid_capacity": liquid_capacity,
		"animation_frame": animation_frame,
		"visual_liquid_before": visual_liquid,
		"source_delta": source_delta,
		"size": size_value,
		"draw_rotation": draw_rotation,
		"liquid_alpha": liquid_alpha,
		"tile_count": size_value * size_value,
		"frame": frame_token,
		"spinner_rotation": spinner_rotation,
		"spinner_raw_rotation": spinner_raw,
		"light_target": light_target,
		"light_lerp": light_lerp,
		"visual_liquid_after": visual_after,
		"light_opacity": light_opacity,
		"light_drawn": light_drawn,
		"icon_regions": icon_regions,
		"bottom_call": bottom_call,
		"liquid_call": liquid_call,
		"spinner_call": spinner_call,
		"base_call": base_call,
		"draw_light_call": draw_light_call,
	}

static func source_separator_draw_plan_state(plan_drawx: float, plan_drawy: float, plan_rotation: int, plan_world_context: bool, player_present: bool, team_region_found: bool, team_matches: bool) -> Dictionary:
	# The drawPlanRegion rows (Separator.drawPlanRegion(),
	# Separator.java:66-69, `drawer.drawPlan(this, plan, list);`),
	# the pure plan draw-call dict -- the port never draws for
	# real (the N2396 MassDriver precedent). The drawer is the
	# DrawMulti def drawer (Blocks.java:1246/1266, see
	# source_separator_draw_state), and DrawMulti.drawPlan
	# iterates in drawer order (DrawMulti.java:40-43,
	# `for(var draw : drawers){`): DrawRegion("-bottom")
	# draws its plan rect
	# (`Draw.rect(region, plan.drawx()+ x, plan.drawy() + y, (buildingRotate ? plan.rotation * 90f : 0 + rotation));`,
	# DrawRegion.java:63) with drawPlan true (no early return,
	# `if(!drawPlan) return;`, DrawRegion.java:59), rotation
	# 0 + rotation 0 = 0 (buildingRotate false); DrawLiquidTile
	# draws NOTHING in the plan (no drawPlan() override, the
	# base is the no-op `public void drawPlan(Block block, BuildPlan plan, Eachable<BuildPlan> list){}`,
	# DrawBlock.java:37-39); DrawRegion("-spinner") draws its
	# plan spin (`Drawf.spinSprite(region, plan.drawx() + x, plan.drawy() + y, (buildingRotate ? plan.rotation * 90f : 0 + rotation));`,
	# DrawRegion.java:61) at rotation 0, so spinSprite
	# (Drawf.java:602-608, `r = Mathf.mod(r, 90f);`) draws
	# the rect at 0 plus the second rect at -90 with alpha
	# factor 0/90 = 0; DrawDefault draws the default plan
	# region (`block.drawDefaultPlanRegion(plan, list);`,
	# DrawDefault.java:18). drawDefaultPlanRegion
	# (Block.java:856-870) rects the plan region
	# (`TextureRegion reg = getPlanRegion(plan, list);`,
	# :857; `return fullIcon;`, getPlanRegion, :881-883) at
	# the plan position
	# (`Draw.rect(reg, plan.drawx(), plan.drawy(), !rotate || !rotateDraw ? 0 : plan.rotation * 90);`,
	# :859) -- rotation 0, Separator sets no rotate
	# (`public boolean rotate;`, Block.java:120, default
	# false) -- then the team overlay, only in a world
	# context with a player and a found team region
	# (`if(plan.worldContext && player != null && teamRegion != null && teamRegion.found()){`,
	# :861), coloring the team color only when the team's
	# region IS the base team region
	# (`if(teamRegions[player.team().id] == teamRegion) Draw.color(player.team().color, a);`,
	# :862) before
	# (`Draw.rect(teamRegions[player.team().id], plan.drawx(), plan.drawy());`,
	# :863), and finally drawPlanConfig -- the base no-op
	# (`public void drawPlanConfig(BuildPlan plan, Eachable<BuildPlan> list){}`,
	# Block.java:885-887), so the plan carries no config
	# call. Pure-only: the plan is caller-supplied data, the
	# tick never plans.
	var plan_rotation_value: float = 0.0
	var plan_bottom_call: Dictionary = {
		"call": "Draw.rect(region, plan.drawx()+ x, plan.drawy() + y, (buildingRotate ? plan.rotation * 90f : 0 + rotation));",
		"region": "block.name-bottom",
		"x": plan_drawx,
		"y": plan_drawy,
		"rotation": 0.0,
	}
	var plan_spinner_call: Dictionary = {
		"call": "Drawf.spinSprite(region, plan.drawx() + x, plan.drawy() + y, (buildingRotate ? plan.rotation * 90f : 0 + rotation));",
		"region": "block.name-spinner",
		"x": plan_drawx,
		"y": plan_drawy,
		"rotation": 0.0,
		"second_rotation": -90.0,
		"second_alpha_factor": 0.0,
	}
	var plan_call: Dictionary = {
		"call": "Draw.rect(reg, plan.drawx(), plan.drawy(), !rotate || !rotateDraw ? 0 : plan.rotation * 90);",
		"region": "fullIcon",
		"x": plan_drawx,
		"y": plan_drawy,
		"rotation": plan_rotation_value,
	}
	var team_gate: bool = plan_world_context and player_present and team_region_found
	var plan_team_call: Dictionary = {}
	if team_gate:
		plan_team_call = {
			"call": "Draw.rect(teamRegions[player.team().id], plan.drawx(), plan.drawy());",
			"region": "teamRegions[player.team().id]",
			"x": plan_drawx,
			"y": plan_drawy,
			"color": "player.team().color" if team_matches else "",
		}
	return {
		"plan_bottom_expr": "Draw.rect(region, plan.drawx()+ x, plan.drawy() + y, (buildingRotate ? plan.rotation * 90f : 0 + rotation));",
		"plan_spinner_expr": "Drawf.spinSprite(region, plan.drawx() + x, plan.drawy() + y, (buildingRotate ? plan.rotation * 90f : 0 + rotation));",
		"plan_expr": "Draw.rect(reg, plan.drawx(), plan.drawy(), !rotate || !rotateDraw ? 0 : plan.rotation * 90);",
		"plan_team_expr": "Draw.rect(teamRegions[player.team().id], plan.drawx(), plan.drawy());",
		"plan_drawx": plan_drawx,
		"plan_drawy": plan_drawy,
		"plan_rotation": plan_rotation,
		"plan_rotation_value": plan_rotation_value,
		"plan_world_context": plan_world_context,
		"player_present": player_present,
		"team_region_found": team_region_found,
		"team_matches": team_matches,
		"team_gate": team_gate,
		"plan_bottom_call": plan_bottom_call,
		"plan_spinner_call": plan_spinner_call,
		"plan_call": plan_call,
		"plan_team_call": plan_team_call,
	}
