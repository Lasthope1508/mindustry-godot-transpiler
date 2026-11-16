import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LAUNCH_PAD_STATE = ROOT / 'godot-mindustry/src/game/SourceLaunchPadBuildState.gd'
LAUNCH_PAD_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadShouldConsumeProof.gd'


class C07LaunchPadShouldConsumeTests(unittest.TestCase):
    def test_c07_launch_pad_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2205']['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_should_consume_state')
        # N2172 folded power-only for the launch pad: a pure
        # power row over the stamped frame value, folded by the
        # shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) in its own driver. But
        # LaunchPadBuild DOES override shouldConsume:
        # `return launchCounter < launchTime;`
        # (LaunchPad.java:94), and updateConsumption forces
        # efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992-1993,
        # `if(!update){` / `efficiency = optionalEfficiency =
        # 0f;`). N2172 deferred the gate with a documented limit
        # (the PointDefenseTurret N2151 precedent): the port
        # tracked no live launch counter on any placed-building
        # frame, so with a full counter power.status reads 1.0
        # while Java efficiency is 0 -- the observable gap is
        # efficiency 1.0 vs 0.0 once the counter is full. N2205
        # closes that gap with one pure function over one frame
        # key (`launch_counter`, float) plus the per-def
        # launchTime parameter: the gate is the same expression
        # over the observed counter, `launchCounter <
        # launchTime`, read as `float(launch_counter) <
        # launch_time and enabled`. The per-def launchTime
        # differs (launch-pad 1200f = 60f * 20, Blocks.java:6794;
        # advanced-launch-pad 1800f = 60f * 30, Blocks.java:6804;
        # class default 1f, LaunchPad.java:32), and the catalog
        # carries no launchTime property, so the driver selects
        # it by block id (SOURCE_LAUNCH_PAD_LAUNCH_TIMES) and
        # passes it in -- the pure function takes
        # (frame, launch_time), it does not read a frame key for
        # the threshold. RED decision (pinned by this slice, the
        # proof's fourth key -- the N2191 `targets_count`
        # precedent): when the frame carries NO `launch_counter`
        # key, preserve the N2172 behavior (`should_consume =
        # enabled`) -- null means "no observation yet", not
        # "fully launched", because the future updateTile advance
        # stamps `launch_counter` only after the first launch
        # gate consult each tick, and defaulting absent to false
        # would zero efficiency for every live launch pad
        # before its first advance tick, a live regression
        # against N2172 GREEN. It also matches the Java init:
        # `public float launchCounter;` (LaunchPad.java:84)
        # defaults to 0.0f, always < launchTime, so at Java
        # init the gate is true when enabled. One new result
        # symbol: the gate itself.
        self.assertEqual(
            ledger['N2205']['source_symbols'],
            [
                'source_launch_pad_should_consume_state_result.should_consume',
            ],
        )
        for name in ledger['N2205']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_launch_pad_should_consume_state_result.should_consume': 'SourceLaunchPadBuildState.source_launch_pad_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2205']['runtime_proof'], '/root/C07LaunchPadShouldConsumeProof')
        self.assertEqual(
            ledger['N2205']['tests'],
            [
                'test_c07_launch_pad_should_consume_registration',
                'test_all_c07_launch_pad_should_consume_input_evidence_is_exact',
                'test_launch_pad_should_consume_state',
                'test_reference_graph_and_actual_c07_launch_pad_should_consume',
            ],
        )
        self.assertTrue(ledger['N2205']['deferred_exprs'])

    def test_all_c07_launch_pad_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2205']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_launch_pad_should_consume_state_result.should_consume': 'SourceLaunchPadBuildState.source_launch_pad_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2205']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_launch_pad_should_consume_state(self):
        launch_pad = LAUNCH_PAD_STATE.read_text(encoding='utf-8')
        # The pure shouldConsume gate lives on the launch-pad
        # build state: LaunchPadBuild overrides shouldConsume
        # (LaunchPad.java:92, `public boolean shouldConsume(){`
        # with `return launchCounter < launchTime;`,
        # LaunchPad.java:94) over the launch counter
        # (LaunchPad.java:84, `public float launchCounter;`),
        # which the updateTile advance alone writes
        # (LaunchPad.java:146, `if((launchCounter += edelta())
        # >= launchTime && items.total() >= itemCapacity){`),
        # and updateConsumption forces efficiency to zero when
        # the gate is false (BuildingComp.java:1960, `boolean
        # update = shouldConsume() && productionValid();` +
        # 1992, `if(!update){` + 1993, `efficiency =
        # optionalEfficiency = 0f;`). The gate matters because
        # with a full counter Java efficiency is 0 while the
        # port folds power-only and reports 1.0 -- the N2172
        # gap this slice closes once the frame carries the
        # observed counter. A missing power stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus =
        # !enabled ? 0f : power == null ? 1f : power.status;`),
        # and the power consumer counts toward hasConsumers
        # (Block.java:1449, `hasConsumers = consumers.length >
        # 0;`); edelta() is efficiency * delta
        # (BuildingComp.java:1928, `return efficiency *
        # delta();`). The launch pad's power draw is STATIC, not
        # conditional: `consumePower(4f);` (Blocks.java:6797)
        # and `consumePower(8f);` (Blocks.java:6809) register
        # plain ConsumePower rows, so the row read is the plain
        # one (ConsumePower.java:39, `return build.power.status;`)
        # -- no RepairTurret-style ConsumePowerCondition
        # adaptation. The gate reads the counter the updateTile
        # advance last stamped, so the driver calls the pure
        # gate BEFORE the consumption setup (the Java order,
        # updateConsumption :2274 reads shouldConsume() at
        # :1960). The per-def launchTime is 1200f for
        # launch-pad (Blocks.java:6794, `launchTime = 60f *
        # 20;`, with `size = 3;` and `itemCapacity = 100;`)
        # and 1800f for advanced-launch-pad (Blocks.java:6804,
        # `launchTime = 60f * 30;`, with `size = 4;` and
        # `itemCapacity = 100;`), overriding the class default
        # `public float launchTime = 1f;` (LaunchPad.java:32),
        # so the gate threshold the counter runs against is
        # per-def, not a single hardcoded constant.
        self.assertIn('static func source_launch_pad_should_consume_state(frame: Dictionary, launch_time: float)', launch_pad)
        # The gate cases, pinned as the pure function's
        # decision structure: the frame carries the live counter
        # as `launch_counter` (float, stamped by the future
        # updateTile advance); the function reads it with a null
        # default, so an absent key means "no observation yet",
        # not "fully launched". launch_counter=10.0 (< 1200f)
        # with enabled passes the gate (should_consume true);
        # launch_counter=1200.0 (at launchTime, not <
        # launchTime) blocks it (should_consume false);
        # launch_counter=10.0 with enabled=false blocks it
        # (should_consume false); advanced-launch-pad
        # launch_counter=1500.0 (< 1800f) passes the gate even
        # though 1500.0 is past the launch-pad threshold --
        # all observed cases run through the one conjunction,
        # `float(observed) < launch_time and enabled`; NO
        # launch_counter key preserves the N2172 behavior,
        # `should_consume = enabled`.
        self.assertIn('frame.get("launch_counter", null)', launch_pad)
        with self.subTest(case='launch_counter=10.0 below launchTime passes the gate'):
            self.assertIn('float(observed) < launch_time and enabled', launch_pad)
        with self.subTest(case='launch_counter=1200.0 at launchTime blocks the gate'):
            self.assertIn('float(observed) < launch_time and enabled', launch_pad)
        with self.subTest(case='launch_counter=10.0 with enabled=false blocks the gate'):
            self.assertIn('float(observed) < launch_time and enabled', launch_pad)
        with self.subTest(case='advanced launch_counter=1500.0 below 1800f passes the gate'):
            self.assertIn('float(observed) < launch_time and enabled', launch_pad)
        with self.subTest(case='no launch_counter key preserves N2172 behavior'):
            self.assertIn('return {"should_consume": enabled}', launch_pad)
        self.assertIn('public boolean shouldConsume(){', launch_pad)
        self.assertIn('return launchCounter < launchTime;', launch_pad)
        self.assertIn('public float launchCounter;', launch_pad)
        self.assertIn('public float launchTime = 1f;', launch_pad)
        self.assertIn('launchTime = 60f * 20;', launch_pad)
        self.assertIn('launchTime = 60f * 30;', launch_pad)
        self.assertIn('public class LaunchPad extends Block{', launch_pad)
        self.assertIn('public class LaunchPadBuild extends Building{', launch_pad)
        self.assertIn('if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){', launch_pad)
        self.assertIn('if(sensor == LAccess.progress) return Mathf.clamp(launchCounter / launchTime);', launch_pad)
        self.assertIn('boolean update = shouldConsume() && productionValid();', launch_pad)
        self.assertIn('if(!update){', launch_pad)
        self.assertIn('efficiency = optionalEfficiency = 0f;', launch_pad)
        self.assertIn('return efficiency * delta();', launch_pad)
        self.assertIn('return build.power.status;', launch_pad)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', launch_pad)
        self.assertIn('hasConsumers = consumers.length > 0;', launch_pad)
        self.assertIn('consumePower(4f);', launch_pad)
        self.assertIn('consumePower(8f);', launch_pad)
        self.assertIn('size = 3;', launch_pad)
        self.assertIn('size = 4;', launch_pad)
        self.assertIn('itemCapacity = 100;', launch_pad)
        self.assertIn('return enabled;', launch_pad)
        self.assertIn('source_launch_pad_should_consume_state(frame, launch_time)', launch_pad)
        self.assertIn('static func source_launch_pad_tick_buildings_state', launch_pad)
        # The proof's keys drive the pure gate (passes below
        # launchTime / blocks at launchTime / blocks when
        # disabled / absent key preserves the power fold) plus
        # the live tick (the gate overrides the power fold when
        # fully charged / passes below launchTime at half
        # power). There are no updateTile / sense / liquid keys:
        # the launch advance (LaunchPad.java:143-161), the sense
        # (LAccess.progress) (:98-101) and the advanced
        # oil consumer (Blocks.java:6808) wait for their own
        # slices, and the future updateTile slice owns the live
        # stamping of `launch_counter`.
        proof = LAUNCH_PAD_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_passes_below_launch_time',
            'gate_blocks_at_launch_time',
            'gate_blocks_when_disabled',
            'gate_absent_preserves_power_fold',
            'gate_blocks_when_fully_charged',
            'gate_passes_below_launch_time_live',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_launch_pad_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaunchPadShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LAUNCH_PAD_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_passes_below_launch_time',
            'gate_blocks_at_launch_time',
            'gate_blocks_when_disabled',
            'gate_absent_preserves_power_fold',
            'gate_blocks_when_fully_charged',
            'gate_passes_below_launch_time_live',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
