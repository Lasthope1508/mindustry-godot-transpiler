import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RADAR_STATE = ROOT / 'godot-mindustry/src/game/SourceRadarBuildState.gd'
RADAR_FOG_RADIUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarFogRadiusProof.gd'


class C07RadarFogRadiusTests(unittest.TestCase):
    def test_c07_radar_fog_radius_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2275']['godot_owner'], 'SourceRadarBuildState.source_radar_fog_radius_state')
        # RadarBuild.fogRadius() (Radar.java:55, `public float
        # fogRadius(){` with `return fogRadius * progress *
        # smoothEfficiency;`, Radar.java:56) is the live fog
        # radius: the def fogRadius (34 for the radar def,
        # Blocks.java:1991, `fogRadius = 34;`, overriding the
        # class default 10, Radar.java:33, `fogRadius = 10;`)
        # scaled by the discovery progress (Radar.java:49,
        # `public float progress;`, init 0.0) and the smoothed
        # efficiency (Radar.java:51, `public float
        # smoothEfficiency = 1f;`, init 1.0). The accessor is
        # what updateTile reads for its force-update check
        # (Radar.java:63, `if(Math.abs(fogRadius() -
        # lastRadius) >= 0.5f){`) and what drawSelect draws
        # (Radar.java:80-82, `Drawf.dashCircle(x, y,
        # fogRadius() * tilesize, Pal.accent);`). N2275 closes
        # the accessor half of that gap with one pure function
        # over the frame (`progress`, `smooth_efficiency`)
        # plus the per-def fog_radius parameter (the N2212
        # per-def-param precedent), following the N2248
        # updateTile precedent: the pure function takes
        # (frame, fog_radius) and returns the live fog
        # radius. The updateTile advance (N2248) and the
        # drawSelect/drawPlace rows (N2250 owns icons; draw
        # rows wait for their own slice) consume the value;
        # no driver tick line lands here because this base
        # has no updateTile driver yet -- the accessor is
        # the read its callers will share. One new result
        # symbol: fog_radius.
        self.assertEqual(
            ledger['N2275']['source_symbols'],
            [
                'source_radar_fog_radius_state_result.fog_radius',
            ],
        )
        for name in ledger['N2275']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/Radar.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2275']['runtime_proof'], '/root/C07RadarFogRadiusProof')
        self.assertEqual(
            ledger['N2275']['tests'],
            [
                'test_c07_radar_fog_radius_registration',
                'test_all_c07_radar_fog_radius_input_evidence_is_exact',
                'test_radar_fog_radius_state',
                'test_reference_graph_and_actual_c07_radar_fog_radius',
            ],
        )
        self.assertTrue(ledger['N2275']['deferred_exprs'])

    def test_all_c07_radar_fog_radius_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2275']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/Radar.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2275']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_radar_fog_radius_state(self):
        radar = RADAR_STATE.read_text(encoding='utf-8')
        # The pure fogRadius() accessor lives on the radar
        # build state next to the N2173 power row and the
        # N2248 updateTile advance: RadarBuild.fogRadius()
        # (Radar.java:55, `public float fogRadius(){` with
        # `return fogRadius * progress * smoothEfficiency;`,
        # Radar.java:56) returns the def fogRadius scaled by
        # progress and smooth efficiency. The def fogRadius
        # is 34 (Blocks.java:1991, `fogRadius = 34;`),
        # overriding the class default 10 (Radar.java:33,
        # `fogRadius = 10;`). The frame carries `progress`
        # (float, absent defaults to 0.0 -- `public float
        # progress;`, Radar.java:49) and `smooth_efficiency`
        # (float, absent defaults to 1.0 -- `public float
        # smoothEfficiency = 1f;`, Radar.java:51). The
        # accessor is what updateTile reads for its
        # force-update check (Radar.java:63,
        # `if(Math.abs(fogRadius() - lastRadius) >= 0.5f){`)
        # and what drawSelect draws (Radar.java:80-82,
        # `Drawf.dashCircle(x, y, fogRadius() * tilesize,
        # Pal.accent);`). fog_radius is an explicit per-def
        # param (the N2212 per-def-param precedent); the
        # driver passes the radar-def value 34.0 when it
        # lands. One def (radar, Radar.java:17, `public
        # class Radar extends Block{`; RadarBuild,
        # Radar.java:48, `public class RadarBuild extends
        # Building{`).
        self.assertIn('static func source_radar_fog_radius_state(frame: Dictionary, fog_radius: float) -> Dictionary:', radar)
        # The accessor cases, pinned as the pure function's
        # decision structure: the live radius is the def
        # radius times progress times smooth efficiency; an
        # absent frame starts at the Java defaults.
        self.assertIn('float(frame.get("progress", 0.0))', radar)
        self.assertIn('float(frame.get("smooth_efficiency", 1.0))', radar)
        with self.subTest(case='live radius is def radius times progress times smooth efficiency'):
            self.assertIn('var fog_radius_value: float = fog_radius * progress * smooth_efficiency', radar)
        with self.subTest(case='the one key is returned'):
            self.assertIn('return {"fog_radius": fog_radius_value}', radar)
        for expr in [
            'public float fogRadius(){',
            'return fogRadius * progress * smoothEfficiency;',
            'fogRadius = 34;',
            'fogRadius = 10;',
            'public float progress;',
            'public float smoothEfficiency = 1f;',
            'if(Math.abs(fogRadius() - lastRadius) >= 0.5f){',
            'Drawf.dashCircle(x, y, fogRadius() * tilesize, Pal.accent);',
            'public class Radar extends Block{',
            'public class RadarBuild extends Building{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, radar)
        # The proof's keys drive the pure fogRadius()
        # accessor (zero before discovery / scales with
        # progress / scales with smooth efficiency / full
        # discovery / class-default def radius / absent frame
        # starts at the Java defaults). There are no fog-
        # system keys: the actual FogControl.forceUpdate
        # call waits for its own fog slice, and the
        # updateTile advance (N2248) and the draw / icons
        # rows are separate slices with their own proofs.
        proof = RADAR_FOG_RADIUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'fog_radius_zero_before_discovery',
            'fog_radius_scales_with_progress',
            'fog_radius_scales_with_smooth_efficiency',
            'fog_radius_full_discovery',
            'fog_radius_class_default_ten',
            'fog_radius_absent_frame_starts_at_java_defaults',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_radar_fog_radius(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RadarFogRadiusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RADAR_FOG_RADIUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'fog_radius_zero_before_discovery',
            'fog_radius_scales_with_progress',
            'fog_radius_scales_with_smooth_efficiency',
            'fog_radius_full_discovery',
            'fog_radius_class_default_ten',
            'fog_radius_absent_frame_starts_at_java_defaults',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
