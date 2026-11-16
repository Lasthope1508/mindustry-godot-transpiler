import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
STACK_CONVEYOR_STATE = ROOT / 'godot-mindustry/src/game/SourceStackConveyorBuildState.gd'
STACK_CONVEYOR_BLANDS_PLAN_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackConveyorBlendsPlanRowsProof.gd'
STACK_CONVEYOR_BLANDS_PLAN_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackConveyorBlendsPlanRowsProof.tscn'


class C07StackConveyorBlendsPlanRowsTests(unittest.TestCase):
    def test_c07_stack_conveyor_blends_plan_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2448']['godot_owner'], 'SourceStackConveyorBuildState.source_stack_conveyor_blends_state')
        # The StackConveyor tick is live (N2180 power.status
        # row + N2239 updateTile advance) and the draw
        # rows are live (N2434 draw / drawCached) but
        # NOTHING modeled the autotiler rows:
        # blends() (StackConveyor.java:71-88),
        # drawPlanRegion() (:90-104) and
        # rotatedOutput() (:106-112). N2448 ports
        # them as THREE pure-only pures (no tick
        # wiring): the blends pure takes every
        # geometry / indexer predicate
        # caller-supplied (the N2435 precedent) and
        # returns {blends}; the plan pure takes the
        # getTiling bits caller-supplied (getTiling
        # itself is a CALL record, NOT ported) and
        # returns {base_call, edge_calls}; the
        # rotated-output pure takes the other build
        # state + the super call caller-supplied and
        # returns {rotated_output}. Four new result
        # symbols: blends 1 + plan 2 + rotated 1.
        self.assertEqual(
            ledger['N2448']['source_symbols'],
            [
                'source_stack_conveyor_blends_state_result.blends',
                'source_stack_conveyor_draw_plan_state_result.base_call',
                'source_stack_conveyor_draw_plan_state_result.edge_calls',
                'source_stack_conveyor_rotated_output_state_result.rotated_output',
            ],
        )
        expected_sources = {
            'source_stack_conveyor_blends_state_result.blends': 'core/src/mindustry/world/blocks/distribution/StackConveyor.java',
            'source_stack_conveyor_draw_plan_state_result.base_call': 'core/src/mindustry/world/blocks/distribution/StackConveyor.java',
            'source_stack_conveyor_draw_plan_state_result.edge_calls': 'core/src/mindustry/world/blocks/distribution/StackConveyor.java',
            'source_stack_conveyor_rotated_output_state_result.rotated_output': 'core/src/mindustry/world/blocks/distribution/StackConveyor.java',
        }
        for name in ledger['N2448']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceStackConveyorBuildState.source_stack_conveyor_'))
        self.assertEqual(ledger['N2448']['runtime_proof'], '/root/C07StackConveyorBlendsPlanRowsProof')
        self.assertEqual(
            ledger['N2448']['tests'],
            [
                'test_c07_stack_conveyor_blends_plan_rows_registration',
                'test_all_c07_stack_conveyor_blends_plan_rows_input_evidence_is_exact',
                'test_stack_conveyor_blends_plan_rows_state',
                'test_reference_graph_and_actual_c07_stack_conveyor_blends_plan_rows',
            ],
        )
        self.assertTrue(ledger['N2448']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #58 (1-based in
        # the merged advances-28 DEFERRED base): the
        # StackConveyor blends / rotatedOutput /
        # drawPlanRegion rows entry is REMOVED --
        # blends, drawPlanRegion and rotatedOutput
        # are all live now. setStats (:64-68, Stat.
        # itemsMoved round(capacity*speed*60)) is NOT
        # in #58 and no entry covered it, so N2448
        # ADDS one new entry for it (the N2430
        # precedent). Net 258 - 1 + 1 = 258. The
        # onProximityUpdate and acceptStack entries
        # STAY.
        self.assertFalse(any(entry.startswith('StackConveyor blends / rotatedOutput / drawPlanRegion rows (') for entry in ledger['N2448']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackConveyor setStats rows (') for entry in ledger['N2448']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackConveyor onProximityUpdate state machine (') for entry in ledger['N2448']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackConveyor acceptStack / handleStack / removeStack / itemTaken / acceptItem rows (') for entry in ledger['N2448']['deferred_exprs']))
        self.assertEqual(len(ledger['N2448']['deferred_exprs']), 258)

    def test_all_c07_stack_conveyor_blends_plan_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2448']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceStackConveyorBuildState.source_stack_conveyor_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/StackConveyor.java',
            'core/src/mindustry/world/blocks/Autotiler.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2448']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_stack_conveyor_blends_plan_rows_state(self):
        stack_conveyor = STACK_CONVEYOR_STATE.read_text(encoding='utf-8')
        # The blends rows (StackConveyor.blends(),
        # StackConveyor.java:71-88): the tile build
        # is a StackConveyorBuild with stateLoad (1)
        # -> otherblock.outputsItems() &&
        # lookingAtEither(...); stateUnload (2) &&
        # !outputRouter -> the router-mode gate
        # (acceptsItems && the noSideBlend /
        # lookingAtEither half && the notLookingAt
        # / facing half && NOT the other build
        # unloading && NOT the other build moving
        # away); anything else (not a stack build,
        # stateMove, or unload with outputRouter)
        # falls through to outputsItems() &&
        # blendsArmored(...) && instanceof
        # StackConveyor. The state constants are
        # stateMove 0 / stateLoad 1 / stateUnload 2
        # (StackConveyor.java:25) -- the brief
        # mislabels stateLoad as 0, Java wins.
        # The plan rows (drawPlanRegion(),
        # StackConveyor.java:90-104): bits =
        # getTiling(plan, list), null -> return;
        # regions[0] at plan.rotation * 90, then
        # the edge loop over bits[3] with
        # (plan.rotation - i) * 90. getTiling is a
        # CALL record -- the bits ride
        # caller-supplied, getTiling itself is NOT
        # ported. The rotated-output rows
        # (rotatedOutput(), StackConveyor.
        # java:106-112): a StackConveyorBuild tile
        # returns s.state != stateUnload, else the
        # super call (Block.java:615-617, return
        # rotate; -- StackConveyor sets rotate =
        # true, but the pure takes the super value
        # caller-supplied). setStats (:64-68) is
        # NOT ported here -- it gets its own
        # DEFERRED entry. Pure-only: the tick
        # never calls blends / drawPlanRegion /
        # rotatedOutput. Keep each Java expr on ONE
        # comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_stack_conveyor_blends_state', stack_conveyor)
        self.assertIn('static func source_stack_conveyor_draw_plan_state', stack_conveyor)
        self.assertIn('static func source_stack_conveyor_rotated_output_state', stack_conveyor)
        self.assertIn('public class StackConveyor extends Block implements Autotiler{', stack_conveyor)
        self.assertIn('protected static final int stateMove = 0, stateLoad = 1, stateUnload = 2;', stack_conveyor)
        self.assertIn('public @Load(value = "@-#", length = 3) TextureRegion[] regions;', stack_conveyor)
        self.assertIn('public @Load("@-edge") TextureRegion edgeRegion;', stack_conveyor)
        self.assertIn('public boolean outputRouter = true;', stack_conveyor)
        self.assertIn('public boolean blends(Tile tile, int rotation, int otherx, int othery, int otherrot, Block otherblock){', stack_conveyor)
        self.assertIn('if(tile.build instanceof StackConveyorBuild b){', stack_conveyor)
        self.assertIn('int state = b.state;', stack_conveyor)
        self.assertIn('if(state == stateLoad){ //standard conveyor mode', stack_conveyor)
        self.assertIn('return otherblock.outputsItems() && lookingAtEither(tile, rotation, otherx, othery, otherrot, otherblock);', stack_conveyor)
        self.assertIn('}else if(state == stateUnload && !outputRouter){ //router mode', stack_conveyor)
        self.assertIn('return otherblock.acceptsItems &&', stack_conveyor)
        self.assertIn('(!otherblock.noSideBlend || lookingAtEither(tile, rotation, otherx, othery, otherrot, otherblock)) &&', stack_conveyor)
        self.assertIn('(notLookingAt(tile, rotation, otherx, othery, otherrot, otherblock) ||', stack_conveyor)
        self.assertIn('(otherblock instanceof StackConveyor && facing(otherx, othery, otherrot, tile.x, tile.y))) &&', stack_conveyor)
        self.assertIn('!(world.build(otherx, othery) instanceof StackConveyorBuild s && s.state == stateUnload) &&', stack_conveyor)
        self.assertIn('!(world.build(otherx, othery) instanceof StackConveyorBuild s2 && s2.state == stateMove &&', stack_conveyor)
        self.assertIn('!facing(otherx, othery, otherrot, tile.x, tile.y));', stack_conveyor)
        self.assertIn('return otherblock.outputsItems() && blendsArmored(tile, rotation, otherx, othery, otherrot, otherblock) && otherblock instanceof StackConveyor;', stack_conveyor)
        self.assertIn('public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){', stack_conveyor)
        self.assertIn('int[] bits = getTiling(plan, list);', stack_conveyor)
        self.assertIn('if(bits == null) return;', stack_conveyor)
        self.assertIn('TextureRegion region = regions[0];', stack_conveyor)
        self.assertIn('Draw.rect(region, plan.drawx(), plan.drawy(), plan.rotation * 90);', stack_conveyor)
        self.assertIn('for(int i = 0; i < 4; i++){', stack_conveyor)
        self.assertIn('if((bits[3] & (1 << i)) == 0){', stack_conveyor)
        self.assertIn('Draw.rect(edgeRegion, plan.drawx(), plan.drawy(), (plan.rotation - i) * 90);', stack_conveyor)
        self.assertIn('public boolean rotatedOutput(int x, int y){', stack_conveyor)
        self.assertIn('Building tile = world.build(x, y);', stack_conveyor)
        self.assertIn('if(tile instanceof StackConveyorBuild s){', stack_conveyor)
        self.assertIn('return s.state != stateUnload;', stack_conveyor)
        self.assertIn('return super.rotatedOutput(x, y);', stack_conveyor)
        self.assertIn('public class StackConveyorBuild extends Building{', stack_conveyor)
        self.assertIn('default @Nullable int[] getTiling(BuildPlan plan, Eachable<BuildPlan> list){', stack_conveyor)
        self.assertIn('default boolean facing(int x, int y, int rotation, int x2, int y2){', stack_conveyor)
        self.assertIn('default boolean blendsArmored(Tile tile, int rotation, int otherx, int othery, int otherrot, Block otherblock){', stack_conveyor)
        self.assertIn('default boolean notLookingAt(Tile tile, int rotation, int otherx, int othery, int otherrot, Block otherblock){', stack_conveyor)
        self.assertIn('default boolean lookingAtEither(Tile tile, int rotation, int otherx, int othery, int otherrot, Block otherblock){', stack_conveyor)
        self.assertIn('return rotate;', stack_conveyor)
        self.assertIn('public boolean acceptsItems = false;', stack_conveyor)
        self.assertIn('public boolean noSideBlend = false;', stack_conveyor)
        self.assertIn('public boolean outputsItems(){', stack_conveyor)
        # The documented limits record the blends /
        # plan / rotatedOutput rows as live.
        self.assertIn('Blends / plan / rotatedOutput rows live (N2448)', stack_conveyor)
        # The proof's keys drive the three pures
        # (the load branch + the router-mode gate
        # with the facing / unload / move-away
        # halves + the fallback, the plan null-bits
        # early return + the edge loop over bits[3],
        # and the rotated-output state check vs the
        # super call).
        proof = STACK_CONVEYOR_BLANDS_PLAN_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'blends_load',
            'blends_unload_router',
            'blends_fallback',
            'plan_bits_null',
            'plan_edges',
            'rotated_output',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceStackConveyorBuildState.gd")', proof)
        self.assertTrue(STACK_CONVEYOR_STATE.exists())
        self.assertTrue(STACK_CONVEYOR_BLANDS_PLAN_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07StackConveyorBlendsPlanRowsProof.gd', STACK_CONVEYOR_BLANDS_PLAN_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_stack_conveyor_blends_plan_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07StackConveyorBlendsPlanRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_STACK_CONVEYOR_BLANDS_PLAN_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'blends_load',
            'blends_unload_router',
            'blends_fallback',
            'plan_bits_null',
            'plan_edges',
            'rotated_output',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
