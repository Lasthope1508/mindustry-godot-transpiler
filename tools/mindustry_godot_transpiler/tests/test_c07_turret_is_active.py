import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_IS_ACTIVE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretIsActiveProof.gd'


class C07TurretIsActiveTests(unittest.TestCase):
    def test_c07_turret_is_active_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2280']['godot_owner'], 'SourceTurretBuildState.source_turret_is_active_state')
        # isActive() is `public boolean isActive(){ return
        # (target != null || wasShooting) && enabled &&
        # activationTimer <= 0; }` (Turret.java:449-450) on the
        # fields `public boolean wasShooting, isShooting;`
        # (Turret.java:292, set false at :517 and true at
        # :600/:608), `transient boolean enabled = true;`
        # (BuildingComp.java:77) and `public float
        # activationTimer = 0;` (BaseTurret.java:115, decayed
        # live by the N2279 tick). Only LaserTurret consumes
        # it in Java (`if(bullets.any() || isActive()) return
        # true;`, LaserTurret.java:55 in shouldConsume()
        # :53-57); duo is an ItemTurret with no consumer, so
        # this slice is stamp-only like N2274-N2276: one pure
        # function plus one driver tick, no consumer rewired.
        # One new result symbol: is_active.
        self.assertEqual(
            ledger['N2280']['source_symbols'],
            [
                'source_turret_is_active_state_result.is_active',
            ],
        )
        for name in ledger['N2280']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/Turret.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_is_active_state')
        self.assertEqual(ledger['N2280']['runtime_proof'], '/root/C07TurretIsActiveProof')
        self.assertEqual(
            ledger['N2280']['tests'],
            [
                'test_c07_turret_is_active_registration',
                'test_all_c07_turret_is_active_input_evidence_is_exact',
                'test_turret_is_active_state',
                'test_reference_graph_and_actual_c07_turret_is_active',
            ],
        )
        self.assertTrue(ledger['N2280']['deferred_exprs'])

    def test_all_c07_turret_is_active_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2280']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_is_active_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2280']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_is_active_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # isActive() (Turret.java:449-450) is `return (target
        # != null || wasShooting) && enabled &&
        # activationTimer <= 0;`. The pure function takes the
        # four live frame inputs -- has_target (the `target !=
        # null` clause, the N2277 precedent), was_shooting
        # (Turret.java:292, stamped from the aim result every
        # tick), enabled (BuildingComp.java:77, preserved every
        # tick) and activation_timer (BaseTurret.java:115,
        # decayed live by the N2279 tick) -- and returns one
        # key: `{"is_active": ..}`. The driver tick runs in the
        # duo branch right AFTER the was_shooting stamp
        # (:1602), once every input is its final value for
        # this tick, and stamps the key on the frame. No
        # consumer is rewired: duo never calls isActive(), and
        # the only Java consumer (LaserTurret.shouldConsume(),
        # LaserTurret.java:55) also needs the bullets live
        # list, which the port does not have yet.
        self.assertIn('static func source_turret_is_active_state(has_target: bool, was_shooting: bool, enabled: bool, activation_timer: float) -> Dictionary:', turret)
        self.assertIn('var is_active: bool = (has_target or was_shooting) and enabled and activation_timer <= 0.0', turret)
        self.assertIn('return {"is_active": is_active}', turret)
        self.assertIn('public boolean isActive(){', turret)
        self.assertIn('return (target != null || wasShooting) && enabled && activationTimer <= 0;', turret)
        self.assertIn('public boolean wasShooting, isShooting;', turret)
        self.assertIn('transient boolean enabled = true;', turret)
        self.assertIn('public float activationTimer = 0;', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch right
        # after the was_shooting stamp: it derives is_active
        # live from the frame values and stamps the key.
        self.assertIn('var is_active_state: Dictionary = source_turret_is_active_state(bool(frame.get("has_target", false)), bool(frame.get("was_shooting", false)), bool(frame.get("enabled", true)), float(frame.get("activation_timer", 0.0)))', turret)
        self.assertIn('frame["is_active"] = is_active_state.get("is_active", false)', turret)
        self.assertLess(turret.index('frame["was_shooting"] = aim.get("was_shooting", false)'), turret.index('var is_active_state: Dictionary = source_turret_is_active_state('))
        self.assertLess(turret.index('var is_active_state: Dictionary = source_turret_is_active_state('), turret.index('if bool(aim.get("shot", false)):'))
        # The pure function sits immediately AFTER
        # source_turret_activation_timer_state, since isActive()
        # consumes the activationTimer <= 0 clause N2279 stamps.
        self.assertLess(turret.index('static func source_turret_activation_timer_state('), turret.index('static func source_turret_is_active_state('))
        self.assertLess(turret.index('static func source_turret_is_active_state('), turret.index('static func source_turret_heat_req_state('))
        # The proof's keys pin the four clauses through the pure
        # function and the real driver (target alone / was
        # shooting alone / disabled / positive timer -- directly;
        # both keys stamped live on the frame, with the target
        # and timer clauses observable through the driver).
        proof = TURRET_IS_ACTIVE_PROOF.read_text(encoding='utf-8')
        for key in [
            'is_active_true_with_target',
            'is_active_true_when_was_shooting',
            'is_active_false_when_disabled',
            'is_active_false_when_timer_positive',
            'is_active_stamped_to_frame',
            'is_active_target_and_timer_stamped_to_frame',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_is_active(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretIsActiveProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_IS_ACTIVE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'is_active_true_with_target',
            'is_active_true_when_was_shooting',
            'is_active_false_when_disabled',
            'is_active_false_when_timer_positive',
            'is_active_stamped_to_frame',
            'is_active_target_and_timer_stamped_to_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
