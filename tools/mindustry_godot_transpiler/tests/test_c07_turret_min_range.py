import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_MIN_RANGE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretMinRangeProof.gd'


class C07TurretMinRangeTests(unittest.TestCase):
    def test_c07_turret_min_range_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2282']['godot_owner'], 'SourceTurretBuildState.source_turret_min_range_state')
        # TurretBuild.minRange() (Turret.java:334-339):
        # `public float minRange(){`
        # `if(peekAmmo() != null){`
        # `return minRange + peekAmmo().minRangeChange;`
        # `}`
        # `return minRange;`
        # on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
        # (Turret.java:277). The def minimum is the Turret field
        # (`public float minRange = 0f;`, Turret.java:74,
        # "Minimum bullet range. Used for artillery only."); the
        # ammo change is the peeked bullet's minRangeChange
        # (BulletType.java:163, `public float minRangeChange
        # = 0f;`, default 0f). The gate is peekAmmo() != null
        # (Turret.java:693, `public @Nullable BulletType
        # peekAmmo(){`), NOT hasAmmo() (Turret.java:698, which
        # has the ammo-swap side effect and can be false while
        # peekAmmo() is non-null) -- so the pure function takes
        # has_ammo as an explicit bool carrying the peekAmmo()
        # null check (the isActive :509 precedent, where the
        # param is_shooting carries wasShooting), never calls
        # hasAmmo(). peekAmmo() is likewise not ported here:
        # the caller passes the peeked bullet's minRangeChange
        # explicitly (0.0 when peekAmmo() is null, the Java
        # fall-through leg). All live values arrive as explicit
        # params (the N2188 precedent), because the tick frame
        # tracks no ammo state yet. NO driver line: minRange()
        # is a read accessor its callers read (drawSelect
        # :485, the shoot life-scale :787), not a per-tick
        # write (the N2249 precedent); those callers wait for
        # their own slices. One new result symbol:
        # min_range.
        self.assertEqual(
            ledger['N2282']['source_symbols'],
            [
                'source_turret_min_range_state_result.min_range',
            ],
        )
        for name in ledger['N2282']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2282']['runtime_proof'], '/root/C07TurretMinRangeProof')
        self.assertEqual(
            ledger['N2282']['tests'],
            [
                'test_c07_turret_min_range_registration',
                'test_all_c07_turret_min_range_input_evidence_is_exact',
                'test_turret_min_range_state',
                'test_reference_graph_and_actual_c07_turret_min_range',
            ],
        )
        self.assertTrue(ledger['N2282']['deferred_exprs'])

    def test_all_c07_turret_min_range_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2282']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2282']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_min_range_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.minRange() (Turret.java:334-339):
        # `public float minRange(){`
        # `if(peekAmmo() != null){`
        # `return minRange + peekAmmo().minRangeChange;`
        # `}`
        # `return minRange;`
        # The def minimum arrives as min_range, peekAmmo() !=
        # null as has_ammo, and the peeked bullet's
        # minRangeChange as ammo_min_range_change. No ammo
        # returns the bare def minimum (the Java fall-through
        # leg); with ammo the change is added even when it is
        # 0f (the BulletType default).
        # NO driver line: minRange() is a read accessor its
        # callers read (drawSelect :485, the shoot life-scale
        # :787), not a per-tick write.
        self.assertIn('static func source_turret_min_range_state(frame: Dictionary, min_range: float, has_ammo: bool, ammo_min_range_change: float) -> Dictionary:', turret)
        self.assertIn('return {"min_range": min_range + ammo_min_range_change if has_ammo else min_range}', turret)
        for expr in [
            'public float minRange(){',
            'if(peekAmmo() != null){',
            'return minRange + peekAmmo().minRangeChange;',
            'return minRange;',
            'public float minRange = 0f;',
            'public float minRangeChange = 0f;',
            'public @Nullable BulletType peekAmmo(){',
            'return ammo.size == 0 ? null : ammo.peek().type();',
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
            'public class BulletType extends Content implements Cloneable{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function with
        # synthetic frames (no live tick: minRange is a pure
        # accessor over three inputs): ammo adds the change /
        # no ammo returns the bare def minimum / zero def with
        # zero change stays zero / a negative change lowers
        # the minimum / the change is ignored without ammo /
        # an artillery-scale minimum adds the change / the
        # result carries only the one min_range key.
        proof = TURRET_MIN_RANGE_PROOF.read_text(encoding='utf-8')
        for key in [
            'min_range_with_ammo',
            'min_range_without_ammo',
            'min_range_default_zero',
            'min_range_negative_change',
            'min_range_change_ignored_without_ammo',
            'min_range_artillery_scale',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_min_range(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretMinRangeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_MIN_RANGE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'min_range_with_ammo',
            'min_range_without_ammo',
            'min_range_default_zero',
            'min_range_negative_change',
            'min_range_change_ignored_without_ammo',
            'min_range_artillery_scale',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
