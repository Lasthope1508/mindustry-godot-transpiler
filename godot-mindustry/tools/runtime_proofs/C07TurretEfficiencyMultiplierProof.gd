extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
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

	# --- Turret efficiency fold (N2265): N2250-N2264 never folded
	# efficiency on the new duo driver -- the frame's efficiency
	# key only carried the first-pass value.
	# TurretBuild.updateEfficiencyMultiplier()
	# (Turret.java:674-679) overrides BuildingComp's
	# (BuildingComp.java:1932-1935,
	# `float scale = efficiencyScale();` /
	# `efficiency *= scale;` /
	# `optionalEfficiency *= scale;`) with the heat fold:
	# `if(heatRequirement > 0){`
	# `efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);`
	# (Turret.java:675-677). The override replaces the base --
	# it does not call super and never touches
	# optionalEfficiency -- and it runs inside
	# updateConsumption() (BuildingComp.java:1949 cheating path
	# / :1996 normal path), which BuildingComp.update() calls
	# BEFORE updateTile() (:2274-2278), so the fold reads the
	# PREVIOUS tick's heatReq: heatReq is only recomputed later
	# in updateTile() (:538-540, N2263). `heatRequirement`
	# defaults to -1 (Turret.java:53, `public float
	# heatRequirement = -1f;`) and duo never sets it
	# (Blocks.java:3257-3331), so the guard is false for duo
	# and efficiency stays at the first-pass value
	# (BuildingComp.java:1946, 1.0 when enabled and
	# production-valid). Only afflict (PowerTurret,
	# `heatRequirement = 20f;`, Blocks.java:5122) and malign
	# (PowerTurret, `heatRequirement = 144f;`,
	# Blocks.java:6240) set a positive requirement among
	# turrets, with `public float maxHeatEfficiency = 3f;`
	# (Turret.java:55) capping the fold at 3x. `cheating()`
	# is `public boolean cheating(){` /
	# `return team.rules().cheat;` (TeamComp.java:17-19, N2099
	# stamps it live on frame["cheating"] every tick), so a
	# cheating team floors the ratio at 1.0 and never loses
	# efficiency to missing heat, while a non-cheating team
	# with no heat folds to 0. Java order: updateConsumption
	# with the fold, then updateTile's warmup :512-514 -- the
	# warmup lerp reads efficiency as its rate, so the fold
	# tick runs BEFORE the N2253 warmup tick. The direct
	# pure-function calls pin the fold behind the driver
	# observables below: guard off with -1 keeps the value,
	# the duo live case / guard on with the afflict
	# requirement 20 halves efficiency at half heat / a
	# cheating team floors the ratio at 1.0 with no heat /
	# a non-cheating team with no heat folds to 0 / the fold
	# caps at maxHeatEfficiency 3.0 / a zero requirement
	# keeps the value, the guard is strict > / the malign
	# requirement 144 halves 0.8 to 0.4 at half heat.

	# The direct pure-function calls pin the fold behind the
	# driver observables below.
	var direct_off: Dictionary = turret_build_state.source_turret_efficiency_multiplier_state(1.0, -1.0, 99.0, false, 3.0)
	var direct_on: Dictionary = turret_build_state.source_turret_efficiency_multiplier_state(1.0, 20.0, 10.0, false, 3.0)
	var direct_cheating: Dictionary = turret_build_state.source_turret_efficiency_multiplier_state(1.0, 20.0, 0.0, true, 3.0)
	var direct_noncheating: Dictionary = turret_build_state.source_turret_efficiency_multiplier_state(1.0, 20.0, 0.0, false, 3.0)
	var direct_capped: Dictionary = turret_build_state.source_turret_efficiency_multiplier_state(1.0, 20.0, 100.0, false, 3.0)
	var direct_zero: Dictionary = turret_build_state.source_turret_efficiency_multiplier_state(0.7, 0.0, 99.0, false, 3.0)
	var direct_malign: Dictionary = turret_build_state.source_turret_efficiency_multiplier_state(0.8, 144.0, 72.0, false, 3.0)

	# Guard off with -1 keeps the value -- directly (duo never
	# sets heatRequirement, so the class default -1 leaves
	# efficiency 1.0 untouched; Java skips the fold).
	proof["eff_mult_guard_off_keeps_value"] = float(direct_off.get("efficiency", -1.0)) == 1.0
	# Guard on with the afflict requirement 20 scales --
	# directly (20.0 > 0, half heat 10 / 20 halves 1.0 to 0.5).
	proof["eff_mult_guard_on_scales"] = float(direct_on.get("efficiency", -1.0)) == 0.5
	# A cheating team floors the ratio at 1.0 -- directly (no
	# heat at all, but cheating() floors max(0 / 20, 1.0) = 1.0).
	proof["eff_mult_cheating_floor_one"] = float(direct_cheating.get("efficiency", -1.0)) == 1.0
	# A non-cheating team with no heat folds to 0 -- directly
	# (max(0 / 20, 0.0) = 0.0, efficiency 1.0 * 0.0).
	proof["eff_mult_noncheating_floor_zero"] = float(direct_noncheating.get("efficiency", -1.0)) == 0.0
	# The fold caps at maxHeatEfficiency 3.0 -- directly (heat
	# 100 / 20 = 5.0, min(5.0, 3.0) = 3.0).
	proof["eff_mult_capped_at_max"] = float(direct_capped.get("efficiency", -1.0)) == 3.0
	# A zero requirement keeps the value -- directly (the guard
	# is strict >, 0.0 does not fold).
	proof["eff_mult_zero_requirement_keeps"] = float(direct_zero.get("efficiency", -1.0)) == 0.7
	# The malign requirement 144 halves 0.8 to 0.4 at half heat
	# -- directly (72 / 144 = 0.5, 0.8 * 0.5 = 0.4).
	proof["eff_mult_malign_partial"] = float(direct_malign.get("efficiency", -1.0)) == 0.4

	# One duo segment, live on the driver: the fold tick runs
	# before the warmup tick, so the frame carries a live
	# efficiency key after a single tick.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cell := Vector2i(28, 21)
	var segment := Sprite2D.new()
	game.add_child(segment)
	game.call("record_placed_block", segment, blocks_by_id["duo"], cell)
	# The raw Sprite2D node never passes through the texture
	# path (SourceTextureRuntimeState.configure_block_sprite),
	# which is what assigns a placed block its world position
	# (`sprite.position = game.source_block_sprite_base_position(block, cell)`),
	# so without this the segment sits at the origin (0, 0)
	# and the turret-centred query cannot be distinguished
	# from an origin-centred one. Seed the position exactly
	# the way the game does (the N2211 proof lesson).
	segment.position = game.source_block_sprite_base_position(blocks_by_id["duo"], cell)
	turret_build_state.source_turret_bind_frame_state(segment, blocks_by_id["duo"])

	# One shared tick wires team_id / cheating / enabled onto
	# the frame (and charges the reload by 1/60).
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	var frame: Dictionary = segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	# The fold is stamped on the frame after the tick, as a live
	# key -- not just computed by the pure function.
	proof["eff_mult_stamped_to_frame"] = frame.has("efficiency")
	# The duo live tick keeps efficiency 1.0: duo never sets
	# heatRequirement, so the class default -1.0 keeps the
	# guard off and the tick stamps the first-pass value --
	# the stamp is live, not a default left behind by a
	# missing tick.
	proof["eff_mult_duo_live"] = float(frame.get("efficiency", -1.0)) == 1.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretEfficiencyMultiplierProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
