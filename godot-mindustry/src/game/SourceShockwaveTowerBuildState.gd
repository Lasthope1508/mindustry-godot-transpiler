extends RefCounted
class_name SourceShockwaveTowerBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")

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
# The cyanogen liquid consumer (ConsumeLiquids, Blocks.java:2041,
# `consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));`):
# the def constant "cyanogen" resolves the catalog liquid id, and the
# amount is 1.5f/60f = 0.025 per frame. The catalog carries no
# consumeLiquids property for shockwave-tower, so the tick passes
# these def constants directly (the RegenProjector N2260 precedent).
const SOURCE_SHOCKWAVE_TOWER_CYANOGEN_LIQUID := "cyanogen"
const SOURCE_SHOCKWAVE_TOWER_CYANOGEN_AMOUNT := 1.5 / 60.0
# The shape fields (ShockwaveTower.java:39-40, `public float shapeRotateSpeed = 1f, shapeRadius = 6f;` / `public int shapeSides = 4;`): the draw shape is a 4-sided poly of radius shapeRadius * potentialEfficiency rotating at Time.time * shapeRotateSpeed (`Fill.poly(x, y, shapeSides, shapeRadius * potentialEfficiency, Time.time * shapeRotateSpeed);`, ShockwaveTower.java:132). No def override.
const SOURCE_SHOCKWAVE_TOWER_SHAPE_SIDES := 4
const SOURCE_SHOCKWAVE_TOWER_SHAPE_RADIUS := 6.0
const SOURCE_SHOCKWAVE_TOWER_SHAPE_ROTATE_SPEED := 1.0

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
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a shockwave tower does not take the early return. The shockwave tower's power draw is STATIC, not conditional: `consumePower(100f / 60f);` (Blocks.java:2042) registers a plain ConsumePower, so the catalog consumePower 1.6666666666666667 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The updateTile fire gate follows the folded efficiency: the reload charge (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`) charges by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a shockwave tower with no power would never charge and never fire its wave. ShockwaveTowerBuild overrides shouldConsume (ShockwaveTower.java:121, `public boolean shouldConsume(){` with `return reloadCounter < reload;`, ShockwaveTower.java:122); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). N2187 makes the gate live (resolving the N2177 RED decision, the PointDefenseTurret N2151 precedent and the RepairTurret N2174 / RepairTower N2176 precedents): the driver tracks reloadCounter on the frame and feeds `should_consume = enabled && reload_counter < reload` to the machinery (the pure gate is source_shockwave_tower_should_consume_state), so a fully reloaded tower folds efficiency 0 like Java. The shockwave tower is its own family (ShockwaveTower.java:22, `public class ShockwaveTower extends Block{`; ShockwaveTowerBuild, ShockwaveTower.java:66, `public class ShockwaveTowerBuild extends Building{`). Class fields: `public int timerCheck = timers ++;` (ShockwaveTower.java:23), `public float range = 110f;` (ShockwaveTower.java:25), `public float reload = 60f * 1.5f;` (ShockwaveTower.java:26), `public float bulletDamage = 160;` (ShockwaveTower.java:27), `public float falloffCount = 20f;` (ShockwaveTower.java:28), `public float shake = 2f;` (ShockwaveTower.java:29), `public float checkInterval = 8f;` (ShockwaveTower.java:31), `public float cooldownMultiplier = 1f;` (ShockwaveTower.java:34); constructor `update = true;` (ShockwaveTower.java:46), `solid = true;` (ShockwaveTower.java:47). Build fields: `public float reloadCounter = Mathf.random(reload);` (ShockwaveTower.java:67), `public float heat = 0f;` (ShockwaveTower.java:68). The wave damage line (ShockwaveTower.java:87, `float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);`) and the heat decay (ShockwaveTower.java:104, `heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);`) follow the fire gate. canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) are the surrounding gates. sense(LAccess.progress) returns `reloadCounter / reload` (ShockwaveTower.java:110, `if(sensor == LAccess.progress) return reloadCounter / reload;`) and warmup() returns heat (ShockwaveTower.java:117, `return heat;`) -- both live since N2390 (source_shockwave_tower_sense_state / source_shockwave_tower_warmup_state, pure-only: sense is called by logic and warmup by UI/display, not the tick). Single def -- shockwave-tower only (size 3, range 170f, reload 80f, surge-alloy 50 / silicon 150 / oxide 30 / tungsten 100, Blocks.java:2038-2044). RepairTower (unit-repair-tower) is a different class and NOT covered by this driver.
	# Documented limits: (1) cyanogen row live (N2331) -- the shockwave tower's static power consumer (consumePower 100f/60f, Blocks.java:2042) and its required cyanogen liquid consumer (consumeLiquids cyanogen 1.5f/60f = 0.025, Blocks.java:2041, `consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));`) both fold the first pass (ConsumeLiquids.efficiency, ConsumeLiquids.java:52-60, the min over the stacks -- the single-stack def collapses to min(cyanogen / (0.025 * ed * mult), 1f)), so the folded efficiency is the min over power + cyanogen; the second pass removes amount * folded edelta from the live store (ConsumeLiquids.update, ConsumeLiquids.java:44-49). No live intake fills the cyanogen store yet, so a live tower with no intake reads 0 cyanogen and folds efficiency 0. (2) shouldConsume gate live (N2187) -- ShockwaveTowerBuild overrides shouldConsume (`return reloadCounter < reload;`, ShockwaveTower.java:121-122); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the driver feeds the live gate to the machinery, so a fully reloaded tower folds efficiency 0 like Java. The random init (`public float reloadCounter = Mathf.random(reload);`, ShockwaveTower.java:67) is NOT modeled: a fresh frame starts at 0.0, which preserves the gate outcome at spawn (Mathf.random(reload) is always < reload) but not the time-to-first-fire; the fire reset (`reloadCounter = 0f;`, ShockwaveTower.java:83) is modeled by N2247 (the fire slice), so a fully charged tower that finds bullets resets and charges again. (3) updateTile advance live (N2247) -- N2187 models the reloadCounter charge (`(reloadCounter += edelta())`, ShockwaveTower.java:73, edelta() = efficiency * delta(), BuildingComp.java:1927-1929) each tick after the consumption fold, and N2247 models the rest of updateTile (ShockwaveTower.java:73-104): the fire gate over the already-charged counter, the bullet scan, the wave damage, the fire reset (`reloadCounter = 0f;`, ShockwaveTower.java:83) and the heat decay (`heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);`, ShockwaveTower.java:104); the N2247 proof carries the wave/heat/target keys. The charge and the advance run inside the existing driver guard (power consumer, enabled, not cheating), so a cheating team's tower does not advance its counter; timerCheck cadence live (N2318) -- the tick accumulates frame["timer_check_elapsed"] every guarded tick and passes the computed check_ready into the advance (the frame-local Interval-equivalent, source_shockwave_tower_timer_check_state, checkInterval 8f, ShockwaveTower.java:31); the live bullet scan is live (N2327) -- the tick filters the frame bullet candidates (frame["bullet_candidates"], default []) through the scan pure (rect + enemy + hittable) at the def range from the live tower position and passes the filtered list into the advance, so a live tower with supplied candidates fires; the hitbox refinement is live (N2340) -- the tick chains the hitbox pure after the scan (bullet hitbox STRICT overlap with the rect, QuadTree semantics) and passes the refined list into the advance, so a degenerate edge hitbox is dropped downstream; the broad hitbox phase is live (N2347) -- the scan pure calls the broad hitbox pure instead of the rect center test, so straddlers reach the advance and the refinement re-filters the same overlap (idempotent); the live bullet query (Groups.bullet) still defers -- no live query fills frame["bullet_candidates"] yet -- and heat decays every tick. First-fire deviation: Java fires nearly at once after placement; the frame clock delays the first check by a full 8-tick interval. (4) Sense/warmup rows live (N2390) -- `sense(LAccess.progress)` (:110, the BARE reloadCounter / reload ratio, NO clamp -- unlike the MendProjector and the LaunchPad) and `warmup()` returning heat (:117) are pure-only pures (source_shockwave_tower_sense_state / source_shockwave_tower_warmup_state); the tick never calls them -- sense is called by logic, warmup by UI/display, and the call sites wait for logic-executor / display slices. (5) Single def -- shockwave-tower only (size 3, range 170f, reload 80f, surge-alloy 50 / silicon 150 / oxide 30 / tungsten 100); per-def stat values wait for their own verification slice. (6) Draw rows live (N2356) -- the draw pure (source_shockwave_tower_draw_state) models draw() (:126-134): super.draw + the additive heatRegion glow (heatColor, alpha = heat) + the shape poly (4 sides, radius 6f * potentialEfficiency, rotation Time.time * 1f, color lerp shapeColor -> waveColor by heat^2); the draw-select pure (source_shockwave_tower_draw_select_state) models drawSelect (:137-139) and drawPlace (:60-64) as the same waveColor dash circle at the def range (drawPlace passes x * tilesize + offset, drawSelect passes building x/y -- drawPlace uses waveColor, NOT Pal.placing, verified at :63). Pure-only: draw never runs in the tick, and there is no shape state advance -- the rotation is a function of Time.time (the caller supplies time_value). sense progress + warmup live since N2390.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_shockwave_tower_liquid_consumer_row_state(frame: Dictionary, has_liquid_consumer: bool, liquid_id: int, amount: float, source_delta: float, time_scale: float, efficiency_scale: float, multiplier: float = 1.0) -> Dictionary:
	# ConsumeLiquids.efficiency (ConsumeLiquids.java:52-60):
	# `float ed = build.edelta() * build.efficiencyScale();`
	# `if(ed <= 0.00000001f) return 0f;`
	# `float min = 1f;`
	# `min = Math.min(build.liquids.get(stack.liquid) / (stack.amount * ed * mult), min);`
	# `return min;`
	# ConsumeLiquids extends Consume DIRECTLY (`public class ConsumeLiquids extends Consume{`, ConsumeLiquids.java:11) -- it is NOT a ConsumeLiquidBase, so no ConsumeLiquid pattern is reused blindly: the efficiency is the MIN over the stacks (starting from 1f, which is the cap -- there can be more liquid than necessary), and the update removes EVERY stack (`build.liquids.remove(stack.liquid, stack.amount * build.edelta() * mult);`, ConsumeLiquids.java:47). The shockwave-tower def carries exactly ONE stack (`consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));`, Blocks.java:2041, via `public ConsumeLiquids consumeLiquids(LiquidStack... stacks){` / `return consume(new ConsumeLiquids(stacks));`, Block.java:1131-1132), so the min loop collapses to min(cyanogen / (amount * ed * mult), 1f) -- the same number as the ConsumeLiquid formula for one stack, but reached through the ConsumeLiquids lines, not the ConsumeLiquid ones. The first pass assumes efficiency 1f (BuildingComp.java:1965, `efficiency = optionalEfficiency = 1f;`), so edelta() = delta() = Time.delta * timeScale (`return Time.delta * timeScale;`, BuildingComp.java:1922-1924; `return efficiency * delta();`, BuildingComp.java:1927-1929 -- with efficiency 1f the two coincide). The def sets no multiplier, so the default multiplier 1f applies (`public Floatf<Building> multiplier = b -> 1f;`, Consume.java:18); the multiplier stays an explicit parameter (default 1.0) so the formula stays Java-exact. The def calls no .boost(), so the row is REQUIRED (non-optional) -- it folds the FIRST pass (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`), and the shared fold sets shouldConsumePower=false when the row is <= 1e-7 (BuildingComp.java:1972-1973, `if(cons != block.consPower && result <= 0.0000001f){` / `shouldConsumePower = false;`). The liquid amount comes from the shared liquid module helper (SourceLiquidModuleState.source_get_state, reused through a preload, NOT re-implemented) over the frame liquids key, with the Fracker gate guard (frame has "liquids", id in bounds, SourceFrackerBuildState.gd:279, the guard inside source_fracker_liquid_consumer_row_state; amount 0.0 when the store has no entry for the liquid -- Java's liquids.get returns 0.0 for a liquid never added). The row shape mirrors the power row: {"has_liquid_row": bool, "row": {"result": float, "is_power": false}} -- is_power false. A block with no liquid consumer contributes no row (the N2253 launch-pad precedent). The second pass removes the consumed cyanogen (ConsumeLiquids.update, ConsumeLiquids.java:44-49, `build.liquids.remove(stack.liquid, stack.amount * build.edelta() * mult);`, only when `if(update && efficiency > 0){`, BuildingComp.java:1999, with `for(var cons : block.updateConsumers){` / `cons.update(self());`, BuildingComp.java:2000-2001) -- the tick does that after the fold, with edelta from the folded efficiency.
	if not has_liquid_consumer:
		return {"has_liquid_row": false, "row": {}}
	var liquids: Dictionary = frame.get("liquids", {})
	var liquid_amount: float = 0.0
	if liquids.has("liquids") and liquid_id >= 0 and liquid_id < int(liquids["liquids"].size()):
		liquid_amount = float(source_liquid_module_state.source_get_state(liquids, liquid_id).get("amount", 0.0))
	var edelta: float = source_delta * time_scale
	var ed: float = edelta * efficiency_scale
	var result: float = 0.0
	if ed > 0.00000001:
		result = minf(liquid_amount / (amount * ed * multiplier), 1.0)
	return {"has_liquid_row": true, "row": {"result": result, "is_power": false}}

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

static func source_shockwave_tower_supplied_bullets_broad_hitbox_state(candidates: Array, range_value: float, tower_x: float, tower_y: float) -> Dictionary:
	# The hitbox broad phase (Groups.bullet.intersect is a QuadTree hitbox overlap query, EntityGroup.java:195), the pure filter the N2327 scan pure calls INSTEAD of the rect center test (N2347, resolving DEFERRED #330): the intersect visits the spatial bullet group
	# `public void intersect(float x, float y, float width, float height, Cons<? super T> out){`
	# `tree.intersect(x, y, width, height, out);`
	# (EntityGroup.java:195-198); the QuadTree admits a bullet whose HITBOX overlaps the query rect
	# `hitbox(item);`
	# `if(tmp.overlaps(x, y, width, height)){`
	# (QuadTree.java:190-191) with the STRICT Rect overlap
	# `return x < rx + rwidth && x + width > rx && y < ry + rheight && y + height > ry;`
	# (Rect.java:274-276); a bullet's hitbox is its type hitSize
	# `public float hitSize = 4;`
	# (BulletType.java:43), set onto the bullet at spawn
	# `bullet.hitSize = hitSize;`
	# (BulletType.java:970), a hitSize-sided square centered on the bullet
	# `rect.setCentered(x, y, hitSize, hitSize);`
	# (HitboxComp.java:65-67 -- BulletComp implements Hitboxc, BulletComp.java:28). The query rect is the range*2 box (`Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {`, ShockwaveTower.java:75); the range is the class `public float range = 110f;` (ShockwaveTower.java:25), overridden by the def `range = 170f;` (Blocks.java:2043); the pure takes it as a parameter and stays def-agnostic. The N2327 scan pure used to test the bullet CENTER against the INCLUSIVE rect (the N2277 precedent) -- an approximation of the port, not Java: a straddler whose center sat just outside the rect was dropped before the N2340 refinement ever saw it. This pure IS the Java-exact test: the N2327 pure calls it and then filters team / hittable (`if(b.team != team && b.type.hittable){`, ShockwaveTower.java:76) on the broad-admitted list. Scoping decisions, all source-backed: (1) the pure filters HITBOX OVERLAP ONLY -- it does NOT re-filter team / hittable (the N2327 pure does that after the broad call), so a same-team or non-hittable entry passed directly is admitted here and dropped downstream by the scan / the N2247 advance (which re-checks team + hittable, ShockwaveTower.java:76). (2) A bullet dict carries x / y plus hit_size (the type hitSize, default 4.0 -- the BulletType default, BulletType.java:43); a missing hit_size reads as 4.0, so a bullet with no hit_size key behaves like a default-type bullet. (3) A missing x or y EXCLUDES the candidate (the N2327 precedent); a non-Dictionary entry is excluded the same way. (4) The admitted entries are the candidate dicts themselves, in candidate order, like Java's Seq<Bullet> holding the bullets -- the pure never rewrites an entry. (5) The N2340 refinement stays chained after the scan and re-filters the SAME overlap -- idempotent, harmless (it drops nothing this pure admitted: both test the same STRICT overlap at the same range and tower position).
	var broad: Array = []
	for candidate in candidates:
		if not (candidate is Dictionary):
			continue
		if not candidate.has("x") or not candidate.has("y"):
			continue
		var hit_size: float = float(candidate.get("hit_size", 4.0))
		var half_size: float = hit_size / 2.0
		var bullet_x: float = float(candidate.get("x", 0.0))
		var bullet_y: float = float(candidate.get("y", 0.0))
		if bullet_x - half_size >= tower_x + range_value or bullet_x + half_size <= tower_x - range_value:
			continue
		if bullet_y - half_size >= tower_y + range_value or bullet_y + half_size <= tower_y - range_value:
			continue
		broad.append(candidate)
	return {"bullets": broad}

static func source_shockwave_tower_supplied_bullets_state(candidates: Array, range_value: float, tower_x: float, tower_y: float, tower_team: int) -> Dictionary:
	# The live bullet scan (ShockwaveTowerBuild.updateTile(), ShockwaveTower.java:75-79), the pure filter the N2247 advance fires from: at fire-gate time Java clears (`targets.clear();`, ShockwaveTower.java:74) and scans
	# `Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {`
	# `if(b.team != team && b.type.hittable){`
	# `targets.add(b);`
	# (ShockwaveTower.java:75-77). The scan is a RECTANGLE intersect over the range*2 box -- NOT a circle: a bullet at the rect corner (range, range) is IN even though its distance exceeds range. The intersect visits the spatial bullet group (EntityGroup.java:195, `public void intersect(float x, float y, float width, float height, Cons<? super T> out){`, delegating to `tree.intersect(x, y, width, height, out);`, EntityGroup.java:198); the QuadTree admits a bullet whose HITBOX overlaps the query rect (`hitbox(item);` / `if(tmp.overlaps(x, y, width, height)){`, QuadTree.java:190-191) with the STRICT Rect overlap (`return x < rx + rwidth && x + width > rx && y < ry + rheight && y + height > ry;`, Rect.java:274-276); a bullet's hitbox is its type hitSize (`public float hitSize = 4;`, BulletType.java:43). Since N2347 the port tests the HITBOX, not the center: this pure calls the broad hitbox pure (source_shockwave_tower_supplied_bullets_broad_hitbox_state -- the Java-exact QuadTree test, resolving DEFERRED #330) and then filters team / hittable on the broad-admitted list; the old inclusive center test (the N2277 precedent) is gone -- a straddler whose center sits just outside the rect but whose hitbox overlaps it is admitted like Java. The N2340 refinement chains after this pure and re-tests the admitted bullets by the SAME hitbox STRICT overlap -- idempotent, harmless. The range is the class `public float range = 110f;` (ShockwaveTower.java:25), overridden by the def `range = 170f;` (Blocks.java:2043); the pure takes it as a parameter and stays def-agnostic. hittable lives on the bullet TYPE (`public boolean hittable = true;`, BulletType.java:143, default true), carried on the candidate dict; the bullet dict contract (the N2212 fixture precedent) is x / y / team / hittable / damage (`@Import float x, y, damage, lastX, lastY, time, lifetime;`, BulletComp.java:31). Scoping decisions, all source-backed: (1) a missing x or y EXCLUDES the candidate (the broad pure excludes it -- no guessed position); a non-Dictionary entry is excluded the same way. (2) A missing team reads as the tower's own team (the N2236 precedent -- never enemy), so it is excluded. (3) A missing hittable reads as true (the BulletType default). (4) A missing hit_size reads as 4.0 (the BulletType default -- the broad pure's default, consistent with N2340). (5) The admitted entries are the candidate dicts themselves, in candidate order, like Java's Seq<Bullet> holding the bullets -- the N2247 advance duplicates them into targets. (6) The tower team is an explicit parameter: the pure reads no frame, so the tick passes the live team_id (the frame default is derelict, source_block_geometry.SOURCE_TEAM_DERELICT_ID).
	var broad: Dictionary = source_shockwave_tower_supplied_bullets_broad_hitbox_state(candidates, range_value, tower_x, tower_y)
	var bullets: Array = []
	for candidate in broad.get("bullets", []):
		if int(candidate.get("team", tower_team)) == tower_team:
			continue
		if not bool(candidate.get("hittable", true)):
			continue
		bullets.append(candidate)
	return {"bullets": bullets}

static func source_shockwave_tower_supplied_bullets_hitbox_state(candidates: Array, range_value: float, tower_x: float, tower_y: float) -> Dictionary:
	# The hitbox refinement (Groups.bullet.intersect is a QuadTree hitbox overlap query, EntityGroup.java:195), the pure filter chained AFTER the N2327 scan (broad -> hitbox, the N2335 MendProjector narrow pattern): the intersect visits the spatial bullet group
	# `public void intersect(float x, float y, float width, float height, Cons<? super T> out){`
	# `tree.intersect(x, y, width, height, out);`
	# (EntityGroup.java:195-198); the QuadTree admits a bullet whose HITBOX overlaps the query rect
	# `hitbox(item);`
	# `if(tmp.overlaps(x, y, width, height)){`
	# (QuadTree.java:190-191) with the STRICT Rect overlap
	# `return x < rx + rwidth && x + width > rx && y < ry + rheight && y + height > ry;`
	# (Rect.java:274-276); a bullet's hitbox is its type hitSize
	# `public float hitSize = 4;`
	# (BulletType.java:43), set onto the bullet at spawn
	# `bullet.hitSize = hitSize;`
	# (BulletType.java:970), a hitSize-sided square centered on the bullet
	# `rect.setCentered(x, y, hitSize, hitSize);`
	# (HitboxComp.java:65-67 -- BulletComp implements Hitboxc, BulletComp.java:28). The query rect is the same range*2 box the N2327 scan uses (`Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {`, ShockwaveTower.java:75); the range is the class `public float range = 110f;` (ShockwaveTower.java:25), overridden by the def `range = 170f;` (Blocks.java:2043); the pure takes it as a parameter and stays def-agnostic. Since N2347 the N2327 scan pure calls the broad hitbox pure instead of the rect center test, so the bullets reaching this refinement already passed the SAME hitbox STRICT overlap; this refinement re-tests them by hitbox STRICT overlap -- idempotent, harmless (it drops nothing the broad phase admitted). Scoping decisions, all source-backed: (1) the pure filters HITBOX OVERLAP ONLY -- it does NOT re-filter team / hittable (the N2327 pure already did), so a same-team or non-hittable entry passed directly is admitted here and dropped downstream by the N2247 advance (which re-checks team + hittable, ShockwaveTower.java:76). (2) A bullet dict carries x / y plus hit_size (the type hitSize, default 4.0 -- the BulletType default, BulletType.java:43); a missing hit_size reads as 4.0, so a bullet with no hit_size key behaves like a default-type bullet. (3) A missing x or y EXCLUDES the candidate (the N2327 precedent); a non-Dictionary entry is excluded the same way. (4) The admitted entries are the candidate dicts themselves, in candidate order, like Java's Seq<Bullet> holding the bullets -- the pure never rewrites an entry. (5) The chain order is broad -> hitbox: the tick passes the N2327 admitted list here, at the SAME range and tower position, and passes the refined list into the N2247 advance; the re-filter is idempotent because both pures test the same STRICT overlap (DEFERRED #330, the straddler drop, is resolved by N2347 -- the broad phase admits straddlers before this refinement sees them).
	var refined: Array = []
	for candidate in candidates:
		if not (candidate is Dictionary):
			continue
		if not candidate.has("x") or not candidate.has("y"):
			continue
		var hit_size: float = float(candidate.get("hit_size", 4.0))
		var half_size: float = hit_size / 2.0
		var bullet_x: float = float(candidate.get("x", 0.0))
		var bullet_y: float = float(candidate.get("y", 0.0))
		if bullet_x - half_size >= tower_x + range_value or bullet_x + half_size <= tower_x - range_value:
			continue
		if bullet_y - half_size >= tower_y + range_value or bullet_y + half_size <= tower_y - range_value:
			continue
		refined.append(candidate)
	return {"bullets": refined}

static func source_shockwave_tower_draw_state(x_value: float, y_value: float, heat: float, potential_efficiency: float, time_value: float) -> Dictionary:
	# The draw rows (ShockwaveTowerBuild.draw(), ShockwaveTower.java:126-134), the pure draw-call dict -- the port never draws for real (the SourceBlockDrawState / SourceBaseTurretDrawState pattern: the pure returns the draw calls as data). Java draws, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `super.draw();`
	# `Drawf.additive(heatRegion, heatColor, heat, x, y, 0f, Layer.blockAdditive);`
	# `Draw.z(Layer.effect);`
	# `Draw.color(shapeColor, waveColor, Mathf.pow(heat, 2f));`
	# `Fill.poly(x, y, shapeSides, shapeRadius * potentialEfficiency, Time.time * shapeRotateSpeed);`
	# `Draw.color();`
	# heatRegion is the `@-heat` region (`public @Load("@-heat") TextureRegion heatRegion;`, ShockwaveTower.java:42); the colors are `public Color waveColor = Pal.accent, heatColor = Pal.turretHeat, shapeColor = Color.valueOf("f29c83");` (ShockwaveTower.java:33); the shape fields are `public float shapeRotateSpeed = 1f, shapeRadius = 6f;` / `public int shapeSides = 4;` (ShockwaveTower.java:39-40), carried as driver constants (no def override). The heat call is the additive glow: region heatRegion, color heatColor, alpha = heat (the frame heat, `public float heat = 0f;`, ShockwaveTower.java:68, set to 1f on fire and decayed every tick by the N2247 advance), rotation 0, layer Layer.blockAdditive. The shape call is the poly at Layer.effect: shapeSides sides, radius shapeRadius * potentialEfficiency (the frame potentialEfficiency stamped by apply_update_consumption_state -- an unpowered tower draws a collapsed poly of radius 0, Java still calls Fill.poly), rotation Time.time * shapeRotateSpeed. The shape has NO state advance -- the rotation is a function of Time.time, which the caller supplies as time_value (draw never runs in the tick, so the tick never stamps it; the pure takes no frame). The color lerp factor is heat SQUARED (`Mathf.pow(heat, 2f);`, ShockwaveTower.java:131), not heat. The color lerp has NO precedent in the port's draw-call dicts (BaseTurret uses flat color strings, which cannot express a lerp), so the shape call carries it as an explicit from/to/t dict {from: shapeColor, to: waveColor, t: pow(heat, 2.0)}. super.draw() is Building.draw() (the base region); the pure records that the super call happens, not its content (the BaseTurret draw_place precedent).
	var heat_call: Dictionary = {
		"call": "Drawf.additive(heatRegion, heatColor, heat, x, y, 0f, Layer.blockAdditive);",
		"region": "heatRegion",
		"color": "heatColor",
		"alpha": heat,
		"x": x_value,
		"y": y_value,
		"rotation": 0.0,
		"layer": "Layer.blockAdditive",
	}
	var color_lerp_t: float = pow(heat, 2.0)
	var shape_call: Dictionary = {
		"call": "Fill.poly(x, y, shapeSides, shapeRadius * potentialEfficiency, Time.time * shapeRotateSpeed);",
		"x": x_value,
		"y": y_value,
		"sides": SOURCE_SHOCKWAVE_TOWER_SHAPE_SIDES,
		"radius": SOURCE_SHOCKWAVE_TOWER_SHAPE_RADIUS * potential_efficiency,
		"rotation": time_value * SOURCE_SHOCKWAVE_TOWER_SHAPE_ROTATE_SPEED,
		"color": {"from": "shapeColor", "to": "waveColor", "t": color_lerp_t},
		"z": "Layer.effect",
	}
	return {
		"super_draw_called": true,
		"super_draw_expr": "super.draw();",
		"heat_expr": "Drawf.additive(heatRegion, heatColor, heat, x, y, 0f, Layer.blockAdditive);",
		"z_expr": "Draw.z(Layer.effect);",
		"color_expr": "Draw.color(shapeColor, waveColor, Mathf.pow(heat, 2f));",
		"poly_expr": "Fill.poly(x, y, shapeSides, shapeRadius * potentialEfficiency, Time.time * shapeRotateSpeed);",
		"reset_expr": "Draw.color();",
		"x": x_value,
		"y": y_value,
		"heat": heat,
		"potential_efficiency": potential_efficiency,
		"time_value": time_value,
		"shape_sides": SOURCE_SHOCKWAVE_TOWER_SHAPE_SIDES,
		"shape_radius": SOURCE_SHOCKWAVE_TOWER_SHAPE_RADIUS,
		"shape_rotate_speed": SOURCE_SHOCKWAVE_TOWER_SHAPE_ROTATE_SPEED,
		"shape_radius_value": SOURCE_SHOCKWAVE_TOWER_SHAPE_RADIUS * potential_efficiency,
		"shape_rotation": time_value * SOURCE_SHOCKWAVE_TOWER_SHAPE_ROTATE_SPEED,
		"color_lerp_t": color_lerp_t,
		"heat_call": heat_call,
		"shape_call": shape_call,
	}

static func source_shockwave_tower_draw_select_state(x_value: float, y_value: float, range_value: float) -> Dictionary:
	# The drawSelect / drawPlace rows (ShockwaveTowerBuild.drawSelect(), ShockwaveTower.java:137-139; ShockwaveTower.drawPlace(), ShockwaveTower.java:60-64), the pure draw-call dict shared by both -- drawSelect is
	# `Drawf.dashCircle(x, y, range, waveColor);`
	# at the building x/y, and drawPlace is
	# `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, waveColor);`
	# at the tile position (after `super.drawPlace(x, y, rotation, valid);`, ShockwaveTower.java:61). VERIFIED by reading :63: drawPlace uses waveColor, NOT Pal.placing -- unlike BaseTurret.drawPlace, which uses Pal.placing -- so ONE pure serves both: the caller supplies world coords (drawSelect passes the building x/y, drawPlace passes x * tilesize + offset). super.drawPlace is Block.drawPlace (drawPotentialLinks + drawOverlay, SourceBlockDrawState) and is NOT modeled here: the pure covers only the ShockwaveTower dash circle line. The range is the class `public float range = 110f;` (ShockwaveTower.java:25), overridden by the def `range = 170f;` (Blocks.java:2043); the pure takes it as a parameter and stays def-agnostic. Like the draw pure, this pure never runs in the tick (pure-only, like the BaseTurret drawPlace).
	var dash_circle_call: Dictionary = {
		"call": "Drawf.dashCircle(x, y, range, waveColor);",
		"x": x_value,
		"y": y_value,
		"radius": range_value,
		"color": "waveColor",
	}
	return {
		"dash_circle_expr": "Drawf.dashCircle(x, y, range, waveColor);",
		"draw_place_expr": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, waveColor);",
		"draw_place_super_expr": "super.drawPlace(x, y, rotation, valid);",
		"x": x_value,
		"y": y_value,
		"range": range_value,
		"dash_circle_call": dash_circle_call,
	}

static func source_shockwave_tower_sense_state(sensor: String, reload_counter: float, reload_value: float, super_value: Variant = null) -> Dictionary:
	# The sense rows (ShockwaveTowerBuild.sense(), ShockwaveTower.java:109-112), the pure logic-sense dispatch -- Java senses, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public double sense(LAccess sensor) {`
	# `if(sensor == LAccess.progress) return reloadCounter / reload;`
	# `return super.sense(sensor);`
	# The ratio is BARE -- Java has NO clamp here, unlike the MendProjector (`if(sensor == LAccess.progress) return Mathf.clamp(charge / reload);`, MendProjector.java:127) and the LaunchPad, so the pure uses plain reload_counter / reload_value: a counter past the reload reads above 1.0 (the proof pins 1.5), and a zero reload reads +Infinity for a positive counter, exactly like Java float division. Do NOT add a clamp Java does not have. reload_counter is the frame value the N2187 gate and the N2247 advance track (`public float reloadCounter = Mathf.random(reload);`, ShockwaveTower.java:67: charged by edelta() each tick, reset to 0f on fire, :73/83); reload_value is the per-def explicit input (shockwave-tower 80f, Blocks.java:2044; the class default is `public float reload = 60f * 1.5f;`, ShockwaveTower.java:26) -- the pure stays def-agnostic (the N2187 gate precedent). super.sense is VERIFIED, not guessed: the BuildingComp switch (BuildingComp.java:2094-2123):
	# `return switch(sensor){`
	# `case health -> health;`
	# `case efficiency -> efficiency;`
	# `default -> Float.NaN; //gets converted to null in logic`
	# covers x / y / color / dead / solid / team / health / maxHealth / efficiency / timescale / range / rotation / totalItems / totalLiquids / totalPower / itemCapacity / liquidCapacity / powerCapacity / powerNetIn / powerNetOut / powerNetStored / powerNetCapacity / enabled / controlled / payloadCount / size / cameraX, cameraY, cameraWidth, cameraHeight, and the default branch is Float.NaN (converted to null in logic). The port ALREADY models that switch (SourceBuildingSenseState: sense_position_state, sense_health_process_state, sense_totals_state, sense_capacity_power_net_state, sense_enabled_controlled_state, sense_payload_size_state, sense_camera_default_state), so the pure takes the caller's super.sense result as super_value (default null = the default branch) instead of re-modeling the switch. senseObject / sense(Content) are separate overloads (BuildingComp.java:2124+) and are NOT modeled here. Pure-only, like the N2383 sense pure and the N2356 draw pures: the tick never calls sense (verified: grep `sense` in this driver finds only comment defers) -- sense is called by logic, not the tick, and the logic call site waits for a logic-executor slice (a port-wide concern, not a ShockwaveTower deferral).
	var is_progress: bool = sensor == "progress"
	var value: Variant = reload_counter / reload_value if is_progress else super_value
	return {
		"progress_expr": "if(sensor == LAccess.progress) return reloadCounter / reload;",
		"super_expr": "return super.sense(sensor);",
		"sensor": sensor,
		"reload_counter": reload_counter,
		"reload": reload_value,
		"super_value": super_value,
		"is_progress": is_progress,
		"value": value,
	}

static func source_shockwave_tower_warmup_state(heat: float) -> Dictionary:
	# The warmup row (ShockwaveTowerBuild.warmup(), ShockwaveTower.java:115-118), the pure warmup accessor -- Java, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public float warmup(){`
	# `return heat;`
	# heat is the frame value (`public float heat = 0f;`, ShockwaveTower.java:68), set to 1f on fire and decayed every tick by the N2247 advance (`heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);`, ShockwaveTower.java:104). A trivial accessor, kept as its own pure so each pure has one Java method (the N2383 single-purpose precedent and the N2356 two-pure precedent). Pure-only, like the sense pure above: the tick never calls warmup (verified: grep `warmup` in this driver finds only comment defers) -- warmup is called by UI/display, not the tick, and the display call site waits for a display slice (a port-wide concern, not a ShockwaveTower deferral).
	return {
		"warmup_expr": "return heat;",
		"heat": heat,
		"warmup": heat,
	}

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
	var liquid_id_by_name: Dictionary = source_content_registry_runtime_state.source_liquid_catalog_state(catalog).get("liquid_id_by_name", {})
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
		# The frame carries the Building.liquids LiquidModule
		# (frame["liquids"]): the live store lives on the
		# sprite meta (source_building_liquids), so the driver
		# syncs the reference into the frame each tick BEFORE
		# the fold, and the pure liquid row reads the cyanogen
		# amount from it (the Fracker:623 / RegenProjector:601
		# precedent). PortGame NEVER initializes the store for
		# a shockwave tower: its record_placed_block only binds
		# liquid consumers for blocks with a catalog
		# consumeLiquid property, and the catalog carries no
		# consumeLiquids property for shockwave-tower -- so a
		# sprite that somehow lacks a store gets it bound here
		# instead of crashing the loop (the LiquidBridge
		# precedent, SourceLiquidBridgeBuildState.gd:496-498),
		# with hasLiquids true by construction
		# (ConsumeLiquids.apply sets `block.hasLiquids =
		# true;`, ConsumeLiquids.java:26).
		var liquids_store: Dictionary = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		if liquids_store.is_empty():
			liquids_store = source_placed_block_state.source_initialize_building_liquids_state(sprite, true, catalog).get("liquids", {})
		frame["liquids"] = liquids_store
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a shockwave tower with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the reload charge (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a shockwave tower does not take the early return. The shockwave tower's power draw is STATIC: `consumePower(100f / 60f);` (Blocks.java:2042) registers a plain ConsumePower, so the catalog consumePower 1.6666666666666667 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The cyanogen liquid consumer folds alongside the power row since N2331 (ConsumeLiquids.efficiency, ConsumeLiquids.java:52-60; the second pass removes amount * folded edelta after the fold, ConsumeLiquids.java:44-49). A shockwave tower with no power consumer is untouched: the tick models no consumers beyond power + cyanogen yet (the updateTile advance below is wired for towers with a power consumer), and ShockwaveTowerBuild overrides shouldConsume (ShockwaveTower.java:121, `public boolean shouldConsume(){` with `return reloadCounter < reload;`, ShockwaveTower.java:122) -- N2187 feeds the live gate to the machinery (the pure gate is source_shockwave_tower_should_consume_state, fed the frame's reload_counter against the def reload); the N2177 RED decision is resolved. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var tick_source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var tick_time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
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
			# The liquid consumer reads live since N2331: a
			# shockwave tower folds the pure cyanogen row into
			# the first pass (ConsumeLiquids.efficiency,
			# ConsumeLiquids.java:52-60), so the folded
			# efficiency is the min over power + cyanogen and
			# the shared fold stops power draw when the liquid
			# row is <= 1e-7. The cyanogen id resolves from
			# the catalog with the def constant "cyanogen"
			# (`consumeLiquids(LiquidStack.with(Liquids.
			# cyanogen, 1.5f / 60f));`, Blocks.java:2041 --
			# 0.025 per frame). The single def always has the
			# row, so has_liquid_consumer is the true literal
			# (the RegenProjector N2260 precedent) -- the
			# catalog carries no consumeLiquids property to
			# gate on. In the first pass efficiency is assumed
			# 1f (BuildingComp.java:1965), so the row's edelta
			# is tick_source_delta * tick_time_scale.
			var cyanogen_liquid_id: int = int(liquid_id_by_name.get(SOURCE_SHOCKWAVE_TOWER_CYANOGEN_LIQUID, -1))
			var liquid_row: Dictionary = source_shockwave_tower_liquid_consumer_row_state(frame, true, cyanogen_liquid_id, SOURCE_SHOCKWAVE_TOWER_CYANOGEN_AMOUNT, tick_source_delta, tick_time_scale, float(frame.get("efficiency_scale", 1.0)))
			if bool(liquid_row.get("has_liquid_row", false)):
				required_results.append(liquid_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# Second pass (N2331): ConsumeLiquids.update removes
			# `build.liquids.remove(stack.liquid, stack.amount * build.edelta() * mult);`
			# (ConsumeLiquids.java:44-49), only when update &&
			# efficiency > 0 (`if(update && efficiency > 0){`,
			# BuildingComp.java:1999, with `for(var cons : block.updateConsumers){` / `cons.update(self());` at :2000-2001), and edelta comes from the FOLDED efficiency (`return efficiency * delta();`, BuildingComp.java:1927-1929 -- NOT the first-pass 1f assumption). The AdjacentFactory updates-array precedent (SourceAdjacentFactoryBuildState.gd:382) does not fit: it passes bound RuntimeConsumer actors with update(self_state) methods (N2115/N2116), and this driver is pure-function based with no consumer actors -- so the removal is direct, through the shared liquid module helper (the PayloadLoader source_remove_state precedent), which clamps exactly like Java's LiquidModule.remove (`add(liquid, Math.max(-amount, -liquids[liquid.id]));`, LiquidModule.java:125-128). The multiplier is the default 1f (Consume.java:18), so the removal is amount * folded edelta.
			if should_consume and valid and float(frame.get("efficiency", 0.0)) > 0.0 and cyanogen_liquid_id >= 0:
				if liquids_store.has("liquids") and cyanogen_liquid_id < int(liquids_store["liquids"].size()):
					var folded_edelta: float = float(frame.get("efficiency", 0.0)) * tick_source_delta * tick_time_scale
					var remove_amount: float = SOURCE_SHOCKWAVE_TOWER_CYANOGEN_AMOUNT * folded_edelta
					var cache_sums: Array = []
					if liquids_store.get("flow") != null:
						cache_sums.resize(int(liquids_store["liquids"].size()))
						cache_sums.fill(0.0)
					source_liquid_module_state.source_remove_state(liquids_store, cyanogen_liquid_id, remove_amount, cache_sums)
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
			# N2340: the hitbox refinement (Groups.bullet.intersect is a QuadTree hitbox overlap query, EntityGroup.java:195 -- the QuadTree admits a bullet whose HITBOX strictly overlaps the query rect, QuadTree.java:190-191 / Rect.java:274-276) -- the rect-admitted list is refined by the hitbox pure at the SAME def range from the SAME live tower position, and the refined list reaches the advance below. The refinement filters hitbox overlap ONLY (team / hittable already filtered by the scan); a bullet with no hit_size key reads the BulletType default 4.0. Since N2347 the scan's broad phase admits straddlers (DEFERRED #330 resolved), so the refinement re-filters the same overlap -- idempotent.
			var refinement: Dictionary = source_shockwave_tower_supplied_bullets_hitbox_state(scanned_bullets, float(block.properties.get("range", 110.0)), scan_building_x, scan_building_y)
			var refined_bullets: Array = refinement.get("bullets", [])
			# The updateTile advance (N2247, ShockwaveTowerBuild.updateTile(), ShockwaveTower.java:72-105) follows the charge: the pure advance reads the counter the charge just advanced (it does NOT add edelta again), gates on the stamped potentialEfficiency + counter >= reload + the timer outcome, and decays heat every tick. reload comes from the catalog block like the N2187 gate (`reload = 80f;`, Blocks.java:2043, falling back to the class default `public float reload = 60f * 1.5f;`, ShockwaveTower.java:26); bulletDamage / falloffCount / cooldownMultiplier have no def override, so the driver constants carry the class values.
			var advanced: Dictionary = source_shockwave_tower_update_tile_advance_state(frame, source_placed_block_state.game_source_delta(game, seconds), float(block.properties.get("reload", 60.0 * 1.5)), SOURCE_SHOCKWAVE_TOWER_BULLET_DAMAGE, SOURCE_SHOCKWAVE_TOWER_FALLOFF_COUNT, SOURCE_SHOCKWAVE_TOWER_COOLDOWN_MULTIPLIER, refined_bullets, check_ready)
			frame["reload_counter"] = advanced.get("reload_counter", frame.get("reload_counter", 0.0))
			frame["heat"] = advanced.get("heat", frame.get("heat", 0.0))
			frame["targets"] = advanced.get("targets", frame.get("targets", []))
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
