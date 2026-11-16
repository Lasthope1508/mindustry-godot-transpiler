import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
STACK_ROUTER_STATE = ROOT / 'godot-mindustry/src/game/SourceStackRouterBuildState.gd'
STACK_ROUTER_ACCEPT_ITEM_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackRouterAcceptItemProof.gd'
STACK_ROUTER_ACCEPT_ITEM_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackRouterAcceptItemProof.tscn'


class C07StackRouterAcceptItemTests(unittest.TestCase):
    def test_c07_stack_router_accept_item_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2332']['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_accept_item_state')
        # N2240 ported the StackRouter updateTile advance and
        # N2324 the target() live proximity selection -- but
        # the router's own intake gate was still unported: the
        # StackRouter acceptItem OVERRIDE (StackRouter.java:
        # 89-93), a 4-term gate -- !unloading + (current ==
        # null || item == current) + items.total() <
        # itemCapacity + the facing term (Edges.getFacingEdge
        # (source.tile, tile).relativeTo(tile) == rotation).
        # The parent DuctRouter acceptItem (DuctRouter.java:
        # 160-164) is STRICTER -- current == null &&
        # items.total() == 0 && the same facing term -- so the
        # port follows the override, not the parent: the
        # override takes the current item into a partially
        # filled router, the parent only into an empty one.
        # The facing value arrives precomputed (facing_rel,
        # the N2324 precedent: rel precomputed per neighbour --
        # the port has no live tile geometry to run
        # Edges.getFacingEdge / Tile.relativeTo itself), and
        # items compare by name string (the N2225 precedent --
        # Java compares Item references). One new result
        # symbol: the accepts verdict.
        self.assertEqual(
            ledger['N2332']['source_symbols'],
            [
                'source_stack_router_accept_item_state_result.accepts',
            ],
        )
        self.assertEqual(symbols['source_stack_router_accept_item_state_result.accepts']['java_source'], 'core/src/mindustry/world/blocks/distribution/StackRouter.java')
        for name in ledger['N2332']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_accept_item_state')
        self.assertEqual(ledger['N2332']['runtime_proof'], '/root/C07StackRouterAcceptItemProof')
        self.assertEqual(
            ledger['N2332']['tests'],
            [
                'test_c07_stack_router_accept_item_registration',
                'test_all_c07_stack_router_accept_item_input_evidence_is_exact',
                'test_stack_router_accept_item_state',
                'test_reference_graph_and_actual_c07_stack_router_accept_item',
            ],
        )
        self.assertTrue(ledger['N2332']['deferred_exprs'])
        # This slice resolves the StackRouter acceptItem /
        # target rows entry -- target() is live since N2324
        # and acceptItem is live now, so the combined entry is
        # gone -- replaced by the acceptItem live-fill entry
        # (no live caller evaluates the gate yet: acceptItem is
        # called by other buildings' dump/offload, and no live
        # proximity/facing query fills facing_rel; handleItem
        # application still defers). The N2324 live proximity
        # query + handleItem application entry STAYS.
        self.assertFalse(any(entry.startswith('StackRouter acceptItem / target rows (') for entry in ledger['N2332']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter acceptItem live fill (') for entry in ledger['N2332']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter live proximity query + handleItem application (') for entry in ledger['N2332']['deferred_exprs']))

    def test_all_c07_stack_router_accept_item_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2332']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_accept_item_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/StackRouter.java',
            'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/Edges.java',
            'core/src/mindustry/world/Tile.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2332']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_stack_router_accept_item_state(self):
        stack_router = STACK_ROUTER_STATE.read_text(encoding='utf-8')
        # The pure acceptItem gate ports the StackRouter
        # OVERRIDE (StackRouter.java:89-93), NOT the parent
        # DuctRouter acceptItem (DuctRouter.java:160-164,
        # stricter: current == null && items.total() == 0).
        # Keep each Java expr on ONE comment line (the N2148
        # shootWarmup lesson: a split line fails this test).
        # The four terms are independent: !unloading (the
        # build field, StackRouter.java:25), current == null
        # || item == current (current is the nullable build
        # field, DuctRouter.java:80; items compare by name
        # string, the N2225 precedent), items.total() <
        # itemCapacity (total(), ItemModule.java:174-176;
        # itemCapacity 10, Block.java:75), and the facing term
        # (Edges.getFacingEdge(source.tile, tile).relativeTo
        # (tile) == rotation). The facing chain: getFacingEdge
        # (Tile, Tile) (Edges.java:57-60) returns the source
        # tile itself when the source block is not a
        # multiblock (Edges.java:62-63), and relativeTo is
        # Tile.relativeTo (Tile.java:82-84, adjacency -- 0-3
        # for an adjacent tile, -1 otherwise), NOT
        # BuildingComp.relativeTo(Building) (BuildingComp.
        # java:530, the float-position one target() uses); a
        # non-adjacent source yields -1, which never equals
        # rotation. The port takes facing_rel precomputed (the
        # N2324 precedent -- no live tile geometry) and
        # compares it to rotation (BuildingComp.java:69).
        # acceptItem is an intake gate called by OTHER
        # buildings' dump/offload (BuildingComp.java:1001-
        # 1016, `if(other.acceptItem(self(), item) &&
        # canDump(other, item)){`), never by the router's own
        # tick -- so there is no tick wiring in this slice:
        # pure + test + proof only, and handleItem application
        # (DuctRouter.java:179-184) still defers.
        self.assertIn('static func source_stack_router_accept_item_state', stack_router)
        self.assertIn('public boolean acceptItem(Building source, Item item){', stack_router)
        self.assertIn('return !unloading && (current == null || item == current) && items.total() < itemCapacity &&', stack_router)
        self.assertIn('(Edges.getFacingEdge(source.tile, tile).relativeTo(tile) == rotation);', stack_router)
        self.assertIn('public boolean unloading = false;', stack_router)
        self.assertIn('public @Nullable Item current;', stack_router)
        self.assertIn('public int total(){', stack_router)
        self.assertIn('public int itemCapacity = 10;', stack_router)
        self.assertIn('public static Tile getFacingEdge(Tile tile, Tile other){', stack_router)
        self.assertIn('if(!block.isMultiblock()) return world.tile(tilex, tiley);', stack_router)
        self.assertIn('public byte relativeTo(Tile tile){', stack_router)
        self.assertIn('public static byte relativeTo(int x, int y, int cx, int cy){', stack_router)
        self.assertIn('transient int rotation;', stack_router)
        self.assertIn('return current == null && items.total() == 0 &&', stack_router)
        # The four terms are evaluated independently and ANDed:
        # the current match is null-or-same-name, the capacity
        # term reads the shared inventory total, and the facing
        # term compares the precomputed facing_rel to rotation.
        self.assertIn('current == null or str(item) == str(current)', stack_router)
        self.assertIn('not unloading and current_match and inventory.items_total(items) < item_capacity and facing_rel == rotation', stack_router)
        self.assertIn('"accepts": accepts', stack_router)
        # The documented limits now record the acceptItem gate
        # as live, with the live-fill deferral (no live caller
        # + no live facing fill + handleItem application); the
        # earlier live rows stay pinned.
        self.assertIn('acceptItem gate live (N2332)', stack_router)
        self.assertIn('updateTile advance live (N2240)', stack_router)
        self.assertIn('target() selection live (N2324)', stack_router)
        # The proof's keys drive the pure gate (accepts when
        # idle + facing with no current item, and when the
        # incoming item IS the current item; rejects when
        # unloading, when the current item differs, when the
        # store is full -- total >= capacity, with total ==
        # capacity - 1 still accepting -- and when the facing
        # is wrong, including the non-adjacent -1 facing).
        proof = STACK_ROUTER_ACCEPT_ITEM_PROOF.read_text(encoding='utf-8')
        for key in [
            'accepts_when_idle_and_facing',
            'rejects_when_unloading',
            'rejects_when_current_differs',
            'rejects_when_full',
            'rejects_when_wrong_facing',
            'accepts_current_item_when_facing',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceStackRouterBuildState.gd")', proof)
        self.assertIn('stack_router_build_state.source_stack_router_accept_item_state(', proof)
        self.assertTrue(STACK_ROUTER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = STACK_ROUTER_ACCEPT_ITEM_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07StackRouterAcceptItemProof.gd', scene)
        self.assertIn('C07StackRouterAcceptItemProof', scene)

    def test_reference_graph_and_actual_c07_stack_router_accept_item(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07StackRouterAcceptItemProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_STACK_ROUTER_ACCEPT_ITEM_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'accepts_when_idle_and_facing',
            'rejects_when_unloading',
            'rejects_when_current_differs',
            'rejects_when_full',
            'rejects_when_wrong_facing',
            'accepts_current_item_when_facing',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
