extends RefCounted
class_name SourceConstructorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_move_out_payload_state := preload("res://src/game/SourceBlockProducerMoveOutPayloadState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")

# The Constructor implementation (Constructor.java:19, `public class Constructor extends BlockProducer{`): constructor (consumePower(2.5f);, size 3, buildSpeed 0.6f, Blocks.java:6658-6667) and large-constructor (consumePower(3f);, size 5, buildSpeed 0.75f, Blocks.java:6670-6680). BlockProducer has hasPower = true; (BlockProducer.java:32), hasItems=true, update=true, solid=true, outputsPayload=true (BlockProducer.java:28-35). Constructor extends BlockProducer, NOT a drill or factory, so it cannot reuse an existing frame key; this driver uses its own family frame key ("source_constructor_building", the mechanical-pump / beam-drill / mend-projector / overdrive-projector / force-projector / base-shield / regen-projector precedent), and this slice adds the constructor key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceConstructor* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the produce gate (BlockProducer.java:110, `boolean produce = recipe != null && efficiency > 0 && payload == null;`) follows the folded efficiency, with the progress advance (BlockProducer.java:113, `progress += buildSpeed * edelta();`).
const SOURCE_CONSTRUCTOR_BUILD_IMPLEMENTATIONS := ["Constructor"]
const SOURCE_CONSTRUCTOR_BUILDING_META_KEY := "source_constructor_building"
# buildSpeed per def (constructor `buildSpeed = 0.6f;`, Blocks.java:6662;
# large-constructor `buildSpeed = 0.75f;`, Blocks.java:6674) with the class
# default (`public float buildSpeed = 0.4f;`, BlockProducer.java:22) as fallback --
# the catalog carries no buildSpeed key, so the driver resolves it from this
# dict (the BurstDrill per-def dict precedent). Payload speeds are the
# PayloadBlock class constants (`public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;`, PayloadBlock.java:18), passed to the reused moveOutPayload helper.
const SOURCE_CONSTRUCTOR_BUILD_SPEED := {"constructor": 0.6, "large-constructor": 0.75}
const SOURCE_CONSTRUCTOR_BUILD_SPEED_DEFAULT := 0.4
const SOURCE_CONSTRUCTOR_PAYLOAD_SPEED := 0.7
const SOURCE_CONSTRUCTOR_PAYLOAD_ROTATE_SPEED := 5.0

static func _is_constructor_build_implementation(implementation: String) -> bool:
	return SOURCE_CONSTRUCTOR_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_constructor_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The constructor tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (Constructor.java:19, `public class Constructor extends BlockProducer{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# constructor skips consumption like Java's updateConsumption
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
	# for this constructor (N2125); the tick preserves a disabled
	# constructor instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {"recipe": null, "items": {}, "progress": 0.0, "heat": 0.0, "time": 0.0, "payload": null, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0}

static func source_constructor_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the constructor frame meta key
	# ("source_constructor_building"). A Constructor sprite gets a
	# frame bound with the recipe key defaulting to null (the Java field
	# `public @Nullable Block recipe;`, Constructor.java:59, defaults to null)
	# and the items key defaulting to {} (the N2265 dynamic row reads it;
	# no live intake fills it yet); the N2274 advance keys default to the
	# Java field defaults (progress / heat / time 0f, `public float
	# progress, time, heat;`, BlockProducer.java:78; payload null,
	# payVector (0, 0), payRotation 0f, PayloadBlock.java:92-95);
	# the live-loop tick fills its other keys every tick. Any other
	# block, or an already-bound sprite, binds nothing.
	if block == null or not _is_constructor_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_CONSTRUCTOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_CONSTRUCTOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_CONSTRUCTOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_constructor_should_consume_state(frame: Dictionary) -> Dictionary:
	# BlockProducerBuild overrides shouldConsume (BlockProducer.java:102, `public boolean shouldConsume(){` with `return super.shouldConsume() && recipe() != null;`, BlockProducer.java:103): the gate reads the live recipe AND the enabled flag -- `super` is the BuildingComp default (`return enabled;`, BuildingComp.java:755-756); PayloadBlockBuild does NOT override shouldConsume, so the gate is really `enabled && recipe() != null`. The field is `public @Nullable Block recipe;` (Constructor.java:59) on ConstructorBuild (`public class ConstructorBuild extends BlockProducerBuild{`, Constructor.java:58); Constructor extends BlockProducer (Constructor.java:19, `public class Constructor extends BlockProducer{`), and BlockProducer is abstract (`public abstract class BlockProducer extends PayloadBlock{`, BlockProducer.java:21) with the abstract recipe (`public abstract @Nullable Block recipe();`, BlockProducer.java:80). The gate HAS the enabled term via super -- the pure gate reads frame["enabled"] too (the ItemBridge N2188 / RepairTurret N2212 precedent): recipe (frame["recipe"], default null for a frame bound before this slice -- the Java field default) and enabled (frame["enabled"], default true -- BuildingComp.java:77, `transient boolean enabled = true;`); the live recipe fill is live since N2462 -- the tick applies the N2455 config pure from frame["recipe_config"] before the fold (`config(Block.class, (ConstructorBuild tile, Block block) -> {`, Constructor.java:32, set only when canProduce, Constructor.java:54; `configClear((ConstructorBuild tile) -> tile.recipe = null);`, Constructor.java:31/38). When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The produce gate (BlockProducer.java:110, `boolean produce = recipe != null && efficiency > 0 && payload == null;`) follows the folded efficiency, with the progress advance (BlockProducer.java:113, `progress += buildSpeed * edelta();`). The two defs carry `consumePower(2.5f);` (constructor, Blocks.java:6663) and `consumePower(3f);` (large-constructor, Blocks.java:6679).
	var recipe: Variant = frame.get("recipe", null)
	var enabled: bool = bool(frame.get("enabled", true))
	return {"should_consume": recipe != null and enabled, "has_recipe": recipe != null}

static func source_constructor_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a constructor does not take the early return. The produce gate follows the folded efficiency (BlockProducer.java:110, `boolean produce = recipe != null && efficiency > 0 && payload == null;`), with the progress advance (BlockProducer.java:113, `progress += buildSpeed * edelta();`) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){`) and the shouldConsume override (BlockProducer.java:103, `return super.shouldConsume() && recipe() != null;`). The shouldConsume gate is live (N2216) -- the pure gate (source_constructor_should_consume_state) feeds should_consume to the machinery from the frame recipe key (null with no recipe, non-null once a block is configured as the recipe) and the enabled flag; the live recipe fill is live since N2462 (frame["recipe_config"] -> the N2455 config pure, Constructor.java:31-38).
	# Documented limits: (1) dynamic item row live (N2265) -- the ConsumeItemDynamic over the recipe requirements (BlockProducer.java:39-55) folds beside power into the first pass: the stacks clone the recipe block's requirements with each amount ceiled against the build-cost multiplier (BlockProducer.java:49), the row is BINARY (ConsumeItemDynamic.efficiency, ConsumeItemDynamic.java:60-62), and a null recipe folds 1.0 (ItemStack.empty, BlockProducer.java:53). The build-cost multiplier reads rules_state.get("buildCostMultiplier", 1.0) -- the port rules_state carries no buildCostMultiplier key yet, so the 1.0 default (Rules.java:115) always applies for now. No live intake fills frame["items"] yet, so the row reads the frame as-is; the trigger is wired live since N2274 (consume() fires when the progress advance completes, BlockProducer.java:115-116); the live recipe fill is live since N2462 (see (6)). (2) shouldConsume gate live (N2216) -- BlockProducerBuild overrides shouldConsume() to return super.shouldConsume() && recipe() != null (BlockProducer.java:102-104); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the pure gate reads the frame recipe key (default null) plus enabled and feeds should_consume to the machinery; the live recipe fill is live since N2462 (see (6)). (3) updateTile advance live (N2274) -- progress / heat / time / moveOutPayload (BlockProducer.java:107-128) run every tick after the consumption fold through the pure source_constructor_update_tile_advance_state function: the produce gate (BlockProducer.java:110, `boolean produce = recipe != null && efficiency > 0 && payload == null;`), progress += buildSpeed * edelta (BlockProducer.java:113), completion consumes via the N2265 trigger (now wired live) + spawns the BuildPayload dict + payVector zero + progress %= 1f (BlockProducer.java:115-120, the remainder is kept, not reset to 0), heat lerps toward produce at 0.15f (BlockProducer.java:124), time += heat * delta (BlockProducer.java:125), moveOutPayload reuses the shared helper (PayloadBlock.java:199-228) with no-front defaults; the placeEffect (BlockProducer.java:118) is recorded by the draw pure (N2440, see (5)), the recipe buildTime follows the Block.init formula (Block.java:1432-1443) from the catalog requirements + item costs since the catalog carries no buildTime key, and the live recipe fill is live since N2462 (see (6)). (4) Config/filter rows live (N2455) -- see (6). (5) Draw rows live (N2440) -- draw (BlockProducer.java:134-160) + drawSelect (Constructor.java:77-87) + the placeEffect (BlockProducer.java:116-119) are modeled by the pure-only source_constructor_draw_state (base rect + out rect at rotdeg() + recipe shadow + blockbuild shader loop + scan line + drawPayload + top rect + drawSelect icon + place effect); config/filter rows live (see (6)). (6) Config/filter rows live (N2455) -- the can-produce pure (source_constructor_can_produce_state) models canProduce() (Constructor.java:54-56: all 7 conditions in Java order over the caller-supplied block dict + filter name list) + the config pure (source_constructor_config_state) models config(Block) (:32-37: progress reset BEFORE the canProduce gate, so a non-producible block still resets progress) + configClear (:31/:38, recipe = null, no progress reset) + buildConfiguration (:66-70, the ItemSelection.buildTable CALL record) + config() (:73-75, the pure's recipe IS the post-action config() value) as a pure-only fold over the discriminated action (set / clear / none, the N2449 precedent) + the stats pure (source_constructor_stats_state) models setStats() (:41-47: Stat.output "@x@ ~ @x@" with [min, min, max, max] + Stat.buildSpeed RAW, percent formatting at display, Stats.java:38, the N2451 precedent). Defs: constructor (filter 7 walls/containers + beam-node, Blocks.java:6666; buildSpeed 0.6f, :6662; min/max class defaults 1/2) and large-constructor (empty filter, min 3 / max 4, buildSpeed 0.75f, Blocks.java:6675-6677). The config pure is wired live since N2462 (the tick applies it from frame["recipe_config"] before the fold); canProduce / buildConfiguration / setStats stay pure-only -- the configure-UI / input-handler / stats-UI call sites wait for their own slices.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_constructor_dynamic_item_stacks_state(recipe_requirements: Array, build_cost_multiplier: float) -> Array:
	# The BlockProducer dynamic consumer (BlockProducer.java:39, `consume(new ConsumeItemDynamic((BlockProducerBuild e) -> {`): when recipe() != null the stacks clone the recipe block's requirements with each amount ceiled against the build-cost multiplier (`clone[i].amount = Mathf.ceil(block.requirements[i].amount * state.rules.buildCostMultiplier);`, BlockProducer.java:49); when recipe() == null the stacks are ItemStack.empty (`return ItemStack.empty;`, BlockProducer.java:53), so empty requirements yield an empty array. The multiplier default is 1f (`public float buildCostMultiplier = 1f;`, Rules.java:115). The pure function takes the requirements as a parameter and reads no catalog -- the driver resolves the recipe block id through the catalog and passes its requirements ([{amount, item}] kebab-case).
	var stacks: Array = []
	for requirement in recipe_requirements:
		if not (requirement is Dictionary):
			continue
		var item_name: String = str(requirement.get("item", ""))
		var amount: int = int(ceil(float(requirement.get("amount", 0)) * build_cost_multiplier))
		stacks.append({"item": item_name, "amount": amount})
	return stacks

static func source_constructor_dynamic_item_consumer_row_state(frame: Dictionary, stacks: Array, multiplier: float) -> Dictionary:
	# ConsumeItemDynamic.efficiency (ConsumeItemDynamic.java:60-62, `return build.consumeTriggerValid() || build.items.has(items.get(build), multiplier.get(build)) ? 1f : 0f;`): BINARY 1/0, not a ratio -- 1 when the building is burning a trigger consumer or its item module holds every stack, 0 otherwise. consumeTriggerValid() is false at the base (BuildingComp.java:764-766, `public boolean consumeTriggerValid(){` with `return false;`) and no Constructor/BlockProducer build overrides it, so the trigger term is always false here. items.has (ItemModule.java:153-156, `if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;`) requires EVERY stack to hold round(amount * multiplier), with has(item, amount) = get(item) >= amount (ItemModule.java:126-128, `return get(item) >= amount;`); the port's item module is a Dictionary keyed by item name, so an unknown item reads 0 through the shared inventory helper (SourceDrillInventoryRuntimeState.item_count, reused through a preload, NOT re-implemented), the same outcome as the id-out-of-range branch. An empty stacks array holds trivially (the loop never runs), so a null recipe folds 1.0 -- the consumer is still in nonOptionalConsumers, so the row always joins the first pass (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The multiplier defaults to 1f (Consume.java:18, `public Floatf<Building> multiplier = b -> 1f;`); the BlockProducer dynamic consumer sets none.
	var items: Dictionary = frame.get("items", {})
	var result := 1.0
	for stack in stacks:
		if not (stack is Dictionary):
			continue
		var item_name: String = str(stack.get("item", ""))
		var needed: int = int(round(float(stack.get("amount", 0)) * multiplier))
		if inventory.item_count(items, item_name) < needed:
			result = 0.0
	return {"has_item_row": true, "row": {"result": result, "is_power": false}}

static func source_constructor_dynamic_item_trigger_state(items: Dictionary, stacks: Array, multiplier: float) -> Dictionary:
	# ConsumeItemDynamic.trigger (ConsumeItemDynamic.java:53-57, `build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));`): remove round(amount * multiplier) of each stack, clamped to the held count (`amount = Math.min(amount, items[item.id]);`, ItemModule.java:258-263) through the shared inventory helper (SourceDrillInventoryRuntimeState.remove_item_state, reused through a preload, NOT re-implemented). Wired live since N2274: consume() fires when the progress advance completes (`if(progress >= recipe.buildTime){`, BlockProducer.java:115, with `consume();`, BlockProducer.java:116) -- the advance calls this trigger and writes the items back.
	var next_items: Dictionary = items.duplicate(true)
	for stack in stacks:
		if not (stack is Dictionary):
			continue
		var item_name: String = str(stack.get("item", ""))
		var amount: int = int(round(float(stack.get("amount", 0)) * multiplier))
		var removed: Dictionary = inventory.remove_item_state(next_items, item_name, amount)
		next_items = removed.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, next_items)
	return next_items

static func source_constructor_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, build_speed: float, build_time: float, stacks: Array, rotdeg_value: float, size_value: float, front: Dictionary, move_payload_result: bool) -> Dictionary:
	# The updateTile advance (N2274): BlockProducerBuild.updateTile()
	# (BlockProducer.java:107-128), `public void updateTile(){`, on
	# `public abstract class BlockProducer extends PayloadBlock{`
	# (BlockProducer.java:21). Build fields: `public float progress, time, heat;` (BlockProducer.java:78), `public @Nullable T payload;` / `public Vec2 payVector = new Vec2();` / `public float payRotation;` (PayloadBlock.java:92-95), `public float buildSpeed = 0.4f;` (BlockProducer.java:22, the class default; constructor 0.6f / large-constructor 0.75f, Blocks.java:6662/6674). Java order, step by step.
	# `super.updateTile();` (BlockProducer.java:108) is the payload entity update (PayloadBlock.java:158-162) -- skipped, no live payload entity. `var recipe = recipe();` (BlockProducer.java:109); `boolean produce = recipe != null && efficiency > 0 && payload == null;` (BlockProducer.java:110). If produce: `progress += buildSpeed * edelta();` (BlockProducer.java:113), then `if(progress >= recipe.buildTime){` (BlockProducer.java:115) with `consume();` (BlockProducer.java:116) -- the N2265 trigger, wired live here -- then `payload = new BuildPayload(recipe, team);` (BlockProducer.java:117; `public BuildPayload(Block block, Team team){` with `this.build = block.newBuilding().create(block, team);`, BuildPayload.java:18-21), then `payload.block().placeEffect.at(x, y, payload.size() / tilesize);` (BlockProducer.java:118, presentation -- deferred), then `payVector.setZero();` (BlockProducer.java:119), then `progress %= 1f;` (BlockProducer.java:120) -- the remainder is KEPT, not reset to 0 (fmod in GDScript, the same float remainder Java `%` computes). Then `heat = Mathf.lerpDelta(heat, Mathf.num(produce), 0.15f);` (BlockProducer.java:124) and `time += heat * delta();` (BlockProducer.java:125) -- time uses the NEW heat, the heat line runs first. Then `moveOutPayload();` (BlockProducer.java:127), UNCONDITIONAL -- it runs every tick, including the tick a payload spawns. delta() is `return Time.delta * timeScale;` (BuildingComp.java:1922-1924) and edelta() is `return efficiency * delta();` (BuildingComp.java:1927-1929); source_delta is Time.delta in ticks (seconds * 60 through game_source_delta, arc Time.java:26), never raw seconds; timeScale reads `private transient float timeScale = 1f, timeScaleDuration;` (BuildingComp.java:98); efficiency is `transient float efficiency;` (BuildingComp.java:85), default 0.0. The heat lerp takes the RAW Time.delta: arc lerpDelta is `return lerp(fromValue, toValue, clamp(progress * Time.delta));` (Mathf.java:430-432), so the port passes source_delta, not the scaled delta (the N2193 precedent), while progress / time use the scaled delta / edelta.
	# moveOutPayload (PayloadBlock.java:199-228): `public void moveOutPayload(){` with `if(payload == null) return;` / `Vec2 dest = Tmp.v1.trns(rotdeg(), size * tilesize/2f);` / `payRotation = Angles.moveToward(payRotation, rotdeg(), payloadRotateSpeed * delta());` / `payVector.approach(dest, payloadSpeed * delta());` / `Building front = front();` / `boolean canDump = front == null || !front.tile.solid();` / `boolean canMove = front != null && (front.block.outputsPayload || front.block.acceptsPayload);` / `if(canDump && !canMove){` / `pushOutput(payload, 1f - (payVector.dst(dest) / (size * tilesize / 2f)));` / `if(payVector.within(dest, 0.001f)){` / `payVector.clamp(-size * tilesize / 2f, -size * tilesize / 2f, size * tilesize / 2f, size * tilesize / 2f);` / `if(canMove){` / `if(movePayload(payload)){` / `payload = null;` / `}else if(canDump){` / `dumpPayload();` -- the WHOLE moveOut branch REUSES the ported SourceBlockProducerMoveOutPayloadState.move_out_payload_state helper through a preload (the N2231 / N2224 cross-driver precedent): its signature matches this call exactly (same PayloadBlock.moveOutPayload, generic params). `public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;` (PayloadBlock.java:18); `public static final int tilesize = 8;` (Vars.java:135). The front snapshot arrives as an explicit param (driver passes no-front defaults). The spawned payload dict is {"block": recipe id, "team": team id} + the N2231 build stores (build_items / build_liquids / build_current_liquid / build_power_status, empty for a fresh build); the N2231 block_* flags are NOT populated from the recipe block yet (a downstream loader reads them as their defaults) -- unifying the payload contract waits for its own slice.
	# Returns the advanced frame values plus the consumed flag; the driver writes the frame keys back. The advance runs after consumption, like Java's Building.update() (BuildingComp.java:2274-2277, `updateConsumption();` then `if(enabled || !block.noUpdateDisabled){` / `updateTile();`), and WITHOUT an enabled guard: BlockProducer has `public boolean noUpdateDisabled = false;` (Block.java:170, the default), so Java runs updateTile() even when disabled (updateConsumption folds efficiency to 0, so the progress advance stalls while heat / time / moveOut still run on delta). When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`).
	var recipe: Variant = frame.get("recipe", null)
	var recipe_id: String = ""
	if recipe is String:
		recipe_id = str(recipe)
	elif recipe is Dictionary:
		recipe_id = str(recipe.get("block", ""))
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var payload_value: Variant = frame.get("payload", null)
	var payload: Variant = null
	if payload_value is Dictionary:
		payload = (payload_value as Dictionary).duplicate(true)
	var produce: bool = recipe != null and efficiency > 0.0 and payload == null
	var progress: float = float(frame.get("progress", 0.0))
	var heat: float = float(frame.get("heat", 0.0))
	var time_value: float = float(frame.get("time", 0.0))
	var pay_vector_value: Variant = frame.get("pay_vector", {})
	var pay_vector: Dictionary = {"x": 0.0, "y": 0.0}
	if pay_vector_value is Dictionary:
		pay_vector = {"x": float(pay_vector_value.get("x", 0.0)), "y": float(pay_vector_value.get("y", 0.0))}
	var pay_rotation: float = float(frame.get("pay_rotation", 0.0))
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var delta: float = source_delta * time_scale
	var edelta: float = efficiency * delta
	var consumed: bool = false
	if produce:
		progress += build_speed * edelta
		if progress >= build_time:
			items = source_constructor_dynamic_item_trigger_state(items, stacks, 1.0)
			consumed = true
			payload = {"block": recipe_id, "team": int(frame.get("team_id", 0)), "build_items": {}, "build_liquids": {}, "build_current_liquid": "", "build_power_status": 0.0}
			pay_vector = {"x": 0.0, "y": 0.0}
			progress = fmod(progress, 1.0)
	var heat_target: float = 1.0 if produce else 0.0
	heat = source_math_state.source_lerp_delta(heat, heat_target, 0.15, source_delta)
	time_value += heat * delta
	if payload != null:
		var moved_out: Dictionary = source_move_out_payload_state.move_out_payload_state(true, float(pay_vector.get("x", 0.0)), float(pay_vector.get("y", 0.0)), pay_rotation, rotdeg_value, size_value, source_world_defaults.TILESIZE, SOURCE_CONSTRUCTOR_PAYLOAD_ROTATE_SPEED, SOURCE_CONSTRUCTOR_PAYLOAD_SPEED, delta, bool(front.get("present", false)), bool(front.get("solid", false)), bool(front.get("outputs_payload", false)), bool(front.get("accepts_payload", false)), move_payload_result)
		pay_vector = moved_out.get("pay_vector_after", pay_vector)
		pay_rotation = float(moved_out.get("pay_rotation_after", pay_rotation))
		if not bool(moved_out.get("payload_after_present", true)):
			payload = null
	return {"progress": progress, "heat": heat, "time": time_value, "payload": payload, "pay_vector": pay_vector, "pay_rotation": pay_rotation, "items": items, "consumed": consumed}

@warning_ignore("unused_parameter")
static func source_constructor_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the constructor tick wiring every
	# tick (BlockProducerBuild.updateTile(), BlockProducer.java:107,
	# gates on the produce gate (BlockProducer.java:110, `boolean produce = recipe != null && efficiency > 0 && payload == null;`) and the progress advance (BlockProducer.java:113, `progress += buildSpeed * edelta();`), so the produce gate follows the folded efficiency; no placed-buildings driver ticks Constructor blocks, so this driver is the placed-constructor tick): each placed Constructor build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
	var items_by_id: Dictionary = {}
	for registered_item in catalog.get_many("item"):
		items_by_id[registered_item.id] = registered_item
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if not _is_constructor_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_constructor_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_constructor_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The live recipe config fill (N2462, DEFERRED #95):
		# the input handler's pending config action arrives
		# on the frame as frame["recipe_config"] = {action:
		# "set" / "clear" / "none", block: the family recipe
		# fixture {"block": <catalog id>} or null,
		# can_produce: the caller-supplied verdict of
		# source_constructor_can_produce_state over the full
		# block dict, computed by the input handler -- the
		# tick never calls canProduce itself} (the N2449
		# discriminated-action precedent); an absent
		# frame["recipe_config"] key is action "none"
		# (no-op). The tick applies the EXISTING N2455
		# config pure -- source_constructor_config_state,
		# Constructor.java:32-37 + :31/:38 -- and stamps
		# frame["recipe"] + frame["progress"] BEFORE the
		# recipe resolution, the shouldConsume gate and the
		# consumption fold: Java order is config as an
		# input-handler event, applied before the tick's
		# consumption fold, so the gate sees the new recipe
		# the same tick. The pure returns progress_reset,
		# not a progress value: the wiring writes 0.0 only
		# when the pure says reset -- a set of a DIFFERENT
		# block resets progress BEFORE the canProduce gate
		# (if(tile.recipe != block) tile.progress = 0f; runs
		# before if(canProduce(block)){, :33 before :34, so
		# a non-producible block still resets progress
		# while the recipe stays put); "clear" never resets
		# (configClear sets recipe = null only, :31/:38),
		# and a set of the SAME block resets nothing, so
		# re-applying the frame input every tick is harmless
		# -- the input does NOT need to be consumed
		# (idempotent by :33's recipe != block guard). No
		# new pure, no register: the wiring reuses the N2455
		# pure (the N2413 wiring-only precedent).
		var recipe_config: Dictionary = {}
		if frame.get("recipe_config", null) is Dictionary:
			recipe_config = frame.get("recipe_config", {})
		var config_action: String = str(recipe_config.get("action", "none"))
		var config_result: Dictionary = source_constructor_config_state(config_action, recipe_config.get("block", null), frame.get("recipe", null), bool(recipe_config.get("can_produce", false)))
		frame["recipe"] = config_result.get("recipe", frame.get("recipe", null))
		if bool(config_result.get("progress_reset", false)):
			frame["progress"] = 0.0
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a constructor with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the produce gate (BlockProducer.java:110)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a constructor does not take the early return. A constructor with no power consumer is untouched: the machinery runs only when the block has a power consumer, and both defs do. The dynamic item row (N2265) folds beside the power row inside the guard, and BlockProducerBuild overrides shouldConsume() to return super.shouldConsume() && recipe() != null (BlockProducer.java:102-104) -- N2216 feeds the live gate to the machinery (the pure gate is source_constructor_should_consume_state, fed the frame); the N2161 RED decision is resolved. The gate HAS an enabled term via super (Java returns `super.shouldConsume() && recipe() != null;` with the default `return enabled;`), so the pure gate reads frame["enabled"] too (the ItemBridge N2188 / RepairTurret N2212 precedent); the outer guard below already runs the machinery only when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		# The recipe resolution (N2265) is hoisted above the
		# fold guard so the N2274 advance below reuses it:
		# the recipe block id resolves through the catalog,
		# whose requirements arrive as [{amount, item}]
		# kebab-case; a null recipe (or a recipe block the
		# catalog does not know, or one with no requirements)
		# yields empty stacks, so the row folds 1.0 -- the
		# consumer is still in nonOptionalConsumers, so the
		# row always appends. The frame recipe is the family
		# dict fixture {"block": <id>} (the N2161/N2216 proof
		# precedent); a bare string id is accepted too.
		# The build-cost multiplier reads the live rules
		# state with the 1.0 default -- the port
		# rules_state carries no buildCostMultiplier key
		# yet (Rules.java:115, `public float
		# buildCostMultiplier = 1f;`). The multiplier
		# defaults to 1f (Consume.java:18, `public
		# Floatf<Building> multiplier = b -> 1f;`); the
		# BlockProducer dynamic consumer sets none.
		var recipe: Variant = frame.get("recipe", null)
		var recipe_id: String = ""
		if recipe is String:
			recipe_id = str(recipe)
		elif recipe is Dictionary:
			recipe_id = str(recipe.get("block", ""))
		var recipe_requirements: Array = []
		if recipe_id != "" and blocks_by_id.has(recipe_id):
			var recipe_block = blocks_by_id[recipe_id]
			var catalog_requirements: Variant = recipe_block.properties.get("requirements", [])
			if catalog_requirements is Array:
				recipe_requirements = catalog_requirements
		var build_cost_multiplier: float = 1.0
		if rules_state is Dictionary:
			build_cost_multiplier = float(rules_state.get("buildCostMultiplier", 1.0))
		var dynamic_stacks: Array = source_constructor_dynamic_item_stacks_state(recipe_requirements, build_cost_multiplier)
		# The recipe buildTime (N2274, Block.init,
		# Block.java:1432-1443): `if(requirements.length > 0 && buildTime < 0){` /
		# `buildTime = 0f;` / `buildTime += stack.amount * stack.item.cost;`
		# then `if(buildTime < 0){` / `buildTime = 20f;`
		# then `buildTime *= buildCostMultiplier;` -- the
		# catalog carries no buildTime key, so the driver
		# computes it from the catalog requirements + item
		# costs (`public float cost = 1f;`, Item.java:35,
		# the default for an item the catalog does not
		# know). A null recipe yields the 20f default, which
		# the advance never reads (produce is false with no
		# recipe). A recipe block with an explicit def
		# buildTime (Blocks.java:4456, the only explicit def)
		# reads the formula value instead -- the catalog
		# capture waits for its own slice.
		var recipe_build_time: float = 20.0
		if not recipe_requirements.is_empty():
			recipe_build_time = 0.0
			for requirement in recipe_requirements:
				if requirement is Dictionary:
					var requirement_cost: float = 1.0
					var requirement_item: String = str(requirement.get("item", ""))
					if items_by_id.has(requirement_item):
						requirement_cost = float(items_by_id[requirement_item].properties.get("cost", 1.0))
					recipe_build_time += float(requirement.get("amount", 0)) * requirement_cost
		recipe_build_time *= build_cost_multiplier
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_constructor_should_consume_state(frame)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_constructor_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var dynamic_row: Dictionary = source_constructor_dynamic_item_consumer_row_state(frame, dynamic_stacks, 1.0)
			if bool(dynamic_row.get("has_item_row", false)):
				required_results.append(dynamic_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# The updateTile advance (N2274, BlockProducer.java:107-128): runs after the
		# consumption fold -- the Java order, `updateConsumption();` then
		# `if(enabled || !block.noUpdateDisabled){` / `updateTile();` (BuildingComp.java:2274-2277) --
		# and WITHOUT an enabled guard: BlockProducer has
		# `public boolean noUpdateDisabled = false;` (Block.java:170, the default), so
		# Java runs updateTile() even when disabled (updateConsumption folds efficiency
		# to 0, so the progress advance stalls while heat / time / moveOut still run
		# on delta -- the N2231 precedent). The driver passes the per-def buildSpeed
		# (constructor 0.6f / large-constructor 0.75f, Blocks.java:6662/6674, class
		# default 0.4f, BlockProducer.java:22), the recipe buildTime computed above,
		# the dynamic stacks (the N2265 trigger fires through consume() when progress
		# completes), the live rotdeg from the rotation meta (`public float rotdeg(){`
		# with `return rotation * 90;`, BuildingComp.java:582-584), the catalog size
		# (3 / 5), and no-front defaults (no live front query yet -- the catalog
		# carries no outputsPayload / acceptsPayload flags) with move_payload_result
		# false. The source delta is Time.delta in ticks: game_source_delta(game,
		# seconds) is seconds * 60 (arc Time.java:26), never raw seconds; timeScale
		# reads live from the sprite meta, default 1.0 (BuildingComp.java:98). The
		# pure advance returns the advanced frame values, which the driver writes
		# back; with the live recipe fill (N2462) the advance produces once a
		# recipe is configured, and stays a heat-decay / move-out no-op with no
		# recipe (recipe null -> no produce).
		var build_speed: float = float(SOURCE_CONSTRUCTOR_BUILD_SPEED.get(block_id, SOURCE_CONSTRUCTOR_BUILD_SPEED_DEFAULT))
		var rotdeg_value: float = float(int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))) * 90.0
		var front: Dictionary = {"present": false, "solid": false, "outputs_payload": false, "accepts_payload": false}
		var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
		var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
		var advanced: Dictionary = source_constructor_update_tile_advance_state(frame, source_delta, time_scale, build_speed, recipe_build_time, dynamic_stacks, rotdeg_value, float(block.properties.get("size", 3)), front, false)
		frame["progress"] = advanced["progress"]
		frame["heat"] = advanced["heat"]
		frame["time"] = advanced["time"]
		frame["payload"] = advanced["payload"]
		frame["pay_vector"] = advanced["pay_vector"]
		frame["pay_rotation"] = advanced["pay_rotation"]
		frame["items"] = advanced["items"]
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}

static func source_constructor_draw_state(x_value: float, y_value: float, rotation: int, time_value: float, heat: float, progress: float, recipe: Variant, payload_present: bool, just_crafted: bool, size_value: int, draw_scl: float, draw_xscl: float, draw_yscl: float) -> Dictionary:
	# The draw / drawSelect / placeEffect rows
	# (BlockProducerBuild.draw(), BlockProducer.java:134-160
	# + ConstructorBuild.drawSelect(), Constructor.java:77-87
	# + the craft-complete effect, BlockProducer.java:116-119),
	# the pure draw-call dict -- the port never draws for real
	# (the N2418 PayloadDeconstructor precedent: the pure
	# returns the draw calls as data). Java draws, in order
	# (each exact expr on ONE comment line, the N2148 lesson):
	# `Draw.rect(region, x, y);`
	# `Draw.rect(outRegion, x, y, rotdeg());`
	# `if(recipe != null){`
	# `Drawf.shadow(x, y, recipe.size * tilesize * 2f, progress / recipe.buildTime);`
	# `Draw.draw(Layer.blockBuilding, () -> {`
	# `Draw.color(Pal.accent);`
	# `for(TextureRegion region : recipe.getGeneratedIcons()){`
	# `Shaders.blockbuild.region = region;`
	# `Shaders.blockbuild.time = time;`
	# `Shaders.blockbuild.progress = progress / recipe.buildTime;`
	# `Draw.rect(region, x, y, recipe.rotate ? rotdeg() : 0);`
	# `Draw.flush();`
	# `Draw.color();`
	# `Draw.z(Layer.blockBuilding + 1);`
	# `Draw.color(Pal.accent, heat);`
	# `Lines.lineAngleCenter(x + Mathf.sin(time, 10f, Vars.tilesize / 2f * recipe.size + 1f), y, 90, recipe.size * Vars.tilesize + 1f);`
	# `Draw.reset();`
	# `drawPayload();`
	# `Draw.z(Layer.blockBuilding + 1.1f);`
	# `Draw.rect(topRegion, x, y);`
	# The base rect always draws; then the out rect at
	# rotdeg(); then, only with a recipe, the shadow + the
	# blockbuild shader loop + the scan line; then
	# drawPayload(); then the top rect always, at z
	# Layer.blockBuilding + 1.1f. drawSelect():
	# `float dx = x - size * tilesize/2f, dy = y + size * tilesize/2f;`
	# `TextureRegion icon = recipe.uiIcon;`
	# `Draw.mixcol(Color.darkGray, 1f);`
	# `Draw.rect(icon, dx - 0.7f, dy - 1f, Draw.scl * Draw.xscl * 24f, Draw.scl * Draw.yscl * 24f);`
	# `Draw.reset();`
	# `Draw.rect(icon, dx, dy, Draw.scl * Draw.xscl * 24f, Draw.scl * Draw.yscl * 24f);`
	# -- dx / dy use the PRODUCER block size (3 / 5), not
	# the recipe size; the shadow rect sits at dx - 0.7f,
	# dy - 1f under the darkGray mixcol. The placeEffect
	# fires when the craft completes:
	# `if(progress >= recipe.buildTime){`
	# `payload = new BuildPayload(recipe, team);`
	# `payload.block().placeEffect.at(x, y, payload.size() / tilesize);`
	# -- the scale is payload.size() / tilesize, and
	# BuildPayload.size() is `public float size(){` /
	# `return build.block.size * tilesize;`
	# (BuildPayload.java:86-88), so the scale is the RECIPE
	# block size in tiles -- NOT the producer size. The
	# placeEffect default is `public Effect placeEffect = Fx.placeBlock;`
	# (Block.java:374); the recipe dict carries its
	# place_effect token caller-supplied. just_crafted is
	# the caller-supplied craft-complete flag -- the N2274
	# advance owns the progress >= buildTime condition, so
	# the pure fires the effect only when just_crafted is
	# true (and a recipe is present). drawPayload()
	# (PayloadBlock.java:246-253):
	# `public void drawPayload(){`
	# `if(payload != null){`
	# `updatePayload();`
	# `Draw.z(Layer.blockOver);`
	# `payload.draw();`
	# -- the HELD payload, recorded as the call + z + the
	# updatePayload() call, not the inner draw (the N2418
	# precedent). The generated icons come from
	# `public TextureRegion[] getGeneratedIcons(){` /
	# `return generatedIcons == null ? (generatedIcons = icons()) : generatedIcons;`
	# (Block.java:986-988) -- content, caller-supplied as
	# the recipe icons array of region names; the shader
	# loop is recorded as CALL + params (region / time /
	# progress ratio / per-region rotation), the shader
	# itself is NOT ported. The sin is the arc 3-arg form
	# `public static float sin(float radians, float scl, float mag){`
	# `return sin(radians / scl) * mag;`
	# (Mathf.java:90-92, arc) -- NOT absin (the N2415
	# precedent) -- so the scan offset is sin(time / 10f)
	# * (tilesize / 2f * recipe.size + 1f) and the length
	# is recipe.size * tilesize + 1f: recipe size 2 gives
	# magnitude 9 and length 17, recipe size 4 gives 17
	# and 33. rotdeg() is `public float rotdeg(){` /
	# `return rotation * 90;` (BuildingComp.java:582-584).
	# Layer.blockBuilding is `blockBuilding = 40,` and
	# Layer.blockOver is `blockOver = 35,` (Layer.java:
	# 42/45), so the scan z is 41 and the top z is 41.1.
	# Drawf.shadow is
	# `public static void shadow(float x, float y, float rad, float alpha){`
	# (Drawf.java:360-364):
	# `Draw.color(0, 0, 0, 0.4f * alpha);`
	# `Draw.rect("circle-shadow", x, y, rad * Draw.xscl, rad * Draw.yscl);`
	# -- the circle-shadow at black alpha 0.4 * progress
	# ratio. Build fields are `public float progress, time, heat;`
	# (BlockProducer.java:78, tracked by the N2274 advance)
	# and the recipe is `public abstract @Nullable Block recipe();`
	# (BlockProducer.java:80) over the field
	# `public @Nullable Block recipe;` (Constructor.java:59)
	# on `public class Constructor extends BlockProducer{`
	# (Constructor.java:19). tilesize is the Java constant
	# 8.0 (`public static final int tilesize = 8;`,
	# Vars.java:135 -- NEVER the game tile_size 32, the
	# N2375 lesson). Two defs share this driver:
	# `size = 3;` (constructor, Blocks.java:6658-6667,
	# `buildSpeed = 0.6f;`) and `size = 5;`
	# (large-constructor, Blocks.java:6670-6680,
	# `buildSpeed = 0.75f;`); neither def overrides the
	# drawer -- draw() is the BlockProducerBuild override,
	# no drawer field on Constructor / BlockProducer.
	# size_value is the PRODUCER block size (the drawSelect
	# dx / dy input); draw_scl / draw_xscl / draw_yscl are
	# the Draw scale statics, caller-supplied (draw never
	# runs in the tick, so the tick never stamps them, the
	# N2396/N2372 convention). Pure-only: the tick never
	# calls draw -- draw is called by the renderer, and
	# the renderer call site waits for a renderer slice.
	var tile_size: float = source_world_defaults.TILESIZE
	var rotdeg_value: float = float(rotation) * 90.0
	var has_recipe: bool = recipe != null
	var recipe_dict: Dictionary = {}
	if recipe is Dictionary:
		recipe_dict = recipe
	var recipe_size: int = int(recipe_dict.get("size", 0))
	var recipe_build_time: float = float(recipe_dict.get("build_time", 0.0))
	var progress_ratio: float = 0.0
	if has_recipe and recipe_build_time != 0.0:
		progress_ratio = progress / recipe_build_time
	var recipe_rotate: bool = bool(recipe_dict.get("rotate", false))
	var recipe_icons: Array = []
	if recipe_dict.get("icons", null) is Array:
		recipe_icons = recipe_dict.get("icons")
	var ui_icon: String = str(recipe_dict.get("ui_icon", "recipe.uiIcon"))
	var place_effect: String = str(recipe_dict.get("place_effect", "Fx.placeBlock"))
	var shadow_radius: float = float(recipe_size) * tile_size * 2.0
	var scan_magnitude: float = tile_size / 2.0 * float(recipe_size) + 1.0
	var scan_length: float = float(recipe_size) * tile_size + 1.0
	var scan_x: float = x_value + sin(time_value / 10.0) * scan_magnitude
	var select_dx: float = x_value - float(size_value) * tile_size / 2.0
	var select_dy: float = y_value + float(size_value) * tile_size / 2.0
	var select_width: float = draw_scl * draw_xscl * 24.0
	var select_height: float = draw_scl * draw_yscl * 24.0
	var base_call: Dictionary = {
		"call": "Draw.rect(region, x, y);",
		"region": "region",
		"x": x_value,
		"y": y_value,
	}
	var out_call: Dictionary = {
		"call": "Draw.rect(outRegion, x, y, rotdeg());",
		"region": "outRegion",
		"x": x_value,
		"y": y_value,
		"rotation": rotdeg_value,
	}
	var shadow_call: Variant = null
	if has_recipe:
		shadow_call = {
			"call": "Drawf.shadow(x, y, recipe.size * tilesize * 2f, progress / recipe.buildTime);",
			"x": x_value,
			"y": y_value,
			"radius": shadow_radius,
			"alpha": progress_ratio,
			"color_alpha": 0.4 * progress_ratio,
			"region": "circle-shadow",
		}
	var build_call: Variant = null
	if has_recipe:
		var region_calls: Array = []
		for icon in recipe_icons:
			region_calls.append({
				"call": "Draw.rect(region, x, y, recipe.rotate ? rotdeg() : 0);",
				"region": str(icon),
				"x": x_value,
				"y": y_value,
				"rotation": rotdeg_value if recipe_rotate else 0.0,
				"shader_region": "Shaders.blockbuild.region = region;",
				"shader_time_expr": "Shaders.blockbuild.time = time;",
				"shader_progress_expr": "Shaders.blockbuild.progress = progress / recipe.buildTime;",
				"flush": "Draw.flush();",
			})
		build_call = {
			"call": "Draw.draw(Layer.blockBuilding, () -> {",
			"layer": "Layer.blockBuilding",
			"layer_value": 40.0,
			"color": "Pal.accent",
			"regions": recipe_icons,
			"region_calls": region_calls,
			"shader_time": time_value,
			"shader_progress": progress_ratio,
			"rotate": recipe_rotate,
		}
	var scan_call: Variant = null
	if has_recipe:
		scan_call = {
			"call": "Lines.lineAngleCenter(x + Mathf.sin(time, 10f, Vars.tilesize / 2f * recipe.size + 1f), y, 90, recipe.size * Vars.tilesize + 1f);",
			"x": scan_x,
			"y": y_value,
			"angle": 90.0,
			"length": scan_length,
			"color": "Pal.accent",
			"alpha": heat,
			"z": "Layer.blockBuilding + 1",
			"z_value": 41.0,
			"magnitude": scan_magnitude,
		}
	var payload_call: Variant = null
	if payload_present:
		payload_call = {
			"call": "payload.draw();",
			"update_payload_call": "updatePayload();",
			"z": "Layer.blockOver",
			"z_value": 35.0,
		}
	var top_call: Dictionary = {
		"call": "Draw.rect(topRegion, x, y);",
		"region": "topRegion",
		"x": x_value,
		"y": y_value,
		"z": "Layer.blockBuilding + 1.1f",
		"z_value": 41.1,
	}
	var select_call: Variant = null
	if has_recipe:
		select_call = {
			"call": "Draw.rect(icon, dx, dy, Draw.scl * Draw.xscl * 24f, Draw.scl * Draw.yscl * 24f);",
			"shadow_call": "Draw.rect(icon, dx - 0.7f, dy - 1f, Draw.scl * Draw.xscl * 24f, Draw.scl * Draw.yscl * 24f);",
			"icon": ui_icon,
			"x": select_dx,
			"y": select_dy,
			"shadow_x": select_dx - 0.7,
			"shadow_y": select_dy - 1.0,
			"width": select_width,
			"height": select_height,
			"mixcol": "Color.darkGray",
			"mixcol_alpha": 1.0,
		}
	var place_effect_call: Variant = null
	if just_crafted and has_recipe:
		place_effect_call = {
			"call": "payload.block().placeEffect.at(x, y, payload.size() / tilesize);",
			"effect": place_effect,
			"x": x_value,
			"y": y_value,
			"scale": float(recipe_size),
		}
	return {
		"base_expr": "Draw.rect(region, x, y);",
		"out_expr": "Draw.rect(outRegion, x, y, rotdeg());",
		"shadow_expr": "Drawf.shadow(x, y, recipe.size * tilesize * 2f, progress / recipe.buildTime);",
		"build_expr": "Draw.draw(Layer.blockBuilding, () -> {",
		"scan_expr": "Lines.lineAngleCenter(x + Mathf.sin(time, 10f, Vars.tilesize / 2f * recipe.size + 1f), y, 90, recipe.size * Vars.tilesize + 1f);",
		"payload_expr": "payload.draw();",
		"top_expr": "Draw.rect(topRegion, x, y);",
		"select_expr": "Draw.rect(icon, dx, dy, Draw.scl * Draw.xscl * 24f, Draw.scl * Draw.yscl * 24f);",
		"place_effect_expr": "payload.block().placeEffect.at(x, y, payload.size() / tilesize);",
		"x": x_value,
		"y": y_value,
		"rotdeg": rotdeg_value,
		"has_recipe": has_recipe,
		"payload_present": payload_present,
		"just_crafted": just_crafted,
		"progress": progress,
		"progress_ratio": progress_ratio,
		"time_value": time_value,
		"heat": heat,
		"size": size_value,
		"recipe_size": recipe_size,
		"shadow_radius": shadow_radius,
		"scan_magnitude": scan_magnitude,
		"scan_length": scan_length,
		"scan_x": scan_x,
		"select_dx": select_dx,
		"select_dy": select_dy,
		"select_width": select_width,
		"select_height": select_height,
		"base_call": base_call,
		"out_call": out_call,
		"shadow_call": shadow_call,
		"build_call": build_call,
		"scan_call": scan_call,
		"payload_call": payload_call,
		"top_call": top_call,
		"select_call": select_call,
		"place_effect_call": place_effect_call,
	}

static func source_constructor_can_produce_state(block: Dictionary, min_block_size: int, max_block_size: int, filter: Array) -> Dictionary:
	# The canProduce gate (Constructor.canProduce(), Constructor.java:54-56), the pure producibility verdict -- Java, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public boolean canProduce(Block b){`
	# `return b.isVisible() && b.size >= minBlockSize && b.size <= maxBlockSize && !(b instanceof CoreBlock) && !state.rules.isBanned(b) && b.environmentBuildable() && (filter.isEmpty() || filter.contains(b));`
	# `public Seq<Block> filter = new Seq<>();`
	# `public int minBlockSize = 1, maxBlockSize = 2;`
	# `public void getPlanConfigs(Seq<UnlockableContent> options){`
	# `options.add(content.blocks().select(this::canProduce));`
	# `public class Constructor extends BlockProducer{`
	# `public class ConstructorBuild extends BlockProducerBuild{`
	# The block is a caller-supplied Dict {name, is_visible, size, is_core_block, is_banned, environment_buildable} (all predicates caller-supplied -- the N2435 precedent; the pure never reads content/rules) and the filter is an Array of block names (empty = no filter, `public Seq<Block> filter = new Seq<>();`, Constructor.java:21). All 7 Java conditions, in Java order: visible, size >= min, size <= max, not a core block, not banned, environment-buildable, and (filter empty OR filter contains the block). getPlanConfigs (:50-52) selects content.blocks() by this same predicate, so the pure IS the plan-options gate. Defs (verified first): constructor keeps the class min/max 1/2 and sets the 7-entry filter (Blocks.java:6666); large-constructor keeps the empty filter and overrides min 3 / max 4 (Blocks.java:6676-6677). Pure-only: the tick never calls canProduce -- the configure UI / plan code call it, and the call sites wait for their own slices.
	var block_name: String = str(block.get("name", ""))
	var can_produce: bool = bool(block.get("is_visible", false)) and int(block.get("size", 0)) >= min_block_size and int(block.get("size", 0)) <= max_block_size and not bool(block.get("is_core_block", false)) and not bool(block.get("is_banned", false)) and bool(block.get("environment_buildable", false)) and (filter.is_empty() or filter.has(block_name))
	return {
		"can_produce_expr": "return b.isVisible() && b.size >= minBlockSize && b.size <= maxBlockSize && !(b instanceof CoreBlock) && !state.rules.isBanned(b) && b.environmentBuildable() && (filter.isEmpty() || filter.contains(b));",
		"block": block,
		"min_block_size": min_block_size,
		"max_block_size": max_block_size,
		"filter": filter,
		"can_produce": can_produce,
	}

static func source_constructor_config_state(action: String, block: Variant, current_recipe: Variant, can_produce: bool) -> Dictionary:
	# The config rows (Constructor config(Block), Constructor.java:32-37; configClear, :31/:38; buildConfiguration, :66-70; config(), :73-75), the pure config fold -- Java, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `configClear((ConstructorBuild tile) -> tile.recipe = null);`
	# `config(Block.class, (ConstructorBuild tile, Block block) -> {`
	# `if(tile.recipe != block) tile.progress = 0f;`
	# `if(canProduce(block)){`
	# `tile.recipe = block;`
	# `public @Nullable Block recipe;`
	# `public void buildConfiguration(Table table){`
	# `ItemSelection.buildTable(Constructor.this, table, filter.isEmpty() ? content.blocks().select(Constructor.this::canProduce) : filter, () -> recipe, this::configure, selectionRows, selectionColumns);`
	# `public Object config(){`
	# `return recipe;`
	# `configurable = true;`
	# `clearOnDoubleTap = true;`
	# The action is a discriminated input (the N2449 precedent): "set" applies the config(Block) handler, "clear" applies configClear, "none" leaves the recipe untouched (the pure returns the current_recipe input). The reset runs BEFORE the canProduce gate (:33 before :34) -- verified first, so a non-producible block still resets progress while the recipe stays put; a set of the SAME block (recipe == block -- Java reference equality over content-singleton blocks, so Dict value-equality stands in here) resets nothing. configClear sets recipe = null with NO progress reset (:31/:38, registered twice in Java, same lambda). can_produce is caller-supplied (the output of source_constructor_can_produce_state). buildConfiguration is recorded as a CALL {method: "ItemSelection.buildTable", current_recipe} -- the supplier `() -> recipe` reads the pre-action recipe and `this::configure` is the callback the UI would invoke; the picker options (filter empty ? content.blocks().select(canProduce) : filter) are the can-produce pure's domain, not this fold's; the UI itself is NOT ported (the N2449 CALL precedent). config() returns recipe (Constructor.java:73-75), so the pure's recipe IS the post-action config() value. The block is `configurable = true;` + `clearOnDoubleTap = true;` (Constructor.java:27-28). Wired live since N2462: the tick calls config from frame["recipe_config"] before the consumption fold (the input handler stamps the pending action); buildConfiguration stays pure-only -- it runs from the configure UI and waits for its own slice.
	var new_recipe: Variant = current_recipe
	var progress_reset: bool = false
	if action == "set":
		if block != current_recipe:
			progress_reset = true
		if can_produce:
			new_recipe = block
	elif action == "clear":
		new_recipe = null
	var configure_call: Dictionary = {"method": "ItemSelection.buildTable", "current_recipe": current_recipe}
	return {
		"config_expr": "config(Block.class, (ConstructorBuild tile, Block block) -> {",
		"config_clear_expr": "configClear((ConstructorBuild tile) -> tile.recipe = null);",
		"build_configuration_expr": "ItemSelection.buildTable(Constructor.this, table, filter.isEmpty() ? content.blocks().select(Constructor.this::canProduce) : filter, () -> recipe, this::configure, selectionRows, selectionColumns);",
		"config_getter_expr": "return recipe;",
		"action": action,
		"block": block,
		"current_recipe": current_recipe,
		"can_produce": can_produce,
		"recipe": new_recipe,
		"progress_reset": progress_reset,
		"configure_call": configure_call,
	}

static func source_constructor_stats_state(min_block_size: int, max_block_size: int, build_speed: float) -> Dictionary:
	# The stats rows (Constructor.setStats(), Constructor.java:41-47), the pure stats dict -- Java, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public void setStats(){`
	# `super.setStats();`
	# `stats.add(Stat.output, "@x@ ~ @x@", minBlockSize, minBlockSize, maxBlockSize, maxBlockSize);`
	# `stats.addPercent(Stat.buildSpeed, buildSpeed);`
	# `output = new Stat("output", StatCat.crafting),`
	# `buildSpeed = new Stat("buildSpeed"),`
	# `public float buildSpeed = 0.4f;`
	# `buildSpeed = 0.6f;`
	# `buildSpeed = 0.75f;`
	# `maxBlockSize = 4;`
	# `minBlockSize = 3;`
	# `filter = Seq.with(Blocks.tungstenWallLarge, Blocks.berylliumWallLarge, Blocks.carbideWallLarge, Blocks.reinforcedSurgeWallLarge, Blocks.reinforcedLiquidContainer, Blocks.reinforcedContainer, Blocks.beamNode);`
	# `public void addPercent(Stat stat, float value){`
	# `add(stat, StatValues.number((int)(value * 100), StatUnit.percent));`
	# The tokens are exact: output (Stat.java:68) and buildSpeed (Stat.java:30). The output row carries the format "@x@ ~ @x@" with [min, min, max, max] -- the two min/max pairs are the size range the stat displays. The buildSpeed value is the RAW buildSpeed -- addPercent formats at display time only (`public void addPercent(Stat stat, float value){` / `add(stat, StatValues.number((int)(value * 100), StatUnit.percent));`, Stats.java:37-38), so the constructor def 0.6f (`buildSpeed = 0.6f;`, Blocks.java:6662) displays as 60% and the large-constructor def 0.75f (`buildSpeed = 0.75f;`, Blocks.java:6675) as 75% (the N2451 precedent: percent formatting is a UI concern); the class default is 0.4f (`public float buildSpeed = 0.4f;`, BlockProducer.java:22). The size bounds are caller-supplied (constructor 1/2 class defaults, large-constructor 3/4, Blocks.java:6676-6677); the constructor filter (Blocks.java:6666) is the can-produce pure's domain, quoted here only because setStats shares the def. Pure-only: the tick never calls setStats -- setStats is called by the stats UI, and the call site waits for a stats-UI slice.
	var output_stat: Dictionary = {"key": "output", "format": "@x@ ~ @x@", "values": [min_block_size, min_block_size, max_block_size, max_block_size]}
	var build_speed_stat: Dictionary = {"key": "buildSpeed", "value": build_speed}
	return {
		"set_stats_expr": "stats.add(Stat.output, \"@x@ ~ @x@\", minBlockSize, minBlockSize, maxBlockSize, maxBlockSize);",
		"build_speed_expr": "stats.addPercent(Stat.buildSpeed, buildSpeed);",
		"min_block_size": min_block_size,
		"max_block_size": max_block_size,
		"build_speed": build_speed,
		"output_stat": output_stat,
		"build_speed_stat": build_speed_stat,
	}
