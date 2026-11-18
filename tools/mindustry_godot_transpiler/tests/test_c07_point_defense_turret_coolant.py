import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
POINT_DEFENSE_STATE = ROOT / 'godot-mindustry/src/game/SourcePointDefenseTurretBuildState.gd'
POINT_DEFENSE_COOLANT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretCoolantProof.gd'


class C07PointDefenseTurretCoolantTests(unittest.TestCase):
    def test_c07_point_defense_turret_coolant_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2248']['godot_owner'], 'SourcePointDefenseTurretBuildState.source_point_defense_turret_coolant_state')
        # N2248 closes the coolant mechanism the earlier
        # PointDefenseTurret slices left behind. The N2241 cooling
        # pure function takes coolant_efficiency as a parameter
        # and returns the reload boost, but nothing in the port
        # computes that efficiency from live liquids, nothing
        # picks the consumed coolant liquid, nothing subtracts
        # it, and the coolEffect chance key is missing
        # (ReloadTurret.java:28-38, `updateCooling()`). One new
        # pure function: the ConsumeCoolant filter
        # (ConsumeCoolant.java:14, `liquid.coolant &&
        # (allowLiquid && !liquid.gas || allowGas && liquid.gas)
        # && temperature <= maxTemp && flammability <
        # maxFlammability`, defaults allowLiquid=true,
        # allowGas=false) over the live liquids dict, then the
        # ConsumeLiquidFilter getConsumed pick
        # (ConsumeLiquidFilter.java:63-79, current liquid first
        # if the filter passes and its amount is > 0, else the
        # first liquid in content order passing the filter with
        # amount > 0), the efficiency
        # (ConsumeLiquidFilter.java:50-56, `min(liquids.get(liq)
        # / (amount * ed * multiplier), 1f)`, 0 when ed <= 1e-8
        # or no liquid), the update removal
        # (ConsumeLiquidFilter.java:44-49, `liquids.remove(liq,
        # amount * edelta * multiplier)` -- the consumer amount
        # field, NOT the efficiency-scaled local amount), the
        # consumed liquid's heatCapacity
        # (ReloadTurret.java:30, the ConsumeLiquidFilter filter
        # branch), and the coolEffect chance key
        # (`Mathf.chance(0.06 * amount)`, ReloadTurret.java:35,
        # a random visual -- the N2240 precedent: the pure
        # function returns the chance, it never rolls). NO
        # driver tick line: the only PointDefenseTurret def,
        # segment (Blocks.java:3835-3846), defines NO coolant
        # consumer, so BaseTurret.init leaves coolant null
        # (`coolant = findConsumer(c -> c instanceof
        # ConsumeCoolant);`, BaseTurret.java:50-52) and the
        # driver call stays the faithful no-op -- and the live
        # driver wiring is BLOCKED on catalog capture anyway
        # (the catalog records consumeCoolant for NO block, not
        # even salvo which defines `coolant =
        # consumeCoolant(0.2f);` at Blocks.java:3831, and its
        # liquid rows carry heatCapacity only, none of coolant
        # / gas / temperature / flammability). Seven new result
        # symbols: consumed_liquid / consumed_index /
        # checked_liquids / coolant_efficiency / heat_capacity /
        # remove_amount / cool_effect_chance.
        self.assertEqual(
            ledger['N2248']['source_symbols'],
            [
                'source_point_defense_turret_coolant_state_result.consumed_liquid',
                'source_point_defense_turret_coolant_state_result.consumed_index',
                'source_point_defense_turret_coolant_state_result.checked_liquids',
                'source_point_defense_turret_coolant_state_result.coolant_efficiency',
                'source_point_defense_turret_coolant_state_result.heat_capacity',
                'source_point_defense_turret_coolant_state_result.remove_amount',
                'source_point_defense_turret_coolant_state_result.cool_effect_chance',
            ],
        )
        for name in ledger['N2248']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumeCoolant.java',
                    'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java',
                    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourcePointDefenseTurretBuildState.source_point_defense_turret_coolant_state')
        self.assertEqual(ledger['N2248']['runtime_proof'], '/root/C07PointDefenseTurretCoolantProof')
        self.assertEqual(
            ledger['N2248']['tests'],
            [
                'test_c07_point_defense_turret_coolant_registration',
                'test_all_c07_point_defense_turret_coolant_input_evidence_is_exact',
                'test_point_defense_turret_coolant',
                'test_reference_graph_and_actual_c07_point_defense_turret_coolant',
            ],
        )
        self.assertTrue(ledger['N2248']['deferred_exprs'])

    def test_all_c07_point_defense_turret_coolant_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2248']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePointDefenseTurretBuildState.source_point_defense_turret_coolant_state')
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeCoolant.java',
            'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java',
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/content/Liquids.java',
            'core/src/mindustry/type/Liquid.java',
            'core/src/mindustry/world/consumers/Consume.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2248']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_point_defense_turret_coolant(self):
        point_defense = POINT_DEFENSE_STATE.read_text(encoding='utf-8')
        # (1) The coolant filter: ConsumeCoolant is a
        # ConsumeLiquidFilter whose filter is the coolant
        # predicate (ConsumeCoolant.java:14), with the (float)
        # constructor defaults allowLiquid=true, allowGas=false
        # (ConsumeCoolant.java:20-22). The pure function takes
        # the live liquids dict (the SourceLiquidModuleState
        # shape, {"liquids": Array[float] by liquid id,
        # "current": int id, "flow": null}) plus synthetic
        # liquid rows in content order ({id, name, coolant,
        # gas, temperature, flammability, heat_capacity} --
        # the catalog cannot supply these rows: its liquid
        # entries carry heatCapacity only, and coolant / gas /
        # temperature / flammability are Java class defaults,
        # Liquid.java:50 `public boolean coolant = true;` /
        # :28 `public boolean gas = false;` / :40 `public float
        # temperature = 0.5f;` / :38 `public float flammability;`
        # (0f), so the rows are proof-supplied, the N2241
        # synthetic-inputs precedent). The filter defaults in
        # the row reads are those same Java defaults.
        self.assertIn('static func source_point_defense_turret_coolant_state(liquids: Dictionary, liquid_rows: Array, coolant_amount: float, edelta: float, multiplier: float) -> Dictionary:', point_defense)
        self.assertIn('var filter_pass: bool = bool(row.get("coolant", true)) and not bool(row.get("gas", false)) and float(row.get("temperature", 0.5)) <= 0.5 and float(row.get("flammability", 0.0)) < 0.1', point_defense)
        self.assertIn('liquid.coolant && (this.allowLiquid && !liquid.gas || this.allowGas && liquid.gas) && liquid.temperature <= maxTemp && liquid.flammability < maxFlammability', point_defense)
        # (2) getConsumed + efficiency + removal + capacity +
        # coolEffect chance: the current liquid wins when its
        # row passes the filter and its amount is > 0
        # (ConsumeLiquidFilter.java:63-66,
        # `if(filter.get(build.liquids.current()) &&
        # build.liquids.currentAmount() > 0){`), else the first
        # liquid in content order passing the filter with amount
        # > 0 (:67-79); efficiency is `min(liquids.get(liq) /
        # (amount * ed * multiplier), 1f)` (:50-56) with the ed
        # guard `ed <= 0.00000001f` (:52) and 0 when no liquid;
        # multiplier defaults to 1f (`public Floatf<Building>
        # multiplier = b -> 1f;`, Consume.java:18); the removal
        # is the consumer amount field times edelta times
        # multiplier (`build.liquids.remove(liq, amount *
        # build.edelta() * multiplier.get(build));`, :44-49) --
        # NOTE this is NOT the efficiency-scaled local amount
        # the N2241 cooling state returns as coolant_consumed
        # (`coolant_consumed = amount * edelta` with `amount =
        # coolant_amount * efficiency`): that N2241 key stays
        # as registered and this slice does NOT change it, the
        # new function returns the Java-exact removal under its
        # own key remove_amount; heatCapacity is the consumed
        # liquid's (`float capacity = coolant instanceof
        # ConsumeLiquidFilter filter ?
        # filter.getConsumed(this).heatCapacity : ...`,
        # ReloadTurret.java:30, the filter branch applies
        # because ConsumeCoolant extends ConsumeLiquidFilter),
        # defaulting to the Liquid.java 0.5f class default when
        # the row omits it; the coolEffect chance is `0.06 *
        # amount` with `amount = coolant.amount *
        # coolant.efficiency(this)` (ReloadTurret.java:31, :35
        # `if(Mathf.chance(0.06 * amount)){`), returned as a
        # key, never rolled (the N2240 precedent).
        self.assertIn('0.00000001', point_defense)
        self.assertIn('coolant_amount * edelta * multiplier', point_defense)
        self.assertIn('float(row.get("heat_capacity", 0.5))', point_defense)
        self.assertIn('0.06 * coolant_amount * coolant_efficiency', point_defense)
        self.assertIn('return {"consumed_liquid": consumed_liquid, "consumed_index": consumed_index, "checked_liquids": checked_liquids, "coolant_efficiency": coolant_efficiency, "heat_capacity": heat_capacity, "remove_amount": remove_amount, "cool_effect_chance": cool_effect_chance}', point_defense)
        self.assertIn('if(Mathf.chance(0.06 * amount)){', point_defense)
        # (3) NO driver tick line (the N2245/N2246 precedent):
        # the driver keeps the faithful no-op call -- segment
        # defines NO coolant consumer (Blocks.java:3835-3846,
        # `segment = new PointDefenseTurret("segment"){{`, only
        # `consumePower(8f);` / `reload = 8f;`), so
        # BaseTurret.init leaves coolant null
        # (`coolant = findConsumer(c -> c instanceof
        # ConsumeCoolant);`, BaseTurret.java:50-52) and
        # `if(coolant != null){ updateCooling(); }`
        # (PointDefenseTurret.java:74-76) never runs for
        # segment. The neighbouring `coolant =
        # consumeCoolant(0.2f);` at Blocks.java:3831 belongs to
        # salvo (ItemTurret, range 190, reload 29, shots 4),
        # NOT segment. Live driver wiring is BLOCKED on a
        # catalog-capture slice: the catalog records
        # consumeCoolant for NO block (salvo's entry has no
        # such key either) and no liquid filter fields.
        self.assertIn('source_point_defense_turret_cooling_state(frame, false, 0.0, 0.0, 0.0, 2.0, 8.0, edelta)', point_defense)
        self.assertIn('coolant = findConsumer(c -> c instanceof ConsumeCoolant);', point_defense)
        self.assertIn('segment = new PointDefenseTurret("segment"){{', point_defense)
        # The proof's keys drive the pure function with
        # synthetic live liquids and synthetic liquid rows
        # (water passes the filter / slag fails on temperature
        # 1.0 / oil fails on flammability 1.2 / ozone fails as
        # a gas / current liquid preferred when present /
        # fallback to the first passing liquid in content order
        # / partial efficiency fraction / zero efficiency with
        # no coolant liquid / removal is amount * edelta *
        # multiplier / coolEffect chance is 0.06 * amount *
        # efficiency / edelta guard at 1e-8 returns 0) plus the
        # driver no-op for a segment with no catalog coolant
        # consumer (reload_counter unchanged, liquids meta
        # untouched).
        proof = POINT_DEFENSE_COOLANT_PROOF.read_text(encoding='utf-8')
        for key in [
            'coolant_filter_passes_water',
            'coolant_filter_rejects_hot_liquid',
            'coolant_filter_rejects_flammable_liquid',
            'coolant_filter_rejects_gas',
            'coolant_prefers_current_liquid',
            'coolant_falls_back_to_first_passing_liquid',
            'coolant_efficiency_partial_fraction',
            'coolant_efficiency_zero_without_liquid',
            'coolant_removes_live_amount',
            'coolant_cool_effect_chance',
            'coolant_edelta_guard_zero',
            'driver_noop_without_catalog_coolant',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_point_defense_turret_coolant(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PointDefenseTurretCoolantProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_POINT_DEFENSE_TURRET_COOLANT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'coolant_filter_passes_water',
            'coolant_filter_rejects_hot_liquid',
            'coolant_filter_rejects_flammable_liquid',
            'coolant_filter_rejects_gas',
            'coolant_prefers_current_liquid',
            'coolant_falls_back_to_first_passing_liquid',
            'coolant_efficiency_partial_fraction',
            'coolant_efficiency_zero_without_liquid',
            'coolant_removes_live_amount',
            'coolant_cool_effect_chance',
            'coolant_edelta_guard_zero',
            'driver_noop_without_catalog_coolant',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
