import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RADAR_STATE = ROOT / 'godot-mindustry/src/game/SourceRadarBuildState.gd'
RADAR_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarUpdateTileProof.gd'
RADAR_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarUpdateTileProof.tscn'


class C07RadarUpdateTileTests(unittest.TestCase):
    def test_c07_radar_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2190']['godot_owner'], 'SourceRadarBuildState.source_radar_update_tile_state')
        # N2173 gave the radar its live power.status read -- a pure
        # power row over the stamped frame value, folded by the
        # shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but the radar's updateTile
        # advance (Radar.java:60-72) still waited: smoothEfficiency
        # never lerped toward the folded efficiency, progress never
        # advanced by edelta() / discoveryTime, totalProgress never
        # accumulated, and lastRadius never tracked the fog radius
        # -- so a radar never discovered, however long it ran. N2190
        # is the advance: a pure updateTile step over the frame
        # state (smooth_efficiency / progress / total_progress /
        # last_radius), wired into the N2173 driver every tick, in
        # Java order -- the smooth-efficiency lerp FIRST
        # (Radar.java:61, `smoothEfficiency =
        # Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);`),
        # then the fog-radius change check against the NEW smooth
        # efficiency and the CURRENT progress (Radar.java:63-66),
        # then the progress advance + clamp (Radar.java:68-69,
        # `progress += edelta() / discoveryTime;` /
        # `progress = Mathf.clamp(progress);`), then the
        # total-progress advance (Radar.java:71, `totalProgress +=
        # efficiency * edelta();`). The fogControl.forceUpdate call
        # (Radar.java:64, `Vars.fogControl.forceUpdate(team,
        # this);`) is a side-effect into the fog system, which has
        # no port-side control yet -- the advance tracks the
        # condition (|fogRadius() - lastRadius| >= 0.5f) and the
        # lastRadius write, and the call itself waits for its own
        # fog slice. Two new result symbols: the advance dict and
        # its force-update flag.
        self.assertEqual(
            ledger['N2190']['source_symbols'],
            [
                'source_radar_update_tile_result.advance',
                'source_radar_update_tile_result.force_update_needed',
            ],
        )
        for name in ledger['N2190']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/Radar.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_radar_update_tile_result.advance': 'SourceRadarBuildState.source_radar_update_tile_state',
                    'source_radar_update_tile_result.force_update_needed': 'SourceRadarBuildState.source_radar_update_tile_state',
                }[name])
        self.assertEqual(ledger['N2190']['runtime_proof'], '/root/C07RadarUpdateTileProof')
        self.assertEqual(
            ledger['N2190']['tests'],
            [
                'test_c07_radar_update_tile_registration',
                'test_all_c07_radar_update_tile_input_evidence_is_exact',
                'test_radar_update_tile_state',
                'test_reference_graph_and_actual_c07_radar_update_tile',
            ],
        )
        self.assertTrue(ledger['N2190']['deferred_exprs'])

    def test_all_c07_radar_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2190']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_radar_update_tile_result.advance': 'SourceRadarBuildState.source_radar_update_tile_state',
                    'source_radar_update_tile_result.force_update_needed': 'SourceRadarBuildState.source_radar_update_tile_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/Radar.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'arc-core/src/arc/math/Mathf.java',
            'arc-core/src/arc/util/Time.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2190']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_radar_update_tile_state(self):
        radar = RADAR_STATE.read_text(encoding='utf-8')
        # The pure updateTile advance lives on the radar build
        # state: smoothEfficiency lerps toward the folded
        # efficiency (Radar.java:61, `smoothEfficiency =
        # Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);`,
        # keep on ONE comment line, the N2148 shootWarmup lesson:
        # a split line fails this test), with lerpDelta's exact
        # formula (arc Mathf.java:430-432, `return lerp(fromValue,
        # toValue, clamp(progress * Time.delta));`) through the
        # shared SourceMathState.source_lerp_delta helper; the
        # fog-radius change check (Radar.java:63, `if(Math.abs(
        # fogRadius() - lastRadius) >= 0.5f){`) runs against the
        # NEW smooth efficiency and the CURRENT progress
        # (fogRadius() is `return fogRadius * progress *
        # smoothEfficiency;`, Radar.java:56), tracking lastRadius
        # (`lastRadius = fogRadius();`, Radar.java:65) while the
        # forceUpdate call (`Vars.fogControl.forceUpdate(team,
        # this);`, Radar.java:64) waits for its own fog slice;
        # progress advances by edelta() / discoveryTime
        # (Radar.java:68, `progress += edelta() / discoveryTime;`)
        # and clamps to [0, 1] (Radar.java:69, `progress =
        # Mathf.clamp(progress);`, arc Mathf.java:402-404, `return
        # Math.max(Math.min(value, 1f), 0f);`); totalProgress
        # accumulates efficiency * edelta() (Radar.java:71,
        # `totalProgress += efficiency * edelta();`). edelta is
        # efficiency * delta (BuildingComp.java:1927-1929, `return
        # efficiency * delta();`), delta is Time.delta * timeScale
        # (BuildingComp.java:1922-1924, `return Time.delta *
        # timeScale;`) with timeScale 1f by default
        # (BuildingComp.java:98, `private transient float
        # timeScale = 1f, timeScaleDuration;`), and Time.delta is
        # the frame delta scaled to 60fps ticks (arc Time.java:26,
        # `private static Floatp deltaimpl = () -> Math.min(
        # Core.graphics.getDeltaTime() * 60f, 3f);`), so the driver
        # passes seconds * TICK_RATE (the N2093 pump precedent).
        # Build fields (Radar.java:49-52): `public float
        # progress;`, `public float lastRadius = 0f;`, `public
        # float smoothEfficiency = 1f;`, `public float
        # totalProgress;`. Class field (Radar.java:18): `public
        # float discoveryTime = 60f * 10f;`. Def (Blocks.java:1991):
        # `fogRadius = 34;`. The radar is its own family
        # (Radar.java:17, `public class Radar extends Block{`;
        # RadarBuild, Radar.java:48, `public class RadarBuild
        # extends Building{`). One def (radar, `consumePower(0.6f);`,
        # Blocks.java:1994). The N2173 power row is preserved: the
        # live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency, and the advance follows that
        # folded efficiency.
        self.assertIn('static func source_radar_update_tile_state', radar)
        self.assertIn('source_radar_update_tile_state(', radar)
        self.assertIn('smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);', radar)
        self.assertIn('return lerp(fromValue, toValue, clamp(progress * Time.delta));', radar)
        self.assertIn('source_math_state.source_lerp_delta', radar)
        self.assertIn('if(Math.abs(fogRadius() - lastRadius) >= 0.5f){', radar)
        self.assertIn('Vars.fogControl.forceUpdate(team, this);', radar)
        self.assertIn('lastRadius = fogRadius();', radar)
        self.assertIn('return fogRadius * progress * smoothEfficiency;', radar)
        self.assertIn('progress += edelta() / discoveryTime;', radar)
        self.assertIn('progress = Mathf.clamp(progress);', radar)
        self.assertIn('return Math.max(Math.min(value, 1f), 0f);', radar)
        self.assertIn('totalProgress += efficiency * edelta();', radar)
        self.assertIn('return efficiency * delta();', radar)
        self.assertIn('return Time.delta * timeScale;', radar)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', radar)
        self.assertIn('private static Floatp deltaimpl = () -> Math.min(Core.graphics.getDeltaTime() * 60f, 3f);', radar)
        self.assertIn('public float progress;', radar)
        self.assertIn('public float lastRadius = 0f;', radar)
        self.assertIn('public float smoothEfficiency = 1f;', radar)
        self.assertIn('public float totalProgress;', radar)
        self.assertIn('public float discoveryTime = 60f * 10f;', radar)
        self.assertIn('public class RadarBuild extends Building{', radar)
        self.assertIn('fogRadius = 34;', radar)
        self.assertIn('consumePower(0.6f);', radar)
        self.assertIn('return build.power.status;', radar)
        self.assertIn('source_time_defaults.TICK_RATE', radar)
        self.assertIn('SOURCE_RADAR_FOG_RADIUS', radar)
        self.assertIn('SOURCE_RADAR_DISCOVERY_TIME', radar)
        self.assertIn('"smooth_efficiency"', radar)
        self.assertIn('"total_progress"', radar)
        self.assertIn('"last_radius"', radar)
        self.assertIn('"force_update_needed"', radar)
        self.assertIn('static func source_radar_power_status_row_state', radar)
        self.assertIn('static func source_radar_tick_buildings_state', radar)
        # The proof's keys drive the pure advance (lerp / progress
        # advance / clamp / total-progress / last-radius) plus the
        # live tick (advance + preserved power row). The proof
        # carries no forceUpdate-call key: the fogControl call
        # (Radar.java:64) waits for its own fog slice -- the
        # last-radius key proves the condition + the lastRadius
        # write, not the call. Static checks: the proof preloads
        # the family state file that exists, and the scene file
        # references the proof script that exists.
        proof = RADAR_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'smooth_efficiency_lerps_to_efficiency',
            'progress_advances_edelta_over_discovery',
            'progress_clamps_at_one',
            'total_progress_accumulates',
            'last_radius_updates_on_fog_change',
            'live_tick_advances_and_keeps_power_row',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceRadarBuildState.gd")', proof)
        self.assertTrue(RADAR_STATE.is_file())
        scene = RADAR_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RadarUpdateTileProof.gd', scene)
        self.assertTrue(RADAR_UPDATE_TILE_PROOF.is_file())

    def test_reference_graph_and_actual_c07_radar_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RadarUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RADAR_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'smooth_efficiency_lerps_to_efficiency',
            'progress_advances_edelta_over_discovery',
            'progress_clamps_at_one',
            'total_progress_accumulates',
            'last_radius_updates_on_fog_change',
            'live_tick_advances_and_keeps_power_row',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
