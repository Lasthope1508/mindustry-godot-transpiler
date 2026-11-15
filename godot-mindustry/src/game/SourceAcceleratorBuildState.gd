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
# lerpDelta/slerpDelta progress values from AcceleratorBuild.updateTile (Accelerator.java:131-140).
const SOURCE_ACCELERATOR_HEAT_LERP_PROGRESS := 0.05
const SOURCE_ACCELERATOR_STATUS_LERP_PROGRESS := 0.05
const SOURCE_ACCELERATOR_TIME_SLERP_PROGRESS := 0.4
const SOURCE_ACCELERATOR_LAUNCH_HEAT_LERP_PROGRESS := 0.1

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
	# Build fields: `public float heat, statusLerp;` (Accelerator.java:120), `public float progress;` (Accelerator.java:121), `public float time, launchHeat;` (Accelerator.java:122), `public boolean launching;` (Accelerator.java:123), `public float launchTime;` (Accelerator.java:124). The accessors `public float progress(){` (Accelerator.java:149) with `return progress;` (Accelerator.java:150) expose the progress, `public boolean isCoreBuilt(){` (Accelerator.java:153) with `return progress >= 1f;` (Accelerator.java:154) gates the launch, and `public boolean canLaunch(){` (Accelerator.java:239) with `return isValid() && !net.client() && state.isCampaign() && efficiency > 0f && power.graph.getBatteryStored() >= powerBufferRequirement-0.00001f && progress >= 1f && !launching;` (Accelerator.java:240, keep on ONE comment line, the N2148 shootWarmup lesson) needs efficiency AND a full battery AND progress 1f; the battery half waits for its own slice. The launch itself consumes the stored items and the battery (Accelerator.java:267, `if(power.graph.getBatteryStored() < powerBufferRequirement && !launching){` with Accelerator.java:270, `power.graph.useBatteries(powerBufferRequirement);`, Accelerator.java:271, `progress = 0f;`, and Accelerator.java:289, `Events.fire(Trigger.acceleratorUse);`) -- the launch waits for its own slice. The item gate `public int getMaximumAccepted(Item item){` (Accelerator.java:293) with `return capacities[item.id] + (isCoreBuilt() ? launchBlock.itemCapacity : 0);` (Accelerator.java:294) and `return items.get(item) < getMaximumAccepted(item);` (Accelerator.java:299) rides on the launch, not the tick. The progress persists across saves: `write.f(progress);` (Accelerator.java:305) with `progress = read.f();` (Accelerator.java:311). The launch duration `public float launchDuration(){` (Accelerator.java:317) with `return launchDuration + chargeDuration;` (Accelerator.java:318) is the full launch time.
	# Single def -- interplanetary-accelerator only (size 7, scaledHealth 80, powerBufferRequirement 1,000,000f, copper 16000 / silicon 11000 / thorium 13000 / titanium 12000 / surge-alloy 6000 / phase-fabric 5000, Blocks.java:6823-6832): `interplanetaryAccelerator = new Accelerator("interplanetary-accelerator"){{` (Blocks.java:6823) with `requirements(Category.effect, BuildVisibility.campaignOnly, with(Items.copper, 16000, Items.silicon, 11000, Items.thorium, 13000, Items.titanium, 12000, Items.surgeAlloy, 6000, Items.phaseFabric, 5000));` (Blocks.java:6824), `researchCostMultiplier = 0.1f;` (Blocks.java:6825), `powerBufferRequirement = 1_000_000f;` (Blocks.java:6826), `size = 7;` (Blocks.java:6827), `consumePower(10f);` (Blocks.java:6829), `buildCostMultiplier = 0.5f;` (Blocks.java:6830) and `scaledHealth = 80;` (Blocks.java:6831). No second Accelerator def exists; there is no family split to manage. No sense / read / write overrides exist on AcceleratorBuild beyond the progress save -- those wait for their own slices only if a later Java line needs them.
	# Documented limits: (1) power + item first pass -- the accelerator's static power consumer (consumePower 10f, Blocks.java:6829) and the launch-block item consumer rows (core-nucleus requirements copper 8000 / lead 8000 / silicon 5000 / thorium 4000, Blocks.java:3154, registered by `consumeItems(launchBlock.requirements);`, Accelerator.java:91) are live since N2267, with the init() capacities (copper 8000 / lead 8000 / silicon 5000 / thorium 4000, itemCapacity 25000, Accelerator.java:85-90) and the getMaximumAccepted / acceptItem accessors (Accelerator.java:293-299, core bonus 13000 from the core-nucleus itemCapacity, Blocks.java:3158); the folded efficiency is the min over the *modeled* consumers (power + items). No live intake fills frame["items"] yet (the Separator precedent) -- the row reads the frame as-is, so a live accelerator with no intake folds efficiency 0; the launch consume() (Accelerator.java:258-291) and the battery gate (Accelerator.java:239-240, 270) still wait for their own slices. (2) NO shouldConsume gate to defer -- AcceleratorBuild has no shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-756) applies; the power + item fold is EXACT for this family. (3) updateTile advance is DONE (N2191: heat/statusLerp/time/launchHeat/progress, Accelerator.java:127-146) -- the launch / battery advance still waits: canLaunch battery gate / useBatteries / acceleratorUse event (Accelerator.java:239-240, 267-289), the launching flag transitions (beginLaunch / endLaunch, Accelerator.java:334-337, 392-394) and the launchTime / cloudSeed state (Accelerator.java:124, 126) wait for their own slices; the proof carries no launch / battery keys, and the launching branch of the advance is proven pure only, because nothing in the port sets the flag yet. (4) No battery-side modeling -- getBatteryStored / useBatteries / powerBufferRequirement bar (Accelerator.java:105-109, 240, 270) wait for their own slice. (5) Single def -- interplanetary-accelerator only (size 7, scaledHealth 80, powerBufferRequirement 1,000,000f, copper 16000 / silicon 11000 / thorium 13000 / titanium 12000 / surge-alloy 6000 / phase-fabric 5000); per-def stat values wait for their own verification slice. (6) No draw/config modeling -- draw / drawSelect / config wait for their own slices. (7) Disabled-efficiency staleness -- updateConsumption forces efficiency to 0 when !shouldConsume (BuildingComp.java:1992), but the driver skips the consumption fold when disabled, so frame["efficiency"] keeps its last folded value and the updateTile advance reads it stale; the driver zeroing waits for its own slice.
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
	# Build fields: `public float heat, statusLerp;` (Accelerator.java:120), `public float progress;` (Accelerator.java:121), `public float time, launchHeat;` (Accelerator.java:122), `public boolean launching;` (Accelerator.java:123), `public float launchTime;` (Accelerator.java:124). buildDuration is the class field `public float buildDuration = 120f;` (Accelerator.java:52), not overridden by the interplanetary-accelerator def. The accessors `public float progress(){` (Accelerator.java:149) with `return progress;` (Accelerator.java:150) and `public boolean isCoreBuilt(){` (Accelerator.java:153) with `return progress >= 1f;` (Accelerator.java:154) wait for their own slice -- but the advance is what lets progress reach 1f.
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
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
