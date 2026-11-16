import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOLID_PUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceSolidPumpBuildState.gd'
SOLID_PUMP_UPDATE_EFFECT_CHANCE_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SolidPumpUpdateEffectChanceProof.gd'
SOLID_PUMP_UPDATE_EFFECT_CHANCE_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SolidPumpUpdateEffectChanceProof.tscn'


class C07SolidPumpUpdateEffectChanceRowsTests(unittest.TestCase):
    def test_c07_solid_pump_update_effect_chance_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2481']['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_update_effect_chance_state')
        # The updateEffect chance (SolidPump.java:
        # 131-132), inside the pump branch
        # (SolidPump.java:126): `if(Mathf.chance(
        # delta() * updateEffectChance))` then
        # `updateEffect.at(x + Mathf.range(size *
        # 2f), y + Mathf.range(size * 2f));`.
        # N2481 ports it as ONE pure-only pure,
        # the N2421/N2468 precedent: NO RNG in
        # the pure -- the chance roll + the two
        # position rolls are caller-supplied
        # already-rolled inputs, and the pure
        # returns the effect call record {effect,
        # x, y} (or null when the gate fails or
        # the roll misses). One pure, one new
        # result symbol: the effect call record.
        self.assertEqual(
            ledger['N2481']['source_symbols'],
            [
                'source_solid_pump_update_effect_chance_state_result.effect_call',
            ],
        )
        for name in ledger['N2481']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/SolidPump.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceSolidPumpBuildState.source_solid_pump_'))
        self.assertEqual(ledger['N2481']['runtime_proof'], '/root/C07SolidPumpUpdateEffectChanceProof')
        self.assertEqual(
            ledger['N2481']['tests'],
            [
                'test_c07_solid_pump_update_effect_chance_rows_registration',
                'test_all_c07_solid_pump_update_effect_chance_rows_input_evidence_is_exact',
                'test_solid_pump_update_effect_chance_rows_state',
                'test_reference_graph_and_actual_c07_solid_pump_update_effect_chance_rows',
            ],
        )
        self.assertTrue(ledger['N2481']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #90 (1-based
        # in the merged advances-32 DEFERRED base,
        # 234 entries): "SolidPump updateEffect
        # chance rows (if(Mathf.chance(delta() *
        # updateEffectChance)) updateEffect.at(...),
        # SolidPump.java:131-132; updateEffectChance
        # 0.02f, SolidPump.java:24; updateEffect
        # Fx.none by default, SolidPump.java:23)".
        # Net 234 - 1 = 233. No new entry: the
        # pure is complete as a pure -- the effect
        # call sites that would spawn the Fx effect
        # are renderer/effect work that waits for
        # their own slices (the N2421 draw
        # precedent: no entry added for call
        # sites).
        self.assertFalse(any(entry.startswith('SolidPump updateEffect chance rows (') for entry in ledger['N2481']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump water-attribute / validTiles / boost fraction rows (') for entry in ledger['N2481']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump dumpLiquid campaign unlock surfacing (') for entry in ledger['N2481']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump fraction linked-tiles live fill (') for entry in ledger['N2481']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Pump proximity amount / liquidDrop rows (') for entry in ledger['N2481']['deferred_exprs']))
        self.assertEqual(len(ledger['N2481']['deferred_exprs']), 233)

    def test_all_c07_solid_pump_update_effect_chance_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2481']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_solid_pump_update_effect_chance_state_result.effect_call': 'SourceSolidPumpBuildState.source_solid_pump_update_effect_chance_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/SolidPump.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/content/Fx.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2481']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_solid_pump_update_effect_chance_rows_state(self):
        solid_pump = SOLID_PUMP_STATE.read_text(encoding='utf-8')
        # The updateEffect chance rows
        # (SolidPumpBuild.updateTile(),
        # SolidPump.java:122-141). The pump branch
        # is `if(efficiency > 0 && typeLiquid() <
        # liquidCapacity - 0.001f){`
        # (SolidPump.java:126 -- the brief said
        # :125, Java wins). Inside it, `if(Mathf.
        # chance(delta() * updateEffectChance))`
        # (SolidPump.java:131) gates `updateEffect.
        # at(x + Mathf.range(size * 2f), y +
        # Mathf.range(size * 2f));` (SolidPump.
        # java:132). The fields are `public Effect
        # updateEffect = Fx.none;` (SolidPump.
        # java:23) and `public float updateEffect
        # Chance = 0.02f;` (SolidPump.java:24);
        # the water-extractor def overrides NEITHER
        # (Blocks.java:2920-2930 -- the Blocks.java
        # updateEffect hits are Drill defs at
        # :1128/:1298/:2892/:2906 and the Fracker
        # oil-extractor at :2967-2968), so the live
        # call records the Fx.none token. Mathf.
        # chance is `return d >= 1f || rand.
        # nextFloat() < d;` (arc Mathf.java:240-242)
        # -- the d >= 1f short-circuit fires the
        # effect unconditionally -- and Mathf.range
        # is `return random(-range, range);` (arc
        # Mathf.java:220-222), so the position
        # rolls span [-size * 2f, size * 2f] =
        # [-4f, 4f] for the size-2 water-extractor
        # (`size = 2;`, Blocks.java:2924; the
        # driver constant SOURCE_SOLID_PUMP_SIZE).
        # delta() is Time.delta * timeScale
        # (BuildingComp.java:1922-1923). NO RNG in
        # the pure (the N2421/N2468 precedent):
        # the chance roll + the two position rolls
        # are caller-supplied already-rolled
        # inputs. Pure-only: the tick never calls
        # the chance pure -- the effect call sites
        # wait for renderer/effect slices.
        # Keep each Java expr on ONE comment line
        # (the N2148 lesson: a split line fails
        # this test).
        self.assertIn('static func source_solid_pump_update_effect_chance_state', solid_pump)
        self.assertIn('public Effect updateEffect = Fx.none;', solid_pump)
        self.assertIn('public float updateEffectChance = 0.02f;', solid_pump)
        self.assertIn('if(efficiency > 0 && typeLiquid() < liquidCapacity - 0.001f){', solid_pump)
        self.assertIn('if(Mathf.chance(delta() * updateEffectChance))', solid_pump)
        self.assertIn('updateEffect.at(x + Mathf.range(size * 2f), y + Mathf.range(size * 2f));', solid_pump)
        self.assertIn('public class SolidPumpBuild extends PumpBuild{', solid_pump)
        self.assertIn('public void updateTile(){', solid_pump)
        self.assertIn('public float delta(){', solid_pump)
        self.assertIn('return Time.delta * timeScale;', solid_pump)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', solid_pump)
        self.assertIn('none = new Effect(0, 0f, e -> {}),', solid_pump)
        self.assertIn('size = 2;', solid_pump)
        self.assertIn('public class SolidPump extends Pump{', solid_pump)
        self.assertIn('public static boolean chance(double d){', solid_pump)
        self.assertIn('return d >= 1f || rand.nextFloat() < d;', solid_pump)
        self.assertIn('public static float range(float range){', solid_pump)
        self.assertIn('return random(-range, range);', solid_pump)
        # The documented limits record the
        # updateEffect chance rows as live.
        self.assertIn('UpdateEffect chance rows live (N2481)', solid_pump)
        # The proof's keys drive the pure (the
        # roll hit incl. the d >= 1 short-circuit,
        # the roll miss incl. the exact-threshold
        # boundary, the closed gate, the position
        # rolls incl. the +-4f size-2 boundary, the
        # Fx.none token, and the live-advance gate
        # verdict).
        proof = SOLID_PUMP_UPDATE_EFFECT_CHANCE_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'fx_roll_hit',
            'fx_roll_miss',
            'fx_gate_closed',
            'fx_position_rolls',
            'fx_none_token',
            'fx_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceSolidPumpBuildState.gd")', proof)
        self.assertTrue(SOLID_PUMP_STATE.exists())
        self.assertTrue(SOLID_PUMP_UPDATE_EFFECT_CHANCE_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07SolidPumpUpdateEffectChanceProof.gd', SOLID_PUMP_UPDATE_EFFECT_CHANCE_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_solid_pump_update_effect_chance_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SolidPumpUpdateEffectChanceProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOLID_PUMP_UPDATE_EFFECT_CHANCE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'fx_roll_hit',
            'fx_roll_miss',
            'fx_gate_closed',
            'fx_position_rolls',
            'fx_none_token',
            'fx_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
