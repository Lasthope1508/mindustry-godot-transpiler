import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
ITEM_TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceItemTurretBuildState.gd'
TURRET_CONTROLLED_STAMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretControlledStampProof.gd'


class C07TurretControlledStampTests(unittest.TestCase):
    def test_c07_turret_controlled_stamp_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2523']['godot_owner'], 'SourceTurretBuildState.source_turret_controlled_stamp_state')
        # controlled() is `public boolean controlled(){` /
        # `return unit.isPlayer();` (Turret.java:441-443), on
        # the unit `public BlockUnitc unit =
        # (BlockUnitc)UnitTypes.block.create(team);` (:291).
        # It rescues validateTarget (`return
        # !Units.invalidateTarget(target, canHeal() ?
        # Team.derelict : team, x, y) || controlled() ||
        # logicControlled();`, :631-633, N2251), picks the
        # player branch of isShooting (`isShooting =
        # alwaysShooting || (unit.controller() instanceof
        # Player ? unit.isShooting() : logicControlled() ?
        # logicShooting : target != null);`, :492, N2277)
        # and gates the warmup hold (`if(warmupTarget > 0 &&
        # !controlled()){` / `warmupHold = 1f;`, :503,
        # N2253) -- but the driver validate / isShooting /
        # warmup calls passed `bool(frame.get("controlled",
        # false))` while frame["controlled"] was NEVER
        # stamped anywhere, so the three readers always saw
        # the absent default. This slice ports the one-line
        # Java method as a pure stamp function and stamps it
        # live on the frame right before the validate call
        # (the N2278 logicControlled precedent). The tick
        # reads the live `unit_is_player` frame input (absent
        # today, so false: the port has NO player unit -- every
        # turret unit is the BlockUnitc from
        # UnitTypes.block.create(team) (:291), PortGame.gd
        # carries no player, and the proxy unit has no player
        # controller attached -- so unit.isPlayer() is false
        # for every live turret (the N2520 unit_sense_value =
        # 0.0 precedent). One new result symbol: controlled.
        # The ported method is TurretBuild.controlled(), so
        # the java_source is Turret.java and the slice mirrors
        # into the defense shard (210/209 -> 211/210); comp
        # stays 572/475.
        self.assertEqual(
            ledger['N2523']['source_symbols'],
            [
                'source_turret_controlled_stamp_state_result.controlled',
            ],
        )
        for name in ledger['N2523']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_controlled_stamp_state')
        self.assertEqual(ledger['N2523']['runtime_proof'], '/root/C07TurretControlledStampProof')
        self.assertEqual(
            ledger['N2523']['tests'],
            [
                'test_c07_turret_controlled_stamp_registration',
                'test_all_c07_turret_controlled_stamp_input_evidence_is_exact',
                'test_turret_controlled_stamp_state',
                'test_reference_graph_and_actual_c07_turret_controlled_stamp',
            ],
        )
        self.assertTrue(ledger['N2523']['deferred_exprs'])

    def test_all_c07_turret_controlled_stamp_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2523']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_controlled_stamp_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2523']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_controlled_stamp_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # controlled() (Turret.java:441-443) is the one-line
        # predicate on the turret's own unit (:291):
        # `public boolean controlled(){ return unit.isPlayer();
        # }`. The pure stamp function takes the bool (named
        # `unit_is_player`, the existing SSOT/port name --
        # `source_turret_control_state` :1852 and
        # `source_turret_is_shooting_state` :1321) and writes
        # exactly one key, `frame["controlled"]`, returning
        # the frame (the N2108 tick-frame precedent). The
        # driver tick runs immediately AFTER the N2278
        # logic_controlled stamp and right BEFORE the
        # validateTarget call (Java order :491 validate reads
        # it, so the stamp must run before validate -- the
        # same position rule as N2278), reading the live
        # `unit_is_player` frame input (absent today, so
        # false -- no player unit in the port -- the N2278
        # `logic_control_time` precedent: the input drives
        # the stamp instead of the stamp overwriting it).
        # The validate / isShooting / warmup calls themselves
        # are UNCHANGED -- they just stop reading an absent
        # key, and their values are identical on all current
        # frames (absent default false == stamped false).
        self.assertIn('static func source_turret_controlled_stamp_state(frame: Dictionary, unit_is_player: bool) -> Dictionary:', turret)
        self.assertIn('frame["controlled"] = unit_is_player', turret)
        self.assertIn('return frame', turret)
        self.assertIn('public boolean controlled(){', turret)
        self.assertIn('return unit.isPlayer();', turret)
        self.assertIn('public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);', turret)
        # The pure function sits immediately AFTER
        # source_turret_logic_controlled_state (mirroring Java
        # order :441-443 controlled before :445-447
        # logicControlled).
        self.assertLess(turret.index('static func source_turret_logic_controlled_state('), turret.index('static func source_turret_controlled_stamp_state('))
        self.assertLess(turret.index('static func source_turret_controlled_stamp_state('), turret.index('static func source_turret_sense_state('))
        # The tick call site sits inside
        # source_turret_tick_buildings_state, right after the
        # N2278 logic_controlled stamp call and before the
        # validateTarget call.
        tick = turret[turret.index('static func source_turret_tick_buildings_state('):]
        self.assertLess(tick.index('var logic_controlled_state: Dictionary = source_turret_logic_controlled_state(float(frame.get("logic_control_time", -1.0)))'), tick.index('var controlled_state: Dictionary = source_turret_controlled_stamp_state(frame, bool(frame.get("unit_is_player", false)))'))
        self.assertLess(tick.index('var controlled_state: Dictionary = source_turret_controlled_stamp_state(frame, bool(frame.get("unit_is_player", false)))'), tick.index('var validate: Dictionary = source_item_turret_build_state.source_item_turret_validate_target_state('))
        self.assertIn('frame["controlled"] = controlled_state.get("controlled", false)', tick)
        # The three readers are UNCHANGED by this slice: the
        # validate / isShooting / warmup calls still read the
        # frame key with the same false default.
        self.assertIn('bool(frame.get("controlled", false)),', turret)
        self.assertIn('source_turret_is_shooting_state(false, bool(frame.get("controlled", false)), false,', turret)
        self.assertIn('bool(frame.get("controlled", false)), float(frame.get("efficiency", 1.0)), seconds, 0.1, false, 0.0)', turret)
        # The validateTarget formula itself lives on the N2251
        # pure function (SourceItemTurretBuildState.gd), whose
        # verdict the driver tick feeds.
        item_turret = ITEM_TURRET_BUILD_STATE.read_text(encoding='utf-8')
        self.assertIn('return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();', item_turret)
        # The proof's keys drive the stamp through the pure
        # function and the real driver (false stamps false /
        # true stamps true / the stamp composes with validate
        # so a controlled duo keeps an otherwise-invalid
        # target / the player branch of isShooting reads the
        # stamped key / the :503 warmup hold is skipped for a
        # controlled turret).
        proof = TURRET_CONTROLLED_STAMP_PROOF.read_text(encoding='utf-8')
        for key in [
            'controlled_stamp_false',
            'controlled_stamp_true',
            'controlled_stamp_composed_validate',
            'controlled_is_shooting_player_branch',
            'controlled_warmup_hold_skipped',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_controlled_stamp(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretControlledStampProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_CONTROLLED_STAMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'controlled_stamp_false',
            'controlled_stamp_true',
            'controlled_stamp_composed_validate',
            'controlled_is_shooting_player_branch',
            'controlled_warmup_hold_skipped',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
