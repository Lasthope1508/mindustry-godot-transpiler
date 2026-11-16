extends RefCounted
class_name SourceRepairTowerBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

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

# The def scan range (Blocks.java:6579, `range = 100f;`; the
# class default is `public float range = 80f;`,
# RepairTower.java:21; the catalog carries the same 100.0):
# the Units.nearby radius the live scan (N2306) filters the
# frame unit candidates by.
const SOURCE_REPAIR_TOWER_RANGE := 100.0

# The liquid consumer def constants (Blocks.java:6583,
# `consumeLiquid(Liquids.ozone, 3f / 60f);`): the consumed
# liquid is ozone and the amount is 3f/60f = 0.05 per frame
# (the catalog carries the same 0.05 in the consumeLiquid
# builder). The multiplier is the Consume default 1f
# (Consume.java:18, `public Floatf<Building> multiplier =
# b -> 1f;`) -- the def sets no multiplier.
const SOURCE_REPAIR_TOWER_LIQUID := "ozone"
const SOURCE_REPAIR_TOWER_LIQUID_AMOUNT := 3.0 / 60.0

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
	return {"targets": [], "liquids": {}}

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
	# RepairTowerBuild overrides shouldConsume (RepairTower.java:89, `public boolean shouldConsume(){` with `return targets.size > 0;`, RepairTower.java:90): the tower consumes only while at least one damaged unit is in range. The field is `public Seq<Unit> targets = new Seq<>();` (RepairTower.java:54) on RepairTowerBuild (`public class RepairTowerBuild extends Building implements Ranged{`, RepairTower.java:46); RepairTower extends Block (RepairTower.java:18, `public class RepairTower extends Block{`), so the default (`return enabled;`, BuildingComp.java:755-756) does NOT apply here. Unlike the Separator/Drill gates this one has NO `&& enabled` -- Java returns the bare size check, so the pure gate does NOT read frame["enabled"] at all (the driver already runs the machinery only when enabled). The frame carries the targets (frame["targets"], default [] for a frame bound before this slice -- the Java field initializer is `new Seq<>()`); the live scan fills it since N2306 -- the periodic refresh (RepairTower.java:59, `if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){` with `static final float refreshInterval = 6f;`, RepairTower.java:19, and `Units.nearby(team, x, y, range, damaged)`) is the updateTile advance (RepairTower.java:57-86, live since N2227: the cadence + clear run each tick with a supplied refill list, and the Units.nearby scan itself is live since N2306 -- source_repair_tower_supplied_damaged_state filters the frame unit candidates; the live unit query that would supply those candidates still waits for its own slice). When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The heal advance (RepairTower.java:78, `target.heal(healAmount * edelta());`) follows the folded efficiency. The def consumes power 1f (`consumePower(1f);`, Blocks.java:6582) plus liquid ozone 3f/60f (`consumeLiquid(Liquids.ozone, 3f / 60f);`, Blocks.java:6583) -- the liquid row is live since N2250 (source_repair_tower_liquid_consumer_row_state, ConsumeLiquid.efficiency, ConsumeLiquid.java:42-47).
	var targets: Variant = frame.get("targets", [])
	if not (targets is Array):
		targets = []
	return {"should_consume": targets.size() > 0, "target_count": targets.size()}

static func source_repair_tower_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a repair tower does not take the early return. The repair tower's power draw is STATIC, not conditional: `consumePower(1f);` (Blocks.java:6582) registers a plain ConsumePower, so the catalog consumePower 1.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The updateTile advance follows the folded efficiency: the heal advance (RepairTower.java:78, `target.heal(healAmount * edelta());`) heals by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a repair tower with no power would never heal. RepairTowerBuild overrides shouldConsume (RepairTower.java:89, `public boolean shouldConsume(){` with `return targets.size > 0;`, RepairTower.java:90); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The shouldConsume gate is live (N2213) -- the pure gate (source_repair_tower_should_consume_state) feeds should_consume to the machinery from the frame targets key (empty before any refresh, non-empty with damaged units in range); the live scan fills frame["targets"] since N2306 (the periodic refresh is the updateTile advance, RepairTower.java:57-86, live since N2227 with a supplied refill list; the Units.nearby scan pure filters the frame unit candidates). The repair tower is its own family (RepairTower.java:18, `public class RepairTower extends Block{`; RepairTowerBuild, RepairTower.java:46, `public class RepairTowerBuild extends Building implements Ranged{`). Class fields: `static final float refreshInterval = 6f;` (RepairTower.java:19), `public float range = 80f;` (RepairTower.java:21), `public float healAmount = 1f;` (RepairTower.java:24); constructor `update = true;` (RepairTower.java:29), `suppressable = true;` (RepairTower.java:31), `flags = EnumSet.of(BlockFlag.repair);` (RepairTower.java:32). The target refresh itself is gated on potentialEfficiency (RepairTower.java:59, `if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){`), and the warmup lerp (RepairTower.java:84, `warmup = Mathf.lerpDelta(warmup, any ? efficiency : 0f, 0.08f);`) follows efficiency. canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) are the surrounding gates. Single def -- unit-repair-tower only (size 2, range 100f, healAmount 1.5f, graphite 90 / silicon 90 / tungsten 80, Blocks.java:6575-6583). RepairTurret (repair-point / repair-turret) is a different class and NOT covered by this driver.
	# Documented limits: (1) power + liquid first pass -- the repair tower's static power consumer (consumePower 1f, Blocks.java:6582) and its ozone liquid consumer (consumeLiquid ozone 3f/60f = 0.05, Blocks.java:6583, `consumeLiquid(Liquids.ozone, 3f / 60f);`) are both modeled since N2250 (the liquid row is source_repair_tower_liquid_consumer_row_state, ConsumeLiquid.efficiency, ConsumeLiquid.java:42-47; the second-pass removal is ConsumeLiquid.update, ConsumeLiquid.java:37-39), so the folded efficiency is the min over both modeled consumers; no other consumer rows exist on this def. (2) shouldConsume gate live (N2213) -- RepairTowerBuild overrides shouldConsume (`return targets.size > 0;`, RepairTower.java:89-91); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the pure gate reads the frame targets key (default []) and feeds should_consume to the machinery; the live scan fills frame["targets"] since N2306 (the periodic refresh is the updateTile advance, RepairTower.java:57-86, live since N2227 with a supplied refill list; the Units.nearby scan pure filters the frame unit candidates). (3) updateTile advance live (N2227) -- target refresh cadence + clear / heal amounts / warmup lerp / totalProgress advance (RepairTower.java:57-86) advance each tick; Units.nearby scan live (N2306) -- the scan pure filters the frame unit candidates by the Java predicates (damaged + within range + hitSize/2) and the tick stamps the refill onto frame["supplied_damaged"], but the heal application to live units and the live unit-candidate query wait for their own slices (the advance returns heal amounts as a pure result, frame["heal_amounts"]). (4) Suppression branch live on a frame input (N2227) -- `suppressable = true` (RepairTower.java:31) and `checkSuppression()` zeroes warmup (RepairTower.java:69-72); the advance reads frame["heal_suppressed"] (default false, the N2215 precedent) but no live fill sets it yet (applyHealSuppression, BuildingComp.java:482-485, waits for its own slice). (5) Single def -- unit-repair-tower only (size 2, range 100f, healAmount 1.5f, graphite 90 / silicon 90 / tungsten 80); Per-def stat rows live (N2490) -- source_repair_tower_per_def_stats_state returns the def rows with the class defaults (size 1, range 80f, healAmount 1f, no requirements) for an unknown def id. (6) RepairTurret (repair-point / repair-turret) is a different class and NOT covered by this driver. (7) Draw rows live (N2428) -- the draw pure (source_repair_tower_draw_state) models draw() (RepairTower.java:94-110: super + the warmup-gated Layer.effect circle / Pal.heal square / additive glow at Layer.blockAdditive, Java-exact absin at the doubled scale) + drawSelect (:122-124) + drawPlace (:44-48, tile coords + offset), and the stats pure (source_repair_tower_stats_state) models setStats (:36-40, range / tilesize blocks + healAmount * 60 per second) + the range() / warmup() accessors. Pure-only: draw never runs in the tick.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_repair_tower_liquid_consumer_row_state(frame: Dictionary, has_liquid_consumer: bool, liquid_id: int, amount: float, source_delta: float, time_scale: float, efficiency_scale: float, multiplier := 1.0) -> Dictionary:
	# ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47, each
	# exact expr on ONE comment line, the N2148 lesson):
	# `float ed = build.edelta() * build.efficiencyScale();`
	# `if(ed <= 0.00000001f) return 0f;`
	# `return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);`
	# The first pass folds the row into the min efficiency
	# (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`).
	# In the first pass efficiency is assumed 1f
	# (BuildingComp.java:1964-1966), so edelta() is delta()
	# (`return efficiency * delta();`, BuildingComp.java:1927-1929, with efficiency 1f) and delta() is `return Time.delta * timeScale;` (BuildingComp.java:1922-1924) -- the source delta in ticks times the time scale. The liquid amount reads through the shared liquid module helper (SourceLiquidModuleState.source_get_state) with the Fracker guard (SourceFrackerBuildState.gd:279, `liquids.has("liquids")` + bounds check): a frame without a liquids store, or a liquid never added, reads 0.0, like Java's liquids.get. The multiplier is the Consume default 1f (Consume.java:18, `public Floatf<Building> multiplier = b -> 1f;`) -- the def sets no multiplier. The row is NOT power (`"is_power": false`), so a starved row also stops power draw: `if(cons != block.consPower && result <= 0.0000001f){` / `shouldConsumePower = false;` (BuildingComp.java:1972-1974, folded by the shared machinery). The second pass removes the consumed liquid (ConsumeLiquid.update, ConsumeLiquid.java:37-39, `build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));`) when `if(update && efficiency > 0){` (BuildingComp.java:1999-2003, `cons.update(self());`), with edelta from the FOLDED efficiency (`efficiency = minEfficiency;`, BuildingComp.java:1985; `potentialEfficiency = efficiency;`, BuildingComp.java:1989) -- the tick does that removal directly after apply_update_consumption_state, with `boolean update = shouldConsume() && productionValid();` (BuildingComp.java:1960) as the guard; the RuntimeConsumer actor pattern (SourceAdjacentFactoryBuildState.gd:368) does not fit a single static consumer with a constant multiplier. The def is the single unit-repair-tower (consumeLiquid ozone 3f/60f = 0.05, Blocks.java:6583, `consumeLiquid(Liquids.ozone, 3f / 60f);`, plus `consumePower(1f);`, Blocks.java:6582). The repair tower is its own family (RepairTower.java:18, `public class RepairTower extends Block{`; RepairTowerBuild, RepairTower.java:46, `public class RepairTowerBuild extends Building implements Ranged{`); the gate is `return targets.size > 0;` (RepairTower.java:90) and the heal advance is `target.heal(healAmount * edelta());` (RepairTower.java:78).
	if not has_liquid_consumer:
		return {"has_liquid_row": false, "row": {}}
	var liquids: Dictionary = frame.get("liquids", {})
	var liquid_amount := 0.0
	if liquids.has("liquids") and liquid_id >= 0 and liquid_id < int(liquids["liquids"].size()):
		liquid_amount = float(source_liquid_module_state.source_get_state(liquids, liquid_id).get("amount", 0.0))
	var edelta: float = source_delta * time_scale
	var ed: float = edelta * efficiency_scale
	if ed <= 0.00000001:
		return {"has_liquid_row": true, "row": {"result": 0.0, "is_power": false}}
	return {"has_liquid_row": true, "row": {"result": minf(liquid_amount / (amount * ed * multiplier), 1.0), "is_power": false}}

static func source_repair_tower_supplied_damaged_state(candidates: Array, range: float, tower_x := 0.0, tower_y := 0.0) -> Dictionary:
	# The live Units.nearby scan (RepairTower.java:62-66),
	# the pure filter the N2227 advance refills from: at
	# refresh (`if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){`
	# with `static final float refreshInterval = 6f;`,
	# RepairTower.java:19) Java clears (`targets.clear();`)
	# and refills from
	# `Units.nearby(team, x, y, range, u -> {`
	# `if(u.damaged()){`
	# `targets.add(u);`
	# (RepairTower.java:62-64). The range predicate is NOT
	# a plain distance <= range: Units.nearby
	# `public static void nearby(@Nullable Team team, float x, float y, float radius, Cons<Unit> cons){`
	# (Units.java:445-451) first intersects the team's unit
	# tree with the bounding square
	# `nearby(team, x - radius, y - radius, radius*2f, radius*2f, unit -> {`
	# and then admits only
	# `if(unit.within(x, y, radius + unit.hitSize/2f)){`
	# -- the unit's half hitSize extends the reach -- and
	# within is a STRICT squared-distance check
	# `return Mathf.dst2(getX(), getY(), x, y) < dst*dst;`
	# (Position.java:44-46), so a unit exactly at range +
	# hitSize/2 is OUT (the N2226 RepairTurret precedent).
	# Damaged is
	# `boolean damaged(){`
	# `return health < maxHealth - 0.001f;`
	# (HealthComp.java:47-49). The range is the class
	# default `public float range = 80f;`
	# (RepairTower.java:21), overridden by the def
	# `range = 100f;` (Blocks.java:6579).
	# Scoping decisions, all source-backed: (1) the
	# candidates are frame-supplied (frame["unit_candidates"],
	# the N2226 frame-key precedent) -- the port has no
	# live unit query, so no live Units.nearby over the
	# game world fills them yet; the team filter is the
	# caller's: Java visits the tower team's tree only
	# (Units.java:435-436), so the caller supplies
	# same-team candidates. (2) A candidate dict carries
	# health / max_health plus distance (the CENTER
	# distance from the tower -- NOT the RepairTurret
	# dst-minus-half-hitSize value, RepairTurret.java:193)
	# or x / y (world position, measured from the tower
	# position params); a missing health, max_health, or
	# distance-or-x/y key EXCLUDES the candidate (a
	# partial fixture never supplies a target), while a
	# missing hit_size reads as 0.0 (a point unit). A
	# non-Dictionary entry is excluded the same way.
	# (3) The checks run in Java order -- range first
	# (nearby visits in-range units), damaged second --
	# so a healthy out-of-range unit counts as
	# out-of-range, and the exclusion counts need not sum
	# to the candidate count: unscorable entries (missing
	# keys) are excluded without a bucket. (4) The
	# admitted entries are the candidate dicts themselves,
	# in candidate order, like Java's Seq<Unit> holding
	# the units -- the advance's heal loop reads their
	# `damaged` key when present (default true, the N2227
	# list-membership rule).
	var supplied_damaged: Array = []
	var healthy_excluded_count := 0
	var out_of_range_count := 0
	for candidate in candidates:
		if not (candidate is Dictionary):
			continue
		var distance2 := -1.0
		if candidate.has("distance"):
			var center_distance: float = float(candidate.get("distance", 0.0))
			distance2 = center_distance * center_distance
		elif candidate.has("x") and candidate.has("y"):
			var dx: float = float(candidate.get("x", 0.0)) - tower_x
			var dy: float = float(candidate.get("y", 0.0)) - tower_y
			distance2 = dx * dx + dy * dy
		if distance2 < 0.0:
			continue
		var hit_size: float = float(candidate.get("hit_size", 0.0))
		var reach: float = range + hit_size / 2.0
		if not (distance2 < reach * reach):
			out_of_range_count += 1
			continue
		if not candidate.has("health") or not candidate.has("max_health"):
			continue
		var health: float = float(candidate.get("health", 0.0))
		var max_health: float = float(candidate.get("max_health", 0.0))
		if not (health < max_health - 0.001):
			healthy_excluded_count += 1
			continue
		supplied_damaged.append(candidate)
	return {"supplied_damaged": supplied_damaged, "damaged_count": supplied_damaged.size(), "candidate_count": candidates.size(), "healthy_excluded_count": healthy_excluded_count, "out_of_range_count": out_of_range_count}

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
	# (BuildingComp.java:1989). (2) The live scan is live
	# since N2306 (source_repair_tower_supplied_damaged_state
	# filters the frame unit candidates by the Java
	# predicates): at refresh the targets clear and refill
	# from the supplied_damaged parameter -- the damaged
	# list the scan returns -- and the tick stamps it from
	# frame["supplied_damaged"]; the live unit query that
	# would supply the candidates still waits. (3)
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

static func source_repair_tower_draw_state(x_value: float, y_value: float, warmup: float, total_progress: float, range_value: float, time_value: float, circle_color: String, circle_stroke: float, square_rad: float, square_spin_scl: float, glow_color: String, glow_mag: float, glow_scl: float, offset: float, tile_x: int, tile_y: int) -> Dictionary:
	# The draw / drawSelect / drawPlace rows (RepairTowerBuild.draw(),
	# RepairTower.java:94-110; drawSelect(), :122-124;
	# RepairTower.drawPlace(), :44-48), the pure draw-call dict -- the
	# port never draws for real (the N2419 Separator precedent: the pure
	# returns the draw calls as data). Java draws, in order (each exact
	# expr on ONE comment line, the N2148 lesson):
	# `super.draw();`
	# `if(warmup <= 0.001f) return;`
	# `Draw.z(Layer.effect);`
	# `float mod = totalProgress % 1f;`
	# `Draw.color(circleColor);`
	# `Lines.stroke(circleStroke * (1f - mod) * warmup);`
	# `Lines.circle(x, y, range * mod);`
	# `Draw.color(Pal.heal);`
	# `Fill.square(x, y, squareRad * warmup, Time.time / squareSpinScl);`
	# `Draw.reset();`
	# `Drawf.additive(glow, glowColor, warmup * (1f - glowMag + Mathf.absin(Time.time, glowScl, glowMag)), x, y, 0f, Layer.blockAdditive);`
	# super.draw() runs BEFORE the warmup gate, so a cold tower still
	# draws its base (the super call is a marker -- the BuildingComp base
	# draw is the shared renderer concern, not a RepairTower row). Past
	# the gate everything draws at z Layer.effect (Layer.java:75) except
	# the glow, which is the additive call at Layer.blockAdditive
	# (Layer.java:36). mod is totalProgress % 1f: totalProgress never goes
	# negative (the N2227 advance only adds Time.delta / circleSpeed), so
	# GDScript fmod matches Java %. The square color is Pal.heal
	# (Pal.java:77). The glow region is the `@-glow` region
	# (RepairTower.java:25) through the 7-arg additive form
	# (Drawf.java:183). The absin is Java-exact through the shared helper
	# at the DOUBLED scale (the N2372/N2382 lesson): Java absin is
	# `return (sin(in, scl * 2f, mag) + mag) / 2f;` (arc Mathf.java:78-80)
	# while the helper is `(sin(value / scl) * 0.5 + 0.5) * mag` (SourceMathState.source_absin),
	# i.e. helper(v, s) == Java absin(v, s / 2f) -- so the pure passes
	# glowScl * 2f (16f at the class default) to land Java's absin
	# (Time.time, glowScl, glowMag) exactly. Layer / palette / Drawf /
	# tilesize exact exprs (each on ONE line, the N2148 lesson):
	# `effect = 110,`
	# `blockAdditive = 31,`
	# `heal = Color.valueOf("98ffa9"),`
	# `placing = accent,`
	# `public static void dashCircle(float x, float y, float rad, Color color){`
	# `public static void additive(TextureRegion region, Color color, float alpha, float x, float y, float rotation, float layer){`
	# `public static final int tilesize = 8;`
	# `public @Load("@-glow") TextureRegion glow;`
	# The class defaults are
	# `public Color circleColor = Pal.heal, glowColor = Pal.heal.cpy().a(0.5f);`
	# (RepairTower.java:22) and `public float circleSpeed = 120f, circleStroke = 3f, squareRad = 3f, squareSpinScl = 0.8f, glowMag = 0.5f, glowScl = 8f;`
	# (RepairTower.java:23); the def (unit-repair-tower,
	# Blocks.java:6575-6583) overrides only range (`range = 100f;`,
	# :6579; the class default is `public float range = 80f;`,
	# RepairTower.java:21) and healAmount -- every draw constant arrives
	# as an explicit caller-supplied input, so the pure stays
	# def-agnostic. Time.time is caller-supplied as time_value (the
	# N2356 precedent: draw never runs in the tick, so the tick never
	# stamps it).
	# drawSelect() is one line (RepairTower.java:122-124):
	# `Drawf.dashCircle(x, y, range, Pal.placing);`
	# at the building x/y, with NO warmup gate -- a cold tower still
	# selects. drawPlace() (RepairTower.java:44-48) is:
	# `super.drawPlace(x, y, rotation, valid);`
	# `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);`
	# at the TILE position: offset is the Block offset (`offset = ((size + 1) % 2) * tilesize / 2f;`,
	# Block.java:761 -- 4.0 for the size-2 def, `size = 2;`,
	# Blocks.java:6578) and tilesize is the Java constant 8.0 (Vars.java:135
	# -- NEVER the game tile_size 32, the N2375 lesson). The pure takes
	# tile_x / tile_y as explicit int inputs (the draw x/y are world
	# coords and cannot serve both). super.drawPlace is Block.drawPlace
	# (drawPotentialLinks + drawOverlay, the shared placement concern)
	# and is NOT modeled here (the N2372 MendProjector precedent).
	# Pal.placing is Pal.accent (Pal.java:95); dashCircle is the Drawf
	# helper (Drawf.java:398). The build fields are `public float warmup = 0f;`
	# and `public float totalProgress = 0f;` (RepairTower.java:52-53) on
	# RepairTowerBuild (`public class RepairTowerBuild extends Building implements Ranged{`,
	# RepairTower.java:46); RepairTower extends Block (`public class RepairTower extends Block{`,
	# RepairTower.java:18). Pure-only: draw never runs in the tick, and
	# the renderer call site that would call draw() on a placed repair
	# tower waits for a renderer slice.
	var tile_size: float = source_world_defaults.TILESIZE
	var warmup_gated: bool = warmup <= 0.001
	var mod_value: float = fmod(total_progress, 1.0)
	var circle_stroke_value: float = circle_stroke * (1.0 - mod_value) * warmup
	var circle_radius: float = range_value * mod_value
	var square_radius: float = square_rad * warmup
	var square_rotation: float = time_value / square_spin_scl
	var glow_absin: float = source_math_state.source_absin(time_value, glow_scl * 2.0, glow_mag)
	var glow_alpha: float = warmup * (1.0 - glow_mag + glow_absin)
	var place_x: float = float(tile_x) * tile_size + offset
	var place_y: float = float(tile_y) * tile_size + offset
	var super_call: Dictionary = {
		"call": "super.draw();",
		"x": x_value,
		"y": y_value,
	}
	var circle_call: Dictionary = {}
	var square_call: Dictionary = {}
	var glow_call: Dictionary = {}
	if not warmup_gated:
		circle_call = {
			"call": "Lines.circle(x, y, range * mod);",
			"x": x_value,
			"y": y_value,
			"radius": circle_radius,
			"stroke": circle_stroke_value,
			"color": circle_color,
			"layer": "Layer.effect",
			"mod": mod_value,
		}
		square_call = {
			"call": "Fill.square(x, y, squareRad * warmup, Time.time / squareSpinScl);",
			"x": x_value,
			"y": y_value,
			"radius": square_radius,
			"rotation": square_rotation,
			"color": "Pal.heal",
			"layer": "Layer.effect",
		}
		glow_call = {
			"call": "Drawf.additive(glow, glowColor, warmup * (1f - glowMag + Mathf.absin(Time.time, glowScl, glowMag)), x, y, 0f, Layer.blockAdditive);",
			"region": "glow",
			"color": glow_color,
			"alpha": glow_alpha,
			"x": x_value,
			"y": y_value,
			"rotation": 0.0,
			"layer": "Layer.blockAdditive",
			"absin": glow_absin,
		}
	var select_call: Dictionary = {
		"call": "Drawf.dashCircle(x, y, range, Pal.placing);",
		"x": x_value,
		"y": y_value,
		"radius": range_value,
		"color": "Pal.placing",
	}
	var place_call: Dictionary = {
		"call": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);",
		"x": place_x,
		"y": place_y,
		"radius": range_value,
		"color": "Pal.placing",
		"tile_x": tile_x,
		"tile_y": tile_y,
		"offset": offset,
	}
	return {
		"super_expr": "super.draw();",
		"gate_expr": "if(warmup <= 0.001f) return;",
		"z_expr": "Draw.z(Layer.effect);",
		"mod_expr": "float mod = totalProgress % 1f;",
		"circle_color_expr": "Draw.color(circleColor);",
		"stroke_expr": "Lines.stroke(circleStroke * (1f - mod) * warmup);",
		"circle_expr": "Lines.circle(x, y, range * mod);",
		"heal_color_expr": "Draw.color(Pal.heal);",
		"square_expr": "Fill.square(x, y, squareRad * warmup, Time.time / squareSpinScl);",
		"reset_expr": "Draw.reset();",
		"glow_expr": "Drawf.additive(glow, glowColor, warmup * (1f - glowMag + Mathf.absin(Time.time, glowScl, glowMag)), x, y, 0f, Layer.blockAdditive);",
		"select_expr": "Drawf.dashCircle(x, y, range, Pal.placing);",
		"place_super_expr": "super.drawPlace(x, y, rotation, valid);",
		"place_expr": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);",
		"x": x_value,
		"y": y_value,
		"warmup": warmup,
		"total_progress": total_progress,
		"range": range_value,
		"time_value": time_value,
		"circle_color": circle_color,
		"circle_stroke": circle_stroke,
		"square_rad": square_rad,
		"square_spin_scl": square_spin_scl,
		"glow_color": glow_color,
		"glow_mag": glow_mag,
		"glow_scl": glow_scl,
		"offset": offset,
		"tile_x": tile_x,
		"tile_y": tile_y,
		"warmup_gated": warmup_gated,
		"mod": mod_value,
		"circle_stroke_value": circle_stroke_value,
		"circle_radius": circle_radius,
		"square_radius": square_radius,
		"square_rotation": square_rotation,
		"glow_absin": glow_absin,
		"glow_alpha": glow_alpha,
		"place_x": place_x,
		"place_y": place_y,
		"super_call": super_call,
		"circle_call": circle_call,
		"square_call": square_call,
		"glow_call": glow_call,
		"select_call": select_call,
		"place_call": place_call,
	}

static func source_repair_tower_stats_state(range_value: float, heal_amount: float, warmup: float) -> Dictionary:
	# The setStats / range() / warmup() rows (RepairTower.setStats(),
	# RepairTower.java:36-40; RepairTowerBuild.range(), :112-114;
	# warmup(), :117-119), the pure stat-row dict. Java adds, in order
	# (each exact expr on ONE comment line, the N2148 lesson):
	# `stats.add(Stat.range, range / tilesize, StatUnit.blocks);`
	# `stats.add(Stat.repairSpeed, healAmount * 60f, StatUnit.perSecond);`
	# super.setStats() is the shared stats concern and is NOT modeled
	# here. tilesize is the Java constant 8.0 (Vars.java:135 -- NEVER the
	# game tile_size 32, the N2375 lesson), so the def range 100f (`range = 100f;`,
	# Blocks.java:6579; the class default is `public float range = 80f;`,
	# RepairTower.java:21) reads 12.5 blocks and the def healAmount 1.5f
	# (`healAmount = 1.5f;`, Blocks.java:6580; the class default is
	# `public float healAmount = 1f;`, RepairTower.java:24) reads 90 per
	# second. The accessors are the bare returns:
	# `return range;`
	# `return warmup;`
	# warmup is a caller-supplied input (the frame warmup the N2227
	# advance tracks, `public float warmup = 0f;`, RepairTower.java:52).
	# Pure-only: stats never run in the tick.
	var tile_size: float = source_world_defaults.TILESIZE
	var range_blocks_value: float = range_value / tile_size
	var repair_per_second_value: float = heal_amount * 60.0
	var range_blocks: Dictionary = {
		"stat": "Stat.range",
		"value": range_blocks_value,
		"unit": "StatUnit.blocks",
	}
	var repair_per_second: Dictionary = {
		"stat": "Stat.repairSpeed",
		"value": repair_per_second_value,
		"unit": "StatUnit.perSecond",
	}
	return {
		"range_stat_expr": "stats.add(Stat.range, range / tilesize, StatUnit.blocks);",
		"repair_stat_expr": "stats.add(Stat.repairSpeed, healAmount * 60f, StatUnit.perSecond);",
		"range_expr": "return range;",
		"warmup_expr": "return warmup;",
		"range": range_value,
		"heal_amount": heal_amount,
		"warmup": warmup,
		"range_blocks": range_blocks,
		"repair_per_second": repair_per_second,
		"range_value": range_value,
		"warmup_value": warmup,
	}

static func source_repair_tower_per_def_stats_state(def_id: String) -> Dictionary:
	# The per-def stat rows (the VERIFICATION slice: the values
	# are already constants in this driver's header -- the
	# N2304 / N2442 precedent): the def's size / range /
	# healAmount / requirements for unit-repair-tower, the
	# single RepairTower def (Blocks.java:6575-6583), with the
	# CLASS defaults for an unknown def id (the N2304 fallback
	# precedent). The def block (each exact expr on ONE comment
	# line, the N2148 lesson):
	# `unitRepairTower = new RepairTower("unit-repair-tower"){{`
	# `requirements(Category.units, with(Items.graphite, 90, Items.silicon, 90, Items.tungsten, 80));`
	# `size = 2;`
	# `range = 100f;`
	# `healAmount = 1.5f;`
	# The class defaults (RepairTower.java:21/24, Block.java:215/356):
	# `public float range = 80f;`
	# `public float healAmount = 1f;`
	# `public int size = 1;`
	# `public ItemStack[] requirements = {};`
	# RepairTower extends Block (`public class RepairTower extends Block{`,
	# RepairTower.java:18). The requirements dict is the
	# {item: amount} dict from the def (the
	# SourceAcceleratorBuildState capacities precedent:
	# {"copper": 8000, "lead": 8000, "silicon": 5000,
	# "thorium": 4000}); the catalog carries the same rows as
	# an Array of {item, amount} dicts
	# (content_registry.json, unit-repair-tower). An unknown
	# def id falls back to the CLASS defaults -- size 1, range
	# 80f, healAmount 1f, and NO requirements (the Block
	# default is the empty array). Pure-only: the caller reads
	# it; the advance + shouldConsume pures take these values
	# as caller-supplied inputs and are unchanged.
	if def_id == "unit-repair-tower":
		return {
			"size": 2,
			"range_value": 100.0,
			"heal_amount": 1.5,
			"requirements": {"graphite": 90, "silicon": 90, "tungsten": 80},
		}
	return {
		"size": 1,
		"range_value": 80.0,
		"heal_amount": 1.0,
		"requirements": {},
	}

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
	var liquid_id_by_name: Dictionary = source_content_registry_runtime_state.source_liquid_catalog_state(catalog).get("liquid_id_by_name", {})
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
		# The frame carries the Building.liquids LiquidModule
		# (frame["liquids"]): the live store lives on the
		# sprite meta (source_building_liquids, initialized
		# at placement), so the driver syncs the reference
		# into the frame each tick BEFORE the fold and the
		# pure liquid row reads the ozone amount from it
		# (the Fracker:327 precedent).
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# Time.delta in ticks from the placed-block helper;
		# timeScale live from the sprite meta (default 1f,
		# BuildingComp.java:98). Both are needed BEFORE the
		# fold (the liquid row's edelta is source_delta *
		# time_scale with efficiency assumed 1f) and again
		# by the updateTile advance below, so they are read
		# once here.
		var time_delta: float = source_placed_block_state.game_source_delta(game, seconds)
		var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a repair tower with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the heal advance (RepairTower.java:78, `target.heal(healAmount * edelta());`)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a repair tower does not take the early return. The repair tower's power draw is STATIC: `consumePower(1f);` (Blocks.java:6582) registers a plain ConsumePower, so the catalog consumePower 1.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. A repair tower with no power consumer folds no consumption rows, though the updateTile advance below still runs for it. The liquid consumer reads live since N2250: a repair tower with a liquid consumer folds the pure ozone row into the first pass beside the power row (`consumeLiquid(Liquids.ozone, 3f / 60f);`, Blocks.java:6583), so ConsumeLiquid.efficiency folds into the min efficiency like every other non-optional consumer, and the second pass removes the consumed ozone after the fold. RepairTowerBuild overrides shouldConsume (RepairTower.java:89, `public boolean shouldConsume(){` with `return targets.size > 0;`, RepairTower.java:90) -- N2213 feeds the live gate to the machinery (the pure gate is source_repair_tower_should_consume_state, fed the frame); the N2176 RED decision is resolved. The gate has no enabled term (Java returns the bare size check); the outer guard below already runs the machinery only when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
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
			# The ozone liquid consumer (consumeLiquid ozone
			# 3f/60f = 0.05, Blocks.java:6583) folds beside
			# the power row: the pure row reads the live
			# ozone amount from the synced frame store, with
			# edelta = source_delta * time_scale (efficiency
			# assumed 1f in the first pass) and the Consume
			# default multiplier 1f (Consume.java:18 -- the
			# def sets no multiplier).
			var has_liquid_consumer: bool = bool(block.properties.has("consumeLiquid"))
			var liquid_id: int = int(liquid_id_by_name.get(SOURCE_REPAIR_TOWER_LIQUID, -1))
			var liquid_multiplier := 1.0
			var liquid_row: Dictionary = source_repair_tower_liquid_consumer_row_state(frame, has_liquid_consumer, liquid_id, SOURCE_REPAIR_TOWER_LIQUID_AMOUNT, time_delta, time_scale, float(frame.get("efficiency_scale", 1.0)), liquid_multiplier)
			if bool(liquid_row.get("has_liquid_row", false)):
				required_results.append(liquid_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# Second pass (BuildingComp.java:1999-2003,
			# `if(update && efficiency > 0){`): ConsumeLiquid.
			# update removes `amount * edelta() * multiplier`
			# (ConsumeLiquid.java:37-39) with edelta from the
			# FOLDED efficiency -- NOT the 1f assumed in the
			# first pass. Direct removal after the fold (the
			# RuntimeConsumer actor pattern,
			# SourceAdjacentFactoryBuildState.gd:368, needs
			# per-frame actor binding for a single static
			# consumer with a constant multiplier); the
			# shared module helper clamps at zero and the
			# cache_sums follow the SolidPump precedent
			# (empty when the store has no flow).
			if has_liquid_consumer and bool(setup.get("update", false)) and float(frame.get("efficiency", 0.0)) > 0.0:
				var folded_edelta: float = float(frame.get("efficiency", 0.0)) * time_delta * time_scale
				var remove_amount: float = SOURCE_REPAIR_TOWER_LIQUID_AMOUNT * folded_edelta * liquid_multiplier
				var liquids_store: Dictionary = frame.get("liquids", {})
				if liquid_id >= 0 and liquids_store.has("liquids") and liquid_id < int(liquids_store["liquids"].size()):
					var cache_sums: Array = []
					if liquids_store.get("flow") != null:
						cache_sums.resize(int(liquids_store["liquids"].size()))
						cache_sums.fill(0.0)
					source_liquid_module_state.source_remove_state(liquids_store, liquid_id, remove_amount, cache_sums)
		# The updateTile advance runs for every ticked repair
		# tower, inside or outside the consumption gate:
		# updateTile runs even when disabled
		# (BuildingComp.java:2276, `if(enabled ||
		# !block.noUpdateDisabled){` with noUpdateDisabled
		# false, Block.java:170), and updateConsumption runs
		# first (BuildingComp.java:2274), so the advance
		# follows the frame efficiency / potentialEfficiency
		# the machinery last folded. Time.delta in ticks and
		# timeScale were read above (before the fold, for
		# the liquid row); the def heal amount 1.5f
		# (Blocks.java:6580) and the class circle speed 120f
		# (RepairTower.java:23). The refill is the live scan
		# (N2306): the frame unit candidates (frame["unit_
		# candidates"], default [] -- no candidates, the Java
		# no-units-in-range outcome) are filtered by the scan
		# pure at the def range from the live tower position
		# (origin cell + block offset, the N2226/N2280
		# RepairTurret precedent: Building x/y are
		# tile.drawx()/drawy(), BuildingComp.java:124), the
		# result is stamped onto frame["supplied_damaged"],
		# and the advance reads that frame key (the N2226
		# frame-fallback precedent: the frame key feeds the
		# param; an explicit param still wins when the
		# advance is called directly). The scan runs on every
		# ticked tower, inside or outside the consumption
		# gate, like the advance itself -- the advance only
		# consumes the refill at refresh (RepairTower.java:59),
		# so stamping it every tick is inert between refreshes.
		var scan_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		var scan_block_size: int = int(block.properties.get("size", 1))
		var scan_block_offset: float = float((scan_block_size + 1) % 2) * source_world_defaults.TILESIZE / 2.0
		var scan_building_x: float = source_block_geometry.tile_drawx_state(scan_cell.x, source_world_defaults.TILESIZE, scan_block_offset)
		var scan_building_y: float = source_block_geometry.tile_drawy_state(scan_cell.y, source_world_defaults.TILESIZE, scan_block_offset)
		var scan_candidates: Array = []
		var frame_unit_candidates: Variant = frame.get("unit_candidates", [])
		if frame_unit_candidates is Array:
			scan_candidates = frame_unit_candidates
		var scan: Dictionary = source_repair_tower_supplied_damaged_state(scan_candidates, SOURCE_REPAIR_TOWER_RANGE, scan_building_x, scan_building_y)
		frame["supplied_damaged"] = scan.get("supplied_damaged", [])
		var supplied_damaged: Variant = frame.get("supplied_damaged", [])
		source_repair_tower_update_tile_advance_state(frame, SOURCE_REPAIR_TOWER_HEAL_AMOUNT, SOURCE_REPAIR_TOWER_CIRCLE_SPEED, time_delta, time_scale, supplied_damaged)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
