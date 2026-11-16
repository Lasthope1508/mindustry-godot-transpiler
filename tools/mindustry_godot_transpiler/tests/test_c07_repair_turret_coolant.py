import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_COOLANT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretCoolantProof.gd'


class C07RepairTurretCoolantTests(unittest.TestCase):
    def test_c07_repair_turret_coolant_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2209']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_coolant_multiplier_state')
        # N2174 folded power-only for the repair turret and
        # deferred the coolant optional consumer with a
        # documented limit (the tick models the power row only;
        # the coolant row waits for its own slice, so the folded
        # efficiency is the min over the modeled consumers --
        # power only). N2188 then wired the shouldConsume gate.
        # RepairPointBuild.updateTile computes the heal
        # multiplier as `float multiplier = 1f;` then
        # `if(acceptCoolant){ multiplier = 1f +
        # liquids.current().heatCapacity * coolantMultiplier *
        # optionalEfficiency; }` (RepairTurret.java:188-190),
        # and heals with it: `target.heal(repairSpeed *
        # strength * edelta() * multiplier);`
        # (RepairTurret.java:207). The coolant consumer is
        # registered in init() only when the block accepts
        # coolant: `if(acceptCoolant){ hasLiquids = true;
        # consume(new ConsumeCoolant(coolantUse)).optional(true,
        # true); }` (RepairTurret.java:84-86) -- an OPTIONAL
        # consumer, so its efficiency folds into
        # optionalEfficiency in the optional pass
        # (BuildingComp.java:1979-1981,
        # `optionalEfficiency = Math.min(optionalEfficiency,
        # cons.efficiency(self()));`), which updateConsumption
        # initializes to 1f before the pass
        # (BuildingComp.java:1965, `efficiency =
        # optionalEfficiency = 1f;`). Per-def, only
        # repair-turret accepts coolant: coolantUse 0.16f,
        # coolantMultiplier 1.6f, acceptCoolant true
        # (Blocks.java:6404-6406); class defaults are
        # coolantUse 0.5f, coolantMultiplier 1f,
        # acceptCoolant false (RepairTurret.java:39-45), so
        # repair-point never boosts. N2209 closes the
        # deferred coolant item with one pure function over
        # two frame keys (`liquids_current_heat_capacity` and
        # `optional_efficiency`) plus the per-def
        # accept_coolant and coolant_multiplier params. RED
        # decisions (pinned by this slice): accept_coolant
        # false returns 1.0 (the Java `if(acceptCoolant){`
        # guard leaves multiplier at 1f); an absent
        # `liquids_current_heat_capacity` key reads 0.0 (no
        # current coolant liquid observed yet -- the future
        # liquid-state slice stamps it from
        # `liquids.current().heatCapacity`); an absent
        # `optional_efficiency` key reads 1.0 (the pre-pass
        # init, BuildingComp.java:1965); coolantUse is NOT a
        # parameter (it belongs to the ConsumeCoolant
        # consumer's efficiency/update -- the optional coolant
        # row that folds optionalEfficiency from the liquid
        # amount -- which waits for its own slice); NO driver
        # tick line (the multiplier feeds the updateTile heal
        # advance, which waits for its own slice -- the N2208
        # precedent). One new result symbol: the heal
        # multiplier itself.
        self.assertEqual(
            ledger['N2209']['source_symbols'],
            [
                'source_repair_turret_coolant_multiplier_state_result.heal_multiplier',
            ],
        )
        for name in ledger['N2209']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_turret_coolant_multiplier_state_result.heal_multiplier': 'SourceRepairTurretBuildState.source_repair_turret_coolant_multiplier_state',
                }[name])
        self.assertEqual(ledger['N2209']['runtime_proof'], '/root/C07RepairTurretCoolantProof')
        self.assertEqual(
            ledger['N2209']['tests'],
            [
                'test_c07_repair_turret_coolant_registration',
                'test_all_c07_repair_turret_coolant_input_evidence_is_exact',
                'test_repair_turret_coolant_multiplier_state',
                'test_reference_graph_and_actual_c07_repair_turret_coolant',
            ],
        )
        self.assertTrue(ledger['N2209']['deferred_exprs'])

    def test_all_c07_repair_turret_coolant_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2209']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_turret_coolant_multiplier_state_result.heal_multiplier': 'SourceRepairTurretBuildState.source_repair_turret_coolant_multiplier_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/world/consumers/ConsumeCoolant.java',
            'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
            'core/src/mindustry/type/Liquid.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2209']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_coolant_multiplier_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # The pure coolant multiplier lives on the repair-turret
        # build state: RepairPointBuild.updateTile computes
        # `float multiplier = 1f;` then `if(acceptCoolant){
        # multiplier = 1f + liquids.current().heatCapacity *
        # coolantMultiplier * optionalEfficiency; }`
        # (RepairTurret.java:188-190), and heals with it:
        # `target.heal(repairSpeed * strength * edelta() *
        # multiplier);` (RepairTurret.java:207). The coolant
        # consumer is optional (`consume(new
        # ConsumeCoolant(coolantUse)).optional(true, true);`,
        # RepairTurret.java:86), so its efficiency folds into
        # optionalEfficiency in the optional pass
        # (BuildingComp.java:1979-1981,
        # `optionalEfficiency = Math.min(optionalEfficiency,
        # cons.efficiency(self()));`), which updateConsumption
        # initializes to 1f before the pass
        # (BuildingComp.java:1965, `efficiency =
        # optionalEfficiency = 1f;`). Java's `current()` can
        # never be null in practice (`private Liquid current =
        # content.liquid(0);`, LiquidModule.java:24), but the
        # port frame carries no liquid observation yet, and
        # absent means "no observation", not "a liquid with
        # zero heat capacity" -- the observable (multiplier
        # 1.0) is the same either way.
        self.assertIn('static func source_repair_turret_coolant_multiplier_state', repair_turret)
        # The multiplier cases, pinned as the pure function's
        # decision structure: the frame carries the current
        # liquid's heat capacity as
        # `liquids_current_heat_capacity` (float) and the
        # folded optional efficiency as `optional_efficiency`
        # (float); accept_coolant=false returns 1.0 with
        # coolant_active false; accept_coolant=true returns
        # `1.0 + heat_capacity * coolant_multiplier *
        # optional_efficiency` with coolant_active true. An
        # absent heat-capacity key reads 0.0 (no boost); an
        # absent optional_efficiency key reads 1.0 (the
        # pre-pass init).
        self.assertIn('frame.get("liquids_current_heat_capacity", 0.0)', repair_turret)
        self.assertIn('frame.get("optional_efficiency", 1.0)', repair_turret)
        with self.subTest(case='accept_coolant=false returns 1.0'):
            self.assertIn('if not accept_coolant:', repair_turret)
            self.assertIn('return {"heal_multiplier": 1.0, "coolant_active": false}', repair_turret)
        with self.subTest(case='accept_coolant=true applies the heat-capacity boost'):
            self.assertIn('1.0 + heat_capacity * coolant_multiplier * optional_efficiency', repair_turret)
        self.assertIn('multiplier = 1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency;', repair_turret)
        self.assertIn('public boolean acceptCoolant = false;', repair_turret)
        self.assertIn('public float coolantMultiplier = 1f;', repair_turret)
        self.assertIn('coolantUse = 0.16f;', repair_turret)
        self.assertIn('coolantMultiplier = 1.6f;', repair_turret)
        self.assertIn('acceptCoolant = true;', repair_turret)
        self.assertIn('consume(new ConsumeCoolant(coolantUse)).optional(true, true);', repair_turret)
        self.assertIn('optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));', repair_turret)
        self.assertIn('efficiency = optionalEfficiency = 1f;', repair_turret)
        self.assertIn('private Liquid current = content.liquid(0);', repair_turret)
        self.assertIn('target.heal(repairSpeed * strength * edelta() * multiplier);', repair_turret)
        # The proof's keys drive the pure multiplier (no boost
        # without coolant / boost with coolant / scales with
        # optionalEfficiency / no boost without liquid / absent
        # optional_efficiency defaults to 1.0 / no boost when
        # optionalEfficiency is zero). There are no heal /
        # strength / rotation / target-acquisition keys: the
        # updateTile heal advance (RepairTurret.java:187-218)
        # waits for its own slice, and the optional coolant
        # row (liquid amount -> optionalEfficiency) waits for
        # its own slice.
        proof = REPAIR_TURRET_COOLANT_PROOF.read_text(encoding='utf-8')
        for key in [
            'multiplier_one_without_coolant',
            'multiplier_boost_with_coolant',
            'multiplier_scales_with_optional_efficiency',
            'multiplier_one_without_liquid',
            'multiplier_absent_optional_efficiency_defaults_one',
            'multiplier_one_when_optional_efficiency_zero',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_coolant(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretCoolantProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_COOLANT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'multiplier_one_without_coolant',
            'multiplier_boost_with_coolant',
            'multiplier_scales_with_optional_efficiency',
            'multiplier_one_without_liquid',
            'multiplier_absent_optional_efficiency_defaults_one',
            'multiplier_one_when_optional_efficiency_zero',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
