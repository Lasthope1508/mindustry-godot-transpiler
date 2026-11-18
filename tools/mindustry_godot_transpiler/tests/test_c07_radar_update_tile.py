import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RADAR_STATE = ROOT / 'godot-mindustry/src/game/SourceRadarBuildState.gd'
RADAR_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarUpdateTileProof.gd'


class C07RadarUpdateTileTests(unittest.TestCase):
    def test_c07_radar_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2248']['godot_owner'], 'SourceRadarBuildState.source_radar_update_tile_state')
        # RadarBuild.updateTile advances the radar's discovery
        # state every tick (Radar.java:60, `public void
        # updateTile(){`): `smoothEfficiency =
        # Mathf.lerpDelta(smoothEfficiency, efficiency,
        # 0.05f);` (Radar.java:61) lerps the smoothed
        # efficiency toward the folded efficiency;
        # `if(Math.abs(fogRadius() - lastRadius) >= 0.5f){`
        # (Radar.java:63) with `Vars.fogControl.forceUpdate
        # (team, this);` (Radar.java:64) and `lastRadius =
        # fogRadius();` (Radar.java:65) forces a fog update
        # when the live fog radius moved by half a tile or
        # more; `progress += edelta() / discoveryTime;`
        # (Radar.java:68) with `progress =
        # Mathf.clamp(progress);` (Radar.java:69) advances
        # discovery by edelta() over the discovery time,
        # clamped to [0, 1]; `totalProgress += efficiency *
        # edelta();` (Radar.java:71) tracks the
        # efficiency-weighted tick count. edelta() is
        # efficiency * delta (BuildingComp.java:1927-1929,
        # `public float edelta(){` with `return efficiency *
        # delta();`, and delta() is `Time.delta * timeScale`,
        # BuildingComp.java:1922-1923). The fog radius read
        # is fogRadius() (Radar.java:55, `public float
        # fogRadius(){` with `return fogRadius * progress *
        # smoothEfficiency;`, Radar.java:56): the def
        # fogRadius is 34 (Blocks.java:1991, `fogRadius =
        # 34;`), overriding the class default 10
        # (Radar.java:33, `fogRadius = 10;`). The discovery
        # time is 600f (Radar.java:18, `public float
        # discoveryTime = 60f * 10f;`). N2248 closes the
        # advance half of that gap with one pure function
        # over the frame (`smooth_efficiency`, `progress`,
        # `last_radius`, `total_progress`, `efficiency`)
        # plus the per-def discovery_time and fog_radius
        # parameters, following the N2207 LaunchPad
        # updateTile precedent exactly: the pure function
        # takes (frame, delta, discovery_time, fog_radius)
        # and returns the new smooth_efficiency, fog_radius,
        # force_update flag, last_radius, progress and
        # total_progress, and the driver stamps all six on
        # the frame every tick. The actual FogControl call
        # (`public void forceUpdate(Team team, Building
        # build){`, FogControl.java:177) waits for its own
        # fog slice; the `force_update` flag is the
        # observable signal that slice will consume. RED
        # decisions (pinned by this slice): (1) the frame
        # carries `smooth_efficiency` (absent -> 1.0, the
        # Java field init), `progress` (absent -> 0.0),
        # `last_radius` (absent -> 0.0), `total_progress`
        # (absent -> 0.0) and `efficiency` (absent -> 0.0,
        # the transient field default, the N2192/N2204
        # precedent). (2) The fog-radius check uses the NEW
        # smoothed efficiency and the OLD progress (Java
        # order: the lerp :61 runs before the check :63-66,
        # the progress advance :68 runs after). (3) The
        # driver tick line runs for every ticked radar
        # AFTER the consumption block, with efficiency
        # zeroed first when disabled (`if(!enabled){` with
        # `potentialEfficiency = efficiency =
        # optionalEfficiency = 0f;`,
        # BuildingComp.java:1954-1955), so a disabled radar
        # never advances (the N2204 precedent). (4)
        # discovery_time and fog_radius are explicit per-def
        # params (the N2212 per-def-param precedent); the
        # driver passes the radar-def values 600.0 and 34.0.
        # Six new result symbols: smooth_efficiency,
        # fog_radius, force_update, last_radius, progress,
        # total_progress.
        self.assertEqual(
            ledger['N2248']['source_symbols'],
            [
                'source_radar_update_tile_state_result.smooth_efficiency',
                'source_radar_update_tile_state_result.fog_radius',
                'source_radar_update_tile_state_result.force_update',
                'source_radar_update_tile_state_result.last_radius',
                'source_radar_update_tile_state_result.progress',
                'source_radar_update_tile_state_result.total_progress',
            ],
        )
        for name in ledger['N2248']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/Radar.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/game/FogControl.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2248']['runtime_proof'], '/root/C07RadarUpdateTileProof')
        self.assertEqual(
            ledger['N2248']['tests'],
            [
                'test_c07_radar_update_tile_registration',
                'test_all_c07_radar_update_tile_input_evidence_is_exact',
                'test_radar_update_tile_state',
                'test_reference_graph_and_actual_c07_radar_update_tile',
            ],
        )
        self.assertTrue(ledger['N2248']['deferred_exprs'])

    def test_all_c07_radar_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2248']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/Radar.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/game/FogControl.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2248']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_radar_update_tile_state(self):
        radar = RADAR_STATE.read_text(encoding='utf-8')
        # The pure updateTile advance lives on the radar
        # build state next to the N2173 power row:
        # RadarBuild.updateTile (Radar.java:60, `public void
        # updateTile(){`) lerps the smoothed efficiency
        # (Radar.java:61, `smoothEfficiency =
        # Mathf.lerpDelta(smoothEfficiency, efficiency,
        # 0.05f);`), force-updates the fog when the live
        # radius moved by 0.5 or more (Radar.java:63,
        # `if(Math.abs(fogRadius() - lastRadius) >= 0.5f){`
        # with `Vars.fogControl.forceUpdate(team, this);`,
        # Radar.java:64, and `lastRadius = fogRadius();`,
        # Radar.java:65), advances discovery
        # (Radar.java:68, `progress += edelta() /
        # discoveryTime;` with `progress =
        # Mathf.clamp(progress);`, Radar.java:69) and
        # tracks the efficiency-weighted ticks
        # (Radar.java:71, `totalProgress += efficiency *
        # edelta();`). edelta() is efficiency * delta
        # (BuildingComp.java:1927-1928, `public float
        # edelta(){` with `return efficiency * delta();`,
        # and `public float delta(){` with `return
        # Time.delta * timeScale;`, BuildingComp.java:1922-
        # 1923 -- timeScale is 1 by default and the port
        # passes the raw tick seconds, the N2190 driver
        # convention). The folded efficiency is the
        # transient field (BuildingComp.java:85, `transient
        # float efficiency;`), default 0.0 before the first
        # machinery run; a disabled radar never advances
        # because updateConsumption zeroes the efficiencies
        # first (`if(!enabled){` with
        # `potentialEfficiency = efficiency =
        # optionalEfficiency = 0f;`,
        # BuildingComp.java:1954-1955), so the driver
        # zeroes efficiency before the call (the N2204
        # precedent). The frame carries `smooth_efficiency`
        # (float, absent defaults to 1.0 -- the Java field
        # init, Radar.java:51, `public float
        # smoothEfficiency = 1f;`), `progress` (float,
        # absent defaults to 0.0 -- `public float
        # progress;`, Radar.java:49), `last_radius` (float,
        # absent defaults to 0.0 -- `public float
        # lastRadius = 0f;`, Radar.java:50),
        # `total_progress` (float, absent defaults to 0.0
        # -- `public float totalProgress;`, Radar.java:52)
        # and `efficiency` (float, absent defaults to 0.0
        # -- the transient field default, the N2192/N2204
        # precedent). The fog radius read is fogRadius()
        # (Radar.java:55, `public float fogRadius(){` with
        # `return fogRadius * progress * smoothEfficiency;`,
        # Radar.java:56): the def fogRadius is 34
        # (Blocks.java:1991, `fogRadius = 34;`),
        # overriding the class default 10 (Radar.java:33,
        # `fogRadius = 10;`), and the discovery time is
        # 600f (Radar.java:18, `public float discoveryTime
        # = 60f * 10f;`). The actual FogControl call
        # (`public void forceUpdate(Team team, Building
        # build){`, FogControl.java:177) waits for its own
        # fog slice; the `force_update` flag is the
        # observable signal that slice will consume. One
        # def (radar, Radar.java:17, `public class Radar
        # extends Block{`; RadarBuild, Radar.java:48,
        # `public class RadarBuild extends Building{`).
        self.assertIn('static func source_radar_update_tile_state(frame: Dictionary, delta: float, discovery_time: float, fog_radius: float) -> Dictionary:', radar)
        # The advance cases, pinned as the pure function's
        # decision structure: the smoothed efficiency lerps
        # toward the folded efficiency; the fog radius is
        # computed with the new smooth efficiency and the
        # old progress; the force flag fires only when the
        # radius moved by 0.5 or more and stores the new
        # radius; progress advances by edelta() over the
        # discovery time and clamps to [0, 1];
        # total_progress advances by efficiency * edelta().
        self.assertIn('float(frame.get("smooth_efficiency", 1.0))', radar)
        self.assertIn('float(frame.get("efficiency", 0.0))', radar)
        self.assertIn('float(frame.get("progress", 0.0))', radar)
        self.assertIn('float(frame.get("last_radius", 0.0))', radar)
        self.assertIn('float(frame.get("total_progress", 0.0))', radar)
        with self.subTest(case='smooth efficiency lerps toward the folded efficiency'):
            self.assertIn('smooth_efficiency = source_math_state.source_lerp_delta(smooth_efficiency, efficiency, 0.05, delta)', radar)
        with self.subTest(case='fog radius uses the new smooth efficiency and the old progress'):
            self.assertIn('var fog_radius_value: float = fog_radius * progress * smooth_efficiency', radar)
        with self.subTest(case='force flag fires only on a 0.5-or-more radius move'):
            self.assertIn('var force_update: bool = absf(fog_radius_value - last_radius) >= 0.5', radar)
            self.assertIn('if force_update:', radar)
            self.assertIn('last_radius = fog_radius_value', radar)
        with self.subTest(case='progress advances by edelta over the discovery time'):
            self.assertIn('progress += edelta / discovery_time', radar)
        with self.subTest(case='progress clamps to [0, 1]'):
            self.assertIn('progress = clampf(progress, 0.0, 1.0)', radar)
        with self.subTest(case='total progress advances by efficiency times edelta'):
            self.assertIn('total_progress += efficiency * edelta', radar)
        with self.subTest(case='all six keys are returned'):
            self.assertIn('return {"smooth_efficiency": smooth_efficiency, "fog_radius": fog_radius_value, "force_update": force_update, "last_radius": last_radius, "progress": progress, "total_progress": total_progress}', radar)
        for expr in [
            'public void updateTile(){',
            'smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);',
            'if(Math.abs(fogRadius() - lastRadius) >= 0.5f){',
            'Vars.fogControl.forceUpdate(team, this);',
            'lastRadius = fogRadius();',
            'progress += edelta() / discoveryTime;',
            'progress = Mathf.clamp(progress);',
            'totalProgress += efficiency * edelta();',
            'public float fogRadius(){',
            'return fogRadius * progress * smoothEfficiency;',
            'public float discoveryTime = 60f * 10f;',
            'fogRadius = 34;',
            'fogRadius = 10;',
            'public float edelta(){',
            'return efficiency * delta();',
            'public float delta(){',
            'return Time.delta * timeScale;',
            'transient float efficiency;',
            'potentialEfficiency = efficiency = optionalEfficiency = 0f;',
            'public float progress;',
            'public float lastRadius = 0f;',
            'public float smoothEfficiency = 1f;',
            'public float totalProgress;',
            'public class Radar extends Block{',
            'public class RadarBuild extends Building{',
            'public void forceUpdate(Team team, Building build){',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, radar)
        self.assertIn('source_radar_update_tile_state(frame, seconds, SOURCE_RADAR_DISCOVERY_TIME, SOURCE_RADAR_FOG_RADIUS)', radar)
        self.assertIn('frame["smooth_efficiency"] = advanced.get("smooth_efficiency", 1.0)', radar)
        self.assertIn('frame["progress"] = advanced.get("progress", 0.0)', radar)
        self.assertIn('frame["total_progress"] = advanced.get("total_progress", 0.0)', radar)
        self.assertIn('static func source_radar_tick_buildings_state', radar)
        # The proof's keys drive the pure updateTile advance
        # (smooth-efficiency lerp / force update on a radius
        # jump / no force update when stable / progress
        # advance by edelta / no advance without efficiency /
        # progress clamp at one / absent frame starts at the
        # Java defaults). There are no fog-system keys: the
        # actual FogControl.forceUpdate call waits for its
        # own fog slice, and the fogRadius() accessor
        # (N2249) and the draw / icons rows are separate
        # slices with their own proofs.
        proof = RADAR_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'update_tile_smooth_efficiency_lerps_toward_efficiency',
            'update_tile_force_update_when_radius_jumps',
            'update_tile_no_force_update_when_radius_stable',
            'update_tile_progress_advances_by_edelta',
            'update_tile_no_advance_without_efficiency',
            'update_tile_progress_clamps_at_one',
            'update_tile_absent_frame_starts_at_java_defaults',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

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
            'update_tile_smooth_efficiency_lerps_toward_efficiency',
            'update_tile_force_update_when_radius_jumps',
            'update_tile_no_force_update_when_radius_stable',
            'update_tile_progress_advances_by_edelta',
            'update_tile_no_advance_without_efficiency',
            'update_tile_progress_clamps_at_one',
            'update_tile_absent_frame_starts_at_java_defaults',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
