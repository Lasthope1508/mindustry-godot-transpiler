import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_SENSE_OBJECT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretSenseObjectProof.gd'

SENSE_OBJECT_SIGNATURE = 'static func source_turret_sense_object_state(sensor: String, block_id: String, first_item: String) -> Dictionary:'
PROOF_KEYS = [
    'sense_object_type_duo',
    'sense_object_first_item_copper',
    'sense_object_first_item_none',
    'sense_object_config_null',
    'sense_object_payload_type_null',
    'sense_object_unknown_is_no_sensed',
]


class C07TurretSenseObjectTests(unittest.TestCase):
    def test_c07_turret_sense_object_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2506']['godot_owner'], 'SourceTurretBuildState.source_turret_sense_object_state')
        # senseObject() is `public Object senseObject(LAccess
        # sensor){ return switch(sensor){ case type -> block;
        # case firstItem -> items == null ? null :
        # items.first(); case config ->
        # block.configSenseable() ? config() : null; case
        # payloadType -> getPayload() instanceof UnitPayload
        # p1 ? p1.unit.type : getPayload() instanceof
        # BuildPayload p2 ? p2.block() : null; default ->
        # noSensed; }; }` (BuildingComp.java:2128-2136). All
        # 4 legs + default are implemented here (see the
        # scope file
        # docs/superpowers/handoffs/hidden_files/n2506-scope.md
        # for the leg-by-leg liveness): type returns the block
        # id; firstItem returns the observed first item (""
        # encodes null); config is constant null for duo (no
        # config() registration, so configSenseable() is
        # false); payloadType is constant null (base
        # getPayload() returns null, no turret override); an
        # unknown sensor falls through to the noSensed
        # sentinel. There is NO driver tick line: senseObject
        # is a logic read, not a tick write (the
        # N2206/N2208/N2223/N2283/N2284/N2234 precedent); the
        # proof calls the pure function directly with
        # synthetic inputs, and the logic-processor dispatch
        # hook is its own later slice. Three new result
        # symbols: handled, sense_object, is_no_sensed.
        self.assertEqual(
            ledger['N2506']['source_symbols'],
            [
                'source_turret_sense_object_state_result.handled',
                'source_turret_sense_object_state_result.sense_object',
                'source_turret_sense_object_state_result.is_no_sensed',
            ],
        )
        for name in ledger['N2506']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/entities/comp/BuildingComp.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_sense_object_state')
        self.assertEqual(ledger['N2506']['runtime_proof'], '/root/C07TurretSenseObjectProof')
        self.assertEqual(
            ledger['N2506']['tests'],
            [
                'test_c07_turret_sense_object_registration',
                'test_all_c07_turret_sense_object_input_evidence_is_exact',
                'test_turret_sense_object_state',
                'test_reference_graph_and_actual_c07_turret_sense_object',
            ],
        )
        self.assertTrue(ledger['N2506']['deferred_exprs'])

    def test_all_c07_turret_sense_object_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2506']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_sense_object_state')
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/logic/Senseable.java',
            'core/src/mindustry/logic/LAccess.java',
            'core/src/mindustry/logic/LExecutor.java',
            'core/src/mindustry/world/modules/ItemModule.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2506']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_sense_object_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # senseObject() (BuildingComp.java:2128-2136)
        # dispatches the object sensors over the block id
        # (type) and the observed first item (firstItem),
        # with config / payloadType constant null for duo
        # and the noSensed sentinel for unknown sensors.
        # The sensor spellings are the LAccess enum names.
        # The pure function returns the N2234 senseObject
        # wire shape (handled + sense_object +
        # is_no_sensed). There is no driver tick line:
        # senseObject is a logic read, not a tick write.
        self.assertIn(SENSE_OBJECT_SIGNATURE, turret)
        for line in [
            'return {"handled": true, "sense_object": block_id, "is_no_sensed": false}',
            'return {"handled": true, "sense_object": first_item_value, "is_no_sensed": false}',
            'return {"handled": true, "sense_object": null, "is_no_sensed": false}',
            'return {"handled": false, "sense_object": null, "is_no_sensed": true}',
        ]:
            with self.subTest(line=line):
                self.assertIn(line, turret)
        for expr in [
            'public Object senseObject(LAccess sensor){',
            'case type -> block;',
            'case firstItem -> items == null ? null : items.first();',
            'case config -> block.configSenseable() ? config() : null;',
            'case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null;',
            'default -> noSensed;',
            'Object noSensed = new Object();',
            'if(objOut == Senseable.noSensed){',
            'to.setnum(se.sense(la));',
            'public boolean configSenseable(){',
            'return configurations.containsKey(Item.class) || configurations.containsKey(Liquid.class) || configurations.containsKey(UnlockableContent.class) ||',
            'configurations.containsKey(Block.class) || configurations.containsKey(UnitType.class);',
            'public @Nullable Payload getPayload(){',
            'public Object config(){',
            'public @Nullable Item first(){',
            'return content.item(i);',
            'hasItems = true;',
            'duo = new ItemTurret("duo"){{',
            'if(block.hasItems) items = new ItemModule();',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
            'firstItem,',
            'type,',
            'payloadType,',
            'config(true, "to"),',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The pure function sits immediately AFTER
        # source_building_comp_sense_state, since Java order
        # is sense() then senseObject() in BuildingComp, and
        # BEFORE source_turret_progress_state.
        self.assertLess(turret.index('static func source_building_comp_sense_state('), turret.index('static func source_turret_sense_object_state('))
        self.assertLess(turret.index('static func source_turret_sense_object_state('), turret.index('static func source_turret_progress_state('))
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick: senseObject is a
        # logic read of the block id + observed first item):
        # type returns the duo id, firstItem returns copper
        # or null, config / payloadType are null, and an
        # unknown sensor reports the noSensed sentinel.
        proof = TURRET_SENSE_OBJECT_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_sense_object(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretSenseObjectProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_SENSE_OBJECT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
