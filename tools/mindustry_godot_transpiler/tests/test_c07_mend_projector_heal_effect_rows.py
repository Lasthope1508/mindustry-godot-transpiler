import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MEND_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceMendProjectorBuildState.gd'
MEND_PROJECTOR_HEAL_EFFECT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorHealEffectRowsProof.gd'
MEND_PROJECTOR_HEAL_EFFECT_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorHealEffectRowsProof.tscn'


class C07MendProjectorHealEffectRowsTests(unittest.TestCase):
    def test_c07_mend_projector_heal_effect_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2484']['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_heal_effect_state')
        # The heal scan is live since N2242
        # (source_mend_projector_heal_scan_state): it
        # returns the heal amounts (one per healed
        # candidate) and the any flag, but the
        # Fx.healBlockFull.at FX at MendProjector.
        # java:115 deferred under its own narrow
        # entry (DEFERRED #124). N2484 ports ONLY
        # that FX as ONE pure-only pure (the N2469
        # precedent, NO tick wiring):
        # source_mend_projector_heal_effect_state
        # (healed, x, y, size, base_color, block_id)
        # returns heal_effect_call {effect
        # "Fx.healBlockFull", x, y, size, color:
        # base_color, block: block_id} when the
        # caller-supplied healed verdict is true,
        # null otherwise (the N2397 null-when-absent
        # precedent). The healed verdict is a
        # caller-supplied input (from the N2242 scan
        # -- a candidate is healed iff damaged &&
        # !heal_suppressed && the charge crossed) --
        # this pure does NOT recompute the heal gate
        # and does NOT amend the N2242 pure or its
        # proof. NO effect is spawned -- the effect
        # call site waits for its own slice. The FX
        # fires once per healed building (inside the
        # eachBlock lambda, MendProjector.java:
        # 112-117, after heal :113 + recentlyHealed
        # :114, before any = true :116). The effect
        # is Fx.healBlockFull (`healBlockFull = new
        # Effect(20, e -> {`, Fx.java:2781) and the
        # color is baseColor (`public Color baseColor
        # = Color.valueOf("84f491");`, MendProjector.
        # java:23; neither def overrides it, Blocks.
        # java:1919-1942), carried as the "baseColor"
        # field-name token (the N2373 color-token
        # precedent). One new result symbol:
        # heal_effect_call.
        self.assertEqual(
            ledger['N2484']['source_symbols'],
            [
                'source_mend_projector_heal_effect_state_result.heal_effect_call',
            ],
        )
        for name in ledger['N2484']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/MendProjector.java')
                self.assertEqual(symbol['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_heal_effect_state')
        self.assertEqual(ledger['N2484']['runtime_proof'], '/root/C07MendProjectorHealEffectRowsProof')
        self.assertEqual(
            ledger['N2484']['tests'],
            [
                'test_c07_mend_projector_heal_effect_rows_registration',
                'test_all_c07_mend_projector_heal_effect_rows_input_evidence_is_exact',
                'test_mend_projector_heal_effect_rows_state',
                'test_reference_graph_and_actual_c07_mend_projector_heal_effect_rows',
            ],
        )
        self.assertTrue(ledger['N2484']['deferred_exprs'])
        # This slice resolves DEFERRED #124 (1-based in
        # DEFERRED-after-advances-33.py, the merged 231
        # file): the heal effect rows entry is gone --
        # while the mendSound entry (#125) and the
        # recentlyHealed entry (#126) stay (different
        # Java lines, their own slices). No new entry:
        # the effect call site that would spawn
        # Fx.healBlockFull is an audio/effect slice,
        # not a MendProjector deferral (the N2482
        # precedent -- no entry added). Net 231 - 1
        # = 230.
        self.assertFalse(any(entry.startswith('MendProjector heal effect rows (') for entry in ledger['N2484']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector mendSound rows (') for entry in ledger['N2484']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector recentlyHealed rows (') for entry in ledger['N2484']['deferred_exprs']))
        self.assertEqual(len(ledger['N2484']['deferred_exprs']), 230)

    def test_all_c07_mend_projector_heal_effect_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2484']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_heal_effect_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/MendProjector.java',
            'core/src/mindustry/content/Fx.java',
            'core/src/mindustry/entities/Effect.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2484']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mend_projector_heal_effect_rows_state(self):
        mend_projector = MEND_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The heal effect row (MendBuild.updateTile()
        # heal branch, MendProjector.java:106-122):
        # the heal scan is live since N2242, so this
        # pure consumes the caller-supplied healed
        # verdict and reports the effect as a pure
        # call record (the N2469 precedent -- no
        # effect spawned): `indexer.eachBlock(this,
        # realRange, b -> b.damaged() &&
        # !b.isHealSuppressed(), other -> {` +
        # `other.heal(other.maxHealth() *
        # (healPercent + phaseHeat * phaseBoost) /
        # 100f * efficiency);` + `other.
        # recentlyHealed();` + `Fx.healBlockFull.at(
        # other.x, other.y, other.block.size,
        # baseColor, other.block);` + `any = true;`.
        # The effect is Fx.healBlockFull
        # (`healBlockFull = new Effect(20, e -> {`,
        # Fx.java:2781; the renderer reads e.color +
        # e.data as the Block -- `if(!(e.data
        # instanceof Block block)) return;` +
        # `mixcol(e.color, 1f);` + `Draw.rect(block.
        # fullIcon, e.x, e.y);`) and the color is
        # baseColor (`public Color baseColor =
        # Color.valueOf("84f491");`, MendProjector.
        # java:23; neither def overrides it, Blocks.
        # java:1919-1942). The .at overload is
        # `public void at(float x, float y, float
        # rotation, Color color, Object data){`
        # (Effect.java:133): the block size rides
        # the rotation arg. The defs are `mender =
        # new MendProjector("mender"){{` (size 1) and
        # `mendProjector = new MendProjector(
        # "mend-projector"){{` (size 2). Keep each
        # Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_mend_projector_heal_effect_state', mend_projector)
        self.assertIn('indexer.eachBlock(this, realRange, b -> b.damaged() && !b.isHealSuppressed(), other -> {', mend_projector)
        self.assertIn('other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);', mend_projector)
        self.assertIn('other.recentlyHealed();', mend_projector)
        self.assertIn('Fx.healBlockFull.at(other.x, other.y, other.block.size, baseColor, other.block);', mend_projector)
        self.assertIn('any = true;', mend_projector)
        self.assertIn('public Color baseColor = Color.valueOf("84f491");', mend_projector)
        self.assertIn('healBlockFull = new Effect(20, e -> {', mend_projector)
        self.assertIn('if(!(e.data instanceof Block block)) return;', mend_projector)
        self.assertIn('mixcol(e.color, 1f);', mend_projector)
        self.assertIn('Draw.rect(block.fullIcon, e.x, e.y);', mend_projector)
        self.assertIn('public void at(float x, float y, float rotation, Color color, Object data){', mend_projector)
        self.assertIn('mender = new MendProjector("mender"){{', mend_projector)
        self.assertIn('mendProjector = new MendProjector("mend-projector"){{', mend_projector)
        # The documented limits record the heal
        # effect FX row as live, and the N2242 pure
        # is untouched (this slice amends neither it
        # nor its proof).
        self.assertIn('heal effect', mend_projector)
        self.assertIn('is live since N2484 as this pure-only call record', mend_projector)
        self.assertIn('static func source_mend_projector_heal_scan_state', mend_projector)
        # Pure-only: the driver NEVER calls the effect
        # pure from the tick -- the only call-shaped
        # occurrence is its definition itself
        # (docstring mentions carry no parens). The
        # N2242 scan pure keeps its 2 call-shaped
        # occurrences (definition + the live tick
        # call) -- this slice adds no third.
        self.assertEqual(mend_projector.count('source_mend_projector_heal_effect_state('), 1)
        self.assertEqual(mend_projector.count('source_mend_projector_heal_scan_state('), 2)
        # The proof's keys drive the FX pure (the fire
        # + the null gate + the position pass-through
        # + the size pass-through + the color token
        # and block id + the live N2242 heal verdict
        # as the input).
        proof = MEND_PROJECTOR_HEAL_EFFECT_PROOF.read_text(encoding='utf-8')
        for key in [
            'fx_on_heal',
            'fx_null_when_not_healed',
            'fx_position',
            'fx_size',
            'fx_color_block',
            'fx_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist). Pure-only: the proof
        # never touches the live tick; the live-input keys
        # compose the N2242 pure (its any result key feeds
        # this pure's healed input).
        self.assertIn('preload("res://src/game/SourceMendProjectorBuildState.gd")', proof)
        self.assertIn('mend_projector_build_state.source_mend_projector_heal_effect_state(', proof)
        self.assertIn('mend_projector_build_state.source_mend_projector_heal_scan_state(', proof)
        self.assertNotIn('source_mend_projector_tick_buildings_state', proof)
        self.assertTrue(MEND_PROJECTOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = MEND_PROJECTOR_HEAL_EFFECT_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07MendProjectorHealEffectRowsProof.gd', scene)
        self.assertIn('C07MendProjectorHealEffectRowsProof', scene)

    def test_reference_graph_and_actual_c07_mend_projector_heal_effect_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MendProjectorHealEffectRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MEND_PROJECTOR_HEAL_EFFECT_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'fx_on_heal',
            'fx_null_when_not_healed',
            'fx_position',
            'fx_size',
            'fx_color_block',
            'fx_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
