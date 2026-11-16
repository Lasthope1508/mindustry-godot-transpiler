import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
IMPACT_REACTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceImpactReactorBuildState.gd'
IMPACT_REACTOR_SENSE_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorSenseRowsProof.gd'
IMPACT_REACTOR_SENSE_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorSenseRowsProof.tscn'


class C07ImpactReactorSenseRowsTests(unittest.TestCase):
    def test_c07_impact_reactor_sense_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2391']['godot_owner'], 'SourceImpactReactorBuildState.source_impact_reactor_sense_state')
        # The ImpactReactor tick is live (N2192 advance +
        # N2254 liquid row + N2266 item row + timer use)
        # but NOTHING modeled sense(): sense(LAccess.heat)
        # returns the frame warmup directly
        # (ImpactReactor.java:119-122) and every other
        # sensor falls through to super.sense(sensor)
        # (the BuildingComp switch, BuildingComp.java:
        # 2093-2125). N2391 ports sense() as one pure
        # dispatch: heat returns the frame warmup
        # DIRECTLY -- no clamp, no ratio (unlike the
        # N2383 MendProjector progress clamp); any other
        # sensor returns the caller-supplied super_value
        # -- the super.sense result computed through the
        # already-modeled SourceBuildingSenseState pures
        # (sense_position_state, sense_health_process_
        # state, sense_totals_state, sense_capacity_power_
        # net_state, sense_enabled_controlled_state,
        # sense_payload_size_state, sense_camera_default_
        # state), NOT re-modeled here -- and a null
        # super_value is the super switch's default branch
        # (`default -> Float.NaN; //gets converted to null
        # in logic`, BuildingComp.java:2123). The warmup()
        # accessor (ImpactReactor.java:104-106) is a
        # SECOND pure, not folded into the sense dispatch:
        # its call shape differs -- warmup() is called by
        # the DRAWER (DrawPlasma scales its light and
        # alpha by build.warmup(), DrawPlasma.java:32,
        # 42), not by logic, so a drawer caller must not
        # go through a sensor dispatch Java never gives
        # it. Three new result symbols: the sensed value,
        # the heat dispatch flag, and the warmup value.
        # CORRECTION, verified against upstream Java: the
        # driver docstring used to claim no sense override
        # existed on ImpactReactorBuild -- WRONG, the
        # sense override EXISTS at ImpactReactor.java:
        # 119-122 (and warmup() at :104-106, NOT :114-116
        # as the slice brief said -- :114-116 is
        # ambientVolume(); the DEFERRED cite :124-127 was
        # also off -- :124-127 is the write() override).
        # N2391 fixes that docstring line in this slice.
        self.assertEqual(
            ledger['N2391']['source_symbols'],
            [
                'source_impact_reactor_sense_state_result.value',
                'source_impact_reactor_sense_state_result.is_heat',
                'source_impact_reactor_warmup_state_result.value',
            ],
        )
        expected_owners = {
            'source_impact_reactor_sense_state_result.value': 'SourceImpactReactorBuildState.source_impact_reactor_sense_state',
            'source_impact_reactor_sense_state_result.is_heat': 'SourceImpactReactorBuildState.source_impact_reactor_sense_state',
            'source_impact_reactor_warmup_state_result.value': 'SourceImpactReactorBuildState.source_impact_reactor_warmup_state',
        }
        for name in ledger['N2391']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/power/ImpactReactor.java')
                self.assertEqual(symbol['godot_owner'], expected_owners[name])
        self.assertEqual(ledger['N2391']['runtime_proof'], '/root/C07ImpactReactorSenseRowsProof')
        self.assertEqual(
            ledger['N2391']['tests'],
            [
                'test_c07_impact_reactor_sense_rows_registration',
                'test_all_c07_impact_reactor_sense_rows_input_evidence_is_exact',
                'test_impact_reactor_sense_rows_state',
                'test_reference_graph_and_actual_c07_impact_reactor_sense_rows',
            ],
        )
        self.assertTrue(ledger['N2391']['deferred_exprs'])
        # This slice RESOLVES the ImpactReactor sense rows
        # (#96 in the merged advances-20 DEFERRED base):
        # the entry is REMOVED (resolve by text). No new
        # entry is added: the sense/warmup pures are
        # pure-only (no tick wiring to defer), the
        # super.sense delegation rides the already-modeled
        # SourceBuildingSenseState pures, the logic call
        # site is a port-wide logic-executor concern (not
        # an ImpactReactor deferral), and the drawer call
        # site stays under the existing ImpactReactor draw
        # rows entry. Net 306 - 1 = 305.
        self.assertFalse(any(entry.startswith('ImpactReactor sense rows (') for entry in ledger['N2391']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor explosion rows (') for entry in ledger['N2391']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor setBars / setStats rows (') for entry in ledger['N2391']['deferred_exprs']))
        self.assertEqual(len(ledger['N2391']['deferred_exprs']), 305)

    def test_all_c07_impact_reactor_sense_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        expected_owners = {
            'source_impact_reactor_sense_state_result.value': 'SourceImpactReactorBuildState.source_impact_reactor_sense_state',
            'source_impact_reactor_sense_state_result.is_heat': 'SourceImpactReactorBuildState.source_impact_reactor_sense_state',
            'source_impact_reactor_warmup_state_result.value': 'SourceImpactReactorBuildState.source_impact_reactor_warmup_state',
        }
        for name in ledger['N2391']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], expected_owners[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/power/ImpactReactor.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/draw/DrawPlasma.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2391']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_impact_reactor_sense_rows_state(self):
        impact_reactor = IMPACT_REACTOR_STATE.read_text(encoding='utf-8')
        # The sense rows (ImpactReactorBuild.sense(),
        # ImpactReactor.java:119-122): `public double
        # sense(LAccess sensor){` + `if(sensor ==
        # LAccess.heat) return warmup;` + `return
        # super.sense(sensor);`. warmup is the frame
        # value the N2192 advance tracks (`public float
        # warmup, totalProgress;`, :75) -- sense(heat)
        # returns it DIRECTLY, no clamp, no ratio (unlike
        # the N2383 MendProjector progress clamp).
        # super.sense is the BuildingComp switch
        # (BuildingComp.java:2093-2125, `return
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
        # overloads and are NOT modeled here. The warmup()
        # accessor (ImpactReactor.java:104-106, `public
        # float warmup(){` + `return warmup;`) is a
        # separate pure: the DRAWER calls it (DrawPlasma
        # scales light/alpha by build.warmup(),
        # DrawPlasma.java:32, 42), not logic. NOTE the
        # parent: PowerGenerator.warmup() returns
        # productionEfficiency when enabled
        # (PowerGenerator.java:105, `return enabled ?
        # productionEfficiency : 0f;`) -- but
        # ImpactReactorBuild OVERRIDES it to return the
        # raw warmup field, so the port models the
        # override, not the parent. Pure-only: the tick
        # never calls sense or warmup() (verified: grep
        # finds only comments in the driver) -- sense is
        # called by logic, warmup() by the drawer, and
        # both call sites wait for their own slices.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_impact_reactor_sense_state', impact_reactor)
        self.assertIn('static func source_impact_reactor_warmup_state', impact_reactor)
        self.assertIn('public double sense(LAccess sensor){', impact_reactor)
        self.assertIn('if(sensor == LAccess.heat) return warmup;', impact_reactor)
        self.assertIn('return super.sense(sensor);', impact_reactor)
        self.assertIn('public float warmup(){', impact_reactor)
        self.assertIn('return warmup;', impact_reactor)
        self.assertIn('public float warmup, totalProgress;', impact_reactor)
        self.assertIn('return switch(sensor){', impact_reactor)
        self.assertIn('default -> Float.NaN; //gets converted to null in logic', impact_reactor)
        self.assertIn('case health -> health;', impact_reactor)
        self.assertIn('case efficiency -> efficiency;', impact_reactor)
        self.assertIn('build.warmup()', impact_reactor)
        # The documented limits record the sense rows as
        # live, and the wrong docstring line (no sense
        # override existed) is gone.
        self.assertIn('Sense rows live (N2391)', impact_reactor)
        self.assertNotIn('No sense / read / write overrides exist on ImpactReactorBuild', impact_reactor)
        # The proof's keys drive the sense pure (the
        # heat 0.0 / 0.5 / 1.0 cases, the super.sense
        # delegation for a known sensor and the null
        # default for an unknown sensor, plus the live
        # frame warmup feeding the heat value) and the
        # warmup pure (checked inside the heat keys and
        # the live-frame key).
        proof = IMPACT_REACTOR_SENSE_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'sense_heat_zero',
            'sense_heat_partial',
            'sense_heat_full',
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
        self.assertIn('preload("res://src/game/SourceImpactReactorBuildState.gd")', proof)
        self.assertIn('preload("res://src/game/SourceBuildingSenseState.gd")', proof)
        self.assertTrue(IMPACT_REACTOR_STATE.exists())
        self.assertTrue((ROOT / 'godot-mindustry/src/game/SourceBuildingSenseState.gd').exists())
        self.assertTrue(IMPACT_REACTOR_SENSE_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07ImpactReactorSenseRowsProof.gd', IMPACT_REACTOR_SENSE_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_impact_reactor_sense_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ImpactReactorSenseRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_IMPACT_REACTOR_SENSE_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sense_heat_zero',
            'sense_heat_partial',
            'sense_heat_full',
            'sense_super_sensor',
            'sense_super_default',
            'sense_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
