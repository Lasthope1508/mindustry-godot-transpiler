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

	# --- Read sync (N2353): TurretBuild.readSync() snapshots the aim rotation
	# and the reload counter, applies the sync payload via readAll, then
	# restores both values (`public void readSync(Reads read, byte revision){` /
	# `//maintain rotation and reload when syncing so clients don't see turrets
	# snapping around` / `float oldRot = rotation, oldReload = reloadCounter;` /
	# `readAll(read, revision);` / `rotation = oldRot;` /
	# `reloadCounter = oldReload;`, Turret.java:853-861). The rotation is the
	# RotComp float aim angle (`@SyncField(false) @SyncLocal float rotation;`,
	# RotComp.java:8), NOT the Building int rotation 0-3 (`transient int
	# rotation;`, BuildingComp.java:69). The reload counter is the
	# ReloadTurretBuild field (`public float reloadCounter;`,
	# ReloadTurret.java:26), default 0.0. revision is passed through to readAll
	# and the Turret override never branches on it. The proof calls the pure
	# function with synthetic frames and already-parsed sync payloads (no live
	# tick, no net stream: the payload arrives as read_data).

	# A payload carrying different rotation/reload values must NOT move the
	# turret: frame 135.0 / 12.5 with payload rotation 999.0 / reload 77.0
	# -> rotation 135.0, reload 12.5, read applied.
	var frame: Dictionary = {"rotation": 135.0, "reload_counter": 12.5}
	var payload: Dictionary = {"rotation": 999.0, "reload_counter": 77.0, "health": 42.0}
	var synced: Dictionary = turret_build_state.source_turret_read_sync_state(frame, payload, 1)
	proof["rotation_preserved"] = is_equal_approx(float(synced.get("rotation", -1.0)), 135.0)
	proof["reload_preserved"] = is_equal_approx(float(synced.get("reload_counter", -1.0)), 12.5)

	# A non-empty payload is reported applied.
	proof["read_applied"] = bool(synced.get("read_applied", false))

	# An empty payload is reported not applied -- readAll read nothing.
	var synced_empty: Dictionary = turret_build_state.source_turret_read_sync_state({"rotation": 45.0, "reload_counter": 3.0}, {}, 1)
	proof["read_empty_not_applied"] = bool(synced_empty.get("read_applied", true)) == false and is_equal_approx(float(synced_empty.get("rotation", -1.0)), 45.0) and is_equal_approx(float(synced_empty.get("reload_counter", -1.0)), 3.0)

	# Empty frame + empty payload gives the Java field defaults 0.0 / 0.0.
	var synced_defaults: Dictionary = turret_build_state.source_turret_read_sync_state({}, {}, 0)
	proof["defaults_zero"] = is_equal_approx(float(synced_defaults.get("rotation", -1.0)), 0.0) and is_equal_approx(float(synced_defaults.get("reload_counter", -1.0)), 0.0) and bool(synced_defaults.get("read_applied", true)) == false

	# The call mutates neither the frame nor the payload: the Java method
	# writes rotation/reloadCounter on the build, not on its arguments.
	proof["input_unmutated"] = is_equal_approx(float(frame.get("rotation", -1.0)), 135.0) and is_equal_approx(float(frame.get("reload_counter", -1.0)), 12.5) and is_equal_approx(float(payload.get("rotation", -1.0)), 999.0) and is_equal_approx(float(payload.get("reload_counter", -1.0)), 77.0) and is_equal_approx(float(payload.get("health", -1.0)), 42.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretReadSyncProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
