extends RefCounted
class_name SourceShockwaveTowerBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The ShockwaveTower implementation (ShockwaveTower.java:22, `public class ShockwaveTower extends Block{`): shockwave-tower (consumePower 100f / 60f, Blocks.java:2042, `consumePower(100f / 60f);`; consumeLiquids cyanogen 1.5f / 60f, Blocks.java:2041, `consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));`; size 3, range 170f, reload 80f, surge-alloy 50 / silicon 150 / oxide 30 / tungsten 100, Blocks.java:2038-2044). ShockwaveTower extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_shockwave_tower_building", the radar precedent), and this slice adds the shockwave-tower key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceShockwaveTower* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile fire gate (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`) charges its reload counter by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a shockwave tower with no power would never charge and never fire its wave -- its reload counter would sit frozen as if power.status were 1.0.
const SOURCE_SHOCKWAVE_TOWER_BUILD_IMPLEMENTATIONS := ["ShockwaveTower"]
const SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY := "source_shockwave_tower_building"
# Class values (ShockwaveTower.java) with no def override:
# `public float bulletDamage = 160;` (:27), `public float
# falloffCount = 20f;` (:28), `public float cooldownMultiplier =
# 1f;` (:34) and `public float checkInterval = 8f;` (:31, the
# check cadence, live since N2318 -- the frame-local
# Interval-equivalent, source_shockwave_tower_timer_check_state).
# reload and range DO have
# def overrides (`reload = 80f;` / `range = 170f;`,
# Blocks.java:2043-2044 over the class `public float reload =
# 60f * 1.5f;` / `public float range = 110f;`), so the tick
# reads reload from the catalog block like the N2187 gate.
const SOURCE_SHOCKWAVE_TOWER_BULLET_DAMAGE := 160.0
const SOURCE_SHOCKWAVE_TOWER_FALLOFF_COUNT := 20.0
const SOURCE_SHOCKWAVE_TOWER_COOLDOWN_MULTIPLIER := 1.0
const SOURCE_SHOCKWAVE_TOWER_CHECK_INTERVAL := 8.0

static func _is_shockwave_tower_build_implementation(implementation: String) -> bool:
	return SOURCE_SHOCKWAVE_TOWER_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_shockwave_tower_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The shockwave-tower tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (ShockwaveTower.java:22, `public class ShockwaveTower extends Block{`; ShockwaveTowerBuild, ShockwaveTower.java:66, `public class ShockwaveTowerBuild extends Building{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# shockwave tower skips consumption like Java's updateConsumption
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
	# for this shockwave tower (N2125); the tick preserves a disabled
	# shockwave tower instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {"reload_counter": 0.0, "heat": 0.0, "targets": []}

static func source_shockwave_tower_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the shockwave-tower frame meta key
	# ("source_shockwave_tower_building"). A ShockwaveTower sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_shockwave_tower_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_shockwave_tower_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a shockwave tower does not take the early return. The shockwave tower's power draw is STATIC, not conditional: `consumePower(100f / 60f);` (Blocks.java:2042) registers a plain ConsumePower, so the catalog consumePower 1.6666666666666667 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The updateTile fire gate follows the folded efficiency: the reload charge (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`) charges by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a shockwave tower with no power would never charge and never fire its wave. ShockwaveTowerBuild overrides shouldConsume (ShockwaveTower.java:121, `public boolean shouldConsume(){` with `return reloadCounter < reload;`, ShockwaveTower.java:122); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). N2187 makes the gate live (resolving the N2177 RED decision, the PointDefenseTurret N2151 precedent and the RepairTurret N2174 / RepairTower N2176 precedents): the driver tracks reloadCounter on the frame and feeds `should_consume = enabled && reload_counter < reload` to the machinery (the pure gate is source_shockwave_tower_should_consume_state), so a fully reloaded tower folds efficiency 0 like Java. The shockwave tower is its own family (ShockwaveTower.java:22, `public class ShockwaveTower extends Block{`; ShockwaveTowerBuild, ShockwaveTower.java:66, `public class ShockwaveTowerBuild extends Building{`). Class fields: `public int timerCheck = timers ++;` (ShockwaveTower.java:23), `public float range = 110f;` (ShockwaveTower.java:25), `public float reload = 60f * 1.5f;` (ShockwaveTower.java:26), `public float bulletDamage = 160;` (ShockwaveTower.java:27), `public float falloffCount = 20f;` (ShockwaveTower.java:28), `public float shake = 2f;` (ShockwaveTower.java:29), `public float checkInterval = 8f;` (ShockwaveTower.java:31), `public float cooldownMultiplier = 1f;` (ShockwaveTower.java:34); constructor `update = true;` (ShockwaveTower.java:46), `solid = true;` (ShockwaveTower.java:47). Build fields: `public float reloadCounter = Mathf.random(reload);` (ShockwaveTower.java:67), `public float heat = 0f;` (ShockwaveTower.java:68). The wave damage line (ShockwaveTower.java:87, `float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);`) and the heat decay (ShockwaveTower.java:104, `heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);`) follow the fire gate. canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) are the surrounding gates. sense(LAccess.progress) returns `reloadCounter / reload` (ShockwaveTower.java:110, `if(sensor == LAccess.progress) return reloadCounter / reload;`) and warmup() returns heat (ShockwaveTower.java:117, `return heat;`) -- both wait for their own slices. Single def -- shockwave-tower only (size 3, range 170f, reload 80f, surge-alloy 50 / silicon 150 / oxide 30 / tungsten 100, Blocks.java:2038-2044). RepairTower (unit-repair-tower) is a different class and NOT covered by this driver.
	# Documented limits: (1) power-only first pass -- the shockwave tower's static power consumer (consumePower 100f/60f, Blocks.java:2042) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); the cyanogen liquid consumer (consumeLiquids cyanogen 1.5f/60f = 0.025, Blocks.java:2041, `consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));`) waits for its own slice (the N2174 coolant / N2176 ozone precedent). (2) shouldConsume gate live (N2187) -- ShockwaveTowerBuild overrides shouldConsume (`return reloadCounter < reload;`, ShockwaveTower.java:121-122); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the driver feeds the live gate to the machinery, so a fully reloaded tower folds efficiency 0 like Java. The random init (`public float reloadCounter = Mathf.random(reload);`, ShockwaveTower.java:67) is NOT modeled: a fresh frame starts at 0.0, which preserves the gate outcome at spawn (Mathf.random(reload) is always < reload) but not the time-to-first-fire; the fire reset (`reloadCounter = 0f;`, ShockwaveTower.java:83) is modeled by N2247 (the fire slice), so a fully charged tower that finds bullets resets and charges again. (3) updateTile advance live (N2247) -- N2187 models the reloadCounter charge (`(reloadCounter += edelta())`, ShockwaveTower.java:73, edelta() = efficiency * delta(), BuildingComp.java:1927-1929) each tick after the consumption fold, and N2247 models the rest of updateTile (ShockwaveTower.java:73-104): the fire gate over the already-charged counter, the bullet scan, the wave damage, the fire reset (`reloadCounter = 0f;`, ShockwaveTower.java:83) and the heat decay (`heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);`, ShockwaveTower.java:104); the N2247 proof carries the wave/heat/target keys. The charge and the advance run inside the existing driver guard (power consumer, enabled, not cheating), so a cheating team's tower does not advance its counter; timerCheck cadence live (N2318) -- the tick accumulates frame["timer_check_elapsed"] every guarded tick and passes the computed check_ready into the advance (the frame-local Interval-equivalent, source_shockwave_tower_timer_check_state, checkInterval 8f, ShockwaveTower.java:31); the live bullet scan is live (N2327) -- the tick filters the frame bullet candidates (frame["bullet_candidates"], default []) through the scan pure (rect + enemy + hittable) at the def range from the live tower position and passes the filtered list into the advance, so a live tower with supplied candidates fires; the live bullet query (Groups.bullet) still defers -- no live query fills frame["bullet_candidates"] yet -- and heat decays every tick. First-fire deviation: Java fires nearly at once after placement; the frame clock delays the first check by a full 8-tick interval. (4) No sense/warmup modeling -- `sense(LAccess.progress)` (:110) and `warmup()` returning heat (:117) wait for their own slices. (5) Single def -- shockwave-tower only (size 3, range 170f, reload 80f, surge-alloy 50 / silicon 150 / oxide 30 / tungsten 100); per-def stat values wait for their own verification slice. (6) No draw modeling -- heatRegion / shape draw (:126-134) wait for their own slices.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_shockwave_tower_should_consume_state(frame: Dictionary, block: Object) -> Dictionary:
	# ShockwaveTowerBuild.shouldConsume() (ShockwaveTower.java:121, `public boolean shouldConsume(){` with `return reloadCounter < reload;`, ShockwaveTower.java:122): the tower consumes only while its reload counter is below reload. The counter lives on the frame ("reload_counter", `public float reloadCounter = Mathf.random(reload);`, ShockwaveTower.java:67); a fresh frame starts at 0.0 -- Java's random init is uniform in [0, reload) (Mathf.java:279-282, 0 inclusive, range exclusive), so the gate is always true at spawn and 0.0 preserves that outcome, while the exact random offset (time-to-first-fire) waits for its own slice. reload is the def value from the catalog block (`reload = 80f;`, Blocks.java:2043), falling back to the class default (`public float reload = 60f * 1.5f;`, ShockwaveTower.java:26) when the block carries none. The BuildingComp default (`return enabled;`, BuildingComp.java:755-756) does NOT apply here -- this override replaces it; enabled is enforced separately by the driver guard and the machinery's disabled early return. When the gate is false updateConsumption forces efficiency to zero (`boolean update = shouldConsume() && productionValid();`, BuildingComp.java:1960, + `if(!update){`, BuildingComp.java:1992).
	var reload_counter: float = float(frame.get("reload_counter", 0.0))
	var reload: float = 60.0 * 1.5
	if block != null:
		reload = float(block.properties.get("reload", 60.0 * 1.5))
	return {"should_consume": reload_counter < reload, "reload_counter": reload_counter}

static func source_shockwave_tower_update_tile_advance_state(frame: Dictionary, source_delta: float, reload: float, bullet_damage: float, falloff_count: float, cooldown_multiplier: float, bullet_candidates: Array, check_ready: bool) -> Dictionary:
	# The updateTile advance (ShockwaveTowerBuild.updateTile(), ShockwaveTower.java:72-105), the pure frame advance -- the build fields are `public float reloadCounter = Mathf.random(reload);` (ShockwaveTower.java:67), `public float heat = 0f;` (ShockwaveTower.java:68) and `public Seq<Bullet> targets = new Seq<>();` (ShockwaveTower.java:69), and the advance follows the Java lines in order (each exact expr on ONE comment line, the N2148 lesson):
	# `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`
	# `targets.clear();`
	# `Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {`
	# `if(b.team != team && b.type.hittable){`
	# `targets.add(b);`
	# `if(targets.size > 0){`
	# `heat = 1f;`
	# `reloadCounter = 0f;`
	# `float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);`
	# `if(target.damage > waveDamage){`
	# `target.damage -= waveDamage;`
	# `target.remove();`
	# `heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);`
	# `Events.fire(Trigger.shockwaveTowerUse);`
	# The fire gate reads the reload counter N2187 ALREADY charged in the driver (`(reloadCounter += edelta())`, ShockwaveTower.java:73, edelta() = `return efficiency * delta();`, BuildingComp.java:1927-1929) -- this advance does NOT add edelta again; the gate is potentialEfficiency > 0 (the frame value stamped by apply_update_consumption_state, so no efficiency-for-potentialEfficiency deviation) + counter >= reload + the timer outcome. The timer is the explicit check_ready input: the timerCheck cadence is live since N2318 (the frame-local Interval-equivalent, source_shockwave_tower_timer_check_state; `public float checkInterval = 8f;`, ShockwaveTower.java:31), so the driver passes the computed check_ready each tick; the live bullet scan is live since N2327 (source_shockwave_tower_supplied_bullets_state filters the frame bullet candidates and the driver passes the filtered list), so a live tower with supplied candidates fires; the live bullet query (Groups.bullet) still defers -- frame["bullet_candidates"] is a frame input. The scan is a RECTANGLE intersect over the range*2 box (ShockwaveTower.java:75); the explicit `bullet_candidates` list IS the intersect result (the N2229 precedent): the caller supplies the bullets in the box, and the pure filter keeps enemy + hittable bullets only. hittable lives on the bullet TYPE (`public boolean hittable = true;`, BulletType.java:143, default true), carried on the candidate dict; the bullet dict contract (the N2212 fixture precedent) is x / y / team / hittable / damage (`@Import float x, y, damage, lastX, lastY, time, lifetime;`, BulletComp.java:31). targets.clear() runs INSIDE the gate, so a failed gate keeps the previous target list; a passed gate with no targets fires nothing and does NOT reset the counter (`if(targets.size > 0){`, ShockwaveTower.java:81). The wave damage is min(bulletDamage, bulletDamage * falloffCount / targets.size) (`public float bulletDamage = 160;`, ShockwaveTower.java:27; `public float falloffCount = 20f;`, ShockwaveTower.java:28); each target with damage STRICTLY above waveDamage loses waveDamage, the rest are removed (the boundary is strict: damage == waveDamage removes). The port returns the post-wave targets as pure results (each with its updated damage and a `removed` flag -- Java's remove() does not change the bullet damage, so a removed target keeps its original damage); the APPLICATION (target.damage writing / target.remove() on live bullets) defers. Heat is set to 1f on fire (`heat = 1f;`, ShockwaveTower.java:82), then the UNCONDITIONAL decay runs every tick (`heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);`, ShockwaveTower.java:104; Arc's single-arg clamp is [0, 1], Mathf.java:402-404; `public float cooldownMultiplier = 1f;`, ShockwaveTower.java:34), so a fired tick ends below 1f. The wave effect / sound / shake (:84-86), the hit effect (:95) and the team event (`Events.fire(Trigger.shockwaveTowerUse);`, :99, guard :98) defer -- the advance fires silently. source_delta is Time.delta in ticks (seconds * 60 through game_source_delta, arc Time.java:26), never raw seconds. DEF BEATS CLASS: the shockwave-tower def (Blocks.java:2038-2044) sets `range = 170f;` and `reload = 80f;` over the class `public float range = 110f;` / `public float reload = 60f * 1.5f;`; bulletDamage / falloffCount / cooldownMultiplier have no def override.
	var team_id: int = int(frame.get("team_id", source_block_geometry.SOURCE_TEAM_DERELICT_ID))
	var potential_efficiency: float = float(frame.get("potential_efficiency", 0.0))
	var reload_counter: float = float(frame.get("reload_counter", 0.0))
	var heat: float = float(frame.get("heat", 0.0))
	var targets: Array = (frame.get("targets", []) as Array).duplicate(true)
	var fired: bool = false
	var wave_damage: float = 0.0
	if potential_efficiency > 0.0 and reload_counter >= reload and check_ready:
		targets = []
		for bullet in bullet_candidates:
			if not (bullet is Dictionary):
				continue
			if int(bullet.get("team", team_id)) == team_id:
				continue
			if not bool(bullet.get("hittable", true)):
				continue
			targets.append((bullet as Dictionary).duplicate(true))
		if targets.size() > 0:
			fired = true
			heat = 1.0
			reload_counter = 0.0
			wave_damage = min(bullet_damage, bullet_damage * falloff_count / float(targets.size()))
			for target in targets:
				var target_damage: float = float(target.get("damage", 0.0))
				if target_damage > wave_damage:
					target["damage"] = target_damage - wave_damage
					target["removed"] = false
				else:
					target["removed"] = true
	heat = clampf(heat - source_delta / reload * cooldown_multiplier, 0.0, 1.0)
	return {"fired": fired, "reload_counter": reload_counter, "heat": heat, "targets": targets, "wave_damage": wave_damage}

static func source_shockwave_tower_timer_check_state(elapsed: float, source_delta: float, time_scale: float, duration: float) -> Dictionary:
	# The frame-local Interval-equivalent for the timerCheck
	# cadence (TimerComp.timer, TimerComp.java:10-13, each
	# exact expr on ONE comment line, the N2148 lesson):
	# `if(Float.isInfinite(time)) return false;`
	# `return timer.get(index, time);`
	# Interval.get resets times[id] = Time.time on fire
	# (arc Interval.java:20-26):
	# `boolean got = check(id, time);`
	# `if(got) times[id] = Time.time;`
	# and check compares Time.time - times[id] >= time (arc
	# Interval.java:28-30):
	# `return Time.time - times[id] >= time || Time.time < times[id];`
	# Time.time counts TICKS (arc Time.java:69-80):
	# `timeRaw += delta;`
	# The port has no global tick clock at the driver layer, so
	# the elapsed clock is frame-local (frame["timer_check_
	# elapsed"], accumulated by the tick delta every tick the
	# advance runs, unconditionally -- mirroring Time.time,
	# which grows even while the gate is closed): elapsed +=
	# source_delta unconditionally (source_delta is the
	# UNSCALED Time.delta in ticks -- game_source_delta is
	# seconds * 60, never scaled by timeScale -- so the
	# frame clock mirrors the global Time.time exactly);
	# check_ready = elapsed >= threshold (the LITERAL
	# duration -- Java passes checkInterval (8f) with NO
	# timeScale division, unlike the MendProjector /
	# WallCrafter / ImpactReactor timers -- the N2290
	# lesson: do not invent a timeScale division);
	# timer_elapsed_after RESETS to 0.0 on fire (a reset,
	# not a subtraction like the Fracker accumulator); a
	# non-positive time_scale is a defensive guard
	# (check_ready false, threshold INF -- the clock still
	# accumulates). The Java call is
	# (ShockwaveTower.java:73):
	# `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`
	# with `public int timerCheck = timers ++;`
	# (ShockwaveTower.java:23) and `public float checkInterval = 8f;`
	# (ShockwaveTower.java:31). The timer ONLY supplies
	# check_ready -- the fire gate still needs
	# potentialEfficiency > 0 and counter >= reload (the
	# N2247 advance gates on all three), so a timer fire
	# alone never fires the wave. time_scale stays a
	# parameter (signature stability -- the contract, call
	# sites, and tests keep it) and is still read: a
	# non-positive time_scale never fires, a defensive port
	# guard for a corrupt frame input -- Java timeScale is
	# always positive in practice (the default,
	# BuildingComp.java:98, is
	# `private transient float timeScale = 1f, timeScaleDuration;`;
	# applyBoost / applySlowdown take positive intensities,
	# BuildingComp.java:461-478; decay resets it to 1f,
	# BuildingComp.java:2265-2266), so the guard is
	# unreachable in Java-exact play and the threshold is
	# Java-exact at every reachable time_scale. Note the
	# clock still ACCUMULATES at time_scale 0 (source_delta
	# is unscaled) -- only the fire is guarded. Documented
	# deviation (first fire): Java fires (nearly)
	# immediately after placement (the global Time.time is
	# already large vs a fresh Interval times[id] = 0); the
	# frame-local clock delays the first fire by a full
	# interval (8 ticks). It cannot be fixed without a
	# global clock -- it waits for a timer-infra slice if
	# exact first-fire timing is ever needed.
	var threshold: float = INF if time_scale <= 0.0 else duration
	var accumulated: float = elapsed + source_delta
	var check_ready: bool = accumulated >= threshold
	var timer_elapsed_after: float = 0.0 if check_ready else accumulated
	return {"check_ready": check_ready, "timer_elapsed_after": timer_elapsed_after, "threshold": threshold}

static func source_shockwave_tower_supplied_bullets_state(candidates: Array, range_value: float, tower_x: float, tower_y: float, tower_team: int) -> Dictionary:
	# The live bullet scan (ShockwaveTowerBuild.updateTile(), ShockwaveTower.java:75-79), the pure filter the N2247 advance fires from: at fire-gate time Java clears (`targets.clear();`, ShockwaveTower.java:74) and scans
	# `Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {`
	# `if(b.team != team && b.type.hittable){`
	# `targets.add(b);`
	# (ShockwaveTower.java:75-77). The scan is a RECTANGLE intersect over the range*2 box -- NOT a circle: a bullet at the rect corner (range, range) is IN even though its distance exceeds range. The intersect visits the spatial bullet group (EntityGroup.java:195, `public void intersect(float x, float y, float width, float height, Cons<? super T> out){`, delegating to `tree.intersect(x, y, width, height, out);`, EntityGroup.java:198); the QuadTree admits a bullet whose HITBOX overlaps the query rect (`hitbox(item);` / `if(tmp.overlaps(x, y, width, height)){`, QuadTree.java:190-191) with the STRICT Rect overlap (`return x < rx + rwidth && x + width > rx && y < ry + rheight && y + height > ry;`, Rect.java:274-276); a bullet's hitbox is its type hitSize (`public float hitSize = 4;`, BulletType.java:43). DOCUMENTED DEVIATION (the N2277 precedent): the port tests the bullet CENTER against the rect (INCLUSIVE bounds -- a center exactly on the edge counts) because the candidate dict carries no hitbox; a bullet whose center sits just outside the rect but whose hitbox straddles the edge is admitted by Java and missed by the port. The range is the class `public float range = 110f;` (ShockwaveTower.java:25), overridden by the def `range = 170f;` (Blocks.java:2043); the pure takes it as a parameter and stays def-agnostic. hittable lives on the bullet TYPE (`public boolean hittable = true;`, BulletType.java:143, default true), carried on the candidate dict; the bullet dict contract (the N2212 fixture precedent) is x / y / team / hittable / damage (`@Import float x, y, damage, lastX, lastY, time, lifetime;`, BulletComp.java:31). Scoping decisions, all source-backed: (1) a missing x or y EXCLUDES the candidate (no guessed position); a non-Dictionary entry is excluded the same way. (2) A missing team reads as the tower's own team (the N2236 precedent -- never enemy), so it is excluded. (3) A missing hittable reads as true (the BulletType default). (4) The admitted entries are the candidate dicts themselves, in candidate order, like Java's Seq<Bullet> holding the bullets -- the N2247 advance duplicates them into targets. (5) The tower team is an explicit parameter: the pure reads no frame, so the tick passes the live team_id (the frame default is derelict, source_block_geometry.SOURCE_TEAM_DERELICT_ID).
	var bullets: Array = []
	for candidate in candidates:
		if not (candidate is Dictionary):
			continue
		if not candidate.has("x") or not candidate.has("y"):
			continue
		var bullet_x: float = float(candidate.get("x", 0.0))
		var bullet_y: float = float(candidate.get("y", 0.0))
		if bullet_x < tower_x - range_value or bullet_x > tower_x + range_value:
			continue
		if bullet_y < tower_y - range_value or bullet_y > tower_y + range_value:
			continue
		if int(candidate.get("team", tower_team)) == tower_team:
			continue
		if not bool(candidate.get("hittable", true)):
			continue
		bullets.append(candidate)
	return {"bullets": bullets}

@warning_ignore("unused_parameter")
static func source_shockwave_tower_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the shockwave-tower tick wiring every
	# tick (ShockwaveTowerBuild.updateTile(), ShockwaveTower.java:73,
	# charges the reload counter by the reload charge (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`), so the reload charge follows the folded efficiency; no placed-buildings driver ticks ShockwaveTower blocks, so this driver is the placed-shockwave-tower tick): each placed ShockwaveTower build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_shockwave_tower_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_shockwave_tower_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_shockwave_tower_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a shockwave tower with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the reload charge (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a shockwave tower does not take the early return. The shockwave tower's power draw is STATIC: `consumePower(100f / 60f);` (Blocks.java:2042) registers a plain ConsumePower, so the catalog consumePower 1.6666666666666667 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. A shockwave tower with no power consumer is untouched: the tick models no other consumers yet (the updateTile advance below is wired for towers with a power consumer), and ShockwaveTowerBuild overrides shouldConsume (ShockwaveTower.java:121, `public boolean shouldConsume(){` with `return reloadCounter < reload;`, ShockwaveTower.java:122) -- N2187 feeds the live gate to the machinery (the pure gate is source_shockwave_tower_should_consume_state, fed the frame's reload_counter against the def reload); the N2177 RED decision is resolved. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_shockwave_tower_should_consume_state(frame, block)
			var should_consume: bool = bool(frame.get("enabled", true)) and bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_shockwave_tower_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# The updateTile charge (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`): the reload counter charges by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`, with delta() `return Time.delta * timeScale;`, BuildingComp.java:1922-1924; Time.delta is seconds * 60 in the port via game_source_delta, arc Time.java:26, the N2093/N2189 precedent) once updateConsumption has folded this tick's efficiency (BuildingComp.java:2274 `updateConsumption();` runs before :2277 `updateTile();`); the charge needs potentialEfficiency > 0, and a gate-false tower folds efficiency 0 so its counter sits frozen at full charge until the fire slice resets it (`reloadCounter = 0f;`, ShockwaveTower.java:83) -- N2247 is that fire slice (the advance below), so a fully charged tower that finds bullets resets and charges again. The advance follows the charge in Java order (BuildingComp.java:2274 `updateConsumption();` runs before :2277 `updateTile();`).
			if float(frame.get("potential_efficiency", 0.0)) > 0.0:
				frame["reload_counter"] = float(frame.get("reload_counter", 0.0)) + float(frame.get("efficiency", 0.0)) * source_placed_block_state.game_source_delta(game, seconds)
			# N2318: the timerCheck cadence (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`; `public float checkInterval = 8f;`, ShockwaveTower.java:31) -- the frame-local clock (frame["timer_check_elapsed"]) accumulates the tick delta every guarded tick, and its check_ready reaches the advance below. The timer ONLY supplies check_ready -- the fire gate still needs potentialEfficiency > 0 and counter >= reload. The live bullet scan is live (N2327, below) -- the tick filters the frame bullet candidates through the scan pure before the advance call and passes the filtered list in, so a live tower with supplied candidates fires; the live bullet query (Groups.bullet) still defers -- frame["bullet_candidates"] is a frame input, default [] -- but the heat decay and the frame write-back run every guarded tick. First-fire deviation: Java fires nearly at once after placement; the frame clock delays the first check by a full 8-tick interval.
			var timer_check: Dictionary = source_shockwave_tower_timer_check_state(float(frame.get("timer_check_elapsed", 0.0)), source_placed_block_state.game_source_delta(game, seconds), source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game)), SOURCE_SHOCKWAVE_TOWER_CHECK_INTERVAL)
			frame["timer_check_elapsed"] = timer_check.get("timer_elapsed_after", 0.0)
			var check_ready: bool = bool(timer_check.get("check_ready", false))
			# N2327: the live bullet scan (ShockwaveTower.java:75-77, `Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {` / `if(b.team != team && b.type.hittable){` / `targets.add(b);`) -- the frame bullet candidates (frame["bullet_candidates"], default [] -- no candidates, the Java no-bullets-in-range outcome) are filtered by the scan pure at the def range from the live tower position (origin cell + block offset, the N2306 RepairTower precedent: Building x/y are tile.drawx()/drawy(), BuildingComp.java:124), and the filtered list reaches the advance below. The scan runs BEFORE the advance call every guarded tick (Java runs the intersect INSIDE the fire gate, ShockwaveTower.java:73-75, but the scan pure is a side-effect-free filter, so running it before the advance is inert when the gate fails -- the advance still gates on check_ready + counter + potential efficiency, the N2306 pattern). Range comes from the catalog block like the N2187 reload (`range = 170f;`, Blocks.java:2043, falling back to the class default `public float range = 110f;`, ShockwaveTower.java:25); the live bullet query (Groups.bullet) still defers -- no live query fills frame["bullet_candidates"] yet.
			var scan_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
			var scan_block_size: int = int(block.properties.get("size", 1))
			var scan_block_offset: float = float((scan_block_size + 1) % 2) * source_world_defaults.TILESIZE / 2.0
			var scan_building_x: float = source_block_geometry.tile_drawx_state(scan_cell.x, source_world_defaults.TILESIZE, scan_block_offset)
			var scan_building_y: float = source_block_geometry.tile_drawy_state(scan_cell.y, source_world_defaults.TILESIZE, scan_block_offset)
			var scan_candidates: Array = []
			var frame_bullet_candidates: Variant = frame.get("bullet_candidates", [])
			if frame_bullet_candidates is Array:
				scan_candidates = frame_bullet_candidates
			var scan: Dictionary = source_shockwave_tower_supplied_bullets_state(scan_candidates, float(block.properties.get("range", 110.0)), scan_building_x, scan_building_y, team_id)
			var scanned_bullets: Array = scan.get("bullets", [])
			# The updateTile advance (N2247, ShockwaveTowerBuild.updateTile(), ShockwaveTower.java:72-105) follows the charge: the pure advance reads the counter the charge just advanced (it does NOT add edelta again), gates on the stamped potentialEfficiency + counter >= reload + the timer outcome, and decays heat every tick. reload comes from the catalog block like the N2187 gate (`reload = 80f;`, Blocks.java:2043, falling back to the class default `public float reload = 60f * 1.5f;`, ShockwaveTower.java:26); bulletDamage / falloffCount / cooldownMultiplier have no def override, so the driver constants carry the class values.
			var advanced: Dictionary = source_shockwave_tower_update_tile_advance_state(frame, source_placed_block_state.game_source_delta(game, seconds), float(block.properties.get("reload", 60.0 * 1.5)), SOURCE_SHOCKWAVE_TOWER_BULLET_DAMAGE, SOURCE_SHOCKWAVE_TOWER_FALLOFF_COUNT, SOURCE_SHOCKWAVE_TOWER_COOLDOWN_MULTIPLIER, scanned_bullets, check_ready)
			frame["reload_counter"] = advanced.get("reload_counter", frame.get("reload_counter", 0.0))
			frame["heat"] = advanced.get("heat", frame.get("heat", 0.0))
			frame["targets"] = advanced.get("targets", frame.get("targets", []))
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
