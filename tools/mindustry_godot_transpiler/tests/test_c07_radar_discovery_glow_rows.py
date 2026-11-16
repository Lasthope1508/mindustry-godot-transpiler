import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RADAR_STATE = ROOT / 'godot-mindustry/src/game/SourceRadarBuildState.gd'
RADAR_DISCOVERY_GLOW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarDiscoveryGlowRowsProof.gd'
RADAR_DISCOVERY_GLOW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarDiscoveryGlowRowsProof.tscn'


class C07RadarDiscoveryGlowRowsTests(unittest.TestCase):
    def test_c07_radar_discovery_glow_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2503']['godot_owner'], 'SourceRadarBuildState.source_radar_discovery_glow_rows_state')
        # The radar tick is live (N2173 power row + N2190
        # updateTile advance + N2427 draw rows + N2474
        # fogRadius accessor + N2479 canPickup /
        # progress rows) but NOTHING modeled the
        # discoveryTime / rotateSpeed / glow static
        # defs themselves as source-backed values:
        # discoveryTime is consumed by the N2190
        # advance (`progress += edelta() /
        # discoveryTime;`, Radar.java:68) as a
        # caller-supplied divisor, and rotateSpeed /
        # glow ride the N2427 draw pure as
        # caller-supplied inputs. N2503 ports them
        # as ONE pure-only rows pure (the N2304 /
        # N2442 / N2489 / N2490 / N2498
        # verification-slice precedent): the def's
        # rows for radar, with the CLASS defaults
        # for an unknown def id (the N2304 fallback
        # precedent). The radar def
        # (Blocks.java:1988-1995) does NOT override
        # discoveryTime / rotateSpeed / glow -- it
        # sets only fogRadius 34 + consumers -- so
        # the def row EQUALS the class row here.
        # Five new result symbols: the discovery
        # time + the rotate speed + the glow color
        # token + the glow scale + the glow
        # magnitude.
        self.assertEqual(
            ledger['N2503']['source_symbols'],
            [
                'source_radar_discovery_glow_rows_state_result.discovery_time',
                'source_radar_discovery_glow_rows_state_result.rotate_speed',
                'source_radar_discovery_glow_rows_state_result.glow_color',
                'source_radar_discovery_glow_rows_state_result.glow_scl',
                'source_radar_discovery_glow_rows_state_result.glow_mag',
            ],
        )
        for name in ledger['N2503']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/Radar.java')
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.source_radar_discovery_glow_rows_state')
        self.assertEqual(ledger['N2503']['runtime_proof'], '/root/C07RadarDiscoveryGlowRowsProof')
        self.assertEqual(
            ledger['N2503']['tests'],
            [
                'test_c07_radar_discovery_glow_rows_registration',
                'test_all_c07_radar_discovery_glow_rows_input_evidence_is_exact',
                'test_radar_discovery_glow_rows_state',
                'test_reference_graph_and_actual_c07_radar_discovery_glow_rows',
            ],
        )
        self.assertTrue(ledger['N2503']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #110 (1-based
        # in DEFERRED-after-advances-35.py, 218
        # entries): the Radar discoveryTime /
        # rotateSpeed / glow rows entry is REMOVED
        # -- the static defs are live now as a
        # source-backed pure. The forceUpdate CALL
        # (#123 in the old numbering) and the
        # read/write rows (#32) stay deferred: they
        # are NOT in this slice's scope. Net 218 -
        # 1 = 217.
        self.assertFalse(any(entry.startswith('Radar discoveryTime / rotateSpeed / glow rows (discoveryTime 60f * 10f') for entry in ledger['N2503']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Radar read/write rows (progress, Radar.java:98-110)') for entry in ledger['N2503']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Radar fogControl.forceUpdate call (Vars.fogControl.forceUpdate(team, this), Radar.java:64)') for entry in ledger['N2503']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Radar shouldConsume gate (RadarBuild has no shouldConsume override') for entry in ledger['N2503']['deferred_exprs']))
        self.assertEqual(len(ledger['N2503']['deferred_exprs']), 217)

    def test_all_c07_radar_discovery_glow_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2503']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.source_radar_discovery_glow_rows_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/Radar.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2503']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_radar_discovery_glow_rows_state(self):
        radar = RADAR_STATE.read_text(encoding='utf-8')
        # The discovery/glow static defs
        # (Radar.java:18-19, :24-25):
        # `public float discoveryTime = 60f * 10f;`
        # `public float rotateSpeed = 2f;`
        # `public Color glowColor = Pal.turretHeat;`
        # `public float glowScl = 5f, glowMag = 0.6f;`
        # The single radar def
        # (`radar = new Radar("radar"){{`,
        # Blocks.java:1988) does NOT override any
        # of them -- it sets only `fogRadius = 34;`
        # (Blocks.java:1991) + consumers
        # (`consumePower(0.6f);`, Blocks.java:1994)
        # -- so the def row EQUALS the class row.
        # An unknown def id falls back to the CLASS
        # defaults (the N2304 fallback precedent).
        # The glow color rides as a String TOKEN
        # ("Pal.turretHeat", the N2469 token
        # precedent -- SSOT has no Color type, the
        # MendProjector precedent). Pure-only: the
        # caller (the N2427 draw pure's caller, the
        # N2190 advance's caller) reads it; the
        # existing pures are unchanged.
        # Keep each Java expr on ONE comment line (the
        # N2148 lesson: a split line fails this test).
        self.assertIn('static func source_radar_discovery_glow_rows_state', radar)
        self.assertIn('public float discoveryTime = 60f * 10f;', radar)
        self.assertIn('public float rotateSpeed = 2f;', radar)
        self.assertIn('public Color glowColor = Pal.turretHeat;', radar)
        self.assertIn('public float glowScl = 5f, glowMag = 0.6f;', radar)
        self.assertIn('radar = new Radar("radar"){{', radar)
        self.assertIn('public class Radar extends Block{', radar)
        self.assertIn('fogRadius = 34;', radar)
        self.assertIn('consumePower(0.6f);', radar)
        self.assertIn('progress += edelta() / discoveryTime;', radar)
        self.assertIn('Drawf.additive(glowRegion, glowColor, glowColor.a * (1f - glowMag + Mathf.absin(glowScl, glowMag)), x, y, rotateSpeed * totalProgress, Layer.blockAdditive);', radar)
        self.assertIn('"discovery_time"', radar)
        self.assertIn('"rotate_speed"', radar)
        self.assertIn('"glow_color"', radar)
        self.assertIn('"glow_scl"', radar)
        self.assertIn('"glow_mag"', radar)
        # The documented limits record the
        # discovery/glow rows as live.
        self.assertIn('Discovery/glow rows live (N2503)', radar)
        # The proof's keys drive the discovery/glow
        # rows pure (the radar def row, the
        # discovery time + the 600-tick full
        # discovery, the rotate speed + glow scale /
        # magnitude, the glow color token, the class
        # fallback for an unknown def id, and the
        # rows feeding the N2427 draw pure + the
        # N2190 advance as live inputs).
        proof = RADAR_DISCOVERY_GLOW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'rows_radar',
            'rows_discovery',
            'rows_rotate_glow',
            'rows_color_token',
            'rows_class_fallback',
            'rows_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceRadarBuildState.gd")', proof)
        self.assertTrue(RADAR_STATE.is_file())
        scene = RADAR_DISCOVERY_GLOW_ROWS_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RadarDiscoveryGlowRowsProof.gd', scene)
        self.assertTrue(RADAR_DISCOVERY_GLOW_ROWS_PROOF.is_file())

    def test_reference_graph_and_actual_c07_radar_discovery_glow_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RadarDiscoveryGlowRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RADAR_DISCOVERY_GLOW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'rows_radar',
            'rows_discovery',
            'rows_rotate_glow',
            'rows_color_token',
            'rows_class_fallback',
            'rows_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
