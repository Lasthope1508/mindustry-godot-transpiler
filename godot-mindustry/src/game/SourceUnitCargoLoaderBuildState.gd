extends RefCounted
class_name SourceUnitCargoLoaderBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")

# The UnitCargoLoader implementation (UnitCargoLoader.java:23, `public class UnitCargoLoader extends Block{`): unit-cargo-loader (consumePower 8f/60f, Blocks.java:2276; size 3, itemCapacity 200, Blocks.java:2270-2281). UnitCargoLoader sets solid=true, update=true, hasItems=true, itemCapacity=200 (UnitCargoLoader.java:30-37), unitType manifold / unitBuildTime 60f * 8f (UnitCargoLoader.java:24-25, `public float unitBuildTime = 60f * 8f;`). UnitCargoLoader extends Block, NOT a drill or factory, so it cannot reuse an existing frame key; this driver uses its own family frame key ("source_unit_cargo_loader_building", the mechanical-pump / beam-drill / mend-projector / overdrive-projector / force-projector / base-shield / regen-projector / constructor / payload-loader / payload-unloader / payload-mass-driver precedent), and this slice adds the unit-cargo-loader key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceUnitCargoLoader* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the warmup fold (UnitCargoLoader.java:105, `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 60f);`) follows the folded efficiency, with the build advance (UnitCargoLoader.java:109, `buildProgress += edelta() / unitBuildTime;`).
const SOURCE_UNIT_CARGO_LOADER_BUILD_IMPLEMENTATIONS := ["UnitCargoLoader"]
const SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY := "source_unit_cargo_loader_building"
# N2234 def constants (single def -- unit-cargo-loader): the
# warmup/readyness approach speed 1f/60f (UnitCargoLoader.java:
# 105-106), the unit build time 60f * 8f = 480f (`public float unitBuildTime = 60f * 8f;`,
# UnitCargoLoader.java:25, restated by the def, `unitBuildTime = 60f * 8f;`,
# Blocks.java:2273), the unit type manifold (`public UnitType unitType = UnitTypes.manifold;`,
# UnitCargoLoader.java:24, the def does NOT override it) and the
# spawn rotation 90f (`unit.rotation = 90f;`, UnitCargoLoader.java:119).
const SOURCE_UNIT_CARGO_LOADER_WARMUP_SPEED := 1.0 / 60.0
const SOURCE_UNIT_CARGO_LOADER_UNIT_BUILD_TIME := 480.0
const SOURCE_UNIT_CARGO_LOADER_UNIT_TYPE := "manifold"
const SOURCE_UNIT_CARGO_LOADER_SPAWN_ROTATION := 90.0
# N2249 def constants (single def -- unit-cargo-loader): the
# consumed liquid nitrogen and its per-frame amount 10f/60f
# (`consumeLiquid(Liquids.nitrogen, 10f / 60f);`,
# Blocks.java:2279 -- the def writes Xf/60f = X per second, so
# the per-frame amount is the literal 10f/60f). The multiplier
# defaults to 1f (`public Floatf<Building> multiplier = b -> 1f;`,
# Consume.java:18) and the def does NOT override it
# (Blocks.java:2270-2283 has no multiplier call).
const SOURCE_UNIT_CARGO_LOADER_CONSUMED_LIQUID := "nitrogen"
const SOURCE_UNIT_CARGO_LOADER_LIQUID_AMOUNT := 10.0 / 60.0

static func _is_unit_cargo_loader_build_implementation(implementation: String) -> bool:
	return SOURCE_UNIT_CARGO_LOADER_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_unit_cargo_loader_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The unit-cargo-loader tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (UnitCargoLoader.java:23, `public class UnitCargoLoader extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# unit-cargo-loader skips consumption like Java's updateConsumption
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
	# for this unit-cargo-loader (N2125); the tick preserves a disabled
	# unit-cargo-loader instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# The fresh frame binds the Java build-field defaults:
	# `public int readUnitId = -1;` (UnitCargoLoader.java:86),
	# `public float buildProgress, totalProgress;`
	# (UnitCargoLoader.java:87, both 0f), `public float warmup, readyness;`
	# (UnitCargoLoader.java:88, both 0f) and `public @Nullable Unit unit;`
	# (UnitCargoLoader.java:89, null); the frame inputs (x / y)
	# are NOT bound here: the advance reads them with frame.get
	# defaults (0.0), the N2223 efficiency_factor precedent.
	# The liquids key (N2249) is the Building.liquids
	# LiquidModule dict, {} by default (the Fracker
	# precedent); the tick syncs the live store from the
	# sprite meta into it every tick, before the fold.
	return {"unit": null, "read_unit_id": -1, "build_progress": 0.0, "total_progress": 0.0, "warmup": 0.0, "readyness": 0.0, "liquids": {}}

static func source_unit_cargo_loader_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the unit-cargo-loader frame meta key
	# ("source_unit_cargo_loader_building"). A UnitCargoLoader sprite gets a
	# frame bound with the unit key defaulting to null (the Java field
	# `public @Nullable Unit unit;`, UnitCargoLoader.java:89, is nullable)
	# plus the updateTile state keys (read_unit_id / build_progress /
	# total_progress / warmup / readyness, the Java build-field defaults,
	# UnitCargoLoader.java:86-89 -- N2234); the live-loop tick fills its other keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_unit_cargo_loader_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_unit_cargo_loader_should_consume_state(frame: Dictionary) -> Dictionary:
	# UnitTransportSourceBuild overrides shouldConsume (UnitCargoLoader.java:141, `public boolean shouldConsume(){` with `return unit == null;`, UnitCargoLoader.java:142): the gate is INVERTED -- the loader consumes while NO unit is held (still building one) and stops consuming once a unit waits to be loaded. The field is `public @Nullable Unit unit;` (UnitCargoLoader.java:89) on UnitTransportSourceBuild (`public class UnitTransportSourceBuild extends Building implements UnitTetherBlock{`, UnitCargoLoader.java:84); UnitCargoLoader extends Block (UnitCargoLoader.java:23, `public class UnitCargoLoader extends Block{`), so the default (`return enabled;`, BuildingComp.java:755) does NOT apply here. Unlike the Separator/Drill gates this one has NO `&& enabled` -- Java returns the bare null check, so the pure gate does NOT read frame["enabled"] at all (the driver already runs the machinery only when enabled). The frame carries the unit (frame["unit"], default null for a frame bound before this slice -- the Java field is nullable); the updateTile advance is live (N2234) -- the pure advance (source_unit_cargo_loader_update_tile_advance_state) fills frame["unit"] from the found_unit param and from the spawn, so the gate closes the tick after a unit spawns (the advance runs after consumption, BuildingComp.java:2274/2276-2277, so the gate reads the pre-advance unit); the live Groups.unit.getByID fill still waits for its own slice (the driver passes found_unit null). When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The warmup fold (UnitCargoLoader.java:105, `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 60f);`) and the build advance (UnitCargoLoader.java:109, `buildProgress += edelta() / unitBuildTime;`) follow the folded efficiency; the unit build takes unitBuildTime 60f * 8f (`public float unitBuildTime = 60f * 8f;`, UnitCargoLoader.java:24-25). The def consumes power 8f/60f (`consumePower(8f / 60f);`, Blocks.java:2276) plus liquid nitrogen 10f/60f (`consumeLiquid(Liquids.nitrogen, 10f / 60f);`, Blocks.java:2279) -- the liquid row is live (N2249), so the folded efficiency is the min over power + liquid.
	var unit: Variant = frame.get("unit", null)
	return {"should_consume": unit == null, "has_unit": unit != null}

static func source_unit_cargo_loader_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a unit-cargo-loader does not take the early return. The warmup fold follows the folded efficiency (UnitCargoLoader.java:105, `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 60f);`), with the build advance (UnitCargoLoader.java:109, `buildProgress += edelta() / unitBuildTime;`) and the shouldConsume override (UnitCargoLoader.java:141-143, `return unit == null;`, default BuildingComp.java:755, `public boolean shouldConsume(){`) -- UnitTransportSourceBuild overrides shouldConsume() to return unit == null, so the default does not apply here; the shouldConsume gate is live (N2211) -- the pure gate (source_unit_cargo_loader_should_consume_state) feeds should_consume to the machinery from the frame unit key (null while building, non-null once a unit waits to be loaded); the updateTile advance is live (N2234) -- the pure advance fills frame["unit"] from the found_unit param and from the spawn, while the live Groups.unit.getByID fill still waits for its own slice. The unit-cargo-loader also consumes liquid nitrogen 10f/60f (Blocks.java:2279, `consumeLiquid(Liquids.nitrogen, 10f / 60f);`), so the folded efficiency is the min over power + liquid -- the liquid row is live (N2249).
	# Documented limits: (1) liquid row live (N2249) -- the unit-cargo-loader also consumes liquid nitrogen 10f/60f (Blocks.java:2279, `consumeLiquid(Liquids.nitrogen, 10f / 60f);`), so the folded efficiency is the min over power + liquid (source_unit_cargo_loader_liquid_consumer_row_state, ConsumeLiquid.efficiency ConsumeLiquid.java:42-47, with the second-pass removal ConsumeLiquid.java:37-39); the consumer's build/display rows (ConsumeLiquid.build ReqImage, ConsumeLiquid.java:31-34; display Stat.input, ConsumeLiquid.java:49-52) still defer. (2) shouldConsume gate live (N2211) -- UnitTransportSourceBuild overrides shouldConsume() to return unit == null (UnitCargoLoader.java:141-143, `return unit == null;`); the pure gate reads the frame unit key (default null) and feeds should_consume to the machinery; the updateTile advance is live (N2234) -- the pure advance fills frame["unit"] from the found_unit param and from the spawn, so the gate closes the tick after a unit spawns. (3) updateTile advance live (N2234) -- unit lost/destroyed / readUnitId / warmup / readyness / buildProgress / totalProgress / unit spawn (UnitCargoLoader.java:92-125) advance in the pure function (source_unit_cargo_loader_update_tile_advance_state), the warmup fold (UnitCargoLoader.java:105, `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 60f);`) and the build advance (UnitCargoLoader.java:109, `buildProgress += edelta() / unitBuildTime;`) following the folded efficiency; the live fill (Groups.unit.getByID query + Units.canCreate live cap check + live spawn application) still defers. (4) No canPlaceOn / bar / draw / read-write rows -- canPlaceOn (UnitCargoLoader.java:65-68), setBars (UnitCargoLoader.java:48-63), draw (UnitCargoLoader.java:146-162), read/write (UnitCargoLoader.java:174-188) are placement/presentation/serialization, not tick state. (5) Unit spawn pure result live (N2234) -- unitType manifold / unitBuildTime 60f * 8f (UnitCargoLoader.java:24-25, `public float unitBuildTime = 60f * 8f;`) and the spawn report (spawned_unit + buildProgress 0f, UnitCargoLoader.java:114-122/127-133) are modeled; the live application (unitType.create + unit.add + Call.unitTetherBlockSpawned + Fx.spawn) waits for its own slice.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_unit_cargo_loader_liquid_consumer_row_state(frame: Dictionary, has_liquid_consumer: bool, liquid_id: int, amount: float, source_delta: float, time_scale: float, efficiency_scale: float = 1.0, multiplier: float = 1.0) -> Dictionary:
	# ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47): the
	# liquid consumer's efficiency is the min-capped ratio of
	# the held liquid over what one tick needs, and the first
	# pass folds it into the min efficiency like every other
	# non-optional consumer (BuildingComp.java:1969-1976,
	# `for(var cons : block.nonOptionalConsumers){` /
	# `minEfficiency = Math.min(minEfficiency, result);`), with
	# a starved liquid row switching off power draw
	# (`if(cons != block.consPower && result <= 0.0000001f){`,
	# BuildingComp.java:1972 -- the shared fold does that from
	# is_power false, SourceBuildingEfficiencyState.gd:109-117).
	# The Java lines, each on ONE comment line (the N2148
	# lesson):
	# `float ed = build.edelta() * build.efficiencyScale();`
	# `if(ed <= 0.00000001f) return 0f;`
	# `return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);`
	# In the first pass efficiency is assumed 1f
	# (BuildingComp.java:1964, `//assume efficiency is 1 for
	# the calculations below`), so edelta() = delta() =
	# source_delta * time_scale (BuildingComp.java:1922-1929,
	# `return Time.delta * timeScale;` /
	# `return efficiency * delta();`). The multiplier defaults
	# to 1f (`public Floatf<Building> multiplier = b -> 1f;`,
	# Consume.java:18) and the def does NOT override it
	# (Blocks.java:2270-2283 has no multiplier call), so the
	# driver passes 1.0. The liquid amount comes from the
	# shared liquid module helper
	# (SourceLiquidModuleState.source_get_state, reused
	# through a preload, NOT re-implemented) over the frame
	# liquids key (the Building.liquids LiquidModule dict,
	# default {} for a frame bound before this slice), with
	# the Fracker guard (liquids.has("liquids") + the bounds
	# check, SourceFrackerBuildState.gd:141-142); Java's
	# liquids.get returns 0.0 for a liquid never added
	# (LiquidModule.java:102-104,
	# `return liquids[liquid.id];`). A block with no liquid
	# consumer contributes no row. The liquid consumer counts
	# toward hasConsumers (Block.java:1449,
	# `hasConsumers = consumers.length > 0;`), so a
	# unit-cargo-loader does not take the early return. The
	# second pass is NOT this function: ConsumeLiquid.update
	# (`build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));`,
	# ConsumeLiquid.java:37-39) runs only when
	# `boolean update = shouldConsume() && productionValid();`
	# (BuildingComp.java:1960) and `if(update && efficiency > 0){`
	# (BuildingComp.java:1999), with edelta from the FOLDED
	# efficiency -- the tick wires it as a direct removal
	# after apply_update_consumption_state through the shared
	# source_remove_state, which caps removal so the store
	# never goes negative (LiquidModule.java:125-128,
	# `add(liquid, Math.max(-amount, -liquids[liquid.id]));`).
	# The AdjacentFactory updates-actor precedent
	# (SourceAdjacentFactoryBuildState.gd:382) does NOT fit
	# here: it dispatches through RuntimeConsumer actors
	# carrying liquids/cache_sums/cost_multiplier +
	# source_delta/time_scale, and this driver has no actor
	# infrastructure (no frame "consumers" cache, no
	# cost_multiplier Callable). The def consumes nitrogen
	# 10f/60f (`consumeLiquid(Liquids.nitrogen, 10f / 60f);`,
	# Blocks.java:2279, the SECOND consumer), so the folded
	# efficiency is the min over power + liquid. The
	# function does NOT mutate its input frame.
	if not has_liquid_consumer:
		return {"has_liquid_row": false, "row": {}}
	var liquids: Dictionary = frame.get("liquids", {})
	var liquid_amount: float = 0.0
	if liquids.has("liquids") and liquid_id >= 0 and liquid_id < int(liquids["liquids"].size()):
		liquid_amount = float(source_liquid_module_state.source_get_state(liquids, liquid_id).get("amount", 0.0))
	var edelta: float = source_delta * time_scale
	var ed: float = edelta * efficiency_scale
	if ed <= 0.00000001:
		return {"has_liquid_row": true, "row": {"result": 0.0, "is_power": false}}
	var result: float = minf(liquid_amount / (amount * ed * multiplier), 1.0)
	return {"has_liquid_row": true, "row": {"result": result, "is_power": false}}

static func source_unit_cargo_loader_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, found_unit: Variant = null, can_create: bool = true) -> Dictionary:
	# The updateTile advance (UnitTransportSourceBuild.updateTile(),
	# UnitCargoLoader.java:92-125), the pure frame advance -- the
	# build fields are `public int readUnitId = -1;`
	# (UnitCargoLoader.java:86), `public float buildProgress, totalProgress;`
	# (UnitCargoLoader.java:87), `public float warmup, readyness;`
	# (UnitCargoLoader.java:88) and `public @Nullable Unit unit;`
	# (UnitCargoLoader.java:89), and the advance follows the Java
	# lines in order (each exact expr on ONE comment line, the
	# N2148 lesson):
	# `if(unit != null && (unit.dead || !unit.isAdded())){`
	# `unit = null;`
	# `if(readUnitId != -1){`
	# `unit = Groups.unit.getByID(readUnitId);`
	# `if(unit != null || !net.client()){`
	# `readUnitId = -1;`
	# `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 60f);`
	# `readyness = Mathf.approachDelta(readyness, unit != null ? 1f : 0f, 1f / 60f);`
	# `if(unit == null && Units.canCreate(team, unitType)){`
	# `buildProgress += edelta() / unitBuildTime;`
	# `totalProgress += edelta();`
	# `if(buildProgress >= 1f){`
	# `if(!net.client()){`
	# `unit = unitType.create(team);`
	# `if(unit instanceof BuildingTetherc bt){`
	# `bt.building(this);`
	# `unit.set(x, y);`
	# `unit.rotation = 90f;`
	# `unit.add();`
	# `Call.unitTetherBlockSpawned(tile, unit.id);`
	# `public void spawned(int id){`
	# `Fx.spawn.at(x, y);`
	# `buildProgress = 0f;`
	# `if(net.client()){`
	# `readUnitId = id;`
	# The Arc formula, not a guess: approachDelta(from, to,
	# speed) = approach(from, to, Time.delta * speed) with
	# approach = from + clamp(to - from, -speed, speed)
	# (Mathf.java:208, 415-427), via the shared
	# source_math_state.source_approach_delta helper.
	# source_delta is Time.delta in ticks (seconds * 60 through
	# game_source_delta, arc Time.java:26); edelta() =
	# efficiency * delta() with delta() = Time.delta *
	# timeScale (BuildingComp.java:1922-1929, `return Time.delta * timeScale;`
	# / `return efficiency * delta();`). efficiency defaults 0.0,
	# the Java field default (BuildingComp.java:85
	# `transient float efficiency;`); read_unit_id defaults -1,
	# build_progress / total_progress / warmup / readyness
	# default 0.0, unit defaults null (UnitCargoLoader.java:
	# 86-89). The def values are driver constants (single def --
	# unit-cargo-loader): `public UnitType unitType = UnitTypes.manifold;`
	# (UnitCargoLoader.java:24, the def does NOT override it),
	# `public float unitBuildTime = 60f * 8f;`
	# (UnitCargoLoader.java:25, restated by the def,
	# `unitBuildTime = 60f * 8f;`, Blocks.java:2273) and the
	# spawn rotation 90f (UnitCargoLoader.java:119). The def
	# also consumes liquid nitrogen 10f/60f
	# (`consumeLiquid(Liquids.nitrogen, 10f / 60f);`,
	# Blocks.java:2279, the SECOND consumer) -- the liquid row
	# is live (N2249), so the folded efficiency is the min
	# over power + liquid. Scoping decisions, all
	# source-backed: (1) the live Groups.unit query
	# (UnitCargoLoader.java:99) has no helper in the port, so
	# the found unit arrives as the explicit found_unit param
	# (dict or null, default null); the driver passes null
	# until the live fill lands. The port is single-player
	# (net_client defaults false everywhere --
	# SourceBuildingPayloadState.gd:115,
	# SourcePuddlesDepositState.gd:11 -- and no net layer exists
	# in godot-mindustry/src), so !net.client() is always true:
	# a null found_unit still clears readUnitId
	# (UnitCargoLoader.java:100-101), and the spawn always
	# takes the server branch (unit created at once,
	# buildProgress 0f; the client branch readUnitId = id,
	# UnitCargoLoader.java:130-131, never applies). (2)
	# Units.canCreate is a live cap check --
	# `public static boolean canCreate(Team team, UnitType type){`
	# with `return !type.useUnitCap || (team.data().countType(type) < getCap(team) && !type.isBanned());`
	# (Units.java:115-117) -- and manifold keeps the UnitType
	# default `useUnitCap = true,` (UnitType.java:205; the
	# useUnitCap = false at UnitTypes.java:4612 belongs to
	# assemblyDrone, NOT manifold), so the check is live, not
	# vacuous; it arrives as the explicit can_create param
	# (default true) and the driver passes true until the N2140
	# live helper is wired for this family. (3) the spawn is a
	# pure result (the N2228 `consumed` precedent): spawned_unit
	# is {type: manifold, x, y, rotation: 90} plus the unit-dict
	# contract flags (dead false, added true) when buildProgress
	# reaches 1f, else null; the frame unit becomes the spawned
	# unit and buildProgress resets to 0f via spawned()
	# (UnitCargoLoader.java:127-133, server branch). The live
	# application -- unitType.create + BuildingTetherc
	# building(this) + unit.set/add + Call.unitTetherBlockSpawned
	# + Fx.spawn -- defers: no live unit entity is created.
	# (4) the unit dict contract is {type, x, y, rotation, dead
	# (default false), added (default true)}; a non-dict unit
	# has no readable flags and is kept (defensive -- the N2211
	# gate only reads null-ness, so the {"type": "dart"} fixture
	# keeps working). (5) x/y arrive as frame inputs (default
	# 0.0, the building world position Java reads in unit.set(x,
	# y)); the driver does not stamp them live yet -- the live
	# spawn application defers. (6) the shouldConsume gate
	# (`public boolean shouldConsume(){` with `return unit == null;`,
	# UnitCargoLoader.java:141-142) is INVERTED and live (N2211):
	# the advance runs after consumption (BuildingComp.java:2274
	# updateConsumption(), then the updateTile gate
	# `if(enabled || !block.noUpdateDisabled){` at
	# BuildingComp.java:2276-2277), so the gate reads the
	# pre-advance unit and closes the tick AFTER a unit spawns.
	# The function does NOT mutate its input frame.
	var unit: Variant = frame.get("unit", null)
	if unit != null and unit is Dictionary and (bool(unit.get("dead", false)) or not bool(unit.get("added", true))):
		unit = null
	var read_unit_id: int = int(frame.get("read_unit_id", -1))
	if read_unit_id != -1:
		unit = found_unit
		read_unit_id = -1
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var warmup: float = source_math_state.source_approach_delta(float(frame.get("warmup", 0.0)), efficiency, SOURCE_UNIT_CARGO_LOADER_WARMUP_SPEED, source_delta)
	var readyness: float = source_math_state.source_approach_delta(float(frame.get("readyness", 0.0)), 1.0 if unit != null else 0.0, SOURCE_UNIT_CARGO_LOADER_WARMUP_SPEED, source_delta)
	var build_progress: float = float(frame.get("build_progress", 0.0))
	var total_progress: float = float(frame.get("total_progress", 0.0))
	var spawned_unit: Variant = null
	if unit == null and can_create:
		var edelta: float = efficiency * source_delta * time_scale
		build_progress += edelta / SOURCE_UNIT_CARGO_LOADER_UNIT_BUILD_TIME
		total_progress += edelta
		if build_progress >= 1.0:
			spawned_unit = {"type": SOURCE_UNIT_CARGO_LOADER_UNIT_TYPE, "x": float(frame.get("x", 0.0)), "y": float(frame.get("y", 0.0)), "rotation": SOURCE_UNIT_CARGO_LOADER_SPAWN_ROTATION, "dead": false, "added": true}
			unit = spawned_unit
			build_progress = 0.0
	return {"unit": unit, "read_unit_id": read_unit_id, "warmup": warmup, "readyness": readyness, "build_progress": build_progress, "total_progress": total_progress, "spawned_unit": spawned_unit}

@warning_ignore("unused_parameter")
static func source_unit_cargo_loader_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the unit-cargo-loader tick wiring every
	# tick (UnitTransportSourceBuild.updateTile(), UnitCargoLoader.java:92,
	# gates on the warmup fold (UnitCargoLoader.java:105, `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 60f);`) with the build advance (UnitCargoLoader.java:109, `buildProgress += edelta() / unitBuildTime;`), so the warmup fold follows the folded efficiency; no placed-buildings driver ticks UnitCargoLoader blocks, so this driver is the placed-unit-cargo-loader tick): each placed UnitCargoLoader build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_unit_cargo_loader_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_unit_cargo_loader_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_unit_cargo_loader_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The frame carries the Building.liquids LiquidModule
		# (frame["liquids"]): the live store lives on the
		# sprite meta (source_building_liquids, initialized
		# at placement), so the driver syncs the reference
		# into the frame each tick BEFORE the fold, and the
		# pure liquid row reads the nitrogen amount from it
		# (the Fracker:327 precedent).
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60
		# (arc Time.java:26), never raw seconds. timeScale
		# reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`). The liquid row
		# (first pass, efficiency assumed 1f), the second-pass
		# removal (folded efficiency) and the updateTile
		# advance all read them.
		var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
		var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a unit-cargo-loader with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the warmup fold (UnitCargoLoader.java:105)
		# follows it. The liquid consumer reads live since N2249:
		# a unit-cargo-loader with a liquid consumer folds the pure
		# liquid row into the same first pass
		# (ConsumeLiquid.efficiency, ConsumeLiquid.java:42-47),
		# so the folded efficiency is the min over power +
		# liquid. Both consumers count toward hasConsumers
		# (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a unit-cargo-loader does not take the early return, and the machinery gate below is (power or liquid). A unit-cargo-loader with neither consumer is untouched, and UnitTransportSourceBuild overrides shouldConsume() to return unit == null (UnitCargoLoader.java:141-143) -- N2211 feeds the live gate to the machinery (the pure gate is source_unit_cargo_loader_should_consume_state, fed the frame); the N2165 RED decision is resolved. The gate has no enabled term (Java returns the bare null check); the outer guard below already runs the machinery only when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		var has_liquid_consumer: bool = bool(block.properties.has("consumeLiquid"))
		if (has_power_consumer or has_liquid_consumer) and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_unit_cargo_loader_should_consume_state(frame)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_unit_cargo_loader_power_status_row_state(frame, has_power_consumer)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			# N2249: the liquid row joins the same first pass.
			# The nitrogen id resolves from the catalog
			# liquid_id_by_name with the def constant (the
			# Fracker precedent); the multiplier is the
			# Consume default 1f (Consume.java:18,
			# `public Floatf<Building> multiplier = b -> 1f;`)
			# -- the def does NOT override it
			# (Blocks.java:2270-2283 has no multiplier call).
			var liquid_id_by_name: Dictionary = source_content_registry_runtime_state.source_liquid_catalog_state(catalog).get("liquid_id_by_name", {})
			var nitrogen_id: int = int(liquid_id_by_name.get(SOURCE_UNIT_CARGO_LOADER_CONSUMED_LIQUID, -1))
			var liquid_multiplier: float = 1.0
			var liquid_row: Dictionary = source_unit_cargo_loader_liquid_consumer_row_state(frame, has_liquid_consumer, nitrogen_id, SOURCE_UNIT_CARGO_LOADER_LIQUID_AMOUNT, source_delta, time_scale, float(frame.get("efficiency_scale", 1.0)), liquid_multiplier)
			var liquid_row_live: bool = bool(liquid_row.get("has_liquid_row", false))
			if liquid_row_live:
				required_results.append(liquid_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# N2249 second pass: ConsumeLiquid.update removes
			# amount * edelta * multiplier
			# (`build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));`,
			# ConsumeLiquid.java:37-39) only when
			# `if(update && efficiency > 0){`
			# (BuildingComp.java:1999), with edelta from the
			# FOLDED efficiency (not the first-pass 1f
			# assumption). Direct removal after
			# apply_update_consumption_state through the
			# shared source_remove_state (the PayloadLoader
			# cache_sums precedent) -- the AdjacentFactory
			# updates-actor precedent does not fit this
			# driver (no RuntimeConsumer actor
			# infrastructure); the removal caps at the held
			# amount so the store never goes negative
			# (LiquidModule.java:125-128).
			var frame_liquids: Dictionary = frame.get("liquids", {})
			if liquid_row_live and should_consume and valid and float(frame.get("efficiency", 0.0)) > 0.0 and frame_liquids.has("liquids") and nitrogen_id >= 0 and nitrogen_id < int(frame_liquids["liquids"].size()):
				var folded_edelta: float = float(frame.get("efficiency", 0.0)) * source_delta * time_scale
				var remove_amount: float = SOURCE_UNIT_CARGO_LOADER_LIQUID_AMOUNT * folded_edelta * liquid_multiplier
				var cache_sums: Array = []
				cache_sums.resize(int((frame_liquids["liquids"] as Array).size()))
				cache_sums.fill(0.0)
				source_liquid_module_state.source_remove_state(frame_liquids, nitrogen_id, remove_amount, cache_sums)
		# N2234: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277; noUpdateDisabled defaults
		# false, Block.java:170, so Java runs updateTile even
		# when disabled -- in Java a disabled unit-cargo-loader's
		# warmup DECAYS toward 0 (efficiency is zeroed by the
		# disabled early return, BuildingComp.java:1954-1957)
		# and the build freezes (edelta() is 0). The port
		# keeps the enabled gate below as a pragmatic choice
		# (the N2195 coordinator-fix precedent): the driver
		# skips the consumption fold when disabled, so the frame
		# efficiency goes stale and running the advance on it
		# would charge warmup/build from a stale efficiency.
		# The driver-wide disabled-early-return slice (deferred
		# in the N2234 register) removes this gate for all
		# families. super.updateTile() is an empty no-op
		# (BuildingComp.java:2010-2012), so the driver owes it
		# nothing. The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60
		# (arc Time.java:26), never raw seconds. timeScale
		# reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`). The driver passes
		# the found_unit / can_create defaults (null / true): no
		# live Groups.unit fill and no live cap check yet (the
		# N2234 live-fill deferrals). The gate reads the
		# pre-advance unit (consumption runs first), so a spawn
		# closes the INVERTED shouldConsume gate the NEXT tick --
		# and a spawn needs buildProgress >= 1f, i.e. 480 ticks
		# at full efficiency, so a single tick never spawns.
		if bool(frame.get("enabled", true)):
			var advanced: Dictionary = source_unit_cargo_loader_update_tile_advance_state(frame, source_delta, time_scale)
			frame["unit"] = advanced["unit"]
			frame["read_unit_id"] = advanced["read_unit_id"]
			frame["warmup"] = advanced["warmup"]
			frame["readyness"] = advanced["readyness"]
			frame["build_progress"] = advanced["build_progress"]
			frame["total_progress"] = advanced["total_progress"]
			frame["spawned_unit"] = advanced["spawned_unit"]
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
