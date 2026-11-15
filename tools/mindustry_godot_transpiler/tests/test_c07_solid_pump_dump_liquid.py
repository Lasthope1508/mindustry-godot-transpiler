import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOLID_PUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceSolidPumpBuildState.gd'
SOLID_PUMP_DUMP_LIQUID_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SolidPumpDumpLiquidProof.gd'
SOLID_PUMP_DUMP_LIQUID_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SolidPumpDumpLiquidProof.tscn'


class C07SolidPumpDumpLiquidTests(unittest.TestCase):
    def test_c07_solid_pump_dump_liquid_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2286']['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_dump_liquid_state')
        # N2150 proved the SolidPump family's live power read,
        # N2206 proved the shouldConsume gate, and N2220 proved
        # the updateTile advance (warmup / pumpTime / lastPump
        # / maxPump / fraction) -- but the advance pumped into
        # a store that never drained: dumpLiquid(result)
        # (SolidPump.java:140, unconditional, after pumpTime +=
        # warmup * edelta() at :138) was RED-deferred all
        # along, so a water-extractor filled to capacity and
        # stopped consuming. N2286 is the dump rows:
        # dumpLiquid(Liquid) (BuildingComp.java:877-878) scales
        # by 2f with any output direction (-1, :881-882); the
        # impl (:886-908) early-returns at <= 0.0001f, unlocks
        # the liquid on campaign (:891), then scans proximity
        # from the cdump cursor, incrementDump once per
        # iteration (:894), gating on other.block.hasLiquids &&
        # canDumpLiquid && other.liquids != null (:901) and
        # transferring (fract - ofract) * block.liquidCapacity
        # / scaling when ofract < fract (:905); transferLiquid
        # (:914-921) flows min(neighbour free capacity, amount)
        # only when next.acceptLiquid(self(), liquid). The dump
        # is UNCONDITIONAL -- unlike the pump branch
        # (SolidPump.java:126, efficiency > 0), it runs even at
        # efficiency 0. Three new result symbols: the liquids
        # after the tick, the dumped amount, and the cursor.
        self.assertEqual(
            ledger['N2286']['source_symbols'],
            [
                'source_solid_pump_dump_liquid_state_result.liquids_after',
                'source_solid_pump_dump_liquid_state_result.dumped_amount',
                'source_solid_pump_dump_liquid_state_result.cursor_after',
            ],
        )
        for name in ledger['N2286']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/SolidPump.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_dump_liquid_state')
        self.assertEqual(ledger['N2286']['runtime_proof'], '/root/C07SolidPumpDumpLiquidProof')
        self.assertEqual(
            ledger['N2286']['tests'],
            [
                'test_c07_solid_pump_dump_liquid_registration',
                'test_all_c07_solid_pump_dump_liquid_input_evidence_is_exact',
                'test_solid_pump_dump_liquid_state',
                'test_reference_graph_and_actual_c07_solid_pump_dump_liquid',
            ],
        )
        self.assertTrue(ledger['N2286']['deferred_exprs'])
        # This slice resolves the dump half of the combined
        # N2220 "SolidPump dumpLiquid + updateEffect" entry and
        # narrows it to an updateEffect-only entry; it adds the
        # neighbour live fill, the neighbour write-back, and
        # the campaign-unlock surfacing deferrals. The live
        # fraction fill entry stays: the dump reads the store
        # as-is, and the onProximityUpdate fill still waits for
        # its own slice.
        self.assertFalse(any(entry.startswith('SolidPump dumpLiquid + updateEffect (') for entry in ledger['N2286']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump updateEffect chance rows (') for entry in ledger['N2286']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump dump neighbour live fill (') for entry in ledger['N2286']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump dump neighbour write-back (') for entry in ledger['N2286']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump dumpLiquid campaign unlock surfacing (') for entry in ledger['N2286']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump updateTile live fraction fill (') for entry in ledger['N2286']['deferred_exprs']))

    def test_all_c07_solid_pump_dump_liquid_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2286']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_dump_liquid_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/SolidPump.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2286']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_solid_pump_dump_liquid_state(self):
        solid_pump = SOLID_PUMP_STATE.read_text(encoding='utf-8')
        # The pure dump lives on the solid-pump build state:
        # dumpLiquid(result) (SolidPump.java:140) runs
        # UNCONDITIONALLY after pumpTime += warmup * edelta()
        # (:138) -- after the pump branch (:126-136), so the
        # dump drains the store the advance filled THIS tick,
        # and with no efficiency gate, so it runs even when
        # efficiency is 0. dumpLiquid(Liquid)
        # (BuildingComp.java:877-878) scales by 2f with any
        # output direction (-1, :881-882); the impl (:886-908)
        # early-returns when the store holds <= 0.0001f,
        # unlocks the liquid on campaign (:891), then scans
        # proximity from the cdump cursor, incrementDump once
        # per iteration (:894), gating on other.block.
        # hasLiquids && canDumpLiquid(other, liquid) &&
        # other.liquids != null (:901) after the
        # getLiquidDestination hop (:899, default returns self,
        # :980-982), and transferring (fract - ofract) *
        # block.liquidCapacity / scaling when ofract < fract
        # (:905); transferLiquid (:914-921) flows min(neighbour
        # free capacity, amount) only when next.acceptLiquid
        # (self(), liquid). A full scan over N neighbours
        # advances the cursor N times -- a full cycle, so the
        # cursor ends where it started. Keep each Java expr on
        # ONE comment line (the N2148 shootWarmup lesson: a
        # split line fails this test).
        self.assertIn('static func source_solid_pump_dump_liquid_state', solid_pump)
        self.assertIn('dumpLiquid(result);', solid_pump)
        self.assertIn('pumpTime += warmup * edelta();', solid_pump)
        self.assertIn('public void dumpLiquid(Liquid liquid){', solid_pump)
        self.assertIn('dumpLiquid(liquid, 2f);', solid_pump)
        self.assertIn('public void dumpLiquid(Liquid liquid, float scaling){', solid_pump)
        self.assertIn('dumpLiquid(liquid, scaling, -1);', solid_pump)
        self.assertIn('public void dumpLiquid(Liquid liquid, float scaling, int outputDir){', solid_pump)
        self.assertIn('int dump = this.cdump;', solid_pump)
        self.assertIn('if(liquids.get(liquid) <= 0.0001f) return;', solid_pump)
        self.assertIn('if(!net.client() && state.isCampaign() && team == state.rules.defaultTeam) liquid.unlock();', solid_pump)
        self.assertIn('for(int i = 0; i < proximity.size; i++){', solid_pump)
        self.assertIn('incrementDump(proximity.size);', solid_pump)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', solid_pump)
        self.assertIn('if(outputDir != -1 && (outputDir + rotation) % 4 != relativeTo(other)) continue;', solid_pump)
        self.assertIn('other = other.getLiquidDestination(self(), liquid);', solid_pump)
        self.assertIn('if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){', solid_pump)
        self.assertIn('float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;', solid_pump)
        self.assertIn('float fract = liquids.get(liquid) / block.liquidCapacity;', solid_pump)
        self.assertIn('if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);', solid_pump)
        self.assertIn('public boolean canDumpLiquid(Building to, Liquid liquid){', solid_pump)
        self.assertIn('public void transferLiquid(Building next, float amount, Liquid liquid){', solid_pump)
        self.assertIn('float flow = Math.min(next.block.liquidCapacity - next.liquids.get(liquid), amount);', solid_pump)
        self.assertIn('if(next.acceptLiquid(self(), liquid)){', solid_pump)
        self.assertIn('next.handleLiquid(self(), liquid, flow);', solid_pump)
        self.assertIn('liquids.remove(liquid, flow);', solid_pump)
        self.assertIn('public Building getLiquidDestination(Building from, Liquid liquid){', solid_pump)
        self.assertIn('return self();', solid_pump)
        self.assertIn('public void incrementDump(int prox){', solid_pump)
        self.assertIn('if(prox != 0){', solid_pump)
        self.assertIn('cdump = ((cdump + 1) % prox);', solid_pump)
        self.assertIn('transient int cdump;', solid_pump)
        self.assertIn('public Liquid result = Liquids.water;', solid_pump)
        self.assertIn('liquidCapacity = 40f;', solid_pump)
        # The dump reuses the shared liquid routing -- the
        # dumpLiquid port SourceBuildingLiquidState.
        # dump_liquid_state (which binds transfer_liquid_state,
        # the scenario-pump precedent) with the shared
        # increment_dump_cursor_state callback, never a
        # hand-rolled routing loop; the store write-back reuses
        # the shared liquid module helper (source_set_state,
        # the scenario-pump precedent), not a re-implementation.
        # The result liquid is water and the capacity the def
        # constant 40f, both driver constants from N2206/N2220.
        self.assertIn('source_building_liquid_state.dump_liquid_state(', solid_pump)
        self.assertIn('Callable(source_building_item_dump_state, "increment_dump_cursor_state")', solid_pump)
        self.assertIn('source_liquid_module_state.source_set_state(', solid_pump)
        self.assertIn('const source_building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")', solid_pump)
        self.assertIn('const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")', solid_pump)
        self.assertIn('SOURCE_SOLID_PUMP_RESULT_LIQUID', solid_pump)
        self.assertIn('SOURCE_SOLID_PUMP_LIQUID_CAPACITY', solid_pump)
        # The frame carries the dump cursor at the Java field
        # default: cdump 0 (BuildingComp.java:68); the
        # neighbour liquid amounts / capacities / accepts /
        # canDump arrays are frame inputs (default [] -- no
        # neighbours, the Java proximity.size == 0 outcome)
        # until a live proximity fill lands. The tick wires the
        # dump into the live loop AFTER the advance (Java
        # order: SolidPump.java:140 after :138), inside the
        # same enabled gate as the advance
        # (BuildingComp.java:2276-2277), with the result id and
        # the def capacity the advance already reads.
        self.assertIn('"cdump": 0', solid_pump)
        self.assertIn('frame.get("dump_neighbour_liquid_amounts", [])', solid_pump)
        self.assertIn('frame.get("dump_neighbour_liquid_capacities", [])', solid_pump)
        self.assertIn('frame.get("dump_neighbour_accepts_liquid", [])', solid_pump)
        self.assertIn('frame.get("dump_neighbour_can_dump_liquid", [])', solid_pump)
        self.assertIn('source_solid_pump_dump_liquid_state(frame, advance_result_id, SOURCE_SOLID_PUMP_LIQUID_CAPACITY, neighbour_amounts, neighbour_capacities, neighbour_accepts, neighbour_can_dump)', solid_pump)
        self.assertIn('frame["liquids"]', solid_pump)
        self.assertIn('frame["cdump"]', solid_pump)
        self.assertLess(
            solid_pump.index('source_solid_pump_update_tile_advance_state(frame, source_delta, time_scale, advance_result_id, SOURCE_SOLID_PUMP_LIQUID_CAPACITY, SOURCE_SOLID_PUMP_PUMP_AMOUNT)'),
            solid_pump.index('source_solid_pump_dump_liquid_state(frame, advance_result_id, SOURCE_SOLID_PUMP_LIQUID_CAPACITY, neighbour_amounts, neighbour_capacities, neighbour_accepts, neighbour_can_dump)'),
        )
        # The documented limits now record the dump as live
        # (dumpLiquid(result) unconditional after pumpTime) and
        # the remaining deferrals (the live onProximityUpdate
        # fill, the updateEffect chance); the N2220 advance,
        # the N2206 gate, and the N2150 power row are preserved.
        self.assertIn('Dump rows live (N2286)', solid_pump)
        self.assertIn('updateTile advance live (N2220)', solid_pump)
        self.assertIn('shouldConsume gate live (N2206)', solid_pump)
        self.assertIn('static func source_solid_pump_power_status_row_state', solid_pump)
        self.assertIn('static func source_solid_pump_should_consume_state', solid_pump)
        self.assertIn('static func source_solid_pump_update_tile_advance_state', solid_pump)
        # The pure N2220 advance is untouched: its return dict
        # keeps exactly the five N2220 keys and the dump wires
        # AFTER its call, never inside it.
        self.assertIn('return {"warmup": next_warmup, "pump_time": next_pump_time, "last_pump": last_pump, "max_pump": max_pump, "fraction": fraction}', solid_pump)
        # The proof's keys drive the pure dump (the fraction
        # transfer (fract - ofract) * capacity / scaling with
        # the neighbour-capacity flow clamp, the 2f scaling,
        # no transfer when the neighbour is fuller or equal,
        # the acceptLiquid / canDumpLiquid gates, the dump
        # running at efficiency 0, the 0.0001f threshold) plus
        # the live tick (a placed water-extractor dumps to an
        # accepting neighbour in one tick).
        proof = SOLID_PUMP_DUMP_LIQUID_PROOF.read_text(encoding='utf-8')
        for key in [
            'dump_transfers_to_neighbour',
            'dump_scales_by_two',
            'dump_no_transfer_when_neighbour_full',
            'dump_runs_when_efficiency_zero',
            'dump_no_transfer_below_threshold',
            'live_tick_dumps_liquid',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceSolidPumpBuildState.gd")', proof)
        self.assertTrue(SOLID_PUMP_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('solid_pump_build_state.source_solid_pump_dump_liquid_state(', proof)
        self.assertIn('solid_pump_build_state.source_solid_pump_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = SOLID_PUMP_DUMP_LIQUID_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07SolidPumpDumpLiquidProof.gd', scene)
        self.assertIn('C07SolidPumpDumpLiquidProof', scene)

    def test_reference_graph_and_actual_c07_solid_pump_dump_liquid(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SolidPumpDumpLiquidProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOLID_PUMP_DUMP_LIQUID_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'dump_transfers_to_neighbour',
            'dump_scales_by_two',
            'dump_no_transfer_when_neighbour_full',
            'dump_runs_when_efficiency_zero',
            'dump_no_transfer_below_threshold',
            'live_tick_dumps_liquid',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
