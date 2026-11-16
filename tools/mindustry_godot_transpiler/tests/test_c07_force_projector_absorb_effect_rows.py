import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FORCE_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceForceProjectorBuildState.gd'
FORCE_PROJECTOR_ABSORB_EFFECT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ForceProjectorAbsorbEffectProof.gd'
FORCE_PROJECTOR_ABSORB_EFFECT_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ForceProjectorAbsorbEffectProof.tscn'


class C07ForceProjectorAbsorbEffectRowsTests(unittest.TestCase):
    def test_c07_force_projector_absorb_effect_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2482']['godot_owner'], 'SourceForceProjectorBuildState.source_force_projector_absorb_effect_state')
        # The absorb gate / hit / buildup are live since
        # N2423 (source_force_projector_absorb_explosion_
        # state): absorb is !broken && the explosion point
        # inside the regular polygon at the real radius,
        # hit is set to 1f only when absorb, and buildup
        # grows by damage * crashDamageMultiplier (2f)
        # only when absorb. The absorbEffect.at FX at
        # :272 deferred under its own narrow entry
        # (DEFERRED #233). N2482 ports ONLY that FX as
        # ONE pure-only pure (the N2469 precedent, NO
        # tick wiring): source_force_projector_absorb_
        # effect_state(absorb, ex, ey) returns
        # absorb_effect_call {effect "Fx.absorb", ex,
        # ey} when the caller-supplied absorb verdict is
        # true, null otherwise (the N2397 null-when-
        # absent precedent). The absorb verdict is a
        # caller-supplied input (from the N2423 pure's
        # absorb result key) -- this pure does NOT
        # recompute the polygon gate and does NOT amend
        # the N2423 pure or its proof. NO effect is
        # spawned -- the audio/effect call sites wait
        # for their own slices. The effect is Fx.absorb
        # (`public Effect absorbEffect = Fx.absorb;`,
        # ForceProjector.java:49; `absorb = new
        # Effect(12, e -> {`, Fx.java:1356) and the
        # single force-projector def does NOT override
        # it (Blocks.java:1964-1976). One new result
        # symbol: absorb_effect_call.
        self.assertEqual(
            ledger['N2482']['source_symbols'],
            [
                'source_force_projector_absorb_effect_state_result.absorb_effect_call',
            ],
        )
        for name in ledger['N2482']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/ForceProjector.java')
                self.assertEqual(symbol['godot_owner'], 'SourceForceProjectorBuildState.source_force_projector_absorb_effect_state')
        self.assertEqual(ledger['N2482']['runtime_proof'], '/root/C07ForceProjectorAbsorbEffectProof')
        self.assertEqual(
            ledger['N2482']['tests'],
            [
                'test_c07_force_projector_absorb_effect_rows_registration',
                'test_all_c07_force_projector_absorb_effect_rows_input_evidence_is_exact',
                'test_force_projector_absorb_effect_rows_state',
                'test_reference_graph_and_actual_c07_force_projector_absorb_effect_rows',
            ],
        )
        self.assertTrue(ledger['N2482']['deferred_exprs'])
        # This slice resolves DEFERRED #233 (1-based in
        # DEFERRED-after-advances-32.py, the merged 234
        # file): the absorbExplosion effect row entry is
        # gone -- while the new shieldConsumer FX entry
        # (this slice's own new deferral: the bullet-
        # path absorbEffect.at(bullet) + hitSound.at,
        # ForceProjector.java:64-65, a DIFFERENT call
        # site from the absorbExplosion :272 call) and
        # the updateTile live-fill entry stay. Net
        # 234 - 1 + 1 = 234.
        self.assertFalse(any(entry.startswith('ForceProjector absorbExplosion effect row (') for entry in ledger['N2482']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ForceProjector shieldConsumer absorb FX rows (') for entry in ledger['N2482']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ForceProjector updateTile live fill (') for entry in ledger['N2482']['deferred_exprs']))
        self.assertEqual(len(ledger['N2482']['deferred_exprs']), 234)

    def test_all_c07_force_projector_absorb_effect_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2482']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceForceProjectorBuildState.source_force_projector_absorb_effect_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ForceProjector.java',
            'core/src/mindustry/content/Fx.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2482']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_force_projector_absorb_effect_rows_state(self):
        force_projector = FORCE_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The absorbExplosion FX row (ForceBuild.
        # absorbExplosion(), ForceProjector.java:269-
        # 277): the gate / hit / buildup are live since
        # N2423, so this pure consumes the caller-
        # supplied absorb verdict (the N2423 pure's
        # absorb result key) and reports the effect as
        # a pure call record (the N2469 precedent --
        # no effect spawned): `public boolean
        # absorbExplosion(float ex, float ey, float
        # damage){` + `boolean absorb = !broken &&
        # Intersector.isInRegularPolygon(sides, x, y,
        # realRadius(), shieldRotation, ex, ey);` +
        # `if(absorb){` + `absorbEffect.at(ex, ey);`
        # + `return absorb;`. The effect is Fx.absorb
        # (`public Effect absorbEffect = Fx.absorb;`,
        # ForceProjector.java:49; `absorb = new
        # Effect(12, e -> {`, Fx.java:1356) and the
        # single def does not override it (Blocks.
        # java:1964-1976). The shieldConsumer bullet
        # path is a DIFFERENT call site (ForceProjector.
        # java:64-65): `paramBlock.hitSound.at(bullet.
        # x, bullet.y, 1f + Mathf.range(0.1f),
        # paramBlock.hitSoundVolume);` +
        # `paramBlock.absorbEffect.at(bullet);` -- it
        # defers under its own new entry, not this
        # pure. Keep each Java expr on ONE comment
        # line (the N2148 lesson: a split line fails
        # this test).
        self.assertIn('static func source_force_projector_absorb_effect_state', force_projector)
        self.assertIn('public boolean absorbExplosion(float ex, float ey, float damage){', force_projector)
        self.assertIn('boolean absorb = !broken && Intersector.isInRegularPolygon(sides, x, y, realRadius(), shieldRotation, ex, ey);', force_projector)
        self.assertIn('if(absorb){', force_projector)
        self.assertIn('absorbEffect.at(ex, ey);', force_projector)
        self.assertIn('return absorb;', force_projector)
        self.assertIn('public Effect absorbEffect = Fx.absorb;', force_projector)
        self.assertIn('absorb = new Effect(12, e -> {', force_projector)
        self.assertIn('paramBlock.hitSound.at(bullet.x, bullet.y, 1f + Mathf.range(0.1f), paramBlock.hitSoundVolume);', force_projector)
        self.assertIn('paramBlock.absorbEffect.at(bullet);', force_projector)
        # The documented limits record the absorbEffect
        # FX row as live, and the N2423 pure is
        # untouched (this slice amends neither it nor
        # its proof).
        self.assertIn('absorbEffect.at FX is live since N2482', force_projector)
        self.assertIn('static func source_force_projector_absorb_explosion_state', force_projector)
        # Pure-only: the driver NEVER calls either pure
        # from the tick -- the only call-shaped
        # occurrence of each is its definition itself
        # (docstring mentions carry no parens).
        self.assertEqual(force_projector.count('source_force_projector_absorb_effect_state('), 1)
        self.assertEqual(force_projector.count('source_force_projector_absorb_explosion_state('), 1)
        # The proof's keys drive the FX pure (the fire
        # + the null gate + the position pass-through
        # + the exact Fx.absorb token + the broken
        # shield through the live N2423 gate + the
        # live N2423 absorb verdict as the input).
        proof = FORCE_PROJECTOR_ABSORB_EFFECT_PROOF.read_text(encoding='utf-8')
        for key in [
            'fx_on_absorb',
            'fx_null_when_not_absorbed',
            'fx_position',
            'fx_token',
            'fx_broken',
            'fx_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist). Pure-only: the proof
        # never touches the live tick; the live-input keys
        # compose the N2423 pure (its absorb result key feeds
        # this pure's absorb input).
        self.assertIn('preload("res://src/game/SourceForceProjectorBuildState.gd")', proof)
        self.assertIn('force_projector_build_state.source_force_projector_absorb_effect_state(', proof)
        self.assertIn('force_projector_build_state.source_force_projector_absorb_explosion_state(', proof)
        self.assertNotIn('source_force_projector_tick_buildings_state', proof)
        self.assertTrue(FORCE_PROJECTOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = FORCE_PROJECTOR_ABSORB_EFFECT_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ForceProjectorAbsorbEffectProof.gd', scene)
        self.assertIn('C07ForceProjectorAbsorbEffectProof', scene)

    def test_reference_graph_and_actual_c07_force_projector_absorb_effect_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ForceProjectorAbsorbEffectProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FORCE_PROJECTOR_ABSORB_EFFECT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'fx_on_absorb',
            'fx_null_when_not_absorbed',
            'fx_position',
            'fx_token',
            'fx_broken',
            'fx_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
