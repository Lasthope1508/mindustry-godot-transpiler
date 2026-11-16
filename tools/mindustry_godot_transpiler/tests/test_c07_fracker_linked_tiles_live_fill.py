import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FRACKER_STATE = ROOT / 'godot-mindustry/src/game/SourceFrackerBuildState.gd'
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
SOLID_PUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceSolidPumpBuildState.gd'
FRACKER_LINKED_TILES_LIVE_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerLinkedTilesLiveFillProof.gd'
FRACKER_LINKED_TILES_LIVE_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerLinkedTilesLiveFillProof.tscn'
FRACKER_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/production/Fracker.java'
SOLID_PUMP_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/production/SolidPump.java'
TILE_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/Tile.java'
BLOCK_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/Block.java'
BLOCKS_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/content/Blocks.java'


class C07FrackerLinkedTilesLiveFillTests(unittest.TestCase):
    def test_c07_fracker_linked_tiles_live_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2414']['godot_owner'], 'SourceFrackerBuildState.source_fracker_linked_tiles_live_fill_state')
        # N2305 ported the fraction fill (onProximityUpdate,
        # SolidPump.java:150-159, recomputed each enabled tick
        # from frame["proximity_linked_tiles"], default []) --
        # but the linked tiles stayed frame inputs, so a live
        # oil-extractor with no fill read an empty proximity
        # and pumped nothing. N2414 is the live fill: the tick
        # scans the tile map (frame["world_tiles"], the
        # BeamDrill N2339 pattern, Dict keyed "x,y") over the
        # fracker's linked-tile footprint (Tile.getLinkedTiles,
        # Tile.java:474-485: the size x size footprint walk,
        # NOT a ring) BEFORE the N2305 recompute and fills the
        # per-tile dict array ({can_pump, attribute_value,
        # is_deep}) from the floor state. One new symbol: the
        # filled linked-tile dict array.
        self.assertEqual(
            ledger['N2414']['source_symbols'],
            [
                'source_fracker_linked_tiles_live_fill_state_result.proximity_linked_tiles',
            ],
        )
        for name in ledger['N2414']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Fracker.java',
                    'core/src/mindustry/world/blocks/production/SolidPump.java',
                    'core/src/mindustry/world/Tile.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_linked_tiles_live_fill_state')
        self.assertEqual(ledger['N2414']['runtime_proof'], '/root/C07FrackerLinkedTilesLiveFillProof')
        self.assertEqual(
            ledger['N2414']['tests'],
            [
                'test_c07_fracker_linked_tiles_live_fill_registration',
                'test_all_c07_fracker_linked_tiles_live_fill_input_evidence_is_exact',
                'test_fracker_linked_tiles_live_fill_state',
                'test_reference_graph_and_actual_c07_fracker_linked_tiles_live_fill',
            ],
        )
        self.assertTrue(ledger['N2414']['deferred_exprs'])
        # This slice RESOLVES the Fracker fraction
        # linked-tiles live fill entry (DEFERRED #247 in the
        # coordinator's merged numbering, base
        # DEFERRED-after-advances-23, 291 entries): the fill
        # is live now, so the entry is REMOVED and the list
        # drops to 290. No new entry: the live tile-producer
        # gap (no producer stamps the floor fields onto
        # frame["world_tiles"] yet) is a follow-through note,
        # not a deferral -- the pure + frame input work with
        # seeded maps. The attribute-env, onProximityUpdate
        # trigger, item-intake, and SolidPump linked-tiles
        # entries stay verbatim.
        self.assertEqual(len(ledger['N2414']['deferred_exprs']), 290)
        self.assertFalse(any(entry.startswith('Fracker fraction linked-tiles live fill (') for entry in ledger['N2414']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker attribute env live fill (') for entry in ledger['N2414']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker onProximityUpdate trigger (') for entry in ledger['N2414']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker item intake (') for entry in ledger['N2414']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump fraction linked-tiles live fill (') for entry in ledger['N2414']['deferred_exprs']))

    def test_all_c07_fracker_linked_tiles_live_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2414']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_linked_tiles_live_fill_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Fracker.java',
            'core/src/mindustry/world/blocks/production/SolidPump.java',
            'core/src/mindustry/world/Tile.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2414']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_fracker_linked_tiles_live_fill_state(self):
        fracker = FRACKER_STATE.read_text(encoding='utf-8')
        # The live fill (N2414, DEFERRED #247): the tick fills
        # the linked-tile dict array from the live tile map
        # BEFORE the N2305 fraction recompute reads it. The
        # linked tiles are the size x size FOOTPRINT
        # (Tile.getLinkedTiles, Tile.java:474-485 -- dx outer
        # 0..size-1, dy inner 0..size-1, at (x + dx + o,
        # y + dy + o) with o = sizeOffset = -((size - 1) / 2),
        # Block.java:762/1430), NOT a ring: for the size-3
        # oil-extractor the footprint is the 3x3 centred on
        # the origin cell. Java skips null tiles
        # (`if(other != null) cons.get(other);`, Tile.java:480),
        # so a missing / null / non-Dict map entry contributes
        # no dict -- an empty map fills an empty list. Each
        # entry is the exact N2305 dict shape ({can_pump,
        # attribute_value, is_deep}): can_pump is the canPump
        # answer (`tile != null && !tile.floor().isLiquid`,
        # SolidPump.java:80-81), attribute_value is the floor
        # OIL attribute (sumAttribute, Block.java:575-582 --
        # the value adds whether or not the tile is pumpable,
        # the N2305 note), is_deep is the deep-floor flag
        # (the N2305 pure applies the deep exclusion,
        # Block.java:580, not this fill). Keep each Java expr
        # on ONE comment line (the N2148 lesson: a split line
        # fails this test).
        self.assertIn('static func source_fracker_linked_tiles_live_fill_state(world_tiles: Dictionary, cell: Vector2i, size: int) -> Dictionary:', fracker)
        self.assertIn('protected boolean canPump(Tile tile){', fracker)
        self.assertIn('return tile != null && !tile.floor().isLiquid;', fracker)
        self.assertIn('public void getLinkedTiles(Cons<Tile> cons){', fracker)
        self.assertIn('int size = block.size, o = block.sizeOffset;', fracker)
        self.assertIn('for(int dx = 0; dx < size; dx++){', fracker)
        self.assertIn('for(int dy = 0; dy < size; dy++){', fracker)
        self.assertIn('Tile other = world.tile(x + dx + o, y + dy + o);', fracker)
        self.assertIn('if(other != null) cons.get(other);', fracker)
        self.assertIn('sizeOffset = -((size - 1) / 2);', fracker)
        self.assertIn('public float sumAttribute(@Nullable Attribute attr, int x, int y){', fracker)
        self.assertIn('.sumf(other -> !floating && !placeableLiquid && other.floor().isDeep() ? 0 : other.floor().attributes.get(attr));', fracker)
        self.assertIn('for(Tile other : tile.getLinkedTiles(tempTiles)){', fracker)
        self.assertIn('boost = sumAttribute(attribute, tile.x, tile.y) / size / size;', fracker)
        self.assertIn('attribute = Attribute.oil;', fracker)
        # DESIGN DECISION (verified, not guessed): the
        # BeamDrill world_tiles convention carries {solid,
        # wall_drop} per tile (SourceBeamDrillBuildState.gd:
        # 374) and NO floor / attribute / deep fields, and no
        # producer stamps frame["world_tiles"] anywhere -- the
        # BeamDrill tick only reads it (frame.get default {})
        # and proofs seed it. So this slice defines the
        # MINIMAL extension in the pure's input contract
        # ({floor_is_liquid, oil_attribute, is_deep} per tile)
        # and documents the producer gap (the live tile
        # producer that stamps those fields waits for its own
        # slice) -- it does NOT invent a tile producer.
        beam_drill = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        self.assertIn('world_tiles is a Dict keyed "x,y" to {solid,', beam_drill)
        self.assertNotIn('floor_is_liquid', beam_drill)
        self.assertNotIn('oil_attribute', beam_drill)
        self.assertIn('floor_is_liquid', fracker)
        self.assertIn('oil_attribute', fracker)
        self.assertIn('tile producer', fracker)
        # The fill walks the footprint in Java order (dx
        # outer, dy inner) from the sizeOffset, skips missing
        # tiles, and builds one N2305-shaped dict per present
        # tile.
        self.assertIn('var size_offset: int = -((size - 1) / 2)', fracker)
        self.assertIn('world_tiles.get(str(cell.x + dx + size_offset) + "," + str(cell.y + dy + size_offset), null)', fracker)
        self.assertIn('{"can_pump": not bool(tile.get("floor_is_liquid", false)), "attribute_value": float(tile.get("oil_attribute", 0.0)), "is_deep": bool(tile.get("is_deep", false))}', fracker)
        self.assertIn('"proximity_linked_tiles": linked_tiles', fracker)
        # The fill is called exactly once (its definition plus
        # the one tick call site), with the frame tile map,
        # the origin cell inline (cell is bound after the
        # enabled block, the N2363 note), and the catalog size.
        self.assertEqual(fracker.count('source_fracker_linked_tiles_live_fill_state('), 2)
        self.assertIn('source_fracker_linked_tiles_live_fill_state(world_tiles, fill_cell, int(block.properties.get("size", 1)))', fracker)
        # The tick wires the fill BEFORE the N2305 recompute
        # reads the frame array: frame["world_tiles"] defaults
        # to {} (an empty map fills an empty list, preserving
        # the no-fill behavior). A supplied array WINS (the
        # N2381 precedent -- the N2305 proof seeds
        # proximity_linked_tiles by hand, so a fill there
        # would overwrite the seed), and a previously
        # live-filled frame (proximity_linked_tiles_live --
        # port bookkeeping, not Java state, the N2394
        # precedent) refreshes every tick.
        self.assertIn('has_supplied_proximity_linked_tiles', fracker)
        self.assertIn('frame.get("world_tiles", {})', fracker)
        self.assertIn('frame["proximity_linked_tiles_live"] = true', fracker)
        self.assertIn('bool(frame.get("proximity_linked_tiles_live", false))', fracker)
        self.assertLess(
            fracker.index('source_fracker_linked_tiles_live_fill_state(world_tiles, fill_cell, int(block.properties.get("size", 1)))'),
            fracker.index('frame.get("proximity_linked_tiles", [])'),
        )
        self.assertLess(
            fracker.index('frame["proximity_linked_tiles"] = filled.get("proximity_linked_tiles", [])'),
            fracker.index('frame.get("proximity_linked_tiles", [])'),
        )
        # The N2305 fraction pins still hold: the recompute
        # call, the frame-input read, the valid_tiles / boost
        # stamps, and the doc strings.
        self.assertIn('source_fracker_proximity_fraction_state(proximity_tiles, float(frame.get("attribute_env", 0.0)))', fracker)
        self.assertIn('frame["valid_tiles"] = fraction_filled["valid_tiles"]', fracker)
        self.assertIn('frame["boost"] = fraction_filled["boost"]', fracker)
        self.assertIn('Fraction fill live (N2305)', fracker)
        self.assertIn('dumpLiquid live (N2284)', fracker)
        self.assertIn('shouldConsume gate live (N2207)', fracker)
        self.assertIn('updateTile advance live (N2224)', fracker)
        # The documented limits now record the linked-tile
        # scan as live (N2414).
        self.assertIn('linked-tile scan live since N2414', fracker)
        self.assertIn('static func source_fracker_proximity_fraction_state', fracker)
        self.assertIn('static func source_fracker_update_tile_advance_state', fracker)
        self.assertIn('static func source_fracker_should_consume_state', fracker)
        self.assertIn('static func source_fracker_tick_buildings_state', fracker)
        # The N2305 consumer contract still holds: the N2292
        # SolidPump pure reads {can_pump, attribute_value,
        # is_deep} per entry (can_pump gates validTiles,
        # is_deep excludes the attribute sum when !floating &&
        # !placeableLiquid).
        solid_pump = SOLID_PUMP_STATE.read_text(encoding='utf-8')
        self.assertIn('tile.get("can_pump", false)', solid_pump)
        self.assertIn('tile.get("is_deep", false)', solid_pump)
        self.assertIn('tile.get("attribute_value", 0.0)', solid_pump)
        # Scope pins, by Java line number: canPump
        # (SolidPump.java:80-81), the linked-tile walk
        # (Tile.java:474-480), the size offset
        # (Block.java:762), sumAttribute (Block.java:575,
        # :580), and the def constants (Blocks.java:2970,
        # :2972-2973).
        solid_pump_lines = SOLID_PUMP_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(solid_pump_lines[79].strip(), 'protected boolean canPump(Tile tile){')
        self.assertEqual(solid_pump_lines[80].strip(), 'return tile != null && !tile.floor().isLiquid;')
        self.assertEqual(solid_pump_lines[152].strip(), 'boost = sumAttribute(attribute, tile.x, tile.y) / size / size;')
        self.assertEqual(solid_pump_lines[154].strip(), 'for(Tile other : tile.getLinkedTiles(tempTiles)){')
        tile_lines = TILE_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(tile_lines[473].strip(), 'public void getLinkedTiles(Cons<Tile> cons){')
        self.assertEqual(tile_lines[475].strip(), 'int size = block.size, o = block.sizeOffset;')
        self.assertEqual(tile_lines[476].strip(), 'for(int dx = 0; dx < size; dx++){')
        self.assertEqual(tile_lines[477].strip(), 'for(int dy = 0; dy < size; dy++){')
        self.assertEqual(tile_lines[478].strip(), 'Tile other = world.tile(x + dx + o, y + dy + o);')
        self.assertEqual(tile_lines[479].strip(), 'if(other != null) cons.get(other);')
        block_lines = BLOCK_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(block_lines[574].strip(), 'public float sumAttribute(@Nullable Attribute attr, int x, int y){')
        self.assertEqual(block_lines[579].strip(), '.sumf(other -> !floating && !placeableLiquid && other.floor().isDeep() ? 0 : other.floor().attributes.get(attr));')
        self.assertEqual(block_lines[761].strip(), 'sizeOffset = -((size - 1) / 2);')
        blocks_lines = BLOCKS_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(blocks_lines[2969].strip(), 'size = 3;')
        self.assertEqual(blocks_lines[2971].strip(), 'attribute = Attribute.oil;')
        self.assertEqual(blocks_lines[2972].strip(), 'baseEfficiency = 0f;')
        # The proof's keys drive the fill (linked tiles filled
        # from the live tile map, the can_pump gate requiring
        # a non-liquid floor, attribute values summed from the
        # floors, the deep flag carried, no tile map reporting
        # empty) plus the live tick (a live fracker with the
        # fill pumps).
        proof = FRACKER_LINKED_TILES_LIVE_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'linked_tiles_filled_from_live_tile_map',
            'can_pump_gate_requires_non_liquid_floor',
            'attribute_values_summed_from_floors',
            'deep_flag_carried',
            'no_tile_map_reports_empty',
            'live_tick_pumps_with_fill',
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
        self.assertIn('fracker_build_state.source_fracker_linked_tiles_live_fill_state(', proof)
        self.assertIn('fracker_build_state.source_fracker_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = FRACKER_LINKED_TILES_LIVE_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07FrackerLinkedTilesLiveFillProof.gd', scene)
        self.assertIn('C07FrackerLinkedTilesLiveFillProof', scene)

    def test_reference_graph_and_actual_c07_fracker_linked_tiles_live_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07FrackerLinkedTilesLiveFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FRACKER_LINKED_TILES_LIVE_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'linked_tiles_filled_from_live_tile_map',
            'can_pump_gate_requires_non_liquid_floor',
            'attribute_values_summed_from_floors',
            'deep_flag_carried',
            'no_tile_map_reports_empty',
            'live_tick_pumps_with_fill',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
