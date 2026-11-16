import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitFactoryBuildState.gd'
UNIT_ASSEMBLER_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitAssemblerModuleBuildState.gd'
CHECK_TIER_WIRING_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerCheckTierWiringProof.gd'
CHECK_TIER_WIRING_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerCheckTierWiringProof.tscn'
UNIT_ASSEMBLER_JAVA = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
UNIT_ASSEMBLER_MODULE_JAVA = 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java'
PURE_OWNER = 'SourceUnitFactoryBuildState.source_unit_assembler_modules_event_state'
HELPER_OWNER = 'SourceUnitFactoryBuildState.source_unit_factory_modules_event_for_cell_state'


class C07UnitAssemblerCheckTierWiringTests(unittest.TestCase):
    def test_c07_unit_assembler_check_tier_wiring_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2351']['godot_owner'], PURE_OWNER)
        # The checkTier pure has been live since N2133
        # (source_unit_factory_assembler_check_tier_state,
        # reading the assembler frame modules list of ints)
        # and the module frame has carried tier since N2348
        # -- but nothing filled the assembler frame modules
        # list live. N2351 is the cross-building wiring:
        # findLink() (UnitAssemblerModule.java:75-83) calls
        # link.removeModule(this) on the old link and
        # link.updateModules(this) on the new one;
        # updateModules (UnitAssembler.java:355-358) is
        # `modules.addUnique(build); checkTier();` and
        # removeModule (:359-362) is `modules.remove(build);
        # checkTier();`. The event pure applies one module
        # event to the tier list and re-derives the tier
        # through the N2133 pure (no duplicated climb
        # logic); the cell helper applies it to a placed
        # assembler's frame through the unit-factory meta
        # key (the battery-setter pattern); the module tick
        # wires both after the N2248 advance, on a link
        # refresh only. Five new result symbols: three from
        # the event pure, two from the cell helper.
        self.assertEqual(
            ledger['N2351']['source_symbols'],
            [
                'source_unit_assembler_modules_event_state_result.modules',
                'source_unit_assembler_modules_event_state_result.current_tier',
                'source_unit_assembler_modules_event_state_result.tier_gap',
                'source_unit_factory_modules_event_for_cell_state_result.applied',
                'source_unit_factory_modules_event_for_cell_state_result.reason',
            ],
        )
        for name in ledger['N2351']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_unit_assembler_modules_event_state_result.modules': UNIT_ASSEMBLER_JAVA,
                    'source_unit_assembler_modules_event_state_result.current_tier': UNIT_ASSEMBLER_JAVA,
                    'source_unit_assembler_modules_event_state_result.tier_gap': UNIT_ASSEMBLER_JAVA,
                    'source_unit_factory_modules_event_for_cell_state_result.applied': UNIT_ASSEMBLER_JAVA,
                    'source_unit_factory_modules_event_for_cell_state_result.reason': UNIT_ASSEMBLER_MODULE_JAVA,
                }[name])
                self.assertEqual(symbol['godot_owner'], PURE_OWNER if name.startswith('source_unit_assembler_modules_event_state') else HELPER_OWNER)
        self.assertEqual(ledger['N2351']['runtime_proof'], '/root/C07UnitAssemblerCheckTierWiringProof')
        self.assertEqual(
            ledger['N2351']['tests'],
            [
                'test_c07_unit_assembler_check_tier_wiring_registration',
                'test_all_c07_unit_assembler_check_tier_wiring_input_evidence_is_exact',
                'test_unit_assembler_check_tier_wiring_state',
                'test_reference_graph_and_actual_c07_unit_assembler_check_tier_wiring',
            ],
        )
        self.assertTrue(ledger['N2351']['deferred_exprs'])
        # This slice resolves DEFERRED entry #325 (the
        # UnitAssembler checkTier tier consumption -- the
        # cross-building wiring) and adds one new entry
        # for the getLink discovery (which must produce the
        # N2351 link frame-input format {"block", "cell":
        # Vector2i}); the link / findLink entry is
        # REWRITTEN in place (the removeModule /
        # updateModules side effects are live since N2351,
        # the discovery + live moduleFits still wait).
        # DEFERRED goes 326 - 1 + 1 = 326.
        self.assertEqual(len(ledger['N2351']['deferred_exprs']), 326)
        self.assertFalse(any(entry.startswith('UnitAssembler checkTier tier consumption (') for entry in ledger['N2351']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule getLink discovery (') and '{"block": <id>, "cell": <Vector2i>}' in entry for entry in ledger['N2351']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule link / findLink rows (') and 'LIVE since N2351' in entry for entry in ledger['N2351']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule handoff-to-intake wiring (') for entry in ledger['N2351']['deferred_exprs']))

    def test_all_c07_unit_assembler_check_tier_wiring_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2351']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], PURE_OWNER if name.startswith('source_unit_assembler_modules_event_state') else HELPER_OWNER)
        slice_sources = {
            ('mindustry-upstream', UNIT_ASSEMBLER_JAVA),
            ('mindustry-upstream', UNIT_ASSEMBLER_MODULE_JAVA),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2351']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_assembler_check_tier_wiring_state(self):
        factory = UNIT_FACTORY_STATE.read_text(encoding='utf-8')
        unit_assembler_module = UNIT_ASSEMBLER_MODULE_STATE.read_text(encoding='utf-8')
        # The event pure (N2351): one module event applied
        # to the assembler modules list -- updateModules
        # (UnitAssembler.java:355-358) `modules.addUnique
        # (build); checkTier();` and removeModule (:359-362)
        # `modules.remove(build); checkTier();` -- with the
        # tier re-derived through the N2133 pure (the climb
        # itself is NOT duplicated: `modules.sort(b ->
        # b.tier());` then the max walk to `currentTier =
        # max;`, stopping at the first gap). Java's addUnique
        # dedupes by BUILD identity (Seq.addUnique / equals,
        # no override on the build), so two distinct tier-1
        # modules both enter: the port's tier list appends
        # on add (it carries no build identity) and removes
        # ONE occurrence on remove (Java removes the one
        # build object). Keep each Java expr on ONE comment
        # line (the N2148 lesson).
        self.assertIn('public Seq<UnitAssemblerModuleBuild> modules = new Seq<>();', factory)
        self.assertIn('public void updateModules(UnitAssemblerModuleBuild build){', factory)
        self.assertIn('modules.addUnique(build);', factory)
        self.assertIn('public void removeModule(UnitAssemblerModuleBuild build){', factory)
        self.assertIn('modules.remove(build);', factory)
        self.assertIn('static func source_unit_assembler_modules_event_state(modules: Array, tier: int, event: String) -> Dictionary:', factory)
        self.assertIn('source_unit_factory_assembler_check_tier_state({"modules": updated})', factory)
        self.assertIn('updated.append(tier)', factory)
        self.assertIn('updated.remove_at(index)', factory)
        self.assertIn('"modules": updated', factory)
        self.assertIn('"current_tier": int(derived.get("current_tier", 0))', factory)
        self.assertIn('"tier_gap": bool(derived.get("tier_gap", false))', factory)
        # The cell helper (N2351, the battery-setter
        # pattern): resolve the assembler sprite through
        # block_sprite_at_cell, read its unit-factory frame
        # through the family meta key, apply the event pure,
        # write modules + current_tier back with set_meta.
        # A cell with no sprite, a non-factory sprite, or a
        # sprite with no frame applies nothing (the N2342
        # setter reasons).
        self.assertIn('static func source_unit_factory_modules_event_for_cell_state(game: Object, cell: Vector2i, tier: int, event: String) -> Dictionary:', factory)
        self.assertIn('game.call("block_sprite_at_cell", cell)', factory)
        self.assertIn('sprite.has_meta(SOURCE_UNIT_FACTORY_BUILDING_META_KEY)', factory)
        self.assertIn('sprite.set_meta(SOURCE_UNIT_FACTORY_BUILDING_META_KEY, frame)', factory)
        self.assertIn('"no_sprite"', factory)
        self.assertIn('"not_unit_factory"', factory)
        self.assertIn('"no_frame"', factory)
        self.assertIn('"live_frame"', factory)
        self.assertIn('frame["modules"] = result.get("modules", [])', factory)
        self.assertIn('frame["current_tier"] = int(result.get("current_tier", 0))', factory)
        # The wiring (N2351): the module tick preloads the
        # unit-factory driver (no cycle -- the factory
        # driver never preloads the module driver), captures
        # the pre-advance link, and after the N2248 advance
        # -- on a link refresh only -- removes this module's
        # tier from the OLD assembler (findLink,
        # UnitAssemblerModule.java:75-83: `if(link != null){`
        # `link.removeModule(this);` then `link = getLink
        # (team, tile.x, tile.y, rotation);` then
        # `link.updateModules(this);`) and adds it to the
        # NEW one. The link frame-input format is the N2351
        # coordinator contract: {"block", "cell": Vector2i},
        # cell is the assembler origin cell; a link without
        # a cell skips that half (the defined pre-discovery
        # behavior -- the 4 old proofs keep block-only links
        # and their behavior is pinned unchanged).
        self.assertIn('const source_unit_factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")', unit_assembler_module)
        self.assertIn('var previous_link: Variant = frame.get("link", null)', unit_assembler_module)
        self.assertIn('if bool(advanced.get("link_refreshed", false)):', unit_assembler_module)
        self.assertIn('previous_link is Dictionary and (previous_link as Dictionary).has("cell")', unit_assembler_module)
        self.assertIn('refreshed_link is Dictionary and (refreshed_link as Dictionary).has("cell")', unit_assembler_module)
        self.assertIn('source_unit_factory_build_state.source_unit_factory_modules_event_for_cell_state(game, (previous_link as Dictionary).get("cell"), module_tier, "remove")', unit_assembler_module)
        self.assertIn('source_unit_factory_build_state.source_unit_factory_modules_event_for_cell_state(game, (refreshed_link as Dictionary).get("cell"), module_tier, "add")', unit_assembler_module)
        # The wiring sits after the advance stamps and
        # before the N2299 module verdict (which reads the
        # post-advance link / payload).
        wiring_call = unit_assembler_module.index('source_unit_factory_modules_event_for_cell_state(game, (previous_link as Dictionary).get("cell"), module_tier, "remove")')
        advance_call = unit_assembler_module.index('source_unit_assembler_module_update_tile_advance_state(frame, source_delta, time_scale)')
        module_call = unit_assembler_module.index('source_unit_assembler_module_accept_payload_state(frame.get("link", null) != null, frame.get("payload", null) != null, bool(link_verdict.get("accepts", false)))')
        self.assertLess(advance_call, wiring_call)
        self.assertLess(wiring_call, module_call)
        # The documented limits now record the wiring as
        # live (N2351): the advance docstring no longer
        # defers the removeModule / updateModules side
        # effects, the tier-stamp note no longer waits for
        # the wiring, and the N2248/N2299/N2314/N2348 rows
        # stay.
        self.assertIn('checkTier wiring live (N2351)', unit_assembler_module)
        self.assertIn('updateTile advance live (N2248)', unit_assembler_module)
        self.assertIn('acceptPayload rows live (N2299)', unit_assembler_module)
        self.assertIn('Handoff-gate wiring live (N2314)', unit_assembler_module)
        self.assertIn('Tier stamp live (N2348)', unit_assembler_module)
        self.assertNotIn('the cross-building wiring feeding stamped module tiers into the assembler frame modules list waits for its own slice', unit_assembler_module)
        # The proof's keys drive the pure (add climbs, a
        # remove opens a gap, duplicate tiers keep both and
        # lose one, a remove of an absent tier is a no-op),
        # the cell helper (a fake-game assembler frame takes
        # the event, a missing sprite and a non-factory
        # sprite skip), and the live tick (two modules link
        # into one assembler, a block-only link skips the
        # wiring, an unlink removes one tier).
        proof = CHECK_TIER_WIRING_PROOF.read_text(encoding='utf-8')
        for key in [
            'event_add_climbs_tier',
            'event_remove_gap_resets_tier',
            'event_add_duplicate_tier_keeps_both',
            'event_remove_one_of_duplicate',
            'event_remove_absent_noop',
            'helper_add_writes_frame',
            'helper_missing_sprite_skips',
            'helper_non_factory_skips',
            'live_tick_two_modules_link',
            'live_tick_block_only_link_skips',
            'live_tick_unlink_removes_one',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceUnitFactoryBuildState.gd")', proof)
        self.assertIn('preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")', proof)
        self.assertIn('unit_factory_build_state.source_unit_assembler_modules_event_state(', proof)
        self.assertIn('unit_factory_build_state.source_unit_factory_modules_event_for_cell_state(', proof)
        self.assertIn('unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(', proof)
        self.assertTrue(UNIT_FACTORY_STATE.is_file())
        self.assertTrue(UNIT_ASSEMBLER_MODULE_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = CHECK_TIER_WIRING_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07UnitAssemblerCheckTierWiringProof.gd', scene)
        self.assertIn('C07UnitAssemblerCheckTierWiringProof', scene)

    def test_reference_graph_and_actual_c07_unit_assembler_check_tier_wiring(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitAssemblerCheckTierWiringProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_ASSEMBLER_CHECK_TIER_WIRING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'event_add_climbs_tier',
            'event_remove_gap_resets_tier',
            'event_add_duplicate_tier_keeps_both',
            'event_remove_one_of_duplicate',
            'event_remove_absent_noop',
            'helper_add_writes_frame',
            'helper_missing_sprite_skips',
            'helper_non_factory_skips',
            'live_tick_two_modules_link',
            'live_tick_block_only_link_skips',
            'live_tick_unlink_removes_one',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
