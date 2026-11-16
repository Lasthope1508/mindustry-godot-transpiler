import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FORCE_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceForceProjectorBuildState.gd'
FORCE_PROJECTOR_ABSORB_EXPLOSION_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ForceProjectorAbsorbExplosionProof.gd'
FORCE_PROJECTOR_ABSORB_EXPLOSION_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ForceProjectorAbsorbExplosionProof.tscn'


class C07ForceProjectorAbsorbExplosionTests(unittest.TestCase):
    def test_c07_force_projector_absorb_explosion_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2423']['godot_owner'], 'SourceForceProjectorBuildState.source_force_projector_absorb_explosion_state')
        # N2235 ported the updateTile advance -- but
        # absorbExplosion (ForceBuild.absorbExplosion(),
        # ForceProjector.java:269-277) is a SEPARATE method
        # (the ExplosionShield interface,
        # ForceProjector.java:164, called from explosion
        # handling: Damage.explode, Damage.java:113, and the
        # unit crash path, UnitComp.java:906 -- NOT from
        # updateTile), so it stayed deferred as DEFERRED
        # #148. N2423 ports it as a pure with explicit
        # inputs (broken, ex, ey, damage, sides, building x/y,
        # real_radius, shield_rotation, the current hit, and
        # crash_damage_multiplier defaulting to 2f): absorb
        # is !broken && the explosion point inside the
        # regular polygon at the real radius (the N2235
        # isInRegularPolygon port, REUSED -- no second
        # polygon test), hit is set to 1f only when absorb
        # (reported as hit_value + a hit_set flag, so the
        # caller can tell "set to 1f" from "already 1f"),
        # and buildup grows by damage * crashDamageMultiplier
        # (2f, ForceProjector.java:45) only when absorb. The
        # absorbEffect.at FX defers (the N2235 effects
        # precedent) under its own narrow entry. Four new
        # result symbols: absorb, hit_value, hit_set, and
        # buildup_delta.
        self.assertEqual(
            ledger['N2423']['source_symbols'],
            [
                'source_force_projector_absorb_explosion_state_result.absorb',
                'source_force_projector_absorb_explosion_state_result.hit_value',
                'source_force_projector_absorb_explosion_state_result.hit_set',
                'source_force_projector_absorb_explosion_state_result.buildup_delta',
            ],
        )
        for name in ledger['N2423']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/ForceProjector.java')
                self.assertEqual(symbol['godot_owner'], 'SourceForceProjectorBuildState.source_force_projector_absorb_explosion_state')
        self.assertEqual(ledger['N2423']['runtime_proof'], '/root/C07ForceProjectorAbsorbExplosionProof')
        self.assertEqual(
            ledger['N2423']['tests'],
            [
                'test_c07_force_projector_absorb_explosion_registration',
                'test_all_c07_force_projector_absorb_explosion_input_evidence_is_exact',
                'test_force_projector_absorb_explosion_state',
                'test_reference_graph_and_actual_c07_force_projector_absorb_explosion',
            ],
        )
        self.assertTrue(ledger['N2423']['deferred_exprs'])
        # This slice resolves the ForceProjector
        # absorbExplosion rows deferral (DEFERRED #148), so
        # the rows entry is gone from DEFERRED -- while the
        # narrow absorbEffect FX entry (this slice's own new
        # deferral: the effect is FX, not state) and the
        # updateTile live-fill entry stay. 290 entries: the
        # N2415 base of 290, minus the resolved rows entry,
        # plus the new FX entry.
        self.assertFalse(any(entry.startswith('ForceProjector absorbExplosion rows (') for entry in ledger['N2423']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ForceProjector absorbExplosion effect row (') for entry in ledger['N2423']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ForceProjector updateTile live fill (') for entry in ledger['N2423']['deferred_exprs']))
        self.assertEqual(len(ledger['N2423']['deferred_exprs']), 290)

    def test_all_c07_force_projector_absorb_explosion_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2423']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceForceProjectorBuildState.source_force_projector_absorb_explosion_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ForceProjector.java',
            'core/src/mindustry/world/blocks/ExplosionShield.java',
            'core/src/mindustry/entities/Damage.java',
            'core/src/mindustry/entities/comp/UnitComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The polygon test lives in Arc, not Mindustry:
        # Intersector.java and Vec2.java under arc-upstream
        # (the N2191 precedent) -- the pure REUSEs the
        # N2235 port, so these exprs pin the reused
        # formulas, not a second port.
        upstream['arc-core/src/arc/math/geom/Intersector.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/Intersector.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/geom/Vec2.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/Vec2.java').read_text(encoding='utf-8')
        for expr in ledger['N2423']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_force_projector_absorb_explosion_state(self):
        force_projector = FORCE_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The pure absorbExplosion lives on the
        # force-projector build state:
        # ForceBuild.absorbExplosion()
        # (ForceProjector.java:269-277). Keep each Java expr
        # on ONE comment line (the N2148 shootWarmup lesson:
        # a split line fails this test). The gate is
        # `boolean absorb = !broken &&
        # Intersector.isInRegularPolygon(sides, x, y,
        # realRadius(), shieldRotation, ex, ey);` (:270) --
        # the SAME polygon test deflectBullets uses, so the
        # pure calls the N2235 helper instead of porting it
        # twice. On absorb ONLY: the effect fires
        # (absorbEffect.at, :272 -- FX, defers, not modeled),
        # hit is set to 1f (:273), and buildup grows by
        # damage * crashDamageMultiplier (:274, 2f, :45).
        # Java never touches hit or buildup when the gate is
        # false, so the pure reports hit_value (1f on absorb,
        # the incoming hit otherwise) PLUS a hit_set flag
        # (true only on absorb -- without it a hit already at
        # 1f would be indistinguishable from a fresh set).
        # real_radius is an EXPLICIT input: the caller
        # supplies the N2235 advance's real_radius result
        # ((radius + phaseHeat * phaseRadiusBoost) * radscl,
        # :280). There is NO tick wiring: absorbExplosion is
        # called from explosion handling (Damage.explode,
        # Damage.java:113; the unit crash path,
        # UnitComp.java:906), not from updateTile -- pure-only
        # like the draw rows.
        self.assertIn('static func source_force_projector_absorb_explosion_state', force_projector)
        self.assertIn('public boolean absorbExplosion(float ex, float ey, float damage){', force_projector)
        self.assertIn('boolean absorb = !broken && Intersector.isInRegularPolygon(sides, x, y, realRadius(), shieldRotation, ex, ey);', force_projector)
        self.assertIn('absorbEffect.at(ex, ey);', force_projector)
        self.assertIn('hit = 1f;', force_projector)
        self.assertIn('buildup += damage * crashDamageMultiplier;', force_projector)
        self.assertIn('return absorb;', force_projector)
        self.assertIn('public float crashDamageMultiplier = 2f;', force_projector)
        self.assertIn('public Effect absorbEffect = Fx.absorb;', force_projector)
        self.assertIn('public class ForceBuild extends Building implements Ranged, ExplosionShield{', force_projector)
        self.assertIn('boolean absorbExplosion(float x, float y, float damage);', force_projector)
        self.assertIn('s.absorbExplosion(x, y, damagePerWave)', force_projector)
        self.assertIn('s.absorbExplosion(x, y, crashDamage)', force_projector)
        self.assertIn('return (radius + phaseHeat * phaseRadiusBoost) * radscl;', force_projector)
        # The crash multiplier is a driver constant (the
        # class value 2f, ForceProjector.java:45 -- the def
        # does not override it, Blocks.java:1964-1976; the
        # Separator craftTime precedent for def/class
        # constants). The pure takes it as an explicit param
        # defaulting to the constant, so a proof can still
        # vary it.
        self.assertIn('SOURCE_FORCE_PROJECTOR_CRASH_DAMAGE_MULTIPLIER := 2.0', force_projector)
        self.assertIn('crash_damage_multiplier: float = SOURCE_FORCE_PROJECTOR_CRASH_DAMAGE_MULTIPLIER', force_projector)
        # REUSE, not a second port: the pure calls the N2235
        # polygon helper with the explicit inputs.
        self.assertIn('source_force_projector_is_in_regular_polygon(sides, building_x, building_y, real_radius, shield_rotation, ex, ey)', force_projector)
        # Pure-only: the driver NEVER calls the pure from the
        # tick -- the only call-shaped occurrence is the
        # definition itself (docstring mentions carry no
        # parens). The docstring records absorbExplosion as
        # live since N2423, and the old "is not ported here"
        # sentence is gone.
        self.assertEqual(force_projector.count('source_force_projector_absorb_explosion_state('), 1)
        self.assertIn('absorbExplosion live (N2423)', force_projector)
        self.assertNotIn('is not ported here', force_projector)
        # The proof's keys drive the pure (absorb true inside
        # the hexagon, false outside it and when broken, the
        # damage * 2f buildup math, the hit set, and the
        # zero-damage edge where absorb still fires and hit
        # still sets but the buildup delta is 0).
        proof = FORCE_PROJECTOR_ABSORB_EXPLOSION_PROOF.read_text(encoding='utf-8')
        for key in [
            'absorb_true_inside_polygon',
            'absorb_false_outside_polygon',
            'absorb_false_when_broken',
            'buildup_delta_math',
            'hit_set',
            'edge_damage_zero',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist). Pure-only: the proof
        # never touches the live tick.
        self.assertIn('preload("res://src/game/SourceForceProjectorBuildState.gd")', proof)
        self.assertIn('force_projector_build_state.source_force_projector_absorb_explosion_state(', proof)
        self.assertNotIn('source_force_projector_tick_buildings_state', proof)
        self.assertTrue(FORCE_PROJECTOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = FORCE_PROJECTOR_ABSORB_EXPLOSION_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ForceProjectorAbsorbExplosionProof.gd', scene)
        self.assertIn('C07ForceProjectorAbsorbExplosionProof', scene)

    def test_reference_graph_and_actual_c07_force_projector_absorb_explosion(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ForceProjectorAbsorbExplosionProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FORCE_PROJECTOR_ABSORB_EXPLOSION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'absorb_true_inside_polygon',
            'absorb_false_outside_polygon',
            'absorb_false_when_broken',
            'buildup_delta_math',
            'hit_set',
            'edge_damage_zero',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
