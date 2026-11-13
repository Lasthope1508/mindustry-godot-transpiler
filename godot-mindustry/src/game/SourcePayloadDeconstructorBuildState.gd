extends RefCounted
class_name SourcePayloadDeconstructorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The PayloadDeconstructor implementation (PayloadDeconstructor.java:17, `public class PayloadDeconstructor extends PayloadBlock{`): deconstructor (consumePower 3f, Blocks.java:6653; size 5, deconstructSpeed 6f, itemCapacity 250, Blocks.java:6649-6656) and small-deconstructor (consumePower 1f, Blocks.java:6644; size 3, deconstructSpeed 3f, itemCapacity 100, Blocks.java:6640-6647). PayloadDeconstructor sets outputsPayload=false, acceptsPayload=true, update=true, solid=true, size=5, hasItems=true, hasPower=true, itemCapacity=100 (PayloadDeconstructor.java:22-38), deconstructSpeed 2.5f class default (PayloadDeconstructor.java:19, `public float deconstructSpeed = 2.5f;`), maxPayloadSize 4 (PayloadDeconstructor.java:18, `public float maxPayloadSize = 4;`), dumpRate 4 (PayloadDeconstructor.java:20). PayloadDeconstructor extends PayloadBlock, NOT a drill or factory, so it cannot reuse an existing frame key; this driver uses its own family frame key ("source_payload_deconstructor_building", the mechanical-pump / beam-drill / mend-projector / overdrive-projector / force-projector / base-shield / regen-projector / constructor / payload-loader / payload-unloader / payload-mass-driver / unit-cargo-loader precedent), and this slice adds the payload-deconstructor key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourcePayloadDeconstructor* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the progress advance (PayloadDeconstructor.java:142, `float shift = edelta() * deconstructSpeed / deconstructing.buildTime();`) with `progress += shift;` follows the folded efficiency.
const SOURCE_PAYLOAD_DECONSTRUCTOR_BUILD_IMPLEMENTATIONS := ["PayloadDeconstructor"]
const SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY := "source_payload_deconstructor_building"

static func _is_payload_deconstructor_build_implementation(implementation: String) -> bool:
	return SOURCE_PAYLOAD_DECONSTRUCTOR_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_payload_deconstructor_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The payload-deconstructor tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (PayloadDeconstructor.java:17, `public class PayloadDeconstructor extends PayloadBlock{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# payload-deconstructor skips consumption like Java's updateConsumption
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
	# for this payload-deconstructor (N2125); the tick preserves a disabled
	# payload-deconstructor instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_payload_deconstructor_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the payload-deconstructor frame meta key
	# ("source_payload_deconstructor_building"). A PayloadDeconstructor sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_payload_deconstructor_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_payload_deconstructor_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a payload-deconstructor does not take the early return. The progress advance follows the folded efficiency (PayloadDeconstructor.java:142, `float shift = edelta() * deconstructSpeed / deconstructing.buildTime();`) with `progress += shift;` and the shouldConsume override (PayloadDeconstructor.java:219-221, `return deconstructing != null && enabled;`, default BuildingComp.java:755, `public boolean shouldConsume(){`) -- PayloadDeconstructorBuild overrides shouldConsume() to return deconstructing != null && enabled, so the default does not apply here; the gate is deferred (deconstructing state is not tracked yet) and the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). The deconstructor (consumePower 3f, Blocks.java:6653, `consumePower(3f);`; small-deconstructor consumePower 1f, Blocks.java:6644, `consumePower(1f);`) has no liquid consumer, so the folded efficiency is the min over the *modeled* consumers (power only).
	# Documented limits: (1) power-only first pass -- the deconstructor has no liquid consumer, so the folded efficiency is the min over the *modeled* consumers (power only). (2) shouldConsume gate deferred -- PayloadDeconstructorBuild overrides shouldConsume() to return deconstructing != null && enabled (PayloadDeconstructor.java:219-221, `return deconstructing != null && enabled;`); deconstructing state is not tracked yet, so the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). (3) No updateTile advance -- dumpAccumulate / progress / payRotation / canProgress / accum / speedScl / item transfer / finish deconstruction (PayloadDeconstructor.java:109-204) wait for their own slices; the proof carries no progress/accum/dump keys, the progress advance (PayloadDeconstructor.java:142, `float shift = edelta() * deconstructSpeed / deconstructing.buildTime();`) with `progress += shift;` is what the efficiency keys prove. (4) No acceptPayload / handlePayload / acceptUnitPayload / sense / draw / icons / setBars / read-write rows -- acceptPayload (PayloadDeconstructor.java:104-106), handlePayload (PayloadDeconstructor.java:98-101), acceptUnitPayload (PayloadDeconstructor.java:92-95), sense (PayloadDeconstructor.java:206-216), draw (PayloadDeconstructor.java:58-89), icons (PayloadDeconstructor.java:40-42), setBars (PayloadDeconstructor.java:45-49), read/write (PayloadDeconstructor.java:224-252) are acceptance / logic / presentation / serialization, not tick state. (5) No dump rows -- dumpRate 4 (PayloadDeconstructor.java:20) and dumpAccumulate (PayloadDeconstructor.java:111-115) wait for their own slice.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_payload_deconstructor_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the payload-deconstructor tick wiring every
	# tick (PayloadDeconstructorBuild.updateTile(), PayloadDeconstructor.java:109,
	# gates on the progress advance (PayloadDeconstructor.java:142, `float shift = edelta() * deconstructSpeed / deconstructing.buildTime();`) with `progress += shift;`, so the progress advance follows the folded efficiency; no placed-buildings driver ticks PayloadDeconstructor blocks, so this driver is the placed-payload-deconstructor tick): each placed PayloadDeconstructor build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_payload_deconstructor_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_payload_deconstructor_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_payload_deconstructor_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a payload-deconstructor with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the progress advance (PayloadDeconstructor.java:142)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a payload-deconstructor does not take the early return. A payload-deconstructor with no power consumer is untouched: the tick models no other consumers yet (the deconstructor has no liquid consumer), and there is no shouldConsume gate yet (PayloadDeconstructorBuild overrides shouldConsume() to return deconstructing != null && enabled, PayloadDeconstructor.java:219-221, but deconstructing state is not tracked yet), so the machinery runs with should_consume=true when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_payload_deconstructor_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
