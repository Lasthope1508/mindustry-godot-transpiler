import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_FACING_SCAN_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillFacingScanProof.gd'
BEAM_DRILL_FACING_SCAN_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillFacingScanProof.tscn'


class C07BeamDrillFacingScanTests(unittest.TestCase):
    def test_c07_beam_drill_facing_scan_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2339']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_facing_scan_state')
        # N2202 gave the beam drill its shouldConsume gate
        # (`return items.total() < itemCapacity &&
        # facingAmount > 0 && enabled;`, BeamDrill.java:271)
        # -- but facingAmount itself was RED-deferred all
        # along: the tick preserved frame["facing_amount"]
        # at the Java default 0, so a live beam drill never
        # consumed unless a proof seeded the count. N2339
        # is the scan: updateFacing() (BeamDrill.java:
        # 375-411 -- the driver and the DEFERRED entry both
        # cited :375-410 / :368-411, both wrong: updateLasers
        # is :368-373 and updateFacing is :375-411, the
        # closing brace at :411) resets facingAmount to 0
        # and, for each of the size facing lasers, walks
        # range tiles along the rotation from the laser
        # origin, takes the FIRST solid tile, and counts it
        # when its wallDrop passes the mineable check
        # (`drop != null && drop.hardness <= tier &&
        # (blockedItems == null || !blockedItems.contains(
        # drop))`, BeamDrill.java:391) -- the first solid
        # tile BREAKS the ray even when its drop is
        # unmineable, and a null tile (out of the world)
        # does not break it. The port has no live world,
        # so the pure takes the facing rays as frame inputs
        # (the N2301 WallCrafter getEfficiency precedent):
        # one Array per laser in laser order, one Dict per
        # tile in walk order {solid, wall_drop} carrying
        # the `other != null && other.solid()` answer and
        # the wallDrop item {id, hardness} (null when the
        # tile drops nothing); size / range / tier read
        # from the catalog per def (2/5/3 plasma-bore,
        # 3/6/5 large-plasma-bore), blockedItems through
        # the shared Drill bind (neither def sets one).
        # One new result symbol: the facing count.
        self.assertEqual(
            ledger['N2339']['source_symbols'],
            [
                'source_beam_drill_facing_scan_state_result.facing_amount',
            ],
        )
        for name in ledger['N2339']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/BeamDrill.java')
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_facing_scan_state')
        self.assertEqual(ledger['N2339']['runtime_proof'], '/root/C07BeamDrillFacingScanProof')
        self.assertEqual(
            ledger['N2339']['tests'],
            [
                'test_c07_beam_drill_facing_scan_registration',
                'test_all_c07_beam_drill_facing_scan_input_evidence_is_exact',
                'test_beam_drill_facing_scan_state',
                'test_reference_graph_and_actual_c07_beam_drill_facing_scan',
            ],
        )
        self.assertTrue(ledger['N2339']['deferred_exprs'])
        # This slice REWRITES the facing / laser binding
        # entry (27) in place: the updateFacing COUNT is
        # live since N2339, but the updateLasers geometry
        # and the LIVE facing-tile fill still wait (no live
        # world query exists, so a live beam drill with no
        # supplied facing_tiles reads an empty proximity
        # and facing_amount stays 0), and lastItem /
        # facing[] wait for the drop-loop slice (entry
        # 190). The old entry text (the whole binding
        # deferred on tile/wall proximity state) is gone;
        # the drop loop + drillMultipliers entries stay.
        self.assertTrue(any(entry.startswith('BeamDrill facing / laser binding (') and 'live since N2339' in entry for entry in ledger['N2339']['deferred_exprs']))
        self.assertFalse(any('needs tile/wall proximity state the tick does not track yet' in entry for entry in ledger['N2339']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill drop loop + time reset + lastDrillSpeed (') for entry in ledger['N2339']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill drillMultipliers / blockedItem rows (') for entry in ledger['N2339']['deferred_exprs']))

    def test_all_c07_beam_drill_facing_scan_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2339']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_facing_scan_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/BeamDrill.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2339']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_facing_scan_state(self):
        beam_drill = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # The updateFacing count (BeamDrillBuild.
        # updateFacing(), BeamDrill.java:375-411 -- the
        # range is :375-411, NOT :375-410 (the driver
        # cite, off by one: the closing brace is :411)
        # and NOT :368-411 (the DEFERRED cite: :368-373
        # is updateLasers): `lastItem = null;` /
        # `boolean multiple = false;` / `facingAmount =
        # 0;`, then for each of the size lasers
        # (`for(int p = 0; p < size; p++){`, `Point2 l =
        # lasers[p];`) walk range tiles along the
        # rotation (`for(int i = 0; i < range; i++){`,
        # `int rx = l.x + dx*i, ry = l.y + dy*i;`, `Tile
        # other = world.tile(rx, ry);`): a null tile
        # does NOT break the ray, a non-solid tile does
        # not break it either, and the FIRST solid tile
        # breaks it whether or not its drop is mineable
        # (`if(other.solid()){` / `Item drop = other.
        # wallDrop();` / the :391 mineable check /
        # `break;`). A mineable drop increments
        # (`facingAmount ++;`), tracks lastItem
        # (`if(lastItem != drop && lastItem != null){` /
        # `multiple = true;` / `lastItem = drop;`) and
        # records the tile (`dest = other;` /
        # `facing[p] = dest;`); multiple distinct drops
        # clear lastItem (`if(multiple){` / `lastItem =
        # null;`). updateLasers (`protected void
        # updateLasers(){`, `nearbySide(tileX(), tileY(),
        # rotation, i, lasers[i]);`) computes the laser
        # origins the port does NOT model -- the caller
        # supplies the rays. Keep each Java expr on ONE
        # comment line (the N2148 shootWarmup lesson: a
        # split line fails this test).
        self.assertIn('static func source_beam_drill_facing_scan_state', beam_drill)
        self.assertIn('protected void updateFacing(){', beam_drill)
        self.assertIn('lastItem = null;', beam_drill)
        self.assertIn('boolean multiple = false;', beam_drill)
        self.assertIn('int dx = Geometry.d4x(rotation), dy = Geometry.d4y(rotation);', beam_drill)
        self.assertIn('facingAmount = 0;', beam_drill)
        self.assertIn('for(int p = 0; p < size; p++){', beam_drill)
        self.assertIn('Point2 l = lasers[p];', beam_drill)
        self.assertIn('Tile dest = null;', beam_drill)
        self.assertIn('for(int i = 0; i < range; i++){', beam_drill)
        self.assertIn('int rx = l.x + dx*i, ry = l.y + dy*i;', beam_drill)
        self.assertIn('Tile other = world.tile(rx, ry);', beam_drill)
        self.assertIn('if(other != null){', beam_drill)
        self.assertIn('if(other.solid()){', beam_drill)
        self.assertIn('Item drop = other.wallDrop();', beam_drill)
        self.assertIn('if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){', beam_drill)
        self.assertIn('facingAmount ++;', beam_drill)
        self.assertIn('if(lastItem != drop && lastItem != null){', beam_drill)
        self.assertIn('multiple = true;', beam_drill)
        self.assertIn('lastItem = drop;', beam_drill)
        self.assertIn('dest = other;', beam_drill)
        self.assertIn('break;', beam_drill)
        self.assertIn('facing[p] = dest;', beam_drill)
        self.assertIn('if(multiple){', beam_drill)
        self.assertIn('updateFacing();', beam_drill)
        self.assertIn('protected void updateLasers(){', beam_drill)
        self.assertIn('nearbySide(tileX(), tileY(), rotation, i, lasers[i]);', beam_drill)
        self.assertIn('public Tile[] facing = new Tile[size];', beam_drill)
        self.assertIn('public Point2[] lasers = new Point2[size];', beam_drill)
        self.assertIn('public @Nullable Item lastItem;', beam_drill)
        self.assertIn('public int facingAmount;', beam_drill)
        self.assertIn('public int range = 5;', beam_drill)
        self.assertIn('public int tier = 1;', beam_drill)
        self.assertIn('if(blockedItems == null && blockedItem != null){', beam_drill)
        self.assertIn('blockedItems = Seq.with(blockedItem);', beam_drill)
        self.assertIn('return items.total() < itemCapacity && facingAmount > 0 && enabled;', beam_drill)
        self.assertIn('tier = 3;', beam_drill)
        self.assertIn('tier = 5;', beam_drill)
        self.assertIn('size = 2;', beam_drill)
        self.assertIn('size = 3;', beam_drill)
        self.assertIn('range = 5;', beam_drill)
        self.assertIn('range = 6;', beam_drill)
        self.assertIn('public int size = 1;', beam_drill)
        # The pure returns exactly the one N2339 key, and
        # the range is NOT a parameter named `range`
        # (GDScript's range() builtin -- the parameter is
        # beam_range, the BeamDrill.java:35 `range` field).
        self.assertIn('static func source_beam_drill_facing_scan_state(facing_tiles: Array, size: int, beam_range: int, tier: int, blocked_items: Variant) -> Dictionary:', beam_drill)
        self.assertIn('return {"facing_amount": facing_amount}', beam_drill)
        # The tick wires the scan BEFORE the advance (Java
        # order: updateFacing is called inside updateTile,
        # BeamDrill.java:244, between the warmup approach
        # :242 and the multiplier :246 -- and AFTER the
        # consumption fold, so the shouldConsume gate
        # reads the PREVIOUS tick's facingAmount, the
        # Java order BuildingComp.java:2274-2277), inside
        # the same enabled gate as the advance
        # (BuildingComp.java:2276-2277). The facing rays
        # are frame inputs (default [] -- no tiles, the
        # Java no-facing-wall outcome) until a live tile
        # fill lands; size / range / tier read from the
        # catalog per def (2/5/3 plasma-bore, 3/6/5
        # large-plasma-bore; the class defaults are
        # size 1 Block.java:215, range 5 / tier 1
        # BeamDrill.java:35-36); blockedItems resolve
        # through the shared Drill bind (SourceDrill
        # RuntimeState.source_bind_ore_items_state,
        # guarded -- neither BeamDrill def carries the
        # keys in the catalog, so the bind is skipped and
        # the scan runs unblocked), loaded with load()
        # instead of preload() -- a preload would cycle
        # (the BurstDrill precedent: Factory preloads
        # this file and DrillRuntime preloads Factory).
        # The scan stamps facing_amount onto the frame;
        # the advance reads nothing from it and is
        # unchanged.
        self.assertIn('frame.get("facing_tiles", [])', beam_drill)
        self.assertIn('block.properties.get("size", 1)', beam_drill)
        self.assertIn('block.properties.get("range", 5)', beam_drill)
        self.assertIn('block.properties.get("tier", 1)', beam_drill)
        self.assertIn('load("res://src/game/SourceDrillRuntimeState.gd")', beam_drill)
        self.assertNotIn('preload("res://src/game/SourceDrillRuntimeState.gd")', beam_drill)
        self.assertIn('drill_runtime_state.source_bind_ore_items_state(block, item_catalog)', beam_drill)
        self.assertIn('source_beam_drill_facing_scan_state(facing_tiles, beam_size, beam_range, beam_tier, beam_blocked_items)', beam_drill)
        self.assertIn('frame["facing_amount"] = scanned.get("facing_amount", 0)', beam_drill)
        self.assertLess(
            beam_drill.index('source_beam_drill_facing_scan_state(facing_tiles, beam_size, beam_range, beam_tier, beam_blocked_items)'),
            beam_drill.index('source_beam_drill_update_tile_advance_state(frame, source_delta, time_scale)'),
        )
        # The documented limits now record the facing scan
        # as live (the corrected :375-411 range) and the
        # remaining deferrals (updateLasers geometry, the
        # live facing-tile fill, lastItem / facing[] +
        # the drop loop); the N2195 advance, the N2202
        # gate, the N2256 liquid rows and the N2289 timer
        # dump are preserved.
        self.assertIn('facing scan live (N2339)', beam_drill)
        self.assertIn('BeamDrill.java:375-411', beam_drill)
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
        # scan wires BEFORE its call, never inside it.
        self.assertIn('return {"warmup": next_warmup, "boost_warmup": next_boost_warmup, "multiplier": multiplier, "time": next_time}', beam_drill)
        # The proof's keys drive the pure scan (counts
        # mineable facing tiles with the tier boundary;
        # the first solid tile breaks the ray; blocked
        # items are excluded; missing tiles and the size
        # / range bounds; the large-plasma-bore's three
        # lasers) plus the live tick (a placed
        # plasma-bore stamps facing_amount in one tick
        # and the gate opens on the NEXT tick -- Java
        # order, the gate reads the previous tick's
        # facingAmount).
        proof = BEAM_DRILL_FACING_SCAN_PROOF.read_text(encoding='utf-8')
        for key in [
            'counts_mineable_facing_tiles',
            'first_solid_tile_breaks_ray',
            'blocked_items_excluded',
            'missing_tiles_and_bounds',
            'large_bore_three_lasers',
            'live_tick_stamps_facing_amount',
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
        self.assertIn('beam_drill_build_state.source_beam_drill_facing_scan_state(', proof)
        self.assertIn('beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = BEAM_DRILL_FACING_SCAN_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BeamDrillFacingScanProof.gd', scene)
        self.assertIn('C07BeamDrillFacingScanProof', scene)

    def test_reference_graph_and_actual_c07_beam_drill_facing_scan(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillFacingScanProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_FACING_SCAN_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'counts_mineable_facing_tiles',
            'first_solid_tile_breaks_ray',
            'blocked_items_excluded',
            'missing_tiles_and_bounds',
            'large_bore_three_lasers',
            'live_tick_stamps_facing_amount',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
