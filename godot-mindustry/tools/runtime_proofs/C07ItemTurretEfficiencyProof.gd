extends Node

const main_scene := preload("res://scenes/Main.tscn")
const item_turret_build := preload("res://src/game/SourceItemTurretBuildPortBridge.gd")
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

	# --- Anonymous ConsumeItemFilter.efficiency(Building
	# build) inside ItemTurret.init() (N2419):
	# `public float efficiency(Building build){`
	# `//valid when it can shoot`
	# `return build instanceof ItemTurretBuild it &&
	# it.ammo.size > 0 && (it.ammo.peek().amount >=
	# ammoPerShot || it.cheating()) ? 1f : 0f;`
	# One efficiency slice (batch 31 slot 3): the 1
	# distinguishing return expr only. The proof calls
	# the pure function with synthetic inputs (no live
	# tick, no render): 1.0 when it can shoot, 1.0 when
	# cheating even with too little peeked ammo, 0.0
	# when not an ItemTurretBuild, 0.0 with no ammo,
	# 0.0 when the peeked amount is below ammoPerShot
	# without cheating, 1.0 at exactly ammoPerShot.
	# `it.ammo.peek().amount` is the peeked ItemEntry
	# amount, `ammoPerShot` is the Turret field
	# (Turret.java:49, default 1), `it.cheating()` is
	# the BuildingComp call-site -- all arrive as
	# explicit params.

	# 1.0 when it can shoot: an ItemTurretBuild with
	# ammo, peeked amount above ammoPerShot.
	var can_shoot: Dictionary = item_turret_build.source_item_turret_efficiency_state(true, 2, 5, 1, false)
	proof["efficiency_full_when_can_shoot"] = can_shoot.get("efficiency", -1.0) == 1.0

	# 1.0 when cheating: peeked amount below
	# ammoPerShot, but the build is cheating.
	var cheating: Dictionary = item_turret_build.source_item_turret_efficiency_state(true, 1, 2, 5, true)
	proof["efficiency_full_when_cheating"] = cheating.get("efficiency", -1.0) == 1.0

	# 0.0 when the build is not an ItemTurretBuild,
	# even with ammo and a cheating flag.
	var not_build: Dictionary = item_turret_build.source_item_turret_efficiency_state(false, 2, 5, 1, true)
	proof["efficiency_zero_when_not_item_turret_build"] = not_build.get("efficiency", -1.0) == 0.0

	# 0.0 with no ammo: the peeked amount is never
	# read when the seq is empty.
	var no_ammo: Dictionary = item_turret_build.source_item_turret_efficiency_state(true, 0, 0, 1, false)
	proof["efficiency_zero_when_no_ammo"] = no_ammo.get("efficiency", -1.0) == 0.0

	# 0.0 when the peeked amount is below ammoPerShot
	# and the build is not cheating.
	var below: Dictionary = item_turret_build.source_item_turret_efficiency_state(true, 3, 1, 5, false)
	proof["efficiency_zero_when_peek_below_per_shot"] = below.get("efficiency", -1.0) == 0.0

	# 1.0 at exactly ammoPerShot: the gate is >=, not
	# >.
	var exact: Dictionary = item_turret_build.source_item_turret_efficiency_state(true, 1, 1, 1, false)
	proof["efficiency_full_at_exact_per_shot"] = exact.get("efficiency", -1.0) == 1.0

	# The result carries only the efficiency key.
	proof["efficiency_returns_only_one_key"] = can_shoot.size() == 1 and cheating.size() == 1 and not_build.size() == 1 and no_ammo.size() == 1 and below.size() == 1 and exact.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ItemTurretEfficiencyProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
