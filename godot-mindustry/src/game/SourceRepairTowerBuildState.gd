extends RefCounted
class_name SourceRepairTowerBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_unit_runtime_state := preload("res://src/game/SourceUnitRuntimeState.gd")

# The RepairTower implementation (RepairTower.java:18, `public class RepairTower extends Block{`): unit-repair-tower (consumePower 1f, Blocks.java:6582, `consumePower(1f);`; consumeLiquid ozone 3f/60f, Blocks.java:6583, `consumeLiquid(Liquids.ozone, 3f / 60f);`; size 2, range 100f, healAmount 1.5f, graphite 90 / silicon 90 / tungsten 80, Blocks.java:6575-6583). RepairTower extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_repair_tower_building", the radar precedent), and this slice adds the repair-tower key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceRepairTower* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile heal advance (RepairTower.java:78, `target.heal(healAmount * edelta());`) heals by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a repair tower with no power would never heal -- its targets' health would sit frozen as if power.status were 1.0.
const SOURCE_REPAIR_TOWER_BUILD_IMPLEMENTATIONS := ["RepairTower"]
const SOURCE_REPAIR_TOWER_BUILDING_META_KEY := "source_repair_tower_building"
# The target-refresh interval (RepairTower.java:19, `static final float refreshInterval = 6f;`).
const SOURCE_REPAIR_TOWER_REFRESH_INTERVAL := 6.0

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
	return {}

static func source_repair_tower_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the repair-tower frame meta key
	# ("source_repair_tower_building"). A RepairTower sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_repair_tower_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_REPAIR_TOWER_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_REPAIR_TOWER_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_REPAIR_TOWER_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_repair_tower_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a repair tower does not take the early return. The repair tower's power draw is STATIC, not conditional: `consumePower(1f);` (Blocks.java:6582) registers a plain ConsumePower, so the catalog consumePower 1.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The updateTile advance follows the folded efficiency: the heal advance (RepairTower.java:78, `target.heal(healAmount * edelta());`) heals by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a repair tower with no power would never heal. RepairTowerBuild overrides shouldConsume (RepairTower.java:89, `public boolean shouldConsume(){` with `return targets.size > 0;`, RepairTower.java:90); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). RED decision (the PointDefenseTurret N2151 precedent and the RepairTurret N2174 precedent): the port tracks no live target on any placed-building frame, so this slice folds power-only and defers the gate with a documented limit; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent) -- with no targets requestedPower is 0 so power.status reads 1.0 while Java efficiency is 0; the observable gap is efficiency 1.0 vs 0.0 with no targets. The repair tower is its own family (RepairTower.java:18, `public class RepairTower extends Block{`; RepairTowerBuild, RepairTower.java:46, `public class RepairTowerBuild extends Building implements Ranged{`). Class fields: `static final float refreshInterval = 6f;` (RepairTower.java:19), `public float range = 80f;` (RepairTower.java:21), `public float healAmount = 1f;` (RepairTower.java:24); constructor `update = true;` (RepairTower.java:29), `suppressable = true;` (RepairTower.java:31), `flags = EnumSet.of(BlockFlag.repair);` (RepairTower.java:32). The target refresh itself is gated on potentialEfficiency (RepairTower.java:59, `if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){`), and the warmup lerp (RepairTower.java:84, `warmup = Mathf.lerpDelta(warmup, any ? efficiency : 0f, 0.08f);`) follows efficiency. canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) are the surrounding gates. Single def -- unit-repair-tower only (size 2, range 100f, healAmount 1.5f, graphite 90 / silicon 90 / tungsten 80, Blocks.java:6575-6583). RepairTurret (repair-point / repair-turret) is a different class and NOT covered by this driver.
	# Documented limits: (1) power-only first pass -- the repair tower's static power consumer (consumePower 1f, Blocks.java:6582) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); the ozone liquid consumer (consumeLiquid ozone 3f/60f = 0.05, Blocks.java:6583, `consumeLiquid(Liquids.ozone, 3f / 60f);`) waits for its own slice (the N2174 coolant precedent). (2) shouldConsume gate deferred -- RepairTowerBuild overrides shouldConsume (`return targets.size > 0;`, RepairTower.java:89-91); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the driver runs with should_consume=true when enabled (the MendProjector suppression precedent) -- with no targets power.status reads 1.0 while Java efficiency is 0. (3) No updateTile heal advance -- target refresh / heal / warmup lerp / totalProgress advance (RepairTower.java:57-86) wait for their own slices; the proof carries no heal/warmup/target keys, the heal advance (RepairTower.java:78) is what the efficiency keys prove. (4) No suppression modeling -- `suppressable = true` (RepairTower.java:31) and `checkSuppression()` zeroes warmup (RepairTower.java:69-72); the suppression coupling waits for its own slice. (5) Single def -- unit-repair-tower only (size 2, range 100f, healAmount 1.5f, graphite 90 / silicon 90 / tungsten 80); per-def stat values wait for their own verification slice. (6) RepairTurret (repair-point / repair-turret) is a different class and NOT covered by this driver.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_repair_tower_refresh_targets_state(frame: Dictionary, delta: float) -> Dictionary:
	# The target refresh (RepairTower.java:59-66, `if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){` / `targets.clear();` / `refresh = 0f;` / `Units.nearby(team, x, y, range, u -> {` / `if(u.damaged()){` / `targets.add(u);`): the refresh block is the ONLY writer of `targets`, and the tower's shouldConsume gate reads that list (`public boolean shouldConsume(){` with `return targets.size > 0;`, RepairTower.java:89-90). The interval is the class constant (`static final float refreshInterval = 6f;`, RepairTower.java:19). The gate reads the potentialEfficiency stamped by THIS tick's updateConsumption (BuildingComp.java:2263-2277, updateConsumption() runs BEFORE updateTile()), and the port mirror sets `potentialEfficiency = efficiency;` (the min) before the `if not update` zeroing (SourceBuildingEfficiencyState.gd:129-137), so potentialEfficiency is the pre-gate min efficiency (power.status fold) and stays 1.0 with full power even when shouldConsume is false (no targets) -- the tower therefore keeps refreshing with no targets; it only stops when power is gone or it is disabled (BuildingComp.java:1946, `potentialEfficiency = enabled && productionValid() ? 1f : 0f;` + 1955, the disabled branch zeroes all three). The query itself is NOT this slice: the effective radius is range + hitSize/2 per unit (`if(unit.within(x, y, radius + unit.hitSize/2f)){`, Units.java:449-451, from `public static void nearby(@Nullable Team team, float x, float y, float radius, Cons<Unit> cons){`, Units.java:445) and belongs to the future live-units query slice, which stamps the `nearby_damaged_units` observation on the frame; this pure function consumes the observed count, it does not produce it. RED decisions: absent `refresh` -> 0.0 (timer starts at 0; first refresh after exactly 6s of powered operation). Java inits the timer randomly (`public float refresh = Mathf.random(refreshInterval);`, RepairTower.java:47) -- the port takes the deterministic 0.0 start, a documented deviation pinned in the proof; no `randf` in the pure function (determinism; the C06DefenseProof lesson: seeded RNG only in proof scenes, never in game code). Absent `potential_efficiency` -> 0.0 (Java field default, BuildingComp.java:89, `transient float potentialEfficiency;`) -- no advance before the first consumption stamp. Absent `nearby_damaged_units` at expiry -> the timer refreshes but `targets_count` is NOT stamped (no observation yet -- the N2188 `has_target` precedent), so the follow-up shouldConsume gate must treat an absent `targets_count` as "no observation" and preserve the N2176 power-only behavior. The result is a 4-key dict: `refreshed` (the refresh fired this tick), `refresh` (the accumulated timer after this tick, 0.0 on expiry), `targets_count` (the stamped count on expiry when an observation exists, null otherwise) and `has_targets_count` (whether a count was stamped).
	var refresh: float = float(frame.get("refresh", 0.0))
	var potential_efficiency: float = float(frame.get("potential_efficiency", 0.0))
	if potential_efficiency <= 0.0:
		return {"refreshed": false, "refresh": refresh, "targets_count": null, "has_targets_count": false}
	refresh += delta
	if refresh < SOURCE_REPAIR_TOWER_REFRESH_INTERVAL:
		return {"refreshed": false, "refresh": refresh, "targets_count": null, "has_targets_count": false}
	var observed: Variant = frame.get("nearby_damaged_units", null)
	if observed == null:
		return {"refreshed": true, "refresh": 0.0, "targets_count": null, "has_targets_count": false}
	return {"refreshed": true, "refresh": 0.0, "targets_count": int(observed), "has_targets_count": true}

static func source_repair_tower_should_consume_state(frame: Dictionary) -> Dictionary:
	# RepairTowerBuild overrides shouldConsume (RepairTower.java:89, `public boolean shouldConsume(){` with `return targets.size > 0;`, RepairTower.java:90) over the target list (RepairTower.java:49, `public Seq<Unit> targets = new Seq<>();`), and updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){` + 1993, `efficiency = optionalEfficiency = 0f;`). The gate matters because with no targets requestedPower is 0 so power.status reads 1.0 (the row read, ConsumePower.java:39, `return build.power.status;`) while Java efficiency is 0 -- the N2176 gap this slice closes. A missing power stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`), and the power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`); edelta() is efficiency * delta (BuildingComp.java:1928, `return efficiency * delta();`). The frame carries the live target count as `targets_count` (int), stamped by the N2190 refresh on expiry when a `nearby_damaged_units` observation exists; the function reads it with a null default, so an absent key means "no observation yet", not "no targets": targets_count=0 blocks the gate, targets_count>0 with enabled passes it, targets_count>0 with enabled=false blocks it -- all three observed cases run through the one conjunction, `int(observed) > 0 and enabled`; NO targets_count key preserves the N2176 behavior, `should_consume = enabled`, because no placed-building frame carries a live targets count until the live-units query slice stamps `nearby_damaged_units` and a refresh expiry stamps `targets_count`, and defaulting absent to false would zero efficiency for every live repair tower. The gate activates when a refresh expiry stamps `targets_count` from the observed count (the refresh block is the ONLY writer of `targets`, RepairTower.java:59-66).
	var enabled: bool = bool(frame.get("enabled", true))
	var observed: Variant = frame.get("targets_count", null)
	if observed == null:
		return {"should_consume": enabled}
	return {"should_consume": int(observed) > 0 and enabled}

static func source_repair_tower_ozone_row_state(frame: Dictionary, delta: float) -> Dictionary:
	# The ozone liquid consumer row (ConsumeLiquid.java:42-48, `public float efficiency(Building build){`): the per-def ozone consumer (`consumeLiquid(Liquids.ozone, 3f / 60f);`, Blocks.java:6583, amount 0.05f/tick) folds into the first pass beside the power row. The fold is `float ed = build.edelta() * build.efficiencyScale();` (:43) with the first-pass efficiency assumed 1 (`efficiency = optionalEfficiency = 1f;`, BuildingComp.java:1966, `//assume efficiency is 1 for the calculations below`, :1967), so ed = 1.0 * delta * efficiency_scale (efficiencyScale() defaults 1f, BuildingComp.java:1940-1942); the guard `if(ed <= 0.00000001f) return 0f;` (:44) is CONSUME_EFFICIENCY_EPSILON (SourceConsumerDefaults.gd:4); the fold is `return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);` (:47) with the multiplier default 1f (`public Floatf<Building> multiplier = b -> 1f;`, Consume.java:18). The row goes through the generic helper SourceConsumeLiquidState.efficiency_state (the N2007 drill precedent -- it mirrors ConsumeLiquid.efficiency exactly, including the epsilon guard and the cap at 1). A non-power row <= 1e-7 clears should_consume_power (`if(cons != block.consPower && result <= 0.0000001f){` / `shouldConsumePower = false;`, BuildingComp.java:1972-1974, mirrored by update_consumption_non_optional_pass_state). RED decision (the N2191 absent-observation precedent, settled): absent key "ozone" in frame["liquids"] means NO observation, NOT an empty tank -- has_ozone_row false, the power-only fold is kept (folding absent to 0 would zero efficiency for every live tower); a present {"ozone": 0.0} (observed empty tank) folds to result 0.0. delta is the driver seconds (the N2228 precedent -- no separate time_scale, unlike N2187; timeScale != 1 stays deferred).
	var liquids: Variant = frame.get("liquids", null)
	if not (liquids is Dictionary) or not liquids.has("ozone"):
		return {"has_ozone_row": false, "row": {}}
	var stock: float = float(liquids.get("ozone", 0.0))
	var efficiency_scale: float = float(frame.get("efficiency_scale", 1.0))
	var result: float = float(SourceConsumeLiquidState.efficiency_state(stock, 0.05, delta, efficiency_scale, 1.0).get("efficiency", 0.0))
	return {"has_ozone_row": true, "row": {"result": result, "is_power": false}}

static func source_repair_tower_ozone_consume_state(frame: Dictionary, delta: float) -> Dictionary:
	# The ozone drain (ConsumeLiquid.java:37-38, `public void update(Building build){` / `build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));`): 0.05 * folded efficiency * delta per tick, with edelta = efficiency * delta (BuildingComp.java:1927-1928, `return efficiency * delta();`) and the multiplier default 1f (`public Floatf<Building> multiplier = b -> 1f;`, Consume.java:18). The drain is clamped at the stock (`//cap to prevent negative removal`, LiquidModule.java:125-127, `add(liquid, Math.max(-amount, -liquids[liquid.id]));`), so the tank never goes negative. It runs only in the second pass (`if(update && efficiency > 0){` / `for(var cons : block.updateConsumers){` / `cons.update(self());`, BuildingComp.java:1997-2000; `public boolean update = true;`, Consume.java:16, so ConsumeLiquid is in updateConsumers) -- the function gates on enabled and efficiency > 0.0 itself, the N2187 cryofluid precedent. The drain does NOT use the generic update_state, because that helper takes a numeric liquid_id the frame never carries (the frame keys liquids by slug, "ozone"), so the drain inlines the 3 lines like the N2187 cryofluid precedent. Absent key "ozone" means no observation: drain 0 and the dict unchanged.
	var efficiency: float = float(frame.get("efficiency", 1.0))
	var enabled: bool = bool(frame.get("enabled", true))
	var liquids_raw: Variant = frame.get("liquids", {})
	var liquids: Dictionary = liquids_raw.duplicate() if liquids_raw is Dictionary else {}
	var ozone_drained: float = 0.0
	if enabled and efficiency > 0.0 and liquids.has("ozone"):
		var drain: float = 0.05 * efficiency * delta
		var tank: float = float(liquids.get("ozone", 0.0))
		ozone_drained = minf(drain, tank)
		liquids["ozone"] = tank - ozone_drained
	return {"ozone_drained": ozone_drained, "liquids": liquids}

static func source_repair_tower_heal_advance_state(frame: Dictionary, targets: Array, heal_amount: float, delta: float, circle_speed: float, suppressed: bool) -> Dictionary:
	# The remainder of RepairTowerBuild.updateTile() (RepairTower.java:69-85): the suppression gate (`if(checkSuppression()){` / `warmup = 0f;` / `return;`, RepairTower.java:69-72) zeroes warmup and returns early -- no heal, no totalProgress advance. `boolean any = false;` (RepairTower.java:74) starts the heal loop, which runs only when `if(efficiency > 0){` (RepairTower.java:75) and heals each damaged target in the `targets` Seq (`for(var target : targets){` / `if(target.damaged()){` / `target.heal(healAmount * edelta());` / `any = true;`, RepairTower.java:76-81). damaged() is `health < maxHealth - 0.001f` (HealthComp.java:47-49, `return health < maxHealth - 0.001f;`), NOT `health < maxHealth`; the heal adds `healAmount * edelta()` and clamps at maxHealth (`health += amount;` / `clampHealth();`, HealthComp.java:109-111, with `health = Math.min(health, maxHealth);`, HealthComp.java:104). edelta() is efficiency * delta() (BuildingComp.java:1927-1928, `public float edelta(){` / `return efficiency * delta();`), and delta() is Time.delta * timeScale (BuildingComp.java:1922-1923) -- the driver passes its per-tick seconds as delta, the same `seconds` the N2190 refresh and the N2211 driver use, so the pure function reads edelta = efficiency * delta directly. The warmup lerp (`warmup = Mathf.lerpDelta(warmup, any ? efficiency : 0f, 0.08f);`, RepairTower.java:84) and the totalProgress advance (`totalProgress += Time.delta / circleSpeed;`, RepairTower.java:85) sit OUTSIDE the `if(efficiency > 0){` block -- they run on every non-suppressed tick. The lerp goes through the shared helper SourceMathState.source_lerp_delta (SourceMathState.gd:52-53, the N2215 strength-lerp math precedent). warmup and totalProgress are Java fields (`public float warmup = 0f;` / `public float totalProgress = 0f;`, RepairTower.java:52-53), default 0. The returned targets are DUPLICATES with the healed health -- the input list is not mutated, so the driver stamps the returned list (the N2213 precedent). Per-def healAmount is 1.5f (`healAmount = 1.5f;`, Blocks.java:6580); the class default is 1f (`public float healAmount = 1f;`, RepairTower.java:24) -- the driver resolves it from the block properties, the N2211 range precedent. The ozone liquid consumer (`consumeLiquid(Liquids.ozone, 3f / 60f);`, Blocks.java:6583) is NOT this slice: its fold needs a liquid-stock observation no frame carries yet. `suppressed` is a bool param (the driver reads `frame.get("heal_suppressed", false)`; no frame stamps it yet and the default false is the Java default, `healSuppressionTime = -1f`, BuildingComp.java:93); the bridges are the static funcs SourceBuildingLifecycleState.is_heal_suppressed_state (:408) and check_suppression_state (:463) -- N2228 calls neither; live suppression plumbing waits for its own slice.
	var warmup: float = float(frame.get("warmup", 0.0))
	var total_progress: float = float(frame.get("total_progress", 0.0))
	if suppressed:
		return {"suppressed": true, "any": false, "healed_count": 0, "warmup": 0.0, "total_progress": total_progress, "targets": targets, "heal_amount": 0.0}
	var efficiency: float = float(frame.get("efficiency", 1.0))
	var edelta: float = efficiency * delta
	var amount: float = heal_amount * edelta
	var healed_targets: Array = []
	var healed_count: int = 0
	if efficiency > 0.0:
		for target in targets:
			if not (target is Dictionary):
				healed_targets.append(target)
				continue
			var health: float = float(target.get("health", 0.0))
			var max_health: float = float(target.get("max_health", 0.0))
			var healed_target: Dictionary = target.duplicate()
			if health < max_health - 0.001:
				healed_target["health"] = min(health + amount, max_health)
				healed_count += 1
			healed_targets.append(healed_target)
	else:
		for target in targets:
			if target is Dictionary:
				healed_targets.append(target.duplicate())
			else:
				healed_targets.append(target)
	var any: bool = healed_count > 0
	warmup = SourceMathState.source_lerp_delta(warmup, efficiency if any else 0.0, 0.08, delta)
	total_progress += delta / circle_speed
	return {"suppressed": false, "any": any, "healed_count": healed_count, "warmup": warmup, "total_progress": total_progress, "targets": healed_targets, "heal_amount": amount}

static func source_repair_tower_set_stats_state(range: float, heal_amount: float, tilesize: float) -> Dictionary:
	# RepairTower.setStats() (RepairTower.java:35-41, `public void setStats(){`): `super.setStats();` (:37) is Block-level stat work (N1696), NOT this slice; this slice owns the two unconditional rows (`stats.add(Stat.range, range / tilesize, StatUnit.blocks);` -- :38 -- and `stats.add(Stat.repairSpeed, healAmount * 60f, StatUnit.perSecond);` -- :39). All three params are explicit per-def floats (the N2212 acquire / N2220 draw-place / N2224 setStats per-def-param precedent -- range and healAmount are per-def static state, not live frame keys): class defaults range 80f / healAmount 1f (`public float range = 80f;` / `public float healAmount = 1f;`, RepairTower.java:21, :24); unit-repair-tower 100f / 1.5f (`range = 100f;` / `healAmount = 1.5f;`, Blocks.java:6579-6580); tilesize is 8 (`public static final int tilesize = 8;`, Vars.java:135). The class is `public class RepairTower extends Block{` (RepairTower.java:18). NO driver tick line: setStats is a stat-display read, not a tick write (the N2224 RepairTurret setStats / N2220 draw-select/draw-place precedent).
	var range_blocks: float = range / tilesize
	var repair_speed_per_second: float = heal_amount * 60.0
	return {"stats": [{"stat": "range", "value": range_blocks, "unit": "blocks"}, {"stat": "repairSpeed", "value": repair_speed_per_second, "unit": "perSecond"}]}

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
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a repair tower does not take the early return. The repair tower's power draw is STATIC: `consumePower(1f);` (Blocks.java:6582) registers a plain ConsumePower, so the catalog consumePower 1.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. A repair tower with no power consumer is untouched: the tick models no other consumers yet (the updateTile advance waits for its own slice), and RepairTowerBuild overrides shouldConsume (RepairTower.java:89, `public boolean shouldConsume(){` with `return targets.size > 0;`, RepairTower.java:90) -- RED decision (the PointDefenseTurret N2151 precedent and the RepairTurret N2174 precedent): the port tracks no live target on any placed-building frame, so the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			# N2191 wires the shouldConsume gate through source_repair_tower_should_consume_state(frame): targets_count > 0 and enabled when a count observation is present, enabled when the frame carries no targets_count key (the N2176 behavior preserved; no live targets count is stamped on any placed-building frame yet).
			var should_consume: bool = bool(source_repair_tower_should_consume_state(frame).get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_repair_tower_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			# N2229 driver: the ozone row folds into the first pass beside the power row (ConsumeLiquid.java:42-48, `public float efficiency(Building build){` -- the per-def ozone consumer, `consumeLiquid(Liquids.ozone, 3f / 60f);`, Blocks.java:6583); the row appends to required_results only when an ozone observation exists (absent key means no observation, the N2191 precedent).
			var ozone_row: Dictionary = source_repair_tower_ozone_row_state(frame, seconds)
			if bool(ozone_row.get("has_ozone_row", false)):
				required_results.append(ozone_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# N2229 driver: the ozone drain is the second pass of updateConsumption (ConsumeLiquid.java:37-38, `public void update(Building build){` / `build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));`), which Java runs before updateTile (BuildingComp.java:2274 updateConsumption() runs before :2277 updateTile()) -- so the drain lands after apply_update_consumption_state and before the refresh / heal. frame["liquids"] is ensured a Dictionary first (the N2187 precedent); the driver stamps frame["ozone_drained"] and frame["liquids"] live.
			if not (frame.get("liquids") is Dictionary):
				frame["liquids"] = {}
			var ozone_consume: Dictionary = source_repair_tower_ozone_consume_state(frame, seconds)
			frame["ozone_drained"] = ozone_consume.get("ozone_drained", 0.0)
			frame["liquids"] = ozone_consume.get("liquids", {})
			# N2211 driver: stamp the live nearby-damaged count before the refresh consumes it (RepairTower.java:59, `if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){` — the gate is the potentialEfficiency this tick's updateConsumption just stamped, BuildingComp.java:1989, `potentialEfficiency = efficiency;` — so at no power no observation is stamped and the refresh cannot fire anyway). The query is the N2210 pure function (Units.java:445, `public static void nearby(@Nullable Team team, float x, float y, float radius, Cons<Unit> cons){`): the units list is the frame's `units` key (the N2141/N2144 precedent — no live units list is stamped on any frame yet, so the count stays 0 until a unit-list slice lands), the centre is the tower's world position (`sprite.position`, the turret-targeting precedent — Java passes the Building's own x, y), the radius is the per-def range (`block.properties.get("range", 80.0)` — 100f for unit-repair-tower, `range = 100f;`, Blocks.java:6579, falling back to the class default `public float range = 80f;`, RepairTower.java:21). The query runs every powered tick, not only on refresh expiry — the stamped count at expiry is the same value Java computes, because the refresh consumes the current tick's observation.
			if float(frame.get("potential_efficiency", 0.0)) > 0.0:
				var nearby_result: Dictionary = source_unit_runtime_state.source_units_nearby_damaged_count_state(frame.get("units", []), team_id, sprite.position.x, sprite.position.y, float(block.properties.get("range", 80.0)))
				frame["nearby_damaged_units"] = nearby_result.get("nearby_damaged_units", 0)
			# The target refresh is the updateTile half of this tick (BuildingComp.java:2274 updateConsumption() runs BEFORE :2277 updateTile()): the refresh block (RepairTower.java:59, `if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){`) reads the potentialEfficiency this tick's updateConsumption just stamped (BuildingComp.java:1989, `potentialEfficiency = efficiency;`), clears the targets (`targets.clear();`), resets the timer (`refresh = 0f;`) and re-queries the nearby damaged units (`Units.nearby(team, x, y, range, u -> {` / `if(u.damaged()){` / `targets.add(u);`); the query itself is NOT this slice -- the pure function consumes the observed count from the `nearby_damaged_units` frame key, it does not produce it. The driver writes `frame["refresh"]` from the result every call, and `frame["targets_count"]` only when the result carries a stamped count (`has_targets_count` true).
			var refresh_result: Dictionary = source_repair_tower_refresh_targets_state(frame, seconds)
			frame["refresh"] = refresh_result.get("refresh", 0.0)
			if bool(refresh_result.get("has_targets_count", false)):
				frame["targets_count"] = refresh_result.get("targets_count")
			# N2228 driver: the heal advance is the updateTile remainder (RepairTower.java:69-85) and runs AFTER the refresh in the same updateTile() (Java runs refresh :59-66 before heal :74-82, and updateConsumption() runs before updateTile(), BuildingComp.java:2274/2277). The suppression gate (`if(checkSuppression()){` / `warmup = 0f;` / `return;`, :69-72), the heal loop (`target.heal(healAmount * edelta());`, :78), the warmup lerp (`warmup = Mathf.lerpDelta(warmup, any ? efficiency : 0f, 0.08f);`, :84) and the totalProgress advance (`totalProgress += Time.delta / circleSpeed;`, :85) all run here. healAmount is the per-def value (`healAmount = 1.5f;`, Blocks.java:6580, falling back to the class default `public float healAmount = 1f;`, RepairTower.java:24 -- the N2211 range precedent); circleSpeed is 120f (RepairTower.java:23, Blocks does not override); `suppressed` reads `frame.get("heal_suppressed", false)` (no frame stamps it yet; default false is the Java default, `healSuppressionTime = -1f`, BuildingComp.java:93); `targets` reads `frame.get("targets", [])` (no frame stamps a live targets list yet -- with zero targets the advance still runs warmup/totalProgress, exactly Java with an empty list). The driver stamps `frame["warmup"]`, `frame["total_progress"]` and `frame["targets"]` (the healed duplicates) live.
			var heal_result: Dictionary = source_repair_tower_heal_advance_state(frame, frame.get("targets", []), float(block.properties.get("healAmount", 1.0)), seconds, 120.0, bool(frame.get("heal_suppressed", false)))
			frame["warmup"] = heal_result.get("warmup", 0.0)
			frame["total_progress"] = heal_result.get("total_progress", 0.0)
			frame["targets"] = heal_result.get("targets", [])
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
