import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_ASSEMBLER_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitAssemblerModuleBuildState.gd'
HANDOFF_FITS_WIRING_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleHandoffFitsWiringProof.gd'
HANDOFF_FITS_WIRING_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleHandoffFitsWiringProof.tscn'
UNIT_ASSEMBLER_MODULE_JAVA = 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java'
UNIT_ASSEMBLER_JAVA = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
FITS_OWNER = 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_fits_state'


class C07UnitAssemblerModuleHandoffFitsWiringTests(unittest.TestCase):
    def test_c07_unit_assembler_module_handoff_fits_wiring_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2370']['godot_owner'], FITS_OWNER)
        # The handoff gate (UnitAssemblerModule.java:138)
        # evaluates moduleFits LIVE in Java
        # (`link.moduleFits(block, x, y, rotation)`), but
        # the port gate read the frame predicate
        # frame["module_fits"] (default false) while the
        # N2358 fits pure was only called inside the
        # discovery pure. N2370 is wiring only (the
        # N2314/N2359 precedent): no new pure, no new
        # symbols -- the tick computes the fits verdict
        # for the CURRENT link before the N2248 advance
        # and stamps frame["module_fits"] with it, so the
        # advance (signature and call unchanged) reads
        # the live verdict. The ledger entry references
        # the reused N2358 fits pure's seven result
        # symbols (shared ownership is allowed -- the
        # registry already carries symbols claimed by
        # more than one slice).
        self.assertEqual(
            ledger['N2370']['source_symbols'],
            [
                'source_unit_assembler_module_fits_state_result.fits',
                'source_unit_assembler_module_fits_state_result.spawn',
                'source_unit_assembler_module_fits_state_result.dx',
                'source_unit_assembler_module_fits_state_result.dy',
                'source_unit_assembler_module_fits_state_result.dst',
                'source_unit_assembler_module_fits_state_result.target',
                'source_unit_assembler_module_fits_state_result.relative_to',
            ],
        )
        for name in ledger['N2370']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], UNIT_ASSEMBLER_JAVA)
                self.assertEqual(symbol['godot_owner'], FITS_OWNER)
        self.assertEqual(ledger['N2370']['runtime_proof'], '/root/C07UnitAssemblerModuleHandoffFitsWiringProof')
        self.assertEqual(
            ledger['N2370']['tests'],
            [
                'test_c07_unit_assembler_module_handoff_fits_wiring_registration',
                'test_all_c07_unit_assembler_module_handoff_fits_wiring_input_evidence_is_exact',
                'test_unit_assembler_module_handoff_fits_wiring_state',
                'test_reference_graph_and_actual_c07_unit_assembler_module_handoff_fits_wiring',
            ],
        )
        self.assertTrue(ledger['N2370']['deferred_exprs'])
        # This slice resolves NO standalone entry: the
        # handoff-gate fits follow-through was never a
        # DEFERRED entry (the N2358 register docstring
        # said so, the N2359 net-0 precedent). It
        # REWRITES the UnitAssemblerModule updateTile
        # live fill entry in place (moduleFits live
        # evaluation is LIVE since N2370; wasOccupied
        # still waits) and adds no new deferral.
        # DEFERRED goes 316 - 0 = 316.
        self.assertEqual(len(ledger['N2370']['deferred_exprs']), 316)
        self.assertFalse(any('moduleFits / wasOccupied live evaluation needs the assembler object' in entry for entry in ledger['N2370']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule updateTile live fill (') and 'LIVE since N2370' in entry and 'wasOccupied live evaluation still needs the assembler object' in entry for entry in ledger['N2370']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule handoff-to-intake wiring (') for entry in ledger['N2370']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule getLink live flagged-buildings index fill (') for entry in ledger['N2370']['deferred_exprs']))

    def test_all_c07_unit_assembler_module_handoff_fits_wiring_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2370']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], FITS_OWNER)
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/units/UnitAssembler.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2370']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_assembler_module_handoff_fits_wiring_state(self):
        unit_assembler_module = UNIT_ASSEMBLER_MODULE_STATE.read_text(encoding='utf-8')
        # The handoff gate (UnitAssemblerModuleBuild.
        # updateTile(), UnitAssemblerModule.java:132-141):
        # the refresh (`if(lastChange != world.
        # tileChanges){` / `lastChange = world.tileChanges;`
        # / `findLink();`) then `if(moveInPayload() &&
        # link != null && link.moduleFits(block, x, y,
        # rotation) && !link.wasOccupied && link.
        # acceptPayload(this, payload) && efficiency > 0){`
        # -- moduleFits is evaluated LIVE in Java, against
        # the link assembler object (UnitAssembler.java:
        # 338-351, geometry only, NO tier term: the spawn
        # from getUnitSpawn() (:332-336), the relativeTo
        # direction check, the Chebyshev dst against
        # tilesize * areaSize / 2f - tilesize/2f through
        # Mathf.equal). Keep each Java expr on ONE comment
        # line (the N2148 lesson).
        self.assertIn('if(lastChange != world.tileChanges){', unit_assembler_module)
        self.assertIn('lastChange = world.tileChanges;', unit_assembler_module)
        self.assertIn('if(moveInPayload() && link != null && link.moduleFits(block, x, y, rotation) && !link.wasOccupied && link.acceptPayload(this, payload) && efficiency > 0){', unit_assembler_module)
        self.assertIn('public boolean moduleFits(Block other, float ox, float oy, int rotation){', unit_assembler_module)
        self.assertIn('public Vec2 getUnitSpawn(){', unit_assembler_module)
        self.assertIn('float len = tilesize * (areaSize + size)/2f;', unit_assembler_module)
        self.assertIn('if(Tile.relativeTo(ox, oy, spawn.x, spawn.y) != rotation){', unit_assembler_module)
        self.assertIn('return Mathf.equal(dst, tilesize * areaSize / 2f - tilesize/2f);', unit_assembler_module)
        self.assertIn('link.yeetPayload(payload);', unit_assembler_module)
        # The wiring (N2370): the tick computes the fits
        # verdict for the CURRENT link BEFORE the N2248
        # advance and stamps frame["module_fits"] with it
        # (the N2314 frame-stamp precedent) -- the advance
        # keeps reading frame["module_fits"], its
        # signature and call site unchanged. The CURRENT
        # link is the link the advance WILL read: the
        # post-discovery link_candidate when the advance
        # refreshes (last_change != tile_changes), else
        # the frame link. The assembler descriptor comes
        # from frame["link_candidates"] by cell (the N2358
        # discovery format -- x/y/size/rotation/area_size,
        # same defaults); a link with no matching
        # descriptor stamps false (the safe no-assembler
        # default). The stamp runs ONLY when frame
        # ["link_candidates"] is supplied (the N2358
        # discovery precedent): a tick with no candidate
        # list keeps the seeded module_fits, so the
        # N2248/N2314 proofs (which seed module_fits true
        # with a block-only link and no candidates) stay
        # green. The module geometry mirrors the discovery
        # computation (sprite origin cell + Block offset +
        # catalog size + the stamped frame rotation).
        self.assertIn('var fits_will_refresh: bool = int(frame.get("last_change", -2)) != int(frame.get("tile_changes", 1))', unit_assembler_module)
        self.assertIn('frame.get("link_candidate", null) if fits_will_refresh else frame.get("link", null)', unit_assembler_module)
        self.assertIn('(fits_candidate as Dictionary).get("cell") == fits_link_cell', unit_assembler_module)
        self.assertIn('source_unit_assembler_module_fits_state(fits_module, fits_assembler, source_world_defaults.TILESIZE)', unit_assembler_module)
        self.assertIn('frame["module_fits"] = bool(fits_verdict.get("fits", false))', unit_assembler_module)
        self.assertIn('frame["module_fits"] = false', unit_assembler_module)
        self.assertIn('"x": float(fits_descriptor.get("x", 0.0))', unit_assembler_module)
        self.assertIn('int(fits_descriptor.get("area_size", 11))', unit_assembler_module)
        rotation_stamp = unit_assembler_module.index('frame["rotation"] = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))')
        discovery_call = unit_assembler_module.index('source_unit_assembler_module_get_link_state(discovery_module, discovery_candidates, source_world_defaults.TILESIZE)')
        fits_call = unit_assembler_module.index('source_unit_assembler_module_fits_state(fits_module, fits_assembler, source_world_defaults.TILESIZE)')
        advance_call = unit_assembler_module.index('source_unit_assembler_module_update_tile_advance_state(frame, source_delta, time_scale)')
        self.assertLess(rotation_stamp, discovery_call)
        self.assertLess(discovery_call, fits_call)
        self.assertLess(fits_call, advance_call)
        # The advance is untouched: it still reads the
        # module_fits predicate (now live-stamped) plus
        # the was_occupied / accept_payload frame inputs.
        self.assertIn('static func source_unit_assembler_module_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float) -> Dictionary', unit_assembler_module)
        self.assertIn('frame.get("module_fits", false)', unit_assembler_module)
        self.assertIn('frame.get("was_occupied", false)', unit_assembler_module)
        self.assertIn('frame.get("accept_payload", false)', unit_assembler_module)
        # The documented limits now record the fits wiring
        # as live (N2370); the N2358 discovery, the N2314
        # acceptPayload wiring, the N2351 checkTier
        # wiring, the N2248 advance and the N2299 rows
        # stay. The advance docstring no longer defers
        # the gate wiring.
        self.assertIn('Handoff-gate moduleFits wiring live (N2370)', unit_assembler_module)
        self.assertIn('getLink discovery live (N2358)', unit_assembler_module)
        self.assertIn('Handoff-gate wiring live (N2314)', unit_assembler_module)
        self.assertIn('checkTier wiring live (N2351)', unit_assembler_module)
        self.assertIn('updateTile advance live (N2248)', unit_assembler_module)
        self.assertIn('acceptPayload rows live (N2299)', unit_assembler_module)
        self.assertNotIn('wiring the pure into the gate waits for its own slice', unit_assembler_module)
        # The proof's keys drive the live tick through the
        # gate: fires when the current link fits (refresh
        # path -- the discovery links the fitting assembler
        # and the stamp reads true), blocked when the
        # current link does not fit (no-refresh path -- a
        # seeded link to a far assembler stamps false),
        # blocked with no candidates and no seed (the
        # false default holds, the stamp never runs), the
        # seeded true value is preserved with no
        # candidates (the N2248/N2314 fixture shape --
        # the handoff fires), and blocked when candidates
        # are supplied but no descriptor matches the link
        # cell (the safe-default false stamp).
        proof = HANDOFF_FITS_WIRING_PROOF.read_text(encoding='utf-8')
        for key in [
            'handoff_fires_when_link_fits',
            'handoff_blocked_when_link_does_not_fit',
            'no_candidates_unseeded_stays_false',
            'no_candidates_seeded_true_preserved',
            'candidates_without_matching_descriptor_stays_false',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")', proof)
        self.assertIn('preload("res://src/game/SourceUnitFactoryBuildState.gd")', proof)
        self.assertIn('unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(', proof)
        self.assertTrue(UNIT_ASSEMBLER_MODULE_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = HANDOFF_FITS_WIRING_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07UnitAssemblerModuleHandoffFitsWiringProof.gd', scene)
        self.assertIn('C07UnitAssemblerModuleHandoffFitsWiringProof', scene)

    def test_reference_graph_and_actual_c07_unit_assembler_module_handoff_fits_wiring(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitAssemblerModuleHandoffFitsWiringProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_ASSEMBLER_MODULE_HANDOFF_FITS_WIRING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'handoff_fires_when_link_fits',
            'handoff_blocked_when_link_does_not_fit',
            'no_candidates_unseeded_stays_false',
            'no_candidates_seeded_true_preserved',
            'candidates_without_matching_descriptor_stays_false',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
