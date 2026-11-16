extends RefCounted
class_name SourceSolidPumpBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")

# The SolidPump implementation (SolidPump.java:19-20, `public class
# SolidPump extends Pump{`): water-extractor (consumePower 1.5f,
# pumpAmount 0.11f, size 2, liquidCapacity 40f, rotateSpeed 1.4f,
# attribute water, envRequired groundWater, result water). The only
# SolidPump block in the game (Blocks.java:2920-2930). SolidPumpBuild
# extends PumpBuild, but the pump runtime
# (SourcePumpRuntimeState.gd) ticks only the scenario mechanical
# pump at PUMP_POS with efficiency hardcoded 1.0 ("consumes no
# power"), so this driver is the solid-pump tick. The driver uses
# its own family frame key ("source_solid_pump_building", the
# turret precedent); the mechanical-pump per-cell frame
# ("source_pump_building") stays untouched, and this slice adds
# the solid-pump key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it.
const SOURCE_SOLID_PUMP_BUILD_IMPLEMENTATIONS := ["SolidPump"]
const SOURCE_SOLID_PUMP_BUILDING_META_KEY := "source_solid_pump_building"

# The water-extractor def constants (Blocks.java:2920-2925): the
# catalog carries no `result` or `liquidCapacity` property for
# the water-extractor, so the driver uses the def values (the
# N2190 fogRadius / N2199 transportTime def-constant precedent):
# result water (`result = Liquids.water;`, Blocks.java:2922 --
# also the class default, `public Liquid result =
# Liquids.water;`, SolidPump.java:22) and liquidCapacity 40f
# (`liquidCapacity = 40f;`, Blocks.java:2925; the class default
# is -1f, `public float liquidCapacity = -1f;`, Block.java:77,
# but every pump def sets it explicitly).
const SOURCE_SOLID_PUMP_RESULT_LIQUID := "water"
const SOURCE_SOLID_PUMP_LIQUID_CAPACITY := 40.0

# The water-extractor def pump amount (Blocks.java:2923,
# `pumpAmount = 0.11f;`, overriding the Pump class default
# 0.2f, Pump.java:20, `public float pumpAmount = 0.2f;`): the
# driver passes it to the advance as a parameter (like the
# capacity), so the Fracker advance (N2224) can reuse the
# same pure function with the oil-extractor's 0.25f
# (Blocks.java:2969; FrackerBuild.updateTile calls
# super.updateTile(), Fracker.java:37).
const SOURCE_SOLID_PUMP_PUMP_AMOUNT := 0.11
# SolidPump.java:130/134, the warmup lerpDelta rate `0.02f`.
const SOURCE_SOLID_PUMP_WARMUP_RATE := 0.02
# The water-extractor def size (Blocks.java:2924, `size = 2;`)
# and the SolidPump class base efficiency (SolidPump.java:26,
# `public float baseEfficiency = 1f;`): both sums in the
# onProximityUpdate fill divide by size * size
# (SolidPump.java:153, 157), so the driver passes them to the
# fill as parameters (the def-constant precedent).
const SOURCE_SOLID_PUMP_SIZE := 2
const SOURCE_SOLID_PUMP_BASE_EFFICIENCY := 1.0

static func _is_solid_pump_build_implementation(implementation: String) -> bool:
	return SOURCE_SOLID_PUMP_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_solid_pump_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The solid-pump tick wires the frame keys the consumption
	# path reads (the N2148 turret pattern): block_implementation
	# is the block's implementation (SolidPump.java:19, `public
	# class SolidPump extends Pump{`), team_id and rules_state
	# are what Java reads as b.team and state.rules, and cheating
	# is the team's live TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's solid pump
	# skips consumption like Java's updateConsumption
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
	# for this solid pump (N2125); the tick preserves a disabled
	# solid pump instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# The frame carries the Building.liquids LiquidModule
	# (frame["liquids"], the module state dict
	# {liquids/current/flow}, default {}): the driver refreshes
	# it from the sprite meta each tick (the meta is initialized
	# at placement through SourcePlacedBlockState), and the
	# shouldConsume gate reads the result amount from it
	# (SolidPump.java:118, `return liquids.get(result) <
	# liquidCapacity - 0.01f;`). The pump advance (N2220)
	# fills it each tick from the updateTile advance
	# (SolidPump.java:122-141); the gate reads the store
	# as-is. The frame also carries the dump cursor
	# (frame["cdump"], `transient int cdump;`,
	# BuildingComp.java:68, default 0): the dump (N2286)
	# scans proximity from it each tick.
	return {"liquids": {}, "cdump": 0}

static func source_solid_pump_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the solid-pump frame meta key
	# ("source_solid_pump_building"). A SolidPump sprite gets a
	# frame bound with the liquids key ({} by default); the
	# live-loop tick fills its other keys every tick. Any other
	# block, or an already-bound sprite, binds nothing.
	if block == null or not _is_solid_pump_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_SOLID_PUMP_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_SOLID_PUMP_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_SOLID_PUMP_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_solid_pump_should_consume_state(frame: Dictionary, result_liquid_id: int, liquid_capacity: float) -> Dictionary:
	# SolidPumpBuild overrides shouldConsume (SolidPump.java:117, `public boolean shouldConsume(){` with `return liquids.get(result) < liquidCapacity - 0.01f;`, SolidPump.java:118): the solid pump consumes only while its result liquid store holds less than the liquid capacity minus 0.01f. SolidPump extends Pump (SolidPump.java:21, `public class SolidPump extends Pump{`) and SolidPumpBuild extends PumpBuild (SolidPump.java:89, `public class SolidPumpBuild extends PumpBuild{`), so the default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`) does NOT apply here. Unlike the Pump gate this one has NO `&& enabled` -- Java returns the bare capacity comparison, so the pure gate does NOT read frame["enabled"] at all (the driver already runs the machinery only when enabled). The result liquid is water (the Java field default, `public Liquid result = Liquids.water;`, SolidPump.java:22, set explicitly by the def, `result = Liquids.water;`, Blocks.java:2922) and the capacity is the def constant 40f (`liquidCapacity = 40f;`, Blocks.java:2925) -- both arrive as parameters from the driver, which resolves the result id from the liquid catalog and uses the def capacity constant because the catalog carries neither property for the water-extractor; the class default is -1f (`public float liquidCapacity = -1f;`, Block.java:77) but every pump def sets it explicitly. The amount comes from the shared liquid module helper (SourceLiquidModuleState.source_get_state, reused through a preload, NOT re-implemented) over the frame liquids key (the Building.liquids LiquidModule state dict, default {} for a frame bound before this slice, which reads 0.0). When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`).
	var liquids: Dictionary = frame.get("liquids", {})
	var result_amount: float = 0.0
	if result_liquid_id >= 0 and liquids.has("liquids"):
		var amounts: Array = liquids["liquids"]
		if result_liquid_id < amounts.size():
			result_amount = float(source_liquid_module_state.source_get_state(liquids, result_liquid_id).get("amount", 0.0))
	return {"should_consume": result_amount < liquid_capacity - 0.01, "result_amount": result_amount}

static func source_solid_pump_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
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
	# so a solid pump does not take the early return. The
	# solid-pump speed follows the folded efficiency
	# (SolidPump.java:121, `float maxPump = Math.min(liquidCapacity - typeLiquid(), pumpAmount * delta() * fraction * efficiency);`).
	# Documented limits: (1) power-only first pass -- the
	# fraction inputs are explicit frame keys since N2220
	# (valid_tiles / boost / attribute_env, default 0f); the
	# live onProximityUpdate fill is live since N2292
	# (recomputed each enabled tick from frame proximity
	# inputs; see (5)), so the folded efficiency is the min
	# over the *modeled* consumers (power only). (2)
	# shouldConsume gate live (N2206) --
	# SolidPumpBuild overrides shouldConsume() to return
	# liquids.get(result) < liquidCapacity - 0.01f
	# (SolidPump.java:117-119, `return liquids.get(result) <
	# liquidCapacity - 0.01f;`); the pure gate reads the result
	# amount via the shared liquid module helper, with the
	# result id resolved from the liquid catalog and the def
	# capacity constant 40f; the pump advance (N2220) fills
	# the liquids store each tick (SolidPump.java:122-141).
	# (3) updateTile advance live (N2220) -- warmup /
	# pumpTime / lastPump / maxPump / fraction advance each
	# tick (SolidPump.java:122-141) from explicit fraction
	# inputs (frame valid_tiles / boost / attribute_env,
	# default 0f); dumpLiquid(result) live since N2286 (see
	# (4)); the live onProximityUpdate fill is live since
	# N2292 (see (5)); the updateEffect chance is live since
	# N2481 (see (6)).
	# (4) Dump rows live (N2286) -- dumpLiquid(result)
	# (SolidPump.java:140) dumps the result water to
	# neighbours through the shared dump_liquid_state routing
	# (scaling 2f, output_dir -1, BuildingComp.java:877-878,
	# 886-908), unconditional after pumpTime
	# (SolidPump.java:138), so it runs even at efficiency 0;
	# the neighbour liquid amounts / capacities / accepts /
	# canDump arrays are frame inputs (default [] -- no
	# neighbours, the Java proximity.size == 0 outcome),
	# live-filled since N2411 (the tick scans the live
	# proximity BEFORE the dump pure reads them); the dump exposes
	# dump_neighbour_index + dumped_liquid and the tick
	# wires the N2371 shared helper after the dump --
	# neighbour write-back live since N2377.
	# (5) Fraction fill live (N2292) -- onProximityUpdate
	# (SolidPump.java:150-159) recomputed each enabled tick
	# from frame proximity inputs (frame["proximity_linked_tiles"],
	# default [] -- no tiles) and the N2220 attribute_env
	# frame input (default 0.0): validTiles = baseEfficiency
	# / (size * size) per pumpable linked tile, boost =
	# sumAttribute / size / size with 0 for deep floors
	# (!floating && !placeableLiquid -- the water-extractor
	# def leaves both at the Block class defaults false),
	# fraction = max(validTiles + boost + env, 0); the fill
	# stamps valid_tiles / boost onto the frame BEFORE the
	# advance (Java order), and the advance recomputes the
	# fraction from the stamped keys. Still deferred: the
	# live linked-tile scan, the live envAttrs read, and a
	# proximity-change trigger (Java runs onProximityUpdate
	# only when placement/proximity changes).
	# (6) UpdateEffect chance rows live (N2481) -- the
	# chance pure (source_solid_pump_update_effect_chance_
	# state) models `if(Mathf.chance(delta() *
	# updateEffectChance)) updateEffect.at(x + Mathf.range(
	# size * 2f), y + Mathf.range(size * 2f));`
	# (SolidPump.java:131-132) inside the pump branch
	# (SolidPump.java:126) as a pure-only call record
	# {effect, x, y} (null when the gate fails or the roll
	# misses): the gate verdict + delta + chance + token +
	# the three rolls are caller-supplied (NO RNG in the
	# pure, the N2421/N2468 precedent), the chance
	# comparison is STRICT < with the d >= 1f short-circuit
	# (arc Mathf.java:240-242), and the position rolls are
	# already-ranged in [-4f, 4f] for the size-2
	# water-extractor. The live token is Fx.none (the def
	# overrides neither field, Blocks.java:2920-2930).
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_solid_pump_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, result_liquid_id: int, liquid_capacity: float, pump_amount: float) -> Dictionary:
	# The updateTile advance (SolidPumpBuild.updateTile(),
	# SolidPump.java:122-141). SolidPump extends Pump
	# (SolidPump.java:21, `public class SolidPump extends Pump{`)
	# and SolidPumpBuild extends PumpBuild (SolidPump.java:89,
	# `public class SolidPumpBuild extends PumpBuild{`); the
	# build fields are `public float warmup;`
	# (SolidPump.java:90 -- this shadows PumpBuild.warmup,
	# `public float warmup, totalProgress;`, Pump.java:111),
	# `public float pumpTime;` (SolidPump.java:91),
	# `public float boost;` (SolidPump.java:92),
	# `public float validTiles;` (SolidPump.java:93),
	# `public float lastPump;` (SolidPump.java:94), and the
	# inherited liquidDrop (`public @Nullable Liquid liquidDrop = null;`,
	# Pump.java:114). The result liquid is water (the Java field
	# default, `public Liquid result = Liquids.water;`,
	# SolidPump.java:22, set explicitly by the def,
	# `result = Liquids.water;`, Blocks.java:2922) and the
	# capacity is the def constant 40f
	# (`liquidCapacity = 40f;`, Blocks.java:2925; the class
	# default is -1f, `public float liquidCapacity = -1f;`,
	# Block.java:77). pumpAmount arrives as a parameter (the
	# driver passes the def constant 0.11f,
	# `pumpAmount = 0.11f;`, Blocks.java:2923, overriding the
	# Pump class default, `public float pumpAmount = 0.2f;`,
	# Pump.java:20) so the Fracker advance (N2224) can reuse
	# this pure function with the oil-extractor's 0.25f
	# (Blocks.java:2969). Each Java expr below stays on ONE
	# comment line (the N2148 lesson):
	# `liquidDrop = result;` (SolidPump.java:123 -- the port
	# needs no liquid_drop frame key: the result is the def
	# constant water and the driver always resolves it).
	# `float fraction = Math.max(validTiles + boost + (attribute == null ? 0 : attribute.env()), 0);` (SolidPump.java:124).
	# `if(efficiency > 0 && typeLiquid() < liquidCapacity - 0.001f){` (SolidPump.java:126).
	# `float maxPump = Math.min(liquidCapacity - typeLiquid(), pumpAmount * delta() * fraction * efficiency);` (SolidPump.java:127).
	# `liquids.add(result, maxPump);` (SolidPump.java:128 -- via the shared liquid module helper, the SourcePumpRuntimeState precedent).
	# `lastPump = maxPump / Time.delta;` (SolidPump.java:129 -- RAW Time.delta, not delta()).
	# `warmup = Mathf.lerpDelta(warmup, 1f, 0.02f);` (SolidPump.java:130).
	# `if(Mathf.chance(delta() * updateEffectChance))` (SolidPump.java:131 -- live since N2481, source_solid_pump_update_effect_chance_state, pure-only; updateEffect is Fx.none by default, SolidPump.java:23).
	# `warmup = Mathf.lerpDelta(warmup, 0f, 0.02f);` (SolidPump.java:134).
	# `lastPump = 0f;` (SolidPump.java:135).
	# `pumpTime += warmup * edelta();` (SolidPump.java:138 -- the NEW warmup, assigned above).
	# `dumpLiquid(result);` (SolidPump.java:140 -- live since N2286, source_solid_pump_dump_liquid_state, wired in the tick AFTER this advance -- Java order).
	# The Arc formula, not a guess: lerpDelta(from, to,
	# progress) = lerp(from, to, clamp(progress * Time.delta))
	# with lerp = from + (to - from) * progress and clamp(value)
	# = clamp(value, 0, 1) (Mathf.java:401-404, 425-432); it
	# scales by RAW Time.delta, so timeScale touches neither
	# the warmup lerp nor lastPump. delta() = Time.delta *
	# timeScale (`return Time.delta * timeScale;`,
	# BuildingComp.java:1922-1924) and edelta() = efficiency *
	# delta() (`return efficiency * delta();`,
	# BuildingComp.java:1927-1929). source_delta is Time.delta
	# in ticks (seconds * 60 through game_source_delta, arc
	# Time.java:26), never raw seconds (the N2186/N2187/N2191
	# lesson: raw seconds run 60x slow). typeLiquid() is
	# `public float typeLiquid(){` (SolidPump.java:162) with
	# `return liquids.get(result);` (SolidPump.java:163), read
	# through the shared liquid module helper; a frame with no
	# liquids module yet reads 0.0, like the N2206 gate.
	# efficiency defaults 0.0, the Java field default
	# (BuildingComp.java:85 `transient float efficiency;`);
	# warmup / pumpTime / lastPump / validTiles / boost default
	# 0.0, the Java build-field defaults (SolidPump.java:90-94).
	# The fraction inputs are explicit frame keys (valid_tiles
	# / boost / attribute_env, default 0f): the live
	# onProximityUpdate fill (SolidPump.java:150-159,
	# `boost = sumAttribute(attribute, tile.x, tile.y) / size / size;`
	# and `validTiles += baseEfficiency / (size * size);` over
	# the canPump linked-tile scan, with `public float baseEfficiency = 1f;`,
	# SolidPump.java:26) waits for its own slice -- the N2087
	# pump proximity helper does not apply (it scans floor
	# liquidDrop / liquidMultiplier, not solid-tile
	# attributes), and attribute.env() reads state envAttrs
	# (Attribute.java:31-34) the port does not model yet.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var valid_tiles: float = float(frame.get("valid_tiles", 0.0))
	var boost: float = float(frame.get("boost", 0.0))
	var attribute_env: float = float(frame.get("attribute_env", 0.0))
	var warmup: float = float(frame.get("warmup", 0.0))
	var pump_time: float = float(frame.get("pump_time", 0.0))
	var liquids: Dictionary = frame.get("liquids", {})
	var has_store: bool = result_liquid_id >= 0 and liquids.has("liquids") and result_liquid_id < int(liquids["liquids"].size())
	var type_liquid: float = 0.0
	if has_store:
		type_liquid = float(source_liquid_module_state.source_get_state(liquids, result_liquid_id).get("amount", 0.0))
	var fraction: float = maxf(valid_tiles + boost + attribute_env, 0.0)
	var delta: float = source_delta * time_scale
	var max_pump: float = 0.0
	var last_pump: float = 0.0
	var next_warmup: float = warmup
	if efficiency > 0.0 and type_liquid < liquid_capacity - 0.001:
		max_pump = minf(liquid_capacity - type_liquid, pump_amount * delta * fraction * efficiency)
		if has_store:
			var cache_sums: Array = []
			if liquids.get("flow") != null:
				cache_sums.resize(int(liquids["liquids"].size()))
				cache_sums.fill(0.0)
			source_liquid_module_state.source_add_state(liquids, result_liquid_id, max_pump, cache_sums)
		last_pump = max_pump / source_delta
		next_warmup = lerpf(warmup, 1.0, clampf(SOURCE_SOLID_PUMP_WARMUP_RATE * source_delta, 0.0, 1.0))
	else:
		next_warmup = lerpf(warmup, 0.0, clampf(SOURCE_SOLID_PUMP_WARMUP_RATE * source_delta, 0.0, 1.0))
		last_pump = 0.0
	var next_pump_time: float = pump_time + next_warmup * efficiency * delta
	return {"warmup": next_warmup, "pump_time": next_pump_time, "last_pump": last_pump, "max_pump": max_pump, "fraction": fraction}

static func source_solid_pump_update_effect_chance_state(pump_branch_open: bool, source_delta: float, time_scale: float, update_effect_chance: float, update_effect: String, x: float, y: float, chance_roll: float, range_roll_x: float, range_roll_y: float) -> Dictionary:
	# The updateEffect chance rows (SolidPumpBuild.updateTile(), each exact expr on ONE comment line, the N2148 lesson):
	# `public class SolidPump extends Pump{` (SolidPump.java:21)
	# `public class SolidPumpBuild extends PumpBuild{` (SolidPump.java:89)
	# `public void updateTile(){` (SolidPump.java:122)
	# `public Effect updateEffect = Fx.none;` (SolidPump.java:23)
	# `public float updateEffectChance = 0.02f;` (SolidPump.java:24)
	# `if(efficiency > 0 && typeLiquid() < liquidCapacity - 0.001f){` (SolidPump.java:126)
	# `if(Mathf.chance(delta() * updateEffectChance))` (SolidPump.java:131)
	# `updateEffect.at(x + Mathf.range(size * 2f), y + Mathf.range(size * 2f));` (SolidPump.java:132)
	# `public float delta(){` (BuildingComp.java:1922)
	# `return Time.delta * timeScale;` (BuildingComp.java:1923)
	# `private transient float timeScale = 1f, timeScaleDuration;` (BuildingComp.java:98)
	# `none = new Effect(0, 0f, e -> {}),` (Fx.java:30)
	# `size = 2;` (water-extractor, Blocks.java:2924; the driver constant SOURCE_SOLID_PUMP_SIZE)
	# `public static boolean chance(double d){` (arc Mathf.java:240)
	# `return d >= 1f || rand.nextFloat() < d;` (arc Mathf.java:241)
	# `public static float range(float range){` (arc Mathf.java:220)
	# `return random(-range, range);` (arc Mathf.java:221)
	# The chance gate sits INSIDE the pump branch (SolidPump.java:126), so the pure takes pump_branch_open as a caller-evaluated bool and does NOT recompute efficiency / typeLiquid (the N2397 precedent -- the N2220 advance owns the gate; the advance computes it inline, there is no separate gate key). delta() is Time.delta * timeScale (BuildingComp.java:1922-1923); the pure takes source_delta + time_scale like the N2220 advance (the family precedent) and computes delta inside. Mathf.chance is `return d >= 1f || rand.nextFloat() < d;` -- the d >= 1f short-circuit fires unconditionally, and the comparison is STRICT < (a roll exactly at the threshold misses). Mathf.range(r) is random(-r, r), so the position rolls span [-size * 2f, size * 2f] = [-4f, 4f] for the size-2 water-extractor. The water-extractor def overrides NEITHER updateEffect nor updateEffectChance (Blocks.java:2920-2930 -- the Blocks.java updateEffect hits are Drill defs and the Fracker oil-extractor), so the live call records the Fx.none token -- the pure still records the call with that token, and takes the token + the chance as params (the N2475 repair_radius precedent) so a def override would pass through verbatim. NO RNG in the pure (the N2421/N2468 precedent): the chance roll + the two position rolls are caller-supplied already-rolled inputs -- the position rolls arrive ALREADY-RANGED (the N2421 magnitude precedent), so the pure never sees the size, only the offsets. Pure-only: the tick never calls the chance pure -- the effect call sites that would spawn the Fx effect wait for renderer/effect slices (the N2421 draw precedent); the dump half of the old combined entry is live since N2286.
	var delta: float = source_delta * time_scale
	var threshold: float = delta * update_effect_chance
	var effect_call: Variant = null
	if pump_branch_open and (threshold >= 1.0 or chance_roll < threshold):
		effect_call = {"effect": update_effect, "x": x + range_roll_x, "y": y + range_roll_y}
	return {"effect_call": effect_call}

static func source_solid_pump_proximity_fraction_state(linked_tiles: Array, block_size: int, base_efficiency: float, attribute_env: float, floating: bool, placeable_liquid: bool, has_attribute: bool) -> Dictionary:
	# The live fraction fill (SolidPumpBuild.onProximityUpdate(),
	# SolidPump.java:150-159). Java runs it when placement /
	# proximity changes; the port recomputes it every enabled
	# tick from the frame inputs (the N2205 pump re-scan
	# precedent) -- the pure is cheap and the inputs are
	# explicit. Each Java expr below stays on ONE comment line
	# (the N2148 lesson):
	# `public void onProximityUpdate(){` (SolidPump.java:150).
	# `super.onProximityAdded();` (SolidPump.java:151 -- the parent hook, not a second updateTile).
	# `boost = sumAttribute(attribute, tile.x, tile.y) / size / size;` (SolidPump.java:153).
	# `validTiles = 0f;` (SolidPump.java:154).
	# `for(Tile other : tile.getLinkedTiles(tempTiles)){` (SolidPump.java:155).
	# `if(canPump(other)){` (SolidPump.java:156).
	# `validTiles += baseEfficiency / (size * size);` (SolidPump.java:157).
	# `protected boolean canPump(Tile tile){` (SolidPump.java:80).
	# `return tile != null && !tile.floor().isLiquid;` (SolidPump.java:81).
	# `public float baseEfficiency = 1f;` (SolidPump.java:26).
	# `float fraction = Math.max(validTiles + boost + (attribute == null ? 0 : attribute.env()), 0);` (SolidPump.java:124).
	# `public float sumAttribute(@Nullable Attribute attr, int x, int y){` (Block.java:575).
	# `if(attr == null) return 0;` (Block.java:576).
	# `if(tile == null) return 0;` (Block.java:578).
	# `return tile.getLinkedTilesAs(this, tempTiles)` (Block.java:579).
	# `.sumf(other -> !floating && !placeableLiquid && other.floor().isDeep() ? 0 : other.floor().attributes.get(attr));` (Block.java:580).
	# `public float env(){` (Attribute.java:31).
	# `if(Vars.state == null) return 0;` (Attribute.java:32).
	# `return Vars.state.envAttrs.get(this);` (Attribute.java:33).
	# `public boolean floating = false;` (Block.java:212, class default; the water-extractor def does not override it).
	# `public boolean placeableLiquid = false;` (Block.java:152, class default; the water-extractor def does not override it).
	# `attribute = Attribute.water;` (Blocks.java:2927).
	# `size = 2;` (Blocks.java:2924).
	# The two linked-tile scans use the same tile set:
	# onProximityUpdate iterates tile.getLinkedTiles(tempTiles)
	# while sumAttribute iterates tile.getLinkedTilesAs(this,
	# tempTiles) -- both walk the size x size footprint
	# including the origin tile (Tile.java:474-525), so one
	# linked_tiles input serves both sums exactly. Each entry
	# is a Dict {can_pump, attribute_value, is_deep}: the
	# canPump answer, the floor attribute value for the block
	# attribute, and the deep-floor flag. A null tile in Java
	# fails canPump and never reaches either sum (the
	# linked-tile walk skips nulls, Tile.java:480/518); a
	# frame entry with can_pump false and attribute_value 0.0
	# is the same outcome. pickedUp() resets boost =
	# validTiles = 0f (SolidPump.java:100-102) -- the per-tick
	# recompute makes that reset moot. The fill returns the
	# fraction as a pure result, but the driver stamps only
	# valid_tiles / boost onto the frame: the N2220 advance
	# recomputes the fraction from the stamped keys (Java
	# order).
	var valid_tiles: float = 0.0
	var attribute_sum: float = 0.0
	for linked_tile in linked_tiles:
		var tile: Dictionary = linked_tile
		if bool(tile.get("can_pump", false)):
			valid_tiles += base_efficiency / (block_size * block_size)
		if has_attribute:
			var deep_excluded: bool = not floating and not placeable_liquid and bool(tile.get("is_deep", false))
			if not deep_excluded:
				attribute_sum += float(tile.get("attribute_value", 0.0))
	var boost: float = attribute_sum / (block_size * block_size)
	var fraction: float = maxf(valid_tiles + boost + (attribute_env if has_attribute else 0.0), 0.0)
	return {"valid_tiles": valid_tiles, "boost": boost, "fraction": fraction}

static func source_solid_pump_dump_liquid_state(frame: Dictionary, result_liquid_id: int, liquid_capacity: float, neighbour_liquid_amounts: Array, neighbour_liquid_capacities: Array, neighbour_accepts_liquid: Array, neighbour_can_dump_liquid: Array) -> Dictionary:
	# The updateTile dump step (SolidPumpBuild.updateTile(),
	# SolidPump.java:122-141):
	# `dumpLiquid(result);` (SolidPump.java:140 --
	# UNCONDITIONAL, after `pumpTime += warmup * edelta();`,
	# SolidPump.java:138, so it runs even when efficiency is
	# 0 -- unlike the pump branch, `if(efficiency > 0 &&
	# typeLiquid() < liquidCapacity - 0.001f){`,
	# SolidPump.java:126 -- and after the pump add,
	# `liquids.add(result, maxPump);`, SolidPump.java:128,
	# so the dump drains the store the advance filled THIS
	# tick). dumpLiquid(Liquid)
	# (BuildingComp.java:877-908):
	# `public void dumpLiquid(Liquid liquid){` (BuildingComp.java:877).
	# `dumpLiquid(liquid, 2f);` (BuildingComp.java:878 -- scaling 2f).
	# `public void dumpLiquid(Liquid liquid, float scaling){` (BuildingComp.java:881).
	# `dumpLiquid(liquid, scaling, -1);` (BuildingComp.java:882 -- output_dir -1, any direction).
	# `public void dumpLiquid(Liquid liquid, float scaling, int outputDir){` (BuildingComp.java:886).
	# `int dump = this.cdump;` (BuildingComp.java:887).
	# `if(liquids.get(liquid) <= 0.0001f) return;` (BuildingComp.java:889 -- the empty-store early return).
	# `if(!net.client() && state.isCampaign() && team == state.rules.defaultTeam) liquid.unlock();` (BuildingComp.java:891 -- the campaign unlock; the shared helper evaluates the guard with the scenario-pump defaults, but the pure result carries no unlock key -- surfacing + applying it waits for its own slice).
	# `for(int i = 0; i < proximity.size; i++){` (BuildingComp.java:893).
	# `incrementDump(proximity.size);` (BuildingComp.java:894 -- once per iteration, so a full scan over N neighbours advances the cursor N times: a full cycle, leaving it where it started; the cursor still matters WITHIN the scan, as the starting neighbour).
	# `Building other = proximity.get((i + dump) % proximity.size);` (BuildingComp.java:896).
	# `if(outputDir != -1 && (outputDir + rotation) % 4 != relativeTo(other)) continue;` (BuildingComp.java:897 -- vacuous here: output_dir is -1).
	# `other = other.getLiquidDestination(self(), liquid);` (BuildingComp.java:899 -- the default returns self, `public Building getLiquidDestination(Building from, Liquid liquid){` (BuildingComp.java:980) with `return self();` (BuildingComp.java:981), so every listed neighbour is its own destination).
	# `if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){` (BuildingComp.java:901 -- the routing gate).
	# `float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;` (BuildingComp.java:902).
	# `float fract = liquids.get(liquid) / block.liquidCapacity;` (BuildingComp.java:903).
	# `if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);` (BuildingComp.java:905 -- the transfer is STRICTLY less-than: an equal neighbour takes nothing).
	# `public boolean canDumpLiquid(Building to, Liquid liquid){` (BuildingComp.java:910 -- the default returns true, BuildingComp.java:911).
	# transferLiquid (BuildingComp.java:914-921):
	# `public void transferLiquid(Building next, float amount, Liquid liquid){` (BuildingComp.java:914).
	# `float flow = Math.min(next.block.liquidCapacity - next.liquids.get(liquid), amount);` (BuildingComp.java:915 -- the flow is capped by the neighbour free capacity).
	# `if(next.acceptLiquid(self(), liquid)){` (BuildingComp.java:917).
	# `next.handleLiquid(self(), liquid, flow);` (BuildingComp.java:918 -- the neighbour write-back is live since N2377: the pure exposes the handled neighbour index + the dumped liquid name, and the tick wires the shared source_neighbour_liquid_write_back_state helper (N2371) after the dump write-back when something dumped).
	# `liquids.remove(liquid, flow);` (BuildingComp.java:919).
	# incrementDump (BuildingComp.java:1116-1120):
	# `public void incrementDump(int prox){` (BuildingComp.java:1116).
	# `if(prox != 0){` (BuildingComp.java:1117).
	# `cdump = ((cdump + 1) % prox);` (BuildingComp.java:1119).
	# The dump cursor is `transient int cdump;`
	# (BuildingComp.java:68, default 0), carried on the frame.
	# The result liquid is water (the Java field default,
	# `public Liquid result = Liquids.water;`,
	# SolidPump.java:22, set explicitly by the def,
	# `result = Liquids.water;`, Blocks.java:2922) and the
	# capacity is the def constant 40f
	# (`liquidCapacity = 40f;`, Blocks.java:2925; the class
	# default is -1f, `public float liquidCapacity = -1f;`,
	# Block.java:77). The dump runs through the shared
	# dumpLiquid port (SourceBuildingLiquidState.
	# dump_liquid_state, which binds transfer_liquid_state --
	# the scenario-pump N2090 precedent) with the shared
	# increment_dump_cursor_state callback, never a
	# hand-rolled routing loop; the store write-back reuses
	# the shared liquid module helper (source_set_state, the
	# scenario-pump precedent) and mutates the module dict in
	# place (the N2220 advance precedent: the dict is a
	# reference to the sprite meta store). The neighbour
	# arrays are parallel, in proximity order (the N2276
	# precedent, default [] -- no neighbours, the Java
	# proximity.size == 0 outcome); they list only neighbours
	# with a liquids module (the scenario-pump filter), so
	# destination-present and liquids-present are true for
	# every listed neighbour and hasLiquids follows from a
	# positive capacity. The campaign / net flags follow the
	# scenario-pump precedent (not a client, campaign,
	# default team). The neighbour write-back is live since
	# N2377 (the N2371 Fracker precedent): the pure exposes
	# the handled neighbour index (dump_neighbour_index, from
	# the shared routing's handled_index -- the FIRST eligible
	# neighbour whose transfer actually moved liquid, -1 when
	# nothing moved) + the dumped liquid name (dumped_liquid,
	# the def constant "water"), and the tick wires the shared
	# source_neighbour_liquid_write_back_state helper after
	# the dump when dumped_amount > 0. A dump that reaches
	# several neighbours reports only the first handled index,
	# so the write-back lands the total there -- the
	# per-neighbour split waits for its own slice.
	var liquids: Dictionary = frame.get("liquids", {})
	var has_store: bool = result_liquid_id >= 0 and liquids.has("liquids") and result_liquid_id < int(liquids["liquids"].size())
	var current: float = 0.0
	if has_store:
		current = float(source_liquid_module_state.source_get_state(liquids, result_liquid_id).get("amount", 0.0))
	var cursor: int = int(frame.get("cdump", 0))
	var proximity_size: int = neighbour_liquid_amounts.size()
	var relative_to: Array = []
	var destination_present: Array = []
	var other_has_liquids: Array = []
	var can_dump_liquid: Array = []
	var other_liquids_present: Array = []
	for i in range(proximity_size):
		relative_to.append(i)
		destination_present.append(true)
		other_has_liquids.append(float(neighbour_liquid_capacities[i]) > 0.0)
		can_dump_liquid.append(bool(neighbour_can_dump_liquid[i]))
		other_liquids_present.append(true)
	var dump: Dictionary = source_building_liquid_state.dump_liquid_state(SOURCE_SOLID_PUMP_RESULT_LIQUID, 2.0, -1, current, false, true, true, proximity_size, cursor, 0, relative_to, destination_present, other_has_liquids, can_dump_liquid, other_liquids_present, neighbour_liquid_amounts, neighbour_liquid_capacities, neighbour_accepts_liquid, liquid_capacity, Callable(source_building_item_dump_state, "increment_dump_cursor_state"))
	var amount_after: float = float(dump.get("current_liquid_amount_after", current))
	if has_store:
		source_liquid_module_state.source_set_state(liquids, result_liquid_id, amount_after)
	return {"liquids_after": liquids, "dumped_amount": current - amount_after, "cursor_after": int(dump.get("final_cdump", cursor)), "dump_neighbour_index": int(dump.get("handled_index", -1)), "dumped_liquid": SOURCE_SOLID_PUMP_RESULT_LIQUID}

static func source_solid_pump_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the solid-pump tick wiring every tick
	# (SolidPumpBuild.updateTile(), SolidPump.java:122, reads the
	# folded efficiency for its pump speed; the pump runtime
	# never ticks SolidPump implementations, so this driver is
	# the solid-pump tick): each placed SolidPump build gets its
	# frame keys refreshed from the live rules, so the frame's
	# cheating flag tracks team.rules().cheat and the consumption
	# machinery skips consumption for a cheating team. The frame
	# is bound at placement; a sprite that somehow lacks one gets
	# it bound here instead of crashing the loop.
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
		if not _is_solid_pump_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_solid_pump_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_solid_pump_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The frame carries the Building.liquids LiquidModule
		# (frame["liquids"]): the sprite meta holds the live
		# store (initialized at placement through
		# SourcePlacedBlockState), and the driver refreshes the
		# frame key from it each tick -- a Dictionary is a
		# reference, so the frame reads the same live store the
		# pump advance fills. A sprite with no liquids meta
		# yet reads {} and the gate reads 0.0.
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# The power consumer reads live since N2150 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a solid pump with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the speed fold (SolidPump.java:121)
		# follows it. The power consumer counts toward hasConsumers
		# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
		# so a solid pump does not take the early return. A solid
		# pump with no power consumer is untouched: the tick
		# models no other consumers yet (the live
		# onProximityUpdate fill for the water-attribute /
		# validTiles / boost fraction is live since N2292
		# (recomputed each enabled tick from frame proximity
		# inputs, stamped before the advance); N2220 computes
		# the fraction from explicit frame inputs),
		# and SolidPumpBuild overrides shouldConsume() to return
		# liquids.get(result) < liquidCapacity - 0.01f
		# (SolidPump.java:117-119) -- N2206 feeds the live gate
		# to the machinery (the pure gate is
		# source_solid_pump_should_consume_state, fed the frame
		# plus the resolved result liquid id and the def capacity
		# constant); the N2150 RED decision is resolved. The gate
		# has no enabled term (Java returns the bare capacity
		# comparison); the outer guard below already runs the
		# machinery only when enabled. productionValid is the
		# canonical true default (SourceBuildingAccessState.
		# production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var liquid_catalog: Dictionary = source_content_registry_runtime_state.source_liquid_catalog_state(catalog)
			var result_liquid_id: int = int(liquid_catalog["liquid_id_by_name"].get(SOURCE_SOLID_PUMP_RESULT_LIQUID, -1))
			var gate: Dictionary = source_solid_pump_should_consume_state(frame, result_liquid_id, SOURCE_SOLID_PUMP_LIQUID_CAPACITY)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_solid_pump_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# N2220: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2278; noUpdateDisabled defaults
		# false, Block.java:170, `public boolean noUpdateDisabled = false;`),
		# so a disabled solid pump freezes its warmup / pumpTime.
		# The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60 (arc
		# Time.java:26), never raw seconds. timeScale reads live
		# from the sprite meta, default 1.0 (BuildingComp.java:98
		# `private transient float timeScale = 1f, timeScaleDuration;`).
		# The advance mutates the frame liquids store in place
		# (the module dict is a reference to the sprite meta
		# store) and returns the advanced scalars, which the
		# driver writes back to the frame.
		if bool(frame.get("enabled", true)):
			# N2292: the live fraction fill runs BEFORE the
			# advance (Java order: onProximityUpdate stamps
			# validTiles / boost, SolidPump.java:150-159, and
			# updateTile reads them at :124). Java runs
			# onProximityUpdate only when placement/proximity
			# changes; the port recomputes the fill every
			# enabled tick from the frame inputs (the N2205
			# pump re-scan precedent) -- the pure is cheap
			# and the inputs are explicit. The linked tiles
			# are frame inputs (default [] -- no tiles, the
			# Java empty-proximity outcome) until a live tile
			# scan lands; the attribute env is the N2220
			# frame input (default 0.0); floating /
			# placeableLiquid ride the Block class defaults
			# false (Block.java:212 / :152, the def does not
			# override them) and has_attribute is true for
			# the water-extractor def (attribute =
			# Attribute.water, Blocks.java:2927). The fill
			# stamps valid_tiles / boost onto the frame; the
			# fraction is recomputed by the N2220 advance
			# from the stamped keys.
			var proximity_tiles: Array = frame.get("proximity_linked_tiles", [])
			var filled: Dictionary = source_solid_pump_proximity_fraction_state(proximity_tiles, SOURCE_SOLID_PUMP_SIZE, SOURCE_SOLID_PUMP_BASE_EFFICIENCY, float(frame.get("attribute_env", 0.0)), false, false, true)
			frame["valid_tiles"] = filled["valid_tiles"]
			frame["boost"] = filled["boost"]
			var advance_liquid_catalog: Dictionary = source_content_registry_runtime_state.source_liquid_catalog_state(catalog)
			var advance_result_id: int = int(advance_liquid_catalog["liquid_id_by_name"].get(SOURCE_SOLID_PUMP_RESULT_LIQUID, -1))
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var advanced: Dictionary = source_solid_pump_update_tile_advance_state(frame, source_delta, time_scale, advance_result_id, SOURCE_SOLID_PUMP_LIQUID_CAPACITY, SOURCE_SOLID_PUMP_PUMP_AMOUNT)
			frame["warmup"] = advanced["warmup"]
			frame["pump_time"] = advanced["pump_time"]
			frame["last_pump"] = advanced["last_pump"]
			frame["max_pump"] = advanced["max_pump"]
			frame["fraction"] = advanced["fraction"]
			# N2286: dumpLiquid(result) (SolidPump.java:140)
			# runs after pumpTime += warmup * edelta() (:138)
			# -- unconditional, so it runs even at efficiency
			# 0 (unlike the pump branch, which gates on
			# efficiency > 0, SolidPump.java:126). The dump
			# drains the store the advance filled THIS tick
			# (Java order: :128 add, :140 dump). The neighbour
			# liquid amounts / capacities / accepts / canDump
			# arrays are frame inputs (default [] -- no
			# neighbours, the Java proximity.size == 0 outcome)
			# live-filled since N2411 (the fill below, before
			# the reads -- supplied arrays win, the N2381
			# precedent). The pure N2220 advance is unchanged
			# -- the dump is a separate step after its call,
			# and the dump mutates the frame liquids store in
			# place (the module dict is a reference to the
			# sprite meta store).
			# N2411: the dump neighbour live fill -- the tick
			# fills the four neighbour arrays from the live
			# proximity BEFORE the dump pure reads them.
			# Supplied arrays WIN (the N2381 precedent): the
			# fill runs only when the frame carries NONE of
			# the four keys -- the N2286/N2377 proofs seed
			# the arrays by hand, so a fill there would
			# overwrite the seed. A frame the fill already
			# stamped (dump_neighbour_live -- port
			# bookkeeping, not Java state) refreshes every
			# tick, so a later-placed neighbour joins the
			# arrays and a removed one leaves them. The tick
			# reads the origin_cell meta inline as fill_cell
			# (cell is bound after the enabled block, the
			# N2363 note) and the catalog size.
			var has_supplied_dump_neighbour_arrays: bool = frame.has("dump_neighbour_liquid_amounts") or frame.has("dump_neighbour_liquid_capacities") or frame.has("dump_neighbour_accepts_liquid") or frame.has("dump_neighbour_can_dump_liquid")
			if not has_supplied_dump_neighbour_arrays or bool(frame.get("dump_neighbour_live", false)):
				var fill_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
				var dump_filled: Dictionary = source_solid_pump_dump_neighbour_live_fill_state(game, fill_cell, int(block.properties.get("size", 1)), advance_result_id)
				frame["dump_neighbour_liquid_amounts"] = dump_filled.get("dump_neighbour_liquid_amounts", [])
				frame["dump_neighbour_liquid_capacities"] = dump_filled.get("dump_neighbour_liquid_capacities", [])
				frame["dump_neighbour_accepts_liquid"] = dump_filled.get("dump_neighbour_accepts_liquid", [])
				frame["dump_neighbour_can_dump_liquid"] = dump_filled.get("dump_neighbour_can_dump_liquid", [])
				frame["dump_neighbour_live"] = true
			var neighbour_amounts: Array = frame.get("dump_neighbour_liquid_amounts", [])
			var neighbour_capacities: Array = frame.get("dump_neighbour_liquid_capacities", [])
			var neighbour_accepts: Array = frame.get("dump_neighbour_accepts_liquid", [])
			var neighbour_can_dump: Array = frame.get("dump_neighbour_can_dump_liquid", [])
			var dumped: Dictionary = source_solid_pump_dump_liquid_state(frame, advance_result_id, SOURCE_SOLID_PUMP_LIQUID_CAPACITY, neighbour_amounts, neighbour_capacities, neighbour_accepts, neighbour_can_dump)
			frame["liquids"] = dumped["liquids_after"]
			frame["cdump"] = dumped["cursor_after"]
			# N2377: neighbour write-back -- the shared
			# source_neighbour_liquid_write_back_state helper
			# lands the dumped water in the handled neighbour's
			# store (dumpLiquid's next.handleLiquid,
			# BuildingComp.java:918) after the dump write-back
			# above, when something dumped. The handled index
			# is a ring index (index i is ring cell i, the
			# N2353 convention), so the live fill must fill
			# the frame neighbour arrays in ring order; the
			# tick reads the origin_cell meta inline as
			# dump_cell (cell is bound after the enabled block,
			# the N2363 note) and the catalog size. A failed
			# write-back (no sprite / no frame / no liquids
			# store) drops the water -- the routing already
			# decided, so there is no fallback to the pump's
			# own store (the N2353 precedent). A dump that
			# reaches several neighbours lands the total in
			# the first handled one -- the per-neighbour split
			# waits for its own slice.
			if float(dumped.get("dumped_amount", 0.0)) > 0.0:
				var dump_index: int = int(dumped.get("dump_neighbour_index", -1))
				if dump_index >= 0:
					var dump_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
					source_building_liquid_state.source_neighbour_liquid_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_liquid", SOURCE_SOLID_PUMP_RESULT_LIQUID)), float(dumped.get("dumped_amount", 0.0)))
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}

static func source_solid_pump_dump_neighbour_live_fill_state(game: Object, cell: Vector2i, size: int, result_liquid_id: int) -> Dictionary:
	# The dump neighbour live fill (N2411, DEFERRED
	# #230): the N2286 dump rows read the four neighbour
	# arrays as frame inputs (default [] -- no neighbours,
	# the Java proximity.size == 0 outcome), so a live
	# solid pump with no fill never dumped. This fill scans
	# the live proximity BEFORE the dump pure and fills the
	# four arrays from the live neighbour frames, in ring
	# order (index i is ring cell i, the N2353 convention --
	# the ring comes from source_block_proximity_cells_state,
	# the sprite from block_sprite_at_cell, the frame from
	# the first SOURCE_CONSUMER_FRAME_META_KEYS meta on the
	# sprite, the N2353/N2371 resolution path):
	# `Building other = proximity.get((i + dump) % proximity.size);`
	# The dumped liquid is the fixed def result water -- the
	# SolidPump always dumps its def result (Blocks.java:2922),
	# not liquids.current() (the N2394 unloader case) -- so
	# the fill takes the result liquid id as a param, like
	# the N2286 dump pure, and matches the consumeLiquid
	# rows against the def constant name. The frame carries
	# nothing the fill needs, so it is not a param. The
	# amount is the neighbour frame liquids module's amount
	# for the result id, the capacity is the neighbour def's
	# liquidCapacity (the ofract denominator):
	# `float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;`
	# A neighbour frame with no liquids store reports
	# capacity 0.0 (the N2371 no_liquids_store precedent),
	# so the pure derives other_has_liquids false from the
	# capacity; the :901 gate needs the store too:
	# `if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){`
	# The accepts/canDump verdicts come from the DEFAULT
	# BuildingComp gates -- acceptLiquid is hasLiquids AND
	# consumesLiquid:
	# `public boolean acceptLiquid(Building source, Liquid liquid){`
	# `return block.hasLiquids && block.consumesLiquid(liquid);`
	# and canDumpLiquid defaults to true:
	# `public boolean canDumpLiquid(Building to, Liquid liquid){`
	# The consumes read is the liquidFilter:
	# `public boolean consumesLiquid(Liquid liq){`
	# `return liquidFilter[liq.id];`
	# which the port represents as the catalog consumeLiquid
	# rows. The liquid capacity default is the 10.0 port
	# precedent (SourceFactoryBuildState) when the catalog
	# carries no liquidCapacity key -- Java computes it in
	# Block.init:
	# `liquidCapacity = Mathf.round(10f * consumeAmount);`
	# (min 10f, since consumeAmount starts at 1f). Per-block
	# overrides are OUT of scope: a neighbour with a modeled
	# override is evaluated with the DEFAULT gate here (the
	# override dispatch is a follow-through note). A
	# neighbour with no frame (no sprite / unknown def /
	# conduit / no meta-key frame) reports the no-frame
	# outcome -- 0.0 / 0.0 / false / false -- the
	# N2353/N2371 no-frame precedent (a routed liquid to a
	# frameless neighbour drops, so the fill closes the
	# gates and nothing routes there). A conduit is
	# no-frame because its acceptLiquid is a per-block
	# override (Conduit.java:242-244, out of scope) and the
	# DEFAULT gate would reject it anyway (a conduit
	# consumes no liquid). Catalog gap (NOT fixed): 30 defs
	# carry consumeLiquid rows but lack the hasLiquids key
	# (e.g. electrolyzer) -- the fill reads the catalog key
	# with the Java field default false (the N2394
	# precedent). Two ring-model notes: Java updateProximity
	# dedupes multi-cell neighbours (`//using a set to prevent duplicates`,
	# BuildingComp.java:1879-1900) and keeps same-team
	# buildings only (`other.team != team` skips), while the
	# ring reports a multi-cell neighbour at each of its
	# ring cells with no team filter -- the N2353 / N2371
	# ring convention this fill mirrors (a delivery to
	# either index lands in the same frame). Dedup + the
	# team filter wait for a shared ring-geometry slice.
	# The frame-key list comes from a runtime load (the
	# N2371/BeamDrill precedent), NOT a preload, and this
	# pure lives after the tick function (the N2408
	# precedent).
	var ring: Array = source_block_geometry.source_block_proximity_cells_state(size, cell.x, cell.y).get("cells", [])
	var power_graph_state = load("res://src/game/SourcePlacedPowerGraphState.gd")
	var blocks_by_id: Dictionary = {}
	if game != null:
		var catalog: Variant = game.get("content_catalog")
		if catalog != null:
			for registered_block in catalog.get_many("block"):
				blocks_by_id[registered_block.id] = registered_block
	var neighbour_liquid_amounts: Array = []
	var neighbour_liquid_capacities: Array = []
	var neighbour_accepts_liquid: Array = []
	var neighbour_can_dump_liquid: Array = []
	for neighbour_cell in ring:
		var amount := 0.0
		var capacity := 0.0
		var accepts := false
		var can_dump := false
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
				for meta_key in power_graph_state.SOURCE_CONSUMER_FRAME_META_KEYS:
					if not sprite.has_meta(meta_key):
						continue
					var candidate: Variant = sprite.get_meta(meta_key)
					if candidate is Dictionary:
						neighbour_frame = candidate
						has_neighbour_frame = true
						break
				if has_neighbour_frame:
					var neighbour_properties = neighbour_block.properties
					can_dump = true
					var neighbour_liquids: Variant = neighbour_frame.get("liquids", null)
					var neighbour_amounts: Variant = null
					if neighbour_liquids is Dictionary:
						neighbour_amounts = (neighbour_liquids as Dictionary).get("liquids", null)
					if neighbour_amounts is Array:
						capacity = float(neighbour_properties.get("liquidCapacity", 10.0))
						if result_liquid_id >= 0 and result_liquid_id < (neighbour_amounts as Array).size():
							amount = float(source_liquid_module_state.source_get_state(neighbour_liquids, result_liquid_id).get("amount", 0.0))
					var consumes_liquid := false
					for row in neighbour_properties.get("consumeLiquid", []):
						if not (row is Dictionary):
							continue
						if str(row.get("liquid", "")) == SOURCE_SOLID_PUMP_RESULT_LIQUID:
							consumes_liquid = true
							break
					accepts = bool(neighbour_properties.get("hasLiquids", false)) and consumes_liquid
		neighbour_liquid_amounts.append(amount)
		neighbour_liquid_capacities.append(capacity)
		neighbour_accepts_liquid.append(accepts)
		neighbour_can_dump_liquid.append(can_dump)
	return {"dump_neighbour_liquid_amounts": neighbour_liquid_amounts, "dump_neighbour_liquid_capacities": neighbour_liquid_capacities, "dump_neighbour_accepts_liquid": neighbour_accepts_liquid, "dump_neighbour_can_dump_liquid": neighbour_can_dump_liquid}
