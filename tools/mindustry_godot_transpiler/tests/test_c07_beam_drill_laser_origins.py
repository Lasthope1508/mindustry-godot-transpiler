import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_LASER_ORIGINS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillLaserOriginsProof.gd'
BEAM_DRILL_LASER_ORIGINS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillLaserOriginsProof.tscn'


class C07BeamDrillLaserOriginsTests(unittest.TestCase):
    def test_c07_beam_drill_laser_origins_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2346']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_laser_origins_state')
        # N2339 gave the beam drill its updateFacing COUNT
        # (source_beam_drill_facing_scan_state over the
        # frame facing_tiles) but left the laser ORIGINS
        # unmodeled: updateLasers() (BeamDrill.java:368-373)
        # computes one origin per laser through nearbySide
        # (Block.java:936-944), and the port had no
        # nearbySide at all -- the scan pure took its rays
        # as frame inputs instead. N2346 is the geometry:
        # updateLasers runs in onProximityUpdate
        # (BeamDrill.java:362-366, `public void
        # onProximityUpdate(){` / `updateLasers();` /
        # `updateFacing();`, when the drill is placed or
        # rotated) plus a lazy first-tick call from
        # updateTile (`if(lasers[0] == null)
        # updateLasers();`, BeamDrill.java:240), so the
        # pure computes the origins from the tile position
        # + rotation + size and the tick stamps them onto
        # frame["lasers"] only when tile_changes moves
        # (the N2277 pattern), with a first-tick refresh
        # covering the lazy :240 call. One new result
        # symbol: the origins array.
        self.assertEqual(
            ledger['N2346']['source_symbols'],
            [
                'source_beam_drill_laser_origins_state_result.lasers',
            ],
        )
        for name in ledger['N2346']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/BeamDrill.java')
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_laser_origins_state')
        self.assertEqual(ledger['N2346']['runtime_proof'], '/root/C07BeamDrillLaserOriginsProof')
        self.assertEqual(
            ledger['N2346']['tests'],
            [
                'test_c07_beam_drill_laser_origins_registration',
                'test_all_c07_beam_drill_laser_origins_input_evidence_is_exact',
                'test_beam_drill_laser_origins_state',
                'test_reference_graph_and_actual_c07_beam_drill_laser_origins',
            ],
        )
        self.assertTrue(ledger['N2346']['deferred_exprs'])
        # This slice REWRITES the facing / laser binding
        # entry (329) in place: the updateLasers GEOMETRY
        # is live since N2346, but the LIVE facing-tile
        # fill still waits (no live world query exists, so
        # a live beam drill with no supplied facing_tiles
        # reads an empty proximity and facing_amount stays
        # 0), and lastItem / facing[] wait for the
        # drop-loop slice (entry 187 in the advances-15
        # merged list -- the old text cited entry 190,
        # stale from the advances-14 numbering). The
        # facing count (live since N2339) is preserved in
        # the rewritten text, and the drop loop + drill
        # multipliers entries stay.
        self.assertTrue(any(entry.startswith('BeamDrill facing / laser binding (') and 'live since N2346' in entry and 'live since N2339' in entry for entry in ledger['N2346']['deferred_exprs']))
        self.assertFalse(any('still waiting: the updateLasers geometry' in entry for entry in ledger['N2346']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill facing / laser binding (') and 'LIVE facing-tile fill' in entry for entry in ledger['N2346']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill drop loop + time reset + lastDrillSpeed (') for entry in ledger['N2346']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill drillMultipliers / blockedItem rows (') for entry in ledger['N2346']['deferred_exprs']))

    def test_all_c07_beam_drill_laser_origins_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2346']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_laser_origins_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/BeamDrill.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/core/World.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/defense/RegenProjector.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Point2.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2346']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_laser_origins_state(self):
        beam_drill = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # The updateLasers origins (BeamDrillBuild.
        # updateLasers(), BeamDrill.java:368-373 -- called
        # from onProximityUpdate :362-366 when the drill is
        # placed or rotated, NOT every tick, plus the lazy
        # first-tick call `if(lasers[0] == null)
        # updateLasers();` (BeamDrill.java:240)): one origin
        # per laser through nearbySide (Block.java:936-944
        # -- the range is :936-944, NOT :936-947 (the brief
        # cite: :946-948 is getEdges)): corner = tile -
        # (size-1)/2 with JAVA integer division, then the
        # rotation switch: 0 -> (cornerX + s, cornerY +
        # index); 1 -> (cornerX + index, cornerY + s); 2 ->
        # (cornerX - 1, cornerY + index); 3 -> (cornerX +
        # index, cornerY - 1). The switch has NO default in
        # Java: an out-of-range rotation leaves `out`
        # unchanged, and updateLasers creates a fresh `new
        # Point2()` (x = 0, y = 0, the arc Point2 field
        # defaults) when the slot is null, so a fresh laser
        # under an unmatched rotation reads (0, 0) -- the
        # pure seeds each origin at (0, 0) and only the four
        # rotation cases move it. The lasers are what
        # updateFacing walks from (`Point2 l = lasers[p];`,
        # BeamDrill.java:383). Keep each Java expr on ONE
        # comment line (the N2148 shootWarmup lesson: a
        # split line fails this test).
        self.assertIn('static func source_beam_drill_laser_origins_state(tile_x: int, tile_y: int, rotation: int, size: int) -> Dictionary:', beam_drill)
        self.assertIn('protected void updateLasers(){', beam_drill)
        self.assertIn('for(int i = 0; i < size; i++){', beam_drill)
        self.assertIn('if(lasers[i] == null) lasers[i] = new Point2();', beam_drill)
        self.assertIn('nearbySide(tileX(), tileY(), rotation, i, lasers[i]);', beam_drill)
        self.assertIn('public void onProximityUpdate(){', beam_drill)
        self.assertIn('updateLasers();', beam_drill)
        self.assertIn('if(lasers[0] == null) updateLasers();', beam_drill)
        self.assertIn('public Point2[] lasers = new Point2[size];', beam_drill)
        self.assertIn('Point2 l = lasers[p];', beam_drill)
        self.assertIn('int rx = l.x + dx*i, ry = l.y + dy*i;', beam_drill)
        self.assertIn('public void nearbySide(int x, int y, int rotation, int index, Point2 out){', beam_drill)
        self.assertIn('int cornerX = x - (size-1)/2, cornerY = y - (size-1)/2, s = size;', beam_drill)
        self.assertIn('switch(rotation){', beam_drill)
        self.assertIn('case 0 -> out.set(cornerX + s, cornerY + index);', beam_drill)
        self.assertIn('case 1 -> out.set(cornerX + index, cornerY + s);', beam_drill)
        self.assertIn('case 2 -> out.set(cornerX - 1, cornerY + index);', beam_drill)
        self.assertIn('case 3 -> out.set(cornerX + index, cornerY - 1);', beam_drill)
        self.assertIn('public int size = 1;', beam_drill)
        self.assertIn('public int tileX(){', beam_drill)
        self.assertIn('return tile.x;', beam_drill)
        self.assertIn('public int tileY(){', beam_drill)
        self.assertIn('return tile.y;', beam_drill)
        self.assertIn('transient int rotation;', beam_drill)
        self.assertIn('public int tileChanges = 1, floorChanges = 1;', beam_drill)
        self.assertIn('public int lastChange = -2;', beam_drill)
        self.assertIn('if(lastChange != world.tileChanges){', beam_drill)
        self.assertIn('lastChange = world.tileChanges;', beam_drill)
        self.assertIn('public Point2(){', beam_drill)
        # The pure returns exactly the one N2346 key, one
        # origin per laser in laser order, each {x, y} in
        # tile coordinates; the nearbySide geometry is
        # driver-local inside the pure (no other caller in
        # the port), NOT in the shared SourceBlockGeometry.
        self.assertIn('return {"lasers": lasers}', beam_drill)
        self.assertIn('var corner_x: int = tile_x - (size - 1) / 2', beam_drill)
        self.assertIn('var corner_y: int = tile_y - (size - 1) / 2', beam_drill)
        # The tick stamps frame["lasers"] only when
        # tile_changes moves (the N2277 pattern: the
        # frame input tile_changes, default 1, World.java:
        # 35, against lasers_last_change, default -2, the
        # N2277 sentinel, so the first tick always
        # refreshes -- covering the lazy :240 call -- and
        # a rotation/placement bump refreshes again), plus
        # the direct :240 analog (an empty lasers array
        # refreshes even without a tile_changes move). The
        # refresh is NOT gated on enabled (onProximityUpdate
        # fires on placement / rotation regardless of
        # enabled) and runs BEFORE the consumption fold and
        # the facing scan (Java order: updateLasers :364
        # before updateFacing :365 in onProximityUpdate).
        # tileX/tileY come from the sprite origin_cell (the
        # building tile), rotation from the sprite rotation
        # meta (SourceBlockGeometry.
        # SOURCE_BUILD_ROTATION_META_KEY, default 0), size
        # from the catalog per def (2 plasma-bore / 3
        # large-plasma-bore). The initial frame carries the
        # empty origins + the -2 sentinel (the N2277
        # RegenProjector _initial_frame precedent: targets
        # [] + last_change -2).
        self.assertIn('frame.get("tile_changes", 1)', beam_drill)
        self.assertIn('frame.get("lasers_last_change", -2)', beam_drill)
        self.assertIn('frame.get("lasers", [])', beam_drill)
        self.assertIn('var laser_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)', beam_drill)
        self.assertIn('sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0)', beam_drill)
        self.assertIn('source_beam_drill_laser_origins_state(laser_cell.x, laser_cell.y, laser_rotation, laser_size)', beam_drill)
        self.assertIn('frame["lasers"] = laser_origins.get("lasers", [])', beam_drill)
        self.assertIn('frame["lasers_last_change"] = int(frame.get("tile_changes", 1))', beam_drill)
        self.assertIn('"lasers": []', beam_drill)
        self.assertIn('"lasers_last_change": -2', beam_drill)
        self.assertLess(
            beam_drill.index('source_beam_drill_laser_origins_state(laser_cell.x, laser_cell.y, laser_rotation, laser_size)'),
            beam_drill.index('source_beam_drill_should_consume_state(frame, int(block.properties.get("itemCapacity", 10)))'),
        )
        self.assertLess(
            beam_drill.index('source_beam_drill_laser_origins_state(laser_cell.x, laser_cell.y, laser_rotation, laser_size)'),
            beam_drill.index('source_beam_drill_facing_scan_state(facing_tiles, beam_size, beam_range, beam_tier, beam_blocked_items)'),
        )
        # The N2339 facing scan pure is untouched: its
        # signature, its single-key return and its tick
        # stamp are exactly as N2339 left them (the scan
        # still takes its rays as frame inputs; the live
        # facing-tile fill that would read frame["lasers"]
        # waits for its own slice).
        self.assertIn('static func source_beam_drill_facing_scan_state(facing_tiles: Array, size: int, beam_range: int, tier: int, blocked_items: Variant) -> Dictionary:', beam_drill)
        self.assertIn('return {"facing_amount": facing_amount}', beam_drill)
        self.assertIn('source_beam_drill_facing_scan_state(facing_tiles, beam_size, beam_range, beam_tier, beam_blocked_items)', beam_drill)
        self.assertIn('frame["facing_amount"] = scanned.get("facing_amount", 0)', beam_drill)
        # The documented limits now record the updateLasers
        # geometry as live (N2346) and the remaining
        # deferrals (the live facing-tile fill, lastItem /
        # facing[] + the drop loop); the N2195 advance, the
        # N2202 gate, the N2256 liquid rows, the N2289 timer
        # dump and the N2339 facing scan are preserved.
        self.assertIn('updateLasers geometry live since N2346', beam_drill)
        self.assertIn('facing scan live (N2339)', beam_drill)
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
        # dict keeps exactly the four N2195 keys.
        self.assertIn('return {"warmup": next_warmup, "boost_warmup": next_boost_warmup, "multiplier": multiplier, "time": next_time}', beam_drill)
        # The proof's keys drive the pure origins (rotation
        # 0 for both defs + size 1; all four rotations; the
        # corner formula across even/odd sizes; one origin
        # per laser; the unmatched-rotation fresh-Point2
        # default) plus the live tick (a placed plasma-bore
        # stamps its origins on tick 1, re-stamps them when
        # the rotation changes with a tile_changes bump, and
        # keeps them when the rotation changes WITHOUT a
        # tile_changes bump -- the gate holds).
        proof = BEAM_DRILL_LASER_ORIGINS_PROOF.read_text(encoding='utf-8')
        for key in [
            'rotation_zero_origins',
            'all_rotations_origins',
            'corner_formula_even_odd_sizes',
            'laser_count_matches_size',
            'invalid_rotation_keeps_fresh_origin',
            'live_tick_stamps_laser_origins',
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
        self.assertIn('beam_drill_build_state.source_beam_drill_laser_origins_state(', proof)
        self.assertIn('beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = BEAM_DRILL_LASER_ORIGINS_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BeamDrillLaserOriginsProof.gd', scene)
        self.assertIn('C07BeamDrillLaserOriginsProof', scene)

    def test_reference_graph_and_actual_c07_beam_drill_laser_origins(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillLaserOriginsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_LASER_ORIGINS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'rotation_zero_origins',
            'all_rotations_origins',
            'corner_formula_even_odd_sizes',
            'laser_count_matches_size',
            'invalid_rotation_keeps_fresh_origin',
            'live_tick_stamps_laser_origins',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
