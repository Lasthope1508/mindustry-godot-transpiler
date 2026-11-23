import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_SHOULD_TURN_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretShouldTurnProof.gd'


class C07TurretShouldTurnTests(unittest.TestCase):
    def test_c07_turret_should_turn_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2337']['godot_owner'], 'SourceTurretBuildState.source_turret_should_turn_state')
        # TurretBuild.shouldTurn() (Turret.java:669-671):
        # `public boolean shouldTurn(){`
        # `return moveWhileCharging || !charging();`
        # on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
        # (Turret.java:277). moveWhileCharging is the Turret def
        # field (`public boolean moveWhileCharging = true;`,
        # Turret.java:80) and arrives as an explicit bool param;
        # charging() is NOT re-ported (Turret.java:715-717,
        # `public boolean charging(){` / `return queuedBullets
        # > 0 && shoot.firstShotDelay > 0;`) -- the caller
        # passes its result as the explicit bool charging
        # param; remote N2269 owns charging() (dedup at merge).
        # The frame carries no tracked key for this predicate.
        # NO driver tick line: shouldTurn() is a predicate the
        # updateTile() tick driver reads (:595
        # `if(shouldTurn()){`), not a tick write of its own.
        # One new result symbol: should_turn.
        self.assertEqual(
            ledger['N2337']['source_symbols'],
            [
                'source_turret_should_turn_state_result.should_turn',
            ],
        )
        for name in ledger['N2337']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2337']['runtime_proof'], '/root/C07TurretShouldTurnProof')
        self.assertEqual(
            ledger['N2337']['tests'],
            [
                'test_c07_turret_should_turn_registration',
                'test_all_c07_turret_should_turn_input_evidence_is_exact',
                'test_turret_should_turn_state',
                'test_reference_graph_and_actual_c07_turret_should_turn',
            ],
        )
        self.assertTrue(ledger['N2337']['deferred_exprs'])

    def test_all_c07_turret_should_turn_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2337']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2337']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_should_turn_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.shouldTurn() (Turret.java:669-671):
        # `public boolean shouldTurn(){`
        # `return moveWhileCharging || !charging();`
        # moveWhileCharging arrives as the explicit bool
        # move_while_charging (the def field, Turret.java:80),
        # charging() arrives as the explicit bool charging
        # (its result, Turret.java:715-717, NOT re-ported
        # here), and the frame carries no tracked key. NO
        # driver tick line: shouldTurn() is a predicate the
        # updateTile() driver reads (:595 `if(shouldTurn()){`).
        self.assertIn('static func source_turret_should_turn_state(frame: Dictionary, move_while_charging: bool, charging: bool) -> Dictionary:', turret)
        self.assertIn('return {"should_turn": move_while_charging or not charging}', turret)
        for expr in [
            'public boolean shouldTurn(){',
            'return moveWhileCharging || !charging();',
            'public boolean moveWhileCharging = true;',
            'public boolean charging(){',
            'return queuedBullets > 0 && shoot.firstShotDelay > 0;',
            'if(shouldTurn()){',
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function with
        # synthetic frames (no live tick: shouldTurn is a pure
        # predicate over two bools): turns while charging when
        # moveWhileCharging is true / turns while not charging
        # when moveWhileCharging is true / turns while not
        # charging when moveWhileCharging is false / does not
        # turn while charging when moveWhileCharging is false /
        # the result carries only the one should_turn key.
        proof = TURRET_SHOULD_TURN_PROOF.read_text(encoding='utf-8')
        for key in [
            'turns_while_charging_when_move_while_charging',
            'turns_while_not_charging_when_move_while_charging',
            'turns_while_not_charging_when_not_move_while_charging',
            'does_not_turn_while_charging_when_not_move_while_charging',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_should_turn(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretShouldTurnProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_SHOULD_TURN_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'turns_while_charging_when_move_while_charging',
            'turns_while_not_charging_when_move_while_charging',
            'turns_while_not_charging_when_not_move_while_charging',
            'does_not_turn_while_charging_when_not_move_while_charging',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
