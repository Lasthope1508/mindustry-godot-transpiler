import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIGHT_BLOCK_STATE = ROOT / 'godot-mindustry/src/game/SourceLightBlockBuildState.gd'
LIGHT_BLOCK_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LightBlockUpdateTileProof.gd'


class C07LightBlockUpdateTileTests(unittest.TestCase):
    def test_c07_light_block_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2189']['godot_owner'], 'SourceLightBlockBuildState.source_light_block_smooth_time_state')
        # N2185 proved the illuminator's live power.status read,
        # but the port still never advanced smoothTime:
        # LightBuild.updateTile() does exactly one thing
        # (LightBlock.java:104-107, `smoothTime =
        # Mathf.lerpDelta(smoothTime, timeScale, 0.1f);`), and
        # drawLight scales the emitted light by `lightRadius *
        # Math.min(smoothTime, 2f)` (LightBlock.java:127-128) --
        # so without this slice the light radius never follows
        # timeScale. N2189 is the advance: a pure lerpDelta step
        # over the frame's smooth_time toward the building's
        # live timeScale, driven every tick by the light-block
        # driver. timeScale is the BuildingComp field
        # (BuildingComp.java:98, `private transient float
        # timeScale = 1f, timeScaleDuration;`, read through
        # timeScale(), BuildingComp.java:599-601); the port
        # already tracks it per sprite
        # (SourcePlacedBlockState SOURCE_BLOCK_TIME_SCALE_META_KEY,
        # default 1.0), so the driver reads the live meta --
        # no new time-scale infrastructure is needed.
        # lerpDelta is Arc's delta-corrected lerp
        # (Mathf.java:430-432, `return lerp(fromValue, toValue,
        # clamp(progress * Time.delta));` with lerp
        # `fromValue + (toValue - fromValue) * progress` and
        # clamp to [0, 1]); Time.delta is the frame delta in
        # 60fps ticks (Time.java:26, `Math.min(Core.graphics.
        # getDeltaTime() * 60f, 3f)`), so the driver converts
        # its seconds argument with seconds * 60 (the N2093
        # pump / conveyor precedent). The updateTile gate
        # (BuildingComp.java:2276, `if(enabled ||
        # !block.noUpdateDisabled){`) always runs for a
        # LightBlock -- noUpdateDisabled defaults false
        # (Block.java:170) -- so the driver advances
        # unconditionally. Two new result symbols: the advanced
        # smooth_time and its drawLight radius clamp.
        self.assertEqual(
            ledger['N2189']['source_symbols'],
            [
                'source_light_block_smooth_time_state_result.smooth_time',
                'source_light_block_smooth_time_state_result.light_radius_scale',
            ],
        )
        for name in ledger['N2189']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/power/LightBlock.java')
                self.assertEqual(symbol['godot_owner'], 'SourceLightBlockBuildState.source_light_block_smooth_time_state')
        self.assertEqual(ledger['N2189']['runtime_proof'], '/root/C07LightBlockUpdateTileProof')
        self.assertEqual(
            ledger['N2189']['tests'],
            [
                'test_c07_light_block_update_tile_registration',
                'test_all_c07_light_block_update_tile_input_evidence_is_exact',
                'test_light_block_update_tile_state',
                'test_reference_graph_and_actual_c07_light_block_update_tile',
            ],
        )
        self.assertTrue(ledger['N2189']['deferred_exprs'])

    def test_all_c07_light_block_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2189']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceLightBlockBuildState.source_light_block_smooth_time_state')
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/power/LightBlock.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'arc-core/src/arc/math/Mathf.java',
            'arc-core/src/arc/util/Time.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2189']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_light_block_update_tile_state(self):
        light_block = LIGHT_BLOCK_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the light-block build state:
        # updateTile (LightBlock.java:104-107) only lerps
        # smoothTime toward timeScale (LightBlock.java:105,
        # `smoothTime = Mathf.lerpDelta(smoothTime, timeScale,
        # 0.1f);`) with the Arc delta-corrected lerp
        # (Mathf.java:430-432, `return lerp(fromValue,
        # toValue, clamp(progress * Time.delta));`), lerp
        # (Mathf.java:425-427, `return fromValue + (toValue -
        # fromValue) * progress;`) and clamp to [0, 1]
        # (Mathf.java:402-404, `return Math.max(Math.min(value,
        # 1f), 0f);`). Time.delta is the frame delta in 60fps
        # ticks (Time.java:26, `private static Floatp
        # deltaimpl = () -> Math.min(Core.graphics.
        # getDeltaTime() * 60f, 3f);`), so the driver converts
        # seconds * 60 at the live-loop boundary (the N2093
        # pump / conveyor precedent). timeScale is the
        # BuildingComp field (BuildingComp.java:98, `private
        # transient float timeScale = 1f, timeScaleDuration;`),
        # read through timeScale() (BuildingComp.java:599-601,
        # `public float timeScale(){` / `return timeScale;`),
        # decaying back to 1f when its duration runs out
        # (BuildingComp.java:2265-2266, `if((timeScaleDuration
        # -= Time.delta) <= 0f){` / `timeScale = 1f;`), and it
        # also scales delta() (BuildingComp.java:1922-1923,
        # `return Time.delta * timeScale;`). The updateTile
        # gate (BuildingComp.java:2276, `if(enabled ||
        # !block.noUpdateDisabled){`) always runs for a
        # LightBlock because noUpdateDisabled defaults false
        # (Block.java:170, `public boolean noUpdateDisabled =
        # false;`), so the driver advances unconditionally.
        # smoothTime starts at 1f (LightBlock.java:69, `public
        # float smoothTime = 1f;`), and drawLight clamps it
        # (LightBlock.java:127-128, `Drawf.light(x, y,
        # lightRadius * Math.min(smoothTime, 2f), Tmp.c1.set
        # (color), brightness * efficiency);`) -- the pure
        # advance returns both the advanced smooth_time and
        # the light_radius_scale min(smooth_time, 2f).
        self.assertIn('smoothTime = Mathf.lerpDelta(smoothTime, timeScale, 0.1f);', light_block)
        self.assertIn('return lerp(fromValue, toValue, clamp(progress * Time.delta));', light_block)
        self.assertIn('return fromValue + (toValue - fromValue) * progress;', light_block)
        self.assertIn('return Math.max(Math.min(value, 1f), 0f);', light_block)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', light_block)
        self.assertIn('public float timeScale(){', light_block)
        self.assertIn('return timeScale;', light_block)
        self.assertIn('if((timeScaleDuration -= Time.delta) <= 0f){', light_block)
        self.assertIn('timeScale = 1f;', light_block)
        self.assertIn('private static Floatp deltaimpl = () -> Math.min(Core.graphics.getDeltaTime() * 60f, 3f);', light_block)
        self.assertIn('return Time.delta * timeScale;', light_block)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', light_block)
        self.assertIn('public boolean noUpdateDisabled = false;', light_block)
        self.assertIn('public float smoothTime = 1f;', light_block)
        self.assertIn('Drawf.light(x, y, lightRadius * Math.min(smoothTime, 2f), Tmp.c1.set(color), brightness * efficiency);', light_block)
        # The pure advance + the driver wiring: the frame binds
        # smooth_time at its Java initial value, the driver
        # reads the live sprite time_scale and converts its
        # seconds argument to Time.delta ticks.
        self.assertIn('static func source_light_block_smooth_time_state(smooth_time: float, time_scale: float, source_delta: float) -> Dictionary:', light_block)
        self.assertIn('source_lerp_delta(smooth_time, time_scale, 0.1, source_delta)', light_block)
        self.assertIn('"smooth_time": 1.0', light_block)
        self.assertIn('source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))', light_block)
        self.assertIn('seconds * source_time_defaults.TICK_RATE', light_block)
        self.assertIn('frame["smooth_time"]', light_block)
        self.assertIn('minf(', light_block)
        # The power.status row from N2185 is untouched: the
        # pure row still reads the stamped frame value.
        self.assertIn('return build.power.status;', light_block)
        self.assertIn('static func source_light_block_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:', light_block)
        # The proof's keys drive the pure advance (one lerpDelta
        # step, convergence after many ticks, hold at timeScale,
        # the min(smoothTime, 2f) radius clamp) plus the live
        # tick advance and the unchanged power.status row.
        # There are no drawLight / color / config keys: drawLight
        # presentation (LightBlock.java:127-128) and the color
        # config (LightBlock.java:35, 72-94, 109-127) wait for
        # their own slices; the radius clamp is what the
        # light_radius_scale key proves.
        proof = LIGHT_BLOCK_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'smooth_time_lerp_delta_step',
            'smooth_time_converges_after_ticks',
            'smooth_time_holds_at_time_scale',
            'light_radius_clamps_at_two',
            'smooth_time_tick_advances_live',
            'power_status_row_unchanged',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_light_block_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LightBlockUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIGHT_BLOCK_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'smooth_time_lerp_delta_step',
            'smooth_time_converges_after_ticks',
            'smooth_time_holds_at_time_scale',
            'light_radius_clamps_at_two',
            'smooth_time_tick_advances_live',
            'power_status_row_unchanged',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
