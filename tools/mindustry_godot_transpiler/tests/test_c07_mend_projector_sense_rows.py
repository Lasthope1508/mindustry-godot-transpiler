import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MEND_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceMendProjectorBuildState.gd'
MEND_PROJECTOR_SENSE_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorSenseRowsProof.gd'
MEND_PROJECTOR_SENSE_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorSenseRowsProof.tscn'


class C07MendProjectorSenseRowsTests(unittest.TestCase):
    def test_c07_mend_projector_sense_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2383']['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_sense_state')
        # The MendProjector tick is live (N2193 advance +
        # N2242 heal scan + N2263 booster items + N2269
        # timer use + N2329 range query + N2335 narrow
        # filter + N2350 hitbox broad phase + N2372 draw
        # rows) but NOTHING modeled sense():
        # sense(LAccess.progress) is Mathf.clamp(charge /
        # reload) (MendProjector.java:126-129) and every
        # other sensor falls through to super.sense(sensor)
        # (the BuildingComp switch, BuildingComp.java:2093-
        # 2122). N2383 ports sense() as one pure dispatch:
        # progress returns the clamped charge / reload
        # (charge is the frame value the N2193 advance
        # tracks, reload is the per-def explicit input --
        # mender 200f, mend-projector 250f, Blocks.java:
        # 1923/1936, class default 250f, MendProjector.java:
        # 26); any other sensor returns the caller-supplied
        # super_value -- the super.sense result computed
        # through the already-modeled SourceBuildingSense-
        # State pures (sense_position_state, sense_health_
        # process_state, sense_totals_state, sense_capacity_
        # power_net_state, sense_enabled_controlled_state,
        # sense_payload_size_state, sense_camera_default_
        # state), NOT re-modeled here -- and a null
        # super_value is the super switch's default branch
        # (`default -> Float.NaN; //gets converted to null
        # in logic`, BuildingComp.java:2121). Pure-only,
        # like the N2372 draw pures: the tick never calls
        # sense (grep finds only comment defers in the
        # driver) -- sense is called by logic, not the
        # tick, and the logic call site waits for a
        # logic-executor slice. Two new result symbols:
        # the sensed value and the progress dispatch flag.
        self.assertEqual(
            ledger['N2383']['source_symbols'],
            [
                'source_mend_projector_sense_state_result.value',
                'source_mend_projector_sense_state_result.is_progress',
            ],
        )
        for name in ledger['N2383']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/MendProjector.java')
                self.assertEqual(symbol['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_sense_state')
        self.assertEqual(ledger['N2383']['runtime_proof'], '/root/C07MendProjectorSenseRowsProof')
        self.assertEqual(
            ledger['N2383']['tests'],
            [
                'test_c07_mend_projector_sense_rows_registration',
                'test_all_c07_mend_projector_sense_rows_input_evidence_is_exact',
                'test_mend_projector_sense_rows_state',
                'test_reference_graph_and_actual_c07_mend_projector_sense_rows',
            ],
        )
        self.assertTrue(ledger['N2383']['deferred_exprs'])
        # This slice RESOLVES the MendProjector sense rows
        # (#309 in the merged advances-19 DEFERRED base):
        # the entry is REMOVED (resolve by text). No new
        # entry is added: the sense pure is pure-only (no
        # tick wiring to defer), the super.sense delegation
        # rides the already-modeled SourceBuildingSenseState
        # pures, and the logic call site is a port-wide
        # logic-executor concern, not a MendProjector
        # deferral. Net 311 - 1 = 310.
        self.assertFalse(any(entry.startswith('MendProjector sense rows (') for entry in ledger['N2383']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector suppression gate (') for entry in ledger['N2383']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector heal scan live building-index fill (') for entry in ledger['N2383']['deferred_exprs']))
        self.assertEqual(len(ledger['N2383']['deferred_exprs']), 310)

    def test_all_c07_mend_projector_sense_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2383']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_sense_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/MendProjector.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2383']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mend_projector_sense_rows_state(self):
        mend_projector = MEND_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The sense rows (MendBuild.sense(),
        # MendProjector.java:126-129): `public double
        # sense(LAccess sensor){` + `if(sensor ==
        # LAccess.progress) return Mathf.clamp(charge /
        # reload);` + `return super.sense(sensor);`.
        # charge is the frame value the N2193 advance
        # tracks (`public float heat, charge =
        # Mathf.random(reload), phaseHeat,
        # smoothEfficiency;`, :85); reload is per-def
        # (mender 200f, mend-projector 250f, Blocks.java:
        # 1923/1936; the class default is `public float
        # reload = 250f;`, :26). Mathf.clamp(value) clamps
        # to [0, 1] (arc Mathf.java:401-404, `return
        # Math.max(Math.min(value, 1f), 0f);`), so the pure
        # uses clampf(charge / reload, 0.0, 1.0).
        # super.sense is the BuildingComp switch
        # (BuildingComp.java:2093-2122, `return
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
        self.assertIn('static func source_mend_projector_sense_state', mend_projector)
        self.assertIn('public double sense(LAccess sensor){', mend_projector)
        self.assertIn('if(sensor == LAccess.progress) return Mathf.clamp(charge / reload);', mend_projector)
        self.assertIn('return super.sense(sensor);', mend_projector)
        self.assertIn('public float heat, charge = Mathf.random(reload), phaseHeat, smoothEfficiency;', mend_projector)
        self.assertIn('public float reload = 250f;', mend_projector)
        self.assertIn('return switch(sensor){', mend_projector)
        self.assertIn('default -> Float.NaN; //gets converted to null in logic', mend_projector)
        self.assertIn('case health -> health;', mend_projector)
        self.assertIn('case efficiency -> efficiency;', mend_projector)
        # The documented limits record the sense rows as
        # live (the old "sense still waits" deferral text
        # is gone; the suppression gate still defers).
        self.assertIn('Sense rows live (N2383)', mend_projector)
        self.assertNotIn('sense() (:126-129) still waits for its own slice.', mend_projector)
        self.assertNotIn('defer (suppression, sense, the live building index;', mend_projector)
        # The proof's keys drive the sense pure (the
        # progress 0.0 / 0.5 / 1.0-clamped cases, the
        # super.sense delegation for a known sensor and
        # the null default for an unknown sensor, plus the
        # live frame charge feeding the progress value).
        proof = MEND_PROJECTOR_SENSE_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'sense_progress_zero',
            'sense_progress_half',
            'sense_progress_clamped',
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
        self.assertIn('preload("res://src/game/SourceMendProjectorBuildState.gd")', proof)
        self.assertIn('preload("res://src/game/SourceBuildingSenseState.gd")', proof)
        self.assertTrue(MEND_PROJECTOR_STATE.exists())
        self.assertTrue((ROOT / 'godot-mindustry/src/game/SourceBuildingSenseState.gd').exists())
        self.assertTrue(MEND_PROJECTOR_SENSE_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07MendProjectorSenseRowsProof.gd', MEND_PROJECTOR_SENSE_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_mend_projector_sense_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MendProjectorSenseRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MEND_PROJECTOR_SENSE_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sense_progress_zero',
            'sense_progress_half',
            'sense_progress_clamped',
            'sense_super_sensor',
            'sense_super_default',
            'sense_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
