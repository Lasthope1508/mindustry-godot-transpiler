import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
STACK_ROUTER_STATE = ROOT / 'godot-mindustry/src/game/SourceStackRouterBuildState.gd'
STACK_ROUTER_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackRouterUpdateTileProof.gd'
STACK_ROUTER_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackRouterUpdateTileProof.tscn'


class C07StackRouterUpdateTileTests(unittest.TestCase):
    def test_c07_stack_router_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2240']['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_update_tile_advance_state')
        # N2181 gave the stack router its live power.status read
        # -- but the port tracked no unloading / current /
        # progress / items state at all, so a surge-router never
        # charged toward its cap, never unloaded, never picked
        # a current item. N2240 is the updateTile advance
        # (StackRouterBuild.updateTile(), StackRouter.java:
        # 28-70): the eff fold (eff = enabled ? (efficiency +
        # baseEfficiency) : 0f, :29 -- 0f when disabled, NOT the
        # conveyor's 1f), the cap (cap = speed, :30), the
        # charge branch (:32-41 -- progress += eff with NO
        # delta multiply, then unloading = true + progress %=
        # cap at the cap), the unload branch (:45-60 -- target
        # = target() + the while handoff loop + the out-of-
        # items clear), the current-pick branch (:62-63 --
        # current = items.first()) and the empty reset
        # (:66-68). target() is DuctRouter.target()
        # (DuctRouter.java:139-156): a live proximity scan with
        # cdump rotation + sortItem/rotation gates + acceptItem
        # -- no live query exists in the port, so the pure
        # advance takes an explicit ordered targets list (the
        # driver passes []) and pops one entry per handoff
        # (cdump rotation simulated by list order -- to model
        # N items to the same target, repeat its entry N
        # times); handleItem application defers, so the advance
        # returns handed_off / handed_to as pure results.
        # items.first() scans in content-id order
        # (ItemModule.java:182-189), so the advance takes the
        # catalog item_order (the N2225 take() precedent). Six
        # new result symbols: the advanced unloading / current
        # / progress / items, the handoff count, and the
        # handoff target ids.
        self.assertEqual(
            ledger['N2240']['source_symbols'],
            [
                'source_stack_router_update_tile_advance_state_result.unloading',
                'source_stack_router_update_tile_advance_state_result.current',
                'source_stack_router_update_tile_advance_state_result.progress',
                'source_stack_router_update_tile_advance_state_result.items',
                'source_stack_router_update_tile_advance_state_result.handed_off',
                'source_stack_router_update_tile_advance_state_result.handed_to',
            ],
        )
        for name in ledger['N2240']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/distribution/StackRouter.java')
                self.assertEqual(symbol['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_update_tile_advance_state')
        self.assertEqual(ledger['N2240']['runtime_proof'], '/root/C07StackRouterUpdateTileProof')
        self.assertEqual(
            ledger['N2240']['tests'],
            [
                'test_c07_stack_router_update_tile_registration',
                'test_all_c07_stack_router_update_tile_input_evidence_is_exact',
                'test_stack_router_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_stack_router_update_tile',
            ],
        )
        self.assertTrue(ledger['N2240']['deferred_exprs'])
        # This slice resolves the N2181 StackRouter updateTile
        # advance deferral, so the advance entry is gone from
        # DEFERRED -- while the live-fill entry (target() live
        # proximity selection + handleItem application) takes
        # its place. The StackRouter acceptItem / target rows
        # entry STAYS: acceptItem itself (the facing gate,
        # StackRouter.java:90-93) is still unported.
        self.assertFalse(any(entry.startswith('StackRouter updateTile advance (') for entry in ledger['N2240']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter updateTile live fill (') for entry in ledger['N2240']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter acceptItem / target rows (') for entry in ledger['N2240']['deferred_exprs']))

    def test_all_c07_stack_router_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2240']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/StackRouter.java',
            'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2240']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_stack_router_update_tile_advance_state(self):
        stack_router = STACK_ROUTER_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the stack-router build
        # state: StackRouterBuild.updateTile()
        # (StackRouter.java:28-70). Keep each Java expr on ONE
        # comment line (the N2148 shootWarmup lesson: a split
        # line fails this test). The eff fold is `float eff =
        # enabled ? (efficiency + baseEfficiency) : 0f;`
        # (StackRouter.java:29) -- disabled is 0f, NOT the
        # conveyor's 1f (StackConveyor.java:270) -- and the
        # charge is `progress += eff;` (StackRouter.java:35)
        # with NO delta multiply: this advance takes no
        # source_delta at all. The cap is `float cap = speed;`
        # (StackRouter.java:30); the surge def sets speed 6f
        # (Blocks.java:2259) against the DuctRouter class
        # default 5f (DuctRouter.java:19). The charge gate is
        # `if(!unloading && current != null && items.total()
        # >= itemCapacity){` (StackRouter.java:32); at the cap
        # `unloading = true;` + `progress %= cap;`
        # (StackRouter.java:39-40). The unload branch
        # (StackRouter.java:45-60) re-queries target() every
        # iteration; the pure list models that call sequence,
        # one entry per handoff. items.first() scans content-
        # id order (ItemModule.java:182-189), so the advance
        # takes the catalog item_order (the N2225 take()
        # precedent); an EMPTY order picks nothing (no content
        # order is known). items.empty() is total == 0
        # (ItemModule.java:170-172). The driver runs the
        # advance only when enabled -- and for this family
        # that gate is EXACT, not the N2195 pragmatic choice:
        # DuctRouter sets `noUpdateDisabled = true;`
        # (DuctRouter.java:32), so Java's `if(enabled ||
        # !block.noUpdateDisabled){` (BuildingComp.java:2276)
        # never runs updateTile for a disabled stack router.
        self.assertIn('static func source_stack_router_update_tile_advance_state', stack_router)
        self.assertIn('static func _stack_router_first_item', stack_router)
        self.assertIn('public class StackRouter extends DuctRouter{', stack_router)
        self.assertIn('public class StackRouterBuild extends DuctRouterBuild{', stack_router)
        self.assertIn('public float baseEfficiency = 0f;', stack_router)
        self.assertIn('itemCapacity = 10;', stack_router)
        self.assertIn('public boolean unloading = false;', stack_router)
        self.assertIn('public void updateTile(){', stack_router)
        self.assertIn('float eff = enabled ? (efficiency + baseEfficiency) : 0f;', stack_router)
        self.assertIn('float cap = speed;', stack_router)
        self.assertIn('if(!unloading && current != null && items.total() >= itemCapacity){', stack_router)
        self.assertIn('if(progress < cap){', stack_router)
        self.assertIn('progress += eff;', stack_router)
        self.assertIn('if(progress >= cap){', stack_router)
        self.assertIn('unloading = true;', stack_router)
        self.assertIn('progress %= cap;', stack_router)
        self.assertIn('if(unloading && current != null){', stack_router)
        self.assertIn('var target = target();', stack_router)
        self.assertIn('while(target != null && items.get(current) > 0){', stack_router)
        self.assertIn('target.handleItem(this, current);', stack_router)
        self.assertIn('items.remove(current, 1);', stack_router)
        self.assertIn('target = target();', stack_router)
        self.assertIn('if(items.get(current) == 0){', stack_router)
        self.assertIn('current = null;', stack_router)
        self.assertIn('unloading = false;', stack_router)
        self.assertIn('if((current == null || items.get(current) == 0) && items.total() > 0){', stack_router)
        self.assertIn('current = items.first();', stack_router)
        self.assertIn('if(items.empty()){', stack_router)
        self.assertIn('public class DuctRouter extends Block{', stack_router)
        self.assertIn('public float speed = 5f;', stack_router)
        self.assertIn('public class DuctRouterBuild extends Building{', stack_router)
        self.assertIn('public float progress;', stack_router)
        self.assertIn('public @Nullable Item current;', stack_router)
        self.assertIn('noUpdateDisabled = true;', stack_router)
        self.assertIn('public Building target(){', stack_router)
        self.assertIn('if(current == null) return null;', stack_router)
        self.assertIn('int dump = cdump;', stack_router)
        self.assertIn('for(int i = 0; i < proximity.size; i++){', stack_router)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', stack_router)
        self.assertIn('int rel = relativeTo(other);', stack_router)
        self.assertIn('if(!(sortItem != null && (current == sortItem) != (rel == rotation)) && !(rel == (rotation + 2) % 4) && other.team == team && other.acceptItem(this, current)){', stack_router)
        self.assertIn('incrementDump(proximity.size);', stack_router)
        self.assertIn('public @Nullable Item first(){', stack_router)
        self.assertIn('for(int i = 0; i < items.length; i++){', stack_router)
        self.assertIn('if(items[i] > 0){', stack_router)
        self.assertIn('return content.item(i);', stack_router)
        self.assertIn('public boolean empty(){', stack_router)
        self.assertIn('return total == 0;', stack_router)
        self.assertIn('public int get(Item item){', stack_router)
        self.assertIn('return items[item.id];', stack_router)
        self.assertIn('amount = Math.min(amount, items[item.id]);', stack_router)
        self.assertIn('items[item.id] -= amount;', stack_router)
        self.assertIn('total -= amount;', stack_router)
        self.assertIn('transient float efficiency;', stack_router)
        self.assertIn('transient boolean enabled = true;', stack_router)
        self.assertIn('updateConsumption();', stack_router)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', stack_router)
        self.assertIn('public boolean noUpdateDisabled = false;', stack_router)
        self.assertIn('public int itemCapacity = 10;', stack_router)
        self.assertIn('speed = 6f;', stack_router)
        self.assertIn('baseEfficiency = 1f;', stack_router)
        self.assertIn('consumePower(3f / 60f);', stack_router)
        # The def values are driver constants (the catalog
        # carries neither speed nor baseEfficiency for this
        # family -- the Separator craftTime precedent): the
        # surge-router def is the only def, so there is no
        # per-def helper, unlike N2226.
        self.assertIn('SOURCE_STACK_ROUTER_SPEED := 6.0', stack_router)
        self.assertIn('SOURCE_STACK_ROUTER_BASE_EFFICIENCY := 1.0', stack_router)
        self.assertIn('SOURCE_STACK_ROUTER_ITEM_CAPACITY := 10', stack_router)
        # The items math reuses the shared drill inventory
        # helpers (item_count / items_total / remove_item_state,
        # the N2225 precedent -- remove clamps like
        # ItemModule.remove, ItemModule.java:258-262).
        self.assertIn('inventory.item_count(', stack_router)
        self.assertIn('inventory.items_total(', stack_router)
        self.assertIn('inventory.remove_item_state(', stack_router)
        # The frame reads carry the Java field defaults:
        # unloading false (StackRouter.java:25), current null
        # + progress 0.0 (DuctRouter.java:79-80), efficiency
        # 0.0 (BuildingComp.java:85), enabled true
        # (BuildingComp.java:77), items {} (the factory
        # precedent -- the Building.items ItemModule starts
        # empty).
        self.assertIn('frame.get("unloading", false)', stack_router)
        self.assertIn('frame.get("current", null)', stack_router)
        self.assertIn('frame.get("progress", 0.0)', stack_router)
        self.assertIn('frame.get("items", {})', stack_router)
        self.assertIn('frame.get("efficiency", 0.0)', stack_router)
        self.assertIn('frame.get("enabled", true)', stack_router)
        # The driver wires the advance into the live tick after
        # the consumption fold (updateConsumption before
        # updateTile, BuildingComp.java:2274-2277) and only
        # when enabled (the EXACT noUpdateDisabled gate for
        # this family, DuctRouter.java:32). Since N2324 the
        # driver passes the live-computed targets list (the
        # target() simulation over the frame proximity_
        # neighbours input) instead of [] -- a router with no
        # stamped neighbours still passes an empty list, so
        # the N2240 proof's no-handoff live tick still holds.
        # The item order is the catalog item_names_by_id, the
        # content-id order ItemModule.first() scans.
        self.assertIn('source_stack_router_update_tile_advance_state(frame, SOURCE_STACK_ROUTER_SPEED, SOURCE_STACK_ROUTER_BASE_EFFICIENCY, SOURCE_STACK_ROUTER_ITEM_CAPACITY, targets, item_order)', stack_router)
        self.assertIn('item_names_by_id', stack_router)
        self.assertIn('frame["unloading"]', stack_router)
        self.assertIn('frame["current"]', stack_router)
        self.assertIn('frame["progress"]', stack_router)
        self.assertIn('frame["items"]', stack_router)
        self.assertIn('frame["handed_off"]', stack_router)
        self.assertIn('frame["handed_to"]', stack_router)
        # The documented limits now record the advance as done
        # and the remaining deferrals (target() live selection
        # + handleItem application); the power-only fold stays
        # exact (no shouldConsume override on this family).
        self.assertIn('updateTile advance live (N2240)', stack_router)
        self.assertNotIn('No updateTile advance', stack_router)
        # The proof's keys drive the pure advance (progress
        # charges by eff when full -- no delta multiply, and
        # still charges at eff 1f with no power; unloading
        # starts at the cap with progress %= cap, including
        # the exact-cap and already-at-cap cases; the handoff
        # drains the current item in list order and re-picks
        # the next item, stops when the list runs out, and
        # clears current/unloading when the current count hits
        # zero -- including the zero-count-current edge where
        # the loop never runs; current picks the first item in
        # content-id order, not dict order; empty items reset
        # unloading and current) plus the live tick (a placed
        # surge-router with a seeded full store charges
        # progress by the folded efficiency + base and writes
        # the advance keys onto the frame).
        proof = STACK_ROUTER_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'progress_charges_when_full',
            'unloading_starts_at_cap',
            'handoff_drains_current_item',
            'current_picks_first_item',
            'empty_resets_unloading',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceStackRouterBuildState.gd")', proof)
        self.assertIn('stack_router_build_state.source_stack_router_update_tile_advance_state(', proof)
        self.assertIn('stack_router_build_state.source_stack_router_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(STACK_ROUTER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = STACK_ROUTER_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07StackRouterUpdateTileProof.gd', scene)
        self.assertIn('C07StackRouterUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_stack_router_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07StackRouterUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_STACK_ROUTER_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'progress_charges_when_full',
            'unloading_starts_at_cap',
            'handoff_drains_current_item',
            'current_picks_first_item',
            'empty_resets_unloading',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
