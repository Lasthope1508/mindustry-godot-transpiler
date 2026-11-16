import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_OFFLOAD_EFFECTS_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillOffloadEffectsRowsProof.gd'
BURST_DRILL_OFFLOAD_EFFECTS_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillOffloadEffectsRowsProof.tscn'


class C07BurstDrillOffloadEffectsRowsTests(unittest.TestCase):
    def test_c07_burst_drill_offload_effects_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2469']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_offload_effects_state')
        # The BurstDrill updateTile STATE is live
        # (N2219 advance + N2282 timerDump dump): the
        # progress / warmup / timeDrilled /
        # lastDrillSpeed / smoothProgress / invertTime
        # advance and the offload itself (:76-125) run
        # every tick, and the timerDump dump (:83-84)
        # runs before the advance -- but the offload
        # effects rows were never modeled. N2469 ports
        # them as ONE pure-only pure (the N2468
        # precedent, NO tick wiring):
        # source_burst_drill_offload_effects_state(
        # cycle_complete, was_visible, x, y, pitch_roll,
        # effect_roll_x, effect_roll_y,
        # dominant_item_color) returns shake_call
        # {intensity 2.0, duration 2.0} +
        # drill_sound_call {sound "drillImpact", x, y,
        # pitch 1f + pitch_roll, volume 0.6f} +
        # drill_effect_call {effect "Fx.shockwave",
        # x + effect_roll_x, y + effect_roll_y, color
        # dominant_item_color}, all null unless the
        # cycle-complete + wasVisible gate fires. NO
        # sound is played, NO effect spawned, NO camera
        # shaken -- the audio/effect call sites wait
        # for their own slices. The pitch roll
        # (Mathf.range(0.1f)) and the two effect
        # position rolls (Mathf.range(drillEffectRnd))
        # are ALREADY-ROLLED caller-supplied inputs --
        # NO RNG in the pure (the N2421 precedent).
        # The class defaults are what the pure records
        # (shake 2f, drillEffect Fx.shockwave): both
        # defs override shake = 4f (Blocks.java:3077/
        # :3106) and drillEffect to a MultiEffect
        # (:3076 / :3100-3105), so the per-def rows
        # wait for their own slice (the N2304 per-def
        # precedent); drillEffectRnd stays 0f for both
        # defs (BurstDrill.java:41, no def override),
        # so the effect spawns at (x, y) exactly.
        # Three new result symbols, in Java updateTile
        # order: the shake (:115), then the sound
        # (:116), then the effect (:117).
        self.assertEqual(
            ledger['N2469']['source_symbols'],
            [
                'source_burst_drill_offload_effects_state_result.shake_call',
                'source_burst_drill_offload_effects_state_result.drill_sound_call',
                'source_burst_drill_offload_effects_state_result.drill_effect_call',
            ],
        )
        for name in ledger['N2469']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/BurstDrill.java')
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_offload_effects_state')
        self.assertEqual(ledger['N2469']['runtime_proof'], '/root/C07BurstDrillOffloadEffectsRowsProof')
        self.assertEqual(
            ledger['N2469']['tests'],
            [
                'test_c07_burst_drill_offload_effects_rows_registration',
                'test_all_c07_burst_drill_offload_effects_rows_input_evidence_is_exact',
                'test_burst_drill_offload_effects_rows_state',
                'test_reference_graph_and_actual_c07_burst_drill_offload_effects_rows',
            ],
        )
        self.assertTrue(ledger['N2469']['deferred_exprs'])
        # This slice ports ONLY the FX half of
        # DEFERRED #91 (1-based in
        # DEFERRED-after-advances-31.py): the entry is
        # REWRITTEN IN PLACE (the N2459 precedent) to
        # record the effects live since N2469 + the
        # neighbor routing still waiting -- the
        # DEFERRED count does NOT decrease for this
        # slice. Net 238 - 0 = 238.
        rewritten = [entry for entry in ledger['N2469']['deferred_exprs'] if entry.startswith('BurstDrill updateTile offload effects + offload neighbor routing (')]
        self.assertEqual(len(rewritten), 1)
        self.assertIn('live since N2469', rewritten[0])
        self.assertIn('the neighbor routing waits for its own slice', rewritten[0])
        self.assertIn('per-def shake/effect rows wait for their own slice', rewritten[0])
        self.assertEqual(len(ledger['N2469']['deferred_exprs']), 238)

    def test_all_c07_burst_drill_offload_effects_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2469']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceBurstDrillBuildState.source_burst_drill_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/content/Fx.java',
            'core/src/mindustry/entities/Effect.java',
            'core/src/mindustry/type/Item.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2469']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_offload_effects_rows_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # The updateTile offload effects rows
        # (BurstDrillBuild.updateTile(), BurstDrill.
        # java:106-118): the STATE is live since N2219
        # (the advance + the offload itself) and the
        # timerDump dump is live since N2282, so this
        # pure consumes the caller-evaluated gates
        # (cycle_complete = the :106 branch verdict,
        # was_visible = the :114 gate) and reports the
        # shake + sound + effect as pure call records
        # (the N2468 precedent -- no sound played, no
        # effect spawned, no camera shaken):
        # `if(dominantItems > 0 && progress >=
        # drillTime && items.total() < itemCapacity){`
        # + `if(wasVisible){` + `Effect.shake(shake,
        # shake, this);` + `drillSound.at(x, y, 1f +
        # Mathf.range(drillSoundPitchRand),
        # drillSoundVolume);` + `drillEffect.at(x +
        # Mathf.range(drillEffectRnd), y + Mathf.range(
        # drillEffectRnd), dominantItem.color);`. The
        # fields are the block fields (`public float
        # shake = 2f;`, BurstDrill.java:18; `public
        # Sound drillSound = Sounds.drillImpact;`,
        # :32; `public float drillSoundVolume = 0.6f,
        # drillSoundPitchRand = 0.1f;`, :33;
        # `drillEffectRnd = 0f;`, :41; `drillEffect =
        # Fx.shockwave;`, :42). The effect is
        # Fx.shockwave (`shockwave = new Effect(10f,
        # 80f, e -> {`, Fx.java:1625), fired at (x +
        # range(drillEffectRnd), y + range(
        # drillEffectRnd)) with the dominant item's
        # color (`public Color color;`, Item.java:19,
        # set in the Item constructor, :51-53 -- the
        # color comes from the item def, caller-
        # supplied, not a def lookup). The sound is
        # Sounds.drillImpact -- the Sounds class is
        # build-generated (mindustry.gen.Sounds, no
        # gen/ dir in the upstream checkout), but the
        # token is exact: the asset is core/assets/
        # sounds/block/drillImpact.ogg (the N2444
        # padLaunch precedent). The shake is Effect.
        # shake(shake, shake, this) -- the Position
        # overload (`public static void shake(float
        # intensity, float duration, Position loc){`,
        # Effect.java:210-212) delegates to (`public
        # static void shake(float intensity, float
        # duration, float x, float y){`, Effect.
        # java:201), so the first arg is the intensity
        # and the second the duration, both 2f; the
        # camera-distance falloff inside the x/y
        # overload (Effect.java:204-207) is the
        # callee's own behavior -- the pure records
        # the CALL params, not the falloff result. The
        # pitch roll (Mathf.range(0.1f), in [-0.1,
        # 0.1]) and the two effect position rolls
        # (Mathf.range(drillEffectRnd)) are ALREADY-
        # ROLLED caller-supplied inputs (Mathf.range(r)
        # is the arc uniform roll in [-r, r], `public
        # static float range(float range){` with
        # `return random(-range, range);`, arc Mathf.
        # java:220-222) -- NO RNG in the pure (the
        # N2421 precedent). drillEffectRnd stays 0f
        # for both defs (BurstDrill.java:41, no def
        # override in Blocks.java; Drill.init only
        # fills it when < 0, Drill.java:96), so the
        # effect spawns at (x, y) exactly -- but the
        # pure still takes the rolls as inputs, so the
        # formula stays Java-exact. Both defs override
        # shake = 4f (Blocks.java:3077/:3106) and
        # drillEffect to a MultiEffect (:3076 /
        # :3100-3105): the pure records the CLASS
        # defaults and the per-def rows wait for their
        # own slice (the N2304 per-def precedent).
        # Keep each Java expr on ONE comment line (the
        # N2148 lesson: a split line fails this test).
        self.assertIn('static func source_burst_drill_offload_effects_state', burst_drill)
        self.assertIn('if(dominantItems > 0 && progress >= drillTime && items.total() < itemCapacity){', burst_drill)
        self.assertIn('if(wasVisible){', burst_drill)
        self.assertIn('Effect.shake(shake, shake, this);', burst_drill)
        self.assertIn('drillSound.at(x, y, 1f + Mathf.range(drillSoundPitchRand), drillSoundVolume);', burst_drill)
        self.assertIn('drillEffect.at(x + Mathf.range(drillEffectRnd), y + Mathf.range(drillEffectRnd), dominantItem.color);', burst_drill)
        self.assertIn('public float shake = 2f;', burst_drill)
        self.assertIn('public Sound drillSound = Sounds.drillImpact;', burst_drill)
        self.assertIn('public float drillSoundVolume = 0.6f, drillSoundPitchRand = 0.1f;', burst_drill)
        self.assertIn('drillEffectRnd = 0f;', burst_drill)
        self.assertIn('drillEffect = Fx.shockwave;', burst_drill)
        self.assertIn('shockwave = new Effect(10f, 80f, e -> {', burst_drill)
        self.assertIn('public static void shake(float intensity, float duration, Position loc){', burst_drill)
        self.assertIn('public static void shake(float intensity, float duration, float x, float y){', burst_drill)
        self.assertIn('public Color color;', burst_drill)
        self.assertIn('drillEffect = new MultiEffect(Fx.mineImpact, Fx.drillSteam, Fx.mineImpactWave.wrap(Pal.redLight, 40f));', burst_drill)
        self.assertIn('drillEffect = new MultiEffect(', burst_drill)
        self.assertIn('shake = 4f;', burst_drill)
        self.assertIn('public static float range(float range){', burst_drill)
        self.assertIn('return random(-range, range);', burst_drill)
        # The documented limits record the offload
        # effects rows as live.
        self.assertIn('updateTile offload effects rows live (N2469)', burst_drill)
        # The proof's keys drive the effects pure (the
        # fire + the two gates + pitch + position +
        # color).
        proof = BURST_DRILL_OFFLOAD_EFFECTS_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'effects_fire',
            'effects_gate_cycle',
            'effects_gate_visible',
            'effects_pitch',
            'effects_position',
            'effects_color',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceBurstDrillBuildState.gd")', proof)
        self.assertTrue(BURST_DRILL_STATE.exists())
        self.assertTrue(BURST_DRILL_OFFLOAD_EFFECTS_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07BurstDrillOffloadEffectsRowsProof.gd', BURST_DRILL_OFFLOAD_EFFECTS_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_burst_drill_offload_effects_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillOffloadEffectsRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_OFFLOAD_EFFECTS_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'effects_fire',
            'effects_gate_cycle',
            'effects_gate_visible',
            'effects_pitch',
            'effects_position',
            'effects_color',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
