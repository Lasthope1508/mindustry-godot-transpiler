extends RefCounted
class_name SourceAcceleratorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_drill_inventory_state := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")

# The Accelerator implementation (Accelerator.java:35, `public class Accelerator extends Block{`): interplanetary-accelerator (consumePower 10f, Blocks.java:6829, `consumePower(10f);`; size 7, powerBufferRequirement 1,000,000f, scaledHealth 80, copper 16000 / silicon 11000 / thorium 13000 / titanium 12000 / surge-alloy 6000 / phase-fabric 5000, Blocks.java:6823-6832). Accelerator extends Block, NOT a factory or crafter or bridge or conveyor or router or power generator, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_accelerator_building", the radar precedent), and this slice adds the accelerator key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceAccelerator* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the AcceleratorBuild.updateTile only advances progress by efficiency (Accelerator.java:142-144, `if(efficiency >= 0f){` / `progress += Time.delta * efficiency / buildDuration;` / `progress = Math.min(progress, 1f);`) -- so an accelerator that cannot draw its 10f never reaches progress 1f and canLaunch never passes, as if power.status were 1.0. Battery care: the accelerator is a LAUNCH block -- its canLaunch needs BOTH efficiency AND a full battery (Accelerator.java:239-240, `public boolean canLaunch(){` / `return isValid() && !net.client() && state.isCampaign() && efficiency > 0f && power.graph.getBatteryStored() >= powerBufferRequirement-0.00001f && progress >= 1f && !launching;`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) -- so the row this slice folds is the CONSUMER-side read (`return build.power.status;`, ConsumePower.java:39), exactly like every pure-consumer slice; the BATTERY side (`power.graph.getBatteryStored()`, `power.graph.useBatteries(powerBufferRequirement);`, Accelerator.java:240, 270, and the powerBufferRequirement bar, Accelerator.java:105-109, `if(powerBufferRequirement > 0f){` / `addBar("powerBufferRequirement", b -> new Bar(` / `() -> b.power.graph.getBatteryStored() / powerBufferRequirement`) waits for its own slice. The power-only fold is EXACT for the efficiency side: without it the port would behave as if power.status were 1.0 and the accelerator would charge progress at full speed with no power.
const SOURCE_ACCELERATOR_BUILD_IMPLEMENTATIONS := ["Accelerator"]
const SOURCE_ACCELERATOR_BUILDING_META_KEY := "source_accelerator_building"
# buildDuration is the class field (Accelerator.java:52, `public float buildDuration = 120f;`), not overridden by the interplanetary-accelerator def (Blocks.java:6823-6832).
const SOURCE_ACCELERATOR_BUILD_DURATION := 120.0
# powerBufferRequirement is the class field (Accelerator.java:41, `public float powerBufferRequirement;`), set by the single def to 1,000,000f (Blocks.java:6826, `powerBufferRequirement = 1_000_000f;`); the canLaunch gate (Accelerator.java:239-240) and the launch drain (Accelerator.java:270) both read it.
const SOURCE_ACCELERATOR_POWER_BUFFER_REQUIREMENT := 1000000.0
# lerpDelta/slerpDelta progress values from AcceleratorBuild.updateTile (Accelerator.java:131-140).
const SOURCE_ACCELERATOR_HEAT_LERP_PROGRESS := 0.05
const SOURCE_ACCELERATOR_STATUS_LERP_PROGRESS := 0.05
const SOURCE_ACCELERATOR_TIME_SLERP_PROGRESS := 0.4
const SOURCE_ACCELERATOR_LAUNCH_HEAT_LERP_PROGRESS := 0.1
# Draw constants (N2373): the def size (Blocks.java:6827, `size = 7;`), the launch-block size (core-nucleus, Blocks.java:3159, `size = 5;`), the tile size (Vars.java:135, `public static final int tilesize = 8;`) and the light radius (Accelerator.java:79, `lightRadius = 70f;`, with `lightColor = Pal.accent;`, Accelerator.java:80). No def override for any of them.
const SOURCE_ACCELERATOR_SIZE := 7
const SOURCE_ACCELERATOR_LAUNCH_BLOCK_SIZE := 5
const SOURCE_ACCELERATOR_TILESIZE := 8.0
const SOURCE_ACCELERATOR_LIGHT_RADIUS := 70.0

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
	return {"items": {}}

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
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so an accelerator does not take the early return. The accelerator's power draw is STATIC, not conditional: `consumePower(10f);` (Blocks.java:6829) registers a plain ConsumePower, so the catalog consumePower 10.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The accelerator's updateTile (Accelerator.java:131-144, `heat = Mathf.lerpDelta(heat, launching ? 1f : efficiency, 0.05f);` / `statusLerp = Mathf.lerpDelta(statusLerp, power.status, 0.05f);` / `time += Time.delta * efficiency;` / `time = Mathf.slerpDelta(time, 0f, 0.4f);` / `launchHeat = Mathf.lerpDelta(launchHeat, launching ? 1f : 0f, 0.1f);` / `if(efficiency >= 0f){` / `progress += Time.delta * efficiency / buildDuration;` / `progress = Math.min(progress, 1f);`) advances progress only by efficiency -- and because there is no baseEfficiency-style floor, the progress never reaches 1f when the gate fails; the folded efficiency is what the efficiency keys prove, and the progress advance is the updateTile slice (N2191) while the launch / battery advance waits for its own slice.
	# AcceleratorBuild has NO shouldConsume override, so the BuildingComp default applies (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). There is NO gate to defer here (unlike the ItemBridge / LiquidBridge link gates): the power-only fold is EXACT, because the only gate is `enabled`, which the driver already checks. canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and edelta (BuildingComp.java:1927-1929, `return efficiency * delta();`) are the surrounding gates.
	# The accelerator is its own family (Accelerator.java:35, `public class Accelerator extends Block{`; AcceleratorBuild, Accelerator.java:119, `public class AcceleratorBuild extends Building implements LaunchAnimator{`), a campaign / effect block, NOT related to any factory / turret / defense / bridge / conveyor / router / power-generator family. Class fields: `public Block launchBlock = Blocks.coreNucleus;` (Accelerator.java:40), `public float powerBufferRequirement;` (Accelerator.java:41), `public float launchDuration = 120f;` (Accelerator.java:50), `public float chargeDuration = 220f;` (Accelerator.java:51), `public float buildDuration = 120f;` (Accelerator.java:52); constructor `public Accelerator(String name){` (Accelerator.java:70), `update = true;` (Accelerator.java:72), `solid = true;` (Accelerator.java:73), `hasItems = true;` (Accelerator.java:74), `hasPower = true;` (Accelerator.java:75), `itemCapacity = 8000;` (Accelerator.java:76), `configurable = true;` (Accelerator.java:77), `emitLight = true;` (Accelerator.java:78), `lightRadius = 70f;` (Accelerator.java:79), `lightColor = Pal.accent;` (Accelerator.java:80). init fills the item capacity from the launch block's requirements (Accelerator.java:85, `itemCapacity = 0;` with Accelerator.java:86, `capacities = new int[content.items().size];` and Accelerator.java:91, `consumeItems(launchBlock.requirements);`). The powerBufferRequirement bar (Accelerator.java:105, `if(powerBufferRequirement > 0f){` with Accelerator.java:106, `addBar("powerBufferRequirement", b -> new Bar(`) shows the stored battery over the requirement (Accelerator.java:109, `() -> b.power.graph.getBatteryStored() / powerBufferRequirement`).
	# Build fields: `public float heat, statusLerp;` (Accelerator.java:120), `public float progress;` (Accelerator.java:121), `public float time, launchHeat;` (Accelerator.java:122), `public boolean launching;` (Accelerator.java:123), `public float launchTime;` (Accelerator.java:124). The accessors `public float progress(){` (Accelerator.java:149) with `return progress;` (Accelerator.java:150) expose the progress, `public boolean isCoreBuilt(){` (Accelerator.java:153) with `return progress >= 1f;` (Accelerator.java:154) gates the launch, and `public boolean canLaunch(){` (Accelerator.java:239) with `return isValid() && !net.client() && state.isCampaign() && efficiency > 0f && power.graph.getBatteryStored() >= powerBufferRequirement-0.00001f && progress >= 1f && !launching;` (Accelerator.java:240, keep on ONE comment line, the N2148 shootWarmup lesson) needs efficiency AND a full battery AND progress 1f; the battery half waits for its own slice. The launch itself consumes the stored items and the battery (Accelerator.java:252, `if(power.graph.getBatteryStored() < powerBufferRequirement && !launching){` is the drawSelect battery warning, not the launch; the launch is Accelerator.java:270, `power.graph.useBatteries(powerBufferRequirement);`, Accelerator.java:271, `progress = 0f;`, and Accelerator.java:289, `Events.fire(Trigger.acceleratorUse);`) -- the canLaunch gate and the launch transition are live since N2271; the renderer / Time.runTask / event half still waits for its own slice. The item gate `public int getMaximumAccepted(Item item){` (Accelerator.java:293) with `return capacities[item.id] + (isCoreBuilt() ? launchBlock.itemCapacity : 0);` (Accelerator.java:294) and `return items.get(item) < getMaximumAccepted(item);` (Accelerator.java:299) rides on the launch, not the tick. The progress persists across saves: `write.f(progress);` (Accelerator.java:310) with `progress = read.f();` (Accelerator.java:318, verified N2485 -- the old comment :305/:311 was wrong). The launch duration `public float launchDuration(){` (Accelerator.java:324) with `return launchDuration + chargeDuration;` (Accelerator.java:325, verified N2485 -- the old comment :317/:318 was wrong) is the full launch time.
	# Single def -- interplanetary-accelerator only (size 7, scaledHealth 80, powerBufferRequirement 1,000,000f, copper 16000 / silicon 11000 / thorium 13000 / titanium 12000 / surge-alloy 6000 / phase-fabric 5000, Blocks.java:6823-6832): `interplanetaryAccelerator = new Accelerator("interplanetary-accelerator"){{` (Blocks.java:6823) with `requirements(Category.effect, BuildVisibility.campaignOnly, with(Items.copper, 16000, Items.silicon, 11000, Items.thorium, 13000, Items.titanium, 12000, Items.surgeAlloy, 6000, Items.phaseFabric, 5000));` (Blocks.java:6824), `researchCostMultiplier = 0.1f;` (Blocks.java:6825), `powerBufferRequirement = 1_000_000f;` (Blocks.java:6826), `size = 7;` (Blocks.java:6827), `consumePower(10f);` (Blocks.java:6829), `buildCostMultiplier = 0.5f;` (Blocks.java:6830) and `scaledHealth = 80;` (Blocks.java:6831). No second Accelerator def exists; there is no family split to manage. No sense / read / write overrides exist on AcceleratorBuild beyond the progress save -- those wait for their own slices only if a later Java line needs them.
	# Documented limits: (1) power + item first pass -- the accelerator's static power consumer (consumePower 10f, Blocks.java:6829) and the launch-block item consumer rows (core-nucleus requirements copper 8000 / lead 8000 / silicon 5000 / thorium 4000, Blocks.java:3154, registered by `consumeItems(launchBlock.requirements);`, Accelerator.java:91) are live since N2267, with the init() capacities (copper 8000 / lead 8000 / silicon 5000 / thorium 4000, itemCapacity 25000, Accelerator.java:85-90) and the getMaximumAccepted / acceptItem accessors (Accelerator.java:293-299, core bonus 13000 from the core-nucleus itemCapacity, Blocks.java:3158); the folded efficiency is the min over the *modeled* consumers (power + items). No live intake fills frame["items"] yet (the Separator precedent) -- the row reads the frame as-is, so a live accelerator with no intake folds efficiency 0; the launch consume() (Accelerator.java:258-290) and the battery gate (Accelerator.java:239-240, 270) are live since N2271 (canLaunch gate + launch transition, driven by the one-shot frame key launch_requested; battery_stored is a frame input with no live fill yet -- see (4)). (2) NO shouldConsume gate to defer -- AcceleratorBuild has no shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-756) applies; the power + item fold is EXACT for this family. (3) updateTile advance is DONE (N2191: heat/statusLerp/time/launchHeat/progress, Accelerator.java:127-146) -- the launch / battery advance is PARTLY DONE (N2271: canLaunch battery gate + useBatteries total drain + consume() item removal + progress reset, Accelerator.java:239-240, 261-271); still waiting: the acceleratorUse event (Accelerator.java:289), the renderer.showLaunch / Time.runTask launch (Accelerator.java:273-286), the launching flag transitions (beginLaunch / endLaunch, Accelerator.java:334-337, 392-394) and the launchTime / cloudSeed state (Accelerator.java:124, 126); the proof carries launch / battery keys since N2271, and the launching branch of the advance is proven pure only, because nothing in the port sets the flag yet. (4) Battery-side modeling is PARTLY live (N2271): the canLaunch gate reads frame["battery_stored"] (getBatteryStored, PowerGraph.java:118-127, the enabled-battery total) and the launch drains the total by the requirement (useBatteries, PowerGraph.java:154-167); the graph stamp is live since N2342 (the distribute step stamps frame battery_stored from the updated batteries); the per-battery proportional status scaling (PowerGraph.java:160-165) is live since N2354 (one-shot launch_drain_request + runtime apply through the existing use_batteries_state, 1-tick delay -- the graph update runs before the driver ticks); the powerBufferRequirement bar rows are live since N2422 (the pure source_accelerator_power_buffer_bar_state, Accelerator.java:105-109). (5) Single def -- interplanetary-accelerator only (size 7, scaledHealth 80, powerBufferRequirement 1,000,000f, copper 16000 / silicon 11000 / thorium 13000 / titanium 12000 / surge-alloy 6000 / phase-fabric 5000); Per-def stat rows live (N2498) -- source_accelerator_per_def_stats_state returns the def rows with the class defaults (size 1, scaledHealth -1, powerBufferRequirement 0f, no requirements) for an unknown def id. (6) Draw rows live (N2373) -- the draw pure (source_accelerator_draw_state) models draw() (:157-233): super.draw + the statusLerp arrows (4 layers x 4 arrows, absin pulse) + the shadow (launchBlock.size * tilesize * 2f = 80) + blockbuild shader draw + the heat-gated charge rings (3 Lines.square rings + team-color arrows); the draw-light pure (source_accelerator_draw_light_state) models drawLight() (:235-237, lightRadius 70f, lightColor Pal.accent, opacity launchHeat); the draw-select pure (source_accelerator_draw_select_state) models drawSelect() (:249-256, battery warning when stored < requirement && !launching). Pure-only: draw never runs in the tick. Still deferred: the launching branch of draw() (:180-194, launchTime untracked), drawLaunch / drawLaunchGlobalZ / drawLanding (launch sequence rendering), and config (the buildConfiguration dialog / sector select waits for its own slice). getCursor rows live (N2452) -- the get-cursor pure (source_accelerator_get_cursor_state) models getCursor() (:243-245): canLaunch ? hand : super.getCursor(), with the environment half (isValid / !net.client / state.isCampaign) composed over the caller-supplied N2271 gate output and the super branch (block.configurable && interactable(player.team()), BuildingComp.java:1683-1684; configurable = true, Accelerator.java:77). Pure-only: getCursor never runs in the tick. (7) Disabled-efficiency staleness -- updateConsumption forces efficiency to 0 when !shouldConsume (BuildingComp.java:1992), but the driver skips the consumption fold when disabled, so frame["efficiency"] keeps its last folded value and the updateTile advance reads it stale; the driver zeroing waits for its own slice. (8) Bar rows live (N2422) -- the powerBufferRequirement bar pure (source_accelerator_power_buffer_bar_state) models setBars() (Accelerator.java:105-109): the bar exists only when the requirement > 0f, the label key is bar.powerbuffer with the raw stored + requirement amounts (the UI.formatAmount rendering is a UI concern, UI.java:781-800), the color is Pal.powerBar, and the fraction is the raw stored / requirement ratio (the Bar clamps it at render, Bar.java). Pure-only: the bar never runs in the tick. (9) Progress / isCoreBuilt rows live (N2485) -- the pure-only accessor source_accelerator_progress_is_core_built_state ports progress() (Accelerator.java:149-150) + isCoreBuilt() (Accelerator.java:153-154, exact >= 1f boundary); the write/read serialization (Accelerator.java:310/:318) still waits for its own slice.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func _accelerator_item_stacks_for_block(block_id: String) -> Array:
	# The launch-block requirement stacks (the Separator
	# per-def helper precedent): the single Accelerator def
	# (interplanetary-accelerator) consumes the core-nucleus
	# requirements -- copper 8000, lead 8000, silicon 5000,
	# thorium 4000:
	# `requirements(Category.effect, with(Items.copper, 8000, Items.lead, 8000, Items.silicon, 5000, Items.thorium, 4000));`
	# (Blocks.java:3154) -- registered as one ConsumeItems by
	# `consumeItems(launchBlock.requirements);`
	# (Accelerator.java:91), where
	# `public Block launchBlock = Blocks.coreNucleus;`
	# (Accelerator.java:40) and the def does NOT override it
	# (Blocks.java:6823-6832). Item ids are kebab-case per the
	# catalog ("copper", "lead", "silicon", "thorium"). An
	# unknown block id has no item row.
	if block_id == "interplanetary-accelerator":
		return [{"item": "copper", "amount": 8000}, {"item": "lead", "amount": 8000}, {"item": "silicon", "amount": 5000}, {"item": "thorium", "amount": 4000}]
	return []

static func source_accelerator_item_consumer_row_state(frame: Dictionary, stacks: Array) -> Dictionary:
	# ConsumeItems.efficiency (ConsumeItems.java:51-53, each
	# exact expr on ONE comment line, the N2148 lesson):
	# `return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;`
	# The result is BINARY 1.0/0.0 -- not a ratio like
	# ConsumeLiquid. The trigger-valid half is the base false
	# (`public boolean consumeTriggerValid(){`, BuildingComp.java:764-766,
	# `return false;`; AcceleratorBuild does NOT override it,
	# grep-verified), so the row is 1.0 exactly when every
	# stack is held:
	# `if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;`
	# (ItemModule.java:153-157), with `return get(item) >= amount;`
	# (ItemModule.java:126-128). The multiplier is the Consume
	# default 1f (`public Floatf<Building> multiplier = b -> 1f;`,
	# Consume.java:18) -- the init-registered consumer sets
	# none -- so the required count is round(amount * 1f) =
	# amount. consumeItems registers the launch-block
	# requirements as one ConsumeItems
	# (`public ConsumeItems consumeItems(ItemStack... items){` /
	# `return consume(new ConsumeItems(items));`, Block.java:1175-1176).
	# The counts read through the shared drill inventory helper
	# (SourceDrillInventoryRuntimeState.item_count, the
	# Separator precedent) over frame["items"], not a
	# recomputation; a frame without an items store reads 0,
	# like Java items.get for an item never added. The row is
	# REQUIRED (not .boost(), not optional): it folds into the
	# first pass:
	# `for(var cons : block.nonOptionalConsumers){`
	# `minEfficiency = Math.min(minEfficiency, result);`
	# (BuildingComp.java:1969-1976), so a starved row zeroes
	# efficiency (`efficiency = minEfficiency;`,
	# BuildingComp.java:1985; `efficiency = optionalEfficiency = 0f;`,
	# BuildingComp.java:1992) and the progress advance follows
	# it (`progress += Time.delta * efficiency / buildDuration;`,
	# Accelerator.java:143). NO removal in this slice:
	# consume() only happens at launch (Accelerator.java:258-291)
	# -- the trigger
	# `build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));`
	# (ConsumeItems.java:44-48) waits for the launch slice.
	# A block with no item consumer (empty stacks) contributes
	# no row. The catalog carries NO consumeItem for
	# interplanetary-accelerator (registered in init, the
	# extractor skips it), so the stacks come from the Java
	# source, not the catalog.
	if stacks.is_empty():
		return {"has_item_row": false, "row": {}}
	var items: Dictionary = frame.get("items", {})
	var has_all := true
	for stack in stacks:
		var entry: Dictionary = stack if stack is Dictionary else {}
		var item_id: String = str(entry.get("item", ""))
		var amount: int = int(entry.get("amount", 0))
		if source_drill_inventory_state.item_count(items, item_id) < amount:
			has_all = false
			break
	var result: float = 1.0 if has_all else 0.0
	return {"has_item_row": true, "row": {"result": result, "is_power": false}}

static func source_accelerator_capacities_state() -> Dictionary:
	# init() (Accelerator.java:84-92) fills the per-item
	# capacities and the item capacity from the launch-block
	# requirements (each exact expr on ONE comment line, the
	# N2148 lesson):
	# `itemCapacity = 0;`
	# `capacities = new int[content.items().size];`
	# `for(ItemStack stack : launchBlock.requirements){`
	# `capacities[stack.item.id] = stack.amount;`
	# `itemCapacity += stack.amount;`
	# `consumeItems(launchBlock.requirements);`
	# The class default `itemCapacity = 8000;`
	# (Accelerator.java:76) is zeroed first, so the summed
	# capacity is 8000 + 8000 + 5000 + 4000 = 25000 -- NOT the
	# catalog's itemCapacity 10, which is the stale Block
	# default (the catalog never runs init()). The launch
	# block is `public Block launchBlock = Blocks.coreNucleus;`
	# (Accelerator.java:40); its requirements are copper 8000,
	# lead 8000, silicon 5000, thorium 4000 (Blocks.java:3154).
	# An item with no requirement reads capacity 0, like the
	# fresh int array in Java.
	var capacities: Dictionary = {"copper": 8000, "lead": 8000, "silicon": 5000, "thorium": 4000}
	var item_capacity: int = 0
	for amount in capacities.values():
		item_capacity += int(amount)
	return {"capacities": capacities, "item_capacity": item_capacity}

static func source_accelerator_get_maximum_accepted_state(item: String, is_core_built: bool) -> Dictionary:
	# `public int getMaximumAccepted(Item item){`
	# `return capacities[item.id] + (isCoreBuilt() ? launchBlock.itemCapacity : 0);`
	# (Accelerator.java:293-295, each exact expr on ONE comment
	# line, the N2148 lesson). The core bonus is the launch
	# block's itemCapacity -- core-nucleus
	# `itemCapacity = 13000;` (Blocks.java:3158) -- and it
	# applies only once the core is built
	# (`public boolean isCoreBuilt(){` / `return progress >= 1f;`,
	# Accelerator.java:153-154). An item with no requirement
	# reads capacity 0, like the fresh int array in Java, so
	# its maximum is the core bonus alone when built, 0 when
	# not. The progress itself is the N2191 advance; this
	# accessor takes is_core_built as an input because the
	# frame's progress lives on the tick, not in this pure
	# function.
	var capacities: Dictionary = source_accelerator_capacities_state().get("capacities", {})
	var capacity: int = int(capacities.get(item, 0))
	var core_bonus: int = 13000 if is_core_built else 0
	return {"maximum_accepted": capacity + core_bonus, "capacity": capacity, "core_bonus": core_bonus}

static func source_accelerator_accept_item_state(item: String, held: int, is_core_built: bool) -> Dictionary:
	# `public boolean acceptItem(Building source, Item item){`
	# `return items.get(item) < getMaximumAccepted(item);`
	# (Accelerator.java:297-299, each exact expr on ONE comment
	# line, the N2148 lesson). Strictly less-than: held ==
	# maximum rejects. The maximum comes from the
	# getMaximumAccepted accessor above (Accelerator.java:
	# 293-295), so the core bonus (13000, Blocks.java:3158)
	# applies exactly when is_core_built. This accessor is
	# pure -- no live intake calls it yet (the intake slice
	# wires it); the row fold is what the tick uses today.
	var maximum_accepted: int = int(source_accelerator_get_maximum_accepted_state(item, is_core_built).get("maximum_accepted", 0))
	return {"accept": held < maximum_accepted, "held": held, "maximum_accepted": maximum_accepted}

static func source_accelerator_progress_is_core_built_state(progress: float) -> Dictionary:
	# The progress / isCoreBuilt rows (N2485), the pure-only
	# accessor -- the launch/UI path reads it; no tick wiring
	# (the N2479 Radar precedent). progress() returns the
	# build field as-is and isCoreBuilt() gates on the exact
	# >= 1f boundary (progress exactly 1f IS core-built),
	# each exact expr on ONE comment line (the N2148 lesson):
	# `public float progress(){`
	# `return progress;`
	# `public boolean isCoreBuilt(){`
	# `return progress >= 1f;`
	# (Accelerator.java:149-150 / :153-154). The field is
	# `public float progress;` (Accelerator.java:121),
	# tracked on the frame under the same key name
	# (progress) since the N2191 advance, which advances
	# it (`progress += Time.delta * efficiency / buildDuration;`,
	# Accelerator.java:143) and clamps it (`progress = Math.min(progress, 1f);`,
	# Accelerator.java:144). The clamp lives in updateTile,
	# NOT in progress() -- so this pure does NOT clamp: it
	# returns its input as-is, and a progress above 1f
	# still reports is_core_built true. Until this slice,
	# is_core_built was only an INPUT of
	# source_accelerator_get_maximum_accepted_state and
	# source_accelerator_accept_item_state above -- no pure
	# COMPUTED it; the caller now feeds this pure's output
	# into those accessors. The write/read serialization
	# (`write.f(progress);`, Accelerator.java:310, and
	# `progress = read.f();`, Accelerator.java:318) is NOT
	# this slice -- it waits for its own slice (the entry
	# lines :310/:318 are right; the old driver comment
	# :305/:311 was wrong, fixed in this slice).
	var is_core_built: bool = progress >= 1.0
	return {"progress": progress, "is_core_built": is_core_built}

static func source_accelerator_can_launch_state(efficiency: float, battery_stored: float, progress: float, launching: bool, power_buffer_requirement: float) -> Dictionary:
	# canLaunch (Accelerator.java:239-240, each exact expr
	# on ONE comment line, the N2148 lesson):
	# `public boolean canLaunch(){`
	# `return isValid() && !net.client() && state.isCampaign() && efficiency > 0f && power.graph.getBatteryStored() >= powerBufferRequirement-0.00001f && progress >= 1f && !launching;`
	# The gate is a conjunction of an environment half and a
	# tick-state half. The environment half (isValid() /
	# !net.client() / state.isCampaign()) is NOT modeled by
	# THIS pure: the port has no net / campaign state, so
	# this pure function evaluates the four tick-state
	# conditions only and the docstring says so -- a caller
	# that needs the environment half composes it itself
	# (N2452's source_accelerator_get_cursor_state does
	# exactly that, taking this pure's can_launch output as
	# its caller-supplied gate_can_launch). The tick-state
	# conditions: efficiency > 0f (the folded efficiency,
	# BuildingComp.java:1985); battery_stored >= requirement
	# - 0.00001f, where battery_stored is getBatteryStored()
	# (PowerGraph.java:118-127):
	# `public float getBatteryStored(){`
	# `totalAccumulator += battery.power.status * battery.block.consPower.capacity;`
	# the enabled-battery total of power.status *
	# consPower.capacity, and the requirement is the
	# single-def 1,000,000f:
	# `public float powerBufferRequirement;`
	# `powerBufferRequirement = 1_000_000f;`
	# (Accelerator.java:41, Blocks.java:6826); progress >= 1f
	# is isCoreBuilt():
	# `public boolean isCoreBuilt(){`
	# `return progress >= 1f;`
	# (Accelerator.java:153-154); and !launching, where
	# `public boolean launching;` (Accelerator.java:123) is
	# set true only by beginLaunch (Accelerator.java:334-337)
	# and false only by endLaunch (Accelerator.java:392-394)
	# and the launch Time.runTask (Accelerator.java:277).
	# Precision note: Java evaluates the battery comparison
	# in float32, where 1_000_000f - 0.00001f rounds to
	# 1_000_000f (the float32 ulp at 1e6 is 0.0625); the port
	# evaluates it in GDScript float64, so the written
	# 0.00001 epsilon is exact here -- stored =
	# requirement - 0.00001 passes, requirement - 0.00002
	# fails. The difference is 1e-5 on a 1e6 scale and the
	# port keeps the written epsilon. The battery_stored
	# argument is a frame INPUT: the graph summary computes
	# it (SourcePlacedPowerGraphState.gd:303) but does NOT
	# stamp it on the building frame, so a live accelerator
	# reads the input as-is (default 0.0) until the
	# graph-stamp slice wires it.
	var efficiency_ok: bool = efficiency > 0.0
	var battery_ok: bool = battery_stored >= power_buffer_requirement - 0.00001
	var progress_ok: bool = progress >= 1.0
	var not_launching: bool = not launching
	var can_launch: bool = efficiency_ok and battery_ok and progress_ok and not_launching
	return {"can_launch": can_launch, "efficiency_ok": efficiency_ok, "battery_ok": battery_ok, "progress_ok": progress_ok, "not_launching": not_launching}

static func source_accelerator_launch_state(items: Dictionary, battery_stored: float, power_buffer_requirement: float, requirement_stacks: Array) -> Dictionary:
	# The launch transition (N2271): buildConfiguration
	# (Accelerator.java:258-290) opens the planet-launch
	# dialog only `if(!canLaunch()) return;`
	# (Accelerator.java:261), and on sector select it
	# re-checks the gate (each exact expr on ONE comment
	# line, the N2148 lesson):
	# `public void buildConfiguration(Table table){`
	# `if(canLaunch()){`
	# `consume();`
	# `ItemSeq resources = new ItemSeq();`
	# `resources.add(items);`
	# `items.clear();`
	# `power.graph.useBatteries(powerBufferRequirement);`
	# `progress = 0f;`
	# (Accelerator.java:258, 264-271). consume() triggers
	# every consumer (BuildingComp.java:1911-1915):
	# `public void consume(){`
	# `for(Consume cons : block.consumers){`
	# `cons.trigger(self());`
	# and the ConsumeItems trigger removes each requirement
	# stack (ConsumeItems.java:44-48):
	# `build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));`
	# with the multiplier the Consume default 1f, so the
	# removed count is the stack amount, clamped by
	# ItemModule.remove (ItemModule.java:258-263):
	# `amount = Math.min(amount, items[item.id]);`
	# `items[item.id] -= amount;`
	# The requirements are the core-nucleus stacks
	# (copper 8000 / lead 8000 / silicon 5000 / thorium 4000):
	# `requirements(Category.effect, with(Items.copper, 8000, Items.lead, 8000, Items.silicon, 5000, Items.thorium, 4000));`
	# (Blocks.java:3154), registered by
	# `consumeItems(launchBlock.requirements);`
	# (Accelerator.java:91) -- the caller passes them in as
	# requirement_stacks (the N2267 helper
	# _accelerator_item_stacks_for_block). resources is the
	# remainder AFTER the removal: every held item minus its
	# requirement amount, clamped at 0 per stack -- and it
	# carries only NONZERO remainders, because
	# `resources.add(items);` iterates via ItemModule.each,
	# which visits only nonzero counts (ItemModule.java:
	# 100-106):
	# `if(items[i] != 0){`
	# `itemModule.each(this::add);`
	# (ItemSeq.java:104-106), so a fully-consumed stack
	# leaves no entry at all; an item with no requirement
	# keeps its full count. items is then emptied
	# (`items.clear();`). The battery drain is
	# useBatteries (PowerGraph.java:154-167):
	# `public float useBatteries(float needed){`
	# `float stored = getBatteryStored();`
	# `if(Mathf.equal(stored, 0f)) return 0f;`
	# `float used = Math.min(stored, needed);`
	# `float consumedPowerPercentage = Math.min(1.0f, needed / stored);`
	# `battery.power.status *= (1f-consumedPowerPercentage);`
	# `return used;`
	# The port drains the TOTAL only: new stored = stored -
	# min(stored, requirement), clamped at 0 (the clamp
	# guards the epsilon residue when the gate passed at
	# stored = requirement - 0.00001). The per-battery
	# proportional status scaling is live since N2354: the
	# driver writes a one-shot launch_drain_request on a
	# successful launch and the runtime applies the existing
	# use_batteries_state to the post-update batteries
	# (1-tick delay -- the graph update runs before the
	# driver ticks). The remainder of
	# buildConfiguration is DEFERRED, not modeled here:
	# `renderer.showLaunch(this);` (Accelerator.java:273)
	# and the Time.runTask launch
	# `Time.runTask(launchDuration() - 6f, () -> {`
	# (Accelerator.java:275-286, which sets
	# `launching = false;` at :277 and hands the resources to
	# `universe.updateLaunchResources(resources);` at :281)
	# and `Events.fire(Trigger.acceleratorUse);`
	# (Accelerator.java:289). The caller DISCARDS the
	# resources: universe.updateLaunchResources has no port
	# equivalent. The launching flag is NOT touched here:
	# beginLaunch sets it true
	# `public void beginLaunch(boolean launching){`
	# `this.launching = true;`
	# (Accelerator.java:334-337), called by the LaunchAnimator
	# via renderer.showLaunch -- NOT by buildConfiguration --
	# so the flag transitions wait for the launch-sequence
	# slice. The input items dict is NOT mutated: the
	# resources are built on a duplicate.
	var resources: Dictionary = items.duplicate()
	for stack in requirement_stacks:
		var entry: Dictionary = stack if stack is Dictionary else {}
		var item_id: String = str(entry.get("item", ""))
		var amount: int = int(entry.get("amount", 0))
		var held: int = int(resources.get(item_id, 0))
		var remainder: int = maxi(0, held - amount)
		if remainder > 0:
			resources[item_id] = remainder
		else:
			resources.erase(item_id)
	var battery_after: float = maxf(0.0, battery_stored - minf(battery_stored, power_buffer_requirement))
	return {"items": {}, "resources": resources, "battery_stored": battery_after, "progress": 0.0}

static func source_mathf_slerp_delta(from_degrees: float, to_degrees: float, progress: float, source_delta: float) -> float:
	# Mathf.slerpDelta (Mathf.java:460-462, `public static float slerpDelta(float fromDegrees, float toDegrees, float progress){` with `return slerp(fromDegrees, toDegrees, clamp(progress * Time.delta));`): slerp is the angle lerp in degrees (Mathf.java:455-458, `public static float slerp(float fromDegrees, float toDegrees, float progress){` with `float delta = ((toDegrees - fromDegrees + 360 + 180) % 360) - 180;` and `return (fromDegrees + delta * progress + 360) % 360;`), so the wrapped delta picks the shortest way round the circle; clamp is [0, 1] (Mathf.java:402-404, `public static float clamp(float value){` with `return Math.max(Math.min(value, 1f), 0f);`). The port has no slerp helper, so the advance carries this local transliteration; GDScript fmod matches Java % (sign of the dividend), so the wrap is exact. Time.delta in the port is seconds * 60 via game_source_delta (arc Time.java:26, the N2093/N2189 precedent); the driver converts before calling this helper.
	var clamped: float = clampf(progress * source_delta, 0.0, 1.0)
	var delta: float = fmod(to_degrees - from_degrees + 360.0 + 180.0, 360.0) - 180.0
	return fmod(from_degrees + delta * clamped + 360.0, 360.0)

static func source_accelerator_update_tile_advance_state(frame: Dictionary, source_delta: float) -> Dictionary:
	# The pure updateTile advance (N2191): AcceleratorBuild.updateTile() (Accelerator.java:127-146, `public void updateTile(){` with `super.updateTile();` -- super is the empty BuildingComp updateTile, BuildingComp.java:2010-2012, so the advance is the whole tick):
	# `heat = Mathf.lerpDelta(heat, launching ? 1f : efficiency, 0.05f);`
	# `statusLerp = Mathf.lerpDelta(statusLerp, power.status, 0.05f);`
	# `if(!launching){`
	# `time += Time.delta * efficiency;`
	# `time = Mathf.slerpDelta(time, 0f, 0.4f);`
	# `launchHeat = Mathf.lerpDelta(launchHeat, launching ? 1f : 0f, 0.1f);`
	# `if(efficiency >= 0f){`
	# `progress += Time.delta * efficiency / buildDuration;`
	# `progress = Math.min(progress, 1f);`
	# Build fields: `public float heat, statusLerp;` (Accelerator.java:120), `public float progress;` (Accelerator.java:121), `public float time, launchHeat;` (Accelerator.java:122), `public boolean launching;` (Accelerator.java:123), `public float launchTime;` (Accelerator.java:124). buildDuration is the class field `public float buildDuration = 120f;` (Accelerator.java:52), not overridden by the interplanetary-accelerator def. The accessors `public float progress(){` (Accelerator.java:149) with `return progress;` (Accelerator.java:150) and `public boolean isCoreBuilt(){` (Accelerator.java:153) with `return progress >= 1f;` (Accelerator.java:154) are live since N2485 (source_accelerator_progress_is_core_built_state) -- and the advance is what lets progress reach 1f.
	# launching defaults false (Java boolean default); only beginLaunch sets it true (Accelerator.java:334-337, `public void beginLaunch(boolean launching){` with `this.launching = true;`) and only endLaunch (Accelerator.java:392-394) and the launch Time.runTask (Accelerator.java:277) set it false again (`launching = false;`) -- the launch sequence waits for its own slice, but the flag exists as frame state so the lerps pick the right target.
	# Building.update() runs updateConsumption() before updateTile() (BuildingComp.java:2274-2278, `updateConsumption();` then `if(enabled || !block.noUpdateDisabled){` then `updateTile();`), and noUpdateDisabled defaults false (Block.java:170, `public boolean noUpdateDisabled = false;`) and Accelerator never sets it, so the driver advances every tick, after the consumption fold, even when disabled.
	# The formulas come from Arc Mathf.java, not from guessing: lerp is fromValue + (toValue - fromValue) * progress (Mathf.java:425-427), lerpDelta is lerp(from, to, clamp(progress * Time.delta)) (Mathf.java:430-432), slerp is the angle lerp in degrees with wrap (Mathf.java:455-458), slerpDelta is slerp(from, to, clamp(progress * Time.delta)) (Mathf.java:460-462), and clamp is [0, 1] (Mathf.java:402-404):
	# `public static float lerp(float fromValue, float toValue, float progress){`
	# `return fromValue + (toValue - fromValue) * progress;`
	# `public static float lerpDelta(float fromValue, float toValue, float progress){`
	# `return lerp(fromValue, toValue, clamp(progress * Time.delta));`
	# `public static float slerp(float fromDegrees, float toDegrees, float progress){`
	# `float delta = ((toDegrees - fromDegrees + 360 + 180) % 360) - 180;`
	# `return (fromDegrees + delta * progress + 360) % 360;`
	# `public static float slerpDelta(float fromDegrees, float toDegrees, float progress){`
	# `return slerp(fromDegrees, toDegrees, clamp(progress * Time.delta));`
	# `public static float clamp(float value){`
	# `return Math.max(Math.min(value, 1f), 0f);`
	# lerpDelta reuses the shared SourceMathState.source_lerp_delta, which already implements lerp(from, to, clamp(progress * Time.delta)) exactly; slerpDelta uses the local source_mathf_slerp_delta above. Frame defaults are the Java field defaults: heat/statusLerp/time/launchHeat/progress 0.0, launching false, efficiency 0.0 (Java float/boolean defaults); a missing power_status stamp folds to 1.0, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). Time.delta in the port is seconds * 60 via game_source_delta (arc Time.java:26, the N2093/N2189 precedent); the driver converts before calling.
	var launching: bool = bool(frame.get("launching", false))
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var stamped_power: Variant = frame.get("power_status", null)
	var power_status: float = 1.0 if stamped_power == null else float(stamped_power)
	var heat: float = float(frame.get("heat", 0.0))
	var status_lerp: float = float(frame.get("status_lerp", 0.0))
	var time: float = float(frame.get("time", 0.0))
	var launch_heat: float = float(frame.get("launch_heat", 0.0))
	var progress: float = float(frame.get("progress", 0.0))
	var heat_after: float = source_math_state.source_lerp_delta(heat, 1.0 if launching else efficiency, SOURCE_ACCELERATOR_HEAT_LERP_PROGRESS, source_delta)
	var status_lerp_after: float = source_math_state.source_lerp_delta(status_lerp, power_status, SOURCE_ACCELERATOR_STATUS_LERP_PROGRESS, source_delta)
	var time_after: float
	if not launching:
		time_after = time + source_delta * efficiency
	else:
		time_after = source_mathf_slerp_delta(time, 0.0, SOURCE_ACCELERATOR_TIME_SLERP_PROGRESS, source_delta)
	var launch_heat_after: float = source_math_state.source_lerp_delta(launch_heat, 1.0 if launching else 0.0, SOURCE_ACCELERATOR_LAUNCH_HEAT_LERP_PROGRESS, source_delta)
	var progress_after: float = progress
	if efficiency >= 0.0:
		progress_after = minf(progress + source_delta * efficiency / SOURCE_ACCELERATOR_BUILD_DURATION, 1.0)
	return {"heat": heat_after, "status_lerp": status_lerp_after, "time": time_after, "launch_heat": launch_heat_after, "progress": progress_after}

static func source_accelerator_draw_state(x_value: float, y_value: float, heat: float, status_lerp: float, launch_heat: float, time_value: float, build_time: float, progress: float, launching: bool) -> Dictionary:
	# The draw rows (AcceleratorBuild.draw(), Accelerator.java:157-233), the pure draw-call dict -- the port never draws for real (the SourceBlockDrawState / SourceBaseTurretDrawState pattern, the N2356 ShockwaveTower precedent: the pure returns the draw calls as data). Java draws, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `super.draw();`
	# `float length = 7f + l * 5f;`
	# `Draw.color(Tmp.c1.set(Pal.darkMetal).lerp(team.color, statusLerp), Pal.darkMetal, Mathf.absin(Time.time + l*50f, 10f, 1f));`
	# `Draw.rect(arrowRegion, x + Angles.trnsx(rot, length), y + Angles.trnsy(rot, length), rot + 180f);`
	# `Drawf.shadow(x, y, launchBlock.size * tilesize * 2f, progress);`
	# `Draw.draw(Layer.blockBuilding, () -> {`
	# `Draw.color(Pal.accent, heat);`
	# `Shaders.blockbuild.progress = progress;`
	# `if(heat < 0.0001f) return;`
	# `float rad = size * tilesize / 2f * 0.74f * Mathf.lerp(1f, 1.3f, launchHeat);`
	# `Lines.stroke(1.75f * heat, Pal.accent);`
	# `Lines.square(x, y, rad * 1.22f, Mathf.lerp(45f, 0f, launchHeat));`
	# `Lines.square(x, y, rad * Mathf.lerp(1f, 1.3f, launchHeat), 45f + time / scl);`
	# `Lines.square(x, y, rad * Mathf.lerp(1f, 1.8f, launchHeat), Mathf.lerp(45f, 0f, launchHeat) - time / scl);`
	# `Draw.alpha(Mathf.clamp(heat * 3f));`
	# `float length = 26f * heat * Mathf.lerp(1f, 1.5f, launchHeat);`
	# arrowRegion is the `@-launch-arrow` region (`public @Load(value = "@-launch-arrow", fallback = "launch-arrow") TextureRegion arrowRegion;`, Accelerator.java:36). The arrows loop (:160-169) runs 4 layers x 4 arrows: layer l has length 7f + l * 5f and pulse Mathf.absin(Time.time + l*50f, 10f, 1f) -- ported as source_absin(time_value + l * 50.0, 10.0, 1.0), the ThermalGenerator precedent (SourceThermalGeneratorState.gd:236, Java Mathf.absin(10f, 5f) -> source_absin(source_time, 10.0, 5.0)) -- and the color is the nested lerp (darkMetal -> team.color by statusLerp, then -> darkMetal by the pulse), carried as from/to/t dicts (the N2356 color-lerp precedent); team.color stays a symbolic token, never resolved to RGB. Arrow i sits at rot i*90f + 45f (`float rot = i*90f + 45f;`, :165) via Angles.trnsx/trnsy (len * cosDeg / sinDeg, Angles.java:66-72) with rotation rot + 180f. The launching branch (:180-194) is DEFERRED: `Fill.light(x, y, 15, launchBlock.size * tilesize * 1f, Tmp.c2.set(Pal.accent).a(launchTime / chargeDuration), Tmp.c1.set(Pal.accent).a(0f));` and the fullIcon / mixcol lines (`Draw.mixcol(Pal.accent, Mathf.clamp(launchTime / chargeDuration));`, `Draw.color(1f, 1f, 1f, Interp.pow2In.apply(Mathf.clamp(launchTime / chargeDuration * 0.7f)));`, `Draw.rect(launchBlock.fullIcon, x, y);`) need launchTime, which the frame does not track (see the launchTime / cloudSeed DEFERRED entry) -- when launching is true the pure returns launching_visual_deferred and no shadow / blockbuild calls. The non-launching branch (:195-212) is the shadow (launchBlock.size * tilesize * 2f = 5 * 8 * 2 = 80 -- the launchBlock is core-nucleus, `public Block launchBlock = Blocks.coreNucleus;`, Accelerator.java:40, size 5, Blocks.java:3159; Drawf.shadow draws the circle-shadow at black alpha 0.4 * progress, Drawf.java:360-364) + the Layer.blockBuilding draw (`Draw.color(Pal.accent, heat);` + the blockbuild shader: `Shaders.blockbuild.region = region;` / `Shaders.blockbuild.time = time;` / `Shaders.blockbuild.progress = progress;` per generated icon, `for(TextureRegion region : launchBlock.getGeneratedIcons()){` -- the region list is content, so the call carries the shader params, not the enumeration). The rings (:217-232) run only when heat >= 0.0001f (`if(heat < 0.0001f) return;`); rad = size * tilesize / 2f * 0.74f * lerp(1f, 1.3f, launchHeat) (base 20.72 at size 7, tilesize 8) at z Layer.bullet - 0.0001f (`Draw.z(Layer.bullet - 0.0001f);`); the three Pal.accent squares (`float scl = 2f;`, :218; `Lines.stroke(3f * heat, Pal.accent);`, :224) and the team-color arrows (`Draw.color(team.color);`, :228; rot `float rot = i*90f + 45f + (-time/3f)%360f;`, :230 -- GDScript fmod matches Java % (sign of the dividend), the N2191 precedent). All frame state the pure reads (heat, statusLerp, launchHeat, time, progress, launching) is tracked by the N2191 advance; Time.time is caller-supplied as time_value (the N2356 precedent: draw never runs in the tick, so the tick never stamps it; the pure takes no frame).
	var layers: Array = []
	for l in range(4):
		var length: float = 7.0 + float(l) * 5.0
		var pulse: float = source_math_state.source_absin(time_value + float(l) * 50.0, 10.0, 1.0)
		var arrows: Array = []
		for i in range(4):
			var rot: float = float(i) * 90.0 + 45.0
			arrows.append({
				"x": x_value + cos(deg_to_rad(rot)) * length,
				"y": y_value + sin(deg_to_rad(rot)) * length,
				"rotation": rot + 180.0,
				"rot": rot,
			})
		layers.append({
			"layer": l,
			"length": length,
			"pulse": pulse,
			"color": {"base": {"from": "Pal.darkMetal", "to": "team.color", "t": status_lerp}, "pulse_to": "Pal.darkMetal", "pulse_t": pulse},
			"arrows": arrows,
		})
	var arrows_call: Dictionary = {
		"call": "Draw.rect(arrowRegion, x + Angles.trnsx(rot, length), y + Angles.trnsy(rot, length), rot + 180f);",
		"region": "arrowRegion",
		"layers": layers,
	}
	var shadow_call: Dictionary = {}
	var blockbuild_call: Dictionary = {}
	if not launching:
		shadow_call = {
			"call": "Drawf.shadow(x, y, launchBlock.size * tilesize * 2f, progress);",
			"region": "circle-shadow",
			"radius": float(SOURCE_ACCELERATOR_LAUNCH_BLOCK_SIZE) * SOURCE_ACCELERATOR_TILESIZE * 2.0,
			"alpha_factor": progress,
			"black_alpha": 0.4 * progress,
			"x": x_value,
			"y": y_value,
		}
		blockbuild_call = {
			"call": "Draw.draw(Layer.blockBuilding, () -> {",
			"layer": "Layer.blockBuilding",
			"color": "Pal.accent",
			"alpha": heat,
			"shader_time": build_time,
			"shader_progress": progress,
			"region_source": "launchBlock.getGeneratedIcons()",
			"x": x_value,
			"y": y_value,
		}
	var build_call: Dictionary = {
		"launching": launching,
		"launching_visual_deferred": launching,
		"shadow_call": shadow_call,
		"blockbuild_call": blockbuild_call,
	}
	var heat_gate: bool = heat >= 0.0001
	var rad: float = 0.0
	var squares: Array = []
	var ring_arrows: Array = []
	if heat_gate:
		rad = float(SOURCE_ACCELERATOR_SIZE) * SOURCE_ACCELERATOR_TILESIZE / 2.0 * 0.74 * lerpf(1.0, 1.3, launch_heat)
		squares = [
			{"stroke": 1.75 * heat, "color": "Pal.accent", "radius": rad * 1.22, "rotation": lerpf(45.0, 0.0, launch_heat)},
			{"stroke": 3.0 * heat, "color": "Pal.accent", "radius": rad * lerpf(1.0, 1.3, launch_heat), "rotation": 45.0 + build_time / 2.0},
			{"stroke": 3.0 * heat, "color": "Pal.accent", "radius": rad * lerpf(1.0, 1.8, launch_heat), "rotation": lerpf(45.0, 0.0, launch_heat) - build_time / 2.0},
		]
		var ring_length: float = 26.0 * heat * lerpf(1.0, 1.5, launch_heat)
		for i in range(4):
			var rot: float = float(i) * 90.0 + 45.0 + fmod(-build_time / 3.0, 360.0)
			ring_arrows.append({
				"x": x_value + cos(deg_to_rad(rot)) * ring_length,
				"y": y_value + sin(deg_to_rad(rot)) * ring_length,
				"rotation": rot + 180.0,
				"rot": rot,
				"length": ring_length,
			})
	var rings_call: Dictionary = {
		"present": heat_gate,
		"heat_gate": heat_gate,
		"rad": rad,
		"z": "Layer.bullet - 0.0001f",
		"squares": squares,
		"arrows": ring_arrows,
		"arrow_color": "team.color",
		"arrow_alpha": clampf(heat * 3.0, 0.0, 1.0),
	}
	return {
		"super_draw_called": true,
		"super_draw_expr": "super.draw();",
		"arrow_color_expr": "Draw.color(Tmp.c1.set(Pal.darkMetal).lerp(team.color, statusLerp), Pal.darkMetal, Mathf.absin(Time.time + l*50f, 10f, 1f));",
		"arrow_rect_expr": "Draw.rect(arrowRegion, x + Angles.trnsx(rot, length), y + Angles.trnsy(rot, length), rot + 180f);",
		"shadow_expr": "Drawf.shadow(x, y, launchBlock.size * tilesize * 2f, progress);",
		"blockbuild_expr": "Draw.draw(Layer.blockBuilding, () -> {",
		"heat_gate_expr": "if(heat < 0.0001f) return;",
		"rad_expr": "float rad = size * tilesize / 2f * 0.74f * Mathf.lerp(1f, 1.3f, launchHeat);",
		"z_expr": "Draw.z(Layer.bullet - 0.0001f);",
		"reset_expr": "Draw.reset();",
		"x": x_value,
		"y": y_value,
		"heat": heat,
		"status_lerp": status_lerp,
		"launch_heat": launch_heat,
		"time_value": time_value,
		"build_time": build_time,
		"progress": progress,
		"launching": launching,
		"shadow_radius": float(SOURCE_ACCELERATOR_LAUNCH_BLOCK_SIZE) * SOURCE_ACCELERATOR_TILESIZE * 2.0,
		"rad": rad,
		"arrows_call": arrows_call,
		"build_call": build_call,
		"rings_call": rings_call,
	}

static func source_accelerator_draw_light_state(x_value: float, y_value: float, launch_heat: float) -> Dictionary:
	# The drawLight rows (AcceleratorBuild.drawLight(), Accelerator.java:235-237), the pure draw-call dict -- the port never draws for real (the N2356 pattern). Java draws, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `Drawf.light(x, y, lightRadius, lightColor, launchHeat);`
	# lightRadius is 70f and lightColor is Pal.accent (`lightRadius = 70f;` / `lightColor = Pal.accent;`, Accelerator.java:79-80, set in the constructor; `emitLight = true;`, Accelerator.java:78); the opacity is the frame launchHeat (Accelerator.java:122, advanced by the N2191 advance toward 1f when launching, 0f otherwise), so an idle accelerator emits no light. Drawf.light(x, y, radius, color, opacity) adds the light to the renderer (Drawf.java:301-304, `public static void light(float x, float y, float radius, Color color, float opacity){`); the pure records the call as data, like the draw pure. Pure-only: drawLight never runs in the tick.
	var light_call: Dictionary = {
		"call": "Drawf.light(x, y, lightRadius, lightColor, launchHeat);",
		"x": x_value,
		"y": y_value,
		"radius": SOURCE_ACCELERATOR_LIGHT_RADIUS,
		"color": "lightColor",
		"opacity": launch_heat,
	}
	return {
		"light_expr": "Drawf.light(x, y, lightRadius, lightColor, launchHeat);",
		"x": x_value,
		"y": y_value,
		"launch_heat": launch_heat,
		"light_call": light_call,
	}

static func source_accelerator_draw_select_state(tile_x: int, tile_y: int, battery_stored: float, launching: bool) -> Dictionary:
	# The drawSelect rows (AcceleratorBuild.drawSelect(), Accelerator.java:249-256), the pure draw-call dict -- the port never draws for real (the N2356 pattern). Java draws, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `super.drawSelect();`
	# `if(power.graph.getBatteryStored() < powerBufferRequirement && !launching){`
	# `drawPlaceText(Core.bundle.get("bar.nobatterypower"), tile.x, tile.y, false);`
	# super.drawSelect() is Building.drawSelect() (the selection overlay); the pure records that the super call happens, not its content (the N2356 super.draw() precedent). The battery warning shows exactly when the stored battery is below the requirement (powerBufferRequirement 1,000,000f, Blocks.java:6826, `powerBufferRequirement = 1_000_000f;`) and the accelerator is not launching; battery_stored is the frame input stamped live by the N2342 graph stamp (getBatteryStored(), PowerGraph.java:118-127), and launching is the N2191 frame flag. drawPlaceText(text, x, y, valid) with valid false draws the text in Pal.remove with the underline (`public float drawPlaceText(String text, int x, int y, boolean valid){` / `return drawPlaceText(text, x, y, valid ? Pal.accent : Pal.remove, true);`, Block.java:531-532). getCursor (`return canLaunch() ? SystemCursor.hand : super.getCursor();`, Accelerator.java:245) is live since N2452 as the pure source_accelerator_get_cursor_state (the environment half composes over the caller-supplied N2271 gate output; the super branch reads block.configurable && interactable(player.team()), BuildingComp.java:1683-1684). Pure-only: drawSelect never runs in the tick.
	var warning_shown: bool = battery_stored < SOURCE_ACCELERATOR_POWER_BUFFER_REQUIREMENT and not launching
	var battery_warning_call: Dictionary = {
		"call": "drawPlaceText(Core.bundle.get(\"bar.nobatterypower\"), tile.x, tile.y, false);",
		"shown": warning_shown,
		"text_key": "bar.nobatterypower",
		"tile_x": tile_x,
		"tile_y": tile_y,
		"valid": false,
		"color": "Pal.remove",
		"draw_line": true,
	}
	return {
		"super_draw_select_called": true,
		"super_draw_select_expr": "super.drawSelect();",
		"warning_gate_expr": "if(power.graph.getBatteryStored() < powerBufferRequirement && !launching){",
		"warning_expr": "drawPlaceText(Core.bundle.get(\"bar.nobatterypower\"), tile.x, tile.y, false);",
		"tile_x": tile_x,
		"tile_y": tile_y,
		"battery_stored": battery_stored,
		"launching": launching,
		"battery_warning_call": battery_warning_call,
	}

static func source_accelerator_power_buffer_bar_state(battery_stored: float, power_buffer_requirement: float) -> Dictionary:
	# The powerBufferRequirement bar rows (Accelerator.setBars(), Accelerator.java:100-111), the pure bar-call dict -- the port never draws for real (the N2373 draw precedent: the pure returns the bar call as data). Java registers the bar only when the requirement is positive (each exact expr on ONE comment line, the N2148 lesson):
	# `public void setBars(){`
	# `super.setBars();`
	# `if(powerBufferRequirement > 0f){`
	# `addBar("powerBufferRequirement", b -> new Bar(`
	# `() -> Core.bundle.format("bar.powerbuffer",UI.formatAmount((long)b.power.graph.getBatteryStored()),  UI.formatAmount((long)powerBufferRequirement)),`
	# `() -> Pal.powerBar,`
	# `() -> b.power.graph.getBatteryStored() / powerBufferRequirement`
	# The bar name is "powerBufferRequirement" and the label key is "bar.powerbuffer" (`bar.powerbuffer = Batteries: {0}/{1}`, bundle.properties:1283) with the stored and required amounts formatted by UI.formatAmount (`public static String formatAmount(long number){`, UI.java:781-800 -- magnitude suffixes with [gray] markup from the billions / millions / thousands bundle strings, plus the Long.MAX_VALUE / Long.MIN_VALUE infinity guards). The pure returns the RAW long amounts -- Java casts the floats to long (`(long)b.power.graph.getBatteryStored()`, `(long)powerBufferRequirement`, truncation toward zero, which GDScript int() matches) -- and the formatted "Batteries: X/Y" string is a UI concern the pure does not build: inventing the [gray] markup / suffix rendering here would guess at bundle content the pure cannot see. The color is Pal.powerBar (`powerBar = Color.valueOf("ec7b4c"),`, Pal.java:93), carried as a symbolic token, never resolved to RGB (the N2373 color-token precedent). The fraction is the raw stored / requirement ratio: Java does NOT clamp it in the lambda -- the Bar itself clamps at render (`lastValue = value = Mathf.clamp(fraction.get());` in the constructor and `float computed = Mathf.clamp(fraction.get());` in draw(), Bar.java; `public static float clamp(float value){` clamps to [0, 1], `return Math.max(Math.min(value, 1f), 0f);`, Mathf.java:402-404) -- so a stored battery above the requirement reports a raw fraction above 1.0 here and the Bar draws it full. When the requirement is 0f or negative the bar does not exist at all (the gate is strict > 0f): the pure returns bar_present false, an empty bar dict and fraction 0.0 -- Java never evaluates the fraction lambda then (the Bar is never constructed), so 0.0 is the documented absent default, not a Java value. battery_stored is the caller-supplied getBatteryStored() value (`public float getBatteryStored(){`, PowerGraph.java:118-127, the enabled-battery total, stamped live on the frame by the N2342 graph stamp) -- the pure never queries the power graph itself. power_buffer_requirement is the class field (`public float powerBufferRequirement;`, Accelerator.java:41), set by the single def to 1,000,000f (`powerBufferRequirement = 1_000_000f;`, Blocks.java:6826). Pure-only: the bar never runs in the tick.
	var bar_present: bool = power_buffer_requirement > 0.0
	var stored_amount: int = int(battery_stored)
	var requirement_amount: int = int(power_buffer_requirement)
	var fraction: float = battery_stored / power_buffer_requirement if bar_present else 0.0
	var bar: Dictionary = {}
	if bar_present:
		bar = {
			"call": "addBar(\"powerBufferRequirement\", b -> new Bar(",
			"name": "powerBufferRequirement",
			"label_key": "bar.powerbuffer",
			"stored_amount": stored_amount,
			"requirement_amount": requirement_amount,
			"color": "Pal.powerBar",
			"fraction": fraction,
		}
	return {
		"bar_present": bar_present,
		"bar_gate_expr": "if(powerBufferRequirement > 0f){",
		"bar_expr": "addBar(\"powerBufferRequirement\", b -> new Bar(",
		"label_expr": "() -> Core.bundle.format(\"bar.powerbuffer\",UI.formatAmount((long)b.power.graph.getBatteryStored()),  UI.formatAmount((long)powerBufferRequirement)),",
		"color_expr": "() -> Pal.powerBar,",
		"fraction_expr": "() -> b.power.graph.getBatteryStored() / powerBufferRequirement",
		"bar_name": "powerBufferRequirement",
		"label_key": "bar.powerbuffer",
		"stored_amount": stored_amount,
		"requirement_amount": requirement_amount,
		"color": "Pal.powerBar",
		"fraction": fraction,
		"bar": bar,
	}

static func source_accelerator_get_cursor_state(gate_can_launch: bool, is_valid: bool, is_client: bool, is_campaign: bool, configurable: bool, interactable: bool) -> Dictionary:
	# The getCursor rows (AcceleratorBuild.getCursor(), Accelerator.java:243-246), the pure cursor dict -- the port never sets a cursor for real (the N2373 draw precedent: the pure returns the cursor as data). Java returns the hand cursor when the launch gate passes, else the BuildingComp super branch (each exact expr on ONE comment line, the N2148 lesson):
	# `public Cursor getCursor(){`
	# `return canLaunch() ? SystemCursor.hand : super.getCursor();`
	# canLaunch() (Accelerator.java:239-240) is the conjunction of the environment half and the tick-state half:
	# `public boolean canLaunch(){`
	# `return isValid() && !net.client() && state.isCampaign() && efficiency > 0f && power.graph.getBatteryStored() >= powerBufferRequirement-0.00001f && progress >= 1f && !launching;`
	# The tick-state half (efficiency > 0f, battery >= requirement - 0.00001f, progress >= 1f, !launching) is the EXISTING N2271 pure source_accelerator_can_launch_state, whose can_launch output arrives here as the caller-supplied gate_can_launch -- this pure does NOT recompute it. The environment half is the three caller-supplied bools: isValid() (`public boolean isValid(){`, BuildingComp.java:2030, `return tile.build == self() && !dead();`), net.client() (`public boolean client(){`, Net.java:404) and state.isCampaign() (`public boolean isCampaign(){`, GameState.java:73) -- the port has no net / campaign state, so the caller supplies the evaluated values. The super branch is BuildingComp.getCursor() (BuildingComp.java:1682-1685, `/** Returns whether a hand cursor should be shown over this block. */`):
	# `public Cursor getCursor(){`
	# `return block.configurable && interactable(player.team()) ? SystemCursor.hand : SystemCursor.arrow;`
	# with interactable(Team) (`public boolean interactable(Team team){`, BuildingComp.java:595, `return state.teams.canInteract(team, team());`) also caller-supplied. Verify-first finding: Accelerator DOES set `configurable = true;` in its constructor (Accelerator.java:77), so the super-hand branch is live for this def whenever the building is interactable -- the pure still takes configurable as an input (the N554 BuildingComp precedent: the canonical source_building_cursor_state takes block_configurable explicit), so the pure stays honest about what it reads. The cursor tokens are the SystemCursor names ("hand" / "arrow"), carried as strings, never resolved to a Godot cursor object (the N2373 color-token precedent). Pure-only: getCursor never runs in the tick.
	var can_launch: bool = gate_can_launch and is_valid and not is_client and is_campaign
	var cursor: String = "hand" if can_launch else ("hand" if configurable and interactable else "arrow")
	return {"can_launch": can_launch, "cursor": cursor}

static func source_accelerator_per_def_stats_state(def_id: String) -> Dictionary:
	# The per-def stat rows (the VERIFICATION slice: the values
	# are already constants in this driver's header -- the
	# N2304 / N2442 / N2489 / N2490 precedent): the def's size /
	# scaledHealth / powerBufferRequirement / requirements for
	# interplanetary-accelerator, the single Accelerator def
	# (Blocks.java:6823-6832), with the CLASS defaults for an
	# unknown def id (the N2304 fallback precedent). The def
	# block (each exact expr on ONE comment line, the N2148
	# lesson):
	# `interplanetaryAccelerator = new Accelerator("interplanetary-accelerator"){{`
	# `requirements(Category.effect, BuildVisibility.campaignOnly, with(Items.copper, 16000, Items.silicon, 11000, Items.thorium, 13000, Items.titanium, 12000, Items.surgeAlloy, 6000, Items.phaseFabric, 5000));`
	# `size = 7;`
	# `scaledHealth = 80;`
	# `powerBufferRequirement = 1_000_000f;`
	# The class defaults (Accelerator.java:41, Block.java:188/215/356):
	# `public float powerBufferRequirement;`
	# `public float scaledHealth = -1;`
	# `public int size = 1;`
	# `public ItemStack[] requirements = {};`
	# Accelerator extends Block (`public class Accelerator extends Block{`,
	# Accelerator.java:35). The requirements dict is the
	# {item: amount} dict from the def (the
	# SourceAcceleratorBuildState capacities precedent:
	# {"copper": 8000, "lead": 8000, "silicon": 5000,
	# "thorium": 4000}); the catalog carries the same rows as
	# an Array of {item, amount} dicts
	# (content_registry.json, interplanetary-accelerator).
	# scaledHealth fallback note: the CLASS field default is
	# -1 (Block.java:188, `public float scaledHealth = -1;`),
	# the "unset" sentinel -- Block.init() resolves it to 40
	# when health == -1 (Block.java:1380-1381,
	# `scaledHealth = 40;`, times the requirements
	# healthScaling sum, 1f for an unknown def with no
	# requirements), and that resolution lives in
	# SourceBlockInitHealthState (block_health.
	# default_scaled_health), NOT in this pure: this pure
	# returns the field value, the N2490 precedent. The def's
	# own health cross-checks: 7 * 7 * 80 = 3920, the catalog
	# health (Block.init, Block.java:1393-1394). An unknown
	# def id falls back to the CLASS defaults -- size 1,
	# scaledHealth -1, powerBufferRequirement 0f (the
	# uninitialized float field, Java default 0f), and NO
	# requirements (the Block default is the empty array).
	# Pure-only: the caller reads it; the advance +
	# shouldConsume pures take these values as
	# caller-supplied inputs and are unchanged.
	if def_id == "interplanetary-accelerator":
		return {
			"size": 7,
			"scaled_health": 80.0,
			"power_buffer_requirement": 1000000.0,
			"requirements": {"copper": 16000, "silicon": 11000, "thorium": 13000, "titanium": 12000, "surge-alloy": 6000, "phase-fabric": 5000},
		}
	return {
		"size": 1,
		"scaled_health": -1.0,
		"power_buffer_requirement": 0.0,
		"requirements": {},
	}

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
		# row and the pure item row (N2267) into the first pass,
		# so ConsumePower.efficiency and the ConsumeItems row fold
		# into the min efficiency like every other non-optional
		# consumer, and the progress advance (Accelerator.java:143)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so an accelerator does not take the early return. The accelerator's power draw is STATIC: `consumePower(10f);` (Blocks.java:6829) registers a plain ConsumePower, so the catalog consumePower 10.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. An accelerator with no power consumer is untouched: the tick models the power row and the item row (N2267) -- the launch / battery advance waits for its own slice; the updateTile heat/statusLerp/time/launchHeat/progress advance is N2191 -- and AcceleratorBuild has NO shouldConsume override, so the BuildingComp default applies (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) -- there is NO gate to defer here, the power + item fold is EXACT, because the only gate is `enabled`, which the driver already checks. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
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
			# The launch-block item consumer rows read live
			# since N2267: the core-nucleus requirements
			# (copper 8000 / lead 8000 / silicon 5000 /
			# thorium 4000, Blocks.java:3154) fold into the
			# REQUIRED first pass like every other
			# non-optional consumer, so a starved item row
			# zeroes efficiency and the progress advance
			# (Accelerator.java:143) follows it. No live
			# intake fills frame["items"] yet (the Separator
			# precedent) -- the row reads the frame as-is.
			# NO removal here: consume() only happens at
			# launch (Accelerator.java:258-291).
			var item_row: Dictionary = source_accelerator_item_consumer_row_state(frame, _accelerator_item_stacks_for_block(block_id))
			if bool(item_row.get("has_item_row", false)):
				required_results.append(item_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# The updateTile advance (Accelerator.java:127-146) runs every tick after the consumption fold (Building.update() calls updateConsumption() then updateTile(), BuildingComp.java:2274-2278; the gate `if(enabled || !block.noUpdateDisabled){` passes even when disabled because noUpdateDisabled defaults false, Block.java:170, and Accelerator never sets it) -- so heat/statusLerp/launchHeat lerp, time advances or slerps, and progress charges toward isCoreBuilt() (Accelerator.java:153-154, `return progress >= 1f;`) on the folded efficiency; super.updateTile() is empty (BuildingComp.java:2010-2012). The launching flag stays false until the launch-sequence slice drives beginLaunch (Accelerator.java:334-337). The driver converts its seconds argument to Time.delta ticks via game_source_delta (seconds * 60, arc Time.java:26).
		var advanced: Dictionary = source_accelerator_update_tile_advance_state(frame, source_placed_block_state.game_source_delta(game, seconds))
		frame["heat"] = advanced.get("heat", 0.0)
		frame["status_lerp"] = advanced.get("status_lerp", 0.0)
		frame["time"] = advanced.get("time", 0.0)
		frame["launch_heat"] = advanced.get("launch_heat", 0.0)
		frame["progress"] = advanced.get("progress", 0.0)
		# The launch transition (N2271): buildConfiguration (Accelerator.java:258-290) is a UI action, not a tick -- the port drives it from the frame key `launch_requested` (default false), a one-shot trigger set by the config path (no config UI exists yet, so the key is a frame input like battery_stored). When true, the driver re-checks canLaunch (Accelerator.java:264, `if(canLaunch()){`) on the folded efficiency, the frame battery_stored input, the advanced progress and the launching flag -- and applies the launch transition (Accelerator.java:265-271: `consume();` / `ItemSeq resources = new ItemSeq();` / `resources.add(items);` / `items.clear();` / `power.graph.useBatteries(powerBufferRequirement);` / `progress = 0f;`) only when the gate passes. The resources are DISCARDED: Java hands them to universe.updateLaunchResources(resources) (Accelerator.java:281, inside the deferred Time.runTask), which has no port equivalent. The request is CLEARED in both cases (Java: the dialog closes, there is no queue -- the user clicks again). The launching flag is NOT touched here: beginLaunch (Accelerator.java:334-337) sets it true via renderer.showLaunch, which is deferred. The battery_stored frame input has no live fill yet (the graph summary computes it, SourcePlacedPowerGraphState.gd:303, but does not stamp it on the building frame) -- a live accelerator reads the input as-is (default 0.0), so the gate stays closed until the graph-stamp slice wires it.
		if bool(frame.get("launch_requested", false)):
			var gate: Dictionary = source_accelerator_can_launch_state(float(frame.get("efficiency", 0.0)), float(frame.get("battery_stored", 0.0)), float(frame.get("progress", 0.0)), bool(frame.get("launching", false)), SOURCE_ACCELERATOR_POWER_BUFFER_REQUIREMENT)
			if bool(gate.get("can_launch", false)):
				var launched: Dictionary = source_accelerator_launch_state(frame.get("items", {}), float(frame.get("battery_stored", 0.0)), SOURCE_ACCELERATOR_POWER_BUFFER_REQUIREMENT, _accelerator_item_stacks_for_block(block_id))
				frame["items"] = launched.get("items", {})
				frame["battery_stored"] = launched.get("battery_stored", 0.0)
				frame["progress"] = launched.get("progress", 0.0)
				# The per-battery drain request (N2354): Java drains the batteries themselves here (`power.graph.useBatteries(powerBufferRequirement);`, Accelerator.java:270), but the graph update runs BEFORE the driver ticks in simulate_factory (SourceFactoryRuntimeState.gd:199 vs :509), so the driver leaves a one-shot frame["launch_drain_request"] = {requirement} for the runtime to take on the NEXT tick's graph update (a 1-tick delay, documented in the runtime) -- the runtime scales every enabled battery through the existing Java-exact use_batteries_state before the N2342 stamp recomputes the total, so the stamp reads the drained total and the drain is never refunded. A failed gate leaves no request: Java calls useBatteries only inside the `if(canLaunch()){` branch.
				frame["launch_drain_request"] = {"requirement": SOURCE_ACCELERATOR_POWER_BUFFER_REQUIREMENT}
			frame["launch_requested"] = false
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
