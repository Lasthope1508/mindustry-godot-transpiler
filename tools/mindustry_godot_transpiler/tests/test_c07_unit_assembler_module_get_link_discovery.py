import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_ASSEMBLER_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitAssemblerModuleBuildState.gd'
GET_LINK_DISCOVERY_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleGetLinkDiscoveryProof.gd'
GET_LINK_DISCOVERY_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleGetLinkDiscoveryProof.tscn'
UNIT_ASSEMBLER_JAVA = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
UNIT_ASSEMBLER_MODULE_JAVA = 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java'
FITS_OWNER = 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_fits_state'
LINK_OWNER = 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_get_link_state'


class C07UnitAssemblerModuleGetLinkDiscoveryTests(unittest.TestCase):
    def test_c07_unit_assembler_module_get_link_discovery_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2358']['godot_owner'], LINK_OWNER)
        # getLink (UnitAssemblerModule.java:65-69) scans
        # Vars.indexer.getFlagged(team, BlockFlag.
        # unitAssembler) team-wide and returns the first
        # assembler whose moduleFits holds; moduleFits
        # (UnitAssembler.java:338-351) is geometry only
        # (NO tier term): the spawn from getUnitSpawn()
        # (:332-336, len = tilesize * (areaSize + size)/2f
        # along the ASSEMBLER rotation), the relativeTo
        # direction check (Tile.java:103-113, the float
        # overload, against the MODULE rotation), and the
        # Chebyshev dst against tilesize * areaSize / 2f -
        # tilesize/2f through Mathf.equal (arc
        # Mathf.java:544-546, FLOAT_ROUNDING_ERROR
        # 0.000001f). The port has no team-wide flagged
        # index, so the discovery takes an EXPLICIT frame
        # -input candidate list (the N2301 precedent) and
        # returns the first fit as the N2351 link format
        # {"block", "cell": Vector2i} (cell = assembler
        # origin cell) or null. Ten new result symbols:
        # seven from the fits pure, three from the
        # discovery pure.
        self.assertEqual(
            ledger['N2358']['source_symbols'],
            [
                'source_unit_assembler_module_fits_state_result.fits',
                'source_unit_assembler_module_fits_state_result.spawn',
                'source_unit_assembler_module_fits_state_result.dx',
                'source_unit_assembler_module_fits_state_result.dy',
                'source_unit_assembler_module_fits_state_result.dst',
                'source_unit_assembler_module_fits_state_result.target',
                'source_unit_assembler_module_fits_state_result.relative_to',
                'source_unit_assembler_module_get_link_state_result.link',
                'source_unit_assembler_module_get_link_state_result.candidate_index',
                'source_unit_assembler_module_get_link_state_result.checked',
            ],
        )
        for name in ledger['N2358']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], UNIT_ASSEMBLER_JAVA if name.startswith('source_unit_assembler_module_fits_state') else UNIT_ASSEMBLER_MODULE_JAVA)
                self.assertEqual(symbol['godot_owner'], FITS_OWNER if name.startswith('source_unit_assembler_module_fits_state') else LINK_OWNER)
        self.assertEqual(ledger['N2358']['runtime_proof'], '/root/C07UnitAssemblerModuleGetLinkDiscoveryProof')
        self.assertEqual(
            ledger['N2358']['tests'],
            [
                'test_c07_unit_assembler_module_get_link_discovery_registration',
                'test_all_c07_unit_assembler_module_get_link_discovery_input_evidence_is_exact',
                'test_unit_assembler_module_get_link_discovery_state',
                'test_reference_graph_and_actual_c07_unit_assembler_module_get_link_discovery',
            ],
        )
        self.assertTrue(ledger['N2358']['deferred_exprs'])
        # This slice resolves the getLink discovery entry
        # (brief DEFERRED #317) and adds one new entry
        # for the live team-wide flagged-buildings index
        # fill (frame["link_candidates"] is an explicit
        # frame input until that slice lands); the link /
        # findLink entry is REWRITTEN in place (the
        # discovery + moduleFits are live since N2358,
        # the live flagged fill still waits). DEFERRED
        # goes 326 - 1 + 1 = 326.
        self.assertEqual(len(ledger['N2358']['deferred_exprs']), 326)
        self.assertFalse(any(entry.startswith('UnitAssemblerModule getLink discovery (') for entry in ledger['N2358']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule getLink live flagged-buildings index fill (') and 'frame["link_candidates"]' in entry for entry in ledger['N2358']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule link / findLink rows (') and 'LIVE since N2358' in entry for entry in ledger['N2358']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule handoff-to-intake wiring (') for entry in ledger['N2358']['deferred_exprs']))

    def test_all_c07_unit_assembler_module_get_link_discovery_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2358']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], FITS_OWNER if name.startswith('source_unit_assembler_module_fits_state') else LINK_OWNER)
        slice_sources = {
            ('mindustry-upstream', UNIT_ASSEMBLER_JAVA),
            ('mindustry-upstream', UNIT_ASSEMBLER_MODULE_JAVA),
            ('mindustry-upstream', 'core/src/mindustry/world/Tile.java'),
            ('mindustry-upstream', 'core/src/mindustry/Vars.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Geometry.java'),
            ('arc-upstream', 'arc-core/src/arc/math/Mathf.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2358']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_assembler_module_get_link_discovery_state(self):
        unit_assembler_module = UNIT_ASSEMBLER_MODULE_STATE.read_text(encoding='utf-8')
        # Pure (a) -- moduleFits (UnitAssembler.java:338-351),
        # geometry only (NO tier term): dx/dy from
        # Geometry.d4x/d4y(module rotation) * (other.size/2f
        # + 0.5f) * tilesize; the spawn from getUnitSpawn()
        # (UnitAssembler.java:332-336, len = tilesize *
        # (areaSize + size)/2f along the ASSEMBLER rotation
        # -- the two rotations differ in general); the
        # Tile.relativeTo float check (Tile.java:103-113,
        # through the existing tile_relative_float_state
        # helper -- no invented relativeTo) against the
        # MODULE rotation; the Chebyshev dst against
        # tilesize * areaSize / 2f - tilesize/2f through
        # Mathf.equal (arc Mathf.java:544-546, the
        # FLOAT_ROUNDING_ERROR 0.000001f tolerance). The
        # d4 tables are local arrays indexed through
        # posmod(rotation, 4) (the BeamDrill precedent for
        # Geometry.d4x/d4y, arc Geometry.java:23-24 +
        # :47-52, Mathf.mod(i, 4)). area_size defaults to
        # the UnitAssembler class default 11
        # (UnitAssembler.java:45); the three defs all set
        # 13 (Blocks.java:6531/6546/6561). Keep each Java
        # expr on ONE comment line (the N2148 lesson).
        self.assertIn('public boolean moduleFits(Block other, float ox, float oy, int rotation){', unit_assembler_module)
        self.assertIn('public Vec2 getUnitSpawn(){', unit_assembler_module)
        self.assertIn('float len = tilesize * (areaSize + size)/2f;', unit_assembler_module)
        self.assertIn('if(Tile.relativeTo(ox, oy, spawn.x, spawn.y) != rotation){', unit_assembler_module)
        self.assertIn('return Mathf.equal(dst, tilesize * areaSize / 2f - tilesize/2f);', unit_assembler_module)
        self.assertIn('static func source_unit_assembler_module_fits_state(module: Dictionary, assembler: Dictionary, tilesize: float) -> Dictionary:', unit_assembler_module)
        self.assertIn('source_block_geometry.tile_relative_float_state(module_x, module_y, spawn.x, spawn.y)', unit_assembler_module)
        self.assertIn('var d4x: Array = [1, 0, -1, 0]', unit_assembler_module)
        self.assertIn('var d4y: Array = [0, 1, 0, -1]', unit_assembler_module)
        self.assertIn('int(assembler.get("area_size", 11))', unit_assembler_module)
        self.assertIn('"fits": fits', unit_assembler_module)
        self.assertIn('"spawn": spawn', unit_assembler_module)
        self.assertIn('"dst": dst', unit_assembler_module)
        self.assertIn('"target": target', unit_assembler_module)
        self.assertIn('"relative_to": relative_to', unit_assembler_module)
        # Pure (b) -- getLink discovery
        # (UnitAssemblerModule.java:65-69): `var results =
        # Vars.indexer.getFlagged(team, BlockFlag.
        # unitAssembler).<UnitAssemblerBuild>as();` then
        # `return results.find(b -> b.moduleFits(this, x
        # * tilesize + offset, y * tilesize + offset,
        # rotation));` -- the FIRST fit in list order
        # (Java Seq.find). The port has no team-wide
        # flagged index, so the candidate list is an
        # EXPLICIT frame input (the N2301 precedent); the
        # pure skips non-dict entries and entries without
        # a block/cell (they cannot form the N2351 link
        # format {"block", "cell": Vector2i}) and returns
        # the first fitting candidate as that format, or
        # null with candidate_index -1.
        self.assertIn('public @Nullable UnitAssemblerBuild getLink(Team team, int x, int y, int rotation){', unit_assembler_module)
        self.assertIn('var results = Vars.indexer.getFlagged(team, BlockFlag.unitAssembler).<UnitAssemblerBuild>as();', unit_assembler_module)
        self.assertIn('return results.find(b -> b.moduleFits(this, x * tilesize + offset, y * tilesize + offset, rotation));', unit_assembler_module)
        self.assertIn('static func source_unit_assembler_module_get_link_state(module: Dictionary, candidates: Array, tilesize: float) -> Dictionary:', unit_assembler_module)
        self.assertIn('source_unit_assembler_module_fits_state(module, assembler, tilesize)', unit_assembler_module)
        self.assertIn('"link": link', unit_assembler_module)
        self.assertIn('"candidate_index": candidate_index', unit_assembler_module)
        self.assertIn('"checked": checked', unit_assembler_module)
        # The wiring (N2358): the module tick fills
        # frame["link_candidate"] from the discovery
        # BEFORE the N2248 advance reads it -- but ONLY
        # when frame["link_candidates"] is supplied (the
        # N2352 facing_tiles precedent): a tick with no
        # candidate list keeps the seeded link_candidate,
        # so the N2248/N2351 proofs (which seed
        # link_candidate directly and run the live tick)
        # stay green. The module world position comes from
        # the sprite origin cell through tile_drawx/y_state
        # with the Block offset formula (Block.java:761 /
        # :1429, `offset = ((size + 1) % 2) * tilesize /
        # 2f;` -- 0 for the size-5 module) and the catalog
        # size (the BaseShield precedent); the rotation is
        # the frame rotation stamped just above; the
        # tilesize is source_world_defaults.TILESIZE
        # (Vars.java:135, `public static final int
        # tilesize = 8;`).
        self.assertIn('const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")', unit_assembler_module)
        self.assertIn('if frame.has("link_candidates"):', unit_assembler_module)
        self.assertIn('source_unit_assembler_module_get_link_state(discovery_module, discovery_candidates, source_world_defaults.TILESIZE)', unit_assembler_module)
        self.assertIn('frame["link_candidate"] = discovered.get("link", null)', unit_assembler_module)
        self.assertIn('int(block.properties.get("size", 1))', unit_assembler_module)
        discovery_call = unit_assembler_module.index('source_unit_assembler_module_get_link_state(discovery_module, discovery_candidates, source_world_defaults.TILESIZE)')
        advance_call = unit_assembler_module.index('source_unit_assembler_module_update_tile_advance_state(frame, source_delta, time_scale)')
        rotation_stamp = unit_assembler_module.index('frame["rotation"] = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))')
        self.assertLess(rotation_stamp, discovery_call)
        self.assertLess(discovery_call, advance_call)
        # The documented limits now record the discovery
        # as live (N2358): the advance docstring no longer
        # defers the getLink discovery or the moduleFits
        # evaluation, and the N2248/N2299/N2314/N2348/
        # N2351 rows stay.
        self.assertIn('getLink discovery live (N2358)', unit_assembler_module)
        self.assertIn('updateTile advance live (N2248)', unit_assembler_module)
        self.assertIn('acceptPayload rows live (N2299)', unit_assembler_module)
        self.assertIn('Handoff-gate wiring live (N2314)', unit_assembler_module)
        self.assertIn('Tier stamp live (N2348)', unit_assembler_module)
        self.assertIn('checkTier wiring live (N2351)', unit_assembler_module)
        self.assertNotIn('the getLink discovery that would produce those links still waits for its own slice', unit_assembler_module)
        # The proof's keys drive the fits pure (a side
        # module fits, a rotated assembler fits, the
        # module rotation may differ from the assembler
        # rotation, the class-default area_size 11 fits,
        # a wrong direction fails, a wrong distance fails,
        # a module on the spawn fails the -1 branch), the
        # discovery pure (first fit in list order, no fit
        # is null, malformed entries skip, an empty list
        # is null), and the live tick (a fitting candidate
        # links AND the N2351 wiring adds the tier, a
        # non-fitting candidate leaves null, a tick with
        # no candidate list keeps the seeded candidate).
        proof = GET_LINK_DISCOVERY_PROOF.read_text(encoding='utf-8')
        for key in [
            'fits_side_module',
            'fits_rotated_assembler',
            'fits_module_rotation_differs',
            'fits_default_area_size',
            'no_fit_wrong_direction',
            'no_fit_wrong_distance',
            'no_fit_module_on_spawn',
            'discovery_first_fit',
            'discovery_no_fit_null',
            'discovery_skips_malformed',
            'discovery_empty_list_null',
            'live_tick_discovery_links',
            'live_tick_no_fit_null',
            'live_tick_no_candidates_keeps_seed',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")', proof)
        self.assertIn('preload("res://src/game/SourceUnitFactoryBuildState.gd")', proof)
        self.assertIn('unit_assembler_module_build_state.source_unit_assembler_module_fits_state(', proof)
        self.assertIn('unit_assembler_module_build_state.source_unit_assembler_module_get_link_state(', proof)
        self.assertIn('unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(', proof)
        self.assertTrue(UNIT_ASSEMBLER_MODULE_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = GET_LINK_DISCOVERY_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07UnitAssemblerModuleGetLinkDiscoveryProof.gd', scene)
        self.assertIn('C07UnitAssemblerModuleGetLinkDiscoveryProof', scene)

    def test_reference_graph_and_actual_c07_unit_assembler_module_get_link_discovery(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitAssemblerModuleGetLinkDiscoveryProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_ASSEMBLER_MODULE_GET_LINK_DISCOVERY_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'fits_side_module',
            'fits_rotated_assembler',
            'fits_module_rotation_differs',
            'fits_default_area_size',
            'no_fit_wrong_direction',
            'no_fit_wrong_distance',
            'no_fit_module_on_spawn',
            'discovery_first_fit',
            'discovery_no_fit_null',
            'discovery_skips_malformed',
            'discovery_empty_list_null',
            'live_tick_discovery_links',
            'live_tick_no_fit_null',
            'live_tick_no_candidates_keeps_seed',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
