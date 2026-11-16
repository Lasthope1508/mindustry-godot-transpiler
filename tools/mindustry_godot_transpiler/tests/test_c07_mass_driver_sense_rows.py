import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MASS_DRIVER_STATE = ROOT / 'godot-mindustry/src/game/SourceMassDriverBuildState.gd'
MASS_DRIVER_SENSE_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverSenseRowsProof.gd'
MASS_DRIVER_SENSE_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverSenseRowsProof.tscn'


class C07MassDriverSenseRowsTests(unittest.TestCase):
    def test_c07_mass_driver_sense_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2392']['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_sense_state')
        # The MassDriver tick is live (N2237 advance +
        # N2294 dump + N2336 acceptItem + N2369 dump
        # write-back) but NOTHING modeled sense():
        # sense(LAccess.progress) is Mathf.clamp(1f -
        # reloadCounter) (MassDriver.java:224-228) and
        # every other sensor falls through to
        # super.sense(sensor) (the BuildingComp switch,
        # BuildingComp.java:2093-2122). N2392 ports
        # sense() as one pure dispatch, the N2383
        # pattern: progress returns the clamped 1f -
        # reloadCounter (reloadCounter is the frame value
        # the N2237 advance tracks, and it counts DOWN
        # from 1.0 to 0 -- fire() resets it to 1f,
        # MassDriver.java:292, and the decay drains it,
        # MassDriver.java:143 -- so progress RISES 0->1
        # as the driver charges; a fresh reloadCounter
        # 1.0 reads progress 0, NOT 1); any other sensor
        # returns the caller-supplied super_value -- the
        # super.sense result computed through the
        # already-modeled SourceBuildingSenseState pures
        # (sense_position_state, sense_health_process_
        # state, sense_totals_state, sense_capacity_
        # power_net_state, sense_enabled_controlled_
        # state, sense_payload_size_state, sense_camera_
        # default_state), NOT re-modeled here -- and a
        # null super_value is the super switch's default
        # branch (`default -> Float.NaN; //gets converted
        # to null in logic`, BuildingComp.java:2121).
        # Pure-only, like the N2383 sense pures: the tick
        # never calls sense (grep finds only comment
        # defers in the driver) -- sense is called by
        # logic, not the tick, and the logic call site
        # waits for a logic-executor slice. Two new
        # result symbols: the sensed value and the
        # progress dispatch flag.
        self.assertEqual(
            ledger['N2392']['source_symbols'],
            [
                'source_mass_driver_sense_state_result.value',
                'source_mass_driver_sense_state_result.is_progress',
            ],
        )
        for name in ledger['N2392']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/distribution/MassDriver.java')
                self.assertEqual(symbol['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_sense_state')
        self.assertEqual(ledger['N2392']['runtime_proof'], '/root/C07MassDriverSenseRowsProof')
        self.assertEqual(
            ledger['N2392']['tests'],
            [
                'test_c07_mass_driver_sense_rows_registration',
                'test_all_c07_mass_driver_sense_rows_input_evidence_is_exact',
                'test_mass_driver_sense_rows_state',
                'test_reference_graph_and_actual_c07_mass_driver_sense_rows',
            ],
        )
        self.assertTrue(ledger['N2392']['deferred_exprs'])
        # This slice RESOLVES the MassDriver sense half
        # of DEFERRED #47 (1-based in the merged
        # advances-20 DEFERRED base): the entry is
        # REWRITTEN IN PLACE (sense live since N2392;
        # draw / drawConfigure / drawPlace / icons still
        # wait) -- NOT removed. Net 306 - 0 = 306.
        self.assertFalse(any(entry.startswith('MassDriver sense / draw / drawConfigure / drawPlace / icons rows (') for entry in ledger['N2392']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver draw / drawConfigure / drawPlace / icons rows (') for entry in ledger['N2392']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver handlePayload / receive rows (') for entry in ledger['N2392']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver read/write rows (') for entry in ledger['N2392']['deferred_exprs']))
        self.assertEqual(len(ledger['N2392']['deferred_exprs']), 306)

    def test_all_c07_mass_driver_sense_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2392']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_sense_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/MassDriver.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2392']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mass_driver_sense_rows_state(self):
        mass_driver = MASS_DRIVER_STATE.read_text(encoding='utf-8')
        # The sense rows (MassDriverBuild.sense(),
        # MassDriver.java:224-228): `public double
        # sense(LAccess sensor){` + `if(sensor ==
        # LAccess.progress) return Mathf.clamp(1f -
        # reloadCounter);` + `return super.sense(sensor);`.
        # reloadCounter is the frame value the N2237
        # advance tracks (`public float reloadCounter =
        # 0f;`, :118); it counts DOWN from 1.0 to 0 --
        # fire() resets it (`reloadCounter = 1f;`,
        # :292) and the decay drains it
        # (`reloadCounter = Mathf.clamp(reloadCounter -
        # edelta() / reload);`, :143) -- so progress
        # rises 0->1 as the driver charges, and the
        # formula is clamp(1f - reloadCounter), NOT
        # reloadCounter / reload. Mathf.clamp(value)
        # clamps to [0, 1] (arc Mathf.java:401-404,
        # `return Math.max(Math.min(value, 1f), 0f);`),
        # so the pure uses clampf(1.0 - reload_counter,
        # 0.0, 1.0). super.sense is the BuildingComp
        # switch (BuildingComp.java:2093-2122, `return
        # switch(sensor){`): x / y / color / dead / solid
        # / team / health / maxHealth / efficiency /
        # timescale / range / rotation / totalItems /
        # totalLiquids / totalPower / itemCapacity /
        # liquidCapacity / powerCapacity / powerNetIn /
        # powerNetOut / powerNetStored / powerNetCapacity
        # / enabled / controlled / payloadCount / size /
        # cameraX, cameraY, cameraWidth, cameraHeight, and
        # `default -> Float.NaN; //gets converted to null
        # in logic`. The port already models that switch
        # (SourceBuildingSenseState -- sense_position_state,
        # sense_health_process_state, sense_totals_state,
        # sense_capacity_power_net_state, sense_enabled_
        # controlled_state, sense_payload_size_state,
        # sense_camera_default_state), so the pure takes
        # the caller's super.sense result as super_value
        # instead of re-modeling it; null is the default
        # branch. senseObject / sense(Content) are separate
        # overloads and are NOT modeled here. Pure-only:
        # the tick never calls sense (verified: grep finds
        # only comment defers in the driver) -- sense is
        # called by logic, and the logic call site waits
        # for a logic-executor slice.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_mass_driver_sense_state', mass_driver)
        self.assertIn('public double sense(LAccess sensor){', mass_driver)
        self.assertIn('if(sensor == LAccess.progress) return Mathf.clamp(1f - reloadCounter);', mass_driver)
        self.assertIn('return super.sense(sensor);', mass_driver)
        self.assertIn('public float reloadCounter = 0f;', mass_driver)
        self.assertIn('reloadCounter = Mathf.clamp(reloadCounter - edelta() / reload);', mass_driver)
        self.assertIn('reloadCounter = 1f;', mass_driver)
        self.assertIn('return switch(sensor){', mass_driver)
        self.assertIn('default -> Float.NaN; //gets converted to null in logic', mass_driver)
        self.assertIn('case health -> health;', mass_driver)
        self.assertIn('case efficiency -> efficiency;', mass_driver)
        # The documented limits record the sense rows as
        # live (the old "No link/config / handlePayload /
        # sense / draw / read-write rows" deferral text
        # is gone; the draw rows still defer).
        self.assertIn('Sense rows live (N2392)', mass_driver)
        self.assertNotIn('No link/config / handlePayload / sense / draw / read-write rows', mass_driver)
        # The proof's keys drive the sense pure (the
        # progress 0.0 (just shot, reloadCounter 1.0) /
        # 0.5 / 1.0 (ready, reloadCounter 0.0) cases, the
        # super.sense delegation for a known sensor and
        # the null default for an unknown sensor, plus
        # the live frame reload_counter feeding the
        # progress value).
        proof = MASS_DRIVER_SENSE_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'sense_progress_zero',
            'sense_progress_half',
            'sense_progress_full',
            'sense_super_sensor',
            'sense_super_default',
            'sense_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file and the
        # super.sense state file (the N2185 lesson: check
        # the preload targets exist, and the scene file
        # exists and points at the proof script).
        self.assertIn('preload("res://src/game/SourceMassDriverBuildState.gd")', proof)
        self.assertIn('preload("res://src/game/SourceBuildingSenseState.gd")', proof)
        self.assertTrue(MASS_DRIVER_STATE.exists())
        self.assertTrue((ROOT / 'godot-mindustry/src/game/SourceBuildingSenseState.gd').exists())
        self.assertTrue(MASS_DRIVER_SENSE_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07MassDriverSenseRowsProof.gd', MASS_DRIVER_SENSE_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_mass_driver_sense_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MassDriverSenseRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MASS_DRIVER_SENSE_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sense_progress_zero',
            'sense_progress_half',
            'sense_progress_full',
            'sense_super_sensor',
            'sense_super_default',
            'sense_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
