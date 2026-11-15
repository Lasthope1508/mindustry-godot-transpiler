extends RefCounted
class_name SourceRepairTowerBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

# The RepairTower implementation (RepairTower.java:18, `public class RepairTower extends Block{`): unit-repair-tower (consumePower 1f, Blocks.java:6582, `consumePower(1f);`; consumeLiquid ozone 3f/60f, Blocks.java:6583, `consumeLiquid(Liquids.ozone, 3f / 60f);`; size 2, range 100f, healAmount 1.5f, graphite 90 / silicon 90 / tungsten 80, Blocks.java:6575-6583). RepairTower extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_repair_tower_building", the radar precedent), and this slice adds the repair-tower key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceRepairTower* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile heal advance (RepairTower.java:78, `target.heal(healAmount * edelta());`) heals by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a repair tower with no power would never heal -- its targets' health would sit frozen as if power.status were 1.0.
const SOURCE_REPAIR_TOWER_BUILD_IMPLEMENTATIONS := ["RepairTower"]
const SOURCE_REPAIR_TOWER_BUILDING_META_KEY := "source_repair_tower_building"

# The updateTile advance constants (RepairTower.java:19/23/84,
# Blocks.java:6580): the refresh interval is `static final float
# refreshInterval = 6f;` (RepairTower.java:19); the warmup lerp
# progress is 0.08f (RepairTower.java:84, `warmup =
# Mathf.lerpDelta(warmup, any ? efficiency : 0f, 0.08f);`); the
# circle speed is 120f (RepairTower.java:23); the def heal amount
# is `healAmount = 1.5f;` (Blocks.java:6580; the class default is
# `public float healAmount = 1f;`, RepairTower.java:24).
const SOURCE_REPAIR_TOWER_REFRESH_INTERVAL := 6.0
const SOURCE_REPAIR_TOWER_WARMUP_LERP_PROGRESS := 0.08
const SOURCE_REPAIR_TOWER_CIRCLE_SPEED := 120.0
const SOURCE_REPAIR_TOWER_HEAL_AMOUNT := 1.5

static func _is_repair_tower_build_implementation(implementation: String) -> bool:
	return SOURCE_REPAIR_TOWER_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_repair_tower_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The repair-tower tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (RepairTower.java:18, `public class RepairTower extends Block{`; RepairTowerBuild, RepairTower.java:46, `public class RepairTowerBuild extends Building implements Ranged{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# repair tower skips consumption like Java's updateConsumption
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
	# for this repair tower (N2125); the tick preserves a disabled
	# repair tower instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {"targets": []}

static func source_repair_tower_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the repair-tower frame meta key
	# ("source_repair_tower_building"). A RepairTower sprite gets a
	# frame bound with the targets key defaulting to the empty list
	# (the Java field `public Seq<Unit> targets = new Seq<>();`,
	# RepairTower.java:54, initializes to `new Seq<>()`); the
	# live-loop tick fills its other keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_repair_tower_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_REPAIR_TOWER_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_REPAIR_TOWER_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_REPAIR_TOWER_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_repair_tower_should_consume_state(frame: Dictionary) -> Dictionary:
	# RepairTowerBuild overrides shouldConsume (RepairTower.java:89, `public boolean shouldConsume(){` with `return targets.size > 0;`, RepairTower.java:90): the tower consumes only while at least one damaged unit is in range. The field is `public Seq<Unit> targets = new Seq<>();` (RepairTower.java:54) on RepairTowerBuild (`public class RepairTowerBuild extends Building implements Ranged{`, RepairTower.java:46); RepairTower extends Block (RepairTower.java:18, `public class RepairTower extends Block{`), so the default (`return enabled;`, BuildingComp.java:755-756) does NOT apply here. Unlike the Separator/Drill gates this one has NO `&& enabled` -- Java returns the bare size check, so the pure gate does NOT read frame["enabled"] at all (the driver already runs the machinery only when enabled). The frame carries the targets (frame["targets"], default [] for a frame bound before this slice -- the Java field initializer is `new Seq<>()`); no live scan fills it yet -- the periodic refresh (RepairTower.java:59, `if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){` with `static final float refreshInterval = 6f;`, RepairTower.java:19, and `Units.nearby(team, x, y, range, damaged)`) is the updateTile advance (RepairTower.java:57-86, live since N2227: the cadence + clear run each tick with a supplied refill list, the Units.nearby scan itself still waits for its own slice). When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The heal advance (RepairTower.java:78, `target.heal(healAmount * edelta());`) follows the folded efficiency. The def consumes power 1f (`consumePower(1f);`, Blocks.java:6582) plus liquid ozone 3f/60f (`consumeLiquid(Liquids.ozone, 3f / 60f);`, Blocks.java:6583) -- the liquid row waits for its own slice.
	var targets: Variant = frame.get("targets", [])
	if not (targets is Array):
		targets = []
	return {"should_consume": targets.size() > 0, "target_count": targets.size()}

static func source_repair_tower_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a repair tower does not take the early return. The repair tower's power draw is STATIC, not conditional: `consumePower(1f);` (Blocks.java:6582) registers a plain ConsumePower, so the catalog consumePower 1.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The updateTile advance follows the folded efficiency: the heal advance (RepairTower.java:78, `target.heal(healAmount * edelta());`) heals by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a repair tower with no power would never heal. RepairTowerBuild overrides shouldConsume (RepairTower.java:89, `public boolean shouldConsume(){` with `return targets.size > 0;`, RepairTower.java:90); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The shouldConsume gate is live (N2213) -- the pure gate (source_repair_tower_should_consume_state) feeds should_consume to the machinery from the frame targets key (empty before any refresh, non-empty with damaged units in range); no live scan fills frame["targets"] yet (the periodic refresh is the updateTile advance, RepairTower.java:57-86, live since N2227 with a supplied refill list; the Units.nearby scan still waits). The repair tower is its own family (RepairTower.java:18, `public class RepairTower extends Block{`; RepairTowerBuild, RepairTower.java:46, `public class RepairTowerBuild extends Building implements Ranged{`). Class fields: `static final float refreshInterval = 6f;` (RepairTower.java:19), `public float range = 80f;` (RepairTower.java:21), `public float healAmount = 1f;` (RepairTower.java:24); constructor `update = true;` (RepairTower.java:29), `suppressable = true;` (RepairTower.java:31), `flags = EnumSet.of(BlockFlag.repair);` (RepairTower.java:32). The target refresh itself is gated on potentialEfficiency (RepairTower.java:59, `if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){`), and the warmup lerp (RepairTower.java:84, `warmup = Mathf.lerpDelta(warmup, any ? efficiency : 0f, 0.08f);`) follows efficiency. canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) are the surrounding gates. Single def -- unit-repair-tower only (size 2, range 100f, healAmount 1.5f, graphite 90 / silicon 90 / tungsten 80, Blocks.java:6575-6583). RepairTurret (repair-point / repair-turret) is a different class and NOT covered by this driver.
	# Documented limits: (1) power-only first pass -- the repair tower's static power consumer (consumePower 1f, Blocks.java:6582) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); the ozone liquid consumer (consumeLiquid ozone 3f/60f = 0.05, Blocks.java:6583, `consumeLiquid(Liquids.ozone, 3f / 60f);`) waits for its own slice (the N2174 coolant precedent). (2) shouldConsume gate live (N2213) -- RepairTowerBuild overrides shouldConsume (`return targets.size > 0;`, RepairTower.java:89-91); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the pure gate reads the frame targets key (default []) and feeds should_consume to the machinery; no live scan fills frame["targets"] yet (the periodic refresh is the updateTile advance, RepairTower.java:57-86, live since N2227 with a supplied refill list). (3) updateTile advance live (N2227) -- target refresh cadence + clear / heal amounts / warmup lerp / totalProgress advance (RepairTower.java:57-86) advance each tick; the live Units.nearby scan and the heal application to live units wait for their own slices (the advance returns heal amounts as a pure result, frame["heal_amounts"]). (4) Suppression branch live on a frame input (N2227) -- `suppressable = true` (RepairTower.java:31) and `checkSuppression()` zeroes warmup (RepairTower.java:69-72); the advance reads frame["heal_suppressed"] (default false, the N2215 precedent) but no live fill sets it yet (applyHealSuppression, BuildingComp.java:482-485, waits for its own slice). (5) Single def -- unit-repair-tower only (size 2, range 100f, healAmount 1.5f, graphite 90 / silicon 90 / tungsten 80); per-def stat values wait for their own verification slice. (6) RepairTurret (repair-point / repair-turret) is a different class and NOT covered by this driver.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_repair_tower_update_tile_advance_state(frame: Dictionary, heal_amount: float, circle_speed: float, time_delta: float, time_scale := 1.0, supplied_damaged := []) -> Dictionary:
	# RepairTowerBuild.updateTile() (RepairTower.java:57-86), the
	# pure frame advance -- the build fields are
	# `public float refresh = Mathf.random(refreshInterval);`
	# `public float warmup = 0f;`
	# `public float totalProgress = 0f;`
	# `public Seq<Unit> targets = new Seq<>();`
	# (RepairTower.java:51-54), and the advance follows the Java
	# lines in order (each exact expr on ONE comment line, the
	# N2148 lesson):
	# `if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){`
	# `targets.clear();`
	# `refresh = 0f;`
	# `Units.nearby(team, x, y, range, u -> {`
	# `if(u.damaged()){`
	# `targets.add(u);`
	# `if(checkSuppression()){`
	# `warmup = 0f;`
	# `boolean any = false;`
	# `if(efficiency > 0){`
	# `for(var target : targets){`
	# `if(target.damaged()){`
	# `target.heal(healAmount * edelta());`
	# `any = true;`
	# `warmup = Mathf.lerpDelta(warmup, any ? efficiency : 0f, 0.08f);`
	# `totalProgress += Time.delta / circleSpeed;`
	# The constants: `static final float refreshInterval = 6f;`
	# (RepairTower.java:19), `public float circleSpeed = 120f, circleStroke = 3f, squareRad = 3f, squareSpinScl = 0.8f, glowMag = 0.5f, glowScl = 8f;`
	# (RepairTower.java:23), the class `public float healAmount = 1f;`
	# (RepairTower.java:24) overridden by the def
	# `healAmount = 1.5f;` (Blocks.java:6580), `range = 100f;`
	# (Blocks.java:6579). The lerp formula comes from Arc, not
	# from a guess: lerpDelta is `return lerp(fromValue, toValue, clamp(progress * Time.delta));` (Mathf.java:430-432),
	# so the warmup lerp uses the UNSCALED Time.delta
	# (source_math_state.source_lerp_delta), while the heal
	# amount uses the SCALED edelta():
	# `return efficiency * delta();` (BuildingComp.java:1927-1929)
	# with `return Time.delta * timeScale;` (BuildingComp.java:1922-1924).
	# The refresh / totalProgress advances use the UNSCALED
	# Time.delta straight from the Java lines.
	# Scoping decisions, all source-backed: (1) the refresh
	# advance short-circuits on potentialEfficiency -- the
	# `&&` in RepairTower.java:59 means refresh only advances
	# while potentialEfficiency > 0. frame["potential_efficiency"]
	# is folded onto the frame by the shared machinery
	# (apply_update_consumption_state) and defaults to the
	# folded efficiency: `potentialEfficiency = efficiency;`
	# (BuildingComp.java:1989). (2) The live scan is deferred
	# (no live unit query in the driver): at refresh the
	# targets clear and refill from the supplied_damaged
	# parameter -- the damaged list the scan would return --
	# and the tick supplies the frame's current targets. (3)
	# Suppression reads frame["heal_suppressed"] (default
	# false, the N2215 BuildTurret precedent mirroring
	# isHealSuppressed(): `return block.suppressable && Time.time <= healSuppressionTime;`
	# (BuildingComp.java:487-489); `public boolean checkSuppression(){`
	# (BuildingComp.java:1336)); no live fill sets it yet. The
	# suppressed branch runs AFTER the refresh block in Java
	# order, so a refresh still clears + refills before the
	# early return, while totalProgress does not advance on
	# the suppressed tick. (4) The heal APPLICATION is
	# deferred: the advance writes frame["heal_amounts"], one
	# healAmount * edelta() amount per damaged target in
	# target order, instead of writing into another frame. A
	# target entry without a `damaged` key counts as damaged
	# -- the refresh scan only admits damaged units
	# (`if(u.damaged()){ targets.add(u); }`,
	# RepairTower.java:63-64), so list membership implies
	# damaged until a later state update says otherwise; the
	# N2213 proof's minimal `{"type": "dart"}` fixtures
	# therefore heal. (5) refresh binds 0.0 deterministically
	# instead of the Java random init (documented deviation:
	# the random stagger only desynchronizes first-refresh
	# timing across towers); the N2222 created-seed precedent
	# does NOT apply -- the Separator seed derives from
	# tile.pos() (Separator.java:82-84), while the tower
	# refresh is a plain global random with no
	# position-derived seed.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var potential_efficiency: float = float(frame.get("potential_efficiency", efficiency))
	var refresh: float = float(frame.get("refresh", 0.0))
	var warmup: float = float(frame.get("warmup", 0.0))
	var total_progress: float = float(frame.get("total_progress", 0.0))
	var targets: Variant = frame.get("targets", [])
	if not (targets is Array):
		targets = []
	var heal_amounts: Array = []
	if potential_efficiency > 0.0:
		refresh += time_delta
		if refresh >= SOURCE_REPAIR_TOWER_REFRESH_INTERVAL:
			targets = supplied_damaged.duplicate() if supplied_damaged is Array else []
			refresh = 0.0
	frame["refresh"] = refresh
	frame["targets"] = targets
	if bool(frame.get("heal_suppressed", false)):
		frame["warmup"] = 0.0
		frame["heal_amounts"] = heal_amounts
		return frame
	var any_healed := false
	if efficiency > 0.0:
		var edelta: float = efficiency * time_delta * time_scale
		for target in targets:
			var damaged := true
			if target is Dictionary:
				damaged = bool(target.get("damaged", true))
			if damaged:
				heal_amounts.append(heal_amount * edelta)
				any_healed = true
	warmup = source_math_state.source_lerp_delta(warmup, efficiency if any_healed else 0.0, SOURCE_REPAIR_TOWER_WARMUP_LERP_PROGRESS, time_delta)
	total_progress += time_delta / circle_speed
	frame["warmup"] = warmup
	frame["total_progress"] = total_progress
	frame["heal_amounts"] = heal_amounts
	return frame

@warning_ignore("unused_parameter")
static func source_repair_tower_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the repair-tower tick wiring every
	# tick (RepairTowerBuild.updateTile(), RepairTower.java:57,
	# advances the heal by the heal advance (RepairTower.java:78, `target.heal(healAmount * edelta());`), so the heal advance follows the folded efficiency; no placed-buildings driver ticks RepairTower blocks, so this driver is the placed-repair-tower tick): each placed RepairTower build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_repair_tower_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_repair_tower_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_repair_tower_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a repair tower with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the heal advance (RepairTower.java:78, `target.heal(healAmount * edelta());`)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a repair tower does not take the early return. The repair tower's power draw is STATIC: `consumePower(1f);` (Blocks.java:6582) registers a plain ConsumePower, so the catalog consumePower 1.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. A repair tower with no power consumer folds no consumption rows: the tick models no other consumers yet (the ozone liquid consumer still waits for its own slice), though the updateTile advance below still runs for it. RepairTowerBuild overrides shouldConsume (RepairTower.java:89, `public boolean shouldConsume(){` with `return targets.size > 0;`, RepairTower.java:90) -- N2213 feeds the live gate to the machinery (the pure gate is source_repair_tower_should_consume_state, fed the frame); the N2176 RED decision is resolved. The gate has no enabled term (Java returns the bare size check); the outer guard below already runs the machinery only when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_repair_tower_should_consume_state(frame)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_repair_tower_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# The updateTile advance runs for every ticked repair
		# tower, inside or outside the consumption gate:
		# updateTile runs even when disabled
		# (BuildingComp.java:2276, `if(enabled ||
		# !block.noUpdateDisabled){` with noUpdateDisabled
		# false, Block.java:170), and updateConsumption runs
		# first (BuildingComp.java:2274), so the advance
		# follows the frame efficiency / potentialEfficiency
		# the machinery last folded. Time.delta in ticks from
		# the placed-block helper; timeScale live from the
		# sprite meta (default 1f, BuildingComp.java:98); the
		# def heal amount 1.5f (Blocks.java:6580) and the
		# class circle speed 120f (RepairTower.java:23); the
		# refill is the frame's current targets -- no live
		# Units.nearby scan fills them yet (the N2227
		# deferral), so a refresh clears and refills with the
		# targets the tower already knows.
		var time_delta: float = source_placed_block_state.game_source_delta(game, seconds)
		var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
		var supplied_damaged: Variant = frame.get("targets", [])
		source_repair_tower_update_tile_advance_state(frame, SOURCE_REPAIR_TOWER_HEAL_AMOUNT, SOURCE_REPAIR_TOWER_CIRCLE_SPEED, time_delta, time_scale, supplied_damaged)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
