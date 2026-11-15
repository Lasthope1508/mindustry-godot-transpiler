import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ITEM_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceItemBridgeBuildState.gd'
ITEM_BRIDGE_TRANSPORT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeTransportProof.gd'
ITEM_BRIDGE_TRANSPORT_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeTransportProof.tscn'


class C07ItemBridgeTransportTests(unittest.TestCase):
    def test_c07_item_bridge_transport_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2225']['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_update_transport_state')
        # N2197 proved the ItemBridge link frame state and N2199
        # proved placement auto-link -- but the port tracked no
        # transport counter / warmup / time / incoming at all, so
        # a linked phase-conveyor never moved an item across the
        # bridge: the gate read a store no live transport ever
        # filled. N2225 is the updateTile transport advance
        # (ItemBridgeBuild.updateTile(), ItemBridge.java:319-348,
        # + updateTransport(), ItemBridge.java:355-368): the
        # timeSpeed approachDelta toward (wasMoved ? 1 : 0) at
        # 1/60f, time += timeSpeed * delta(), the checkIncoming
        # prune, the incoming registration on the partner frame,
        # the warmup approachDelta toward efficiency at 1/30f,
        # and updateTransport (transportCounter += edelta(),
        # take / acceptItem / handleItem handoff, add-back +
        # undoFlow on reject, counter -= transportTime). The
        # hadValidLink recompute is N2197's and is NOT redone
        # here -- the advance takes it as a parameter. The
        # timerCheckMoved snapshot (ItemBridge.java:320-323)
        # defers (no timer infra), doDump defers (no neighbor
        # dump wiring), and checkAccept facing defers for
        # non-linked sources -- the transport path takes the
        # linked() shortcut (ItemBridge.java:464-466), which is
        # always true when hadValidLink holds, so acceptItem
        # there is the capacity gate only.
        # Ten new result symbols: the advanced frame values
        # plus the partner frame updates.
        self.assertEqual(
            ledger['N2225']['source_symbols'],
            [
                'source_item_bridge_update_transport_state_result.transport_counter',
                'source_item_bridge_update_transport_state_result.warmup',
                'source_item_bridge_update_transport_state_result.time',
                'source_item_bridge_update_transport_state_result.time_speed',
                'source_item_bridge_update_transport_state_result.moved',
                'source_item_bridge_update_transport_state_result.incoming',
                'source_item_bridge_update_transport_state_result.items',
                'source_item_bridge_update_transport_state_result.take_rotation',
                'source_item_bridge_update_transport_state_result.partner_items',
                'source_item_bridge_update_transport_state_result.partner_incoming',
            ],
        )
        for name in ledger['N2225']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
                    'core/src/mindustry/world/modules/ItemModule.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_update_transport_state')
        self.assertEqual(ledger['N2225']['runtime_proof'], '/root/C07ItemBridgeTransportProof')
        self.assertEqual(
            ledger['N2225']['tests'],
            [
                'test_c07_item_bridge_transport_registration',
                'test_all_c07_item_bridge_transport_input_evidence_is_exact',
                'test_item_bridge_transport_advance_state',
                'test_reference_graph_and_actual_c07_item_bridge_transport',
            ],
        )
        self.assertTrue(ledger['N2225']['deferred_exprs'])
        # This slice resolves FOUR deferrals: the N2179
        # updateTile advance entry AND the N2197 updateTransport
        # entry (same content, different wording), plus the
        # checkIncoming / incoming rows and the acceptItem /
        # checkAccept rows (the transport-path acceptance --
        # capacity gate + linked shortcut + handleItem handoff --
        # is this slice; only the facing path remains, as a new
        # narrower entry). Four new deferrals record what this
        # slice leaves behind (timerCheckMoved snapshot, doDump,
        # checkAccept facing, live items intake).
        self.assertFalse(any(entry.startswith('ItemBridge updateTile advance (') for entry in ledger['N2225']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('ItemBridge updateTransport advance (') for entry in ledger['N2225']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('ItemBridge checkIncoming / incoming rows (') for entry in ledger['N2225']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('ItemBridge acceptItem / checkAccept rows (') for entry in ledger['N2225']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge timerCheckMoved / wasMoved snapshot (') for entry in ledger['N2225']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge doDump / dumpAccumulate (') for entry in ledger['N2225']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge checkAccept facing (') for entry in ledger['N2225']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge live items intake (') for entry in ledger['N2225']['deferred_exprs']))

    def test_all_c07_item_bridge_transport_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2225']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_update_transport_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2225']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_item_bridge_transport_advance_state(self):
        item_bridge = ITEM_BRIDGE_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the item-bridge build state:
        # the timeSpeed approach (ItemBridge.java:326), time +=
        # timeSpeed * delta() (ItemBridge.java:328), checkIncoming
        # (ItemBridge.java:305-317), the hadValidLink branch
        # (ItemBridge.java:335-347), doDump (ItemBridge.java:336,
        # deferred) + warmup = 0f (ItemBridge.java:337), the
        # incoming registration (ItemBridge.java:339-344), the
        # warmup approach (ItemBridge.java:345), updateTransport
        # (ItemBridge.java:355-368), acceptItem (ItemBridge.java:424-426)
        # with the linked() shortcut (ItemBridge.java:464-466),
        # and take() (ItemModule.java:191-204). Keep each Java
        # expr on ONE comment line (the N2148 shootWarmup lesson:
        # a split line fails this test). approachDelta scales by
        # RAW Time.delta (Mathf.java:420-422, approach(from, to,
        # Time.delta * speed)), never by delta(); time +=
        # timeSpeed * delta() and transportCounter += edelta()
        # use delta() = Time.delta * timeScale
        # (BuildingComp.java:1922-1924) and edelta() =
        # efficiency * delta() (BuildingComp.java:1927-1929).
        # Time.delta in the port is seconds * 60 through
        # game_source_delta (arc Time.java:26), never raw seconds.
        self.assertIn('static func source_item_bridge_update_transport_state', item_bridge)
        self.assertIn('public int link = -1;', item_bridge)
        self.assertIn('public IntSeq incoming = new IntSeq(false, 4);', item_bridge)
        self.assertIn('public float warmup;', item_bridge)
        self.assertIn('public float time = -8f, timeSpeed;', item_bridge)
        self.assertIn('public boolean wasMoved, moved, hadValidLink;', item_bridge)
        self.assertIn('public float transportCounter;', item_bridge)
        self.assertIn('public final int timerCheckMoved = timers ++;', item_bridge)
        self.assertIn('noUpdateDisabled = true;', item_bridge)
        self.assertIn('itemCapacity = 10;', item_bridge)
        self.assertIn('public float transportTime;', item_bridge)
        self.assertIn('if(timer(timerCheckMoved, 30f)){', item_bridge)
        self.assertIn('wasMoved = moved;', item_bridge)
        self.assertIn('moved = false;', item_bridge)
        self.assertIn('timeSpeed = Mathf.approachDelta(timeSpeed, wasMoved ? 1f : 0f, 1f / 60f);', item_bridge)
        self.assertIn('time += timeSpeed * delta();', item_bridge)
        self.assertIn('checkIncoming();', item_bridge)
        self.assertIn('int i = incoming.items[idx];', item_bridge)
        self.assertIn('if(!linkValid(tile, other, false) || ((ItemBridgeBuild)other.build).link != tile.pos()){', item_bridge)
        self.assertIn('incoming.removeIndex(idx);', item_bridge)
        self.assertIn('Tile other = world.tile(link);', item_bridge)
        self.assertIn('hadValidLink = linkValid(tile, other);', item_bridge)
        self.assertIn('doDump();', item_bridge)
        self.assertIn('warmup = 0f;', item_bridge)
        self.assertIn('var inc = ((ItemBridgeBuild)other.build).incoming;', item_bridge)
        self.assertIn('int pos = tile.pos();', item_bridge)
        self.assertIn('if(!inc.contains(pos)){', item_bridge)
        self.assertIn('inc.add(pos);', item_bridge)
        self.assertIn('warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);', item_bridge)
        self.assertIn('updateTransport(other.build);', item_bridge)
        self.assertIn('dumpAccumulate();', item_bridge)
        self.assertIn('transportCounter += edelta();', item_bridge)
        self.assertIn('while(transportCounter >= transportTime){', item_bridge)
        self.assertIn('Item item = items.take();', item_bridge)
        self.assertIn('if(item != null && other.acceptItem(this, item)){', item_bridge)
        self.assertIn('other.handleItem(this, item);', item_bridge)
        self.assertIn('moved = true;', item_bridge)
        self.assertIn('items.add(item, 1);', item_bridge)
        self.assertIn('items.undoFlow(item);', item_bridge)
        self.assertIn('transportCounter -= transportTime;', item_bridge)
        self.assertIn('return hasItems && team == source.team && items.total() < itemCapacity && checkAccept(source, world.tile(link));', item_bridge)
        self.assertIn('if(tile == null || linked(source)) return true;', item_bridge)
        self.assertIn('return source instanceof ItemBridgeBuild && linkValid(source.tile, tile) && ((ItemBridgeBuild)source).link == pos();', item_bridge)
        self.assertIn('var facing = Edges.getFacingEdge(source, this);', item_bridge)
        self.assertIn('return rel != rel2;', item_bridge)
        self.assertIn('public @Nullable Item take(){', item_bridge)
        self.assertIn('takeRotation = index + 1;', item_bridge)
        self.assertIn('protected int takeRotation;', item_bridge)
        self.assertIn('public void undoFlow(Item item){', item_bridge)
        self.assertIn('cacheSums[item.id] -= 1;', item_bridge)
        self.assertIn('transportTime = 2f;', item_bridge)
        self.assertIn('return Time.delta * timeScale;', item_bridge)
        self.assertIn('return efficiency * delta();', item_bridge)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', item_bridge)
        self.assertIn('public boolean noUpdateDisabled = false;', item_bridge)
        self.assertIn('dumpAccum += delta();', item_bridge)
        self.assertIn('while(dumpAccum >= 1f){', item_bridge)
        self.assertIn('public void handleItem(Building source, Item item){', item_bridge)
        self.assertIn('public class ItemBridge extends Block{', item_bridge)
        self.assertIn('public class ItemBridgeBuild extends Building{', item_bridge)
        # transportTime is the def constant 2f (Blocks.java:2119)
        # and itemCapacity the def constant 10 (ItemBridge.java:49);
        # both arrive as parameters, the N2220 pump_amount
        # precedent. time starts at -8f (ItemBridge.java:201),
        # not 0 -- the initial frame carries it.
        self.assertIn('SOURCE_ITEM_BRIDGE_TRANSPORT_TIME := 2.0', item_bridge)
        self.assertIn('SOURCE_ITEM_BRIDGE_ITEM_CAPACITY := 10', item_bridge)
        self.assertIn('SOURCE_ITEM_BRIDGE_TIME_SPEED_RATE := 1.0 / 60.0', item_bridge)
        self.assertIn('SOURCE_ITEM_BRIDGE_WARMUP_RATE := 1.0 / 30.0', item_bridge)
        self.assertIn('"time": -8.0', item_bridge)
        # The driver wires the advance into the live tick after
        # the N2197 had_valid_link recompute (the Java order:
        # updateConsumption before updateTile, BuildingComp.java:2274-2277),
        # only when enabled (noUpdateDisabled = true,
        # ItemBridge.java:54). The source delta is
        # game_source_delta(game, seconds) and timeScale reads
        # live from the sprite meta (SourcePlacedBlockState.time_scale,
        # default 1.0, BuildingComp.java:98). The take rotation
        # runs over the catalog item order (item_names_by_id,
        # the content-id order ItemModule.take() iterates), and
        # the item add / total reuse the shared drill inventory
        # helpers (SourceDrillInventoryRuntimeState), not a
        # re-implementation. The approachDelta steps reuse
        # SourceMathState.source_approach_delta (the arc
        # Mathf.java:420-422 formula).
        self.assertIn('game_source_delta(game, seconds)', item_bridge)
        self.assertIn('time_scale(sprite', item_bridge)
        self.assertIn('source_item_bridge_update_transport_state(frame, source_delta, time_scale, SOURCE_ITEM_BRIDGE_TRANSPORT_TIME, SOURCE_ITEM_BRIDGE_ITEM_CAPACITY, bool(frame.get("had_valid_link", false)), this_pos, partner, incoming_valid, item_order)', item_bridge)
        self.assertIn('item_names_by_id', item_bridge)
        self.assertIn('source_approach_delta(', item_bridge)
        self.assertIn('inventory.add_item_state(', item_bridge)
        self.assertIn('inventory.items_total(', item_bridge)
        self.assertIn('frame["transport_counter"]', item_bridge)
        self.assertIn('frame["warmup"]', item_bridge)
        self.assertIn('frame["time"]', item_bridge)
        self.assertIn('frame["time_speed"]', item_bridge)
        self.assertIn('frame["moved"]', item_bridge)
        self.assertIn('frame["incoming"]', item_bridge)
        self.assertIn('frame["take_rotation"]', item_bridge)
        self.assertIn('partner_frame["items"]', item_bridge)
        self.assertIn('partner_frame["incoming"]', item_bridge)
        # The documented limits now record the transport advance
        # as live and the remaining deferrals (timerCheckMoved,
        # doDump, checkAccept facing); the old N2179/N2197 "no
        # transport advance" text is gone. The N2188 gate, the
        # N2197 link frame state, and the N2199 auto-link are
        # preserved.
        self.assertIn('updateTile transport advance live (N2225)', item_bridge)
        self.assertNotIn('No updateTile transport advance', item_bridge)
        self.assertIn('shouldConsume gate LIVE (N2188)', item_bridge)
        self.assertIn('static func source_item_bridge_should_consume_state', item_bridge)
        self.assertIn('static func source_item_bridge_link_valid_state', item_bridge)
        self.assertIn('static func source_item_bridge_player_placed_state', item_bridge)
        self.assertIn('static func source_item_bridge_power_status_row_state', item_bridge)
        # The proof's keys drive the pure advance (the counter
        # charges by edelta with the timeScale split, the
        # handoff fires at transportTime, a rejected item comes
        # back with the counter still spent, warmup approaches
        # efficiency when linked and zeroes when unlinked, dead
        # incoming links prune while the live one registers on
        # the partner). Static checks: the proof preloads the
        # family state file that exists, and the scene file
        # references the proof script that exists.
        proof = ITEM_BRIDGE_TRANSPORT_PROOF.read_text(encoding='utf-8')
        for key in [
            'transport_counter_charges_with_edelta',
            'handoff_at_transport_time',
            'item_returns_when_partner_rejects',
            'warmup_approaches_efficiency_when_linked',
            'warmup_zero_when_unlinked',
            'incoming_prunes_dead_links',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceItemBridgeBuildState.gd")', proof)
        self.assertTrue(ITEM_BRIDGE_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = ITEM_BRIDGE_TRANSPORT_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ItemBridgeTransportProof.gd', scene)
        self.assertIn('C07ItemBridgeTransportProof', scene)

    def test_reference_graph_and_actual_c07_item_bridge_transport(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ItemBridgeTransportProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ITEM_BRIDGE_TRANSPORT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'transport_counter_charges_with_edelta',
            'handoff_at_transport_time',
            'item_returns_when_partner_rejects',
            'warmup_approaches_efficiency_when_linked',
            'warmup_zero_when_unlinked',
            'incoming_prunes_dead_links',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
