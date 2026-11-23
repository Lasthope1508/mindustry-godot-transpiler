import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DRILL_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceDrillRuntimePortBridge.gd'
UPDATE_TILE_EFFECTS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DrillUpdateTileEffectsProof.gd'


class C07DrillUpdateTileEffectsTests(unittest.TestCase):
    def test_c07_drill_update_tile_effects_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2420']['godot_owner'], 'PortGame.source_drill_update_tile_effects_state')
        # DrillBuild.updateTile() (Drill.java:287-327,
        # `public void updateTile(){`) -- this slice is ONLY
        # the 3 effect lines: `if(Mathf.chanceDelta(
        # updateEffectChance * warmup))` (:307),
        # `updateEffect.at(x + Mathf.range(size * 2f), y +
        # Mathf.range(size * 2f));` (:308), and
        # `if(wasVisible && Mathf.chanceDelta(
        # drillEffectChance * warmup)) drillEffect.at(x +
        # Mathf.range(drillEffectRnd), y + Mathf.range(
        # drillEffectRnd), dominantItem.color);` (:323).
        # NOT this slice: the items/efficiency gate
        # `if(items.total() < itemCapacity &&
        # dominantItems > 0 && efficiency > 0){` (N693),
        # `progress %= delay` (N696), `offload(
        # dominantItem)` (N2022), `float delay =
        # getDrillTime(dominantItem);` (N693/N2022),
        # `warmup = Mathf.approachDelta(...)` (N692/N703).
        # The 3 distinguishing exprs are 0-hit in both the
        # local and the remote ledger (re-probed at base
        # 9cd7239f, remote origin/main eafdfdb4). One pure
        # function on SourceDrillRuntimePortBridge.gd (the
        # Drill file, non-static func -- the PortGame-era
        # style of this file). The owner is PortGame.* (the
        # N691/N692/N693/N696/N697/N701/N703 precedent for
        # the other updateTile legs in this file). RNG
        # arrives as explicit params: the chanceDelta rolls
        # as floats in [0, 1) compared against chance *
        # warmup * source_delta here (Mathf.chanceDelta is
        # `rand.nextFloat() < d * Time.delta`,
        # Mathf.java:236-238), and the Mathf.range calls as
        # float rolls mapped to (2 * roll - 1) * amount
        # (Mathf.range is random(-range, range),
        # Mathf.java:220-222, random(start, end) is start +
        # roll * (end - start), Mathf.java:285-287).
        # updateEffect.at / drillEffect.at arrive as
        # explicit Callables, NOT re-ported. `size`,
        # `x`, `y`, `wasVisible`, `drillEffectRnd` and
        # `dominantItem.color` arrive as explicit params.
        # Nine new result symbols: update_effect,
        # update_effect_x, update_effect_y,
        # update_effect_called, drill_effect,
        # drill_effect_x, drill_effect_y,
        # drill_effect_color, drill_effect_called.
        self.assertEqual(
            ledger['N2420']['java_method'],
            'DrillBuild.updateTile()',
        )
        self.assertEqual(
            ledger['N2420']['source_symbols'],
            [
                'source_drill_update_tile_effects_state_result.update_effect',
                'source_drill_update_tile_effects_state_result.update_effect_x',
                'source_drill_update_tile_effects_state_result.update_effect_y',
                'source_drill_update_tile_effects_state_result.update_effect_called',
                'source_drill_update_tile_effects_state_result.drill_effect',
                'source_drill_update_tile_effects_state_result.drill_effect_x',
                'source_drill_update_tile_effects_state_result.drill_effect_y',
                'source_drill_update_tile_effects_state_result.drill_effect_color',
                'source_drill_update_tile_effects_state_result.drill_effect_called',
            ],
        )
        for name in ledger['N2420']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'arc-core/src/arc/math/Mathf.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.source_drill_update_tile_effects_state')
        self.assertEqual(ledger['N2420']['runtime_proof'], '/root/C07DrillUpdateTileEffectsProof')
        self.assertEqual(
            ledger['N2420']['tests'],
            [
                'test_c07_drill_update_tile_effects_registration',
                'test_all_c07_drill_update_tile_effects_input_evidence_is_exact',
                'test_drill_update_tile_effects_state',
                'test_reference_graph_and_actual_c07_drill_update_tile_effects',
            ],
        )
        self.assertTrue(ledger['N2420']['deferred_exprs'])

    def test_all_c07_drill_update_tile_effects_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2420']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.source_drill_update_tile_effects_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Drill.java',
            'arc-core/src/arc/math/Mathf.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2420']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_drill_update_tile_effects_state(self):
        defaults = DRILL_BRIDGE.read_text(encoding='utf-8')
        # DrillBuild.updateTile() effect legs
        # (Drill.java:307-308, :323): the update effect
        # fires when the chanceDelta roll falls below
        # updateEffectChance * warmup * delta and spawns
        # at x/y offset by Mathf.range(size * 2f); the
        # drill effect fires only when wasVisible and its
        # own chanceDelta roll falls below
        # drillEffectChance * warmup * delta, spawning at
        # x/y offset by Mathf.range(drillEffectRnd) with
        # the dominant item color. Chance rolls and range
        # rolls arrive as explicit float params (the N2315
        # chance-roll precedent); the .at calls arrive as
        # explicit Callables. No driver tick line: this IS
        # the effect-leg state function itself, driven by
        # the proof with synthetic frames (no live tick).
        self.assertIn('func source_drill_update_tile_effects_state(update_effect_chance: float, warmup: float, update_effect_roll: float, source_delta: float, size: float, x: float, y: float, was_visible: bool, drill_effect_chance: float, drill_effect_roll: float, drill_effect_rnd: float, dominant_item_color: Variant, update_effect_range_roll_x: float, update_effect_range_roll_y: float, drill_effect_range_roll_x: float, drill_effect_range_roll_y: float, update_effect_at: Callable, drill_effect_at: Callable) -> Dictionary:', defaults)
        self.assertIn('return {"update_effect": update_effect, "update_effect_x": update_effect_x, "update_effect_y": update_effect_y, "update_effect_called": update_effect_called, "drill_effect": drill_effect, "drill_effect_x": drill_effect_x, "drill_effect_y": drill_effect_y, "drill_effect_color": dominant_item_color, "drill_effect_called": drill_effect_called}', defaults)
        for expr in [
            'if(Mathf.chanceDelta(updateEffectChance * warmup))',
            'updateEffect.at(x + Mathf.range(size * 2f), y + Mathf.range(size * 2f));',
            'if(wasVisible && Mathf.chanceDelta(drillEffectChance * warmup)) drillEffect.at(x + Mathf.range(drillEffectRnd), y + Mathf.range(drillEffectRnd), dominantItem.color);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, defaults)
        # The proof's keys drive the pure function with
        # synthetic frames (no live tick): the update
        # effect fires when its roll is below the
        # chance*warmup*delta threshold and stays silent
        # above it / its offsets scale with size /
        # warmup zero silences it / the threshold scales
        # with source_delta / the drill effect fires only
        # when wasVisible and its roll is below threshold
        # / its offsets scale with drillEffectRnd / it
        # carries the dominant item color / the result-key
        # shapes.
        proof = UPDATE_TILE_EFFECTS_PROOF.read_text(encoding='utf-8')
        for key in [
            'update_effect_fires_when_roll_below_threshold',
            'update_effect_silent_when_roll_above_threshold',
            'update_effect_offset_uses_size',
            'update_effect_silent_when_warmup_zero',
            'update_effect_threshold_scales_with_source_delta',
            'drill_effect_fires_when_visible_and_roll_below_threshold',
            'drill_effect_silent_when_not_visible',
            'drill_effect_silent_when_roll_above_threshold',
            'drill_effect_offset_uses_drill_effect_rnd',
            'drill_effect_carries_dominant_item_color',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_drill_update_tile_effects(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DrillUpdateTileEffectsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DRILL_UPDATE_TILE_EFFECTS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'update_effect_fires_when_roll_below_threshold',
            'update_effect_silent_when_roll_above_threshold',
            'update_effect_offset_uses_size',
            'update_effect_silent_when_warmup_zero',
            'update_effect_threshold_scales_with_source_delta',
            'drill_effect_fires_when_visible_and_roll_below_threshold',
            'drill_effect_silent_when_not_visible',
            'drill_effect_silent_when_roll_above_threshold',
            'drill_effect_offset_uses_drill_effect_rnd',
            'drill_effect_carries_dominant_item_color',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
