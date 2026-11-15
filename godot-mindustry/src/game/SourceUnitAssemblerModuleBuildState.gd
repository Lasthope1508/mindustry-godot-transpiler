extends RefCounted
class_name SourceUnitAssemblerModuleBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

# The UnitAssemblerModule implementation (UnitAssemblerModule.java:18, `public class UnitAssemblerModule extends PayloadBlock{`): basic-assembler-module (consumePower 3.5f, Blocks.java:6568, `consumePower(3.5f);`; size 5, tier 1, UnitAssemblerModule.java:22, `public int tier = 1;`). UnitAssemblerModule sets acceptsPayload=true (UnitAssemblerModule.java:27, `acceptsPayload = true;`), and its build extends PayloadBlockBuild<Payload> (UnitAssemblerModule.java:71, `public class UnitAssemblerModuleBuild extends PayloadBlockBuild<Payload>{`). The module finds its linked assembler on tileChanges (UnitAssemblerModule.java:79, `link = getLink(team, tile.x, tile.y, rotation);`) and forwards its payload when the forward gate holds (UnitAssemblerModule.java:138, `if(moveInPayload() && link != null && link.moduleFits(block, x, y, rotation) && !link.wasOccupied && link.acceptPayload(this, payload) && efficiency > 0){`). UnitAssemblerModule extends PayloadBlock, NOT UnitAssembler, so it cannot reuse the unit-factory driver (implementations ["UnitFactory", "Reconstructor", "UnitAssembler"], SourceUnitFactoryBuildState.gd:31); this driver uses its own family frame key ("source_unit_assembler_module_building", the payload-deconstructor precedent), and this slice adds the unit-assembler-module key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The module has NO shouldConsume override, so the BuildingComp default (BuildingComp.java:755, `public boolean shouldConsume(){`) applies. The port has NO SourceUnitAssemblerModule* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the forward gate (UnitAssemblerModule.java:138) follows the folded efficiency.
const SOURCE_UNIT_ASSEMBLER_MODULE_BUILD_IMPLEMENTATIONS := ["UnitAssemblerModule"]
const SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY := "source_unit_assembler_module_building"
# payloadSpeed 0.7f and payloadRotateSpeed 5f are the PayloadBlock class
# defaults (PayloadBlock.java:18, `public float payloadSpeed = 0.7f,
# payloadRotateSpeed = 5f;`); the module does not override them. The
# arrival margin is the hasArrived isZero(0.01f) squared-length margin
# (PayloadBlock.java:242-244, Vec2.java:679-681, `return len2() < margin;`).
const SOURCE_UNIT_ASSEMBLER_MODULE_PAYLOAD_SPEED := 0.7
const SOURCE_UNIT_ASSEMBLER_MODULE_PAYLOAD_ROTATE_SPEED := 5.0
const SOURCE_UNIT_ASSEMBLER_MODULE_ARRIVAL_MARGIN := 0.01

static func _is_unit_assembler_module_build_implementation(implementation: String) -> bool:
	return SOURCE_UNIT_ASSEMBLER_MODULE_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_unit_assembler_module_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The unit-assembler-module tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (UnitAssemblerModule.java:18, `public class UnitAssemblerModule extends PayloadBlock{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# unit-assembler-module skips consumption like Java's updateConsumption
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
	# for this unit-assembler-module (N2125); the tick preserves a disabled
	# unit-assembler-module instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# The fresh frame binds the Java build-field defaults:
	# `public UnitAssemblerBuild link;` (UnitAssemblerModule.java:72,
	# null until the first findLink), `public int lastChange = -2;`
	# (UnitAssemblerModule.java:73), the held payload
	# (`public @Nullable T payload;`, PayloadBlock.java:92), the payload
	# offset (`public Vec2 payVector = new Vec2();`, PayloadBlock.java:94)
	# and `public float payRotation;` (PayloadBlock.java:95). The frame
	# inputs (tile_changes, link_candidate, module_fits, was_occupied,
	# accept_payload, rotation) are NOT bound here: the advance reads
	# them with frame.get defaults (1 / null / false / false / false /
	# 0), the N2228 regen-projector precedent.
	return {"link": null, "last_change": -2, "payload": null, "pay_vector": Vector2.ZERO, "pay_rotation": 0.0}

static func source_unit_assembler_module_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the unit-assembler-module frame meta key
	# ("source_unit_assembler_module_building"). A UnitAssemblerModule sprite gets a
	# frame bound with the Java build-field defaults (link null /
	# last_change -2 / payload null / pay_vector zero / pay_rotation 0,
	# N2248); the live-loop tick fills its other keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_unit_assembler_module_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_unit_assembler_module_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a unit-assembler-module does not take the early return. The forward gate follows the folded efficiency (UnitAssemblerModule.java:138, `if(moveInPayload() && link != null && link.moduleFits(block, x, y, rotation) && !link.wasOccupied && link.acceptPayload(this, payload) && efficiency > 0){`) and the module has no shouldConsume override, so the default (BuildingComp.java:755, `public boolean shouldConsume(){`) applies -- the row folds under the live default, not the MendProjector-suppression precedent. The basic-assembler-module (consumePower 3.5f, Blocks.java:6568, `consumePower(3.5f);`) has no liquid consumer, so the folded efficiency is the min over the *modeled* consumers (power only).
	# Documented limits: (1) power-only first pass -- the module has no liquid/item consumer, so the folded efficiency is the min over the *modeled* consumers (power only). (2) shouldConsume default applies -- the module has no override; the machinery runs with should_consume=true when enabled. (3) updateTile advance live (N2248) -- the lastChange refresh + findLink re-discovery + moveInPayload + the handoff gate (UnitAssemblerModule.java:132-141) run in source_unit_assembler_module_update_tile_advance_state; the N2168 proof still carries no link/payload/tier keys (the efficiency > 0 gate (UnitAssemblerModule.java:138) is what the efficiency keys prove) while the N2248 proof carries the link/payload keys. The getLink discovery, the removeModule / updateModules side effects, the live predicate evaluation, the handoff-to-intake wiring, and the live payload fill wait for their own slices -- see DEFERRED. (4) No link/tier/canPlaceOn/draw/acceptPayload/onRemoved rows -- see DEFERRED. (5) No variant verification -- there is only one module def (basic-assembler-module).
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func _unit_assembler_module_vec2_approach(pay_vector: Vector2, alpha: float) -> Vector2:
	# Vec2.approach(Vec2 target, float alpha) (Vec2.java:525-537),
	# target Vec2.ZERO here (PayloadBlock.java:194,
	# `payVector.approach(Vec2.ZERO, payloadSpeed * delta());`).
	# `float dx = x - target.x, dy = y - target.y;`
	# `float alpha2 = alpha*alpha;`
	# `float len2 = Mathf.len2(dx, dy);`
	# `if(len2 > alpha2){` scales the offset by
	# `float scl = Mathf.sqrt(alpha2 / len2);` and subtracts it, else
	# `return set(target);` snaps to the target.
	var dx: float = pay_vector.x
	var dy: float = pay_vector.y
	var alpha2: float = alpha * alpha
	var len2: float = dx * dx + dy * dy
	if len2 > alpha2:
		var scl: float = sqrt(alpha2 / len2)
		return Vector2(pay_vector.x - dx * scl, pay_vector.y - dy * scl)
	return Vector2.ZERO

static func _unit_assembler_module_move_in_payload(pay_vector: Vector2, pay_rotation: float, rotation_degrees: float, delta: float) -> Dictionary:
	# PayloadBlockBuild.moveInPayload(true)
	# (PayloadBlock.java:181-197, the no-arg call delegates:
	# `public boolean moveInPayload(){`
	# `return moveInPayload(true);`
	# `public boolean moveInPayload(boolean rotate){`
	# `if(payload == null) return false;`
	# -- the caller checks the payload first, so this helper only
	# runs with a payload present. `updatePayload();` (:189) sets
	# the live payload position
	# `payload.set(x + payVector.x, y + payVector.y, payRotation);`
	# (PayloadBlock.java:174-177) -- DEFERRED, the port's payload
	# dict carries no position. rotate is TRUE here (unlike the
	# deconstructor's moveInPayload(false), N2233), so the
	# rotation branch runs:
	# `payRotation = Angles.moveToward(payRotation, block.rotate ? rotdeg() : 90f, payloadRotateSpeed * delta());`
	# -- the module rotates (UnitAssemblerModule.java:26,
	# `rotate = true;`), so the target is rotdeg()
	# `public float rotdeg(){`
	# `return rotation * 90;`
	# (BuildingComp.java:582-584), passed in as rotation_degrees.
	# `payVector.approach(Vec2.ZERO, payloadSpeed * delta());`
	# `return hasArrived();`
	# `return payVector.isZero(0.01f);`
	# (PayloadBlock.java:242-244, Vec2.java:679-681)
	# `return len2() < margin;`
	# -- the SQUARED length, not the length. payloadSpeed 0.7f
	# and payloadRotateSpeed 5f are the PayloadBlock class
	# defaults
	# `public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;`
	# (PayloadBlock.java:18); the module does not override them.
	var moved_rotation: float = source_math_state.source_angles_move_toward(pay_rotation, rotation_degrees, SOURCE_UNIT_ASSEMBLER_MODULE_PAYLOAD_ROTATE_SPEED * delta)
	var moved: Vector2 = _unit_assembler_module_vec2_approach(pay_vector, SOURCE_UNIT_ASSEMBLER_MODULE_PAYLOAD_SPEED * delta)
	return {"pay_vector": moved, "pay_rotation": moved_rotation, "arrived": moved.length_squared() < SOURCE_UNIT_ASSEMBLER_MODULE_ARRIVAL_MARGIN}

static func source_unit_assembler_module_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float) -> Dictionary:
	# The updateTile advance (UnitAssemblerModuleBuild.updateTile(),
	# UnitAssemblerModule.java:132-141), the pure frame advance -- the
	# build fields are `public UnitAssemblerBuild link;`
	# (UnitAssemblerModule.java:72), `public int lastChange = -2;`
	# (UnitAssemblerModule.java:73), the held payload
	# (`public @Nullable T payload;`, PayloadBlock.java:92), the payload
	# offset (`public Vec2 payVector = new Vec2();`, PayloadBlock.java:94)
	# and `public float payRotation;` (PayloadBlock.java:95), and the
	# advance follows the Java lines in order (each exact expr on ONE
	# comment line, the N2148 lesson):
	# `if(lastChange != world.tileChanges){`
	# `lastChange = world.tileChanges;`
	# `findLink();` -- `public void findLink(){`
	# (UnitAssemblerModule.java:75-83):
	# `link.removeModule(this);` -- DEFERRED, a side effect on the
	# assembler object (the port has no assembler object here).
	# `link = getLink(team, tile.x, tile.y, rotation);`
	# -- the getLink discovery
	# `public @Nullable UnitAssemblerBuild getLink(Team team, int x, int y, int rotation){`
	# `var results = Vars.indexer.getFlagged(team, BlockFlag.unitAssembler).<UnitAssemblerBuild>as();`
	# `return results.find(b -> b.moduleFits(this, x * tilesize + offset, y * tilesize + offset, rotation));`
	# (UnitAssemblerModule.java:65-69) has no live building query in
	# the port, so the candidate arrives as the frame input
	# link_candidate (the getLink result: an assembler link ref dict,
	# or null when nothing fits; default null).
	# `link.updateModules(this);` -- DEFERRED, a side effect on the
	# assembler object.
	# `if(moveInPayload() && link != null && link.moduleFits(block, x, y, rotation) && !link.wasOccupied && link.acceptPayload(this, payload) && efficiency > 0){`
	# `link.yeetPayload(payload);`
	# `payload = null;`
	# -- moduleFits (`public boolean moduleFits(Block other, float ox, float oy, int rotation){`,
	# UnitAssembler.java:338), wasOccupied (`public boolean wasOccupied = false;`,
	# UnitAssembler.java:328) and acceptPayload are explicit frame
	# predicates (defaults false / false / false, the safe
	# no-assembler values); the live evaluation needs the assembler
	# object and defers. yeetPayload is the assembler-side receive
	# (`public void yeetPayload(Payload payload){`,
	# UnitAssembler.java:688-695, `blocks.add(payload.content(), 1);`),
	# already ported as the N2131 intake state -- the module side
	# only clears its payload and reports handed_off; the wiring
	# that feeds a handed-off payload into the assembler intake
	# waits for its own slice. moveInPayload() is evaluated FIRST
	# (Java && short-circuit), so the payVector / payRotation
	# advance runs on every tick with a payload, even when the rest
	# of the gate fails; this function keeps that order (the
	# _unit_assembler_module_move_in_payload helper,
	# PayloadBlock.java:181-197, rotate=true). delta() is
	# `return Time.delta * timeScale;`
	# (BuildingComp.java:1922-1924); source_delta is Time.delta in
	# ticks (seconds * 60 through game_source_delta, arc
	# Time.java:26), never raw seconds. tile_changes is the frame
	# input (default 1, `public int tileChanges = 1, floorChanges = 1;`,
	# World.java:35) against lastChange -2, so the first tick
	# refreshes (the N2228 RegenProjector precedent). efficiency
	# defaults 0.0, the Java field default (BuildingComp.java:85
	# `transient float efficiency;`). The function does NOT mutate
	# its input frame.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var tile_changes: int = int(frame.get("tile_changes", 1))
	var last_change: int = int(frame.get("last_change", -2))
	var link: Variant = frame.get("link", null)
	var link_refreshed := false
	if last_change != tile_changes:
		last_change = tile_changes
		link_refreshed = true
		link = frame.get("link_candidate", null)
	var payload: Variant = frame.get("payload", null)
	var pay_vector: Vector2 = frame.get("pay_vector", Vector2.ZERO)
	var pay_rotation: float = float(frame.get("pay_rotation", 0.0))
	var moved_in := false
	if payload != null:
		var delta: float = source_delta * time_scale
		var rotation_degrees: float = float(int(frame.get("rotation", 0))) * 90.0
		var moved: Dictionary = _unit_assembler_module_move_in_payload(pay_vector, pay_rotation, rotation_degrees, delta)
		pay_vector = moved["pay_vector"]
		pay_rotation = moved["pay_rotation"]
		moved_in = bool(moved["arrived"])
	var handed_off := false
	if moved_in and link != null and bool(frame.get("module_fits", false)) and not bool(frame.get("was_occupied", false)) and bool(frame.get("accept_payload", false)) and efficiency > 0.0:
		payload = null
		handed_off = true
	return {"last_change": last_change, "link": link, "link_refreshed": link_refreshed, "pay_vector": pay_vector, "pay_rotation": pay_rotation, "moved_in": moved_in, "payload": payload, "handed_off": handed_off}

@warning_ignore("unused_parameter")
static func source_unit_assembler_module_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the unit-assembler-module tick wiring every
	# tick (UnitAssemblerModuleBuild.updateTile(), UnitAssemblerModule.java:132,
	# gates on the forward gate (UnitAssemblerModule.java:138, `if(moveInPayload() && link != null && link.moduleFits(block, x, y, rotation) && !link.wasOccupied && link.acceptPayload(this, payload) && efficiency > 0){`), so the forward follows the folded efficiency; no placed-buildings driver ticks UnitAssemblerModule blocks, so this driver is the placed-unit-assembler-module tick): each placed UnitAssemblerModule build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_unit_assembler_module_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_unit_assembler_module_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_unit_assembler_module_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a unit-assembler-module with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the forward gate (UnitAssemblerModule.java:138)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a unit-assembler-module does not take the early return. A unit-assembler-module with no power consumer is untouched: the tick models no other consumers yet (the module has no liquid consumer), and there is no shouldConsume override (BuildingComp.java:755, `public boolean shouldConsume(){`), so the machinery runs with should_consume=true when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_unit_assembler_module_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# N2248: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277; noUpdateDisabled defaults
		# false, Block.java:170, so Java runs updateTile even
		# when disabled -- in Java a disabled module's efficiency
		# is zeroed by the disabled early return
		# (BuildingComp.java:1954-1957) and the handoff gate
		# (UnitAssemblerModule.java:138, `efficiency > 0`) never
		# fires. The port keeps the enabled gate below as a
		# pragmatic choice (the N2195 coordinator-fix precedent):
		# the driver skips the consumption fold when disabled, so
		# the frame efficiency goes stale and running the advance
		# on it would hand payloads off from a stale efficiency.
		# The driver-wide disabled-early-return slice (deferred
		# in the N2228 register) removes this gate for all
		# families. super.updateTile() is an empty no-op
		# (BuildingComp.java:2010-2012), so the driver owes it
		# nothing. The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60
		# (arc Time.java:26), never raw seconds. timeScale
		# reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`). The rotation
		# reads live from the sprite rotation meta
		# (SourceBlockGeometry.SOURCE_BUILD_ROTATION_META_KEY,
		# default 0) -- the moveInPayload rotation target is
		# rotdeg() = rotation * 90 (BuildingComp.java:582-584).
		# The advance reads the link candidate + the handoff
		# predicates + tile_changes as frame inputs (the
		# N2248 live-fill deferral): a live module with no fill
		# refreshes once (lastChange -2 vs tileChanges 1), reads
		# link null, and never hands off.
		if bool(frame.get("enabled", true)):
			frame["rotation"] = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var advanced: Dictionary = source_unit_assembler_module_update_tile_advance_state(frame, source_delta, time_scale)
			frame["last_change"] = advanced["last_change"]
			frame["link"] = advanced["link"]
			frame["link_refreshed"] = advanced["link_refreshed"]
			frame["pay_vector"] = advanced["pay_vector"]
			frame["pay_rotation"] = advanced["pay_rotation"]
			frame["moved_in"] = advanced["moved_in"]
			frame["payload"] = advanced["payload"]
			frame["handed_off"] = advanced["handed_off"]
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
