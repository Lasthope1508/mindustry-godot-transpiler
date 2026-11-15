import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOLID_PUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceSolidPumpBuildState.gd'
SOLID_PUMP_FRACTION_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SolidPumpFractionFillProof.gd'
SOLID_PUMP_FRACTION_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SolidPumpFractionFillProof.tscn'


class C07SolidPumpFractionFillTests(unittest.TestCase):
    def test_c07_solid_pump_fraction_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2292']['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_proximity_fraction_state')
        # N2220 proved the updateTile advance (warmup / pumpTime /
        # lastPump / maxPump / fraction) from EXPLICIT fraction
        # inputs (frame valid_tiles / boost / attribute_env,
        # default 0f) -- but no live proximity fill ever set
        # them: onProximityUpdate (SolidPump.java:150-159) was
        # RED-deferred all along, so a live water-extractor
        # pumped nothing (fraction 0). N2292 is the live fill:
        # boost = sumAttribute(attribute, tile.x, tile.y) / size
        # / size (:153) with the deep-floor exclusion
        # (Block.java:575-582, 0 for deep floors when !floating
        # && !placeableLiquid) and validTiles = the canPump
        # linked-tile scan (:154-158, baseEfficiency / (size *
        # size) per pumpable tile, canPump :80-83, tile != null
        # && !tile.floor().isLiquid), with fraction =
        # Math.max(validTiles + boost + attribute.env(), 0)
        # (:124, env() Attribute.java:31-34). Three new result
        # symbols: the valid tiles, the boost, and the fraction.
        self.assertEqual(
            ledger['N2292']['source_symbols'],
            [
                'source_solid_pump_proximity_fraction_state_result.valid_tiles',
                'source_solid_pump_proximity_fraction_state_result.boost',
                'source_solid_pump_proximity_fraction_state_result.fraction',
            ],
        )
        for name in ledger['N2292']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/SolidPump.java')
                self.assertEqual(symbol['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_proximity_fraction_state')
        self.assertEqual(ledger['N2292']['runtime_proof'], '/root/C07SolidPumpFractionFillProof')
        self.assertEqual(
            ledger['N2292']['tests'],
            [
                'test_c07_solid_pump_fraction_fill_registration',
                'test_all_c07_solid_pump_fraction_fill_input_evidence_is_exact',
                'test_solid_pump_proximity_fraction_state',
                'test_reference_graph_and_actual_c07_solid_pump_fraction_fill',
            ],
        )
        self.assertTrue(ledger['N2292']['deferred_exprs'])
        # This slice resolves the live fraction fill entry: the
        # N2220 advance now reads valid_tiles / boost stamped
        # live by the N2292 fill each enabled tick. It adds the
        # linked-tiles live fill, the attribute env live fill,
        # and the onProximityUpdate trigger deferrals. The
        # updateEffect chance and the dump neighbour entries
        # stay: this slice touches neither.
        self.assertFalse(any(entry.startswith('SolidPump updateTile live fraction fill (') for entry in ledger['N2292']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump fraction linked-tiles live fill (') for entry in ledger['N2292']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump attribute env live fill (') for entry in ledger['N2292']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump onProximityUpdate trigger (') for entry in ledger['N2292']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump updateEffect chance rows (') for entry in ledger['N2292']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump dump neighbour live fill (') for entry in ledger['N2292']['deferred_exprs']))

    def test_all_c07_solid_pump_fraction_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2292']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_proximity_fraction_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/SolidPump.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/meta/Attribute.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2292']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_solid_pump_proximity_fraction_state(self):
        solid_pump = SOLID_PUMP_STATE.read_text(encoding='utf-8')
        # The live fraction fill (SolidPumpBuild.
        # onProximityUpdate(), SolidPump.java:150-159):
        # `super.onProximityAdded();` (:151 -- the parent hook,
        # not a second updateTile), then `boost = sumAttribute(
        # attribute, tile.x, tile.y) / size / size;` (:153)
        # with the deep-floor exclusion inside sumAttribute
        # (Block.java:575-582: attr null -> 0, tile null -> 0,
        # else the sum of floor().attributes over the linked
        # tiles with 0 for deep floors when !floating &&
        # !placeableLiquid), then the canPump scan (:154-158):
        # `validTiles = 0f;` and `validTiles += baseEfficiency
        # / (size * size);` per pumpable linked tile (canPump
        # :80-83, `tile != null && !tile.floor().isLiquid`).
        # The fraction (:124) is `Math.max(validTiles + boost
        # + (attribute == null ? 0 : attribute.env()), 0)`
        # with env() (Attribute.java:31-34) reading
        # Vars.state.envAttrs, 0 when Vars.state is null. The
        # water-extractor def (Blocks.java:2920-2930) sets
        # size 2, attribute Attribute.water, and leaves
        # floating / placeableLiquid at the Block class
        # defaults false (Block.java:212 / :152), so deep
        # floors contribute 0 for it. Keep each Java expr on
        # ONE comment line (the N2148 shootWarmup lesson: a
        # split line fails this test).
        self.assertIn('static func source_solid_pump_proximity_fraction_state', solid_pump)
        self.assertIn('public void onProximityUpdate(){', solid_pump)
        self.assertIn('super.onProximityAdded();', solid_pump)
        self.assertIn('boost = sumAttribute(attribute, tile.x, tile.y) / size / size;', solid_pump)
        self.assertIn('validTiles = 0f;', solid_pump)
        self.assertIn('for(Tile other : tile.getLinkedTiles(tempTiles)){', solid_pump)
        self.assertIn('if(canPump(other)){', solid_pump)
        self.assertIn('validTiles += baseEfficiency / (size * size);', solid_pump)
        self.assertIn('protected boolean canPump(Tile tile){', solid_pump)
        self.assertIn('return tile != null && !tile.floor().isLiquid;', solid_pump)
        self.assertIn('public float baseEfficiency = 1f;', solid_pump)
        self.assertIn('float fraction = Math.max(validTiles + boost + (attribute == null ? 0 : attribute.env()), 0);', solid_pump)
        self.assertIn('public float sumAttribute(@Nullable Attribute attr, int x, int y){', solid_pump)
        self.assertIn('if(attr == null) return 0;', solid_pump)
        self.assertIn('if(tile == null) return 0;', solid_pump)
        self.assertIn('return tile.getLinkedTilesAs(this, tempTiles)', solid_pump)
        self.assertIn('.sumf(other -> !floating && !placeableLiquid && other.floor().isDeep() ? 0 : other.floor().attributes.get(attr));', solid_pump)
        self.assertIn('public float env(){', solid_pump)
        self.assertIn('if(Vars.state == null) return 0;', solid_pump)
        self.assertIn('return Vars.state.envAttrs.get(this);', solid_pump)
        self.assertIn('public boolean floating = false;', solid_pump)
        self.assertIn('public boolean placeableLiquid = false;', solid_pump)
        self.assertIn('attribute = Attribute.water;', solid_pump)
        self.assertIn('size = 2;', solid_pump)
        # The pure returns exactly the three N2292 keys, and
        # the def constants ride driver consts (the N2190
        # fogRadius / N2199 transportTime def-constant
        # precedent): size 2 (Blocks.java:2924) and
        # baseEfficiency 1f (SolidPump.java:26).
        self.assertIn('return {"valid_tiles": valid_tiles, "boost": boost, "fraction": fraction}', solid_pump)
        self.assertIn('SOURCE_SOLID_PUMP_SIZE := 2', solid_pump)
        self.assertIn('SOURCE_SOLID_PUMP_BASE_EFFICIENCY := 1.0', solid_pump)
        # The tick wires the fill BEFORE the advance (Java
        # order: onProximityUpdate stamps validTiles / boost,
        # updateTile reads them at :124), inside the same
        # enabled gate as the advance (BuildingComp.java:
        # 2276-2277). The linked tiles are frame inputs
        # (default [] -- no tiles, the Java empty-proximity
        # outcome) until a live tile scan lands; the
        # attribute env is the N2220 frame input (default
        # 0.0); floating / placeableLiquid ride the Block
        # class defaults false and has_attribute is true for
        # the water-extractor def (attribute = Attribute.water,
        # Blocks.java:2927). The fill stamps valid_tiles /
        # boost onto the frame; the fraction is recomputed by
        # the N2220 advance from the stamped keys.
        self.assertIn('frame.get("proximity_linked_tiles", [])', solid_pump)
        self.assertIn('source_solid_pump_proximity_fraction_state(proximity_tiles, SOURCE_SOLID_PUMP_SIZE, SOURCE_SOLID_PUMP_BASE_EFFICIENCY, float(frame.get("attribute_env", 0.0)), false, false, true)', solid_pump)
        self.assertIn('frame["valid_tiles"] = filled["valid_tiles"]', solid_pump)
        self.assertIn('frame["boost"] = filled["boost"]', solid_pump)
        self.assertLess(
            solid_pump.index('source_solid_pump_proximity_fraction_state(proximity_tiles, SOURCE_SOLID_PUMP_SIZE, SOURCE_SOLID_PUMP_BASE_EFFICIENCY, float(frame.get("attribute_env", 0.0)), false, false, true)'),
            solid_pump.index('source_solid_pump_update_tile_advance_state(frame, source_delta, time_scale, advance_result_id, SOURCE_SOLID_PUMP_LIQUID_CAPACITY, SOURCE_SOLID_PUMP_PUMP_AMOUNT)'),
        )
        # The documented limits now record the fraction fill as
        # live (recomputed each enabled tick from frame
        # proximity inputs) and the remaining deferrals (the
        # linked-tiles live fill, the env live fill, the
        # updateEffect chance); the N2220 advance, the N2206
        # gate, the N2150 power row, and the N2286 dump rows
        # are preserved.
        self.assertIn('Fraction fill live (N2292)', solid_pump)
        self.assertIn('Dump rows live (N2286)', solid_pump)
        self.assertIn('updateTile advance live (N2220)', solid_pump)
        self.assertIn('shouldConsume gate live (N2206)', solid_pump)
        self.assertIn('static func source_solid_pump_power_status_row_state', solid_pump)
        self.assertIn('static func source_solid_pump_should_consume_state', solid_pump)
        self.assertIn('static func source_solid_pump_update_tile_advance_state', solid_pump)
        self.assertIn('static func source_solid_pump_dump_liquid_state', solid_pump)
        # The pure N2220 advance is untouched: its return dict
        # keeps exactly the five N2220 keys and the fill wires
        # BEFORE its call, never inside it.
        self.assertIn('return {"warmup": next_warmup, "pump_time": next_pump_time, "last_pump": last_pump, "max_pump": max_pump, "fraction": fraction}', solid_pump)
        # The proof's keys drive the pure fill (validTiles
        # counts pumpable tiles at baseEfficiency / size^2,
        # boost sums the floor attributes over size^2, deep
        # floors contribute 0 when !floating &&
        # !placeableLiquid, the fraction clamps at zero, the
        # env adds only when the attribute is present) plus
        # the live tick (a placed water-extractor fills
        # valid_tiles / boost / fraction in one tick).
        proof = SOLID_PUMP_FRACTION_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'valid_tiles_counts_pumpable',
            'boost_sums_attributes',
            'deep_floor_excluded_when_not_floating',
            'fraction_clamps_at_zero',
            'env_adds_when_attribute_present',
            'live_tick_fills_fraction',
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
        self.assertIn('solid_pump_build_state.source_solid_pump_proximity_fraction_state(', proof)
        self.assertIn('solid_pump_build_state.source_solid_pump_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = SOLID_PUMP_FRACTION_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07SolidPumpFractionFillProof.gd', scene)
        self.assertIn('C07SolidPumpFractionFillProof', scene)

    def test_reference_graph_and_actual_c07_solid_pump_fraction_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SolidPumpFractionFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOLID_PUMP_FRACTION_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'valid_tiles_counts_pumpable',
            'boost_sums_attributes',
            'deep_floor_excluded_when_not_floating',
            'fraction_clamps_at_zero',
            'env_adds_when_attribute_present',
            'live_tick_fills_fraction',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
