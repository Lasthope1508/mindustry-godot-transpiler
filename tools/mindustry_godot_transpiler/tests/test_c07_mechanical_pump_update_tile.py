import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MECHANICAL_PUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceMechanicalPumpBuildState.gd'
MECHANICAL_PUMP_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MechanicalPumpUpdateTileProof.gd'
MECHANICAL_PUMP_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MechanicalPumpUpdateTileProof.tscn'


class C07MechanicalPumpUpdateTileTests(unittest.TestCase):
    def test_c07_mechanical_pump_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2221']['godot_owner'], 'SourceMechanicalPumpBuildState.source_mechanical_pump_update_tile_advance_state')
        # N2154 proved the mechanical-pump family's live power
        # read and N2205 gated shouldConsume on the live
        # liquidDrop / liquids / capacity / enabled -- but the
        # port tracked no warmup / totalProgress / consTimer at
        # all, so a placed pump never pumped anything into its
        # store. N2221 is the updateTile advance
        # (PumpBuild.updateTile(), Pump.java:160-182): while
        # efficiency > 0 and liquidDrop != null, maxPump =
        # min(capacity - liquids.get(liquidDrop), amount *
        # pumpAmount * edelta()) is added to the store,
        # consTimer advances by delta() and wraps at
        # consumeTime (300f) with consume() a no-op for these
        # pumps (neither rotary nor impulse consumes items,
        # Blocks.java:2304-2320), warmup approachDelta moves
        # toward 1 when it pumped (maxPump > 0.001f) and toward
        # 0 otherwise, and totalProgress += warmup *
        # Time.delta. dumpLiquid (Pump.java:178-180) waits for
        # its own slice: the scenario-path dump helper
        # (SourcePumpRuntimeState.source_pump_dump_liquid_state)
        # is bound to the scenario frame and its own capacity,
        # so the placed-pump dump is a new deferral. Five new
        # result symbols, in Java execution order: the pumped
        # amount, the post-add stored amount, the item timer,
        # the warmup, and the total progress.
        self.assertEqual(
            ledger['N2221']['source_symbols'],
            [
                'source_mechanical_pump_update_tile_advance_state_result.max_pump',
                'source_mechanical_pump_update_tile_advance_state_result.liquid_amount',
                'source_mechanical_pump_update_tile_advance_state_result.cons_timer',
                'source_mechanical_pump_update_tile_advance_state_result.warmup',
                'source_mechanical_pump_update_tile_advance_state_result.total_progress',
            ],
        )
        for name in ledger['N2221']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Pump.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceMechanicalPumpBuildState.source_mechanical_pump_update_tile_advance_state')
        self.assertEqual(ledger['N2221']['runtime_proof'], '/root/C07MechanicalPumpUpdateTileProof')
        self.assertEqual(
            ledger['N2221']['tests'],
            [
                'test_c07_mechanical_pump_update_tile_registration',
                'test_all_c07_mechanical_pump_update_tile_input_evidence_is_exact',
                'test_mechanical_pump_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_mechanical_pump_update_tile',
            ],
        )
        self.assertTrue(ledger['N2221']['deferred_exprs'])

    def test_all_c07_mechanical_pump_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2221']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceMechanicalPumpBuildState.source_mechanical_pump_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Pump.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2221']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mechanical_pump_update_tile_advance_state(self):
        pump = MECHANICAL_PUMP_STATE.read_text(encoding='utf-8')
        # The pure advance is PumpBuild.updateTile() exactly
        # (Pump.java:160-182): `if(efficiency > 0 &&
        # liquidDrop != null){` (Pump.java:161), `float maxPump
        # = Math.min(liquidCapacity - liquids.get(liquidDrop),
        # amount * pumpAmount * edelta());` (Pump.java:162),
        # `liquids.add(liquidDrop, maxPump);` (Pump.java:163),
        # `if((consTimer += delta()) >= consumeTime){`
        # (Pump.java:166) with `consTimer %= 1f;`
        # (Pump.java:168) -- consume() `//does nothing for most
        # pumps, as those do not require items.`
        # (Pump.java:165), so the timer advances and wraps and
        # consume() is a documented no-op for these pumps --
        # `warmup = Mathf.approachDelta(warmup, maxPump >
        # 0.001f ? 1f : 0f, warmupSpeed);` (Pump.java:171) in
        # the pumping branch and `warmup =
        # Mathf.approachDelta(warmup, 0f, warmupSpeed);`
        # (Pump.java:173) otherwise, `totalProgress += warmup *
        # Time.delta;` (Pump.java:176) on the NEW warmup, and
        # `dumpLiquid(liquidDrop);` (Pump.java:179) deferred to
        # its own slice. Keep each Java expr on ONE comment
        # line (the N2148 shootWarmup lesson: a split line
        # fails this test). The Arc formula is approachDelta =
        # approach(from, to, Time.delta * speed) with approach
        # = from + clamp(to - from, -speed, speed)
        # (Mathf.java:415-422), so the warmup step uses the RAW
        # source delta (Time.delta), never edelta. delta() =
        # Time.delta * timeScale and edelta() = efficiency *
        # delta() (BuildingComp.java:1922-1929), so maxPump and
        # consTimer scale with timeScale while totalProgress
        # uses raw Time.delta. Time.delta in the port is
        # seconds * 60 through game_source_delta (arc
        # Time.java:26), never raw seconds (the N2186/N2187/
        # N2191 lesson: raw seconds run 60x slow). The class
        # defaults are `public float pumpAmount = 0.2f;`
        # (Pump.java:20), `public float consumeTime = 60f *
        # 5f;` (Pump.java:22), `public float warmupSpeed =
        # 0.019f;` (Pump.java:23); the build fields default to
        # 0 (`public float warmup, totalProgress;`,
        # Pump.java:111, `public float consTimer;`,
        # Pump.java:112). The impulse-pump overrides
        # `pumpAmount = 0.22f;` (Blocks.java:2315).
        self.assertIn('static func source_mechanical_pump_update_tile_advance_state', pump)
        self.assertIn('if(efficiency > 0 && liquidDrop != null){', pump)
        self.assertIn('float maxPump = Math.min(liquidCapacity - liquids.get(liquidDrop), amount * pumpAmount * edelta());', pump)
        self.assertIn('liquids.add(liquidDrop, maxPump);', pump)
        self.assertIn('//does nothing for most pumps, as those do not require items.', pump)
        self.assertIn('if((consTimer += delta()) >= consumeTime){', pump)
        self.assertIn('consTimer %= 1f;', pump)
        self.assertIn('warmup = Mathf.approachDelta(warmup, maxPump > 0.001f ? 1f : 0f, warmupSpeed);', pump)
        self.assertIn('warmup = Mathf.approachDelta(warmup, 0f, warmupSpeed);', pump)
        self.assertIn('totalProgress += warmup * Time.delta;', pump)
        self.assertIn('dumpLiquid(liquidDrop);', pump)
        self.assertIn('public float pumpAmount = 0.2f;', pump)
        self.assertIn('public float consumeTime = 60f * 5f;', pump)
        self.assertIn('public float warmupSpeed = 0.019f;', pump)
        self.assertIn('public float warmup, totalProgress;', pump)
        self.assertIn('public float consTimer;', pump)
        self.assertIn('return Time.delta * timeScale;', pump)
        self.assertIn('return efficiency * delta();', pump)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', pump)
        self.assertIn('pumpAmount = 0.22f;', pump)
        # pumpAmount is a def constant like liquidCapacity (the
        # N2190/N2199 precedent): rotary-pump 0.2f (the class
        # default, Pump.java:20, Blocks.java:2306) /
        # impulse-pump 0.22f (Blocks.java:2315); unknown Pump
        # defs fall back to the class default 0.2f.
        self.assertIn('SOURCE_MECHANICAL_PUMP_WARMUP_SPEED := 0.019', pump)
        self.assertIn('SOURCE_MECHANICAL_PUMP_CONSUME_TIME := 300.0', pump)
        self.assertIn('static func _pump_amount_for_block_id', pump)
        # The driver wires the advance into the live tick after
        # consumption (BuildingComp.java:2274 updateConsumption,
        # then :2277 updateTile): the source delta is
        # game_source_delta(game, seconds) and timeScale reads
        # live from the sprite meta (SourcePlacedBlockState.
        # time_scale, default 1.0, BuildingComp.java:98). The
        # proximity liquid_drop / amount come from the N2087
        # helper already called for the N2205 gate; the driver
        # writes the advanced warmup / total_progress /
        # cons_timer back to the frame and performs the
        # liquids.add through the shared liquid module
        # source_add_state (LiquidModule.java:84-91, `liquids[
        # liquid.id] += amount; current = liquid;`).
        self.assertIn('game_source_delta(game, seconds)', pump)
        self.assertIn('time_scale(sprite', pump)
        self.assertIn('source_mechanical_pump_update_tile_advance_state(frame, proximity.get("liquid_drop", null), float(proximity.get("amount", 0.0)), liquids, _liquid_capacity_for_block_id(block_id), _pump_amount_for_block_id(block_id), source_delta, time_scale, liquid_id_by_name)', pump)
        self.assertIn('frame["warmup"]', pump)
        self.assertIn('frame["total_progress"]', pump)
        self.assertIn('frame["cons_timer"]', pump)
        self.assertIn('source_add_state(liquids, liquid_id, float(advanced.get("max_pump", 0.0)), cache_sums)', pump)
        # The documented limits now record the advance as done
        # and the remaining deferral (dumpLiquid on the placed
        # path; the scenario pump path stays untouched).
        self.assertIn('dumpLiquid waits for its own slice', pump)
        # The proof's keys drive the pure advance (maxPump
        # capped by remaining capacity, warmup approaching 1
        # while pumping, totalProgress advancing with warmup,
        # consTimer advancing and wrapping at consumeTime, no
        # pumping without a liquid drop) plus the live tick (a
        # placed rotary-pump pumps and advances warmup on one
        # 1/60s tick).
        proof = MECHANICAL_PUMP_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'max_pump_capped_by_remaining_capacity',
            'warmup_approaches_one_when_pumping',
            'total_progress_advances_with_warmup',
            'cons_timer_advances_and_wraps',
            'no_pump_without_liquid_drop',
            'live_tick_pumps_and_advances_warmup',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene
        # is written but never run on this VM, so the test pins
        # its preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceMechanicalPumpBuildState.gd")', proof)
        self.assertTrue(MECHANICAL_PUMP_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('write_proof("C07MechanicalPumpUpdateTileProof"', proof)
        scene = MECHANICAL_PUMP_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07MechanicalPumpUpdateTileProof.gd', scene)
        self.assertIn('[node name="C07MechanicalPumpUpdateTileProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_mechanical_pump_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MechanicalPumpUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MECHANICAL_PUMP_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'max_pump_capped_by_remaining_capacity',
            'warmup_approaches_one_when_pumping',
            'total_progress_advances_with_warmup',
            'cons_timer_advances_and_wraps',
            'no_pump_without_liquid_drop',
            'live_tick_pumps_and_advances_warmup',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
