import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_GET_AMMO_CONTENT_FRACTION_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretGetAmmoContentFractionProof.gd'


class C07TurretGetAmmoContentFractionTests(unittest.TestCase):
    def test_c07_turret_get_ammo_content_fraction_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2348']['godot_owner'], 'SourceTurretBuildState.source_turret_get_ammo_content_state')
        # TurretBuild.getAmmoContent() (Turret.java:319-321):
        # `@Nullable`
        # `public UnlockableContent getAmmoContent(){`
        # `return null;`
        # `}`
        # and TurretBuild.getAmmoFraction() (Turret.java:324-326):
        # `/** @return ammo as a fraction of capacity; used for direct turret control HUD */`
        # `public float getAmmoFraction(){`
        # `return 1f;`
        # `}`
        # on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
        # (Turret.java:277). Both are base-class defaults: the
        # base has no ammo content (null) and counts as full
        # (1f); subclass overrides (ItemTurret N1180/N1181,
        # LiquidTurret N1197/N1198, ContinuousLiquidTurret
        # N1220/N1221, PowerTurret N1168) are NOT touched by
        # this slice -- they own their own bodies. NO driver
        # line: both are pure defaults, not per-tick writes;
        # the updateTile() call site :495 and the DrawTurret
        # :108-112 consumer are deferred. Two new result
        # symbols: ammo_content, ammo_fraction.
        self.assertEqual(
            ledger['N2348']['source_symbols'],
            [
                'source_turret_get_ammo_content_state_result.ammo_content',
                'source_turret_get_ammo_fraction_state_result.ammo_fraction',
            ],
        )
        for name in ledger['N2348']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2348']['runtime_proof'], '/root/C07TurretGetAmmoContentFractionProof')
        self.assertEqual(
            ledger['N2348']['tests'],
            [
                'test_c07_turret_get_ammo_content_fraction_registration',
                'test_all_c07_turret_get_ammo_content_fraction_input_evidence_is_exact',
                'test_turret_get_ammo_content_fraction_state',
                'test_reference_graph_and_actual_c07_turret_get_ammo_content_fraction',
            ],
        )
        self.assertTrue(ledger['N2348']['deferred_exprs'])

    def test_all_c07_turret_get_ammo_content_fraction_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2348']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2348']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_get_ammo_content_fraction_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.getAmmoContent() (Turret.java:319-321)
        # is the base default null; getAmmoFraction()
        # (Turret.java:324-326) is the base default 1f. Both
        # are constants: no live input besides the frame
        # itself, which carries no tracked key for either
        # accessor (the isShooting :429 precedent -- the frame
        # is the family-convention first arg, kept even when
        # the function reads nothing from it). NO driver line:
        # both are pure defaults, not per-tick writes.
        self.assertIn('static func source_turret_get_ammo_content_state(frame: Dictionary) -> Dictionary:', turret)
        self.assertIn('return {"ammo_content": null}', turret)
        self.assertIn('static func source_turret_get_ammo_fraction_state(frame: Dictionary) -> Dictionary:', turret)
        self.assertIn('return {"ammo_fraction": 1.0}', turret)
        for expr in [
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
            '@Nullable',
            'public UnlockableContent getAmmoContent(){',
            'return null;',
            '/** @return ammo as a fraction of capacity; used for direct turret control HUD */',
            'public float getAmmoFraction(){',
            'return 1f;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure functions with
        # synthetic frames (no live tick: both are pure
        # constants over the frame): content is null / null
        # regardless of frame contents / frame unmutated /
        # fraction is one / one regardless of frame contents
        # / frame unmutated / each result carries only its
        # one key.
        proof = TURRET_GET_AMMO_CONTENT_FRACTION_PROOF.read_text(encoding='utf-8')
        for key in [
            'ammo_content_null',
            'ammo_content_null_regardless_of_frame',
            'ammo_content_input_unmutated',
            'ammo_content_returns_only_one_key',
            'ammo_fraction_one',
            'ammo_fraction_one_regardless_of_frame',
            'ammo_fraction_input_unmutated',
            'ammo_fraction_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_get_ammo_content_fraction(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretGetAmmoContentFractionProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_GET_AMMO_CONTENT_FRACTION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ammo_content_null',
            'ammo_content_null_regardless_of_frame',
            'ammo_content_input_unmutated',
            'ammo_content_returns_only_one_key',
            'ammo_fraction_one',
            'ammo_fraction_one_regardless_of_frame',
            'ammo_fraction_input_unmutated',
            'ammo_fraction_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
