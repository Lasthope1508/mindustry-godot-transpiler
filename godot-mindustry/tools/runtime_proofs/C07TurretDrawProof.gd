extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

var _stub_calls: int = 0
var _received_build: Dictionary = {}


func _draw_stub(build: Dictionary) -> void:
	_stub_calls += 1
	_received_build = build


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

	# --- Pure draw() row (N2377): TurretBuild.draw()
	# (Turret.java:476-478) is one line: `drawer.draw(this);`
	# (Turret.java:477). The drawer is the block-level
	# DrawBlock field (`public DrawBlock drawer = new
	# DrawTurret();`, Turret.java:155) -- it arrives as an
	# explicit Callable param (the SourceBlockGeometry
	# world_tile_lookup precedent: guarded with is_valid(),
	# invoked with .call()), NOT re-ported here; DrawTurret
	# itself is NOT ported. The build (`this`) arrives as an
	# explicit Dictionary param. The proof calls the pure
	# function source_turret_draw_state(drawer, build)
	# directly with a stub drawer bound to _draw_stub; there
	# is no driver-tick key: draw() is a render delegate, not
	# tick state.

	# The drawer is invoked once and the delegation flag reads true.
	var build: Dictionary = {"marker": "turret-build-a", "x": 100.0, "y": 200.0}
	var delegated: Dictionary = turret_build_state.source_turret_draw_state(Callable(self, "_draw_stub"), build)
	proof["draw_delegates_to_drawer"] = bool(delegated.get("draw_delegated", false)) and bool(delegated.get("drawer_called", false)) and _stub_calls == 1

	# The drawer receives the build itself (the `this` of `drawer.draw(this);`).
	proof["draw_passes_build_to_drawer"] = _received_build == build and str(_received_build.get("marker", "")) == "turret-build-a"

	# A second draw with a different build still delegates.
	var other: Dictionary = {"marker": "turret-build-b", "x": 300.0, "y": 400.0}
	var again: Dictionary = turret_build_state.source_turret_draw_state(Callable(self, "_draw_stub"), other)
	proof["draw_returns_delegated_flag"] = bool(again.get("draw_delegated", false)) and _stub_calls == 2 and str(_received_build.get("marker", "")) == "turret-build-b"

	# An invalid drawer is not invoked, but the delegation flag still reads true.
	var uninvoked: Dictionary = turret_build_state.source_turret_draw_state(Callable(), build)
	proof["draw_reports_uninvoked_drawer"] = bool(uninvoked.get("draw_delegated", false)) and not bool(uninvoked.get("drawer_called", true)) and _stub_calls == 2

	# The result carries exactly two keys.
	proof["draw_returns_only_two_keys"] = delegated.keys().size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretDrawProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
