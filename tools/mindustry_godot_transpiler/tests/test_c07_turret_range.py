import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_RANGE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretRangeProof.gd'


class C07TurretRangeTests(unittest.TestCase):
    def test_c07_turret_range_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2526']['godot_owner'], 'SourceTurretBuildState.source_turret_range_state')
        # range() / minRange() / trackingRange() are the three
        # TurretBuild accessors (Turret.java:334-350):
        # `public float minRange(){` /
        # `if(peekAmmo() != null){` /
        # `return minRange + peekAmmo().minRangeChange;` /
        # `return minRange;` (:334-338) /
        # `public float range(){` /
        # `if(peekAmmo() != null){` /
        # `return range + peekAmmo().rangeChange;` /
        # `return range;` (:340-346) /
        # `public float trackingRange(){` /
        # `return range() + trackingRange - range;` (:348-350),
        # with the init() normalization (`trackingRange =
        # Math.max(range, trackingRange);`, Turret.java:217-219)
        # folded into the function so a raw catalog
        # trackingRange of 0f (the class default,
        # Turret.java:72, `public float trackingRange = 0f;` --
        # no def records trackingRange in the catalog) does not
        # shrink the tracking range below range(). `range` is
        # the BaseTurret field (`public float range = 80f;`,
        # BaseTurret.java:21); `minRange` is the Turret field
        # (`public float minRange = 0f;`, Turret.java:74 --
        # only ripple sets it, `minRange = 50f;`,
        # Blocks.java:4076); `rangeChange` / `minRangeChange`
        # are BulletType defaults (`public float rangeChange =
        # 0f;`, BulletType.java:157; `public float
        # minRangeChange = 0f;`, :163 -- duo graphite sets
        # `rangeChange = 16f;`, Blocks.java:3276, copper and
        # silicon leave both at 0f, :3259-3295). `has_peek_ammo`
        # is `peekAmmo() != null` (the ammo stack non-empty),
        # NOT `hasAmmo()` (which also folds canConsume(),
        # Turret.java:705-708). The three accessors are ported
        # as ONE pure function because they share the peekAmmo()
        # read and the same consumers (`findTarget()`,
        # Turret.java:652-656, `float trackRange =
        # trackingRange(), range = range();`, and the
        # updateTile() within-check, :590 -- both consumers are
        # later slices; findTarget stays BLOCKED). Three new
        # result symbols: range / min_range / tracking_range.
        # The slice mirrors into the defense shard (213/212 ->
        # 214/213); comp stays 572/475.
        self.assertEqual(
            ledger['N2526']['source_symbols'],
            [
                'source_turret_range_state_result.range',
                'source_turret_range_state_result.min_range',
                'source_turret_range_state_result.tracking_range',
            ],
        )
        for name in ledger['N2526']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_range_state')
        self.assertEqual(ledger['N2526']['runtime_proof'], '/root/C07TurretRangeProof')
        self.assertEqual(
            ledger['N2526']['tests'],
            [
                'test_c07_turret_range_registration',
                'test_all_c07_turret_range_input_evidence_is_exact',
                'test_turret_range_state',
                'test_reference_graph_and_actual_c07_turret_range',
            ],
        )
        self.assertTrue(ledger['N2526']['deferred_exprs'])

    def test_all_c07_turret_range_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2526']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_range_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2526']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_range_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # range() / minRange() / trackingRange()
        # (Turret.java:334-350) for the Turret family as one
        # pure function: `min_range_out = min_range +
        # min_range_change if has_peek_ammo else min_range`
        # (:334-338); `range_out = range_value + range_change
        # if has_peek_ammo else range_value` (:340-346);
        # `tracking_range_out = range_out +
        # maxf(range_value, tracking_range) - range_value`
        # (:348-350 with the init() normalization
        # `trackingRange = Math.max(range, trackingRange);`,
        # :217-219, folded in -- a raw catalog trackingRange
        # of 0f must NOT shrink the tracking range below
        # range()). `has_peek_ammo` is `peekAmmo() != null`
        # (NOT hasAmmo(), Turret.java:705-708). NO driver tick
        # call site (the N2525 precedent): the frame stamps no
        # `tracking_range` / `min_range` live keys and the
        # consumers (findTarget, Turret.java:652-656, and the
        # updateTile() within-check, :590) are later slices;
        # the aim inline (`SourceItemTurretBuildState.gd:506`,
        # `shoot_range = range + range_change + hit_size /
        # 1.9`) is a within-check, NOT range() -- left alone.
        self.assertIn('static func source_turret_range_state(frame: Dictionary, range_value: float, min_range: float, tracking_range: float, has_peek_ammo: bool, range_change: float, min_range_change: float) -> Dictionary:', turret)
        self.assertIn('var range_out: float = range_value + range_change if has_peek_ammo else range_value', turret)
        self.assertIn('var min_range_out: float = min_range + min_range_change if has_peek_ammo else min_range', turret)
        self.assertIn('var tracking_range_out: float = range_out + maxf(range_value, tracking_range) - range_value', turret)
        self.assertIn('return {"range": range_out, "min_range": min_range_out, "tracking_range": tracking_range_out}', turret)
        self.assertIn('return minRange + peekAmmo().minRangeChange;', turret)
        self.assertIn('return minRange;', turret)
        self.assertIn('return range + peekAmmo().rangeChange;', turret)
        self.assertIn('return range;', turret)
        self.assertIn('return range() + trackingRange - range;', turret)
        self.assertIn('trackingRange = Math.max(range, trackingRange);', turret)
        self.assertIn('public float trackingRange = 0f;', turret)
        self.assertIn('public float minRange = 0f;', turret)
        self.assertIn('public float range = 80f;', turret)
        self.assertIn('public float rangeChange = 0f;', turret)
        self.assertIn('public float minRangeChange = 0f;', turret)
        self.assertIn('if(peekAmmo() != null){', turret)
        self.assertIn('float trackRange = trackingRange(), range = range();', turret)
        # The pure function sits immediately AFTER
        # source_turret_cooling_state (N2525) and BEFORE
        # source_turret_can_heal_state.
        self.assertLess(turret.index('static func source_turret_cooling_state('), turret.index('static func source_turret_range_state('))
        self.assertLess(turret.index('static func source_turret_range_state('), turret.index('static func source_turret_can_heal_state('))
        # NO driver tick call site: the frame stamps no
        # tracking_range / min_range live keys and the
        # consumers (findTarget, the updateTile() within-check)
        # are later slices. The tick function must not call
        # the new pure function.
        tick = turret[turret.index('static func source_turret_tick_buildings_state('):]
        self.assertNotIn('source_turret_range_state(', tick)
        # The proof's keys drive the pure function on exact
        # catalog values (duo range 160, graphite rangeChange
        # 16, ripple range 290 / minRange 50, smite range 300
        # / trackingRange 420 = 300 * 1.4, malign range 410 /
        # trackingRange 574 = 410 * 1.4 -- all exact-binary
        # floats, so the equalities are exact): duo copper
        # (no rangeChange) / duo graphite (+16) / duo silicon
        # (no rangeChange) / ripple minRange 50 with no ammo /
        # smite trackingRange 1.4x / malign trackingRange 1.4x
        # / the no-ammo branch ignores nonzero changes / the
        # minRangeChange fold with ammo (synthetic 8.0 -- no
        # def sets minRangeChange today, so the value exercises
        # the formula only, it is NOT a catalog fact).
        proof = TURRET_RANGE_PROOF.read_text(encoding='utf-8')
        for key in [
            'range_duo_copper_no_change',
            'range_duo_graphite_adds_16',
            'range_duo_silicon_no_change',
            'range_ripple_min_range_50',
            'range_smite_tracking_1_4x',
            'range_malign_tracking_1_4x',
            'range_no_ammo_branch',
            'range_min_range_change_adds_with_ammo',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_range(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretRangeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_RANGE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'range_duo_copper_no_change',
            'range_duo_graphite_adds_16',
            'range_duo_silicon_no_change',
            'range_ripple_min_range_50',
            'range_smite_tracking_1_4x',
            'range_malign_tracking_1_4x',
            'range_no_ammo_branch',
            'range_min_range_change_adds_with_ammo',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
