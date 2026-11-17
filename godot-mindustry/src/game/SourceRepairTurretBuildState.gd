extends RefCounted
class_name SourceRepairTurretBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_unit_runtime_state := preload("res://src/game/SourceUnitRuntimeState.gd")

# The RepairTurret implementation (RepairTurret.java:25, `public class RepairTurret extends Block{`): repair-point (powerUse 1f, Blocks.java:6391, `powerUse = 1f;`; repairSpeed 0.45f, repairRadius 60f, Blocks.java:6388-6389) and repair-turret (powerUse 5f, Blocks.java:6402, `powerUse = 5f;`; size 2, repairSpeed 3f, repairRadius 145f, Blocks.java:6398-6401). RepairTurret extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_repair_turret_building", the radar precedent), and this slice adds the repair-turret key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceRepairTurret* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile heal advance (RepairTurret.java:207, `target.heal(repairSpeed * strength * edelta() * multiplier);`) heals by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a repair turret with no power would never heal -- its target's health would sit frozen as if power.status were 1.0.
const SOURCE_REPAIR_TURRET_BUILD_IMPLEMENTATIONS := ["RepairTurret"]
const SOURCE_REPAIR_TURRET_BUILDING_META_KEY := "source_repair_turret_building"

static func _is_repair_turret_build_implementation(implementation: String) -> bool:
	return SOURCE_REPAIR_TURRET_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_repair_turret_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The repair-turret tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (RepairTurret.java:25, `public class RepairTurret extends Block{`; RepairPointBuild, RepairTurret.java:153, `public class RepairPointBuild extends Building implements Ranged, RotBlock{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# repair turret skips consumption like Java's updateConsumption
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
	# for this repair turret (N2125); the tick preserves a disabled
	# repair turret instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_repair_turret_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the repair-turret frame meta key
	# ("source_repair_turret_building"). A RepairTurret sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_repair_turret_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_REPAIR_TURRET_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_REPAIR_TURRET_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_REPAIR_TURRET_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_repair_turret_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a repair turret does not take the early return. The repair turret's power draw is CONDITIONAL, not static: `consumePowerCond(powerUse, (RepairPointBuild entity) -> entity.target != null);` (RepairTurret.java:89), and ConsumePowerCondition only draws when its condition holds (ConsumePowerCondition.java:17, `return consume.get(entity) ? usage : 0f;`) -- the catalog consumePower None is CORRECT for this family, it records no static consumePower def; the two defs carry powerUse 1f (repair-point, Blocks.java:6391, `powerUse = 1f;`) and 5f (repair-turret, Blocks.java:6402, `powerUse = 5f;`), and the block declares `public float powerUse;` (RepairTurret.java:34) with `hasPower = true;` (RepairTurret.java:60). The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39) -- ConsumePowerCondition does not override efficiency(), so the row folds power.status exactly like the static case. The updateTile advance follows the folded efficiency: the heal advance (RepairTurret.java:207, `target.heal(repairSpeed * strength * edelta() * multiplier);`) heals by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a repair turret with no power would never heal. RepairPointBuild overrides shouldConsume (RepairTurret.java:221, `public boolean shouldConsume(){` with `return target != null && enabled;`, RepairTurret.java:222); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). RED decision (the PointDefenseTurret N2151 precedent): the port tracks no live target on any placed-building frame, so N2174 folded power-only and deferred the gate with a documented limit; N2188 wires the gate through source_repair_turret_should_consume_state(frame) -- with no target requestedPower is 0 so power.status reads 1.0 while Java efficiency is 0; the observable gap is efficiency 1.0 vs 0.0 with no target. The repair turret is its own family (RepairTurret.java:25, `public class RepairTurret extends Block{`; RepairPointBuild, RepairTurret.java:153, `public class RepairPointBuild extends Building implements Ranged, RotBlock{`). Two defs (repair-point, `powerUse = 1f;`, Blocks.java:6391; repair-turret, `powerUse = 5f;`, Blocks.java:6402).
	# Documented limits: (1) power-only first pass -- the repair turret's power consumer is conditional (ConsumePowerCondition, target-gated), so the folded efficiency is the min over the *modeled* consumers (power only); the coolant optional consumer (repair-turret only: ConsumeCoolant, acceptCoolant, coolantUse 0.16f, coolantMultiplier 1.6f, Blocks.java:6404-6406) is the second pass and waits for its own slice. (2) shouldConsume gate -- RepairPointBuild overrides shouldConsume (`target != null && enabled`, RepairTurret.java:221-223); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); N2188 wires the gate through source_repair_turret_should_consume_state(frame) -- with no target observation stamped yet the frame carries no has_target key, so the gate preserves the N2174 behavior (should_consume = enabled) until the future target-acquisition slice stamps it. (3) No updateTile heal advance -- target re-acquire / heal / rotation slerp / strength lerp (RepairTurret.java:187-218) wait for their own slices; the proof carries no heal/strength/rotation/target keys, the heal advance (RepairTurret.java:207) is what the efficiency keys prove. (4) Two defs -- repair-point (powerUse 1f) and repair-turret (powerUse 5f + coolant) share the one driver; repairSpeed / repairRadius / length / beamWidth / pulseRadius per-def values wait for their own verification slice. (5) RepairTower (unit-repair-tower) is a different class and NOT covered by this driver.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_repair_turret_should_consume_state(frame: Dictionary) -> Dictionary:
	# RepairPointBuild overrides shouldConsume (RepairTurret.java:221, `public boolean shouldConsume(){` with `return target != null && enabled;`, RepairTurret.java:222) over the target field (RepairTurret.java:154, `public Unit target;`), and updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){` + 1993, `efficiency = optionalEfficiency = 0f;`). The gate matters because the power draw is conditional on the same field (RepairTurret.java:89, `consumePowerCond(powerUse, (RepairPointBuild entity) -> entity.target != null);`) and ConsumePowerCondition only draws when its condition holds (ConsumePowerCondition.java:17, `return consume.get(entity) ? usage : 0f;`), so with no target power.status reads 1.0 (the row read, ConsumePower.java:39, `return build.power.status;`) while Java efficiency is 0 -- the N2174 gap this slice closes. A missing power stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`), and the power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`); edelta() is efficiency * delta (BuildingComp.java:1928, `return efficiency * delta();`). The frame carries the live target observation as `has_target` (bool); the function reads it with a null default, so an absent key means "no observation yet", not "no target": has_target=false blocks the gate, has_target=true with enabled passes it, has_target=true with enabled=false blocks it -- all three observed cases run through the one conjunction, `bool(has_target) and enabled`; NO has_target key preserves the N2174 behavior, `should_consume = enabled`, because no placed-building frame carries a live target today and defaulting absent to false would zero efficiency for every live repair turret. The gate activates when the future target-acquisition slice stamps `has_target` from `Units.closest(team, x, y, repairRadius, Unit::damaged)` (RepairTurret.java:216) plus the null-out conditions (RepairTurret.java:193-195).
	var enabled: bool = bool(frame.get("enabled", true))
	var has_target: Variant = frame.get("has_target", null)
	if has_target == null:
		return {"should_consume": enabled}
	return {"should_consume": bool(has_target) and enabled}

static func source_repair_turret_coolant_multiplier_state(frame: Dictionary, accept_coolant: bool, coolant_multiplier: float) -> Dictionary:
	# RepairPointBuild.updateTile computes the heal multiplier as `float multiplier = 1f;` then `if(acceptCoolant){ multiplier = 1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency; }` (RepairTurret.java:188-190), and heals with it: `target.heal(repairSpeed * strength * edelta() * multiplier);` (RepairTurret.java:207). The coolant consumer is registered only when the block accepts coolant: `if(acceptCoolant){ hasLiquids = true; consume(new ConsumeCoolant(coolantUse)).optional(true, true); }` (RepairTurret.java:84-86), and it is OPTIONAL, so its efficiency folds into optionalEfficiency in the optional pass (BuildingComp.java:1979-1981, `optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));`), which updateConsumption initializes to 1f before the pass (BuildingComp.java:1965, `efficiency = optionalEfficiency = 1f;`). Per-def, only repair-turret accepts coolant: `coolantUse = 0.16f;` + `coolantMultiplier = 1.6f;` + `acceptCoolant = true;` (Blocks.java:6404-6406); class defaults are `public boolean acceptCoolant = false;` and `public float coolantMultiplier = 1f;` (RepairTurret.java:39/45), so repair-point never boosts. Java's `current()` can never be null in practice (`private Liquid current = content.liquid(0);`, LiquidModule.java:24), but the port frame carries no liquid observation yet, and absent means "no observation", not "a liquid with zero heat capacity" -- the observable (multiplier 1.0) is the same either way. coolantUse is NOT a parameter: it belongs to the ConsumeCoolant consumer's efficiency/update (the optional coolant row that folds optionalEfficiency from the liquid amount), which waits for its own slice; the multiplier formula never reads it. No driver tick line: the multiplier feeds the updateTile heal advance, which waits for its own slice (the N2208 precedent).
	if not accept_coolant:
		return {"heal_multiplier": 1.0, "coolant_active": false}
	var heat_capacity: float = float(frame.get("liquids_current_heat_capacity", 0.0))
	var optional_efficiency: float = float(frame.get("optional_efficiency", 1.0))
	return {"heal_multiplier": 1.0 + heat_capacity * coolant_multiplier * optional_efficiency, "coolant_active": true}

static func _repair_radius_for_block_id(block_id: String) -> float:
	# Per-def repairRadius (the catalog carries no
	# repairRadius, so the driver resolves it from the block
	# id, the N2209 per-def-param precedent): repair-point
	# 60f (`repairRadius = 60f;`, Blocks.java:6389),
	# repair-turret 145f (`repairRadius = 145f;`,
	# Blocks.java:6400), class default 50f
	# (`public float repairRadius = 50f;`, RepairTurret.java:31).
	if block_id == "repair-point":
		return 60.0
	if block_id == "repair-turret":
		return 145.0
	return 50.0

static func _repair_speed_for_block_id(block_id: String) -> float:
	# Per-def repairSpeed (the catalog carries no
	# repairSpeed, so the driver resolves it from the block
	# id, the N2209 per-def-param precedent): repair-point
	# 0.45f (`repairSpeed = 0.45f;`, Blocks.java:6388),
	# repair-turret 3f (`repairSpeed = 3f;`,
	# Blocks.java:6400), class default 0.3f
	# (`public float repairSpeed = 0.3f;`, RepairTurret.java:32).
	if block_id == "repair-point":
		return 0.45
	if block_id == "repair-turret":
		return 3.0
	return 0.3

static func source_repair_turret_target_acquire_state(frame: Dictionary, units: Array, team_id: int, x: float, y: float, repair_radius: float, delta: float) -> Dictionary:
	# RepairPointBuild.updateTile target acquisition
	# (RepairTurret.java:193-199 + 214-217): the target is
	# nulled when it dies, walks out of range, or is fully
	# healed (`if(target != null && (target.dead() || target.dst(this) - target.hitSize/2f > repairRadius || target.health() >= target.maxHealth())){` / `target = null;`, RepairTurret.java:193-195), the beam offset is zeroed whenever there is no target (`if(target == null){` / `offset.setZero();`, RepairTurret.java:197-199), and the target is re-acquired every 20s through the closest damaged ally in range (`if(timer(timerTarget, 20)){` / `rect.setSize(repairRadius * 2).setCenter(x, y);` / `target = Units.closest(team, x, y, repairRadius, Unit::damaged);`, RepairTurret.java:214-217). The timer slot is `public int timerTarget = timers++;` (RepairTurret.java:29) on a per-building Interval (`transient Interval timer = new Interval(6);`, TimerComp.java:8); `timer()` (TimerComp.java:10-12, `public boolean timer(int index, float time){` / `if(Float.isInfinite(time)) return false;` / `return timer.get(index, time);`) delegates to `Interval.get`, which fires on elapsed game time (`return Time.time - times[id] >= time || Time.time < times[id];`, Interval.java:32, times[] init 0, so the first fire is at Time.time >= 20) and stamps the fire time (`if(got) times[id] = Time.time;`, Interval.java:31). The port models this with a per-frame accumulator `target_timer += delta; if target_timer >= 20.0: fire, target_timer = 0` -- reset-to-0 drops overshoot exactly like `Interval.get`; do NOT subtract the interval (that would carry overshoot and drift the re-acquire cadence vs Java). The invalidation reads the CURRENT unit record: the stored target is looked up by `id` in the units list (the stored dict is a snapshot, Java holds a live reference over `public Unit target;`, RepairTurret.java:154; a target whose id is absent from the list is gone, so it is dropped, and a stored target with no id cannot be re-identified, so it is dropped too). The health check is PLAIN `health >= maxHealth` (no 0.001 epsilon, unlike `damaged()`); the distance check is Euclidean dst minus hitSize/2, STRICTLY greater than repairRadius. The re-acquire replaces the target unconditionally on fire -- even a still-valid one is re-picked. The result is a 5-key dict: `target` (the target dict after this tick, null when none), `has_target` (the observation the N2188 shouldConsume gate reads, `return target != null && enabled;`, RepairTurret.java:222), `target_timer` (the accumulator after this tick, 0.0 on a fire), `offset` (the beam offset after this tick, zeroed whenever there is no target), and `reacquired` (whether the 20s timer fired this tick). The heal advance (RepairTurret.java:200-212) is NOT this slice -- it waits for its own slice.
	var target: Variant = frame.get("target", null)
	var target_timer: float = float(frame.get("target_timer", 0.0)) + delta
	var offset: Vector2 = frame.get("offset", Vector2.ZERO)
	var reacquired: bool = false
	if target is Dictionary:
		var target_id: int = int(target.get("id", -1))
		var fresh: Dictionary = {}
		for unit in units:
			if unit is Dictionary and target_id >= 0 and int(unit.get("id", -1)) == target_id:
				fresh = unit
				break
		if fresh.is_empty():
			target = null
		else:
			var dead: bool = bool(fresh.get("dead", false))
			var target_x: float = float(fresh.get("x", 0.0))
			var target_y: float = float(fresh.get("y", 0.0))
			var hit_size: float = float(fresh.get("hit_size", 6.0))
			var health: float = float(fresh.get("health", 0.0))
			var max_health: float = float(fresh.get("max_health", 1.0))
			var dist: float = sqrt((target_x - x) * (target_x - x) + (target_y - y) * (target_y - y))
			if dead or dist - hit_size / 2.0 > repair_radius or health >= max_health:
				target = null
	if target == null:
		offset = Vector2.ZERO
	if target_timer >= 20.0:
		target_timer = 0.0
		reacquired = true
		var query: Dictionary = source_unit_runtime_state.source_units_closest_damaged_state(units, team_id, x, y, repair_radius)
		target = query.get("target", null)
		if target == null:
			offset = Vector2.ZERO
	return {"target": target, "has_target": target != null, "target_timer": target_timer, "offset": offset, "reacquired": reacquired}

static func source_repair_turret_heal_advance_state(frame: Dictionary, x: float, y: float, repair_speed: float, delta: float, multiplier: float) -> Dictionary:
	# RepairPointBuild.updateTile heals the acquired target only when it has efficiency and the beam is aimed at it (RepairTurret.java:203-207):
	# if(target != null && efficiency > 0){
	# float angle = Angles.angle(x, y, target.x + offset.x, target.y + offset.y);
	# if(Angles.angleDist(angle, rotation) < 30f){
	# healed = true;
	# target.heal(repairSpeed * strength * edelta() * multiplier);
	# edelta() is efficiency * delta() (BuildingComp.java:1927-1928):
	# public float edelta(){
	# return efficiency * delta();
	# delta() is Time.delta * timeScale (BuildingComp.java:1922-1923):
	# public float delta(){
	# return Time.delta * timeScale;
	# HealthComp.heal(float) adds the amount and clamps (HealthComp.java:109-111, with HealthComp.java:104):
	# void heal(float amount){
	# health += amount;
	# clampHealth();
	# health = Math.min(health, maxHealth);
	# The frame carries the target dict (already validated by the N2212 acquire, which runs first in the same tick), rotation (Java field default 90, `public float strength, rotation = 90;`, RepairTurret.java:155), strength (Java field default 0), efficiency (folded, absent -> 1.0, the N2174 fold), and the beam offset (Vector2.ZERO when there is no target). The angle follows Angles.angle exactly: atan2(dx, dy) in degrees, normalized to [0, 360) (Angles.java:56-58):
	# float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;
	# if(ang < 0) ang += 360f;
	# The distance is the minimal circular distance, always in [0, 180] (Angles.java:23-26):
	# return Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a);
	# The cone is STRICT `< 30` (30.0 exactly does not heal). `healed` is set by the angle gate, not by the amount: Java sets `healed = true;` before the heal call, so a strength-0 turret still reports healed with a 0.0 amount. The returned target is a DUPLICATE with the healed health -- the input dict is not mutated, so the driver stamps the returned target. Rotation slerp and strength lerp are NOT this slice -- they wait for their own slices (the N2212 handoff deferral):
	# rotation = Mathf.slerpDelta(rotation, angle, 0.5f * efficiency * timeScale);
	# strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f * Time.delta);
	# UnitComp.heal(float) only sets the wasHealed flag (UnitComp.java:623-625):
	# wasHealed = true;
	# Per-def repairSpeed: repair-point 0.45f, repair-turret 3f (Blocks.java:6388/6400); class default 0.3f (RepairTurret.java:32):
	# public float repairSpeed = 0.3f;
	# repairSpeed = 0.45f;
	# repairSpeed = 3f;
	var target: Variant = frame.get("target", null)
	if not (target is Dictionary):
		return {"healed": false, "heal_amount": 0.0, "target": null, "target_health": 0.0}
	var efficiency: float = float(frame.get("efficiency", 1.0))
	var strength: float = float(frame.get("strength", 0.0))
	var rotation: float = float(frame.get("rotation", 90.0))
	var offset: Vector2 = frame.get("offset", Vector2.ZERO)
	var target_x: float = float(target.get("x", 0.0)) + offset.x
	var target_y: float = float(target.get("y", 0.0)) + offset.y
	var health: float = float(target.get("health", 0.0))
	var max_health: float = float(target.get("max_health", 1.0))
	if efficiency <= 0.0:
		return {"healed": false, "heal_amount": 0.0, "target": target, "target_health": health}
	var angle: float = fmod(rad_to_deg(atan2(target_x - x, target_y - y)) + 360.0, 360.0)
	var angle_dist: float = abs(fmod(angle - rotation, 360.0))
	if angle_dist > 180.0:
		angle_dist = 360.0 - angle_dist
	if angle_dist >= 30.0:
		return {"healed": false, "heal_amount": 0.0, "target": target, "target_health": health}
	var edelta: float = efficiency * delta
	var heal_amount: float = repair_speed * strength * edelta * multiplier
	var healed_target: Dictionary = target.duplicate()
	healed_target["health"] = min(health + heal_amount, max_health)
	return {"healed": true, "heal_amount": heal_amount, "target": healed_target, "target_health": float(healed_target["health"])}

static func source_repair_turret_rotation_slerp_state(frame: Dictionary, x: float, y: float, delta: float, time_scale: float) -> Dictionary:
	# RepairPointBuild.updateTile rotates the turret toward the acquired target after the heal (RepairTurret.java:209):
	# rotation = Mathf.slerpDelta(rotation, angle, 0.5f * efficiency * timeScale);
	# inside the same gate as the heal (RepairTurret.java:203):
	# if(target != null && efficiency > 0){
	# but OUTSIDE the aim cone (RepairTurret.java:205, `if(Angles.angleDist(angle, rotation) < 30f){`), which gates only the heal -- the slerp runs every tick with a target and efficiency > 0, even when the target is outside the cone. The angle is the same as the N2213 heal (RepairTurret.java:204):
	# float angle = Angles.angle(x, y, target.x + offset.x, target.y + offset.y);
	# Angles.angle is atan2(dx, dy) in degrees, normalized to [0, 360) (Angles.java:56-58):
	# float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;
	# if(ang < 0) ang += 360f;
	# Mathf.slerpDelta multiplies its progress by Time.delta and clamps to [0, 1] (Mathf.java:460-462):
	# public static float slerpDelta(float fromDegrees, float toDegrees, float progress){
	# return slerp(fromDegrees, toDegrees, clamp(progress * Time.delta));
	# and slerp always takes the shortest circular path, returning [0, 360) (Mathf.java:455-458):
	# public static float slerp(float fromDegrees, float toDegrees, float progress){
	# float delta = ((toDegrees - fromDegrees + 360 + 180) % 360) - 180;
	# return (fromDegrees + delta * progress + 360) % 360;
	# clamp with one argument clamps to [0, 1] (Mathf.java:402-403):
	# public static float clamp(float value){
	# return Math.max(Math.min(value, 1f), 0f);
	# timeScale is the Building's own field (BuildingComp.java:98):
	# private transient float timeScale = 1f, timeScaleDuration;
	# read through (BuildingComp.java:599-600):
	# public float timeScale(){
	# return timeScale;
	# -- NOT the global Time.timeScale. delta() is Time.delta * timeScale (BuildingComp.java:1922-1923):
	# public float delta(){
	# return Time.delta * timeScale;
	# and Time.delta is the per-frame delta (Time.java:15):
	# public static float delta = 1f;
	# -- the driver passes its per-tick seconds as delta, the same `seconds` the N2212 acquire and the N2213 heal use, so the pure function folds it as `0.5 * efficiency * time_scale * delta` and clamps. The frame carries the target dict (already validated by the N2212 acquire, which runs first in the same tick), rotation (Java field default 90, `public float strength, rotation = 90;`, RepairTurret.java:155), efficiency (folded, absent -> 1.0, the N2174 fold), and the beam offset (Vector2.ZERO when there is no target). The driver calls the slerp AFTER the N2213 heal in the same tick (the Java order: angle -> cone/heal -> slerp), because the heal reads the pre-slerp rotation for its cone check. The strength lerp is NOT this slice -- it waits for its own slice:
	# strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f * Time.delta);
	# time_scale has no live source in the port yet (no frame key stamps it), so the driver passes `frame.get("time_scale", 1.0)` -- the Java default 1f -- and a future timeScale slice only needs to stamp the frame key. The result carries ONLY rotation: angle is an intermediate like edelta in N2213, no consumer stamps it.
	var target: Variant = frame.get("target", null)
	var rotation: float = float(frame.get("rotation", 90.0))
	if not (target is Dictionary):
		return {"rotation": rotation}
	var efficiency: float = float(frame.get("efficiency", 1.0))
	if efficiency <= 0.0:
		return {"rotation": rotation}
	var offset: Vector2 = frame.get("offset", Vector2.ZERO)
	var target_x: float = float(target.get("x", 0.0)) + offset.x
	var target_y: float = float(target.get("y", 0.0)) + offset.y
	var angle: float = fmod(rad_to_deg(atan2(target_x - x, target_y - y)) + 360.0, 360.0)
	var progress: float = clampf(0.5 * efficiency * time_scale * delta, 0.0, 1.0)
	var angle_delta: float = fmod(angle - rotation + 360.0 + 180.0, 360.0) - 180.0
	var new_rotation: float = fmod(rotation + angle_delta * progress + 360.0, 360.0)
	return {"rotation": new_rotation}

static func source_repair_turret_strength_lerp_state(frame: Dictionary, delta: float) -> Dictionary:
	# RepairPointBuild.updateTile fades the beam strength toward 1 while healing and toward 0 otherwise (RepairTurret.java:212):
	# strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f * Time.delta);
	# The lerp sits OUTSIDE the `if(target != null && efficiency > 0){` gate (RepairTurret.java:203) -- it runs on EVERY tick, so a turret that stops healing decays its beam back to 0 instead of freezing at full strength. `healed` is the same tick's local (`boolean healed = false;`, RepairTurret.java:200, set `healed = true;` only inside the aim cone, RepairTurret.java:206, before the heal `target.heal(repairSpeed * strength * edelta() * multiplier);`, RepairTurret.java:207) -- the N2213 heal stamps it on the frame, so the pure function reads `frame["healed"]` (absent -> false, no heal observed). strength is a Java field (`public float strength, rotation = 90;`, RepairTurret.java:155), default 0. Mathf.lerpDelta multiplies its progress by Time.delta and clamps to [0, 1] (Mathf.java:430-432):
	# public static float lerpDelta(float fromValue, float toValue, float progress){
	# return lerp(fromValue, toValue, clamp(progress * Time.delta));
	# and lerp is the plain linear interpolation (Mathf.java:425-427):
	# public static float lerp(float fromValue, float toValue, float progress){
	# return fromValue + (toValue - fromValue) * progress;
	# clamp with one argument clamps to [0, 1] (Mathf.java:402-403):
	# public static float clamp(float value){
	# return Math.max(Math.min(value, 1f), 0f);
	# Time.delta is the per-frame delta (Time.java:15):
	# public static float delta = 1f;
	# -- the driver passes its per-tick seconds as delta, the same `seconds` the N2212 acquire, the N2213 heal and the N2214 slerp use, so the pure function folds it as `0.08 * delta` and clamps. The driver calls the lerp AFTER the N2214 slerp in the same tick (the Java order: angle -> cone/heal -> slerp -> strength lerp), because the heal reads the pre-lerp strength. This is the FIRST stamp of `frame["strength"]` -- before N2215 the N2213 heal read strength 0.0 forever, so no repair turret ever healed anything. The result carries ONLY strength.
	var strength: float = float(frame.get("strength", 0.0))
	var healed: bool = bool(frame.get("healed", false))
	var target_strength: float = 1.0 if healed else 0.0
	var progress: float = clampf(0.08 * delta, 0.0, 1.0)
	return {"strength": strength + (target_strength - strength) * progress}

static func source_repair_turret_draw_beam_state(frame: Dictionary, x: float, y: float, rotation: float, length: float, beam_width: float, pulse_stroke: float) -> Dictionary:
	# RepairPointBuild.draw() calls the static drawBeam (RepairTurret.java:171-173, inside `public void draw(){`, RepairTurret.java:164-174):
	# drawBeam(x, y, rotation, length, id, target, team, strength,
	# public static void drawBeam(float x, float y, float rotation, float length, int id, @Nullable Sized target, Team team,
	# float strength, float pulseStroke, float pulseRadius, float beamWidth,
	# Vec2 lastEnd, Vec2 offset,
	# Color laserColor, Color laserTopColor,
	# TextureRegion laser, TextureRegion laserEnd, TextureRegion laserTop, TextureRegion laserTopEnd){
	# rand.setSeed(id + (target instanceof Entityc e ? e.id() : 0));
	# The beam origin is the turret position plus the rotated length (RepairTurret.java:115-116):
	# originX = x + Angles.trnsx(rotation, length),
	# originY = y + Angles.trnsy(rotation, length);
	# With a target the endpoint is the target position relative to the origin, clamped to at least 2f (RepairTurret.java:118-119):
	# lastEnd.set(target).sub(originX, originY);
	# lastEnd.setLength(Math.max(2f, lastEnd.len()));
	# then the random jitter is added and the origin re-added (RepairTurret.java:121-125):
	# lastEnd.add(offset.trns(
	# rand.random(360f) + Time.time/2f,
	# Mathf.sin(Time.time + rand.random(200f), 55f, rand.random(target.hitSize() * 0.2f, target.hitSize() * 0.45f))
	# ).rotate(target instanceof Rotc rot ? rot.rotation() : 0f));
	# lastEnd.add(originX, originY);
	# -- the jitter is DEFERRED: it needs arc Rand modeling (three rand.random calls plus Time.time), so the endpoint this slice returns is the PRE-JITTER position. The whole endpoint branch is guarded by the target (RepairTurret.java:113):
	# if(target != null){
	# -- with no target Java leaves lastEnd untouched, so the function returns the frame's stored last_end (Vector2.ZERO when the frame carries none, the `new Vec2()` field default, `public Vec2 offset = new Vec2(), lastEnd = new Vec2();`, RepairTurret.java:155).
	# The laser draws only while the beam is strong (RepairTurret.java:129, STRICT -- 0.01f itself does not draw):
	# if(strength > 0.01f){
	# float f = (Time.time / 85f + rand.random(1f)) % 1f;
	# Draw.alpha(1f - Interp.pow5In.apply(f));
	# Lines.stroke(strength * pulseStroke);
	# Lines.circle(lastEnd.x, lastEnd.y, 1f + f * pulseRadius);
	# Drawf.laser(laser, laserEnd, originX, originY, lastEnd.x, lastEnd.y, strength * beamWidth);
	# -- the pulse phase (`float f = (Time.time / 85f + rand.random(1f)) % 1f;`) is DEFERRED with the jitter (same Rand + Time.time modeling), so there is no pulse-circle radius key: the pulse stroke (`strength * pulseStroke`, RepairTurret.java:141) and the laser width (`strength * beamWidth`, RepairTurret.java:145) are deterministic and ARE returned. strength is a Java field (`public float strength, rotation = 90;`, RepairTurret.java:155), default 0, stamped live by the N2215 lerp. Per-def length / beamWidth (the driver resolves them, the N2209 per-def-param precedent): repair-point length 5f class default (`public float length = 5f;`, RepairTurret.java:35), beamWidth 0.73f (Blocks.java:6390); repair-turret length 6f (Blocks.java:6399), beamWidth 1.1f (Blocks.java:6403); class defaults `public float length = 5f;` / `public float beamWidth = 1f;` (RepairTurret.java:35-36). pulseStroke is the 2f class default (`public float pulseStroke = 2f;`, RepairTurret.java:38), overridden by neither def; pulseRadius is the 6f class default (`public float pulseRadius = 6f;`, RepairTurret.java:37), repair-point 5f (Blocks.java:6392) / repair-turret 6.1f (Blocks.java:6404) -- it feeds only the deferred pulse circle. The driver calls this pure function once per tick AFTER the N2215 strength lerp (draw() runs after updateTile in the frame loop, so the beam reads the tick's final target/rotation/strength), stamping beam_origin, last_end (= beam_end), beam_visible, beam_width and pulse_stroke on the frame. Rendering itself stays out of the game -- only the state the beam depends on is captured, per the user boundary.
	var beam_origin: Vector2 = Vector2(x + cos(deg_to_rad(rotation)) * length, y + sin(deg_to_rad(rotation)) * length)
	var strength: float = float(frame.get("strength", 0.0))
	var target: Variant = frame.get("target", null)
	var has_target: bool = target is Dictionary
	var beam_end: Vector2 = frame.get("last_end", Vector2.ZERO)
	if has_target:
		var rel: Vector2 = Vector2(float(target.get("x", 0.0)), float(target.get("y", 0.0))) - beam_origin
		if rel.length() > 0.0:
			rel = rel.normalized() * maxf(2.0, rel.length())
		beam_end = beam_origin + rel
	return {"beam_origin": beam_origin, "beam_end": beam_end, "beam_visible": strength > 0.01, "beam_width": strength * beam_width, "pulse_stroke": strength * pulse_stroke, "has_target": has_target}

static func _beam_length_for_block_id(block_id: String) -> float:
	# Per-def length (the catalog carries no length, so the driver resolves it from the block id, the N2209 per-def-param precedent): repair-turret 6f (`length = 6f;`, Blocks.java:6399), repair-point the 5f class default (`public float length = 5f;`, RepairTurret.java:35).
	if block_id == "repair-turret":
		return 6.0
	return 5.0

static func _beam_width_for_block_id(block_id: String) -> float:
	# Per-def beamWidth (the catalog carries no beamWidth, so the driver resolves it from the block id, the N2209 per-def-param precedent): repair-point 0.73f (`beamWidth = 0.73f;`, Blocks.java:6390), repair-turret 1.1f (`beamWidth = 1.1f;`, Blocks.java:6403), class default 1f (`public float beamWidth = 1f;`, RepairTurret.java:36).
	if block_id == "repair-point":
		return 0.73
	if block_id == "repair-turret":
		return 1.1
	return 1.0

static func source_repair_turret_draw_select_state(x: float, y: float, repair_radius: float) -> Dictionary:
	# RepairPointBuild.drawSelect() draws one dash circle around the building (RepairTurret.java:177-179, inside `public void drawSelect(){`, RepairTurret.java:177):
	# Drawf.dashCircle(x, y, repairRadius, Pal.accent);
	# The radius is the per-def repairRadius, resolved by the caller through the existing `_repair_radius_for_block_id` helper (N2212): repair-point 60f (Blocks.java:6389), repair-turret 145f (Blocks.java:6401), class default 50f (`public float repairRadius = 50f;`, RepairTurret.java:32). The color is Pal.accent (SourceBlockDrawState.gd:182 precedent). There is no driver tick line: drawSelect is selection UI, not per-tick. Rendering itself stays out of the game -- only the state the circle depends on is captured, per the user boundary.
	return {"center": Vector2(x, y), "radius": repair_radius, "color": "Pal.accent"}

static func source_repair_turret_draw_place_state(tile_x: int, tile_y: int, repair_radius: float, tilesize: float, block_offset: float) -> Dictionary:
	# RepairTurret.drawPlace() draws the same dash circle at the ghost position (RepairTurret.java:95-100, inside `public void drawPlace(int x, int y, int rotation, boolean valid){`, RepairTurret.java:95, after `super.drawPlace(x, y, rotation, valid);`, RepairTurret.java:96 -- the super call draws the block itself, not the circle, so it is out of scope):
	# Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, repairRadius, Pal.accent);
	# The place center converts tile coords to world coords with the tilesize and the block offset (`x * tilesize + offset`, RepairTurret.java:98; tilesize 8, Vars.java:135). The radius is a world distance, not repairRadius / tilesize tiles. The color is Pal.accent in both call sites. There is no driver tick line: drawPlace is placement UI, not per-tick.
	var center: Vector2 = Vector2(float(tile_x) * tilesize + block_offset, float(tile_y) * tilesize + block_offset)
	return {"center": center, "radius": repair_radius, "color": "Pal.accent"}

static func _size_for_block_id(block_id: String) -> float:
	# Per-def Block.size in tiles (the catalog carries no
	# size, so the driver resolves it from the block id, the
	# N2209 per-def-param precedent): repair-turret 2
	# (`size = 2;`, Blocks.java:6398), repair-point the 1
	# class default (`public int size = 1;`, Block.java:215;
	# no override in Blocks.java:6386-6394).
	if block_id == "repair-turret":
		return 2.0
	return 1.0

static func source_repair_turret_draw_state(x: float, y: float, rotation: float, size: float) -> Dictionary:
	# RepairPointBuild.draw() (RepairTurret.java:164-174, inside `public void draw(){`, RepairTurret.java:164, `public class RepairTurret extends Block{`):
	# Draw.rect(baseRegion, x, y); -- :165, the base rect at (x, y) with no rotation;
	# Draw.z(Layer.turret); -- :167, the z-layer (`turret = 50,`, Layer.java:48);
	# Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90); -- :168, the shadow at (x - size/2f, y - size/2f) with angle rotation - 90;
	# Draw.rect(region, x, y, rotation - 90); -- :169, the region rect at (x, y) with angle rotation - 90;
	# then drawBeam (:171-173) -- N2219, NOT this slice.
	# The shadow offset quirk stays as Java wrote it: `size / 2f` is subtracted directly on world coords, NOT tilesize-scaled -- size is Block.size in tiles (class default 1, Block.java:215, `public int size = 1;`; repair-point has no override, Blocks.java:6386-6394; repair-turret 2, Blocks.java:6398, `size = 2;`), so repair-point offsets 0.5, repair-turret offsets 1.0. rotation defaults to 90 (the field init `public float strength, rotation = 90;`, RepairTurret.java:156). There IS a driver tick line: draw() runs every frame after updateTile in the frame loop, and the driver already calls draw_beam_state each tick (:664), so N2225 adds one draw_state call there, stamping draw_rotation, shadow_position, base_position and z_layer live. Rendering itself stays out of the game -- only the state draw() depends on is captured, per the user boundary.
	var draw_rotation: float = rotation - 90.0
	var shadow_position: Vector2 = Vector2(x - size / 2.0, y - size / 2.0)
	var base_position: Vector2 = Vector2(x, y)
	return {"draw_rotation": draw_rotation, "shadow_position": shadow_position, "base_position": base_position, "z_layer": 50.0}

static func _block_offset_for_block_id(block_id: String) -> float:
	# Per-def block offset (`offset = ((size + 1) % 2) * tilesize / 2f;`, Block.java:761, tilesize 8, Vars.java:135): repair-turret size 2 (Blocks.java:6398) so 4.0, repair-point size 1 (no size override in Blocks.java:6386) so 0.0, class default 0.0.
	if block_id == "repair-turret":
		return 4.0
	return 0.0

static func source_repair_turret_should_ambient_sound_state(frame: Dictionary) -> Dictionary:
	# RepairPointBuild.shouldAmbientSound() (RepairTurret.java:182, inside `public boolean shouldAmbientSound(){`, RepairTurret.java:181):
	# return target != null && efficiency > 0f;
	# The live target observation is `has_target` (stamped every tick by the N2212 acquire; absent means "no observation yet", so it reads false) and `efficiency` is the folded efficiency (stamped every tick by the driver via apply_update_consumption_state; absent folds to 1.0, the N2174 missing-stamp precedent). There is no driver tick line: shouldAmbientSound() is a read function (the ambient-sound gate BuildingComp.update() calls), not per-tick.
	var has_target: bool = bool(frame.get("has_target", false))
	var efficiency: float = float(frame.get("efficiency", 1.0))
	return {"should_ambient_sound": has_target and efficiency > 0.0}

static func source_repair_turret_status_state(frame: Dictionary, tick: float) -> Dictionary:
	# RepairPointBuild.status() (RepairTurret.java:226, inside `public BlockStatus status(){`, RepairTurret.java:225):
	# return Mathf.equal(potentialEfficiency, 0f, 0.01f) ? BlockStatus.noInput : super.status();
	# potentialEfficiency is a transient Java field (`transient float potentialEfficiency;`, BuildingComp.java:89), so an unticked frame reads 0.0 and reports noInput, exactly like Java before the first updateConsumption. Mathf.equal(potentialEfficiency, 0f, 0.01f) is `Math.abs(a - b) <= tolerance` (Mathf.java:554-556, arc-upstream/arc-core/src/arc/math/Mathf.java).
	# super.status() is BuildingComp.status() (BuildingComp.java:632-646):
	# if(!enabled){ return BlockStatus.logicDisable; }
	# if(!shouldConsume()){ return BlockStatus.noOutput; }
	# if(efficiency <= 0 || !productionValid()){ return BlockStatus.noInput; }
	# return ((state.tick / 30f) % 1f) < efficiency ? BlockStatus.active : BlockStatus.noInput;
	# The shouldConsume leg reuses source_repair_turret_should_consume_state (N2188) and productionValid is the canonical true default (source_building_access_state.production_valid_state()). The tick arrives as an explicit float param, not from the frame (the driver stamps no tick key). There is no driver tick line: status() is a read function, not per-tick.
	var potential_efficiency: float = float(frame.get("potential_efficiency", 0.0))
	if absf(potential_efficiency) <= 0.01:
		return {"status": source_building_access_state.SOURCE_BUILDING_STATUS_NO_INPUT}
	var enabled: bool = bool(frame.get("enabled", true))
	if not enabled:
		return {"status": source_building_access_state.SOURCE_BUILDING_STATUS_LOGIC_DISABLE}
	var should_consume: bool = bool(source_repair_turret_should_consume_state(frame).get("should_consume", true))
	if not should_consume:
		return {"status": source_building_access_state.SOURCE_BUILDING_STATUS_NO_OUTPUT}
	var efficiency: float = float(frame.get("efficiency", 1.0))
	var production_valid: bool = source_building_access_state.production_valid_state()
	if efficiency <= 0.0 or not production_valid:
		return {"status": source_building_access_state.SOURCE_BUILDING_STATUS_NO_INPUT}
	if fmod(tick / 30.0, 1.0) < efficiency:
		return {"status": source_building_access_state.SOURCE_BUILDING_STATUS_ACTIVE}
	return {"status": source_building_access_state.SOURCE_BUILDING_STATUS_NO_INPUT}

const SOURCE_REPAIR_TURRET_AMBIENT_SOUND := "beamHeal"
const SOURCE_REPAIR_TURRET_AMBIENT_SOUND_VOLUME := 1.0

static func source_repair_turret_ambient_sound_loop_state(frame: Dictionary, headless: bool) -> Dictionary:
	# BuildingComp.update() loops the ambient sound each tick (BuildingComp.java:2270-2271, inside `public void update(){`, BuildingComp.java:2262):
	# if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){
	# control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());
	# The sound is `Sounds.beamHeal` and its volume scale is `1f` (RepairTurret.java:66-67, set in the RepairTurret constructor, so both defs share them):
	# ambientSound = Sounds.beamHeal;
	# ambientSoundVolume = 1f;
	# The Block defaults they override (Block.java:351, :353):
	# public Sound ambientSound = Sounds.none;
	# public float ambientSoundVolume = 0.05f;
	# ambientVolume() is the folded efficiency (BuildingComp.java:2015-2017):
	# public float ambientVolume(){
	# return efficiency;
	# The shouldAmbientSound() leg reuses the N2221 pure function (RepairTurret.java:182):
	# return target != null && efficiency > 0f;
	# headless arrives as an explicit bool param (the SourceBlockGeometry precedent -- the port has no game-level headless flag yet). There is no driver tick line: the loop call is a sound side effect (control.sound.loop) with no sink in the port yet, and nothing consumes an ambient-loop stamp.
	var should_ambient_sound: bool = bool(source_repair_turret_should_ambient_sound_state(frame).get("should_ambient_sound", false))
	var efficiency: float = float(frame.get("efficiency", 1.0))
	var volume: float = SOURCE_REPAIR_TURRET_AMBIENT_SOUND_VOLUME * efficiency
	var should_loop: bool = (not headless) and SOURCE_REPAIR_TURRET_AMBIENT_SOUND != "none" and should_ambient_sound
	return {"should_loop": should_loop, "sound": SOURCE_REPAIR_TURRET_AMBIENT_SOUND, "volume": volume}

static func source_repair_turret_sense_state(frame: Dictionary, sensor: String, repair_radius: float, tilesize: float) -> Dictionary:
	# BuildingComp.sense reads the two RepairTurret-specific legs (BuildingComp.java:2093):
	# public double sense(LAccess sensor){
	# case range -> this instanceof Ranged r ? r.range() / tilesize : 0;
	# case rotation -> rotation;
	# RepairPointBuild implements Ranged (RepairTurret.java:153):
	# public class RepairPointBuild extends Building implements Ranged, RotBlock{
	# with range() returning repairRadius (RepairTurret.java:231-232):
	# public float range(){
	# return repairRadius;
	# and its rotation field defaulting to 90 (RepairTurret.java:156):
	# public float strength, rotation = 90;
	# read by buildRotation() (RepairTurret.java:158-161):
	# return rotation;
	# The class-default radius (RepairTurret.java:32):
	# public float repairRadius = 50f;
	# repair-point 60f and repair-turret 145f (Blocks.java:6389, :6401). The world tilesize (Vars.java:135):
	# public static final int tilesize = 8;
	# The sensor spellings are the LAccess enum names (LAccess.java:48, `range,`; LAccess.java:30, `rotation,`). Any other sensor falls through to the switch default (BuildingComp.java:2123):
	# default -> Float.NaN; //gets converted to null in logic
	# repair_radius and tilesize are explicit float params (the N2212 acquire / N2220 draw-place per-def-param precedent -- repairRadius is per-def static state, not a live frame key); rotation is the live frame key (stamped by the N2214 slerp + N2217 read/write), absent folding to 90.0, the Java field init. There is no driver tick line: sense is a logic read, not a tick write (the N2206 launch-pad / N2208 mass-driver sense precedent); the logic-processor dispatch hook is its own later slice.
	if sensor == "range":
		var range_value: float = repair_radius / tilesize
		return {"handled": true, "sense_value": range_value, "sense_value_is_nan": false}
	if sensor == "rotation":
		var observed: Variant = frame.get("rotation", null)
		var rotation_value: float = 90.0 if observed == null else float(observed)
		return {"handled": true, "sense_value": rotation_value, "sense_value_is_nan": false}
	return {"handled": false, "sense_value": null, "sense_value_is_nan": true}

static func source_repair_turret_sense_object_state(sensor: String, block_id: String) -> Dictionary:
	# BuildingComp.senseObject() (BuildingComp.java:2128-2136, inside `public Object senseObject(LAccess sensor){`, BuildingComp.java:2128):
	# return switch(sensor){
	# case type -> block;
	# case firstItem -> items == null ? null : items.first();
	# case config -> block.configSenseable() ? config() : null;
	# case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null;
	# default -> noSensed;
	# };
	# The sensor spellings are the LAccess enum names (LAccess.java:8; LAccess.java:63; LAccess.java:69; LAccess.java:83):
	#     firstItem,
	#     type,
	#     payloadType,
	#     config(true, "to"),
	# The `type` leg returns the block itself; the port identity of a block is its id string (the same key every `_..._for_block_id` helper resolves): repair-point (`repairPoint = new RepairTurret("repair-point"){{`, Blocks.java:6386) and repair-turret (`repairTurret = new RepairTurret("repair-turret"){{`, Blocks.java:6397).
	# The three middle legs are all null for a repair turret, pinned not guessed. `firstItem` is null because the items module is never created: `hasItems` is false by default (`public @NoPatch boolean hasItems;`, Block.java:45) and RepairTurret never sets it, so `if(block.hasItems) items = new ItemModule();` (BuildingComp.java:145) never runs and `items == null`. `config` is null because RepairTurret registers no `config()` call, so `configurations` (`public ObjectMap<Class<?>, Cons2> configurations = new ObjectMap<>();`, Block.java:402) stays empty and `configSenseable()` (`public boolean configSenseable(){`, Block.java:809, `return configurations.containsKey(Item.class) || configurations.containsKey(Liquid.class) || configurations.containsKey(UnlockableContent.class) ||` / `configurations.containsKey(Block.class) || configurations.containsKey(UnitType.class);`, Block.java:810-811) is false -- the short-circuit returns null regardless of `config()`. `payloadType` is null because the base `getPayload()` returns null (`public @Nullable Payload getPayload(){`, BuildingComp.java:984, `return null;`, BuildingComp.java:985) and RepairTurret does not override it.
	# An unhandled sensor falls through to the `noSensed` sentinel (`Object noSensed = new Object();`, Senseable.java:6), which the logic converts to a numeric `sense()` fallback (`if(objOut == Senseable.noSensed){` / `to.setnum(se.sense(la));`, LExecutor.java:697-698) -- the port reports it as `handled: false` + `is_no_sensed: true`, the sense() N2223 `sense_value_is_nan` precedent, so the caller knows to fall back to `source_repair_turret_sense_state`. RepairPointBuild is the building (`public class RepairPointBuild extends Building implements Ranged, RotBlock{`, RepairTurret.java:153) of the block (`public class RepairTurret extends Block{`, RepairTurret.java:25). There is no driver tick line: senseObject is a logic read, not a tick write (the N2223 sense / N2230 setStats precedent); the logic-processor dispatch hook is its own later slice.
	if sensor == "type":
		return {"handled": true, "sense_object": block_id, "is_no_sensed": false}
	if sensor == "firstItem" or sensor == "config" or sensor == "payloadType":
		return {"handled": true, "sense_object": null, "is_no_sensed": false}
	return {"handled": false, "sense_object": null, "is_no_sensed": true}

static func source_repair_turret_range_state(repair_radius: float) -> Dictionary:
	# RepairPointBuild.range() (RepairTurret.java:230-233):
	# public float range(){
	# return repairRadius;
	# from the Ranged interface (Ranged.java:5-6):
	# public interface Ranged extends Posc, Teamc{
	# float range();
	# RepairPointBuild implements Ranged (RepairTurret.java:153):
	# public class RepairPointBuild extends Building implements Ranged, RotBlock{
	# of the block (RepairTurret.java:1):
	# public class RepairTurret extends Block{
	# The per-def repairRadius: class default 50f
	# (RepairTurret.java:32):
	# public float repairRadius = 50f;
	# repair-point 60f (Blocks.java:6389):
	# repairRadius = 60f;
	# repair-turret 145f (Blocks.java:6401):
	# repairRadius = 145f;
	# repair_radius is an explicit float param (the N2212
	# acquire / N2220 draw-place per-def-param precedent --
	# repairRadius is per-def static state, not a live frame
	# key; resolved by the existing
	# `_repair_radius_for_block_id` helper). There is no
	# driver tick line: range() is a pure read (the N2223
	# sense / N2230 setStats / N2232 RepairTower range+warmup
	# precedent).
	return {"range": repair_radius}

static func source_repair_turret_build_rotation_state(frame: Dictionary) -> Dictionary:
	# RepairPointBuild.buildRotation() (RepairTurret.java:158-161):
	# public float buildRotation(){
	# return rotation;
	# from the RotBlock interface (RotBlock.java:4-5):
	# public interface RotBlock{
	# float buildRotation();
	# RepairPointBuild implements RotBlock (RepairTurret.java:153):
	# public class RepairPointBuild extends Building implements Ranged, RotBlock{
	# The rotation field defaults to 90 (RepairTurret.java:156):
	# public float strength, rotation = 90;
	# rotation is the live frame key (stamped by the N2214
	# slerp + N2217 read/write), absent folding to 90.0, the
	# Java field init (the N2223 sense(rotation) precedent).
	# There is no driver tick line: buildRotation() is a pure
	# read (the N2223 sense / N2230 setStats / N2232
	# RepairTower range+warmup precedent).
	return {"build_rotation": float(frame.get("rotation", 90.0))}

static func source_repair_turret_set_stats_state(repair_radius: float, repair_speed: float, accept_coolant: bool, coolant_use: float, coolant_multiplier: float, tilesize: float) -> Dictionary:
	# RepairTurret.setStats() (RepairTurret.java:75-84):
	# public void setStats(){
	# super.setStats();
	# stats.add(Stat.range, repairRadius / tilesize, StatUnit.blocks);
	# stats.add(Stat.repairSpeed, repairSpeed * 60f, StatUnit.perSecond);
	# if(acceptCoolant){
	# stats.remove(Stat.booster);
	# stats.add(Stat.booster, StatValues.speedBoosters(Core.bundle.get("bar.strength"), coolantUse, coolantMultiplier, true, this::consumesLiquid));
	# }
	# The `super.setStats();` leg (:76) is Block-level stat work (N1696), NOT this slice; this slice owns the two unconditional rows (:77-:78) and the coolant-gated booster row (:80-:82).
	# The booster value builder (StatValues.java:506):
	# public static StatValue speedBoosters(String unit, float amount, float speed, boolean strength, Boolf<Liquid> filter){
	# The class (RepairTurret.java:27):
	# public class RepairTurret extends Block{
	# Class defaults (RepairTurret.java:32, :33, :40, :42, :45):
	# public float repairRadius = 50f;
	# public float repairSpeed = 0.3f;
	# public boolean acceptCoolant = false;
	# public float coolantUse = 0.5f;
	# public float coolantMultiplier = 1f;
	# The world tilesize (Vars.java:135):
	# public static final int tilesize = 8;
	# repair-point 60f / 0.45f and repair-turret 145f / 3f / acceptCoolant true / coolantUse 0.16f / coolantMultiplier 1.6f (Blocks.java:6389, :6388, :6401, :6400, :6404, :6405, :6406).
	# There is no driver tick line: setStats is a stat-display read, not a tick write (the N2220 draw-select/draw-place precedent); the proof calls the pure function directly with per-def params.
	var range_blocks: float = repair_radius / tilesize
	var repair_speed_per_second: float = repair_speed * 60.0
	return {"range_blocks": range_blocks, "repair_speed_per_second": repair_speed_per_second, "booster_present": accept_coolant, "booster_coolant_use": coolant_use, "booster_coolant_multiplier": coolant_multiplier}

static func source_repair_turret_init_state(repair_radius: float, tilesize: float) -> Dictionary:
	# RepairTurret.init() (RepairTurret.java:83-92):
	# public void init(){
	# if(acceptCoolant){
	# hasLiquids = true;
	# consume(new ConsumeCoolant(coolantUse)).optional(true, true);
	# }
	# consumePowerCond(powerUse, (RepairPointBuild entity) -> entity.target != null);
	# updateClipRadius(repairRadius + tilesize);
	# super.init();
	# This slice pins ONLY the updateClipRadius call argument (:90): clip_radius = repair_radius + tilesize. The coolant leg (:84-86) registers a coolant consumer and waits for its own slice; the consumePowerCond leg (:89) registers a power-condition consumer and waits for its own slice; `super.init();` (:91) is Block.init internals, deferred (the N1234 TractorBeamTurret.init() precedent: "Inherited BaseTurret.init internals and Block.updateClipRadius side effects remain deferred; this slice records the exact TractorBeamTurret updateClipRadius argument"). The Block.updateClipRadius side effect itself (`clipSize = Math.max(clipSize, this.size * tilesize + radiusInWorldUnits * 2f);`, Block.java:1007, `public void updateClipRadius(float radiusInWorldUnits){`, Block.java:1006) is likewise deferred -- only the call argument is pinned.
	# Class defaults (RepairTurret.java:32): `public float repairRadius = 50f;` -- repair-point 60f (`repairRadius = 60f;`, Blocks.java:6389), repair-turret 145f (`repairRadius = 145f;`, Blocks.java:6401). The world tilesize (Vars.java:135): `public static final int tilesize = 8;`. So clip_radius is 58.0 / 68.0 / 153.0 per def.
	# The class (RepairTurret.java:25): `public class RepairTurret extends Block{`.
	# There is no driver tick line: init() runs once at block init, not per tick (the N2217 read/write + N2224 setStats lifecycle precedent).
	var clip_radius: float = repair_radius + tilesize
	return {"clip_radius": clip_radius}

static func source_repair_turret_icons_state(base_region: Variant, region: Variant) -> Dictionary:
	# RepairTurret.icons() (RepairTurret.java:101-104):
	# @Override
	# public TextureRegion[] icons(){
	# return new TextureRegion[]{baseRegion, region};
	# }
	# This slice pins ONLY the override's two-element return array, base first. baseRegion is the block's own base field (RepairTurret.java:47): `public @Load(value = "@-base", fallback = "block-@size") TextureRegion baseRegion;` -- loaded as name + "-base" with the "block-@size" fallback. region is the inherited block region (Block.java:427): `public TextureRegion region;` -- the block's own region, the block name. The Block.icons() base (`protected TextureRegion[] icons(){`, Block.java:976-980, the variants/teamRegion fold) is NOT this slice: RepairTurret overrides it. The getGeneratedIcons cache (`public TextureRegion[] getGeneratedIcons(){`, Block.java:986, `return generatedIcons == null ? (generatedIcons = icons()) : generatedIcons;`, Block.java:987) is likewise deferred -- only the override's return array is pinned (the N1232 TractorBeamTurret.icons() precedent: "TextureRegion internals and inherited region loading remain deferred; explicit inputs carry baseRegion and region field values", pinned as the identity pure function source_tractor_beam_turret_icons_state).
	# The class (RepairTurret.java:25): `public class RepairTurret extends Block{`.
	# Per-def region ids: repair-point ("repair-point", Blocks.java:6386) -> ["repair-point-base", "repair-point"]; repair-turret ("repair-turret", Blocks.java:6396) -> ["repair-turret-base", "repair-turret"].
	# There is no driver tick line: icons() is a load-time region accessor, not a per-tick write (the N2217 read/write + N2224 setStats lifecycle precedent).
	var icons: Array = [base_region, region]
	return {"icons": icons}

const REPAIR_TURRET_SAVE_VERSION := 1

static func source_repair_turret_write_state(frame: Dictionary) -> Dictionary:
	# RepairPointBuild persists exactly ONE field, its rotation
	# (RepairTurret.java:236-239):
	# public void write(Writes write){
	# super.write(write);
	# write.f(rotation);
	# The rotation default is 90.0 (`public float strength, rotation = 90;`, RepairTurret.java:156).
	# Strength is NOT persisted -- it is re-lerped every tick
	# (`strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f * Time.delta);`, RepairTurret.java:212),
	# so a loaded turret rebuilds it from 0. Target is NOT persisted
	# either -- it is re-acquired by the 20-tick timer
	# (`target = Units.closest(team, x, y, repairRadius, Unit::damaged);`, RepairTurret.java:216).
	# The write returns ONLY rotation (the proof checks the result has exactly one key).
	# There is NO driver tick line: persistence is not a per-tick call, and the port has no save/load stream to call this function yet.
	var rotation: float = float(frame.get("rotation", 90.0))
	return {"rotation": rotation}

static func source_repair_turret_read_state(frame: Dictionary, saved_rotation: float, revision: int) -> Dictionary:
	# RepairPointBuild restores the rotation only for saves written at revision >= 1
	# (RepairTurret.java:243-248):
	# public void read(Reads read, byte revision){
	# super.read(read, revision);
	# if(revision >= 1){
	# rotation = read.f();
	# because the save version is 1 (RepairTurret.java:252-254):
	# public byte version(){
	# return 1;
	# A revision-0 save leaves the turret pointing where it already
	# points -- the frame's current rotation (default 90.0, `public float strength, rotation = 90;`, RepairTurret.java:156).
	# Strength is NOT persisted -- it is re-lerped every tick
	# (`strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f * Time.delta);`, RepairTurret.java:212) --
	# and target is NOT persisted either -- it is re-acquired by the 20-tick timer
	# (`target = Units.closest(team, x, y, repairRadius, Unit::damaged);`, RepairTurret.java:216).
	# There is NO driver tick line: persistence is not a per-tick call, and the port has no save/load stream to call this function yet.
	var rotation: float = float(frame.get("rotation", 90.0))
	if revision >= 1:
		rotation = saved_rotation
	return {"rotation": rotation}

static func source_repair_turret_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the repair-turret tick wiring every
	# tick (RepairPointBuild.updateTile(), RepairTurret.java:187,
	# advances the heal by the heal advance (RepairTurret.java:207, `target.heal(repairSpeed * strength * edelta() * multiplier);`), so the heal advance follows the folded efficiency; no placed-buildings driver ticks RepairTurret blocks, so this driver is the placed-repair-turret tick): each placed RepairTurret build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_repair_turret_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_repair_turret_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_repair_turret_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a repair turret with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the heal advance (RepairTurret.java:207)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a repair turret does not take the early return. The driver gate reads the conditional consumer through the catalog: the conditional registration (RepairTurret.java:89, `consumePowerCond(powerUse, (RepairPointBuild entity) -> entity.target != null);`) carries no static consumePower def, so the catalog records consumePower None (CORRECT) but consumesPower true for both defs -- the gate is `block.properties.has("consumePower")` or the catalog consumesPower flag, so a repair turret is ticked while a block with no power consumer at all is untouched: the tick models no other consumers yet (the updateTile advance waits for its own slice), and RepairPointBuild overrides shouldConsume (RepairTurret.java:221, `public boolean shouldConsume(){` with `return target != null && enabled;`, RepairTurret.java:222) -- N2188 wires the gate through source_repair_turret_should_consume_state(frame): has_target && enabled when a target observation is present, enabled when the frame carries no has_target key (the N2174 behavior preserved; no live target is stamped on any placed-building frame yet). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower") or block.properties.get("consumesPower", false))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(source_repair_turret_should_consume_state(frame).get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_repair_turret_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# N2212: target acquisition (RepairTurret.java:193-199 +
		# 214-217) runs on EVERY tick for every ticked repair
		# turret, unconditional on power / enabled / cheating:
		# Java updateTile runs regardless -- only the heal
		# needs efficiency > 0 (RepairTurret.java:203). The
		# units list is the frame's `units` key (the
		# N2141/N2144 precedent -- no live units list is
		# stamped on any frame yet, so the target stays null
		# until a unit-list slice lands), the centre is the
		# turret's world position (`sprite.position`, the
		# turret-targeting precedent), the radius is the
		# per-def repairRadius (`_repair_radius_for_block_id`
		# -- 60f repair-point, 145f repair-turret, class
		# default 50f; the catalog carries no repairRadius).
		# The acquire stamps `target` / `has_target` /
		# `target_timer` / `offset` live, so the N2188
		# shouldConsume gate reads a live `has_target` from
		# the next tick on.
		var repair_radius: float = _repair_radius_for_block_id(block_id)
		var acquire: Dictionary = source_repair_turret_target_acquire_state(frame, frame.get("units", []), team_id, sprite.position.x, sprite.position.y, repair_radius, seconds)
		frame["target"] = acquire.get("target")
		frame["has_target"] = acquire.get("has_target", false)
		frame["target_timer"] = acquire.get("target_timer", 0.0)
		frame["offset"] = acquire.get("offset", Vector2.ZERO)
		# N2213: heal advance (RepairTurret.java:203-207)
		# runs after the acquire stamps, on EVERY tick like
		# the acquire: the pure function gates on target /
		# efficiency / aim cone itself, so a blocked heal
		# returns the target unchanged. repairSpeed is the
		# per-def value (`_repair_speed_for_block_id` --
		# 0.45f repair-point, 3f repair-turret, class default
		# 0.3f; the catalog carries no repairSpeed), and the
		# multiplier is the N2209 coolant multiplier
		# (repair-turret only accepts coolant,
		# `acceptCoolant = true;` + `coolantMultiplier =
		# 1.6f;`, Blocks.java:6404-6406; repair-point never
		# boosts, class default `acceptCoolant = false;`).
		# The heal stamps the returned target /
		# target_health live, so the healed health is what
		# the next tick reads.
		var repair_speed: float = _repair_speed_for_block_id(block_id)
		var accept_coolant: bool = block_id == "repair-turret"
		var multiplier: float = float(source_repair_turret_coolant_multiplier_state(frame, accept_coolant, 1.6).get("heal_multiplier", 1.0))
		var heal: Dictionary = source_repair_turret_heal_advance_state(frame, sprite.position.x, sprite.position.y, repair_speed, seconds, multiplier)
		frame["target"] = heal.get("target")
		frame["target_health"] = heal.get("target_health", 0.0)
		frame["healed"] = heal.get("healed", false)
		frame["heal_amount"] = heal.get("heal_amount", 0.0)
		# N2214: rotation slerp (RepairTurret.java:209)
		# runs after the heal stamps, on EVERY tick like
		# the acquire/heal: the pure function gates on
		# target / efficiency itself, and the cone does NOT
		# gate it -- the turret turns toward a target even
		# outside the 30-degree cone. The slerp MUST run
		# after the heal (the Java order), because the heal
		# reads the pre-slerp rotation for its cone check.
		# time_scale has no live source in the port yet, so
		# the driver passes `frame.get("time_scale", 1.0)`
		# -- the Java default 1f (BuildingComp.java:98).
		# This is the first stamp of `frame["rotation"]`:
		# before N2214 every repair turret sat at the 90.0
		# default the N2213 heal read.
		var slerp: Dictionary = source_repair_turret_rotation_slerp_state(frame, sprite.position.x, sprite.position.y, seconds, float(frame.get("time_scale", 1.0)))
		frame["rotation"] = slerp.get("rotation", 90.0)
		# N2215: strength lerp (RepairTurret.java:212)
		# runs after the slerp stamps, on EVERY tick like
		# the acquire/heal/slerp -- the lerp sits OUTSIDE
		# the target/efficiency gate, so the beam fades
		# toward 0 with no target or no power instead of
		# freezing. The lerp MUST run after the heal (the
		# Java order), because the heal reads the
		# pre-lerp strength. This is the first stamp of
		# `frame["strength"]`: before N2215 the N2213 heal
		# read strength 0.0 forever, so no repair turret
		# ever healed anything.
		var lerp: Dictionary = source_repair_turret_strength_lerp_state(frame, seconds)
		frame["strength"] = lerp.get("strength", 0.0)
		# N2219: drawBeam state (RepairTurret.java:106-151, called
		# from draw(), RepairTurret.java:164-176) runs after the
		# strength lerp stamps, on EVERY tick like the
		# acquire/heal/slerp/lerp -- draw() runs after updateTile
		# in the frame loop, so the beam reads the tick's final
		# target/rotation/strength. The pure function returns the
		# deterministic beam geometry (origin, pre-jitter
		# endpoint, visibility, widths); the driver stamps
		# beam_origin, last_end (= beam_end), beam_visible,
		# beam_width and pulse_stroke live. length / beamWidth
		# are the per-def values (`_beam_length_for_block_id` --
		# 5f repair-point class default, 6f repair-turret;
		# `_beam_width_for_block_id` -- 0.73f repair-point,
		# 1.1f repair-turret, class default 1f); pulseStroke is
		# the 2f class default (`public float pulseStroke = 2f;`,
		# RepairTurret.java:38), overridden by neither def, so
		# the driver passes the 2.0 literal.
		var beam: Dictionary = source_repair_turret_draw_beam_state(frame, sprite.position.x, sprite.position.y, float(frame.get("rotation", 90.0)), _beam_length_for_block_id(block_id), _beam_width_for_block_id(block_id), 2.0)
		frame["beam_origin"] = beam.get("beam_origin", Vector2.ZERO)
		frame["last_end"] = beam.get("beam_end", Vector2.ZERO)
		frame["beam_visible"] = beam.get("beam_visible", false)
		frame["beam_width"] = beam.get("beam_width", 0.0)
		frame["pulse_stroke"] = beam.get("pulse_stroke", 0.0)
		# N2225: draw() body state (RepairTurret.java:164-174, called
		# from draw() itself -- draw() runs after updateTile in the
		# frame loop, so this reads the tick's final rotation and
		# position, right after the N2219 beam). The pure function
		# returns the deterministic draw geometry (region angle
		# rotation - 90, shadow position, base position, z-layer
		# Layer.turret = 50); the driver stamps draw_rotation,
		# shadow_position, base_position and z_layer live. size is
		# the per-def value (`_size_for_block_id` -- 1 repair-point
		# class default, 2 repair-turret).
		var draw: Dictionary = source_repair_turret_draw_state(sprite.position.x, sprite.position.y, float(frame.get("rotation", 90.0)), _size_for_block_id(block_id))
		frame["draw_rotation"] = draw.get("draw_rotation", 0.0)
		frame["shadow_position"] = draw.get("shadow_position", Vector2.ZERO)
		frame["base_position"] = draw.get("base_position", Vector2.ZERO)
		frame["z_layer"] = draw.get("z_layer", 50.0)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
