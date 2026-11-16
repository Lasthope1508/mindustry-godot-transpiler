extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_runtime_state := preload("res://src/game/SourceUnitRuntimeState.gd")
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

	# --- Pure Units.nearby live query (N2210): the query that
	# produces the `nearby_damaged_units` observation N2190's
	# RepairTower refresh consumes. The refresh block
	# (`if(potentialEfficiency > 0 && (refresh += Time.delta)
	# >= refreshInterval){`, RepairTower.java:59) clears the
	# targets (`targets.clear();`, RepairTower.java:60), resets
	# the timer (`refresh = 0f;`, RepairTower.java:61) and
	# re-queries (`Units.nearby(team, x, y, range, u -> {`,
	# RepairTower.java:62) for damaged units
	# (`if(u.damaged()){`, RepairTower.java:63 /
	# `targets.add(u);`, RepairTower.java:64). The circle
	# overload (`public static void nearby(@Nullable Team team,
	# float x, float y, float radius, Cons<Unit> cons){`,
	# Units.java:445) first intersects the rect
	# (`nearby(team, x - radius, y - radius, radius*2f,
	# radius*2f, unit -> {`, Units.java:446) then keeps only
	# units within the effective radius
	# (`if(unit.within(x, y, radius + unit.hitSize/2f)){`,
	# Units.java:449). Damaged is the HealthComp predicate
	# (`return health < maxHealth - 0.001f;`,
	# HealthComp.java:48). The query is a read the driver
	# integration uses, not a tick write: NO driver tick line
	# belongs here (the N2208/N2209 precedent), so the proof
	# calls the pure function
	# source_units_nearby_damaged_count_state(units, team_id, x,
	# y, radius) directly with synthetic unit records. Tower
	# centre (0, 0); RepairTower class range 80f
	# (`public float range = 80f;`, RepairTower.java:21).

	# Damaged same-team units inside count: two damaged units
	# of team 1 inside radius 80 -- one with an explicit
	# hit_size 6 at (10, 0), one with NO hit_size key at
	# (82, 0). The absent hit_size reads 6.0 (the UnitType
	# default, `hitSize = 6f,`, UnitType.java:70), so the
	# second unit's effective radius is 80 + 3 = 83 and 82 <
	# 83 counts it; with a 0.0 default it would not count.
	# Expect 2.
	var inside: Dictionary = unit_runtime_state.source_units_nearby_damaged_count_state([
		{"team_id": 1, "x": 10.0, "y": 0.0, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
		{"team_id": 1, "x": 82.0, "y": 0.0, "health": 50.0, "max_health": 100.0},
	], 1, 0.0, 0.0, 80.0)
	proof["count_damaged_same_team_inside"] = int(inside.get("nearby_damaged_units", -1)) == 2

	# Undamaged inside does not count: a full-health unit of
	# team 1 at (10, 0) -- health 100 == maxHealth 100, so
	# `health < maxHealth - 0.001f` is false. Expect 0.
	var whole: Dictionary = unit_runtime_state.source_units_nearby_damaged_count_state([
		{"team_id": 1, "x": 10.0, "y": 0.0, "hit_size": 6.0, "health": 100.0, "max_health": 100.0},
	], 1, 0.0, 0.0, 80.0)
	proof["count_excludes_undamaged_inside"] = int(whole.get("nearby_damaged_units", -1)) == 0

	# Other team does not count under a set filter: a damaged
	# unit of team 2 at (10, 0) with the filter set to team 1
	# -- the rect overload reads only the filtered team's tree
	# (`team.data().tree().intersect(x, y, width, height,
	# cons);`, Units.java:436). Expect 0.
	var foreign: Dictionary = unit_runtime_state.source_units_nearby_damaged_count_state([
		{"team_id": 2, "x": 10.0, "y": 0.0, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
	], 1, 0.0, 0.0, 80.0)
	proof["count_excludes_other_team"] = int(foreign.get("nearby_damaged_units", -1)) == 0

	# Null team counts all teams: damaged units of teams 1
	# and 2 inside radius 80 with a null filter -- the null
	# branch reads every present team's tree (`for(var other
	# : state.teams.present){`, Units.java:438). The team-2
	# unit carries NO health keys: absent health reads 0.0
	# and absent max_health reads 1.0 (the HealthComp field
	# defaults), so 0.0 < 1.0 - 0.001 counts it damaged.
	# Expect 2.
	var all_teams: Dictionary = unit_runtime_state.source_units_nearby_damaged_count_state([
		{"team_id": 1, "x": 10.0, "y": 0.0, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
		{"team_id": 2, "x": -10.0, "y": 0.0, "hit_size": 6.0},
	], null, 0.0, 0.0, 80.0)
	proof["count_null_team_counts_all_teams"] = int(all_teams.get("nearby_damaged_units", -1)) == 2

	# Rect corner outside the circle does not count: a damaged
	# unit of team 1 at (60, 60) -- inside the query rect
	# (|60| < 80 + 3) so the rect pre-filter passes it, but
	# dst^2 = 7200 > 83^2 = 6889, so the circle test
	# (`if(unit.within(x, y, radius + unit.hitSize/2f)){`,
	# Units.java:449) rejects it. Expect 0.
	var corner: Dictionary = unit_runtime_state.source_units_nearby_damaged_count_state([
		{"team_id": 1, "x": 60.0, "y": 60.0, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
	], 1, 0.0, 0.0, 80.0)
	proof["count_excludes_rect_corner_outside_circle"] = int(corner.get("nearby_damaged_units", -1)) == 0

	# Strict boundary excluded: radius 12 with a damaged unit
	# of team 1 at (9, 12) and hit_size 6 -- dst = 15 exactly,
	# the effective radius 12 + 3 = 15. The circle test is
	# STRICT (`return Mathf.dst2(getX(), getY(), x, y) <
	# dst*dst;`, Position.java:44-46): 15^2 < 15^2 is false,
	# so the unit is NOT counted even though it passes the
	# rect (|9| < 15, |12| < 15). Expect 0.
	var boundary: Dictionary = unit_runtime_state.source_units_nearby_damaged_count_state([
		{"team_id": 1, "x": 9.0, "y": 12.0, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
	], 1, 0.0, 0.0, 12.0)
	proof["count_strict_boundary_excluded"] = int(boundary.get("nearby_damaged_units", -1)) == 0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitsNearbyProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
