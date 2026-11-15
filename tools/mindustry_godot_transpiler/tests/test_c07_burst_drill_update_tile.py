import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillUpdateTileProof.gd'
BURST_DRILL_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillUpdateTileProof.tscn'


class C07BurstDrillUpdateTileTests(unittest.TestCase):
    def test_c07_burst_drill_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2219']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_update_tile_advance_state')
        # N2149 proved the BurstDrill family's live power read and
        # N2203 wired its shouldConsume gate, but the port
        # tracked no progress / warmup / timeDrilled /
        # lastDrillSpeed / smoothProgress / invertTime at all,
        # so a burst drill never accumulated progress toward
        # drillTime and never offloaded anything. N2219 is the
        # updateTile advance (BurstDrillBuild.updateTile(),
        # BurstDrill.java:76-125): the invertTime decay, the
        # smoothProgress lerpDelta, the gate branch (warmup
        # approachDelta toward progress/drillTime, speed =
        # lerp(1, liquidBoostIntensity, optionalEfficiency) *
        # efficiency, timeDrilled += pow2In(progress/drillTime)
        # * speed, lastDrillSpeed, progress += delta() *
        # speed), the blocked branch (warmup toward 0,
        # lastDrillSpeed 0, return), and the offload branch
        # (offload dominantItem x dominantItems, invertTime =
        # 1f, progress %= drillTime). The drillTime uses the
        # BurstDrill getDrillTime OVERRIDE (BurstDrill.java:54,
        # `return drillTime / drillMultipliers.get(item, 1f);`,
        # NO hardness term), not the base-Drill formula
        # (Drill.java:171). The timerDump dump and the
        # shake/sound/drillEffect presentation defer (no timer
        # infra in the port, the N2193 precedent); offload takes
        # the no-neighbor fallback branch (BuildingComp.java:
        # 1017, `handleItem(self(), item);`), the base-Drill
        # driver precedent, and the neighbor routing waits for
        # its own slice. Ten new result symbols: the six
        # advanced frame values, the next items map, the
        # offloaded count, the effective drillTime, and the
        # speed this tick.
        self.assertEqual(
            ledger['N2219']['source_symbols'],
            [
                'source_burst_drill_update_tile_advance_state_result.progress',
                'source_burst_drill_update_tile_advance_state_result.warmup',
                'source_burst_drill_update_tile_advance_state_result.time_drilled',
                'source_burst_drill_update_tile_advance_state_result.last_drill_speed',
                'source_burst_drill_update_tile_advance_state_result.smooth_progress',
                'source_burst_drill_update_tile_advance_state_result.invert_time',
                'source_burst_drill_update_tile_advance_state_result.items',
                'source_burst_drill_update_tile_advance_state_result.offloaded',
                'source_burst_drill_update_tile_advance_state_result.drill_time',
                'source_burst_drill_update_tile_advance_state_result.speed',
            ],
        )
        for name in ledger['N2219']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BurstDrill.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_update_tile_advance_state')
        self.assertEqual(ledger['N2219']['runtime_proof'], '/root/C07BurstDrillUpdateTileProof')
        self.assertEqual(
            ledger['N2219']['tests'],
            [
                'test_c07_burst_drill_update_tile_registration',
                'test_all_c07_burst_drill_update_tile_input_evidence_is_exact',
                'test_burst_drill_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_burst_drill_update_tile',
            ],
        )
        self.assertTrue(ledger['N2219']['deferred_exprs'])
        # The slice resolves the BurstDrill updateTile advance
        # deferral and adds one new deferral for the remainder
        # (timerDump dump + offload effects + neighbor routing).
        deferred = ledger['N2219']['deferred_exprs']
        self.assertFalse(any(entry.startswith('BurstDrill updateTile advance (progress / timeDrilled / offload / invertTime / speedCurve, BurstDrill.java:70-125)') for entry in deferred))
        self.assertTrue(any(entry.startswith('BurstDrill updateTile timerDump dump + offload effects + offload neighbor routing') for entry in deferred))

    def test_all_c07_burst_drill_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2219']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2219']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_update_tile_advance_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the burst-drill build state:
        # the invertTime decay (BurstDrill.java:81), the
        # smoothProgress lerpDelta (BurstDrill.java:89), the gate
        # branch (BurstDrill.java:91-99), the blocked branch
        # (BurstDrill.java:100-104), and the offload branch
        # (BurstDrill.java:106-112). Keep each Java expr on ONE
        # comment line (the N2148 shootWarmup lesson: a split
        # line fails this test). The Arc formulas are
        # approachDelta(from, to, speed) = approach(from, to,
        # Time.delta * speed) with approach = from + clamp(to -
        # from, -speed, speed), lerpDelta = lerp(from, to,
        # clamp(progress * Time.delta)), lerp = from + (to -
        # from) * progress (Mathf.java:402, 415-432); pow2In(a)
        # = a * a (Interp.java:29 `PowIn pow2In = new PowIn(2);`
        # with PowIn.apply :119-121 `return (float)Math.pow(a,
        # power);`). Time.delta in the port is seconds * 60
        # through game_source_delta (arc Time.java:26), never
        # raw seconds; delta() = Time.delta * timeScale
        # (BuildingComp.java:1922-1924) while approachDelta /
        # lerpDelta scale by Time.delta alone (Mathf.java:420 /
        # :430-432).
        self.assertIn('static func source_burst_drill_update_tile_advance_state', burst_drill)
        self.assertIn('if(dominantItem == null){', burst_drill)
        self.assertIn('if(invertTime > 0f) invertTime -= delta() / invertedTime;', burst_drill)
        self.assertIn('float drillTime = getDrillTime(dominantItem);', burst_drill)
        self.assertIn('smoothProgress = Mathf.lerpDelta(smoothProgress, progress / (drillTime - 20f), 0.1f);', burst_drill)
        self.assertIn('if(items.total() <= itemCapacity - dominantItems && dominantItems > 0 && efficiency > 0){', burst_drill)
        self.assertIn('warmup = Mathf.approachDelta(warmup, progress / drillTime, 0.01f);', burst_drill)
        self.assertIn('float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;', burst_drill)
        self.assertIn('timeDrilled += speedCurve.apply(progress / drillTime) * speed;', burst_drill)
        self.assertIn('lastDrillSpeed = 1f / drillTime * speed * dominantItems;', burst_drill)
        self.assertIn('progress += delta() * speed;', burst_drill)
        self.assertIn('warmup = Mathf.approachDelta(warmup, 0f, 0.01f);', burst_drill)
        self.assertIn('lastDrillSpeed = 0f;', burst_drill)
        self.assertIn('if(dominantItems > 0 && progress >= drillTime && items.total() < itemCapacity){', burst_drill)
        self.assertIn('offload(dominantItem);', burst_drill)
        self.assertIn('invertTime = 1f;', burst_drill)
        self.assertIn('progress %= drillTime;', burst_drill)
        self.assertIn('public Interp speedCurve = Interp.pow2In;', burst_drill)
        self.assertIn('public float invertedTime = 200f;', burst_drill)
        # The drillTime uses the BurstDrill getDrillTime
        # OVERRIDE (BurstDrill.java:53-55, NO hardness term),
        # not the base-Drill formula (Drill.java:170-172) --
        # both exprs are cited so the distinction is pinned.
        self.assertIn('return drillTime / drillMultipliers.get(item, 1f);', burst_drill)
        self.assertIn('return (drillTime + hardnessDrillMultiplier * item.hardness) / drillMultipliers.get(item, 1f);', burst_drill)
        # The per-def drillTime / liquidBoostIntensity tables
        # (Blocks.java): eruption 281.25f / 2f, impact 60f*12f
        # (720f) / 1.75f; the catalog lacks impact's drillTime
        # and both defs' liquidBoostIntensity, so the driver
        # reads these tables with the Drill class defaults as
        # fallback (drillTime 300, Drill.java:36;
        # liquidBoostIntensity 1.6f, Drill.java:38). Both defs
        # put beryllium at 2f in drillMultipliers
        # (Blocks.java:3083/:3114).
        self.assertIn('SOURCE_BURST_DRILL_DRILL_TIME := {"eruption-drill": 281.25, "impact-drill": 720.0}', burst_drill)
        self.assertIn('SOURCE_BURST_DRILL_LIQUID_BOOST_INTENSITY := {"eruption-drill": 2.0, "impact-drill": 1.75}', burst_drill)
        self.assertIn('SOURCE_BURST_DRILL_BERYLLIUM_MULTIPLIER := 2.0', burst_drill)
        self.assertIn('drillTime = 281.25f;', burst_drill)
        self.assertIn('drillTime = 60f * 12f;', burst_drill)
        self.assertIn('liquidBoostIntensity = 1.75f;', burst_drill)
        self.assertIn('liquidBoostIntensity = 2f;', burst_drill)
        self.assertIn('drillMultipliers.put(Items.beryllium, 2f);', burst_drill)
        self.assertIn('public float drillTime = 300;', burst_drill)
        self.assertIn('public float liquidBoostIntensity = 1.6f;', burst_drill)
        # The driver wires the advance into the live tick: the
        # source delta is game_source_delta(game, seconds) and
        # timeScale reads live from the sprite meta
        # (SourcePlacedBlockState.time_scale, default 1.0,
        # BuildingComp.java:98 `private transient float timeScale
        # = 1f, timeScaleDuration;`); the advance runs after the
        # consumption fold and only when enabled
        # (BuildingComp.java:2274-2278, updateConsumption()
        # then `if(enabled || !block.noUpdateDisabled){
        # updateTile(); }`, and noUpdateDisabled defaults false,
        # Block.java:170). The dominant item name resolves
        # through the shared drill helper via load() (a preload
        # would cycle: Factory preloads this file and
        # DrillRuntime preloads Factory). The advance writes
        # all six frame keys plus the offloaded items back.
        self.assertIn('game_source_delta(game, seconds)', burst_drill)
        self.assertIn('time_scale(sprite', burst_drill)
        self.assertIn('source_burst_drill_update_tile_advance_state(frame, source_delta, time_scale, block_drill_time, block_boost, drill_multiplier, dominant_item_name, int(block.properties.get("itemCapacity", 10)))', burst_drill)
        self.assertIn('source_dominant_item_name_state(game, sprite)', burst_drill)
        self.assertIn('frame["progress"]', burst_drill)
        self.assertIn('frame["warmup"]', burst_drill)
        self.assertIn('frame["time_drilled"]', burst_drill)
        self.assertIn('frame["last_drill_speed"]', burst_drill)
        self.assertIn('frame["smooth_progress"]', burst_drill)
        self.assertIn('frame["invert_time"]', burst_drill)
        self.assertIn('frame["items"] = advanced["items"]', burst_drill)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', burst_drill)
        # The offload takes the no-neighbor fallback branch
        # (BuildingComp.java:1017, `handleItem(self(), item);`)
        # through the shared inventory helper, the base-Drill
        # driver precedent (SourceDrillConsumptionRuntimeState.
        # gd:290); the neighbor routing and the timerDump dump
        # wait for their own slices.
        self.assertIn('handleItem(self(), item);', burst_drill)
        self.assertIn('source_drill_inventory_runtime_state.add_item_state(', burst_drill)
        self.assertIn('if(timer(timerDump, dumpTime / timeScale)){', burst_drill)
        # The documented limits now record the advance as live
        # (N2219) and the remaining deferrals (timerDump dump,
        # offload effects, neighbor routing).
        self.assertIn('updateTile advance LIVE (N2219)', burst_drill)
        # The proof's keys drive the pure advance (progress
        # advance at full efficiency, warmup approaching the
        # progress ratio, offload at drillTime with the
        # beryllium 2x multiplier, invertTime set on offload
        # and decaying, lastDrillSpeed zero when blocked) plus
        # the live tick (progress advances on a placed
        # eruption-drill, efficiency still folding
        # power.status).
        proof = BURST_DRILL_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'progress_advances_when_efficient',
            'warmup_approaches_progress_ratio',
            'offload_at_drill_time',
            'invert_time_set_on_offload',
            'last_drill_speed_zero_when_blocked',
            'live_tick_advances_progress',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceBurstDrillBuildState.gd")', proof)
        self.assertTrue(BURST_DRILL_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('write_proof("C07BurstDrillUpdateTileProof"', proof)
        scene = BURST_DRILL_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BurstDrillUpdateTileProof.gd', scene)
        self.assertIn('[node name="C07BurstDrillUpdateTileProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_burst_drill_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'progress_advances_when_efficient',
            'warmup_approaches_progress_ratio',
            'offload_at_drill_time',
            'invert_time_set_on_offload',
            'last_drill_speed_zero_when_blocked',
            'live_tick_advances_progress',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
