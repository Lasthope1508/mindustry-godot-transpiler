extends RefCounted
class_name SourceMechanicalPumpBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_pump_runtime_state := preload("res://src/game/SourcePumpRuntimeState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")

# The Pump implementation (Pump.java:18, `public class Pump
# extends LiquidBlock{`): rotary-pump (consumePower 0.3f,
# pumpAmount 0.2f, size 2, liquidCapacity 80f) and
# impulse-pump (consumePower 1.3f, pumpAmount 0.22f, size 3,
# liquidCapacity 200f). The only two power-consuming Pump
# blocks in the game (Blocks.java:2304-2320). The
# mechanical-pump (pumpAmount 7f/60f, liquidCapacity 20f,
# Blocks.java:2298-2302) has NO consumePower in Java or the
# catalog, so the driver gate
# (block.properties.has("consumePower")) naturally excludes
# it; the scenario pump tick in SourcePumpRuntimeState.gd
# stays untouched. This driver uses its own family frame key
# ("source_mechanical_pump_building", the turret precedent);
# the scenario pump's per-family frame
# ("source_pump_building") stays untouched, and this slice
# adds the mechanical-pump key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it.
const SOURCE_MECHANICAL_PUMP_BUILD_IMPLEMENTATIONS := ["Pump"]
const SOURCE_MECHANICAL_PUMP_BUILDING_META_KEY := "source_mechanical_pump_building"
# Pump.java:23, `public float warmupSpeed = 0.019f;` -- the
# approachDelta rate for warmup (Pump.java:171/173).
const SOURCE_MECHANICAL_PUMP_WARMUP_SPEED := 0.019
# Pump.java:22, `public float consumeTime = 60f * 5f;` -- the
# interval in-between item consumptions, 300 ticks
# (Pump.java:166-169).
const SOURCE_MECHANICAL_PUMP_CONSUME_TIME := 300.0

static func _is_mechanical_pump_build_implementation(implementation: String) -> bool:
	return SOURCE_MECHANICAL_PUMP_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_mechanical_pump_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The mechanical-pump tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (Pump.java:18, `public class Pump extends LiquidBlock{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's pump
	# skips consumption like Java's updateConsumption
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
	# for this pump (N2125); the tick preserves a disabled
	# pump instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_mechanical_pump_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the mechanical-pump frame meta key
	# ("source_mechanical_pump_building"). A Pump sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_mechanical_pump_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_MECHANICAL_PUMP_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_MECHANICAL_PUMP_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_MECHANICAL_PUMP_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_mechanical_pump_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40,
	# `return build.power.status;`): the power consumer's
	# efficiency is the building's live power.status, and the
	# first pass folds it into the min efficiency
	# (BuildingComp.java:1969-1976, `for(var cons : block.
	# nonOptionalConsumers){` / `minEfficiency = Math.min(
	# minEfficiency, result);`). The graph update stamps
	# frame["power_status"] each tick (N2142); a missing stamp
	# folds to 1.0 before the first graph update, the assembler
	# fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`).
	# A block with no power consumer contributes no row. The
	# power consumer counts toward hasConsumers
	# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
	# so a pump does not take the early return. The pump
	# accumulator follows the folded efficiency
	# (Pump.java:161, `if(efficiency > 0 && liquidDrop != null){` and Pump.java:162, `float maxPump = Math.min(liquidCapacity - liquids.get(liquidDrop), amount * pumpAmount * edelta());`).
	# Documented limits: (1) power-only first pass -- the
	# liquidDrop / amount proximity (Pump.java:141-152) is a
	# per-tick re-scan (Java computes it only in
	# onProximityUpdate), so the folded efficiency is the
	# min over the *modeled* consumers (power only);
	# dumpLiquid does not fold efficiency (it runs after
	# consumption, Pump.java:178-180, and is live since
	# N2285 -- see limit (3)). (2)
	# shouldConsume gate live (N2205) -- PumpBuild.shouldConsume()
	# (Pump.java:155-157, `return liquidDrop != null && liquids.get(liquidDrop) < liquidCapacity - 0.01f && enabled;`) feeds the pure gate
	# source_mechanical_pump_should_consume_state
	# (liquidDrop from the per-tick proximity scan, liquids
	# from the sprite liquids meta, def-constant
	# liquidCapacity); when the gate is false
	# updateConsumption forces efficiency to 0
	# (BuildingComp.java:1960 + 1992-1994). (3) Partial
	# updateTile advance (N2221) -- maxPump / liquids.add /
	# warmup / totalProgress / consTimer advance each tick
	# (Pump.java:161-176). Dump rows live (N2285) --
	# dumpLiquid (Pump.java:178-180) dumps through the
	# shared liquid routing after the advance each tick;
	# the scenario path stays untouched, and the per-tick
	# proximity re-scan (Java computes liquidDrop only in
	# onProximityUpdate, Pump.java:141-152) still waits for
	# its own slice. The neighbour arrays are
	# live-filled since N2410 (the tick scans the live
	# proximity BEFORE the dump reads them; supplied
	# arrays win, the N2381 precedent).
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func _liquid_capacity_for_block_id(block_id: String) -> float:
	# The catalog carries no liquidCapacity for pump defs, so
	# the driver resolves it from the block id (the N2190
	# fogRadius / N2199 transportTime def constant precedent):
	# rotary-pump `liquidCapacity = 80f;` (Blocks.java:2308,
	# `consumePower(0.3f);`, Blocks.java:2307) /
	# impulse-pump `liquidCapacity = 200f;` (Blocks.java:2317,
	# `consumePower(1.3f);`, Blocks.java:2316). Unknown Pump
	# defs fall back to the Block.java:77 default
	# `liquidCapacity = -1f;`, which closes the gate, exactly
	# as Java would (the mechanical-pump, 20f,
	# Blocks.java:2301, never reaches this helper -- it has no
	# consumePower, so the driver gate excludes it).
	match block_id:
		"rotary-pump":
			return 80.0
		"impulse-pump":
			return 200.0
	return -1.0

static func _pump_amount_for_block_id(block_id: String) -> float:
	# The catalog carries no pumpAmount for pump defs, so the
	# driver resolves it from the block id (the same def
	# constant precedent as liquidCapacity): rotary-pump
	# `pumpAmount = 0.2f;` (Blocks.java:2306, the class
	# default `public float pumpAmount = 0.2f;`, Pump.java:20)
	# / impulse-pump `pumpAmount = 0.22f;`
	# (Blocks.java:2315). Unknown Pump defs fall back to the
	# class default 0.2f (the mechanical-pump, 7f/60f,
	# Blocks.java:2300, never reaches this helper -- it has no
	# consumePower, so the driver gate excludes it).
	match block_id:
		"impulse-pump":
			return 0.22
	return 0.2

static func source_mechanical_pump_should_consume_state(frame: Dictionary, liquid_drop: Variant, liquids: Dictionary, liquid_capacity: float, liquid_id_by_name: Dictionary) -> Dictionary:
	# PumpBuild.shouldConsume() exactly (Pump.java:155,
	# `public boolean shouldConsume(){` with
	# `return liquidDrop != null && liquids.get(liquidDrop) < liquidCapacity - 0.01f && enabled;`, Pump.java:156): the pump
	# consumes only while it has a liquid drop AND its stored
	# amount of that liquid is below capacity minus 0.01f AND
	# it is enabled. The override INCLUDES the enabled check
	# -- unlike the LaunchPad (N2186) and ShockwaveTower
	# (N2187) overrides -- so the pure function reads enabled
	# from the frame (BuildingComp.java:77, `transient
	# boolean enabled = true;`; the BuildingComp default
	# shouldConsume, BuildingComp.java:755-756, `return enabled;`, does not apply here because PumpBuild
	# overrides it). liquidDrop is the onProximityUpdate
	# field (Pump.java:114, `public @Nullable Liquid liquidDrop = null;`, set by onProximityUpdate,
	# Pump.java:141-152: `liquidDrop = other.floor().liquidDrop;` / `amount += other.floor().liquidMultiplier;` for each linked tile
	# passing canPump, Pump.java:106-108,
	# `return tile != null && tile.floor().liquidDrop != null;`). The liquids amount is
	# liquids.get(liquidDrop) over the sprite liquids meta
	# (the LiquidModule dict, read through the shared liquid
	# module source_get_state by liquid id, resolved from the
	# drop name through the catalog liquid_id_by_name map --
	# the factory precedent). A missing liquids dict reads
	# empty (amount 0.0); an unknown drop id reads 0.0 (all
	# floor drops are catalog liquids, so the guard is
	# defensive only). When the gate is false,
	# updateConsumption folds efficiency to 0
	# (BuildingComp.java:1960,
	# `boolean update = shouldConsume() && productionValid();`, with BuildingComp.java:1992-1994,
	# `if(!update){` / `efficiency = optionalEfficiency = 0f;`).
	var enabled: bool = bool(frame.get("enabled", true))
	if liquid_drop == null:
		return {"should_consume": false, "liquid_drop": null}
	var liquid_id: int = int(liquid_id_by_name.get(str(liquid_drop), -1))
	var current: float = 0.0
	var stored: Array = liquids.get("liquids", [])
	if liquid_id >= 0 and liquid_id < stored.size():
		current = float(source_liquid_module_state.source_get_state(liquids, liquid_id).get("amount", 0.0))
	return {"should_consume": current < liquid_capacity - 0.01 and enabled, "liquid_drop": liquid_drop}

static func source_mechanical_pump_update_tile_advance_state(frame: Dictionary, liquid_drop: Variant, amount: float, liquids: Dictionary, liquid_capacity: float, pump_amount: float, source_delta: float, time_scale: float, liquid_id_by_name: Dictionary) -> Dictionary:
	# The updateTile advance (PumpBuild.updateTile(),
	# Pump.java:160-182): `if(efficiency > 0 && liquidDrop != null){`
	# (Pump.java:161), `float maxPump = Math.min(liquidCapacity - liquids.get(liquidDrop), amount * pumpAmount * edelta());`
	# (Pump.java:162), `liquids.add(liquidDrop, maxPump);`
	# (Pump.java:163), `if((consTimer += delta()) >= consumeTime){`
	# (Pump.java:166) with `consTimer %= 1f;`
	# (Pump.java:168), `warmup = Mathf.approachDelta(warmup, maxPump > 0.001f ? 1f : 0f, warmupSpeed);`
	# (Pump.java:171) in the pumping branch and `warmup = Mathf.approachDelta(warmup, 0f, warmupSpeed);`
	# (Pump.java:173) otherwise, `totalProgress += warmup * Time.delta;`
	# (Pump.java:176) on the NEW warmup. consume() is a no-op
	# for these pumps -- `//does nothing for most pumps, as those do not require items.`
	# (Pump.java:165): neither rotary-pump nor impulse-pump
	# consumes items (Blocks.java:2304-2320), so the timer
	# advances and wraps and nothing else happens at the wrap.
	# `dumpLiquid(liquidDrop);` (Pump.java:179) is live since
	# N2285 (source_mechanical_pump_dump_liquid_state, wired
	# in the tick after this advance); before N2285 the
	# documented deferral was "dumpLiquid waits for its own slice"
	# (the scenario-path dump helper is bound to the scenario
	# frame, so the placed-pump dump needed its own wiring).
	# The Arc formula
	# is approachDelta(from, to, speed) = approach(from, to,
	# Time.delta * speed) with approach = from + clamp(to -
	# from, -speed, speed) (Mathf.java:415-422), so the warmup
	# step uses the RAW source delta (Time.delta), never
	# edelta; move_toward is the same clamp-step (the
	# scenario pump precedent,
	# SourcePumpRuntimeState.source_pump_update_state).
	# delta() = Time.delta * timeScale and edelta() =
	# efficiency * delta(): `return Time.delta * timeScale;`
	# (BuildingComp.java:1923) and `return efficiency * delta();`
	# (BuildingComp.java:1928), so maxPump and consTimer scale
	# with timeScale while totalProgress uses raw Time.delta.
	# source_delta is Time.delta in ticks (seconds * 60
	# through game_source_delta, arc Time.java:26), never raw
	# seconds. efficiency / warmup / totalProgress / consTimer
	# default 0.0, the Java field defaults
	# (BuildingComp.java:85 `transient float efficiency;`,
	# `public float warmup, totalProgress;` Pump.java:111,
	# `public float consTimer;` Pump.java:112). The class
	# defaults are `public float pumpAmount = 0.2f;`
	# (Pump.java:20), `public float consumeTime = 60f * 5f;`
	# (Pump.java:22), `public float warmupSpeed = 0.019f;`
	# (Pump.java:23); the driver passes the per-def pumpAmount
	# (impulse-pump `pumpAmount = 0.22f;`, Blocks.java:2315).
	# The pure function does NOT mutate the liquids store: it
	# returns max_pump and the post-add liquid_amount, and the
	# driver performs liquids.add through the shared liquid
	# module source_add_state (LiquidModule.java:84-91,
	# `liquids[liquid.id] += amount; current = liquid;`).
	# When the store is already over capacity the min is
	# negative, exactly as Java computes it -- live, the N2205
	# gate closes before that (efficiency folds to 0), so the
	# pumping branch never runs overfull.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var warmup: float = float(frame.get("warmup", 0.0))
	var total_progress: float = float(frame.get("total_progress", 0.0))
	var cons_timer: float = float(frame.get("cons_timer", 0.0))
	var liquid_id: int = -1
	if liquid_drop != null:
		liquid_id = int(liquid_id_by_name.get(str(liquid_drop), -1))
	var current: float = 0.0
	var stored: Array = liquids.get("liquids", [])
	if liquid_id >= 0 and liquid_id < stored.size():
		current = float(source_liquid_module_state.source_get_state(liquids, liquid_id).get("amount", 0.0))
	var max_pump: float = 0.0
	var next_cons_timer: float = cons_timer
	var target: float = 0.0
	if efficiency > 0.0 and liquid_drop != null:
		var edelta: float = efficiency * source_delta * time_scale
		max_pump = minf(liquid_capacity - current, amount * pump_amount * edelta)
		next_cons_timer = cons_timer + source_delta * time_scale
		if next_cons_timer >= SOURCE_MECHANICAL_PUMP_CONSUME_TIME:
			# consume() is a no-op for these pumps (Pump.java:165).
			next_cons_timer = fmod(next_cons_timer, 1.0)
		target = 1.0 if max_pump > 0.001 else 0.0
	var next_warmup: float = move_toward(warmup, target, SOURCE_MECHANICAL_PUMP_WARMUP_SPEED * source_delta)
	var next_total_progress: float = total_progress + next_warmup * source_delta
	return {"max_pump": max_pump, "liquid_amount": current + max_pump, "cons_timer": next_cons_timer, "warmup": next_warmup, "total_progress": next_total_progress}

static func source_mechanical_pump_dump_liquid_state(frame: Dictionary, liquid_drop: Variant, liquids: Dictionary, liquid_capacity: float, liquid_id_by_name: Dictionary, neighbour_amounts: Array, neighbour_capacities: Array, neighbour_accepts: Array, neighbour_can_dump: Array) -> Dictionary:
	# The updateTile dump (PumpBuild.updateTile(),
	# Pump.java:160-182): after `totalProgress += warmup * Time.delta;`
	# (Pump.java:176),
	# `if(liquidDrop != null){`
	# `dumpLiquid(liquidDrop);`
	# (Pump.java:178-180) -- OUTSIDE the efficiency branch,
	# so a pump dumps even at zero efficiency (the dump
	# drains what the advance pumped THIS tick, plus whatever
	# the store already held). dumpLiquid(Liquid)
	# (BuildingComp.java:877-878):
	# `public void dumpLiquid(Liquid liquid){`
	# `dumpLiquid(liquid, 2f);`
	# scales by 2f through
	# `public void dumpLiquid(Liquid liquid, float scaling){`
	# `dumpLiquid(liquid, scaling, -1);`
	# (BuildingComp.java:881-882) into the implementation
	# (BuildingComp.java:886-908):
	# `public void dumpLiquid(Liquid liquid, float scaling, int outputDir){`
	# `int dump = this.cdump;`
	# `if(liquids.get(liquid) <= 0.0001f) return;`
	# `if(!net.client() && state.isCampaign() && team == state.rules.defaultTeam) liquid.unlock();`
	# `for(int i = 0; i < proximity.size; i++){`
	# `incrementDump(proximity.size);`
	# `Building other = proximity.get((i + dump) % proximity.size);`
	# `if(outputDir != -1 && (outputDir + rotation) % 4 != relativeTo(other)) continue;`
	# `other = other.getLiquidDestination(self(), liquid);`
	# `if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){`
	# `float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;`
	# `float fract = liquids.get(liquid) / block.liquidCapacity;`
	# `if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);`
	# -- the early return, the campaign unlock, the
	# per-iteration incrementDump, the outputDir filter
	# (outputDir -1 passes every neighbour), the destination
	# lookup (the default returns self(),
	# BuildingComp.java:980-982, so every neighbour is its
	# own destination), the eligibility gate, and the
	# fraction transfer. canDumpLiquid defaults to true
	# (`public boolean canDumpLiquid(Building to, Liquid liquid){`,
	# BuildingComp.java:910-912); transferLiquid
	# (BuildingComp.java:914-921):
	# `public void transferLiquid(Building next, float amount, Liquid liquid){`
	# `float flow = Math.min(next.block.liquidCapacity - next.liquids.get(liquid), amount);`
	# `if(next.acceptLiquid(self(), liquid)){`
	# `next.handleLiquid(self(), liquid, flow);`
	# `liquids.remove(liquid, flow);`
	# -- flow is min(neighbour free capacity, amount), and
	# the transfer happens only when the neighbour accepts.
	# The cursor advances once per iteration (incrementDump,
	# BuildingComp.java:1116-1121):
	# `public void incrementDump(int prox){`
	# `if(prox != 0){`
	# `cdump = ((cdump + 1) % prox);`
	# -- a full loop runs incrementDump proximity.size times,
	# so the cursor wraps back to its start value; the
	# rotation shows in WHICH neighbour is tried first, not
	# in the final cursor. The dump field is a Building field
	# at its Java default: `transient int cdump;`
	# (BuildingComp.java:68, 0). The dump itself runs through
	# the shared liquid routing (SourceBuildingLiquidState.
	# dump_liquid_state, the SourceBuildingLiquidDumpState
	# port with the transferLiquid callable bound) -- the
	# scenario pump wires the same helper
	# (SourcePumpRuntimeState.source_pump_dump_liquid_state),
	# but this placed-path pure function takes the neighbour
	# arrays as explicit inputs instead of scanning the
	# scenario world. The neighbour arrays are frame inputs
	# (default [] -- no neighbours, the Java proximity.size
	# == 0 outcome) until a live proximity fill lands; they
	# carry only liquid-bearing neighbours (destination /
	# hasLiquids / liquids-present are true by construction,
	# the scenario pump precedent -- it only appends
	# neighbours with a liquids meta and capacity > 0), and
	# the per-neighbour canDumpLiquid answers default true
	# in Java. The neighbour write-back live since N2378:
	# the pure exposes the handled neighbour index
	# (dump_neighbour_index, from the shared routing's
	# handled_index -- the FIRST eligible neighbour whose
	# transfer actually moved liquid, -1 when nothing
	# moved) + the dumped liquid name (dumped_liquid),
	# and the tick wires the shared
	# source_neighbour_liquid_write_back_state helper
	# after the dump when dumped_amount > 0. Unlike the
	# Fracker's def constant "oil", the pumped liquid
	# VARIES BY TILE: liquidDrop is the floor drop's name
	# (water / oil / cryofluid / slag / arkycite, from
	# source_floor_liquid_drop_state -- deep/shallow/
	# tainted water, tar, pooled-cryofluid, molten-slag,
	# arkycite-floor -- or null), so dumped_liquid is
	# str(liquid_drop), the same resolution the pure
	# already uses for liquid_id_by_name, and "" on the
	# null-drop path. A dump that reaches several
	# neighbours reports only the first handled index, so
	# the write-back lands the total there -- the
	# per-neighbour split waits for its own slice. The
	# campaign unlock is computed by the helper but never
	# applied (the port has no content-unlock model). The
	# pure function does NOT mutate the liquids store: it
	# returns a copy with the dumped amount removed, and
	# the driver writes it back through the shared liquid
	# module source_set_state.
	var cdump: int = int(frame.get("cdump", 0))
	var liquids_after: Dictionary = liquids.duplicate(true)
	if liquid_drop == null:
		return {"liquids_after": liquids_after, "dumped_amount": 0.0, "cursor_after": cdump, "dump_neighbour_index": -1, "dumped_liquid": ""}
	var liquid_id: int = int(liquid_id_by_name.get(str(liquid_drop), -1))
	var stored: Array = liquids.get("liquids", [])
	var current: float = 0.0
	if liquid_id >= 0 and liquid_id < stored.size():
		current = float(source_liquid_module_state.source_get_state(liquids, liquid_id).get("amount", 0.0))
	var proximity_size: int = neighbour_amounts.size()
	var relative_to: Array = []
	var destination_present: Array = []
	var other_has_liquids: Array = []
	var other_liquids_present: Array = []
	for i in range(proximity_size):
		relative_to.append(i)
		destination_present.append(true)
		other_has_liquids.append(true)
		other_liquids_present.append(true)
	var dump: Dictionary = source_building_liquid_state.dump_liquid_state(liquid_drop, 2.0, -1, current, false, true, true, proximity_size, cdump, 0, relative_to, destination_present, other_has_liquids, neighbour_can_dump, other_liquids_present, neighbour_amounts, neighbour_capacities, neighbour_accepts, liquid_capacity, Callable(source_building_item_dump_state, "increment_dump_cursor_state"))
	var amount_after: float = float(dump.get("current_liquid_amount_after", current))
	if liquid_id >= 0 and liquid_id < stored.size():
		source_liquid_module_state.source_set_state(liquids_after, liquid_id, amount_after)
	return {"liquids_after": liquids_after, "dumped_amount": current - amount_after, "cursor_after": int(dump.get("final_cdump", cdump)), "dump_neighbour_index": int(dump.get("handled_index", -1)), "dumped_liquid": str(liquid_drop)}

static func source_mechanical_pump_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the mechanical-pump tick wiring every
	# tick (PumpBuild.updateTile(), Pump.java:159, gates on
	# `if(efficiency > 0 && liquidDrop != null){` and pumps
	# maxPump into the liquid, so the maxPump fold
	# (Pump.java:162) follows the folded efficiency; the pump
	# runtime never ticks placed Pump blocks, so this driver is
	# the placed-pump tick): each placed Pump build gets its
	# frame keys refreshed from the live rules, so the frame's
	# cheating flag tracks team.rules().cheat and the
	# consumption machinery skips consumption for a cheating
	# team. The frame is bound at placement; a sprite that
	# somehow lacks one gets it bound here instead of crashing
	# the loop.
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
		if not _is_mechanical_pump_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_mechanical_pump_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_mechanical_pump_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a pump with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the maxPump fold (Pump.java:162)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449,
		# `hasConsumers = consumers.length > 0;`), so a pump
		# does not take the early return. A pump with no power
		# consumer is untouched: the tick models no other
		# consumers yet (dumpLiquid is live since N2285, but
		# it is not a consumer -- it runs after the advance).
		# The shouldConsume gate is live since N2205:
		# the driver gathers liquidDrop per tick from the
		# existing N2087 proximity helper
		# (source_pump_proximity_state, the onProximityUpdate
		# scan, Pump.java:141-152 -- the helper also rewrites
		# the sprite's source_pump_building meta, but that meta
		# is per-sprite, so the scenario pump stays untouched),
		# reads the liquids amount from the sprite liquids meta
		# and the def-constant liquidCapacity from the block
		# id, and feeds the pure gate
		# source_mechanical_pump_should_consume_state to the
		# machinery (the N2188/N2198 gate precedent); when the
		# gate is false updateConsumption forces efficiency to
		# 0 (BuildingComp.java:1960 + 1992-1994). Java computes
		# liquidDrop only in onProximityUpdate, so the
		# per-tick re-scan is a recorded deferral.
		# productionValid is the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var proximity: Dictionary = source_pump_runtime_state.source_pump_proximity_state(game, cell)
			var liquids: Dictionary = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
			var liquid_catalog: Dictionary = source_content_registry_runtime_state.source_liquid_catalog_state(catalog)
			var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
			var gate: Dictionary = source_mechanical_pump_should_consume_state(frame, proximity.get("liquid_drop", null), liquids, _liquid_capacity_for_block_id(block_id), liquid_id_by_name)
			var should_consume: bool = bool(gate.get("should_consume", false))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_mechanical_pump_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# N2221: the updateTile advance runs after consumption,
			# like Java's Building.update() (BuildingComp.java:2274
			# updateConsumption(), then the updateTile gate
			# `if(enabled || !block.noUpdateDisabled){` at
			# BuildingComp.java:2276-2278; noUpdateDisabled defaults
			# false, Block.java:170, so Java runs updateTile even
			# when disabled -- in Java a disabled pump's warmup
			# DECAYS toward 0 (efficiency is zeroed by the
			# disabled early return, BuildingComp.java:1954-1957)
			# and maxPump is 0 (edelta() is 0). The port keeps the
			# enabled gate below as a pragmatic choice (the N2195
			# precedent): the driver skips the consumption fold
			# when disabled, so the frame efficiency goes stale
			# and running the advance on it would pump from a
			# stale efficiency. The driver-wide disabled-early-
			# return slice (deferred in the N2195 register)
			# removes this gate for all families. The source delta
			# is Time.delta in ticks: game_source_delta(game,
			# seconds) is seconds * 60 (arc Time.java:26), never
			# raw seconds. timeScale reads live from the sprite
			# meta, default 1.0 (BuildingComp.java:98 `private
			# transient float timeScale = 1f, timeScaleDuration;`).
			# The proximity liquid_drop / amount are the N2087
			# helper values already gathered for the N2205 gate;
			# the driver writes the advanced warmup /
			# total_progress / cons_timer back to the frame and
			# performs liquids.add(liquidDrop, maxPump)
			# (Pump.java:163) through the shared liquid module
			# source_add_state, with a cache_sums array sized to
			# the catalog (the scenario pump precedent,
			# SourcePumpRuntimeState.source_pump_update_state).
			# dumpLiquid (Pump.java:178-180) is wired below
			# (N2285), after the advance.
			if bool(frame.get("enabled", true)):
				var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
				var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
				var advanced: Dictionary = source_mechanical_pump_update_tile_advance_state(frame, proximity.get("liquid_drop", null), float(proximity.get("amount", 0.0)), liquids, _liquid_capacity_for_block_id(block_id), _pump_amount_for_block_id(block_id), source_delta, time_scale, liquid_id_by_name)
				frame["warmup"] = advanced["warmup"]
				frame["total_progress"] = advanced["total_progress"]
				frame["cons_timer"] = advanced["cons_timer"]
				var liquid_id: int = int(liquid_id_by_name.get(str(proximity.get("liquid_drop", "")), -1))
				if liquid_id >= 0 and float(frame.get("efficiency", 0.0)) > 0.0:
					var cache_sums: Array = []
					cache_sums.resize(liquid_catalog.get("content_liquid_ids", []).size())
					cache_sums.fill(0.0)
					source_liquid_module_state.source_add_state(liquids, liquid_id, float(advanced.get("max_pump", 0.0)), cache_sums)
				# N2285: dumpLiquid runs AFTER the advance
				# (Java order: Pump.java:178-180 runs after
				# totalProgress, Pump.java:176), so the dump
				# drains the store the advance filled THIS
				# tick. The dump is OUTSIDE the efficiency
				# branch in Java -- it runs even at zero
				# efficiency, gated only on liquidDrop !=
				# null (the pure function guards it). The
				# neighbour arrays are frame inputs (default
				# [] -- no neighbours, the Java
				# proximity.size == 0 outcome), live-filled
				# since N2410 (the tick scans the live
				# proximity BEFORE the dump reads them; a
				# frame with no fill still reads the frame
				# input as-is); the driver writes the
				# dumped store back through the shared liquid
				# module source_set_state (the scenario pump
				# precedent) and persists the cursor on the
				# frame. The neighbour write-back is live
				# since N2378 (wired below, after the dump
				# write-back, through the shared helper).
				# N2410: the dump neighbour live fill -- the tick
				# fills the four neighbour arrays from the live
				# proximity BEFORE the dump pure reads them.
				# Supplied arrays WIN (the N2381 precedent): the
				# fill runs only when the frame carries NONE of
				# the four keys -- the N2285/N2378 proofs seed
				# the arrays by hand, so a fill there would
				# overwrite the seed. A frame the fill already
				# stamped (dump_neighbour_live -- port
				# bookkeeping, not Java state) refreshes every
				# tick, so a later-placed neighbour joins the
				# arrays and a removed one leaves them. `cell`
				# is already bound before the enabled block, so
				# no N2363-style fill_cell workaround is
				# needed, and the size comes from the block
				# properties (the Fracker pattern). The dumped
				# liquid is the proximity liquid_drop NAME
				# (it varies by tile, the N2378 precedent),
				# resolved to the module id inside the fill
				# through the same liquid_id_by_name map the
				# dump pure takes.
				var has_supplied_dump_neighbour_arrays: bool = frame.has("dump_neighbour_amounts") or frame.has("dump_neighbour_capacities") or frame.has("dump_neighbour_accepts") or frame.has("dump_neighbour_can_dump")
				if not has_supplied_dump_neighbour_arrays or bool(frame.get("dump_neighbour_live", false)):
					var filled: Dictionary = source_mechanical_pump_dump_neighbour_live_fill_state(game, cell, int(block.properties.get("size", 1)), proximity.get("liquid_drop", null), liquid_id_by_name)
					frame["dump_neighbour_amounts"] = filled.get("dump_neighbour_amounts", [])
					frame["dump_neighbour_capacities"] = filled.get("dump_neighbour_capacities", [])
					frame["dump_neighbour_accepts"] = filled.get("dump_neighbour_accepts", [])
					frame["dump_neighbour_can_dump"] = filled.get("dump_neighbour_can_dump", [])
					frame["dump_neighbour_live"] = true
				var neighbour_amounts: Array = frame.get("dump_neighbour_amounts", [])
				var neighbour_capacities: Array = frame.get("dump_neighbour_capacities", [])
				var neighbour_accepts: Array = frame.get("dump_neighbour_accepts", [])
				var neighbour_can_dump: Array = frame.get("dump_neighbour_can_dump", [])
				var dumped: Dictionary = source_mechanical_pump_dump_liquid_state(frame, proximity.get("liquid_drop", null), liquids, _liquid_capacity_for_block_id(block_id), liquid_id_by_name, neighbour_amounts, neighbour_capacities, neighbour_accepts, neighbour_can_dump)
				frame["cdump"] = dumped["cursor_after"]
				var liquids_after: Dictionary = dumped["liquids_after"]
				if liquid_id >= 0 and liquid_id < liquids_after.get("liquids", []).size():
					source_liquid_module_state.source_set_state(liquids, liquid_id, float(liquids_after["liquids"][liquid_id]))
				# N2378: neighbour write-back -- the shared
				# source_neighbour_liquid_write_back_state helper
				# lands the dumped liquid in the handled
				# neighbour's store (dumpLiquid's
				# next.handleLiquid, BuildingComp.java:918)
				# after the dump write-back above, when
				# something dumped. The handled index is a
				# ring index (index i is ring cell i, the
				# N2353 convention), so the live fill must
				# fill the frame neighbour inputs in ring
				# order; `cell` is already bound before the
				# enabled block, so no N2363-style dump_cell
				# workaround is needed, and the size comes
				# from the block properties (the Fracker
				# pattern). A failed write-back (no sprite /
				# no frame / no liquids store) drops the
				# liquid -- the routing already decided, so
				# there is no fallback to the pump's own
				# store (the N2353 precedent). A dump that
				# reaches several neighbours lands the total
				# in the first handled one -- the
				# per-neighbour split waits for its own
				# slice.
				if float(dumped.get("dumped_amount", 0.0)) > 0.0:
					var dump_index: int = int(dumped.get("dump_neighbour_index", -1))
					if dump_index >= 0:
						source_building_liquid_state.source_neighbour_liquid_write_back_state(game, cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_liquid", "")), float(dumped.get("dumped_amount", 0.0)))
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}

static func source_mechanical_pump_dump_neighbour_live_fill_state(game: Object, cell: Vector2i, size: int, liquid_drop: Variant, liquid_id_by_name: Dictionary) -> Dictionary:
	# The dump neighbour live fill (N2410, DEFERRED #228):
	# the N2285 dump pure takes the four neighbour arrays
	# as explicit frame inputs (default [] -- no neighbours,
	# the Java proximity.size == 0 outcome), so a live pump
	# with no fill never dumped. This fill scans the live
	# proximity BEFORE the dump pure and fills the four
	# arrays from the live neighbour frames, in ring order
	# (index i is ring cell i, the N2353 convention -- the
	# ring comes from source_block_proximity_cells_state,
	# the sprite from block_sprite_at_cell, the frame from
	# the first SOURCE_CONSUMER_FRAME_META_KEYS meta on the
	# sprite, the N2353/N2371 resolution path):
	# `Building other = proximity.get((i + dump) % proximity.size);`
	# The dumped liquid VARIES BY TILE: liquidDrop is the
	# floor drop's NAME (water / oil / cryofluid / slag /
	# arkycite, or null), NOT a constant id (unlike
	# SolidPump's water or Fracker's oil):
	# `public @Nullable Liquid liquidDrop = null;`
	# `dumpLiquid(liquidDrop);`
	# so the fill takes the NAME + the liquid_id_by_name
	# map, like the N2285 dump pure -- the consumeLiquid
	# rows match on the NAME, and the amount read resolves
	# the id through the same map the dump pure uses. A
	# null drop fills no accepts and no amounts (the id
	# resolves to -1); the capacities still fill when a
	# neighbour frame carries a liquids store (the N2394
	# precedent -- capacity is liquid-independent). The
	# amount is the neighbour frame liquids module's amount
	# for the dumped id, the capacity is the neighbour
	# def's liquidCapacity (the ofract denominator):
	# `float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;`
	# A neighbour frame with no liquids store reports
	# capacity 0.0 (the N2371 no_liquids_store precedent);
	# the :901 gate needs the store too:
	# `if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){`
	# The accepts/canDump verdicts come from the DEFAULT
	# BuildingComp gates -- acceptLiquid is hasLiquids AND
	# consumesLiquid:
	# `public boolean acceptLiquid(Building source, Liquid liquid){`
	# `return block.hasLiquids && block.consumesLiquid(liquid);`
	# and canDumpLiquid defaults to true:
	# `public boolean canDumpLiquid(Building to, Liquid liquid){`
	# The consumes read is the liquidFilter:
	# `public boolean consumesLiquid(Liquid liq){`
	# `return liquidFilter[liq.id];`
	# which the port represents as the catalog consumeLiquid
	# rows. The destination defaults to present (the default
	# getLiquidDestination returns self()):
	# `public Building getLiquidDestination(Building from, Liquid liquid){`
	# The liquid capacity default is the 10.0 port precedent
	# (SourceFactoryBuildState) when the catalog carries no
	# liquidCapacity key -- Java computes it in Block.init:
	# `liquidCapacity = Mathf.round(10f * consumeAmount);`
	# (min 10f, since consumeAmount starts at 1f). The dump
	# pure hardcodes other_has_liquids / liquids_present
	# true for every array entry (the N2285 frame-input
	# shape), so rejecting neighbours stay in the arrays
	# with accepts false and the transfer gate
	# (acceptLiquid, BuildingComp.java:917) keeps liquid
	# out -- the accepts array is the gate that matters.
	# Per-block overrides are OUT of scope: a neighbour
	# with a modeled override is evaluated with the DEFAULT
	# gate here (the override dispatch is a follow-through
	# note). A neighbour with no frame (no sprite / unknown
	# def / conduit / no meta-key frame) reports the
	# no-frame outcome -- 0.0 / 0.0 / false / false -- the
	# N2353/N2371 no-frame precedent (a routed liquid to a
	# frameless neighbour drops, so the fill closes the
	# gates and nothing routes there). A conduit is
	# no-frame because its acceptLiquid is a per-block
	# override (Conduit.java:242-244, out of scope) and the
	# DEFAULT gate would reject it anyway (a conduit
	# consumes no liquid). Catalog gap (NOT fixed): 30 defs
	# carry consumeLiquid rows but lack the hasLiquids key
	# (e.g. electrolyzer) -- the fill reads the catalog key
	# with the Java field default false (the N2394
	# precedent). Two ring-model notes: Java
	# updateProximity dedupes multi-cell neighbours
	# (`//using a set to prevent duplicates`,
	# BuildingComp.java:1879-1900) and keeps same-team
	# buildings only (`other.team != team` skips), while
	# the ring reports a multi-cell neighbour at each of
	# its ring cells with no team filter -- the N2353 /
	# N2371 ring convention this fill mirrors (a delivery
	# to either index lands in the same frame). Dedup + the
	# team filter wait for a shared ring-geometry slice.
	# The frame-key list comes from a runtime load (the
	# N2371/BeamDrill/N2408 precedent), NOT a preload, and
	# this pure lives after the tick function (the N2408
	# placement).
	var ring: Array = source_block_geometry.source_block_proximity_cells_state(size, cell.x, cell.y).get("cells", [])
	var power_graph_state = load("res://src/game/SourcePlacedPowerGraphState.gd")
	var blocks_by_id: Dictionary = {}
	if game != null:
		var catalog: Variant = game.get("content_catalog")
		if catalog != null:
			for registered_block in catalog.get_many("block"):
				blocks_by_id[registered_block.id] = registered_block
	var liquid_name: String = str(liquid_drop) if liquid_drop != null else ""
	var liquid_id: int = int(liquid_id_by_name.get(liquid_name, -1)) if liquid_drop != null else -1
	var neighbour_amounts: Array = []
	var neighbour_capacities: Array = []
	var neighbour_accepts: Array = []
	var neighbour_can_dump: Array = []
	for neighbour_cell in ring:
		var amount := 0.0
		var capacity := 0.0
		var accepts := false
		var can_dump := false
		var sprite: Variant = null
		if game != null:
			sprite = game.call("block_sprite_at_cell", neighbour_cell)
		if sprite != null:
			var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
			var is_conduit: bool = sprite.has_meta(source_building_liquid_state.SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY) or source_building_liquid_state.SOURCE_NEIGHBOUR_CONDUIT_BLOCK_IDS.has(block_id)
			if not is_conduit and blocks_by_id.has(block_id):
				var neighbour_block = blocks_by_id[block_id]
				var neighbour_frame: Dictionary = {}
				var has_neighbour_frame := false
				for meta_key in power_graph_state.SOURCE_CONSUMER_FRAME_META_KEYS:
					if not sprite.has_meta(meta_key):
						continue
					var candidate: Variant = sprite.get_meta(meta_key)
					if candidate is Dictionary:
						neighbour_frame = candidate
						has_neighbour_frame = true
						break
				if has_neighbour_frame:
					var neighbour_properties = neighbour_block.properties
					can_dump = true
					var neighbour_liquids: Variant = neighbour_frame.get("liquids", null)
					var neighbour_store_amounts: Variant = null
					if neighbour_liquids is Dictionary:
						neighbour_store_amounts = (neighbour_liquids as Dictionary).get("liquids", null)
					if neighbour_store_amounts is Array:
						capacity = float(neighbour_properties.get("liquidCapacity", 10.0))
						if liquid_id >= 0 and liquid_id < (neighbour_store_amounts as Array).size():
							amount = float(source_liquid_module_state.source_get_state(neighbour_liquids, liquid_id).get("amount", 0.0))
					if not liquid_name.is_empty():
						var consumes_liquid := false
						for row in neighbour_properties.get("consumeLiquid", []):
							if not (row is Dictionary):
								continue
							if str(row.get("liquid", "")) == liquid_name:
								consumes_liquid = true
								break
						accepts = bool(neighbour_properties.get("hasLiquids", false)) and consumes_liquid
		neighbour_amounts.append(amount)
		neighbour_capacities.append(capacity)
		neighbour_accepts.append(accepts)
		neighbour_can_dump.append(can_dump)
	return {"dump_neighbour_amounts": neighbour_amounts, "dump_neighbour_capacities": neighbour_capacities, "dump_neighbour_accepts": neighbour_accepts, "dump_neighbour_can_dump": neighbour_can_dump}
