extends RefCounted
class_name SourceAcceleratorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The Accelerator implementation (Accelerator.java:35, `public class Accelerator extends Block{`): interplanetary-accelerator (consumePower 10f, Blocks.java:6829, `consumePower(10f);`; size 7, powerBufferRequirement 1,000,000f, scaledHealth 80, copper 16000 / silicon 11000 / thorium 13000 / titanium 12000 / surge-alloy 6000 / phase-fabric 5000, Blocks.java:6823-6832). Accelerator extends Block, NOT a factory or crafter or bridge or conveyor or router or power generator, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_accelerator_building", the radar precedent), and this slice adds the accelerator key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceAccelerator* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the AcceleratorBuild.updateTile only advances progress by efficiency (Accelerator.java:142-144, `if(efficiency >= 0f){` / `progress += Time.delta * efficiency / buildDuration;` / `progress = Math.min(progress, 1f);`) -- so an accelerator that cannot draw its 10f never reaches progress 1f and canLaunch never passes, as if power.status were 1.0. Battery care: the accelerator is a LAUNCH block -- its canLaunch needs BOTH efficiency AND a full battery (Accelerator.java:239-240, `public boolean canLaunch(){` / `return isValid() && !net.client() && state.isCampaign() && efficiency > 0f && power.graph.getBatteryStored() >= powerBufferRequirement-0.00001f && progress >= 1f && !launching;`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) -- so the row this slice folds is the CONSUMER-side read (`return build.power.status;`, ConsumePower.java:39), exactly like every pure-consumer slice; the BATTERY side (`power.graph.getBatteryStored()`, `power.graph.useBatteries(powerBufferRequirement);`, Accelerator.java:240, 270, and the powerBufferRequirement bar, Accelerator.java:105-109, `if(powerBufferRequirement > 0f){` / `addBar("powerBufferRequirement", b -> new Bar(` / `() -> b.power.graph.getBatteryStored() / powerBufferRequirement`) waits for its own slice. The power-only fold is EXACT for the efficiency side: without it the port would behave as if power.status were 1.0 and the accelerator would charge progress at full speed with no power.
const SOURCE_ACCELERATOR_BUILD_IMPLEMENTATIONS := ["Accelerator"]
const SOURCE_ACCELERATOR_BUILDING_META_KEY := "source_accelerator_building"

static func _is_accelerator_build_implementation(implementation: String) -> bool:
	return SOURCE_ACCELERATOR_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_accelerator_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The accelerator tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (Accelerator.java:35, `public class Accelerator extends Block{`; AcceleratorBuild, Accelerator.java:119, `public class AcceleratorBuild extends Building implements LaunchAnimator{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# accelerator skips consumption like Java's updateConsumption
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
	# for this accelerator (N2125); the tick preserves a disabled
	# accelerator instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_accelerator_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the accelerator frame meta key
	# ("source_accelerator_building"). An Accelerator sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_accelerator_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_ACCELERATOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_ACCELERATOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_ACCELERATOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_accelerator_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so an accelerator does not take the early return. The accelerator's power draw is STATIC, not conditional: `consumePower(10f);` (Blocks.java:6829) registers a plain ConsumePower, so the catalog consumePower 10.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The accelerator's updateTile (Accelerator.java:131-144, `heat = Mathf.lerpDelta(heat, launching ? 1f : efficiency, 0.05f);` / `statusLerp = Mathf.lerpDelta(statusLerp, power.status, 0.05f);` / `time += Time.delta * efficiency;` / `time = Mathf.slerpDelta(time, 0f, 0.4f);` / `launchHeat = Mathf.lerpDelta(launchHeat, launching ? 1f : 0f, 0.1f);` / `if(efficiency >= 0f){` / `progress += Time.delta * efficiency / buildDuration;` / `progress = Math.min(progress, 1f);`) advances progress only by efficiency -- and because there is no baseEfficiency-style floor, the progress never reaches 1f when the gate fails; the folded efficiency is what the efficiency keys prove, and the progress / launch / battery advance waits for its own slice.
	# AcceleratorBuild has NO shouldConsume override, so the BuildingComp default applies (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). There is NO gate to defer here (unlike the ItemBridge / LiquidBridge link gates): the power-only fold is EXACT, because the only gate is `enabled`, which the driver already checks. canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and edelta (BuildingComp.java:1927-1929, `return efficiency * delta();`) are the surrounding gates.
	# The accelerator is its own family (Accelerator.java:35, `public class Accelerator extends Block{`; AcceleratorBuild, Accelerator.java:119, `public class AcceleratorBuild extends Building implements LaunchAnimator{`), a campaign / effect block, NOT related to any factory / turret / defense / bridge / conveyor / router / power-generator family. Class fields: `public Block launchBlock = Blocks.coreNucleus;` (Accelerator.java:40), `public float powerBufferRequirement;` (Accelerator.java:41), `public float launchDuration = 120f;` (Accelerator.java:50), `public float chargeDuration = 220f;` (Accelerator.java:51), `public float buildDuration = 120f;` (Accelerator.java:52); constructor `public Accelerator(String name){` (Accelerator.java:70), `update = true;` (Accelerator.java:72), `solid = true;` (Accelerator.java:73), `hasItems = true;` (Accelerator.java:74), `hasPower = true;` (Accelerator.java:75), `itemCapacity = 8000;` (Accelerator.java:76), `configurable = true;` (Accelerator.java:77), `emitLight = true;` (Accelerator.java:78), `lightRadius = 70f;` (Accelerator.java:79), `lightColor = Pal.accent;` (Accelerator.java:80). init fills the item capacity from the launch block's requirements (Accelerator.java:85, `itemCapacity = 0;` with Accelerator.java:86, `capacities = new int[content.items().size];` and Accelerator.java:91, `consumeItems(launchBlock.requirements);`). The powerBufferRequirement bar (Accelerator.java:105, `if(powerBufferRequirement > 0f){` with Accelerator.java:106, `addBar("powerBufferRequirement", b -> new Bar(`) shows the stored battery over the requirement (Accelerator.java:109, `() -> b.power.graph.getBatteryStored() / powerBufferRequirement`).
	# Build fields: `public float heat, statusLerp;` (Accelerator.java:120), `public float progress;` (Accelerator.java:121), `public float time, launchHeat;` (Accelerator.java:122), `public boolean launching;` (Accelerator.java:123), `public float launchTime;` (Accelerator.java:124). The accessors `public float progress(){` (Accelerator.java:149) with `return progress;` (Accelerator.java:150) expose the progress, `public boolean isCoreBuilt(){` (Accelerator.java:153) with `return progress >= 1f;` (Accelerator.java:154) gates the launch, and `public boolean canLaunch(){` (Accelerator.java:239) with `return isValid() && !net.client() && state.isCampaign() && efficiency > 0f && power.graph.getBatteryStored() >= powerBufferRequirement-0.00001f && progress >= 1f && !launching;` (Accelerator.java:240, keep on ONE comment line, the N2148 shootWarmup lesson) needs efficiency AND a full battery AND progress 1f; the battery half waits for its own slice. The launch itself consumes the stored items and the battery (Accelerator.java:267, `if(power.graph.getBatteryStored() < powerBufferRequirement && !launching){` with Accelerator.java:270, `power.graph.useBatteries(powerBufferRequirement);`, Accelerator.java:271, `progress = 0f;`, and Accelerator.java:289, `Events.fire(Trigger.acceleratorUse);`) -- the launch waits for its own slice. The item gate `public int getMaximumAccepted(Item item){` (Accelerator.java:293) with `return capacities[item.id] + (isCoreBuilt() ? launchBlock.itemCapacity : 0);` (Accelerator.java:294) and `return items.get(item) < getMaximumAccepted(item);` (Accelerator.java:299) rides on the launch, not the tick. The progress persists across saves: `write.f(progress);` (Accelerator.java:305) with `progress = read.f();` (Accelerator.java:311). The launch duration `public float launchDuration(){` (Accelerator.java:317) with `return launchDuration + chargeDuration;` (Accelerator.java:318) is the full launch time.
	# Single def -- interplanetary-accelerator only (size 7, scaledHealth 80, powerBufferRequirement 1,000,000f, copper 16000 / silicon 11000 / thorium 13000 / titanium 12000 / surge-alloy 6000 / phase-fabric 5000, Blocks.java:6823-6832): `interplanetaryAccelerator = new Accelerator("interplanetary-accelerator"){{` (Blocks.java:6823) with `requirements(Category.effect, BuildVisibility.campaignOnly, with(Items.copper, 16000, Items.silicon, 11000, Items.thorium, 13000, Items.titanium, 12000, Items.surgeAlloy, 6000, Items.phaseFabric, 5000));` (Blocks.java:6824), `researchCostMultiplier = 0.1f;` (Blocks.java:6825), `powerBufferRequirement = 1_000_000f;` (Blocks.java:6826), `size = 7;` (Blocks.java:6827), `consumePower(10f);` (Blocks.java:6829), `buildCostMultiplier = 0.5f;` (Blocks.java:6830) and `scaledHealth = 80;` (Blocks.java:6831). No second Accelerator def exists; there is no family split to manage. No sense / read / write overrides exist on AcceleratorBuild beyond the progress save -- those wait for their own slices only if a later Java line needs them.
	# Documented limits: (1) power-only first pass -- the accelerator's static power consumer (consumePower 10f, Blocks.java:6829) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); the accelerator also consumes the core-nucleus requirements (Blocks.java:6824 / Accelerator.java:91), which wait for their own slices. (2) NO shouldConsume gate to defer -- AcceleratorBuild has no shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-756) applies; the power-only fold is EXACT for this family. (3) No updateTile progress / launch / battery advance -- progress advance / canLaunch battery gate / useBatteries / acceleratorUse event (Accelerator.java:131-144, 239-240, 267-289) wait for their own slices; the proof carries no progress / launch / battery keys, the eff fold (Accelerator.java:143) is what the efficiency keys prove. (4) No battery-side modeling -- getBatteryStored / useBatteries / powerBufferRequirement bar (Accelerator.java:105-109, 240, 270) wait for their own slice. (5) Single def -- interplanetary-accelerator only (size 7, scaledHealth 80, powerBufferRequirement 1,000,000f, copper 16000 / silicon 11000 / thorium 13000 / titanium 12000 / surge-alloy 6000 / phase-fabric 5000); per-def stat values wait for their own verification slice. (6) No draw/config modeling -- draw / drawSelect / config wait for their own slices.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_accelerator_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the accelerator tick wiring every
	# tick (AcceleratorBuild.updateTile(), Accelerator.java:131-144,
	# only advances progress by efficiency
	# (Accelerator.java:143, `progress += Time.delta * efficiency / buildDuration;`), so the progress follows the folded efficiency; no placed-buildings driver ticks Accelerator blocks, so this driver is the placed-accelerator tick): each placed Accelerator build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_accelerator_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_accelerator_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_accelerator_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# an accelerator with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the progress advance (Accelerator.java:143)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so an accelerator does not take the early return. The accelerator's power draw is STATIC: `consumePower(10f);` (Blocks.java:6829) registers a plain ConsumePower, so the catalog consumePower 10.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. An accelerator with no power consumer is untouched: the tick models no other consumers yet (the updateTile progress / launch / battery advance waits for its own slice), and AcceleratorBuild has NO shouldConsume override, so the BuildingComp default applies (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) -- there is NO gate to defer here, the power-only fold is EXACT, because the only gate is `enabled`, which the driver already checks. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_accelerator_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
