import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
LOGIC_SENSE_CONTENT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretLogicSenseContentProof.gd'

LOGIC_SENSE_CONTENT_SIGNATURE = 'static func source_logic_sense_content_state(content_kind: String, has_items: bool, item_count: float, has_liquids: bool, liquid_amount: float, has_payloads: bool, payload_unit_count: float, payload_block_count: float) -> Dictionary:'
PROOF_KEYS = [
    'content_item_copper_num',
    'content_liquid_water_num',
    'content_unit_dagger_num',
    'content_block_duo_num',
    'content_item_no_items_invalid',
    'content_unknown_kind_invalid',
]


class C07TurretLogicSenseContentTests(unittest.TestCase):
    def test_c07_turret_logic_sense_content_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2508']['godot_owner'], 'SourceTurretBuildState.source_logic_sense_content_state')
        # SenseI.run() is `public void run(LExecutor exec){ Object
        # target = from.obj(); Object sense = type.obj(); if(target
        # == null && sense == LAccess.dead){ to.setnum(1); return; }
        # if(target instanceof Senseable se){ if(sense instanceof
        # Content co){ to.setnum(se.sense(co)); }else if(sense
        # instanceof LAccess la){ ... } } }` (LExecutor.java:681-718).
        # BuildingComp.sense(Content) is `public double
        # sense(Content content){ if(content instanceof Item i &&
        # items != null) return items.get(i); if(content instanceof
        # Liquid l && liquids != null) return liquids.get(l);
        # if(getPayloads() != null){ if(content instanceof UnitType
        # u) return getPayloads().get(u); if(content instanceof
        # Block b) return getPayloads().get(b); } return Float.NaN;
        # //invalid sense }` (BuildingComp.java:2139-2147). This
        # slice ports the Content leg for a duo Senseable target:
        # Item / Liquid / UnitType / Block counts from the live
        # inventories, passed in as params (the N2212/N2220
        # per-def-param precedent), and Float.NaN for anything
        # else. The leg always writes with to.setnum, never
        # to.setobj, so output_kind is always "num" and handled is
        # true throughout. There is NO driver tick line: the leg is
        # a logic read, not a tick write (the
        # N2206/N2208/N2223/N2283/N2284/N2506/N2507 precedent); the
        # proof calls the pure function directly with synthetic
        # inputs. Four new result symbols: handled, output_kind,
        # output_value, is_invalid. The ported method is
        # BuildingComp.sense(Content), so the java_source is
        # BuildingComp.java and the slice mirrors into the comp
        # shard (559/463 -> 560/464); defense stays 210/209.
        self.assertEqual(
            ledger['N2508']['source_symbols'],
            [
                'source_logic_sense_content_state_result.handled',
                'source_logic_sense_content_state_result.output_kind',
                'source_logic_sense_content_state_result.output_value',
                'source_logic_sense_content_state_result.is_invalid',
            ],
        )
        for name in ledger['N2508']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/entities/comp/BuildingComp.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_logic_sense_content_state')
        self.assertEqual(ledger['N2508']['runtime_proof'], '/root/C07TurretLogicSenseContentProof')
        self.assertEqual(
            ledger['N2508']['tests'],
            [
                'test_c07_turret_logic_sense_content_registration',
                'test_all_c07_turret_logic_sense_content_input_evidence_is_exact',
                'test_turret_logic_sense_content_state',
                'test_reference_graph_and_actual_c07_turret_logic_sense_content',
            ],
        )
        self.assertTrue(ledger['N2508']['deferred_exprs'])

    def test_all_c07_turret_logic_sense_content_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2508']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_logic_sense_content_state')
        slice_sources = {
            'core/src/mindustry/logic/LExecutor.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2508']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_logic_sense_content_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # BuildingComp.sense(Content) (BuildingComp.java:2139-2147)
        # reads the sensed Content from the live inventories: an
        # Item reads items.get(i) when items exists, a Liquid reads
        # liquids.get(l) when liquids exists, a UnitType / Block
        # reads getPayloads().get(...) when payloads exist, and
        # anything else returns Float.NaN (invalid sense). SenseI
        # writes the result with to.setnum (LExecutor.java:692-693),
        # so the pure function returns handled + output_kind
        # (always "num") + output_value + is_invalid. There is no
        # driver tick line: the leg is a logic read, not a tick
        # write.
        self.assertIn(LOGIC_SENSE_CONTENT_SIGNATURE, turret)
        for line in [
            'return {"handled": true, "output_kind": "num", "output_value": item_count, "is_invalid": false}',
            'return {"handled": true, "output_kind": "num", "output_value": liquid_amount, "is_invalid": false}',
            'return {"handled": true, "output_kind": "num", "output_value": payload_unit_count, "is_invalid": false}',
            'return {"handled": true, "output_kind": "num", "output_value": payload_block_count, "is_invalid": false}',
            'return {"handled": true, "output_kind": "num", "output_value": NAN, "is_invalid": true}',
        ]:
            with self.subTest(line=line):
                self.assertIn(line, turret)
        for expr in [
            'if(sense instanceof Content co){',
            'to.setnum(se.sense(co));',
            'public double sense(Content content){',
            'if(content instanceof Item i && items != null) return items.get(i);',
            'if(content instanceof Liquid l && liquids != null) return liquids.get(l);',
            'if(getPayloads() != null){',
            'if(content instanceof UnitType u) return getPayloads().get(u);',
            'if(content instanceof Block b) return getPayloads().get(b);',
            'return Float.NaN; //invalid sense',
            'public static class SenseI implements LInstruction{',
            'if(target instanceof Senseable se){',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The pure function sits immediately AFTER
        # source_logic_sense_dispatch_state, since the Content leg
        # is the other branch of the same SenseI.run() dispatch,
        # and BEFORE source_turret_progress_state.
        self.assertLess(turret.index('static func source_logic_sense_dispatch_state('), turret.index('static func source_logic_sense_content_state('))
        self.assertLess(turret.index('static func source_logic_sense_content_state('), turret.index('static func source_turret_progress_state('))
        # The proof's keys drive the pure function with synthetic
        # inputs (no live tick: the leg is a logic read of the
        # passed-in live counts): Item / Liquid / UnitType / Block
        # read their counts, an Item sensor with no items is
        # invalid even when payloads exist, and an unknown kind is
        # invalid.
        proof = LOGIC_SENSE_CONTENT_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_logic_sense_content(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretLogicSenseContentProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_LOGIC_SENSE_CONTENT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
