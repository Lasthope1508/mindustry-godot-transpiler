import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretShouldConsumeProof.gd'


class C07TurretShouldConsumeTests(unittest.TestCase):
    def test_c07_turret_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2253']['godot_owner'], 'SourceTurretBuildState.source_turret_should_consume_state')
        # TurretBuild overrides shouldConsume (Turret.java:364-366,
        # `public boolean shouldConsume(){` / `return isShooting
        # || reloadCounter < reload;`). The base default it
        # overrides is BuildingComp.shouldConsume
        # (BuildingComp.java:755-757, `return enabled;`), and
        # updateConsumption forces efficiency to zero when the
        # gate is false (BuildingComp.java:1960, `boolean update
        # = shouldConsume() && productionValid();` + 1993,
        # `efficiency = optionalEfficiency = 0f;`). The two
        # inputs are TurretBuild fields: isShooting
        # (Turret.java:292, `public boolean wasShooting,
        # isShooting;`, set in updateTile :492) and
        # reloadCounter (ReloadTurret.java:26, `public float
        # reloadCounter;`, advanced in updateReload,
        # Turret.java:720-723 and capped at reload :723),
        # against the per-def reload time
        # (ReloadTurret.java:10, `public float reload =
        # 10f;`). The same comparison is the canReload gate
        # (ReloadTurret.java:50, `return reloadCounter <
        # reload;`). This closes the deferred item recorded
        # in N2148. RED decisions (recorded in the register
        # docstring): (1) one pure function on
        # SourceTurretBuildState.gd next to the N2148
        # power-status row, (frame, is_shooting,
        # reload_counter, reload), following the N2188 /
        # N2188 explicit-param precedent -- frame reads no
        # live key, the three inputs arrive as explicit
        # params. (2) The driver line replaces
        # `should_consume = enabled` in the power-consumer
        # branch of the tick driver and reads frame defaults
        # (false / 0.0 / 10f), preserving the N2148 behaviour
        # (should_consume=true when enabled) until a
        # frame-tracking slice stamps them. (3) progress()
        # and sense() stay deferred (assigned N2254 / N2255).
        # One new result symbol: should_consume.
        self.assertEqual(
            ledger['N2253']['source_symbols'],
            [
                'source_turret_should_consume_state_result.should_consume',
            ],
        )
        for name in ledger['N2253']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2253']['runtime_proof'], '/root/C07TurretShouldConsumeProof')
        self.assertEqual(
            ledger['N2253']['tests'],
            [
                'test_c07_turret_should_consume_registration',
                'test_all_c07_turret_should_consume_input_evidence_is_exact',
                'test_turret_should_consume_state',
                'test_reference_graph_and_actual_c07_turret_should_consume',
            ],
        )
        self.assertTrue(ledger['N2253']['deferred_exprs'])
        self.assertNotIn(
            'Turret shouldConsume gate (isShooting / reloadCounter, Turret.java:364-366)',
            ' '.join(ledger['N2253']['deferred_exprs']),
        )

    def test_all_c07_turret_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2253']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2253']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_should_consume_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.shouldConsume() (Turret.java:364-366):
        # `return isShooting || reloadCounter < reload;`
        # over isShooting (Turret.java:292) and reloadCounter
        # (ReloadTurret.java:26, capped at reload,
        # Turret.java:723) against reload
        # (ReloadTurret.java:10, `public float reload =
        # 10f;`). updateConsumption forces efficiency to zero
        # when the gate is false (BuildingComp.java:1960 +
        # 1993). The driver reads frame defaults
        # (is_shooting=false, reload_counter=0.0,
        # reload=10f) until a frame-tracking slice stamps
        # them; with those defaults 0.0 < 10f, so the gate
        # preserves the N2148 behaviour. progress()
        # (Turret.java:425-427) and sense()
        # (Turret.java:406-419) are the assigned N2254 /
        # N2255 slices, not this one.
        self.assertIn('static func source_turret_should_consume_state(frame: Dictionary, is_shooting: bool, reload_counter: float, reload: float) -> Dictionary:', turret)
        self.assertIn('return {"should_consume": is_shooting or reload_counter < reload}', turret)
        for expr in [
            'public boolean shouldConsume(){',
            'return isShooting || reloadCounter < reload;',
            'public boolean wasShooting, isShooting;',
            'public float reloadCounter;',
            'public float reload = 10f;',
            'return reloadCounter < reload;',
            'boolean update = shouldConsume() && productionValid();',
            'efficiency = optionalEfficiency = 0f;',
            'reloadCounter = Math.min(reloadCounter, reload);',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
            'return enabled;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The driver line calls the pure function with frame
        # defaults (no isShooting / reloadCounter / reload
        # keys are stamped by the tick frame yet).
        self.assertIn('source_turret_should_consume_state(frame', turret)
        self.assertIn('frame.get("is_shooting", false)', turret)
        self.assertIn('frame.get("reload_counter", 0.0)', turret)
        self.assertIn('frame.get("reload", 10.0)', turret)
        # The proof's keys drive the pure function directly
        # with explicit params plus one live-driver key: a
        # shooting turret consumes, a reloading turret
        # consumes, a reloaded idle turret does not, a
        # counter past reload does not, and the live tick
        # driver passes the gate with frame defaults.
        proof = TURRET_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'should_consume_shooting',
            'should_consume_reloading',
            'should_consume_reloaded_idle',
            'should_consume_beyond_reload',
            'driver_gate_passes_with_frame_defaults',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'should_consume_shooting',
            'should_consume_reloading',
            'should_consume_reloaded_idle',
            'should_consume_beyond_reload',
            'driver_gate_passes_with_frame_defaults',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
