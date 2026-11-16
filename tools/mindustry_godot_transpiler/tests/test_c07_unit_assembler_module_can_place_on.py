import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_ASSEMBLER_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitAssemblerModuleBuildState.gd'
UNIT_ASSEMBLER_MODULE_CAN_PLACE_ON_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleCanPlaceOnProof.gd'
UNIT_ASSEMBLER_MODULE_CAN_PLACE_ON_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleCanPlaceOnProof.tscn'


class C07UnitAssemblerModuleCanPlaceOnTests(unittest.TestCase):
    def test_c07_unit_assembler_module_can_place_on_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2345']['godot_owner'], 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_can_place_on_state')
        # UnitAssemblerModule overrides canPlaceOn (UnitAssemblerModule.java:48-51,
        # `return getLink(team, tile.x, tile.y, rotation) != null;` at :50):
        # a module can be placed only where a fitting assembler is
        # linked. The frame already carries that getLink verdict as
        # frame["link"] (the N2248 advance re-discovers it with
        # findLink on tileChanges), so the N2345 pure reads the
        # verdict the frame carries -- the N2330 UCL canPlaceOn
        # precedent -- and returns {can_place_on}: true iff
        # frame["link"] != null. canPlaceOn is a placement gate,
        # NOT tick wiring: the driver never calls it each tick
        # (grep-verified: only the Documented limits mention
        # it), so this slice adds no tick call. One new result
        # symbol. Cite correction: the brief and the resolved
        # DEFERRED entry cited :53-55, but the method is
        # :48-51 at this pin (signature :49, return :50);
        # :53-55 is inside drawPlanRegion.
        self.assertEqual(
            ledger['N2345']['source_symbols'],
            [
                'source_unit_assembler_module_can_place_on_state_result.can_place_on',
            ],
        )
        for name in ledger['N2345']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java')
                self.assertEqual(symbol['godot_owner'], 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_can_place_on_state')
        self.assertEqual(ledger['N2345']['runtime_proof'], '/root/C07UnitAssemblerModuleCanPlaceOnProof')
        self.assertEqual(
            ledger['N2345']['tests'],
            [
                'test_c07_unit_assembler_module_can_place_on_registration',
                'test_all_c07_unit_assembler_module_can_place_on_input_evidence_is_exact',
                'test_unit_assembler_module_can_place_on_state',
                'test_reference_graph_and_actual_c07_unit_assembler_module_can_place_on',
            ],
        )
        self.assertTrue(ledger['N2345']['deferred_exprs'])
        # This slice resolves the canPlaceOn placement-gate
        # entry, so it is gone from DEFERRED -- and one new
        # entry takes its place: the live placement call site
        # (no placement path calls the pure yet; the
        # valid-place hook defaults to the Block default true
        # without one). The tier rows stay deferred (N2348,
        # same driver, running in parallel -- this slice does
        # not touch them), as do the draw / onRemoved rows.
        self.assertFalse(any(entry.startswith('UnitAssemblerModule canPlaceOn rows (') for entry in ledger['N2345']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule canPlaceOn live placement call site (') for entry in ledger['N2345']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule tier rows (') for entry in ledger['N2345']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule draw / drawPlace / drawPlanRegion / icons rows (') for entry in ledger['N2345']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule onRemoved / drawSelect rows (') for entry in ledger['N2345']['deferred_exprs']))

    def test_all_c07_unit_assembler_module_can_place_on_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2345']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_can_place_on_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2345']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_assembler_module_can_place_on_state(self):
        unit_assembler_module = UNIT_ASSEMBLER_MODULE_STATE.read_text(encoding='utf-8')
        # The canPlaceOn pure (N2345) reads the getLink verdict
        # the frame already carries: Java's override is
        # `return getLink(team, tile.x, tile.y, rotation) != null;`
        # (UnitAssemblerModule.java:48-51, the return is :50)
        # and getLink finds the first flagged assembler whose
        # moduleFits holds (UnitAssemblerModule.java:65-69).
        # The build field is `public UnitAssemblerBuild link;`
        # (UnitAssemblerModule.java:72), refreshed by findLink
        # (UnitAssemblerModule.java:75-83, the discovery is
        # :79) on tileChanges -- the N2248 advance ports that
        # refresh, so the frame link IS the getLink verdict.
        # The pure takes the frame only: Java receives tile /
        # team / rotation, but the port has no live building
        # query, so the verdict arrives through the frame link
        # (the N2330 precedent). No link stamped (absent or
        # null) means CANNOT place -- the Java-exact default:
        # the link field defaults null (:72, no initializer;
        # _initial_frame binds null) and getLink returns null
        # when no assembler fits. This is RESTRICTIVE, unlike
        # the N2330 permissive canCreate default.
        self.assertIn('static func source_unit_assembler_module_can_place_on_state', unit_assembler_module)
        self.assertIn('public boolean canPlaceOn(Tile tile, Team team, int rotation){', unit_assembler_module)
        self.assertIn('return getLink(team, tile.x, tile.y, rotation) != null;', unit_assembler_module)
        self.assertIn('public @Nullable UnitAssemblerBuild getLink(Team team, int x, int y, int rotation){', unit_assembler_module)
        self.assertIn('return results.find(b -> b.moduleFits(this, x * tilesize + offset, y * tilesize + offset, rotation));', unit_assembler_module)
        self.assertIn('public UnitAssemblerBuild link;', unit_assembler_module)
        self.assertIn('link = getLink(team, tile.x, tile.y, rotation);', unit_assembler_module)
        self.assertIn('public class UnitAssemblerModule extends PayloadBlock{', unit_assembler_module)
        # The pure reads the frame link only -- it does not
        # re-run the discovery and does not read link_candidate
        # (the candidate only becomes the link on refresh).
        self.assertIn('{"can_place_on": frame.get("link", null) != null}', unit_assembler_module)
        # canPlaceOn is a placement gate, NOT tick wiring: the
        # only call-shaped occurrence of the pure in the
        # driver is its own definition -- no tick call site,
        # no placement hook wiring (the live call site waits
        # for its own slice).
        self.assertEqual(unit_assembler_module.count('source_unit_assembler_module_can_place_on_state('), 1)
        # The documented limits now record canPlaceOn as live
        # (N2345); the link discovery / tier / draw / onRemoved
        # rows still defer, and the N2248 updateTile advance,
        # the N2299 acceptPayload gates and the N2314
        # handoff-gate wiring stay live.
        self.assertIn('canPlaceOn live (N2345)', unit_assembler_module)
        self.assertIn('updateTile advance live (N2248)', unit_assembler_module)
        self.assertIn('acceptPayload rows live (N2299)', unit_assembler_module)
        self.assertIn('Handoff-gate wiring live (N2314)', unit_assembler_module)
        self.assertIn('static func source_unit_assembler_module_update_tile_advance_state', unit_assembler_module)
        self.assertIn('static func source_unit_assembler_module_accept_payload_state', unit_assembler_module)
        self.assertIn('static func source_unit_assembler_module_power_status_row_state', unit_assembler_module)
        # The proof's keys drive the pure (linked, unlinked,
        # no link input, and the post-refresh link the N2248
        # advance stamps). There is NO live-tick key:
        # canPlaceOn is a placement gate, not tick wiring, so
        # no tick reports a verdict.
        proof = UNIT_ASSEMBLER_MODULE_CAN_PLACE_ON_PROOF.read_text(encoding='utf-8')
        for key in [
            'can_place_on_when_linked',
            'cannot_place_on_when_unlinked',
            'cannot_place_on_without_link_input',
            'can_place_on_after_link_refresh',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")', proof)
        self.assertTrue(UNIT_ASSEMBLER_MODULE_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = UNIT_ASSEMBLER_MODULE_CAN_PLACE_ON_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07UnitAssemblerModuleCanPlaceOnProof.gd', scene)
        self.assertIn('C07UnitAssemblerModuleCanPlaceOnProof', scene)

    def test_reference_graph_and_actual_c07_unit_assembler_module_can_place_on(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitAssemblerModuleCanPlaceOnProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_ASSEMBLER_MODULE_CAN_PLACE_ON_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'can_place_on_when_linked',
            'cannot_place_on_when_unlinked',
            'cannot_place_on_without_link_input',
            'can_place_on_after_link_refresh',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
