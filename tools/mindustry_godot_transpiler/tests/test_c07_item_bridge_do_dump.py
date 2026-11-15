import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ITEM_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceItemBridgeBuildState.gd'
ITEM_BRIDGE_DO_DUMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeDoDumpProof.gd'
ITEM_BRIDGE_DO_DUMP_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeDoDumpProof.tscn'


class C07ItemBridgeDoDumpTests(unittest.TestCase):
    def test_c07_item_bridge_do_dump_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2288']['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_do_dump_state')
        # N2178 gave the item bridge its live power.status
        # read, N2197 the link frame state, N2188 the
        # shouldConsume gate, N2199 the placement auto-link,
        # N2225 the updateTransport advance -- but the
        # unlinked branch still only zeroed warmup: Java
        # calls doDump() there (ItemBridge.java:335-337),
        # and doDump is dumpAccumulate()
        # (ItemBridge.java:350-353, `dumpAccumulate();`),
        # which adds delta() to dumpAccum and dumps while
        # dumpAccum >= 1f (BuildingComp.java:1053-1061) --
        # possibly MULTIPLE times per frame. N2288 is that
        # doDump (dump(null) through the shared
        # dump_item_state routing, BuildingComp.java:
        # 1072-1113): the hasItems / total / proximity
        # guard, the neighbours-outer / content-items-inner
        # scan from cdump, the acceptItem && canDump gate,
        # handleItem + remove 1 + incrementDump. The
        # LiquidBridge override (dumpLiquid(current, 1f),
        # LiquidBridge.java:29-31) is a different slice,
        # N2287. Five new result symbols: the accumulator
        # after the tick, whether anything dumped, how many
        # dump() attempts fired, the items after the dump,
        # and the cursor after the scan.
        self.assertEqual(
            ledger['N2288']['source_symbols'],
            [
                'source_item_bridge_do_dump_state_result.dump_accum_after',
                'source_item_bridge_do_dump_state_result.dumped',
                'source_item_bridge_do_dump_state_result.dump_attempts',
                'source_item_bridge_do_dump_state_result.items_after',
                'source_item_bridge_do_dump_state_result.cursor_after',
            ],
        )
        for name in ledger['N2288']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_do_dump_state')
        self.assertEqual(ledger['N2288']['runtime_proof'], '/root/C07ItemBridgeDoDumpProof')
        self.assertEqual(
            ledger['N2288']['tests'],
            [
                'test_c07_item_bridge_do_dump_registration',
                'test_all_c07_item_bridge_do_dump_input_evidence_is_exact',
                'test_item_bridge_do_dump_state',
                'test_reference_graph_and_actual_c07_item_bridge_do_dump',
            ],
        )
        self.assertTrue(ledger['N2288']['deferred_exprs'])
        # This slice resolves the doDump entry; the
        # timerCheckMoved snapshot, the live items intake,
        # and the checkAccept facing gate stay deferred, and
        # two new deferrals record what this slice leaves
        # behind (the live neighbour fill and the neighbour
        # write-back).
        self.assertFalse(any(entry.startswith('ItemBridge doDump / dumpAccumulate (') for entry in ledger['N2288']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge timerCheckMoved / wasMoved snapshot (') for entry in ledger['N2288']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge live items intake (') for entry in ledger['N2288']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge checkAccept facing (') for entry in ledger['N2288']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge doDump live neighbour fill (') for entry in ledger['N2288']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge doDump neighbour write-back (') for entry in ledger['N2288']['deferred_exprs']))

    def test_all_c07_item_bridge_do_dump_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2288']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_do_dump_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2288']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_item_bridge_do_dump_state(self):
        item_bridge = ITEM_BRIDGE_STATE.read_text(encoding='utf-8')
        # The pure doDump lives on the item-bridge build
        # state: doDump() (ItemBridge.java:350-353,
        # `dumpAccumulate();`), called only from the
        # unlinked branch of updateTile
        # (ItemBridge.java:335-337, `if(!hadValidLink){
        # doDump(); warmup = 0f; }`), and dumpAccumulate
        # (BuildingComp.java:1048-1061: the null delegate,
        # `dumpAccum += delta();`, the while loop
        # `while(dumpAccum >= 1f){ res |= dump(item);
        # dumpAccum -=1f; }` -- possibly multiple dumps per
        # frame) plus dump() (BuildingComp.java:1064-1066)
        # and dump(Item) (BuildingComp.java:1072-1113: the
        # guard, the cdump scan, neighbours outer /
        # content items inner, the acceptItem && canDump
        # gate, handleItem + remove 1 + incrementDump) and
        # incrementDump (BuildingComp.java:1116-1121,
        # guarded on prox != 0). Keep each Java expr on ONE
        # comment line (the N2148 shootWarmup lesson: a
        # split line fails this test). The LiquidBridge
        # override (dumpLiquid(current, 1f),
        # LiquidBridge.java:29-31) is a different slice,
        # N2287 -- this slice is the base item dump only.
        # delta() is Time.delta * timeScale
        # (BuildingComp.java:1922-1924), NOT edelta(), so
        # the dump cadence ignores efficiency.
        self.assertIn('static func source_item_bridge_do_dump_state', item_bridge)
        self.assertIn('public class ItemBridge extends Block{', item_bridge)
        self.assertIn('public class ItemBridgeBuild extends Building{', item_bridge)
        self.assertIn('public void updateTile(){', item_bridge)
        self.assertIn('Tile other = world.tile(link);', item_bridge)
        self.assertIn('hadValidLink = linkValid(tile, other);', item_bridge)
        self.assertIn('if(!hadValidLink){', item_bridge)
        self.assertIn('doDump();', item_bridge)
        self.assertIn('warmup = 0f;', item_bridge)
        self.assertIn('public void doDump(){', item_bridge)
        self.assertIn('dumpAccumulate();', item_bridge)
        self.assertIn('hasItems = true;', item_bridge)
        self.assertIn('itemCapacity = 10;', item_bridge)
        self.assertIn('public boolean dumpAccumulate(){', item_bridge)
        self.assertIn('return dumpAccumulate(null);', item_bridge)
        self.assertIn('public boolean dumpAccumulate(Item item){', item_bridge)
        self.assertIn('boolean res = false;', item_bridge)
        self.assertIn('dumpAccum += delta();', item_bridge)
        self.assertIn('while(dumpAccum >= 1f){', item_bridge)
        self.assertIn('res |= dump(item);', item_bridge)
        self.assertIn('dumpAccum -=1f;', item_bridge)
        self.assertIn('public boolean dump(){', item_bridge)
        self.assertIn('return dump(null);', item_bridge)
        self.assertIn('public boolean dump(Item todump){', item_bridge)
        self.assertIn('if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;', item_bridge)
        self.assertIn('int dump = this.cdump;', item_bridge)
        self.assertIn('var allItems = content.items();', item_bridge)
        self.assertIn('int itemSize = allItems.size;', item_bridge)
        self.assertIn('if(todump == null){', item_bridge)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', item_bridge)
        self.assertIn('if(!items.has(ii)) continue;', item_bridge)
        self.assertIn('Item item = (Item)itemArray[ii];', item_bridge)
        self.assertIn('if(other.acceptItem(self(), item) && canDump(other, item)){', item_bridge)
        self.assertIn('other.handleItem(self(), item);', item_bridge)
        self.assertIn('items.remove(item, 1);', item_bridge)
        self.assertIn('incrementDump(proximity.size);', item_bridge)
        self.assertIn('public void incrementDump(int prox){', item_bridge)
        self.assertIn('if(prox != 0){', item_bridge)
        self.assertIn('cdump = ((cdump + 1) % prox);', item_bridge)
        self.assertIn('private transient float dumpAccum;', item_bridge)
        self.assertIn('transient int cdump;', item_bridge)
        self.assertIn('return Time.delta * timeScale;', item_bridge)
        self.assertIn('public boolean canDump(Building to, Item item){', item_bridge)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', item_bridge)
        # The dump fields start at their Java defaults in a
        # fresh frame (dumpAccum 0f, cdump 0). The dump runs
        # through the shared helpers -- the accumulator
        # step (dump_accumulate_state, the function the
        # PortBridge source_dump_accumulate_attempt_state
        # delegates to) counts the attempts and the
        # remainder, and each attempt runs dump(null)
        # through the shared dump_item_state routing (the
        # N2276 precedent) -- no local re-implementation,
        # no helper modification.
        self.assertIn('"dump_accum": 0.0', item_bridge)
        self.assertIn('"cdump": 0', item_bridge)
        self.assertIn('preload("res://src/game/SourceBuildingItemDumpState.gd")', item_bridge)
        self.assertIn('dump_accumulate_state(dump_accum, delta)', item_bridge)
        self.assertIn('dump_item_state(true, inventory.items_total(items), neighbour_accepts_item.size(), null, false, content_item_ids, amounts, neighbour_accepts_item, neighbour_can_dump, cursor)', item_bridge)
        # The driver wires the dump into the live tick in
        # the unlinked branch only (after the N2197
        # had_valid_link recompute and the N2225 transport
        # advance, which already zeroed warmup when
        # unlinked and left the store untouched): the
        # neighbour arrays are frame inputs (the N2281 /
        # N2276 precedent, default []), and the dumped
        # store + accumulator + cursor persist to the
        # frame. The linked branch never dumps (the pure
        # gates on had_valid_link).
        self.assertIn('source_item_bridge_do_dump_state(frame, bool(frame.get("had_valid_link", false)), source_delta, time_scale, item_order, dump_neighbour_accepts, dump_neighbour_can_dump)', item_bridge)
        self.assertIn('frame["items"] = dumped["items_after"]', item_bridge)
        self.assertIn('frame["dump_accum"] = dumped["dump_accum_after"]', item_bridge)
        self.assertIn('frame["cdump"] = dumped["cursor_after"]', item_bridge)
        self.assertIn('dump_neighbour_accepts', item_bridge)
        self.assertIn('dump_neighbour_can_dump', item_bridge)
        # The documented limits now record doDump as live
        # and the remaining deferrals (the timerCheckMoved
        # snapshot, the live neighbour fill, the neighbour
        # write-back); the old "doDump defer" text is gone.
        # The N2225 transport advance, the N2188 gate, the
        # N2197 link frame state, and the N2199 auto-link
        # are preserved.
        self.assertIn('doDump live (N2288)', item_bridge)
        self.assertNotIn('doDump (ItemBridge.java:336, 350-353) defer', item_bridge)
        self.assertIn('updateTile transport advance live (N2225)', item_bridge)
        self.assertIn('shouldConsume gate LIVE (N2188)', item_bridge)
        self.assertIn('static func source_item_bridge_update_transport_state', item_bridge)
        self.assertIn('static func source_item_bridge_should_consume_state', item_bridge)
        self.assertIn('static func source_item_bridge_power_status_row_state', item_bridge)
        self.assertIn('static func source_item_bridge_auto_link_placement_state', item_bridge)
        # The proof's keys drive the pure dump (the
        # accumulator firing at 1f, no fire below the
        # threshold, multiple dumps per frame when delta
        # is large, dump only when unlinked, the item
        # leaving the store, and the live tick dumping out
        # of the placed bridge). Static checks: the proof
        # preloads the family state file that exists, and
        # the scene file references the proof script that
        # exists.
        proof = ITEM_BRIDGE_DO_DUMP_PROOF.read_text(encoding='utf-8')
        for key in [
            'dump_fires_when_accum_reaches_one',
            'dump_no_fire_below_threshold',
            'dump_multiple_times_per_frame',
            'dump_only_when_unlinked',
            'dump_removes_item_from_store',
            'live_tick_dumps_item',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceItemBridgeBuildState.gd")', proof)
        self.assertTrue(ITEM_BRIDGE_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = ITEM_BRIDGE_DO_DUMP_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ItemBridgeDoDumpProof.gd', scene)
        self.assertIn('C07ItemBridgeDoDumpProof', scene)

    def test_reference_graph_and_actual_c07_item_bridge_do_dump(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ItemBridgeDoDumpProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ITEM_BRIDGE_DO_DUMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'dump_fires_when_accum_reaches_one',
            'dump_no_fire_below_threshold',
            'dump_multiple_times_per_frame',
            'dump_only_when_unlinked',
            'dump_removes_item_from_store',
            'live_tick_dumps_item',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
