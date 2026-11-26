import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
CAN_RELOAD_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ReloadTurretCanReloadProof.gd'

PROOF_KEYS = [
    'below_threshold_true',
    'product_of_normal_cycle',
    'equal_is_false',
    'above_threshold_false',
    'zero_zero_is_false',
    'zero_counter_default_reload_true',
    'negative_counter_not_clamped',
    'fractional_just_below',
]


class C07ReloadTurretCanReloadTests(unittest.TestCase):
    def test_c07_reload_turret_can_reload_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2473']['godot_owner'], 'SourceTurretBuildState.source_reload_turret_can_reload_state')
        # ReloadTurretBuild.canReload() (ReloadTurret.java:49-51):
        #     return reloadCounter < reload;
        # reloadCounter is the ReloadTurretBuild field (:26,
        # default 0f) and reload is the ReloadTurret field
        # (:10, default 10f). TRAP: the comparison is STRICT
        # `<` -- counter == reload is false, 0 < 0 is false,
        # and a negative counter is NOT clamped (Java has no
        # Math.max here; capping lives in updateReload, not
        # here). Near names already ported: updateCooling N2525
        # (same class, a CALLER of canReload -- it registers
        # updateCooling, not canReload), N746
        # TurretBuild.updateReload/ammoReloadMultiplier
        # (different class), isActive N2280 (embeds the same
        # expression as half of an OR, not a registration of
        # this method).
        self.assertEqual(
            ledger['N2473']['java_method'],
            'ReloadTurretBuild.canReload()',
        )
        self.assertEqual(
            ledger['N2473']['source_symbols'],
            [
                'source_reload_turret_can_reload_state_input.reload_counter',
                'source_reload_turret_can_reload_state_input.reload',
                'source_reload_turret_can_reload_state_result.can_reload',
            ],
        )
        for name in ledger['N2473']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_reload_turret_can_reload_state'))
        self.assertEqual(ledger['N2473']['runtime_proof'], '/root/C07ReloadTurretCanReloadProof')
        self.assertEqual(
            ledger['N2473']['tests'],
            [
                'test_c07_reload_turret_can_reload_registration',
                'test_all_c07_reload_turret_can_reload_input_evidence_is_exact',
                'test_reload_turret_can_reload_state',
                'test_reference_graph_and_actual_c07_reload_turret_can_reload',
            ],
        )
        self.assertTrue(ledger['N2473']['deferred_exprs'])

    def test_all_c07_reload_turret_can_reload_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2473']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_reload_turret_can_reload_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2473']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_reload_turret_can_reload_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # ReloadTurretBuild.canReload() (ReloadTurret.java:49-51):
        #     return reloadCounter < reload;
        # TRAP: strict `<` -- equal is false (counter 10,
        # reload 10), 0 < 0 is false, and a negative counter
        # passes through as true (no clamp). A port that
        # uses `<=` is wrong, and a port that clamps the
        # counter at 0 is wrong.
        self.assertIn('static func source_reload_turret_can_reload_state(reload_counter: float, reload: float) -> Dictionary:', turret)
        self.assertIn('return {"can_reload": reload_counter < reload}', turret)
        # Function order follows Java order: updateCooling()
        # (:28-38) comes before canReload() (:49-51) in
        # ReloadTurret.java, so source_turret_cooling_state
        # comes before source_reload_turret_can_reload_state
        # in this file; the spare ammoReloadMultiplier (:41-43)
        # and baseReloadSpeed (:45-47) would slot between them
        # if ported later. canReload() (:49-51) comes before
        # TurretBuild.range() (:334-350), so the new function
        # comes before source_turret_range_state.
        self.assertLess(
            turret.index('static func source_turret_cooling_state('),
            turret.index('static func source_reload_turret_can_reload_state('),
        )
        self.assertLess(
            turret.index('static func source_reload_turret_can_reload_state('),
            turret.index('static func source_turret_range_state('),
        )
        # The proof drives the pure function with synthetic
        # counter/reload pairs (no live tick, no game state):
        # below threshold is true, 9.5 < 10 is true, equal is
        # false, above is false, 0 < 0 is false, the field
        # defaults (0, 10) are true, a negative counter is
        # not clamped (true), and 9.999 < 10 is true.
        proof = CAN_RELOAD_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_reload_turret_can_reload(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ReloadTurretCanReloadProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RELOAD_TURRET_CAN_RELOAD_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
