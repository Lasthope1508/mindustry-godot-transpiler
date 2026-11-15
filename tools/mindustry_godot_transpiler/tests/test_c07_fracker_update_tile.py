import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FRACKER_STATE = ROOT / 'godot-mindustry/src/game/SourceFrackerBuildState.gd'
SOLID_PUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceSolidPumpBuildState.gd'
LIQUID_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceLiquidModuleState.gd'
INVENTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceDrillInventoryRuntimeState.gd'
FRACKER_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerUpdateTileProof.gd'
FRACKER_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerUpdateTileProof.tscn'


class C07FrackerUpdateTileTests(unittest.TestCase):
    def test_c07_fracker_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2224']['godot_owner'], 'SourceFrackerBuildState.source_fracker_update_tile_advance_state')
        # N2153 proved the Fracker family's live power read and
        # N2207 proved the shouldConsume gate -- but the port
        # tracked no accumulator at all, so an oil-extractor
        # never consumed sand and never pumped anything: the
        # gate read a store no live intake ever filled. N2224
        # is the updateTile advance (FrackerBuild.updateTile(),
        # Fracker.java:30-44): while efficiency > 0 the
        # accumulator consumes one sand at itemUseTime
        # (consume(), Fracker.java:33, via ConsumeItems.trigger)
        # and advances by delta() * efficiency, and
        # super.updateTile() runs the solid-pump advance
        # (Fracker.java:37, reused from N2220 with the
        # oil-extractor pump amount 0.25f, Blocks.java:2969);
        # while efficiency is 0 the Fracker decays its own
        # warmup and zeroes lastPump WITHOUT calling
        # super.updateTile(), so pumpTime stands still too
        # (Fracker.java:40-43). The item use time is the def
        # constant 60f (Blocks.java:2974), overriding the class
        # default 100f (Fracker.java:8). consume() is PORTED,
        # not deferred: only ConsumeItems overrides trigger
        # (ConsumeItems.java:44-48, remove 1 sand with the
        # default multiplier 1f, Consume.java:18), ConsumePower
        # and ConsumeLiquid keep the base no-op trigger
        # (Consume.java:50), and the shared inventory helper
        # clamps exactly like ItemModule.remove
        # (ItemModule.java:258-263) -- the N2222 Separator
        # precedent. Seven new result symbols: the advanced
        # frame values plus the items dict after consume().
        self.assertEqual(
            ledger['N2224']['source_symbols'],
            [
                'source_fracker_update_tile_advance_state_result.accumulator',
                'source_fracker_update_tile_advance_state_result.warmup',
                'source_fracker_update_tile_advance_state_result.pump_time',
                'source_fracker_update_tile_advance_state_result.last_pump',
                'source_fracker_update_tile_advance_state_result.max_pump',
                'source_fracker_update_tile_advance_state_result.fraction',
                'source_fracker_update_tile_advance_state_result.items',
            ],
        )
        for name in ledger['N2224']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Fracker.java',
                    'core/src/mindustry/world/blocks/production/SolidPump.java',
                    'core/src/mindustry/world/consumers/ConsumeItems.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_update_tile_advance_state')
        self.assertEqual(ledger['N2224']['runtime_proof'], '/root/C07FrackerUpdateTileProof')
        self.assertEqual(
            ledger['N2224']['tests'],
            [
                'test_c07_fracker_update_tile_registration',
                'test_all_c07_fracker_update_tile_input_evidence_is_exact',
                'test_fracker_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_fracker_update_tile',
            ],
        )
        self.assertTrue(ledger['N2224']['deferred_exprs'])
        # This slice resolves the N2153 Fracker updateTile
        # advance deferral -- the entry is gone from DEFERRED --
        # while the fraction live fill stays covered by the
        # existing Fracker fraction entry (inherited via
        # super.updateTile()) and the item/liquid consumer
        # efficiency rows stay deferred (the fold is still
        # power-only). Two new deferrals record what this slice
        # leaves behind: the else-branch dumpLiquid
        # (Fracker.java:43; the super.updateTile() dump and the
        # updateEffect chance stay covered by N2220's
        # "SolidPump dumpLiquid + updateEffect" entry) and the
        # sand intake (nothing fills frame["items"] live yet).
        self.assertFalse(any(entry.startswith('Fracker updateTile advance (') for entry in ledger['N2224']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker dumpLiquid (else branch) (') for entry in ledger['N2224']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker item intake (') for entry in ledger['N2224']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker water-attribute / validTiles / boost fraction rows (') for entry in ledger['N2224']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker item / liquid rows (') for entry in ledger['N2224']['deferred_exprs']))

    def test_all_c07_fracker_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2224']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Fracker.java',
            'core/src/mindustry/world/blocks/production/SolidPump.java',
            'core/src/mindustry/world/blocks/production/Pump.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/world/modules/ItemModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2224']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_fracker_update_tile_advance_state(self):
        fracker = FRACKER_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the fracker build state:
        # the efficiency gate (Fracker.java:31), the consume
        # threshold (Fracker.java:32-35), super.updateTile()
        # (Fracker.java:37), the accumulator advance
        # (Fracker.java:38), and the else branch (Fracker.java:
        # 40-43) which decays warmup and zeroes lastPump
        # WITHOUT calling super.updateTile() -- pumpTime stands
        # still there. Keep each Java expr on ONE comment line
        # (the N2148 shootWarmup lesson: a split line fails
        # this test). The Arc formulas are lerpDelta(from, to,
        # progress) = lerp(from, to, clamp(progress * Time.delta))
        # with lerp = from + (to - from) * progress and
        # clamp(value) = clamp(value, 0, 1) (Mathf.java:401-404,
        # 425-432); Time.delta in the port is seconds * 60
        # through game_source_delta (arc Time.java:26,
        # `Math.min(Core.graphics.getDeltaTime() * 60f, 3f)`),
        # never raw seconds (the N2186/N2187/N2191 lesson: raw
        # seconds run 60x slow). delta() = Time.delta *
        # timeScale (BuildingComp.java:1922-1924) and edelta()
        # = efficiency * delta() (BuildingComp.java:1927-1929),
        # but the warmup lerpDelta scales by RAW Time.delta --
        # timeScale touches neither the lerp nor lastPump.
        self.assertIn('static func source_fracker_update_tile_advance_state', fracker)
        self.assertIn('public class Fracker extends SolidPump{', fracker)
        self.assertIn('public class FrackerBuild extends SolidPumpBuild{', fracker)
        self.assertIn('public float accumulator;', fracker)
        self.assertIn('public float itemUseTime = 100f;', fracker)
        self.assertIn('if(efficiency > 0){', fracker)
        self.assertIn('if(accumulator >= itemUseTime){', fracker)
        self.assertIn('consume();', fracker)
        self.assertIn('accumulator -= itemUseTime;', fracker)
        self.assertIn('super.updateTile();', fracker)
        self.assertIn('accumulator += delta() * efficiency;', fracker)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, 0f, 0.02f);', fracker)
        self.assertIn('lastPump = 0f;', fracker)
        self.assertIn('dumpLiquid(result);', fracker)
        self.assertIn('hasItems = true;', fracker)
        self.assertIn('public void consume(){', fracker)
        self.assertIn('cons.trigger(self());', fracker)
        self.assertIn('build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', fracker)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', fracker)
        self.assertIn('public void trigger(Building build){}', fracker)
        self.assertIn('amount = Math.min(amount, items[item.id]);', fracker)
        self.assertIn('return consumeItem(item, 1);', fracker)
        self.assertIn('return consume(new ConsumeItems(new ItemStack[]{new ItemStack(item, amount)}));', fracker)
        self.assertIn('consumeItem(Items.sand);', fracker)
        self.assertIn('itemUseTime = 60f;', fracker)
        self.assertIn('pumpAmount = 0.25f;', fracker)
        self.assertIn('result = Liquids.oil;', fracker)
        self.assertIn('liquidCapacity = 40f;', fracker)
        self.assertIn('public float liquidCapacity = -1f;', fracker)
        self.assertIn('public float pumpAmount = 0.2f;', fracker)
        self.assertIn('return Time.delta * timeScale;', fracker)
        self.assertIn('return efficiency * delta();', fracker)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', fracker)
        self.assertIn('public boolean noUpdateDisabled = false;', fracker)
        self.assertIn('updateConsumption();', fracker)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', fracker)
        # The super.updateTile() exprs are cited (not copied):
        # the reused N2220 pure function owns them.
        self.assertIn('float fraction = Math.max(validTiles + boost + (attribute == null ? 0 : attribute.env()), 0);', fracker)
        self.assertIn('float maxPump = Math.min(liquidCapacity - typeLiquid(), pumpAmount * delta() * fraction * efficiency);', fracker)
        self.assertIn('liquids.add(result, maxPump);', fracker)
        self.assertIn('lastPump = maxPump / Time.delta;', fracker)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, 1f, 0.02f);', fracker)
        self.assertIn('pumpTime += warmup * edelta();', fracker)
        # The def constants: pump amount 0.25f (Blocks.java:
        # 2969), item use time 60f (Blocks.java:2974, the def
        # overriding the 100f class default), warmup rate 0.02f
        # (Fracker.java:41), consume item sand (Blocks.java:2976).
        self.assertIn('SOURCE_FRACKER_PUMP_AMOUNT := 0.25', fracker)
        self.assertIn('SOURCE_FRACKER_ITEM_USE_TIME := 60.0', fracker)
        self.assertIn('SOURCE_FRACKER_WARMUP_RATE := 0.02', fracker)
        self.assertIn('SOURCE_FRACKER_CONSUME_ITEM := "sand"', fracker)
        # The advance REUSES the N2220 SolidPump pure function
        # for super.updateTile() through a preload (the N2221
        # cross-driver precedent) -- it does not copy the
        # SolidPump logic: no fraction maxf, no liquid add in
        # this file. consume() goes through the shared
        # inventory helper (the N2222 Separator precedent).
        self.assertIn('preload("res://src/game/SourceSolidPumpBuildState.gd")', fracker)
        self.assertIn('source_solid_pump_state.source_solid_pump_update_tile_advance_state(frame, source_delta, time_scale, result_liquid_id, liquid_capacity, pump_amount)', fracker)
        self.assertNotIn('maxf(valid_tiles + boost + attribute_env, 0.0)', fracker)
        self.assertNotIn('source_liquid_module_state.source_add_state(', fracker)
        self.assertIn('preload("res://src/game/SourceDrillInventoryRuntimeState.gd")', fracker)
        self.assertIn('inventory.remove_item_state(items, SOURCE_FRACKER_CONSUME_ITEM, 1)', fracker)
        # The driver wires the advance into the live tick: the
        # source delta is game_source_delta(game, seconds) and
        # timeScale reads live from the sprite meta
        # (SourcePlacedBlockState.time_scale, default 1.0,
        # BuildingComp.java:98 `private transient float timeScale
        # = 1f, timeScaleDuration;`); the advance runs after
        # consumption (BuildingComp.java:2274 updateConsumption(),
        # then the updateTile gate at :2276-2278) and only when
        # enabled (noUpdateDisabled defaults false,
        # Block.java:170). The frame carries the items dict
        # (the Separator precedent) and the advance writes all
        # seven result keys back.
        self.assertIn('game_source_delta(game, seconds)', fracker)
        self.assertIn('time_scale(sprite', fracker)
        self.assertIn('source_fracker_update_tile_advance_state(frame, source_delta, time_scale, advance_result_id, SOURCE_FRACKER_LIQUID_CAPACITY, SOURCE_FRACKER_PUMP_AMOUNT, SOURCE_FRACKER_ITEM_USE_TIME)', fracker)
        self.assertIn('frame["accumulator"]', fracker)
        self.assertIn('frame["warmup"]', fracker)
        self.assertIn('frame["pump_time"]', fracker)
        self.assertIn('frame["last_pump"]', fracker)
        self.assertIn('frame["max_pump"]', fracker)
        self.assertIn('frame["fraction"]', fracker)
        self.assertIn('frame["items"]', fracker)
        self.assertIn('"items": {}', fracker)
        # The documented limits now record the advance as live
        # and the remaining deferrals (else-branch dumpLiquid,
        # sand intake, live fraction fill); the old N2153/N2207
        # "no advance / no intake" text is gone. The N2207 gate
        # and the N2153 power row are preserved.
        self.assertIn('updateTile advance live (N2224)', fracker)
        self.assertNotIn('No updateTile advance', fracker)
        self.assertNotIn('no live intake fills the oil store yet', fracker)
        self.assertIn('shouldConsume gate live (N2207)', fracker)
        self.assertIn('static func source_fracker_should_consume_state', fracker)
        self.assertIn('static func source_fracker_power_status_row_state', fracker)
        # The reused N2220 pure function exists with the
        # pump_amount parameter the Fracker advance passes
        # 0.25f to, and the shared inventory helper exists and
        # removes an amount by item id (the advance reuses it,
        # it does not re-implement the item remove).
        solid_pump = SOLID_PUMP_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_solid_pump_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, result_liquid_id: int, liquid_capacity: float, pump_amount: float)', solid_pump)
        inventory = INVENTORY_STATE.read_text(encoding='utf-8')
        self.assertIn('static func remove_item_state(items: Dictionary, item_id: String, amount: int) -> Dictionary:', inventory)
        # The proof's keys drive the pure advance (the
        # accumulator folds delta() * efficiency, consume()
        # fires at itemUseTime and clamps on an empty store,
        # super.updateTile() pumps oil through the reused N2220
        # function, warmup decays with no efficiency while
        # pumpTime and the accumulator freeze, lastPump is zero
        # whenever idle, frame defaults zero). Static checks:
        # the proof preloads the family state file that exists,
        # and the scene file references the proof script that
        # exists.
        proof = FRACKER_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'accumulator_advances_with_efficiency',
            'consume_at_item_use_time',
            'super_advance_pumps_oil',
            'warmup_decays_when_no_efficiency',
            'last_pump_zero_when_idle',
            'frame_defaults_zero',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceFrackerBuildState.gd")', proof)
        self.assertTrue(FRACKER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = FRACKER_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07FrackerUpdateTileProof.gd', scene)
        self.assertIn('C07FrackerUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_fracker_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07FrackerUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FRACKER_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'accumulator_advances_with_efficiency',
            'consume_at_item_use_time',
            'super_advance_pumps_oil',
            'warmup_decays_when_no_efficiency',
            'last_pump_zero_when_idle',
            'frame_defaults_zero',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
