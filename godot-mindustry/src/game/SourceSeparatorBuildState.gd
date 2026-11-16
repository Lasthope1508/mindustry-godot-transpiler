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
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a separator does not take the early return. The progress advance follows the folded efficiency (Separator.java:133, `if(efficiency > 0){` with `progress += getProgressIncrease(craftTime);`) and the shouldConsume override (Separator.java:92, `public boolean shouldConsume(){` with `return total < itemCapacity && enabled;`, Separator.java:100; default BuildingComp.java:755, `public boolean shouldConsume(){`) -- SeparatorBuild (Separator.java:75, `public class SeparatorBuild extends Building{`) overrides shouldConsume() to return total < itemCapacity && enabled, so the default does not apply here; the gate is live since N2200 (the pure gate source_separator_should_consume_state feeds total-minus-consItems-buffer < itemCapacity && enabled to the machinery; when the gate is false updateConsumption forces efficiency to 0, BuildingComp.java:1960 + 1992). The separator (consumePower 1.1f, Blocks.java:1243, `consumePower(1.1f);`; disassembler consumePower 4f, Blocks.java:1262, `consumePower(4f);`) also consumes liquid slag (separator `consumeLiquid(Liquids.slag, 4f / 60f);`, Blocks.java:1244; disassembler `consumeLiquid(Liquids.slag, 0.12f);`, Blocks.java:1264) -- the liquid row is live since N2252 (source_separator_liquid_consumer_row_state), so the folded efficiency is the min over the *modeled* consumers (power + liquid).
	# Documented limits: (1) liquid row live (N2252) -- the separator consumes liquid slag (separator 4f/60f, Blocks.java:1244; disassembler 0.12f per frame, Blocks.java:1264), folded by the pure liquid row (source_separator_liquid_consumer_row_state, ConsumeLiquid.efficiency, ConsumeLiquid.java:42-47) with the second-pass removal (ConsumeLiquid.update, ConsumeLiquid.java:37-39); the folded efficiency is the min over the *modeled* consumers (power + liquid). Still deferred: the disassembler scrap ConsumeItems efficiency row (ConsumeItems.java:51-53, `return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;`) -- the scrap is only removed by consume() in the updateTile advance (N2222), so a disassembler with no scrap still folds as if the item row were 1.0. (2) shouldConsume gate live (N2200) -- SeparatorBuild overrides shouldConsume() to return total < itemCapacity && enabled (Separator.java:92-100, `return total < itemCapacity && enabled;`); the pure gate reads the frame items Dictionary (minus the consItems buffer from the catalog consumeItem rows) and feeds should_consume to the machinery; when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994). No live intake fills frame["items"] yet -- the gate reads the frame as-is, and intake waits for its own slice. (3) Partial updateTile advance (N2222) -- progress / warmup / totalProgress / seed / consume() / the offload random result pick (Separator.java:130-167) advance each tick, and a fresh frame is seeded from its tile position like created() (Separator.java:82-84); the timerDump dump is live since N2281 (source_separator_timer_dump_state, the frame-local Interval-equivalent, dumpTime 5f / timeScale, Separator.java:165-166, dump(null) through the shared dump_item_state routing; first-fire deviation: Java fires nearly at once after placement, the frame clock delays the first fire by one interval, 5 ticks); the offload neighbor routing live since N2343 (the tick builds the routing context from the shared dump neighbour frame inputs and passes it into the advance, so the picked result routes to the first accepting neighbour from the cdump cursor, BuildingComp.java:1001-1016; still deferred: the offload neighbour write-back -- a routed item leaves the separator without landing in a neighbour store); the dump neighbour live fill + write-back are still deferred too (the neighbour acceptItem / canDump arrays are frame inputs, default [], and the dumped item is not written into the neighbour frame yet). (4) No sense / canDump / draw / drawLight / icons / drawPlanRegion / read-write / shouldAmbientSound rows -- sense (Separator.java:169-172), canDump (Separator.java:175-177), draw (Separator.java:109-111), drawLight (Separator.java:114-117), icons (Separator.java:71-73), drawPlanRegion (Separator.java:66-69), read/write (Separator.java:180-194), shouldAmbientSound (Separator.java:87-89) are logic / presentation / serialization / lifecycle, not tick state; created() (Separator.java:82-84) is live since N2222 (the driver seeds a fresh frame from its tile position). (5) Disassembler variant verification pending -- the same driver covers both defs via the catalog consumePower.
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

static func source_separator_should_consume_state(frame: Dictionary, cons_item_names: Array, item_capacity: int) -> Dictionary:
	# SeparatorBuild.shouldConsume() (Separator.java:92-101, `public boolean shouldConsume(){` with `return total < itemCapacity && enabled;`, Separator.java:100): `int total = items.total();` (Separator.java:93), then -- when the block has a ConsumeItems consumer -- the consItems buffer is subtracted (`for(ItemStack stack : consItems.items){` / `total -= items.get(stack.item);`, Separator.java:96-97; consItems is found by init(), `consItems = findConsumer(c -> c instanceof ConsumeItems);`, Separator.java:58, from `protected @Nullable ConsumeItems consItems;`, Separator.java:21, so it is null on a def with no consumeItem). The separator def has no consumeItem (Blocks.java:1231-1246), so its consItems is null and nothing is subtracted; the disassembler consumes scrap (`consumeItem(Items.scrap);`, Blocks.java:1263), so the held scrap is subtracted. The capacity is the catalog itemCapacity (`public int itemCapacity = 10;`, Block.java:75, the default; disassembler `itemCapacity = 20;`, Blocks.java:1261). The total is the drill inventory total (SourceDrillInventoryRuntimeState.items_total, reused through the inventory preload, not recomputed) minus the held count of each cons item (item_count); the frame carries the Building.items ItemModule (frame["items"], Dictionary keyed by item name, the factory precedent SourceFactoryBuildState.gd:89-101). When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). SeparatorBuild overrides shouldConsume (Separator.java:75, `public class SeparatorBuild extends Building{`; Separator.java:19, `public class Separator extends Block{`), so the default (`return enabled;`, BuildingComp.java:755-756) does not apply here. The updateTile progress advance (Separator.java:133, `if(efficiency > 0){` with `progress += getProgressIncrease(craftTime);`) follows the folded efficiency and is live since N2222 (source_separator_update_tile_advance_state).
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
		return (value >> 26) & 0x3FFFFFFFF
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
	# own items, the Java no-neighbor-accepts outcome. A
	# context without a dump cursor defaults it from the
	# frame cdump (offload() reads `this.cdump`,
	# BuildingComp.java:1003), so a context-less craft no
	# longer clobbers the frame cursor to 0 on the fallback
	# path. The timerDump dump is live since N2281
	# (source_separator_timer_dump_state, wired after this
	# advance in the tick:
	# `if(timer(timerDump, dumpTime / timeScale)){ dump(); }`,
	# Separator.java:165-166). Deferred, not done here: the
	# offload neighbour write-back (a routed item leaves the
	# separator without landing in a neighbour store) and the
	# live fill of the shared neighbour frame inputs (the
	# N2281 dump entry). With empty results there is no
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
	return {"progress": progress, "warmup": warmup, "total_progress": total_progress, "seed": seed, "items": items, "cdump": cdump, "picked_item": picked_item, "crafted": crafted}

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
	# shared port reports the handled neighbour but does not
	# write the item into the neighbour frame -- the
	# write-back waits for its own slice. The timer is called
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
	if fired:
		var amounts: Array = []
		for item_id in content_item_ids:
			amounts.append(int(items.get(str(item_id), 0)))
		var result: Dictionary = source_building_item_dump_state.dump_item_state(true, inventory.items_total(items), neighbour_accepts_item.size(), null, false, content_item_ids, amounts, neighbour_accepts_item, neighbour_can_dump, cursor)
		cursor = int(result.get("cdump", cursor))
		if bool(result.get("dumped", false)):
			dumped = true
			var amounts_after: Array = result.get("item_amounts_by_index", amounts)
			for j in range(content_item_ids.size()):
				if j < amounts_after.size():
					items[str(content_item_ids[j])] = int(amounts_after[j])
	return {"fired": fired, "elapsed_after": elapsed_after, "dumped": dumped, "items_after": items, "cursor_after": cursor}

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
			# the Java proximity.size == 0 outcome) until a
			# live proximity fill lands (the N2281 dump
			# entry); a routed item is not written into the
			# neighbour frame yet (no offload neighbour
			# write-back).
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
			var content_item_ids: Array = source_content_registry_runtime_state.source_item_catalog_state(catalog).get("item_names_by_id", [])
			var neighbour_accepts: Array = frame.get("dump_neighbour_accepts", [])
			var neighbour_can_dump: Array = frame.get("dump_neighbour_can_dump", [])
			var timer_dump: Dictionary = source_separator_timer_dump_state(frame, source_delta, time_scale, content_item_ids, neighbour_accepts, neighbour_can_dump)
			frame["timer_dump_elapsed"] = timer_dump.get("elapsed_after", 0.0)
			frame["items"] = timer_dump.get("items_after", frame.get("items", {}))
			frame["cdump"] = timer_dump.get("cursor_after", frame.get("cdump", 0))
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
