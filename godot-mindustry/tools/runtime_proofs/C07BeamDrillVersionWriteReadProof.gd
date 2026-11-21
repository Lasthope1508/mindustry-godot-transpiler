extends Node

const main_scene := preload("res://scenes/Main.tscn")
const state := preload("res://src/game/SourceBeamDrillBuildState.gd")
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

	# --- BeamDrillBuild.version() + write() + read() (N2378):
	# BeamDrillBuild.version()
	# (BeamDrill.java:414-416) stamps the save revision:
	# `public byte version(){`
	# `return 1;`
	# `}`
	# BeamDrillBuild.write()
	# (BeamDrill.java:419-424) persists the two own fields
	# time and warmup:
	# `public void write(Writes write){`
	# `super.write(write);`
	# `write.f(time);`
	# `write.f(warmup);`
	# `}`
	# BeamDrillBuild.read()
	# (BeamDrill.java:426-433) restores them only for
	# saves at revision >= 1:
	# `public void read(Reads read, byte revision){`
	# `super.read(read, revision);`
	# `if(revision >= 1){`
	# `time = read.f();`
	# `warmup = read.f();`
	# `}`
	# `}`
	# on `public class BeamDrillBuild extends Building{`
	# (BeamDrill.java:220). The super layer is
	# DrillBuild.write/read (N2286), a callee, not re-ported
	# here. The port has no save/load stream, so the values
	# read.f() would return arrive as the explicit
	# stored_time / stored_warmup params (the N2330 param
	# precedent). A revision below 1 leaves time and warmup
	# where they already are. NO driver tick line:
	# persistence is not a per-tick call. The proof calls
	# the pure function with synthetic scalar inputs (no
	# live tick). All values are float32-safe, so write/read
	# round-trips exactly. Write order is time then warmup
	# (BeamDrill.java:421-422), read order the same
	# (:429-430).

	# version() is always 1, whatever the fields or revision.
	var stamped: Dictionary = state.source_beam_drill_version_write_read_state(32.0, 0.5, 1, 99.0, 0.25)
	proof["version_returns_one"] = int(stamped.get("version", -1)) == 1

	# write() persists the current time.
	proof["write_persists_time"] = float(stamped.get("write_time", -1.0)) == 32.0

	# write() persists the current warmup.
	proof["write_persists_warmup"] = float(stamped.get("write_warmup", -1.0)) == 0.5

	# write() carries no revision: the persisted values are
	# the current time and warmup at revision 0 and at
	# revision 5 alike.
	var written_old: Dictionary = state.source_beam_drill_version_write_read_state(12.5, 0.75, 0, 99.0, 0.25)
	var written_new: Dictionary = state.source_beam_drill_version_write_read_state(12.5, 0.75, 5, 99.0, 0.25)
	proof["write_ignores_revision"] = float(written_old.get("write_time", -1.0)) == 12.5 and float(written_old.get("write_warmup", -1.0)) == 0.75 and float(written_new.get("write_time", -1.0)) == 12.5 and float(written_new.get("write_warmup", -1.0)) == 0.75

	# read() at exactly revision 1 restores the stored values.
	proof["read_restores_at_revision_one"] = float(stamped.get("time", -1.0)) == 99.0 and float(stamped.get("warmup", -1.0)) == 0.25

	# read() above revision 1 restores the stored values too.
	var restored_above: Dictionary = state.source_beam_drill_version_write_read_state(32.0, 0.5, 2, 77.5, 0.125)
	proof["read_restores_above_revision_one"] = float(restored_above.get("time", -1.0)) == 77.5 and float(restored_above.get("warmup", -1.0)) == 0.125

	# read() at revision 0 keeps the current values (the only
	# revision below the gate 1).
	var kept_zero: Dictionary = state.source_beam_drill_version_write_read_state(32.0, 0.5, 0, 99.0, 0.25)
	proof["read_keeps_current_at_revision_zero"] = float(kept_zero.get("time", -1.0)) == 32.0 and float(kept_zero.get("warmup", -1.0)) == 0.5

	# write then read round-trips: the values write()
	# persists are the values read() restores at revision 1.
	var written: Dictionary = state.source_beam_drill_version_write_read_state(48.0, 0.625, 1, 48.0, 0.625)
	proof["write_then_read_round_trips"] = float(written.get("write_time", -1.0)) == float(written.get("time", -2.0)) and float(written.get("write_warmup", -1.0)) == float(written.get("warmup", -2.0)) and float(written.get("time", -1.0)) == 48.0 and float(written.get("warmup", -1.0)) == 0.625

	# The revision gate IS the version stamp: reading at a
	# revision equal to version() restores the stored values.
	var at_version: Dictionary = state.source_beam_drill_version_write_read_state(32.0, 0.5, int(stamped.get("version", -1)), 64.0, 0.375)
	proof["version_matches_revision_gate"] = int(stamped.get("version", -1)) == 1 and float(at_version.get("time", -1.0)) == 64.0 and float(at_version.get("warmup", -1.0)) == 0.375

	# Each result carries ONLY its five keys.
	proof["returns_only_five_keys"] = stamped.size() == 5 and written.size() == 5

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillVersionWriteReadProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
