import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
BASE_RELOAD_SPEED_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ReloadTurretBaseReloadSpeedProof.gd'

PROOF_KEYS = [
    'efficiency_1_returns_1',
    'efficiency_0_returns_0',
    'efficiency_above_1_passes_through',
    'efficiency_negative_passes_through',
    'efficiency_half_returns_half',
    'efficiency_fractional_precision',
    'returns_only_one_key',
    'idempotent_second_call',
]


class C07ReloadTurretBaseReloadSpeedTests(unittest.TestCase):
    def test_c07_reload_turret_base_reload_speed_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2476']['godot_owner'], 'SourceTurretBuildState.source_reload_turret_base_reload_speed_state')
        # ReloadTurretBuild.baseReloadSpeed() (ReloadTurret.java:45-47):
        #     return efficiency;
        # efficiency is the Building field (BuildingComp.java:84-85,
        # "Base efficiency. Takes the minimum value of all
        # consumers", transient float). TRAP: the value is returned
        # WHOLE -- no clamp, no floor: efficiency 0 stays 0.0,
        # efficiency > 1 passes through, a negative efficiency
        # passes through (Java has no Math.min/max here). Near
        # names already ported: ammoReloadMultiplier
        # (ReloadTurret.java:41-43, same class, returns the
        # constant 1f -- NOT registered by this slice),
        # TurretBuild.ammoReloadMultiplier N746 (Turret.java,
        # ternary on peekAmmo -- a different method that DOES
        # look at ammo; baseReloadSpeed never looks at ammo),
        # updateReload (Turret.java:719-721, the CALLER that
        # multiplies delta * ammoReloadMultiplier *
        # baseReloadSpeed -- it registers updateReload, not
        # baseReloadSpeed).
        self.assertEqual(
            ledger['N2476']['java_method'],
            'ReloadTurretBuild.baseReloadSpeed()',
        )
        self.assertEqual(
            ledger['N2476']['source_symbols'],
            [
                'source_reload_turret_base_reload_speed_state_input.efficiency',
                'source_reload_turret_base_reload_speed_state_result.base_reload_speed',
            ],
        )
        for name in ledger['N2476']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_reload_turret_base_reload_speed_state'))
        self.assertEqual(ledger['N2476']['runtime_proof'], '/root/C07ReloadTurretBaseReloadSpeedProof')
        self.assertEqual(
            ledger['N2476']['tests'],
            [
                'test_c07_reload_turret_base_reload_speed_registration',
                'test_all_c07_reload_turret_base_reload_speed_input_evidence_is_exact',
                'test_reload_turret_base_reload_speed_state',
                'test_reference_graph_and_actual_c07_reload_turret_base_reload_speed',
            ],
        )
        self.assertTrue(ledger['N2476']['deferred_exprs'])

    def test_all_c07_reload_turret_base_reload_speed_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2476']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_reload_turret_base_reload_speed_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2476']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_reload_turret_base_reload_speed_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # ReloadTurretBuild.baseReloadSpeed() (ReloadTurret.java:45-47):
        #     return efficiency;
        # TRAP: return efficiency WHOLE -- no clamp, no floor.
        # A port that clamps to [0, 1] is wrong (1.5 must stay
        # 1.5, -0.5 must stay -0.5) and a port that floors at 0
        # is wrong (0 must stay 0.0, not a default of 1).
        self.assertIn('static func source_reload_turret_base_reload_speed_state(efficiency: float) -> Dictionary:', turret)
        self.assertIn('return {"base_reload_speed": efficiency}', turret)
        # Function order follows Java order: updateCooling()
        # (:28-38) comes before baseReloadSpeed() (:45-47),
        # which comes before canReload() (:49-51), which comes
        # before TurretBuild.range() (:334-350) in Java, so the
        # new function sits between source_turret_cooling_state
        # and source_reload_turret_can_reload_state in this
        # file; the spare ammoReloadMultiplier (:41-43) would
        # slot between cooling and baseReloadSpeed if ported
        # later.
        self.assertLess(
            turret.index('static func source_turret_cooling_state('),
            turret.index('static func source_reload_turret_base_reload_speed_state('),
        )
        self.assertLess(
            turret.index('static func source_reload_turret_base_reload_speed_state('),
            turret.index('static func source_reload_turret_can_reload_state('),
        )
        self.assertLess(
            turret.index('static func source_reload_turret_base_reload_speed_state('),
            turret.index('static func source_turret_range_state('),
        )
        # The proof drives the pure function with synthetic
        # efficiency values (no live tick, no game state):
        # 1.0 -> 1.0, 0 -> 0.0, 1.5 -> 1.5 (no clamp to 1),
        # -0.5 -> -0.5 (no clamp to 0), 0.5 -> 0.5,
        # 0.333 -> 0.333 (no rounding), the result has exactly
        # one key, and a second call with the same input gives
        # the same output.
        proof = BASE_RELOAD_SPEED_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_reload_turret_base_reload_speed(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ReloadTurretBaseReloadSpeedProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RELOAD_TURRET_BASE_RELOAD_SPEED_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
