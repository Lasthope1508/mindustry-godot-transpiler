import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
COMBAT_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretCombatState.gd'
TARGET_POSITION_OFFSET_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretTargetPositionOffsetProof.gd'

PROOF_KEYS = [
    'offset_zero_at_core_no_lead',
    'offset_zero_at_core_matches_pure_intercept',
    'offset_updated_away_from_core_leads',
    'offset_zero_null_game_no_intercept',
]


class C07TurretTargetPositionOffsetTests(unittest.TestCase):
    def test_c07_turret_target_position_offset_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2432']['godot_owner'], 'SourceTurretCombatState.source_turret_target_position_state')
        # TurretBuild.targetPosition(Posc) (Turret.java:453-470):
        # the one line N2122 did not register --
        # `var offset = Tmp.v1.setZero();` (:457, the charge
        # offset starts at zero before the accurateDelay
        # branch). The GD function already exists (N2122):
        # this slice extends it -- it adds no new owner, no
        # new contract and no new schema (the N2427/N2430
        # registration-only precedent). The zero init is
        # already live as `velocity := Vector2.ZERO` in the
        # GD func (only updated when the target is off the
        # core). NOT re-registered here: the guards and
        # the intercept call (`if(!hasAmmo() || pos ==
        # null) return;`, `BulletType bullet = peekAmmo();`,
        # the accurateDelay guard, `offset.set(...)`,
        # the predictTarget guard, `Predict.intercept(...)`,
        # `targetPos.set(pos);`, the isZero guard) stay
        # owned at N2122 (some also at remote N2266).
        self.assertEqual(
            ledger['N2432']['java_method'],
            'TurretBuild.targetPosition(Posc)',
        )
        self.assertEqual(
            ledger['N2432']['exact_exprs'],
            [
                'var offset = Tmp.v1.setZero();',
            ],
        )
        self.assertEqual(
            ledger['N2432']['source_symbols'],
            [
                'source_turret_target_position_state_result.target_position',
                'source_turret_target_position_state_result.used_intercept',
                'source_turret_target_position_state_result.bullet_speed',
            ],
        )
        for name in ledger['N2432']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretCombatState.source_turret_target_position_state'))
        self.assertEqual(ledger['N2432']['runtime_proof'], '/root/C07TurretTargetPositionOffsetProof')
        self.assertEqual(
            ledger['N2432']['tests'],
            [
                'test_c07_turret_target_position_offset_registration',
                'test_all_c07_turret_target_position_offset_input_evidence_is_exact',
                'test_turret_target_position_offset_state',
                'test_reference_graph_and_actual_c07_turret_target_position_offset',
            ],
        )
        self.assertTrue(ledger['N2432']['deferred_exprs'])

    def test_all_c07_turret_target_position_offset_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2432']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretCombatState.source_turret_target_position_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2432']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_target_position_offset_state(self):
        state = COMBAT_STATE.read_text(encoding='utf-8')
        # The GD function already exists (N2122); N2432
        # registers the one leftover line it already
        # implements -- the offset starts at zero
        # (`var offset = Tmp.v1.setZero();`, Turret.java:457)
        # and is only updated when the target is off the
        # core: the GD func opens with `velocity :=
        # Vector2.ZERO` and only recomputes it when the
        # direction to the core is non-zero. The exact
        # expr is quoted verbatim on its own comment line
        # (the N2378 precedent: never split an exact expr
        # across lines).
        self.assertIn('static func source_turret_target_position_state(game: Object, origin, target) -> Dictionary:', state)
        for expr in [
            'var offset = Tmp.v1.setZero();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive one aspect each: a target
        # sitting on the core gets no lead (the offset
        # stayed at its zero init); that aim equals the
        # pure zero-velocity intercept; a target away from
        # the core gets a lead (the offset was updated);
        # a null game yields no intercept.
        proof = TARGET_POSITION_OFFSET_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_target_position_offset(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretTargetPositionOffsetProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_TARGET_POSITION_OFFSET_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
