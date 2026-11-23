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

	# --- Handle liquid (N2356): TurretBuild.handleLiquid() fires the
	# turret-cool event only when the block has a coolant consumer and the
	# liquid store is (near-)empty, then ALWAYS delegates to the Building
	# base (`public void handleLiquid(Building source, Liquid liquid, float amount){` /
	# `if(coolant != null && liquids.currentAmount() <= 0.001f){` /
	# `Events.fire(Trigger.turretCool);` /
	# `super.handleLiquid(source, liquid, amount);`, Turret.java:615-621).
	# The event is a bool flag in the returned dict (no Events/Trigger
	# port); the super call is the super_called flag
	# (Building.handleLiquid itself is NOT ported -- N585 owns
	# `liquids.add(liquid, amount);`). The coolant field lives on the block
	# (`public @Nullable ConsumeLiquidBase coolant;`, BaseTurret.java:34)
	# and arrives as the explicit bool param has_coolant; the liquid amount
	# is `public float currentAmount(){` (LiquidModule.java:98) and arrives
	# as the explicit float param liquid_amount. The proof calls the pure
	# function with synthetic frames and explicit params (no live tick, no
	# liquid flow: the amount arrives already measured).

	# Coolant + empty store fires the event and always calls super.
	var frame: Dictionary = {"coolant": true}
	var cooled: Dictionary = turret_build_state.source_turret_handle_liquid_state(frame, true, 0.0)
	proof["turret_cool_fired"] = bool(cooled.get("turret_cool_fired", false)) and bool(cooled.get("super_called", false))

	# No coolant never fires, even with an empty store -- super still called.
	var no_coolant: Dictionary = turret_build_state.source_turret_handle_liquid_state(frame, false, 0.0)
	proof["no_coolant_noop"] = bool(no_coolant.get("turret_cool_fired", true)) == false and bool(no_coolant.get("super_called", false))

	# Coolant + liquid present never fires -- super still called.
	var liquid_present: Dictionary = turret_build_state.source_turret_handle_liquid_state(frame, true, 5.0)
	proof["liquid_present_noop"] = bool(liquid_present.get("turret_cool_fired", true)) == false and bool(liquid_present.get("super_called", false))

	# The 0.001 boundary still fires (`<= 0.001f`).
	var boundary: Dictionary = turret_build_state.source_turret_handle_liquid_state(frame, true, 0.001)
	proof["boundary_fires"] = bool(boundary.get("turret_cool_fired", false)) and bool(boundary.get("super_called", false))

	# The call mutates neither the frame nor its inputs: the Java method
	# writes nothing on the build besides firing the event and delegating.
	proof["input_unmutated"] = bool(frame.get("coolant", false)) and frame.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretHandleLiquidProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
