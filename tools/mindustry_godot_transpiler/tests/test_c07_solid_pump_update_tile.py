import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOLID_PUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceSolidPumpBuildState.gd'
LIQUID_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceLiquidModuleState.gd'
SOLID_PUMP_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SolidPumpUpdateTileProof.gd'
SOLID_PUMP_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SolidPumpUpdateTileProof.tscn'


class C07SolidPumpUpdateTileTests(unittest.TestCase):
    def test_c07_solid_pump_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2220']['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_update_tile_advance_state')
        # N2150 proved the SolidPump family's live power read and
        # N2206 proved the shouldConsume gate -- but the port
        # tracked no warmup / pumpTime / lastPump at all, so a
        # water-extractor never pumped anything: the gate read a
        # store no live intake ever filled. N2220 is the
        # updateTile advance (SolidPumpBuild.updateTile(),
        # SolidPump.java:122-141): liquidDrop = result, the
        # fraction max(validTiles + boost + attribute.env(), 0),
        # the pumping branch (maxPump = min(capacity -
        # typeLiquid(), pumpAmount * delta() * fraction *
        # efficiency), liquids.add(result, maxPump), lastPump =
        # maxPump / Time.delta, warmup lerpDelta toward 1f at
        # 0.02f), the idle branch (warmup lerpDelta toward 0f,
        # lastPump = 0f), and pumpTime += warmup * edelta().
        # The fraction inputs arrive explicit (frame valid_tiles
        # / boost / attribute_env, default 0f): the live
        # onProximityUpdate fill (SolidPump.java:150-159) waits
        # for its own slice, the N2087 pump proximity helper
        # does not apply (it scans floor liquidDrop, not
        # solid-tile attributes), and dumpLiquid(result) +
        # the updateEffect chance defer with it. pumpAmount is
        # the def constant 0.11f (Blocks.java:2923), passed as a
        # parameter so the Fracker advance (N2224) can reuse
        # this pure function with the oil-extractor's 0.25f
        # (Blocks.java:2969; FrackerBuild.updateTile calls
        # super.updateTile(), Fracker.java:37).
        # Five new result symbols: the advanced frame values.
        self.assertEqual(
            ledger['N2220']['source_symbols'],
            [
                'source_solid_pump_update_tile_advance_state_result.warmup',
                'source_solid_pump_update_tile_advance_state_result.pump_time',
                'source_solid_pump_update_tile_advance_state_result.last_pump',
                'source_solid_pump_update_tile_advance_state_result.max_pump',
                'source_solid_pump_update_tile_advance_state_result.fraction',
            ],
        )
        for name in ledger['N2220']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/SolidPump.java')
                self.assertEqual(symbol['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_update_tile_advance_state')
        self.assertEqual(ledger['N2220']['runtime_proof'], '/root/C07SolidPumpUpdateTileProof')
        self.assertEqual(
            ledger['N2220']['tests'],
            [
                'test_c07_solid_pump_update_tile_registration',
                'test_all_c07_solid_pump_update_tile_input_evidence_is_exact',
                'test_solid_pump_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_solid_pump_update_tile',
            ],
        )
        self.assertTrue(ledger['N2220']['deferred_exprs'])
        # This slice resolves the N2150 SolidPump updateTile
        # advance deferral AND the N2206 frame liquids intake
        # deferral (the advance IS the intake) -- both entries
        # are gone from DEFERRED -- while the water-attribute /
        # validTiles / boost fraction rows stay deferred (their
        # live fill is still open) and two new deferrals record
        # what this slice leaves behind (live fraction fill,
        # dumpLiquid + updateEffect).
        self.assertFalse(any(entry.startswith('SolidPump updateTile advance (') for entry in ledger['N2220']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('SolidPump frame liquids intake (') for entry in ledger['N2220']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump updateTile live fraction fill (') for entry in ledger['N2220']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump dumpLiquid + updateEffect (') for entry in ledger['N2220']['deferred_exprs']))

    def test_all_c07_solid_pump_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2220']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/SolidPump.java',
            'core/src/mindustry/world/blocks/production/Pump.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2220']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_solid_pump_update_tile_advance_state(self):
        solid_pump = SOLID_PUMP_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the solid-pump build state:
        # liquidDrop = result (SolidPump.java:123), the fraction
        # (SolidPump.java:124), the pumping branch
        # (SolidPump.java:126-132), the idle branch
        # (SolidPump.java:133-136), pumpTime += warmup * edelta()
        # (SolidPump.java:138), dumpLiquid(result)
        # (SolidPump.java:140, deferred). Keep each Java expr on
        # ONE comment line (the N2148 shootWarmup lesson: a
        # split line fails this test). The Arc formulas are
        # lerpDelta(from, to, progress) = lerp(from, to,
        # clamp(progress * Time.delta)) with lerp = from + (to -
        # from) * progress and clamp(value) = clamp(value, 0, 1)
        # (Mathf.java:401-404, 425-432); Time.delta in the port
        # is seconds * 60 through game_source_delta (arc
        # Time.java:26, `Math.min(Core.graphics.getDeltaTime()
        # * 60f, 3f)`), never raw seconds (the N2186/N2187/N2191
        # lesson: raw seconds run 60x slow). delta() = Time.delta
        # * timeScale (BuildingComp.java:1922-1924) and edelta()
        # = efficiency * delta() (BuildingComp.java:1927-1929),
        # but lastPump divides by RAW Time.delta
        # (SolidPump.java:129) and lerpDelta scales by RAW
        # Time.delta too -- timeScale touches neither.
        self.assertIn('static func source_solid_pump_update_tile_advance_state', solid_pump)
        self.assertIn('liquidDrop = result;', solid_pump)
        self.assertIn('float fraction = Math.max(validTiles + boost + (attribute == null ? 0 : attribute.env()), 0);', solid_pump)
        self.assertIn('if(efficiency > 0 && typeLiquid() < liquidCapacity - 0.001f){', solid_pump)
        self.assertIn('float maxPump = Math.min(liquidCapacity - typeLiquid(), pumpAmount * delta() * fraction * efficiency);', solid_pump)
        self.assertIn('liquids.add(result, maxPump);', solid_pump)
        self.assertIn('lastPump = maxPump / Time.delta;', solid_pump)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, 1f, 0.02f);', solid_pump)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, 0f, 0.02f);', solid_pump)
        self.assertIn('lastPump = 0f;', solid_pump)
        self.assertIn('pumpTime += warmup * edelta();', solid_pump)
        self.assertIn('dumpLiquid(result);', solid_pump)
        self.assertIn('if(Mathf.chance(delta() * updateEffectChance))', solid_pump)
        self.assertIn('public float warmup;', solid_pump)
        self.assertIn('public float pumpTime;', solid_pump)
        self.assertIn('public float boost;', solid_pump)
        self.assertIn('public float validTiles;', solid_pump)
        self.assertIn('public float lastPump;', solid_pump)
        self.assertIn('public class SolidPump extends Pump{', solid_pump)
        self.assertIn('public class SolidPumpBuild extends PumpBuild{', solid_pump)
        self.assertIn('public float warmup, totalProgress;', solid_pump)
        self.assertIn('public @Nullable Liquid liquidDrop = null;', solid_pump)
        self.assertIn('public Liquid result = Liquids.water;', solid_pump)
        self.assertIn('public float baseEfficiency = 1f;', solid_pump)
        self.assertIn('public float pumpAmount = 0.2f;', solid_pump)
        self.assertIn('pumpAmount = 0.11f;', solid_pump)
        self.assertIn('liquidCapacity = 40f;', solid_pump)
        self.assertIn('public float liquidCapacity = -1f;', solid_pump)
        self.assertIn('boost = sumAttribute(attribute, tile.x, tile.y) / size / size;', solid_pump)
        self.assertIn('validTiles += baseEfficiency / (size * size);', solid_pump)
        self.assertIn('public float typeLiquid(){', solid_pump)
        self.assertIn('return liquids.get(result);', solid_pump)
        self.assertIn('return Time.delta * timeScale;', solid_pump)
        self.assertIn('return efficiency * delta();', solid_pump)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', solid_pump)
        self.assertIn('public boolean noUpdateDisabled = false;', solid_pump)
        # pumpAmount is the def constant 0.11f (Blocks.java:2923,
        # overriding the Pump class default 0.2f, Pump.java:20);
        # the driver passes it as a parameter so the Fracker
        # advance (N2224) can reuse this pure function with
        # 0.25f (Blocks.java:2969).
        self.assertIn('SOURCE_SOLID_PUMP_PUMP_AMOUNT := 0.11', solid_pump)
        self.assertIn('SOURCE_SOLID_PUMP_WARMUP_RATE := 0.02', solid_pump)
        # The driver wires the advance into the live tick: the
        # source delta is game_source_delta(game, seconds) and
        # timeScale reads live from the sprite meta
        # (SourcePlacedBlockState.time_scale, default 1.0,
        # BuildingComp.java:98 `private transient float timeScale
        # = 1f, timeScaleDuration;`); the advance runs after
        # consumption (BuildingComp.java:2274 updateConsumption(),
        # then the updateTile gate at :2276-2278) and only when
        # enabled (noUpdateDisabled defaults false,
        # Block.java:170). The liquids add reuses the shared
        # module helper (SourceLiquidModuleState.source_add_state,
        # the SourcePumpRuntimeState precedent), not a
        # re-implementation.
        self.assertIn('game_source_delta(game, seconds)', solid_pump)
        self.assertIn('time_scale(sprite', solid_pump)
        self.assertIn('source_solid_pump_update_tile_advance_state(frame, source_delta, time_scale, advance_result_id, SOURCE_SOLID_PUMP_LIQUID_CAPACITY, SOURCE_SOLID_PUMP_PUMP_AMOUNT)', solid_pump)
        self.assertIn('frame["warmup"]', solid_pump)
        self.assertIn('frame["pump_time"]', solid_pump)
        self.assertIn('frame["last_pump"]', solid_pump)
        self.assertIn('frame["max_pump"]', solid_pump)
        self.assertIn('frame["fraction"]', solid_pump)
        self.assertIn('source_liquid_module_state.source_add_state(', solid_pump)
        # The documented limits now record the advance as live
        # and the remaining deferrals (live onProximityUpdate
        # fill, dumpLiquid, updateEffect); the old N2150/N2206
        # "no advance / no intake" text is gone. The N2206 gate
        # and the N2150 power row are preserved.
        self.assertIn('updateTile advance live (N2220)', solid_pump)
        self.assertNotIn('No updateTile advance', solid_pump)
        self.assertNotIn('no live intake fills the liquids store yet', solid_pump)
        self.assertIn('shouldConsume gate live (N2206)', solid_pump)
        self.assertIn('static func source_solid_pump_should_consume_state', solid_pump)
        self.assertIn('static func source_solid_pump_power_status_row_state', solid_pump)
        # The shared liquid module helper exists and adds an
        # amount by liquid id (the advance reuses it, it does
        # not re-implement the module add).
        liquid_module = LIQUID_MODULE_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_add_state(self_state: Dictionary, liquid_id: int, amount: float, cache_sums: Array) -> Dictionary:', liquid_module)
        # The proof's keys drive the pure advance (maxPump folds
        # fraction * efficiency with the capacity clamp, lastPump
        # is the maxPump rate over raw Time.delta, warmup lerps
        # toward 1 while pumping, pumpTime advances by warmup *
        # edelta with the timeScale split, no pump when full or
        # unpowered, frame defaults zero). Static checks: the
        # proof preloads the family state file that exists, and
        # the scene file references the proof script that exists.
        proof = SOLID_PUMP_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'max_pump_folds_fraction_efficiency',
            'last_pump_rate_from_max_pump',
            'warmup_approaches_one_when_pumping',
            'pump_time_advances_with_warmup',
            'no_pump_when_full',
            'frame_defaults_zero',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceSolidPumpBuildState.gd")', proof)
        self.assertTrue(SOLID_PUMP_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = SOLID_PUMP_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07SolidPumpUpdateTileProof.gd', scene)
        self.assertIn('C07SolidPumpUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_solid_pump_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SolidPumpUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOLID_PUMP_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'max_pump_folds_fraction_efficiency',
            'last_pump_rate_from_max_pump',
            'warmup_approaches_one_when_pumping',
            'pump_time_advances_with_warmup',
            'no_pump_when_full',
            'frame_defaults_zero',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
