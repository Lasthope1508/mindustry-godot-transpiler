import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_ASSEMBLER_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitAssemblerModuleBuildState.gd'
UNIT_ASSEMBLER_MODULE_SELECT_REMOVE_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleSelectRemoveRowsProof.gd'
UNIT_ASSEMBLER_MODULE_SELECT_REMOVE_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleSelectRemoveRowsProof.tscn'


class C07UnitAssemblerModuleSelectRemoveRowsTests(unittest.TestCase):
    def test_c07_unit_assembler_module_select_remove_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2447']['godot_owner'], 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_select_remove_state')
        # The UnitAssemblerModule tick is live (N2248
        # advance + N2299 acceptPayload + N2314 handoff
        # gate + N2345 canPlaceOn + N2348 tier stamp +
        # N2351 checkTier wiring + N2358 getLink
        # discovery + N2370 moduleFits wiring + N2381
        # flagged fill) and the draw rows are live
        # (N2425), but NOTHING modeled drawSelect()
        # (UnitAssemblerModule.java:118-123: the TODO
        # draw area? + the link highlight
        # `Drawf.selected(link, Pal.accent);` when
        # linked) or onRemoved() (:125-131: `super.
        # onRemoved();` + `link.removeModule(this);`
        # when linked). N2447 ports both as ONE
        # pure-only select/remove pure, the N2396
        # MassDriver pattern: drawSelect is called by
        # the selection UI and onRemoved by the removal
        # lifecycle, never by the tick, so the pure
        # takes the caller-supplied link (the N2351
        # frame-input format {"block", "cell":
        # Vector2i} -- a link without a cell reads as
        # null, defensive like N2351) and returns the
        # two calls as data. Two new result symbols:
        # the select call and the remove call. The
        # TODO has no Java behaviour and is not
        # ported; super.onRemoved() is recorded, not
        # modeled; removeModule itself is the
        # assembler's method (UnitAssembler.java:358)
        # and is recorded as a call, not ported.
        self.assertEqual(
            ledger['N2447']['source_symbols'],
            [
                'source_unit_assembler_module_select_remove_state_result.select_call',
                'source_unit_assembler_module_select_remove_state_result.remove_call',
            ],
        )
        for name in ledger['N2447']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_'))
        self.assertEqual(ledger['N2447']['runtime_proof'], '/root/C07UnitAssemblerModuleSelectRemoveRowsProof')
        self.assertEqual(
            ledger['N2447']['tests'],
            [
                'test_c07_unit_assembler_module_select_remove_rows_registration',
                'test_all_c07_unit_assembler_module_select_remove_rows_input_evidence_is_exact',
                'test_unit_assembler_module_select_remove_rows_state',
                'test_reference_graph_and_actual_c07_unit_assembler_module_select_remove_rows',
            ],
        )
        self.assertTrue(ledger['N2447']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #29 (1-based in
        # DEFERRED-after-advances-28.py): the
        # UnitAssemblerModule onRemoved / drawSelect
        # rows entry is REMOVED -- drawSelect() +
        # onRemoved() are live now, so nothing of the
        # entry remains. Net 258 - 1 = 257.
        self.assertFalse(any(entry.startswith('UnitAssemblerModule onRemoved / drawSelect rows (removeModule on remove, UnitAssemblerModule.java:111-115; drawSelect link highlight, UnitAssemblerModule.java:118-123)') for entry in ledger['N2447']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule link / findLink rows (getLink over the flagged unitAssembler builds, UnitAssemblerModule.java:65-69; findLink / removeModule / updateModules, UnitAssemblerModule.java:75-83; moduleFits, UnitAssembler.java:338)') for entry in ledger['N2447']['deferred_exprs']))
        self.assertEqual(len(ledger['N2447']['deferred_exprs']), 257)

    def test_all_c07_unit_assembler_module_select_remove_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2447']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/graphics/Pal.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2447']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_assembler_module_select_remove_rows_state(self):
        unit_assembler_module = UNIT_ASSEMBLER_MODULE_STATE.read_text(encoding='utf-8')
        # The select / remove rows (UnitAssemblerModuleBuild.drawSelect(),
        # UnitAssemblerModule.java:118-123 + onRemoved(), :125-131).
        # drawSelect() is the TODO (`//TODO draw area?`) plus the link
        # highlight (`if(link != null){` + `Drawf.selected(link,
        # Pal.accent);`) -- the Building overload (`public static void
        # selected(Building tile, Color color){`, Drawf.java:330), so the
        # pure records the call as {method drawSelected, target link,
        # color Pal.accent} (the N2396 CALL-record precedent), null when
        # the link is null. onRemoved() is `super.onRemoved();` plus the
        # module unregister (`if(link != null){` +
        # `link.removeModule(this);`) -- the pure records the call as
        # {method removeModule, target link}, null when the link is null,
        # and records the super call without modeling it (the N2425
        # place_super_expr precedent). removeModule is the assembler's
        # method (`public void removeModule(UnitAssemblerModuleBuild
        # build){` / `modules.remove(build);`, UnitAssembler.java:358-360)
        # and is NOT ported -- the call record is the whole port. The
        # link field is `public UnitAssemblerBuild link;`
        # (UnitAssemblerModule.java:72); the pure takes it in the N2351
        # frame-input format {"block", "cell": Vector2i} and a link
        # without a cell reads as null (defensive, the N2351 precedent).
        # The accent color is `accent = Color.valueOf("ffd37f"),`
        # (Pal.java:79). The TODO has no Java behaviour and is not
        # ported. Pure-only: drawSelect is called by the selection UI
        # and onRemoved by the removal lifecycle, never by the tick.
        # Keep each Java expr on ONE comment line (the N2148 lesson: a
        # split line fails this test).
        self.assertIn('static func source_unit_assembler_module_select_remove_state', unit_assembler_module)
        self.assertIn('public void drawSelect(){', unit_assembler_module)
        self.assertIn('//TODO draw area?', unit_assembler_module)
        self.assertIn('if(link != null){', unit_assembler_module)
        self.assertIn('Drawf.selected(link, Pal.accent);', unit_assembler_module)
        self.assertIn('public void onRemoved(){', unit_assembler_module)
        self.assertIn('super.onRemoved();', unit_assembler_module)
        self.assertIn('link.removeModule(this);', unit_assembler_module)
        self.assertIn('public void removeModule(UnitAssemblerModuleBuild build){', unit_assembler_module)
        self.assertIn('modules.remove(build);', unit_assembler_module)
        self.assertIn('public static void selected(Building tile, Color color){', unit_assembler_module)
        self.assertIn('accent = Color.valueOf("ffd37f"),', unit_assembler_module)
        self.assertIn('public UnitAssemblerBuild link;', unit_assembler_module)
        # The documented limits record the select / remove rows as live
        # (the old "onRemoved / drawSelect still defer" text is gone).
        self.assertIn('Select / remove rows live (N2447)', unit_assembler_module)
        self.assertNotIn('onRemoved / drawSelect still defer', unit_assembler_module)
        # The proof's keys drive the select/remove pure (the null-link
        # select, the linked select, the accent color, the null-link
        # remove, the linked remove, the no-cell defensive read).
        proof = UNIT_ASSEMBLER_MODULE_SELECT_REMOVE_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'select_null',
            'select_link',
            'select_accent',
            'remove_null',
            'remove_link',
            'link_no_cell_defensive',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")', proof)
        self.assertTrue(UNIT_ASSEMBLER_MODULE_STATE.exists())
        self.assertTrue(UNIT_ASSEMBLER_MODULE_SELECT_REMOVE_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07UnitAssemblerModuleSelectRemoveRowsProof.gd', UNIT_ASSEMBLER_MODULE_SELECT_REMOVE_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_unit_assembler_module_select_remove_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitAssemblerModuleSelectRemoveRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_ASSEMBLER_MODULE_SELECT_REMOVE_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'select_null',
            'select_link',
            'select_accent',
            'remove_null',
            'remove_link',
            'link_no_cell_defensive',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
