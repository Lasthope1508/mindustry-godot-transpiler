import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BaseTurretStatusProof.gd'

PROOF_KEYS = [
    'timer_positive_inactive',
    'timer_zero_returns_base',
    'timer_negative_returns_base',
    'timer_positive_overrides_logic_disable',
    'timer_zero_passes_no_input',
    'tiny_positive_inactive',
    'timer_positive_overrides_inactive_unit_factory',
    'idempotent_second_call',
]


class C07BaseTurretStatusTests(unittest.TestCase):
    def test_c07_base_turret_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2475']['godot_owner'], 'SourceTurretBuildState.source_base_turret_build_status_state')
        # BaseTurretBuild.status() (BaseTurret.java:143-145):
        #     @Override
        #     public BlockStatus status() {
        #         return (activationTimer <= 0)? super.status() : BlockStatus.inactive;
        #     }
        # TRAP 1 (boundary): `<= 0` -- timer 0 returns
        # super.status() (the base), NOT inactive; a port
        # using `< 0` fails the timer-zero key.
        # TRAP 2: super.status() is BuildingComp.status()
        # (BuildingComp.java:632-646, already live as N1888
        # PortGame.source_building_status_state) -- it arrives
        # here as the PRECOMPUTED base_status input (the
        # N1256/N2374 precedent), NOT re-ported.
        # TRAP 3: `inactive` (BlockStatus.inactive) is NOT
        # `inactiveUnitFactory` -- the proof pins a base
        # "inactiveUnitFactory" overridden to "inactive"
        # when the timer is positive.
        # NOT TurretBuild.status() (N2285, Turret.java:369-374):
        # that method has the hasAmmo leg and its own Java body
        # never mentions activationTimer -- the timer leg is its
        # super call, which resolves to THIS method. TWIN NOTE:
        # the body literal below is already an exact_expr of
        # N2285 (which cites it as the super chain of
        # TurretBuild.status() and inlines the leg in
        # source_turret_status_state); this slice adds the
        # first GD function OWNED as BaseTurretBuild.status(),
        # for the inheritors that do NOT override status
        # (RadarBuild / BuildTurretBuild / ReloadTurretBuild).
        # Near names already ported: TurretBuild.status()
        # N2285, BaseTurretBuild.drawSelect() (in this file),
        # BaseTurretBuild.range() N739, BuildTurretBuild
        # .buildRotation() (backup, different method).
        self.assertEqual(
            ledger['N2475']['java_method'],
            'BaseTurretBuild.status()',
        )
        self.assertEqual(
            ledger['N2475']['source_symbols'],
            [
                'source_base_turret_build_status_state_input.activation_timer',
                'source_base_turret_build_status_state_input.base_status',
                'source_base_turret_build_status_state_result.status',
            ],
        )
        for name in ledger['N2475']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_base_turret_build_status_state'))
        self.assertEqual(ledger['N2475']['runtime_proof'], '/root/C07BaseTurretStatusProof')
        self.assertEqual(
            ledger['N2475']['tests'],
            [
                'test_c07_base_turret_status_registration',
                'test_all_c07_base_turret_status_input_evidence_is_exact',
                'test_base_turret_status_state',
                'test_reference_graph_and_actual_c07_base_turret_status',
            ],
        )
        self.assertTrue(ledger['N2475']['deferred_exprs'])

    def test_all_c07_base_turret_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2475']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_base_turret_build_status_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2475']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_base_turret_status_state(self):
        turret_state = TURRET_STATE.read_text(encoding='utf-8')
        # BaseTurretBuild.status() (BaseTurret.java:143-145):
        #     return (activationTimer <= 0)? super.status() : BlockStatus.inactive;
        # TRAP: `<= 0` -- timer 0 returns the base status,
        # NOT inactive. super.status() arrives as the
        # precomputed base_status input (N1888); the inactive
        # leg reuses the family-local const from N2285
        # (BlockStatus.inactive has no N1888 constant).
        self.assertIn('static func source_base_turret_build_status_state(activation_timer: float, base_status: String) -> Dictionary:', turret_state)
        self.assertIn('if activation_timer <= 0.0:', turret_state)
        self.assertIn('return {"status": base_status}', turret_state)
        self.assertIn('return {"status": SOURCE_TURRET_STATUS_INACTIVE}', turret_state)
        # Function order follows Java order: drawSelect()
        # (:133-135) comes before status() (:143-145) in
        # BaseTurret.java, so
        # source_base_turret_build_draw_select_state comes
        # before source_base_turret_build_status_state in
        # this file. estimateDps() (:138) sits between them
        # in Java and is spared -- a later slice inserts it
        # between these two functions. status() comes before
        # the next function in this file (TurretBuild.draw(),
        # source_turret_draw_state).
        self.assertLess(
            turret_state.index('static func source_base_turret_build_draw_select_state('),
            turret_state.index('static func source_base_turret_build_status_state('),
        )
        self.assertLess(
            turret_state.index('static func source_base_turret_build_status_state('),
            turret_state.index('static func source_turret_draw_state('),
        )
        # The proof drives the pure function with synthetic
        # (timer, base) pairs (no live tick, no game state):
        # positive timer forces "inactive" whatever the base
        # (even "inactiveUnitFactory" -- a different enum
        # value), timer 0 passes the base through (the
        # boundary trap), a negative timer also passes the
        # base through, a tiny positive timer (0.001) is
        # already inactive, and a repeated call is identical.
        proof = STATUS_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_base_turret_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BaseTurretStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BASE_TURRET_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
