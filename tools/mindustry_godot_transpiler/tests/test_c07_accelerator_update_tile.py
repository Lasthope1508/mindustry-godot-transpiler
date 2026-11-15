import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ACCELERATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceAcceleratorBuildState.gd'
ACCELERATOR_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorUpdateTileProof.gd'
ACCELERATOR_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorUpdateTileProof.tscn'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'
PROOF_KEYS = [
    'heat_lerps_toward_efficiency',
    'status_lerp_tracks_power_status',
    'launch_heat_lerps_by_launching',
    'time_advances_and_slerps',
    'progress_advances_and_clamps',
    'live_tick_advances_and_folds_power',
]


class C07AcceleratorUpdateTileTests(unittest.TestCase):
    def test_c07_accelerator_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2191']['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_update_tile_advance_state')
        # N2183 gave the accelerator its live power.status read
        # (the pure power row, folded by the shared machinery
        # into the min efficiency) -- but the port still never
        # advanced the AcceleratorBuild.updateTile state
        # (Accelerator.java:127-146): heat, statusLerp, time,
        # launchHeat and progress sat at their defaults, so the
        # accelerator never reached progress 1f and isCoreBuilt
        # (Accelerator.java:153-154, `return progress >= 1f;`)
        # never passed. N2191 is the updateTile advance: a pure
        # advance over the frame (heat/statusLerp/launchHeat
        # lerpDelta toward their targets, time advances by
        # Time.delta * efficiency when idle and slerps toward 0
        # when launching, progress advances by Time.delta *
        # efficiency / buildDuration and clamps at 1f), wired
        # into the N2183 driver after the consumption fold --
        # Building.update() calls updateConsumption() then
        # updateTile() (BuildingComp.java:2274-2278), and the
        # gate `if(enabled || !block.noUpdateDisabled){`
        # passes even when disabled because noUpdateDisabled
        # defaults false (Block.java:170) and Accelerator never
        # sets it. super.updateTile() is empty
        # (BuildingComp.java:2010-2012), so the advance is the
        # whole tick. buildDuration is the class field 120f
        # (Accelerator.java:52), not overridden by the
        # interplanetary-accelerator def. launching defaults
        # false (Java boolean default); only beginLaunch sets
        # it true (Accelerator.java:334-337) and only endLaunch
        # (Accelerator.java:392-394) and the launch Time.runTask
        # (Accelerator.java:277) set it false again -- the
        # launch sequence waits for its own slice, but the flag
        # must exist as frame state so the lerps pick the right
        # target. Time.delta in the port is seconds * 60
        # via game_source_delta (arc Time.java:26, the
        # N2093/N2189 precedent); the conduit file passing raw
        # delta into source_lerp_delta is a pre-existing
        # deviation, not a precedent to follow. The
        # lerpDelta/slerpDelta formulas
        # come from Arc Mathf.java, not from guessing:
        # lerpDelta is lerp(from, to, clamp(progress *
        # Time.delta)) (Mathf.java:430-432) and slerpDelta is
        # slerp(from, to, clamp(progress * Time.delta))
        # (Mathf.java:460-462), where slerp is the angle lerp in
        # degrees with wrap (Mathf.java:455-458) and clamp is
        # [0, 1] (Mathf.java:402-404). Five new result symbols:
        # the five advanced values.
        self.assertEqual(
            ledger['N2191']['source_symbols'],
            [
                'source_accelerator_update_tile_advance_state_result.heat',
                'source_accelerator_update_tile_advance_state_result.status_lerp',
                'source_accelerator_update_tile_advance_state_result.time',
                'source_accelerator_update_tile_advance_state_result.launch_heat',
                'source_accelerator_update_tile_advance_state_result.progress',
            ],
        )
        for name in ledger['N2191']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/campaign/Accelerator.java')
                self.assertEqual(symbol['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_update_tile_advance_state')
        self.assertEqual(ledger['N2191']['runtime_proof'], '/root/C07AcceleratorUpdateTileProof')
        self.assertEqual(
            ledger['N2191']['tests'],
            [
                'test_c07_accelerator_update_tile_registration',
                'test_all_c07_accelerator_update_tile_input_evidence_is_exact',
                'test_accelerator_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_accelerator_update_tile',
            ],
        )
        self.assertTrue(ledger['N2191']['deferred_exprs'])

    def test_all_c07_accelerator_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2191']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/Accelerator.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The lerpDelta/slerpDelta formulas live in Arc, not
        # Mindustry: Mathf.java under arc-upstream.
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        for expr in ledger['N2191']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_accelerator_update_tile_advance_state(self):
        accelerator = ACCELERATOR_STATE.read_text(encoding='utf-8')
        # The pure updateTile advance lives on the accelerator
        # build state: AcceleratorBuild.updateTile()
        # (Accelerator.java:127-146) lerps heat toward
        # launching ? 1f : efficiency and statusLerp toward
        # power.status (Accelerator.java:131-132), advances time
        # by Time.delta * efficiency when idle and slerps it
        # toward 0 when launching (Accelerator.java:134-138),
        # lerps launchHeat toward launching ? 1f : 0f
        # (Accelerator.java:140), and advances progress by
        # Time.delta * efficiency / buildDuration, clamped at
        # 1f, when efficiency >= 0 (Accelerator.java:142-145).
        # super.updateTile() is empty (BuildingComp.java:2010-
        # 2012), so the advance is the whole tick; Building.
        # update() runs updateConsumption() before updateTile()
        # (BuildingComp.java:2274-2278), and the gate
        # `if(enabled || !block.noUpdateDisabled){` passes
        # even when disabled because noUpdateDisabled defaults
        # false (Block.java:170) and Accelerator never sets it
        # -- so the driver advances every tick, after the
        # consumption fold. buildDuration is the class field
        # 120f (Accelerator.java:52), not overridden by the
        # interplanetary-accelerator def. launching defaults
        # false; only beginLaunch sets it true
        # (Accelerator.java:334-337, `this.launching = true;`)
        # and only endLaunch (Accelerator.java:392-394) and the
        # launch Time.runTask (Accelerator.java:277) set it
        # false again -- the launch sequence waits for its own
        # slice, but the flag exists as frame state so the
        # lerps pick the right target. progress() returns the
        # progress (Accelerator.java:149-150) and isCoreBuilt()
        # is progress >= 1f (Accelerator.java:153-154); the
        # accessor + serialization wait for their own slice,
        # but the advance is what lets progress reach 1f.
        # The formulas come from Arc Mathf.java, not from
        # guessing: lerp is fromValue + (toValue - fromValue)
        # * progress (Mathf.java:425-427), lerpDelta is lerp
        # (from, to, clamp(progress * Time.delta))
        # (Mathf.java:430-432), slerp is the angle lerp in
        # degrees with wrap (Mathf.java:455-458), slerpDelta
        # is slerp(from, to, clamp(progress * Time.delta))
        # (Mathf.java:460-462), and clamp is [0, 1]
        # (Mathf.java:402-404). GDScript fmod matches Java %
        # (sign of the dividend), so the slerp
        # transliteration is exact. Time.delta in the port is
        # seconds * 60 via game_source_delta (arc Time.java:26).
        self.assertIn('public class Accelerator extends Block{', accelerator)
        self.assertIn('public float buildDuration = 120f;', accelerator)
        self.assertIn('public class AcceleratorBuild extends Building implements LaunchAnimator{', accelerator)
        self.assertIn('public float heat, statusLerp;', accelerator)
        self.assertIn('public float progress;', accelerator)
        self.assertIn('public float time, launchHeat;', accelerator)
        self.assertIn('public boolean launching;', accelerator)
        self.assertIn('public float launchTime;', accelerator)
        self.assertIn('public void updateTile(){', accelerator)
        self.assertIn('super.updateTile();', accelerator)
        self.assertIn('heat = Mathf.lerpDelta(heat, launching ? 1f : efficiency, 0.05f);', accelerator)
        self.assertIn('statusLerp = Mathf.lerpDelta(statusLerp, power.status, 0.05f);', accelerator)
        self.assertIn('if(!launching){', accelerator)
        self.assertIn('time += Time.delta * efficiency;', accelerator)
        self.assertIn('time = Mathf.slerpDelta(time, 0f, 0.4f);', accelerator)
        self.assertIn('launchHeat = Mathf.lerpDelta(launchHeat, launching ? 1f : 0f, 0.1f);', accelerator)
        self.assertIn('if(efficiency >= 0f){', accelerator)
        self.assertIn('progress += Time.delta * efficiency / buildDuration;', accelerator)
        self.assertIn('progress = Math.min(progress, 1f);', accelerator)
        self.assertIn('public float progress(){', accelerator)
        self.assertIn('return progress;', accelerator)
        self.assertIn('public boolean isCoreBuilt(){', accelerator)
        self.assertIn('return progress >= 1f;', accelerator)
        self.assertIn('public void beginLaunch(boolean launching){', accelerator)
        self.assertIn('this.launching = true;', accelerator)
        self.assertIn('launching = false;', accelerator)
        self.assertIn('updateConsumption();', accelerator)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', accelerator)
        self.assertIn('updateTile();', accelerator)
        self.assertIn('public boolean noUpdateDisabled = false;', accelerator)
        self.assertIn('public static float lerp(float fromValue, float toValue, float progress){', accelerator)
        self.assertIn('return fromValue + (toValue - fromValue) * progress;', accelerator)
        self.assertIn('public static float lerpDelta(float fromValue, float toValue, float progress){', accelerator)
        self.assertIn('return lerp(fromValue, toValue, clamp(progress * Time.delta));', accelerator)
        self.assertIn('public static float slerp(float fromDegrees, float toDegrees, float progress){', accelerator)
        self.assertIn('float delta = ((toDegrees - fromDegrees + 360 + 180) % 360) - 180;', accelerator)
        self.assertIn('return (fromDegrees + delta * progress + 360) % 360;', accelerator)
        self.assertIn('public static float slerpDelta(float fromDegrees, float toDegrees, float progress){', accelerator)
        self.assertIn('return slerp(fromDegrees, toDegrees, clamp(progress * Time.delta));', accelerator)
        self.assertIn('public static float clamp(float value){', accelerator)
        self.assertIn('return Math.max(Math.min(value, 1f), 0f);', accelerator)
        # The pure advance is wired into the driver: the driver
        # calls it every tick after the consumption fold and
        # writes the five advanced values back onto the frame.
        # The launching flag is frame state (read by the
        # advance, default false); the launch sequence that
        # sets it true waits for its own slice.
        self.assertIn('static func source_accelerator_update_tile_advance_state(frame: Dictionary, source_delta: float) -> Dictionary:', accelerator)
        self.assertIn('static func source_mathf_slerp_delta(', accelerator)
        self.assertIn('source_lerp_delta', accelerator)
        self.assertIn('const SOURCE_ACCELERATOR_BUILD_DURATION := 120.0', accelerator)
        self.assertIn('source_accelerator_update_tile_advance_state(frame, source_placed_block_state.game_source_delta(game, seconds))', accelerator)
        self.assertIn('frame["heat"]', accelerator)
        self.assertIn('frame["status_lerp"]', accelerator)
        self.assertIn('frame["time"]', accelerator)
        self.assertIn('frame["launch_heat"]', accelerator)
        self.assertIn('frame["progress"]', accelerator)
        self.assertIn('frame.get("launching", false)', accelerator)
        self.assertIn('frame.get("efficiency", 0.0)', accelerator)
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_accelerator_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_accelerator_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure advance (heat /
        # statusLerp / launchHeat lerpDelta toward the right
        # target, time advance when idle and slerp when
        # launching, progress advance + clamp at 1) plus the
        # live tick (the driver advances the frame and the
        # N2183 power.status fold still holds: efficiency folds
        # the power min, zero at no power). There are no launch
        # / battery keys: the launch sequence (beginLaunch /
        # endLaunch / buildConfiguration, Accelerator.java:258-
        # 291, 334-394) and the canLaunch battery gate
        # (Accelerator.java:239-240) wait for their own slices;
        # the launching branch of the advance is proven pure
        # (with launching=true in the frame), not live, because
        # nothing in the port sets the flag yet.
        proof = ACCELERATOR_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof checks (the N2185 lesson: the proof is
        # written but NOT run on this VM, so the test pins what
        # it can statically): every preload in the proof must
        # point at a file that exists, and the scene must load
        # this proof script.
        for preload in re.findall(r'preload\("(res://[^"]+)"\)', proof):
            with self.subTest(preload=preload):
                self.assertTrue((ROOT / 'godot-mindustry' / preload[len('res://'):]).is_file(), preload)
        scene = ACCELERATOR_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07AcceleratorUpdateTileProof.gd', scene)

    def test_reference_graph_and_actual_c07_accelerator_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07AcceleratorUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ACCELERATOR_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
