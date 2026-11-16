import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LAUNCH_PAD_STATE = ROOT / 'godot-mindustry/src/game/SourceLaunchPadBuildState.gd'
LAUNCH_PAD_POD_RESULT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadPodResultProof.gd'
LAUNCH_PAD_POD_RESULT_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadPodResultProof.tscn'


class C07LaunchPadPodResultTests(unittest.TestCase):
    def test_c07_launch_pad_pod_result_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2397']['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_launch_pod_state')
        # The launch fire is ALREADY LIVE since N2238 (the
        # full-and-timed gate, the stacks copy,
        # items.clear(), the launchCounter = 0f reset,
        # exposing launched + launched_stacks) -- the
        # DEFERRED #161 premise ("the launch fire itself
        # waits") is STALE, so N2397 does NOT re-implement
        # the fire. What N2397 adds is the pod descriptor
        # as a separate pure result (the N2234 spawned_unit
        # precedent): source_launch_pad_launch_pod_state(
        # launched, launched_stacks, team_id, x, y) returns
        # the pod {stacks, lifetime 120f, team, x, y} when
        # launched, null otherwise. NO live entity is
        # created -- the port has no live entity spawn path.
        # consume() (LaunchPad.java:148) is a no-op for a
        # LaunchPad (verified: the pad has NO item consumer
        # -- only consumePower, Blocks.java:6797/6809, plus
        # the advanced def's consumeLiquid oil, Blocks.
        # java:6808 -- and neither ConsumePower nor
        # ConsumeLiquid overrides trigger; only ConsumeItems
        # / ConsumeItemDynamic remove anything, and the
        # Consume default trigger is empty, Consume.
        # java:50), so the pure owes consume() nothing.
        # Sound/FX (launchSound / Fx.launchPod /
        # Effect.shake, LaunchPad.java:149/156/158) stay
        # deferred -- presentation, not state. Two new
        # result symbols: the pod descriptor and the
        # launched gate echo.
        self.assertEqual(
            ledger['N2397']['source_symbols'],
            [
                'source_launch_pad_launch_pod_state_result.pod',
                'source_launch_pad_launch_pod_state_result.launched',
            ],
        )
        for name in ledger['N2397']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/campaign/LaunchPad.java')
                self.assertEqual(symbol['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_launch_pod_state')
        self.assertEqual(ledger['N2397']['runtime_proof'], '/root/C07LaunchPadPodResultProof')
        self.assertEqual(
            ledger['N2397']['tests'],
            [
                'test_c07_launch_pad_pod_result_registration',
                'test_all_c07_launch_pad_pod_result_input_evidence_is_exact',
                'test_launch_pad_pod_result_state',
                'test_reference_graph_and_actual_c07_launch_pad_pod_result',
            ],
        )
        self.assertTrue(ledger['N2397']['deferred_exprs'])
        # DEFERRED #161 is REWRITTEN IN PLACE, NOT
        # resolved: the new text says the fire is live
        # since N2238, the pod descriptor is live since
        # N2397, and only launchSound / Fx.launchPod /
        # Effect.shake remain. Count stays 301 (the
        # merged advances-21 base).
        rewritten = [entry for entry in ledger['N2397']['deferred_exprs'] if entry.startswith('LaunchPad updateTile launch fire (')]
        self.assertEqual(len(rewritten), 1)
        self.assertIn('the fire is LIVE since N2238', rewritten[0])
        self.assertIn('the pod descriptor is LIVE since N2397', rewritten[0])
        self.assertIn('only launchSound / Fx.launchPod / Effect.shake remain', rewritten[0])
        self.assertFalse(any('the launch fire itself (consume() + pod + clear + reset' in entry for entry in ledger['N2397']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LaunchPad advanced variant (') for entry in ledger['N2397']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LaunchPad draw / drawLiquid / icons rows (') for entry in ledger['N2397']['deferred_exprs']))
        self.assertEqual(len(ledger['N2397']['deferred_exprs']), 301)

    def test_all_c07_launch_pad_pod_result_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2397']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_launch_pod_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
            'core/src/mindustry/world/consumers/Consume.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2397']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_launch_pad_pod_result_state(self):
        launch_pad = LAUNCH_PAD_STATE.read_text(encoding='utf-8')
        # The pod descriptor (LaunchPadBuild.updateTile(),
        # LaunchPad.java:147-159): the fire itself is live
        # since N2238 (the gate, the stacks copy,
        # items.clear(), the launchCounter = 0f reset),
        # and the pod is the LaunchPayload entity creation
        # reported as a pure result (the N2234 spawned_unit
        # precedent -- no live entity is created):
        # `LaunchPayload entity = LaunchPayload.create();`
        # + `items.each((item, amount) -> entity.stacks.add(
        # new ItemStack(item, amount)));` + `entity.set(
        # this);` + `entity.lifetime(120f);` + `entity.team(
        # team);` + `entity.add();`. The pod stacks are the
        # N2238 launched_stacks (the items.each copy, zero
        # amounts skipped like ItemModule.each); the
        # lifetime is the 120f literal; team + x/y are the
        # pad's team and world position (entity.set(this)
        # positions the pod at the pad, entity.team(team)
        # stamps the pad's team). consume() (:148) is a
        # no-op for a LaunchPad: the pad has NO item
        # consumer, and the Consume default trigger is
        # empty (`public void trigger(Building build){}`,
        # Consume.java:50) -- only ConsumeItems /
        # ConsumeItemDynamic override it. Sound/FX
        # (launchSound / Fx.launchPod / Effect.shake,
        # :149/156/158) stay deferred. Keep each Java
        # expr on ONE comment line (the N2148 lesson: a
        # split line fails this test).
        self.assertIn('static func source_launch_pad_launch_pod_state', launch_pad)
        self.assertIn('if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){', launch_pad)
        self.assertIn('LaunchPayload entity = LaunchPayload.create();', launch_pad)
        self.assertIn('items.each((item, amount) -> entity.stacks.add(new ItemStack(item, amount)));', launch_pad)
        self.assertIn('entity.set(this);', launch_pad)
        self.assertIn('entity.lifetime(120f);', launch_pad)
        self.assertIn('entity.team(team);', launch_pad)
        self.assertIn('entity.add();', launch_pad)
        self.assertIn('Seq<ItemStack> stacks = new Seq<>();', launch_pad)
        self.assertIn('public void trigger(Building build){}', launch_pad)
        self.assertIn('consume();', launch_pad)
        # The documented limits record the pod result as
        # live (the launch sound / effects still defer).
        self.assertIn('Launch pod result live (N2397)', launch_pad)
        # The proof's keys drive the pod pure (the null
        # pod when not launched, the stacks mirror, the
        # 120f lifetime, team + position, the stacks copy
        # isolation, plus the live frame values -- a full
        # pad launches through the N2238 advance and the
        # pod descriptor reads from the live frame).
        proof = LAUNCH_PAD_POD_RESULT_PROOF.read_text(encoding='utf-8')
        for key in [
            'pod_null_when_not_launched',
            'pod_stacks_mirror',
            'pod_lifetime',
            'pod_team_position',
            'pod_stacks_copy',
            'pod_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceLaunchPadBuildState.gd")', proof)
        self.assertTrue(LAUNCH_PAD_STATE.exists())
        self.assertTrue(LAUNCH_PAD_POD_RESULT_PROOF_SCENE.exists())
        self.assertIn('C07LaunchPadPodResultProof.gd', LAUNCH_PAD_POD_RESULT_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_launch_pad_pod_result(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaunchPadPodResultProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LAUNCH_PAD_POD_RESULT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'pod_null_when_not_launched',
            'pod_stacks_mirror',
            'pod_lifetime',
            'pod_team_position',
            'pod_stacks_copy',
            'pod_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
