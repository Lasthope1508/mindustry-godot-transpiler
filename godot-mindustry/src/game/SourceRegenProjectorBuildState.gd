extends RefCounted
class_name SourceRegenProjectorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

# The RegenProjector implementation (RegenProjector.java:29, `public class
# RegenProjector extends Block{`): regen-projector (consumePower 1f,
# size 3, range 28, Blocks.java:2009). It hasPower=true
# (RegenProjector.java:45, `hasPower = true;`), hasItems=true,
# suppressable=true, update=true, solid=true. RegenProjector
# extends Block, NOT a drill or factory, so it cannot reuse an
# existing frame key; this driver uses its own family frame key
# ("source_regen_projector_building", the mechanical-pump /
# beam-drill / mend-projector / overdrive-projector /
# force-projector / base-shield precedent), and this slice adds the
# regen-projector key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it. The port has NO SourceRegenProjector* files at all
# yet -- no display/runtime state to lean on -- so the missing
# piece is the live power.status -> efficiency driver, which is
# exactly this slice: the heal gate
# (RegenProjector.java:142, `if(efficiency > 0){`) follows the
# folded efficiency, with the heal amount
# (RegenProjector.java:148, `float healAmount = Mathf.lerp(1f, optionalMultiplier, optionalEfficiency) * healPercent;`) and the regen-projector healPercent
# (Blocks.java:2018, `healPercent = 4f / 60f;`).
const SOURCE_REGEN_PROJECTOR_BUILD_IMPLEMENTATIONS := ["RegenProjector"]
const SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY := "source_regen_projector_building"
# N2228 def constants (single def -- regen-projector; the catalog
# carries no healPercent, so the def values live here): the warmup
# approach speed 1f/70f (RegenProjector.java:129), the def
# healPercent 4f/60f (Blocks.java:2019, overriding the class
# `public float healPercent = 12f / 60f;`, RegenProjector.java:28),
# the optional multiplier 2f and the optional use time 60f * 8f =
# 480f (RegenProjector.java:29-30, class values, no def override).
const SOURCE_REGEN_PROJECTOR_WARMUP_SPEED := 1.0 / 70.0
const SOURCE_REGEN_PROJECTOR_HEAL_PERCENT := 4.0 / 60.0
const SOURCE_REGEN_PROJECTOR_OPTIONAL_MULTIPLIER := 2.0
const SOURCE_REGEN_PROJECTOR_OPTIONAL_USE_TIME := 480.0

static func _is_regen_projector_build_implementation(implementation: String) -> bool:
	return SOURCE_REGEN_PROJECTOR_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_regen_projector_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The regen-projector tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (RegenProjector.java:29, `public class RegenProjector extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# regen projector skips consumption like Java's updateConsumption
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
	# for this regen projector (N2125); the tick preserves a disabled
	# regen projector instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# The fresh frame binds the Java build-field defaults:
	# `public Seq<Building> targets = new Seq<>();`
	# (RegenProjector.java:109), `public int lastChange = -2;`
	# (RegenProjector.java:110), `public float warmup, totalTime, optionalTimer;`
	# (RegenProjector.java:111, all 0f), `public boolean anyTargets = false;`
	# (RegenProjector.java:112) and `public boolean didRegen = false;`
	# (RegenProjector.java:113); mendMap starts empty (the Java map
	# is static-shared, RegenProjector.java:23, but the port tracks
	# a per-building map -- see the advance). The frame inputs
	# (heal_suppressed, tile_changes) are NOT bound here: the advance
	# reads them with frame.get defaults (false / 1), the N2223
	# efficiency_factor precedent.
	return {
		"any_targets": false,
		"warmup": 0.0,
		"total_time": 0.0,
		"optional_timer": 0.0,
		"did_regen": false,
		"targets": [],
		"mend_map": {},
		"last_change": -2,
	}

static func source_regen_projector_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the regen-projector frame meta key
	# ("source_regen_projector_building"). A RegenProjector sprite gets a
	# frame bound with the any_targets key defaulting to false (the Java
	# field `public boolean anyTargets = false;`, RegenProjector.java:112)
	# plus the updateTile state keys (warmup / total_time /
	# optional_timer / did_regen / targets / mend_map / last_change,
	# the Java build-field defaults, RegenProjector.java:109-113 --
	# N2228); the live-loop tick fills its other keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_regen_projector_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_regen_projector_should_consume_state(frame: Dictionary) -> Dictionary:
	# RegenProjectorBuild overrides shouldConsume (RegenProjector.java:181, `public boolean shouldConsume(){` with `return anyTargets;`, RegenProjector.java:182): the gate reads ONLY the anyTargets flag -- the projector consumes while a damaged building is in range and stops consuming once nothing in range is damaged. The field is `public boolean anyTargets = false;` (RegenProjector.java:112) on RegenProjectorBuild (`public class RegenProjectorBuild extends Building{`, RegenProjector.java:108); RegenProjector extends Block (RegenProjector.java:20, `public class RegenProjector extends Block{`), so the default (`return enabled;`, BuildingComp.java:755) does NOT apply here. Unlike the Separator/Drill gates this one has NO `&& enabled` -- Java returns the bare flag, so the pure gate does NOT read frame["enabled"] at all (the driver already runs the machinery only when enabled). The frame carries the flag (frame["any_targets"], default false for a frame bound before this slice -- the Java field defaults to false); no live fill sets the targets list yet -- the targets computation (indexer range query, RegenProjector.java:115-119, + contains damaged, RegenProjector.java:139) is the updateTile advance (RegenProjector.java:122-179): the contains-damaged fold is live (N2228) over the frame targets input, the indexer query still waits for its own slice. The gate reads anyTargets only, never the targets list itself, so this slice adds NO `targets` frame key. When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The heal gate (RegenProjector.java:141, `if(efficiency > 0){`) and the heal amount (RegenProjector.java:147, `float healAmount = Mathf.lerp(1f, optionalMultiplier, optionalEfficiency) * healPercent;`) follow the folded efficiency; the def consumes power 1f (`consumePower(1f);`, Blocks.java:2015) plus liquid hydrogen 1f/60f (`consumeLiquid(Liquids.hydrogen, 1f / 60f);`, Blocks.java:2016) -- the liquid row waits for its own slice. N2214 cites the gate at 181-183 (verified by grep: exactly one shouldConsume in the file).
	var any_targets: bool = bool(frame.get("any_targets", false))
	return {"should_consume": any_targets, "any_targets": any_targets}

static func source_regen_projector_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40,
	# `return build.power.status;`): the power consumer's
	# efficiency is the building's live power.status, and the
	# first pass folds it into the min efficiency
	# (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`).
	# The graph update stamps
	# frame["power_status"] each tick (N2142); a missing stamp
	# folds to 1.0 before the first graph update, the assembler
	# fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`).
	# A block with no power consumer contributes no row. The
	# power consumer counts toward hasConsumers
	# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
	# so a regen projector does not take the early return. The
	# heal gate follows the folded efficiency
	# (RegenProjector.java:142, `if(efficiency > 0){`), with the heal amount
	# (RegenProjector.java:148, `float healAmount = Mathf.lerp(1f, optionalMultiplier, optionalEfficiency) * healPercent;`) and the regen-projector healPercent
	# (Blocks.java:2018, `healPercent = 4f / 60f;`) and the shouldConsume default
	# (BuildingComp.java:755, `public boolean shouldConsume(){`) and the anyTargets override
	# (RegenProjector.java:182, `return anyTargets;`) -- the shouldConsume gate is live
	# (N2214): the pure gate (source_regen_projector_should_consume_state) feeds
	# should_consume to the machinery from the frame any_targets key (false with no
	# damaged building in range, true while one is in range); the updateTile
	# advance (N2228) recomputes frame["any_targets"] every tick from the frame
	# targets input (the contains-damaged fold, RegenProjector.java:139), while
	# no live fill sets the targets list itself yet (the indexer range query,
	# RegenProjector.java:115-119, waits for its own slice).
	# Documented limits: (1) power-only first pass -- RegenProjector has
	# a liquid consumer (hydrogen 1f/60f, Blocks.java:2016) and an
	# optional item booster (phaseFabric, Blocks.java:2017) besides
	# power, so the folded efficiency is the min over the *modeled*
	# consumers (power only) with those rows deferred.
	# (2) shouldConsume gate live (N2214) -- RegenProjectorBuild overrides
	# shouldConsume() to return anyTargets (RegenProjector.java:181-183); the
	# pure gate reads the frame any_targets key (default false) and feeds
	# should_consume to the machinery; the updateTile advance (N2228)
	# recomputes frame["any_targets"] every tick from the frame targets input
	# (the contains-damaged fold, RegenProjector.java:139), while no live fill
	# sets the targets list itself yet (the indexer range query over buildings
	# in range 28, RegenProjector.java:115-119, waits for its own slice).
	# (3) Suppression gate -- checkSuppression() (RegenProjector.java:135;
	# suppressable=true, RegenProjector.java:49) is modeled as the frame input
	# `heal_suppressed` (default false, N2228): the advance returns early on a
	# suppressed tick, after the warmup/totalTime advance and the
	# didRegen/anyTargets reset, exactly like Java; the LIVE suppression fill
	# (isHealSuppressed, BuildingComp.java:487-489) still waits for its own
	# slice. (4) updateTile advance live (N2228) -- warmup / totalTime /
	# optionalTimer / didRegen / anyTargets / mendMap accumulation
	# (RegenProjector.java:122-179) advance on the frame; the updateTargets
	# live query, the optionalTimer consume(), the mendMap flush, the effect
	# chance and the disabled early return wait for their own slices (see the
	# N2228 live-fill deferral).
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_regen_projector_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float) -> Dictionary:
	# The updateTile advance (RegenProjectorBuild.updateTile(),
	# RegenProjector.java:122-179), the pure frame advance -- the
	# build fields are `public Seq<Building> targets = new Seq<>();`
	# (RegenProjector.java:109), `public int lastChange = -2;`
	# (RegenProjector.java:110), `public float warmup, totalTime, optionalTimer;`
	# (RegenProjector.java:111), `public boolean anyTargets = false;`
	# (RegenProjector.java:112) and `public boolean didRegen = false;`
	# (RegenProjector.java:113), and the advance follows the Java
	# lines in order (each exact expr on ONE comment line, the
	# N2148 lesson):
	# `if(lastChange != world.tileChanges){`
	# `lastChange = world.tileChanges;`
	# `warmup = Mathf.approachDelta(warmup, didRegen ? 1f : 0f, 1f / 70f);`
	# `totalTime += warmup * Time.delta;`
	# `didRegen = false;`
	# `anyTargets = false;`
	# `if(checkSuppression()){`
	# `anyTargets = targets.contains(b -> b.damaged());`
	# `if(efficiency > 0){`
	# `if((optionalTimer += edelta() * optionalEfficiency) >= optionalUseTime){`
	# `consume();`
	# `optionalTimer = 0f;`
	# `float healAmount = Mathf.lerp(1f, optionalMultiplier, optionalEfficiency) * healPercent;`
	# `for(var build : targets){`
	# `if(!build.damaged() || build.isHealSuppressed()) continue;`
	# `didRegen = true;`
	# `int pos = build.pos();`
	# `float value = mendMap.get(pos);`
	# `mendMap.put(pos, Math.min(Math.max(value, healAmount * edelta() * build.block.health / 100f), build.block.health - build.health));`
	# `if(value <= 0 && Mathf.chanceDelta(effectChance * build.block.size * build.block.size)){`
	# `if(lastUpdateFrame != state.updateId){`
	# `lastUpdateFrame = state.updateId;`
	# `build.heal(entry.value);`
	# `mendMap.clear();`
	# The Arc formulas, not guesses: approachDelta(from, to,
	# speed) = approach(from, to, Time.delta * speed) with
	# approach = from + clamp(to - from, -speed, speed), lerp =
	# from + (to - from) * progress, num(b) = b ? 1 : 0
	# (Mathf.java:208, 415-427), via the shared
	# source_math_state.source_approach_delta helper.
	# source_delta is Time.delta in ticks (seconds * 60 through
	# game_source_delta, arc Time.java:26); edelta() =
	# efficiency * delta() with delta() = Time.delta *
	# timeScale (BuildingComp.java:1922-1929). NOTE the two
	# deltas: totalTime uses the UNSCALED Time.delta
	# (RegenProjector.java:130), while the optionalTimer and
	# the mend amounts use the SCALED edelta(). efficiency and
	# optionalEfficiency default 0.0, the Java field defaults
	# (BuildingComp.java:85 `transient float efficiency;` /
	# :87 `transient float optionalEfficiency;`); warmup /
	# totalTime / optionalTimer default 0.0, didRegen /
	# anyTargets default false, targets [] and mend_map {}
	# (RegenProjector.java:109-113). The def values are driver
	# constants (single def -- regen-projector; the catalog
	# carries no healPercent): `healPercent = 4f / 60f;`
	# (Blocks.java:2019, the def override of the class
	# `public float healPercent = 12f / 60f;`,
	# RegenProjector.java:28), `public float optionalMultiplier = 2f;`
	# and `public float optionalUseTime = 60f * 8f;`
	# (RegenProjector.java:29-30, class values, no def
	# override). Scoping decisions, all source-backed: (1)
	# the live updateTargets query
	# (RegenProjector.java:115-119, `targets.clear();` +
	# `indexer.eachBlock(team, Tmp.r1.setCentered(x, y, range * tilesize), b -> true, targets::add);`)
	# has no helper in the port, so targets arrive as the frame
	# input (each entry: pos, block_health, health, damaged,
	# heal_suppressed); the lastChange refresh IS modeled,
	# with tile_changes as the frame input (default 1,
	# `public int tileChanges = 1, floorChanges = 1;`,
	# World.java:35) against lastChange -2, so the first tick
	# refreshes. (2) heal_suppressed is a frame input (default
	# false, the N2215 precedent):
	# checkSuppression() reads isHealSuppressed(),
	# `public boolean isHealSuppressed(){` with
	# `return block.suppressable && Time.time <= healSuppressionTime;`
	# (BuildingComp.java:487-489) plus a particle chance
	# (BuildingComp.java:1336-1346); the early return keeps its
	# Java position AFTER the warmup/totalTime advance and the
	# didRegen/anyTargets reset, so a suppressed tick still
	# advances warmup/totalTime but heals nothing and reads
	# any_targets false. (3) consume() DEFERS: it triggers
	# EVERY consumer (BuildingComp.java:1911-1915) and
	# ConsumeItems.trigger removes phaseFabric
	# (ConsumeItems.java:44-48), but the frame tracks no items
	# (the N2193 precedent); the optionalTimer advance +
	# reset IS modeled, and the tick where consume() would fire
	# is reported as the pure result `consumed`. (4) the
	# mendMap flush DEFERS whole (application + cadence):
	# `private static final IntFloatMap mendMap = new IntFloatMap();`
	# (RegenProjector.java:23) is static-shared across
	# projectors and the flush heals live buildings via
	# world.build(pos) (RegenProjector.java:168-177), which the
	# port has no frames for; the port tracks a per-building
	# mend_map instead (documented deviation -- in Java the
	# first projector ticked in a frame flushes every
	# projector's amounts). The accumulation uses Math.max (no
	# stacking) capped by the missing health, so an unflushed
	# map converges instead of diverging. (5) the effect chance
	# defers (no RNG in the pure advance). heal_amount is 0.0
	# when the heal branch does not run (suppressed or
	# efficiency <= 0). The function does NOT mutate its input
	# frame: the mend_map is copied before accumulating.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var optional_efficiency: float = float(frame.get("optional_efficiency", 0.0))
	var targets: Array = frame.get("targets", [])
	var mend_map: Dictionary = Dictionary(frame.get("mend_map", {}))
	var heal_suppressed: bool = bool(frame.get("heal_suppressed", false))
	var tile_changes: int = int(frame.get("tile_changes", 1))
	var last_change: int = int(frame.get("last_change", -2))
	if last_change != tile_changes:
		last_change = tile_changes
	var did_regen_previous: bool = bool(frame.get("did_regen", false))
	var warmup: float = source_math_state.source_approach_delta(float(frame.get("warmup", 0.0)), 1.0 if did_regen_previous else 0.0, SOURCE_REGEN_PROJECTOR_WARMUP_SPEED, source_delta)
	var total_time: float = float(frame.get("total_time", 0.0)) + warmup * source_delta
	var optional_timer: float = float(frame.get("optional_timer", 0.0))
	var did_regen: bool = false
	var any_targets: bool = false
	var heal_amount: float = 0.0
	var consumed: bool = false
	if heal_suppressed:
		return {"last_change": last_change, "warmup": warmup, "total_time": total_time, "optional_timer": optional_timer, "did_regen": false, "any_targets": false, "mend_map": mend_map, "heal_amount": 0.0, "consumed": false}
	for target in targets:
		if bool(target.get("damaged", false)):
			any_targets = true
			break
	if efficiency > 0.0:
		var edelta: float = efficiency * source_delta * time_scale
		optional_timer += edelta * optional_efficiency
		if optional_timer >= SOURCE_REGEN_PROJECTOR_OPTIONAL_USE_TIME:
			consumed = true
			optional_timer = 0.0
		heal_amount = lerpf(1.0, SOURCE_REGEN_PROJECTOR_OPTIONAL_MULTIPLIER, optional_efficiency) * SOURCE_REGEN_PROJECTOR_HEAL_PERCENT
		for target in targets:
			if not bool(target.get("damaged", false)) or bool(target.get("heal_suppressed", false)):
				continue
			did_regen = true
			var pos: int = int(target.get("pos", 0))
			var block_health: float = float(target.get("block_health", 0.0))
			var health: float = float(target.get("health", 0.0))
			var value: float = float(mend_map.get(pos, 0.0))
			mend_map[pos] = minf(maxf(value, heal_amount * edelta * block_health / 100.0), block_health - health)
	return {"last_change": last_change, "warmup": warmup, "total_time": total_time, "optional_timer": optional_timer, "did_regen": did_regen, "any_targets": any_targets, "mend_map": mend_map, "heal_amount": heal_amount, "consumed": consumed}

@warning_ignore("unused_parameter")
static func source_regen_projector_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the regen-projector tick wiring every
	# tick (RegenProjectorBuild.updateTile(), RegenProjector.java:123,
	# gates on the heal gate (RegenProjector.java:142,
	# `if(efficiency > 0){`) and the heal amount
	# (RegenProjector.java:148, `float healAmount = Mathf.lerp(1f, optionalMultiplier, optionalEfficiency) * healPercent;`), so the
	# heal gate follows the folded efficiency; no
	# placed-buildings driver ticks RegenProjector blocks, so this
	# driver is the placed-regen-projector tick): each placed
	# RegenProjector build gets its frame keys refreshed from the
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
		if not _is_regen_projector_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_regen_projector_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_regen_projector_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a regen projector with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the heal gate (RegenProjector.java:142)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449,
		# `hasConsumers = consumers.length > 0;`), so a regen
		# projector does not take the early return. A regen projector with
		# no power consumer is untouched: the tick models no other
		# consumers yet (the liquid hydrogen row and the phaseFabric
		# booster row wait for their own slices), and RegenProjectorBuild
		# overrides shouldConsume() to return anyTargets
		# (RegenProjector.java:181-183) -- N2214 feeds the live gate to the
		# machinery (the pure gate is
		# source_regen_projector_should_consume_state, fed the frame); the
		# N2160 RED decision is resolved. The gate has no enabled term
		# (Java returns the bare flag); the outer guard below already runs
		# the machinery only when enabled.
		# productionValid is the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_regen_projector_should_consume_state(frame)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_regen_projector_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# N2228: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277; noUpdateDisabled defaults
		# false, Block.java:170, so Java runs updateTile even
		# when disabled -- in Java a disabled regen projector's
		# warmup DECAYS toward 0 (efficiency is zeroed by the
		# disabled early return, BuildingComp.java:1954-1957)
		# and the mend amounts freeze (edelta() is 0). The port
		# keeps the enabled gate below as a pragmatic choice
		# (the N2195 coordinator-fix precedent): the driver
		# skips the consumption fold when disabled, so the frame
		# efficiency goes stale and running the advance on it
		# would charge warmup/mend from a stale efficiency.
		# The driver-wide disabled-early-return slice (deferred
		# in the N2228 register) removes this gate for all
		# families. super.updateTile() is an empty no-op
		# (BuildingComp.java:2010-2012), so the driver owes it
		# nothing. The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60
		# (arc Time.java:26), never raw seconds. timeScale
		# reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`). The advance
		# recomputes frame["any_targets"] from the frame targets
		# input every tick (the contains-damaged fold,
		# RegenProjector.java:139), so a live projector with no
		# targets fill reads any_targets false and does not
		# consume -- the N2228 live-fill deferral.
		if bool(frame.get("enabled", true)):
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var advanced: Dictionary = source_regen_projector_update_tile_advance_state(frame, source_delta, time_scale)
			frame["last_change"] = advanced["last_change"]
			frame["warmup"] = advanced["warmup"]
			frame["total_time"] = advanced["total_time"]
			frame["optional_timer"] = advanced["optional_timer"]
			frame["did_regen"] = advanced["did_regen"]
			frame["any_targets"] = advanced["any_targets"]
			frame["mend_map"] = advanced["mend_map"]
			frame["heal_amount"] = advanced["heal_amount"]
			frame["consumed"] = advanced["consumed"]
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
