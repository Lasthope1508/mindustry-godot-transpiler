import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_GET_DRILL_TIME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillGetDrillTimeProof.gd'


class C07BurstDrillGetDrillTimeTests(unittest.TestCase):
    def test_c07_burst_drill_get_drill_time_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2344']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_get_drill_time_state')
        # BurstDrill.getDrillTime() (BurstDrill.java:52-55,
        # `@Override public float getDrillTime(Item item){`)
        # returns the drill time divided by the per-item
        # multiplier (`return drillTime /
        # drillMultipliers.get(item, 1f);` -- :54), with NO
        # hardness term: the base Drill formula
        # (`return (drillTime + hardnessDrillMultiplier *
        # item.hardness) / drillMultipliers.get(item, 1f);`,
        # Drill.java:171) is NOT this slice -- the BurstDrill
        # override drops the `hardnessDrillMultiplier *
        # item.hardness` leg entirely (and the constructor
        # zeroes the field, `hardnessDrillMultiplier = 0f;`,
        # BurstDrill.java:39, "does not drill in the
        # traditional sense, so this is not even used"), so
        # item.hardness is NOT an input here. drillTime is
        # the block field (`public float drillTime = 300;`,
        # Drill.java:36); drillMultipliers is
        # (`public ObjectFloatMap<Item> drillMultipliers =
        # new ObjectFloatMap<>();`, Drill.java:66) and defaults
        # a missing item to 1f. One new result symbol:
        # drill_time. Two defs share the function
        # (impact-drill, Blocks.java:3070, drillTime 720f;
        # eruption-drill, Blocks.java:3093, drillTime
        # 281.25f); both put beryllium at 2f
        # (Blocks.java:3083/3114). This slice is distinct
        # from Drill.getDrillTime (N1367/N690, owner
        # PortGame.source_drill_delay): different class,
        # different formula, different GD name -- the shared
        # signature string `public float getDrillTime(Item
        # item){` in N1367's exact_exprs is evidence-only
        # (same signature string, different class + body),
        # not ownership. There is NO driver tick line: the
        # BurstDrill tick (N2149/N2294/N2296) already reads
        # `getDrillTime(dominantItem)` (BurstDrill.java:87)
        # through its precomputed drill_time_base /
        # drill_multiplier params; this slice ports only the
        # pure function, not the caller.
        # RED decisions (resolved at RED, recorded in the
        # register docstring): (1) One pure function on
        # the same family file N2149 built:
        # source_burst_drill_get_drill_time_state(frame,
        # drill_time, drill_multipliers, item_id)
        # returning drill_time (drill_time /
        # drill_multipliers.get(item_id, 1.0)). frame is the
        # canonical first param of this family file and
        # carries no live keys for this block-level read
        # (the N2212 / N2224 per-def-param precedent, same
        # as setStats). drill_time and drill_multipliers
        # are explicit per-def params; item_id rides as a
        # string id (the source_drill_delay bridge
        # precedent: item_id: String). (2) There is NO
        # driver tick line (see above). One new result
        # symbol: drill_time.
        self.assertEqual(
            ledger['N2344']['source_symbols'],
            [
                'source_burst_drill_get_drill_time_state_result.drill_time',
            ],
        )
        for name in ledger['N2344']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BurstDrill.java',
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2344']['runtime_proof'], '/root/C07BurstDrillGetDrillTimeProof')
        self.assertEqual(
            ledger['N2344']['tests'],
            [
                'test_c07_burst_drill_get_drill_time_registration',
                'test_all_c07_burst_drill_get_drill_time_input_evidence_is_exact',
                'test_burst_drill_get_drill_time_state',
                'test_reference_graph_and_actual_c07_burst_drill_get_drill_time',
            ],
        )
        self.assertTrue(ledger['N2344']['deferred_exprs'])

    def test_all_c07_burst_drill_get_drill_time_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2344']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2344']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_get_drill_time_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # BurstDrill.getDrillTime() (BurstDrill.java:52-55,
        # `@Override public float getDrillTime(Item item){`):
        # `return drillTime / drillMultipliers.get(item,
        # 1f);` (:54) -- the drill time divided by the
        # per-item multiplier, NO hardness term. The base
        # Drill formula (`return (drillTime +
        # hardnessDrillMultiplier * item.hardness) /
        # drillMultipliers.get(item, 1f);`, Drill.java:171)
        # is NOT this slice: the override drops the hardness
        # leg (and the constructor zeroes the field,
        # `hardnessDrillMultiplier = 0f;`,
        # BurstDrill.java:41), so item.hardness is NOT an
        # input. drillTime is `public float drillTime =
        # 300;` (Drill.java:36); drillMultipliers is
        # `public ObjectFloatMap<Item> drillMultipliers = new
        # ObjectFloatMap<>();` (Drill.java:66), missing item
        # defaults to 1f. There is NO driver tick line: the
        # tick (N2149/N2294/N2296) already reads
        # `getDrillTime(dominantItem)` (BurstDrill.java:87)
        # through precomputed params; this slice ports only
        # the pure function.
        self.assertIn('static func source_burst_drill_get_drill_time_state(frame: Dictionary, drill_time: float, drill_multipliers: Dictionary, item_id: Variant) -> Dictionary:', burst_drill)
        self.assertIn('return {"drill_time": drill_time}', burst_drill)
        for expr in [
            '@Override',
            'public float getDrillTime(Item item){',
            'return drillTime / drillMultipliers.get(item, 1f);',
            'public float drillTime = 300;',
            'public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();',
            'public float hardnessDrillMultiplier = 50f;',
            'hardnessDrillMultiplier = 0f;',
            'return (drillTime + hardnessDrillMultiplier * item.hardness) / drillMultipliers.get(item, 1f);',
            'public class BurstDrill extends Drill{',
            'public class Drill extends Block{',
            'drillTime = 60f * 12f;',
            'drillTime = 281.25f;',
            'drillMultipliers.put(Items.beryllium, 2f);',
            'float drillTime = getDrillTime(dominantItem);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # The proof's keys drive the pure function directly
        # with the per-def drill times and multiplier maps:
        # impact-drill 720f (Blocks.java:3072) and
        # eruption-drill 281.25f (Blocks.java:3095), both
        # with beryllium at 2f (Blocks.java:3083/3114); the
        # class default is 300f (Drill.java:36) with an empty
        # map. The no-hardness key pins the trap: for
        # impact-drill + beryllium (hardness 3,
        # Items.java:107) the override gives 720/2 = 360,
        # NOT the base formula's (720 + 50*3)/2 = 435.
        proof = BURST_DRILL_GET_DRILL_TIME_PROOF.read_text(encoding='utf-8')
        for key in [
            'get_drill_time_impact_beryllium',
            'get_drill_time_impact_other',
            'get_drill_time_eruption_beryllium',
            'get_drill_time_eruption_other',
            'get_drill_time_class_default',
            'get_drill_time_no_hardness_term',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_burst_drill_get_drill_time(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillGetDrillTimeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_GET_DRILL_TIME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'get_drill_time_impact_beryllium',
            'get_drill_time_impact_other',
            'get_drill_time_eruption_beryllium',
            'get_drill_time_eruption_other',
            'get_drill_time_class_default',
            'get_drill_time_no_hardness_term',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
