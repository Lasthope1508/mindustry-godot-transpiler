import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_ASSEMBLER_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitAssemblerModuleBuildState.gd'
FLAGGED_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleFlaggedBuildingsFillProof.gd'
FLAGGED_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleFlaggedBuildingsFillProof.tscn'
UNIT_ASSEMBLER_JAVA = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
UNIT_ASSEMBLER_MODULE_JAVA = 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java'
BLOCK_INDEXER_JAVA = 'core/src/mindustry/ai/BlockIndexer.java'
OWNER = 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_flagged_candidates_state'


class C07UnitAssemblerModuleFlaggedBuildingsFillTests(unittest.TestCase):
    def test_c07_unit_assembler_module_flagged_buildings_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2381']['godot_owner'], OWNER)
        # getLink (UnitAssemblerModule.java:65-69) scans
        # Vars.indexer.getFlagged(team, BlockFlag.
        # unitAssembler) team-wide and returns the first
        # assembler whose moduleFits holds. The N2358
        # discovery evaluated an EXPLICIT frame-input
        # candidate list; this slice fills that list live
        # from the placed buildings: same-team builds
        # whose block carries the unitAssembler flag --
        # the flag is set class-wide by the UnitAssembler
        # constructor (UnitAssembler.java:66, `flags =
        # EnumSet.of(BlockFlag.unitAssembler);`), so all
        # three defs (tank / ship / mech-assembler) carry
        # it and the implementation check IS the flag
        # lookup (no UnitAssembler subclass exists at
        # this pin, and the catalog carries no flags key).
        # Three new result symbols: the filled candidate
        # list, the well-formed entries evaluated, and
        # the descriptors emitted.
        self.assertEqual(
            ledger['N2381']['source_symbols'],
            [
                'source_unit_assembler_module_flagged_candidates_state_result.candidates',
                'source_unit_assembler_module_flagged_candidates_state_result.checked',
                'source_unit_assembler_module_flagged_candidates_state_result.matched',
            ],
        )
        for name in ledger['N2381']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['godot_owner'], OWNER)
        self.assertEqual(symbols['source_unit_assembler_module_flagged_candidates_state_result.candidates']['java_source'], UNIT_ASSEMBLER_MODULE_JAVA)
        self.assertEqual(symbols['source_unit_assembler_module_flagged_candidates_state_result.checked']['java_source'], BLOCK_INDEXER_JAVA)
        self.assertEqual(symbols['source_unit_assembler_module_flagged_candidates_state_result.matched']['java_source'], BLOCK_INDEXER_JAVA)
        self.assertEqual(ledger['N2381']['runtime_proof'], '/root/C07UnitAssemblerModuleFlaggedBuildingsFillProof')
        self.assertEqual(
            ledger['N2381']['tests'],
            [
                'test_c07_unit_assembler_module_flagged_buildings_fill_registration',
                'test_all_c07_unit_assembler_module_flagged_buildings_fill_input_evidence_is_exact',
                'test_unit_assembler_module_flagged_buildings_fill_state',
                'test_reference_graph_and_actual_c07_unit_assembler_module_flagged_buildings_fill',
            ],
        )
        self.assertTrue(ledger['N2381']['deferred_exprs'])
        # This slice resolves the live flagged-buildings
        # index fill entry (DEFERRED-after-advances-19
        # #304, 1-based) and rewrites the link / findLink
        # entry (#305) and the updateTile live fill entry
        # (#307) in place (both now record the fill as
        # LIVE since N2381). No new deferral. DEFERRED
        # goes 311 - 1 = 310.
        self.assertEqual(len(ledger['N2381']['deferred_exprs']), 310)
        self.assertFalse(any(entry.startswith('UnitAssemblerModule getLink live flagged-buildings index fill (') for entry in ledger['N2381']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule link / findLink rows (') and 'LIVE since N2381' in entry for entry in ledger['N2381']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule updateTile live fill (') and 'LIVE since N2381' in entry for entry in ledger['N2381']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule handoff-to-intake wiring (') for entry in ledger['N2381']['deferred_exprs']))

    def test_all_c07_unit_assembler_module_flagged_buildings_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2381']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], OWNER)
        slice_sources = {
            ('mindustry-upstream', UNIT_ASSEMBLER_JAVA),
            ('mindustry-upstream', UNIT_ASSEMBLER_MODULE_JAVA),
            ('mindustry-upstream', BLOCK_INDEXER_JAVA),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('mindustry-upstream', 'core/src/mindustry/Vars.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2381']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_assembler_module_flagged_buildings_fill_state(self):
        unit_assembler_module = UNIT_ASSEMBLER_MODULE_STATE.read_text(encoding='utf-8')
        # The flagged-candidates pure -- getLink
        # (UnitAssemblerModule.java:65-69) scans
        # `var results = Vars.indexer.getFlagged(team,
        # BlockFlag.unitAssembler).<UnitAssemblerBuild>
        # as();` and returns the first fit; getFlagged
        # (BlockIndexer.java:315-317) returns the
        # per-team flag list `flagMap[team.id][type.
        # ordinal()]`, appended on index in placement
        # order (BlockIndexer.java:599, `map[flag.
        # ordinal()].add(tile.build);`). The flag itself
        # is class-wide: the UnitAssembler constructor
        # sets `flags = EnumSet.of(BlockFlag.
        # unitAssembler);` (UnitAssembler.java:66), so
        # the implementation check is the flag lookup.
        # The pure filters the tick-gathered placed
        # buildings to same-team UnitAssembler builds
        # and emits N2358 descriptors ({"block", "cell",
        # "rotation", "size", "area_size", "x", "y"} --
        # x/y are the assembler world coords, cell the
        # origin cell), in input order (the placed_blocks
        # insertion order, matching Java's append-on-
        # index order). Malformed entries skip (the
        # N2358 precedent) and do not count toward
        # checked; area_size defaults to the
        # UnitAssembler class default 11
        # (UnitAssembler.java:45) when absent.
        self.assertIn('var results = Vars.indexer.getFlagged(team, BlockFlag.unitAssembler).<UnitAssemblerBuild>as();', unit_assembler_module)
        self.assertIn('flags = EnumSet.of(BlockFlag.unitAssembler);', unit_assembler_module)
        self.assertIn('public Seq<Building> getFlagged(Team team, BlockFlag type){', unit_assembler_module)
        self.assertIn('return flagMap[team.id][type.ordinal()];', unit_assembler_module)
        self.assertIn('map[flag.ordinal()].add(tile.build);', unit_assembler_module)
        self.assertIn('static func source_unit_assembler_module_flagged_candidates_state(buildings: Array, team_id: int) -> Dictionary:', unit_assembler_module)
        self.assertIn('const SOURCE_UNIT_ASSEMBLER_IMPLEMENTATIONS := ["UnitAssembler"]', unit_assembler_module)
        self.assertIn('int(building_dict.get("area_size", 11))', unit_assembler_module)
        self.assertIn('"candidates": candidates', unit_assembler_module)
        self.assertIn('"checked": checked', unit_assembler_module)
        self.assertIn('"matched": candidates.size()', unit_assembler_module)
        # The tick wiring (N2381, the N2277 placed_blocks
        # scan precedent): the placed buildings are
        # gathered once per tick, and -- before the N2358
        # discovery and the N2370 stamp -- the tick fills
        # frame["link_candidates"] from the pure. The
        # descriptor x/y come from the assembler origin
        # cell through tile_drawx/y_state with the Block
        # offset formula and the Java tilesize 8
        # (source_world_defaults.TILESIZE, Vars.java:135
        # -- NOT the game tile_size 32, the N2364/N2375
        # lesson); rotation comes from the sprite
        # rotation meta; area_size is the def constant 13
        # (all three defs set areaSize = 13,
        # Blocks.java:6529/6544/6559 -- the catalog
        # carries no areaSize key, the N2348 explicit-
        # default precedent).
        self.assertIn('var all_buildings: Array = source_placed_block_state.source_unique_buildings_state(game).get("buildings", [])', unit_assembler_module)
        self.assertIn('const SOURCE_UNIT_ASSEMBLER_AREA_SIZE := 13', unit_assembler_module)
        self.assertIn('source_unit_assembler_module_flagged_candidates_state(flagged_buildings, team_id)', unit_assembler_module)
        self.assertIn('frame["link_candidates"] = flagged.get("candidates", [])', unit_assembler_module)
        self.assertIn('frame["link_candidates_live"] = true', unit_assembler_module)
        self.assertIn('source_block_geometry.tile_drawx_state(flagged_cell.x, source_world_defaults.TILESIZE, flagged_offset)', unit_assembler_module)
        self.assertIn('int(other_sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))', unit_assembler_module)
        flagged_call = unit_assembler_module.index('source_unit_assembler_module_flagged_candidates_state(flagged_buildings, team_id)')
        discovery_call = unit_assembler_module.index('source_unit_assembler_module_get_link_state(discovery_module, discovery_candidates, source_world_defaults.TILESIZE)')
        advance_call = unit_assembler_module.index('source_unit_assembler_module_update_tile_advance_state(frame, source_delta, time_scale)')
        self.assertLess(flagged_call, discovery_call)
        self.assertLess(discovery_call, advance_call)
        # Supplied candidates WIN (the brief's hard rule,
        # the N2352 defensive precedent): the fill runs
        # only when the frame carries NEITHER supplied
        # link_candidates NOR a seeded link_candidate --
        # the N2358 module-three / N2370 / N2351 / N2248
        # proofs seed link_candidate directly with a live
        # assembler placed, so a fill there would let the
        # discovery overwrite the seed. A frame the fill
        # already stamped (link_candidates_live) refreshes
        # every tick, so a later-placed assembler joins
        # the list and a removed one leaves it. An empty
        # scan on a fresh frame stamps nothing (a live
        # module with no assemblers keeps its seeded
        # link_candidate, and a fresh frame reads link
        # null from the advance default); on a live-filled
        # frame it clears the stale list.
        self.assertIn('if (not frame.has("link_candidates") and not frame.has("link_candidate")) or bool(frame.get("link_candidates_live", false)):', unit_assembler_module)
        self.assertIn('if int(flagged.get("matched", 0)) > 0 or bool(frame.get("link_candidates_live", false)):', unit_assembler_module)
        # The documented limits now record the fill as
        # live (N2381), and the N2358/N2370 rows stay.
        self.assertIn('Live flagged-buildings index fill live (N2381)', unit_assembler_module)
        self.assertIn('getLink discovery live (N2358)', unit_assembler_module)
        self.assertIn('Handoff-gate moduleFits wiring live (N2370)', unit_assembler_module)
        self.assertIn('checkTier wiring live (N2351)', unit_assembler_module)
        self.assertIn('updateTile advance live (N2248)', unit_assembler_module)
        self.assertNotIn('the live flagged fill waits for its own slice', unit_assembler_module)
        self.assertNotIn('the live team-wide flagged fill still waits', unit_assembler_module)
        # The proof's keys drive the pure (same-team
        # assemblers only, the 7-key descriptor format,
        # the class-default area_size 11, malformed
        # entries skip, an empty list, input order
        # preserved) and the live tick (no assembler
        # placed leaves the link null, two placed
        # assemblers fill two descriptors, the discovery
        # links the fitting one, a far module links
        # nothing, supplied candidates win, a seeded
        # link_candidate is kept, a later-placed
        # assembler joins on refresh).
        proof = FLAGGED_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'scan_same_team_assemblers_only',
            'scan_descriptor_format',
            'scan_default_area_size',
            'scan_skips_malformed',
            'scan_empty_list',
            'scan_preserves_input_order',
            'live_tick_no_assembler_null',
            'live_tick_fills_two_candidates',
            'live_tick_discovery_links_fit',
            'live_tick_no_fit_null',
            'live_tick_supplied_candidates_win',
            'live_tick_seeded_candidate_kept',
            'live_tick_refresh_adds_assembler',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")', proof)
        self.assertIn('preload("res://src/game/SourceUnitFactoryBuildState.gd")', proof)
        self.assertIn('unit_assembler_module_build_state.source_unit_assembler_module_flagged_candidates_state(', proof)
        self.assertIn('unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(', proof)
        self.assertTrue(UNIT_ASSEMBLER_MODULE_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = FLAGGED_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07UnitAssemblerModuleFlaggedBuildingsFillProof.gd', scene)
        self.assertIn('C07UnitAssemblerModuleFlaggedBuildingsFillProof', scene)

    def test_reference_graph_and_actual_c07_unit_assembler_module_flagged_buildings_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitAssemblerModuleFlaggedBuildingsFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_ASSEMBLER_MODULE_FLAGGED_BUILDINGS_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'scan_same_team_assemblers_only',
            'scan_descriptor_format',
            'scan_default_area_size',
            'scan_skips_malformed',
            'scan_empty_list',
            'scan_preserves_input_order',
            'live_tick_no_assembler_null',
            'live_tick_fills_two_candidates',
            'live_tick_discovery_links_fit',
            'live_tick_no_fit_null',
            'live_tick_supplied_candidates_win',
            'live_tick_seeded_candidate_kept',
            'live_tick_refresh_adds_assembler',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
