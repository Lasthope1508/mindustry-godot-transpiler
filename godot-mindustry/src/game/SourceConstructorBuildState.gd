extends RefCounted
class_name SourceConstructorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The Constructor implementation (Constructor.java:19, `public class Constructor extends BlockProducer{`): constructor (consumePower(2.5f);, size 3, buildSpeed 0.6f, Blocks.java:6658-6667) and large-constructor (consumePower(3f);, size 5, buildSpeed 0.75f, Blocks.java:6670-6680). BlockProducer has hasPower = true; (BlockProducer.java:32), hasItems=true, update=true, solid=true, outputsPayload=true (BlockProducer.java:28-35). Constructor extends BlockProducer, NOT a drill or factory, so it cannot reuse an existing frame key; this driver uses its own family frame key ("source_constructor_building", the mechanical-pump / beam-drill / mend-projector / overdrive-projector / force-projector / base-shield / regen-projector precedent), and this slice adds the constructor key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceConstructor* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the produce gate (BlockProducer.java:110, `boolean produce = recipe != null && efficiency > 0 && payload == null;`) follows the folded efficiency, with the progress advance (BlockProducer.java:113, `progress += buildSpeed * edelta();`).
const SOURCE_CONSTRUCTOR_BUILD_IMPLEMENTATIONS := ["Constructor"]
const SOURCE_CONSTRUCTOR_BUILDING_META_KEY := "source_constructor_building"

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
	return {}

static func source_constructor_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the constructor frame meta key
	# ("source_constructor_building"). A Constructor sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_constructor_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_CONSTRUCTOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_CONSTRUCTOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_CONSTRUCTOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_constructor_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a constructor does not take the early return. The produce gate follows the folded efficiency (BlockProducer.java:110, `boolean produce = recipe != null && efficiency > 0 && payload == null;`), with the progress advance (BlockProducer.java:113, `progress += buildSpeed * edelta();`) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){`) and the shouldConsume override (BlockProducer.java:103, `return super.shouldConsume() && recipe() != null;`).
	# Documented limits: (1) power-only first pass -- Constructor has a dynamic item consumer (ConsumeItemDynamic over recipe requirements, BlockProducer.java:39-58) besides power, so the folded efficiency is the min over the *modeled* consumers (power only) with that row deferred. (2) shouldConsume gate deferred -- BlockProducerBuild overrides shouldConsume() to return super.shouldConsume() && recipe() != null (BlockProducer.java:102-104); recipe state is not tracked yet, so the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). (3) No updateTile advance -- progress / heat / time / moveOutPayload (BlockProducer.java:109-131) wait for their own slices; the proof carries no progress/heat/recipe keys, the produce gate (BlockProducer.java:110) is what the efficiency keys prove. (4) No config/filter rows -- filter, minBlockSize/maxBlockSize, canProduce (Constructor.java:21-22, 54-56) are config, not tick state.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_constructor_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the constructor tick wiring every
	# tick (BlockProducerBuild.updateTile(), BlockProducer.java:109,
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
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a constructor with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the produce gate (BlockProducer.java:110)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a constructor does not take the early return. A constructor with no power consumer is untouched: the tick models no other consumers yet (the dynamic item consumer row waits for its own slice), and there is no shouldConsume gate yet (BlockProducerBuild overrides shouldConsume() to return super.shouldConsume() && recipe() != null, BlockProducer.java:102-104, but recipe state is not tracked yet), so the machinery runs with should_consume=true when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_constructor_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
