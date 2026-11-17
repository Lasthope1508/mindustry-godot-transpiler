extends Node

const main_scene := preload("res://scenes/Main.tscn")
const point_defense_turret_build_state := preload("res://src/game/SourcePointDefenseTurretBuildState.gd")
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

	# --- PointDefenseTurret shouldConsume gate + coolant (N2241):
	# the remainder of PointDefenseBuild.updateTile()
	# (PointDefenseTurret.java:62-107). shouldConsume()
	# (PointDefenseTurret.java:105-107, `public boolean
	# shouldConsume(){` / `return super.shouldConsume() &&
	# target != null;`) is `enabled && target != null`:
	# the super chain is PointDefenseBuild ->
	# ReloadTurretBuild -> BaseTurretBuild -> Building, and
	# neither ReloadTurretBuild nor BaseTurretBuild overrides
	# shouldConsume, so super.shouldConsume() is
	# Building.shouldConsume() (BuildingComp.java:755-757,
	# `return enabled;`, with `transient boolean enabled =
	# true;`, BuildingComp.java:77). TurretBuild.shouldConsume()
	# (Turret.java:364, `return isShooting || reloadCounter <
	# reload;`) is NOT in the chain -- TurretBuild is a sibling
	# branch, PointDefenseBuild extends ReloadTurretBuild
	# directly. The driver gates the consumption branch on
	# the pure function, so a segment with no live target
	# consumes nothing and its efficiency folds to 0
	# (BuildingComp.java:1947, `efficiency = ...
	# shouldConsume() ? potentialEfficiency : 0f;`) -- the
	# N2151 "machinery runs with should_consume=true when
	# enabled" approximation ends with this slice. LIVE
	# CONSEQUENCE: until the bullet wiring lands, the frame
	# carries no `observed_bullets`, so `target` stays null
	# and should_consume is false; the proof therefore
	# supplies observed targets. updateCooling()
	# (ReloadTurret.java:28-38, called from
	# PointDefenseTurret.java:74-76 `if(coolant != null){
	# updateCooling(); }` before the aim/shoot half) gates on
	# canReload() (`reloadCounter < reload`,
	# ReloadTurret.java:46-48) && coolant != null &&
	# coolant.efficiency(this) > 0 && efficiency > 0, then
	# `reloadCounter += amount * edelta() * capacity *
	# coolantMultiplier * ammoReloadMultiplier();`
	# (ReloadTurret.java:33) with amount = `coolant.amount *
	# coolant.efficiency(this)` (ReloadTurret.java:31),
	# capacity the consumed liquid's heatCapacity
	# (`float capacity = coolant instanceof
	# ConsumeLiquidFilter filter ? filter.getConsumed(this)
	# .heatCapacity : (coolant.consumes(liquids.current()) ?
	# liquids.current().heatCapacity : 0.4f);`,
	# ReloadTurret.java:30), coolantMultiplier = 2f for
	# PointDefenseTurret (PointDefenseTurret.java:42) and
	# ammoReloadMultiplier() = 1f (ReloadTurret.java:41-43).
	# `coolant.update(this);` (ReloadTurret.java:32) removes
	# `amount * edelta() * multiplier`
	# (ConsumeLiquidFilter.java:44-49, multiplier default 1f,
	# Consume.java:18) -- the pure function returns that as
	# coolant_consumed for a later wiring slice to apply. The
	# coolEffect chance (`if(Mathf.chance(0.06 * amount)){`,
	# ReloadTurret.java:35) is a random visual, NOT in the
	# pure function (the N2240 random-pitch precedent). The
	# only PointDefenseTurret def, segment
	# (Blocks.java:3835-3845, `consumePower(8f);` /
	# `reload = 8f;`), defines NO coolant consumer, so
	# BaseTurret.init (`coolant = findConsumer(c -> c
	# instanceof ConsumeCoolant);`, BaseTurret.java:50-52)
	# leaves coolant null and the driver call is a faithful
	# no-op for segment. Three segments, one shared driver
	# tick per phase: A is enabled with an observed enemy
	# target, B is enabled with no bullets at all, C is
	# disabled with an observed enemy target. The cooling
	# keys call the pure function directly with synthetic
	# frames (the RepairTurret coolant proof precedent: the
	# driver call is a no-op for segment, so the class-level
	# behavior is modeled with synthetic inputs).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cells: Array[Vector2i] = [Vector2i(28, 21), Vector2i(30, 21), Vector2i(32, 21)]
	var segments: Array[Sprite2D] = []
	for cell in cells:
		var segment := Sprite2D.new()
		game.add_child(segment)
		game.call("record_placed_block", segment, blocks_by_id["segment"], cell)
		# The raw Sprite2D nodes never pass through the texture
		# path (SourceTextureRuntimeState.configure_block_sprite),
		# which is what assigns a placed block its world position
		# (`sprite.position = game.source_block_sprite_base_position(block, cell)`),
		# so without this every segment sits at the origin (0, 0)
		# and the turret-centred query cannot be distinguished
		# from an origin-centred one. Seed the position exactly
		# the way the game does (the N2211 proof lesson).
		segment.position = game.source_block_sprite_base_position(blocks_by_id["segment"], cell)
		point_defense_turret_build_state.source_point_defense_turret_bind_frame_state(segment, blocks_by_id["segment"])
		segments.append(segment)
	var frames: Array[Dictionary] = []
	for segment in segments:
		frames.append(segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {}))
	# Full power everywhere: the shouldConsume gate folds
	# efficiency through the consumption branch, so the proof
	# reads the fold, not just the pure function.
	for index in range(3):
		frames[index]["power_status"] = 1.0
	# C is disabled: the tick preserves a disabled segment
	# instead of resetting it (the factory pattern).
	frames[2]["enabled"] = false
	# One shared tick wires team_id onto every frame.
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(3):
		frames[index] = segments[index].get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var teams: Array[int] = []
	for frame in frames:
		teams.append(int(frame.get("team_id", 1)))
	var positions: Array[Vector2] = []
	for segment in segments:
		positions.append(segment.position)

	# A: one enemy hittable due north (+10 y) -- the timer
	# fires on the next tick and acquires it.
	frames[0]["observed_bullets"] = [
		{"id": 1, "team": teams[0] + 1, "hittable": true, "has_type": true, "damage": 100.0, "x": positions[0].x, "y": positions[0].y + 10.0},
	]
	# B: no bullets at all -- no target ever, and the
	# reload_counter seed below must survive the driver
	# cooling no-op untouched.
	frames[1]["observed_bullets"] = []
	frames[1]["reload_counter"] = 3.0
	# C: one enemy hittable due north (+10 y), same as A --
	# the timer fires and acquires it, but the segment is
	# disabled, so should_consume must still be false.
	frames[2]["observed_bullets"] = [
		{"id": 3, "team": teams[2] + 1, "hittable": true, "has_type": true, "damage": 100.0, "x": positions[2].x, "y": positions[2].y + 10.0},
	]
	# Seed the acquire timers just below the 5s fire line so
	# the next tick acquires on A and C.
	frames[0]["target_timer"] = 4.99
	frames[2]["target_timer"] = 4.99

	# Tick 1 at 1/60s: the consumption branch runs BEFORE
	# the retarget, so A still has no target and folds to
	# efficiency 0; the retarget then acquires A's target.
	# Tick 2: A's consumption branch now sees the target, so
	# should_consume is true and efficiency folds back to
	# 1.0; B never acquires, so it stays folded at 0.
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(3):
		frames[index] = segments[index].get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var consume_a: Dictionary = point_defense_turret_build_state.source_point_defense_turret_should_consume_state(frames[0])
	var consume_b: Dictionary = point_defense_turret_build_state.source_point_defense_turret_should_consume_state(frames[1])
	var consume_c: Dictionary = point_defense_turret_build_state.source_point_defense_turret_should_consume_state(frames[2])
	proof["should_consume_true_when_enabled_with_target"] = bool(consume_a.get("should_consume", false)) and bool(frames[0].get("has_target", false)) and is_equal_approx(float(frames[0].get("efficiency", -1.0)), 1.0)
	proof["should_consume_false_without_target"] = not bool(consume_b.get("should_consume", true)) and not bool(frames[1].get("has_target", true)) and is_equal_approx(float(frames[1].get("efficiency", -1.0)), 0.0)
	proof["should_consume_false_when_disabled"] = not bool(consume_c.get("should_consume", true)) and bool(frames[2].get("has_target", false)) and not bool(frames[2].get("enabled", true))

	# Cooling through the pure function with synthetic
	# inputs (the driver call is a faithful no-op for
	# segment, so the class-level behavior is modeled
	# here): amount = coolant_amount * coolant_efficiency
	# = 0.5 * 1.0 = 0.5; the boost is amount * edelta *
	# heatCapacity * coolantMultiplier = 0.5 * 1.0 * 0.4 *
	# 2.0 = 0.4; coolant_consumed = amount * edelta = 0.5.
	var boosted: Dictionary = point_defense_turret_build_state.source_point_defense_turret_cooling_state({"reload_counter": 2.0, "efficiency": 1.0}, true, 0.5, 1.0, 0.4, 2.0, 8.0, 1.0)
	proof["cooling_boosts_reload_counter"] = is_equal_approx(float(boosted.get("reload_counter", -1.0)), 2.4) and bool(boosted.get("cooling_applied", false))
	proof["cooling_reports_coolant_consumed"] = bool(boosted.get("cooling_applied", false)) and is_equal_approx(float(boosted.get("coolant_consumed", -1.0)), 0.5)
	# Reloaded already: reload_counter 8.0 is NOT < reload
	# 8.0, so canReload() fails and the counter is untouched.
	var reloaded: Dictionary = point_defense_turret_build_state.source_point_defense_turret_cooling_state({"reload_counter": 8.0, "efficiency": 1.0}, true, 0.5, 1.0, 0.4, 2.0, 8.0, 1.0)
	proof["cooling_skipped_when_reloaded"] = is_equal_approx(float(reloaded.get("reload_counter", -1.0)), 8.0) and not bool(reloaded.get("cooling_applied", true)) and is_equal_approx(float(reloaded.get("coolant_consumed", -1.0)), 0.0)
	# No coolant consumer: the gate fails and the counter is
	# untouched -- and the driver proves the same no-op live:
	# B's seeded reload_counter 3.0 survives two ticks with
	# no target (aim gate fails, cooling no-op).
	var no_coolant: Dictionary = point_defense_turret_build_state.source_point_defense_turret_cooling_state({"reload_counter": 2.0, "efficiency": 1.0}, false, 0.5, 1.0, 0.4, 2.0, 8.0, 1.0)
	proof["cooling_skipped_without_coolant"] = is_equal_approx(float(no_coolant.get("reload_counter", -1.0)), 2.0) and not bool(no_coolant.get("cooling_applied", true)) and is_equal_approx(float(no_coolant.get("coolant_consumed", -1.0)), 0.0) and is_equal_approx(float(frames[1].get("reload_counter", -1.0)), 3.0)
	# Zero coolant efficiency: the gate fails and nothing
	# is consumed or boosted.
	var zero_efficiency: Dictionary = point_defense_turret_build_state.source_point_defense_turret_cooling_state({"reload_counter": 2.0, "efficiency": 1.0}, true, 0.5, 0.0, 0.4, 2.0, 8.0, 1.0)
	proof["cooling_skipped_when_coolant_efficiency_zero"] = is_equal_approx(float(zero_efficiency.get("reload_counter", -1.0)), 2.0) and not bool(zero_efficiency.get("cooling_applied", true)) and is_equal_approx(float(zero_efficiency.get("coolant_consumed", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PointDefenseTurretShouldConsumeCoolantProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
