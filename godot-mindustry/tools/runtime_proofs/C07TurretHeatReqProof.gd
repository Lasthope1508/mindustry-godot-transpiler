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

	# --- Turret heatReq fold (N2263): N2250-N2262 never folded
	# the heat requirement on the new duo driver -- the frame had
	# no heat_req or side_heat key at all.
	# TurretBuild.updateTile() (Turret.java:490-615) folds it
	# every tick, after the logic-control decay and before the
	# rotate sync:
	# `if(heatRequirement > 0){`
	# `heatReq = calculateHeat(sideHeat);`
	# (Turret.java:538-540). `heatRequirement` defaults to -1
	# (`public float heatRequirement = -1f;`, Turret.java:53)
	# and duo never sets it (Blocks.java:3257-3331), so the
	# guard is false for duo and heatReq stays at its field
	# default 0 (`public float heatReq;`, Turret.java:295).
	# Only afflict (PowerTurret, `heatRequirement = 20f;`,
	# Blocks.java:5122) and malign (PowerTurret,
	# `heatRequirement = 144f;`, Blocks.java:6240) set a
	# positive requirement among turrets.
	# `calculateHeat(sideHeat)` is
	# `public float calculateHeat(float[] sideHeat){`
	# (BuildingComp.java:406) returning
	# `return calculateHeat(sideHeat, null);` (:407), which
	# fills the per-side array (`Arrays.fill(sideHeat, 0f);`,
	# :411) from the live proximity scan of same-team HeatBlock
	# heaters and returns the total heat. That scan is a live
	# entity scan -- BLOCKED, same class as findTarget -- so
	# the scan itself is deferred and the fold takes the scan
	# result (heat_total and the per-side array) as inputs,
	# applying only the guard + assign. The per-side array
	# field is `public float[] sideHeat = new float[4];`
	# (Turret.java:296). Java order :534-536 decay, :538-540
	# heatReq, :542-545 rotate sync, :595-596 turnToTarget,
	# :601/:609 updateShooting -- so the fold tick runs AFTER
	# the N2261 logicControlTime tick and BEFORE the N2262
	# rotate sync tick and the aim/shoot call. The direct
	# pure-function calls pin the fold behind the driver
	# observables below: guard off with -1 keeps the value,
	# the duo live case / guard on with the afflict
	# requirement 20 assigns the scan total / a zero
	# requirement keeps the value, the guard is strict > /
	# the per-side array is stamped when the guard is on /
	# the per-side array is kept when the guard is off / the
	# malign requirement 144 assigns the total / a partial
	# total assigns as-is.

	# The direct pure-function calls pin the fold behind the
	# driver observables below.
	var direct_off: Dictionary = turret_build_state.source_turret_heat_req_state(-1.0, 99.0, [1.0, 2.0, 3.0, 4.0], 5.0)
	var direct_on: Dictionary = turret_build_state.source_turret_heat_req_state(20.0, 12.5, [12.5, 0.0, 0.0, 0.0], 0.0)
	var direct_zero: Dictionary = turret_build_state.source_turret_heat_req_state(0.0, 99.0, [9.0, 9.0, 9.0, 9.0], 3.0)
	var direct_malign: Dictionary = turret_build_state.source_turret_heat_req_state(144.0, 144.0, [36.0, 36.0, 36.0, 36.0], 0.0)
	var direct_partial: Dictionary = turret_build_state.source_turret_heat_req_state(20.0, 7.5, [7.5, 0.0, 0.0, 0.0], 2.0)

	# Guard off with -1 keeps the value -- directly (duo never
	# sets heatRequirement, so the class default -1 leaves
	# heatReq 5.0 untouched; Java skips the assignment).
	proof["heat_req_guard_off_keeps_value"] = float(direct_off.get("heat_req", -1.0)) == 5.0
	# Guard on with the afflict requirement 20 assigns the scan
	# total -- directly (20.0 > 0, heatReq takes 12.5).
	proof["heat_req_guard_on_assigns_total"] = float(direct_on.get("heat_req", -1.0)) == 12.5
	# A zero requirement keeps the value -- directly (the guard
	# is strict >, 0.0 does not fold).
	proof["heat_req_zero_requirement_keeps"] = float(direct_zero.get("heat_req", -1.0)) == 3.0
	# The per-side array is stamped when the guard is on --
	# directly (the scan's per-side array passes through).
	proof["heat_req_side_heat_stamped"] = direct_on.get("side_heat", []) == [12.5, 0.0, 0.0, 0.0]
	# The per-side array is kept when the guard is off --
	# directly (Java skips the whole assignment, side_heat
	# included).
	proof["heat_req_side_heat_kept_when_off"] = direct_off.get("side_heat", []) == [1.0, 2.0, 3.0, 4.0]
	# The malign requirement 144 assigns the total -- directly
	# (144.0 > 0, heatReq takes 144.0).
	proof["heat_req_malign_total"] = float(direct_malign.get("heat_req", -1.0)) == 144.0
	# A partial total assigns as-is -- directly (no clamp, no
	# scaling: 7.5 of the 20 required folds straight in).
	proof["heat_req_partial_total"] = float(direct_partial.get("heat_req", -1.0)) == 7.5

	# One duo segment, live on the driver: the fold tick runs
	# after the logicControlTime tick and before the rotate sync
	# tick and the aim call, so the frame carries live heat keys
	# after a single tick.
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

	# Both keys are stamped on the frame after the tick, as live
	# keys -- not just computed by the pure function.
	proof["heat_req_stamped_to_frame"] = frame.has("heat_req") and frame.has("side_heat")
	# The duo live tick keeps heat_req 0.0 and side_heat four
	# zeros: duo never sets heatRequirement, so the class
	# default -1.0 keeps the guard off and the tick stamps the
	# field defaults -- the stamp is live, not a default left
	# behind by a missing tick.
	proof["heat_req_duo_live"] = float(frame.get("heat_req", -1.0)) == 0.0 and frame.get("side_heat", []) == [0.0, 0.0, 0.0, 0.0]

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretHeatReqProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
