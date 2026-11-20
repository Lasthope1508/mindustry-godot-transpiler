import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
ITEM_TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceItemTurretBuildState.gd'
TURRET_LOGIC_CONTROLLED_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretLogicControlledProof.gd'
ITEM_TURRET_VALIDATE_TARGET_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemTurretValidateTargetProof.gd'


class C07TurretLogicControlledTests(unittest.TestCase):
    def test_c07_turret_logic_controlled_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2278']['godot_owner'], 'SourceTurretBuildState.source_turret_logic_controlled_state')
        # logicControlled() is `public boolean logicControlled(){`
        # / `return logicControlTime > 0;` (Turret.java:445-447),
        # on the field `public float curRecoil, heat,
        # logicControlTime = -1;` (:284, set to
        # logicControlCooldown by the control() setters
        # :384/:394, N2264; decayed :534-536 by the N2261 tick).
        # It rescues validateTarget (`return
        # !Units.invalidateTarget(target, canHeal() ?
        # Team.derelict : team, x, y) || controlled() ||
        # logicControlled();`, :631-633, N2251) and picks the
        # logic branch of isShooting (:492, N2277) -- but the
        # driver validate call passed
        # `bool(frame.get("logic_controlled", false))` while
        # frame["logic_controlled"] was NEVER stamped anywhere,
        # so a logic-controlled duo with an otherwise-invalid
        # target wrongly failed validation. This slice ports
        # the one-line Java method as a pure function and
        # stamps it live on the frame right before the
        # validate call. One new result symbol:
        # logic_controlled.
        self.assertEqual(
            ledger['N2278']['source_symbols'],
            [
                'source_turret_logic_controlled_state_result.logic_controlled',
            ],
        )
        for name in ledger['N2278']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_logic_controlled_state')
        self.assertEqual(ledger['N2278']['runtime_proof'], '/root/C07TurretLogicControlledProof')
        self.assertEqual(
            ledger['N2278']['tests'],
            [
                'test_c07_turret_logic_controlled_registration',
                'test_all_c07_turret_logic_controlled_input_evidence_is_exact',
                'test_turret_logic_controlled_state',
                'test_reference_graph_and_actual_c07_turret_logic_controlled',
            ],
        )
        self.assertTrue(ledger['N2278']['deferred_exprs'])

    def test_all_c07_turret_logic_controlled_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2278']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_logic_controlled_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2278']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_logic_controlled_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # logicControlled() (Turret.java:445-447) is the one-line
        # predicate on the logicControlTime field (:284): `public
        # boolean logicControlled(){ return logicControlTime > 0;
        # }`. The pure function takes the field value and returns
        # the one key: `{"logic_controlled": ..}`. The driver tick
        # runs immediately BEFORE the validateTarget call
        # (:1286, Java order :491 validate before :534-536 decay,
        # so it reads the PREVIOUS tick's logic_control_time --
        # the N2261 decay tick runs later in the driver, the same
        # precedent as N2277 / N2265) and stamps the key back on
        # the frame; the validate call itself is unchanged and now
        # reads a live value instead of the never-stamped default
        # false. controlled() (`return unit.isPlayer();`,
        # :441-443) is NOT this slice -- no player unit exists in
        # the port, so it still defaults false.
        self.assertIn('static func source_turret_logic_controlled_state(logic_control_time: float) -> Dictionary:', turret)
        self.assertIn('var logic_controlled: bool = logic_control_time > 0.0', turret)
        self.assertIn('return {"logic_controlled": logic_controlled}', turret)
        self.assertIn('public boolean logicControlled(){', turret)
        self.assertIn('return logicControlTime > 0;', turret)
        self.assertIn('public float curRecoil, heat, logicControlTime = -1;', turret)
        # The validateTarget formula itself lives on the N2251
        # pure function (SourceItemTurretBuildState.gd), whose
        # verdict the driver tick feeds.
        item_turret = ITEM_TURRET_BUILD_STATE.read_text(encoding='utf-8')
        self.assertIn('return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();', item_turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch right
        # BEFORE the validateTarget call: it derives
        # logic_controlled live from the previous tick's
        # logic_control_time and stamps it on the frame, so the
        # validate call below reads a live value.
        self.assertIn('var logic_controlled_state: Dictionary = source_turret_logic_controlled_state(float(frame.get("logic_control_time", -1.0)))', turret)
        self.assertIn('frame["logic_controlled"] = logic_controlled_state.get("logic_controlled", false)', turret)
        self.assertIn('bool(frame.get("logic_controlled", false))', turret)
        self.assertLess(turret.index('var logic_controlled_state: Dictionary = source_turret_logic_controlled_state(float(frame.get("logic_control_time", -1.0)))'), turret.index('var validate: Dictionary = source_item_turret_build_state.source_item_turret_validate_target_state('))
        # The pure function sits immediately BEFORE
        # source_turret_is_shooting_state, since the :492
        # isShooting formula consumes logicControlled().
        self.assertLess(turret.index('static func source_turret_logic_controlled_state('), turret.index('static func source_turret_is_shooting_state('))
        # The proof's keys drive the predicate through the pure
        # function and the real driver (positive / zero / the
        # -1 default are all false except a positive time / the
        # key is stamped live on the frame / a logic-controlled
        # duo keeps an otherwise-invalid target through the
        # validate call).
        proof = TURRET_LOGIC_CONTROLLED_PROOF.read_text(encoding='utf-8')
        for key in [
            'logic_controlled_positive',
            'logic_controlled_zero',
            'logic_controlled_negative',
            'logic_controlled_stamped_to_frame',
            'logic_controlled_driver_rescues_validate',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The N2251 proof's frame 5 must drive the rescue from
        # logic_control_time now: the new stamp tick overwrites
        # a directly-stamped frame["logic_controlled"] with the
        # live derivation, so the fixture sets the time (120.0)
        # instead of the flag.
        validate_proof = ITEM_TURRET_VALIDATE_TARGET_PROOF.read_text(encoding='utf-8')
        self.assertIn('frames[5]["logic_control_time"] = 120.0', validate_proof)

    def test_reference_graph_and_actual_c07_turret_logic_controlled(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretLogicControlledProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_LOGIC_CONTROLLED_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'logic_controlled_positive',
            'logic_controlled_zero',
            'logic_controlled_negative',
            'logic_controlled_stamped_to_frame',
            'logic_controlled_driver_rescues_validate',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
