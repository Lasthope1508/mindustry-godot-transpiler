import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FRACKER_STATE = ROOT / 'godot-mindustry/src/game/SourceFrackerBuildState.gd'
FRACKER_FRACTION_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerFractionFillProof.gd'
FRACKER_FRACTION_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerFractionFillProof.tscn'


class C07FrackerFractionFillTests(unittest.TestCase):
    def test_c07_fracker_fraction_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2305']['godot_owner'], 'SourceFrackerBuildState.source_fracker_proximity_fraction_state')
        # N2224 proved the updateTile advance (accumulator /
        # warmup / pumpTime / lastPump / maxPump / fraction /
        # items) from EXPLICIT fraction inputs (frame
        # valid_tiles / boost / attribute_env, default 0f) --
        # but no live proximity fill ever set them:
        # onProximityUpdate (SolidPump.java:150-159, inherited
        # by FrackerBuild -- Fracker does NOT override it) was
        # RED-deferred all along, so a live oil-extractor
        # pumped nothing (fraction 0). N2305 is the live fill:
        # boost = sumAttribute(attribute, tile.x, tile.y) /
        # size / size (:153) with the deep-floor exclusion
        # (Block.java:575-582, 0 for deep floors when
        # !floating && !placeableLiquid) and validTiles = the
        # canPump linked-tile scan (:154-158, baseEfficiency /
        # (size * size) per pumpable tile, canPump :80-83, tile
        # != null && !tile.floor().isLiquid), with fraction =
        # Math.max(validTiles + boost + attribute.env(), 0)
        # (:124, env() Attribute.java:31-34). The
        # oil-extractor def sets attribute = Attribute.oil
        # (Blocks.java:2972) and baseEfficiency = 0f
        # (Blocks.java:2973), so validTiles is ALWAYS 0 and
        # the fraction is boost + env only. Three new result
        # symbols: the valid tiles, the boost, and the
        # fraction. The computation is inherited verbatim
        # from SolidPump.java, so the result symbols cite
        # SolidPump.java as their java_source.
        self.assertEqual(
            ledger['N2305']['source_symbols'],
            [
                'source_fracker_proximity_fraction_state_result.valid_tiles',
                'source_fracker_proximity_fraction_state_result.boost',
                'source_fracker_proximity_fraction_state_result.fraction',
            ],
        )
        for name in ledger['N2305']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/SolidPump.java')
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_proximity_fraction_state')
        self.assertEqual(ledger['N2305']['runtime_proof'], '/root/C07FrackerFractionFillProof')
        self.assertEqual(
            ledger['N2305']['tests'],
            [
                'test_c07_fracker_fraction_fill_registration',
                'test_all_c07_fracker_fraction_fill_input_evidence_is_exact',
                'test_fracker_proximity_fraction_state',
                'test_reference_graph_and_actual_c07_fracker_fraction_fill',
            ],
        )
        self.assertTrue(ledger['N2305']['deferred_exprs'])
        # This slice resolves the Fracker fraction entry: the
        # N2224 advance now reads valid_tiles / boost stamped
        # live by the N2305 fill each enabled tick. It adds the
        # linked-tiles live fill, the attribute env live fill,
        # and the onProximityUpdate trigger deferrals. The item
        # intake and the dump neighbour entries stay: this
        # slice touches neither.
        self.assertFalse(any(entry.startswith('Fracker water-attribute / validTiles / boost fraction rows (') for entry in ledger['N2305']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker fraction linked-tiles live fill (') for entry in ledger['N2305']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker attribute env live fill (') for entry in ledger['N2305']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker onProximityUpdate trigger (') for entry in ledger['N2305']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker item intake (') for entry in ledger['N2305']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker dumpLiquid neighbour live fill (') for entry in ledger['N2305']['deferred_exprs']))

    def test_all_c07_fracker_fraction_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2305']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_proximity_fraction_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/Fracker.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/SolidPump.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/meta/Attribute.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2305']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_fracker_proximity_fraction_state(self):
        fracker = FRACKER_STATE.read_text(encoding='utf-8')
        # The live fraction fill (SolidPumpBuild.
        # onProximityUpdate(), SolidPump.java:150-159,
        # INHERITED by FrackerBuild -- Fracker does NOT
        # override it, Fracker.java has no onProximityUpdate):
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
        # oil-extractor def (Blocks.java:2964-2979) sets size
        # 3, attribute Attribute.oil (:2972 -- the Fracker
        # CLASS sets no attribute, but the DEF does) and
        # baseEfficiency 0f (:2973, overriding the class
        # default 1f), and leaves floating / placeableLiquid
        # at the Block class defaults false (Block.java:212 /
        # :152), so deep floors contribute 0 for it and
        # validTiles is ALWAYS 0. Keep each Java expr on ONE
        # comment line (the N2148 shootWarmup lesson: a split
        # line fails this test).
        self.assertIn('static func source_fracker_proximity_fraction_state(linked_tiles: Array, attribute_env: float) -> Dictionary:', fracker)
        self.assertIn('public class Fracker extends SolidPump{', fracker)
        self.assertIn('public class FrackerBuild extends SolidPumpBuild{', fracker)
        self.assertIn('public void onProximityUpdate(){', fracker)
        self.assertIn('super.onProximityAdded();', fracker)
        self.assertIn('boost = sumAttribute(attribute, tile.x, tile.y) / size / size;', fracker)
        self.assertIn('validTiles = 0f;', fracker)
        self.assertIn('for(Tile other : tile.getLinkedTiles(tempTiles)){', fracker)
        self.assertIn('if(canPump(other)){', fracker)
        self.assertIn('validTiles += baseEfficiency / (size * size);', fracker)
        self.assertIn('protected boolean canPump(Tile tile){', fracker)
        self.assertIn('return tile != null && !tile.floor().isLiquid;', fracker)
        self.assertIn('public float baseEfficiency = 1f;', fracker)
        self.assertIn('float fraction = Math.max(validTiles + boost + (attribute == null ? 0 : attribute.env()), 0);', fracker)
        self.assertIn('public float sumAttribute(@Nullable Attribute attr, int x, int y){', fracker)
        self.assertIn('if(attr == null) return 0;', fracker)
        self.assertIn('if(tile == null) return 0;', fracker)
        self.assertIn('return tile.getLinkedTilesAs(this, tempTiles)', fracker)
        self.assertIn('.sumf(other -> !floating && !placeableLiquid && other.floor().isDeep() ? 0 : other.floor().attributes.get(attr));', fracker)
        self.assertIn('public float env(){', fracker)
        self.assertIn('if(Vars.state == null) return 0;', fracker)
        self.assertIn('return Vars.state.envAttrs.get(this);', fracker)
        self.assertIn('public boolean floating = false;', fracker)
        self.assertIn('public boolean placeableLiquid = false;', fracker)
        self.assertIn('attribute = Attribute.oil;', fracker)
        self.assertIn('size = 3;', fracker)
        self.assertIn('baseEfficiency = 0f;', fracker)
        # The Fracker pure DELEGATES to the N2292 SolidPump
        # pure (the N2221 cross-driver preload precedent --
        # the N2224 advance already reuses the N2220 pure the
        # same way) with the oil-extractor def constants bound
        # in the wrapper: size 3 (Blocks.java:2970) and
        # baseEfficiency 0f (Blocks.java:2973), attribute
        # present (oil, Blocks.java:2972), floating /
        # placeableLiquid false. The driver calls the Fracker
        # pure only -- the SolidPump pure is called exactly
        # once in this file, inside the delegate.
        self.assertIn('return source_solid_pump_state.source_solid_pump_proximity_fraction_state(linked_tiles, SOURCE_FRACKER_SIZE, SOURCE_FRACKER_BASE_EFFICIENCY, attribute_env, false, false, true)', fracker)
        self.assertEqual(fracker.count('source_solid_pump_state.source_solid_pump_proximity_fraction_state('), 1)
        self.assertIn('SOURCE_FRACKER_SIZE := 3', fracker)
        self.assertIn('SOURCE_FRACKER_BASE_EFFICIENCY := 0.0', fracker)
        # The tick wires the fill BEFORE the advance (Java
        # order: onProximityUpdate stamps validTiles / boost,
        # updateTile reads them at :124), inside the same
        # enabled gate as the advance (BuildingComp.java:
        # 2276-2277). The linked tiles are frame inputs
        # (default [] -- no tiles, the Java empty-proximity
        # outcome) until a live tile scan lands; the
        # attribute env is the N2224 frame input (default
        # 0.0). The fill stamps valid_tiles / boost onto the
        # frame; the fraction is recomputed by the N2224
        # advance from the stamped keys.
        self.assertIn('frame.get("proximity_linked_tiles", [])', fracker)
        self.assertIn('source_fracker_proximity_fraction_state(proximity_tiles, float(frame.get("attribute_env", 0.0)))', fracker)
        self.assertIn('frame["valid_tiles"] = filled["valid_tiles"]', fracker)
        self.assertIn('frame["boost"] = filled["boost"]', fracker)
        self.assertLess(
            fracker.index('source_fracker_proximity_fraction_state(proximity_tiles, float(frame.get("attribute_env", 0.0)))'),
            fracker.index('source_fracker_update_tile_advance_state(frame, source_delta, time_scale, advance_result_id, SOURCE_FRACKER_LIQUID_CAPACITY, SOURCE_FRACKER_PUMP_AMOUNT, SOURCE_FRACKER_ITEM_USE_TIME)'),
        )
        # The documented limits now record the fraction fill as
        # live (recomputed each enabled tick from frame
        # proximity inputs) and the remaining deferrals (the
        # linked-tiles live fill, the env live fill, the
        # proximity-change trigger); the N2224 advance, the
        # N2284 dump rows, the N2207 gate, the N2255 liquid
        # row, the N2268 item row, and the N2153 power row are
        # preserved.
        self.assertIn('Fraction fill live (N2305)', fracker)
        self.assertIn('dumpLiquid live (N2284)', fracker)
        self.assertIn('updateTile advance live (N2224)', fracker)
        self.assertIn('shouldConsume gate live (N2207)', fracker)
        self.assertIn('liquid row live (N2255)', fracker)
        self.assertIn('item row live (N2268)', fracker)
        self.assertIn('static func source_fracker_power_status_row_state', fracker)
        self.assertIn('static func source_fracker_should_consume_state', fracker)
        self.assertIn('static func source_fracker_update_tile_advance_state', fracker)
        self.assertIn('static func source_fracker_dump_liquid_state', fracker)
        # The pure N2224 advance is untouched: its return dict
        # keeps exactly the seven N2224 keys and the fill wires
        # BEFORE its call, never inside it.
        self.assertIn('return {"accumulator": accumulator, "warmup": next_warmup, "pump_time": next_pump_time, "last_pump": last_pump, "max_pump": max_pump, "fraction": fraction, "items": items}', fracker)
        # The proof's keys drive the pure fill (validTiles
        # stays 0 with baseEfficiency 0f, boost sums the oil
        # attributes over size^2, deep floors contribute 0
        # when !floating && !placeableLiquid, the fraction
        # clamps at zero, the env adds when the attribute is
        # present) plus the live tick (a placed oil-extractor
        # fills valid_tiles / boost / fraction in one tick).
        proof = FRACKER_FRACTION_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'valid_tiles_zero_with_zero_base_efficiency',
            'boost_sums_oil_attributes',
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
        self.assertIn('preload("res://src/game/SourceFrackerBuildState.gd")', proof)
        self.assertTrue(FRACKER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('fracker_build_state.source_fracker_proximity_fraction_state(', proof)
        self.assertIn('fracker_build_state.source_fracker_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = FRACKER_FRACTION_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07FrackerFractionFillProof.gd', scene)
        self.assertIn('C07FrackerFractionFillProof', scene)

    def test_reference_graph_and_actual_c07_fracker_fraction_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07FrackerFractionFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FRACKER_FRACTION_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'valid_tiles_zero_with_zero_base_efficiency',
            'boost_sums_oil_attributes',
            'deep_floor_excluded_when_not_floating',
            'fraction_clamps_at_zero',
            'env_adds_when_attribute_present',
            'live_tick_fills_fraction',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
