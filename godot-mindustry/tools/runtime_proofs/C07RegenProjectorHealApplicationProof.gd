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

	# --- Live heal application (N2399): the mendMap flush loop
	# (RegenProjectorBuild.updateTile(),
	# RegenProjector.java:168-177) -- `for(var entry :
	# mendMap.entries()){` / `var build =
	# world.build(entry.key);` / `if(build != null){` /
	# `build.heal(entry.value);` / `build.recentlyHealed();`
	# / `mendMap.clear();` -- applied by the tick AFTER the
	# N2325 flush write-back. pos is the packed ORIGIN cell
	# (Tile.pos() is `return Point2.pack(x, y);`,
	# Tile.java:73-75; build.pos() is `return tile.pos();`,
	# BuildingComp.java:578-580), decoded with Point2.unpack
	# (`return new Point2((short)(pos >>> 16), (short)(pos &
	# 0xFFFF));`, arc Point2.java:35-37); the cell resolves to
	# its sprite through block_sprite_at_cell (the N2353/N2371
	# precedent). NO family frame carries health -- the
	# target's health lives on the sprite metas
	# source_block_health / source_block_max_health, so the
	# helper repairs the sprite meta through the shared
	# repair_sprite, the exact HealthComp.heal cap (`health
	# += amount;` + clampHealth `health = Math.min(health,
	# maxHealth);`, HealthComp.java:103-112). A missing target
	# reports no_sprite (the Java `build == null` skip;
	# world.build(int pos) returns null, World.java:142-146).
	# recentlyHealed() DEFERS: no Time.time input reaches the
	# tick (the tick gets game + seconds, a delta), so the
	# result reports recently_healed false and no
	# last_heal_time is stamped.
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var hydrogen_id: int = int(liquid_catalog["liquid_id_by_name"].get("hydrogen", -1))
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

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
	var wall_pos: int = block_geometry.tile_pos_state(wall_cell.x, wall_cell.y)
	var wall_health_0: float = wall_max_health * 0.5

	# Pos decode: the helper decodes the packed pos to the
	# wall's origin cell (30, 20) and heals THAT sprite -- the
	# application entry carries the decoded cell, the reason
	# healed, and the exact healed amount.
	var applied_decode: Dictionary = regen_projector_build_state.source_regen_projector_heal_application_state(game, {wall_pos: 5.0})
	var apps_decode: Array = applied_decode.get("applications", [])
	var entry_decode: Dictionary = apps_decode[0] if not apps_decode.is_empty() else {}
	proof["heal_application_decodes_pos_to_cell"] = apps_decode.size() == 1 and int(entry_decode.get("pos", -1)) == wall_pos and entry_decode.get("cell", Vector2i(-1, -1)) == wall_cell and str(entry_decode.get("reason", "")) == "healed" and is_equal_approx(float(entry_decode.get("healed", -1.0)), 5.0) and is_equal_approx(float(entry_decode.get("amount", -1.0)), 5.0) and int(applied_decode.get("applied_count", -1)) == 1 and int(applied_decode.get("skipped_count", -1)) == 0 and is_equal_approx(placed_block_state.health(wall), wall_health_0 + 5.0)

	# The exact amount lands: a second application heals the
	# wall by exactly 7.0 more (no cap hit, no rounding).
	var applied_amount: Dictionary = regen_projector_build_state.source_regen_projector_heal_application_state(game, {wall_pos: 7.0})
	var apps_amount: Array = applied_amount.get("applications", [])
	var entry_amount: Dictionary = apps_amount[0] if not apps_amount.is_empty() else {}
	proof["heal_application_applies_amount_to_target"] = apps_amount.size() == 1 and str(entry_amount.get("reason", "")) == "healed" and is_equal_approx(float(entry_amount.get("healed", -1.0)), 7.0) and is_equal_approx(placed_block_state.health(wall), wall_health_0 + 12.0) and int(applied_amount.get("applied_count", -1)) == 1 and int(applied_amount.get("skipped_count", -1)) == 0

	# The cap at max health: healing by the whole max health
	# from a damaged wall heals only the missing amount, and
	# the wall ends exactly at max (HealthComp.heal +
	# clampHealth).
	var missing_before_cap: float = wall_max_health - (wall_health_0 + 12.0)
	var applied_cap: Dictionary = regen_projector_build_state.source_regen_projector_heal_application_state(game, {wall_pos: wall_max_health})
	var apps_cap: Array = applied_cap.get("applications", [])
	var entry_cap: Dictionary = apps_cap[0] if not apps_cap.is_empty() else {}
	proof["heal_application_caps_at_max_health"] = apps_cap.size() == 1 and str(entry_cap.get("reason", "")) == "healed" and is_equal_approx(float(entry_cap.get("healed", -1.0)), missing_before_cap) and is_equal_approx(placed_block_state.health(wall), wall_max_health) and int(applied_cap.get("applied_count", -1)) == 1 and int(applied_cap.get("skipped_count", -1)) == 0

	# No sprite: an empty cell (90, 40, nothing placed there)
	# reports no_sprite with nothing healed -- the Java
	# `build == null` skip for a demolished / out-of-range
	# target.
	var empty_cell := Vector2i(90, 40)
	var empty_pos: int = block_geometry.tile_pos_state(empty_cell.x, empty_cell.y)
	var applied_empty: Dictionary = regen_projector_build_state.source_regen_projector_heal_application_state(game, {empty_pos: 5.0})
	var apps_empty: Array = applied_empty.get("applications", [])
	var entry_empty: Dictionary = apps_empty[0] if not apps_empty.is_empty() else {}
	proof["heal_application_no_sprite_reports_no_sprite"] = apps_empty.size() == 1 and int(entry_empty.get("pos", -1)) == empty_pos and entry_empty.get("cell", Vector2i(-1, -1)) == empty_cell and str(entry_empty.get("reason", "")) == "no_sprite" and is_equal_approx(float(entry_empty.get("healed", -1.0)), 0.0) and int(applied_empty.get("applied_count", -1)) == 0 and int(applied_empty.get("skipped_count", -1)) == 1

	# --- Live tick: the same regen-projector + damaged
	# copper-wall setup as the N2325 proof (the N2277
	# pattern -- the scan rebuilds targets from the placed
	# buildings on the first tick). The wall is re-damaged to
	# half health first (the direct keys above healed it to
	# full). Hydrogen 1.0 is seeded on the sprite liquids
	# meta (the N2322 pattern) and 1 phaseFabric on the frame
	# items, so efficiency folds the power min 0.5 and
	# optional_efficiency 0.5 (the N2260 rows). One 1/60s
	# tick is one source tick: healAmount is lerp(1, 2, 0.5)
	# * 4/60 = 0.1, and the wall mend is 0.1 * 0.5 *
	# wall_max_health / 100. Tick 1 flushes (last_update_frame
	# -1 vs update_id 0) AND heals the wall in the same tick
	# (the application runs after the flush write-back):
	# mend_map ends empty, heal_applications carries the wall
	# amount, heal_applied reports one application, and the
	# wall health rises by the mend. Tick 2 accumulates again
	# with no flush (update_id 0 == last_update_frame 0):
	# mend_map holds the wall amount, heal_applications is
	# empty, heal_applied reports nothing, and the wall health
	# is unchanged.
	placed_block_state.damage_sprite(wall, wall_max_health * 0.5)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status, seed
	# the phaseFabric and the any_targets gate on it).
	regen_projector_build_state.source_regen_projector_bind_frame_state(regen, blocks_by_id["regen-projector"])
	var regen_frame: Dictionary = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	var regen_liquids: Dictionary = regen.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(regen_liquids, hydrogen_id, 1.0)

	# The gate reads the frame any_targets BEFORE the advance
	# recomputes it, so the first tick needs the seeded true
	# (the N2214 proof pattern); the advance then keeps it true
	# from the scanned damaged wall.
	var expected_mend: float = 0.1 * 0.5 * wall_max_health / 100.0
	regen_frame["any_targets"] = true
	regen_frame["power_status"] = 0.5
	regen_frame["items"] = {"phase-fabric": 1}
	regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)
	regen_frame = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	var tick1_mend: Dictionary = regen_frame.get("mend_map", {})
	var tick1_apps: Dictionary = regen_frame.get("heal_applications", {})
	var tick1_applied: Dictionary = regen_frame.get("heal_applied", {})
	var tick1_applied_apps: Array = tick1_applied.get("applications", [])
	var tick1_entry: Dictionary = tick1_applied_apps[0] if not tick1_applied_apps.is_empty() else {}
	var tick1_ok: bool = is_equal_approx(float(regen_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(regen_frame.get("optional_efficiency", -1.0)), 0.5) and is_equal_approx(float(regen_frame.get("warmup", -1.0)), 0.0) and is_equal_approx(float(regen_frame.get("total_time", -1.0)), 0.0) and is_equal_approx(float(regen_frame.get("optional_timer", -1.0)), 0.25) and is_equal_approx(float(regen_frame.get("heal_amount", -1.0)), 0.1) and tick1_mend.is_empty() and is_equal_approx(float(tick1_apps.get(wall_pos, -1.0)), expected_mend) and int(regen_frame.get("last_update_frame", -99)) == 0 and bool(regen_frame.get("did_regen", false)) and bool(regen_frame.get("any_targets", false)) and int(regen_frame.get("last_change", -99)) == 1 and bool(regen_frame.get("consumed", true)) == false and tick1_applied_apps.size() == 1 and int(tick1_entry.get("pos", -1)) == wall_pos and tick1_entry.get("cell", Vector2i(-1, -1)) == wall_cell and str(tick1_entry.get("reason", "")) == "healed" and is_equal_approx(float(tick1_entry.get("healed", -1.0)), expected_mend) and int(tick1_applied.get("applied_count", -1)) == 1 and int(tick1_applied.get("skipped_count", -1)) == 0 and is_equal_approx(placed_block_state.health(wall), wall_health_0 + expected_mend)

	regen_frame["power_status"] = 0.5
	regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)
	regen_frame = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	var tick2_mend: Dictionary = regen_frame.get("mend_map", {})
	var tick2_apps: Dictionary = regen_frame.get("heal_applications", {})
	var tick2_applied: Dictionary = regen_frame.get("heal_applied", {})
	var tick2_applied_apps: Array = tick2_applied.get("applications", [])
	var tick2_ok: bool = is_equal_approx(float(regen_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(regen_frame.get("warmup", -1.0)), 1.0 / 70.0) and is_equal_approx(float(regen_frame.get("total_time", -1.0)), 1.0 / 70.0) and is_equal_approx(float(regen_frame.get("optional_timer", -1.0)), 0.5) and is_equal_approx(float(tick2_mend.get(wall_pos, -1.0)), expected_mend) and tick2_apps.is_empty() and int(regen_frame.get("last_update_frame", -99)) == 0 and bool(regen_frame.get("any_targets", false)) and tick2_applied_apps.is_empty() and int(tick2_applied.get("applied_count", -1)) == 0 and int(tick2_applied.get("skipped_count", -1)) == 0 and is_equal_approx(placed_block_state.health(wall), wall_health_0 + expected_mend)
	proof["live_tick_applies_flush_after_advance"] = tick1_ok and tick2_ok

	# recentlyHealed() defers: no Time.time input reaches the
	# tick, so the direct helper result AND the live-tick
	# frame result both report recently_healed false.
	proof["recently_healed_deferred_without_time_input"] = bool(applied_decode.get("recently_healed", true)) == false and bool(tick1_applied.get("recently_healed", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RegenProjectorHealApplicationProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
