import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FRACKER_STATE = ROOT / 'godot-mindustry/src/game/SourceFrackerBuildState.gd'
LIQUID_DUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingLiquidState.gd'
ITEM_DUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingItemDumpState.gd'
FRACKER_DUMP_LIQUID_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerDumpLiquidProof.gd'
FRACKER_DUMP_LIQUID_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerDumpLiquidProof.tscn'


class C07FrackerDumpLiquidTests(unittest.TestCase):
    def test_c07_fracker_dump_liquid_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2284']['godot_owner'], 'SourceFrackerBuildState.source_fracker_dump_liquid_state')
        # N2153 proved the Fracker family's live power read,
        # N2207 proved the shouldConsume gate, N2224 proved
        # the updateTile advance (which pumps oil into the
        # store through the reused N2220 pure function) and
        # N2255/N2268 proved the water/sand consumer rows --
        # but the pumped oil never left the building: BOTH
        # updateTile branches end in dumpLiquid(result) (the
        # if-branch through super.updateTile(),
        # Fracker.java:37, whose SolidPump.updateTile ends in
        # dumpLiquid(result), SolidPump.java:140; the
        # else-branch directly, Fracker.java:42), and neither
        # dump ran. N2284 is the dumpLiquid rows: the shared
        # dump_liquid_state routing (scaling 2f, the
        # dumpLiquid(Liquid) overload, BuildingComp.java:
        # 877-878) transfers (fract - ofract) * capacity / 2
        # to each eligible neighbour, gated on the threshold,
        # the routing gate and acceptLiquid. Three new result
        # symbols: the liquids after the tick, the dumped
        # amount, and the cursor after the tick.
        self.assertEqual(
            ledger['N2284']['source_symbols'],
            [
                'source_fracker_dump_liquid_state_result.liquids_after',
                'source_fracker_dump_liquid_state_result.dumped_amount',
                'source_fracker_dump_liquid_state_result.cursor_after',
            ],
        )
        for name in ledger['N2284']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Fracker.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_dump_liquid_state')
        self.assertEqual(ledger['N2284']['runtime_proof'], '/root/C07FrackerDumpLiquidProof')
        self.assertEqual(
            ledger['N2284']['tests'],
            [
                'test_c07_fracker_dump_liquid_registration',
                'test_all_c07_fracker_dump_liquid_input_evidence_is_exact',
                'test_fracker_dump_liquid_state',
                'test_reference_graph_and_actual_c07_fracker_dump_liquid',
            ],
        )
        self.assertTrue(ledger['N2284']['deferred_exprs'])
        # This slice resolves the Fracker else-branch dump
        # deferral and adds the neighbour live fill + the
        # neighbour write-back + the campaign unlock
        # deferrals. The N2220 "SolidPump dumpLiquid +
        # updateEffect" entry STAYS: the pure N2220 still
        # does not dump (the SolidPump-driver dump is
        # N2286's slice) -- the Fracker if-branch dump is
        # live only through this slice's tick wiring after
        # the advance. The fraction fill and the sand intake
        # entries stay too.
        self.assertFalse(any(entry.startswith('Fracker dumpLiquid (else branch) (') for entry in ledger['N2284']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker dumpLiquid neighbour live fill (') for entry in ledger['N2284']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker dumpLiquid neighbour write-back (') for entry in ledger['N2284']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker dumpLiquid campaign unlock (') for entry in ledger['N2284']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump dumpLiquid + updateEffect (') for entry in ledger['N2284']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker water-attribute / validTiles / boost fraction rows (') for entry in ledger['N2284']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker item intake (') for entry in ledger['N2284']['deferred_exprs']))

    def test_all_c07_fracker_dump_liquid_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2284']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_dump_liquid_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Fracker.java',
            'core/src/mindustry/world/blocks/production/SolidPump.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2284']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_fracker_dump_liquid_state(self):
        fracker = FRACKER_STATE.read_text(encoding='utf-8')
        # The pure dump lives on the Fracker build state: BOTH
        # updateTile branches end in dumpLiquid(result) -- the
        # if-branch through super.updateTile()
        # (Fracker.java:37), whose SolidPump.updateTile ends
        # in dumpLiquid(result) (SolidPump.java:140,
        # unconditional, after pumpTime += warmup * edelta(),
        # :138), and the else-branch directly (Fracker.java:
        # 42, after the warmup decay :40 and lastPump = 0f
        # :41 -- the brief/SCOPE/DEFERRED cite :43 is one
        # line off, verified by grep). dumpLiquid(Liquid) is
        # the 2f overload (BuildingComp.java:877-878), which
        # delegates to the scaling overload (:881-882) and
        # then the output-dir impl (:886-908): the cdump
        # snapshot, the <= 0.0001f early return BEFORE the
        # loop (so an empty store leaves cdump untouched),
        # the campaign unlock (:891, NOT modeled -- the frame
        # carries no net/campaign state), the proximity loop
        # with incrementDump EVERY iteration (before the
        # output-dir filter, so the cursor advances even when
        # no neighbour takes anything), the destination
        # lookup (default returns self()), the eligibility
        # gate, and the fraction transfer (fract - ofract) *
        # capacity / scaling -- scaling 2f, so HALF the
        # fraction gap times the capacity. canDumpLiquid
        # defaults to true (:910-912); transferLiquid
        # (:914-921) flows min(neighbour free capacity,
        # amount) only when the neighbour accepts (the
        # default acceptLiquid is hasLiquids &&
        # consumesLiquid, :868-870). Keep each Java expr on
        # ONE comment line (the N2148 shootWarmup lesson: a
        # split line fails this test).
        self.assertIn('static func source_fracker_dump_liquid_state', fracker)
        self.assertIn('dumpLiquid(result);', fracker)
        self.assertIn('super.updateTile();', fracker)
        self.assertIn('pumpTime += warmup * edelta();', fracker)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, 0f, 0.02f);', fracker)
        self.assertIn('lastPump = 0f;', fracker)
        self.assertIn('public void dumpLiquid(Liquid liquid){', fracker)
        self.assertIn('dumpLiquid(liquid, 2f);', fracker)
        self.assertIn('public void dumpLiquid(Liquid liquid, float scaling){', fracker)
        self.assertIn('dumpLiquid(liquid, scaling, -1);', fracker)
        self.assertIn('public void dumpLiquid(Liquid liquid, float scaling, int outputDir){', fracker)
        self.assertIn('int dump = this.cdump;', fracker)
        self.assertIn('if(liquids.get(liquid) <= 0.0001f) return;', fracker)
        self.assertIn('if(!net.client() && state.isCampaign() && team == state.rules.defaultTeam) liquid.unlock();', fracker)
        self.assertIn('for(int i = 0; i < proximity.size; i++){', fracker)
        self.assertIn('incrementDump(proximity.size);', fracker)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', fracker)
        self.assertIn('if(outputDir != -1 && (outputDir + rotation) % 4 != relativeTo(other)) continue;', fracker)
        self.assertIn('other = other.getLiquidDestination(self(), liquid);', fracker)
        self.assertIn('if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){', fracker)
        self.assertIn('float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;', fracker)
        self.assertIn('float fract = liquids.get(liquid) / block.liquidCapacity;', fracker)
        self.assertIn('if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);', fracker)
        self.assertIn('public boolean canDumpLiquid(Building to, Liquid liquid){', fracker)
        self.assertIn('public void transferLiquid(Building next, float amount, Liquid liquid){', fracker)
        self.assertIn('float flow = Math.min(next.block.liquidCapacity - next.liquids.get(liquid), amount);', fracker)
        self.assertIn('if(next.acceptLiquid(self(), liquid)){', fracker)
        self.assertIn('next.handleLiquid(self(), liquid, flow);', fracker)
        self.assertIn('liquids.remove(liquid, flow);', fracker)
        self.assertIn('public void incrementDump(int prox){', fracker)
        self.assertIn('if(prox != 0){', fracker)
        self.assertIn('cdump = ((cdump + 1) % prox);', fracker)
        self.assertIn('transient int cdump;', fracker)
        self.assertIn('public boolean acceptLiquid(Building source, Liquid liquid){', fracker)
        self.assertIn('return block.hasLiquids && block.consumesLiquid(liquid);', fracker)
        self.assertIn('public Building getLiquidDestination(Building from, Liquid liquid){', fracker)
        self.assertIn('return self();', fracker)
        self.assertIn('result = Liquids.oil;', fracker)
        self.assertIn('liquidCapacity = 40f;', fracker)
        # The dump reuses the shared liquid-dump routing --
        # SourceBuildingLiquidState.dump_liquid_state (which
        # supplies the transfer_liquid_state callable to
        # SourceBuildingLiquidDumpState.dump_liquid_state,
        # the factory / scenario-pump precedent) with the
        # cursor callback from
        # SourceBuildingItemDumpState.increment_dump_cursor_state
        # -- the pure does NOT re-implement the routing, the
        # fraction transfer, or the accept gate. The result
        # liquid is the def constant oil, the scaling is the
        # 2f overload default, the output dir is -1 (any
        # direction), and the campaign flags are false (the
        # unlock is deferred). The store write-back removes
        # the dumped amount from a DUPLICATE of the module
        # dict through the shared liquid module helper
        # (source_remove_state, which clamps like Java's
        # LiquidModule.remove) -- never source_add_state
        # (the N2224 assertNotIn) and never a hand-rolled
        # subtraction.
        self.assertIn('const source_building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")', fracker)
        self.assertIn('const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")', fracker)
        self.assertIn('source_building_liquid_state.dump_liquid_state(SOURCE_FRACKER_RESULT_LIQUID, 2.0, -1, current_amount, false, false, false', fracker)
        self.assertIn('Callable(source_building_item_dump_state, "increment_dump_cursor_state")', fracker)
        self.assertIn('source_liquid_module_state.source_remove_state(store, result_liquid_id, dumped_amount, cache_sums)', fracker)
        self.assertNotIn('source_liquid_module_state.source_add_state(', fracker)
        # N2371: the dump also exposes the handled neighbour index
        # (from the shared routing's handled_index) + the dumped
        # liquid name, so the tick can wire the neighbour
        # write-back helper after the dump.
        self.assertIn('return {"liquids_after": store, "dumped_amount": dumped_amount, "cursor_after": int(dumped.get("final_cdump", cursor)), "dump_neighbour_index": int(dumped.get("handled_index", -1)), "dumped_liquid": SOURCE_FRACKER_RESULT_LIQUID}', fracker)
        # The frame carries the dump cursor at the Java field
        # default (cdump 0, BuildingComp.java:68); the
        # neighbour entries are frame inputs (default [] --
        # no neighbours, the Java proximity.size == 0
        # outcome) until a live proximity fill lands. The
        # neighbour defaults follow Java: destination present
        # (getLiquidDestination returns self()), canDump true
        # (canDumpLiquid default), accepts false (acceptLiquid
        # needs consumesLiquid), has_liquids / liquids_present
        # false (unknown neighbour takes nothing).
        self.assertIn('"cdump": 0', fracker)
        self.assertIn('frame.get("dump_liquid_neighbours", [])', fracker)
        self.assertIn('entry.get("destination_present", true)', fracker)
        self.assertIn('entry.get("can_dump", true)', fracker)
        self.assertIn('entry.get("accepts", false)', fracker)
        self.assertIn('entry.get("has_liquids", false)', fracker)
        self.assertIn('entry.get("liquids_present", false)', fracker)
        # The tick wires the dump into the live loop AFTER the
        # advance, inside the same enabled gate as the advance
        # (BuildingComp.java:2276-2278) -- one call site
        # covers BOTH branches, because the advance above
        # already ran exactly one of them and the dump depends
        # only on the post-advance store (the accumulator
        # advance in between cannot affect it). The pure
        # returns a fresh liquids dict, so the driver persists
        # it to the frame AND the sprite meta (the N2275
        # liquid-bridge precedent -- the frame syncs from the
        # meta each tick) plus the advanced cdump. The pure
        # N2220 is untouched: the advance call string and its
        # seven write-backs are exactly as N2224 left them.
        self.assertIn('source_fracker_dump_liquid_state(frame, advance_result_id, SOURCE_FRACKER_LIQUID_CAPACITY, dump_neighbours)', fracker)
        self.assertIn('frame["liquids"] = dumped["liquids_after"]', fracker)
        self.assertIn('sprite.set_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, dumped["liquids_after"])', fracker)
        self.assertIn('frame["cdump"] = dumped["cursor_after"]', fracker)
        self.assertLess(
            fracker.index('source_fracker_update_tile_advance_state(frame, source_delta, time_scale, advance_result_id, SOURCE_FRACKER_LIQUID_CAPACITY, SOURCE_FRACKER_PUMP_AMOUNT, SOURCE_FRACKER_ITEM_USE_TIME)'),
            fracker.index('source_fracker_dump_liquid_state(frame, advance_result_id, SOURCE_FRACKER_LIQUID_CAPACITY, dump_neighbours)'),
        )
        self.assertIn('static func source_fracker_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, result_liquid_id: int, liquid_capacity: float, pump_amount: float, item_use_time: float)', fracker)
        # The documented limits now record the dump as live in
        # both branches (if-branch via super.updateTile,
        # SolidPump.java:140; else-branch Fracker.java:42 --
        # the stale :43 cite is gone) and the remaining
        # deferrals (sand intake, live fraction fill, the
        # neighbour live fill / write-back, the campaign
        # unlock); the N2153 power row, the N2207 gate, the
        # N2224 advance, the N2255 liquid row and the N2268
        # item row are preserved.
        self.assertIn('dumpLiquid live (N2284)', fracker)
        self.assertNotIn('Fracker.java:43', fracker)
        self.assertIn('updateTile advance live (N2224)', fracker)
        self.assertIn('shouldConsume gate live (N2207)', fracker)
        self.assertIn('liquid row live (N2255)', fracker)
        self.assertIn('item row live (N2268)', fracker)
        self.assertIn('static func source_fracker_power_status_row_state', fracker)
        self.assertIn('static func source_fracker_should_consume_state', fracker)
        self.assertIn('static func source_fracker_liquid_consumer_row_state', fracker)
        self.assertIn('static func source_fracker_item_consumer_row_state', fracker)
        self.assertIn('static func source_fracker_tick_buildings_state', fracker)
        # The shared helpers exist: the liquid-dump wrapper
        # (which supplies the transfer callable) and the
        # cursor increment (guarded on prox != 0, wrapping
        # modulo the proximity size).
        liquid_dump = LIQUID_DUMP_STATE.read_text(encoding='utf-8')
        self.assertIn('static func dump_liquid_state(', liquid_dump)
        self.assertIn('Callable(SourceBuildingLiquidState, "transfer_liquid_state")', liquid_dump)
        item_dump = ITEM_DUMP_STATE.read_text(encoding='utf-8')
        self.assertIn('static func increment_dump_cursor_state(current_dump: int, proximity_size: int) -> int:', item_dump)
        self.assertIn('if proximity_size != 0:', item_dump)
        self.assertIn('return (current_dump + 1) % proximity_size', item_dump)
        # The proof's keys drive the pure dump (the transfer
        # (fract - ofract) * capacity / 2 to an empty
        # neighbour, the 2f scaling halving the fraction gap,
        # no transfer when the neighbour is fuller -- with
        # the cursor still advancing -- no transfer below the
        # 0.0001f threshold with the cursor untouched) plus
        # the live tick (a placed oil-extractor dumps in both
        # branches: efficiency 1 after the pump, efficiency 0
        # after the warmup decay).
        proof = FRACKER_DUMP_LIQUID_PROOF.read_text(encoding='utf-8')
        for key in [
            'dump_transfers_to_neighbour',
            'dump_scales_by_two',
            'dump_no_transfer_when_neighbour_full',
            'dump_no_transfer_below_threshold',
            'dump_runs_in_both_branches',
            'live_tick_dumps_liquid',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        for line in proof.splitlines():
            if 'preload("res://' in line:
                res_path = line.split('preload("res://', 1)[1].split('"', 1)[0]
                with self.subTest(preload=res_path):
                    self.assertTrue((ROOT / 'godot-mindustry' / res_path).is_file(), res_path)
        self.assertIn('preload("res://src/game/SourceFrackerBuildState.gd")', proof)
        self.assertTrue(FRACKER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('fracker_build_state.source_fracker_dump_liquid_state(', proof)
        self.assertIn('fracker_build_state.source_fracker_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = FRACKER_DUMP_LIQUID_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07FrackerDumpLiquidProof.gd', scene)
        self.assertIn('C07FrackerDumpLiquidProof', scene)

    def test_reference_graph_and_actual_c07_fracker_dump_liquid(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07FrackerDumpLiquidProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FRACKER_DUMP_LIQUID_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'dump_transfers_to_neighbour',
            'dump_scales_by_two',
            'dump_no_transfer_when_neighbour_full',
            'dump_no_transfer_below_threshold',
            'dump_runs_in_both_branches',
            'live_tick_dumps_liquid',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
