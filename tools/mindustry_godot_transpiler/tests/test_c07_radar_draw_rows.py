import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RADAR_STATE = ROOT / 'godot-mindustry/src/game/SourceRadarBuildState.gd'
RADAR_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarDrawRowsProof.gd'
RADAR_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarDrawRowsProof.tscn'


class C07RadarDrawRowsTests(unittest.TestCase):
    def test_c07_radar_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2427']['godot_owner'], 'SourceRadarBuildState.source_radar_draw_state')
        # The radar tick is live (N2173 power row + N2190
        # updateTile advance) but NOTHING modeled draw():
        # the base rect + the rotating region rect + the
        # additive glow (Radar.java:85-90), the drawSelect
        # dash circle (Radar.java:80-82), icons()
        # (Radar.java:37-39), or the drawPlace dash
        # circle (Radar.java:42-46). N2427 ports all
        # four as ONE pure-only draw pure, the N2396
        # MassDriver pattern: draw is never called by
        # the tick, so the pure takes caller-supplied
        # inputs (world x/y + tile x/y + rotateSpeed /
        # totalProgress + glow defs + Time.time + the
        # fog radii + offset + size) and returns the
        # draw calls as data. The icons ride the draw
        # pure as the icon_regions result key
        # ([baseRegion, region] -- icons() takes no args
        # and the SSOT schema validator requires
        # non-empty input keys). Verify-first:
        # drawSelect uses the fogRadius() METHOD
        # (fogRadius * progress * smoothEfficiency,
        # Radar.java:55-57) while drawPlace uses the
        # fogRadius FIELD (Block.java:348, def 34,
        # Blocks.java:1991) -- so the pure takes both
        # radii as separate inputs. Six new result
        # symbols: the base call, the region call, the
        # glow call, the select call, the place call,
        # and the merged icon regions.
        self.assertEqual(
            ledger['N2427']['source_symbols'],
            [
                'source_radar_draw_state_result.base_call',
                'source_radar_draw_state_result.region_call',
                'source_radar_draw_state_result.glow_call',
                'source_radar_draw_state_result.select_call',
                'source_radar_draw_state_result.place_call',
                'source_radar_draw_state_result.icon_regions',
            ],
        )
        for name in ledger['N2427']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/Radar.java')
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.source_radar_draw_state')
        self.assertEqual(ledger['N2427']['runtime_proof'], '/root/C07RadarDrawRowsProof')
        self.assertEqual(
            ledger['N2427']['tests'],
            [
                'test_c07_radar_draw_rows_registration',
                'test_all_c07_radar_draw_rows_input_evidence_is_exact',
                'test_radar_draw_rows_state',
                'test_reference_graph_and_actual_c07_radar_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2427']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #44 + #45
        # (1-based in DEFERRED-after-advances-25.py):
        # the Radar draw / drawSelect / icons rows entry
        # and the Radar drawPlace rows entry are both
        # REMOVED -- draw() + drawSelect + icons() +
        # drawPlace() are live now, so nothing of either
        # entry remains. Net 280 - 2 = 278.
        self.assertFalse(any(entry.startswith('Radar draw / drawSelect / icons rows (draw base/region/glow rotateSpeed * totalProgress, Radar.java:85-90') for entry in ledger['N2427']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('Radar drawPlace rows (dash circle fogRadius * tilesize, Radar.java:42-46)') for entry in ledger['N2427']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Radar read/write rows (progress, Radar.java:98-110)') for entry in ledger['N2427']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Radar canPickup / progress() rows (canPickup false, Radar.java:75-77') for entry in ledger['N2427']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Radar fogRadius rows (fogRadius() = fogRadius * progress * smoothEfficiency, Radar.java:55-57') for entry in ledger['N2427']['deferred_exprs']))
        self.assertEqual(len(ledger['N2427']['deferred_exprs']), 278)

    def test_all_c07_radar_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2427']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.source_radar_draw_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/Radar.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/graphics/Pal.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Blocks.java',
            'arc-core/src/arc/math/Mathf.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2427']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_radar_draw_rows_state(self):
        radar = RADAR_STATE.read_text(encoding='utf-8')
        # The draw rows (RadarBuild.draw(), Radar.java:
        # 85-90): `Draw.rect(baseRegion, x, y);` then
        # `Draw.rect(region, x, y, rotateSpeed *
        # totalProgress);` then the additive glow
        # (`Drawf.additive(glowRegion, glowColor,
        # glowColor.a * (1f - glowMag + Mathf.absin(
        # glowScl, glowMag)), x, y, rotateSpeed *
        # totalProgress, Layer.blockAdditive);`). The
        # glow absin is the 2-arg form (`return absin(
        # Time.time, scl, mag);`, Mathf.java:74-75, arc)
        # over the 3-arg form (`return (sin(in, scl *
        # 2f, mag) + mag) / 2f;`, Mathf.java:78-80, arc)
        # -- Java-exact through the shared helper at the
        # DOUBLED scale (helper(v, s) == Java absin(v,
        # s / 2f), the N2372/N2382 lesson), so the pure
        # passes glow_scl * 2f. drawSelect
        # (Radar.java:80-82) dashes the LIVE radius
        # (`Drawf.dashCircle(x, y, fogRadius() *
        # tilesize, Pal.accent);`, fogRadius() is
        # `return fogRadius * progress *
        # smoothEfficiency;`, Radar.java:56) while
        # drawPlace (Radar.java:42-46) dashes the DEF
        # radius (`Drawf.dashCircle(x * tilesize +
        # offset, y * tilesize + offset, fogRadius *
        # tilesize, Pal.accent);` after `super.drawPlace(
        # x, y, rotation, valid);`) -- method vs field,
        # verified first. icons() (Radar.java:37-39)
        # returns `{baseRegion, region}` and rides the
        # draw pure (the N2396 precedent). The defs are
        # rotateSpeed 2f / glowScl 5f / glowMag 0.6f /
        # glowColor Pal.turretHeat (Radar.java:19/24-25,
        # no def override -- the radar def,
        # Blocks.java:1989-1995, sets only fogRadius 34
        # / consumers); the regions are `@-base` /
        # `@-glow` (Radar.java:21-22); tilesize is the
        # Java constant 8.0 (`public static final int
        # tilesize = 8;`, Vars.java:135 -- NEVER the
        # game tile_size 32, the N2375 lesson); the
        # offset is the Block offset (`offset = ((size
        # + 1) % 2) * tilesize / 2f;`, Block.java:761 --
        # 0 for the size-1 radar, `public int size = 1;`,
        # Block.java:215). Pure-only: the tick never
        # calls draw (draw is called by the renderer,
        # drawSelect/drawPlace by the UI, icons by the
        # atlas).
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_radar_draw_state', radar)
        self.assertIn('Draw.rect(baseRegion, x, y);', radar)
        self.assertIn('Draw.rect(region, x, y, rotateSpeed * totalProgress);', radar)
        self.assertIn('Drawf.additive(glowRegion, glowColor, glowColor.a * (1f - glowMag + Mathf.absin(glowScl, glowMag)), x, y, rotateSpeed * totalProgress, Layer.blockAdditive);', radar)
        self.assertIn('return absin(Time.time, scl, mag);', radar)
        self.assertIn('return (sin(in, scl * 2f, mag) + mag) / 2f;', radar)
        self.assertIn('source_math_state.source_absin', radar)
        self.assertIn('Drawf.dashCircle(x, y, fogRadius() * tilesize, Pal.accent);', radar)
        self.assertIn('Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, fogRadius * tilesize, Pal.accent);', radar)
        self.assertIn('super.drawPlace(x, y, rotation, valid);', radar)
        self.assertIn('return fogRadius * progress * smoothEfficiency;', radar)
        self.assertIn('public float fogRadius(){', radar)
        self.assertIn('public int fogRadius = -1;', radar)
        self.assertIn('public TextureRegion[] icons(){', radar)
        self.assertIn('return new TextureRegion[]{baseRegion, region};', radar)
        self.assertIn('public void drawPlace(int x, int y, int rotation, boolean valid){', radar)
        self.assertIn('public float rotateSpeed = 2f;', radar)
        self.assertIn('public float glowScl = 5f, glowMag = 0.6f;', radar)
        self.assertIn('public Color glowColor = Pal.turretHeat;', radar)
        self.assertIn('public @Load("@-base") TextureRegion baseRegion;', radar)
        self.assertIn('public @Load("@-glow") TextureRegion glowRegion;', radar)
        self.assertIn('public static void additive(TextureRegion region, Color color, float alpha, float x, float y, float rotation, float layer){', radar)
        self.assertIn('public static void dashCircle(float x, float y, float rad, Color color){', radar)
        self.assertIn('public static final int tilesize = 8;', radar)
        self.assertIn('offset = ((size + 1) % 2) * tilesize / 2f;', radar)
        self.assertIn('public int size = 1;', radar)
        self.assertIn('fogRadius = 34;', radar)
        self.assertIn('turretHeat = Color.valueOf("ab3400"),', radar)
        self.assertIn('"base_call"', radar)
        self.assertIn('"region_call"', radar)
        self.assertIn('"glow_call"', radar)
        self.assertIn('"select_call"', radar)
        self.assertIn('"place_call"', radar)
        self.assertIn('"icon_regions"', radar)
        # The documented limits record the draw rows as
        # live (the old "draw / drawSelect / icons /
        # drawPlace wait" text is gone -- sense +
        # read-write + canPickup still wait, draw does
        # not).
        self.assertIn('Draw rows live (N2427)', radar)
        self.assertNotIn('draw / drawSelect / icons / drawPlace / read-write / canPickup wait', radar)
        # The proof's keys drive the draw pure (the
        # base rect + the region rotation, the glow
        # absin math at the doubled scale, the
        # drawSelect dash circle on the live radius,
        # the drawPlace dash circle on the def radius,
        # the merged icons, and the totalProgress 0
        # edge where nothing rotates).
        proof = RADAR_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_base_region_rotation',
            'draw_glow_absin',
            'draw_select_dash_circle',
            'draw_place_dash_circle',
            'draw_icons_merged',
            'draw_total_progress_zero_edge',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceRadarBuildState.gd")', proof)
        self.assertTrue(RADAR_STATE.is_file())
        scene = RADAR_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RadarDrawRowsProof.gd', scene)
        self.assertTrue(RADAR_DRAW_ROWS_PROOF.is_file())

    def test_reference_graph_and_actual_c07_radar_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RadarDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RADAR_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_base_region_rotation',
            'draw_glow_absin',
            'draw_select_dash_circle',
            'draw_place_dash_circle',
            'draw_icons_merged',
            'draw_total_progress_zero_edge',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
