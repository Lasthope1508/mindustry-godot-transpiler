extends RefCounted
class_name SourceMendProjectorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_projector_boost_state := preload("res://src/game/SourceProjectorBoostState.gd")
const source_mend_projector_state := preload("res://src/game/SourceMendProjectorState.gd")

# The MendProjector implementation (MendProjector.java:21, `public class
# MendProjector extends Block{`): mender (consumePower 0.3f,
# size 1, reload 200f, range 40f, healPercent 4f, phaseBoost 4f,
# phaseRangeBoost 20f, silicon booster) and mend-projector
# (consumePower 1.5f, size 2, reload 250f, range 85f,
# healPercent 11f, phaseBoost 15f, phaseFabric booster). Both
# havePower=true (MendProjector.java:42, `hasPower = true;`)
# and hasItems=true. MendProjector extends Block, NOT a drill
# or factory, so it cannot reuse an existing frame key; this
# driver uses its own family frame key
# ("source_mend_projector_building", the mechanical-pump /
# beam-drill precedent), and this slice adds the
# mend-projector key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it. The port already has MendProjector display/runtime
# state (SourceMendProjectorRuntimeState.gd reads
# `runtime_step.get("efficiency", 1.0)` and multiplies the heal
# by it, `healed_amount *= float(runtime_step.get("efficiency", 1.0))` at :67) -- the heal fold already consumes
# efficiency; the missing piece is the live power.status ->
# efficiency driver, which is exactly this slice.
const SOURCE_MEND_PROJECTOR_BUILD_IMPLEMENTATIONS := ["MendProjector"]
const SOURCE_MEND_PROJECTOR_BUILDING_META_KEY := "source_mend_projector_building"

static func _is_mend_projector_build_implementation(implementation: String) -> bool:
	return SOURCE_MEND_PROJECTOR_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_mend_projector_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The mend-projector tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (MendProjector.java:21, `public class MendProjector extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# mend projector skips consumption like Java's updateConsumption
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
	# for this mend projector (N2125); the tick preserves a disabled
	# mend projector instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_mend_projector_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the mend-projector frame meta key
	# ("source_mend_projector_building"). A MendProjector sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_mend_projector_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_MEND_PROJECTOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_MEND_PROJECTOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_mend_projector_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
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
	# so a mend projector does not take the early return. The
	# heal follows the folded efficiency
	# (MendProjector.java:113, `other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);`), with the smooth-efficiency gate
	# (MendProjector.java:96, `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);`) and the heat gate
	# (MendProjector.java:97, `heat = Mathf.lerpDelta(heat, efficiency > 0 && canHeal ? 1f : 0f, 0.08f);`) and the charge advance
	# (MendProjector.java:98, `charge += heat * delta();`).
	# Documented limits: (1) power-only first pass -- the
	# silicon (mender) and phaseFabric (mend-projector)
	# booster item rows wait for their own slices, so the
	# folded efficiency is the min over the *modeled*
	# consumers (power only). (2) No shouldConsume gate --
	# MendBuild has no shouldConsume override, so the default
	# (BuildingComp.java:755-757, `return enabled;`) applies;
	# the machinery runs with should_consume=true when
	# enabled. (3) No suppression gate -- `canHeal =
	# !checkSuppression();` (MendProjector.java:94) needs
	# suppression state the tick does not track yet. (4)
	# updateTile advance -- N2193 advances smoothEfficiency /
	# heat / charge / phaseHeat (MendProjector.java:94-100,
	# 103-105) on the frame, including the charge reset; the
	# timer/consume line (MendProjector.java:101-103) and the
	# heal scan + sound (MendProjector.java:106-118) wait for
	# their own slices, so the proof carries no timer/heal
	# keys -- the reset, not a heal, is what the reset key
	# proves. N2242 adds the pure heal scan (explicit
	# candidates, MendProjector.java:106-122); Fx / sound /
	# recentlyHealed and the live indexer query still wait.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_mend_projector_update_tile_advance_state(frame: Dictionary, reload_value: float, time_delta: float, time_scale := 1.0, can_heal := true) -> Dictionary:
	# MendBuild.updateTile() (MendProjector.java:94-120), the
	# pure frame advance -- the build fields are
	# `public float heat, charge = Mathf.random(reload), phaseHeat, smoothEfficiency;` (MendProjector.java:85),
	# and the advance follows the Java lines in order (each
	# exact expr on ONE comment line, the N2148 lesson):
	# `boolean canHeal = !checkSuppression();`
	# `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);`
	# `heat = Mathf.lerpDelta(heat, efficiency > 0 && canHeal ? 1f : 0f, 0.08f);`
	# `charge += heat * delta();`
	# `phaseHeat = Mathf.lerpDelta(phaseHeat, optionalEfficiency, 0.1f);`
	# `if(charge >= reload && canHeal){` then `charge = 0f;`
	# The lerp formula comes from Arc, not from a guess:
	# lerpDelta is `return lerp(fromValue, toValue, clamp(progress * Time.delta));` (Mathf.java:430-432),
	# so the lerps use the UNSCALED Time.delta
	# (source_math_state.source_lerp_delta), while the charge
	# advance uses the SCALED delta():
	# `return Time.delta * timeScale;` (BuildingComp.java:1922-1924).
	# The charge advance uses the NEW heat (Java line order:
	# heat is assigned before the charge line). The reset sits
	# in the `charge >= reload` branch BEFORE the indexer
	# scan, so it does not depend on finding a target --
	# this slice implements the reset and defers the scan.
	# Scoping decisions, all source-backed: (1) can_heal
	# defaults true -- the tick tracks no suppression state
	# (the N2184 BuildTurret suppression precedent); the
	# parameter keeps the suppressed branch (heat lerps
	# toward 0, no reset) provable. (2) efficiency /
	# optional_efficiency read from the frame with the Java
	# field default 0.0 (BuildingComp.java:87, `transient
	# float optionalEfficiency;`); the shared machinery folds
	# both onto the frame (apply_update_consumption_state),
	# and with no optional consumers modeled the optional
	# value equals the folded efficiency. (3) charge binds
	# 0.0 deterministically instead of the Java random init
	# (documented deviation: the random stagger only
	# desynchronizes first-heal timing across projectors).
	# (4) reload_value is per-def (mender 200f,
	# mend-projector 250f, Blocks.java:1923/1936), read by
	# the tick through the family helper. DEFERRED, not
	# done and not guessed: the booster timer/consume line
	# `if(optionalEfficiency > 0 && timer(timerUse, useTime / timeScale) && canHeal){` (MendProjector.java:101-103,
	# needs timer + items infrastructure), and the heal scan
	# + sound -- `other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);`
	# (MendProjector.java:113, needs targets/indexer
	# infrastructure) -- plus draw / drawLight / sense
	# (MendProjector.java:122-170). The older runtime
	# simulation (SourceMendProjectorRuntimeState.
	# runtime_step_state) is a separate state store that
	# lerps toward 1.0 unconditionally with no charge reset;
	# this driver frame advance follows Java exactly and
	# does not touch it.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var optional_efficiency: float = float(frame.get("optional_efficiency", 0.0))
	var smooth_efficiency: float = source_math_state.source_lerp_delta(float(frame.get("smooth_efficiency", 0.0)), efficiency, source_projector_boost_state.SOURCE_PROJECTOR_HEAT_LERP_PROGRESS, time_delta)
	var heat_target: float = 1.0 if efficiency > 0.0 and can_heal else 0.0
	var heat: float = source_math_state.source_lerp_delta(float(frame.get("heat", 0.0)), heat_target, source_projector_boost_state.SOURCE_PROJECTOR_HEAT_LERP_PROGRESS, time_delta)
	var charge: float = float(frame.get("charge", 0.0)) + heat * time_delta * time_scale
	var phase_heat: float = source_math_state.source_lerp_delta(float(frame.get("phase_heat", 0.0)), optional_efficiency, source_projector_boost_state.SOURCE_PROJECTOR_PHASE_HEAT_LERP_PROGRESS, time_delta)
	if charge >= reload_value and can_heal:
		charge = 0.0
	frame["smooth_efficiency"] = smooth_efficiency
	frame["heat"] = heat
	frame["charge"] = charge
	frame["phase_heat"] = phase_heat
	return frame

static func source_mend_projector_heal_scan_state(frame: Dictionary, candidates: Array, charge_before: float, reload_value: float, range_value: float, heal_percent: float, phase_boost: float, phase_range_boost: float, time_delta: float, time_scale := 1.0, can_heal := true) -> Dictionary:
	# MendBuild.updateTile() heal branch (MendProjector.java:106-122),
	# the pure scan -- the N2193 advance already ran on this frame
	# (smoothEfficiency / heat / charge / phaseHeat, including the
	# charge reset), so the scan reads the POST-advance phase_heat /
	# heat / efficiency and recomputes the branch crossing from the
	# charge captured BEFORE the advance (each exact expr on ONE
	# comment line, the N2148 lesson):
	# `if(charge >= reload && canHeal){`
	# `float realRange = range + phaseHeat * phaseRangeBoost;`
	# `indexer.eachBlock(this, realRange, b -> b.damaged() && !b.isHealSuppressed(), other -> {`
	# `other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);`
	# `private boolean any = false;`
	# The crossing recompute follows the charge advance line
	# `charge += heat * delta();` (MendProjector.java:98): the
	# advance added heat_after * time_delta * time_scale to
	# charge_before and reset to 0f on crossing, so the scan
	# replays charge_before + heat_after * time_delta *
	# time_scale >= reload_value against the per-def reload --
	# reading the frame charge here would always see the reset
	# 0f. The predicate halves are explicit per-candidate
	# booleans: damaged() is `return health < maxHealth - 0.001f;`
	# (HealthComp.java:47-49) and isHealSuppressed() is
	# `return block.suppressable && Time.time <= healSuppressionTime;`
	# (BuildingComp.java:487-489); the port tracks neither
	# health nor suppression time on candidate buildings, so
	# the caller supplies both. Per-def params are explicit:
	# the defs override the class defaults (mender range 40f /
	# healPercent 4f / phaseBoost 4f / phaseRangeBoost 20f,
	# Blocks.java:1924-1927; mend-projector range 85f /
	# healPercent 11f / phaseBoost 15f, Blocks.java:1937-1939,
	# phaseRangeBoost NOT overridden so the class 50f,
	# MendProjector.java:30, applies). DEFERRED, not done and
	# not guessed: `other.recentlyHealed();` (MendProjector.java:114,
	# a timestamp write on the healed building object),
	# `Fx.healBlockFull.at(other.x, other.y, other.block.size, baseColor, other.block);` (MendProjector.java:115,
	# presentation), and `mendSound.at(this, 1f + Mathf.range(0.1f), mendSoundVolume);` (MendProjector.java:120,
	# sound, gated on `any`) -- the pure scan returns the
	# amounts and the flag and lets the caller apply them.
	# The live indexer range query is deferred too: the port
	# has no live building index, so the caller passes the
	# candidate list explicit and the live tick passes none.
	var phase_heat: float = float(frame.get("phase_heat", 0.0))
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var heat_after: float = float(frame.get("heat", 0.0))
	var real_range: float = range_value + phase_heat * phase_range_boost
	var crossed: bool = charge_before + heat_after * time_delta * time_scale >= reload_value and can_heal
	var heal_amounts: Array = []
	var any_healed: bool = false
	if crossed:
		for candidate in candidates:
			var entry: Dictionary = candidate if candidate is Dictionary else {}
			if bool(entry.get("damaged", false)) and not bool(entry.get("heal_suppressed", false)):
				var max_health: float = float(entry.get("max_health", 0.0))
				heal_amounts.append(max_health * (heal_percent + phase_heat * phase_boost) / 100.0 * efficiency)
				any_healed = true
	return {"real_range": real_range, "heal_amounts": heal_amounts, "any": any_healed, "scanned": crossed}

@warning_ignore("unused_parameter")
static func source_mend_projector_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the mend-projector tick wiring every
	# tick (MendBuild.updateTile(), MendProjector.java:94,
	# gates on the smooth-efficiency gate (MendProjector.java:96,
	# `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);`) and folds the
	# heal (MendProjector.java:113,
	# `other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);`), so the
	# heal fold follows the folded efficiency; no
	# placed-buildings driver ticks MendProjector blocks, so this
	# driver is the placed-mend-projector tick): each placed
	# MendProjector build gets its frame keys refreshed from the
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
		if not _is_mend_projector_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_mend_projector_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_mend_projector_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a mend projector with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the heal fold (MendProjector.java:113)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449,
		# `hasConsumers = consumers.length > 0;`), so a mend
		# projector does not take the early return. A mend projector with
		# no power consumer is untouched: the tick models no other
		# consumers yet (the silicon / phaseFabric booster item rows wait for their
		# own slices), and there is no shouldConsume gate yet
		# (MendBuild has no shouldConsume override; the default
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
			var power_row: Dictionary = source_mend_projector_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# The updateTile advance runs for every ticked mend
		# projector, inside or outside the consumption gate:
		# updateTile runs even when disabled
		# (BuildingComp.java:2276, `if(enabled ||
		# !block.noUpdateDisabled){` with noUpdateDisabled
		# false, Block.java:170), and updateConsumption runs
		# first (BuildingComp.java:2274), so the advance
		# follows the frame efficiency the machinery last
		# folded. The per-def reload comes from the family
		# helper (mender 200f, mend-projector 250f,
		# Blocks.java:1923/1936); Time.delta in ticks from
		# the placed-block helper; timeScale live from the
		# sprite meta (default 1f, BuildingComp.java:98);
		# canHeal is the documented default true
		# (suppression untracked, the N2184 precedent).
		var time_delta: float = source_placed_block_state.game_source_delta(game, seconds)
		var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
		var reload_value: float = source_mend_projector_state.projector_reload(block)
		# The heal scan (N2242) runs right after the advance,
		# in Java order (MendProjector.java:106-122 follows the
		# advance lines :94-100): capture charge_before BEFORE
		# the advance, because the advance resets the frame
		# charge to 0f on crossing and the scan recomputes the
		# crossing from it. The per-def scan params come from
		# the block properties with the class defaults where a
		# def does not override (range 60f, healPercent 12f,
		# phaseBoost 12f, phaseRangeBoost 50f,
		# MendProjector.java:27-30); the live tick passes no
		# candidates -- the port has no indexer, so the range
		# query stays deferred -- and records the scan result
		# on the frame as last_heal_scan (its `any` entry
		# mirrors the Java `any` field, MendProjector.java:35).
		var charge_before: float = float(frame.get("charge", 0.0))
		source_mend_projector_update_tile_advance_state(frame, reload_value, time_delta, time_scale)
		var heal_scan: Dictionary = source_mend_projector_heal_scan_state(frame, [], charge_before, reload_value, float(block.properties.get("range", 60.0)), float(block.properties.get("healPercent", 12.0)), float(block.properties.get("phaseBoost", 12.0)), float(block.properties.get("phaseRangeBoost", 50.0)), time_delta, time_scale)
		frame["last_heal_scan"] = heal_scan
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
