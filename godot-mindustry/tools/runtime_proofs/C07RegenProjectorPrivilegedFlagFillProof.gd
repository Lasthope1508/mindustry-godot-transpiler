extends Node

const main_scene := preload("res://scenes/Main.tscn")
const regen_projector_build_state := preload("res://src/game/SourceRegenProjectorBuildState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- Pure privileged flag (N2344): Java's eachBlock
	# excludes privileged blocks (`if(pred.get(b) &&
	# !b.block.privileged){`, BlockIndexer.java:372) from the
	# updateTargets query. privileged defaults false
	# (`public boolean privileged = false;`,
	# Block.java:148) and exactly four defs set it
	# (`privileged = true;`, Blocks.java:6955/6965/6974/
	# 6981): the world-processor-only logic blocks. The
	# catalog carries no privileged flag, so the pure reads
	# the block id against the four def ids; an empty or
	# unknown id is NOT privileged (the false default).
	var privileged_ids: Array = ["world-processor", "world-cell", "world-message", "world-switch"]
	var pure_four_ok: bool = true
	for block_id in privileged_ids:
		if not bool(regen_projector_build_state.source_regen_projector_privileged_state(block_id).get("privileged", false)):
			pure_four_ok = false
	proof["privileged_pure_four_defs"] = pure_four_ok

	var plain_ids: Array = ["regen-projector", "copper-wall", "graphite-press", "", "not-a-block"]
	var pure_false_ok: bool = true
	for block_id in plain_ids:
		if bool(regen_projector_build_state.source_regen_projector_privileged_state(block_id).get("privileged", true)):
			pure_false_ok = false
	proof["privileged_pure_false_otherwise"] = pure_false_ok

	# --- Live tick: a regen-projector placed live with a
	# damaged copper-wall two tiles away at cell (30, 20)
	# (the in-rect control) and a damaged world-processor
	# four tiles away at cell (32, 20) -- its center (256,
	# 160) is dx 32 < 112, INSIDE the N2277 rect, so the
	# rect scan admits it and only the live privileged flag
	# fill + the N2338 narrow exclude it (the
	# differentiator vs N2338, whose tick stamped
	# privileged=false for every candidate). A damaged
	# copper-wall at (44, 20) is the far control (center
	# 352, dx 128 > 112 + 4, stays out). The exclusion does
	# not depend on damaged (the narrow drops privileged
	# regardless) -- the undamaged projector itself is the
	# in-targets control. The tick driver is called
	# directly (as the N2228/N2277/N2325/N2338 proofs do),
	# not simulate_factory, so the graph update does not
	# overwrite the stamped power_status. Hydrogen 1.0 is
	# seeded on the sprite liquids meta (the N2325 pattern
	# -- the required hydrogen row, Blocks.java:2016, would
	# fold efficiency 0 unseeded, the N2331 lesson) and
	# any_targets is seeded true (the N2214 pattern: the
	# gate reads the frame flag before the advance
	# recomputes it), so the first tick runs at efficiency
	# 1.0. The first tick refreshes (last_change -2 vs
	# tile_changes 1): the frame targets hold the projector
	# itself and the in-rect wall -- but not the
	# world-processor and not the far wall. The second tick
	# changes nothing.
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var hydrogen_id: int = int(liquid_catalog["liquid_id_by_name"].get("hydrogen", -1))
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	# The extracted catalog leaves these health values at -1, so damage cannot
	# establish this scenario. Seed source-initialized health in the fixture:
	# copper wall: Blocks.java:1704/1708, 80 * 4; world processor: empty
	# requirements (Blocks.java:6949), size 1, Block.init health (1378-1394).
	blocks_by_id["copper-wall"].properties["health"] = 320
	blocks_by_id["world-processor"].properties["health"] = 40

	var regen_cell := Vector2i(28, 20)
	var regen := Sprite2D.new()
	game.add_child(regen)
	game.call("record_placed_block", regen, blocks_by_id["regen-projector"], regen_cell)
	var wall_cell := Vector2i(30, 20)
	var wall := Sprite2D.new()
	game.add_child(wall)
	game.call("record_placed_block", wall, blocks_by_id["copper-wall"], wall_cell)
	var wall_max_health: float = float(wall.get_meta(placed_block_state.SOURCE_BLOCK_MAX_HEALTH_META_KEY, 0.0))
	placed_block_state.damage_sprite(wall, wall_max_health * 0.5)
	var proc_cell := Vector2i(32, 20)
	var proc := Sprite2D.new()
	game.add_child(proc)
	game.call("record_placed_block", proc, blocks_by_id["world-processor"], proc_cell)
	var proc_max_health: float = float(proc.get_meta(placed_block_state.SOURCE_BLOCK_MAX_HEALTH_META_KEY, 0.0))
	placed_block_state.damage_sprite(proc, proc_max_health * 0.5)
	var far_cell := Vector2i(44, 20)
	var far_wall := Sprite2D.new()
	game.add_child(far_wall)
	game.call("record_placed_block", far_wall, blocks_by_id["copper-wall"], far_cell)
	var far_max_health: float = float(far_wall.get_meta(placed_block_state.SOURCE_BLOCK_MAX_HEALTH_META_KEY, 0.0))
	placed_block_state.damage_sprite(far_wall, far_max_health * 0.5)
	regen_projector_build_state.source_regen_projector_bind_frame_state(regen, blocks_by_id["regen-projector"])
	var regen_frame: Dictionary = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	var regen_liquids: Dictionary = regen.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(regen_liquids, hydrogen_id, 1.0)
	regen_frame["any_targets"] = true
	regen_frame["power_status"] = 1.0

	var self_pos: int = block_geometry.tile_pos_state(regen_cell.x, regen_cell.y)
	var wall_pos: int = block_geometry.tile_pos_state(wall_cell.x, wall_cell.y)
	var proc_pos: int = block_geometry.tile_pos_state(proc_cell.x, proc_cell.y)
	var far_pos: int = block_geometry.tile_pos_state(far_cell.x, far_cell.y)
	regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)
	regen_frame = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	var tick1_targets: Array = regen_frame.get("targets", [])
	var tick1_by_pos: Dictionary = {}
	for entry in tick1_targets:
		tick1_by_pos[int(entry.get("pos", -1))] = entry
	var tick1_ok: bool = int(regen_frame.get("last_change", -99)) == 1 and is_equal_approx(float(regen_frame.get("efficiency", -1.0)), 1.0) and bool(regen_frame.get("any_targets", false)) and tick1_by_pos.has(self_pos) and tick1_by_pos.has(wall_pos) and not tick1_by_pos.has(proc_pos) and not tick1_by_pos.has(far_pos) and bool(tick1_by_pos[wall_pos].get("damaged", false)) and bool(tick1_by_pos[self_pos].get("damaged", true)) == false and is_equal_approx(float(tick1_by_pos[wall_pos].get("health", -1.0)), wall_max_health * 0.5) and is_equal_approx(float(tick1_by_pos[wall_pos].get("block_health", -1.0)), wall_max_health)

	regen_frame["power_status"] = 1.0
	regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)
	regen_frame = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	var tick2_targets: Array = regen_frame.get("targets", [])
	var tick2_ok: bool = int(regen_frame.get("last_change", -99)) == 1 and bool(regen_frame.get("any_targets", false)) and tick2_targets == tick1_targets
	proof["live_tick_excludes_privileged"] = tick1_ok and tick2_ok

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RegenProjectorPrivilegedFlagFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
