import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_PER_DEF_SHAKE_EFFECT_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillPerDefShakeEffectRowsProof.gd'
BURST_DRILL_PER_DEF_SHAKE_EFFECT_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillPerDefShakeEffectRowsProof.tscn'


class C07BurstDrillPerDefShakeEffectRowsTests(unittest.TestCase):
    def test_c07_burst_drill_per_def_shake_effect_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2486']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_per_def_offload_effects_state')
        # The N2469 pure records the CLASS defaults
        # (shake 2.0, Fx.shockwave) -- but BOTH
        # BurstDrill defs override shake = 4f
        # (Blocks.java:3077/:3106) and drillEffect to
        # a MultiEffect (impact-drill Blocks.java:3076,
        # eruption-drill Blocks.java:3100-3105), so
        # the live offload shake/effect rows were
        # never the class defaults. N2486 ports them
        # as ONE pure-only per-def pure (the N2304
        # per-def precedent, NO tick wiring):
        # source_burst_drill_per_def_offload_effects_
        # state(def_id) returns {shake, drill_effect}
        # -- shake 4.0 + the def's MultiEffect
        # children as an ordered token list for
        # impact-drill / eruption-drill, and the
        # CLASS defaults (shake 2.0, ["Fx.shockwave"])
        # for an unknown def id (the N2304 fallback
        # precedent). The N2469 pure is UNCHANGED.
        # Two new result symbols: the per-def shake,
        # then the per-def drill effect.
        self.assertEqual(
            ledger['N2486']['source_symbols'],
            [
                'source_burst_drill_per_def_offload_effects_state_result.shake',
                'source_burst_drill_per_def_offload_effects_state_result.drill_effect',
            ],
        )
        for name in ledger['N2486']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/content/Blocks.java')
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_per_def_offload_effects_state')
        self.assertEqual(ledger['N2486']['runtime_proof'], '/root/C07BurstDrillPerDefShakeEffectRowsProof')
        self.assertEqual(
            ledger['N2486']['tests'],
            [
                'test_c07_burst_drill_per_def_shake_effect_rows_registration',
                'test_all_c07_burst_drill_per_def_shake_effect_rows_input_evidence_is_exact',
                'test_burst_drill_per_def_shake_effect_rows_state',
                'test_reference_graph_and_actual_c07_burst_drill_per_def_shake_effect_rows',
            ],
        )
        self.assertTrue(ledger['N2486']['deferred_exprs'])
        # This slice ports ONLY the per-def rows of
        # the BurstDrill offload entry (#89 in the
        # 234-base register list; #88 in the merged
        # 231 file -- same entry TEXT): the entry is
        # REWRITTEN IN PLACE (the N2459 precedent)
        # to record the per-def shake/effect rows
        # live since N2486 + the per-neighbour
        # remaining-capacity refinement + the
        # produced stats still waiting -- the
        # DEFERRED count does NOT decrease for this
        # slice. Net 234 - 0 = 234.
        rewritten = [entry for entry in ledger['N2486']['deferred_exprs'] if entry.startswith('BurstDrill updateTile offload effects + offload neighbor routing (')]
        self.assertEqual(len(rewritten), 1)
        self.assertIn('per-def shake/effect rows live since N2486', rewritten[0])
        self.assertIn('per-neighbour remaining-capacity refinement waits for its own slice', rewritten[0])
        self.assertIn('produced(item, 1) stats call defers', rewritten[0])
        self.assertEqual(len(ledger['N2486']['deferred_exprs']), 234)

    def test_all_c07_burst_drill_per_def_shake_effect_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2486']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceBurstDrillBuildState.source_burst_drill_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/content/Fx.java',
            'core/src/mindustry/graphics/Pal.java',
            'core/src/mindustry/content/Liquids.java',
            'core/src/mindustry/entities/effect/MultiEffect.java',
            'core/src/mindustry/entities/Effect.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2486']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_per_def_shake_effect_rows_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # The per-def offload shake/effect rows
        # (BurstDrillBuild.updateTile(), BurstDrill.
        # java:114-118, driven by the Blocks defs):
        # the N2469 pure records the CLASS defaults
        # (`public float shake = 2f;`, BurstDrill.
        # java:18; `drillEffect = Fx.shockwave;`, :42)
        # -- but BOTH defs override shake = 4f
        # (`shake = 4f;`, Blocks.java:3077/:3106) and
        # drillEffect to a MultiEffect. Impact-drill
        # (`impactDrill = new BurstDrill(
        # "impact-drill"){{`, Blocks.java:3070):
        # `drillEffect = new MultiEffect(Fx.mineImpact,
        # Fx.drillSteam, Fx.mineImpactWave.wrap(Pal.
        # redLight, 40f));` (:3076). Eruption-drill
        # (`eruptionDrill = new BurstDrill(
        # "eruption-drill"){{`, Blocks.java:3093):
        # `drillEffect = new MultiEffect(` (:3100)
        # with Fx.mineImpact, Fx.drillSteam,
        # `Fx.dynamicSpikes.wrap(Liquids.hydrogen.
        # color, 30f),` (:3103) and
        # `Fx.mineImpactWave.wrap(Liquids.hydrogen.
        # color, 45f)` (:3104). The Fx tokens are
        # exact (`mineImpact = new Effect(90, e -> {`,
        # Fx.java:2655; `drillSteam = new Effect(220f,
        # e -> {`, Fx.java:1474; `mineImpactWave = new
        # Effect(50f, e -> {`, Fx.java:2662;
        # `dynamicSpikes = new Effect(40f, 100f, e ->
        # {`, Fx.java:737). The wrap colors are
        # source-backed too (`redLight = Color.valueOf(
        # "feb380"),`, Pal.java:138; `hydrogen = new
        # Liquid("hydrogen", Color.valueOf("9eabf7")){{`,
        # Liquids.java:83). A MultiEffect fires its
        # children in order at the same x/y/rotation/
        # color (`public class MultiEffect extends
        # Effect{`, MultiEffect.java:7; `for(var effect
        # : effects){` + `effect.create(x, y,
        # rotation, color, data);`, :19-20), and the
        # wrap second arg is a ROTATION (`public
        # WrapEffect wrap(Color color, float
        # rotation){`, Effect.java:101 -- WrapEffect.
        # create passes its own rotation + color, not
        # the caller's). The shake feeds `Effect.shake(
        # shake, shake, this);` (BurstDrill.java:115).
        # drillSound / drillSoundVolume do NOT differ
        # per def (`public Sound drillSound = Sounds.
        # drillImpact;`, BurstDrill.java:32; `public
        # float drillSoundVolume = 0.6f,
        # drillSoundPitchRand = 0.1f;`, :33 -- no
        # override in either def block, Blocks.
        # java:3070-3121), so the pure returns only
        # {shake, drill_effect}. An unknown def id
        # falls back to the CLASS defaults (shake 2.0,
        # ["Fx.shockwave"]) -- the N2304 fallback
        # precedent. Pure-only: the caller (effects
        # path) reads it; the N2469 pure is unchanged.
        # Keep each Java expr on ONE comment line (the
        # N2148 lesson: a split line fails this test).
        self.assertIn('static func source_burst_drill_per_def_offload_effects_state', burst_drill)
        self.assertIn('public float shake = 2f;', burst_drill)
        self.assertIn('drillEffect = Fx.shockwave;', burst_drill)
        self.assertIn('public Sound drillSound = Sounds.drillImpact;', burst_drill)
        self.assertIn('public float drillSoundVolume = 0.6f, drillSoundPitchRand = 0.1f;', burst_drill)
        self.assertIn('impactDrill = new BurstDrill("impact-drill"){{', burst_drill)
        self.assertIn('drillEffect = new MultiEffect(Fx.mineImpact, Fx.drillSteam, Fx.mineImpactWave.wrap(Pal.redLight, 40f));', burst_drill)
        self.assertIn('shake = 4f;', burst_drill)
        self.assertIn('eruptionDrill = new BurstDrill("eruption-drill"){{', burst_drill)
        self.assertIn('drillEffect = new MultiEffect(', burst_drill)
        self.assertIn('Fx.dynamicSpikes.wrap(Liquids.hydrogen.color, 30f),', burst_drill)
        self.assertIn('Fx.mineImpactWave.wrap(Liquids.hydrogen.color, 45f)', burst_drill)
        self.assertIn('mineImpact = new Effect(90, e -> {', burst_drill)
        self.assertIn('drillSteam = new Effect(220f, e -> {', burst_drill)
        self.assertIn('mineImpactWave = new Effect(50f, e -> {', burst_drill)
        self.assertIn('dynamicSpikes = new Effect(40f, 100f, e -> {', burst_drill)
        self.assertIn('redLight = Color.valueOf("feb380"),', burst_drill)
        self.assertIn('hydrogen = new Liquid("hydrogen", Color.valueOf("9eabf7")){{', burst_drill)
        self.assertIn('public class MultiEffect extends Effect{', burst_drill)
        self.assertIn('for(var effect : effects){', burst_drill)
        self.assertIn('effect.create(x, y, rotation, color, data);', burst_drill)
        self.assertIn('public WrapEffect wrap(Color color, float rotation){', burst_drill)
        self.assertIn('Effect.shake(shake, shake, this);', burst_drill)
        # The documented limits record the per-def
        # shake/effect rows as live.
        self.assertIn('per-def shake/effect rows live (N2486)', burst_drill)
        # The proof's keys drive the per-def pure
        # (one shake + one effect row per def, the
        # class fallback, and the live def-id input).
        proof = BURST_DRILL_PER_DEF_SHAKE_EFFECT_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'shake_impact',
            'shake_eruption',
            'effect_impact',
            'effect_eruption',
            'class_fallback',
            'per_def_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceBurstDrillBuildState.gd")', proof)
        self.assertTrue(BURST_DRILL_STATE.exists())
        self.assertTrue(BURST_DRILL_PER_DEF_SHAKE_EFFECT_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07BurstDrillPerDefShakeEffectRowsProof.gd', BURST_DRILL_PER_DEF_SHAKE_EFFECT_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_burst_drill_per_def_shake_effect_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillPerDefShakeEffectRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_PER_DEF_SHAKE_EFFECT_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'shake_impact',
            'shake_eruption',
            'effect_impact',
            'effect_eruption',
            'class_fallback',
            'per_def_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
