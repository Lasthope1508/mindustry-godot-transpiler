import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceConstructorBuildState.gd'
CONSTRUCTOR_RECIPE_CONFIG_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ConstructorRecipeConfigFillProof.gd'
CONSTRUCTOR_RECIPE_CONFIG_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ConstructorRecipeConfigFillProof.tscn'


class C07ConstructorRecipeConfigFillTests(unittest.TestCase):
    def test_c07_constructor_recipe_config_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        # N2462 is WIRING-ONLY (the N2413 precedent): NO
        # new pure, NO register, SSOT +0/+0/+0/+0. The
        # tick wires the EXISTING N2455 config pure
        # (source_constructor_config_state) into the live
        # tick, so this test pins the dependency, not a
        # new ledger entry: the N2455 config symbols are
        # registered, owned by the config pure, and the
        # driver calls the pure exactly twice -- its
        # definition plus the ONE tick call site.
        config_symbols = [
            'source_constructor_config_state_result.recipe',
            'source_constructor_config_state_result.progress_reset',
            'source_constructor_config_state_result.configure_call',
        ]
        for name in config_symbols:
            with self.subTest(symbol=name):
                self.assertIn(name, ledger['N2455']['source_symbols'])
                self.assertEqual(symbols[name]['godot_owner'], 'SourceConstructorBuildState.source_constructor_config_state')
                self.assertEqual(symbols[name]['java_source'], 'core/src/mindustry/world/blocks/payloads/Constructor.java')
        constructor = CONSTRUCTOR_STATE.read_text(encoding='utf-8')
        self.assertNotIn('static func source_constructor_recipe_config_fill_state', constructor)
        self.assertEqual(constructor.count('source_constructor_config_state('), 2)
        # This slice RESOLVES DEFERRED #95 (1-based in
        # the merged 246 file, DEFERRED-after-advances-30):
        # the Constructor live recipe config fill entry.
        # The merged DEFERRED list lives outside the repo
        # (the coordinator removes #95 by TEXT at
        # integration); the entry is pinned here from the
        # advances-30 base snapshot so the resolution
        # target is exact.
        self.assertTrue(any(entry.startswith('Constructor live recipe config fill (') for entry in ledger['N2461']['deferred_exprs']))

    def test_all_c07_constructor_recipe_config_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        constructor_java = (ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/payloads/Constructor.java').read_text(encoding='utf-8')
        # The wiring reuses the N2455 config pure, so its
        # registered evidence is re-verified verbatim.
        for name in ledger['N2455']['source_symbols']:
            if not name.startswith('source_constructor_config_state_result.'):
                continue
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], constructor_java)
        # The config transition, by Java line number
        # (Constructor.java:31-38, verified first):
        # configClear :31/:38, config(Block) :32-37, the
        # progress reset :33 BEFORE the canProduce gate
        # :34, the recipe set :35.
        constructor_lines = constructor_java.splitlines()
        self.assertEqual(constructor_lines[30].strip(), 'configClear((ConstructorBuild tile) -> tile.recipe = null);')
        self.assertEqual(constructor_lines[31].strip(), 'config(Block.class, (ConstructorBuild tile, Block block) -> {')
        self.assertEqual(constructor_lines[32].strip(), 'if(tile.recipe != block) tile.progress = 0f;')
        self.assertEqual(constructor_lines[33].strip(), 'if(canProduce(block)){')
        self.assertEqual(constructor_lines[34].strip(), 'tile.recipe = block;')
        self.assertEqual(constructor_lines[37].strip(), 'configClear((ConstructorBuild tile) -> tile.recipe = null);')
        # The driver quotes the same exprs (the N2148
        # lesson: each on ONE comment line).
        constructor = CONSTRUCTOR_STATE.read_text(encoding='utf-8')
        self.assertIn('configClear((ConstructorBuild tile) -> tile.recipe = null);', constructor)
        self.assertIn('config(Block.class, (ConstructorBuild tile, Block block) -> {', constructor)
        self.assertIn('if(tile.recipe != block) tile.progress = 0f;', constructor)
        self.assertIn('if(canProduce(block)){', constructor)
        self.assertIn('tile.recipe = block;', constructor)

    def test_constructor_recipe_config_fill_state(self):
        constructor = CONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The live recipe config fill (N2462, DEFERRED
        # #95): the input handler's pending config action
        # arrives on the frame as frame["recipe_config"] =
        # {action: "set" / "clear" / "none", block: the
        # family recipe fixture {"block": <catalog id>} or
        # null, can_produce: the caller-supplied verdict
        # of source_constructor_can_produce_state} (the
        # N2449 discriminated-action precedent); an absent
        # key is action "none" (no-op). The tick applies
        # the EXISTING N2455 config pure and stamps
        # frame["recipe"] + frame["progress"] BEFORE the
        # recipe resolution, the shouldConsume gate and
        # the consumption fold -- Java order: config is an
        # input-handler event, applied before the tick's
        # consumption fold, so the gate sees the new recipe
        # the same tick. The pure returns progress_reset,
        # not a progress value: the wiring writes 0.0 only
        # when the pure says reset. "clear" never resets,
        # and a set of the SAME block resets nothing, so
        # re-applying the frame input every tick is
        # harmless -- the input does NOT need to be
        # consumed. No new pure, no register (the N2413
        # wiring-only precedent).
        config_call = 'source_constructor_config_state(config_action, recipe_config.get("block", null), frame.get("recipe", null), bool(recipe_config.get("can_produce", false)))'
        recipe_stamp = 'frame["recipe"] = config_result.get("recipe", frame.get("recipe", null))'
        progress_guard = 'if bool(config_result.get("progress_reset", false)):'
        progress_stamp = 'frame["progress"] = 0.0'
        recipe_resolution = '# The recipe resolution (N2265) is hoisted above the'
        gate_call = 'var gate: Dictionary = source_constructor_should_consume_state(frame)'
        advance_call = 'var advanced: Dictionary = source_constructor_update_tile_advance_state(frame, source_delta, time_scale, build_speed, recipe_build_time, dynamic_stacks, rotdeg_value, float(block.properties.get("size", 3)), front, false)'
        self.assertIn('frame.get("recipe_config", null) is Dictionary', constructor)
        self.assertIn('recipe_config.get("action", "none")', constructor)
        self.assertIn(config_call, constructor)
        self.assertIn(recipe_stamp, constructor)
        self.assertIn(progress_guard, constructor)
        self.assertIn(progress_stamp, constructor)
        self.assertIn('re-applying the frame input every tick is harmless', constructor)
        # Order pins: the wiring lands BEFORE the recipe
        # resolution (so the dynamic stacks + buildTime
        # read the NEW recipe), the shouldConsume gate
        # and the updateTile advance.
        self.assertLess(constructor.index(config_call), constructor.index(recipe_resolution))
        self.assertLess(constructor.index(recipe_stamp), constructor.index(gate_call))
        self.assertLess(constructor.index(progress_stamp), constructor.index(gate_call))
        self.assertLess(constructor.index(config_call), constructor.index(advance_call))
        # The progress stamp is guarded by the pure's
        # progress_reset verdict (the guard line comes
        # immediately before the stamp).
        self.assertLess(constructor.index(progress_guard), constructor.index(progress_stamp))
        # The docstrings no longer describe the live
        # recipe fill as waiting -- it is live since
        # N2462 (the N2413/N2454 docstring discipline).
        self.assertIn('live since N2462', constructor)
        self.assertNotIn('the live recipe fill still waits', constructor)
        self.assertNotIn('no live fill sets frame["recipe"] yet', constructor)
        self.assertNotIn('the live recipe fill (frame["recipe"]) still waits (DEFERRED #99)', constructor)
        # The proof's keys drive the live tick (a
        # constructor with a seeded recipe_config gaining
        # a recipe, resetting progress, clearing, the
        # no-op, idempotency, and the gate opening the
        # same tick).
        self.assertTrue(CONSTRUCTOR_RECIPE_CONFIG_FILL_PROOF.exists())
        self.assertTrue(CONSTRUCTOR_RECIPE_CONFIG_FILL_PROOF_SCENE.exists())
        proof = CONSTRUCTOR_RECIPE_CONFIG_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'fill_set_stamps',
            'fill_set_resets_progress',
            'fill_clear',
            'fill_none',
            'fill_idempotent',
            'fill_gate_opens',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceConstructorBuildState.gd")', proof)
        self.assertTrue(CONSTRUCTOR_STATE.exists())
        self.assertIn('C07ConstructorRecipeConfigFillProof.gd', CONSTRUCTOR_RECIPE_CONFIG_FILL_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_constructor_recipe_config_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ConstructorRecipeConfigFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_CONSTRUCTOR_RECIPE_CONFIG_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'fill_set_stamps',
            'fill_set_resets_progress',
            'fill_clear',
            'fill_none',
            'fill_idempotent',
            'fill_gate_opens',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
