import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTowerBuildState.gd'
REPAIR_TOWER_LIVE_SCAN_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerLiveScanProof.gd'
REPAIR_TOWER_LIVE_SCAN_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerLiveScanProof.tscn'


class C07RepairTowerLiveScanTests(unittest.TestCase):
    def test_c07_repair_tower_live_scan_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2306']['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_supplied_damaged_state')
        # N2227 proved the updateTile advance (the refresh
        # cadence + clear, the suppression early return, the
        # heal loop, the warmup lerp, the totalProgress
        # advance) -- but the refill was a SUPPLIED list: the
        # live Units.nearby scan (RepairTower.java:62-66) was
        # deferred, so the tick refilled with the targets the
        # tower already knew and a live tower with no refresh
        # never acquired a target. N2306 is the scan: a pure
        # filter over the frame-supplied unit candidates by
        # the exact Java predicates -- damaged (`return health
        # < maxHealth - 0.001f;`, HealthComp.java:47-49) and
        # in range (`unit.within(x, y, radius +
        # unit.hitSize/2f)`, Units.java:447, with within a
        # STRICT dst2 < (radius + hitSize/2)^2,
        # Position.java:44-46) -- returning the refill list.
        # Five new result symbols: the refill list, the
        # admitted count, the examined count, the healthy
        # exclusion count, and the out-of-range count.
        self.assertEqual(
            ledger['N2306']['source_symbols'],
            [
                'source_repair_tower_supplied_damaged_state_result.supplied_damaged',
                'source_repair_tower_supplied_damaged_state_result.damaged_count',
                'source_repair_tower_supplied_damaged_state_result.candidate_count',
                'source_repair_tower_supplied_damaged_state_result.healthy_excluded_count',
                'source_repair_tower_supplied_damaged_state_result.out_of_range_count',
            ],
        )
        expected_sources = {
            'source_repair_tower_supplied_damaged_state_result.supplied_damaged': 'core/src/mindustry/world/blocks/units/RepairTower.java',
            'source_repair_tower_supplied_damaged_state_result.damaged_count': 'core/src/mindustry/world/blocks/units/RepairTower.java',
            'source_repair_tower_supplied_damaged_state_result.candidate_count': 'core/src/mindustry/world/blocks/units/RepairTower.java',
            'source_repair_tower_supplied_damaged_state_result.healthy_excluded_count': 'core/src/mindustry/entities/comp/HealthComp.java',
            'source_repair_tower_supplied_damaged_state_result.out_of_range_count': 'core/src/mindustry/entities/Units.java',
        }
        for name in ledger['N2306']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_supplied_damaged_state')
        self.assertEqual(ledger['N2306']['runtime_proof'], '/root/C07RepairTowerLiveScanProof')
        self.assertEqual(
            ledger['N2306']['tests'],
            [
                'test_c07_repair_tower_live_scan_registration',
                'test_all_c07_repair_tower_live_scan_input_evidence_is_exact',
                'test_repair_tower_live_scan_state',
                'test_reference_graph_and_actual_c07_repair_tower_live_scan',
            ],
        )
        self.assertTrue(ledger['N2306']['deferred_exprs'])
        # This slice REWRITES the N2227 live-scan entry (166)
        # to drop only the scan clause -- the heal application
        # (target.heal writes into another unit frame) still
        # waits -- and adds the live unit-candidate query
        # deferral (no live unit query fills
        # frame["unit_candidates"] yet). The suppression live
        # fill stays deferred. The older live-targets-refresh
        # entry (156) stays as-is: its "waits for the
        # updateTile advance slice" clause was satisfied by
        # N2227, so it is stale -- flagged to the coordinator
        # rather than resolved here, since it is not this
        # slice's entry.
        self.assertFalse(any(entry.startswith('RepairTower live targets refresh scan + heal application (') for entry in ledger['N2306']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTower live heal application (') and 'N2306 fills the targets live' in entry for entry in ledger['N2306']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTower live unit-candidate query (') for entry in ledger['N2306']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTower suppression live fill (') for entry in ledger['N2306']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTower live targets refresh (') for entry in ledger['N2306']['deferred_exprs']))

    def test_all_c07_repair_tower_live_scan_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2306']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_supplied_damaged_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/units/RepairTower.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/HealthComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/Units.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Position.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2306']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_tower_live_scan_state(self):
        repair_tower = REPAIR_TOWER_STATE.read_text(encoding='utf-8')
        # The live scan pure (RepairTower.java:62-66):
        # `Units.nearby(team, x, y, range, u -> {` visits the
        # same-team units in range and `if(u.damaged()){
        # targets.add(u); }` admits the damaged ones. The
        # range predicate is NOT a plain distance <= range:
        # Units.nearby (Units.java:445-451) admits a unit
        # when `unit.within(x, y, radius +
        # unit.hitSize/2f)`, and within is a STRICT dst2 <
        # (radius + hitSize/2)^2 (Position.java:44-46, `return
        # Mathf.dst2(getX(), getY(), x, y) < dst*dst;`) -- so
        # a unit exactly at range + hitSize/2 is OUT, and a
        # unit with a body counts its half hitSize. Damaged
        # is `return health < maxHealth - 0.001f;`
        # (HealthComp.java:47-49). The range is the class
        # default `public float range = 80f;`
        # (RepairTower.java:21), overridden by the def
        # `range = 100f;` (Blocks.java:6579). Keep each Java
        # expr on ONE comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_repair_tower_supplied_damaged_state', repair_tower)
        self.assertIn('Units.nearby(team, x, y, range, u -> {', repair_tower)
        self.assertIn('if(u.damaged()){', repair_tower)
        self.assertIn('targets.add(u);', repair_tower)
        self.assertIn('public float range = 80f;', repair_tower)
        self.assertIn('range = 100f;', repair_tower)
        self.assertIn('boolean damaged(){', repair_tower)
        self.assertIn('return health < maxHealth - 0.001f;', repair_tower)
        self.assertIn('public static void nearby(@Nullable Team team, float x, float y, float radius, Cons<Unit> cons){', repair_tower)
        self.assertIn('nearby(team, x - radius, y - radius, radius*2f, radius*2f, unit -> {', repair_tower)
        self.assertIn('if(unit.within(x, y, radius + unit.hitSize/2f)){', repair_tower)
        self.assertIn('return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', repair_tower)
        self.assertIn('if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){', repair_tower)
        self.assertIn('targets.clear();', repair_tower)
        self.assertIn('static final float refreshInterval = 6f;', repair_tower)
        # The pure returns exactly the five N2306 keys, in
        # candidate order, and the def range rides a driver
        # const (the N2227 heal-amount / circle-speed
        # precedent): 100f for unit-repair-tower
        # (Blocks.java:6579; the class default is 80f,
        # RepairTower.java:21; the catalog carries the same
        # 100.0). A candidate dict carries health /
        # max_health plus distance (the center distance) or
        # x / y (world position, measured from the tower
        # position params); a missing health / max_health /
        # distance-or-x/y key EXCLUDES the candidate (a
        # partial fixture never supplies a target), while a
        # missing hit_size reads as 0.0 (a point unit).
        self.assertIn('return {"supplied_damaged": supplied_damaged, "damaged_count": supplied_damaged.size(), "candidate_count": candidates.size(), "healthy_excluded_count": healthy_excluded_count, "out_of_range_count": out_of_range_count}', repair_tower)
        self.assertIn('SOURCE_REPAIR_TOWER_RANGE := 100.0', repair_tower)
        self.assertIn('candidate.has("health")', repair_tower)
        self.assertIn('candidate.has("max_health")', repair_tower)
        self.assertIn('candidate.has("distance")', repair_tower)
        self.assertIn('candidate.get("hit_size", 0.0)', repair_tower)
        # The tick wires the scan BEFORE the advance (the
        # N2301 fill-before-advance pattern): the frame unit
        # candidates (default [] -- no candidates, the Java
        # no-units-in-range outcome) are filtered by the pure
        # at the def range from the live tower position
        # (origin cell + block offset, the N2226/N2280
        # RepairTurret precedent: Building x/y are
        # tile.drawx()/drawy(), BuildingComp.java:124), the
        # result is stamped onto frame["supplied_damaged"],
        # and the advance call reads that frame key (the
        # N2226 frame-fallback precedent: the frame key feeds
        # the param; an explicit param still wins when the
        # advance is called directly). The scan runs on every
        # ticked tower, inside or outside the consumption
        # gate, like the advance itself.
        self.assertIn('const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")', repair_tower)
        self.assertIn('frame.get("unit_candidates", [])', repair_tower)
        self.assertIn('source_repair_tower_supplied_damaged_state(scan_candidates, SOURCE_REPAIR_TOWER_RANGE, scan_building_x, scan_building_y)', repair_tower)
        self.assertIn('frame["supplied_damaged"] = scan.get("supplied_damaged", [])', repair_tower)
        self.assertIn('var supplied_damaged: Variant = frame.get("supplied_damaged", [])', repair_tower)
        self.assertIn('source_block_geometry.tile_drawx_state(scan_cell.x, source_world_defaults.TILESIZE, scan_block_offset)', repair_tower)
        self.assertIn('source_block_geometry.tile_drawy_state(scan_cell.y, source_world_defaults.TILESIZE, scan_block_offset)', repair_tower)
        self.assertLess(
            repair_tower.index('source_repair_tower_supplied_damaged_state(scan_candidates, SOURCE_REPAIR_TOWER_RANGE, scan_building_x, scan_building_y)'),
            repair_tower.index('source_repair_tower_update_tile_advance_state(frame, SOURCE_REPAIR_TOWER_HEAL_AMOUNT, SOURCE_REPAIR_TOWER_CIRCLE_SPEED, time_delta, time_scale, supplied_damaged)'),
        )
        # The documented limits now record the scan as live
        # and the remaining deferrals (the heal application
        # to live units, the live unit-candidate query); the
        # N2227 advance, the N2213 gate and the N2250 liquid
        # row are preserved, and the old "no live scan" text
        # is gone.
        self.assertIn('Units.nearby scan live (N2306)', repair_tower)
        self.assertIn('updateTile advance live (N2227)', repair_tower)
        self.assertIn('shouldConsume gate live (N2213)', repair_tower)
        self.assertNotIn('the Units.nearby scan itself still waits for its own slice', repair_tower)
        self.assertNotIn("the frame's current targets", repair_tower)
        self.assertIn('static func source_repair_tower_power_status_row_state', repair_tower)
        self.assertIn('static func source_repair_tower_should_consume_state', repair_tower)
        self.assertIn('static func source_repair_tower_liquid_consumer_row_state', repair_tower)
        self.assertIn('static func source_repair_tower_update_tile_advance_state', repair_tower)
        # The N2227 advance is untouched: its signature keeps
        # the supplied_damaged parameter (default []) and its
        # refresh / clear / heal / warmup lines are unchanged
        # -- the scan wires BEFORE its call, never inside it.
        self.assertIn('static func source_repair_tower_update_tile_advance_state(frame: Dictionary, heal_amount: float, circle_speed: float, time_delta: float, time_scale := 1.0, supplied_damaged := []) -> Dictionary:', repair_tower)
        self.assertIn('targets = supplied_damaged.duplicate() if supplied_damaged is Array else []', repair_tower)
        # The proof's keys drive the pure scan (a damaged
        # unit in range is supplied, with the x/y form and
        # the hitSize/2 boundary; a healthy unit is
        # excluded; an out-of-range unit is excluded, with
        # missing-key exclusions; empty candidates give an
        # empty refill) plus the live tick (a placed tower
        # refills its targets from the frame candidates at
        # refresh) and the gate (the N2213 gate opens once
        # the refill lands).
        proof = REPAIR_TOWER_LIVE_SCAN_PROOF.read_text(encoding='utf-8')
        for key in [
            'damaged_in_range_supplied',
            'healthy_excluded',
            'out_of_range_excluded',
            'empty_candidates_empty',
            'live_tick_refills_targets',
            'gate_opens_with_target',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceRepairTowerBuildState.gd")', proof)
        self.assertTrue(REPAIR_TOWER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('repair_tower_build_state.source_repair_tower_supplied_damaged_state(', proof)
        self.assertIn('repair_tower_build_state.source_repair_tower_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertIn('repair_tower_build_state.source_repair_tower_should_consume_state(', proof)
        scene = REPAIR_TOWER_LIVE_SCAN_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RepairTowerLiveScanProof.gd', scene)
        self.assertIn('[node name="C07RepairTowerLiveScanProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_repair_tower_live_scan(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTowerLiveScanProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TOWER_LIVE_SCAN_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'damaged_in_range_supplied',
            'healthy_excluded',
            'out_of_range_excluded',
            'empty_candidates_empty',
            'live_tick_refills_targets',
            'gate_opens_with_target',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
