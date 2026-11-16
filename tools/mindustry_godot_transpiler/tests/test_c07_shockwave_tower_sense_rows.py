import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_SENSE_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerSenseRowsProof.gd'
SHOCKWAVE_TOWER_SENSE_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerSenseRowsProof.tscn'


class C07ShockwaveTowerSenseRowsTests(unittest.TestCase):
    def test_c07_shockwave_tower_sense_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2390']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_sense_state')
        # The ShockwaveTower tick is live (N2187 shouldConsume
        # gate + N2247 updateTile advance + N2318 timerCheck
        # cadence + N2327 bullet scan + N2331 cyanogen row +
        # N2340 hitbox refinement + N2347 broad hitbox phase +
        # N2356 draw rows) but NOTHING modeled sense() or
        # warmup(): sense(LAccess.progress) is the BARE ratio
        # reloadCounter / reload (ShockwaveTower.java:109-112)
        # -- NO clamp, unlike the MendProjector
        # (Mathf.clamp(charge / reload), MendProjector.java:
        # 127) and the LaunchPad -- and every other sensor
        # falls through to super.sense(sensor) (the
        # BuildingComp switch, BuildingComp.java:2094-2123).
        # warmup() returns heat (ShockwaveTower.java:115-118).
        # N2390 ports them as TWO pures, the clean split
        # following the N2383 single-purpose precedent and
        # the N2356 two-pure precedent: the sense dispatch
        # (progress returns the bare reloadCounter / reload,
        # reload_counter is the frame value the N2187 gate
        # and the N2247 advance track, reload is the per-def
        # explicit input -- shockwave-tower 80f,
        # Blocks.java:2044, class default 60f * 1.5f,
        # ShockwaveTower.java:26; any other sensor returns
        # the caller-supplied super_value -- the super.sense
        # result computed through the already-modeled
        # SourceBuildingSenseState pures, NOT re-modeled
        # here -- and a null super_value is the super
        # switch's default branch (`default -> Float.NaN;
        # //gets converted to null in logic`,
        # BuildingComp.java:2123)) and the warmup accessor
        # (returns the frame heat, `public float heat = 0f;`,
        # ShockwaveTower.java:68, set to 1f on fire and
        # decayed every tick by the N2247 advance).
        # Pure-only, like the N2383 sense pure and the N2356
        # draw pures: the tick never calls sense or warmup
        # (grep finds only comment defers in the driver) --
        # sense is called by logic, warmup by UI/display, and
        # the call sites wait for logic-executor / display
        # slices. Three new result symbols: the sensed value,
        # the progress dispatch flag, and the warmup value.
        self.assertEqual(
            ledger['N2390']['source_symbols'],
            [
                'source_shockwave_tower_sense_state_result.value',
                'source_shockwave_tower_sense_state_result.is_progress',
                'source_shockwave_tower_warmup_state_result.warmup',
            ],
        )
        for name in ledger['N2390']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/ShockwaveTower.java')
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_sense_state_result.value': 'SourceShockwaveTowerBuildState.source_shockwave_tower_sense_state',
                    'source_shockwave_tower_sense_state_result.is_progress': 'SourceShockwaveTowerBuildState.source_shockwave_tower_sense_state',
                    'source_shockwave_tower_warmup_state_result.warmup': 'SourceShockwaveTowerBuildState.source_shockwave_tower_warmup_state',
                }[name])
        self.assertEqual(ledger['N2390']['runtime_proof'], '/root/C07ShockwaveTowerSenseRowsProof')
        self.assertEqual(
            ledger['N2390']['tests'],
            [
                'test_c07_shockwave_tower_sense_rows_registration',
                'test_all_c07_shockwave_tower_sense_rows_input_evidence_is_exact',
                'test_shockwave_tower_sense_rows_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_sense_rows',
            ],
        )
        self.assertTrue(ledger['N2390']['deferred_exprs'])
        # This slice RESOLVES the ShockwaveTower sense /
        # warmup rows (#65 in the merged advances-20
        # DEFERRED base): the entry is REMOVED (resolve by
        # text). No new entry is added: the sense + warmup
        # pures are pure-only (no tick wiring to defer), the
        # super.sense delegation rides the already-modeled
        # SourceBuildingSenseState pures, and the logic /
        # display call sites are port-wide concerns, not
        # ShockwaveTower deferrals. Net 306 - 1 = 305.
        self.assertFalse(any(entry.startswith('ShockwaveTower sense / warmup rows (') for entry in ledger['N2390']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower trigger row (') for entry in ledger['N2390']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower per-def stat rows (') for entry in ledger['N2390']['deferred_exprs']))
        self.assertEqual(len(ledger['N2390']['deferred_exprs']), 305)

    def test_all_c07_shockwave_tower_sense_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2390']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_sense_state_result.value': 'SourceShockwaveTowerBuildState.source_shockwave_tower_sense_state',
                    'source_shockwave_tower_sense_state_result.is_progress': 'SourceShockwaveTowerBuildState.source_shockwave_tower_sense_state',
                    'source_shockwave_tower_warmup_state_result.warmup': 'SourceShockwaveTowerBuildState.source_shockwave_tower_warmup_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2390']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_sense_rows_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The sense rows (ShockwaveTowerBuild.sense(),
        # ShockwaveTower.java:109-112): `public double
        # sense(LAccess sensor) {` + `if(sensor ==
        # LAccess.progress) return reloadCounter / reload;`
        # + `return super.sense(sensor);`. The ratio is
        # BARE -- Java has NO clamp here, unlike the
        # MendProjector (Mathf.clamp(charge / reload)) and
        # the LaunchPad, so the pure does NOT clamp: a
        # counter past the reload reads above 1.0.
        # reload_counter is the frame value the N2187 gate
        # and the N2247 advance track (`public float
        # reloadCounter = Mathf.random(reload);`, :67);
        # reload is per-def (shockwave-tower 80f,
        # Blocks.java:2044; the class default is `public
        # float reload = 60f * 1.5f;`, :26). warmup()
        # (ShockwaveTower.java:115-118): `public float
        # warmup(){` + `return heat;` -- heat is the frame
        # value (`public float heat = 0f;`, :68), set to 1f
        # on fire and decayed every tick by the N2247
        # advance. super.sense is the BuildingComp switch
        # (BuildingComp.java:2094-2123, `return
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
        # the tick never calls sense or warmup (verified:
        # grep finds only comment defers in the driver) --
        # sense is called by logic, warmup by UI/display,
        # and the call sites wait for logic-executor /
        # display slices.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_shockwave_tower_sense_state', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_warmup_state', shockwave_tower)
        self.assertIn('public double sense(LAccess sensor) {', shockwave_tower)
        self.assertIn('if(sensor == LAccess.progress) return reloadCounter / reload;', shockwave_tower)
        self.assertIn('return super.sense(sensor);', shockwave_tower)
        self.assertIn('public float warmup(){', shockwave_tower)
        self.assertIn('return heat;', shockwave_tower)
        self.assertIn('public float reloadCounter = Mathf.random(reload);', shockwave_tower)
        self.assertIn('public float heat = 0f;', shockwave_tower)
        self.assertIn('public float reload = 60f * 1.5f;', shockwave_tower)
        self.assertIn('return switch(sensor){', shockwave_tower)
        self.assertIn('default -> Float.NaN; //gets converted to null in logic', shockwave_tower)
        self.assertIn('case health -> health;', shockwave_tower)
        self.assertIn('case efficiency -> efficiency;', shockwave_tower)
        # The documented limits record the sense / warmup
        # rows as live (the old "wait for their own slices"
        # deferral text is gone; the trigger row still
        # defers).
        self.assertIn('Sense/warmup rows live (N2390)', shockwave_tower)
        self.assertNotIn('both wait for their own slices.', shockwave_tower)
        self.assertNotIn('sense progress + warmup still deferred.', shockwave_tower)
        # The proof's keys drive the sense + warmup pures
        # (the progress 0.0 / 0.5 / bare 1.5 cases, the
        # warmup value, the super.sense delegation for a
        # known sensor and the null default for an unknown
        # sensor, plus the live frame counter + heat
        # feeding the progress + warmup values).
        proof = SHOCKWAVE_TOWER_SENSE_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'sense_progress_zero',
            'sense_progress_partial',
            'warmup_value',
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
        self.assertIn('preload("res://src/game/SourceShockwaveTowerBuildState.gd")', proof)
        self.assertIn('preload("res://src/game/SourceBuildingSenseState.gd")', proof)
        self.assertTrue(SHOCKWAVE_TOWER_STATE.exists())
        self.assertTrue((ROOT / 'godot-mindustry/src/game/SourceBuildingSenseState.gd').exists())
        self.assertTrue(SHOCKWAVE_TOWER_SENSE_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07ShockwaveTowerSenseRowsProof.gd', SHOCKWAVE_TOWER_SENSE_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_shockwave_tower_sense_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerSenseRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_SENSE_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sense_progress_zero',
            'sense_progress_partial',
            'warmup_value',
            'sense_super_sensor',
            'sense_super_default',
            'sense_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
