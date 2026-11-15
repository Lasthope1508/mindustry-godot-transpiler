extends RefCounted
class_name SourceShockwaveTowerBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The ShockwaveTower implementation (ShockwaveTower.java:22, `public class ShockwaveTower extends Block{`): shockwave-tower (consumePower 100f / 60f, Blocks.java:2042, `consumePower(100f / 60f);`; consumeLiquids cyanogen 1.5f / 60f, Blocks.java:2041, `consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));`; size 3, range 170f, reload 80f, surge-alloy 50 / silicon 150 / oxide 30 / tungsten 100, Blocks.java:2038-2044). ShockwaveTower extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_shockwave_tower_building", the radar precedent), and this slice adds the shockwave-tower key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceShockwaveTower* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile fire gate (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`) charges its reload counter by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a shockwave tower with no power would never charge and never fire its wave -- its reload counter would sit frozen as if power.status were 1.0.
const SOURCE_SHOCKWAVE_TOWER_BUILD_IMPLEMENTATIONS := ["ShockwaveTower"]
const SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY := "source_shockwave_tower_building"

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
	return {}

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
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a shockwave tower does not take the early return. The shockwave tower's power draw is STATIC, not conditional: `consumePower(100f / 60f);` (Blocks.java:2042) registers a plain ConsumePower, so the catalog consumePower 1.6666666666666667 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The updateTile fire gate follows the folded efficiency: the reload charge (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`) charges by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a shockwave tower with no power would never charge and never fire its wave. ShockwaveTowerBuild overrides shouldConsume (ShockwaveTower.java:121, `public boolean shouldConsume(){` with `return reloadCounter < reload;`, ShockwaveTower.java:122); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). RED decision (the PointDefenseTurret N2151 precedent and the RepairTurret N2174 / RepairTower N2176 precedents): the port tracks no live reload counter on any placed-building frame, so this slice folds power-only and defers the gate with a documented limit; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent) -- when fully reloaded power.status reads 1.0 while Java efficiency is 0; the observable gap is efficiency 1.0 vs 0.0 when fully reloaded. The shockwave tower is its own family (ShockwaveTower.java:22, `public class ShockwaveTower extends Block{`; ShockwaveTowerBuild, ShockwaveTower.java:66, `public class ShockwaveTowerBuild extends Building{`). Class fields: `public int timerCheck = timers ++;` (ShockwaveTower.java:23), `public float range = 110f;` (ShockwaveTower.java:25), `public float reload = 60f * 1.5f;` (ShockwaveTower.java:26), `public float bulletDamage = 160;` (ShockwaveTower.java:27), `public float falloffCount = 20f;` (ShockwaveTower.java:28), `public float shake = 2f;` (ShockwaveTower.java:29), `public float checkInterval = 8f;` (ShockwaveTower.java:31), `public float cooldownMultiplier = 1f;` (ShockwaveTower.java:34); constructor `update = true;` (ShockwaveTower.java:46), `solid = true;` (ShockwaveTower.java:47). Build fields: `public float reloadCounter = Mathf.random(reload);` (ShockwaveTower.java:67), `public float heat = 0f;` (ShockwaveTower.java:68). The wave damage line (ShockwaveTower.java:87, `float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);`) and the heat decay (ShockwaveTower.java:104, `heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);`) follow the fire gate. canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) are the surrounding gates. sense(LAccess.progress) returns `reloadCounter / reload` (ShockwaveTower.java:110, `if(sensor == LAccess.progress) return reloadCounter / reload;`) and warmup() returns heat (ShockwaveTower.java:117, `return heat;`) -- both wait for their own slices. Single def -- shockwave-tower only (size 3, range 170f, reload 80f, surge-alloy 50 / silicon 150 / oxide 30 / tungsten 100, Blocks.java:2038-2044). RepairTower (unit-repair-tower) is a different class and NOT covered by this driver.
	# Documented limits: (1) power-only first pass -- the shockwave tower's static power consumer (consumePower 100f/60f, Blocks.java:2042) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); the cyanogen liquid consumer (consumeLiquids cyanogen 1.5f/60f = 0.025, Blocks.java:2041, `consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));`) waits for its own slice (the N2174 coolant / N2176 ozone precedent). (2) shouldConsume gate deferred -- ShockwaveTowerBuild overrides shouldConsume (`return reloadCounter < reload;`, ShockwaveTower.java:121-122); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the driver runs with should_consume=true when enabled (the MendProjector suppression precedent) -- when fully reloaded power.status reads 1.0 while Java efficiency is 0. (3) No updateTile wave advance -- reloadCounter charge / bullet scan / wave damage / heat / cooldown (ShockwaveTower.java:73-104) wait for their own slices; the proof carries no wave/heat/target keys, the reload charge (ShockwaveTower.java:73) is what the efficiency keys prove. (4) No sense/warmup modeling -- `sense(LAccess.progress)` (:110) and `warmup()` returning heat (:117) wait for their own slices. (5) Single def -- shockwave-tower only (size 3, range 170f, reload 80f, surge-alloy 50 / silicon 150 / oxide 30 / tungsten 100); per-def stat values wait for their own verification slice. (6) No draw modeling -- heatRegion / shape draw (:126-134) wait for their own slices.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_shockwave_tower_charge_state(frame: Dictionary, delta: float) -> Dictionary:
	# ShockwaveTowerBuild.updateTile charges its reload counter by
	# edelta() when it has potential efficiency
	# (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`), and
	# edelta() is efficiency * delta (BuildingComp.java:1927-1929,
	# `return efficiency * delta();`). The gate reads the
	# potentialEfficiency stamped by THIS tick's updateConsumption
	# (BuildingComp.java:1989, `potentialEfficiency = efficiency;`)
	# -- the pre-gate min efficiency (the power.status fold) -- and
	# canConsume is the same gate (BuildingComp.java:1917, `public boolean canConsume(){` with
	# `return potentialEfficiency > 0;`, BuildingComp.java:1918).
	# updateConsumption forces efficiency to zero when the
	# shouldConsume gate is false (BuildingComp.java:1960,
	# `boolean update = shouldConsume() && productionValid();` +
	# 1992, `if(!update){` + 1993, `efficiency = optionalEfficiency = 0f;`).
	# The charge itself lives in updateTile
	# (ShockwaveTower.java:72, `public void updateTile(){`); the
	# per-def block (Blocks.java:2043-2044) sets `range = 170f;`
	# and `reload = 80f;`, so the charge threshold the counter
	# runs against is 80f.
	# An absent `reload_counter` key starts from deterministic
	# 0.0 -- Java inits `public float reloadCounter = Mathf.random(reload);`
	# (ShockwaveTower.java:67), but the port takes the deterministic
	# 0.0 start, the N2190 RepairTower refresh precedent, never
	# `randf` in game code (the C06DefenseProof lesson: seeded RNG
	# only in proof scenes). There is NO clamp at reload and NO
	# reset without fire: Java keeps accumulating past reload until
	# a successful fire resets the counter to 0
	# (ShockwaveTower.java:83, `reloadCounter = 0f;`, with
	# `heat = 1f;`, ShockwaveTower.java:82), so a counter past
	# reload stays past reload.
	var reload_counter: float = float(frame.get("reload_counter", 0.0))
	var potential_efficiency: float = float(frame.get("potential_efficiency", 0.0))
	if potential_efficiency > 0.0:
		reload_counter += float(frame.get("efficiency", 0.0)) * delta
	return {"reload_counter": reload_counter}

static func source_shockwave_tower_should_consume_state(frame: Dictionary) -> Dictionary:
	# ShockwaveTowerBuild overrides shouldConsume
	# (ShockwaveTower.java:121, `public boolean shouldConsume(){`
	# with `return reloadCounter < reload;`,
	# ShockwaveTower.java:122) over the reload counter
	# (ShockwaveTower.java:67, `public float reloadCounter =
	# Mathf.random(reload);`), which the N2192 charge alone writes
	# (ShockwaveTower.java:73, `if(potentialEfficiency > 0 &&
	# (reloadCounter += edelta()) >= reload && timer(timerCheck,
	# checkInterval)){`). The per-def reload is 80f
	# (Blocks.java:2044, `reload = 80f;`, with `size = 3;` and
	# `range = 170f;`), overriding the class default `60f * 1.5f`
	# (ShockwaveTower.java:26, `public float reload = 60f * 1.5f;`).
	# An absent `reload_counter` key means "no observation yet"
	# and preserves the N2177 behavior (`should_consume =
	# enabled`) -- the N2191 `targets_count` precedent -- never
	# "fully charged": the N2192 charge stamps `reload_counter`
	# only after the first consumption stamp each tick, and
	# defaulting absent to false would zero efficiency for every
	# live shockwave tower before its first charge tick. It also
	# matches the Java init: `reloadCounter =
	# Mathf.random(reload);` is always < reload, so at Java init
	# the gate is true when enabled. updateConsumption forces
	# efficiency to zero when the gate is false
	# (BuildingComp.java:1960, `boolean update = shouldConsume()
	# && productionValid();` + 1992, `if(!update){` + 1993,
	# `efficiency = optionalEfficiency = 0f;`).
	var enabled: bool = bool(frame.get("enabled", true))
	var observed: Variant = frame.get("reload_counter", null)
	if observed == null:
		return {"should_consume": enabled}
	return {"should_consume": float(observed) < 80.0 and enabled}

static func source_shockwave_tower_bullet_scan_state(frame: Dictionary) -> Dictionary:
	# ShockwaveTowerBuild.updateTile clears its targets and scans
	# the bullet groups inside the range box
	# (ShockwaveTower.java:72, `public void updateTile(){` with
	# :74, `targets.clear();` and :75,
	# `Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {`
	# with :76, `if(b.team != team && b.type.hittable){` and :77,
	# `targets.add(b);`) over the target list
	# (ShockwaveTower.java:68, `public Seq<Bullet> targets = new Seq<>();`).
	# The scan is what N2194's fire gate reads as the observed
	# `targets_count` (ShockwaveTower.java:81, `if(targets.size > 0){`)
	# -- the fire fires only when the scan found targets. The port
	# has no live bullet query (no Groups.bullet equivalent), so
	# the pure function consumes an observed bullet list
	# (`observed_bullets`, an array of dicts with team/hittable/x/y,
	# world coords) and counts the enemy hittable bullets inside
	# the range box (x +/- range, y +/- range, range 170f per-def,
	# Blocks.java:2043, `range = 170f;`, overriding the class
	# default 110f, ShockwaveTower.java:25, `public float range = 110f;`).
	# The tower's world position comes from the frame's `x`/`y`
	# keys, which the driver derives from the placement cell
	# (Tile.java, `return x * tilesize;` / `return block().offset + worldx();`,
	# tilesize 8, Vars.java:135, `public static final int tilesize = 8;`,
	# offset 0 for size 3, Block.java:761,
	# `offset = ((size + 1) % 2) * tilesize / 2f;`), and its team
	# from the frame's `team_id` key (already stamped by the tick
	# wiring). The range box is a point-in-box test against the
	# Java intersect rect -- the port models no bullet hitSize, so
	# the rect overlap is approximated by the bullet point, a
	# documented limit owned by a later bullet-hitSize slice.
	# The scan runs every tick in the driver (after the N2192
	# charge, before the N2194 fire) -- Java scans only when the
	# fire gate (:73) is true, but the port's timer cadence is
	# already deferred (N2194: the port fires on the first tick at
	# reload), so a fresh scan every tick is observably equivalent
	# for the fire decision, and the timer-gated scan cadence waits
	# for the per-building-timer slice with the timer itself.
	# Absent `observed_bullets` (or absent `x`/`y`/`team_id`)
	# means "no observation yet": the function returns
	# targets_count null and has_targets_count false, and the
	# driver stamps nothing (the N2190 precedent) -- never a
	# fabricated 0, so N2194 keeps reading absent as no fire. A
	# present-but-empty list IS an observation and stamps 0.
	var observed_bullets: Variant = frame.get("observed_bullets", null)
	var tower_x: Variant = frame.get("x", null)
	var tower_y: Variant = frame.get("y", null)
	var tower_team: Variant = frame.get("team_id", null)
	if observed_bullets == null or tower_x == null or tower_y == null or tower_team == null:
		return {"targets_count": null, "has_targets_count": false}
	var targets_count: int = 0
	for bullet in observed_bullets:
		if bullet.get("team", null) == null:
			continue
		if int(bullet.get("team", null)) == int(tower_team):
			continue
		if not bool(bullet.get("hittable", false)):
			continue
		if absf(float(bullet.get("x", 0.0)) - float(tower_x)) > 170.0:
			continue
		if absf(float(bullet.get("y", 0.0)) - float(tower_y)) > 170.0:
			continue
		targets_count += 1
	return {"targets_count": targets_count, "has_targets_count": true}

static func source_shockwave_tower_fire_state(frame: Dictionary, delta: float) -> Dictionary:
	# ShockwaveTowerBuild.updateTile fires its wave when the reload
	# counter, charged by edelta(), reaches reload
	# (ShockwaveTower.java:72, `public void updateTile(){` with
	# :73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`), and
	# edelta() is efficiency * delta (BuildingComp.java:1927-1929,
	# `return efficiency * delta();`). The charge advance is
	# N2192's job and the ONLY writer of `reload_counter` -- the
	# fire function reads the counter the charge stamped this tick
	# and never re-advances it. The fire gate reads the
	# potentialEfficiency stamped by THIS tick's updateConsumption
	# (BuildingComp.java:1989, `potentialEfficiency = efficiency;`)
	# -- the pre-gate min efficiency -- and canConsume is the same
	# gate (BuildingComp.java:1917, `public boolean canConsume(){`
	# with `return potentialEfficiency > 0;`,
	# BuildingComp.java:1918), so a fully charged tower whose
	# N2193 shouldConsume gate zeroes efficiency still fires when
	# it has power, exactly like Java: the fire condition reads
	# potentialEfficiency, not efficiency. The timer cadence
	# (`timer(timerCheck, checkInterval)`, checkInterval 8f,
	# ShockwaveTower.java:31; `public int timerCheck = timers ++;`,
	# ShockwaveTower.java:23) is DEFERRED: the port tracks no
	# per-building Interval state (`public boolean timer(int index, float time){` /
	# `return timer.get(index, time);`, TimerComp.java:10-13, over
	# `transient Interval timer = new Interval(6);`,
	# TimerComp.java:9), so the port fires on the first tick the
	# counter is at reload with targets observed, where Java fires
	# only on a timer tick -- up to checkInterval (8 ticks) earlier,
	# a documented fidelity gap owned by a later
	# per-building-timer slice. The live bullet scan has NO frame
	# input in the port, so the fire reads an observed
	# `targets_count` key (the N2190 RepairTower precedent: stamped
	# only when observed) and absent means no fire, never invented
	# targets. On fire with targets (ShockwaveTower.java:81,
	# `if(targets.size > 0){`) Java sets heat 1f (:82, `heat = 1f;`)
	# and resets the counter (:83, `reloadCounter = 0f;`); the
	# scan itself (:74-79, `targets.clear();` /
	# `Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {` /
	# `if(b.team != team && b.type.hittable){` / `targets.add(b);`),
	# the wave damage line (:87, `float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);`),
	# the per-target damage / removal (:89-95,
	# `for(var target : targets){` / `if(target.damage > waveDamage){` /
	# `target.damage -= waveDamage;` / `target.remove();` /
	# `hitEffect.at(target.x, target.y, waveColor);`), the Fx /
	# sound / shake (:84-86, :95, `waveEffect.at(x, y, range, waveColor);` /
	# `shootSound.at(x, y, 1f + Mathf.range(0.15f), 1f);` /
	# `Effect.shake(shake, shake, this);` over `public Effect waveEffect = Fx.pointShockwave;` /
	# `public Sound shootSound = Sounds.shockwaveTower;` /
	# `public Effect hitEffect = Fx.hitSquaresColor;`) and the
	# shockwaveTowerUse event (:97-99,
	# `if(team == state.rules.defaultTeam){` /
	# `Events.fire(Trigger.shockwaveTowerUse);`) wait for their own
	# slices -- the fire function returns only the flag, the reset
	# counter, and the heat. Every tick, heat decays
	# (ShockwaveTower.java:104, `heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);`)
	# against the per-def reload 80f (Blocks.java:2044,
	# `reload = 80f;`, with `size = 3;` and `range = 170f;`)
	# and cooldownMultiplier 1f (ShockwaveTower.java:34,
	# `public float cooldownMultiplier = 1f;`) -- Time.delta is the
	# raw delta, not edelta, so the decay uses the tick's
	# `seconds`, the N2190 driver convention. On a fire tick Java
	# sets heat 1f (:82) and then decays it the same tick (:104),
	# so the pure function applies the decay AFTER the fire set,
	# in the same order. An absent `reload_counter` key starts
	# from deterministic 0.0 -- Java inits `public float reloadCounter = Mathf.random(reload);`
	# (ShockwaveTower.java:67), but the port takes the deterministic
	# 0.0 start, the N2190 RepairTower refresh precedent, never
	# `randf` in game code (the C06DefenseProof lesson: seeded RNG
	# only in proof scenes). Absent `potential_efficiency` is 0.0,
	# so no fire; absent `heat` is 0.0 (Java init `heat = 0f;`,
	# ShockwaveTower.java:68). Class fields: `public float range = 110f;`
	# (ShockwaveTower.java:25), `public float reload = 60f * 1.5f;`
	# (ShockwaveTower.java:26), `public float bulletDamage = 160;`
	# (ShockwaveTower.java:27), `public float falloffCount = 20f;`
	# (ShockwaveTower.java:28), `public float shake = 2f;`
	# (ShockwaveTower.java:29). sense(LAccess.progress) returns
	# `reloadCounter / reload` (ShockwaveTower.java:110,
	# `if(sensor == LAccess.progress) return reloadCounter / reload;`)
	# and warmup() returns heat (ShockwaveTower.java:117,
	# `return heat;`) -- both wait for their own slices.
	# updateConsumption forces efficiency to zero when the
	# shouldConsume gate is false (BuildingComp.java:1960,
	# `boolean update = shouldConsume() && productionValid();` +
	# 1992, `if(!update){` + 1993,
	# `efficiency = optionalEfficiency = 0f;`); the shouldConsume
	# default is `return enabled;` (BuildingComp.java:755-756,
	# `public boolean shouldConsume(){`), overridden by
	# ShockwaveTowerBuild (`return reloadCounter < reload;`,
	# ShockwaveTower.java:121-122, `public boolean shouldConsume(){`).
	var reload_counter: float = float(frame.get("reload_counter", 0.0))
	var potential_efficiency: float = float(frame.get("potential_efficiency", 0.0))
	var heat: float = float(frame.get("heat", 0.0))
	var observed_targets: Variant = frame.get("targets_count", null)
	var fired: bool = false
	if potential_efficiency > 0.0 and reload_counter >= 80.0 and observed_targets != null and float(observed_targets) > 0.0:
		fired = true
		heat = 1.0
		reload_counter = 0.0
	heat = clampf(heat - delta / 80.0, 0.0, 1.0)
	return {"fired": fired, "reload_counter": reload_counter, "heat": heat}

static func source_shockwave_tower_wave_damage_state(frame: Dictionary) -> Dictionary:
	# ShockwaveTowerBuild.updateTile applies the wave damage
	# inside the fire gate, after the targets.size check
	# (ShockwaveTower.java:72, `public void updateTile(){` with
	# :81, `if(targets.size > 0){` and :87, `float waveDamage =
	# Math.min(bulletDamage, bulletDamage * falloffCount /
	# targets.size);`, bulletDamage 160,
	# ShockwaveTower.java:27, `public float bulletDamage = 160;`,
	# falloffCount 20f, ShockwaveTower.java:28, `public float
	# falloffCount = 20f;`) and loops the targets
	# (ShockwaveTower.java:89, `for(var target : targets){`): a
	# target whose damage exceeds the wave damage loses exactly
	# waveDamage (`if(target.damage > waveDamage){` /
	# `target.damage -= waveDamage;`, ShockwaveTower.java:90-91
	# -- the STRICT comparison, so a target at exactly
	# waveDamage is removed, not left at 0), any other target is
	# removed (`target.remove();`, ShockwaveTower.java:93, over
	# `@Import float x, y, damage, lastX, lastY, time, lifetime;`,
	# BulletComp.java:31, `public void remove(){`,
	# BulletComp.java:83), and every target gets its hit effect
	# at its own position (`hitEffect.at(target.x, target.y,
	# waveColor);`, ShockwaveTower.java:95, over `public Effect
	# hitEffect = Fx.hitSquaresColor;`, ShockwaveTower.java:35).
	# The port has no live bullets to mutate (no Groups.bullet
	# equivalent), so the pure function consumes the same
	# observed bullet list as the N2195 scan
	# (`observed_bullets`, an array of dicts with
	# team/hittable/x/y/damage, world coords) and returns one
	# outcome per target bullet instead of mutating it:
	# `{"damage": remaining or null, "removed": bool, "hit_x":
	# x, "hit_y": y}`. The target filter is the N2195 scan
	# filter verbatim (enemy, hittable, point inside the range
	# box x +/- 170, y +/- 170, range 170f per-def,
	# Blocks.java:2043, `range = 170f;`, overriding the class
	# default 110f, ShockwaveTower.java:25, `public float range =
	# 110f;`) -- the wave only ever touches the scanned targets.
	# Absent `observed_bullets` (or absent `x`/`y`/`team_id`)
	# or zero targets in range means "no wave":
	# `{"wave_damage": null, "bullet_outcomes": [],
	# "has_wave_damage": false}` and the driver stamps nothing
	# (the N2190 / N2195 precedent) -- never a fabricated 0.
	# The driver calls the wave damage AFTER the N2194 fire and
	# ONLY when the fire fired (the local `fired` dict) -- the
	# wave lives inside the fire gate in Java (:81-96), so a
	# charged-but-unfired tick damages nothing, and the pure
	# function stays fire-agnostic and testable on its own. A
	# bullet without a `damage` key reads 0.0 and is removed
	# (0.0 never exceeds the wave damage). The wave damage is
	# min(160, 3200 / N) -- never more than bulletDamage, never
	# divided by zero: N = 0 never reaches the division because
	# the targets.size gate (:81) and the has_wave_damage false
	# return guard it.
	var observed_bullets: Variant = frame.get("observed_bullets", null)
	var tower_x: Variant = frame.get("x", null)
	var tower_y: Variant = frame.get("y", null)
	var tower_team: Variant = frame.get("team_id", null)
	if observed_bullets == null or tower_x == null or tower_y == null or tower_team == null:
		return {"wave_damage": null, "bullet_outcomes": [], "has_wave_damage": false}
	var targets: Array = []
	for bullet in observed_bullets:
		if bullet.get("team", null) == null:
			continue
		if int(bullet.get("team", null)) == int(tower_team):
			continue
		if not bool(bullet.get("hittable", false)):
			continue
		if absf(float(bullet.get("x", 0.0)) - float(tower_x)) > 170.0:
			continue
		if absf(float(bullet.get("y", 0.0)) - float(tower_y)) > 170.0:
			continue
		targets.append(bullet)
	if targets.is_empty():
		return {"wave_damage": null, "bullet_outcomes": [], "has_wave_damage": false}
	var wave_damage: float = minf(160.0, 160.0 * 20.0 / float(targets.size()))
	var bullet_outcomes: Array = []
	for bullet in targets:
		var damage: float = float(bullet.get("damage", 0.0))
		var hit_x: float = float(bullet.get("x", 0.0))
		var hit_y: float = float(bullet.get("y", 0.0))
		if damage > wave_damage:
			bullet_outcomes.append({"damage": damage - wave_damage, "removed": false, "hit_x": hit_x, "hit_y": hit_y})
		else:
			bullet_outcomes.append({"damage": null, "removed": true, "hit_x": hit_x, "hit_y": hit_y})
	return {"wave_damage": wave_damage, "bullet_outcomes": bullet_outcomes, "has_wave_damage": true}

static func source_shockwave_tower_fire_effects_state(frame: Dictionary) -> Dictionary:
	# ShockwaveTowerBuild.updateTile fires the wave effect, the
	# shoot sound and the screen shake inside the fire gate,
	# after heat = 1f and reloadCounter = 0f and before the wave
	# damage (ShockwaveTower.java:82-86, `heat = 1f;` /
	# `reloadCounter = 0f;` / `waveEffect.at(x, y, range,
	# waveColor);` / `shootSound.at(x, y, 1f +
	# Mathf.range(0.15f), 1f);` / `Effect.shake(shake, shake,
	# this);`, inside `if(targets.size > 0){`,
	# ShockwaveTower.java:81). The wave effect is
	# Fx.pointShockwave (ShockwaveTower.java:35, `public Effect
	# waveEffect = Fx.pointShockwave;`, at the tower with rotation
	# = range 170f per-def, Blocks.java:2043, `range = 170f;`,
	# in waveColor Pal.accent, ShockwaveTower.java:29, `public
	# Color waveColor = Pal.accent, heatColor = Pal.turretHeat,
	# shapeColor = Color.valueOf("f29c83");`, Pal.accent =
	# Color.valueOf("ffd37f"), Pal.java:79 -- Fx.pointShockwave
	# draws `Lines.circle(e.x, e.y, e.finpow() * e.rotation)`,
	# Fx.java:223-228, so the `range` argument is the effect
	# rotation). The shoot sound is Sounds.shockwaveTower
	# (ShockwaveTower.java:30, `public Sound shootSound =
	# Sounds.shockwaveTower;`, at the tower, pitch 1f +
	# Mathf.range(0.15f), volume 1f). The shake is
	# Effect.shake(shake, shake, this) (ShockwaveTower.java:27,
	# `public float shake = 2f;`, over `public static void
	# shake(float intensity, float duration, Position loc){`,
	# Effect.java:210-211 -- intensity 2f, duration 2f, at the
	# tower). The port spawns no real Fx / sound / shake (no
	# Godot equivalents are wired), so the pure function stamps
	# one descriptor per Java call instead of spawning it. The
	# pitch is the DETERMINISTIC range of `1f +
	# Mathf.range(0.15f)`, never a sampled pitch: the pure
	# function takes no RNG. The function needs only the tower
	# world position (`x`/`y` frame keys, derived by the driver
	# from the placement cell: Tile.java, `return x * tilesize;`
	# / `return block().offset + worldx();`, tilesize 8, offset 0
	# for size 3). Absent `x`/`y` means "no effects":
	# `{"wave_effect": null, "shoot_sound": null, "shake": null,
	# "has_fire_effects": false}` and the driver stamps nothing
	# (the N2190 / N2195 / N2196 precedent) -- never a fabricated
	# descriptor. The driver calls the effects AFTER the N2194
	# fire and ONLY when the fire fired, and BEFORE the N2196
	# wave damage (the Java order :84-86 before :87).
	var tower_x: Variant = frame.get("x", null)
	var tower_y: Variant = frame.get("y", null)
	if tower_x == null or tower_y == null:
		return {"wave_effect": null, "shoot_sound": null, "shake": null, "has_fire_effects": false}
	var wave_effect: Dictionary = {"effect": "pointShockwave", "x": float(tower_x), "y": float(tower_y), "rotation": 170.0, "color": "Pal.accent"}
	var shoot_sound: Dictionary = {"sound": "shockwaveTower", "x": float(tower_x), "y": float(tower_y), "pitch_min": 0.85, "pitch_max": 1.15, "volume": 1.0}
	var shake: Dictionary = {"intensity": 2.0, "duration": 2.0, "x": float(tower_x), "y": float(tower_y)}
	return {"wave_effect": wave_effect, "shoot_sound": shoot_sound, "shake": shake, "has_fire_effects": true}

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
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a shockwave tower does not take the early return. The shockwave tower's power draw is STATIC: `consumePower(100f / 60f);` (Blocks.java:2042) registers a plain ConsumePower, so the catalog consumePower 1.6666666666666667 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. A shockwave tower with no power consumer is untouched: the tick models no other consumers yet (the updateTile advance waits for its own slice), and ShockwaveTowerBuild overrides shouldConsume (ShockwaveTower.java:121, `public boolean shouldConsume(){` with `return reloadCounter < reload;`, ShockwaveTower.java:122) -- RED decision (the PointDefenseTurret N2151 precedent and the RepairTurret N2174 / RepairTower N2176 precedents): the port tracks no live reload counter on any placed-building frame, so the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			# N2193 wires the shouldConsume gate through source_shockwave_tower_should_consume_state(frame): float(reload_counter) < 80.0 and enabled when a counter observation is present, enabled when the frame carries no reload_counter key (the N2177 behavior preserved; the N2192 charge stamps reload_counter every tick after apply_update_consumption_state).
			var should_consume: bool = bool(source_shockwave_tower_should_consume_state(frame).get("should_consume", true))
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
			# The charge advance (N2192): updateConsumption runs
			# BEFORE updateTile in Java, so the charge reads THIS
			# tick's freshly stamped potential_efficiency /
			# efficiency (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`); the tick's
			# `seconds` is the delta (the N2190 driver convention).
			# The live charge is the only writer of the frame's
			# `reload_counter` key.
			var charged: Dictionary = source_shockwave_tower_charge_state(frame, seconds)
			frame["reload_counter"] = charged.get("reload_counter", 0.0)
			# The live bullet scan (N2195): the scan runs inside
			# the fire gate in Java (ShockwaveTower.java:74-79,
			# `targets.clear();` / `Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {` /
			# `if(b.team != team && b.type.hittable){` / `targets.add(b);`),
			# after the charge and before the targets.size check
			# (ShockwaveTower.java:81, `if(targets.size > 0){`), so
			# the driver calls it after the N2192 charge and
			# before the N2194 fire. The tower world position comes
			# from the placement cell (Tile.java, `return x * tilesize;`
			# / `return block().offset + worldx();`, tilesize 8,
			# Vars.java:135, `public static final int tilesize = 8;`,
			# offset 0 for size 3, Block.java:761,
			# `offset = ((size + 1) % 2) * tilesize / 2f;`), and
			# the scan stamps `targets_count` only when it reports
			# an observation (has_targets_count true) -- absent
			# observation stamps nothing (the N2190 precedent), so
			# N2194 keeps reading absent as no fire.
			var origin_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
			frame["x"] = float(origin_cell.x) * 8.0
			frame["y"] = float(origin_cell.y) * 8.0
			var scanned: Dictionary = source_shockwave_tower_bullet_scan_state(frame)
			if bool(scanned.get("has_targets_count", false)):
				frame["targets_count"] = scanned.get("targets_count", 0)
			# The fire gate (N2194): updateConsumption runs BEFORE
			# updateTile in Java, so the fire reads THIS tick's
			# freshly stamped potential_efficiency and the counter
			# the charge just advanced (ShockwaveTower.java:73,
			# `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`).
			# The tick's `seconds` is the delta (the N2190 driver
			# convention); the fire stamps `reload_counter` (reset
			# to 0.0 on fire) and `heat` from the result. The live
			# bullet scan (Groups.bullet.intersect,
			# ShockwaveTower.java:75-79) has no frame input yet, so
			# the fire reads the observed `targets_count` key only.
			var fired: Dictionary = source_shockwave_tower_fire_state(frame, seconds)
			frame["reload_counter"] = fired.get("reload_counter", 0.0)
			frame["heat"] = fired.get("heat", 0.0)
			# The wave damage (N2196): the wave runs inside the
			# fire gate in Java (ShockwaveTower.java:81-96,
			# `if(targets.size > 0){` / `float waveDamage =
			# Math.min(bulletDamage, bulletDamage * falloffCount /
			# targets.size);` / `for(var target : targets){` /
			# `if(target.damage > waveDamage){` /
			# `target.damage -= waveDamage;` / `target.remove();` /
			# `hitEffect.at(target.x, target.y, waveColor);`),
			# after the fire sets heat and resets the counter
			# (:82-83, `heat = 1f;` / `reloadCounter = 0f;`), so
			# the driver calls it after the N2194 fire and ONLY
			# when the fire fired (the local `fired` dict). The
			# wave damage stamps only `wave_damage` and
			# `bullet_outcomes`, and only when the wave reports
			# one (has_wave_damage true). The stamped outcomes
			# persist on the frame until the next fire (like
			# heat). The hitEffect (:95) and the
			# shockwaveTowerUse event (:97-99) wait for their own
			# slices; the fire effects (:84-86) land in N2197
			# just above the wave damage call.
			if bool(fired.get("fired", false)):
				# The fire effects (N2197): the effects run
				# inside the fire gate in Java
				# (ShockwaveTower.java:81-86, `if(targets.size >
				# 0){` / `heat = 1f;` / `reloadCounter = 0f;` /
				# `waveEffect.at(x, y, range, waveColor);` /
				# `shootSound.at(x, y, 1f + Mathf.range(0.15f),
				# 1f);` / `Effect.shake(shake, shake, this);`),
				# after the fire sets heat and resets the counter
				# (:82-83) and before the wave damage (:87), so
				# the driver calls them after the N2194 fire and
				# ONLY when the fire fired, before the N2196 wave
				# damage. The effects stamp `wave_effect` /
				# `shoot_sound` / `shake` only when the effects
				# report one (has_fire_effects true). The
				# hitEffect (:95) and the shockwaveTowerUse event
				# (:97-99) wait for their own slices.
				var effects: Dictionary = source_shockwave_tower_fire_effects_state(frame)
				if bool(effects.get("has_fire_effects", false)):
					frame["wave_effect"] = effects.get("wave_effect", null)
					frame["shoot_sound"] = effects.get("shoot_sound", null)
					frame["shake"] = effects.get("shake", null)
				var wave: Dictionary = source_shockwave_tower_wave_damage_state(frame)
				if bool(wave.get("has_wave_damage", false)):
					frame["wave_damage"] = wave.get("wave_damage", null)
					frame["bullet_outcomes"] = wave.get("bullet_outcomes", [])
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
