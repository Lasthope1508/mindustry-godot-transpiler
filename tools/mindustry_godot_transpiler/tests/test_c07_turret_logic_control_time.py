import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_LOGIC_CONTROL_TIME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretLogicControlTimeProof.gd'


class C07TurretLogicControlTimeTests(unittest.TestCase):
    def test_c07_turret_logic_control_time_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2261']['godot_owner'], 'SourceTurretBuildState.source_turret_logic_control_time_state')
        # TurretBuild.updateTile() decays the logic-control
        # timer every tick, after the recoilOffset draw:
        # `if(logicControlTime > 0){`
        # `logicControlTime -= Time.delta;`
        # (Turret.java:534-536). The field is
        # `public float curRecoil, heat, logicControlTime = -1;`
        # (:284), so the timer starts at -1 (never
        # logic-controlled) and only a logic shoot control
        # arms it (`logicControlTime = logicControlCooldown;`,
        # :384/:394, with
        # `public final static float logicControlCooldown = 60 * 2;`,
        # :38 -- 120 ticks of logic control). The reader is
        # `logicControlled()` (`return logicControlTime > 0;`,
        # :445-447), so the decay is observable through the
        # isShooting gate (:492) on the very next tick. This
        # slice is the LIVE frame tick on the new duo driver:
        # one pure function on the shared TurretBuild driver
        # file plus one driver tick in the duo branch AFTER
        # the N2258 recoilOffset tick (Java order :532 offset,
        # :534-536 decay). One new result symbol:
        # logic_control_time. The control() setters that arm
        # the timer (:384/:394) wait for their own slices --
        # the decay only reads the frame value, it never arms
        # it -- and the rotate sync (:542-545) is N2262.
        self.assertEqual(
            ledger['N2261']['source_symbols'],
            [
                'source_turret_logic_control_time_state_result.logic_control_time',
            ],
        )
        for name in ledger['N2261']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_logic_control_time_state_result.logic_control_time': 'SourceTurretBuildState.source_turret_logic_control_time_state',
                }[name])
        self.assertEqual(ledger['N2261']['runtime_proof'], '/root/C07TurretLogicControlTimeProof')
        self.assertEqual(
            ledger['N2261']['tests'],
            [
                'test_c07_turret_logic_control_time_registration',
                'test_all_c07_turret_logic_control_time_input_evidence_is_exact',
                'test_turret_logic_control_time_state',
                'test_reference_graph_and_actual_c07_turret_logic_control_time',
            ],
        )
        self.assertTrue(ledger['N2261']['deferred_exprs'])

    def test_all_c07_turret_logic_control_time_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2261']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_logic_control_time_state_result.logic_control_time': 'SourceTurretBuildState.source_turret_logic_control_time_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2261']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_logic_control_time_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild.updateTile() (Turret.java:490-560)
        # decays the logic-control timer every tick:
        # `if(logicControlTime > 0){`
        # `logicControlTime -= Time.delta;`
        # (:534-536), after the recoilOffset draw (:532) and
        # before the heat-requirement fold (:538-540) and the
        # rotate sync (:542-545). The field is
        # `public float curRecoil, heat, logicControlTime = -1;`
        # (:284), so the timer starts at -1 and the guard
        # leaves it untouched until a logic shoot control arms
        # it (`logicControlTime = logicControlCooldown;`,
        # :384/:394, with
        # `public final static float logicControlCooldown = 60 * 2;`,
        # :38 -- 120 ticks). The reader is `logicControlled()`
        # (`return logicControlTime > 0;`, :445-447), so the
        # decay is observable through the isShooting gate
        # (:492) on the very next tick. The decay has NO
        # clamp: a timer of 0.001 with delta 1/60 lands
        # negative (0.001 - 0.0166... = -0.0156...), which is
        # exactly what Java does -- the next tick's guard then
        # leaves it alone. The pure function takes the current
        # timer and the per-tick delta and returns the one
        # key:
        # `{"logic_control_time": ..}`.
        # The driver tick reads the frame timer (default -1.0,
        # the field default) and the live-loop `seconds`,
        # calls the pure function, then stamps the key back on
        # the frame so logicControlled() reads a live timer.
        self.assertIn('static func source_turret_logic_control_time_state(logic_control_time: float, delta: float) -> Dictionary:', turret)
        self.assertIn('return {"logic_control_time": logic_control_time}', turret)
        self.assertIn('if(logicControlTime > 0){', turret)
        self.assertIn('logicControlTime -= Time.delta;', turret)
        self.assertIn('public float curRecoil, heat, logicControlTime = -1;', turret)
        self.assertIn('return logicControlTime > 0;', turret)
        self.assertIn('logicControlTime = logicControlCooldown;', turret)
        self.assertIn('public final static float logicControlCooldown = 60 * 2;', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch AFTER
        # the N2258 recoilOffset tick and BEFORE the aim call
        # (Java order :532 offset, :534-536 decay, :595-596
        # turnToTarget, :601/:609 updateShooting): it reads
        # the frame timer (default -1.0, the field default)
        # and the live-loop `seconds`, calls the new pure
        # function, then stamps the key back on the frame.
        self.assertIn('var logic_control_time_state: Dictionary = source_turret_logic_control_time_state(float(frame.get("logic_control_time", -1.0)), seconds)', turret)
        self.assertIn('frame["logic_control_time"] = logic_control_time_state.get("logic_control_time", -1.0)', turret)
        # The proof's keys drive the decay through the pure
        # function and the real driver (the timer decays by
        # delta while positive / a negative timer is untouched
        # / a zero timer is untouched / a near-zero timer
        # decays past zero with no clamp / the decayed timer
        # still reads logic-controlled while positive / a
        # timer decayed past zero reads not-controlled / the
        # key is stamped on the frame after the tick / the duo
        # live tick decays an armed timer by one delta).
        # There are no arming keys: the control() setters that
        # set the timer to logicControlCooldown (120) wait for
        # their own slices, and the rotate sync (:542-545) is
        # N2262.
        proof = TURRET_LOGIC_CONTROL_TIME_PROOF.read_text(encoding='utf-8')
        for key in [
            'logic_control_time_decays_when_positive',
            'logic_control_time_unchanged_when_negative',
            'logic_control_time_unchanged_when_zero',
            'logic_control_time_can_go_negative',
            'logic_controlled_true_while_positive',
            'logic_controlled_false_when_expired',
            'logic_control_time_stamped_to_frame',
            'logic_control_time_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_logic_control_time(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretLogicControlTimeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_LOGIC_CONTROL_TIME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'logic_control_time_decays_when_positive',
            'logic_control_time_unchanged_when_negative',
            'logic_control_time_unchanged_when_zero',
            'logic_control_time_can_go_negative',
            'logic_controlled_true_while_positive',
            'logic_controlled_false_when_expired',
            'logic_control_time_stamped_to_frame',
            'logic_control_time_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
