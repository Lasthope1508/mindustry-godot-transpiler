import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ITEM_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceItemBridgeBuildState.gd'
ITEM_BRIDGE_CHECK_ACCEPT_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeCheckAcceptRowsProof.gd'
ITEM_BRIDGE_CHECK_ACCEPT_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeCheckAcceptRowsProof.tscn'


class C07ItemBridgeCheckAcceptRowsTests(unittest.TestCase):
    def test_c07_item_bridge_check_accept_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2467']['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_check_accept_state')
        # checkAccept (ItemBridge.java:441-462) is
        # the facing gate acceptItem (:424-426) and
        # acceptLiquid (:434-439) consult for a
        # non-linked source: tile == null or
        # linked(source) accepts outright, a valid
        # link accepts when the link direction
        # differs from the source facing direction
        # (rel != rel2), anything else refuses.
        # The N2225 transport path takes the
        # linked() shortcut, so acceptItem there
        # is the capacity gate only -- but a
        # conveyor feeding a bridge from the side
        # hits the general gate, and NOTHING
        # modeled it until now. N2467 ports it as
        # ONE pure-only pure, the N2435 precedent:
        # the tick never calls checkAccept, so the
        # pure takes caller-supplied inputs (the
        # tile-null verdict, the linked(source)
        # verdict, the linkValid verdict -- the
        # output of the N2197 linkValid pure -- and
        # the two relativeTo verdicts) and returns
        # the verdict as data. One pure, one new
        # result symbol: the accepts verdict.
        self.assertEqual(
            ledger['N2467']['source_symbols'],
            [
                'source_item_bridge_check_accept_state_result.accepts',
            ],
        )
        for name in ledger['N2467']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/distribution/ItemBridge.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceItemBridgeBuildState.source_item_bridge_'))
        self.assertEqual(ledger['N2467']['runtime_proof'], '/root/C07ItemBridgeCheckAcceptRowsProof')
        self.assertEqual(
            ledger['N2467']['tests'],
            [
                'test_c07_item_bridge_check_accept_rows_registration',
                'test_all_c07_item_bridge_check_accept_rows_input_evidence_is_exact',
                'test_item_bridge_check_accept_rows_state',
                'test_reference_graph_and_actual_c07_item_bridge_check_accept_rows',
            ],
        )
        self.assertTrue(ledger['N2467']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #99 (1-based
        # in the merged advances-30 DEFERRED base,
        # 246 entries): "ItemBridge checkAccept
        # facing (checkAccept, ItemBridge.java:
        # 441-463; Edges.getFacingEdge +
        # relativeTo facing comparison,
        # ItemBridge.java:445-458)". Net 246 - 1 =
        # 245. No new entry: the acceptItem /
        # acceptLiquid call sites wait under the
        # existing live-items-intake entry.
        self.assertFalse(any(entry.startswith('ItemBridge checkAccept facing (') for entry in ledger['N2467']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge live items intake (') for entry in ledger['N2467']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge per-def stat rows (') for entry in ledger['N2467']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge config() getter / rebuild rows (') for entry in ledger['N2467']['deferred_exprs']))
        self.assertEqual(len(ledger['N2467']['deferred_exprs']), 245)

    def test_all_c07_item_bridge_check_accept_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2467']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_bridge_check_accept_state_result.accepts': 'SourceItemBridgeBuildState.source_item_bridge_check_accept_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Tile.java',
            'core/src/mindustry/world/Edges.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2467']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_item_bridge_check_accept_rows_state(self):
        item_bridge = ITEM_BRIDGE_STATE.read_text(encoding='utf-8')
        # The check-accept rows (ItemBridgeBuild.
        # checkAccept(), ItemBridge.java:441-462).
        # `if(tile == null || linked(source))
        # return true;` -- a missing tile or a
        # linked source accepts outright.
        # linked(source) (ItemBridge.java:464-466)
        # is `return source instanceof
        # ItemBridgeBuild && linkValid(source.tile,
        # tile) && ((ItemBridgeBuild)source).link
        # == pos();` -- the source is a bridge
        # build, linkValid from the source tile to
        # this tile holds, and the source link
        # points back at this build. `if(linkValid
        # (tile, link)){` -- the two-arg form, so
        # checkDouble is true (ItemBridge.java:
        # 145-146) -- then `int rel = relativeTo
        # (link);` / `var facing = Edges.
        # getFacingEdge(source, this);` / `int rel2
        # = facing == null ? -1 : relativeTo
        # (facing);` / `return rel != rel2;`, else
        # `return false;`. relativeTo here is
        # BuildingComp.relativeTo(Tile) (:526-528),
        # which delegates to relativeTo(int, int)
        # (:545-546) and Tile.absoluteRelativeTo
        # (Tile.java:114) -- NOT Tile.relativeTo
        # (Tile.java:82-84), which returns -1 for
        # the non-adjacent link, and NOT
        # BuildingComp.relativeTo(Building) (:530),
        # the float-position one. Edges.
        # getFacingEdge(Building, Building)
        # (Edges.java:52-55) returns the facing
        # edge of the source multiblock toward
        # this build; a non-multiblock source
        # returns its own tile (:62-63), and the
        # result is null only when the source has
        # no tile. The commented-out incoming loop
        # (:450-456) is NOT ported -- it is
        # commented out in Java, a kept-for-compat
        # bug (issue #9257). checkAccept is called
        # by acceptItem (:424-426) and acceptLiquid
        # (:434-439) with world.tile(link). Pure-
        # only: the tick never calls checkAccept --
        # the intake call sites wait for their own
        # slices. Keep each Java expr on ONE
        # comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_item_bridge_check_accept_state', item_bridge)
        self.assertIn('protected boolean checkAccept(Building source, Tile link){', item_bridge)
        self.assertIn('if(tile == null || linked(source)) return true;', item_bridge)
        self.assertIn('if(linkValid(tile, link)){', item_bridge)
        self.assertIn('int rel = relativeTo(link);', item_bridge)
        self.assertIn('var facing = Edges.getFacingEdge(source, this);', item_bridge)
        self.assertIn('int rel2 = facing == null ? -1 : relativeTo(facing);', item_bridge)
        self.assertIn('return rel != rel2;', item_bridge)
        self.assertIn('protected boolean linked(Building source){', item_bridge)
        self.assertIn('return source instanceof ItemBridgeBuild && linkValid(source.tile, tile) && ((ItemBridgeBuild)source).link == pos();', item_bridge)
        self.assertIn('public boolean acceptItem(Building source, Item item){', item_bridge)
        self.assertIn('return hasItems && team == source.team && items.total() < itemCapacity && checkAccept(source, world.tile(link));', item_bridge)
        self.assertIn('public boolean acceptLiquid(Building source, Liquid liquid){', item_bridge)
        self.assertIn('//this is a bug, but it is kept for compatibility, see: https://github.com/Anuken/Mindustry/issues/9257#issuecomment-1801998747', item_bridge)
        self.assertIn('if(relativeTo(Point2.x(v), Point2.y(v)) == rel2){', item_bridge)
        self.assertIn('public boolean linkValid(Tile tile, Tile other){', item_bridge)
        self.assertIn('return linkValid(tile, other, true);', item_bridge)
        self.assertIn('public byte relativeTo(Tile tile){', item_bridge)
        self.assertIn('return relativeTo(tile.x, tile.y);', item_bridge)
        self.assertIn('public byte relativeTo(int cx, int cy){', item_bridge)
        self.assertIn('return tile.absoluteRelativeTo(cx, cy);', item_bridge)
        self.assertIn('public byte absoluteRelativeTo(int cx, int cy){', item_bridge)
        self.assertIn('if(block.size % 2 == 1){', item_bridge)
        self.assertIn('public static Tile getFacingEdge(Building tile, Building other){', item_bridge)
        self.assertIn('Tile res = getFacingEdge(tile.block, tile.tileX(), tile.tileY(), other.tile);', item_bridge)
        self.assertIn('return res == null ? tile.tile : res;', item_bridge)
        self.assertIn('if(!block.isMultiblock()) return world.tile(tilex, tiley);', item_bridge)
        # The documented limits record the
        # check-accept rows as live.
        self.assertIn('CheckAccept facing rows live (N2467)', item_bridge)
        # The proof's keys drive the pure (the
        # tile-null shortcut, the linked shortcut,
        # the facing mismatch accept, the facing
        # match refuse, the no-facing accept incl.
        # the -1 == -1 boundary, and the invalid-
        # link refuse).
        proof = ITEM_BRIDGE_CHECK_ACCEPT_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'accept_tile_null',
            'accept_linked',
            'accept_facing_mismatch',
            'accept_facing_match',
            'accept_no_facing',
            'accept_link_invalid',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceItemBridgeBuildState.gd")', proof)
        self.assertTrue(ITEM_BRIDGE_STATE.exists())
        self.assertTrue(ITEM_BRIDGE_CHECK_ACCEPT_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07ItemBridgeCheckAcceptRowsProof.gd', ITEM_BRIDGE_CHECK_ACCEPT_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_item_bridge_check_accept_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ItemBridgeCheckAcceptRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ITEM_BRIDGE_CHECK_ACCEPT_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'accept_tile_null',
            'accept_linked',
            'accept_facing_mismatch',
            'accept_facing_match',
            'accept_no_facing',
            'accept_link_invalid',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
