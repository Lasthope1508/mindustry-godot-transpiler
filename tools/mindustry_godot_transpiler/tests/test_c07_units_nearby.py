import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitRuntimeState.gd'
UNITS_NEARBY_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitsNearbyProof.gd'


class C07UnitsNearbyTests(unittest.TestCase):
    def test_c07_units_nearby_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2210']['godot_owner'], 'SourceUnitRuntimeState.source_units_nearby_damaged_count_state')
        # N2190 wired the RepairTower target refresh to consume
        # the `nearby_damaged_units` observation (an INT count,
        # read via `int(observed)`), and N2191 wired the
        # shouldConsume gate on the stamped `targets_count`;
        # the query that PRODUCES the observation is this
        # slice. RepairTowerBuild.updateTile refreshes its
        # targets every 6s of powered operation
        # (`if(potentialEfficiency > 0 && (refresh +=
        # Time.delta) >= refreshInterval){`, RepairTower.java:59)
        # by clearing them (`targets.clear();`,
        # RepairTower.java:60), resetting the timer
        # (`refresh = 0f;`, RepairTower.java:61) and re-querying
        # (`Units.nearby(team, x, y, range, u -> {`,
        # RepairTower.java:62) for damaged units
        # (`if(u.damaged()){`, RepairTower.java:63)
        # (`targets.add(u);`, RepairTower.java:64). The circle
        # overload (`public static void nearby(@Nullable Team
        # team, float x, float y, float radius, Cons<Unit>
        # cons){`, Units.java:445) first intersects the rect
        # (`nearby(team, x - radius, y - radius, radius*2f,
        # radius*2f, unit -> {`, Units.java:446) then keeps only
        # units within the effective radius
        # (`if(unit.within(x, y, radius + unit.hitSize/2f)){`,
        # Units.java:449). The rect overload
        # (`public static void nearby(@Nullable Team team, float
        # x, float y, float width, float height, Cons<Unit>
        # cons){`, Units.java:434) filters by team: a non-null
        # team reads only that team's tree
        # (`team.data().tree().intersect(x, y, width, height,
        # cons);`, Units.java:436), a null team reads every
        # present team's tree (`for(var other :
        # state.teams.present){`, Units.java:438 /
        # `other.tree().intersect(x, y, width, height, cons);`,
        # Units.java:439). Damaged is the HealthComp predicate
        # (`boolean damaged(){`, HealthComp.java:47 /
        # `return health < maxHealth - 0.001f;`,
        # HealthComp.java:48) -- health strictly below maxHealth
        # minus 0.001, NOT plain `health < maxHealth`. One new
        # result symbol: the nearby damaged count itself, which
        # is exactly the `nearby_damaged_units` observation the
        # N2190 refresh consumes.
        self.assertEqual(
            ledger['N2210']['source_symbols'],
            [
                'source_units_nearby_damaged_count_state_result.nearby_damaged_units',
            ],
        )
        for name in ledger['N2210']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/Units.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_units_nearby_damaged_count_state_result.nearby_damaged_units': 'SourceUnitRuntimeState.source_units_nearby_damaged_count_state',
                }[name])
        self.assertEqual(ledger['N2210']['runtime_proof'], '/root/C07UnitsNearbyProof')
        self.assertEqual(
            ledger['N2210']['tests'],
            [
                'test_c07_units_nearby_registration',
                'test_all_c07_units_nearby_input_evidence_is_exact',
                'test_units_nearby_damaged_count_state',
                'test_reference_graph_and_actual_c07_units_nearby',
            ],
        )
        self.assertTrue(ledger['N2210']['deferred_exprs'])

    def test_all_c07_units_nearby_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2210']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_units_nearby_damaged_count_state_result.nearby_damaged_units': 'SourceUnitRuntimeState.source_units_nearby_damaged_count_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/entities/Units.java',
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/entities/comp/HealthComp.java',
            'core/src/mindustry/type/UnitType.java',
            'core/src/mindustry/entities/comp/UnitComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2210']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_units_nearby_damaged_count_state(self):
        unit_state = UNIT_STATE.read_text(encoding='utf-8')
        # The live query lives on the units runtime state (the
        # N2140 precedent: Units.* statics live in
        # SourceUnitRuntimeState.gd, next to
        # source_units_can_create_state): the circle overload
        # (`public static void nearby(@Nullable Team team,
        # float x, float y, float radius, Cons<Unit> cons){`,
        # Units.java:445) intersects the rect
        # (`nearby(team, x - radius, y - radius, radius*2f,
        # radius*2f, unit -> {`, Units.java:446) then keeps only
        # units within the effective radius
        # (`if(unit.within(x, y, radius + unit.hitSize/2f)){`,
        # Units.java:449). Damaged is the HealthComp predicate
        # (`return health < maxHealth - 0.001f;`,
        # HealthComp.java:48). The query is what the N2190
        # RepairTower refresh consumes: `Units.nearby(team, x,
        # y, range, u -> {` / `if(u.damaged()){` /
        # `targets.add(u);` (RepairTower.java:62-64).
        self.assertIn('static func source_units_nearby_damaged_count_state', unit_state)
        # The query cases, pinned as the pure function's
        # decision structure: the caller passes the units array
        # (the N2141 pattern -- an Array of Dictionary unit
        # records, non-Dictionary entries skipped), the team
        # filter (Variant: null reads ALL teams, an int reads
        # only that team -- the @Nullable Team of the rect
        # overload), and the tower position + radius. A unit
        # record carries `team_id`, `x`, `y`, `hit_size`,
        # `health`, `max_health` (the N2141 record convention
        # plus the UnitComp imports: `@Import float x, y,
        # rotation, maxHealth, drag, armor, hitSize, health,
        # shield, dragMultiplier, armorOverride,
        # speedMultiplier;`, UnitComp.java:41). Absent keys read
        # the Java field defaults: `team_id` -1 (matches no
        # team when the filter is set), `x`/`y` 0.0,
        # `hit_size` 6.0 (the UnitType default, `hitSize = 6f,`,
        # UnitType.java:70 -- `this.hitSize = type.hitSize;`,
        # UnitComp.java:536), `health` 0.0 (no initializer,
        # HealthComp.java:11 `float health;`), `max_health`
        # 1.0 (`transient float maxHealth = 1f;`,
        # HealthComp.java:13) -- so a record with no health
        # observation counts as damaged (0.0 < 1.0 - 0.001).
        # The rect pre-filter is the unit hitbox overlapping
        # the query rect (QuadTree.intersect: `hitbox(item);`
        # / `if(tmp.overlaps(x, y, width, height)){`,
        # QuadTree.java:190-191, over the hitbox square
        # `rect.setCentered(x, y, hitSize, hitSize);`,
        # HitboxComp.java:65-67, with the STRICT overlap
        # `return x < rx + rwidth && x + width > rx && y < ry
        # + rheight && y + height > ry;`, Rect.java:274-276) --
        # i.e. |dx| < radius + hitSize/2 and |dy| < radius +
        # hitSize/2 -- but the circle test subsumes it
        # (dst2 < (radius + hitSize/2)^2 implies both), so the
        # rect can never change the count; it is kept as the
        # cheap early skip Java performs. The circle test is
        # STRICT (`return Mathf.dst2(getX(), getY(), x, y) <
        # dst*dst;`, Position.java:44-46): a unit exactly on
        # the effective radius is NOT counted. The result is
        # the single-key dict `{"nearby_damaged_units": count}`
        # -- the int observation the N2190 refresh reads via
        # `int(observed)`; no unit list is returned (the
        # targets list on the tower frame is the later
        # integration slice's business). NO driver tick line:
        # no driver can supply a live units list (the N2190
        # finding -- PortGame.gd exposes no unit-listing
        # accessor, SourceTeamsRuntimeState teams carry empty
        # "units" arrays, SourceEnemyUnitRuntimeState holds
        # enemy dicts of the wrong team), so the integration
        # that calls the query is its own later slice -- the
        # N2208/N2209 precedent.
        self.assertIn('if not unit is Dictionary:', unit_state)
        self.assertIn('if team_id != null and int(unit.get("team_id", -1)) != int(team_id):', unit_state)
        self.assertIn('var hit_size: float = float(unit.get("hit_size", 6.0))', unit_state)
        self.assertIn('var unit_x: float = float(unit.get("x", 0.0))', unit_state)
        self.assertIn('var unit_y: float = float(unit.get("y", 0.0))', unit_state)
        self.assertIn('var health: float = float(unit.get("health", 0.0))', unit_state)
        self.assertIn('var max_health: float = float(unit.get("max_health", 1.0))', unit_state)
        self.assertIn('if health < max_health - 0.001:', unit_state)
        self.assertIn('if dx * dx + dy * dy >= effective_radius * effective_radius:', unit_state)
        self.assertIn('return {"nearby_damaged_units": count}', unit_state)
        self.assertIn('public static void nearby(@Nullable Team team, float x, float y, float radius, Cons<Unit> cons){', unit_state)
        self.assertIn('if(unit.within(x, y, radius + unit.hitSize/2f)){', unit_state)
        self.assertIn('return health < maxHealth - 0.001f;', unit_state)
        self.assertIn('Units.nearby(team, x, y, range, u -> {', unit_state)
        self.assertIn('if(u.damaged()){', unit_state)
        self.assertIn('hitSize = 6f,', unit_state)
        self.assertIn('rect.setCentered(x, y, hitSize, hitSize);', unit_state)
        self.assertIn('return x < rx + rwidth && x + width > rx && y < ry + rheight && y + height > ry;', unit_state)
        self.assertIn('return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', unit_state)
        # The proof's keys drive the pure query (damaged
        # same-team inside counts / undamaged inside does not
        # / other team does not under a set filter / null team
        # counts all teams / rect-corner unit outside the
        # circle does not / a unit exactly on the effective
        # radius does not, strict <). There are no refresh /
        # targets_count / shouldConsume / heal keys: the N2190
        # refresh and N2191 gate are already ported and consume
        # this observation, and the integration that wires the
        # query into the driver waits for its own slice.
        proof = UNITS_NEARBY_PROOF.read_text(encoding='utf-8')
        for key in [
            'count_damaged_same_team_inside',
            'count_excludes_undamaged_inside',
            'count_excludes_other_team',
            'count_null_team_counts_all_teams',
            'count_excludes_rect_corner_outside_circle',
            'count_strict_boundary_excluded',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_units_nearby(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitsNearbyProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNITS_NEARBY_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'count_damaged_same_team_inside',
            'count_excludes_undamaged_inside',
            'count_excludes_other_team',
            'count_null_team_counts_all_teams',
            'count_excludes_rect_corner_outside_circle',
            'count_strict_boundary_excluded',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
