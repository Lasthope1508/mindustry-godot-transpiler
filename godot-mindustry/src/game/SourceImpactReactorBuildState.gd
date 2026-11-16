extends RefCounted
class_name SourceImpactReactorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")

# The ImpactReactor implementation (ImpactReactor.java:17, `public class ImpactReactor extends PowerGenerator{`): impact-reactor (consumePower 25f, Blocks.java:2642, `consumePower(25f);`; size 4, powerProduction 130f, itemDuration 140f, health 900, lead 500 / silicon 300 / graphite 400 / thorium 100 / surge-alloy 250 / metaglass 250, Blocks.java:2632-2645). ImpactReactor extends PowerGenerator, NOT a factory or crafter or bridge or conveyor or router, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_impact_reactor_building", the radar precedent), and this slice adds the impact-reactor key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceImpactReactor* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the ImpactReactorBuild.updateTile only warms up while efficiency is ~1 AND power.status is ~1 (ImpactReactor.java:79, `if(efficiency >= 0.9999f && power.status >= 0.99f){`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) -- so a reactor that cannot draw its 25f never warms up and never produces, as if power.status were 1.0. Consume-vs-produce care: the reactor is a GENERATOR -- it both consumes 25f and produces `powerProduction * productionEfficiency` (130f at full warmup) -- so the row this slice folds is the CONSUMER-side read (`return build.power.status;`, ConsumePower.java:39), exactly like every pure-consumer slice; the PRODUCER side (`getPowerProduction()`, PowerGenerator.java:156-158, `return enabled ? powerProduction * productionEfficiency : 0f;`, with `productionEfficiency = Mathf.pow(warmup, 5f);`, ImpactReactor.java:100) waits for its own slice. The warmup gate is a HARD gate, unlike the router's base-efficiency soft coupling: at efficiency 0 the warmup decays to 0 and production is 0 -- there is no baseEfficiency-style floor.
const SOURCE_IMPACT_REACTOR_BUILD_IMPLEMENTATIONS := ["ImpactReactor"]
const SOURCE_IMPACT_REACTOR_BUILDING_META_KEY := "source_impact_reactor_building"
# ImpactReactor warmup speed (ImpactReactor.java:19, `public float warmupSpeed = 0.001f;`): the class default, NOT overridden by the single impact-reactor def (Blocks.java:2632-2645 carries no warmupSpeed line), so the advance lerps toward 1 at 0.001 * timeScale per tick.
const SOURCE_IMPACT_REACTOR_WARMUP_SPEED := 0.001
# The required liquid consumer (Blocks.java:2644, `consumeLiquid(Liquids.cryofluid, 0.25f);`): the single impact-reactor def consumes cryofluid at 0.25f PER FRAME (= 15/s, ConsumeLiquid.display shows amount * 60f), not /60f; the def sets no multiplier (Consume.java:18 default `public Floatf<Building> multiplier = b -> 1f;`), so the row and the second-pass removal both use 1f.
const SOURCE_IMPACT_REACTOR_LIQUID := "cryofluid"
const SOURCE_IMPACT_REACTOR_LIQUID_AMOUNT := 0.25
# The required item consumer (Blocks.java:2643, `consumeItem(Items.blastCompound);`): the single impact-reactor def consumes ONE blast-compound per timer fire (consumeItem(item) is ItemStack(item, 1), Block.java:1167-1168, `return consumeItem(item, 1);`); the def itemDuration is 140f (Blocks.java:2637, `itemDuration = 140f;`), NOT the class default 60f (ImpactReactor.java:20, `public float itemDuration = 60f;`).
const SOURCE_IMPACT_REACTOR_ITEM := "blast-compound"
const SOURCE_IMPACT_REACTOR_ITEM_AMOUNT := 1
const SOURCE_IMPACT_REACTOR_ITEM_DURATION := 140.0

static func _is_impact_reactor_build_implementation(implementation: String) -> bool:
	return SOURCE_IMPACT_REACTOR_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_impact_reactor_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The impact-reactor tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (ImpactReactor.java:17, `public class ImpactReactor extends PowerGenerator{`; ImpactReactorBuild, ImpactReactor.java:74, `public class ImpactReactorBuild extends GeneratorBuild{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# impact reactor skips consumption like Java's updateConsumption
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
	# for this impact reactor (N2125); the tick preserves a disabled
	# impact reactor instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {"liquids": {}, "items": {}}

static func source_impact_reactor_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the impact-reactor frame meta key
	# ("source_impact_reactor_building"). An ImpactReactor sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_impact_reactor_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_IMPACT_REACTOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_IMPACT_REACTOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_IMPACT_REACTOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_impact_reactor_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so an impact-reactor does not take the early return. The impact reactor's power draw is STATIC, not conditional: `consumePower(25f);` (Blocks.java:2642) registers a plain ConsumePower, so the catalog consumePower 25.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The impact reactor's updateTile (ImpactReactor.java:79, `if(efficiency >= 0.9999f && power.status >= 0.99f){`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) only warms up while efficiency is ~1 AND power.status is ~1 -- and because the reactor has no baseEfficiency floor, the warmup decays to 0 and production is 0 when the gate fails; the power bar shows the NET output (ImpactReactor.java:50, `Strings.fixed(Math.max(entity.getPowerProduction() - (consPower == null ? 0f : consPower.usage), 0) * 60 * entity.timeScale(), 1)),`). The producer side (`getPowerProduction()`, PowerGenerator.java:156-158, `return enabled ? powerProduction * productionEfficiency : 0f;`) is NOT folded here: this slice folds only the consumer-side power.status, exactly like every pure-consumer slice.
	# ImpactReactorBuild has NO shouldConsume override, so the BuildingComp default applies (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). There is NO gate to defer here (unlike the ItemBridge / LiquidBridge link gates): the power-only fold is EXACT, because the only gate is `enabled`, which the driver already checks. canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and edelta (BuildingComp.java:1927-1929, `return efficiency * delta();`) are the surrounding gates. The single def carries `consumePower(25f);` (Blocks.java:2642) against `powerProduction = 130f;` (Blocks.java:2636), with `itemDuration = 140f;` (Blocks.java:2637), `liquidCapacity = 80f;` (Blocks.java:2640), `size = 4;` (Blocks.java:2634), `health = 900;` (Blocks.java:2635), `ambientSound = Sounds.loopPulse;` (Blocks.java:2638) and `ambientSoundVolume = 0.08f;` (Blocks.java:2639).
	# The impact reactor is its own family (ImpactReactor.java:17, `public class ImpactReactor extends PowerGenerator{`; ImpactReactorBuild, ImpactReactor.java:74, `public class ImpactReactorBuild extends GeneratorBuild{`), a power block, NOT related to any factory / turret / defense / bridge / conveyor / router family. Class fields: `public final int timerUse = timers++;` (ImpactReactor.java:18), `public float warmupSpeed = 0.001f;` (ImpactReactor.java:19), `public float itemDuration = 60f;` (ImpactReactor.java:20); constructor `public ImpactReactor(String name){` (ImpactReactor.java:22), `hasPower = true;` (ImpactReactor.java:24), `hasLiquids = true;` (ImpactReactor.java:25), `liquidCapacity = 30f;` (ImpactReactor.java:26), `hasItems = true;` (ImpactReactor.java:27), `outputsPower = consumesPower = true;` (ImpactReactor.java:28), `flags = EnumSet.of(BlockFlag.reactor, BlockFlag.generator);` (ImpactReactor.java:29), `lightRadius = 115f;` (ImpactReactor.java:30), `emitLight = true;` (ImpactReactor.java:31), `envEnabled = Env.any;` (ImpactReactor.java:32), `drawer = new DrawMulti(new DrawRegion("-bottom"), new DrawPlasma(), new DrawDefault());` (ImpactReactor.java:34), `explosionShake = 6f;` (ImpactReactor.java:36), `explosionShakeDuration = 16f;` (ImpactReactor.java:37), `explosionDamage = 1900 * 4;` (ImpactReactor.java:38), `explosionMinWarmup = 0.3f;` (ImpactReactor.java:39), `explodeEffect = Fx.impactReactorExplosion;` (ImpactReactor.java:40), `explodeSound = Sounds.explosionReactor2;` (ImpactReactor.java:41). Build fields: `public float warmup, totalProgress;` (ImpactReactor.java:75). The warmup branch (ImpactReactor.java:80, `boolean prevOut = consPower != null && getPowerProduction() <= consPower.requestedPower(this);` with ImpactReactor.java:82, `warmup = Mathf.lerpDelta(warmup, 1f, warmupSpeed * timeScale);`, ImpactReactor.java:83, `if(Mathf.equal(warmup, 1f, 0.001f)){` and ImpactReactor.java:84, `warmup = 1f;`) warms the reactor while the gate holds; the first-production event (ImpactReactor.java:87, `if(!prevOut && consPower != null && (getPowerProduction() > consPower.requestedPower(this))){` with ImpactReactor.java:88, `Events.fire(Trigger.impactPower);`) fires when production first exceeds the requested power, and the consume timer (ImpactReactor.java:91, `if(timer(timerUse, itemDuration / timeScale)){` with ImpactReactor.java:92, `consume();`) burns the blast-compound / cryofluid on schedule; the else branch (ImpactReactor.java:95, `warmup = Mathf.lerpDelta(warmup, 0f, 0.01f);`) cools the reactor down, and `totalProgress += warmup * Time.delta;` (ImpactReactor.java:98) tracks it, with `productionEfficiency = Mathf.pow(warmup, 5f);` (ImpactReactor.java:100). The accessors `public float warmup(){` (ImpactReactor.java:103) with `return warmup;` and `public float totalProgress(){` (ImpactReactor.java:107) with `return totalProgress;` expose the warmup state. The power bar `addBar("power", (GeneratorBuild entity) -> new Bar(() ->` (ImpactReactor.java:44) shows the net output, and `stats.add(Stat.productionTime, itemDuration / 60f, StatUnit.seconds);` (ImpactReactor.java:60) lists the production time; the warmup-time stats `float max = -(float)Math.log(0.001f) / warmupSpeed / 60f;` (ImpactReactor.java:64) and `float equal = -(float)Math.log(1f - Mathf.pow(consPower.usage / powerProduction, 1f / 5f)) / warmupSpeed / 60f;` (ImpactReactor.java:65) derive from the warmup speed.
	# The parent PowerGenerator (PowerGenerator.java:22, `public class PowerGenerator extends PowerDistributor{`; GeneratorBuild, PowerGenerator.java:93, `public class GeneratorBuild extends Building{`) supplies the production side: `public float powerProduction;` (PowerGenerator.java:25), `public float generateTime;` (PowerGenerator.java:94), `public float productionEfficiency = 0.0f;` (PowerGenerator.java:96), warmup() returns productionEfficiency when enabled (PowerGenerator.java:105, `return enabled ? productionEfficiency : 0f;`), and `public float getPowerProduction(){` (PowerGenerator.java:156) with `return enabled ? powerProduction * productionEfficiency : 0f;` (PowerGenerator.java:157). The production efficiency persists across saves: `write.f(productionEfficiency);` (PowerGenerator.java:166) with `productionEfficiency = read.f();` (PowerGenerator.java:172).
	# Single def -- impact-reactor only (size 4, health 900, powerProduction 130f, itemDuration 140f, liquidCapacity 80f, lead 500 / silicon 300 / graphite 400 / thorium 100 / surge-alloy 250 / metaglass 250, Blocks.java:2632-2645): `impactReactor = new ImpactReactor("impact-reactor"){{` (Blocks.java:2632) with `requirements(Category.power, with(Items.lead, 500, Items.silicon, 300, Items.graphite, 400, Items.thorium, 100, Items.surgeAlloy, 250, Items.metaglass, 250));` (Blocks.java:2633), `size = 4;` (Blocks.java:2634), `health = 900;` (Blocks.java:2635), `powerProduction = 130f;` (Blocks.java:2636), `itemDuration = 140f;` (Blocks.java:2637), `ambientSound = Sounds.loopPulse;` (Blocks.java:2638), `ambientSoundVolume = 0.08f;` (Blocks.java:2639), `liquidCapacity = 80f;` (Blocks.java:2640), `consumePower(25f);` (Blocks.java:2642), `consumeItem(Items.blastCompound);` (Blocks.java:2643) and `consumeLiquid(Liquids.cryofluid, 0.25f);` (Blocks.java:2644). No second ImpactReactor def exists; there is no family split to manage. ImpactReactorBuild DOES override sense() (`public double sense(LAccess sensor){`, ImpactReactor.java:119-122, heat returns warmup) and warmup() (`public float warmup(){`, ImpactReactor.java:104-106) -- both live since N2391 (an earlier docstring line claimed no sense override existed -- WRONG; the DEFERRED cite :124-127 was also off by a few lines, :124-127 is the write() override). The read/write overrides (ImpactReactor.java:125-134) still wait for their own slices.
	# Documented limits: (1) power + liquid + item first pass -- the impact reactor's static power consumer (consumePower 25f, Blocks.java:2642), its required liquid consumer (cryofluid 0.25f per frame, Blocks.java:2644, N2254) and its required item consumer (1 blast-compound, Blocks.java:2643, `consumeItem(Items.blastCompound);`, BINARY row, ConsumeItems.efficiency, ConsumeItems.java:51-53, `return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;`) are the modeled consumers, so the folded efficiency is the min over the *modeled* consumers (power + liquid + item); the item row is live (N2266), and the timer-gated consume is live too (N2266: `if(timer(timerUse, itemDuration / timeScale)){` with `consume();`, ImpactReactor.java:91-92, itemDuration 140f def, Blocks.java:2637) -- the frame-local Interval-equivalent (frame["timer_use_elapsed"] accumulates source_delta every tick, TimerComp.java:10-13, `if(Float.isInfinite(time)) return false;`, arc Interval.java:20-26, `if(got) times[id] = Time.time;`) removes 1 blast-compound when the warmup gate holds and the timer fires. KNOWN DEVIATION (first-fire): Java fires (nearly) immediately after placement when the gate first opens (global Time.time is already large vs a fresh Interval times[]=0, arc Time.java:75, `timeRaw += delta;`), while the frame-local clock delays the first fire by a full interval -- a global-clock timer-infra slice would fix it. NO live intake fills frame["items"] yet (the Separator precedent), so the row reads the frame as-is and a live reactor with no intake folds efficiency 0. The impact-power event (ImpactReactor.java:87-88, `Events.fire(Trigger.impactPower);`) still waits for its own slice. (2) NO shouldConsume gate to defer -- ImpactReactorBuild has no shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-756) applies; the power + liquid + item fold is EXACT for this family. (3) updateTile warmup / production advance DONE (N2192) -- warmup / totalProgress / productionEfficiency advance each tick (ImpactReactor.java:79-100); the consume timer is live (N2266, frame-local Interval-equivalent, first-fire deviation noted in (1)); the impact-power event (ImpactReactor.java:87-88) still waits for its own slice. (4) No producer-side fold yet -- productionEfficiency is tracked as a frame key (N2192) but no production fold reads it; getPowerProduction (PowerGenerator.java:156-158) waits for its own slice. (5) Single def -- impact-reactor only (size 4, health 900, powerProduction 130f, itemDuration 140f, liquidCapacity 80f, lead 500 / silicon 300 / graphite 400 / thorium 100 / surge-alloy 250 / metaglass 250); per-def stat values wait for their own verification slice. (6) Draw rows live (N2430) -- the draw pure (source_impact_reactor_draw_state) models GeneratorBuild.draw() (PowerGenerator.java:99-100, drawer.draw(this)) through the DrawMulti class-default drawer (ImpactReactor.java:34, no def override in Blocks.java:2632-2645): the -bottom region rect (DrawRegion.java:51, rotation 0) + the 4 plasma rects (DrawPlasma.java:36-47, additive blend, r from the caller-supplied atlas sizes, alpha scaled by warmup, rotation totalProgress * (12 + 6i)) + the base rect (DrawDefault.java:13, drawrot 0, rotate false) + the light (GeneratorBuild.drawLight, PowerGenerator.java:145-148: the DrawPlasma light, DrawPlasma.java:32, radius (110 + absin(5, 5)) * warmup, color plasma2 -> plasma1 at absin(7, 0.2), alpha 0.8 * warmup, AND the super liquid light, BuildingComp.java:1309-1317, cryofluid lightColor alpha 0.2, radius size * 30) + icons() (PowerGenerator.java:54-56, [impact-reactor-bottom, impact-reactor], DrawPlasma contributes nothing). NO RNG in the pure: DrawPlasma.draw/drawLight roll nothing (the parent DrawFlame.draw uses Mathf.random, but DrawPlasma overrides draw fully so the parent flame never runs); the absin calls land Java-exact through the shared helper at the DOUBLED scale. lightRadius 115f feeds only Block.drawEnvironmentLight for unbuilt tiles (BlockRenderer.java:842-844), not the placed reactor's light. Pure-only: the tick never calls draw -- draw/drawLight are called by the renderer, icons by the atlas, and the call sites wait for renderer slices. drawPlanRegion waits for its own slice (the N2419 separate plan-pure precedent); drawSelect is the shared BuildingComp default (BuildingComp.java:1242-1248, no family override) and config waits for its own slice. (7) Sense rows live (N2391) -- the sense pure (source_impact_reactor_sense_state) models sense() (:119-122): heat returns the frame warmup directly and every other sensor falls through to the caller-supplied super.sense value (the BuildingComp switch, already modeled by SourceBuildingSenseState); the warmup() accessor pure (source_impact_reactor_warmup_state) models warmup() (:104-106) for the DrawPlasma drawer. Pure-only: the tick never calls sense/warmup -- sense is called by logic and warmup() by the drawer, and both call sites wait for their own slices.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_impact_reactor_liquid_consumer_row_state(frame: Dictionary, has_liquid_consumer: bool, liquid_id: int, amount: float, source_delta: float, time_scale: float, efficiency_scale: float, multiplier: float = 1.0) -> Dictionary:
	# ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47): `float ed = build.edelta() * build.efficiencyScale();` (ConsumeLiquid.java:43), `if(ed <= 0.00000001f) return 0f;` (ConsumeLiquid.java:44), `return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);` (ConsumeLiquid.java:46) -- the required liquid row folds into the first-pass min exactly like the power row (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`), and a starved row stops the power draw (`if(cons != block.consPower && result <= 0.0000001f){`, BuildingComp.java:1972, with `shouldConsumePower = false;`, BuildingComp.java:1973 -- the shared fold does that, SourceBuildingEfficiencyState.gd:109-117). In the first pass efficiency is assumed 1f (BuildingComp.java:1964-1965, `efficiency = optionalEfficiency = 1f;`), so edelta() = delta() = Time.delta * timeScale (BuildingComp.java:1922-1929, `return efficiency * delta();` / `return Time.delta * timeScale;`), i.e. ed = source_delta * time_scale * efficiency_scale here; efficiencyScale() defaults to 1f (BuildingComp.java:1939-1941, `public float efficiencyScale(){` with `return 1f;`). The amount comes from the shared liquid module helper (SourceLiquidModuleState.source_get_state, reused through a preload, NOT re-implemented) over the frame liquids key (the Building.liquids LiquidModule dict, default {} for a frame bound before this slice, amount 0.0 when the store has no entry for the liquid -- Java's liquids.get returns 0.0 for a liquid never added), with the Fracker guard (SourceFrackerBuildState.gd:221: `liquids.has("liquids")` + bounds check). The single def consumes cryofluid 0.25f PER FRAME (= 15/s), `consumeLiquid(Liquids.cryofluid, 0.25f);` (Blocks.java:2644); the def sets no multiplier, so the default `public Floatf<Building> multiplier = b -> 1f;` (Consume.java:18) applies. The item row (blast-compound, Blocks.java:2643, `consumeItem(Items.blastCompound);`, burned on the timer, ImpactReactor.java:91-92, `if(timer(timerUse, itemDuration / timeScale)){` with `consume();`) is NOT this slice -- it stays deferred. A def with no liquid consumer contributes no row (the has_power_row pattern).
	if not has_liquid_consumer:
		return {"has_liquid_row": false, "row": {}}
	var liquids: Dictionary = frame.get("liquids", {})
	var liquid_amount: float = 0.0
	if liquids.has("liquids") and liquid_id >= 0 and liquid_id < int(liquids["liquids"].size()):
		liquid_amount = float(source_liquid_module_state.source_get_state(liquids, liquid_id).get("amount", 0.0))
	var ed: float = source_delta * time_scale * efficiency_scale
	if ed <= 0.00000001:
		return {"has_liquid_row": true, "row": {"result": 0.0, "is_power": false}}
	var result: float = minf(liquid_amount / (amount * ed * multiplier), 1.0)
	return {"has_liquid_row": true, "row": {"result": result, "is_power": false}}

static func source_impact_reactor_item_consumer_row_state(frame: Dictionary, stacks: Array) -> Dictionary:
	# ConsumeItems.efficiency (ConsumeItems.java:51-53, `return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;`): BINARY 1/0, not a ratio -- 1 when the building is burning a trigger consumer or its item module holds every stack, 0 otherwise. consumeTriggerValid() is false at the base (BuildingComp.java:764-766, `public boolean consumeTriggerValid(){` with `return false;`) and no ImpactReactor / GeneratorBuild / PowerGenerator override exists, so the trigger term is always false here. items.has (ItemModule.java:153-158, `if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;`) requires EVERY stack to hold round(amount * multiplier), with has(item, amount) = get(item) >= amount (ItemModule.java:126-128, `return get(item) >= amount;`); the port's item module is a Dictionary keyed by item name, so an unknown item reads 0 through the shared inventory helper (SourceDrillInventoryRuntimeState.item_count, reused through a preload, NOT re-implemented), the same outcome as the id-out-of-range branch. The multiplier defaults to 1f (Consume.java:18, `public Floatf<Building> multiplier = b -> 1f;`); the single def sets none, so the required count is round(amount * 1f) = amount. The row is REQUIRED (non-optional), so it folds the first pass (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`), and a starved row stops the power draw (`if(cons != block.consPower && result <= 0.0000001f){`, BuildingComp.java:1972). The single def consumes one blast-compound, `consumeItem(Items.blastCompound);` (Blocks.java:2643; `consumeItem(item)` is ItemStack(item, 1), Block.java:1167-1168, `return consumeItem(item, 1);`); the stacks arrive explicit from the driver (the catalog captures them as consumeItem, [{amount: 1, item: "blast-compound"}]). ConsumeItems has NO update override, so the second pass (`if(update && efficiency > 0){`, BuildingComp.java:1999, with `cons.update(self());`, BuildingComp.java:2001) never consumes items -- the removal happens only through consume() (`for(Consume cons : block.consumers){`, BuildingComp.java:1912, with `cons.trigger(self());`, BuildingComp.java:1913), when the timer fires: ConsumeItems.trigger removes `build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));` (ConsumeItems.java:44-48), clamped to what the module holds (`amount = Math.min(amount, items[item.id]);`, ItemModule.java:258-263) -- the tick wires that removal after the advance (N2266). No live intake fills frame["items"] yet (the Separator precedent), so the row reads the frame as-is. A def with no item consumer passes empty stacks and contributes no row (the has_power_row pattern).
	if stacks.is_empty():
		return {"has_item_row": false, "row": {}}
	var items: Dictionary = frame.get("items", {})
	var has_all := true
	for stack in stacks:
		var entry: Dictionary = stack if stack is Dictionary else {}
		var item_id: String = str(entry.get("item", ""))
		var amount: int = int(entry.get("amount", 0))
		if inventory.item_count(items, item_id) < amount:
			has_all = false
			break
	var result: float = 1.0 if has_all else 0.0
	return {"has_item_row": true, "row": {"result": result, "is_power": false}}

static func source_impact_reactor_timer_use_state(elapsed: float, duration: float, time_scale: float) -> Dictionary:
	# The frame-local Interval-equivalent for `if(timer(timerUse, itemDuration / timeScale)){` (ImpactReactor.java:91): TimerComp.timer (TimerComp.java:10-13, `if(Float.isInfinite(time)) return false;` with `return timer.get(index, time);`) returns false for an infinite time and otherwise delegates to arc Interval.get (Interval.java:20-26), which fires when `return Time.time - times[id] >= time || Time.time < times[id];` (Interval.java:28-30) and RESETS `if(got) times[id] = Time.time;` (Interval.java:24) on fire -- reset, NOT subtract like the Fracker accumulator. Time.time counts in TICKS (`timeRaw += delta;`, arc Time.java:75, with delta = `Math.min(Core.graphics.getDeltaTime() * 60f, 3f)`, arc Time.java:26), so the threshold is duration / time_scale in ticks (140f / timeScale for the single def, Blocks.java:2637, `itemDuration = 140f;`, NOT the class default 60f, ImpactReactor.java:20, `public float itemDuration = 60f;`). The port has NO global tick clock at the driver layer (source_time_ticks is only a draw param), so the driver accumulates source_delta into frame["timer_use_elapsed"] every tick, unconditionally (mirroring Time.time rising every frame, even while the gate is closed -- Java does the same, so the timer fires as soon as the gate re-opens). time_scale <= 0 makes the Java threshold infinite (140f / 0f), so TimerComp returns false -- the port returns fired=false the same way. KNOWN DEVIATION (first-fire): Java fires (nearly) immediately after placement when the gate first opens (global Time.time is already large vs a fresh Interval times[]=0), while the frame-local clock delays the first fire by a full interval -- a global-clock timer-infra slice would fix it (see DEFERRED).
	if time_scale <= 0.0:
		return {"fired": false, "elapsed_after": elapsed, "threshold": INF}
	var threshold: float = duration / time_scale
	var fired: bool = elapsed >= threshold
	return {"fired": fired, "elapsed_after": 0.0 if fired else elapsed, "threshold": threshold}

static func source_impact_reactor_update_tile_advance_state(frame: Dictionary, time_scale: float, source_delta: float) -> Dictionary:
	# ImpactReactorBuild.updateTile() (ImpactReactor.java:78-101) advances the warmup AFTER updateConsumption (BuildingComp.update(), BuildingComp.java:2274 `updateConsumption();` then :2277 `updateTile();`, gated on `if(enabled || !block.noUpdateDisabled){`, BuildingComp.java:2276, with the default `public boolean noUpdateDisabled = false;`, Block.java:170 -- ImpactReactor sets no override, so updateTile runs even when disabled (the OR holds via !noUpdateDisabled); in Java a disabled reactor's efficiency is 0 (the disabled early return, BuildingComp.java:1954-1957, `potentialEfficiency = efficiency = optionalEfficiency = 0f;`), so its warmup DECAYS -- the port driver gates the advance on enabled (see the driver comment below) because the driver does not model the disabled efficiency-zeroing yet, so a disabled reactor's warmup freezes in the port instead of decaying (documented deviation, see DEFERRED): while the gate holds (`if(efficiency >= 0.9999f && power.status >= 0.99f){`, ImpactReactor.java:79, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) the warmup lerps toward 1 (`warmup = Mathf.lerpDelta(warmup, 1f, warmupSpeed * timeScale);`, ImpactReactor.java:82) and snaps (`if(Mathf.equal(warmup, 1f, 0.001f)){`, ImpactReactor.java:83, with `warmup = 1f;`, ImpactReactor.java:84); otherwise it decays (`warmup = Mathf.lerpDelta(warmup, 0f, 0.01f);`, ImpactReactor.java:95). Either way `totalProgress += warmup * Time.delta;` (ImpactReactor.java:98) and `productionEfficiency = Mathf.pow(warmup, 5f);` (ImpactReactor.java:100). Mathf.lerpDelta is `return lerp(fromValue, toValue, clamp(progress * Time.delta));` (Mathf.java:430-431), ported as SourceMathState.source_lerp_delta (lerpf with clampf(source_delta * progress, 0, 1)); Mathf.equal is `return Math.abs(a - b) <= tolerance;` (Mathf.java:554-555), inlined here as absf(warmup - 1.0) <= 0.001 because the port has no Mathf.equal helper; Mathf.pow is `return (float)Math.pow(a, b);` (Mathf.java:212-213), Godot pow(). Time.delta is the frame delta in 60fps ticks (`Math.min(Core.graphics.getDeltaTime() * 60f, 3f)`, arc Time.java:26), so the driver passes seconds * 60 (the N2093 pump precedent). The frame carries the build fields (`public float warmup, totalProgress;`, ImpactReactor.java:75, both 0f by default) plus the folded efficiency (frame["efficiency"], missing only before the first consumption fold -- the cheating / no-consumer early return sets it to 1f when enabled, BuildingComp.java:1945-1947, `if(!block.hasConsumers || cheating()){` with `efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;`, so the missing default is 1.0) and the stamped power.status (frame["power_status"], 1.0 when missing, the assembler fold). timeScale is the sprite-meta timeScale (BuildingComp.java:98, `private transient float timeScale = 1f, timeScaleDuration;`, read as `return timeScale;`, BuildingComp.java:599-600, default 1.0). DEFERRED, not done here: the first-production event (`boolean prevOut = consPower != null && getPowerProduction() <= consPower.requestedPower(this);`, ImpactReactor.java:80, with `if(!prevOut && consPower != null && (getPowerProduction() > consPower.requestedPower(this))){`, ImpactReactor.java:87, and `Events.fire(Trigger.impactPower);`, ImpactReactor.java:88 -- needs getPowerProduction() and consPower.requestedPower(this) from the power graph, which the port does not model yet) and the consume timer (`if(timer(timerUse, itemDuration / timeScale)){`, ImpactReactor.java:91, with `consume();`, ImpactReactor.java:92 -- needs timer + item/liquid consumption infrastructure). productionEfficiency starts at `public float productionEfficiency = 0.0f;` (PowerGenerator.java:96); the producer fold (`return enabled ? powerProduction * productionEfficiency : 0f;`, PowerGenerator.java:156-158) does NOT read this frame key yet -- the key is tracked here and waits for its consumer slice. Readers of the new state: `public float warmup(){` / `return warmup;` (ImpactReactor.java:104-105) and `public float totalProgress(){` / `return totalProgress;` (ImpactReactor.java:109-110). Single def context: `itemDuration = 140f;` (Blocks.java:2637), `powerProduction = 130f;` (Blocks.java:2636), `consumePower(25f);` (Blocks.java:2642).
	var efficiency: float = float(frame.get("efficiency", 1.0))
	var stamped: Variant = frame.get("power_status", null)
	var power_status: float = 1.0 if stamped == null else float(stamped)
	var warmup: float = float(frame.get("warmup", 0.0))
	var total_progress: float = float(frame.get("total_progress", 0.0))
	if efficiency >= 0.9999 and power_status >= 0.99:
		warmup = source_math_state.source_lerp_delta(warmup, 1.0, SOURCE_IMPACT_REACTOR_WARMUP_SPEED * time_scale, source_delta)
		if absf(warmup - 1.0) <= 0.001:
			warmup = 1.0
	else:
		warmup = source_math_state.source_lerp_delta(warmup, 0.0, 0.01, source_delta)
	total_progress += warmup * source_delta
	var production_efficiency: float = pow(warmup, 5.0)
	return {"warmup": warmup, "total_progress": total_progress, "production_efficiency": production_efficiency}

static func source_impact_reactor_sense_state(sensor: String, warmup: float, super_value: Variant = null) -> Dictionary:
	# The sense rows (ImpactReactorBuild.sense(), ImpactReactor.java:119-122), the pure logic-sense dispatch -- Java senses, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public double sense(LAccess sensor){`
	# `if(sensor == LAccess.heat) return warmup;`
	# `return super.sense(sensor);`
	# warmup is the frame value the N2192 advance tracks
	# (`public float warmup, totalProgress;`, ImpactReactor.java:75) -- the heat value is the frame warmup DIRECTLY, no clamp, no ratio (unlike the N2383 MendProjector progress clamp, which clamps charge / reload to [0, 1]): Java returns the raw field. super.sense is VERIFIED, not guessed: the BuildingComp switch (BuildingComp.java:2093-2125):
	# `return switch(sensor){`
	# `case health -> health;`
	# `case efficiency -> efficiency;`
	# `default -> Float.NaN; //gets converted to null in logic`
	# covers x / y / color / dead / solid / team / health / maxHealth / efficiency / timescale / range / rotation / totalItems / totalLiquids / totalPower / itemCapacity / liquidCapacity / powerCapacity / powerNetIn / powerNetOut / powerNetStored / powerNetCapacity / enabled / controlled / payloadCount / size / cameraX, cameraY, cameraWidth, cameraHeight, and the default branch is Float.NaN (converted to null in logic). The port ALREADY models that switch (SourceBuildingSenseState: sense_position_state, sense_health_process_state, sense_totals_state, sense_capacity_power_net_state, sense_enabled_controlled_state, sense_payload_size_state, sense_camera_default_state), so the pure takes the caller's super.sense result as super_value (default null = the default branch) instead of re-modeling the switch. senseObject / sense(Content) are separate overloads (BuildingComp.java:2128+) and are NOT modeled here. Pure-only, like the N2383 sense pure: the tick never calls sense (verified: grep `sense` in this driver finds only comments) -- sense is called by logic, not the tick, and the logic call site waits for a logic-executor slice (a port-wide concern, not an ImpactReactor deferral).
	var is_heat: bool = sensor == "heat"
	var value: Variant = warmup if is_heat else super_value
	return {
		"heat_expr": "if(sensor == LAccess.heat) return warmup;",
		"super_expr": "return super.sense(sensor);",
		"sensor": sensor,
		"warmup": warmup,
		"super_value": super_value,
		"is_heat": is_heat,
		"value": value,
	}

static func source_impact_reactor_warmup_state(warmup: float) -> Dictionary:
	# The warmup() accessor (ImpactReactorBuild.warmup(), ImpactReactor.java:104-106) -- a SEPARATE pure from the sense dispatch, because the call shape differs: warmup() is called by the DRAWER, not by logic -- DrawPlasma scales its light and alpha by `build.warmup()` (DrawPlasma.java:32, 42), and the ImpactReactor drawer includes DrawPlasma (`drawer = new DrawMulti(new DrawRegion("-bottom"), new DrawPlasma(), new DrawDefault());`, ImpactReactor.java:34). Java, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public float warmup(){`
	# `return warmup;`
	# warmup is the frame value the N2192 advance tracks (`public float warmup, totalProgress;`, ImpactReactor.java:75). NOTE the parent: PowerGenerator.warmup() returns productionEfficiency when enabled (PowerGenerator.java:105, `return enabled ? productionEfficiency : 0f;`) -- but ImpactReactorBuild OVERRIDES it to return the raw warmup field, so the port models the override, not the parent. Pure-only, like the sense pure: the tick never calls warmup() (verified: grep finds only comments in this driver) -- the drawer does, and the draw rows wait for their own slice (see DEFERRED).
	return {
		"warmup_expr": "return warmup;",
		"warmup": warmup,
		"value": warmup,
	}

static func source_impact_reactor_draw_state(x_value: float, y_value: float, warmup: float, total_progress: float, time_value: float, plasma_region_sizes: Array, liquid_amount: float, liquid_light_alpha: float, liquid_light_color: String, visual_liquid: float, source_delta: float, size_value: int) -> Dictionary:
	# The draw / drawLight / icons rows (GeneratorBuild.draw(), PowerGenerator.java:99-100, `drawer.draw(this);`; GeneratorBuild.drawLight(), PowerGenerator.java:145-148, `super.drawLight();` + `drawer.drawLight(this);`; icons(), PowerGenerator.java:54-56, `return drawer.finalIcons(this);`), the pure draw-call dict -- the port never draws for real (the N2396 MassDriver precedent: the pure returns the draw calls as data). Verify-first finding (N2430): the parent class default drawer is DrawDefault (`public DrawBlock drawer = new DrawDefault();`, PowerGenerator.java:27), but ImpactReactor overrides it with the DrawMulti (`drawer = new DrawMulti(new DrawRegion("-bottom"), new DrawPlasma(), new DrawDefault());`, ImpactReactor.java:34), and the single impact-reactor def does NOT override it again (`impactReactor = new ImpactReactor("impact-reactor"){{`, Blocks.java:2632, with `size = 4;`, Blocks.java:2634 -- no drawer line in Blocks.java:2632-2645, unlike the Separator N2419 lesson where BOTH defs overrode the class default), so the live draw is the DrawMulti composition, in drawer order (DrawMulti.java:33-36, `for(var draw : drawers){` + `draw.draw(build);`):
	# (1) DrawRegion("-bottom") -- a plain region rect (`Draw.rect(region, build.x + x, build.y + y, build.totalProgress() * rotateSpeed + rotation + (buildingRotate ? build.rotdeg() : 0));`, DrawRegion.java:51) with rotateSpeed 0, rotation 0, buildingRotate false, x/y 0, color null, layer -1, so the rotation folds to 0 and the z is untouched (layer -1 disables the layer change, DrawRegion.java:46); the region loads as block.name + suffix (`region = Core.atlas.find(name != null ? name : block.name + suffix);`, DrawRegion.java:74), so impact-reactor-bottom for the single def.
	# (2) DrawPlasma() -- the four additive plasma rects (`Draw.blend(Blending.additive);`, DrawPlasma.java:37): `public String suffix = "-plasma-";` (DrawPlasma.java:15) and `public int plasmas = 4;` (DrawPlasma.java:16), so the regions load as block.name + suffix + i (`regions[i] = Core.atlas.find(block.name + suffix + i);`, DrawPlasma.java:26), impact-reactor-plasma-0..3. Per rect (DrawPlasma.java:38-43): `float r = ((float)regions[i].width * regions[i].scl() - 3f + Mathf.absin(Time.time, 2f + i * 1f, 5f - i * 0.5f));` -- the atlas size (width * scl(), arc TextureRegion.java:311-313, `return scale * Draw.scl;`) is caller-supplied in plasma_region_sizes (the port has no atlas; a missing entry reads 0.0, an unloaded region); `Draw.color(plasma1, plasma2, (float)i / regions.length);` with `public Color plasma1 = Color.valueOf("ffd06b"), plasma2 = Color.valueOf("ff361b");` (DrawPlasma.java:18), carried as an explicit from/to/t dict (the N2356 precedent); `Draw.alpha((0.3f + Mathf.absin(Time.time, 2f + i * 2f, 0.3f + i * 0.05f)) * build.warmup());` -- the alpha scales by build.warmup(), the frame warmup the N2192 advance tracks (the N2391 accessor pure); `Draw.rect(regions[i], build.x + x, build.y + y, r, r, build.totalProgress() * (12 + i * 6f));` with x/y 0 (DrawPlasma.java:13 defaults) and totalProgress the frame value the N2192 advance tracks. NO RNG IN THE PURE: DrawPlasma.draw rolls nothing -- the parent DrawFlame.draw uses Mathf.random (DrawFlame.java:36, `float cr = Mathf.random(0.1f);`), but DrawPlasma overrides draw fully (DrawPlasma.java:36) so the parent flame never runs for this drawer. The absin calls land Java-exact through the shared helper at the DOUBLED scale: Java absin is `return (sin(in, scl * 2f, mag) + mag) / 2f;` (arc Mathf.java:78-80), while the helper is `(sin(value / scl) * 0.5 + 0.5) * mag` (SourceMathState.source_absin), i.e. helper(v, s) == Java absin(v, s / 2f) -- so the pure passes the doubled scale 2 * scl (the N2372/N2382 precedent; Java's arc sin is a table lookup, so the pure is exact to <1e-3).
	# (3) DrawDefault -- the base region rect (`Draw.rect(build.block.region, build.x, build.y, build.drawrot());`, DrawDefault.java:13) at drawrot() (`return block.rotate && block.rotateDraw ? rotation * 90 : 0f;`, BuildingComp.java:587-589), which folds to 0: ImpactReactor sets no rotate (`public boolean rotate;`, Block.java:120, default false).
	# The light (GeneratorBuild.drawLight(), PowerGenerator.java:145-148) is super + drawer (DrawMulti.java:47-50, `for(var draw : drawers){` + `draw.drawLight(build);` -- only DrawPlasma overrides drawLight; DrawRegion/DrawDefault inherit the no-op base `public void drawLight(Building build){}`, DrawBlock.java:31-33): the DrawPlasma light `Drawf.light(build.x, build.y, (110f + Mathf.absin(5, 5f)) * build.warmup(), Tmp.c1.set(plasma2).lerp(plasma1, Mathf.absin(7f, 0.2f)), 0.8f * build.warmup());` (DrawPlasma.java:32 -- the 2-arg absin is `return absin(Time.time, scl, mag);`, arc Mathf.java:74-76, so both calls read Time.time; the color lerps plasma2 -> plasma1, NOTE the reversed order vs the draw rects) AND the super liquid light (BuildingComp.java:1309-1317): `Liquid liq = block.hasLiquids && block.lightLiquid == null ? liquids.current() : block.lightLiquid;` (lightLiquid null, so the current liquid -- cryofluid, the only liquid the def consumes, Blocks.java:2644) and `if(block.hasLiquids && block.drawLiquidLight && liq.lightColor.a > 0.001f){` (hasLiquids true, `public boolean drawLiquidLight = true;`, Block.java:276; cryofluid `lightColor = Color.valueOf("0097f5").a(0.2f);`, Liquids.java:44, so the gate passes), then `visualLiquid = Mathf.lerpDelta(visualLiquid, liquids.get(liq)>= 0.01f ? 1f : 0f, 0.06f);` -- lerpDelta is the arc form (`return lerp(fromValue, toValue, clamp(progress * Time.delta));`, arc Mathf.java:430-432), so the step is clamp(0.06 * delta) toward 1 when the tank holds >= 0.01, else toward 0 -- and drawLiquidLight (BuildingComp.java:1319-1327): `Drawf.light(x, y, block.size * 30f * fract, color, opacity * amount);` with fract 1f, opacity = lightColor.a, radius size * 30 (120 for the size-4 def). visualLiquid is transient draw state the tick never tracks, so the caller supplies the previous value and reads the new one back (the Separator N2419 precedent). lightRadius 115f (ImpactReactor.java:30) feeds ONLY Block.drawEnvironmentLight for unbuilt tiles (BlockRenderer.java:842-844, `tile.block().drawEnvironmentLight(tile);` in the entity == null branch -- a tile WITH a building calls entity.drawLight() instead, :841), never the placed reactor's light.
	# The icons ride this pure: icons() returns `return drawer.finalIcons(this);` (PowerGenerator.java:55); finalIcons (DrawBlock.java:50-59) takes the iconOverride branch only when iconOverride != null (`if(iconOverride != null){`, DrawBlock.java:51 -- null here, neither the class nor the def sets it), else the drawer icons, falling back to the error region only when empty. DrawMulti.icons concatenates in drawer order (`result.addAll(draw.icons(block));`, DrawMulti.java:63): "-bottom" gives its region (`return new TextureRegion[]{region};`, DrawRegion.java:69), DrawPlasma gives NOTHING (no icons() override, the base `return new TextureRegion[]{};`, DrawBlock.java:47), DrawDefault gives (`return new TextureRegion[]{block.region};`, DrawDefault.java:23). A zero-arg icons() pure cannot register (the SSOT schema validator requires non-empty input keys, the N2396 precedent), so the two regions ride the draw pure as icon_regions. drawPlanRegion (PowerGenerator.java:84-85, `drawer.drawPlan(this, plan, list);`) waits for its own slice (the N2419 separate plan-pure precedent -- see DEFERRED). Pure-only: the tick never calls draw -- draw is called by the renderer, drawLight by the renderer light pass, icons by the atlas, and the call sites wait for renderer slices.
	var draw_rotation: float = 0.0
	var bottom_call: Dictionary = {
		"call": "Draw.rect(region, build.x + x, build.y + y, build.totalProgress() * rotateSpeed + rotation + (buildingRotate ? build.rotdeg() : 0));",
		"region": "impact-reactor-bottom",
		"x": x_value,
		"y": y_value,
		"rotation": 0.0,
	}
	var plasma_rects: Array = []
	for plasma_index in range(4):
		var region_size: float = float(plasma_region_sizes[plasma_index]) if plasma_index < plasma_region_sizes.size() else 0.0
		var radius_absin: float = source_math_state.source_absin(time_value, (2.0 + float(plasma_index) * 1.0) * 2.0, 5.0 - float(plasma_index) * 0.5)
		var plasma_radius: float = region_size - 3.0 + radius_absin
		var alpha_absin: float = source_math_state.source_absin(time_value, (2.0 + float(plasma_index) * 2.0) * 2.0, 0.3 + float(plasma_index) * 0.05)
		var plasma_alpha: float = (0.3 + alpha_absin) * warmup
		plasma_rects.append({
			"region": "impact-reactor-plasma-" + str(plasma_index),
			"x": x_value,
			"y": y_value,
			"size": plasma_radius,
			"rotation": total_progress * (12.0 + float(plasma_index) * 6.0),
			"color": {"from": "ffd06b", "to": "ff361b", "t": float(plasma_index) / 4.0},
			"alpha": plasma_alpha,
			"radius_absin": radius_absin,
			"alpha_absin": alpha_absin,
		})
	var plasma_call: Dictionary = {
		"call": "Draw.rect(regions[i], build.x + x, build.y + y, r, r, build.totalProgress() * (12 + i * 6f));",
		"blend": "Blending.additive",
		"plasma_count": 4,
		"rects": plasma_rects,
	}
	var base_call: Dictionary = {
		"call": "Draw.rect(build.block.region, build.x, build.y, build.drawrot());",
		"region": "impact-reactor",
		"x": x_value,
		"y": y_value,
		"rotation": draw_rotation,
	}
	var plasma_light_radius: float = (110.0 + source_math_state.source_absin(time_value, 10.0, 5.0)) * warmup
	var plasma_light_t: float = source_math_state.source_absin(time_value, 14.0, 0.2)
	var plasma_light_call: Dictionary = {
		"call": "Drawf.light(build.x, build.y, (110f + Mathf.absin(5, 5f)) * build.warmup(), Tmp.c1.set(plasma2).lerp(plasma1, Mathf.absin(7f, 0.2f)), 0.8f * build.warmup());",
		"x": x_value,
		"y": y_value,
		"radius": plasma_light_radius,
		"color": {"from": "ff361b", "to": "ffd06b", "t": plasma_light_t},
		"alpha": 0.8 * warmup,
	}
	var light_target: float = 1.0 if liquid_amount >= 0.01 else 0.0
	var light_lerp: float = clampf(0.06 * source_delta, 0.0, 1.0)
	var visual_after: float = visual_liquid + (light_target - visual_liquid) * light_lerp
	var liquid_drawn: bool = liquid_light_alpha > 0.001 and visual_after > 0.01 and liquid_light_alpha * 1.0 > 0.001
	var liquid_light_call: Dictionary = {}
	if liquid_drawn:
		liquid_light_call = {
			"call": "Drawf.light(x, y, block.size * 30f * fract, color, opacity * amount);",
			"x": x_value,
			"y": y_value,
			"radius": float(size_value) * 30.0,
			"color": liquid_light_color,
			"opacity": liquid_light_alpha * visual_after,
			"light_alpha": liquid_light_alpha,
			"visual_liquid": visual_after,
			"fract": 1.0,
		}
	var light_call: Dictionary = {
		"plasma_light": plasma_light_call,
		"liquid_light": liquid_light_call,
		"liquid_drawn": liquid_drawn,
		"visual_liquid_after": visual_after,
		"light_target": light_target,
		"light_lerp": light_lerp,
		"super_expr": "super.drawLight();",
		"drawer_expr": "drawer.drawLight(this);",
	}
	var icon_regions: Array = ["impact-reactor-bottom", "impact-reactor"]
	return {
		"bottom_expr": "Draw.rect(region, build.x + x, build.y + y, build.totalProgress() * rotateSpeed + rotation + (buildingRotate ? build.rotdeg() : 0));",
		"plasma_expr": "Draw.rect(regions[i], build.x + x, build.y + y, r, r, build.totalProgress() * (12 + i * 6f));",
		"base_expr": "Draw.rect(build.block.region, build.x, build.y, build.drawrot());",
		"plasma_light_expr": "Drawf.light(build.x, build.y, (110f + Mathf.absin(5, 5f)) * build.warmup(), Tmp.c1.set(plasma2).lerp(plasma1, Mathf.absin(7f, 0.2f)), 0.8f * build.warmup());",
		"liquid_light_expr": "Drawf.light(x, y, block.size * 30f * fract, color, opacity * amount);",
		"icons_expr": "return drawer.finalIcons(this);",
		"x": x_value,
		"y": y_value,
		"warmup": warmup,
		"total_progress": total_progress,
		"time_value": time_value,
		"plasma_region_sizes": plasma_region_sizes,
		"liquid_amount": liquid_amount,
		"liquid_light_alpha": liquid_light_alpha,
		"liquid_light_color": liquid_light_color,
		"visual_liquid_before": visual_liquid,
		"source_delta": source_delta,
		"size": size_value,
		"draw_rotation": draw_rotation,
		"plasma_light_radius": plasma_light_radius,
		"plasma_light_t": plasma_light_t,
		"light_target": light_target,
		"light_lerp": light_lerp,
		"visual_liquid_after": visual_after,
		"liquid_drawn": liquid_drawn,
		"icon_regions": icon_regions,
		"bottom_call": bottom_call,
		"plasma_call": plasma_call,
		"base_call": base_call,
		"light_call": light_call,
	}

@warning_ignore("unused_parameter")
static func source_impact_reactor_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the impact-reactor tick wiring every
	# tick (ImpactReactorBuild.updateTile(), ImpactReactor.java:79,
	# only warms up while efficiency is ~1 AND power.status is ~1
	# (ImpactReactor.java:79, `if(efficiency >= 0.9999f && power.status >= 0.99f){`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test), so the warmup follows the folded efficiency; no placed-buildings driver ticks ImpactReactor blocks, so this driver is the placed-impact-reactor tick): each placed ImpactReactor build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_impact_reactor_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_impact_reactor_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_impact_reactor_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The frame carries the Building.liquids LiquidModule
		# (frame["liquids"]): the live store lives on the
		# sprite meta (source_building_liquids, initialized
		# at placement), so the driver syncs the reference
		# into the frame each tick BEFORE the fold, and the
		# pure liquid row reads the cryofluid amount from it
		# (the Fracker:327 precedent).
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# The frame-local timer clock (N2266): the driver
		# accumulates source_delta (ticks) into
		# frame["timer_use_elapsed"] EVERY tick, unconditionally
		# -- mirroring Time.time rising every frame (arc
		# Time.java:75, `timeRaw += delta;`), even while the
		# warmup gate is closed, so the timer fires as soon as
		# the gate re-opens. The accumulate runs BEFORE the
		# fold/check below. source_delta and time_scale are
		# computed once here for the fold, the advance inputs
		# and the timer check below.
		var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
		var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
		frame["timer_use_elapsed"] = float(frame.get("timer_use_elapsed", 0.0)) + source_delta
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# an impact reactor with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the warmup gate (ImpactReactor.java:79)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so an impact-reactor does not take the early return. The impact reactor's power draw is STATIC: `consumePower(25f);` (Blocks.java:2642) registers a plain ConsumePower, so the catalog consumePower 25.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. An impact reactor with no power consumer folds no row: the tick also folds the required liquid row (cryofluid 0.25f per frame, Blocks.java:2644, N2254) and the required item row (1 blast-compound, Blocks.java:2643, N2266) when the reactor has a power consumer. The updateTile warmup / production advance (N2192) still runs below when enabled, reading the folded efficiency (1.0 before the first fold) and the stamped power.status (1.0 when missing). ImpactReactorBuild has NO shouldConsume override, so the BuildingComp default applies (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) -- there is NO gate to defer here, the power + liquid + item fold is EXACT, because the only gate is `enabled`, which the driver already checks. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_impact_reactor_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			# The required liquid row folds alongside the power
			# row (ConsumeLiquid.efficiency, ConsumeLiquid.java:42-47):
			# in the first pass efficiency is assumed 1f, so
			# edelta is source_delta * time_scale and the row
			# reads the live cryofluid store synced into the
			# frame above. The single def always has the row
			# (`consumeLiquid(Liquids.cryofluid, 0.25f);`,
			# Blocks.java:2644), so has_liquid_consumer is true.
			var cryofluid_id: int = int(liquid_id_by_name.get(SOURCE_IMPACT_REACTOR_LIQUID, -1))
			var liquid_row: Dictionary = source_impact_reactor_liquid_consumer_row_state(frame, true, cryofluid_id, SOURCE_IMPACT_REACTOR_LIQUID_AMOUNT, source_delta, time_scale, float(frame.get("efficiency_scale", 1.0)))
			if bool(liquid_row.get("has_liquid_row", false)):
				required_results.append(liquid_row.get("row", {}))
			# The required item row folds alongside the power
			# and liquid rows (ConsumeItems.efficiency,
			# ConsumeItems.java:51-53, BINARY 1/0): the single
			# def consumes one blast-compound
			# (`consumeItem(Items.blastCompound);`,
			# Blocks.java:2643), so the stacks are one stack
			# of 1 (the catalog consumeItem, [{amount: 1,
			# item: "blast-compound"}]) and the row reads the
			# frame items store (frame["items"], default {}
			# for a frame bound before this slice -- no live
			# intake fills it yet, the Separator precedent).
			var item_row: Dictionary = source_impact_reactor_item_consumer_row_state(frame, [{"item": SOURCE_IMPACT_REACTOR_ITEM, "amount": SOURCE_IMPACT_REACTOR_ITEM_AMOUNT}])
			if bool(item_row.get("has_item_row", false)):
				required_results.append(item_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# Second pass (BuildingComp.java:1999-2003, `if(update && efficiency > 0){` / `cons.update(self());`): ConsumeLiquid.update removes `build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));` (ConsumeLiquid.java:38), with edelta from the FOLDED efficiency (not the first-pass 1f). Direct removal here, not the AdjacentFactory updates-array precedent (SourceAdjacentFactoryBuildState.gd:382): that pattern passes generated consumer actor objects with an update(self_state) method through update_consumption_state, and this driver is pure static functions with no actor -- so the removal runs after apply_update_consumption_state with the same guard (update && efficiency > 0), through the shared module source_remove_state with a cache_sums array sized to the store (the PayloadLoader precedent; flow is null in the live store, so cache_sums is unused but required by the signature). The multiplier is the 1f default (Consume.java:18); the def sets none.
			if should_consume and valid and float(frame.get("efficiency", 0.0)) > 0.0 and cryofluid_id >= 0:
				var liquids: Dictionary = frame.get("liquids", {})
				if liquids.has("liquids"):
					var folded_edelta: float = float(frame.get("efficiency", 0.0)) * source_delta * time_scale
					var cache_sums: Array = []
					cache_sums.resize(int((liquids.get("liquids", []) as Array).size()))
					cache_sums.fill(0.0)
					source_liquid_module_state.source_remove_state(liquids, cryofluid_id, SOURCE_IMPACT_REACTOR_LIQUID_AMOUNT * folded_edelta, cache_sums)
		# updateTile runs after updateConsumption (BuildingComp.java:2274/:2277) and, in Java, even when disabled (BuildingComp.java:2276, `if(enabled || !block.noUpdateDisabled){`, default false, Block.java:170 -- the OR holds via !noUpdateDisabled; a disabled reactor's efficiency is 0, BuildingComp.java:1954-1957, so its warmup decays): the warmup / totalProgress / productionEfficiency advance (N2192) runs for every enabled impact reactor, whether or not the consumption fold above ran -- a cheating team's reactor still warms up (Java efficiency is 1f under cheating, BuildingComp.java:1945-1947), and the advance reads the folded efficiency (1.0 before the first fold) and the stamped power.status (1.0 when missing). timeScale comes from the sprite meta (the UnitFactory precedent) and Time.delta is seconds * 60 (the N2093 pump precedent). The port gates the advance on enabled ONLY because the driver does not model the disabled early return (BuildingComp.java:1954-1957, `potentialEfficiency = efficiency = optionalEfficiency = 0f;`): the fold above is skipped when disabled, so frame efficiency goes stale and an ungated advance would read it. A disabled reactor's warmup therefore freezes in the port instead of decaying as in Java (documented deviation, see DEFERRED -- fixed by the driver-wide disabled-early-return slice).
		if bool(frame.get("enabled", true)):
			var advance: Dictionary = source_impact_reactor_update_tile_advance_state(frame, source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game)), source_placed_block_state.game_source_delta(game, seconds))
			frame["warmup"] = advance.get("warmup", 0.0)
			frame["total_progress"] = advance.get("total_progress", 0.0)
			frame["production_efficiency"] = advance.get("production_efficiency", 0.0)
			# The consume timer (N2266) runs after the advance
			# (Java order inside updateTile: warmup lerp, then
			# `if(timer(timerUse, itemDuration / timeScale)){`
			# with `consume();`, ImpactReactor.java:91-92):
			# the warmup gate is recomputed from the frame
			# (`if(efficiency >= 0.9999f && power.status >=
			# 0.99f){`, ImpactReactor.java:79 -- power_status
			# defaults to 1.0 when unstamped, like the
			# advance), and when the gate holds AND the timer
			# fires (itemDuration 140f def, Blocks.java:2637,
			# over the sprite-meta timeScale), consume()
			# removes 1 blast-compound -- the ONLY consumer
			# with a trigger override (ConsumeItems.trigger,
			# ConsumeItems.java:44-48; ConsumePower /
			# ConsumeLiquid do not override trigger, so the
			# power / liquid rows lose nothing here) -- through
			# the shared inventory remove (clamped to what the
			# module holds, ItemModule.java:258-263), and the
			# frame-local clock resets to 0.0 (Interval.get
			# RESETS times[id] = Time.time on fire, arc
			# Interval.java:24). The check sits inside the
			# enabled gate like the advance: Java's disabled
			# early return zeroes efficiency
			# (BuildingComp.java:1954-1957), so a disabled
			# reactor never fires its timer, and the port
			# does not model that zeroing yet.
			var gate_efficiency: float = float(frame.get("efficiency", 1.0))
			var gate_stamped: Variant = frame.get("power_status", null)
			var gate_power_status: float = 1.0 if gate_stamped == null else float(gate_stamped)
			if gate_efficiency >= 0.9999 and gate_power_status >= 0.99:
				var timer_use: Dictionary = source_impact_reactor_timer_use_state(float(frame.get("timer_use_elapsed", 0.0)), SOURCE_IMPACT_REACTOR_ITEM_DURATION, time_scale)
				if bool(timer_use.get("fired", false)):
					var items: Dictionary = frame.get("items", {})
					var removed: Dictionary = inventory.remove_item_state(items, SOURCE_IMPACT_REACTOR_ITEM, SOURCE_IMPACT_REACTOR_ITEM_AMOUNT)
					frame["items"] = removed.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, items)
					frame["timer_use_elapsed"] = 0.0
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
