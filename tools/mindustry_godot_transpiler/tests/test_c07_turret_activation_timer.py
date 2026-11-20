import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_ACTIVATION_TIMER_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretActivationTimerProof.gd'


class C07TurretActivationTimerTests(unittest.TestCase):
    def test_c07_turret_activation_timer_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2279']['godot_owner'], 'SourceTurretBuildState.source_turret_activation_timer_state')
        # The activation gate (Turret.java:561-564) is
        # `if(activationTimer > 0){ activationTimer -=
        # Time.delta; return; }` on the field `public float
        # activationTimer = 0;` (BaseTurret.java:115, set to
        # activationTime in placed() :119-120), where
        # `public float activationTime = 0f;`
        # (BaseTurret.java:27) is the class default. Duo never
        # overrides activationTime (Blocks.java:3257-3331), and
        # no turret def in Blocks.java sets it above 0, so the
        # duo timer is always 0.0 and the gate never fires --
        # the same vacuous-guard precedent as the N2270 heat
        # fold and the N2263 heatReq fold: the tick still
        # stamps both keys so the frame mirrors the
        # TurretBuild fields. Two new result symbols:
        # activation_timer and activation_timer_elapsed.
        self.assertEqual(
            ledger['N2279']['source_symbols'],
            [
                'source_turret_activation_timer_state_result.activation_timer',
                'source_turret_activation_timer_state_result.activation_timer_elapsed',
            ],
        )
        for name in ledger['N2279']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_activation_timer_state')
        self.assertEqual(ledger['N2279']['runtime_proof'], '/root/C07TurretActivationTimerProof')
        self.assertEqual(
            ledger['N2279']['tests'],
            [
                'test_c07_turret_activation_timer_registration',
                'test_all_c07_turret_activation_timer_input_evidence_is_exact',
                'test_turret_activation_timer_state',
                'test_reference_graph_and_actual_c07_turret_activation_timer',
            ],
        )
        self.assertTrue(ledger['N2279']['deferred_exprs'])

    def test_all_c07_turret_activation_timer_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2279']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_activation_timer_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2279']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_activation_timer_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # The activation gate (Turret.java:561-564) is
        # `if(activationTimer > 0){ activationTimer -=
        # Time.delta; return; }`. The pure function takes the
        # field value and the per-tick delta and returns two
        # keys: `{"activation_timer": ..,
        # "activation_timer_elapsed": ..}`. The timer decays
        # by delta while positive, with NO clamp (a timer of
        # 0.001 with delta 1/60 lands at -0.0156..., the N2261
        # precedent); the elapsed verdict is the gate itself
        # evaluated on the INPUT timer -- Java returns before
        # the rest of the tick when the input is positive,
        # even if this tick's decay would cross zero. The
        # driver tick runs between the rotate sync (:542-545)
        # and the aim call (Java order :542-545, then :561-564,
        # then :566+ hasAmmo/aim) and stamps both keys back
        # on the frame; the early-return skip of the aim/shoot
        # half is NOT wired in this slice -- the gate never
        # fires for duo (activationTime 0 for every def), so
        # restructuring the aim block for a never-firing guard
        # is churn, and it waits for a def with activationTime
        # > 0. The elapsed key is the same `activationTimer <=
        # 0` clause BaseTurret.status() uses (:144).
        self.assertIn('static func source_turret_activation_timer_state(activation_timer: float, delta: float) -> Dictionary:', turret)
        self.assertIn('var activation_timer_after: float = activation_timer - delta if activation_timer > 0.0 else activation_timer', turret)
        self.assertIn('var activation_timer_elapsed: bool = activation_timer <= 0.0', turret)
        self.assertIn('return {"activation_timer": activation_timer_after, "activation_timer_elapsed": activation_timer_elapsed}', turret)
        self.assertIn('if(activationTimer > 0){', turret)
        self.assertIn('activationTimer -= Time.delta;', turret)
        self.assertIn('public float activationTimer = 0;', turret)
        self.assertIn('activationTimer = activationTime;', turret)
        self.assertIn('public float activationTime = 0f;', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch between
        # the rotate sync tick and the aim call: it decays the
        # timer live from the frame value and stamps both keys.
        self.assertIn('var activation_timer_state: Dictionary = source_turret_activation_timer_state(float(frame.get("activation_timer", 0.0)), seconds)', turret)
        self.assertIn('frame["activation_timer"] = activation_timer_state.get("activation_timer", 0.0)', turret)
        self.assertIn('frame["activation_timer_elapsed"] = activation_timer_state.get("activation_timer_elapsed", true)', turret)
        self.assertLess(turret.index('var activation_timer_state: Dictionary = source_turret_activation_timer_state(float(frame.get("activation_timer", 0.0)), seconds)'), turret.index('var aim: Dictionary = source_item_turret_build_state.source_item_turret_aim_shoot_state('))
        self.assertLess(turret.index('var rotate_sync: Dictionary = source_turret_rotate_sync_state('), turret.index('var activation_timer_state: Dictionary = source_turret_activation_timer_state('))
        # The pure function sits immediately AFTER
        # source_turret_rotate_sync_state, since Java order is
        # :542-545 rotate sync, then :561-564 activation gate.
        self.assertLess(turret.index('static func source_turret_rotate_sync_state('), turret.index('static func source_turret_activation_timer_state('))
        self.assertLess(turret.index('static func source_turret_activation_timer_state('), turret.index('static func source_turret_heat_req_state('))
        # The proof's keys drive the decay through the pure
        # function and the real driver (a positive timer decays
        # by delta / zero stays zero / elapsed is true at zero
        # and false while positive / both keys are stamped live
        # on the frame).
        proof = TURRET_ACTIVATION_TIMER_PROOF.read_text(encoding='utf-8')
        for key in [
            'activation_timer_decays_when_positive',
            'activation_timer_unchanged_at_zero',
            'activation_timer_elapsed_at_zero',
            'activation_timer_not_elapsed_when_positive',
            'activation_timer_stamped_to_frame',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_activation_timer(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretActivationTimerProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_ACTIVATION_TIMER_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'activation_timer_decays_when_positive',
            'activation_timer_unchanged_at_zero',
            'activation_timer_elapsed_at_zero',
            'activation_timer_not_elapsed_when_positive',
            'activation_timer_stamped_to_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
