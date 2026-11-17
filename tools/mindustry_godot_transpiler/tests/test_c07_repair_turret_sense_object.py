import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_SENSE_OBJECT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretSenseObjectProof.gd'


class C07RepairTurretSenseObjectTests(unittest.TestCase):
    def test_c07_repair_turret_sense_object_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2234']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_sense_object_state')
        # N2174 / N2188 / N2209 / N2212 / N2213 / N2214 / N2215 /
        # N2217 / N2219 / N2220 / N2221 / N2222 / N2223 / N2224 /
        # N2225 / N2226 / N2227 / N2233 made the repair turret
        # live (power row, should-consume gate, coolant
        # multiplier, target acquire, heal advance, rotation
        # slerp, strength lerp, read/write persistence,
        # drawBeam, draw, drawSelect/drawPlace,
        # shouldAmbientSound/status, ambient-sound loop, sense
        # range/rotation, setStats, init, icons, range() /
        # buildRotation()) -- but nothing in the port captured
        # BuildingComp.senseObject() (BuildingComp.java:2128-
        # 2136), the logic read that senses the block itself
        # (`type`), the first item, the config and the payload
        # type. RED decisions (resolved at RED, recorded in
        # the register docstring): (1) One pure function on
        # the same family file, taking the sensor spelling and
        # the block id explicitly (per-def static state, not a
        # live frame key -- the N2212 / N2220 precedent; the
        # port identity of `block` is its id string, the same
        # key every `_..._for_block_id` helper resolves).
        # (2) The three null legs are pinned, not guessed:
        # firstItem is null because `hasItems` is false by
        # default (Block.java:45) and RepairTurret never sets
        # it, so BuildingComp.java:145 never creates the items
        # module; config is null because RepairTurret
        # registers no `config()` call, so `configurations`
        # (Block.java:402) stays empty and configSenseable()
        # (Block.java:809-813) is false; payloadType is null
        # because the base `getPayload()` returns null
        # (BuildingComp.java:984-986) and RepairTurret does
        # not override it. (3) An unhandled sensor returns
        # the `noSensed` sentinel (Senseable.java:6), which
        # the logic converts to a numeric `sense()` fallback
        # (LExecutor.java:697-701) -- the port reports it as
        # `handled: false` + `is_no_sensed: true`, the sense()
        # N2223 `sense_value_is_nan` precedent. (4) There is
        # NO driver tick line: senseObject is a logic read,
        # not a tick write (the N2223 sense / N2230 setStats /
        # N2232 RepairTower range+warmup precedent). (5) The
        # lumped deferred entry "RepairTurret display() /
        # senseObject(config) rows" is dropped -- senseObject
        # is done here -- and replaced by a display()-only
        # entry plus the N2234 Windows-proof debt entry; the
        # pool already carried that lumped entry twice
        # (identical strings), so the filter drops both
        # copies. (6) Suppression live + targets live list
        # stay BLOCKED (re-checked at RED: no `frame["units"]
        # =` stamp exists anywhere in src/game, and no frame
        # stamps `heal_suppressed` / `heal_suppression_time`).
        # Three new result symbols: handled, sense_object,
        # is_no_sensed.
        self.assertEqual(
            ledger['N2234']['source_symbols'],
            [
                'source_repair_turret_sense_object_state_result.handled',
                'source_repair_turret_sense_object_state_result.sense_object',
                'source_repair_turret_sense_object_state_result.is_no_sensed',
            ],
        )
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/logic/Senseable.java',
            'core/src/mindustry/logic/LAccess.java',
        }
        for name in ledger['N2234']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], slice_sources)
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2234']['runtime_proof'], '/root/C07RepairTurretSenseObjectProof')
        self.assertEqual(
            ledger['N2234']['tests'],
            [
                'test_c07_repair_turret_sense_object_registration',
                'test_all_c07_repair_turret_sense_object_input_evidence_is_exact',
                'test_repair_turret_sense_object_state',
                'test_reference_graph_and_actual_c07_repair_turret_sense_object',
            ],
        )
        self.assertTrue(ledger['N2234']['deferred_exprs'])

    def test_all_c07_repair_turret_sense_object_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2234']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/logic/Senseable.java',
            'core/src/mindustry/logic/LAccess.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2234']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_sense_object_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # BuildingComp.senseObject() (BuildingComp.java:2128-
        # 2136) switches on the LAccess sensor: `type` returns
        # the block itself, `firstItem` the first item or null
        # when the items module is absent, `config` the config
        # only when the block is config-senseable, `payloadType`
        # the payload's unit type / block or null, and any other
        # sensor falls through to the `noSensed` sentinel
        # (Senseable.java:6). For a repair turret the three
        # middle legs are all null (see the registration test):
        # hasItems false (Block.java:45), no `config()` calls
        # so `configurations` (Block.java:402) stays empty, and
        # the base `getPayload()` returns null
        # (BuildingComp.java:984-986). The sensor spellings are
        # the LAccess enum names (LAccess.java:8 `firstItem,`;
        # :63 `type,`; :69 `payloadType,`; :83 `config(true,
        # "to"),`). There is no driver tick line: senseObject
        # is a logic read, not a tick write (the N2223 sense /
        # N2230 setStats precedent).
        self.assertIn('static func source_repair_turret_sense_object_state(sensor: String, block_id: String) -> Dictionary:', repair_turret)
        self.assertIn('return {"handled": true, "sense_object": block_id, "is_no_sensed": false}', repair_turret)
        self.assertIn('return {"handled": true, "sense_object": null, "is_no_sensed": false}', repair_turret)
        self.assertIn('return {"handled": false, "sense_object": null, "is_no_sensed": true}', repair_turret)
        for expr in [
            'public Object senseObject(LAccess sensor){',
            'case type -> block;',
            'case firstItem -> items == null ? null : items.first();',
            'case config -> block.configSenseable() ? config() : null;',
            'case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null;',
            'default -> noSensed;',
            'public boolean configSenseable(){',
            'return configurations.containsKey(Item.class) || configurations.containsKey(Liquid.class) || configurations.containsKey(UnlockableContent.class) ||',
            'public ObjectMap<Class<?>, Cons2> configurations = new ObjectMap<>();',
            'public @NoPatch boolean hasItems;',
            'if(block.hasItems) items = new ItemModule();',
            'public @Nullable Payload getPayload(){',
            'Object noSensed = new Object();',
            'public class RepairTurret extends Block{',
            'public class RepairPointBuild extends Building implements Ranged, RotBlock{',
            'repairPoint = new RepairTurret("repair-point"){{',
            'repairTurret = new RepairTurret("repair-turret"){{',
            '    type,',
            '    firstItem,',
            '    config(true, "to"),',
            '    payloadType,',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_turret)
        driver_start = repair_turret.index('static func source_repair_turret_tick_buildings_state')
        driver_end = repair_turret.find('\nstatic func ', driver_start + 1)
        driver_body = repair_turret[driver_start:driver_end if driver_end != -1 else len(repair_turret)]
        self.assertNotIn('source_repair_turret_sense_object_state', driver_body)
        # The proof's keys drive the pure function with the two
        # catalog block ids and the three null legs, plus the
        # unhandled-sensor sentinel and the no-driver-tick-line
        # check (the proof reads the state script source and
        # greps the driver body -- a runtime check, not a
        # hardcoded true).
        proof = REPAIR_TURRET_SENSE_OBJECT_PROOF.read_text(encoding='utf-8')
        for key in [
            'sense_object_type_repair_point',
            'sense_object_type_repair_turret',
            'sense_object_first_item_null',
            'sense_object_config_null',
            'sense_object_payload_type_null',
            'sense_object_unknown_is_no_sensed',
            'has_no_driver_tick_line',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_sense_object(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretSenseObjectProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_SENSE_OBJECT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sense_object_type_repair_point',
            'sense_object_type_repair_turret',
            'sense_object_first_item_null',
            'sense_object_config_null',
            'sense_object_payload_type_null',
            'sense_object_unknown_is_no_sensed',
            'has_no_driver_tick_line',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
