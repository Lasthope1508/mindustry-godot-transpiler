import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
LOGIC_SENSE_DISPATCH_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretLogicSenseDispatchProof.gd'

LOGIC_SENSE_DISPATCH_SIGNATURE = 'static func source_logic_sense_dispatch_state(sensor: String, target_is_null: bool, sense_object_handled: bool, sense_object: Variant, sense_value: float) -> Dictionary:'
PROOF_KEYS = [
    'dispatch_null_target_dead_num_one',
    'dispatch_type_duo_obj',
    'dispatch_first_item_copper_obj',
    'dispatch_config_null_obj',
    'dispatch_unknown_falls_back_to_sense',
    'dispatch_payload_type_null_obj',
]


class C07TurretLogicSenseDispatchTests(unittest.TestCase):
    def test_c07_turret_logic_sense_dispatch_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2507']['godot_owner'], 'SourceTurretBuildState.source_logic_sense_dispatch_state')
        # SenseI.run() is `public void run(LExecutor exec){ Object
        # target = from.obj(); Object sense = type.obj(); if(target
        # == null && sense == LAccess.dead){ to.setnum(1); return; }
        # if(target instanceof Senseable se){ if(sense instanceof
        # Content co){ to.setnum(se.sense(co)); }else if(sense
        # instanceof LAccess la){ Object objOut =
        # se.senseObject(la); if(objOut == Senseable.noSensed){
        # to.setnum(se.sense(la)); }else{ to.setobj(objOut); } } }
        # else{ if(sense == LAccess.size || sense ==
        # LAccess.bufferSize){ ... } to.setobj(null); } }`
        # (LExecutor.java:681-718). This slice ports the dispatch
        # for a duo Senseable target + an LAccess sensor: the
        # null-target dead leg (num 1, checked first), the
        # senseObject-handled leg (obj output, including the null
        # object for config / payloadType — setobj(null) is NOT the
        # sentinel, so it never falls back to numeric sense), and
        # the noSensed fallback leg (num sense(la) from the
        # N2283/N2284 chain, passed in as sense_value). The
        # Content leg and the non-Senseable size/bufferSize legs
        # are deferred (see the scope file
        # docs/superpowers/handoffs/hidden_files/n2507-scope.md):
        # the Content leg needs live items/liquids/payloads counts
        # and the non-Senseable legs target no building at all.
        # There is NO driver tick line: the dispatch is a logic
        # read, not a tick write (the
        # N2206/N2208/N2223/N2283/N2284/N2506 precedent); the proof
        # calls the pure function directly with synthetic inputs.
        # Four new result symbols: handled, output_kind,
        # output_value, is_no_sensed. This is the FIRST slice
        # whose java_source is under core/src/mindustry/logic/:
        # no /logic/ shard exists, so it lives in the canonical
        # SSOT only — comp stays 559/463, defense stays 210/209.
        self.assertEqual(
            ledger['N2507']['source_symbols'],
            [
                'source_logic_sense_dispatch_state_result.handled',
                'source_logic_sense_dispatch_state_result.output_kind',
                'source_logic_sense_dispatch_state_result.output_value',
                'source_logic_sense_dispatch_state_result.is_no_sensed',
            ],
        )
        for name in ledger['N2507']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/logic/LExecutor.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_logic_sense_dispatch_state')
        self.assertEqual(ledger['N2507']['runtime_proof'], '/root/C07TurretLogicSenseDispatchProof')
        self.assertEqual(
            ledger['N2507']['tests'],
            [
                'test_c07_turret_logic_sense_dispatch_registration',
                'test_all_c07_turret_logic_sense_dispatch_input_evidence_is_exact',
                'test_turret_logic_sense_dispatch_state',
                'test_reference_graph_and_actual_c07_turret_logic_sense_dispatch',
            ],
        )
        self.assertTrue(ledger['N2507']['deferred_exprs'])

    def test_all_c07_turret_logic_sense_dispatch_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2507']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_logic_sense_dispatch_state')
        slice_sources = {
            'core/src/mindustry/logic/LExecutor.java',
            'core/src/mindustry/logic/Senseable.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/logic/LAccess.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2507']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_logic_sense_dispatch_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # SenseI.run() (LExecutor.java:681-718) dispatches the
        # logic `sense` op for a duo Senseable target: null target
        # + dead writes num 1 first; otherwise senseObject() is
        # tried and its object is written when handled (including
        # a null object for config / payloadType); on the noSensed
        # sentinel the numeric sense(la) value is written instead.
        # The sensor spellings are the LAccess enum names. The
        # pure function returns handled + output_kind ("num" /
        # "obj") + output_value + is_no_sensed. There is no driver
        # tick line: the dispatch is a logic read, not a tick
        # write.
        self.assertIn(LOGIC_SENSE_DISPATCH_SIGNATURE, turret)
        self.assertIn('if target_is_null and sensor == "dead":', turret)
        for line in [
            'return {"handled": true, "output_kind": "num", "output_value": 1.0, "is_no_sensed": false}',
            'return {"handled": true, "output_kind": "obj", "output_value": sense_object, "is_no_sensed": false}',
            'return {"handled": true, "output_kind": "num", "output_value": sense_value, "is_no_sensed": true}',
        ]:
            with self.subTest(line=line):
                self.assertIn(line, turret)
        for expr in [
            'public static class SenseI implements LInstruction{',
            'if(target == null && sense == LAccess.dead){',
            'to.setnum(1);',
            'if(target instanceof Senseable se){',
            'if(sense instanceof Content co){',
            'to.setnum(se.sense(co));',
            '}else if(sense instanceof LAccess la){',
            'Object objOut = se.senseObject(la);',
            'if(objOut == Senseable.noSensed){',
            'to.setnum(se.sense(la));',
            'to.setobj(objOut);',
            'if(sense == LAccess.size || sense == LAccess.bufferSize){',
            'to.setobj(null);',
            'Object noSensed = new Object();',
            'default Object senseObject(LAccess sensor){',
            'return noSensed;',
            'public Object senseObject(LAccess sensor){',
            'public double sense(LAccess sensor){',
            'case ammo -> totalAmmo;',
            '    dead,',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The pure function sits immediately AFTER
        # source_turret_sense_object_state, since the dispatch
        # consumes its output, and BEFORE
        # source_turret_progress_state.
        self.assertLess(turret.index('static func source_turret_sense_object_state('), turret.index('static func source_logic_sense_dispatch_state('))
        self.assertLess(turret.index('static func source_logic_sense_dispatch_state('), turret.index('static func source_turret_progress_state('))
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick: the dispatch is a logic
        # read of the senseObject outcome + the numeric sense
        # fallback): null target + dead writes num 1, type /
        # firstItem / config / payloadType write their objects
        # (null stays an obj, never a numeric fallback), and an
        # unknown sensor falls back to the numeric sense value.
        proof = LOGIC_SENSE_DISPATCH_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_logic_sense_dispatch(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretLogicSenseDispatchProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_LOGIC_SENSE_DISPATCH_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
