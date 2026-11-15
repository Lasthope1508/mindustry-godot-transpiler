extends RefCounted
class_name SourceImpactReactorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

# The ImpactReactor implementation (ImpactReactor.java:17, `public class ImpactReactor extends PowerGenerator{`): impact-reactor (consumePower 25f, Blocks.java:2642, `consumePower(25f);`; size 4, powerProduction 130f, itemDuration 140f, health 900, lead 500 / silicon 300 / graphite 400 / thorium 100 / surge-alloy 250 / metaglass 250, Blocks.java:2632-2645). ImpactReactor extends PowerGenerator, NOT a factory or crafter or bridge or conveyor or router, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_impact_reactor_building", the radar precedent), and this slice adds the impact-reactor key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceImpactReactor* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the ImpactReactorBuild.updateTile only warms up while efficiency is ~1 AND power.status is ~1 (ImpactReactor.java:79, `if(efficiency >= 0.9999f && power.status >= 0.99f){`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) -- so a reactor that cannot draw its 25f never warms up and never produces, as if power.status were 1.0. Consume-vs-produce care: the reactor is a GENERATOR -- it both consumes 25f and produces `powerProduction * productionEfficiency` (130f at full warmup) -- so the row this slice folds is the CONSUMER-side read (`return build.power.status;`, ConsumePower.java:39), exactly like every pure-consumer slice; the PRODUCER side (`getPowerProduction()`, PowerGenerator.java:156-158, `return enabled ? powerProduction * productionEfficiency : 0f;`, with `productionEfficiency = Mathf.pow(warmup, 5f);`, ImpactReactor.java:100) waits for its own slice. The warmup gate is a HARD gate, unlike the router's base-efficiency soft coupling: at efficiency 0 the warmup decays to 0 and production is 0 -- there is no baseEfficiency-style floor.
const SOURCE_IMPACT_REACTOR_BUILD_IMPLEMENTATIONS := ["ImpactReactor"]
const SOURCE_IMPACT_REACTOR_BUILDING_META_KEY := "source_impact_reactor_building"
# ImpactReactor warmup speed (ImpactReactor.java:19, `public float warmupSpeed = 0.001f;`): the class default, NOT overridden by the single impact-reactor def (Blocks.java:2632-2645 carries no warmupSpeed line), so the advance lerps toward 1 at 0.001 * timeScale per tick.
const SOURCE_IMPACT_REACTOR_WARMUP_SPEED := 0.001

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
	return {}

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
	# Single def -- impact-reactor only (size 4, health 900, powerProduction 130f, itemDuration 140f, liquidCapacity 80f, lead 500 / silicon 300 / graphite 400 / thorium 100 / surge-alloy 250 / metaglass 250, Blocks.java:2632-2645): `impactReactor = new ImpactReactor("impact-reactor"){{` (Blocks.java:2632) with `requirements(Category.power, with(Items.lead, 500, Items.silicon, 300, Items.graphite, 400, Items.thorium, 100, Items.surgeAlloy, 250, Items.metaglass, 250));` (Blocks.java:2633), `size = 4;` (Blocks.java:2634), `health = 900;` (Blocks.java:2635), `powerProduction = 130f;` (Blocks.java:2636), `itemDuration = 140f;` (Blocks.java:2637), `ambientSound = Sounds.loopPulse;` (Blocks.java:2638), `ambientSoundVolume = 0.08f;` (Blocks.java:2639), `liquidCapacity = 80f;` (Blocks.java:2640), `consumePower(25f);` (Blocks.java:2642), `consumeItem(Items.blastCompound);` (Blocks.java:2643) and `consumeLiquid(Liquids.cryofluid, 0.25f);` (Blocks.java:2644). No second ImpactReactor def exists; there is no family split to manage. No sense / read / write overrides exist on ImpactReactorBuild -- those wait for their own slices only if a later Java line needs them.
	# Documented limits: (1) power-only first pass -- the impact reactor's static power consumer (consumePower 25f, Blocks.java:2642) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); the reactor also consumes blast-compound (Blocks.java:2643) and cryofluid 0.25f (Blocks.java:2644), which wait for their own slices. (2) NO shouldConsume gate to defer -- ImpactReactorBuild has no shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-756) applies; the power-only fold is EXACT for this family. (3) updateTile warmup / production advance DONE (N2192) -- warmup / totalProgress / productionEfficiency advance each tick (ImpactReactor.java:79-100); the consume timer / impact-power event (ImpactReactor.java:87-92) still wait for their own slices. (4) No producer-side fold yet -- productionEfficiency is tracked as a frame key (N2192) but no production fold reads it; getPowerProduction (PowerGenerator.java:156-158) waits for its own slice. (5) Single def -- impact-reactor only (size 4, health 900, powerProduction 130f, itemDuration 140f, liquidCapacity 80f, lead 500 / silicon 300 / graphite 400 / thorium 100 / surge-alloy 250 / metaglass 250); per-def stat values wait for their own verification slice. (6) No draw/config modeling -- draw / drawSelect / config wait for their own slices.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_impact_reactor_update_tile_advance_state(frame: Dictionary, time_scale: float, source_delta: float) -> Dictionary:
	# ImpactReactorBuild.updateTile() (ImpactReactor.java:78-101) advances the warmup AFTER updateConsumption (BuildingComp.update(), BuildingComp.java:2274 `updateConsumption();` then :2277 `updateTile();`, gated on `if(enabled || !block.noUpdateDisabled){`, BuildingComp.java:2276, with the default `public boolean noUpdateDisabled = false;`, Block.java:170 -- ImpactReactor sets no override, so a disabled reactor does not advance): while the gate holds (`if(efficiency >= 0.9999f && power.status >= 0.99f){`, ImpactReactor.java:79, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) the warmup lerps toward 1 (`warmup = Mathf.lerpDelta(warmup, 1f, warmupSpeed * timeScale);`, ImpactReactor.java:82) and snaps (`if(Mathf.equal(warmup, 1f, 0.001f)){`, ImpactReactor.java:83, with `warmup = 1f;`, ImpactReactor.java:84); otherwise it decays (`warmup = Mathf.lerpDelta(warmup, 0f, 0.01f);`, ImpactReactor.java:95). Either way `totalProgress += warmup * Time.delta;` (ImpactReactor.java:98) and `productionEfficiency = Mathf.pow(warmup, 5f);` (ImpactReactor.java:100). Mathf.lerpDelta is `return lerp(fromValue, toValue, clamp(progress * Time.delta));` (Mathf.java:430-431), ported as SourceMathState.source_lerp_delta (lerpf with clampf(source_delta * progress, 0, 1)); Mathf.equal is `return Math.abs(a - b) <= tolerance;` (Mathf.java:554-555), inlined here as absf(warmup - 1.0) <= 0.001 because the port has no Mathf.equal helper; Mathf.pow is `return (float)Math.pow(a, b);` (Mathf.java:212-213), Godot pow(). Time.delta is the frame delta in 60fps ticks (`Math.min(Core.graphics.getDeltaTime() * 60f, 3f)`, arc Time.java:26), so the driver passes seconds * 60 (the N2093 pump precedent). The frame carries the build fields (`public float warmup, totalProgress;`, ImpactReactor.java:75, both 0f by default) plus the folded efficiency (frame["efficiency"], missing only before the first consumption fold -- the cheating / no-consumer early return sets it to 1f when enabled, BuildingComp.java:1945-1947, `if(!block.hasConsumers || cheating()){` with `efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;`, so the missing default is 1.0) and the stamped power.status (frame["power_status"], 1.0 when missing, the assembler fold). timeScale is the sprite-meta timeScale (BuildingComp.java:98, `private transient float timeScale = 1f, timeScaleDuration;`, read as `return timeScale;`, BuildingComp.java:599-600, default 1.0). DEFERRED, not done here: the first-production event (`boolean prevOut = consPower != null && getPowerProduction() <= consPower.requestedPower(this);`, ImpactReactor.java:80, with `if(!prevOut && consPower != null && (getPowerProduction() > consPower.requestedPower(this))){`, ImpactReactor.java:87, and `Events.fire(Trigger.impactPower);`, ImpactReactor.java:88 -- needs getPowerProduction() and consPower.requestedPower(this) from the power graph, which the port does not model yet) and the consume timer (`if(timer(timerUse, itemDuration / timeScale)){`, ImpactReactor.java:91, with `consume();`, ImpactReactor.java:92 -- needs timer + item/liquid consumption infrastructure). productionEfficiency starts at `public float productionEfficiency = 0.0f;` (PowerGenerator.java:96); the producer fold (`return enabled ? powerProduction * productionEfficiency : 0f;`, PowerGenerator.java:156-158) does NOT read this frame key yet -- the key is tracked here and waits for its consumer slice. Readers of the new state: `public float warmup(){` / `return warmup;` (ImpactReactor.java:104-105) and `public float totalProgress(){` / `return totalProgress;` (ImpactReactor.java:109-110). Single def context: `itemDuration = 140f;` (Blocks.java:2637), `powerProduction = 130f;` (Blocks.java:2636), `consumePower(25f);` (Blocks.java:2642).
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
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# an impact reactor with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the warmup gate (ImpactReactor.java:79)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so an impact-reactor does not take the early return. The impact reactor's power draw is STATIC: `consumePower(25f);` (Blocks.java:2642) registers a plain ConsumePower, so the catalog consumePower 25.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. An impact reactor with no power consumer folds no row: the tick models no other consumers yet; the updateTile warmup / production advance (N2192) still runs below when enabled, reading the folded efficiency (1.0 before the first fold) and the stamped power.status (1.0 when missing). ImpactReactorBuild has NO shouldConsume override, so the BuildingComp default applies (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) -- there is NO gate to defer here, the power-only fold is EXACT, because the only gate is `enabled`, which the driver already checks. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
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
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# updateTile runs after updateConsumption (BuildingComp.java:2274/:2277) and only while enabled (BuildingComp.java:2276, `if(enabled || !block.noUpdateDisabled){`, default false, Block.java:170): the warmup / totalProgress / productionEfficiency advance (N2192) runs for every enabled impact reactor, whether or not the consumption fold above ran -- a cheating team's reactor still warms up (Java efficiency is 1f under cheating, BuildingComp.java:1945-1947), and the advance reads the folded efficiency (1.0 before the first fold) and the stamped power.status (1.0 when missing). timeScale comes from the sprite meta (the UnitFactory precedent) and Time.delta is seconds * 60 (the N2093 pump precedent). A disabled reactor does not advance: warmup / totalProgress / productionEfficiency freeze where they are.
		if bool(frame.get("enabled", true)):
			var advance: Dictionary = source_impact_reactor_update_tile_advance_state(frame, source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game)), source_placed_block_state.game_source_delta(game, seconds))
			frame["warmup"] = advance.get("warmup", 0.0)
			frame["total_progress"] = advance.get("total_progress", 0.0)
			frame["production_efficiency"] = advance.get("production_efficiency", 0.0)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
