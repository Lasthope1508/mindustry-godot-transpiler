import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SEPARATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceSeparatorBuildState.gd'
SEPARATOR_CANDUMP_ITEM_FILTER_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorCanDumpItemFilterProof.gd'
SEPARATOR_CANDUMP_ITEM_FILTER_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorCanDumpItemFilterProof.tscn'


class C07SeparatorCanDumpItemFilterTests(unittest.TestCase):
    def test_c07_separator_candump_item_filter_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2395']['godot_owner'], 'SourceSeparatorBuildState.source_separator_can_dump_state')
        # DEFERRED #300 RESOLVED: the canDump half N2388
        # left behind is live now. canDump is
        # `!consumesItem(item)` (Separator.java:175-177)
        # and consumesItem(item) is Block.itemFilter
        # [item.id] (Block.java:774-776); the filter is
        # built by Block.afterPatch (`itemFilter = new
        # boolean[content.items().size];`, Block.java:
        # 764) plus ConsumeItems.apply (`block.
        # itemFilter[stack.item.id] = true;`, ConsumeItems.
        # java:25-28). The separator def has NO
        # consumeItem (Blocks.java:1231-1246, so
        # consItems is null) -> all-false filter ->
        # canDump always true; the disassembler consumes
        # scrap (`consumeItem(Items.scrap);`, Blocks.java:
        # 1263) -> scrap-only filter -> canDump false
        # for scrap, true for anything else. Two pures:
        # the filter pure builds the def filter from
        # the catalog consumeItem rows over the catalog
        # item_names_by_id (content-id order, index IS
        # the id), and the canDump pure negates the
        # generic Block.consumesItem pure (SourceBlock
        # QueryFilterState.consumes_item_state) -- it
        # does NOT re-model consumesItem. canDump is a
        # GATE -- pure-only, NO tick call site (the
        # N2333/N2336 accept-gate precedent): it is
        # called BY neighbours' dump/offload (Building
        # Comp.java:1001-1016, `if(other.acceptItem(
        # self(), item) && canDump(other, item)){`), and
        # the neighbour fills use defaults this wave.
        # Four new result symbols: the filter array and
        # the consumed ids (filter pure), the verdict
        # and the consumes flag (canDump pure).
        self.assertEqual(
            ledger['N2395']['source_symbols'],
            [
                'source_separator_item_filter_state_result.item_filter',
                'source_separator_item_filter_state_result.consumed_item_ids',
                'source_separator_can_dump_state_result.can_dump',
                'source_separator_can_dump_state_result.consumes_item',
            ],
        )
        owners = {
            'source_separator_item_filter_state_result.item_filter': 'SourceSeparatorBuildState.source_separator_item_filter_state',
            'source_separator_item_filter_state_result.consumed_item_ids': 'SourceSeparatorBuildState.source_separator_item_filter_state',
            'source_separator_can_dump_state_result.can_dump': 'SourceSeparatorBuildState.source_separator_can_dump_state',
            'source_separator_can_dump_state_result.consumes_item': 'SourceSeparatorBuildState.source_separator_can_dump_state',
        }
        java_sources = {
            'source_separator_item_filter_state_result.item_filter': 'core/src/mindustry/world/Block.java',
            'source_separator_item_filter_state_result.consumed_item_ids': 'core/src/mindustry/world/consumers/ConsumeItems.java',
            'source_separator_can_dump_state_result.can_dump': 'core/src/mindustry/world/blocks/production/Separator.java',
            'source_separator_can_dump_state_result.consumes_item': 'core/src/mindustry/world/Block.java',
        }
        for name in ledger['N2395']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], java_sources[name])
                self.assertEqual(symbol['godot_owner'], owners[name])
        self.assertEqual(ledger['N2395']['runtime_proof'], '/root/C07SeparatorCanDumpItemFilterProof')
        self.assertEqual(
            ledger['N2395']['tests'],
            [
                'test_c07_separator_candump_item_filter_registration',
                'test_all_c07_separator_candump_item_filter_input_evidence_is_exact',
                'test_separator_candump_item_filter_state',
                'test_reference_graph_and_actual_c07_separator_candump_item_filter',
            ],
        )
        self.assertTrue(ledger['N2395']['deferred_exprs'])
        # DEFERRED #300 (the merged advances-21 base,
        # 301 entries) is RESOLVED and REMOVED -- the
        # canDump row is live now, so the entry is gone.
        # Net 301 - 1 = 300: no entry added.
        self.assertFalse(any(entry.startswith('Separator canDump row (') for entry in ledger['N2395']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator draw / drawLight / icons / drawPlanRegion rows (') for entry in ledger['N2395']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator disassembler variant (') for entry in ledger['N2395']['deferred_exprs']))
        self.assertEqual(len(ledger['N2395']['deferred_exprs']), 300)

    def test_all_c07_separator_candump_item_filter_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2395']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Separator.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2395']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_separator_candump_item_filter_state(self):
        separator = SEPARATOR_STATE.read_text(encoding='utf-8')
        # The filter rows (Block.afterPatch + ConsumeItems.
        # apply): `itemFilter = new boolean[content.
        # items().size];` (Block.java:764) allocates one
        # boolean per content item, all false, and then
        # every consumer applies (`for(var consume :
        # consumeBuilder){` / `consume.apply(this);`,
        # Block.java:768-770) -- ConsumeItems.apply
        # (ConsumeItems.java:25-28) sets the bits:
        # `for(var stack : items){` / `block.itemFilter
        # [stack.item.id] = true;`. The separator def has
        # NO consumeItem (Blocks.java:1231-1246, so
        # consItems is null), so its filter stays
        # all-false; the disassembler consumes scrap
        # (`consumeItem(Items.scrap);`, Blocks.java:1263
        # -- one stack of 1: `return consumeItem(item,
        # 1);`, Block.java:1167-1168), so only the scrap
        # bit is true. The stacks arrive explicit from
        # the driver (the catalog consumeItem rows, the
        # N2349 precedent); the def id resolves to its
        # rows through the catalog, so an unknown def
        # yields no rows and an all-false filter.
        # The canDump rows (SeparatorBuild.canDump(),
        # Separator.java:175-177): `public boolean
        # canDump(Building to, Item item){` +
        # `return !consumesItem(item);` -- a separator
        # can dump any item it does not consume.
        # consumesItem is Block.itemFilter[item.id]
        # (Block.java:774-776, `public boolean
        # consumesItem(Item item){` + `return itemFilter
        # [item.id];`), computed through the generic
        # Block.consumesItem pure (SourceBlockQueryFilter
        # State.consumes_item_state) -- NOT re-modeled
        # here. The `to` Building parameter is unused by
        # the Java body, so the pure takes only the item
        # (by id + value, the generic pure's signature).
        # Pure-only, the N2333/N2336 accept-gate
        # precedent: canDump is called BY neighbours'
        # dump/offload (BuildingComp.java:1001-1016,
        # `if(other.acceptItem(self(), item) && canDump(
        # other, item)){`), and the neighbour fills use
        # defaults this wave -- the tick never calls
        # canDump, so there is no tick call site here.
        # Keep each Java expr on ONE comment line (the
        # N2148 lesson: a split line fails this test).
        self.assertIn('static func source_separator_item_filter_state', separator)
        self.assertIn('static func source_separator_can_dump_state', separator)
        self.assertIn('public boolean canDump(Building to, Item item){', separator)
        self.assertIn('return !consumesItem(item);', separator)
        self.assertIn('public boolean consumesItem(Item item){', separator)
        self.assertIn('return itemFilter[item.id];', separator)
        self.assertIn('itemFilter = new boolean[content.items().size];', separator)
        self.assertIn('block.itemFilter[stack.item.id] = true;', separator)
        self.assertIn('for(var stack : items){', separator)
        self.assertIn('consumeItem(Items.scrap);', separator)
        self.assertIn('return consumeItem(item, 1);', separator)
        self.assertIn('if(other.acceptItem(self(), item) && canDump(other, item)){', separator)
        # The canDump pure reuses the generic Block.
        # consumesItem pure through a preload -- it does
        # NOT re-model consumesItem.
        self.assertIn('preload("res://src/game/SourceBlockQueryFilterState.gd")', separator)
        self.assertIn('consumes_item_state(item_filter, item_id, item)', separator)
        self.assertTrue((ROOT / 'godot-mindustry/src/game/SourceBlockQueryFilterState.gd').exists())
        # The documented limits record canDump as live
        # since N2395; the old N2388 deferral sentence
        # (the parenthetical "canDump still waits
        # (canDump ..." form) is gone -- the bare phrase
        # survives only inside the historical note that
        # resolves it, so the N2388 test keeps passing.
        self.assertIn('canDump live since N2395', separator)
        self.assertNotIn('canDump still waits (canDump', separator)
        self.assertNotIn('No canDump / draw / drawLight', separator)
        # The proof's keys drive both pures (the
        # separator all-false filter, the disassembler
        # scrap-only filter, canDump always true for a
        # separator, canDump false for scrap and true
        # for other items on a disassembler, the unknown
        # def edge, plus the live placed-block values).
        proof = SEPARATOR_CANDUMP_ITEM_FILTER_PROOF.read_text(encoding='utf-8')
        for key in [
            'filter_separator_all_false',
            'filter_disassembler_scrap_only',
            'candump_separator_always_true',
            'candump_disassembler_scrap_false',
            'filter_unknown_def_edge',
            'candump_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceSeparatorBuildState.gd")', proof)
        self.assertTrue(SEPARATOR_STATE.exists())
        self.assertTrue(SEPARATOR_CANDUMP_ITEM_FILTER_PROOF_SCENE.exists())
        self.assertIn('C07SeparatorCanDumpItemFilterProof.gd', SEPARATOR_CANDUMP_ITEM_FILTER_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_separator_candump_item_filter(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SeparatorCanDumpItemFilterProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SEPARATOR_CAN_DUMP_ITEM_FILTER_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'filter_separator_all_false',
            'filter_disassembler_scrap_only',
            'candump_separator_always_true',
            'candump_disassembler_scrap_false',
            'filter_unknown_def_edge',
            'candump_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
