extends RefCounted
class_name SourceUnitCargoLoaderBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

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
	return {"unit": null, "read_unit_id": -1, "build_progress": 0.0, "total_progress": 0.0, "warmup": 0.0, "readyness": 0.0}

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
	# UnitTransportSourceBuild overrides shouldConsume (UnitCargoLoader.java:141, `public boolean shouldConsume(){` with `return unit == null;`, UnitCargoLoader.java:142): the gate is INVERTED -- the loader consumes while NO unit is held (still building one) and stops consuming once a unit waits to be loaded. The field is `public @Nullable Unit unit;` (UnitCargoLoader.java:89) on UnitTransportSourceBuild (`public class UnitTransportSourceBuild extends Building implements UnitTetherBlock{`, UnitCargoLoader.java:84); UnitCargoLoader extends Block (UnitCargoLoader.java:23, `public class UnitCargoLoader extends Block{`), so the default (`return enabled;`, BuildingComp.java:755) does NOT apply here. Unlike the Separator/Drill gates this one has NO `&& enabled` -- Java returns the bare null check, so the pure gate does NOT read frame["enabled"] at all (the driver already runs the machinery only when enabled). The frame carries the unit (frame["unit"], default null for a frame bound before this slice -- the Java field is nullable); the updateTile advance is live (N2234) -- the pure advance (source_unit_cargo_loader_update_tile_advance_state) fills frame["unit"] from the found_unit param and from the spawn, so the gate closes the tick after a unit spawns (the advance runs after consumption, BuildingComp.java:2274/2276-2277, so the gate reads the pre-advance unit); the live Groups.unit.getByID fill still waits for its own slice (the driver passes found_unit null). When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The warmup fold (UnitCargoLoader.java:105, `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 60f);`) and the build advance (UnitCargoLoader.java:109, `buildProgress += edelta() / unitBuildTime;`) follow the folded efficiency; the unit build takes unitBuildTime 60f * 8f (`public float unitBuildTime = 60f * 8f;`, UnitCargoLoader.java:24-25). The def consumes power 8f/60f (`consumePower(8f / 60f);`, Blocks.java:2276) plus liquid nitrogen 10f/60f (`consumeLiquid(Liquids.nitrogen, 10f / 60f);`, Blocks.java:2279) -- the liquid row waits for its own slice.
	var unit: Variant = frame.get("unit", null)
	return {"should_consume": unit == null, "has_unit": unit != null}

static func source_unit_cargo_loader_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a unit-cargo-loader does not take the early return. The warmup fold follows the folded efficiency (UnitCargoLoader.java:105, `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 60f);`), with the build advance (UnitCargoLoader.java:109, `buildProgress += edelta() / unitBuildTime;`) and the shouldConsume override (UnitCargoLoader.java:141-143, `return unit == null;`, default BuildingComp.java:755, `public boolean shouldConsume(){`) -- UnitTransportSourceBuild overrides shouldConsume() to return unit == null, so the default does not apply here; the shouldConsume gate is live (N2211) -- the pure gate (source_unit_cargo_loader_should_consume_state) feeds should_consume to the machinery from the frame unit key (null while building, non-null once a unit waits to be loaded); the updateTile advance is live (N2234) -- the pure advance fills frame["unit"] from the found_unit param and from the spawn, while the live Groups.unit.getByID fill still waits for its own slice. The unit-cargo-loader also consumes liquid nitrogen 10f/60f (Blocks.java:2279, `consumeLiquid(Liquids.nitrogen, 10f / 60f);`), so the folded efficiency is the min over the *modeled* consumers (power only); the liquid row waits for its own slice.
	# Documented limits: (1) power-only first pass -- the unit-cargo-loader also consumes liquid nitrogen 10f/60f (Blocks.java:2279, `consumeLiquid(Liquids.nitrogen, 10f / 60f);`), so the folded efficiency is the min over the *modeled* consumers (power only); the liquid row waits for its own slice. (2) shouldConsume gate live (N2211) -- UnitTransportSourceBuild overrides shouldConsume() to return unit == null (UnitCargoLoader.java:141-143, `return unit == null;`); the pure gate reads the frame unit key (default null) and feeds should_consume to the machinery; the updateTile advance is live (N2234) -- the pure advance fills frame["unit"] from the found_unit param and from the spawn, so the gate closes the tick after a unit spawns. (3) updateTile advance live (N2234) -- unit lost/destroyed / readUnitId / warmup / readyness / buildProgress / totalProgress / unit spawn (UnitCargoLoader.java:92-125) advance in the pure function (source_unit_cargo_loader_update_tile_advance_state), the warmup fold (UnitCargoLoader.java:105, `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 60f);`) and the build advance (UnitCargoLoader.java:109, `buildProgress += edelta() / unitBuildTime;`) following the folded efficiency; the live fill (Groups.unit.getByID query + Units.canCreate live cap check + live spawn application) still defers. (4) No canPlaceOn / bar / draw / read-write rows -- canPlaceOn (UnitCargoLoader.java:65-68), setBars (UnitCargoLoader.java:48-63), draw (UnitCargoLoader.java:146-162), read/write (UnitCargoLoader.java:174-188) are placement/presentation/serialization, not tick state. (5) Unit spawn pure result live (N2234) -- unitType manifold / unitBuildTime 60f * 8f (UnitCargoLoader.java:24-25, `public float unitBuildTime = 60f * 8f;`) and the spawn report (spawned_unit + buildProgress 0f, UnitCargoLoader.java:114-122/127-133) are modeled; the live application (unitType.create + unit.add + Call.unitTetherBlockSpawned + Fx.spawn) waits for its own slice.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

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
	# Blocks.java:2279, the SECOND consumer) -- NOT this slice;
	# the folded efficiency stays the min over the modeled
	# consumers (power only). Scoping decisions, all
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
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a unit-cargo-loader with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the warmup fold (UnitCargoLoader.java:105)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a unit-cargo-loader does not take the early return. A unit-cargo-loader with no power consumer is untouched: the tick models no other consumers yet (the liquid consumer row waits for its own slice), and UnitTransportSourceBuild overrides shouldConsume() to return unit == null (UnitCargoLoader.java:141-143) -- N2211 feeds the live gate to the machinery (the pure gate is source_unit_cargo_loader_should_consume_state, fed the frame); the N2165 RED decision is resolved. The gate has no enabled term (Java returns the bare null check); the outer guard below already runs the machinery only when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_unit_cargo_loader_should_consume_state(frame)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_unit_cargo_loader_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
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
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
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
