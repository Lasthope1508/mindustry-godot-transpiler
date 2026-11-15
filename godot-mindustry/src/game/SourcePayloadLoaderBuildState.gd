extends RefCounted
class_name SourcePayloadLoaderBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The PayloadLoader implementation (PayloadLoader.java:19, `public class PayloadLoader extends PayloadBlock{`): payload-loader (consumePower(2f);, size 3, loadTime 2f, maxPowerConsumption 40f, Blocks.java:6682-6689). PayloadLoader has hasPower = true; (PayloadLoader.java:36), hasItems=true, hasLiquids=true, update=true, outputsPayload=true, size 3, rotate=true (PayloadLoader.java:31-41). PayloadLoader extends PayloadBlock, NOT a drill or factory, so it cannot reuse an existing frame key; this driver uses its own family frame key ("source_payload_loader_building", the mechanical-pump / beam-drill / mend-projector / overdrive-projector / force-projector / base-shield / regen-projector / constructor precedent), and this slice adds the payload-loader key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourcePayloadLoader* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the load gate (PayloadLoader.java:157, `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`) follows the folded efficiency, with the battery charge (PayloadLoader.java:202, `float powerInput = power.status * (basePowerUse + maxPowerConsumption);`).
const SOURCE_PAYLOAD_LOADER_BUILD_IMPLEMENTATIONS := ["PayloadLoader"]
const SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY := "source_payload_loader_building"

static func _is_payload_loader_build_implementation(implementation: String) -> bool:
	return SOURCE_PAYLOAD_LOADER_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_payload_loader_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The payload-loader tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (PayloadLoader.java:19, `public class PayloadLoader extends PayloadBlock{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# payload-loader skips consumption like Java's updateConsumption
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
	# for this payload-loader (N2125); the tick preserves a disabled
	# payload-loader instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# A new PayloadLoaderBuild starts with no payload (the
	# PayloadBlock field, `public @Nullable T payload;`,
	# PayloadBlock.java:92, default null): the shouldConsume
	# gate (PayloadLoader.java:240-242) reads frame["payload"]
	# null-ness, so the frame carries the payload key (null
	# until a live fill sets it -- moveInPayload /
	# handlePayload fill waits for its own slice; the gate
	# reads the frame as-is).
	return {"payload": null}

static func source_payload_loader_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the payload-loader frame meta key
	# ("source_payload_loader_building"). A PayloadLoader sprite gets a
	# frame bound with the payload key (null by default); the live-loop
	# tick fills its other keys every tick. Any other block, or an
	# already-bound sprite, binds nothing.
	if block == null or not _is_payload_loader_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_payload_loader_should_consume_state(frame: Dictionary) -> Dictionary:
	# PayloadLoaderBuild overrides shouldConsume (PayloadLoader.java:240, `public boolean shouldConsume(){` with `return payload != null;`, PayloadLoader.java:241): the payload-loader consumes only while it holds a payload. PayloadLoader extends PayloadBlock (PayloadLoader.java:19, `public class PayloadLoader extends PayloadBlock{`) and PayloadLoaderBuild extends PayloadBlockBuild (PayloadLoader.java:86, `public class PayloadLoaderBuild extends PayloadBlockBuild<BuildPayload>{`; PayloadBlock.java:91, `public class PayloadBlockBuild<T extends Payload> extends Building{`), so the default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`) does NOT apply here. Unlike the Separator/Drill gates this one has NO `&& enabled` -- Java returns the bare null check, so the pure gate does NOT read frame["enabled"] at all (the driver already runs the machinery only when enabled). The payload is the PayloadBlock field (`public @Nullable T payload;`, PayloadBlock.java:92), set by handlePayload (`this.payload = (T)payload;`, PayloadBlock.java:122; PayloadLoader.java:105, `super.handlePayload(source, payload);`) and cleared by takePayload (`payload = null;`, PayloadBlock.java:147); the frame carries it as frame["payload"] (default null for a frame bound before this slice). The gate reads only null-ness, so the payload value itself is opaque -- a minimal Dictionary fixture stands in for a BuildPayload in the proof. The def is the only payload-loader (payload-loader, `consumePower(2f);`, `size = 3;`, Blocks.java:6682-6689); there is no large-payload-loader. When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). No live fill sets frame["payload"] yet -- moveInPayload / handlePayload fill and takePayload clear wait for their own slice; the gate reads the frame as-is.
	var payload: Variant = frame.get("payload", null)
	var has_payload: bool = payload != null
	return {"should_consume": has_payload, "has_payload": has_payload}

static func source_payload_loader_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a payload-loader does not take the early return. The load gate follows the folded efficiency (PayloadLoader.java:157, `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`), with the battery charge (PayloadLoader.java:202, `float powerInput = power.status * (basePowerUse + maxPowerConsumption);`) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){`) and the shouldConsume override (PayloadLoader.java:241, `return payload != null;`).
	# Documented limits: (1) power-only first pass -- PayloadLoader has a dynamic power consumer (consumePowerDynamic, PayloadLoader.java:80; `public float maxPowerConsumption = 40f;` (PayloadLoader.java:26) + basePowerUse when hasBattery() && !exporting, else basePowerUse) besides the static consumePower(2f) def (Blocks.java:6686), so the folded efficiency is the min over the *modeled* consumers (power only) with the dynamic usage value deferred. (2) shouldConsume gate live (N2208) -- PayloadLoaderBuild overrides shouldConsume() to return payload != null (PayloadLoader.java:240-242, `return payload != null;`); the pure gate (source_payload_loader_should_consume_state) feeds should_consume to the machinery from the frame payload key (null by default); no live fill sets frame["payload"] yet (moveInPayload / handlePayload fill waits for its own slice). (3) No updateTile advance -- moveInPayload / moveOutPayload / load items+liquids / battery charge (PayloadLoader.java:143-220) wait for their own slices; the proof carries no load/export/battery keys, the load gate (PayloadLoader.java:157) is what the efficiency keys prove. (4) No accept/handle payload rows -- acceptPayload fits maxBlockSize (PayloadLoader.java:102-115) is payload acceptance, not tick state.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_payload_loader_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the payload-loader tick wiring every
	# tick (PayloadLoaderBuild.updateTile(), PayloadLoader.java:143,
	# gates on the load gate (PayloadLoader.java:157, `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`) and the battery charge (PayloadLoader.java:202, `float powerInput = power.status * (basePowerUse + maxPowerConsumption);`), so the load gate follows the folded efficiency; no placed-buildings driver ticks PayloadLoader blocks, so this driver is the placed-payload-loader tick): each placed PayloadLoader build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_payload_loader_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_payload_loader_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_payload_loader_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a payload-loader with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the load gate (PayloadLoader.java:157)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a payload-loader does not take the early return. A payload-loader with no power consumer is untouched: the tick models no other consumers yet (the dynamic power consumer row waits for its own slice), and PayloadLoaderBuild overrides shouldConsume() to return payload != null (PayloadLoader.java:240-242) -- N2208 feeds the live gate to the machinery (the pure gate is source_payload_loader_should_consume_state, fed the frame; the gate has no enabled term, Java returns the bare null check, and the outer guard below already runs the machinery only when enabled); the N2162 RED decision is resolved. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_payload_loader_should_consume_state(frame)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_payload_loader_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
