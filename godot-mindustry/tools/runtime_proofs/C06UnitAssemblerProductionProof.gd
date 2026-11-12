extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var assembler_block = blocks_by_id["tank-assembler"]
	var plan_zero: Dictionary = unit_factory_build_state.source_unit_factory_assembler_plan_state(assembler_block, 0)

	# --- One tick of UnitAssemblerBuild.updateTile()
	# (UnitAssembler.java:429-571), driven directly on a bound
	# assembler frame. Deterministic: no tick-driver timing, the
	# pure function takes plan, drones_created, drone_construct_time,
	# payload_in_position, spawn_occupied, spawn_visual_occupied,
	# in_position_count, allow_update, can_create, power_status,
	# edelta, unit_build_speed and source_delta as inputs. The
	# mace plan is {unit: "mace", time: 60.0}; the intake key uses
	# the tank-assembler's tier-0 plan (stell 4 +
	# tungsten-wall-large 10, Blocks.java).
	var plan: Dictionary = {"unit": "mace", "time": 60.0}

	# --- progress advance (UnitAssembler.java:526):
	# `if((progress += edelta() * state.rules.unitBuildSpeed(team)
	# * eff / plan.time) >= 1f){` — efficiency 1.0, can_create
	# true, spawn free, 4/4 drones in position, edelta 1.0, unit
	# build speed 1.0: progress 0 -> 1/60, warmup lerps toward
	# efficiency (0 -> 0.1 at source_delta 1.0).
	var advancing: Dictionary = unit_factory_build_state.source_unit_assembler_production_tick_state({"efficiency": 1.0, "progress": 0.0, "warmup": 0.0}, plan, 4, 240.0, false, false, false, 4, true, true, 1.0, 1.0, 1.0, 1.0)
	proof["assembler_progress_advances"] = is_equal_approx(float(advancing.get("progress", -1.0)), 1.0 / 60.0) and is_equal_approx(float(advancing.get("warmup", -1.0)), 0.1) and bool(advancing.get("completed", true)) == false

	# --- tier change resets progress (UnitAssembler.java:441-448):
	# `if(lastTier != currentTier){` / `if(lastTier >= 0f){` /
	# `progress = 0f;` — last_tier 0, current_tier 1, progress 5.0
	# -> progress 0, last_tier 1. No drones in position, so eff is
	# 0 and progress stays 0.
	var tiered: Dictionary = unit_factory_build_state.source_unit_assembler_production_tick_state({"efficiency": 1.0, "progress": 5.0, "current_tier": 1, "last_tier": 0}, plan, 4, 240.0, false, false, false, 0, true, true, 1.0, 1.0, 1.0, 1.0)
	proof["assembler_tier_change_resets_progress"] = is_equal_approx(float(tiered.get("progress", -1.0)), 0.0) and int(tiered.get("last_tier", -99)) == 1

	# --- drone spawn (UnitAssembler.java:474-493):
	# `if(units.size < dronesCreated && enabled && (droneProgress +=
	# delta() * state.rules.unitBuildSpeed(team) * powerStatus /
	# droneConstructTime) >= 1f){` — units_count 3, drone_progress
	# 239.0, source_delta 240.0: 239.0 + 240 * 1 * 1 / 240 = 240.0
	# >= 1 -> drone_spawned, drone_progress 0, units_count 4.
	var spawning: Dictionary = unit_factory_build_state.source_unit_assembler_production_tick_state({"efficiency": 1.0, "units_count": 3, "drone_progress": 239.0}, plan, 4, 240.0, false, false, false, 0, true, true, 1.0, 1.0, 1.0, 240.0)
	proof["assembler_drone_spawns"] = bool(spawning.get("drone_spawned", false)) == true and is_equal_approx(float(spawning.get("drone_progress", -1.0)), 0.0) and int(spawning.get("units_count", -1)) == 4

	# --- intake yeets payload (UnitAssembler.java:500-503):
	# `if(moveInPayload() && !wasOccupied){ yeetPayload(payload);
	# payload = null; }` — a stell block payload has arrived, the
	# spawn was free last tick: the N2131 intake accepts it (stell
	# is a tier-0 requirement row under its cap 4) and adds one to
	# the blocks module, the frame payload clears.
	var intake_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {}, "payload": {"content": "stell", "kind": "block", "source_is_module": false}, "efficiency": 1.0}
	var intake: Dictionary = unit_factory_build_state.source_unit_assembler_production_tick_state(intake_frame, plan_zero, 4, 240.0, true, false, false, 0, true, true, 1.0, 1.0, 1.0, 1.0)
	var intake_blocks: Dictionary = intake.get("blocks", {})
	proof["assembler_intake_yeets_payload"] = bool(intake.get("payload_yeeted", false)) == true and intake.get("payload", "held") == null and int(intake_blocks.get("stell", -1)) == 1

	# --- completion (UnitAssembler.java:526-531 + spawned(),
	# UnitAssembler.java:543-571): progress 0.99 + edelta 1.0 *
	# unit build speed 1.0 * eff 1.0 / plan.time 1.0 = 1.99 >= 1 ->
	# completed, spawned, progress 0 (spawned() sets `progress =
	# 0f`), blocks cleared (`blocks.clear()`), consumed and the
	# UnitCreateEvent recorded.
	var completing: Dictionary = unit_factory_build_state.source_unit_assembler_production_tick_state({"efficiency": 1.0, "progress": 0.99, "blocks": {"stell": 2}}, {"unit": "mace", "time": 1.0}, 4, 240.0, false, false, false, 4, true, true, 1.0, 1.0, 1.0, 1.0)
	proof["assembler_completes_spawn"] = bool(completing.get("completed", false)) == true and bool(completing.get("spawned", false)) == true and is_equal_approx(float(completing.get("progress", -1.0)), 0.0) and Dictionary(completing.get("blocks", {"stell": 2})).is_empty() and bool(completing.get("consumed", false)) == true and bool(completing.get("unit_created_event", false)) == true

	# --- occupied spawn, no progress (UnitAssembler.java:524-531):
	# `if(!wasOccupied && efficiency > 0 && Units.canCreate(team,
	# plan.unit)){` — spawn_occupied true keeps progress at 5.0
	# and warmup lerps toward 0 (1.0 -> 0.9 at source_delta 1.0),
	# nothing completes.
	var occupied: Dictionary = unit_factory_build_state.source_unit_assembler_production_tick_state({"efficiency": 1.0, "progress": 5.0, "warmup": 1.0}, plan, 4, 240.0, false, true, false, 4, true, true, 1.0, 1.0, 1.0, 1.0)
	proof["assembler_occupied_no_progress"] = is_equal_approx(float(occupied.get("progress", -1.0)), 5.0) and is_equal_approx(float(occupied.get("warmup", -1.0)), 0.9) and bool(occupied.get("completed", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06UnitAssemblerProductionProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
