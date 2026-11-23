extends Node

const main_scene := preload("res://scenes/Main.tscn")
const bridge := preload("res://src/game/SourceContinuousTurretBuildPortBridge.gd")
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

	# --- ContinuousTurretBuild.useAmmo() + shouldConsume() + peekAmmo() + activeSoundVolume() (N2421):
	# ContinuousTurretBuild.useAmmo()
	# (ContinuousTurret.java:54-57) returns shootType:
	# `public BulletType useAmmo(){`
	# `//nothing used directly`
	# `return shootType;`
	# `}`
	# ContinuousTurretBuild.shouldConsume()
	# (ContinuousTurret.java:65-67) returns isShooting:
	# `public boolean shouldConsume(){`
	# `return isShooting;`
	# `}`
	# ContinuousTurretBuild.peekAmmo()
	# (ContinuousTurret.java:70-72) returns shootType:
	# `public BulletType peekAmmo(){`
	# `return shootType;`
	# `}`
	# ContinuousTurretBuild.activeSoundVolume()
	# (ContinuousTurret.java:171-173) returns 1f:
	# `public float activeSoundVolume(){`
	# `return 1f;`
	# `}`
	# on `public class ContinuousTurretBuild extends TurretBuild{`
	# (ContinuousTurret.java:38). shootType is the block
	# field `public BulletType shootType = Bullets.placeholder;`
	# (ContinuousTurret.java:15) and arrives as an
	# explicit Variant param (the N2330 param precedent);
	# isShooting is the TurretBuild field (Turret.java:292)
	# and arrives as an explicit bool param. hasAmmo()
	# (ContinuousTurret.java:60-62) is NOT here -- already
	# owned by N2389. One owner + one pure function for
	# the four methods (the N2418 precedent). NO driver
	# tick line: the proof calls the one pure function
	# with synthetic inputs (no live tick).

	# useAmmo returns the shoot type unchanged.
	var shoot_type: Dictionary = {"name": "laser-bullet", "damage": 10.0}
	var used: Dictionary = bridge.source_continuous_turret_build_ammo_one_liners_state(shoot_type, true)
	proof["use_ammo_returns_shoot_type"] = used.get("use_ammo", null) == shoot_type

	# useAmmo returns null when there is no shoot type.
	var used_none: Dictionary = bridge.source_continuous_turret_build_ammo_one_liners_state(null, true)
	proof["use_ammo_returns_null_when_no_type"] = used_none.has("use_ammo") and used_none.get("use_ammo", "sentinel") == null

	# shouldConsume is true while shooting.
	proof["should_consume_true_when_shooting"] = bool(used.get("should_consume", false)) == true

	# shouldConsume is false while not shooting.
	var idle: Dictionary = bridge.source_continuous_turret_build_ammo_one_liners_state(shoot_type, false)
	proof["should_consume_false_when_not_shooting"] = bool(idle.get("should_consume", true)) == false

	# peekAmmo returns the shoot type unchanged.
	proof["peek_ammo_returns_shoot_type"] = used.get("peek_ammo", null) == shoot_type

	# peekAmmo returns null when there is no shoot type.
	proof["peek_ammo_returns_null_when_no_type"] = used_none.has("peek_ammo") and used_none.get("peek_ammo", "sentinel") == null

	# activeSoundVolume is always 1f.
	proof["active_sound_volume_is_one"] = float(used.get("active_sound_volume", -1.0)) == 1.0 and float(idle.get("active_sound_volume", -1.0)) == 1.0

	# Each result carries ONLY its four keys.
	proof["returns_only_expected_keys"] = used.size() == 4 and used_none.size() == 4 and idle.size() == 4

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ContinuousTurretAmmoOneLinersProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
