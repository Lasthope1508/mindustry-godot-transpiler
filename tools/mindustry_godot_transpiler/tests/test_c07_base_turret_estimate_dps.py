import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
ESTIMATE_DPS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BaseTurretEstimateDpsProof.gd'

PROOF_KEYS = [
    'estimate_dps_is_zero',
    'high_dps_turret_still_zero',
    'low_dps_turret_still_zero',
    'no_ammo_still_zero',
    'parent_formula_differs_with_ammo',
    'parent_formula_matches_without_ammo',
    'returns_only_one_key',
    'idempotent_second_call',
]


class C07BaseTurretEstimateDpsTests(unittest.TestCase):
    def test_c07_base_turret_estimate_dps_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2486']['godot_owner'], 'SourceTurretBuildState.source_base_turret_estimate_dps_state')
        # BaseTurretBuild.estimateDps()
        # (BaseTurret.java:138-140):
        #     public float estimateDps(){
        #         return 0f;
        #     }
        # on `public class BaseTurretBuild extends Building
        # implements Ranged, RotBlock{` (BaseTurret.java:113).
        # The override returns the CONSTANT 0f -- a BaseTurret
        # has no ammo and no bullet, so it has no DPS to
        # compute. TRAP: a port that computes real DPS (the
        # TurretBuild.estimateDps() body, N2301,
        # Turret.java:740-745, `shots / reload * 60 *
        # peekAmmo().estimateDps() * ...`) is WRONG -- that
        # is the CHILD-class method; this method never looks
        # at ammo, reload, or efficiency. Zero params: the
        # method takes no state (the N2422 zero-param
        # contract precedent, same as N2481 -- result schema
        # only, no input schema). CLEAN, no twin-register:
        # java_method `BaseTurretBuild.estimateDps()` is
        # 0-hit; the other estimateDps() hits are all
        # different classes (N1236 TractorBeamBuild, N2301
        # TurretBuild, N2389 ContinuousTurretBuild, N2533 /
        # N2536 UnitType) and `return 0f;` is a generic
        # constant line, not twin evidence.
        self.assertEqual(
            ledger['N2486']['java_method'],
            'BaseTurretBuild.estimateDps()',
        )
        self.assertEqual(
            ledger['N2486']['source_symbols'],
            [
                'source_base_turret_estimate_dps_state_result.estimate_dps',
            ],
        )
        for name in ledger['N2486']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_base_turret_estimate_dps_state'))
        self.assertEqual(ledger['N2486']['runtime_proof'], '/root/C07BaseTurretEstimateDpsProof')
        self.assertEqual(
            ledger['N2486']['tests'],
            [
                'test_c07_base_turret_estimate_dps_registration',
                'test_all_c07_base_turret_estimate_dps_input_evidence_is_exact',
                'test_base_turret_estimate_dps_state',
                'test_reference_graph_and_actual_c07_base_turret_estimate_dps',
            ],
        )
        self.assertTrue(ledger['N2486']['deferred_exprs'])

    def test_all_c07_base_turret_estimate_dps_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2486']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_base_turret_estimate_dps_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2486']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_base_turret_estimate_dps_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # BaseTurretBuild.estimateDps()
        # (BaseTurret.java:138-140):
        #     return 0f;
        # TRAP: a port computing real DPS (the child
        # TurretBuild.estimateDps() body, N2301) is wrong --
        # this override reads nothing and always returns 0f.
        # TRAP: a port returning `efficiency` or a range
        # value is wrong -- this method never looks at any
        # field.
        self.assertIn('static func source_base_turret_estimate_dps_state() -> Dictionary:', turret)
        self.assertIn('return {"estimate_dps": 0.0}', turret)
        # Function order follows Java order: drawSelect()
        # (:133-135, N2475-era source_base_turret_build_
        # draw_select_state) comes before estimateDps()
        # (:138-140), which comes before status() (:143-145,
        # N2475, source_base_turret_build_status_state), so
        # the new function sits between those two in this
        # file.
        self.assertLess(
            turret.index('static func source_base_turret_build_draw_select_state('),
            turret.index('static func source_base_turret_estimate_dps_state('),
        )
        self.assertLess(
            turret.index('static func source_base_turret_estimate_dps_state('),
            turret.index('static func source_base_turret_build_status_state('),
        )
        # The proof drives the pure function with no inputs
        # (no live tick, no game state): the key trap cases
        # are a high-DPS turret config (shots 8, reload 15,
        # peek DPS 25 -- the parent N2301 formula gives 800)
        # and a low-DPS one (shots 1, reload 120, peek DPS
        # 5 -- parent gives 2.5), both still 0.0 here; with
        # no ammo the parent formula also gives 0.0, so both
        # agree; the result has exactly one key; and a
        # second call with no input gives the same output.
        proof = ESTIMATE_DPS_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_base_turret_estimate_dps(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BaseTurretEstimateDpsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BASE_TURRET_ESTIMATE_DPS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
