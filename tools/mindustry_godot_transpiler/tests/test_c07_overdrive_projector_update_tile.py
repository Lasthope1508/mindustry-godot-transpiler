import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OVERDRIVE_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceOverdriveProjectorBuildState.gd'
OVERDRIVE_PROJECTOR_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07OverdriveProjectorUpdateTileProof.gd'


class C07OverdriveProjectorUpdateTileTests(unittest.TestCase):
    def test_c07_overdrive_projector_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2194']['godot_owner'], 'SourceOverdriveProjectorBuildState.source_overdrive_projector_update_tile_advance_state')
        # N2157 proved the live power.status -> efficiency driver
        # for the OverdriveProjector family, but the port tracked
        # NO updateTile advance: smoothEfficiency / heat / charge
        # / phaseHeat / useProgress never moved, so an overdrive
        # projector never accumulated charge to `reload` and
        # never boosted. N2194 is the OverdriveBuild.updateTile()
        # advance (OverdriveProjector.java:97-120): the
        # smooth-efficiency and heat lerps
        # (OverdriveProjector.java:98-99), the charge advance on
        # raw Time.delta (OverdriveProjector.java:100, NOT
        # delta() -- unlike MendProjector), the phaseHeat lerp
        # toward optionalEfficiency when hasBoost
        # (OverdriveProjector.java:102-104), the charge reset at
        # reload (OverdriveProjector.java:111-112, before the
        # indexer scan, so the reset does not depend on finding
        # a target), and the useProgress advance on delta() =
        # Time.delta * timeScale with the wrap at useTime
        # (OverdriveProjector.java:116-120). The boost
        # application (indexer.eachBlock + applyBoost,
        # OverdriveProjector.java:113) and consume()
        # (OverdriveProjector.java:119) are deferred: the
        # targets/indexer and item infrastructure they need do
        # not exist yet. Three new result symbols: the advanced
        # frame, the charge-ready (boost-fire) signal, and the
        # use-ready (consume-fire) signal.
        self.assertEqual(
            ledger['N2194']['source_symbols'],
            [
                'source_overdrive_projector_update_tile_advance_state_result.advanced',
                'source_overdrive_projector_update_tile_advance_state_result.charge_ready',
                'source_overdrive_projector_update_tile_advance_state_result.use_ready',
            ],
        )
        for name in ledger['N2194']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/OverdriveProjector.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_overdrive_projector_update_tile_advance_state_result.advanced': 'SourceOverdriveProjectorBuildState.source_overdrive_projector_update_tile_advance_state',
                    'source_overdrive_projector_update_tile_advance_state_result.charge_ready': 'SourceOverdriveProjectorBuildState.source_overdrive_projector_update_tile_advance_state',
                    'source_overdrive_projector_update_tile_advance_state_result.use_ready': 'SourceOverdriveProjectorBuildState.source_overdrive_projector_update_tile_advance_state',
                }[name])
        self.assertEqual(ledger['N2194']['runtime_proof'], '/root/C07OverdriveProjectorUpdateTileProof')
        self.assertEqual(
            ledger['N2194']['tests'],
            [
                'test_c07_overdrive_projector_update_tile_registration',
                'test_all_c07_overdrive_projector_update_tile_input_evidence_is_exact',
                'test_overdrive_projector_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_overdrive_projector_update_tile',
            ],
        )
        self.assertTrue(ledger['N2194']['deferred_exprs'])

    def test_all_c07_overdrive_projector_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2194']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_overdrive_projector_update_tile_advance_state_result.advanced': 'SourceOverdriveProjectorBuildState.source_overdrive_projector_update_tile_advance_state',
                    'source_overdrive_projector_update_tile_advance_state_result.charge_ready': 'SourceOverdriveProjectorBuildState.source_overdrive_projector_update_tile_advance_state',
                    'source_overdrive_projector_update_tile_advance_state_result.use_ready': 'SourceOverdriveProjectorBuildState.source_overdrive_projector_update_tile_advance_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/OverdriveProjector.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2194']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_overdrive_projector_update_tile_advance_state(self):
        overdrive_projector = OVERDRIVE_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The pure updateTile advance lives on the
        # overdrive-projector build state: the five frame fields
        # advance exactly in Java order (OverdriveProjector.java:
        # 97-120) -- smoothEfficiency and heat lerp toward their
        # targets, charge advances on raw Time.delta (NOT
        # delta(): `charge += heat * Time.delta;`, unlike
        # MendProjector's `charge += heat * delta();`), phaseHeat
        # lerps toward optionalEfficiency only when hasBoost,
        # charge resets to 0 at reload BEFORE the indexer scan,
        # and useProgress advances on delta() = Time.delta *
        # timeScale (BuildingComp.java:1922-1924) and wraps at
        # useTime. The lerp is Arc's lerpDelta
        # (Mathf.java:430-432, `return lerp(fromValue, toValue,
        # clamp(progress * Time.delta));` with lerp
        # `fromValue + (toValue - fromValue) * progress`), via
        # the canonical source_lerp_delta; Time.delta in the
        # port is seconds * 60 (game_source_delta, arc
        # Time.java:26 `() -> Math.min(Core.graphics.
        # getDeltaTime() * 60f, 3f)`), never raw seconds (the
        # N2186/N2187/N2191 lesson: raw seconds run 60x slow).
        # The charge init binds Java's `Mathf.random(reload)`
        # (OverdriveProjector.java:84) to deterministic 0.0 --
        # the runtime-state default precedent
        # (SourceOverdriveProjectorRuntimeState.capture_state /
        # runtime_step_state default charge 0.0) -- so proofs
        # are deterministic. hasBoost / reload / useTime come
        # from the catalog per def (overdrive-projector:
        # hasBoost true, useTime 400f, reload 60f;
        # overdrive-dome: hasBoost false, Blocks.java:1960,
        # useTime 300f, Blocks.java:1958, reload 60f) through
        # SourceOverdriveProjectorState's accessors -- no
        # per-def stamp is needed. The timeScale for delta()
        # is read live from the sprite meta (the N2189
        # precedent). optionalEfficiency is already folded by
        # the shared machinery (BuildingComp.java:1965, 1981,
        # 1986; apply_update_consumption_state stamps
        # frame["optional_efficiency"]); with no optional
        # consumers modeled it equals the min efficiency, so
        # the advance defaults a missing stamp to the frame
        # efficiency. The wrap fires with the branch:
        # consume() returns void, so nothing gates
        # `useProgress %= useTime;` on consume's outcome --
        # the wrap is unconditional arithmetic in the branch,
        # and the runtime-step precedent wraps too; only the
        # consume() item side effect is deferred.
        self.assertIn('static func source_overdrive_projector_update_tile_advance_state', overdrive_projector)
        self.assertIn('smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);', overdrive_projector)
        self.assertIn('heat = Mathf.lerpDelta(heat, efficiency > 0 ? 1f : 0f, 0.08f);', overdrive_projector)
        self.assertIn('charge += heat * Time.delta;', overdrive_projector)
        self.assertIn('phaseHeat = Mathf.lerpDelta(phaseHeat, optionalEfficiency, 0.1f);', overdrive_projector)
        self.assertIn('charge = 0f;', overdrive_projector)
        self.assertIn('useProgress += delta();', overdrive_projector)
        self.assertIn('useProgress %= useTime;', overdrive_projector)
        self.assertIn('return (speedBoost + phaseHeat * speedBoostPhase) * efficiency;', overdrive_projector)
        self.assertIn('return lerp(fromValue, toValue, clamp(progress * Time.delta));', overdrive_projector)
        self.assertIn('return Time.delta * timeScale;', overdrive_projector)
        self.assertIn('public float heat, charge = Mathf.random(reload), phaseHeat, smoothEfficiency, useProgress;', overdrive_projector)
        self.assertIn('indexer.eachBlock(this, realRange, other -> other.block.canOverdrive, other -> other.applyBoost(realBoost(), reload + 1f));', overdrive_projector)
        self.assertIn('source_lerp_delta', overdrive_projector)
        self.assertIn('game_source_delta(game, seconds)', overdrive_projector)
        self.assertIn('source_placed_block_state.time_scale(sprite', overdrive_projector)
        self.assertIn('source_overdrive_projector_state.has_boost(block)', overdrive_projector)
        self.assertIn('source_overdrive_projector_state.projector_reload(block)', overdrive_projector)
        self.assertIn('source_overdrive_projector_state.use_time(block)', overdrive_projector)
        self.assertIn('"smooth_efficiency"', overdrive_projector)
        self.assertIn('"phase_heat"', overdrive_projector)
        self.assertIn('"use_progress"', overdrive_projector)
        self.assertIn('"charge_ready"', overdrive_projector)
        self.assertIn('"use_ready"', overdrive_projector)
        self.assertIn('fmod(use_progress', overdrive_projector)
        self.assertIn('static func source_overdrive_projector_tick_buildings_state', overdrive_projector)
        # The power row is untouched: the N2157 behaviour (the
        # live power.status fold) is preserved by this slice.
        self.assertIn('static func source_overdrive_projector_power_status_row_state', overdrive_projector)
        self.assertIn('return build.power.status;', overdrive_projector)
        # The proof's keys drive the pure advance (lerps /
        # charge advance + reset / phaseHeat with and without
        # boost / useProgress advance + wrap) plus the live
        # tick (the frame advances and the power fold is
        # preserved). There are no boost-application keys: the
        # indexer scan + applyBoost (OverdriveProjector.java:
        # 113) waits for its own slice, so the proof asserts
        # only the charge reset, never a boosted target. The
        # proof's preloads must point at files that exist.
        proof = OVERDRIVE_PROJECTOR_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'smooth_efficiency_heat_lerp_toward_efficiency',
            'charge_advances_and_resets_at_reload',
            'phase_heat_lerps_when_has_boost',
            'phase_heat_frozen_without_boost',
            'use_progress_advances_and_wraps',
            'live_tick_advances_frame_and_preserves_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        for preload in re.findall(r'preload\("res://([^"]+)"\)', proof):
            with self.subTest(preload=preload):
                self.assertTrue((ROOT / 'godot-mindustry' / preload).is_file(), preload)

    def test_reference_graph_and_actual_c07_overdrive_projector_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07OverdriveProjectorUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_OVERDRIVE_PROJECTOR_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'smooth_efficiency_heat_lerp_toward_efficiency',
            'charge_advances_and_resets_at_reload',
            'phase_heat_lerps_when_has_boost',
            'phase_heat_frozen_without_boost',
            'use_progress_advances_and_wraps',
            'live_tick_advances_frame_and_preserves_power',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
