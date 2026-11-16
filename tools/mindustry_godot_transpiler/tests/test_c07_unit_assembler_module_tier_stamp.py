import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_ASSEMBLER_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitAssemblerModuleBuildState.gd'
UNIT_ASSEMBLER_MODULE_TIER_STAMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleTierStampProof.gd'
UNIT_ASSEMBLER_MODULE_TIER_STAMP_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleTierStampProof.tscn'
UNIT_ASSEMBLER_MODULE_JAVA = 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java'
UNIT_ASSEMBLER_JAVA = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
TIER_OWNER = 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_tier_state'


class C07UnitAssemblerModuleTierStampTests(unittest.TestCase):
    def test_c07_unit_assembler_module_tier_stamp_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2348']['godot_owner'], TIER_OWNER)
        # tier is a class field (`public int tier = 1;`,
        # UnitAssemblerModule.java:22) read by the build
        # accessor tier() (UnitAssemblerModule.java:85-86)
        # and consumed by the assembler-side checkTier()
        # (UnitAssembler.java:364-378, `modules.sort(b ->
        # b.tier());` plus the max-tier walk). The catalog
        # carries no tier key for basic-assembler-module
        # and the def sets no tier (Blocks.java:6566-6573),
        # so the single def keeps the class default: the
        # pure takes it as an explicit parameter (the N2333
        # acceptMultipleItems precedent) and the tick stamps
        # frame["tier"] from it every tick. One new result
        # symbol: the tier.
        self.assertEqual(
            ledger['N2348']['source_symbols'],
            [
                'source_unit_assembler_module_tier_state_result.tier',
            ],
        )
        for name in ledger['N2348']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], UNIT_ASSEMBLER_MODULE_JAVA)
                self.assertEqual(symbol['godot_owner'], TIER_OWNER)
        self.assertEqual(ledger['N2348']['runtime_proof'], '/root/C07UnitAssemblerModuleTierStampProof')
        self.assertEqual(
            ledger['N2348']['tests'],
            [
                'test_c07_unit_assembler_module_tier_stamp_registration',
                'test_all_c07_unit_assembler_module_tier_stamp_input_evidence_is_exact',
                'test_unit_assembler_module_tier_stamp_state',
                'test_reference_graph_and_actual_c07_unit_assembler_module_tier_stamp',
            ],
        )
        self.assertTrue(ledger['N2348']['deferred_exprs'])
        # This slice resolves DEFERRED entry #40 (the
        # UnitAssemblerModule tier rows) and adds one new
        # deferral: the assembler-side checkTier tier
        # consumption -- the checkTier pure is live since
        # N2133 (reading the assembler frame modules list),
        # but nothing fills that list live from the linked
        # modules' stamped tier values yet, so the
        # cross-building wiring waits for its own slice.
        # DEFERRED goes 332 - 1 + 1 = 332. The canPlaceOn
        # rows (#41) belong to the parallel N2345 slice
        # and stay.
        self.assertEqual(len(ledger['N2348']['deferred_exprs']), 332)
        self.assertFalse(any(entry.startswith('UnitAssemblerModule tier rows (') for entry in ledger['N2348']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssembler checkTier tier consumption (') for entry in ledger['N2348']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule canPlaceOn rows (') for entry in ledger['N2348']['deferred_exprs']))

    def test_all_c07_unit_assembler_module_tier_stamp_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2348']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], TIER_OWNER)
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/units/UnitAssembler.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2348']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_assembler_module_tier_stamp_state(self):
        unit_assembler_module = UNIT_ASSEMBLER_MODULE_STATE.read_text(encoding='utf-8')
        # The tier accessor (UnitAssemblerModuleBuild.tier(),
        # UnitAssemblerModule.java:85-86) returns the block's
        # tier field (`public int tier = 1;`,
        # UnitAssemblerModule.java:22), also surfaced in
        # setStats (`stats.add(Stat.moduleTier, tier);`,
        # UnitAssemblerModule.java:33). The assembler
        # consumes it in checkTier()
        # (UnitAssembler.java:364-378): `modules.sort(b ->
        # b.tier());` then the max-tier walk
        # (`if(mod.tier() == max || mod.tier() == max + 1){`
        # / `max = mod.tier();`). moduleFits
        # (UnitAssembler.java:338-351) is geometry only --
        # no tier term -- so the assembler-side consumption
        # is the checkTier sort + walk alone, whose pure is
        # live since N2133; the cross-building wiring
        # feeding stamped module tiers into the assembler
        # frame modules list is deferred.
        # Keep each Java expr on ONE comment line (the N2148
        # shootWarmup lesson: a split line fails this test).
        self.assertIn('public int tier = 1;', unit_assembler_module)
        self.assertIn('public int tier(){', unit_assembler_module)
        self.assertIn('return tier;', unit_assembler_module)
        self.assertIn('stats.add(Stat.moduleTier, tier);', unit_assembler_module)
        self.assertIn('modules.sort(b -> b.tier());', unit_assembler_module)
        self.assertIn('if(mod.tier() == max || mod.tier() == max + 1){', unit_assembler_module)
        self.assertIn('max = mod.tier();', unit_assembler_module)
        # The pure (N2348): the class default arrives as an
        # explicit parameter (the N2333 acceptMultipleItems
        # precedent -- the catalog carries no tier key and
        # the def sets no tier, so the driver passes the
        # class default). block_id is the def the tier
        # belongs to -- a future def that overrides tier
        # passes its own value as tier_default; the pure
        # itself is def-agnostic, so the unused-parameter
        # warning is silenced (the in-file tick precedent).
        self.assertIn('static func source_unit_assembler_module_tier_state(block_id: String, tier_default: int) -> Dictionary', unit_assembler_module)
        self.assertIn('const SOURCE_UNIT_ASSEMBLER_MODULE_TIER_DEFAULT := 1', unit_assembler_module)
        self.assertIn('return {"tier": tier}', unit_assembler_module)
        # The tick stamp (N2348): every ticked module gets
        # frame["tier"] from the pure, in its own block
        # before the power-consumer fold -- tier is a static
        # class field, not consumption-gated, so the stamp
        # runs whether or not the module is enabled (it sits
        # before the enabled advance gate) and overwrites any
        # seeded frame input. The N2345 canPlaceOn stamp
        # lands in its own block (same driver, parallel
        # slice; the coordinator merges manually).
        self.assertIn('source_unit_assembler_module_tier_state(block_id, SOURCE_UNIT_ASSEMBLER_MODULE_TIER_DEFAULT)', unit_assembler_module)
        self.assertIn('frame["tier"] = tier_state["tier"]', unit_assembler_module)
        tier_call = unit_assembler_module.index('source_unit_assembler_module_tier_state(block_id, SOURCE_UNIT_ASSEMBLER_MODULE_TIER_DEFAULT)')
        advance_gate = unit_assembler_module.index('\t\tif bool(frame.get("enabled", true)):')
        advance_call = unit_assembler_module.index('source_unit_assembler_module_update_tile_advance_state(frame, source_delta, time_scale)')
        self.assertLess(tier_call, advance_gate)
        self.assertLess(tier_call, advance_call)
        # The documented limits now record the tier stamp as
        # live (N2348) and drop tier from the missing rows;
        # the N2299 acceptPayload rows, the N2314 handoff
        # wiring and the N2248 advance stay.
        self.assertIn('Tier stamp live (N2348)', unit_assembler_module)
        self.assertIn('No link/canPlaceOn/draw/onRemoved rows', unit_assembler_module)
        self.assertIn('Handoff-gate wiring live (N2314)', unit_assembler_module)
        self.assertIn('acceptPayload rows live (N2299)', unit_assembler_module)
        self.assertIn('updateTile advance live (N2248)', unit_assembler_module)
        self.assertIn('static func source_unit_assembler_module_power_status_row_state', unit_assembler_module)
        # The proof's keys drive the pure + the live tick:
        # the pure returns the class default for the single
        # def, the pure honors an explicit non-default
        # value (the param is the source of the value, not
        # a hardcoded 1), the live tick stamps frame["tier"]
        # == 1, the stamp overwrites a stale seed, and the
        # stamp survives a disabled module (static class
        # field, not consumption-gated).
        proof = UNIT_ASSEMBLER_MODULE_TIER_STAMP_PROOF.read_text(encoding='utf-8')
        for key in [
            'pure_returns_class_default_tier',
            'pure_honors_explicit_default',
            'live_tick_stamps_tier',
            'tier_stamp_overwrites_stale_seed',
            'tier_stamp_survives_disabled',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")', proof)
        self.assertIn('unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(', proof)
        self.assertIn('unit_assembler_module_build_state.source_unit_assembler_module_tier_state(', proof)
        self.assertTrue(UNIT_ASSEMBLER_MODULE_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = UNIT_ASSEMBLER_MODULE_TIER_STAMP_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07UnitAssemblerModuleTierStampProof.gd', scene)
        self.assertIn('C07UnitAssemblerModuleTierStampProof', scene)

    def test_reference_graph_and_actual_c07_unit_assembler_module_tier_stamp(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitAssemblerModuleTierStampProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_ASSEMBLER_MODULE_TIER_STAMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'pure_returns_class_default_tier',
            'pure_honors_explicit_default',
            'live_tick_stamps_tier',
            'tier_stamp_overwrites_stale_seed',
            'tier_stamp_survives_disabled',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
