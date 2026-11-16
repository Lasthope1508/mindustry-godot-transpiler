extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_deconstructor_build_state := preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")
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

	# --- Break-block FX rows (N2480): the
	# Fx.breakBlock finish effect
	# (PayloadDeconstructor.java:191) reported as
	# a pure call record. The STATE is ALREADY
	# LIVE since N2233 (the deconstruct branch +
	# the finish branch clearing deconstructing /
	# accum), so this pure consumes the caller-
	# evaluated finish gate (the N2233 finished
	# verdict): `if(progress >= 1f){` +
	# `if(canProgress){` + `Fx.breakBlock.at(x, y,
	# deconstructing.size() / tilesize);` +
	# `deconstructing = null;` + `accum = null;`.
	# Payload.size() is the hitbox size in pixels
	# (`float size();`, Payload.java:27): a
	# BuildPayload is block.size * tilesize
	# (BuildPayload.java:86-88), a UnitPayload is
	# hitSize (UnitPayload.java:99-101) -- so
	# size() / tilesize is the block size in
	# tiles for a build payload and hitSize / 8
	# for a unit payload. The divisor is the JAVA
	# tilesize 8 (`public static final int
	# tilesize = 8;`, Vars.java:135), NOT the game
	# tile_size 32 (the N2364 lesson). The effect
	# is Fx.breakBlock (`breakBlock = new Effect(
	# 12, e -> {`, Fx.java:285), and its renderer
	# reads the third .at arg (e.rotation) as the
	# size scale (`Lines.square(e.x, e.y, tilesize
	# / 2f * e.rotation + e.fin() * 3f);`,
	# Fx.java:288) -- so the record carries the
	# value under the "scale" key. The N2233
	# deconstructing descriptor (kind /
	# requirements / build_time) carries no size
	# key, so the size is a caller-supplied float
	# input in pixels, captured BEFORE the advance
	# clears deconstructing. No effect is spawned
	# -- the effect call site waits for its own
	# slice.

	# --- FX on finish: a finished deconstruction
	# of a size-3 block payload (size() = 3 * 8 =
	# 24.0 pixels) fires the breakBlock call at
	# the building position (100, 200) with scale
	# 24.0 / 8.0 = 3.0.
	var finished_call: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_break_block_fx_state(true, 24.0, 100.0, 200.0).get("break_block_call", {})
	proof["fx_on_finish"] = str(finished_call.get("effect", "")) == "Fx.breakBlock" and is_equal_approx(float(finished_call.get("x", -1.0)), 100.0) and is_equal_approx(float(finished_call.get("y", -1.0)), 200.0) and is_equal_approx(float(finished_call.get("scale", -1.0)), 3.0)

	# --- FX null when not finished: no finish, no
	# call -- even with a nonzero size (the N2397
	# null-when-absent precedent).
	var idle: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_break_block_fx_state(false, 16.0, 100.0, 200.0)
	proof["fx_null_when_not_finished"] = idle.get("break_block_call", {}) == null

	# --- FX scale size 1: a size-1 block payload
	# (size() = 1 * 8 = 8.0 pixels) scales 8.0 /
	# 8.0 = 1.0.
	var size_1_call: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_break_block_fx_state(true, 8.0, 0.0, 0.0).get("break_block_call", {})
	proof["fx_scale_size_1"] = is_equal_approx(float(size_1_call.get("scale", -1.0)), 1.0)

	# --- FX scale size 2: a size-2 block payload
	# (size() = 2 * 8 = 16.0 pixels) scales 16.0 /
	# 8.0 = 2.0.
	var size_2_call: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_break_block_fx_state(true, 16.0, 0.0, 0.0).get("break_block_call", {})
	proof["fx_scale_size_2"] = is_equal_approx(float(size_2_call.get("scale", -1.0)), 2.0)

	# --- FX tilesize 8: the divisor is the JAVA
	# tilesize 8 (Vars.java:135), NOT the game
	# tile_size 32 (the N2364 lesson) -- a size-1
	# block scales 8.0 / 8.0 = 1.0 (it would be
	# 0.25 under /32), and a unit payload with
	# hitSize 12.0 scales 12.0 / 8.0 = 1.5 (it
	# would be 0.375 under /32).
	var tilesize_block: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_break_block_fx_state(true, 8.0, 0.0, 0.0).get("break_block_call", {})
	var tilesize_unit: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_break_block_fx_state(true, 12.0, 0.0, 0.0).get("break_block_call", {})
	proof["fx_tilesize_8"] = is_equal_approx(float(tilesize_block.get("scale", -1.0)), 1.0) and is_equal_approx(float(tilesize_unit.get("scale", -1.0)), 1.5)

	# --- FX live input: the finish flag comes from
	# the LIVE N2233 advance, and the size is
	# captured BEFORE the advance clears
	# deconstructing. The finishing frame (progress
	# 0.95, accum [0.0, 0.0], the N2233 proof
	# fixture) deconstructs a size-2 block payload
	# (block_size 2, the N2308 intake key -- inert
	# to the advance, which reads kind /
	# requirements / build_time only), so size() =
	# 2 * 8 = 16.0 pixels; the advance finishes
	# (progress 0.95 + shift 0.1 = 1.05 >= 1f) and
	# the FX call fires with scale 2.0 at the
	# building position (100, 200). A
	# non-finishing tick (progress 0.5) reports
	# finished false and the FX call is null.
	var live_payload: Dictionary = {"kind": "build", "requirements": [{"item": "copper", "amount": 10}, {"item": "lead", "amount": 5}], "build_time": 60.0, "block_size": 2}
	var live_size: float = float(live_payload.get("block_size", 0)) * 8.0
	var live_finish_frame: Dictionary = {"efficiency": 1.0, "deconstructing": live_payload, "progress": 0.95, "accum": [0.0, 0.0], "time": 0.0, "speed_scl": 0.0, "items": {}}
	var live_finished: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(live_finish_frame, 1.0, 1.0, 6.0, 250)
	var live_call: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_break_block_fx_state(bool(live_finished.get("finished", false)), live_size, 100.0, 200.0).get("break_block_call", {})
	var live_progress_frame: Dictionary = {"efficiency": 1.0, "deconstructing": live_payload, "progress": 0.5, "accum": [0.0, 0.0], "time": 0.0, "speed_scl": 0.0, "items": {}}
	var live_progressed: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(live_progress_frame, 1.0, 1.0, 6.0, 250)
	var live_idle: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_break_block_fx_state(bool(live_progressed.get("finished", true)), live_size, 100.0, 200.0)
	proof["fx_live_input"] = bool(live_finished.get("finished", false)) and live_finished.get("deconstructing") == null and str(live_call.get("effect", "")) == "Fx.breakBlock" and is_equal_approx(float(live_call.get("scale", -1.0)), 2.0) and is_equal_approx(float(live_call.get("x", -1.0)), 100.0) and is_equal_approx(float(live_call.get("y", -1.0)), 200.0) and bool(live_progressed.get("finished", true)) == false and live_idle.get("break_block_call", {}) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DeconstructorBreakBlockFxProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
