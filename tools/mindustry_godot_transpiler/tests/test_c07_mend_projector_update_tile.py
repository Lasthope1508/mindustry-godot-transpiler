import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MEND_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceMendProjectorBuildState.gd'
MEND_PROJECTOR_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorUpdateTileProof.gd'
MEND_PROJECTOR_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorUpdateTileProof.tscn'


class C07MendProjectorUpdateTileTests(unittest.TestCase):
    def test_c07_mend_projector_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2193']['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_update_tile_advance_state')
        # N2156 proved the live power.status -> efficiency driver
        # for the mend projector (the pure power row folded into
        # the min efficiency, the heal fold
        # MendProjector.java:113 following it) -- but the port
        # still tracked no smoothEfficiency / heat / charge /
        # phaseHeat on the placed-building frame, so a mend
        # projector never accumulates charge up to `reload` to
        # heal: the updateTile advance (MendProjector.java:94-120) waited
        # for its own slice. N2193 is that advance: a pure
        # frame advance over the exact Java lines -- the
        # smoothEfficiency / heat lerps (0.08f), the charge
        # advance (`charge += heat * delta();`), the phaseHeat
        # lerp (0.1f toward optionalEfficiency), and the charge
        # reset (`charge = 0f;`) inside the `charge >= reload`
        # branch, which sits BEFORE the indexer scan, so the
        # reset does not depend on finding a target. The
        # timer/consume line and the heal scan + sound are
        # deferred (timer + items / targets + indexer
        # infrastructure), as are draw / drawLight / sense.
        # canHeal is a documented default true: `canHeal =
        # !checkSuppression();` (MendProjector.java:94) needs
        # suppression state the tick does not track yet (the
        # N2184 BuildTurret suppression precedent). Four new
        # result symbols: the four frame state values the
        # advance writes back.
        self.assertEqual(
            ledger['N2193']['source_symbols'],
            [
                'source_mend_projector_update_tile_advance_result.smooth_efficiency',
                'source_mend_projector_update_tile_advance_result.heat',
                'source_mend_projector_update_tile_advance_result.charge',
                'source_mend_projector_update_tile_advance_result.phase_heat',
            ],
        )
        for name in ledger['N2193']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/MendProjector.java')
                self.assertEqual(symbol['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_update_tile_advance_state')
        self.assertEqual(ledger['N2193']['runtime_proof'], '/root/C07MendProjectorUpdateTileProof')
        self.assertEqual(
            ledger['N2193']['tests'],
            [
                'test_c07_mend_projector_update_tile_registration',
                'test_all_c07_mend_projector_update_tile_input_evidence_is_exact',
                'test_mend_projector_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_mend_projector_update_tile',
            ],
        )
        self.assertTrue(ledger['N2193']['deferred_exprs'])

    def test_all_c07_mend_projector_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2193']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/MendProjector.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream' / 'arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        for expr in ledger['N2193']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mend_projector_update_tile_advance_state(self):
        mend_projector = MEND_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The pure updateTile advance lives on the mend-projector
        # build state: the four frame values advance exactly the
        # Java lines (MendProjector.java:94-120) -- keep each
        # exact expr on ONE comment line, the N2148 lesson: a
        # split line fails this test.
        self.assertIn('static func source_mend_projector_update_tile_advance_state', mend_projector)
        self.assertIn('boolean canHeal = !checkSuppression();', mend_projector)
        self.assertIn('smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);', mend_projector)
        self.assertIn('heat = Mathf.lerpDelta(heat, efficiency > 0 && canHeal ? 1f : 0f, 0.08f);', mend_projector)
        self.assertIn('charge += heat * delta();', mend_projector)
        self.assertIn('phaseHeat = Mathf.lerpDelta(phaseHeat, optionalEfficiency, 0.1f);', mend_projector)
        self.assertIn('if(charge >= reload && canHeal){', mend_projector)
        self.assertIn('charge = 0f;', mend_projector)
        self.assertIn('public float heat, charge = Mathf.random(reload), phaseHeat, smoothEfficiency;', mend_projector)
        # The lerpDelta formula comes from Arc, not from a guess:
        # lerpDelta lerps by the UNSCALED Time.delta
        # (Mathf.java:430-432), while the charge advance uses
        # the SCALED delta() (BuildingComp.java:1922-1924).
        self.assertIn('return lerp(fromValue, toValue, clamp(progress * Time.delta));', mend_projector)
        self.assertIn('return Time.delta * timeScale;', mend_projector)
        # The deferred lines stay visible as deferrals, not
        # implementations: the booster timer/consume and the
        # heal scan + sound wait for their own slices.
        self.assertIn('if(optionalEfficiency > 0 && timer(timerUse, useTime / timeScale) && canHeal){', mend_projector)
        self.assertIn('other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);', mend_projector)
        # The tick driver wires the advance for every ticked
        # mend projector (updateTile runs even when disabled:
        # BuildingComp.java:2276, `if(enabled ||
        # !block.noUpdateDisabled){` with noUpdateDisabled false,
        # Block.java:170): per-def reload from the family
        # helper (mender 200f, mend-projector 250f,
        # Blocks.java:1923/1936), Time.delta in ticks from the
        # placed-block helper, and the live timeScale from the
        # sprite meta (default 1f, BuildingComp.java:98).
        self.assertIn('source_mend_projector_update_tile_advance_state(frame', mend_projector)
        self.assertIn('projector_reload(block)', mend_projector)
        self.assertIn('game_source_delta(game, seconds)', mend_projector)
        self.assertIn('time_scale(sprite', mend_projector)
        # The proof's keys drive the pure advance (smooth /
        # heat lerps, charge advance, charge reset at reload,
        # phaseHeat lerp) plus the live tick (the N2156
        # power.status fold still holds). There are no
        # timer/consume or heal-scan keys: the timer/consume
        # line (MendProjector.java:101-103) and the heal scan +
        # sound (MendProjector.java:106-118) are deferred, so
        # the reset -- not a heal -- is what the reset key
        # proves.
        proof = MEND_PROJECTOR_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'smooth_efficiency_lerps_to_efficiency',
            'heat_lerps_by_efficiency_and_can_heal',
            'charge_advances_by_heat_delta',
            'charge_resets_at_reload',
            'phase_heat_lerps_to_optional_efficiency',
            'efficiency_folds_power_min',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Every preload in the proof points at a file that
        # exists (the N2185 lesson: a proof scene that cannot
        # load fails for the wrong reason on Windows).
        for preload in re.findall(r'preload\("res://([^"]+)"\)', proof):
            with self.subTest(preload=preload):
                self.assertTrue((ROOT / 'godot-mindustry' / preload).is_file(), preload)
        scene = MEND_PROJECTOR_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07MendProjectorUpdateTileProof.gd', scene)
        self.assertIn('[node name="C07MendProjectorUpdateTileProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_mend_projector_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MendProjectorUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MEND_PROJECTOR_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'smooth_efficiency_lerps_to_efficiency',
            'heat_lerps_by_efficiency_and_can_heal',
            'charge_advances_by_heat_delta',
            'charge_resets_at_reload',
            'phase_heat_lerps_to_optional_efficiency',
            'efficiency_folds_power_min',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
