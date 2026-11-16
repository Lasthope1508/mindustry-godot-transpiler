extends RefCounted
class_name SourceRegenProjectorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")

# The RegenProjector implementation (RegenProjector.java:29, `public class
# RegenProjector extends Block{`): regen-projector (consumePower 1f,
# size 3, range 28, Blocks.java:2009). It hasPower=true
# (RegenProjector.java:45, `hasPower = true;`), hasItems=true,
# suppressable=true, update=true, solid=true. RegenProjector
# extends Block, NOT a drill or factory, so it cannot reuse an
# existing frame key; this driver uses its own family frame key
# ("source_regen_projector_building", the mechanical-pump /
# beam-drill / mend-projector / overdrive-projector /
# force-projector / base-shield precedent), and this slice adds the
# regen-projector key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it. The port has NO SourceRegenProjector* files at all
# yet -- no display/runtime state to lean on -- so the missing
# piece is the live power.status -> efficiency driver, which is
# exactly this slice: the heal gate
# (RegenProjector.java:142, `if(efficiency > 0){`) follows the
# folded efficiency, with the heal amount
# (RegenProjector.java:148, `float healAmount = Mathf.lerp(1f, optionalMultiplier, optionalEfficiency) * healPercent;`) and the regen-projector healPercent
# (Blocks.java:2018, `healPercent = 4f / 60f;`).
const SOURCE_REGEN_PROJECTOR_BUILD_IMPLEMENTATIONS := ["RegenProjector"]
const SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY := "source_regen_projector_building"
# N2228 def constants (single def -- regen-projector; the catalog
# carries no healPercent, so the def values live here): the warmup
# approach speed 1f/70f (RegenProjector.java:129), the def
# healPercent 4f/60f (Blocks.java:2019, overriding the class
# `public float healPercent = 12f / 60f;`, RegenProjector.java:28),
# the optional multiplier 2f and the optional use time 60f * 8f =
# 480f (RegenProjector.java:29-30, class values, no def override).
const SOURCE_REGEN_PROJECTOR_WARMUP_SPEED := 1.0 / 70.0
const SOURCE_REGEN_PROJECTOR_HEAL_PERCENT := 4.0 / 60.0
const SOURCE_REGEN_PROJECTOR_OPTIONAL_MULTIPLIER := 2.0
const SOURCE_REGEN_PROJECTOR_OPTIONAL_USE_TIME := 480.0
# N2260 def constants (single def -- regen-projector): the
# required liquid consumer (Blocks.java:2016,
# `consumeLiquid(Liquids.hydrogen, 1f / 60f);`) and the booster
# item consumer (Blocks.java:2017,
# `consumeItem(Items.phaseFabric).boost();`, one phaseFabric per
# consume() trigger, Block.java:1167-1168). The def sets no
# multiplier, so the Consume.java:18 default (`public
# Floatf<Building> multiplier = b -> 1f;`) applies to both rows.
const SOURCE_REGEN_PROJECTOR_LIQUID := "hydrogen"
const SOURCE_REGEN_PROJECTOR_LIQUID_AMOUNT := 1.0 / 60.0
const SOURCE_REGEN_PROJECTOR_BOOSTER_ITEM := "phase-fabric"
const SOURCE_REGEN_PROJECTOR_BOOSTER_AMOUNT := 1
# N2277 def constant (single def -- regen-projector): the
# updateTargets range 28 (Blocks.java:2012, `range = 28;`, the def
# override of the class `public int range = 14;`,
# RegenProjector.java:26). The scan rect is range * tilesize on a
# side (RegenProjector.java:118), tilesize 8 (Vars.java:135).
const SOURCE_REGEN_PROJECTOR_RANGE := 28
# N2344 def constant: the four privileged block ids (the
# world-processor-only logic blocks, each with
# `privileged = true;`, Blocks.java:6955/6965/6974/6981,
# against the `public boolean privileged = false;` default,
# Block.java:148). The catalog carries no privileged flag,
# so the tick fill reads this list through the pure below
# instead of the catalog.
const SOURCE_REGEN_PROJECTOR_PRIVILEGED_BLOCK_IDS := ["world-processor", "world-cell", "world-message", "world-switch"]

static func _is_regen_projector_build_implementation(implementation: String) -> bool:
	return SOURCE_REGEN_PROJECTOR_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_regen_projector_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The regen-projector tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (RegenProjector.java:29, `public class RegenProjector extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# regen projector skips consumption like Java's updateConsumption
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
	# for this regen projector (N2125); the tick preserves a disabled
	# regen projector instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# The fresh frame binds the Java build-field defaults:
	# `public Seq<Building> targets = new Seq<>();`
	# (RegenProjector.java:109), `public int lastChange = -2;`
	# (RegenProjector.java:110), `public float warmup, totalTime, optionalTimer;`
	# (RegenProjector.java:111, all 0f), `public boolean anyTargets = false;`
	# (RegenProjector.java:112) and `public boolean didRegen = false;`
	# (RegenProjector.java:113); mendMap starts empty (the Java map
	# is static-shared, RegenProjector.java:23, but the port tracks
	# a per-building map -- see the advance). The frame inputs
	# (heal_suppressed, tile_changes) are NOT bound here: the advance
	# reads them with frame.get defaults (false / 1), the N2223
	# efficiency_factor precedent. The liquids + items stores ARE
	# bound here (N2260, the Fracker / Separator precedent): the
	# Building.liquids LiquidModule (frame["liquids"], synced from
	# the sprite meta store each tick before the fold) and the
	# Building.items ItemModule (frame["items"], Dictionary keyed by
	# item name, the factory precedent
	# SourceFactoryBuildState.gd:89-101) -- no live intake fills
	# frame["items"] yet, so the item row reads the frame as-is.
	return {
		"any_targets": false,
		"warmup": 0.0,
		"total_time": 0.0,
		"optional_timer": 0.0,
		"did_regen": false,
		"targets": [],
		"mend_map": {},
		"last_change": -2,
		"liquids": {},
		"items": {},
	}

static func source_regen_projector_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the regen-projector frame meta key
	# ("source_regen_projector_building"). A RegenProjector sprite gets a
	# frame bound with the any_targets key defaulting to false (the Java
	# field `public boolean anyTargets = false;`, RegenProjector.java:112)
	# plus the updateTile state keys (warmup / total_time /
	# optional_timer / did_regen / targets / mend_map / last_change,
	# the Java build-field defaults, RegenProjector.java:109-113 --
	# N2228); the live-loop tick fills its other keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_regen_projector_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_regen_projector_should_consume_state(frame: Dictionary) -> Dictionary:
	# RegenProjectorBuild overrides shouldConsume (RegenProjector.java:181, `public boolean shouldConsume(){` with `return anyTargets;`, RegenProjector.java:182): the gate reads ONLY the anyTargets flag -- the projector consumes while a damaged building is in range and stops consuming once nothing in range is damaged. The field is `public boolean anyTargets = false;` (RegenProjector.java:112) on RegenProjectorBuild (`public class RegenProjectorBuild extends Building{`, RegenProjector.java:108); RegenProjector extends Block (RegenProjector.java:20, `public class RegenProjector extends Block{`), so the default (`return enabled;`, BuildingComp.java:755) does NOT apply here. Unlike the Separator/Drill gates this one has NO `&& enabled` -- Java returns the bare flag, so the pure gate does NOT read frame["enabled"] at all (the driver already runs the machinery only when enabled). The frame carries the flag (frame["any_targets"], default false for a frame bound before this slice -- the Java field defaults to false); the targets list is filled live (N2277) -- the targets computation (indexer range query, RegenProjector.java:115-119, + contains damaged, RegenProjector.java:139) is the updateTile advance (RegenProjector.java:122-179): the contains-damaged fold is live (N2228) over the frame targets input and the indexer query is live (N2277, the scan runs before the advance every tick). The gate reads anyTargets only, never the targets list itself, so this slice adds NO `targets` frame key. When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The heal gate (RegenProjector.java:141, `if(efficiency > 0){`) and the heal amount (RegenProjector.java:147, `float healAmount = Mathf.lerp(1f, optionalMultiplier, optionalEfficiency) * healPercent;`) follow the folded efficiency; the def consumes power 1f (`consumePower(1f);`, Blocks.java:2015) plus liquid hydrogen 1f/60f (`consumeLiquid(Liquids.hydrogen, 1f / 60f);`, Blocks.java:2016) -- the liquid row is live (N2260), folded into the first-pass min alongside power, and the phaseFabric booster row (`consumeItem(Items.phaseFabric).boost();`, Blocks.java:2017) is live too, folded into the optional pass. N2214 cites the gate at 181-183 (verified by grep: exactly one shouldConsume in the file).
	var any_targets: bool = bool(frame.get("any_targets", false))
	return {"should_consume": any_targets, "any_targets": any_targets}

static func source_regen_projector_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40,
	# `return build.power.status;`): the power consumer's
	# efficiency is the building's live power.status, and the
	# first pass folds it into the min efficiency
	# (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`).
	# The graph update stamps
	# frame["power_status"] each tick (N2142); a missing stamp
	# folds to 1.0 before the first graph update, the assembler
	# fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`).
	# A block with no power consumer contributes no row. The
	# power consumer counts toward hasConsumers
	# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
	# so a regen projector does not take the early return. The
	# heal gate follows the folded efficiency
	# (RegenProjector.java:142, `if(efficiency > 0){`), with the heal amount
	# (RegenProjector.java:148, `float healAmount = Mathf.lerp(1f, optionalMultiplier, optionalEfficiency) * healPercent;`) and the regen-projector healPercent
	# (Blocks.java:2018, `healPercent = 4f / 60f;`) and the shouldConsume default
	# (BuildingComp.java:755, `public boolean shouldConsume(){`) and the anyTargets override
	# (RegenProjector.java:182, `return anyTargets;`) -- the shouldConsume gate is live
	# (N2214): the pure gate (source_regen_projector_should_consume_state) feeds
	# should_consume to the machinery from the frame any_targets key (false with no
	# damaged building in range, true while one is in range); the updateTile
	# advance (N2228) recomputes frame["any_targets"] every tick from the frame
	# targets input (the contains-damaged fold, RegenProjector.java:139), while
	# the updateTargets live fill (N2277) rebuilds the targets list itself
	# from the placed buildings whenever tile_changes moves (the indexer
	# range query, RegenProjector.java:115-119).
	# Documented limits: (1) power + liquid first pass, item
	# booster optional pass -- the regen-projector's power consumer
	# (1f, Blocks.java:2015), its required liquid consumer (hydrogen
	# 1f/60f, Blocks.java:2016) and its optional item booster
	# (phaseFabric, Blocks.java:2017) are all live (N2260): the
	# hydrogen row folds into the first-pass min alongside power
	# (ConsumeLiquid.efficiency, ConsumeLiquid.java:42-47, with the
	# second-pass removal, ConsumeLiquid.java:37-39) and the
	# phaseFabric row folds into the optional pass
	# (ConsumeItems.efficiency, ConsumeItems.java:51-53, binary 1/0),
	# capped by the min efficiency (BuildingComp.java:1986). No live
	# intake fills frame["items"] yet (the Separator precedent), so
	# the item row reads the frame as-is and a live projector with
	# no fill folds the booster row 0.0.
	# (2) shouldConsume gate live (N2214) -- RegenProjectorBuild overrides
	# shouldConsume() to return anyTargets (RegenProjector.java:181-183); the
	# pure gate reads the frame any_targets key (default false) and feeds
	# should_consume to the machinery; the updateTile advance (N2228)
	# recomputes frame["any_targets"] every tick from the frame targets input
	# (the contains-damaged fold, RegenProjector.java:139), over the targets
	# list the updateTargets live fill (N2277) rebuilds from the placed
	# buildings whenever tile_changes moves (the indexer range query over
	# buildings in range 28, RegenProjector.java:115-119).
	# (3) Suppression gate -- checkSuppression() (RegenProjector.java:135;
	# suppressable=true, RegenProjector.java:49) is modeled as the frame input
	# `heal_suppressed` (default false, N2228): the advance returns early on a
	# suppressed tick, after the warmup/totalTime advance and the
	# didRegen/anyTargets reset, exactly like Java; the LIVE suppression fill
	# (isHealSuppressed, BuildingComp.java:487-489) still waits for its own
	# slice. (4) updateTile advance live (N2228) -- warmup / totalTime /
	# optionalTimer / didRegen / anyTargets / mendMap accumulation
	# (RegenProjector.java:122-179) advance on the frame; the
	# optionalTimer consume() item removal is wired by the tick
	# (N2260, 1 phaseFabric when the advance reports consumed) and
	# updateTargets live (N2277) -- the scan rebuilds the targets
	# list before the advance whenever tile_changes moves; the
	# hitbox-overlap + privileged refinement is live since N2338
	# (the narrow pure chains after the scan and the tick passes
	# the narrowed list into the frame targets) and the live
	# privileged flag fill is live since N2344 (the tick stamps
	# the pure result on every candidate by block id); the
	# mendMap flush is live (N2325) as the pure heal_applications
	# result (last_update_frame / update_id frame inputs, defaults
	# -1/0; the tick write-backs the flushed amounts on the frame
	# and the live heal application is live (N2399) -- the tick
	# applies the flushed amounts to the target sprite health
	# after the flush, capped at maxHealth, while
	# recentlyHealed() still waits (no Time.time input reaches
	# the tick); the effect chance, the live tileChanges
	# counter, the live updateId counter and the disabled early
	# return wait for their own slices (see the N2228 live-fill
	# deferral, rewritten by N2325 and N2399).
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_regen_projector_liquid_consumer_row_state(frame: Dictionary, has_liquid_consumer: bool, liquid_id: int, amount: float, source_delta: float, time_scale: float, efficiency_scale: float, multiplier: float = 1.0) -> Dictionary:
	# ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47): `float ed = build.edelta() * build.efficiencyScale();` (ConsumeLiquid.java:43), `if(ed <= 0.00000001f) return 0f;` (ConsumeLiquid.java:44), `return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);` (ConsumeLiquid.java:46) -- the required liquid row folds into the first-pass min exactly like the power row (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`), and a starved row stops the power draw (`if(cons != block.consPower && result <= 0.0000001f){`, BuildingComp.java:1972, with `shouldConsumePower = false;`, BuildingComp.java:1973 -- the shared fold does that, SourceBuildingEfficiencyState.gd:109-117). In the first pass efficiency is assumed 1f (BuildingComp.java:1964-1965, `efficiency = optionalEfficiency = 1f;`), so edelta() = delta() = Time.delta * timeScale (BuildingComp.java:1922-1929, `return efficiency * delta();` / `return Time.delta * timeScale;`), i.e. ed = source_delta * time_scale * efficiency_scale here; efficiencyScale() defaults to 1f (BuildingComp.java:1939-1941, `public float efficiencyScale(){` with `return 1f;`). The amount comes from the shared liquid module helper (SourceLiquidModuleState.source_get_state, reused through a preload, NOT re-implemented) over the frame liquids key (the Building.liquids LiquidModule dict, default {} for a frame bound before this slice, amount 0.0 when the store has no entry for the liquid -- Java's liquids.get returns 0.0 for a liquid never added), with the Fracker guard (SourceFrackerBuildState.gd:221: `liquids.has("liquids")` + bounds check). The single def consumes hydrogen 1f/60f, `consumeLiquid(Liquids.hydrogen, 1f / 60f);` (Blocks.java:2016); the def sets no multiplier, so the default `public Floatf<Building> multiplier = b -> 1f;` (Consume.java:18) applies. The second pass removes the consumed hydrogen (ConsumeLiquid.update, ConsumeLiquid.java:37-39, `build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));`, only when `if(update && efficiency > 0){`, BuildingComp.java:1999) -- the tick does that after the fold, with edelta from the folded efficiency. A def with no liquid consumer contributes no row (the has_power_row pattern).
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

static func source_regen_projector_item_consumer_row_state(frame: Dictionary, stacks: Array, consume_trigger_valid: bool, multiplier: float = 1.0) -> Dictionary:
	# ConsumeItems.efficiency (ConsumeItems.java:51-53): `return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;` -- BINARY 1.0/0.0, not a ratio like ConsumeLiquid. `consumeTriggerValid()` returns false at the base (BuildingComp.java:764-766, `public boolean consumeTriggerValid(){` with `return false;`); no RegenProjector override exists, so the tick passes the canonical SourceBuildingAccessState.consume_trigger_valid_state() (false) and the row turns on the held stacks alone. `items.has(ItemStack[], float)` (ItemModule.java:153-156) requires EVERY stack to be held at `Math.round(stack.amount * multiplier)` (`if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;`, ItemModule.java:155; `has(item, amount)` is `get(item) >= amount`, ItemModule.java:126-128, `return get(item) >= amount;`). The count comes from the shared drill inventory helper (SourceDrillInventoryRuntimeState.item_count, reused through the inventory preload, NOT re-implemented) over the frame items key (the Building.items ItemModule, Dictionary keyed by item name, the factory precedent SourceFactoryBuildState.gd:89-101; default {} for a frame bound before this slice, count 0 for an item never held). The booster is `optional(true, true)` (`return optional(true, true);`, Consume.java:33-35, the boost() method), so the row folds into the OPTIONAL pass (`for(var cons : block.optionalConsumers){`, BuildingComp.java:1980, with `optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));`, BuildingComp.java:1981), capped by the min efficiency (`optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);`, BuildingComp.java:1986) -- a missing booster zeroes optionalEfficiency but never touches the min efficiency or shouldConsumePower. The single def consumes one phaseFabric, `consumeItem(Items.phaseFabric).boost();` (Blocks.java:2017; `consumeItem(item)` is ItemStack(item, 1), Block.java:1167-1168); the def sets no multiplier, so the default `public Floatf<Building> multiplier = b -> 1f;` (Consume.java:18) applies. ConsumeItems has NO update override, so the second pass (`if(update && efficiency > 0){`, BuildingComp.java:1999, with `cons.update(self());`, BuildingComp.java:2001) never consumes items -- the removal happens only through consume() (`for(Consume cons : block.consumers){`, BuildingComp.java:1912, with `cons.trigger(self());`, BuildingComp.java:1913), when the N2228 advance reports consumed: ConsumeItems.trigger removes `build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));` (ConsumeItems.java:44-48), clamped to what the module holds (`amount = Math.min(amount, items[item.id]);`, ItemModule.java:258-263) -- the tick wires that removal after the advance. No live intake fills frame["items"] yet (the Separator precedent), so the row reads the frame as-is. A def with no item consumer passes empty stacks and contributes no row (the has_power_row pattern).
	if stacks.is_empty():
		return {"has_item_row": false, "row": {}}
	var items: Dictionary = frame.get("items", {})
	var has_all: bool = true
	for stack in stacks:
		var stack_dict: Dictionary = stack
		var needed: int = int(roundi(float(stack_dict.get("amount", 0)) * multiplier))
		if inventory.item_count(items, str(stack_dict.get("item", ""))) < needed:
			has_all = false
			break
	var result: float = 1.0 if (consume_trigger_valid or has_all) else 0.0
	return {"has_item_row": true, "row": {"result": result, "is_power": false}}

static func source_regen_projector_update_targets_state(frame: Dictionary, building_x: float, building_y: float, candidates: Array) -> Dictionary:
	# The updateTargets scan (RegenProjectorBuild.updateTargets(),
	# RegenProjector.java:115-119), the pure targets rebuild -- the
	# build fields are `public Seq<Building> targets = new Seq<>();`
	# (RegenProjector.java:109) and `public int lastChange = -2;`
	# (RegenProjector.java:110), and the scan follows the Java
	# lines in order (each exact expr on ONE comment line, the
	# N2148 lesson):
	# `public void updateTargets(){`
	# `targets.clear();`
	# `taken.clear();`
	# `indexer.eachBlock(team, Tmp.r1.setCentered(x, y, range * tilesize), b -> true, targets::add);`
	# `public void updateTile(){`
	# `if(lastChange != world.tileChanges){`
	# `lastChange = world.tileChanges;`
	# `updateTargets();`
	# `public class RegenProjector extends Block{`
	# `public class RegenProjectorBuild extends Building{`
	# `public int range = 14;`
	# `range = 28;`
	# `public int tileChanges = 1, floorChanges = 1;`
	# `return health < maxHealth - 0.001f;`
	# `return Point2.pack(x, y);`
	# `return block().offset + worldx();`
	# `return block().offset + worldy();`
	# `offset = ((size + 1) % 2) * tilesize / 2f;`
	# `public static final int tilesize = 8;`
	# `public boolean eachBlock(Team team, Rect rect, Boolf<Building> pred, Cons<Building> cons){`
	# `buildings.intersect(rect, b -> {`
	# `if(pred.get(b) && !b.block.privileged){`
	# `anyTargets = targets.contains(b -> b.damaged());`
	# The trigger lives in updateTile (RegenProjector.java:122-125):
	# only when tile_changes differs from last_change does the scan
	# rebuild; otherwise targets stay untouched and refreshed is
	# false. The rect is a SQUARE: setCentered(x, y, range *
	# tilesize) is Rect.set(x - size/2, y - size/2, size, size)
	# (arc Rect.java:49-51), so the scan tests the building center
	# against |dx| <= half-side and |dy| <= half-side (half-side
	# 112.0: range 28, Blocks.java:2012, the def override of the
	# class `public int range = 14;`, RegenProjector.java:26,
	# times tilesize 8, Vars.java:135, halved) -- never dst2, so a
	# corner building at (112, 112) from the projector is IN the
	# square and out of any circle. The candidates arrive from the
	# driver (each: pos, team_id, x, y, block_health, health,
	# heal_suppressed); the pos is the packed origin cell
	# (Tile.pos(), Tile.java:73-75) and x/y are the drawx/drawy
	# center (Tile.java:176/180). damaged() is computed here,
	# `return health < maxHealth - 0.001f;` (HealthComp.java:47-49),
	# so the scan and the advance agree on what counts as damaged.
	# Scoping decisions, all source-backed: (1) taken is NOT
	# ported -- it is declared at RegenProjector.java:21 and only
	# ever cleared at :117, never read at this pin, so clearing it
	# loses no behavior. (2) live world.tileChanges does NOT exist
	# in the port (only RegenProjector and UnitAssemblerModule read
	# a tile_changes frame input; PortGame/SourceWorld* carry no
	# live counter), so the driver reads the frame input
	# tile_changes as-is (default 1, World.java:35) and the live
	# counter waits for a game-state slice. (3) the Java query is
	# a quadtree hitbox intersect (BlockIndexer.java:364-380) with
	# a privileged exclusion (:372); the port tests building
	# centers against the rect and the live privileged flag
	# fill is live since N2344 (the tick stamps the
	# source_regen_projector_privileged_state result on
	# every candidate by block id -- the only privileged
	# defs are the world-processor-only logic blocks,
	# Blocks.java:6955/6965/6974/6981) -- the hitbox-overlap
	# refinement is live since N2338
	# (source_regen_projector_update_targets_narrow_state,
	# chained after this scan). (4) the projector itself
	# counts when its center falls in its own rect (Java includes
	# every same-team building, predicate `b -> true`). (5) the
	# function does NOT mutate its input frame: a refresh builds a
	# fresh targets array, and a non-refresh returns the frame
	# targets as-is. The rebuilt entries match the exact format
	# the N2228 advance reads (pos, block_health, health,
	# damaged, heal_suppressed), and the advance then folds
	# anyTargets over them (RegenProjector.java:139).
	var tile_changes: int = int(frame.get("tile_changes", 1))
	var last_change: int = int(frame.get("last_change", -2))
	var team_id: int = int(frame.get("team_id", source_block_geometry.SOURCE_TEAM_DERELICT_ID))
	if tile_changes == last_change:
		return {"targets": frame.get("targets", []), "last_change": last_change, "refreshed": false}
	var half_side: float = float(SOURCE_REGEN_PROJECTOR_RANGE) * source_world_defaults.TILESIZE / 2.0
	var targets: Array = []
	for candidate in candidates:
		if int(candidate.get("team_id", source_block_geometry.SOURCE_TEAM_DERELICT_ID)) != team_id:
			continue
		var dx: float = absf(float(candidate.get("x", 0.0)) - building_x)
		var dy: float = absf(float(candidate.get("y", 0.0)) - building_y)
		if dx > half_side or dy > half_side:
			continue
		var block_health: float = float(candidate.get("block_health", 0.0))
		var health: float = float(candidate.get("health", 0.0))
		targets.append({"pos": int(candidate.get("pos", 0)), "block_health": block_health, "health": health, "damaged": health < block_health - 0.001, "heal_suppressed": bool(candidate.get("heal_suppressed", false))})
	return {"targets": targets, "last_change": tile_changes, "refreshed": true}

static func source_regen_projector_privileged_state(block_id: String) -> Dictionary:
	# The live privileged flag (BlockIndexer.eachBlock,
	# BlockIndexer.java:364-380): Java's eachBlock excludes
	# privileged blocks from the updateTargets query (each
	# exact expr on ONE comment line, the N2148 lesson):
	# `indexer.eachBlock(team, Tmp.r1.setCentered(x, y, range * tilesize), b -> true, targets::add);`
	# `if(pred.get(b) && !b.block.privileged){`
	# `public boolean privileged = false;`
	# `privileged = true;`
	# `worldProcessor = new LogicBlock("world-processor"){{`
	# `worldCell = new MemoryBlock("world-cell"){{`
	# `worldMessage = new MessageBlock("world-message"){{`
	# `worldSwitch = new SwitchBlock("world-switch"){{`
	# privileged defaults false (Block.java:148) and exactly
	# four defs set it (Blocks.java:6955/6965/6974/6981):
	# the world-processor-only logic blocks (verified by
	# grep: exactly four `privileged = true;` lines in
	# Blocks.java). The catalog carries no privileged flag,
	# so the pure reads the block id against the four def
	# ids above; an empty or unknown id is NOT privileged
	# (the false default). The tick stamps the result on
	# every live candidate (the N2338 narrow then drops the
	# privileged ones); the N2277 rect pure and the N2338
	# narrow pure are untouched (their candidates are frame
	# inputs, not tick-filled).
	return {"privileged": SOURCE_REGEN_PROJECTOR_PRIVILEGED_BLOCK_IDS.has(block_id)}

static func source_regen_projector_update_targets_narrow_state(targets: Array, candidates: Array, team_id: int, building_x: float, building_y: float) -> Dictionary:
	# The updateTargets hitbox + privileged refinement
	# (BlockIndexer.eachBlock, BlockIndexer.java:364-380),
	# the pure refinement chained AFTER the N2277 rect scan
	# (the N2335 pattern) -- the rect scan is only Java's
	# center approximation, while the real query intersects
	# the team buildingTree quadtree with the rect and
	# excludes privileged blocks (each exact expr on ONE
	# comment line, the N2148 lesson):
	# `indexer.eachBlock(team, Tmp.r1.setCentered(x, y, range * tilesize), b -> true, targets::add);`
	# `public boolean eachBlock(Team team, Rect rect, Boolf<Building> pred, Cons<Building> cons){`
	# `buildings.intersect(rect, b -> {`
	# `if(pred.get(b) && !b.block.privileged){`
	# `public boolean privileged = false;`
	# `return tile.block().size * tilesize;`
	# `out.setCentered(x, y, block.size * tilesize, block.size * tilesize);`
	# `public void intersect(Rect rect, Cons<T> out){`
	# `if(tmp.overlaps(x, y, width, height)){`
	# `return x < rx + rwidth && x + width > rx && y < ry + rheight && y + height > ry;`
	# `return health < maxHealth - 0.001f;`
	# `range = 28;`
	# `public static final int tilesize = 8;`
	# The QuadTree tests each building's HITBOX against the
	# rect (QuadTree.java:190-191, `hitbox(item);` then the
	# tmp.overlaps check), and Rect.overlaps is STRICT
	# (Rect.java:274-276): a hitbox edge exactly ON the rect
	# edge does NOT overlap, so the port excludes on dx >=
	# half_side + hit_half (the same strict boundary). The
	# hitbox is a square centered on the building center
	# with side block.size * tilesize
	# (BuildingComp.java:2292-2294; hitSize is
	# `tile.block().size * tilesize;`,
	# BuildingComp.java:2048). Privileged defaults false
	# (Block.java:148); the four privileged defs are the
	# world-processor-only logic blocks
	# (Blocks.java:6955/6965/6974/6981 -- the brief and the
	# N2277 docstring cite only three, missing world-switch
	# at :6981, verified by grep at this pin).
	# Scoping decisions, all source-backed: (1) the narrow
	# takes BOTH the N2277 rect output and the raw
	# candidates -- it cannot filter the rect output alone,
	# because the N2277 entries carry no x/y/hit_size/
	# privileged, so rect members are joined to the raw
	# candidates by pos. (2) Pass 1 keeps the rect members
	# UNTOUCHED except privileged ones: a member with no
	# matching candidate is kept (privileged defaults
	# false) and its hitbox overlap is never re-tested (its
	# center is in the rect, so its hitbox -- centered on
	# the center -- overlaps the rect for any positive
	# hitSize); the team is NOT re-checked for rect members
	# (the N2277 scan already filtered them). (3) Pass 2
	# admits same-team straddlers whose hitbox STRICTLY
	# overlaps the rect, rebuilt in the exact N2277 entry
	# format (pos, block_health, health, damaged with the
	# 0.001f epsilon, HealthComp.java:47-49,
	# heal_suppressed), in candidate order after the rect
	# members. (4) A missing hit_size defaults to 0.0 (the
	# N2335/N2226 precedent) -- the overlap test then falls
	# back to the center, STRICT; a missing privileged
	# defaults to false (Block.java:148); a missing x or y
	# excludes the candidate from admission (the N2335
	# precedent); a non-Dictionary candidate or target is
	# skipped the same way. (5) The pure does NOT mutate
	# its inputs: kept members are the target dicts
	# themselves, admitted straddlers are fresh dicts.
	var half_side: float = float(SOURCE_REGEN_PROJECTOR_RANGE) * source_world_defaults.TILESIZE / 2.0
	var candidate_by_pos: Dictionary = {}
	for candidate in candidates:
		if not (candidate is Dictionary):
			continue
		if candidate.has("pos"):
			var pos_key: int = int(candidate.get("pos", 0))
			if not candidate_by_pos.has(pos_key):
				candidate_by_pos[pos_key] = candidate
	var narrowed: Array = []
	var admitted_pos := {}
	for target in targets:
		if not (target is Dictionary):
			continue
		if target.has("pos"):
			var target_pos: int = int(target.get("pos", 0))
			var target_candidate: Variant = candidate_by_pos.get(target_pos, null)
			if target_candidate != null and bool(target_candidate.get("privileged", false)):
				continue
			admitted_pos[target_pos] = true
		narrowed.append(target)
	for candidate in candidates:
		if not (candidate is Dictionary):
			continue
		if not candidate.has("x") or not candidate.has("y"):
			continue
		if bool(candidate.get("privileged", false)):
			continue
		if int(candidate.get("team_id", source_block_geometry.SOURCE_TEAM_DERELICT_ID)) != team_id:
			continue
		var pos: int = int(candidate.get("pos", 0))
		if admitted_pos.has(pos):
			continue
		var hit_half: float = float(candidate.get("hit_size", 0.0)) / 2.0
		var dx: float = absf(float(candidate.get("x", 0.0)) - building_x)
		var dy: float = absf(float(candidate.get("y", 0.0)) - building_y)
		if dx >= half_side + hit_half or dy >= half_side + hit_half:
			continue
		var block_health: float = float(candidate.get("block_health", 0.0))
		var health: float = float(candidate.get("health", 0.0))
		narrowed.append({"pos": pos, "block_health": block_health, "health": health, "damaged": health < block_health - 0.001, "heal_suppressed": bool(candidate.get("heal_suppressed", false))})
		admitted_pos[pos] = true
	return {"targets": narrowed}

static func source_regen_projector_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float) -> Dictionary:
	# The updateTile advance (RegenProjectorBuild.updateTile(),
	# RegenProjector.java:122-179), the pure frame advance -- the
	# build fields are `public Seq<Building> targets = new Seq<>();`
	# (RegenProjector.java:109), `public int lastChange = -2;`
	# (RegenProjector.java:110), `public float warmup, totalTime, optionalTimer;`
	# (RegenProjector.java:111), `public boolean anyTargets = false;`
	# (RegenProjector.java:112) and `public boolean didRegen = false;`
	# (RegenProjector.java:113), and the advance follows the Java
	# lines in order (each exact expr on ONE comment line, the
	# N2148 lesson):
	# `if(lastChange != world.tileChanges){`
	# `lastChange = world.tileChanges;`
	# `warmup = Mathf.approachDelta(warmup, didRegen ? 1f : 0f, 1f / 70f);`
	# `totalTime += warmup * Time.delta;`
	# `didRegen = false;`
	# `anyTargets = false;`
	# `if(checkSuppression()){`
	# `anyTargets = targets.contains(b -> b.damaged());`
	# `if(efficiency > 0){`
	# `if((optionalTimer += edelta() * optionalEfficiency) >= optionalUseTime){`
	# `consume();`
	# `optionalTimer = 0f;`
	# `float healAmount = Mathf.lerp(1f, optionalMultiplier, optionalEfficiency) * healPercent;`
	# `for(var build : targets){`
	# `if(!build.damaged() || build.isHealSuppressed()) continue;`
	# `didRegen = true;`
	# `int pos = build.pos();`
	# `float value = mendMap.get(pos);`
	# `mendMap.put(pos, Math.min(Math.max(value, healAmount * edelta() * build.block.health / 100f), build.block.health - build.health));`
	# `if(value <= 0 && Mathf.chanceDelta(effectChance * build.block.size * build.block.size)){`
	# `if(lastUpdateFrame != state.updateId){`
	# `lastUpdateFrame = state.updateId;`
	# `for(var entry : mendMap.entries()){`
	# `var build = world.build(entry.key);`
	# `if(build != null){`
	# `build.heal(entry.value);`
	# `build.recentlyHealed();`
	# `mendMap.clear();`
	# The Arc formulas, not guesses: approachDelta(from, to,
	# speed) = approach(from, to, Time.delta * speed) with
	# approach = from + clamp(to - from, -speed, speed), lerp =
	# from + (to - from) * progress, num(b) = b ? 1 : 0
	# (Mathf.java:208, 415-427), via the shared
	# source_math_state.source_approach_delta helper.
	# source_delta is Time.delta in ticks (seconds * 60 through
	# game_source_delta, arc Time.java:26); edelta() =
	# efficiency * delta() with delta() = Time.delta *
	# timeScale (BuildingComp.java:1922-1929). NOTE the two
	# deltas: totalTime uses the UNSCALED Time.delta
	# (RegenProjector.java:130), while the optionalTimer and
	# the mend amounts use the SCALED edelta(). efficiency and
	# optionalEfficiency default 0.0, the Java field defaults
	# (BuildingComp.java:85 `transient float efficiency;` /
	# :87 `transient float optionalEfficiency;`); warmup /
	# totalTime / optionalTimer default 0.0, didRegen /
	# anyTargets default false, targets [] and mend_map {}
	# (RegenProjector.java:109-113). The def values are driver
	# constants (single def -- regen-projector; the catalog
	# carries no healPercent): `healPercent = 4f / 60f;`
	# (Blocks.java:2019, the def override of the class
	# `public float healPercent = 12f / 60f;`,
	# RegenProjector.java:28), `public float optionalMultiplier = 2f;`
	# and `public float optionalUseTime = 60f * 8f;`
	# (RegenProjector.java:29-30, class values, no def
	# override). Scoping decisions, all source-backed: (1)
	# the live updateTargets query
	# (RegenProjector.java:115-119, `targets.clear();` +
	# `indexer.eachBlock(team, Tmp.r1.setCentered(x, y, range * tilesize), b -> true, targets::add);`)
	# is live since N2277: the tick scans the placed buildings
	# before the advance whenever tile_changes moves and stamps
	# the rebuilt list on the frame (each entry: pos,
	# block_health, health, damaged, heal_suppressed); the
	# lastChange refresh IS modeled, with tile_changes as the
	# frame input (default 1,
	# `public int tileChanges = 1, floorChanges = 1;`,
	# World.java:35) against lastChange -2, so the first tick
	# refreshes. (2) heal_suppressed is a frame input (default
	# false, the N2215 precedent):
	# checkSuppression() reads isHealSuppressed(),
	# `public boolean isHealSuppressed(){` with
	# `return block.suppressable && Time.time <= healSuppressionTime;`
	# (BuildingComp.java:487-489) plus a particle chance
	# (BuildingComp.java:1336-1346); the early return keeps its
	# Java position AFTER the warmup/totalTime advance and the
	# didRegen/anyTargets reset, so a suppressed tick still
	# advances warmup/totalTime but heals nothing and reads
	# any_targets false. (3) consume() is reported, not applied,
	# by the advance: it triggers EVERY consumer
	# (BuildingComp.java:1911-1915) and ConsumeItems.trigger removes
	# phaseFabric (ConsumeItems.java:44-48); the optionalTimer
	# advance + reset IS modeled, and the tick where consume()
	# would fire is reported as the pure result `consumed`. The
	# tick wires the removal itself (N2260): when the advance
	# reports consumed, the tick removes 1 phaseFabric from the
	# frame items (clamped to what the frame holds,
	# ItemModule.remove, ItemModule.java:258-263) -- the advance
	# stays pure and does not touch items. (4) the
	# mendMap flush is live since N2325 as the pure
	# heal_applications result (RegenProjector.java:168-177):
	# `if(lastUpdateFrame != state.updateId){` with
	# `lastUpdateFrame = state.updateId;`,
	# `build.heal(entry.value);` and `mendMap.clear();` --
	# when the frame last_update_frame (default -1,
	# `private static long lastUpdateFrame = -1;`,
	# RegenProjector.java:24) differs from the frame update_id
	# (default 0, `public long updateId;`, GameState.java:23,
	# incremented once per logic update, `state.updateId ++;`,
	# Logic.java:512), the advance reports the whole mend_map
	# as heal_applications {pos: amount} and clears it. The
	# flush sits AFTER the heal branch and OUTSIDE the
	# efficiency gate, so it fires on a zero-efficiency tick
	# too -- but a suppressed tick returns before it (the
	# early return keeps the map and reports no applications).
	# The LIVE application of the amounts to the target
	# buildings (world.build(pos) + build.heal +
	# `public void recentlyHealed(){`, the timestamp write
	# `lastHealTime = Time.time;`, BuildingComp.java:491-493)
	# is live since N2399: the tick applies the flushed
	# amounts to the target sprite health after the flush
	# (capped at maxHealth, HealthComp.heal + clampHealth),
	# while recentlyHealed() still waits -- no Time.time
	# input reaches the tick, so no last_heal_time is
	# stamped.
	# `private static final IntFloatMap mendMap = new IntFloatMap();`
	# (RegenProjector.java:23) is static-shared across
	# projectors in Java, so the first projector ticked in a
	# frame flushes every projector's amounts; the port tracks
	# a per-building mend_map instead (documented deviation).
	# With no live updateId source the frame update_id stays
	# 0, so the flush fires once (on the first tick) and then
	# waits for a game-state slice that stamps the live
	# counter. The accumulation uses Math.max (no
	# stacking) capped by the missing health, so an unflushed
	# map converges instead of diverging. (5) the effect chance
	# defers (no RNG in the pure advance). heal_amount is 0.0
	# when the heal branch does not run (suppressed or
	# efficiency <= 0). The function does NOT mutate its input
	# frame: the mend_map is copied before accumulating, and
	# heal_applications is a copy of the flushed map.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var optional_efficiency: float = float(frame.get("optional_efficiency", 0.0))
	var targets: Array = frame.get("targets", [])
	var mend_map: Dictionary = Dictionary(frame.get("mend_map", {}))
	var heal_suppressed: bool = bool(frame.get("heal_suppressed", false))
	var tile_changes: int = int(frame.get("tile_changes", 1))
	var last_change: int = int(frame.get("last_change", -2))
	var last_update_frame: int = int(frame.get("last_update_frame", -1))
	var update_id: int = int(frame.get("update_id", 0))
	if last_change != tile_changes:
		last_change = tile_changes
	var did_regen_previous: bool = bool(frame.get("did_regen", false))
	var warmup: float = source_math_state.source_approach_delta(float(frame.get("warmup", 0.0)), 1.0 if did_regen_previous else 0.0, SOURCE_REGEN_PROJECTOR_WARMUP_SPEED, source_delta)
	var total_time: float = float(frame.get("total_time", 0.0)) + warmup * source_delta
	var optional_timer: float = float(frame.get("optional_timer", 0.0))
	var did_regen: bool = false
	var any_targets: bool = false
	var heal_amount: float = 0.0
	var consumed: bool = false
	if heal_suppressed:
		return {"last_change": last_change, "warmup": warmup, "total_time": total_time, "optional_timer": optional_timer, "did_regen": false, "any_targets": false, "mend_map": mend_map, "heal_amount": 0.0, "consumed": false, "last_update_frame": last_update_frame, "heal_applications": {}}
	for target in targets:
		if bool(target.get("damaged", false)):
			any_targets = true
			break
	if efficiency > 0.0:
		var edelta: float = efficiency * source_delta * time_scale
		optional_timer += edelta * optional_efficiency
		if optional_timer >= SOURCE_REGEN_PROJECTOR_OPTIONAL_USE_TIME:
			consumed = true
			optional_timer = 0.0
		heal_amount = lerpf(1.0, SOURCE_REGEN_PROJECTOR_OPTIONAL_MULTIPLIER, optional_efficiency) * SOURCE_REGEN_PROJECTOR_HEAL_PERCENT
		for target in targets:
			if not bool(target.get("damaged", false)) or bool(target.get("heal_suppressed", false)):
				continue
			did_regen = true
			var pos: int = int(target.get("pos", 0))
			var block_health: float = float(target.get("block_health", 0.0))
			var health: float = float(target.get("health", 0.0))
			var value: float = float(mend_map.get(pos, 0.0))
			mend_map[pos] = minf(maxf(value, heal_amount * edelta * block_health / 100.0), block_health - health)
	# N2325: the mendMap flush (RegenProjector.java:168-177)
	# sits after the heal branch and outside the efficiency
	# gate, so it fires on a zero-efficiency tick too -- but
	# never on a suppressed tick (the early return above).
	# When the frame last_update_frame differs from the frame
	# update_id, the whole mend_map is reported as
	# heal_applications {pos: amount} and cleared, and
	# last_update_frame stamps the new update_id.
	var heal_applications: Dictionary = {}
	if last_update_frame != update_id:
		last_update_frame = update_id
		heal_applications = Dictionary(mend_map)
		mend_map = {}
	return {"last_change": last_change, "warmup": warmup, "total_time": total_time, "optional_timer": optional_timer, "did_regen": did_regen, "any_targets": any_targets, "mend_map": mend_map, "heal_amount": heal_amount, "consumed": consumed, "last_update_frame": last_update_frame, "heal_applications": heal_applications}

static func _to_short(value: int) -> int:
	# The Java (short) cast: truncate to the low 16 bits, then sign-extend (Point2.pack/unpack cast through short, arc Point2.java:35-42); GDScript ints are 64-bit, so the wrap is explicit.
	var truncated: int = value & 0xFFFF
	if truncated >= 0x8000:
		return truncated - 0x10000
	return truncated

static func _point2_unpack(pos: int) -> Vector2i:
	# Point2.unpack (arc Point2.java:35-37, `return new Point2((short)(pos >>> 16), (short)(pos & 0xFFFF));`).
	return Vector2i(_to_short(pos >> 16), _to_short(pos & 0xFFFF))

static func source_regen_projector_heal_application_state(game: Object, heal_applications: Dictionary) -> Dictionary:
	# The live heal application (N2399): the mendMap flush loop
	# (RegenProjectorBuild.updateTile(), RegenProjector.java:168-177)
	# applies each flushed entry to its live building (each exact
	# expr on ONE comment line, the N2148 lesson):
	# `for(var entry : mendMap.entries()){`
	# `var build = world.build(entry.key);`
	# `if(build != null){`
	# `build.heal(entry.value);`
	# `build.recentlyHealed();`
	# `mendMap.clear();`
	# `public @Nullable Building build(int pos){`
	# `if(tile == null) return null;`
	# `health += amount;`
	# `health = Math.min(health, maxHealth);`
	# `public void recentlyHealed(){`
	# `lastHealTime = Time.time;`
	# `return new Point2((short)(pos >>> 16), (short)(pos & 0xFFFF));`
	# `return (((short)x) << 16) | (((short)y) & 0xFFFF);`
	# `return Point2.pack(x, y);`
	# `return tile.pos();`
	# Verified before coding: (a) pos is the packed ORIGIN cell --
	# the N2277 fill packs the origin cell with tile_pos_state,
	# Tile.pos() is `return Point2.pack(x, y);`
	# (Tile.java:73-75) and build.pos() is `return tile.pos();`
	# (BuildingComp.java:578-580) -- decoded here with
	# _point2_unpack (the ItemBridge / LiquidBridge / MassDriver
	# precedent, no separate symbol). (b) The cell resolves to
	# its sprite through block_sprite_at_cell (the N2353/N2371
	# helper precedent); a missing sprite reports no_sprite --
	# the Java `build == null` skip (world.build(int pos)
	# returns null for a missing tile/build,
	# World.java:142-146), which covers a demolished or
	# out-of-range target. (c) NO family frame carries health
	# (verified by grep: no frame key holds a health value --
	# the N2277 candidates carry health as VALUES read from the
	# sprite metas), so the heal lands on the sprite health
	# meta directly through the shared repair_sprite -- walls
	# and cores heal through the same path, like Java healing
	# ANY building, and there is no frame lookup and no frame
	# write-back here. (d) heal() caps at maxHealth:
	# HealthComp.heal is `health += amount;` + clampHealth
	# (HealthComp.java:103-112), and repair_sprite is that
	# exact cap (min of max health, before + amount), returning
	# the actual healed amount (0.0 at full health). (e)
	# recentlyHealed() DEFERS: no Time.time input reaches the
	# tick (the tick gets game + seconds, a delta, and the port
	# exposes no live elapsed time), so the result reports
	# recently_healed false and no last_heal_time is stamped
	# anywhere -- the timestamp write waits for a game-time
	# slice. Every input pos gets exactly one application entry
	# {pos, cell, amount, healed, reason}; a non-positive
	# amount reports invalid_amount (defensive -- the advance
	# only ever flushes non-negative amounts). The tick calls
	# this AFTER the flush write-back (Java order: the heal
	# loop IS the flush block). Follow-up, not this slice: the
	# frame targets entries keep their pre-heal health snapshot
	# until the next tile_changes scan rebuilds the list, so
	# any_targets keeps reading a healed target as damaged for
	# one scan cycle.
	var applications: Array = []
	var applied_count := 0
	var skipped_count := 0
	for pos_key in heal_applications:
		var pos: int = int(pos_key)
		var amount: float = float(heal_applications[pos_key])
		var target_cell: Vector2i = _point2_unpack(pos)
		if amount <= 0.0:
			applications.append({"pos": pos, "cell": target_cell, "amount": amount, "healed": 0.0, "reason": "invalid_amount"})
			skipped_count += 1
			continue
		var target_sprite: Variant = null
		if game != null:
			target_sprite = game.call("block_sprite_at_cell", target_cell)
		if target_sprite == null:
			applications.append({"pos": pos, "cell": target_cell, "amount": amount, "healed": 0.0, "reason": "no_sprite"})
			skipped_count += 1
			continue
		var healed: float = source_placed_block_state.repair_sprite(target_sprite, amount)
		applications.append({"pos": pos, "cell": target_cell, "amount": amount, "healed": healed, "reason": "healed"})
		applied_count += 1
	return {"applications": applications, "applied_count": applied_count, "skipped_count": skipped_count, "recently_healed": false}

@warning_ignore("unused_parameter")
static func source_regen_projector_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the regen-projector tick wiring every
	# tick (RegenProjectorBuild.updateTile(), RegenProjector.java:123,
	# gates on the heal gate (RegenProjector.java:142,
	# `if(efficiency > 0){`) and the heal amount
	# (RegenProjector.java:148, `float healAmount = Mathf.lerp(1f, optionalMultiplier, optionalEfficiency) * healPercent;`), so the
	# heal gate follows the folded efficiency; no
	# placed-buildings driver ticks RegenProjector blocks, so this
	# driver is the placed-regen-projector tick): each placed
	# RegenProjector build gets its frame keys refreshed from the
	# live rules, so the frame's cheating flag tracks
	# team.rules().cheat and the consumption machinery skips
	# consumption for a cheating team. The frame is bound at
	# placement; a sprite that somehow lacks one gets it bound
	# here instead of crashing the loop.
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
	# N2277: the placed buildings, gathered once per tick -- the
	# updateTargets scan below reads the same list for every
	# projector instead of re-querying placed_blocks per sprite.
	var all_buildings: Array = source_placed_block_state.source_unique_buildings_state(game).get("buildings", [])
	for sprite in all_buildings:
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if not _is_regen_projector_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_regen_projector_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_regen_projector_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The frame carries the Building.liquids LiquidModule
		# (frame["liquids"]): the live store lives on the
		# sprite meta (source_building_liquids, initialized
		# at placement -- PortGame applies the liquid
		# consumers first, so ConsumeLiquidBase.apply sets
		# hasLiquids even though the catalog carries no
		# hasLiquids flag for regen-projector), so the driver
		# syncs the reference into the frame each tick BEFORE
		# the fold, and the pure liquid row reads the hydrogen
		# amount from it (the Fracker:623 precedent).
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a regen projector with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the heal gate (RegenProjector.java:142)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449,
		# `hasConsumers = consumers.length > 0;`), so a regen
		# projector does not take the early return. A regen projector with
		# no power consumer is untouched: the tick also folds the
		# required hydrogen row (1f/60f, Blocks.java:2016, N2260)
		# into the first pass and the phaseFabric booster row
		# (Blocks.java:2017, N2260) into the optional pass when
		# the projector has a power consumer; no live intake fills
		# frame["items"] yet, so the item row reads the frame
		# as-is. RegenProjectorBuild
		# overrides shouldConsume() to return anyTargets
		# (RegenProjector.java:181-183) -- N2214 feeds the live gate to the
		# machinery (the pure gate is
		# source_regen_projector_should_consume_state, fed the frame); the
		# N2160 RED decision is resolved. The gate has no enabled term
		# (Java returns the bare flag); the outer guard below already runs
		# the machinery only when enabled.
		# productionValid is the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_regen_projector_should_consume_state(frame)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_regen_projector_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			# N2260: the required hydrogen row folds alongside
			# the power row (ConsumeLiquid.efficiency,
			# ConsumeLiquid.java:42-47): in the first pass
			# efficiency is assumed 1f, so edelta is
			# source_delta * time_scale and the row reads the
			# live hydrogen store synced into the frame above.
			# The single def always has the row
			# (`consumeLiquid(Liquids.hydrogen, 1f / 60f);`,
			# Blocks.java:2016), so has_liquid_consumer is true.
			# The phaseFabric booster row folds into the
			# OPTIONAL pass (ConsumeItems.efficiency,
			# ConsumeItems.java:51-53, binary 1/0): the single
			# def always has the row
			# (`consumeItem(Items.phaseFabric).boost();`,
			# Blocks.java:2017), so the stacks are the def
			# constant (1 phaseFabric); consumeTriggerValid is
			# the canonical false base
			# (BuildingComp.java:764-766, read through
			# SourceBuildingAccessState).
			var tick_source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var tick_time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var hydrogen_id: int = int(liquid_id_by_name.get(SOURCE_REGEN_PROJECTOR_LIQUID, -1))
			var liquid_row: Dictionary = source_regen_projector_liquid_consumer_row_state(frame, true, hydrogen_id, SOURCE_REGEN_PROJECTOR_LIQUID_AMOUNT, tick_source_delta, tick_time_scale, float(frame.get("efficiency_scale", 1.0)))
			if bool(liquid_row.get("has_liquid_row", false)):
				required_results.append(liquid_row.get("row", {}))
			var booster_stacks: Array = [{"item": SOURCE_REGEN_PROJECTOR_BOOSTER_ITEM, "amount": SOURCE_REGEN_PROJECTOR_BOOSTER_AMOUNT}]
			var item_row: Dictionary = source_regen_projector_item_consumer_row_state(frame, booster_stacks, source_building_access_state.consume_trigger_valid_state())
			var optional_results: Array = []
			if bool(item_row.get("has_item_row", false)):
				optional_results.append(item_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, optional_results, [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# Second pass (BuildingComp.java:1999-2003, `if(update && efficiency > 0){` / `cons.update(self());`): ConsumeLiquid.update removes `build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));` (ConsumeLiquid.java:38), with edelta from the FOLDED efficiency (not the first-pass 1f). Direct removal here, not the AdjacentFactory updates-array precedent (SourceAdjacentFactoryBuildState.gd:382): that pattern passes generated consumer actor objects with an update(self_state) method through update_consumption_state, and this driver is pure static functions with no actor -- so the removal runs after apply_update_consumption_state with the same guard (update && efficiency > 0), through the shared module source_remove_state with a cache_sums array sized to the store (the PayloadLoader precedent; flow is null in the live store, so cache_sums is unused but required by the signature). The multiplier is the 1f default (Consume.java:18); the def sets none. ConsumeItems has no update override, so the second pass never touches the phaseFabric -- its removal is the consume() wiring after the advance below.
			if should_consume and valid and float(frame.get("efficiency", 0.0)) > 0.0 and hydrogen_id >= 0:
				var liquids: Dictionary = frame.get("liquids", {})
				if liquids.has("liquids"):
					var folded_edelta: float = float(frame.get("efficiency", 0.0)) * tick_source_delta * tick_time_scale
					var cache_sums: Array = []
					cache_sums.resize(int((liquids.get("liquids", []) as Array).size()))
					cache_sums.fill(0.0)
					source_liquid_module_state.source_remove_state(liquids, hydrogen_id, SOURCE_REGEN_PROJECTOR_LIQUID_AMOUNT * folded_edelta, cache_sums)
		# N2228: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277; noUpdateDisabled defaults
		# false, Block.java:170, so Java runs updateTile even
		# when disabled -- in Java a disabled regen projector's
		# warmup DECAYS toward 0 (efficiency is zeroed by the
		# disabled early return, BuildingComp.java:1954-1957)
		# and the mend amounts freeze (edelta() is 0). The port
		# keeps the enabled gate below as a pragmatic choice
		# (the N2195 coordinator-fix precedent): the driver
		# skips the consumption fold when disabled, so the frame
		# efficiency goes stale and running the advance on it
		# would charge warmup/mend from a stale efficiency.
		# The driver-wide disabled-early-return slice (deferred
		# in the N2228 register) removes this gate for all
		# families. super.updateTile() is an empty no-op
		# (BuildingComp.java:2010-2012), so the driver owes it
		# nothing. The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60
		# (arc Time.java:26), never raw seconds. timeScale
		# reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`). The advance
		# recomputes frame["any_targets"] every tick from the
		# targets list the N2277 scan rebuilds just above (the
		# contains-damaged fold, RegenProjector.java:139), so a
		# live projector with a damaged building in range reads
		# any_targets true and consumes.
		if bool(frame.get("enabled", true)):
			# N2277: the updateTargets scan runs BEFORE the advance
			# (the Java order: the tileChanges check opens
			# updateTile, RegenProjector.java:122-125, and the
			# advance then folds anyTargets over the fresh
			# targets, RegenProjector.java:139). The driver
			# pre-checks the gate before gathering candidates
			# (Java only scans on change); the pure scan keeps
			# its own gate, so the refresh / no-refresh branches
			# stay provable pure. Each candidate's world center
			# is the drawx/drawy of its origin cell (the
			# RepairTurret precedent: Tile.java:176/180 with the
			# block offset, Block.java:761), its pos is the
			# packed cell (tile_pos_state, Tile.java:73-75), its
			# health/max health come from the sprite metas and
			# its team from the build-team meta; a sprite whose
			# block is not in the catalog is skipped (no size to
			# center it with). heal_suppressed is false for every
			# candidate: the port tracks no live suppression
			# state (the suppression live fill is still
			# deferred). hit_size is size * tilesize
			# (BuildingComp.java:2048) and privileged is the
			# live privileged flag fill, live since N2344
			# (the pure reads the candidate block id against
			# the four privileged defs -- the
			# world-processor-only logic blocks,
			# Blocks.java:6955/6965/6974/6981 -- because the
			# catalog carries no privileged flag). The projector
			# itself counts when it falls in its own rect (Java
			# predicate `b -> true`).
			if int(frame.get("tile_changes", 1)) != int(frame.get("last_change", -2)):
				var scan_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
				var scan_block_size: int = int(block.properties.get("size", 1))
				var scan_block_offset: float = float((scan_block_size + 1) % 2) * source_world_defaults.TILESIZE / 2.0
				var scan_building_x: float = source_block_geometry.tile_drawx_state(scan_cell.x, source_world_defaults.TILESIZE, scan_block_offset)
				var scan_building_y: float = source_block_geometry.tile_drawy_state(scan_cell.y, source_world_defaults.TILESIZE, scan_block_offset)
				var scan_candidates: Array = []
				for other_sprite in all_buildings:
					if not is_instance_valid(other_sprite) or not other_sprite is Sprite2D:
						continue
					var other_block_id: String = str(other_sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
					if not blocks_by_id.has(other_block_id):
						continue
					var other_block = blocks_by_id[other_block_id]
					var other_cell: Vector2i = other_sprite.get_meta("origin_cell", Vector2i.ZERO)
					var other_size: int = int(other_block.properties.get("size", 1))
					var other_offset: float = float((other_size + 1) % 2) * source_world_defaults.TILESIZE / 2.0
					scan_candidates.append({"pos": source_block_geometry.tile_pos_state(other_cell.x, other_cell.y), "team_id": int(other_sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID)), "x": source_block_geometry.tile_drawx_state(other_cell.x, source_world_defaults.TILESIZE, other_offset), "y": source_block_geometry.tile_drawy_state(other_cell.y, source_world_defaults.TILESIZE, other_offset), "block_health": float(other_sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_MAX_HEALTH_META_KEY, 0.0)), "health": source_placed_block_state.health(other_sprite), "heal_suppressed": false, "hit_size": float(other_size) * source_world_defaults.TILESIZE, "privileged": bool(source_regen_projector_privileged_state(other_block_id).get("privileged", false))})
				var scanned: Dictionary = source_regen_projector_update_targets_state(frame, scan_building_x, scan_building_y, scan_candidates)
				# N2338: the hitbox-overlap + privileged
				# refinement chains AFTER the rect scan (the
				# N2335 pattern): the narrow drops privileged
				# rect members and admits same-team straddlers
				# whose hitbox STRICTLY overlaps the rect, so
				# the frame targets take the NARROWED list
				# while last_change still stamps from the scan.
				var narrowed: Dictionary = source_regen_projector_update_targets_narrow_state(scanned["targets"], scan_candidates, team_id, scan_building_x, scan_building_y)
				frame["targets"] = narrowed["targets"]
				frame["last_change"] = scanned["last_change"]
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var advanced: Dictionary = source_regen_projector_update_tile_advance_state(frame, source_delta, time_scale)
			frame["last_change"] = advanced["last_change"]
			frame["warmup"] = advanced["warmup"]
			frame["total_time"] = advanced["total_time"]
			frame["optional_timer"] = advanced["optional_timer"]
			frame["did_regen"] = advanced["did_regen"]
			frame["any_targets"] = advanced["any_targets"]
			frame["mend_map"] = advanced["mend_map"]
			frame["heal_amount"] = advanced["heal_amount"]
			frame["consumed"] = advanced["consumed"]
			# N2325: the mendMap flush result rides the frame --
			# last_update_frame stamps the flushed update_id and
			# heal_applications carries the flushed {pos:
			# amount} map (RegenProjector.java:168-177).
			frame["last_update_frame"] = advanced["last_update_frame"]
			frame["heal_applications"] = advanced["heal_applications"]
			# N2399: the live heal application runs AFTER the
			# flush write-back above (Java order: the heal loop
			# IS the flush block, RegenProjector.java:168-177):
			# each flushed {pos: amount} decodes to its origin
			# cell and heals the sprite health there, capped at
			# maxHealth; a missing target reports no_sprite
			# (the Java build == null skip). The result rides
			# the frame as heal_applied; recentlyHealed()
			# still waits (no Time.time input reaches the
			# tick), so the result reports recently_healed
			# false and no last_heal_time is stamped.
			frame["heal_applied"] = source_regen_projector_heal_application_state(game, advanced["heal_applications"])
			# N2260: consume() fires on the tick the advance
			# reports consumed (`if((optionalTimer += edelta() *
			# optionalEfficiency) >= optionalUseTime){`,
			# RegenProjector.java:142, with `consume();`,
			# RegenProjector.java:143): it triggers EVERY
			# consumer (`for(Consume cons : block.consumers){`,
			# BuildingComp.java:1912, with `cons.trigger(self());`,
			# BuildingComp.java:1913), but only ConsumeItems
			# overrides trigger, so consume() removes 1
			# phaseFabric (`build.items.remove(stack.item,
			# Math.round(stack.amount * multiplier.get(build)));`,
			# ConsumeItems.java:44-48), clamped to what the
			# frame holds (`amount = Math.min(amount,
			# items[item.id]);`, ItemModule.java:258-263) through
			# the shared inventory remove_item_state. The
			# removal runs even when the item row folded 0.0:
			# Java fires consume() on the timer regardless of
			# the held count, and the clamp removes 0 then.
			if bool(frame.get("consumed", false)):
				var held_items: Dictionary = frame.get("items", {})
				var removed: Dictionary = inventory.remove_item_state(held_items, SOURCE_REGEN_PROJECTOR_BOOSTER_ITEM, SOURCE_REGEN_PROJECTOR_BOOSTER_AMOUNT)
				frame["items"] = removed.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, held_items)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
