import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WALL_CRAFTER_STATE = ROOT / 'godot-mindustry/src/game/SourceWallCrafterBuildState.gd'
DRILL_INVENTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceDrillInventoryRuntimeState.gd'
WALL_CRAFTER_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterUpdateTileProof.gd'
WALL_CRAFTER_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterUpdateTileProof.tscn'


class C07WallCrafterUpdateTileTests(unittest.TestCase):
    def test_c07_wall_crafter_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2223']['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_update_tile_advance_state')
        # N2170 proved the WallCrafter family's live power read and
        # N2201 the shouldConsume gate (items.get(output) <
        # itemCapacity, no enabled term) -- but the port tracked
        # no warmup / time / totalTime / lastEfficiency at all,
        # so a cliff-crusher never accumulated time toward
        # drillTime and never offloaded anything. N2223 is the
        # updateTile advance (WallCrafterBuild.updateTile(),
        # WallCrafter.java:187-223): warmup approachDelta toward
        # num(efficiency > 0) at 1f/40f, eff = getEfficiency *
        # lerp(1, 1.6, hasLiquidBooster ? optionalEfficiency : 0)
        # * (itemValid ? 1.6 : 1), lastEfficiency = eff *
        # timeScale * efficiency, time += edelta() * eff gated
        # on cons with the offload + time %= drillTime reset,
        # and totalTime += edelta() * warmup * (eff <= 0 ? 0 :
        # 1). The live getEfficiency scan (WallCrafter.java:
        # 141-180, adjacent solid tiles summed over the sand
        # attribute) has no helper in the port, so the pure
        # advance takes the base efficiency as the frame input
        # efficiency_factor (default 0.0); item_valid and
        # has_liquid_booster are frame inputs too (both default
        # false -- hasLiquidBooster is false for both defs, the
        # large def's hydrogen consumer is not .boost(),
        # Blocks.java:3028). The timerUse booster consume and
        # the timerDump dump defer (no timer helper in the
        # port, the N2193 precedent); the offload routes to the
        # building's own inventory through the shared inventory
        # helper (the handleItem fallback, BuildingComp.java:
        # 1014/:860-861), with the neighbor routing deferred.
        # Seven new result symbols: the advanced frame values
        # plus the offload flag and the offloaded items.
        self.assertEqual(
            ledger['N2223']['source_symbols'],
            [
                'source_wall_crafter_update_tile_advance_state_result.warmup',
                'source_wall_crafter_update_tile_advance_state_result.eff',
                'source_wall_crafter_update_tile_advance_state_result.last_efficiency',
                'source_wall_crafter_update_tile_advance_state_result.time',
                'source_wall_crafter_update_tile_advance_state_result.total_time',
                'source_wall_crafter_update_tile_advance_state_result.offloaded',
                'source_wall_crafter_update_tile_advance_state_result.items',
            ],
        )
        for name in ledger['N2223']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/WallCrafter.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_update_tile_advance_state')
        self.assertEqual(ledger['N2223']['runtime_proof'], '/root/C07WallCrafterUpdateTileProof')
        self.assertEqual(
            ledger['N2223']['tests'],
            [
                'test_c07_wall_crafter_update_tile_registration',
                'test_all_c07_wall_crafter_update_tile_input_evidence_is_exact',
                'test_wall_crafter_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_wall_crafter_update_tile',
            ],
        )
        self.assertTrue(ledger['N2223']['deferred_exprs'])
        # This slice resolves the N2170 WallCrafter updateTile
        # advance deferral, so the advance entry is gone from
        # DEFERRED -- while the live-fill entry (getEfficiency
        # fill + timerUse consume + timerDump dump + offload
        # neighbor routing + updateEffect + disabled early
        # return) takes its place.
        self.assertFalse(any(entry.startswith('WallCrafter updateTile advance (') for entry in ledger['N2223']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('WallCrafter updateTile live fill (') for entry in ledger['N2223']['deferred_exprs']))

    def test_all_c07_wall_crafter_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2223']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/WallCrafter.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2223']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_wall_crafter_update_tile_advance_state(self):
        wall_crafter = WALL_CRAFTER_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the wall-crafter build state:
        # warmup approachDelta (WallCrafter.java:193), the eff
        # fold (WallCrafter.java:196-205), lastEfficiency
        # (WallCrafter.java:211), the cons-gated time advance +
        # offload + reset (WallCrafter.java:213-215), totalTime
        # (WallCrafter.java:218). Keep each Java expr on ONE
        # comment line (the N2148 shootWarmup lesson: a split
        # line fails this test). The Arc formulas are
        # approachDelta(from, to, speed) = approach(from, to,
        # Time.delta * speed) with approach = from + clamp(to -
        # from, -speed, speed), lerp = from + (to - from) *
        # progress, num(b) = b ? 1 : 0 (Mathf.java:208, 415-425);
        # Time.delta in the port is seconds * 60 through
        # game_source_delta (arc Time.java:26), never raw seconds
        # (the N2186/N2187/N2191 lesson: raw seconds run 60x
        # slow). Java short-circuits the time advance on cons
        # (`if(cons && (time += edelta() * eff) >= drillTime)`):
        # with a full store time does NOT advance at all.
        self.assertIn('static func source_wall_crafter_update_tile_advance_state', wall_crafter)
        self.assertIn('warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 40f);', wall_crafter)
        self.assertIn('float eff = getEfficiency(tile.x, tile.y, rotation, dest -> {', wall_crafter)
        self.assertIn('Mathf.lerp(1f, liquidBoostIntensity, hasLiquidBooster ? optionalEfficiency : 0f)', wall_crafter)
        self.assertIn('(itemValid ? itemBoostIntensity : 1f)', wall_crafter)
        self.assertIn('boolean itemValid = itemConsumer != null && itemConsumer.efficiency(this) > 0;', wall_crafter)
        self.assertIn('lastEfficiency = eff * timeScale * efficiency;', wall_crafter)
        self.assertIn('if(cons && (time += edelta() * eff) >= drillTime){', wall_crafter)
        self.assertIn('offload(output);', wall_crafter)
        self.assertIn('time %= drillTime;', wall_crafter)
        self.assertIn('totalTime += edelta() * warmup * (eff <= 0f ? 0f : 1f);', wall_crafter)
        self.assertIn('public float time, warmup, totalTime, lastEfficiency;', wall_crafter)
        self.assertIn('public float liquidBoostIntensity = 1.6f;', wall_crafter)
        self.assertIn('public float itemBoostIntensity = 1.6f;', wall_crafter)
        self.assertIn('public float drillTime = 150f;', wall_crafter)
        self.assertIn('hasLiquidBooster = findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) != null;', wall_crafter)
        # The boost intensities are the class defaults 1.6f
        # (WallCrafter.java:35/:47); neither def overrides them,
        # and the drillTime default is the class 150f
        # (WallCrafter.java:33) while the defs override it (110f
        # / 48f, Blocks.java:3006/:3020), so the driver reads
        # drillTime from the catalog per def.
        self.assertIn('SOURCE_WALL_CRAFTER_WARMUP_SPEED := 1.0 / 40.0', wall_crafter)
        self.assertIn('SOURCE_WALL_CRAFTER_LIQUID_BOOST_INTENSITY := 1.6', wall_crafter)
        self.assertIn('SOURCE_WALL_CRAFTER_ITEM_BOOST_INTENSITY := 1.6', wall_crafter)
        self.assertIn('SOURCE_WALL_CRAFTER_DRILL_TIME_DEFAULT := 150.0', wall_crafter)
        # The driver wires the advance into the live tick: the
        # source delta is game_source_delta(game, seconds) and
        # timeScale reads live from the sprite meta
        # (SourcePlacedBlockState.time_scale, default 1.0,
        # BuildingComp.java:98 `private transient float timeScale
        # = 1f, timeScaleDuration;`); the advance runs after
        # consumption, like Java's Building.update()
        # (BuildingComp.java:2274 updateConsumption(), then the
        # updateTile gate `if(enabled || !block.noUpdateDisabled){`
        # at BuildingComp.java:2276-2277; noUpdateDisabled
        # defaults false, Block.java:170, so Java runs updateTile
        # even when disabled -- the port keeps the enabled gate
        # as a pragmatic choice, the N2195 coordinator-fix
        # precedent, because the driver skips the consumption
        # fold when disabled and the frame efficiency goes stale).
        # super.updateTile() is an empty no-op
        # (BuildingComp.java:2010-2012), so the driver owes it
        # nothing.
        self.assertIn('game_source_delta(game, seconds)', wall_crafter)
        self.assertIn('time_scale(sprite', wall_crafter)
        self.assertIn('source_wall_crafter_update_tile_advance_state(frame, source_delta, time_scale, drill_time, advance_output_item, advance_item_capacity)', wall_crafter)
        self.assertIn('block.properties.get("drillTime", SOURCE_WALL_CRAFTER_DRILL_TIME_DEFAULT)', wall_crafter)
        self.assertIn('frame["warmup"]', wall_crafter)
        self.assertIn('frame["eff"]', wall_crafter)
        self.assertIn('frame["last_efficiency"]', wall_crafter)
        self.assertIn('frame["time"]', wall_crafter)
        self.assertIn('frame["total_time"]', wall_crafter)
        self.assertIn('frame["offloaded"]', wall_crafter)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', wall_crafter)
        # The offload routes through the shared inventory helper
        # (reused, not re-implemented): with no routing context
        # it falls back to the building's own inventory, the
        # handleItem path (BuildingComp.java:1014/:860-861).
        self.assertIn('inventory.offload_item_state(', wall_crafter)
        # The deferred live fills arrive as frame inputs with
        # Java-faithful defaults: no adjacent solid tiles means
        # getEfficiency 0, no item booster means itemValid false,
        # and hasLiquidBooster is false for both defs.
        self.assertIn('frame.get("efficiency_factor", 0.0)', wall_crafter)
        self.assertIn('frame.get("item_valid", false)', wall_crafter)
        self.assertIn('frame.get("has_liquid_booster", false)', wall_crafter)
        # The documented limits now record the advance as done
        # and the remaining deferrals (live getEfficiency fill,
        # timerUse consume, timerDump dump, offload neighbor
        # routing, updateEffect, disabled early return); the
        # shouldConsume gate stays live (N2201).
        self.assertIn('updateTile advance live (N2223)', wall_crafter)
        self.assertNotIn('No updateTile advance', wall_crafter)
        self.assertIn('shouldConsume gate live (N2201)', wall_crafter)
        # The shared inventory helper exists and models the
        # offload (neighbor routing with the own-inventory
        # fallback, BuildingComp.java:1001-1014).
        inventory = DRILL_INVENTORY_STATE.read_text(encoding='utf-8')
        self.assertIn('static func offload_item_state(items: Dictionary, item_id: String, routing_context: Dictionary = {}) -> Dictionary:', inventory)
        # The proof's keys drive the pure advance (warmup up/down,
        # time advance with eff + edelta + boosts, offload at
        # drillTime with the time reset + items intake + the
        # cons short-circuit, lastEfficiency, totalTime) plus
        # the live tick (warmup + time advance on a placed
        # cliff-crusher, efficiency still folding power.status).
        proof = WALL_CRAFTER_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'warmup_approaches_one_when_efficient',
            'time_advances_with_eff_and_edelta',
            'offload_at_drill_time',
            'last_efficiency_folds_eff_timescale',
            'total_time_advances_with_warmup',
            'live_tick_advances_warmup_and_time',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceWallCrafterBuildState.gd")', proof)
        self.assertTrue(WALL_CRAFTER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = WALL_CRAFTER_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07WallCrafterUpdateTileProof.gd', scene)
        self.assertIn('C07WallCrafterUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_wall_crafter_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WallCrafterUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WALL_CRAFTER_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'warmup_approaches_one_when_efficient',
            'time_advances_with_eff_and_edelta',
            'offload_at_drill_time',
            'last_efficiency_folds_eff_timescale',
            'total_time_advances_with_warmup',
            'live_tick_advances_warmup_and_time',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
