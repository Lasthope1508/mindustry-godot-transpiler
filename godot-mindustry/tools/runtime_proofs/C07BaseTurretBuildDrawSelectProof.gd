extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

var _stub_calls: int = 0
var _received_circle: Array = []


func _dash_circle_stub(x: float, y: float, radius: float, color: String) -> void:
	_stub_calls += 1
	_received_circle = [x, y, radius, color]


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

	# --- Pure drawSelect() row (N2393):
	# BaseTurretBuild.drawSelect() (BaseTurret.java:133-135)
	# is one line: `Drawf.dashCircle(x, y, range(),
	# team.color);` (BaseTurret.java:134). The center is the
	# building world position, the radius is the LIVE range()
	# value (BaseTurret.java:124-125 -- the caller passes it
	# in as the explicit range_value param; the field `range`
	# is 80f by default, BaseTurret.java:22), the color is
	# the building team color (passed as a String, the
	# SourceBuildingDrawState draw_team precedent).
	# Drawf.dashCircle arrives as an explicit Callable param
	# (the N2377 drawer precedent: guarded with is_valid(),
	# invoked with .call()); Drawf itself is NOT ported.
	# The proof calls the pure function
	# source_base_turret_build_draw_select_state(x, y,
	# range_value, team_color, dash_circle) directly with a
	# stub dash circle bound to _dash_circle_stub; there is
	# no driver-tick key: drawSelect() is selection UI, not
	# tick state. Float comparisons use is_equal_approx (the
	# N2310 write/read precedent for inexact float32 values).

	# A valid dash circle is invoked once with the center,
	# the live range and the team color, and the flag reads true.
	var drawn: Dictionary = turret_build_state.source_base_turret_build_draw_select_state(100.0, 200.0, 80.0, "ffd37f", Callable(self, "_dash_circle_stub"))
	proof["draw_select_circle_called"] = bool(drawn.get("dash_circle_called", false)) and _stub_calls == 1 and _received_circle == [100.0, 200.0, 80.0, "ffd37f"]

	# An invalid dash circle is not invoked, but the result
	# still carries the center, radius and color.
	var uninvoked: Dictionary = turret_build_state.source_base_turret_build_draw_select_state(100.0, 200.0, 80.0, "ffd37f", Callable())
	proof["draw_select_circle_not_called"] = not bool(uninvoked.get("dash_circle_called", true)) and _stub_calls == 1

	# A live range reads its own value: 120.0 stays 120.0.
	var live: Dictionary = turret_build_state.source_base_turret_build_draw_select_state(100.0, 200.0, 120.0, "ffd37f", Callable(self, "_dash_circle_stub"))
	proof["draw_select_radius_live"] = is_equal_approx(float(live.get("radius", -1.0)), 120.0) and _stub_calls == 2 and is_equal_approx(float(_received_circle[2]), 120.0)

	# A zero live range draws a zero-radius circle (the call
	# still happens -- drawSelect() is unconditional).
	var zero: Dictionary = turret_build_state.source_base_turret_build_draw_select_state(100.0, 200.0, 0.0, "ffd37f", Callable(self, "_dash_circle_stub"))
	proof["draw_select_radius_zero_range"] = bool(zero.get("dash_circle_called", false)) and is_equal_approx(float(zero.get("radius", -1.0)), 0.0) and _stub_calls == 3

	# The circle is centered on the building position.
	var centered: Dictionary = turret_build_state.source_base_turret_build_draw_select_state(100.0, 200.0, 80.0, "ffd37f", Callable(self, "_dash_circle_stub"))
	proof["draw_select_center"] = Vector2(centered.get("center", Vector2(-1.0, -1.0))) == Vector2(100.0, 200.0)

	# The circle color is the building team color.
	var colored: Dictionary = turret_build_state.source_base_turret_build_draw_select_state(100.0, 200.0, 80.0, "f25555", Callable(self, "_dash_circle_stub"))
	proof["draw_select_color_team"] = str(colored.get("color", "")) == "f25555" and str(_received_circle[3]) == "f25555"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BaseTurretBuildDrawSelectProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
