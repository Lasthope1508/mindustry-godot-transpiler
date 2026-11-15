extends RefCounted
class_name SourceSolidPumpBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")

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
	# as-is.
	return {"liquids": {}}

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
	# live onProximityUpdate fill (SolidPump.java:150-159)
	# waits for its own slice, so the folded efficiency is
	# the min over the *modeled* consumers (power only). (2)
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
	# default 0f); still deferred: the live onProximityUpdate
	# fill (SolidPump.java:150-159), dumpLiquid
	# (SolidPump.java:140) and the updateEffect chance
	# (SolidPump.java:131-132).
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
	# `if(Mathf.chance(delta() * updateEffectChance))` (SolidPump.java:131 -- DEFERRED, presentation; updateEffect is Fx.none by default, SolidPump.java:23).
	# `warmup = Mathf.lerpDelta(warmup, 0f, 0.02f);` (SolidPump.java:134).
	# `lastPump = 0f;` (SolidPump.java:135).
	# `pumpTime += warmup * edelta();` (SolidPump.java:138 -- the NEW warmup, assigned above).
	# `dumpLiquid(result);` (SolidPump.java:140 -- DEFERRED, needs neighbor liquid transfer).
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
		# validTiles / boost fraction waits for its own slice;
		# N2220 computes the fraction from explicit frame
		# inputs),
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
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
