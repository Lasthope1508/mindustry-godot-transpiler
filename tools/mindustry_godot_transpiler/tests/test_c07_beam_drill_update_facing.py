import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_UPDATE_FACING_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillUpdateFacingProof.gd'


class C07BeamDrillUpdateFacingTests(unittest.TestCase):
    def test_c07_beam_drill_update_facing_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2379']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_update_facing_state')
        # BeamDrillBuild.onProximityUpdate()
        # (BeamDrill.java:362-366):
        # `public void onProximityUpdate(){`
        # `//when rotated.`
        # `updateLasers();`
        # `updateFacing();`
        # `}`
        # BeamDrillBuild.updateLasers()
        # (BeamDrill.java:368-373):
        # `protected void updateLasers(){`
        # `for(int i = 0; i < size; i++){`
        # `if(lasers[i] == null) lasers[i] = new Point2();`
        # `nearbySide(tileX(), tileY(), rotation, i, lasers[i]);`
        # `}`
        # `}`
        # BeamDrillBuild.updateFacing()
        # (BeamDrill.java:375-412):
        # `protected void updateFacing(){`
        # `lastItem = null;`
        # `boolean multiple = false;`
        # `int dx = Geometry.d4x(rotation), dy = Geometry.d4y(rotation);`
        # `facingAmount = 0;`
        # `for(int p = 0; p < size; p++){`
        # `Point2 l = lasers[p];`
        # `Tile dest = null;`
        # `for(int i = 0; i < range; i++){`
        # `int rx = l.x + dx*i, ry = l.y + dy*i;`
        # `Tile other = world.tile(rx, ry);`
        # `if(other != null){`
        # `if(other.solid()){`
        # `Item drop = other.wallDrop();`
        # `if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){`
        # `facingAmount ++;`
        # `if(lastItem != drop && lastItem != null){`
        # `multiple = true;`
        # `}`
        # `lastItem = drop;`
        # `dest = other;`
        # `}`
        # `break;`
        # `}`
        # `}`
        # `}`
        # `facing[p] = dest;`
        # `}`
        # `if(multiple){`
        # `lastItem = null;`
        # `}`
        # `}`
        # on `public class BeamDrillBuild extends Building{`
        # (BeamDrill.java:220) inside
        # `public class BeamDrill extends Block{`. The three
        # methods are one facing record (the N2374 grouped /
        # N2330 merged-slice precedent): onProximityUpdate
        # only calls the two callees (2 exprs), so it stands
        # alone too thin; updateLasers + updateFacing are
        # one pure facing-tile logic pair over the same
        # frame fields `lasers` / `facing` / `lastItem` /
        # `facingAmount`. The shared names are callee /
        # context only, NOT distinguishing exprs:
        # `public void onProximityUpdate(){` EXACT-hits
        # N968/N2046/N2302 (other classes' proximity
        # updates); `if(other != null){` EXACT-hits 5
        # slices; `break;` EXACT-hits N1152/N2313;
        # `public int tier = 1;` EXACT-hits N2133/N2168;
        # `public @Nullable Seq<Item> blockedItems;`
        # EXACT-hits N2013/N2302/N2332; `public class
        # BeamDrill extends Block{` EXACT-hits N2155/N2378;
        # `public class BeamDrillBuild extends Building{`
        # EXACT-hits N2378; `@Override` EXACT-hits 100+
        # slices. The distinguishing exprs are the 34
        # EXACT 0-hit lines, re-probed at HEAD 4f53d70e
        # in both ledgers. `if(lasers[0] == null)
        # updateLasers();` is the updateTile call site
        # (BeamDrill.java:239-240, N2155's method) -- 0-hit
        # in both ledgers; updateTile N2155 does not own
        # it. Four new result symbols: lasers, facing,
        # last_item, facing_amount. The per-def tier /
        # range / size arrive as explicit params (the
        # N2212 / N2248 per-def-param precedent):
        # plasma-bore tier 3 / size 2 / range 5,
        # large-plasma-bore tier 5 / size 3 / range 6
        # (Blocks.java:3049-3065). NO driver tick line:
        # onProximityUpdate runs at placement / rotation,
        # not per tick (the N2302 precedent).
        self.assertEqual(
            ledger['N2379']['source_symbols'],
            [
                'source_beam_drill_update_facing_state_result.lasers',
                'source_beam_drill_update_facing_state_result.facing',
                'source_beam_drill_update_facing_state_result.last_item',
                'source_beam_drill_update_facing_state_result.facing_amount',
            ],
        )
        for name in ledger['N2379']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BeamDrill.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2379']['runtime_proof'], '/root/C07BeamDrillUpdateFacingProof')
        self.assertEqual(
            ledger['N2379']['tests'],
            [
                'test_c07_beam_drill_update_facing_registration',
                'test_all_c07_beam_drill_update_facing_input_evidence_is_exact',
                'test_beam_drill_update_facing_state',
                'test_reference_graph_and_actual_c07_beam_drill_update_facing',
            ],
        )
        self.assertTrue(ledger['N2379']['deferred_exprs'])

    def test_all_c07_beam_drill_update_facing_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2379']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BeamDrill.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2379']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_update_facing_state(self):
        state = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # BeamDrillBuild.onProximityUpdate() calls the two
        # facing helpers in order (BeamDrill.java:362-366,
        # `updateLasers();` / `updateFacing();`, "when
        # rotated"); updateLasers() fills every null laser
        # point then recomputes it with nearbySide
        # (BeamDrill.java:368-373, `lasers[i] = new Point2();`
        # / `nearbySide(tileX(), tileY(), rotation, i,
        # lasers[i]);` -- nearbySide itself is the N1762
        # callee, not re-ported here); updateFacing()
        # scans each laser's ray for the first solid tile
        # with a mineable wall drop (BeamDrill.java:375-412,
        # `int dx = Geometry.d4x(rotation), dy =
        # Geometry.d4y(rotation);` with d4x {1,0,-1,0} /
        # d4y {0,1,0,-1} from Geometry.java:23-24, 47-51,
        # `Tile other = world.tile(rx, ry);` arriving as
        # the explicit world_tile Callable, `Item drop =
        # other.wallDrop();` with the Tile.java:575 wallDrop
        # rule, `if(drop != null && drop.hardness <= tier
        # && (blockedItems == null ||
        # !blockedItems.contains(drop))){`, `facing[p] =
        # dest;`, and the multiple-items rule `if(multiple){`
        # / `lastItem = null;`). The world_tile Callable
        # returns null or a tile Dictionary {"solid",
        # "wall_drop", "wall_drop_hardness"}; facing[p]
        # stores that tile Dictionary (dest = other).
        # NO driver tick line: proximity update runs at
        # placement / rotation, not per tick.
        self.assertIn('static func source_beam_drill_on_proximity_update_state(frame: Dictionary, tile_x: int, tile_y: int, rotation: int, size: int, range_value: int, tier: int, blocked_items: Variant, world_tile: Callable) -> Dictionary:', state)
        self.assertIn('static func source_beam_drill_update_lasers_state(frame: Dictionary, tile_x: int, tile_y: int, rotation: int, size: int) -> Dictionary:', state)
        self.assertIn('static func source_beam_drill_update_facing_state(frame: Dictionary, rotation: int, size: int, range_value: int, tier: int, blocked_items: Variant, world_tile: Callable) -> Dictionary:', state)
        self.assertIn('return {"lasers": lasers_result.get("lasers", []), "facing": facing_result.get("facing", []), "last_item": facing_result.get("last_item", null), "facing_amount": facing_result.get("facing_amount", 0)}', state)
        self.assertIn('return {"lasers": lasers}', state)
        self.assertIn('return {"facing": facing, "last_item": last_item, "facing_amount": facing_amount}', state)
        for expr in [
            'updateLasers();',
            'updateFacing();',
            'lasers[i] = new Point2();',
            'nearbySide(tileX(), tileY(), rotation, i, lasers[i]);',
            'lastItem = null;',
            'boolean multiple = false;',
            'int dx = Geometry.d4x(rotation), dy = Geometry.d4y(rotation);',
            'facingAmount = 0;',
            'facing[p] = dest;',
            'if(multiple){',
            'int rx = l.x + dx*i, ry = l.y + dy*i;',
            'if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){',
            'facingAmount ++;',
            'if(lastItem != drop && lastItem != null){',
            'multiple = true;',
            'lastItem = drop;',
            'dest = other;',
            'if(lasers[0] == null) updateLasers();',
            'protected void updateLasers(){',
            'protected void updateFacing(){',
            'public Tile[] facing = new Tile[size];',
            'public Point2[] lasers = new Point2[size];',
            'public @Nullable Item lastItem;',
            'public int facingAmount;',
            'for(int i = 0; i < size; i++){',
            'if(lasers[i] == null)',
            'Point2 l = lasers[p];',
            'Tile dest = null;',
            'for(int p = 0; p < size; p++){',
            'for(int i = 0; i < range; i++){',
            'Tile other = world.tile(rx, ry);',
            'if(other.solid()){',
            'Item drop = other.wallDrop();',
            'public int range = 5;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the three pure functions
        # with synthetic frame + tile inputs (no live tick):
        # the proximity entry calls both helpers / lasers
        # fill nulls / rotation 0 and 1 nearbySide points /
        # the solid-drop count / the hard-drop and blocked
        # exclusions / the non-solid skip / the first-solid
        # stop / the multiple-items clear / the same-drop
        # keep / the null-tile safety / the four-key shape.
        proof = BEAM_DRILL_UPDATE_FACING_PROOF.read_text(encoding='utf-8')
        for key in [
            'on_proximity_update_calls_both',
            'update_lasers_fills_nulls',
            'update_lasers_rotation_zero',
            'update_lasers_rotation_one',
            'update_facing_counts_solid_drop',
            'update_facing_ignores_hard_drop',
            'update_facing_ignores_blocked_drop',
            'update_facing_skips_non_solid',
            'update_facing_stops_at_first_solid',
            'update_facing_multiple_clears_last_item',
            'update_facing_same_drop_keeps_last_item',
            'update_facing_null_tile_safe',
            'returns_only_four_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_beam_drill_update_facing(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillUpdateFacingProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_UPDATE_FACING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'on_proximity_update_calls_both',
            'update_lasers_fills_nulls',
            'update_lasers_rotation_zero',
            'update_lasers_rotation_one',
            'update_facing_counts_solid_drop',
            'update_facing_ignores_hard_drop',
            'update_facing_ignores_blocked_drop',
            'update_facing_skips_non_solid',
            'update_facing_stops_at_first_solid',
            'update_facing_multiple_clears_last_item',
            'update_facing_same_drop_keeps_last_item',
            'update_facing_null_tile_safe',
            'returns_only_four_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
