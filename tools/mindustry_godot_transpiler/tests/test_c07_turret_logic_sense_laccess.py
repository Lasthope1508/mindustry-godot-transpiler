import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
LOGIC_SENSE_LACCESS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretLogicSenseLAccessProof.gd'

LOGIC_SENSE_LACCESS_SIGNATURE = 'static func source_logic_sense_laccess_state(sensor: String, turret_handled: bool, turret_sense_value: Variant, comp_handled: bool, comp_sense_value: Variant) -> Dictionary:'
PROOF_KEYS = [
    'turret_ammo_num',
    'turret_wins_rotation',
    'comp_size_num',
    'comp_max_health_num',
    'deferred_health_nan',
    'unknown_sensor_nan',
]


class C07TurretLogicSenseLAccessTests(unittest.TestCase):
    def test_c07_turret_logic_sense_laccess_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2510']['godot_owner'], 'SourceTurretBuildState.source_logic_sense_laccess_state')
        # SenseI.run() is `public void run(LExecutor exec){ Object
        # target = from.obj(); Object sense = type.obj(); if(target
        # == null && sense == LAccess.dead){ to.setnum(1); return; }
        # if(target instanceof Senseable se){ if(sense instanceof
        # Content co){ to.setnum(se.sense(co)); }else if(sense
        # instanceof LAccess la){ Object objOut =
        # se.senseObject(la); if(objOut == Senseable.noSensed){
        # to.setnum(se.sense(la)); }else{ to.setobj(objOut); } }
        # }else{ if(sense == LAccess.size || sense ==
        # LAccess.bufferSize){ ... } to.setobj(null); } }`
        # (LExecutor.java:681-718). N2507 ported this branch's
        # dispatch outcome but took the numeric value as a param
        # (`sense_value`); this slice ports the resolution of
        # `se.sense(la)` itself for a duo turret: Turret.sense
        # (Turret.java:405-419) answers first, its `default`
        # falls through to super.sense
        # (BuildingComp.java:2093-2126), and a sensor neither
        # handles reports handled false + NaN (the
        # BuildingComp default). Three new result symbols
        # (handled, sense_value, sense_value_is_nan -- the
        # N2283/N2284 sense wire shape). The ported method is
        # SenseI.run() itself, so the java_source is LExecutor.java
        # and the slice lives in the canonical SSOT only (the
        # N2507/N2509 precedent -- no shard mirrors it); comp
        # stays 560/464, defense stays 210/209.
        self.assertEqual(
            ledger['N2510']['source_symbols'],
            [
                'source_logic_sense_laccess_state_result.handled',
                'source_logic_sense_laccess_state_result.sense_value',
                'source_logic_sense_laccess_state_result.sense_value_is_nan',
            ],
        )
        expected_sources = {
            'source_logic_sense_laccess_state_result.handled': 'core/src/mindustry/logic/LExecutor.java',
            'source_logic_sense_laccess_state_result.sense_value': 'core/src/mindustry/logic/LExecutor.java',
            'source_logic_sense_laccess_state_result.sense_value_is_nan': 'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        for name in ledger['N2510']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_logic_sense_laccess_state')
        self.assertEqual(ledger['N2510']['runtime_proof'], '/root/C07TurretLogicSenseLAccessProof')
        self.assertEqual(
            ledger['N2510']['tests'],
            [
                'test_c07_turret_logic_sense_laccess_registration',
                'test_all_c07_turret_logic_sense_laccess_input_evidence_is_exact',
                'test_turret_logic_sense_laccess_state',
                'test_reference_graph_and_actual_c07_turret_logic_sense_laccess',
            ],
        )
        self.assertTrue(ledger['N2510']['deferred_exprs'])

    def test_all_c07_turret_logic_sense_laccess_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2510']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_logic_sense_laccess_state')
        slice_sources = {
            'core/src/mindustry/logic/LExecutor.java',
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2510']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_logic_sense_laccess_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # SenseI.run() LAccess leg (LExecutor.java:694-703):
        # `}else if(sense instanceof LAccess la){` /
        # `Object objOut = se.senseObject(la);` /
        # `if(objOut == Senseable.noSensed){` /
        # `to.setnum(se.sense(la));` /
        # `}else{` / `to.setobj(objOut);` / `}` -- on the
        # noSensed sentinel the dispatch writes the numeric
        # `se.sense(la)` value. For a duo turret that value is
        # Turret.sense (`public double sense(LAccess sensor){`,
        # Turret.java:405-419: ammo / ammoCapacity / rotation /
        # shootX / shootY / shooting / progress), whose `default`
        # falls through to super.sense (`default ->
        # super.sense(sensor);`, :415; BuildingComp.java:2093-2126),
        # whose default is NaN (`default -> Float.NaN; //gets
        # converted to null in logic`, :2123). The pure function
        # resolves the numeric value from the two already-ported
        # sense outcomes (passed in as params -- the N2212/N2220
        # per-def-param precedent, same as N2507 passing in
        # `sense_value`); it does not re-implement the 30 sensor
        # legs. The result is the N2283/N2284 sense wire shape:
        # handled + sense_value + sense_value_is_nan. There is
        # no driver tick line: the leg is a logic read, not a
        # tick write.
        self.assertIn(LOGIC_SENSE_LACCESS_SIGNATURE, turret)
        for line in [
            'return {"handled": true, "sense_value": turret_sense_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": comp_sense_value, "sense_value_is_nan": false}',
            'return {"handled": false, "sense_value": null, "sense_value_is_nan": true}',
        ]:
            with self.subTest(line=line):
                self.assertIn(line, turret)
        for expr in [
            '}else if(sense instanceof LAccess la){',
            'Object objOut = se.senseObject(la);',
            'if(objOut == Senseable.noSensed){',
            'to.setnum(se.sense(la));',
            'to.setobj(objOut);',
            'public double sense(LAccess sensor){',
            'case ammo -> totalAmmo;',
            'case rotation -> rotation;',
            'case progress -> progress();',
            'default -> super.sense(sensor);',
            'public static class SenseI implements LInstruction{',
            'if(target instanceof Senseable se){',
            'default -> Float.NaN; //gets converted to null in logic',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The pure function sits immediately AFTER
        # source_logic_sense_content_state and BEFORE
        # source_logic_sense_size_state, mirroring exact Java
        # order inside SenseI.run(): Content (:692-693) ->
        # LAccess (:694) -> else-branch (:705-717).
        self.assertLess(turret.index('static func source_logic_sense_content_state('), turret.index('static func source_logic_sense_laccess_state('))
        self.assertLess(turret.index('static func source_logic_sense_laccess_state('), turret.index('static func source_logic_sense_size_state('))
        # The proof's keys drive the pure function with synthetic
        # inputs (no live tick: the leg is a logic read of the
        # passed-in sense outcomes): a turret-handled sensor
        # takes the turret value (and beats the comp value on the
        # shared `rotation` leg, since Turret.sense runs first),
        # a comp-only sensor takes the comp value, and a sensor
        # neither handles reports handled false + NaN.
        proof = LOGIC_SENSE_LACCESS_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_logic_sense_laccess(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretLogicSenseLAccessProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_LOGIC_SENSE_L_ACCESS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
