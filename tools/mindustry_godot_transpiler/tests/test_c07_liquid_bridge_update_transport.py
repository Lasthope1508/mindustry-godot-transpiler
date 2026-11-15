import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIQUID_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceLiquidBridgeBuildState.gd'
LIQUID_BRIDGE_TRANSPORT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidBridgeUpdateTransportProof.gd'
LIQUID_BRIDGE_TRANSPORT_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidBridgeUpdateTransportProof.tscn'


class C07LiquidBridgeUpdateTransportTests(unittest.TestCase):
    def test_c07_liquid_bridge_update_transport_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2275']['godot_owner'], 'SourceLiquidBridgeBuildState.source_liquid_bridge_update_transport_state')
        # N2179 gave the liquid bridge its live power.status read,
        # N2197 the link frame state, N2198 the shouldConsume
        # gate, N2199 the placement auto-link -- but the port
        # tracked no warmup and never moved a drop of liquid
        # across the bridge: the gate read a store no live
        # transport ever filled. N2275 is the updateTransport
        # advance (LiquidBridgeBuild.updateTransport(),
        # LiquidBridge.java:22-26, over the inherited
        # ItemBridgeBuild.updateTile(), ItemBridge.java:319-348):
        # the warmup approachDelta toward efficiency at 1/30f
        # when linked (ItemBridge.java:345) and warmup = 0f when
        # unlinked (ItemBridge.java:337), the warmup >= 0.25f
        # gate (LiquidBridge.java:23), and moveLiquid
        # (BuildingComp.java:938-978): the pressure-scaled flow
        # (fract - ofract, clamped, capped by what the bridge
        # holds and what the partner has room for), the
        # acceptLiquid gate -- the ItemBridge override
        # (ItemBridge.java:434-439), NOT the BuildingComp
        # default: the partner's current liquid must be the
        # moved liquid or nearly empty (< 0.2f), with
        # checkAccept true through the linked() shortcut
        # (ItemBridge.java:464-466), which is always true when
        # hadValidLink holds -- and moved |= flow > 0.05f
        # (LiquidBridge.java:24). getLiquidDestination returns
        # the build itself (BuildingComp.java:980-982, no
        # override on ItemBridge/LiquidBridge). The reaction
        # branch (BuildingComp.java:954-976) defers -- Java
        # itself TODOs it as wrong for multi-liquid blocks --
        # and doDump (LiquidBridge.java:29-31) waits for its own
        # slice, so the unlinked branch zeroes warmup but does
        # not dump. Five new result symbols: the advanced
        # warmup, the moved flag, the flow this tick, and the
        # two liquid stores after the transfer.
        self.assertEqual(
            ledger['N2275']['source_symbols'],
            [
                'source_liquid_bridge_update_transport_state_result.warmup',
                'source_liquid_bridge_update_transport_state_result.moved',
                'source_liquid_bridge_update_transport_state_result.flow',
                'source_liquid_bridge_update_transport_state_result.liquids_after',
                'source_liquid_bridge_update_transport_state_result.partner_liquids_after',
            ],
        )
        for name in ledger['N2275']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/liquid/LiquidBridge.java',
                    'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceLiquidBridgeBuildState.source_liquid_bridge_update_transport_state')
        self.assertEqual(ledger['N2275']['runtime_proof'], '/root/C07LiquidBridgeUpdateTransportProof')
        self.assertEqual(
            ledger['N2275']['tests'],
            [
                'test_c07_liquid_bridge_update_transport_registration',
                'test_all_c07_liquid_bridge_update_transport_input_evidence_is_exact',
                'test_liquid_bridge_update_transport_advance_state',
                'test_reference_graph_and_actual_c07_liquid_bridge_update_transport',
            ],
        )
        self.assertTrue(ledger['N2275']['deferred_exprs'])
        # This slice resolves the N2179 updateTransport advance
        # entry; doDump, the link rows, the per-def stat rows,
        # and the blocks_match fix stay deferred, and three new
        # deferrals record what this slice leaves behind (the
        # moveLiquid reaction branch, the live liquids intake,
        # and the inherited updateTile steps that are inert for
        # this family).
        self.assertFalse(any(entry.startswith('LiquidBridge updateTransport advance (') for entry in ledger['N2275']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge doDump rows (') for entry in ledger['N2275']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge moveLiquid reaction branch (') for entry in ledger['N2275']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge live liquids intake (') for entry in ledger['N2275']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge inherited updateTile steps (') for entry in ledger['N2275']['deferred_exprs']))

    def test_all_c07_liquid_bridge_update_transport_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2275']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceLiquidBridgeBuildState.source_liquid_bridge_update_transport_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/liquid/LiquidBridge.java',
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
            'arc-core/src/arc/math/Mathf.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2275']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_liquid_bridge_update_transport_advance_state(self):
        liquid_bridge = LIQUID_BRIDGE_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the liquid-bridge build
        # state: the inherited updateTile branch
        # (ItemBridge.java:332-347: the hadValidLink recompute,
        # the unlinked doDump + warmup = 0f, the warmup
        # approachDelta toward efficiency at 1/30f, then
        # updateTransport), the LiquidBridge override
        # (LiquidBridge.java:22-26: warmup >= 0.25f, moved |=
        # moveLiquid(other, liquids.current()) > 0.05f), and
        # moveLiquid (BuildingComp.java:938-978: null guard,
        # getLiquidDestination, the team / hasLiquids / have
        # gate, the pressure-scaled flow, the acceptLiquid
        # gate, the transfer, the deferred reaction branch).
        # Keep each Java expr on ONE comment line (the N2148
        # shootWarmup lesson: a split line fails this test).
        # approachDelta scales by RAW Time.delta
        # (Mathf.java:420-422, approach(from, to, Time.delta *
        # speed)), never by delta(); Time.delta in the port is
        # seconds * 60 through game_source_delta (arc
        # Time.java:26), never raw seconds. Mathf.clamp(value)
        # clamps to [0, 1] (Mathf.java:402-404). acceptLiquid
        # here is the ItemBridge OVERRIDE
        # (ItemBridge.java:434-439), not the BuildingComp
        # default (BuildingComp.java:868-870, `return
        # block.hasLiquids && block.consumesLiquid(liquid);`):
        # the partner's current liquid must be the moved
        # liquid or nearly empty (< 0.2f), and checkAccept
        # passes through the linked() shortcut
        # (ItemBridge.java:464-466), always true when
        # hadValidLink holds. The liquid store is the sprite
        # liquids meta (SourceLiquidModuleState: amounts array
        # by liquid id + current id, `private Liquid current =
        # content.liquid(0);`, LiquidModule.java:24); add sets
        # current (LiquidModule.java:110-112) and remove caps
        # at the stored amount (LiquidModule.java:124-127).
        self.assertIn('static func source_liquid_bridge_update_transport_state', liquid_bridge)
        self.assertIn('public class LiquidBridge extends ItemBridge{', liquid_bridge)
        self.assertIn('public class LiquidBridgeBuild extends ItemBridgeBuild{', liquid_bridge)
        self.assertIn('public void updateTransport(Building other){', liquid_bridge)
        self.assertIn('if(warmup >= 0.25f){', liquid_bridge)
        self.assertIn('moved |= moveLiquid(other, liquids.current()) > 0.05f;', liquid_bridge)
        self.assertIn('public void doDump(){', liquid_bridge)
        self.assertIn('dumpLiquid(liquids.current(), 1f);', liquid_bridge)
        self.assertIn('hasLiquids = true;', liquid_bridge)
        self.assertIn('hasItems = false;', liquid_bridge)
        self.assertIn('public void updateTile(){', liquid_bridge)
        self.assertIn('Tile other = world.tile(link);', liquid_bridge)
        self.assertIn('hadValidLink = linkValid(tile, other);', liquid_bridge)
        self.assertIn('doDump();', liquid_bridge)
        self.assertIn('warmup = 0f;', liquid_bridge)
        self.assertIn('warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);', liquid_bridge)
        self.assertIn('updateTransport(other.build);', liquid_bridge)
        self.assertIn('public float warmup;', liquid_bridge)
        self.assertIn('public boolean wasMoved, moved, hadValidLink;', liquid_bridge)
        self.assertIn('noUpdateDisabled = true;', liquid_bridge)
        self.assertIn('public float moveLiquid(Building next, Liquid liquid){', liquid_bridge)
        self.assertIn('if(next == null) return 0;', liquid_bridge)
        self.assertIn('next = next.getLiquidDestination(self(), liquid);', liquid_bridge)
        self.assertIn('if(next.team == team && next.block.hasLiquids && liquids.get(liquid) > 0f){', liquid_bridge)
        self.assertIn('float ofract = next.liquids.get(liquid) / next.block.liquidCapacity;', liquid_bridge)
        self.assertIn('float fract = liquids.get(liquid) / block.liquidCapacity * block.liquidPressure;', liquid_bridge)
        self.assertIn('float flow = Math.min(Mathf.clamp((fract - ofract)) * (block.liquidCapacity), liquids.get(liquid));', liquid_bridge)
        self.assertIn('flow = Math.min(flow, next.block.liquidCapacity - next.liquids.get(liquid));', liquid_bridge)
        self.assertIn('if(flow > 0f && ofract <= fract && next.acceptLiquid(self(), liquid)){', liquid_bridge)
        self.assertIn('next.handleLiquid(self(), liquid, flow);', liquid_bridge)
        self.assertIn('liquids.remove(liquid, flow);', liquid_bridge)
        self.assertIn('return flow;', liquid_bridge)
        self.assertIn('}else if(!next.block.consumesLiquid(liquid) && next.liquids.currentAmount() / next.block.liquidCapacity > 0.1f && fract > 0.1f){', liquid_bridge)
        self.assertIn('public Building getLiquidDestination(Building from, Liquid liquid){', liquid_bridge)
        self.assertIn('return self();', liquid_bridge)
        self.assertIn('public void handleLiquid(Building source, Liquid liquid, float amount){', liquid_bridge)
        self.assertIn('liquids.add(liquid, amount);', liquid_bridge)
        self.assertIn('public boolean acceptLiquid(Building source, Liquid liquid){', liquid_bridge)
        self.assertIn('hasLiquids && team == source.team &&', liquid_bridge)
        self.assertIn('(liquids.current() == liquid || liquids.get(liquids.current()) < 0.2f) &&', liquid_bridge)
        self.assertIn('checkAccept(source, world.tile(link));', liquid_bridge)
        self.assertIn('if(tile == null || linked(source)) return true;', liquid_bridge)
        self.assertIn('return source instanceof ItemBridgeBuild && linkValid(source.tile, tile) && ((ItemBridgeBuild)source).link == pos();', liquid_bridge)
        self.assertIn('return block.hasLiquids && block.consumesLiquid(liquid);', liquid_bridge)
        self.assertIn('private Liquid current = content.liquid(0);', liquid_bridge)
        self.assertIn('public Liquid current(){', liquid_bridge)
        self.assertIn('public float get(Liquid liquid){', liquid_bridge)
        self.assertIn('return liquids[liquid.id];', liquid_bridge)
        self.assertIn('public void add(Liquid liquid, float amount){', liquid_bridge)
        self.assertIn('liquids[liquid.id] += amount;', liquid_bridge)
        self.assertIn('current = liquid;', liquid_bridge)
        self.assertIn('public void remove(Liquid liquid, float amount){', liquid_bridge)
        self.assertIn('add(liquid, Math.max(-amount, -liquids[liquid.id]));', liquid_bridge)
        self.assertIn('public float currentAmount(){', liquid_bridge)
        self.assertIn('return liquids[current.id];', liquid_bridge)
        self.assertIn('public float liquidPressure = 1f;', liquid_bridge)
        self.assertIn('liquidCapacity = 100f;', liquid_bridge)
        self.assertIn('range = 12;', liquid_bridge)
        self.assertIn('return approach(from, to, Time.delta * speed);', liquid_bridge)
        self.assertIn('return Math.max(Math.min(value, 1f), 0f);', liquid_bridge)
        self.assertIn('updateConsumption();', liquid_bridge)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', liquid_bridge)
        # liquidCapacity is the def constant 100f
        # (Blocks.java:2395; bridge-conduit shares it,
        # Blocks.java:2381) and liquidPressure the Block
        # default 1f (Block.java:79 -- the phase-conduit def
        # does not override it); both arrive as parameters,
        # the N2220 pump_amount precedent. The warmup rate is
        # 1/30f (ItemBridge.java:345). The initial frame
        # carries warmup 0.0 and moved false (ItemBridge.java:200/:202).
        self.assertIn('SOURCE_LIQUID_BRIDGE_LIQUID_CAPACITY := 100.0', liquid_bridge)
        self.assertIn('SOURCE_LIQUID_BRIDGE_LIQUID_PRESSURE := 1.0', liquid_bridge)
        self.assertIn('SOURCE_LIQUID_BRIDGE_WARMUP_RATE := 1.0 / 30.0', liquid_bridge)
        self.assertIn('"warmup": 0.0', liquid_bridge)
        self.assertIn('"moved": false', liquid_bridge)
        # The driver wires the advance into the live tick after
        # the N2197 had_valid_link recompute (the Java order:
        # updateConsumption before updateTile,
        # BuildingComp.java:2274-2277; the recompute itself is
        # ItemBridge.java:332-333), only when enabled
        # (noUpdateDisabled = true, ItemBridge.java:54). The
        # source delta is game_source_delta(game, seconds);
        # the approachDelta step reuses
        # SourceMathState.source_approach_delta (the arc
        # Mathf.java:420-422 formula). The partner snapshot
        # comes from the placed_blocks lookup the recompute
        # already did; the driver writes the advanced warmup /
        # moved back to the frame and both liquid stores back
        # to their sprite metas (the PayloadUnloader N2232
        # precedent: the pure returns duplicates, it does not
        # mutate the synced store in place).
        self.assertIn('game_source_delta(game, seconds)', liquid_bridge)
        self.assertIn('source_approach_delta(', liquid_bridge)
        self.assertIn('source_liquid_bridge_update_transport_state(frame, source_delta, SOURCE_LIQUID_BRIDGE_LIQUID_CAPACITY, SOURCE_LIQUID_BRIDGE_LIQUID_PRESSURE, bool(frame.get("had_valid_link", false)), liquids, partner)', liquid_bridge)
        self.assertIn('frame["warmup"]', liquid_bridge)
        self.assertIn('frame["moved"]', liquid_bridge)
        self.assertIn('advanced["liquids_after"]', liquid_bridge)
        self.assertIn('advanced["partner_liquids_after"]', liquid_bridge)
        self.assertIn('SOURCE_BUILDING_LIQUIDS_META_KEY', liquid_bridge)
        # The documented limits now record the transport
        # advance as live and the remaining deferrals (doDump,
        # the reaction branch); the old N2179 "no
        # updateTransport advance" text is gone. The N2198
        # gate, the N2197 link frame state, and the N2199
        # auto-link are preserved.
        self.assertIn('updateTransport advance live (N2275)', liquid_bridge)
        self.assertNotIn('No updateTransport advance', liquid_bridge)
        self.assertIn('shouldConsume gate live (N2198)', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_should_consume_state', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_power_status_row_state', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_auto_link_placement_state', liquid_bridge)
        # The proof's keys drive the pure advance (warmup
        # approaches efficiency when linked and zeroes when
        # unlinked, the 0.25f gate blocks transport below it,
        # the pressure-scaled flow transfers the right amount,
        # moved sets only above the 0.05f threshold, and a
        # full / mismatched / empty partner takes nothing).
        # Static checks: the proof preloads the family state
        # file that exists, and the scene file references the
        # proof script that exists.
        proof = LIQUID_BRIDGE_TRANSPORT_PROOF.read_text(encoding='utf-8')
        for key in [
            'warmup_approaches_efficiency',
            'transport_blocked_below_warmup_quarter',
            'move_liquid_transfers_by_pressure',
            'moved_set_when_flow_above_threshold',
            'no_transfer_when_partner_full',
            'warmup_zero_when_unlinked',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceLiquidBridgeBuildState.gd")', proof)
        self.assertTrue(LIQUID_BRIDGE_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = LIQUID_BRIDGE_TRANSPORT_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07LiquidBridgeUpdateTransportProof.gd', scene)
        self.assertIn('C07LiquidBridgeUpdateTransportProof', scene)

    def test_reference_graph_and_actual_c07_liquid_bridge_update_transport(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LiquidBridgeUpdateTransportProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIQUID_BRIDGE_UPDATE_TRANSPORT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'warmup_approaches_efficiency',
            'transport_blocked_below_warmup_quarter',
            'move_liquid_transfers_by_pressure',
            'moved_set_when_flow_above_threshold',
            'no_transfer_when_partner_full',
            'warmup_zero_when_unlinked',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
