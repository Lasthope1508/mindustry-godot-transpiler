import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIQUID_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceLiquidBridgeBuildState.gd'
LIQUID_BRIDGE_DO_DUMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidBridgeDoDumpProof.gd'
LIQUID_BRIDGE_DO_DUMP_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidBridgeDoDumpProof.tscn'


class C07LiquidBridgeDoDumpTests(unittest.TestCase):
    def test_c07_liquid_bridge_do_dump_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2287']['godot_owner'], 'SourceLiquidBridgeBuildState.source_liquid_bridge_do_dump_state')
        # N2179 gave the liquid bridge its live power.status read,
        # N2197 the link frame state, N2198 the shouldConsume
        # gate, N2199 the placement auto-link, N2275 the
        # updateTransport advance -- but the unlinked branch
        # still only zeroed warmup: Java calls doDump() there
        # (ItemBridge.java:335-337), and the LiquidBridge
        # override dumps the current liquid at scaling 1f
        # (LiquidBridge.java:29-31). N2287 is that doDump
        # (dumpLiquid, BuildingComp.java:886-908): the 0.0001f
        # early return, the proximity scan from cdump with
        # incrementDump every iteration, the eligibility gate
        # (other.block.hasLiquids && canDumpLiquid &&
        # other.liquids != null), and the fraction transfer
        # (fract - ofract) * capacity / scaling at scaling 1f
        # -- NOT the 2f default (BuildingComp.java:877-878).
        # The base ItemBridge doDump is dumpAccumulate()
        # (ItemBridge.java:350-353, item dump), a different
        # slice; this slice ports only the LiquidBridge
        # override (liquid dump). Three new result symbols:
        # the liquid store after the dump, the total amount
        # dumped, and the cursor after the scan.
        self.assertEqual(
            ledger['N2287']['source_symbols'],
            [
                'source_liquid_bridge_do_dump_state_result.liquids_after',
                'source_liquid_bridge_do_dump_state_result.dumped_amount',
                'source_liquid_bridge_do_dump_state_result.cursor_after',
            ],
        )
        for name in ledger['N2287']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/liquid/LiquidBridge.java',
                    'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceLiquidBridgeBuildState.source_liquid_bridge_do_dump_state')
        self.assertEqual(ledger['N2287']['runtime_proof'], '/root/C07LiquidBridgeDoDumpProof')
        self.assertEqual(
            ledger['N2287']['tests'],
            [
                'test_c07_liquid_bridge_do_dump_registration',
                'test_all_c07_liquid_bridge_do_dump_input_evidence_is_exact',
                'test_liquid_bridge_do_dump_state',
                'test_reference_graph_and_actual_c07_liquid_bridge_do_dump',
            ],
        )
        self.assertTrue(ledger['N2287']['deferred_exprs'])
        # This slice resolves the doDump entry; the moveLiquid
        # reaction branch, the live liquids intake, and the
        # inherited updateTile steps stay deferred, and three
        # new deferrals record what this slice leaves behind
        # (the live neighbour fill, the neighbour write-back,
        # and the campaign unlock).
        self.assertFalse(any(entry.startswith('LiquidBridge doDump rows (') for entry in ledger['N2287']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge moveLiquid reaction branch (') for entry in ledger['N2287']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge live liquids intake (') for entry in ledger['N2287']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge inherited updateTile steps (') for entry in ledger['N2287']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge doDump live neighbour fill (') for entry in ledger['N2287']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge doDump neighbour write-back (') for entry in ledger['N2287']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge doDump campaign unlock (') for entry in ledger['N2287']['deferred_exprs']))

    def test_all_c07_liquid_bridge_do_dump_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2287']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceLiquidBridgeBuildState.source_liquid_bridge_do_dump_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/liquid/LiquidBridge.java',
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2287']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_liquid_bridge_do_dump_state(self):
        liquid_bridge = LIQUID_BRIDGE_STATE.read_text(encoding='utf-8')
        # The pure doDump lives on the liquid-bridge build
        # state: the LiquidBridge override
        # (LiquidBridge.java:29-31, dumpLiquid(current, 1f)),
        # called only from the unlinked branch of the
        # inherited updateTile (ItemBridge.java:335-337), and
        # dumpLiquid (BuildingComp.java:886-908: the 0.0001f
        # early return, the campaign unlock, the proximity
        # scan from cdump with incrementDump every iteration,
        # the output-dir filter, the getLiquidDestination
        # redirect, the eligibility gate, the fraction
        # transfer at scaling 1f) plus transferLiquid
        # (BuildingComp.java:914-921: flow = min(neighbour
        # free capacity, amount), applied only when
        # acceptLiquid holds) and incrementDump
        # (BuildingComp.java:1116-1121, guarded on prox != 0).
        # Keep each Java expr on ONE comment line (the N2148
        # shootWarmup lesson: a split line fails this test).
        # Scaling is 1f, NOT the 2f default
        # (BuildingComp.java:877-878); output_dir is -1 (any
        # direction, BuildingComp.java:881-882). The dump
        # fract has NO liquidPressure multiplier, unlike
        # moveLiquid (BuildingComp.java:945). The base
        # ItemBridge doDump is dumpAccumulate()
        # (ItemBridge.java:350-353, item dump) -- a different
        # slice. The liquid store is the sprite liquids meta
        # (SourceLiquidModuleState: amounts array by liquid
        # id + current id, `private Liquid current =
        # content.liquid(0);`, LiquidModule.java:24); add sets
        # current (LiquidModule.java:110-112) and remove caps
        # at the stored amount (LiquidModule.java:125-127).
        self.assertIn('static func source_liquid_bridge_do_dump_state', liquid_bridge)
        self.assertIn('public class LiquidBridge extends ItemBridge{', liquid_bridge)
        self.assertIn('public class LiquidBridgeBuild extends ItemBridgeBuild{', liquid_bridge)
        self.assertIn('public void doDump(){', liquid_bridge)
        self.assertIn('dumpLiquid(liquids.current(), 1f);', liquid_bridge)
        self.assertIn('hasLiquids = true;', liquid_bridge)
        self.assertIn('hasItems = false;', liquid_bridge)
        self.assertIn('public void updateTile(){', liquid_bridge)
        self.assertIn('Tile other = world.tile(link);', liquid_bridge)
        self.assertIn('hadValidLink = linkValid(tile, other);', liquid_bridge)
        self.assertIn('if(!hadValidLink){', liquid_bridge)
        self.assertIn('doDump();', liquid_bridge)
        self.assertIn('warmup = 0f;', liquid_bridge)
        self.assertIn('public void dumpLiquid(Liquid liquid){', liquid_bridge)
        self.assertIn('dumpLiquid(liquid, 2f);', liquid_bridge)
        self.assertIn('public void dumpLiquid(Liquid liquid, float scaling){', liquid_bridge)
        self.assertIn('dumpLiquid(liquid, scaling, -1);', liquid_bridge)
        self.assertIn('public void dumpLiquid(Liquid liquid, float scaling, int outputDir){', liquid_bridge)
        self.assertIn('int dump = this.cdump;', liquid_bridge)
        self.assertIn('if(liquids.get(liquid) <= 0.0001f) return;', liquid_bridge)
        self.assertIn('if(!net.client() && state.isCampaign() && team == state.rules.defaultTeam) liquid.unlock();', liquid_bridge)
        self.assertIn('for(int i = 0; i < proximity.size; i++){', liquid_bridge)
        self.assertIn('incrementDump(proximity.size);', liquid_bridge)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', liquid_bridge)
        self.assertIn('if(outputDir != -1 && (outputDir + rotation) % 4 != relativeTo(other)) continue;', liquid_bridge)
        self.assertIn('other = other.getLiquidDestination(self(), liquid);', liquid_bridge)
        self.assertIn('if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){', liquid_bridge)
        self.assertIn('float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;', liquid_bridge)
        self.assertIn('float fract = liquids.get(liquid) / block.liquidCapacity;', liquid_bridge)
        self.assertIn('if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);', liquid_bridge)
        self.assertIn('public boolean canDumpLiquid(Building to, Liquid liquid){', liquid_bridge)
        self.assertIn('return true;', liquid_bridge)
        self.assertIn('public void transferLiquid(Building next, float amount, Liquid liquid){', liquid_bridge)
        self.assertIn('float flow = Math.min(next.block.liquidCapacity - next.liquids.get(liquid), amount);', liquid_bridge)
        self.assertIn('if(next.acceptLiquid(self(), liquid)){', liquid_bridge)
        self.assertIn('next.handleLiquid(self(), liquid, flow);', liquid_bridge)
        self.assertIn('liquids.remove(liquid, flow);', liquid_bridge)
        self.assertIn('public void incrementDump(int prox){', liquid_bridge)
        self.assertIn('if(prox != 0){', liquid_bridge)
        self.assertIn('cdump = ((cdump + 1) % prox);', liquid_bridge)
        self.assertIn('transient int cdump;', liquid_bridge)
        self.assertIn('public Building getLiquidDestination(Building from, Liquid liquid){', liquid_bridge)
        self.assertIn('return self();', liquid_bridge)
        self.assertIn('public void handleLiquid(Building source, Liquid liquid, float amount){', liquid_bridge)
        self.assertIn('liquids.add(liquid, amount);', liquid_bridge)
        self.assertIn('private Liquid current = content.liquid(0);', liquid_bridge)
        self.assertIn('public Liquid current(){', liquid_bridge)
        self.assertIn('public float get(Liquid liquid){', liquid_bridge)
        self.assertIn('return liquids[liquid.id];', liquid_bridge)
        self.assertIn('public void add(Liquid liquid, float amount){', liquid_bridge)
        self.assertIn('liquids[liquid.id] += amount;', liquid_bridge)
        self.assertIn('current = liquid;', liquid_bridge)
        self.assertIn('public void remove(Liquid liquid, float amount){', liquid_bridge)
        self.assertIn('add(liquid, Math.max(-amount, -liquids[liquid.id]));', liquid_bridge)
        self.assertIn('liquidCapacity = 100f;', liquid_bridge)
        # Scaling is the 1f def constant, output_dir -1; the
        # dump cursor starts at the Java default 0 in a fresh
        # frame. The dump runs through the shared
        # dump_liquid_state helper (the pump / factory
        # precedent) with the incrementDump cursor callback --
        # no local re-implementation, no helper modification.
        self.assertIn('SOURCE_LIQUID_BRIDGE_DUMP_SCALING := 1.0', liquid_bridge)
        self.assertIn('SOURCE_LIQUID_BRIDGE_DUMP_OUTPUT_DIR := -1', liquid_bridge)
        self.assertIn('"cdump": 0', liquid_bridge)
        self.assertIn('preload("res://src/game/SourceBuildingLiquidState.gd")', liquid_bridge)
        self.assertIn('preload("res://src/game/SourceBuildingItemDumpState.gd")', liquid_bridge)
        self.assertIn('dump_liquid_state(liquid_id, SOURCE_LIQUID_BRIDGE_DUMP_SCALING, SOURCE_LIQUID_BRIDGE_DUMP_OUTPUT_DIR', liquid_bridge)
        self.assertIn('increment_dump_cursor_state', liquid_bridge)
        # The driver wires the dump into the live tick in the
        # unlinked branch only (after the N2197 had_valid_link
        # recompute and the N2275 transport advance, which
        # already zeroed warmup when unlinked and left the
        # store untouched): the neighbour arrays are frame
        # inputs (the N2276 precedent, default []), and the
        # dumped store + cursor persist to the sprite meta
        # and the frame. The linked branch never dumps.
        self.assertIn('source_liquid_bridge_do_dump_state(frame, bool(frame.get("had_valid_link", false)), advanced["liquids_after"], SOURCE_LIQUID_BRIDGE_LIQUID_CAPACITY, dump_neighbours)', liquid_bridge)
        self.assertIn('frame["cdump"] = dumped["cursor_after"]', liquid_bridge)
        self.assertIn('dumped["liquids_after"]', liquid_bridge)
        self.assertIn('dump_neighbour_amounts', liquid_bridge)
        self.assertIn('dump_neighbour_capacities', liquid_bridge)
        self.assertIn('dump_neighbour_accepts', liquid_bridge)
        # The documented limits now record doDump as live and
        # the remaining deferrals (the reaction branch, the
        # timerCheckMoved snapshot, the live neighbour fill,
        # the neighbour write-back); the old "doDump defers"
        # text is gone. The N2275 transport advance, the
        # N2198 gate, the N2197 link frame state, and the
        # N2199 auto-link are preserved.
        self.assertIn('doDump live (N2287)', liquid_bridge)
        self.assertNotIn('doDump (LiquidBridge.java:29-31) defer', liquid_bridge)
        self.assertIn('updateTransport advance live (N2275)', liquid_bridge)
        self.assertIn('shouldConsume gate live (N2198)', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_update_transport_state', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_should_consume_state', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_power_status_row_state', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_auto_link_placement_state', liquid_bridge)
        # The proof's keys drive the pure dump (the fraction
        # transfer at scaling 1f, the room cap, no transfer
        # when the neighbour is fuller / equal / rejecting /
        # liquid-less / undumpable, dump only when unlinked,
        # no transfer at or below the 0.0001f threshold, the
        # cursor advancing every iteration, and the live tick
        # dumping out of the placed bridge). Static checks:
        # the proof preloads the family state file that
        # exists, and the scene file references the proof
        # script that exists.
        proof = LIQUID_BRIDGE_DO_DUMP_PROOF.read_text(encoding='utf-8')
        for key in [
            'dump_transfers_to_neighbour',
            'dump_scales_by_one',
            'dump_no_transfer_when_neighbour_full',
            'dump_only_when_unlinked',
            'dump_no_transfer_below_threshold',
            'dump_cursor_advances',
            'live_tick_dumps_liquid',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceLiquidBridgeBuildState.gd")', proof)
        self.assertTrue(LIQUID_BRIDGE_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = LIQUID_BRIDGE_DO_DUMP_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07LiquidBridgeDoDumpProof.gd', scene)
        self.assertIn('C07LiquidBridgeDoDumpProof', scene)

    def test_reference_graph_and_actual_c07_liquid_bridge_do_dump(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LiquidBridgeDoDumpProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIQUID_BRIDGE_DO_DUMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'dump_transfers_to_neighbour',
            'dump_scales_by_one',
            'dump_no_transfer_when_neighbour_full',
            'dump_only_when_unlinked',
            'dump_no_transfer_below_threshold',
            'dump_cursor_advances',
            'live_tick_dumps_liquid',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
