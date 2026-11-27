import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
AMMO_RELOAD_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ReloadTurretAmmoReloadMultiplierProof.gd'

PROOF_KEYS = [
    'ammo_reload_multiplier_is_one',
    'ammo_high_multiplier_still_one',
    'ammo_low_multiplier_still_one',
    'no_ammo_still_one',
    'parent_formula_differs_with_ammo',
    'parent_formula_matches_without_ammo',
    'returns_only_one_key',
    'idempotent_second_call',
]


class C07ReloadTurretAmmoReloadMultiplierTests(unittest.TestCase):
    def test_c07_reload_turret_ammo_reload_multiplier_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2481']['godot_owner'], 'SourceTurretBuildState.source_reload_turret_ammo_reload_multiplier_state')
        # ReloadTurretBuild.ammoReloadMultiplier()
        # (ReloadTurret.java:41-43):
        #     protected float ammoReloadMultiplier(){
        #         return 1f;
        #     }
        # on `public class ReloadTurretBuild extends
        # BaseTurretBuild{` (ReloadTurret.java:25). The
        # override returns the CONSTANT 1f -- it reads NO
        # ammo, NO coolant, NO efficiency: it "turns off"
        # the parent's ammo multiplier entirely. TRAP: a
        # port returning `peekAmmo().reloadMultiplier` is
        # WRONG -- that is the PARENT TurretBuild
        # .ammoReloadMultiplier() body (N746,
        # Turret.java:727-729, `return hasAmmo() ?
        # peekAmmo().reloadMultiplier : 1f;`), a different
        # method in a different class. TRAP: this is NOT
        # baseReloadSpeed() (N2476, ReloadTurret.java:45-47,
        # `return efficiency;`) and NOT canReload() (N2473,
        # :49-51, `return reloadCounter < reload;`) -- the
        # three consecutive methods :41/:45/:49 are three
        # separate slices. Zero params: the method takes no
        # state (the N2422 zero-param contract precedent --
        # result schema only, no input schema).
        self.assertEqual(
            ledger['N2481']['java_method'],
            'ReloadTurretBuild.ammoReloadMultiplier()',
        )
        self.assertEqual(
            ledger['N2481']['source_symbols'],
            [
                'source_reload_turret_ammo_reload_multiplier_state_result.ammo_reload_multiplier',
            ],
        )
        for name in ledger['N2481']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_reload_turret_ammo_reload_multiplier_state'))
        self.assertEqual(ledger['N2481']['runtime_proof'], '/root/C07ReloadTurretAmmoReloadMultiplierProof')
        self.assertEqual(
            ledger['N2481']['tests'],
            [
                'test_c07_reload_turret_ammo_reload_multiplier_registration',
                'test_all_c07_reload_turret_ammo_reload_multiplier_input_evidence_is_exact',
                'test_reload_turret_ammo_reload_multiplier_state',
                'test_reference_graph_and_actual_c07_reload_turret_ammo_reload_multiplier',
            ],
        )
        self.assertTrue(ledger['N2481']['deferred_exprs'])

    def test_all_c07_reload_turret_ammo_reload_multiplier_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2481']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_reload_turret_ammo_reload_multiplier_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2481']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_reload_turret_ammo_reload_multiplier_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # ReloadTurretBuild.ammoReloadMultiplier()
        # (ReloadTurret.java:41-43):
        #     return 1f;
        # TRAP: a port returning `peekAmmo()
        # .reloadMultiplier` (the parent N746 body) is wrong
        # -- this override ignores ammo entirely and always
        # returns 1f. TRAP: a port returning `efficiency`
        # (the baseReloadSpeed body, N2476) is wrong -- this
        # method never looks at efficiency either.
        self.assertIn('static func source_reload_turret_ammo_reload_multiplier_state() -> Dictionary:', turret)
        self.assertIn('return {"ammo_reload_multiplier": 1.0}', turret)
        # Function order follows Java order: ammoReloadMultiplier()
        # (:41-43) comes before baseReloadSpeed() (:45-47,
        # N2476, source_reload_turret_base_reload_speed_state),
        # which comes before canReload() (:49-51, N2473,
        # source_reload_turret_can_reload_state), so the new
        # function sits before both of those in this file.
        self.assertLess(
            turret.index('static func source_reload_turret_ammo_reload_multiplier_state('),
            turret.index('static func source_reload_turret_base_reload_speed_state('),
        )
        self.assertLess(
            turret.index('static func source_reload_turret_ammo_reload_multiplier_state('),
            turret.index('static func source_reload_turret_can_reload_state('),
        )
        # The proof drives the pure function with no inputs
        # (no live tick, no game state): the key trap case is
        # ammo with reloadMultiplier != 1 (e.g. 2.5) -- the
        # result must still be 1.0, while the parent
        # TurretBuild.ammoReloadMultiplier() (N746) returns
        # 2.5 for the same ammo; both return 1.0 when there
        # is no ammo; the result has exactly one key; and a
        # second call with no input gives the same output.
        proof = AMMO_RELOAD_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_reload_turret_ammo_reload_multiplier(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ReloadTurretAmmoReloadMultiplierProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RELOAD_TURRET_AMMO_RELOAD_MULTIPLIER_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
