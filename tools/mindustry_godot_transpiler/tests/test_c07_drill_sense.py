import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
DRILL_SENSE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DrillSenseProof.gd'


class C07DrillSenseTests(unittest.TestCase):
    def test_c07_drill_sense_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2298']['godot_owner'], 'SourceBurstDrillBuildState.source_drill_sense_object_state')
        # DrillBuild overrides senseObject (Drill.java:281-284,
        # `public Object senseObject(LAccess sensor){` /
        # `if(sensor == LAccess.firstItem) return
        # dominantItem;` / `return super.senseObject(sensor);`)
        # and sense (Drill.java:333-336, `public double
        # sense(LAccess sensor){` / `if(sensor ==
        # LAccess.progress && dominantItem != null) return
        # progress;` / `return super.sense(sensor);`) over the
        # base defaults BuildingComp.senseObject
        # (BuildingComp.java:2128-2137, `public Object
        # senseObject(LAccess sensor){`, whose firstItem leg is
        # `case firstItem -> items == null ? null :
        # items.first();` and whose default is `default ->
        # noSensed;`) and BuildingComp.sense
        # (BuildingComp.java:2093, `public double
        # sense(LAccess sensor){`), whose default is `default
        # -> Float.NaN; //gets converted to null in logic`
        # (BuildingComp.java:2123). The sensor spellings are
        # the LAccess enum names `firstItem,`
        # (LAccess.java:8) and `progress,` (:28). sense()
        # returns the RAW progress field (`public float
        # progress;`, Drill.java:238) -- NOT the clamped
        # progress() (Drill.java:327-329, `return dominantItem
        # == null ? 0f : Mathf.clamp(progress /
        # getDrillTime(dominantItem));`), which is its own
        # slice. senseObject returns dominantItem itself for
        # firstItem -- null when no dominant item is bound --
        # and the caller-passed super result otherwise; sense
        # returns progress for the progress sensor with a
        # dominant item and the caller-passed super result
        # otherwise (the N2271/N2277 super-as-param precedent:
        # the super legs are the live BuildingComp sense
        # N636 / N1078-N1085). All live values arrive as
        # explicit params (the N2188 precedent), because the
        # tick frame tracks only cheating / enabled /
        # power_status / efficiency today. NO driver line:
        # sense is a logic read, not a tick write (the N2206
        # / N2208 / N2223 precedent); the logic-processor
        # dispatch hook is its own later slice. Five new
        # result symbols: sense_object handled +
        # sense_object_value, sense handled + sense_value +
        # sense_value_is_nan.
        self.assertEqual(
            ledger['N2298']['source_symbols'],
            [
                'source_drill_sense_object_state_result.handled',
                'source_drill_sense_object_state_result.sense_object_value',
                'source_drill_sense_state_result.handled',
                'source_drill_sense_state_result.sense_value',
                'source_drill_sense_state_result.sense_value_is_nan',
            ],
        )
        for name in ledger['N2298']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/logic/LAccess.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2298']['runtime_proof'], '/root/C07DrillSenseProof')
        self.assertEqual(
            ledger['N2298']['tests'],
            [
                'test_c07_drill_sense_registration',
                'test_all_c07_drill_sense_input_evidence_is_exact',
                'test_drill_sense_state',
                'test_reference_graph_and_actual_c07_drill_sense',
            ],
        )
        self.assertTrue(ledger['N2298']['deferred_exprs'])

    def test_all_c07_drill_sense_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2298']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                source = symbol['java_source']
                upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / source).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/logic/LAccess.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2298']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_drill_sense_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # The pure senseObject / sense legs live on the
        # burst-drill build state next to the N2283 drawSelect
        # row (both are DrillBuild overrides): senseObject
        # (Drill.java:281-284, `public Object senseObject(
        # LAccess sensor){` / `if(sensor ==
        # LAccess.firstItem) return dominantItem;` /
        # `return super.senseObject(sensor);`) returns the
        # dominant item for firstItem and falls through to
        # the caller-passed super result otherwise; sense
        # (Drill.java:333-336, `public double sense(LAccess
        # sensor){` / `if(sensor == LAccess.progress &&
        # dominantItem != null) return progress;` /
        # `return super.sense(sensor);`) returns the raw
        # progress field for the progress sensor with a
        # dominant item and falls through to the
        # caller-passed super result otherwise. The super
        # legs are BuildingComp.senseObject
        # (BuildingComp.java:2128-2137, firstItem leg `case
        # firstItem -> items == null ? null : items.first();`,
        # default `default -> noSensed;`) and
        # BuildingComp.sense (BuildingComp.java:2093, default
        # `default -> Float.NaN; //gets converted to null in
        # logic`, BuildingComp.java:2123) -- both already live
        # (N636 / N1078-N1085) and passed in as explicit
        # params (the N2271/N2277 super-as-param precedent).
        # The sensor spellings are the LAccess enum names
        # `firstItem,` (LAccess.java:8) and `progress,`
        # (:28). The dominant item is `public Item
        # dominantItem;` (Drill.java:244), set by the N2262
        # ore/dominant binding; the caller passes it as
        # explicit params (has_dominant_item, dominant_item)
        # -- the N2311/N2275/N2281 explicit-param precedent.
        # `progress` is the DrillBuild field (`public float
        # progress;`, Drill.java:238), advanced in updateTile
        # (N2294) -- NOT the clamped progress()
        # (Drill.java:327-329). The classes are `public class
        # Drill extends Block{` (Drill.java:27) and `public
        # class DrillBuild extends Building{` (Drill.java:237);
        # BurstDrillBuild inherits DrillBuild (`public class
        # BurstDrill extends Drill{`, BurstDrill.java:17). There
        # is NO driver tick line: sense is a logic read, not a
        # per-tick write (the N2206 / N2208 / N2223
        # precedent); the logic-processor dispatch hook is its
        # own later slice.
        self.assertIn('static func source_drill_sense_object_state(frame: Dictionary, sensor: String, has_dominant_item: bool, dominant_item: Variant, super_sense_object_value: Variant) -> Dictionary:', burst_drill)
        self.assertIn('static func source_drill_sense_state(frame: Dictionary, sensor: String, has_dominant_item: bool, progress: float, super_sense_value: Variant, super_sense_value_is_nan: bool) -> Dictionary:', burst_drill)
        with self.subTest(case='senseObject firstItem returns the dominant item'):
            self.assertIn('if sensor == "firstItem":', burst_drill)
            self.assertIn('return {"handled": true, "sense_object_value": dominant_item}', burst_drill)
        with self.subTest(case='senseObject falls through to the super result'):
            self.assertIn('return {"handled": false, "sense_object_value": super_sense_object_value}', burst_drill)
        with self.subTest(case='sense progress returns the raw progress with a dominant item'):
            self.assertIn('if sensor == "progress" and has_dominant_item:', burst_drill)
            self.assertIn('return {"handled": true, "sense_value": progress, "sense_value_is_nan": false}', burst_drill)
        with self.subTest(case='sense falls through to the super result'):
            self.assertIn('return {"handled": false, "sense_value": super_sense_value, "sense_value_is_nan": super_sense_value_is_nan}', burst_drill)
        for expr in [
            'public Object senseObject(LAccess sensor){',
            'if(sensor == LAccess.firstItem) return dominantItem;',
            'return super.senseObject(sensor);',
            'public double sense(LAccess sensor){',
            'if(sensor == LAccess.progress && dominantItem != null) return progress;',
            'return super.sense(sensor);',
            'public float progress;',
            'public Item dominantItem;',
            'public class DrillBuild extends Building{',
            'public class Drill extends Block{',
            'public Object senseObject(LAccess sensor){',
            'case firstItem -> items == null ? null : items.first();',
            'default -> noSensed;',
            'public double sense(LAccess sensor){',
            'default -> Float.NaN; //gets converted to null in logic',
            'firstItem,',
            'progress,',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # No driver tick line lands here: sense is a logic
        # read, so the burst-drill tick driver must not call
        # either sense leg.
        driver_start = burst_drill.index('static func source_burst_drill_tick_buildings_state')
        driver_text = burst_drill[driver_start:]
        self.assertNotIn('source_drill_sense_object_state', driver_text)
        self.assertNotIn('source_drill_sense_state', driver_text)
        # The proof's keys drive the pure sense legs
        # (firstItem returns the dominant item / null without
        # one / other sensors fall through to super; progress
        # returns the raw progress with a dominant item /
        # falls through without one / other sensors fall
        # through to super). There is no dispatch-hook key:
        # the logic-processor dispatch hook waits for its own
        # slice.
        proof = DRILL_SENSE_PROOF.read_text(encoding='utf-8')
        for key in [
            'sense_object_first_item_returns_dominant_item',
            'sense_object_first_item_null_without_dominant_item',
            'sense_object_other_sensor_falls_through_to_super',
            'sense_progress_returns_raw_progress_with_dominant_item',
            'sense_progress_falls_through_without_dominant_item',
            'sense_other_sensor_falls_through_to_super',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_drill_sense(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DrillSenseProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DRILL_SENSE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sense_object_first_item_returns_dominant_item',
            'sense_object_first_item_null_without_dominant_item',
            'sense_object_other_sensor_falls_through_to_super',
            'sense_progress_returns_raw_progress_with_dominant_item',
            'sense_progress_falls_through_without_dominant_item',
            'sense_other_sensor_falls_through_to_super',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
