import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_CARGO_LOADER_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitCargoLoaderBuildState.gd'
UNIT_CARGO_LOADER_DRAW_PLACE_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderDrawPlaceRowsProof.gd'
UNIT_CARGO_LOADER_DRAW_PLACE_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderDrawPlaceRowsProof.tscn'


class C07UnitCargoLoaderDrawPlaceRowsTests(unittest.TestCase):
    def test_c07_unit_cargo_loader_draw_place_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2445']['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_draw_place_state')
        # The UnitCargoLoader tick is live (N2234 advance +
        # N2249 liquid row + N2322 canCreate + N2330
        # canPlaceOn) and draw() is live (N2415) and the
        # bar rows are live (N2417), but NOTHING modeled
        # drawPlace(): super.drawPlace(x, y, rotation,
        # valid) + the bar.cargounitcap warning text when
        # !Units.canCreate(Vars.player.team(), unitType)
        # (UnitCargoLoader.java:70-75). N2445 ports
        # drawPlace() as ONE pure-only draw-place pure,
        # the N2396 MassDriver / N2439 LightBlock
        # pattern: drawPlace is never called by the tick,
        # so the pure takes caller-supplied inputs (the
        # placement tile x/y + valid + the canCreate
        # verdict, the N2435 caller-supplied precedent --
        # Units.canCreate is a team/indexer query) and
        # returns the draw call as data. One new result
        # symbol: the warning_call (null when can_create,
        # else the drawPlaceText CALL record, the N2396
        # CALL precedent). The super call is recorded in
        # the docstring, NOT a symbol (the N2439
        # precedent). canPlaceOn is NOT ported again --
        # it is live since N2330.
        self.assertEqual(
            ledger['N2445']['source_symbols'],
            [
                'source_unit_cargo_loader_draw_place_state_result.warning_call',
            ],
        )
        for name in ledger['N2445']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/UnitCargoLoader.java')
                self.assertEqual(symbol['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_draw_place_state')
        self.assertEqual(ledger['N2445']['runtime_proof'], '/root/C07UnitCargoLoaderDrawPlaceRowsProof')
        self.assertEqual(
            ledger['N2445']['tests'],
            [
                'test_c07_unit_cargo_loader_draw_place_rows_registration',
                'test_all_c07_unit_cargo_loader_draw_place_rows_input_evidence_is_exact',
                'test_unit_cargo_loader_draw_place_rows_state',
                'test_reference_graph_and_actual_c07_unit_cargo_loader_draw_place_rows',
            ],
        )
        self.assertTrue(ledger['N2445']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #241 (1-based in
        # DEFERRED-after-advances-27.py): the
        # UnitCargoLoader drawPlace rows entry is REMOVED
        # -- drawPlace() is live now, so nothing of the
        # entry remains. No new entry is added: the pure
        # is pure-only (no tick wiring to defer), and
        # the placement call site waits under the
        # existing canPlaceOn live-call-site entry.
        # Net 266 - 1 = 265.
        self.assertFalse(any(entry.startswith('UnitCargoLoader drawPlace rows (drawPlace cap warning text, UnitCargoLoader.java:70-75)') for entry in ledger['N2445']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader read/write rows (readUnitId, write unit id, UnitCargoLoader.java:174-188)') for entry in ledger['N2445']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader canPlaceOn live placement call site (UnitCargoLoader.java:65-68)') for entry in ledger['N2445']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader canCreate live unit-count source (team.data().countType(manifold) live query, Teams.java:442-444') for entry in ledger['N2445']['deferred_exprs']))
        self.assertEqual(len(ledger['N2445']['deferred_exprs']), 265)

    def test_all_c07_unit_cargo_loader_draw_place_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2445']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_draw_place_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/units/UnitCargoLoader.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/entities/Units.java',
            'core/assets/bundles/bundle.properties',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2445']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_cargo_loader_draw_place_rows_state(self):
        unit_cargo_loader = UNIT_CARGO_LOADER_STATE.read_text(encoding='utf-8')
        # The drawPlace rows (UnitCargoLoader.drawPlace(),
        # UnitCargoLoader.java:70-75): super.drawPlace(x,
        # y, rotation, valid) (:71) + the cap warning
        # (`if(!Units.canCreate(Vars.player.team(),
        # unitType)){`, :73, then `drawPlaceText(
        # Core.bundle.get("bar.cargounitcap"), x, y,
        # valid);`, :74). The super call is recorded in
        # the docstring, NOT a result symbol (the N2439
        # precedent -- Block.drawPlace is
        # drawPotentialLinks + drawOverlay, Block.java:
        # 491-493). The warning fires only when the
        # player's team cannot create the unit type
        # (`public static boolean canCreate(Team team,
        # UnitType type){` with `return !type.useUnitCap
        # || (team.data().countType(type) < getCap(team)
        # && !type.isBanned());`, Units.java:115-117);
        # Units.canCreate is a team/indexer query the
        # pure never runs -- it arrives caller-supplied
        # as can_create (the N2435 precedent), like the
        # N2322 canCreate verdict the N2330 canPlaceOn
        # pure composes. canPlaceOn
        # (UnitCargoLoader.java:66-68) is live since
        # N2330 and is NOT ported again here. The unit
        # type is `public UnitType unitType =
        # UnitTypes.manifold;` (UnitCargoLoader.java:24,
        # the def does NOT override it). drawPlaceText
        # is the Block 4-arg overload (`public float
        # drawPlaceText(String text, int x, int y,
        # boolean valid){`, Block.java:531, delegating
        # with `return drawPlaceText(text, x, y, valid ?
        # Pal.accent : Pal.remove, true);`, Block.java:
        # 532 -- the color is Pal.accent when valid,
        # Pal.remove otherwise, and the line always
        # draws). x/y are TILE coords: the 5-arg
        # overload converts them inside (`float dx = x *
        # tilesize + offset, dy = y * tilesize + offset
        # + size * tilesize / 2f + 3;`, Block.java:546),
        # so the record carries the tile coords as
        # passed. The bundle key is exact
        # (`bar.cargounitcap = Cargo Unit Cap Reached`,
        # bundle.properties:1278). Pure-only: the tick
        # never calls drawPlace -- drawPlace is called
        # by the placement UI, and the placement call
        # site waits for a placement slice. Keep each
        # Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_unit_cargo_loader_draw_place_state', unit_cargo_loader)
        self.assertIn('public void drawPlace(int x, int y, int rotation, boolean valid){', unit_cargo_loader)
        self.assertIn('super.drawPlace(x, y, rotation, valid);', unit_cargo_loader)
        self.assertIn('if(!Units.canCreate(Vars.player.team(), unitType)){', unit_cargo_loader)
        self.assertIn('drawPlaceText(Core.bundle.get("bar.cargounitcap"), x, y, valid);', unit_cargo_loader)
        self.assertIn('public float drawPlaceText(String text, int x, int y, boolean valid){', unit_cargo_loader)
        self.assertIn('return drawPlaceText(text, x, y, valid ? Pal.accent : Pal.remove, true);', unit_cargo_loader)
        self.assertIn('float dx = x * tilesize + offset, dy = y * tilesize + offset + size * tilesize / 2f + 3;', unit_cargo_loader)
        self.assertIn('public static boolean canCreate(Team team, UnitType type){', unit_cargo_loader)
        self.assertIn('return !type.useUnitCap || (team.data().countType(type) < getCap(team) && !type.isBanned());', unit_cargo_loader)
        self.assertIn('public UnitType unitType = UnitTypes.manifold;', unit_cargo_loader)
        self.assertIn('bar.cargounitcap = Cargo Unit Cap Reached', unit_cargo_loader)
        # The documented limits record the draw-place rows
        # as live (the draw rows stay live since N2415).
        self.assertIn('DrawPlace rows live (N2445)', unit_cargo_loader)
        self.assertIn('Draw rows live (N2415)', unit_cargo_loader)
        # The proof's keys drive the draw-place pure (the
        # null warning when the team can create, the
        # warning call when capped, the exact bundle
        # text, the tile x/y passthrough, and the valid
        # flag recorded both ways). There are no
        # canPlaceOn keys: that gate is live since N2330.
        proof = UNIT_CARGO_LOADER_DRAW_PLACE_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_place_warning_null',
            'draw_place_warning_present',
            'draw_place_warning_text',
            'draw_place_warning_xy',
            'draw_place_warning_valid_true',
            'draw_place_warning_valid_false',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the N2185
        # lesson: check the preload target exists, and the
        # scene file exists and points at the proof script).
        self.assertIn('preload("res://src/game/SourceUnitCargoLoaderBuildState.gd")', proof)
        self.assertTrue(UNIT_CARGO_LOADER_STATE.exists())
        self.assertTrue(UNIT_CARGO_LOADER_DRAW_PLACE_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07UnitCargoLoaderDrawPlaceRowsProof.gd', UNIT_CARGO_LOADER_DRAW_PLACE_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_unit_cargo_loader_draw_place_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitCargoLoaderDrawPlaceRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_CARGO_LOADER_DRAW_PLACE_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_place_warning_null',
            'draw_place_warning_present',
            'draw_place_warning_text',
            'draw_place_warning_xy',
            'draw_place_warning_valid_true',
            'draw_place_warning_valid_false',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
