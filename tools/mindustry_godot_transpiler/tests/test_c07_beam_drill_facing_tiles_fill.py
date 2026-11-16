import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_FACING_TILES_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillFacingTilesFillProof.gd'
BEAM_DRILL_FACING_TILES_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillFacingTilesFillProof.tscn'


class C07BeamDrillFacingTilesFillTests(unittest.TestCase):
    def test_c07_beam_drill_facing_tiles_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2352']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_facing_tiles_fill_state')
        # N2339 gave the beam drill its updateFacing COUNT
        # (source_beam_drill_facing_scan_state over the
        # frame facing_tiles) and N2346 gave it the laser
        # ORIGINS (source_beam_drill_laser_origins_state,
        # the nearbySide geometry stamped onto
        # frame["lasers"]) -- but nothing ever FILLED
        # frame["facing_tiles"] from those origins: the
        # scan read caller-supplied rays, and a live beam
        # drill with no supplied facing_tiles read an
        # empty proximity and facing_amount stayed 0.
        # N2352 is the fill: updateFacing()
        # (BeamDrill.java:375-411) walks each laser ray
        # from `Point2 l = lasers[p];` through
        # `world.tile(rx, ry)` (:388) along the rotation
        # (`int dx = Geometry.d4x(rotation), dy =
        # Geometry.d4y(rotation);`, :378), so the pure
        # walks the same rays from frame["lasers"]
        # through the frame input world_tiles (a Dict
        # keyed "x,y" to {solid, wall_drop}, default {})
        # and returns the rays in exactly the format the
        # N2339 scan reads -- one Array per laser in
        # laser order, one entry per tile in walk order
        # (a Dict {solid, wall_drop} or null for a tile
        # the world has no answer for). The tick stamps
        # frame["facing_tiles"] each enabled tick BEFORE
        # the facing scan (Java order: updateLasers /
        # updateFacing in onProximityUpdate :364-365,
        # updateFacing inside updateTile :244 before the
        # advance) -- every enabled tick (N2366: the
        # is_empty gate is gone; a tick with no
        # world_tiles fills all-null rays, the Java
        # no-facing-wall outcome, and the N2339 proof
        # seeds world_tiles now, so no proof seeds
        # facing_tiles directly anymore). One new result
        # symbol: the filled facing rays.
        self.assertEqual(
            ledger['N2352']['source_symbols'],
            [
                'source_beam_drill_facing_tiles_fill_state_result.facing_tiles',
            ],
        )
        for name in ledger['N2352']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/BeamDrill.java')
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_facing_tiles_fill_state')
        self.assertEqual(ledger['N2352']['runtime_proof'], '/root/C07BeamDrillFacingTilesFillProof')
        self.assertEqual(
            ledger['N2352']['tests'],
            [
                'test_c07_beam_drill_facing_tiles_fill_registration',
                'test_all_c07_beam_drill_facing_tiles_fill_input_evidence_is_exact',
                'test_beam_drill_facing_tiles_fill_state',
                'test_reference_graph_and_actual_c07_beam_drill_facing_tiles_fill',
            ],
        )
        self.assertTrue(ledger['N2352']['deferred_exprs'])
        # This slice REWRITES the facing / laser binding
        # entry (324) in place: the facing-tile FILL is
        # live since N2352 (the fill pure walks each
        # laser ray from frame["lasers"] through the
        # frame input world_tiles, stamped each enabled
        # tick before the facing scan), but the LIVE
        # world-tile query still waits (no live world
        # query exists, so world_tiles is a frame input
        # and a live beam drill with no supplied
        # world_tiles gets all-null rays from the fill
        # and facing_amount 0 -- N2366 removed the
        # is_empty gate that used to keep the previous
        # facing_tiles), and lastItem / facing[] wait
        # for the drop-loop slice (entry 183 in the
        # advances-16 merged numbering -- the old text
        # cited entry 187, stale from the advances-15
        # numbering). The facing count (live since
        # N2339) and the laser geometry (live since
        # N2346) are preserved in the rewritten text,
        # and the drop loop + drillMultipliers entries
        # stay.
        self.assertTrue(any(entry.startswith('BeamDrill facing / laser binding (') and 'live since N2352' in entry and 'live since N2339' in entry and 'live since N2346' in entry for entry in ledger['N2352']['deferred_exprs']))
        self.assertFalse(any('still waiting: the LIVE facing-tile fill' in entry for entry in ledger['N2352']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill facing / laser binding (') and 'LIVE world-tile query' in entry for entry in ledger['N2352']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill drop loop + time reset + lastDrillSpeed (') for entry in ledger['N2352']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill drillMultipliers / blockedItem rows (') for entry in ledger['N2352']['deferred_exprs']))

    def test_all_c07_beam_drill_facing_tiles_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2352']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_facing_tiles_fill_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/BeamDrill.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('mindustry-upstream', 'core/src/mindustry/core/World.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Tile.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Geometry.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2352']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_facing_tiles_fill_state(self):
        beam_drill = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # The ordering pins below are TICK pins (the fill runs
        # in the tick before the scan reads facing_tiles) --
        # scope them to the tick function: N2477's drop loop
        # reads frame["facing_tiles"] in the update_tile
        # advance (earlier in the file), so a file-wide
        # .index() finds the advance's read, not the tick's
        # (serial N2483).
        tick = beam_drill[beam_drill.index('static func source_beam_drill_tick_buildings_state'):]
        # The facing-tile fill (BeamDrillBuild.
        # updateFacing(), BeamDrill.java:375-411 -- called
        # from onProximityUpdate :362-366 (`public void
        # onProximityUpdate(){` / `updateLasers();` /
        # `updateFacing();`) and from updateTile :244):
        # `int dx = Geometry.d4x(rotation), dy =
        # Geometry.d4y(rotation);` then for each laser
        # (`for(int p = 0; p < size; p++){`, `Point2 l =
        # lasers[p];`) walk range tiles along the
        # rotation (`for(int i = 0; i < range; i++){`,
        # `int rx = l.x + dx*i, ry = l.y + dy*i;`,
        # `Tile other = world.tile(rx, ry);`): a null
        # tile does NOT break the ray (`if(other !=
        # null){`), a non-solid tile does not break it
        # either (`if(other.solid()){`), and the FIRST
        # solid tile breaks it -- the fill emits the
        # FULL ray in the exact format the N2339 scan
        # reads (one Dict {solid, wall_drop} per tile,
        # null when the world has no tile there), and
        # the scan does the breaking. The direction
        # comes from Geometry.d4x/d4y (arc Geometry.java:
        # 23-24, `public final static int[] d4x = {1, 0,
        # -1, 0};` / `public final static int[] d4y =
        # {0, 1, 0, -1};`, indexed through `public
        # static int d4x(int i){` / `return d4x[Mathf.
        # mod(i, 4)];` and the d4y twins -- rotation is
        # normalized mod 4, so the pure uses posmod).
        # world.tile is `public Tile tile(int x, int
        # y){` (World.java:122); solid() is `public
        # boolean solid(){` (Tile.java:457) and the drop
        # is `public @Nullable Item wallDrop(){`
        # (Tile.java:575). Keep each Java expr on ONE
        # comment line (the N2148 shootWarmup lesson: a
        # split line fails this test).
        self.assertIn('static func source_beam_drill_facing_tiles_fill_state(lasers: Array, world_tiles: Dictionary, size: int, beam_range: int, rotation: int) -> Dictionary:', beam_drill)
        self.assertIn('protected void updateFacing(){', beam_drill)
        self.assertIn('int dx = Geometry.d4x(rotation), dy = Geometry.d4y(rotation);', beam_drill)
        self.assertIn('for(int p = 0; p < size; p++){', beam_drill)
        self.assertIn('Point2 l = lasers[p];', beam_drill)
        self.assertIn('for(int i = 0; i < range; i++){', beam_drill)
        self.assertIn('int rx = l.x + dx*i, ry = l.y + dy*i;', beam_drill)
        self.assertIn('Tile other = world.tile(rx, ry);', beam_drill)
        self.assertIn('if(other != null){', beam_drill)
        self.assertIn('if(other.solid()){', beam_drill)
        self.assertIn('Item drop = other.wallDrop();', beam_drill)
        self.assertIn('facing[p] = dest;', beam_drill)
        self.assertIn('public Point2[] lasers = new Point2[size];', beam_drill)
        self.assertIn('public Tile[] facing = new Tile[size];', beam_drill)
        self.assertIn('public void onProximityUpdate(){', beam_drill)
        self.assertIn('updateLasers();', beam_drill)
        self.assertIn('updateFacing();', beam_drill)
        self.assertIn('public final static int[] d4x = {1, 0, -1, 0};', beam_drill)
        self.assertIn('public final static int[] d4y = {0, 1, 0, -1};', beam_drill)
        self.assertIn('public static int d4x(int i){', beam_drill)
        self.assertIn('return d4x[Mathf.mod(i, 4)];', beam_drill)
        self.assertIn('public static int d4y(int i){', beam_drill)
        self.assertIn('return d4y[Mathf.mod(i, 4)];', beam_drill)
        self.assertIn('public boolean solid(){', beam_drill)
        self.assertIn('public @Nullable Item wallDrop(){', beam_drill)
        self.assertIn('public Tile tile(int x, int y){', beam_drill)
        self.assertIn('public int range = 5;', beam_drill)
        self.assertIn('public int tier = 1;', beam_drill)
        self.assertIn('public int size = 1;', beam_drill)
        self.assertIn('size = 2;', beam_drill)
        self.assertIn('size = 3;', beam_drill)
        self.assertIn('range = 5;', beam_drill)
        self.assertIn('range = 6;', beam_drill)
        # The pure returns exactly the one N2352 key,
        # one ray per laser in laser order, one entry
        # per tile in walk order (a Dict {solid,
        # wall_drop} or null); the direction arrays are
        # the Geometry d4x/d4y tables and the rotation
        # is normalized with posmod (Java's Mathf.mod).
        # A missing or short lasers array gives an empty
        # ray for the missing lasers, and rays past
        # `size` and tiles past `beam_range` are ignored
        # (Java reads exactly `size` lasers and `range`
        # tiles per laser) -- the N2339 precedent.
        self.assertIn('return {"facing_tiles": facing_tiles}', beam_drill)
        self.assertIn('var d4x: Array = [1, 0, -1, 0]', beam_drill)
        self.assertIn('var d4y: Array = [0, 1, 0, -1]', beam_drill)
        self.assertIn('posmod(rotation, 4)', beam_drill)
        self.assertIn('world_tiles.get(str(rx) + "," + str(ry), null)', beam_drill)
        # The tick stamps frame["facing_tiles"] from
        # frame["lasers"] (N2346 origins) + the frame
        # input world_tiles (default {} -- no world
        # data) each enabled tick BEFORE the facing
        # scan (Java order: updateFacing inside
        # updateTile, BeamDrill.java:244, before the
        # advance -- and AFTER the consumption fold, so
        # the shouldConsume gate reads the PREVIOUS
        # tick's facingAmount, BuildingComp.java:
        # 2274-2277), inside the same enabled gate as
        # the scan and the advance
        # (BuildingComp.java:2276-2277). The stamp runs
        # EVERY enabled tick (N2366: the is_empty gate
        # is gone -- it only preserved the N2339 proof,
        # which seeded facing_tiles directly, and the
        # N2339 proof seeds world_tiles now): a tick
        # with no world_tiles fills all-null rays (no
        # solid tiles anywhere, the Java no-facing-wall
        # outcome) and the scan stamps facing_amount 0.
        # size / range read from the catalog per def
        # (2/5 plasma-bore, 3/6 large-plasma-bore);
        # rotation from the sprite rotation meta
        # (SourceBlockGeometry.
        # SOURCE_BUILD_ROTATION_META_KEY, default 0, the
        # same meta the N2346 origins refresh reads).
        self.assertIn('frame.get("world_tiles", {})', beam_drill)
        self.assertNotIn('if not world_tiles.is_empty():', beam_drill)
        self.assertIn('var fill_rotation: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))', beam_drill)
        self.assertIn('source_beam_drill_facing_tiles_fill_state(frame.get("lasers", []), world_tiles, beam_size, beam_range, fill_rotation)', beam_drill)
        self.assertIn('frame["facing_tiles"] = filled.get("facing_tiles", [])', beam_drill)
        self.assertLess(
            tick.index('frame["facing_tiles"] = filled.get("facing_tiles", [])'),
            tick.index('var facing_tiles: Array = frame.get("facing_tiles", [])'),
        )
        self.assertLess(
            tick.index('source_beam_drill_facing_tiles_fill_state(frame.get("lasers", []), world_tiles, beam_size, beam_range, fill_rotation)'),
            tick.index('source_beam_drill_facing_scan_state(facing_tiles, beam_size, beam_range, beam_tier, beam_blocked_items)'),
        )
        # The N2339 facing scan pure and the N2346 laser
        # origins pure are untouched: their signatures,
        # their single-key returns and their tick stamps
        # are exactly as N2339 / N2346 left them (the
        # fill feeds the scan its rays; it does not
        # rewrite it).
        self.assertIn('static func source_beam_drill_facing_scan_state(facing_tiles: Array, size: int, beam_range: int, tier: int, blocked_items: Variant) -> Dictionary:', beam_drill)
        self.assertIn('return {"facing_amount": facing_amount}', beam_drill)
        self.assertIn('source_beam_drill_facing_scan_state(facing_tiles, beam_size, beam_range, beam_tier, beam_blocked_items)', beam_drill)
        self.assertIn('frame["facing_amount"] = scanned.get("facing_amount", 0)', beam_drill)
        self.assertIn('static func source_beam_drill_laser_origins_state(tile_x: int, tile_y: int, rotation: int, size: int) -> Dictionary:', beam_drill)
        self.assertIn('return {"lasers": lasers}', beam_drill)
        self.assertIn('frame["lasers"] = laser_origins.get("lasers", [])', beam_drill)
        # The documented limits now record the
        # facing-tile fill as live (N2352) and the
        # remaining deferral (the LIVE world-tile query,
        # lastItem / facing[] + the drop loop); the
        # N2195 advance, the N2202 gate, the N2256
        # liquid rows, the N2289 timer dump, the N2339
        # facing scan and the N2346 laser origins are
        # preserved.
        self.assertIn('facing-tile fill live since N2352', beam_drill)
        self.assertIn('LIVE world-tile query', beam_drill)
        self.assertIn('facing scan live (N2339)', beam_drill)
        self.assertIn('updateLasers geometry live since N2346', beam_drill)
        self.assertIn('(3) Partial updateTile', beam_drill)
        self.assertIn('advance (N2195)', beam_drill)
        self.assertIn('shouldConsume gate live (N2202)', beam_drill)
        self.assertIn('timerDump dump is live since N2289', beam_drill)
        self.assertIn('time grows unbounded', beam_drill)
        self.assertIn('static func source_beam_drill_power_status_row_state', beam_drill)
        self.assertIn('static func source_beam_drill_should_consume_state', beam_drill)
        self.assertIn('static func source_beam_drill_update_tile_advance_state', beam_drill)
        self.assertIn('static func source_beam_drill_timer_dump_state', beam_drill)
        # The pure N2195 advance is untouched: its return
        # dict keeps exactly the four N2195 keys and the
        # fill wires BEFORE the scan, never inside it.
        self.assertIn('return {"warmup": next_warmup, "boost_warmup": next_boost_warmup, "multiplier": multiplier, "time": next_time}', beam_drill)
        # The proof's keys drive the pure fill (rays
        # walked from the laser origins; rotation
        # changes the ray direction; missing / short
        # rays and the size / range bounds; null and
        # non-solid tiles pass through; the filled rays
        # feed the N2339 scan to the right count) plus
        # the live tick (a placed plasma-bore stamps
        # facing_tiles from seeded world_tiles in one
        # tick and facing_amount follows, a rotation
        # re-walks the rays, and clearing world_tiles
        # fills all-null rays with facing_amount 0 --
        # N2366, no is_empty gate).
        proof = BEAM_DRILL_FACING_TILES_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'walks_rays_from_laser_origins',
            'rotation_changes_ray_direction',
            'missing_short_rays_and_bounds',
            'null_and_nonsolid_tiles_pass_through',
            'fill_feeds_scan_count',
            'live_tick_stamps_facing_tiles',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceBeamDrillBuildState.gd")', proof)
        self.assertTrue(BEAM_DRILL_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('preload("res://src/game/SourceBlockGeometry.gd")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/src/game/SourceBlockGeometry.gd').is_file())
        self.assertIn('beam_drill_build_state.source_beam_drill_facing_tiles_fill_state(', proof)
        self.assertIn('beam_drill_build_state.source_beam_drill_facing_scan_state(', proof)
        self.assertIn('beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = BEAM_DRILL_FACING_TILES_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BeamDrillFacingTilesFillProof.gd', scene)
        self.assertIn('C07BeamDrillFacingTilesFillProof', scene)

    def test_reference_graph_and_actual_c07_beam_drill_facing_tiles_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillFacingTilesFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_FACING_TILES_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'walks_rays_from_laser_origins',
            'rotation_changes_ray_direction',
            'missing_short_rays_and_bounds',
            'null_and_nonsolid_tiles_pass_through',
            'fill_feeds_scan_count',
            'live_tick_stamps_facing_tiles',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
