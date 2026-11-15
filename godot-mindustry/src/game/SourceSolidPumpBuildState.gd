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
	# liquidCapacity - 0.01f;`). No live intake fills it yet --
	# the pump advance is the updateTile advance
	# (SolidPump.java:121-141), which waits for its own slice;
	# the gate reads the store as-is.
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
	# water-attribute / validTiles / boost fraction
	# (SolidPump.java:118, 137-147) waits for its own slice, so
	# the folded efficiency is the min over the *modeled*
	# consumers (power only). (2) shouldConsume gate live (N2206) --
	# SolidPumpBuild overrides shouldConsume() to return
	# liquids.get(result) < liquidCapacity - 0.01f
	# (SolidPump.java:117-119, `return liquids.get(result) <
	# liquidCapacity - 0.01f;`); the pure gate reads the result
	# amount via the shared liquid module helper, with the
	# result id resolved from the liquid catalog and the def
	# capacity constant 40f; no live intake fills the liquids
	# store yet (the pump advance is the updateTile advance,
	# SolidPump.java:121-141). (3)
	# No updateTile advance -- warmup/pumpTime/lastPump/
	# validTiles/boost (SolidPump.java:118-133) waits for its own
	# slice; the proof carries no progress keys, the speed fold
	# (SolidPump.java:121) is what the efficiency keys prove.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_solid_pump_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the solid-pump tick wiring every tick
	# (SolidPumpBuild.updateTile(), SolidPump.java:118, reads the
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
		# pump advance will fill. A sprite with no liquids meta
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
		# models no other consumers yet (the water-attribute /
		# validTiles / boost fraction waits for its own slice),
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
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
