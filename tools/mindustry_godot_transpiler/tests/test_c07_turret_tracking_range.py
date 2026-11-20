import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_TRACKING_RANGE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretTrackingRangeProof.gd'


class C07TurretTrackingRangeTests(unittest.TestCase):
    def test_c07_turret_tracking_range_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2319']['godot_owner'], 'SourceTurretBuildState.source_turret_tracking_range_state')
        # TurretBuild.trackingRange() (Turret.java:349-351,
        # `public float trackingRange(){` / `return range()
        # + trackingRange - range;`) over the
        # TurretBuild.range() result (Turret.java:342-345,
        # `public float range(){` / `return range +
        # peekAmmo().rangeChange;` when peekAmmo() is
        # non-null (Turret.java:693, `public @Nullable
        # BulletType peekAmmo(){`), else `return range;`),
        # the Turret def trackingRange field
        # (Turret.java:72, `public float trackingRange =
        # 0f;`) and the BaseTurret def range
        # (BaseTurret.java:21, `public float range = 80f;`).
        # init() clamps the field (Turret.java:217,
        # `trackingRange = Math.max(range, trackingRange);`),
        # so after init trackingRange() >= range(). The
        # range() result arrives as an explicit param
        # (the N2316 precedent): range() itself is not a
        # live SourceTurretBuildState row (the old N739/N740
        # rows live in PortGame). No driver line:
        # trackingRange() is a load-time accessor findTarget
        # reads at Turret.java:652 (`float trackRange =
        # trackingRange(), range = range();`), not a per-tick
        # write (the N2311/N2249 accessor precedent). One
        # new result symbol: tracking_range. This slice
        # closes the trackingRange part of the N2316
        # deferred follow-up (range() stays an explicit
        # value, hasAmmo()/peekAmmo() stay their own
        # slices).
        self.assertEqual(
            ledger['N2319']['source_symbols'],
            [
                'source_turret_tracking_range_state_result.tracking_range',
            ],
        )
        for name in ledger['N2319']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
                    'core/src/mindustry/entities/bullet/BulletType.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2319']['runtime_proof'], '/root/C07TurretTrackingRangeProof')
        self.assertEqual(
            ledger['N2319']['tests'],
            [
                'test_c07_turret_tracking_range_registration',
                'test_all_c07_turret_tracking_range_input_evidence_is_exact',
                'test_turret_tracking_range_state',
                'test_reference_graph_and_actual_c07_turret_tracking_range',
            ],
        )
        self.assertTrue(ledger['N2319']['deferred_exprs'])
        self.assertIn(
            'Turret trackingRange() Windows Godot proof',
            ' '.join(ledger['N2319']['deferred_exprs']),
        )

    def test_all_c07_turret_tracking_range_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2319']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2319']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_tracking_range_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.trackingRange() (Turret.java:349-351):
        # `public float trackingRange(){`
        # `return range() + trackingRange - range;`
        # over the TurretBuild.range() result
        # (Turret.java:342-345), the Turret def
        # trackingRange field (Turret.java:72, `public float
        # trackingRange = 0f;`) and the BaseTurret def range
        # (BaseTurret.java:21, `public float range = 80f;`).
        # init() clamps the field (Turret.java:217,
        # `trackingRange = Math.max(range, trackingRange);`).
        # No driver line: findTarget reads it at
        # Turret.java:652 (`float trackRange =
        # trackingRange(), range = range();`).
        self.assertIn('static func source_turret_tracking_range_state(frame: Dictionary, range_value: float, tracking_range: float, range: float) -> Dictionary:', turret)
        self.assertIn('return {"tracking_range": range_value + tracking_range - range}', turret)
        for expr in [
            'public float trackingRange(){',
            'return range() + trackingRange - range;',
            'public float range(){',
            'return range + peekAmmo().rangeChange;',
            'return range;',
            'public float trackingRange = 0f;',
            'trackingRange = Math.max(range, trackingRange);',
            'public float range = 80f;',
            'public float rangeChange = 0f;',
            'public @Nullable BulletType peekAmmo(){',
            'float trackRange = trackingRange(), range = range();',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
            'public class BaseTurret extends Block{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function directly
        # with explicit params: the default field (0f) with
        # no ammo gives 0.0 pre-init; the init-clamped field
        # gives the range itself; a field beyond the range
        # extends it; an ammo rangeChange rides the range()
        # result through; ammo alone with a clamped field
        # returns the range() result; equal values agree;
        # and large values scale.
        proof = TURRET_TRACKING_RANGE_PROOF.read_text(encoding='utf-8')
        for key in [
            'tracking_range_default_field_zero',
            'tracking_range_post_init_clamped',
            'tracking_range_extends_beyond_range',
            'tracking_range_ammo_range_change',
            'tracking_range_ammo_only',
            'tracking_range_equal_all',
            'tracking_range_large_values',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_tracking_range(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretTrackingRangeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_TRACKING_RANGE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'tracking_range_default_field_zero',
            'tracking_range_post_init_clamped',
            'tracking_range_extends_beyond_range',
            'tracking_range_ammo_range_change',
            'tracking_range_ammo_only',
            'tracking_range_equal_all',
            'tracking_range_large_values',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
