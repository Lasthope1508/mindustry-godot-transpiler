import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SEPARATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceSeparatorBuildState.gd'
SEPARATOR_SENSE_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorSenseRowsProof.gd'
SEPARATOR_SENSE_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorSenseRowsProof.tscn'


class C07SeparatorSenseRowsTests(unittest.TestCase):
    def test_c07_separator_sense_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2388']['godot_owner'], 'SourceSeparatorBuildState.source_separator_sense_state')
        # The Separator tick is live (N2222 advance +
        # N2281 timerDump + N2343 offload routing + N2353
        # offload write-back + N2361 timerDump write-back)
        # but NOTHING modeled sense(): sense(LAccess.
        # progress) is progress as-is (Separator.java:
        # 169-172) -- Java returns `progress` with NO
        # clamp, unlike the MendProjector clamp -- and
        # every other sensor falls through to super.sense
        # (sensor) (the BuildingComp switch, BuildingComp.
        # java:2094-2123). N2388 ports sense() as one pure
        # dispatch: progress returns the frame progress
        # value untouched (progress is the frame value the
        # N2222 advance tracks, Separator.java:76, `public
        # float progress;`); any other sensor returns the
        # caller-supplied super_value -- the super.sense
        # result computed through the already-modeled
        # SourceBuildingSenseState pures (sense_position_
        # state, sense_health_process_state, sense_totals_
        # state, sense_capacity_power_net_state, sense_
        # enabled_controlled_state, sense_payload_size_
        # state, sense_camera_default_state), NOT re-modeled
        # here -- and a null super_value is the super
        # switch's default branch (`default -> Float.NaN;
        # //gets converted to null in logic`, BuildingComp.
        # java:2123). canDump does NOT land here: canDump
        # is `!consumesItem(item)` (Separator.java:175-
        # 177) and consumesItem(item) is Block.itemFilter
        # [item.id] (Block.java:774-776), but no Separator
        # itemFilter is modeled -- the generic Block.
        # consumesItem pure (SourceBlockQueryFilterState.
        # consumes_item_state) takes a caller-supplied
        # item_filter, and neither the Separator driver nor
        # the catalog supplies the separator/disassembler
        # def filter (the separator def has no consumeItem,
        # Blocks.java:1231-1246, so consItems is null; the
        # disassembler consumes scrap, Blocks.java:1263).
        # Building the def filter would invent a
        # consumesItem model, so this slice is SENSE-ONLY
        # and canDump stays deferred. Pure-only, like the
        # N2383 sense pures: the tick never calls sense
        # (grep finds only the documented-limits comment in
        # the driver) -- sense is called by logic, not the
        # tick, and the logic call site waits for a
        # logic-executor slice. Two new result symbols:
        # the sensed value and the progress dispatch flag.
        self.assertEqual(
            ledger['N2388']['source_symbols'],
            [
                'source_separator_sense_state_result.value',
                'source_separator_sense_state_result.is_progress',
            ],
        )
        for name in ledger['N2388']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/Separator.java')
                self.assertEqual(symbol['godot_owner'], 'SourceSeparatorBuildState.source_separator_sense_state')
        self.assertEqual(ledger['N2388']['runtime_proof'], '/root/C07SeparatorSenseRowsProof')
        self.assertEqual(
            ledger['N2388']['tests'],
            [
                'test_c07_separator_sense_rows_registration',
                'test_all_c07_separator_sense_rows_input_evidence_is_exact',
                'test_separator_sense_rows_state',
                'test_reference_graph_and_actual_c07_separator_sense_rows',
            ],
        )
        self.assertTrue(ledger['N2388']['deferred_exprs'])
        # This slice is SENSE-ONLY: DEFERRED #38 (the
        # merged advances-20 base, 306 entries) is
        # REWRITTEN IN PLACE, not resolved -- the old
        # combined "sense / canDump rows" entry is gone,
        # replaced by the canDump-only entry (sense live
        # since N2388, canDump still waits for a Separator
        # itemFilter/consumesItem model). Net 306 - 0 =
        # 306: no entry added, none removed.
        self.assertFalse(any(entry.startswith('Separator sense / canDump rows (') for entry in ledger['N2388']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator canDump row (') for entry in ledger['N2388']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator draw / drawLight / icons / drawPlanRegion rows (') for entry in ledger['N2388']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator disassembler variant (') for entry in ledger['N2388']['deferred_exprs']))
        self.assertEqual(len(ledger['N2388']['deferred_exprs']), 306)

    def test_all_c07_separator_sense_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2388']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceSeparatorBuildState.source_separator_sense_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Separator.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2388']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_separator_sense_rows_state(self):
        separator = SEPARATOR_STATE.read_text(encoding='utf-8')
        # The sense rows (SeparatorBuild.sense(),
        # Separator.java:169-172): `public double
        # sense(LAccess sensor){` + `if(sensor ==
        # LAccess.progress) return progress;` + `return
        # super.sense(sensor);`. progress is the frame
        # value the N2222 advance tracks (`public float
        # progress;`, :76, advanced by `progress +=
        # getProgressIncrease(craftTime);`, :134) -- and
        # Java returns it AS-IS, with NO clamp (unlike
        # the MendProjector, which clamps charge / reload
        # to [0, 1]): the pure must not clampf. super.
        # sense is the BuildingComp switch (BuildingComp.
        # java:2094-2123, `return switch(sensor){`): x /
        # y / color / dead / solid / team / health /
        # maxHealth / efficiency / timescale / range /
        # rotation / totalItems / totalLiquids / totalPower
        # / itemCapacity / liquidCapacity / powerCapacity
        # / powerNetIn / powerNetOut / powerNetStored /
        # powerNetCapacity / enabled / controlled /
        # payloadCount / size / cameraX, cameraY,
        # cameraWidth, cameraHeight, and `default ->
        # Float.NaN; //gets converted to null in logic`.
        # The port already models that switch
        # (SourceBuildingSenseState -- sense_position_state,
        # sense_health_process_state, sense_totals_state,
        # sense_capacity_power_net_state, sense_enabled_
        # controlled_state, sense_payload_size_state,
        # sense_camera_default_state), so the pure takes
        # the caller's super.sense result as super_value
        # instead of re-modeling it; null is the default
        # branch. senseObject / sense(Content) are separate
        # overloads and are NOT modeled here. canDump
        # (`return !consumesItem(item);`, Separator.java:
        # 175-177) is NOT modeled here either: consumesItem
        # is Block.itemFilter[item.id] (Block.java:774-
        # 776) and no Separator itemFilter is modeled, so
        # canDump stays deferred (see the rewritten
        # DEFERRED entry). Pure-only: the tick never calls
        # sense (verified: grep finds only the documented-
        # limits comment in the driver) -- sense is called
        # by logic, and the logic call site waits for a
        # logic-executor slice.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_separator_sense_state', separator)
        self.assertIn('public double sense(LAccess sensor){', separator)
        self.assertIn('if(sensor == LAccess.progress) return progress;', separator)
        self.assertIn('return super.sense(sensor);', separator)
        self.assertIn('public float progress;', separator)
        self.assertIn('progress += getProgressIncrease(craftTime);', separator)
        self.assertIn('return switch(sensor){', separator)
        self.assertIn('default -> Float.NaN; //gets converted to null in logic', separator)
        self.assertIn('case health -> health;', separator)
        self.assertIn('case efficiency -> efficiency;', separator)
        # The documented limits record the sense rows as
        # live and canDump as still waiting (the old
        # combined "No sense / canDump" deferral text is
        # gone; the draw rows still defer).
        self.assertIn('Sense rows live (N2388)', separator)
        self.assertIn('canDump still waits', separator)
        self.assertNotIn('(4) No sense / canDump / draw / drawLight', separator)
        # The proof's keys drive the sense pure (the
        # progress 0.0 / 0.5 / unclamped cases, the
        # super.sense delegation for a known sensor and
        # the null default for an unknown sensor, plus
        # the live frame progress feeding the progress
        # value). The unclamped key is the no-clamp
        # evidence: Java returns progress as-is.
        proof = SEPARATOR_SENSE_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'sense_progress_zero',
            'sense_progress_partial',
            'sense_progress_unclamped',
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
        self.assertIn('preload("res://src/game/SourceSeparatorBuildState.gd")', proof)
        self.assertIn('preload("res://src/game/SourceBuildingSenseState.gd")', proof)
        self.assertTrue(SEPARATOR_STATE.exists())
        self.assertTrue((ROOT / 'godot-mindustry/src/game/SourceBuildingSenseState.gd').exists())
        self.assertTrue(SEPARATOR_SENSE_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07SeparatorSenseRowsProof.gd', SEPARATOR_SENSE_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_separator_sense_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SeparatorSenseRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SEPARATOR_SENSE_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sense_progress_zero',
            'sense_progress_partial',
            'sense_progress_unclamped',
            'sense_super_sensor',
            'sense_super_default',
            'sense_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
