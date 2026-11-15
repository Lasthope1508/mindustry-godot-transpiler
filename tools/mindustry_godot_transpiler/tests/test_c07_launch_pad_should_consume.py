import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LAUNCH_PAD_STATE = ROOT / 'godot-mindustry/src/game/SourceLaunchPadBuildState.gd'
LAUNCH_PAD_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadShouldConsumeProof.gd'
LAUNCH_PAD_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadShouldConsumeProof.tscn'


class C07LaunchPadShouldConsumeTests(unittest.TestCase):
    def test_c07_launch_pad_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2186']['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_should_consume_state')
        # N2172 wired the launch pad's live power.status read but
        # left its shouldConsume gate deferred: LaunchPadBuild HAS
        # a shouldConsume override (LaunchPad.java:92-95, `return
        # launchCounter < launchTime;`) -- the gate needs
        # launchCounter state the tick did not track yet, so the
        # machinery ran with should_consume=true when enabled
        # (the MendProjector suppression precedent). That is now
        # wrong in the other direction: once launchCounter fills,
        # Java efficiency is 0 (BuildingComp.java:1960, `boolean
        # update = shouldConsume() && productionValid();`, with
        # BuildingComp.java:1992-1994, `if(!update){` /
        # `efficiency = optionalEfficiency = 0f;`) while the port
        # still reads power.status 1.0. N2186 wires the gate: the
        # tick tracks launchCounter as frame state, advances it
        # by edelta each tick (the counter half of the updateTile
        # launch gate, LaunchPad.java:146, `if((launchCounter +=
        # edelta()) >= launchTime && items.total() >=
        # itemCapacity){`), stamps the per-def launchTime from
        # the block id (the catalog carries no launchTime:
        # launch-pad `launchTime = 60f * 20;`, Blocks.java:6794;
        # advanced-launch-pad `launchTime = 60f * 30;`,
        # Blocks.java:6804; class default `public float
        # launchTime = 1f;`, LaunchPad.java:32), and the driver
        # ANDs enabled with the pure gate
        # (source_launch_pad_should_consume_state, the
        # adjacent-factory should_consume_state precedent) --
        # the pure function is the override exactly, with NO
        # enabled check (the WallCrafter precedent: enabled is
        # handled separately by updateConsumption,
        # BuildingComp.java:1954-1957, the disabled early
        # return). The launch fire itself (consume() +
        # LaunchPayload + Fx.launchPod + items.clear +
        # `launchCounter = 0f;`, LaunchPad.java:147-159) still
        # waits for its own slice, so a full pad never launches
        # and its counter freezes at launchTime with the gate
        # closed. Two new result symbols: the gate verdict and
        # the counter it read.
        self.assertEqual(
            ledger['N2186']['source_symbols'],
            [
                'source_launch_pad_should_consume_state_result.should_consume',
                'source_launch_pad_should_consume_state_result.launch_counter',
            ],
        )
        for name in ledger['N2186']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_launch_pad_should_consume_state_result.should_consume': 'SourceLaunchPadBuildState.source_launch_pad_should_consume_state',
                    'source_launch_pad_should_consume_state_result.launch_counter': 'SourceLaunchPadBuildState.source_launch_pad_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2186']['runtime_proof'], '/root/C07LaunchPadShouldConsumeProof')
        self.assertEqual(
            ledger['N2186']['tests'],
            [
                'test_c07_launch_pad_should_consume_registration',
                'test_all_c07_launch_pad_should_consume_input_evidence_is_exact',
                'test_launch_pad_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_launch_pad_should_consume',
            ],
        )
        self.assertTrue(ledger['N2186']['deferred_exprs'])

    def test_all_c07_launch_pad_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2186']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_launch_pad_should_consume_state_result.should_consume': 'SourceLaunchPadBuildState.source_launch_pad_should_consume_state',
                    'source_launch_pad_should_consume_state_result.launch_counter': 'SourceLaunchPadBuildState.source_launch_pad_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2186']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_launch_pad_should_consume_gate_state(self):
        launch_pad = LAUNCH_PAD_STATE.read_text(encoding='utf-8')
        # The pure gate is LaunchPadBuild.shouldConsume()
        # exactly (LaunchPad.java:92, `public boolean
        # shouldConsume(){` with `return launchCounter <
        # launchTime;`, LaunchPad.java:94): the pad consumes
        # only while its launchCounter (LaunchPad.java:84,
        # `public float launchCounter;`, default 0f) is below
        # launchTime (LaunchPad.java:32, `public float
        # launchTime = 1f;`, the class default; per-def
        # `launchTime = 60f * 20;`, Blocks.java:6794, and
        # `launchTime = 60f * 30;`, Blocks.java:6804). The
        # override has NO enabled check -- enabled is handled
        # separately by updateConsumption (BuildingComp.
        # java:1954-1957, the disabled early return) and by
        # the driver gate, the WallCrafter precedent -- so
        # the pure function reads only the counter and the
        # threshold, and the driver ANDs enabled (the
        # BuildingComp default, BuildingComp.java:755-757,
        # `return enabled;`). When the gate is false,
        # updateConsumption folds efficiency to 0
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();`, with
        # BuildingComp.java:1992-1994, `if(!update){` /
        # `efficiency = optionalEfficiency = 0f;`).
        # The counter advance is the counter half of the
        # updateTile launch gate (LaunchPad.java:146, keep on
        # ONE comment line, the N2148 shootWarmup lesson: a
        # split line fails this test): updateConsumption runs
        # first (BuildingComp.java:2274,
        # `updateConsumption();`), then updateTile
        # (BuildingComp.java:2277, `updateTile();`, only
        # `if(enabled || !block.noUpdateDisabled){`,
        # BuildingComp.java:2276; Block.noUpdateDisabled
        # defaults false, Block.java:170), so the counter
        # advances by the freshly folded efficiency times the
        # tick's seconds -- edelta() is `return efficiency *
        # delta();` (BuildingComp.java:1927-1929) with delta()
        # `return Time.delta * timeScale;`
        # (BuildingComp.java:1922-1924) and timeScale default
        # 1f (BuildingComp.java:98). The launch fire itself
        # (consume() + LaunchPayload + Fx.launchPod +
        # items.clear + `launchCounter = 0f;`,
        # LaunchPad.java:147-159) waits for its own slice.
        self.assertIn('static func source_launch_pad_should_consume_state', launch_pad)
        self.assertIn('return launchCounter < launchTime;', launch_pad)
        self.assertIn('public boolean shouldConsume(){', launch_pad)
        self.assertIn('public float launchCounter;', launch_pad)
        self.assertIn('public float launchTime = 1f;', launch_pad)
        self.assertIn('launchTime = 60f * 20;', launch_pad)
        self.assertIn('launchTime = 60f * 30;', launch_pad)
        self.assertIn('if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){', launch_pad)
        self.assertIn('launchCounter = 0f;', launch_pad)
        self.assertIn('return efficiency * delta();', launch_pad)
        self.assertIn('return Time.delta * timeScale;', launch_pad)
        self.assertIn('boolean update = shouldConsume() && productionValid();', launch_pad)
        self.assertIn('if(!update){', launch_pad)
        self.assertIn('efficiency = optionalEfficiency = 0f;', launch_pad)
        self.assertIn('return enabled;', launch_pad)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', launch_pad)
        self.assertIn('updateConsumption();', launch_pad)
        self.assertIn('updateTile();', launch_pad)
        # The driver reads the gate through the pure function
        # (the adjacent-factory precedent) instead of the old
        # `should_consume = enabled` line, stamps the per-def
        # launchTime from the block id (the catalog carries no
        # launchTime), and advances the counter by the folded
        # efficiency times the tick's Time.delta (seconds * 60
        # via game_source_delta, arc Time.java:26).
        self.assertIn('source_launch_pad_should_consume_state(frame)', launch_pad)
        self.assertIn('frame["launch_counter"]', launch_pad)
        self.assertIn('frame["launch_time"]', launch_pad)
        self.assertIn('block_id == "launch-pad"', launch_pad)
        self.assertIn('block_id == "advanced-launch-pad"', launch_pad)
        self.assertIn('+ float(frame.get("efficiency", 0.0)) * source_placed_block_state.game_source_delta(game, seconds)', launch_pad)
        # The old driver line (should_consume = enabled alone, the
        # whole line including its line end -- the new line starts
        # the same way but ANDs the gate) is gone.
        self.assertNotIn('\n\t\t\tvar should_consume: bool = bool(frame.get("enabled", true))\n', launch_pad)
        # The proof's keys drive the pure gate (open below
        # launchTime, closed at and above it) plus the live
        # tick (counter advances by edelta, efficiency 0 when
        # the gate is closed, old behavior kept when the gate
        # is open). There are no launch/payload keys: the
        # launch fire (LaunchPad.java:147-159) waits for its
        # own slice, so the counter freeze at launchTime is
        # what the closed-gate key proves. The proof preloads
        # the family state file, which must exist, and its
        # scene must point at the proof script.
        proof = LAUNCH_PAD_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_open_below_launch_time',
            'gate_closed_at_launch_time',
            'gate_closed_above_launch_time',
            'counter_advances_by_edelta',
            'efficiency_zero_when_gate_closed',
            'efficiency_kept_when_gate_open',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceLaunchPadBuildState.gd")', proof)
        self.assertIn('write_proof("C07LaunchPadShouldConsumeProof"', proof)
        self.assertTrue(LAUNCH_PAD_STATE.is_file())
        scene = LAUNCH_PAD_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07LaunchPadShouldConsumeProof.gd', scene)
        self.assertIn('[node name="C07LaunchPadShouldConsumeProof" type="Node"]', scene)

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
            'gate_open_below_launch_time',
            'gate_closed_at_launch_time',
            'gate_closed_above_launch_time',
            'counter_advances_by_edelta',
            'efficiency_zero_when_gate_closed',
            'efficiency_kept_when_gate_open',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
