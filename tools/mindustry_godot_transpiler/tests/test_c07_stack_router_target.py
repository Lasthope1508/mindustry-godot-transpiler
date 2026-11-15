import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
STACK_ROUTER_STATE = ROOT / 'godot-mindustry/src/game/SourceStackRouterBuildState.gd'
STACK_ROUTER_TARGET_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackRouterTargetProof.gd'
STACK_ROUTER_TARGET_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackRouterTargetProof.tscn'


class C07StackRouterTargetTests(unittest.TestCase):
    def test_c07_stack_router_target_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2324']['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_target_list_state')
        # N2240 ported the StackRouter updateTile advance with
        # an explicit ordered targets list (each entry models
        # one target() call result, popped in order per
        # handoff) -- but the driver passed [] because no live
        # proximity query existed, so no live handoff ever
        # happened. N2324 is the target() live proximity
        # selection (DuctRouter.target(), DuctRouter.java:
        # 139-157): a pure function simulating consecutive
        # target() calls over the frame proximity_neighbours
        # input, returning the ordered targets list plus the
        # cdump value after the simulated calls. Each call
        # scans from the current cdump, the first match wins,
        # and cdump advances by the number of neighbours
        # scanned -- including the match (incrementDump runs
        # on EVERY scanned iteration, before the return on a
        # match and at the end of the loop otherwise,
        # DuctRouter.java:148-153; incrementDump itself is
        # BuildingComp.java:1116-1120, `cdump = ((cdump + 1)
        # % prox)` when prox != 0). A call that scans the whole
        # list without a match returns null and stops the
        # sequence (its cdump advance is a full size, i.e. a
        # no-op modulo size). The match gate is `!(sortItem !=
        # null && (current == sortItem) != (rel == rotation))
        # && !(rel == (rotation + 2) % 4) && other.team == team
        # && other.acceptItem(this, current)` (DuctRouter.java:
        # 148); rel is relativeTo(other) (BuildingComp.java:
        # 530), precomputed per neighbour in the frame input.
        # Two new result symbols: the ordered targets list and
        # the cdump value after the simulated calls.
        self.assertEqual(
            ledger['N2324']['source_symbols'],
            [
                'source_stack_router_target_list_state_result.targets',
                'source_stack_router_target_list_state_result.cdump_after',
            ],
        )
        self.assertEqual(symbols['source_stack_router_target_list_state_result.targets']['java_source'], 'core/src/mindustry/world/blocks/distribution/DuctRouter.java')
        self.assertEqual(symbols['source_stack_router_target_list_state_result.cdump_after']['java_source'], 'core/src/mindustry/entities/comp/BuildingComp.java')
        for name in ledger['N2324']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_target_list_state')
        self.assertEqual(ledger['N2324']['runtime_proof'], '/root/C07StackRouterTargetProof')
        self.assertEqual(
            ledger['N2324']['tests'],
            [
                'test_c07_stack_router_target_registration',
                'test_all_c07_stack_router_target_input_evidence_is_exact',
                'test_stack_router_target_list_state',
                'test_reference_graph_and_actual_c07_stack_router_target',
            ],
        )
        self.assertTrue(ledger['N2324']['deferred_exprs'])
        # This slice resolves the N2240 StackRouter updateTile
        # live-fill entry's target() selection half, so that
        # entry is gone from DEFERRED -- replaced by the live
        # proximity query + handleItem application entry (the
        # neighbour list is still a frame input: no live
        # proximity query fills it yet; handleItem application
        # still defers). The StackRouter acceptItem / target
        # rows entry STAYS: acceptItem itself (the facing gate,
        # StackRouter.java:90-93) is still unported.
        self.assertFalse(any(entry.startswith('StackRouter updateTile live fill (') for entry in ledger['N2324']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter live proximity query + handleItem application (') for entry in ledger['N2324']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter acceptItem / target rows (') for entry in ledger['N2324']['deferred_exprs']))

    def test_all_c07_stack_router_target_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2324']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_target_list_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/StackRouter.java',
            'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2324']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_stack_router_target_list_state(self):
        stack_router = STACK_ROUTER_STATE.read_text(encoding='utf-8')
        # The pure target-list function simulates consecutive
        # DuctRouter.target() calls (DuctRouter.java:139-157)
        # over the frame proximity_neighbours input. Keep each
        # Java expr on ONE comment line (the N2148 shootWarmup
        # lesson: a split line fails this test). Each call
        # snapshots `int dump = cdump;` (:142) and scans
        # `proximity.get((i + dump) % proximity.size)` (:145)
        # from there; the first match wins. incrementDump runs
        # on EVERY scanned iteration -- before the return on a
        # match (:149-150) and at the end of the loop otherwise
        # (:153) -- so each call advances cdump by exactly the
        # number of neighbours scanned (1..size), and a
        # full-scan null call advances it by the whole size
        # (a no-op modulo size). incrementDump is
        # BuildingComp.java:1116-1120: `cdump = ((cdump + 1)
        # % prox)` when prox != 0. The match gate
        # (DuctRouter.java:148) skips the backwards neighbour
        # (rel == (rotation + 2) % 4), a wrong-team neighbour,
        # and a neighbour that rejects the item; the sortItem
        # gate routes the sort item only forward (rel ==
        # rotation) and every other item only elsewhere. rel
        # is relativeTo(other) (BuildingComp.java:530),
        # precomputed per neighbour; sortItem is the nullable
        # build field (DuctRouter.java:77) set via config
        # (DuctRouter.java:43). current == null returns an
        # empty list at once (`if(current == null) return
        # null;`, :140); an empty neighbour list runs no
        # iteration, so cdump is unchanged. handoff_count is
        # items.get(current) at tick start (ItemModule.java:
        # 209-211), read through the shared drill inventory
        # helper -- the StackRouter while loop (StackRouter.
        # java:47-52) calls target() once per handoff, so the
        # list holds at most handoff_count entries.
        self.assertIn('static func source_stack_router_target_list_state', stack_router)
        self.assertIn('public Building target(){', stack_router)
        self.assertIn('if(current == null) return null;', stack_router)
        self.assertIn('int dump = cdump;', stack_router)
        self.assertIn('for(int i = 0; i < proximity.size; i++){', stack_router)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', stack_router)
        self.assertIn('int rel = relativeTo(other);', stack_router)
        self.assertIn('if(!(sortItem != null && (current == sortItem) != (rel == rotation)) && !(rel == (rotation + 2) % 4) && other.team == team && other.acceptItem(this, current)){', stack_router)
        self.assertIn('incrementDump(proximity.size);', stack_router)
        self.assertIn('public void incrementDump(int prox){', stack_router)
        self.assertIn('if(prox != 0){', stack_router)
        self.assertIn('cdump = ((cdump + 1) % prox);', stack_router)
        self.assertIn('public byte relativeTo(Building build){', stack_router)
        self.assertIn('public @Nullable Item sortItem;', stack_router)
        self.assertIn('config(Item.class, (DuctRouterBuild tile, Item item) -> tile.sortItem = item);', stack_router)
        self.assertIn('transient int cdump;', stack_router)
        self.assertIn('transient int rotation;', stack_router)
        self.assertIn('var target = target();', stack_router)
        self.assertIn('while(target != null && items.get(current) > 0){', stack_router)
        self.assertIn('target = target();', stack_router)
        self.assertIn('public int get(Item item){', stack_router)
        self.assertIn('return items[item.id];', stack_router)
        # The pure function returns the ordered targets plus
        # the cdump value after the simulated calls, and the
        # scan order follows the cdump snapshot (the Java dump
        # local), not the advancing cdump.
        self.assertIn('"targets": targets', stack_router)
        self.assertIn('"cdump_after": dump_after', stack_router)
        # The frame carries cdump (Java default int 0,
        # BuildingComp.java:68) and sort_item (Java default
        # null, DuctRouter.java:77) from placement, and the
        # tick reads the neighbour list from the frame input
        # (default [] -- no live proximity query fills it
        # yet) plus the router rotation from the sprite meta
        # (the UnitAssemblerModule precedent).
        self.assertIn('"cdump": 0', stack_router)
        self.assertIn('"sort_item": null', stack_router)
        self.assertIn('frame.get("cdump", 0)', stack_router)
        self.assertIn('frame.get("sort_item", null)', stack_router)
        self.assertIn('frame.get("proximity_neighbours", [])', stack_router)
        self.assertIn('SOURCE_BUILD_ROTATION_META_KEY', stack_router)
        self.assertIn('frame["rotation"]', stack_router)
        # The tick computes the target list BEFORE the advance
        # call (handoff_count from the frame items via the
        # shared drill inventory helper) and passes it into
        # the N2240 advance instead of []; it stamps
        # frame["cdump"] only when a handoff actually happened
        # -- Java calls target() only inside the unload branch,
        # so a charging tick must not rotate cdump.
        self.assertIn('source_stack_router_target_list_state(', stack_router)
        self.assertIn('inventory.item_count(', stack_router)
        self.assertIn('source_stack_router_update_tile_advance_state(frame, SOURCE_STACK_ROUTER_SPEED, SOURCE_STACK_ROUTER_BASE_EFFICIENCY, SOURCE_STACK_ROUTER_ITEM_CAPACITY, targets, item_order)', stack_router)
        self.assertIn('frame["cdump"]', stack_router)
        # The documented limits now record the target()
        # selection as live and the remaining deferrals (live
        # proximity query + handleItem application).
        self.assertIn('target() selection live (N2324)', stack_router)
        self.assertIn('updateTile advance live (N2240)', stack_router)
        # The proof's keys drive the pure target list (scan
        # from cdump with wrap-around, first match wins, cdump
        # advances by the scanned count including the match;
        # backwards / wrong-team / rejecting neighbours are
        # skipped; sortItem routes the sort item forward only
        # and other items elsewhere; a full scan with no match
        # stops the sequence; null current / empty neighbours
        # return [] with cdump unchanged) plus the live tick
        # (a placed surge-router with seeded neighbours hands
        # items off in target-list order and stamps cdump, and
        # a charging tick leaves cdump alone).
        proof = STACK_ROUTER_TARGET_PROOF.read_text(encoding='utf-8')
        for key in [
            'target_scans_from_cdump',
            'target_skips_backwards_neighbour',
            'target_skips_wrong_team',
            'target_skips_rejecting_neighbour',
            'target_sort_item_routing',
            'live_tick_passes_targets_to_advance',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceStackRouterBuildState.gd")', proof)
        self.assertIn('stack_router_build_state.source_stack_router_target_list_state(', proof)
        self.assertIn('stack_router_build_state.source_stack_router_update_tile_advance_state(', proof)
        self.assertIn('stack_router_build_state.source_stack_router_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(STACK_ROUTER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = STACK_ROUTER_TARGET_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07StackRouterTargetProof.gd', scene)
        self.assertIn('C07StackRouterTargetProof', scene)

    def test_reference_graph_and_actual_c07_stack_router_target(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07StackRouterTargetProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_STACK_ROUTER_TARGET_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'target_scans_from_cdump',
            'target_skips_backwards_neighbour',
            'target_skips_wrong_team',
            'target_skips_rejecting_neighbour',
            'target_sort_item_routing',
            'live_tick_passes_targets_to_advance',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
