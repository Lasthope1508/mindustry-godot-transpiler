extends RefCounted
class_name SourceOverdriveProjectorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_projector_boost_state := preload("res://src/game/SourceProjectorBoostState.gd")
const source_overdrive_projector_state := preload("res://src/game/SourceOverdriveProjectorState.gd")

# The OverdriveProjector implementation (OverdriveProjector.java:21, `public class
# OverdriveProjector extends Block{`): overdrive-projector (consumePower 3.50f,
# size 2, range 80f, speedBoost 1.5f, speedBoostPhase 0.75f, useTime 400f,
# phaseRangeBoost 20f, hasBoost=true, phaseFabric booster) and overdrive-dome
# (consumePower 10f, size 3, range 200f, speedBoost 2.5f, useTime 300f,
# hasBoost=false, phaseFabric + silicon booster). Both
# havePower=true (OverdriveProjector.java:38, `hasPower = true;`)
# and hasItems=true. OverdriveProjector extends Block, NOT a drill
# or factory, so it cannot reuse an existing frame key; this
# driver uses its own family frame key
# ("source_overdrive_projector_building", the mechanical-pump /
# beam-drill / mend-projector precedent), and this slice adds the
# overdrive-projector key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it. The port already has OverdriveProjector display/runtime
# state (SourceOverdriveProjectorRuntimeState.gd: `runtime_step_state`
# lerps smooth_efficiency and heat toward 1.0, and `real_boost(
# overdrive_projector, phase_heat, efficiency)` multiplies by
# efficiency with default 1.0 -- the boost fold already consumes
# efficiency) -- the missing piece is the live power.status ->
# efficiency driver, which is exactly this slice. N2194 adds the
# OverdriveBuild.updateTile() advance on top of that driver
# (OverdriveProjector.java:97-120): the frame now tracks
# smoothEfficiency / heat / charge / phaseHeat / useProgress,
# advanced every tick from the folded efficiency, with the
# charge reset at reload; the boost application
# (OverdriveProjector.java:113) and consume()
# (OverdriveProjector.java:119) are deferred to their own
# slices.
const SOURCE_OVERDRIVE_PROJECTOR_BUILD_IMPLEMENTATIONS := ["OverdriveProjector"]
const SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY := "source_overdrive_projector_building"

static func _is_overdrive_projector_build_implementation(implementation: String) -> bool:
	return SOURCE_OVERDRIVE_PROJECTOR_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_overdrive_projector_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The overdrive-projector tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (OverdriveProjector.java:21, `public class OverdriveProjector extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# overdrive projector skips consumption like Java's updateConsumption
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
	# for this overdrive projector (N2125); the tick preserves a disabled
	# overdrive projector instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# Build fields (OverdriveProjector.java:84):
	# public float heat, charge = Mathf.random(reload), phaseHeat, smoothEfficiency, useProgress;
	# Java floats default to 0; charge is the exception, a
	# uniform random in [0, reload). The port binds charge
	# deterministically to 0.0 -- the runtime-state default
	# precedent (SourceOverdriveProjectorRuntimeState.
	# capture_state / runtime_step_state default charge 0.0,
	# same for MendProjector) -- so proofs start from a known
	# state and the first charge cycle runs the full reload.
	return {"smooth_efficiency": 0.0, "heat": 0.0, "charge": 0.0, "phase_heat": 0.0, "use_progress": 0.0}

static func source_overdrive_projector_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, has_boost: bool, reload_value: float, use_time_value: float) -> Dictionary:
	# OverdriveBuild.updateTile() (OverdriveProjector.java:97-120), the internal advance,
	# in exact Java order. The lerp is Arc's lerpDelta (Mathf.java:430-432):
	# return lerp(fromValue, toValue, clamp(progress * Time.delta));
	# with lerp `fromValue + (toValue - fromValue) * progress` (Mathf.java:425-427),
	# via the canonical source_lerp_delta; source_delta is Time.delta in ticks
	# (seconds * 60, game_source_delta -- never raw seconds, the N2186/N2187/N2191
	# lesson: raw seconds run 60x slow). The frame carries the folded efficiency
	# (the N2157 power row) and optionalEfficiency, already folded by the shared
	# machinery (BuildingComp.java:1965 `efficiency = optionalEfficiency = 1f;`, then
	# the optional pass BuildingComp.java:1981 and the min fold BuildingComp.java:1986
	# `optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);`); with no
	# optional consumers modeled yet, optionalEfficiency equals the min efficiency,
	# so a missing optional_efficiency stamp defaults to the frame efficiency, and
	# a missing efficiency stamp folds to 1.0 before the first consumption pass,
	# the assembler fold (UnitAssembler.java:469).
	# smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);
	# heat = Mathf.lerpDelta(heat, efficiency > 0 ? 1f : 0f, 0.08f);
	# charge += heat * Time.delta;
	# phaseHeat = Mathf.lerpDelta(phaseHeat, optionalEfficiency, 0.1f);
	# charge = 0f;
	# useProgress += delta();
	# useProgress %= useTime;
	# return (speedBoost + phaseHeat * speedBoostPhase) * efficiency;
	# Charge advances on raw Time.delta -- NOT delta() (BuildingComp.java:1922-1924):
	# return Time.delta * timeScale;
	# -- unlike MendProjector (`charge += heat * delta();`); only useProgress uses
	# delta(), so timeScale scales the use timer but never the charge. phaseHeat
	# lerps only when hasBoost (OverdriveProjector.java:102 `if(hasBoost){`); the
	# overdrive-dome sets hasBoost = false (Blocks.java:1960), so its phaseHeat
	# stays 0. The charge reset sits inside `if(charge >= reload){` BEFORE the
	# indexer scan (OverdriveProjector.java:110-112), so the reset does not depend
	# on finding a target -- this slice resets, and only the boost application is
	# deferred (OverdriveProjector.java:113):
	# indexer.eachBlock(this, realRange, other -> other.block.canOverdrive, other -> other.applyBoost(realBoost(), reload + 1f));
	# The useProgress wrap is unconditional arithmetic in the `if(useProgress >= useTime){`
	# branch: consume() returns void, so nothing gates the wrap on consume's outcome --
	# the wrap fires whenever the timer crosses useTime, and the runtime-step
	# precedent wraps too (SourceOverdriveProjectorRuntimeState.runtime_step_state
	# fmods use_progress at use_time); only the consume() item side effect
	# (OverdriveProjector.java:119) is deferred, waiting for item infrastructure.
	# realBoost() is NOT computed here: it is a pure computation over phaseHeat and
	# efficiency already covered by SourceOverdriveProjectorRuntimeState.real_boost
	# and the N2157 real-boost fold, and its only updateTile consumer is the
	# deferred boost application. hasBoost / reload / useTime are per-def catalog
	# values (overdrive-projector: hasBoost true, reload 60f, useTime 400f;
	# overdrive-dome: hasBoost false, reload 60f, useTime 300f, Blocks.java:1958),
	# passed in by the driver through SourceOverdriveProjectorState's accessors.
	var efficiency: float = float(frame.get("efficiency", 1.0))
	var optional_efficiency: float = float(frame.get("optional_efficiency", efficiency))
	var smooth_efficiency: float = source_math_state.source_lerp_delta(float(frame.get("smooth_efficiency", 0.0)), efficiency, source_projector_boost_state.SOURCE_PROJECTOR_HEAT_LERP_PROGRESS, source_delta)
	var heat: float = source_math_state.source_lerp_delta(float(frame.get("heat", 0.0)), 1.0 if efficiency > 0.0 else 0.0, source_projector_boost_state.SOURCE_PROJECTOR_HEAT_LERP_PROGRESS, source_delta)
	var charge: float = float(frame.get("charge", 0.0)) + heat * source_delta
	var phase_heat: float = float(frame.get("phase_heat", 0.0))
	if has_boost:
		phase_heat = source_math_state.source_lerp_delta(phase_heat, optional_efficiency, source_projector_boost_state.SOURCE_PROJECTOR_PHASE_HEAT_LERP_PROGRESS, source_delta)
	var charge_ready: bool = charge >= reload_value
	if charge_ready:
		charge = 0.0
	var use_progress: float = float(frame.get("use_progress", 0.0))
	if efficiency > 0.0:
		use_progress += source_delta * time_scale
	var use_ready: bool = use_progress >= use_time_value
	if use_ready:
		use_progress = fmod(use_progress, use_time_value) if use_time_value > 0.0 else 0.0
	return {"advanced": {"smooth_efficiency": smooth_efficiency, "heat": heat, "charge": charge, "phase_heat": phase_heat, "use_progress": use_progress}, "charge_ready": charge_ready, "use_ready": use_ready}

static func source_overdrive_projector_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the overdrive-projector frame meta key
	# ("source_overdrive_projector_building"). An OverdriveProjector sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_overdrive_projector_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_overdrive_projector_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
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
	# so an overdrive projector does not take the early return. The
	# real boost follows the folded efficiency
	# (OverdriveProjector.java:124, `return (speedBoost + phaseHeat * speedBoostPhase) * efficiency;`), with the smooth-efficiency gate
	# (OverdriveProjector.java:98, `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);`) and the heat gate
	# (OverdriveProjector.java:99, `heat = Mathf.lerpDelta(heat, efficiency > 0 ? 1f : 0f, 0.08f);`) and the charge advance
	# (OverdriveProjector.java:100, `charge += heat * Time.delta;`).
	# Documented limits: (1) power-only first pass -- the
	# phaseFabric (overdrive-projector) and phaseFabric+silicon
	# (overdrive-dome) booster item rows wait for their own slices, so the
	# folded efficiency is the min over the *modeled*
	# consumers (power only). (2) No shouldConsume gate --
	# OverdriveBuild has no shouldConsume override, so the default
	# (BuildingComp.java:755-757, `return enabled;`) applies;
	# the machinery runs with should_consume=true when
	# enabled. (3) updateTile advance DONE (N2194) -- smoothEfficiency /
	# heat / charge / phaseHeat / useProgress advance every tick
	# (OverdriveProjector.java:97-120) and charge resets at reload;
	# the boost application (indexer.eachBlock + applyBoost,
	# OverdriveProjector.java:113) and the realRange fold
	# (OverdriveProjector.java:110) wait for their own slices --
	# the proof asserts only the charge reset, never a boosted
	# target. (4) No useProgress consume() rows -- useTime 400f /
	# dome 300f (OverdriveProjector.java:117-120): useProgress
	# advances and wraps at useTime since N2194, but consume()
	# (OverdriveProjector.java:119) needs item infrastructure and
	# waits for its own slice; the dome's hasBoost=false
	# (Blocks.java:1960) means its phaseHeat stays 0, which the
	# advance models.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_overdrive_projector_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the overdrive-projector tick wiring every
	# tick (OverdriveBuild.updateTile(), OverdriveProjector.java:97,
	# gates on the smooth-efficiency gate (OverdriveProjector.java:98,
	# `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);`) and folds the
	# real boost (OverdriveProjector.java:124,
	# `return (speedBoost + phaseHeat * speedBoostPhase) * efficiency;`), so the
	# real-boost fold follows the folded efficiency; no
	# placed-buildings driver ticks OverdriveProjector blocks, so this
	# driver is the placed-overdrive-projector tick): each placed
	# OverdriveProjector build gets its frame keys refreshed from the
	# live rules, so the frame's cheating flag tracks
	# team.rules().cheat and the consumption machinery skips
	# consumption for a cheating team. The frame is bound at
	# placement; a sprite that somehow lacks one gets it bound
	# here instead of crashing the loop.
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
		if not _is_overdrive_projector_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_overdrive_projector_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_overdrive_projector_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# an overdrive projector with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the real-boost fold (OverdriveProjector.java:124)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449,
		# `hasConsumers = consumers.length > 0;`), so an overdrive
		# projector does not take the early return. An overdrive projector with
		# no power consumer is untouched: the tick models no other
		# consumers yet (the phaseFabric / phaseFabric+silicon booster item rows wait for their
		# own slices), and there is no shouldConsume gate yet
		# (OverdriveBuild has no shouldConsume override; the default
		# BuildingComp.java:755-757 `return enabled;` applies),
		# so the machinery runs with should_consume=true when enabled.
		# productionValid is the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_overdrive_projector_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# N2194: the updateTile advance runs every tick for every
		# placed OverdriveProjector build (Java updateTile runs
		# every tick for update=true blocks), AFTER the
		# consumption fold, so it reads the freshly folded
		# efficiency and optionalEfficiency. source_delta is
		# Time.delta in ticks (seconds * 60 via game_source_delta,
		# never raw seconds); the timeScale for delta() is read
		# live from the sprite meta (the N2189 precedent), and
		# hasBoost / reload / useTime are the per-def catalog
		# values through SourceOverdriveProjectorState's
		# accessors (overdrive-projector: hasBoost true, reload
		# 60f, useTime 400f; overdrive-dome: hasBoost false,
		# reload 60f, useTime 300f). The advanced frame merges
		# back into the bound frame; charge_ready / use_ready
		# are the boost-fire / consume-fire signals for the
		# slices that model them (boost application and
		# consume() are deferred).
		var advance: Dictionary = source_overdrive_projector_update_tile_advance_state(frame, source_placed_block_state.game_source_delta(game, seconds), source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game)), source_overdrive_projector_state.has_boost(block), source_overdrive_projector_state.projector_reload(block), source_overdrive_projector_state.use_time(block))
		frame.merge(advance.get("advanced", {}), true)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
