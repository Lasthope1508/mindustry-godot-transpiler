import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LAUNCH_PAD_STATE = ROOT / 'godot-mindustry/src/game/SourceLaunchPadBuildState.gd'
LAUNCH_PAD_ACCEPT_ITEM_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadAcceptItemProof.gd'
LAUNCH_PAD_ACCEPT_ITEM_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadAcceptItemProof.tscn'


class C07LaunchPadAcceptItemTests(unittest.TestCase):
    def test_c07_launch_pad_accept_item_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2333']['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_accept_item_state')
        # N2172 proved the launch pad's live power read, N2186
        # its shouldConsume gate, N2238 its updateTile advance
        # and N2253 its liquid row -- but nothing answered the
        # intake question: LaunchPadBuild.acceptItem
        # (LaunchPad.java:138-140, `return items.total() <
        # itemCapacity && (acceptMultipleItems || items.total()
        # == 0 || items.first() == item);`) gates every item a
        # conveyor or duct tries to push into the pad, and the
        # port had no pure for it (driver grep acceptItem 0
        # hits). N2333 is the pure gate: total < capacity AND
        # (accept_multiple OR total == 0 OR first == item),
        # with the first item scanned in content-id order over
        # the catalog item_names_by_id (the StackRouter
        # _stack_router_first_item / N2225 take() precedent)
        # and the item compared by name string (the N2225
        # precedent -- Java compares Item references).
        # acceptMultipleItems is a field on LaunchPad itself
        # (LaunchPad.java:40, `public boolean
        # acceptMultipleItems = false;`), NOT on StorageBlock:
        # the launch-pad def sets it true (Blocks.java:6796)
        # and the advanced-launch-pad keeps the false default,
        # so a plain pad takes any item while an advanced pad
        # takes only its first item once it holds one. Both
        # defs carry itemCapacity 100 (Blocks.java:6793/6803;
        # Block class default 10, Block.java:75). There is no
        # driver call site yet -- no intake path calls
        # acceptItem, so the slice is pure + test + proof and
        # the wiring defers. One new result symbol: the gate
        # verdict.
        self.assertEqual(
            ledger['N2333']['source_symbols'],
            [
                'source_launch_pad_accept_item_state_result.accepts',
            ],
        )
        for name in ledger['N2333']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/campaign/LaunchPad.java')
                self.assertEqual(symbol['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_accept_item_state')
        self.assertEqual(ledger['N2333']['runtime_proof'], '/root/C07LaunchPadAcceptItemProof')
        self.assertEqual(
            ledger['N2333']['tests'],
            [
                'test_c07_launch_pad_accept_item_registration',
                'test_all_c07_launch_pad_accept_item_input_evidence_is_exact',
                'test_launch_pad_accept_item_state',
                'test_reference_graph_and_actual_c07_launch_pad_accept_item',
            ],
        )
        self.assertTrue(ledger['N2333']['deferred_exprs'])
        # This slice resolves the LaunchPad acceptItem deferral
        # (#62), so the acceptItem entry is gone from DEFERRED
        # -- and the driver wiring entry takes its place: the
        # pure gate is live but no intake path calls it yet.
        self.assertFalse(any(entry.startswith('LaunchPad acceptItem rows (') for entry in ledger['N2333']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LaunchPad acceptItem driver wiring (') for entry in ledger['N2333']['deferred_exprs']))

    def test_all_c07_launch_pad_accept_item_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2333']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_accept_item_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2333']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_launch_pad_accept_item_state(self):
        launch_pad = LAUNCH_PAD_STATE.read_text(encoding='utf-8')
        # The pure acceptItem gate lives on the launch pad build
        # state: LaunchPadBuild.acceptItem (LaunchPad.java:
        # 138-140) -- total < capacity AND (acceptMultipleItems
        # OR total == 0 OR first == item). Keep each Java expr
        # on ONE comment line (the N2148 shootWarmup lesson: a
        # split line fails this test). acceptMultipleItems is a
        # LaunchPad field (LaunchPad.java:40, default false);
        # the launch-pad def sets it true (Blocks.java:6796)
        # and the advanced-launch-pad keeps the false default.
        # Both defs carry itemCapacity 100 (Blocks.java:
        # 6793/6803); the Block class default is 10
        # (Block.java:75). items.first() scans the item slots
        # in content-id order (ItemModule.java:182-189) and
        # returns the first with a count above zero, null when
        # none is held; the port scans item_order -- the
        # catalog item_names_by_id -- through the shared drill
        # inventory helper (the StackRouter precedent), and
        # compares the item by name string (the N2225
        # precedent -- Java compares Item references). The
        # total is the drill inventory total
        # (SourceDrillInventoryRuntimeState.items_total,
        # reused through the inventory preload, not recomputed
        # -- the Separator precedent).
        self.assertIn('static func source_launch_pad_accept_item_state', launch_pad)
        self.assertIn('static func _launch_pad_first_item', launch_pad)
        self.assertIn('public boolean acceptItem(Building source, Item item){', launch_pad)
        self.assertIn('return items.total() < itemCapacity && (acceptMultipleItems || items.total() == 0 || items.first() == item);', launch_pad)
        self.assertIn('public boolean acceptMultipleItems = false;', launch_pad)
        self.assertIn('acceptMultipleItems = true;', launch_pad)
        self.assertIn('itemCapacity = 100;', launch_pad)
        self.assertIn('public int itemCapacity = 10;', launch_pad)
        self.assertIn('public @Nullable Item first(){', launch_pad)
        self.assertIn('for(int i = 0; i < items.length; i++){', launch_pad)
        self.assertIn('if(items[i] > 0){', launch_pad)
        self.assertIn('return content.item(i);', launch_pad)
        self.assertIn('public int total(){', launch_pad)
        self.assertIn('return total;', launch_pad)
        self.assertIn('public class LaunchPad extends Block{', launch_pad)
        self.assertIn('public class LaunchPadBuild extends Building{', launch_pad)
        self.assertIn('inventory.items_total(items)', launch_pad)
        self.assertIn('inventory.item_count(items', launch_pad)
        self.assertIn('return {"accepts": accepts}', launch_pad)
        # The documented limits now record the acceptItem gate
        # as live (def + field + cite) instead of deferring it.
        self.assertIn('acceptItem gate LIVE (N2333)', launch_pad)
        # There is NO driver call site yet: no intake path calls
        # acceptItem (driver grep acceptItem was 0 hits before
        # this slice), so the pure is live but unwired -- the
        # wiring waits for the frame-items-intake design and
        # defers in the register. A call site would read
        # source_launch_pad_accept_item_state(frame, ...); the
        # definition line reads (frame: Dictionary, ...).
        self.assertNotIn('source_launch_pad_accept_item_state(frame, ', launch_pad)
        # The proof's keys drive the pure gate (accepts when
        # empty, accepts the same item when partial, rejects
        # another item when partial and single, accepts any
        # item when multiple are allowed, rejects when full,
        # and the first-item scan following content-id order)
        # plus the registry keys. The proof preloads the family
        # state file, which must exist, and its scene must
        # point at the proof script.
        self.assertTrue(LAUNCH_PAD_ACCEPT_ITEM_PROOF.is_file())
        self.assertTrue(LAUNCH_PAD_ACCEPT_ITEM_PROOF_SCENE.is_file())
        self.assertIn('C07LaunchPadAcceptItemProof.gd', LAUNCH_PAD_ACCEPT_ITEM_PROOF_SCENE.read_text(encoding='utf-8'))
        proof = LAUNCH_PAD_ACCEPT_ITEM_PROOF.read_text(encoding='utf-8')
        self.assertIn('SourceLaunchPadBuildState.gd', proof)
        self.assertIn('preload("res://src/game/SourceLaunchPadBuildState.gd")', proof)
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue(LAUNCH_PAD_STATE.is_file())
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        for key in [
            'accepts_when_empty',
            'accepts_same_item_when_partial',
            'rejects_other_item_when_partial_single',
            'accepts_any_when_multiple_allowed',
            'rejects_when_full',
            'first_item_uses_content_order',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        scene = LAUNCH_PAD_ACCEPT_ITEM_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('[node name="C07LaunchPadAcceptItemProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_launch_pad_accept_item(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaunchPadAcceptItemProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LAUNCH_PAD_ACCEPT_ITEM_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'accepts_when_empty',
            'accepts_same_item_when_partial',
            'rejects_other_item_when_partial_single',
            'accepts_any_when_multiple_allowed',
            'rejects_when_full',
            'first_item_uses_content_order',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
