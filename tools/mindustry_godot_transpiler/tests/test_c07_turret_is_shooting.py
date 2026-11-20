import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_IS_SHOOTING_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretIsShootingProof.gd'


class C07TurretIsShootingTests(unittest.TestCase):
    def test_c07_turret_is_shooting_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2277']['godot_owner'], 'SourceTurretBuildState.source_turret_is_shooting_state')
        # TurretBuild.updateTile() (Turret.java:490-615) sets the
        # shooting flag at the head of the tick, first line after
        # the validateTarget verdict:
        # `isShooting = alwaysShooting || (unit.controller()
        # instanceof Player ? unit.isShooting() :
        # logicControlled() ? logicShooting : target != null);`
        # (Turret.java:492) -- the flag feeds the warmup target
        # at :502 (`float warmupTarget = (isShooting &&
        # canConsume()) || charging() ? 1f : 0f;`) and
        # shouldConsume (Turret.java:364-366). Duo has no player
        # and no logic by default, so isShooting is target !=
        # null after the :491 verdict -- but the driver had no
        # frame["is_shooting"] stamp and no standalone pure
        # function: N2253 folded the formula inline as the
        # warmup call's is_shooting arg. This slice stamps the
        # one result key: is_shooting.
        self.assertEqual(
            ledger['N2277']['source_symbols'],
            [
                'source_turret_is_shooting_state_result.is_shooting',
            ],
        )
        for name in ledger['N2277']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_is_shooting_state')
        self.assertEqual(ledger['N2277']['runtime_proof'], '/root/C07TurretIsShootingProof')
        self.assertEqual(
            ledger['N2277']['tests'],
            [
                'test_c07_turret_is_shooting_registration',
                'test_all_c07_turret_is_shooting_input_evidence_is_exact',
                'test_turret_is_shooting_state',
                'test_reference_graph_and_actual_c07_turret_is_shooting',
            ],
        )
        self.assertTrue(ledger['N2277']['deferred_exprs'])

    def test_all_c07_turret_is_shooting_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2277']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_is_shooting_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2277']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_is_shooting_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild.updateTile() (Turret.java:490-615) sets the
        # shooting flag at the head of the tick:
        # `isShooting = alwaysShooting || (unit.controller()
        # instanceof Player ? unit.isShooting() :
        # logicControlled() ? logicShooting : target != null);`
        # (Turret.java:492). alwaysShooting is
        # `public boolean alwaysShooting = false;` (:103, duo
        # never overrides it); controlled() is
        # `return unit.isPlayer();` (:441-443); logicControlled()
        # is `return logicControlTime > 0;` (:445-447);
        # logicShooting is `public boolean logicShooting =
        # false;` (:288, set by the control() setters :384/:394,
        # N2264). The pure function takes the six branches and
        # returns the one key: `{"is_shooting": ..}`. The driver
        # tick runs right after the :491 validateTarget block and
        # before the N2265 efficiency fold, stamping the key back
        # on the frame; logic_controlled is derived live from the
        # PREVIOUS tick's logic_control_time (the N2261 decay
        # tick runs later in the driver -- Java order :492 before
        # :534-536). The :502 warmup call reads the stamped key
        # instead of recomputing `has_target and valid` inline.
        self.assertIn('static func source_turret_is_shooting_state(always_shooting: bool, is_player: bool, player_is_shooting: bool, logic_controlled: bool, logic_shooting: bool, has_target: bool) -> Dictionary:', turret)
        self.assertIn('return {"is_shooting": is_shooting}', turret)
        self.assertIn('isShooting = alwaysShooting || (unit.controller() instanceof Player ? unit.isShooting() : logicControlled() ? logicShooting : target != null);', turret)
        self.assertIn('public boolean alwaysShooting = false;', turret)
        self.assertIn('public boolean logicShooting = false;', turret)
        self.assertIn('return logicControlTime > 0;', turret)
        self.assertIn('return unit.isPlayer();', turret)
        self.assertIn('float warmupTarget = (isShooting && canConsume()) || charging() ? 1f : 0f;', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch AFTER
        # the validateTarget block and BEFORE the N2265
        # efficiency fold (Java order :491 validate, :492
        # isShooting, then the updateConsumption fold and the
        # :502 warmup): it derives logic_controlled live from
        # the previous tick's logic_control_time, reads
        # logic_shooting and the validated has_target, and
        # stamps the key back on the frame (duo alwaysShooting
        # false, no player, so the player branch never fires).
        self.assertIn('var is_shooting_state: Dictionary = source_turret_is_shooting_state(false, bool(frame.get("controlled", false)), false, float(frame.get("logic_control_time", -1.0)) > 0.0, bool(frame.get("logic_shooting", false)), bool(frame.get("has_target", false)) and bool(validate.get("valid", false)))', turret)
        self.assertIn('frame["is_shooting"] = is_shooting_state.get("is_shooting", false)', turret)
        self.assertLess(turret.index('frame["has_target"] = false'), turret.index('var is_shooting_state: Dictionary = source_turret_is_shooting_state(false,'))
        self.assertLess(turret.index('var is_shooting_state: Dictionary = source_turret_is_shooting_state(false,'), turret.index('var efficiency_multiplier: Dictionary'))
        self.assertIn('source_turret_warmup_state(float(frame.get("shoot_warmup", 0.0)), float(frame.get("warmup_hold", 0.0)), bool(frame.get("is_shooting", false)), duo_can_consume', turret)
        # The proof's keys drive the flag through the pure
        # function and the real driver (a duo with a target is
        # shooting / no target is not / a logic-controlled duo
        # with logicShooting false is not shooting even with a
        # target / the key is stamped on the frame after the
        # tick / a logic-controlled duo with logicShooting true
        # is shooting live, proving the logicControlled
        # derivation from logic_control_time).
        proof = TURRET_IS_SHOOTING_PROOF.read_text(encoding='utf-8')
        for key in [
            'is_shooting_duo_target',
            'is_shooting_no_target',
            'is_shooting_logic_controlled',
            'is_shooting_stamped_to_frame',
            'is_shooting_logic_live',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_is_shooting(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretIsShootingProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_IS_SHOOTING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'is_shooting_duo_target',
            'is_shooting_no_target',
            'is_shooting_logic_controlled',
            'is_shooting_stamped_to_frame',
            'is_shooting_logic_live',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
