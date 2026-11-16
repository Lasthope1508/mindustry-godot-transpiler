import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LAUNCH_PAD_STATE = ROOT / 'godot-mindustry/src/game/SourceLaunchPadBuildState.gd'
LAUNCH_PAD_SENSE_PROGRESS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadSenseProgressProof.gd'


class C07LaunchPadSenseProgressTests(unittest.TestCase):
    def test_c07_launch_pad_sense_progress_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2206']['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_sense_state')
        # LaunchPadBuild overrides sense for LAccess.progress
        # (LaunchPad.java:98, `public double sense(LAccess
        # sensor){` with `if(sensor == LAccess.progress)
        # return Mathf.clamp(launchCounter / launchTime);`,
        # LaunchPad.java:99) over the launch counter
        # (LaunchPad.java:84, `public float launchCounter;`),
        # which the updateTile advance alone writes
        # (LaunchPad.java:146, `if((launchCounter += edelta())
        # >= launchTime && items.total() >= itemCapacity){`).
        # A logic processor reading `progress` on a launch pad
        # currently gets NaN/null: the BuildingComp sense
        # switch has NO progress case (BuildingComp.java:2093,
        # `public double sense(LAccess sensor){` + 2123,
        # `default -> Float.NaN; //gets converted to null in
        # logic`), while Java returns the clamped launch
        # fraction. N2206 closes that gap with one pure
        # function over one frame key (`launch_counter`, float)
        # plus the per-def launchTime parameter, following the
        # N2205 shouldConsume precedent exactly: the pure
        # function takes (frame, sensor, launch_time) -- the
        # sensor parameter because sense is a logic read over
        # an enum, not a tick write -- and returns the generic
        # laccess wire shape (`sense_value` +
        # `sense_value_is_nan`, SourceBlockSenseState
        # .laccess_state) plus an explicit `handled` flag, so
        # a caller can tell "handled, value is a clamped
        # fraction" from "not handled -- fall through to
        # super.sense" (LaunchPad.java:100, `return
        # super.sense(sensor);`). The per-def launchTime
        # differs (launch-pad 1200f = 60f * 20,
        # Blocks.java:6794; advanced-launch-pad 1800f = 60f *
        # 30, Blocks.java:6804; class default 1f,
        # LaunchPad.java:32), and the catalog carries no
        # launchTime property, so the caller selects it by
        # block id (SOURCE_LAUNCH_PAD_LAUNCH_TIMES) and passes
        # it in. RED decisions (pinned by this slice): (1)
        # sensor spelling is "progress" -- LAccess.java:28
        # lists `progress,`, and the generic sense layer
        # matches sensor strings by enum name ("health",
        # "maxHealth", "color", ...). (2) An absent
        # `launch_counter` key reads 0.0, NOT NaN: `public
        # float launchCounter;` defaults to 0.0f at Java init,
        # so a freshly built pad senses clamp(0 /
        # launchTime) = 0.0 -- the only observable Java
        # behavior at init -- and returning 0.0 regresses
        # nothing, because no consumer reads this value yet
        # (the sense-dispatch hook does not exist); absent ->
        # NaN would preserve the port's current UNFAITHFUL
        # output instead. The N2205 absent-means-"no
        # observation yet" precedent does not apply here:
        # there, absent -> false would zero efficiency for
        # every live pad (a live regression); here, absent ->
        # 0.0 IS the Java init value. (3) The clamp edge:
        # counter at/above launchTime senses 1.0 (a full pad
        # waiting for items), counter 0 senses 0.0, a
        # negative counter (impossible in Java -- the counter
        # only grows and resets to 0) floors to 0.0 anyway.
        # One new result symbol: the sensed value itself.
        self.assertEqual(
            ledger['N2206']['source_symbols'],
            [
                'source_launch_pad_sense_state_result.sense_value',
            ],
        )
        for name in ledger['N2206']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/logic/LAccess.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_launch_pad_sense_state_result.sense_value': 'SourceLaunchPadBuildState.source_launch_pad_sense_state',
                }[name])
        self.assertEqual(ledger['N2206']['runtime_proof'], '/root/C07LaunchPadSenseProgressProof')
        self.assertEqual(
            ledger['N2206']['tests'],
            [
                'test_c07_launch_pad_sense_progress_registration',
                'test_all_c07_launch_pad_sense_progress_input_evidence_is_exact',
                'test_launch_pad_sense_progress_state',
                'test_reference_graph_and_actual_c07_launch_pad_sense_progress',
            ],
        )
        self.assertTrue(ledger['N2206']['deferred_exprs'])

    def test_all_c07_launch_pad_sense_progress_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2206']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_launch_pad_sense_state_result.sense_value': 'SourceLaunchPadBuildState.source_launch_pad_sense_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/logic/LAccess.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2206']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_launch_pad_sense_progress_state(self):
        launch_pad = LAUNCH_PAD_STATE.read_text(encoding='utf-8')
        # The pure sense override lives on the launch-pad build
        # state next to the N2205 shouldConsume gate:
        # LaunchPadBuild overrides sense (LaunchPad.java:98,
        # `public double sense(LAccess sensor){` with
        # `if(sensor == LAccess.progress) return
        # Mathf.clamp(launchCounter / launchTime);`,
        # LaunchPad.java:99) over the launch counter
        # (LaunchPad.java:84, `public float launchCounter;`),
        # which the updateTile advance alone writes
        # (LaunchPad.java:146, `if((launchCounter += edelta())
        # >= launchTime && items.total() >= itemCapacity){`).
        # Non-progress sensors fall through to super.sense
        # (LaunchPad.java:100, `return super.sense(sensor);`),
        # and the BuildingComp super switch has NO progress
        # case (BuildingComp.java:2093, `public double
        # sense(LAccess sensor){` + 2123, `default ->
        # Float.NaN; //gets converted to null in logic`), so a
        # logic read of `progress` on a launch pad currently
        # returns NaN/null while Java returns the clamped
        # fraction. Do NOT confuse sense with progress():
        # `public float progress(){` + `return 0f;`
        # (BuildingComp.java:617-619) is a DIFFERENT method the
        # sense switch never calls. The sensor enum value is
        # `progress,` (LAccess.java:28). The same expression
        # drives the progress bar (LaunchPad.java:70,
        # `Mathf.clamp(build.launchCounter / launchTime)`).
        # Mathf.clamp one-arg clamps to [0, 1]; the GDScript
        # spelling is clampf(value, 0.0, 1.0) -- the
        # SourceShockwaveTowerBuildState.gd:306 precedent. The
        # per-def launchTime is 1200f for launch-pad
        # (Blocks.java:6794, `launchTime = 60f * 20;`, with
        # `size = 3;` and `itemCapacity = 100;`) and 1800f for
        # advanced-launch-pad (Blocks.java:6804, `launchTime =
        # 60f * 30;`, with `size = 4;` and `itemCapacity =
        # 100;`), overriding the class default `public float
        # launchTime = 1f;` (LaunchPad.java:32). Sense is a
        # logic read, not a tick write: NO driver tick line
        # belongs here (the N2203 damage() precedent -- the
        # proof calls the pure function directly with
        # synthetic frames); the logic-processor integration --
        # how a logic `sense progress` read on a placed launch
        # pad reaches this family function -- is its own later
        # slice. Do NOT extend the generic
        # SourceBlockSenseState.laccess_state: it is the
        # Block-level sense (Block.java:1651-1664), takes no
        # frame/launch-counter input, and adding family state
        # there would break its generic shape.
        self.assertIn('static func source_launch_pad_sense_state(frame: Dictionary, sensor: String, launch_time: float)', launch_pad)
        # The sense cases, pinned as the pure function's
        # decision structure: the frame carries the live counter
        # as `launch_counter` (float, stamped by the future
        # updateTile advance); the function reads it with a null
        # default, and an ABSENT key reads 0.0 -- the Java init
        # default (`public float launchCounter;` defaults to
        # 0.0f), so a freshly built pad senses 0.0, NOT NaN.
        # launch_counter=600.0 with launch_time=1200.0 senses
        # 0.5; launch_counter=1200.0 (at launchTime) senses 1.0;
        # launch_counter=1500.0 (above launchTime, full pad
        # waiting for items) clamps to 1.0; sensor "health"
        # falls through (handled false, sense_value null,
        # sense_value_is_nan true); advanced-launch-pad
        # launch_counter=900.0 with launch_time=1800.0 senses
        # 0.5 -- all progress cases run through the one
        # expression, `clampf(counter / launch_time, 0.0, 1.0)`.
        self.assertIn('frame.get("launch_counter", null)', launch_pad)
        with self.subTest(case='launch_counter=600.0 below launchTime senses 0.5'):
            self.assertIn('clampf(counter / launch_time, 0.0, 1.0)', launch_pad)
        with self.subTest(case='launch_counter=1200.0 at launchTime senses 1.0'):
            self.assertIn('clampf(counter / launch_time, 0.0, 1.0)', launch_pad)
        with self.subTest(case='launch_counter=1500.0 above launchTime clamps to 1.0'):
            self.assertIn('clampf(counter / launch_time, 0.0, 1.0)', launch_pad)
        with self.subTest(case='no launch_counter key senses 0.0 (Java init)'):
            self.assertIn('0.0 if observed == null else float(observed)', launch_pad)
        with self.subTest(case='non-progress sensor falls through to super.sense'):
            self.assertIn('return {"handled": false, "sense_value": null, "sense_value_is_nan": true}', launch_pad)
        with self.subTest(case='progress sensor returns handled true with the clamped fraction'):
            self.assertIn('return {"handled": true, "sense_value": fraction, "sense_value_is_nan": false}', launch_pad)
        with self.subTest(case='sensor string is the LAccess enum name'):
            self.assertIn('sensor == "progress"', launch_pad)
        self.assertIn('public double sense(LAccess sensor){', launch_pad)
        self.assertIn('if(sensor == LAccess.progress) return Mathf.clamp(launchCounter / launchTime);', launch_pad)
        self.assertIn('return super.sense(sensor);', launch_pad)
        self.assertIn('default -> Float.NaN; //gets converted to null in logic', launch_pad)
        self.assertIn('public float launchCounter;', launch_pad)
        self.assertIn('public float launchTime = 1f;', launch_pad)
        self.assertIn('launchTime = 60f * 20;', launch_pad)
        self.assertIn('launchTime = 60f * 30;', launch_pad)
        self.assertIn('public class LaunchPad extends Block{', launch_pad)
        self.assertIn('public class LaunchPadBuild extends Building{', launch_pad)
        self.assertIn('if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){', launch_pad)
        self.assertIn('public float progress(){', launch_pad)
        self.assertIn('return 0f;', launch_pad)
        self.assertIn('progress,', launch_pad)
        self.assertIn('Mathf.clamp(build.launchCounter / launchTime)', launch_pad)
        self.assertIn('size = 3;', launch_pad)
        self.assertIn('size = 4;', launch_pad)
        self.assertIn('itemCapacity = 100;', launch_pad)
        self.assertIn('source_launch_pad_sense_state(frame, sensor, launch_time)', launch_pad)
        self.assertIn('static func source_launch_pad_tick_buildings_state', launch_pad)
        # The proof's keys drive the pure sense function
        # (fraction below launchTime / 1.0 at launchTime /
        # clamp above launchTime / 0.0 with no counter key /
        # fall-through for a non-progress sensor / per-def
        # advanced-pad fraction). There are no driver-tick /
        # updateTile / liquid keys: sense is a logic read, not
        # a tick write (the N2203 precedent), the launch
        # advance (LaunchPad.java:143-161) and the advanced oil
        # consumer (Blocks.java:6808) wait for their own
        # slices, and the logic-processor dispatch hook that
        # routes a placed pad's `sense progress` read to this
        # function is its own later slice.
        proof = LAUNCH_PAD_SENSE_PROGRESS_PROOF.read_text(encoding='utf-8')
        for key in [
            'sense_progress_below_launch_time',
            'sense_progress_at_launch_time',
            'sense_progress_above_launch_time',
            'sense_progress_absent_counter_zero',
            'sense_fall_through_non_progress',
            'sense_progress_advanced_pad',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_launch_pad_sense_progress(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaunchPadSenseProgressProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LAUNCH_PAD_SENSE_PROGRESS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sense_progress_below_launch_time',
            'sense_progress_at_launch_time',
            'sense_progress_above_launch_time',
            'sense_progress_absent_counter_zero',
            'sense_fall_through_non_progress',
            'sense_progress_advanced_pad',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
