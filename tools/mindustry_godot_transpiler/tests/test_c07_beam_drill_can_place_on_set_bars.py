import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_CAN_PLACE_ON_SET_BARS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillCanPlaceOnSetBarsProof.gd'


class C07BeamDrillCanPlaceOnSetBarsTests(unittest.TestCase):
    def test_c07_beam_drill_can_place_on_set_bars_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2391']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_can_place_on_state')
        # BeamDrill.canPlaceOn() (BeamDrill.java:198-214, `public
        # boolean canPlaceOn(Tile tile, Team team, int rotation){`)
        # is the BeamDrill placement predicate: one scan ray per
        # footprint side (nearbySide + world.tile), true on the
        # first mineable wall drop (hardness <= tier, not
        # blocked), false otherwise; the first solid tile stops
        # its ray whether or not its drop is mineable.
        # BeamDrill.setBars() (BeamDrill.java:90-97, `public void
        # setBars(){`) adds the drillspeed bar: key "drillspeed",
        # text Core.bundle.format("bar.drillspeed",
        # Strings.fixed(lastDrillSpeed * 60, 2)), color Pal.ammo,
        # fraction warmup. Two pure functions on the existing
        # SourceBeamDrillBuildState.gd (the N2330 Drill
        # canPlaceOn+setBars precedent, the N2385 drawPlace scan
        # precedent): they return the computed state and do NOT
        # touch real world / Bar / UI playback. NO driver tick
        # line: canPlaceOn is a placement predicate, setBars is
        # a load-time bar spec. The 5 distinguishing exprs are
        # the 0-hit lines re-probed at base 3b90de35 in both
        # ledgers (3 canPlaceOn + 2 setBars). The HIT lines
        # (`if(other != null && other.solid()){` N2385,
        # `for(int i = 0; i < size; i++){` / `Item drop =
        # other.wallDrop();` / the hardness check N2379,
        # `super.setBars();`, `return true;` / `return false;`)
        # are evidence only, NOT distinguishing. Five new result
        # symbols: can_place_on, bar_key, bar_text, bar_color,
        # bar_fraction.
        self.assertEqual(
            ledger['N2391']['source_symbols'],
            [
                'source_beam_drill_can_place_on_state_result.can_place_on',
                'source_beam_drill_set_bars_state_result.bar_key',
                'source_beam_drill_set_bars_state_result.bar_text',
                'source_beam_drill_set_bars_state_result.bar_color',
                'source_beam_drill_set_bars_state_result.bar_fraction',
            ],
        )
        for name in ledger['N2391']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BeamDrill.java',
                    'core/src/mindustry/graphics/Pal.java',
                    'core/src/mindustry/ui/Bar.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2391']['runtime_proof'], '/root/C07BeamDrillCanPlaceOnSetBarsProof')
        self.assertEqual(
            ledger['N2391']['tests'],
            [
                'test_c07_beam_drill_can_place_on_set_bars_registration',
                'test_all_c07_beam_drill_can_place_on_set_bars_input_evidence_is_exact',
                'test_beam_drill_can_place_on_set_bars_state',
                'test_reference_graph_and_actual_c07_beam_drill_can_place_on_set_bars',
            ],
        )
        self.assertTrue(ledger['N2391']['deferred_exprs'])

    def test_all_c07_beam_drill_can_place_on_set_bars_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2391']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BeamDrill.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/graphics/Pal.java',
            'core/src/mindustry/ui/Bar.java',
            'arc-core/src/arc/util/Strings.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2391']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_can_place_on_set_bars_state(self):
        state = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # BeamDrill.canPlaceOn() (BeamDrill.java:198-214)
        # returns the placement predicate: true on the first
        # mineable wall drop found on any side ray, false when
        # no side finds one. A null or non-solid tile does NOT
        # stop a ray; the first solid tile stops it whether or
        # not its drop is mineable (the break sits inside
        # `if(other.solid()){`). BeamDrill.setBars()
        # (BeamDrill.java:90-97) returns the drillspeed bar
        # spec (key, text, color, fraction) and does NOT touch
        # real Bar/UI playback. NO driver tick line.
        self.assertIn('static func source_beam_drill_can_place_on_state(frame: Dictionary, tile_x: int, tile_y: int, rotation: int, size: int, range_value: int, tier: int, blocked_items: Variant, world_tile: Callable) -> Dictionary:', state)
        self.assertIn('static func source_beam_drill_set_bars_state(frame: Dictionary, super_set_bars: Variant, last_drill_speed: float, warmup: float) -> Dictionary:', state)
        self.assertIn('return {"can_place_on": can_place_on}', state)
        self.assertIn('return {"bar_key": "drillspeed", "bar_text": bar_text, "bar_color": bar_color, "bar_fraction": warmup}', state)
        for expr in [
            'nearbySide(tile.x, tile.y, rotation, i, Tmp.p1);',
            'for(int j = 0; j < range; j++){',
            'Tile other = world.tile(Tmp.p1.x + Geometry.d4x(rotation)*j, Tmp.p1.y + Geometry.d4y(rotation)*j);',
            'addBar("drillspeed", (BeamDrillBuild e) ->',
            'new Bar(() -> Core.bundle.format("bar.drillspeed", Strings.fixed(e.lastDrillSpeed * 60, 2)), () -> Pal.ammo, () -> e.warmup));',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure functions with
        # synthetic worlds (no live tick): mineable drop on the
        # first side / empty world / too-hard drop only /
        # blocked drop / non-solid tile does not stop the ray /
        # deeper drop two steps out / rotation changes the ray
        # / bar text format / bar text truncation / Pal.ammo
        # color / warmup fraction / the result-key shapes.
        proof = BEAM_DRILL_CAN_PLACE_ON_SET_BARS_PROOF.read_text(encoding='utf-8')
        for key in [
            'mineable_first_side_true',
            'no_mineable_false',
            'too_hard_false',
            'blocked_false',
            'non_solid_does_not_stop_ray',
            'scan_steps_to_deeper_drop',
            'rotation_changes_ray',
            'bar_text_format',
            'bar_text_truncates',
            'bar_color_ammo',
            'bar_fraction_warmup',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_beam_drill_can_place_on_set_bars(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillCanPlaceOnSetBarsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_CAN_PLACE_ON_SET_BARS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'mineable_first_side_true',
            'no_mineable_false',
            'too_hard_false',
            'blocked_false',
            'non_solid_does_not_stop_ray',
            'scan_steps_to_deeper_drop',
            'rotation_changes_ray',
            'bar_text_format',
            'bar_text_truncates',
            'bar_color_ammo',
            'bar_fraction_warmup',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
