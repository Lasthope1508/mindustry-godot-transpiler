import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
STACK_CONVEYOR_STATE = ROOT / 'godot-mindustry/src/game/SourceStackConveyorBuildState.gd'
STACK_CONVEYOR_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackConveyorUpdateTileProof.gd'
STACK_CONVEYOR_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackConveyorUpdateTileProof.tscn'


class C07StackConveyorUpdateTileTests(unittest.TestCase):
    def test_c07_stack_conveyor_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2239']['godot_owner'], 'SourceStackConveyorBuildState.source_stack_conveyor_update_tile_advance_state')
        # N2180 proved the StackConveyor power row (the surge
        # def's static consumePower 1f/60f folds into the min
        # efficiency) -- but the port tracked no updateTile
        # advance at all, so a placed stack conveyor never
        # reeled, unloaded, or transferred an item: the eff
        # fold (StackConveyor.java:270) was what the efficiency
        # keys proved, and the reel / cooldown / transfer /
        # link / unload behavior waited. N2239 is the updateTile
        # advance (StackConveyorBuild.updateTile(),
        # StackConveyor.java:268-315): the eff fold (disabled
        # still reels at eff 1f), the cooldown reel with RAW
        # delta() (not edelta), the link == -1 and cooldown > 0
        # early returns, the lastItem pick (items.first() in
        # content-id order), the !enabled return, the unload
        # branch (the (lastItem != null && !outputRouter) ?
        # moveForward : dump precedence -- && binds tighter
        # than ?:, so outputRouter=true always dumps), and the
        # transfer branch (state != stateLoad || total >=
        # getMaximumAccepted, front() is a same-team
        # StackConveyorBuild with link == -1, the whole stack
        # moves, cooldown = recharge, e.cooldown = 1).
        # moveForward (BuildingComp.java:1129-1137) and dump
        # (BuildingComp.java:1072-1113) are live neighbour
        # operations -- the application defers; the pure
        # advance takes explicit move_forward_ok / dump_ok
        # bools (the per-tick live answers, assumed stable
        # within the tick) and returns the unloaded count plus
        # the remaining items. The front() query
        # (BuildingComp.java:550-554) is live too -- the pure
        # advance takes an explicit front dict and returns
        # front_updated values for the driver to write back
        # (the N2225 partner precedent); the driver passes
        # no-front. The poofOut link = -1 state effect IS
        # modeled (the unloadEffect.at(this) presentation stays
        # under the existing poofIn/poofOut entry). Ten new
        # result symbols: the advanced self values plus the
        # front updates.
        self.assertEqual(
            ledger['N2239']['source_symbols'],
            [
                'source_stack_conveyor_update_tile_advance_state_result.cooldown',
                'source_stack_conveyor_update_tile_advance_state_result.link',
                'source_stack_conveyor_update_tile_advance_state_result.last_item',
                'source_stack_conveyor_update_tile_advance_state_result.items',
                'source_stack_conveyor_update_tile_advance_state_result.unloaded',
                'source_stack_conveyor_update_tile_advance_state_result.transferred',
                'source_stack_conveyor_update_tile_advance_state_result.front_items',
                'source_stack_conveyor_update_tile_advance_state_result.front_last_item',
                'source_stack_conveyor_update_tile_advance_state_result.front_link',
                'source_stack_conveyor_update_tile_advance_state_result.front_cooldown',
            ],
        )
        for name in ledger['N2239']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/distribution/StackConveyor.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/modules/ItemModule.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceStackConveyorBuildState.source_stack_conveyor_update_tile_advance_state')
        self.assertEqual(ledger['N2239']['runtime_proof'], '/root/C07StackConveyorUpdateTileProof')
        self.assertEqual(
            ledger['N2239']['tests'],
            [
                'test_c07_stack_conveyor_update_tile_registration',
                'test_all_c07_stack_conveyor_update_tile_input_evidence_is_exact',
                'test_stack_conveyor_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_stack_conveyor_update_tile',
            ],
        )
        self.assertTrue(ledger['N2239']['deferred_exprs'])
        # This slice resolves ONE deferral: the N2180 updateTile
        # advance entry. Three new deferrals record what this
        # slice leaves behind (moveForward / dump application,
        # the live front() query, the live items intake).
        self.assertFalse(any(entry.startswith('StackConveyor updateTile advance (') for entry in ledger['N2239']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackConveyor moveForward / dump application (') for entry in ledger['N2239']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackConveyor live front() query (') for entry in ledger['N2239']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackConveyor live items intake (') for entry in ledger['N2239']['deferred_exprs']))

    def test_all_c07_stack_conveyor_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2239']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceStackConveyorBuildState.source_stack_conveyor_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/StackConveyor.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/ItemModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2239']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_stack_conveyor_update_tile_advance_state(self):
        stack_conveyor = STACK_CONVEYOR_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the stack-conveyor build
        # state: the eff fold (StackConveyor.java:270), the
        # cooldown reel (StackConveyor.java:273, RAW delta(),
        # not edelta), the link gate (StackConveyor.java:276),
        # the cooldown gate (StackConveyor.java:279), the
        # lastItem pick (StackConveyor.java:282-284,
        # items.first() in content-id order,
        # ItemModule.java:182-188), the !enabled return
        # (StackConveyor.java:287), the unload branch
        # (StackConveyor.java:289-300, the precedence trap:
        # `&&` binds tighter than `?:`, so the condition is
        # (lastItem != null && !outputRouter) ? moveForward :
        # dump -- outputRouter=true ALWAYS dumps, even when
        # lastItem is null, but the pick above guarantees
        # lastItem null iff items is empty, and dump(null) on
        # empty items returns false), and the transfer branch
        # (StackConveyor.java:301-314, state != stateLoad ||
        # total >= getMaximumAccepted(lastItem) =
        # block.itemCapacity, BuildingComp.java:781-783, front()
        # is a same-team StackConveyorBuild with link == -1).
        # moveForward is BuildingComp.java:1129-1137 (NOT in
        # StackConveyor.java -- grep at RED), dump(Item) is
        # BuildingComp.java:1072-1113 (it removes 1 itself),
        # front() is BuildingComp.java:550-554. Keep each Java
        # expr on ONE comment line (the N2148 shootWarmup
        # lesson: a split line fails this test). delta() is
        # `return Time.delta * timeScale;`
        # (BuildingComp.java:1922-1924); Time.delta in the port
        # is seconds * 60 through game_source_delta (arc
        # Time.java:26), never raw seconds. The efficiency
        # default is the no-consumers branch
        # (BuildingComp.java:1944-1946): a block with no
        # consumers reads efficiency 1f when enabled (so a
        # plastanium-conveyor reels at eff 1f with no power
        # row), 0f when disabled (and the eff fold uses 1f
        # anyway when disabled). updateTile runs even when
        # disabled (BuildingComp.java:2274-2277,
        # noUpdateDisabled defaults false, Block.java:170) --
        # that is the whole point of the reel-in-when-disabled.
        self.assertIn('static func source_stack_conveyor_update_tile_advance_state', stack_conveyor)
        self.assertIn('public class StackConveyor extends Block implements Autotiler{', stack_conveyor)
        self.assertIn('public class StackConveyorBuild extends Building{', stack_conveyor)
        self.assertIn('protected static final int stateMove = 0, stateLoad = 1, stateUnload = 2;', stack_conveyor)
        self.assertIn('public float baseEfficiency = 0f;', stack_conveyor)
        self.assertIn('public float speed = 0f;', stack_conveyor)
        self.assertIn('public boolean outputRouter = true;', stack_conveyor)
        self.assertIn('public float recharge = 2f;', stack_conveyor)
        self.assertIn('itemCapacity = 10;', stack_conveyor)
        self.assertIn('public int state, blendprox;', stack_conveyor)
        self.assertIn('public int link = -1;', stack_conveyor)
        self.assertIn('public float cooldown;', stack_conveyor)
        self.assertIn('public Item lastItem;', stack_conveyor)
        self.assertIn('public void updateTile(){', stack_conveyor)
        self.assertIn('float eff = enabled ? (efficiency + baseEfficiency) : 1f;', stack_conveyor)
        self.assertIn('if(cooldown > 0f) cooldown = Mathf.clamp(cooldown - speed * eff * delta(), 0f, recharge);', stack_conveyor)
        self.assertIn('if(link == -1) return;', stack_conveyor)
        self.assertIn('if(cooldown > 0f) return;', stack_conveyor)
        self.assertIn('if(lastItem == null || !items.has(lastItem)){', stack_conveyor)
        self.assertIn('lastItem = items.first();', stack_conveyor)
        self.assertIn('if(!enabled) return;', stack_conveyor)
        self.assertIn('if(state == stateUnload){ //unload', stack_conveyor)
        self.assertIn('while(lastItem != null && !outputRouter ? moveForward(lastItem) : dump(lastItem)){', stack_conveyor)
        self.assertIn('if(!outputRouter){', stack_conveyor)
        self.assertIn('items.remove(lastItem, 1);', stack_conveyor)
        self.assertIn('if(!items.has(lastItem)){', stack_conveyor)
        self.assertIn('poofOut();', stack_conveyor)
        self.assertIn('lastItem = null;', stack_conveyor)
        self.assertIn('}else{ //transfer', stack_conveyor)
        self.assertIn('if(state != stateLoad || (items.total() >= getMaximumAccepted(lastItem))){', stack_conveyor)
        self.assertIn('if(front() instanceof StackConveyorBuild e && e.team == team && e.link == -1){', stack_conveyor)
        self.assertIn('e.items.add(items);', stack_conveyor)
        self.assertIn('e.lastItem = lastItem;', stack_conveyor)
        self.assertIn('e.link = tile.pos();', stack_conveyor)
        self.assertIn('link = -1;', stack_conveyor)
        self.assertIn('items.clear();', stack_conveyor)
        self.assertIn('cooldown = recharge;', stack_conveyor)
        self.assertIn('e.cooldown = 1;', stack_conveyor)
        self.assertIn('unloadEffect.at(this);', stack_conveyor)
        self.assertIn('speed = 4f / 60f;', stack_conveyor)
        self.assertIn('speed = 5f / 60f;', stack_conveyor)
        self.assertIn('outputRouter = false;', stack_conveyor)
        self.assertIn('baseEfficiency = 1f;', stack_conveyor)
        self.assertIn('consumePower(1f / 60f);', stack_conveyor)
        self.assertIn('public boolean moveForward(Item item){', stack_conveyor)
        self.assertIn('Building other = front();', stack_conveyor)
        self.assertIn('if(other != null && other.team == team && other.acceptItem(self(), item)){', stack_conveyor)
        self.assertIn('other.handleItem(self(), item);', stack_conveyor)
        self.assertIn('public boolean dump(Item todump){', stack_conveyor)
        self.assertIn('items.remove(todump, 1);', stack_conveyor)
        self.assertIn('public @Nullable Building front(){', stack_conveyor)
        self.assertIn('return Time.delta * timeScale;', stack_conveyor)
        self.assertIn('public int getMaximumAccepted(Item item){', stack_conveyor)
        self.assertIn('return block.itemCapacity;', stack_conveyor)
        self.assertIn('updateConsumption();', stack_conveyor)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', stack_conveyor)
        self.assertIn('public boolean noUpdateDisabled = false;', stack_conveyor)
        self.assertIn('transient float efficiency;', stack_conveyor)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', stack_conveyor)
        self.assertIn('if(!block.hasConsumers || cheating()){', stack_conveyor)
        self.assertIn('potentialEfficiency = enabled && productionValid() ? 1f : 0f;', stack_conveyor)
        self.assertIn('efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;', stack_conveyor)
        self.assertIn('public @Nullable Item first(){', stack_conveyor)
        self.assertIn('for(int i = 0; i < items.length; i++){', stack_conveyor)
        self.assertIn('public void add(ItemModule items){', stack_conveyor)
        self.assertIn('public void remove(Item item, int amount){', stack_conveyor)
        self.assertIn('amount = Math.min(amount, items[item.id]);', stack_conveyor)
        self.assertIn('public void clear(){', stack_conveyor)
        self.assertIn('public int total(){', stack_conveyor)
        self.assertIn('public boolean has(Item item){', stack_conveyor)
        # Per-def tables (the N2219 precedent): the catalog
        # carries NEITHER def's speed / baseEfficiency /
        # outputRouter (content_registry.json holds only
        # consumePower / hasPower / itemCapacity / health /
        # requirements for surge/plastanium-conveyor), so the
        # driver reads these tables, falling back to the class
        # defaults (speed 0f, baseEfficiency 0f, outputRouter
        # true, StackConveyor.java:37-39). recharge 2f and
        # itemCapacity 10 are the class defaults for both defs.
        self.assertIn('SOURCE_STACK_CONVEYOR_STATE_MOVE := 0', stack_conveyor)
        self.assertIn('SOURCE_STACK_CONVEYOR_STATE_LOAD := 1', stack_conveyor)
        self.assertIn('SOURCE_STACK_CONVEYOR_STATE_UNLOAD := 2', stack_conveyor)
        self.assertIn('SOURCE_STACK_CONVEYOR_RECHARGE := 2.0', stack_conveyor)
        self.assertIn('SOURCE_STACK_CONVEYOR_ITEM_CAPACITY := 10', stack_conveyor)
        self.assertIn('"plastanium-conveyor": 4.0 / 60.0', stack_conveyor)
        self.assertIn('"surge-conveyor": 5.0 / 60.0', stack_conveyor)
        self.assertIn('"plastanium-conveyor": 0.0', stack_conveyor)
        self.assertIn('"surge-conveyor": 1.0', stack_conveyor)
        self.assertIn('"plastanium-conveyor": true', stack_conveyor)
        self.assertIn('"surge-conveyor": false', stack_conveyor)
        # The initial frame carries the new keys (state 0 =
        # stateMove, the Java int default; link -1; cooldown
        # 0f; last_item null; items {} -- the N2180 driver had
        # NO items frame key, the frame was bound empty).
        self.assertIn('"state": 0', stack_conveyor)
        self.assertIn('"link": -1', stack_conveyor)
        self.assertIn('"cooldown": 0.0', stack_conveyor)
        self.assertIn('"last_item": null', stack_conveyor)
        self.assertIn('"items": {}', stack_conveyor)
        # The driver wires the advance into the live tick after
        # the consumption fold (the Java order:
        # updateConsumption before updateTile,
        # BuildingComp.java:2274-2277), for BOTH defs and even
        # when disabled (noUpdateDisabled defaults false, so
        # updateTile runs when disabled -- the reel-in). The
        # source delta is game_source_delta(game, seconds) and
        # timeScale reads live from the sprite meta
        # (SourcePlacedBlockState.time_scale, default 1.0,
        # BuildingComp.java:98). The item order is the catalog
        # item_names_by_id (the content-id order
        # ItemModule.first() iterates). The driver passes the
        # no-front default, move_forward_ok false and dump_ok
        # false -- the live front() query and the neighbour
        # application defer. The item add / total / remove
        # reuse the shared drill inventory helpers
        # (SourceDrillInventoryRuntimeState), not a
        # re-implementation.
        self.assertIn('game_source_delta(game, seconds)', stack_conveyor)
        self.assertIn('time_scale(sprite', stack_conveyor)
        self.assertIn('source_stack_conveyor_update_tile_advance_state(frame, source_delta, time_scale, block_speed, block_base_efficiency, block_output_router, SOURCE_STACK_CONVEYOR_RECHARGE, int(block.properties.get("itemCapacity", SOURCE_STACK_CONVEYOR_ITEM_CAPACITY)), this_pos, {}, false, false, item_order)', stack_conveyor)
        self.assertIn('item_names_by_id', stack_conveyor)
        self.assertIn('items_total(', stack_conveyor)
        self.assertIn('add_item_state(', stack_conveyor)
        self.assertIn('remove_item_state(', stack_conveyor)
        self.assertIn('frame["cooldown"]', stack_conveyor)
        self.assertIn('frame["link"]', stack_conveyor)
        self.assertIn('frame["last_item"]', stack_conveyor)
        self.assertIn('frame["items"]', stack_conveyor)
        # The documented limits now record the updateTile
        # advance as live and the remaining deferrals
        # (moveForward/dump application, live front() query,
        # live items intake); the old N2180 "no updateTile
        # advance" text is gone. The N2180 power row and the
        # tick wiring are preserved.
        self.assertIn('updateTile advance LIVE (N2239)', stack_conveyor)
        self.assertNotIn('No updateTile advance', stack_conveyor)
        self.assertIn('static func source_stack_conveyor_power_status_row_state', stack_conveyor)
        self.assertIn('static func source_stack_conveyor_tick_frame_state', stack_conveyor)
        self.assertIn('static func source_stack_conveyor_tick_buildings_state', stack_conveyor)
        self.assertIn('static func source_stack_conveyor_bind_frame_state', stack_conveyor)
        # The proof's keys drive the pure advance (the cooldown
        # reels by speed * eff * delta with the disabled-eff-1f
        # and timeScale splits, the transfer moves the whole
        # stack to the front with the write-back, the unload
        # drains lastItem through both the moveForward and the
        # dump branches, a disabled conveyor reels but never
        # transfers, and no transfer fires without a link) plus
        # the live tick (the driver writes the advance frame
        # keys). Static checks: the proof preloads the family
        # state file that exists, and the scene file references
        # the proof script that exists.
        proof = STACK_CONVEYOR_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'cooldown_reels_with_speed_eff_delta',
            'transfer_moves_all_items_to_front',
            'unload_drains_last_item',
            'disabled_still_reels_but_not_transfers',
            'no_transfer_without_link',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceStackConveyorBuildState.gd")', proof)
        self.assertTrue(STACK_CONVEYOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = STACK_CONVEYOR_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07StackConveyorUpdateTileProof.gd', scene)
        self.assertIn('C07StackConveyorUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_stack_conveyor_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07StackConveyorUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_STACK_CONVEYOR_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'cooldown_reels_with_speed_eff_delta',
            'transfer_moves_all_items_to_front',
            'unload_drains_last_item',
            'disabled_still_reels_but_not_transfers',
            'no_transfer_without_link',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
