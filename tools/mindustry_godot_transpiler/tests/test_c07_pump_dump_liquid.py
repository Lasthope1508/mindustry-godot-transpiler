import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MECHANICAL_PUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceMechanicalPumpBuildState.gd'
PUMP_DUMP_LIQUID_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PumpDumpLiquidProof.gd'
PUMP_DUMP_LIQUID_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PumpDumpLiquidProof.tscn'


class C07PumpDumpLiquidTests(unittest.TestCase):
    def test_c07_pump_dump_liquid_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2285']['godot_owner'], 'SourceMechanicalPumpBuildState.source_mechanical_pump_dump_liquid_state')
        # N2154 proved the mechanical-pump family's live power
        # read, N2205 gated shouldConsume on the live
        # liquidDrop / liquids / capacity / enabled, and N2221
        # advanced maxPump / liquids.add / warmup /
        # totalProgress / consTimer -- but the placed pump
        # never dumped anything: dumpLiquid (Pump.java:178-180)
        # was RED-deferred all along, because the
        # scenario-path dump helper
        # (SourcePumpRuntimeState.source_pump_dump_liquid_state,
        # N2090) is bound to the scenario frame and its own
        # capacity. N2285 is the placed-path dump: after the
        # N2221 advance, when liquidDrop != null, the pump
        # dumps through the shared liquid routing
        # (SourceBuildingLiquidState.dump_liquid_state) at the
        # dumpLiquid(Liquid) scaling 2f (BuildingComp.java:
        # 877-878), any output direction (-1), with the
        # per-neighbour fraction transfer (BuildingComp.java:
        # 901-905) and the acceptLiquid gate
        # (BuildingComp.java:914-921). The pure function is
        # named source_mechanical_pump_dump_liquid_state, NOT
        # the brief's source_pump_dump_liquid_state: that
        # prefix is already owned by the N2090 scenario helper
        # (its input/result schemas + result symbols), and
        # reusing it would overwrite N2090's SSOT entries.
        # Three new result symbols: the store after the dump,
        # the dumped amount, and the cursor after the tick.
        self.assertEqual(
            ledger['N2285']['source_symbols'],
            [
                'source_mechanical_pump_dump_liquid_state_result.liquids_after',
                'source_mechanical_pump_dump_liquid_state_result.dumped_amount',
                'source_mechanical_pump_dump_liquid_state_result.cursor_after',
            ],
        )
        for name in ledger['N2285']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Pump.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceMechanicalPumpBuildState.source_mechanical_pump_dump_liquid_state')
        self.assertEqual(ledger['N2285']['runtime_proof'], '/root/C07PumpDumpLiquidProof')
        self.assertEqual(
            ledger['N2285']['tests'],
            [
                'test_c07_pump_dump_liquid_registration',
                'test_all_c07_pump_dump_liquid_input_evidence_is_exact',
                'test_pump_dump_liquid_state',
                'test_reference_graph_and_actual_c07_pump_dump_liquid',
            ],
        )
        self.assertTrue(ledger['N2285']['deferred_exprs'])
        # This slice resolves the placed-pump dumpLiquid
        # deferral and adds the neighbour live fill, the
        # neighbour write-back, and the campaign unlock
        # deferrals. The SolidPump / Fracker dump entries stay:
        # they belong to N2284 / N2286.
        self.assertFalse(any(entry.startswith('Pump dumpLiquid on the placed-pump path (') for entry in ledger['N2285']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Pump dump neighbour live fill (') for entry in ledger['N2285']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Pump dump neighbour write-back (') for entry in ledger['N2285']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Pump dumpLiquid campaign unlock application (') for entry in ledger['N2285']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump dumpLiquid + updateEffect (') for entry in ledger['N2285']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker dumpLiquid (else branch) (') for entry in ledger['N2285']['deferred_exprs']))

    def test_all_c07_pump_dump_liquid_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2285']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceMechanicalPumpBuildState.source_mechanical_pump_dump_liquid_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Pump.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2285']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_pump_dump_liquid_state(self):
        pump = MECHANICAL_PUMP_STATE.read_text(encoding='utf-8')
        # The pure dump is the updateTile tail
        # (PumpBuild.updateTile(), Pump.java:160-182): after
        # `totalProgress += warmup * Time.delta;`
        # (Pump.java:176), `if(liquidDrop != null){`
        # `dumpLiquid(liquidDrop);` (Pump.java:178-180) --
        # OUTSIDE the efficiency branch, so a pump dumps even
        # at zero efficiency. dumpLiquid(Liquid)
        # (BuildingComp.java:877-878):
        # `public void dumpLiquid(Liquid liquid){`
        # `dumpLiquid(liquid, 2f);` scales by 2f through
        # `public void dumpLiquid(Liquid liquid, float scaling){`
        # `dumpLiquid(liquid, scaling, -1);`
        # (BuildingComp.java:881-882) into the implementation
        # (BuildingComp.java:886-908):
        # `public void dumpLiquid(Liquid liquid, float scaling, int outputDir){`
        # `int dump = this.cdump;`
        # `if(liquids.get(liquid) <= 0.0001f) return;`
        # `if(!net.client() && state.isCampaign() && team == state.rules.defaultTeam) liquid.unlock();`
        # `for(int i = 0; i < proximity.size; i++){`
        # `incrementDump(proximity.size);`
        # `Building other = proximity.get((i + dump) % proximity.size);`
        # `if(outputDir != -1 && (outputDir + rotation) % 4 != relativeTo(other)) continue;`
        # `other = other.getLiquidDestination(self(), liquid);`
        # `if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){`
        # `float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;`
        # `float fract = liquids.get(liquid) / block.liquidCapacity;`
        # `if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);`
        # canDumpLiquid defaults to true
        # (`public boolean canDumpLiquid(Building to, Liquid liquid){`,
        # BuildingComp.java:910-912); transferLiquid
        # (BuildingComp.java:914-921):
        # `public void transferLiquid(Building next, float amount, Liquid liquid){`
        # `float flow = Math.min(next.block.liquidCapacity - next.liquids.get(liquid), amount);`
        # `if(next.acceptLiquid(self(), liquid)){`
        # `next.handleLiquid(self(), liquid, flow);`
        # `liquids.remove(liquid, flow);`
        # -- flow is min(neighbour free capacity, amount), and
        # the transfer happens only when the neighbour accepts.
        # The cursor advances once per iteration (incrementDump,
        # BuildingComp.java:1116-1121):
        # `public void incrementDump(int prox){`
        # `if(prox != 0){`
        # `cdump = ((cdump + 1) % prox);`
        # -- a full loop runs incrementDump proximity.size
        # times, so the cursor wraps back to its start value;
        # the rotation shows in WHICH neighbour is tried
        # first, not in the final cursor. The dump field is
        # `transient int cdump;` (BuildingComp.java:68, 0).
        # Keep each Java expr on ONE comment line (the N2148
        # shootWarmup lesson: a split line fails this test).
        self.assertIn('static func source_mechanical_pump_dump_liquid_state', pump)
        self.assertIn('if(liquidDrop != null){', pump)
        self.assertIn('dumpLiquid(liquidDrop);', pump)
        self.assertIn('totalProgress += warmup * Time.delta;', pump)
        self.assertIn('public void dumpLiquid(Liquid liquid){', pump)
        self.assertIn('dumpLiquid(liquid, 2f);', pump)
        self.assertIn('public void dumpLiquid(Liquid liquid, float scaling){', pump)
        self.assertIn('dumpLiquid(liquid, scaling, -1);', pump)
        self.assertIn('public void dumpLiquid(Liquid liquid, float scaling, int outputDir){', pump)
        self.assertIn('int dump = this.cdump;', pump)
        self.assertIn('if(liquids.get(liquid) <= 0.0001f) return;', pump)
        self.assertIn('if(!net.client() && state.isCampaign() && team == state.rules.defaultTeam) liquid.unlock();', pump)
        self.assertIn('for(int i = 0; i < proximity.size; i++){', pump)
        self.assertIn('incrementDump(proximity.size);', pump)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', pump)
        self.assertIn('if(outputDir != -1 && (outputDir + rotation) % 4 != relativeTo(other)) continue;', pump)
        self.assertIn('other = other.getLiquidDestination(self(), liquid);', pump)
        self.assertIn('if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){', pump)
        self.assertIn('float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;', pump)
        self.assertIn('float fract = liquids.get(liquid) / block.liquidCapacity;', pump)
        self.assertIn('if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);', pump)
        self.assertIn('public boolean canDumpLiquid(Building to, Liquid liquid){', pump)
        self.assertIn('public void transferLiquid(Building next, float amount, Liquid liquid){', pump)
        self.assertIn('float flow = Math.min(next.block.liquidCapacity - next.liquids.get(liquid), amount);', pump)
        self.assertIn('if(next.acceptLiquid(self(), liquid)){', pump)
        self.assertIn('next.handleLiquid(self(), liquid, flow);', pump)
        self.assertIn('liquids.remove(liquid, flow);', pump)
        self.assertIn('public void incrementDump(int prox){', pump)
        self.assertIn('if(prox != 0){', pump)
        self.assertIn('cdump = ((cdump + 1) % prox);', pump)
        self.assertIn('transient int cdump;', pump)
        # The dump reuses the shared liquid routing -- the
        # SourceBuildingLiquidState.dump_liquid_state wrapper
        # (the SourceBuildingLiquidDumpState port with the
        # transferLiquid callable bound), with the shared
        # incrementDump cursor callable -- never a hand-rolled
        # routing loop. The scenario-path helper stays
        # untouched: this placed-path pure function takes the
        # neighbour arrays as explicit inputs instead of
        # scanning the scenario world.
        self.assertIn('const source_building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")', pump)
        self.assertIn('const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")', pump)
        self.assertIn('source_building_liquid_state.dump_liquid_state(', pump)
        self.assertIn('Callable(source_building_item_dump_state, "increment_dump_cursor_state")', pump)
        # The frame carries the dump cursor at the Java field
        # default (cdump 0, BuildingComp.java:68); the
        # neighbour arrays are frame inputs (default [] -- no
        # neighbours, the Java proximity.size == 0 outcome)
        # until a live proximity fill lands. The tick wires the
        # dump into the live loop AFTER the N2221 advance
        # (Java order: Pump.java:178-180 runs after :176), so
        # the dump drains the store the advance filled THIS
        # tick; the driver writes the dumped store back through
        # the shared liquid module source_set_state (the
        # scenario pump precedent) and persists the cursor on
        # the frame.
        self.assertIn('frame.get("cdump", 0)', pump)
        self.assertIn('frame.get("dump_neighbour_amounts", [])', pump)
        self.assertIn('frame.get("dump_neighbour_capacities", [])', pump)
        self.assertIn('frame.get("dump_neighbour_accepts", [])', pump)
        self.assertIn('frame.get("dump_neighbour_can_dump", [])', pump)
        self.assertIn('source_mechanical_pump_dump_liquid_state(frame, proximity.get("liquid_drop", null), liquids, _liquid_capacity_for_block_id(block_id), liquid_id_by_name, neighbour_amounts, neighbour_capacities, neighbour_accepts, neighbour_can_dump)', pump)
        self.assertIn('frame["cdump"]', pump)
        self.assertIn('source_set_state(liquids, liquid_id, float(liquids_after["liquids"][liquid_id]))', pump)
        self.assertLess(
            pump.index('source_mechanical_pump_update_tile_advance_state(frame, proximity.get("liquid_drop", null), float(proximity.get("amount", 0.0)), liquids, _liquid_capacity_for_block_id(block_id), _pump_amount_for_block_id(block_id), source_delta, time_scale, liquid_id_by_name)'),
            pump.index('source_mechanical_pump_dump_liquid_state(frame, proximity.get("liquid_drop", null), liquids, _liquid_capacity_for_block_id(block_id), liquid_id_by_name, neighbour_amounts, neighbour_capacities, neighbour_accepts, neighbour_can_dump)'),
        )
        # The documented limits now record the dump as live
        # (dumpLiquid after the advance) and the remaining
        # deferrals (the neighbour live fill, the neighbour
        # write-back, the campaign unlock); the N2221 advance,
        # the N2205 gate, and the N2154 power row are
        # preserved.
        self.assertIn('Dump rows live (N2285)', pump)
        self.assertIn('updateTile advance (N2221)', pump)
        self.assertIn('shouldConsume gate live (N2205)', pump)
        self.assertIn('static func source_mechanical_pump_power_status_row_state', pump)
        self.assertIn('static func source_mechanical_pump_should_consume_state', pump)
        self.assertIn('static func source_mechanical_pump_update_tile_advance_state', pump)
        # The proof's keys drive the pure dump (the fraction
        # transfer to an emptier neighbour, the scaling-2f
        # halving, no transfer to a fuller neighbour, the
        # liquidDrop-null skip, the 0.0001f threshold) plus
        # the live tick (a placed rotary-pump pumps and dumps
        # on one 1/60s tick, the dump draining what the
        # advance pumped).
        proof = PUMP_DUMP_LIQUID_PROOF.read_text(encoding='utf-8')
        for key in [
            'dump_transfers_to_neighbour',
            'dump_scales_by_two',
            'dump_no_transfer_when_neighbour_full',
            'dump_skipped_when_no_liquid_drop',
            'dump_no_transfer_below_threshold',
            'live_tick_dumps_liquid',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceMechanicalPumpBuildState.gd")', proof)
        self.assertTrue(MECHANICAL_PUMP_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state(', proof)
        self.assertIn('mechanical_pump_build_state.source_mechanical_pump_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertIn('write_proof("C07PumpDumpLiquidProof"', proof)
        scene = PUMP_DUMP_LIQUID_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PumpDumpLiquidProof.gd', scene)
        self.assertIn('[node name="C07PumpDumpLiquidProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_pump_dump_liquid(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PumpDumpLiquidProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PUMP_DUMP_LIQUID_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'dump_transfers_to_neighbour',
            'dump_scales_by_two',
            'dump_no_transfer_when_neighbour_full',
            'dump_skipped_when_no_liquid_drop',
            'dump_no_transfer_below_threshold',
            'live_tick_dumps_liquid',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
