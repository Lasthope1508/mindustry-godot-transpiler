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

	# --- ContinuousTurretBuild.version() + write() + read() (N2375):
	# ContinuousTurretBuild.version()
	# (ContinuousTurret.java:176-178) stamps the save revision:
	# `public byte version(){`
	# `return 3;`
	# `}`
	# ContinuousTurretBuild.write()
	# (ContinuousTurret.java:181-185) persists the single own
	# field lastLength:
	# `public void write(Writes write){`
	# `super.write(write);`
	# `write.f(lastLength);`
	# `}`
	# ContinuousTurretBuild.read()
	# (ContinuousTurret.java:188-194) restores it only for
	# saves at revision >= 3:
	# `public void read(Reads read, byte revision){`
	# `super.read(read, revision);`
	# `if(revision >= 3){`
	# `lastLength = read.f();`
	# `}`
	# `}`
	# on `public class ContinuousTurretBuild extends TurretBuild{`
	# (ContinuousTurret.java:38). The super layer is
	# TurretBuild.write/read (N2322), a callee, not re-ported
	# here. The port has no save/load stream, so the value
	# read.f() would return arrives as the explicit
	# stored_last_length param (the N2330 param precedent).
	# A revision below 3 leaves lastLength where it already
	# is. NO driver tick line: persistence is not a per-tick
	# call. The proof calls the pure function with synthetic
	# scalar inputs (no live tick). All values are
	# float32-safe, so write/read round-trips exactly.

	# version() is always 3, whatever the field or revision.
	var stamped: Dictionary = bridge.source_continuous_turret_build_version_write_read_state(32.0, 3, 99.0)
	proof["version_returns_three"] = int(stamped.get("version", -1)) == 3

	# write() persists the current lastLength.
	proof["write_persists_last_length"] = float(stamped.get("write_last_length", -1.0)) == 32.0

	# write() carries no revision: the persisted value is the
	# current lastLength at revision 0 and at revision 5 alike.
	var written_old: Dictionary = bridge.source_continuous_turret_build_version_write_read_state(12.5, 0, 99.0)
	var written_new: Dictionary = bridge.source_continuous_turret_build_version_write_read_state(12.5, 5, 99.0)
	proof["write_ignores_revision"] = float(written_old.get("write_last_length", -1.0)) == 12.5 and float(written_new.get("write_last_length", -1.0)) == 12.5

	# read() at exactly revision 3 restores the stored value.
	proof["read_restores_at_revision_three"] = float(stamped.get("last_length", -1.0)) == 99.0

	# read() above revision 3 restores the stored value too.
	var restored_above: Dictionary = bridge.source_continuous_turret_build_version_write_read_state(32.0, 4, 77.5)
	proof["read_restores_above_revision_three"] = float(restored_above.get("last_length", -1.0)) == 77.5

	# read() below revision 3 keeps the current value.
	var kept_below: Dictionary = bridge.source_continuous_turret_build_version_write_read_state(32.0, 2, 99.0)
	proof["read_keeps_current_below_revision_three"] = float(kept_below.get("last_length", -1.0)) == 32.0

	# read() at revision 0 keeps the current value.
	var kept_zero: Dictionary = bridge.source_continuous_turret_build_version_write_read_state(32.0, 0, 99.0)
	proof["read_keeps_current_at_revision_zero"] = float(kept_zero.get("last_length", -1.0)) == 32.0

	# write then read round-trips: the value write() persists
	# is the value read() restores at revision 3.
	var written: Dictionary = bridge.source_continuous_turret_build_version_write_read_state(48.0, 3, 48.0)
	proof["write_then_read_round_trips"] = float(written.get("write_last_length", -1.0)) == float(written.get("last_length", -2.0)) and float(written.get("last_length", -1.0)) == 48.0

	# The revision gate IS the version stamp: reading at a
	# revision equal to version() restores the stored value.
	var at_version: Dictionary = bridge.source_continuous_turret_build_version_write_read_state(32.0, int(stamped.get("version", -1)), 64.0)
	proof["version_matches_revision_gate"] = int(stamped.get("version", -1)) == 3 and float(at_version.get("last_length", -1.0)) == 64.0

	# Each result carries ONLY its three keys.
	proof["returns_only_three_keys"] = stamped.size() == 3 and written.size() == 3

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ContinuousTurretVersionWriteReadProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
