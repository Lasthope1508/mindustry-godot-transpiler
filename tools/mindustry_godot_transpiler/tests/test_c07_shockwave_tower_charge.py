import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_CHARGE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerChargeProof.gd'


class C07ShockwaveTowerChargeTests(unittest.TestCase):
    def test_c07_shockwave_tower_charge_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2192']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_charge_state')
        # N2177 folded power-only for the shockwave tower: a pure
        # power row over the stamped frame value, folded by the
        # shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) in its own driver. But
        # ShockwaveTowerBuild's updateTile charges a reload counter
        # by edelta() before it can fire:
        # `if(potentialEfficiency > 0 && (reloadCounter +=
        # edelta()) >= reload && timer(timerCheck,
        # checkInterval)){` (ShockwaveTower.java:73), and edelta()
        # is efficiency * delta (BuildingComp.java:1927-1929,
        # `return efficiency * delta();`). N2177 deferred the
        # whole updateTile advance with a documented limit (the
        # PointDefenseTurret N2151 precedent): the port tracked
        # no live reload counter on any placed-building frame,
        # so the tower could never charge and never fire. N2192
        # lands ONLY the charge advance -- the prerequisite for
        # the shouldConsume gate (`return reloadCounter <
        # reload;`, ShockwaveTower.java:121-122), which needs a
        # live counter to read. The charge is one pure function
        # over the frame keys the N2177 machinery stamps
        # (`potential_efficiency` and `efficiency`, via
        # apply_update_consumption_state): the gate reads
        # potentialEfficiency, the increment reads efficiency *
        # delta. RED decision (pinned by this slice, the N2190
        # RepairTower refresh precedent): when the frame carries
        # NO `reload_counter` key, start from deterministic 0.0
        # -- Java inits `reloadCounter = Mathf.random(reload);`
        # (ShockwaveTower.java:67), but the port takes the
        # deterministic 0.0 start, never `randf` in game code
        # (the C06DefenseProof lesson: seeded RNG only in proof
        # scenes). RED decision (pinned by this slice): NO clamp
        # at reload -- Java keeps accumulating past reload until
        # a successful fire resets the counter to 0
        # (ShockwaveTower.java:83, `reloadCounter = 0f;`), so a
        # counter past reload stays, with no reset without fire.
        # One new result symbol: the charged counter itself.
        self.assertEqual(
            ledger['N2192']['source_symbols'],
            [
                'source_shockwave_tower_charge_state_result.reload_counter',
            ],
        )
        for name in ledger['N2192']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_charge_state_result.reload_counter': 'SourceShockwaveTowerBuildState.source_shockwave_tower_charge_state',
                }[name])
        self.assertEqual(ledger['N2192']['runtime_proof'], '/root/C07ShockwaveTowerChargeProof')
        self.assertEqual(
            ledger['N2192']['tests'],
            [
                'test_c07_shockwave_tower_charge_registration',
                'test_all_c07_shockwave_tower_charge_input_evidence_is_exact',
                'test_shockwave_tower_charge_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_charge',
            ],
        )
        self.assertTrue(ledger['N2192']['deferred_exprs'])

    def test_all_c07_shockwave_tower_charge_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2192']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_charge_state_result.reload_counter': 'SourceShockwaveTowerBuildState.source_shockwave_tower_charge_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2192']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_charge_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The pure charge advance lives on the shockwave-tower
        # build state: ShockwaveTowerBuild.updateTile charges its
        # reload counter by edelta() when it has potential
        # efficiency (ShockwaveTower.java:73,
        # `if(potentialEfficiency > 0 && (reloadCounter +=
        # edelta()) >= reload && timer(timerCheck,
        # checkInterval)){`), and edelta() is efficiency * delta
        # (BuildingComp.java:1927-1929, `return efficiency *
        # delta();`). The gate reads the potentialEfficiency
        # stamped by THIS tick's updateConsumption
        # (BuildingComp.java:1989, `potentialEfficiency =
        # efficiency;`) -- the pre-gate min efficiency (the power
        # .status fold) -- and canConsume is the same gate
        # (BuildingComp.java:1917, `public boolean canConsume(){`
        # with `return potentialEfficiency > 0;`,
        # BuildingComp.java:1918). updateConsumption forces
        # efficiency to zero when the shouldConsume gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){` + 1993, `efficiency =
        # optionalEfficiency = 0f;`), and the shouldConsume
        # default is `return enabled;`
        # (BuildingComp.java:755-756). A missing power stamp folds
        # to 1.0 before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`), and the
        # power consumer counts toward hasConsumers
        # (Block.java:1449, `hasConsumers = consumers.length >
        # 0;`); the power row read is the plain one
        # (ConsumePower.java:39, `return build.power.status;`).
        # The shockwave tower's power draw is STATIC, not
        # conditional: `consumePower(100f / 60f);`
        # (Blocks.java:2042) registers a plain ConsumePower, and
        # the second, deferred liquid consumer is
        # `consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f
        # / 60f));` (Blocks.java:2041). Single def --
        # shockwave-tower only (size 3, range 170f, reload 80f,
        # surge-alloy 50 / silicon 150 / oxide 30 / tungsten 100,
        # Blocks.java:2038-2044); the class default reload is
        # `public float reload = 60f * 1.5f;`
        # (ShockwaveTower.java:26) and the per-def reload 80f
        # overrides it, so the charge threshold the counter runs
        # against is 80f.
        self.assertIn('static func source_shockwave_tower_charge_state', shockwave_tower)
        # The charge cases, pinned as the pure function's
        # decision structure: the frame carries the live counter
        # as `reload_counter` (float); the function reads it
        # with a deterministic 0.0 default, so an absent key
        # starts at zero (Java inits `public float
        # reloadCounter = Mathf.random(reload);`,
        # ShockwaveTower.java:67 -- the port takes the
        # deterministic 0.0 start, the N2190 precedent, never
        # `randf` in game code). The gate reads the stamped
        # `potential_efficiency` (0.0 when absent -- no advance
        # before the first consumption stamp); when it is > 0
        # the counter advances by the stamped `efficiency` *
        # delta, and when it is 0 the counter is unchanged.
        # There is NO clamp at reload and NO reset without fire:
        # a counter past reload stays past reload (Java resets
        # only on a successful fire, ShockwaveTower.java:83,
        # `reloadCounter = 0f;`, with `heat = 1f;`,
        # ShockwaveTower.java:82, and the wave damage line,
        # ShockwaveTower.java:87, `float waveDamage =
        # Math.min(bulletDamage, bulletDamage * falloffCount /
        # targets.size);`).
        self.assertIn('frame.get("reload_counter", 0.0)', shockwave_tower)
        self.assertIn('frame.get("potential_efficiency", 0.0)', shockwave_tower)
        self.assertIn('frame.get("efficiency", 0.0)', shockwave_tower)
        self.assertIn('potential_efficiency > 0.0', shockwave_tower)
        self.assertIn('return {"reload_counter": reload_counter}', shockwave_tower)
        self.assertIn('source_shockwave_tower_charge_state(frame, seconds)', shockwave_tower)
        self.assertIn('public float reloadCounter = Mathf.random(reload);', shockwave_tower)
        self.assertIn('if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', shockwave_tower)
        self.assertIn('return efficiency * delta();', shockwave_tower)
        self.assertIn('public boolean canConsume(){', shockwave_tower)
        self.assertIn('return potentialEfficiency > 0;', shockwave_tower)
        self.assertIn('potentialEfficiency = efficiency;', shockwave_tower)
        self.assertIn('boolean update = shouldConsume() && productionValid();', shockwave_tower)
        self.assertIn('if(!update){', shockwave_tower)
        self.assertIn('efficiency = optionalEfficiency = 0f;', shockwave_tower)
        self.assertIn('return enabled;', shockwave_tower)
        self.assertIn('return build.power.status;', shockwave_tower)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', shockwave_tower)
        self.assertIn('hasConsumers = consumers.length > 0;', shockwave_tower)
        self.assertIn('consumePower(100f / 60f);', shockwave_tower)
        self.assertIn('consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));', shockwave_tower)
        self.assertIn('range = 170f;', shockwave_tower)
        self.assertIn('reload = 80f;', shockwave_tower)
        self.assertIn('public class ShockwaveTower extends Block{', shockwave_tower)
        self.assertIn('public class ShockwaveTowerBuild extends Building{', shockwave_tower)
        self.assertIn('public int timerCheck = timers ++;', shockwave_tower)
        self.assertIn('public float range = 110f;', shockwave_tower)
        self.assertIn('public float reload = 60f * 1.5f;', shockwave_tower)
        self.assertIn('public float bulletDamage = 160;', shockwave_tower)
        self.assertIn('public float falloffCount = 20f;', shockwave_tower)
        self.assertIn('public float shake = 2f;', shockwave_tower)
        self.assertIn('public float checkInterval = 8f;', shockwave_tower)
        self.assertIn('public float cooldownMultiplier = 1f;', shockwave_tower)
        self.assertIn('update = true;', shockwave_tower)
        self.assertIn('solid = true;', shockwave_tower)
        self.assertIn('public float heat = 0f;', shockwave_tower)
        self.assertIn('public void updateTile(){', shockwave_tower)
        self.assertIn('heat = 1f;', shockwave_tower)
        self.assertIn('reloadCounter = 0f;', shockwave_tower)
        self.assertIn('float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);', shockwave_tower)
        self.assertIn('heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);', shockwave_tower)
        self.assertIn('if(sensor == LAccess.progress) return reloadCounter / reload;', shockwave_tower)
        self.assertIn('return heat;', shockwave_tower)
        self.assertIn('public boolean shouldConsume(){', shockwave_tower)
        self.assertIn('return reloadCounter < reload;', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_tick_buildings_state', shockwave_tower)
        # The proof's keys drive the pure charge (advances at
        # full efficiency / frozen without power / scales with
        # partial efficiency / accumulates past reload without
        # fire / absent counter starts zero) plus the live tick
        # (the driver stamps the charged counter on the frame).
        # There are no fire / bullet-scan / wave-damage / heat /
        # sense / warmup keys: the fire gate (ShockwaveTower.java
        # :74-103), the heat decay (:104), sense(LAccess.progress)
        # (:110), warmup() (:117) and the shouldConsume gate
        # (:121-122) wait for their own slices -- this slice is
        # ONLY the charge `reloadCounter += edelta()` gated on
        # `potentialEfficiency > 0`.
        proof = SHOCKWAVE_TOWER_CHARGE_PROOF.read_text(encoding='utf-8')
        for key in [
            'charge_advances_at_full_efficiency',
            'charge_frozen_without_power',
            'charge_scales_with_partial_efficiency',
            'charge_accumulates_past_reload_without_fire',
            'charge_absent_counter_starts_zero',
            'charge_driver_stamps_counter',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_shockwave_tower_charge(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerChargeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_CHARGE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'charge_advances_at_full_efficiency',
            'charge_frozen_without_power',
            'charge_scales_with_partial_efficiency',
            'charge_accumulates_past_reload_without_fire',
            'charge_absent_counter_starts_zero',
            'charge_driver_stamps_counter',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
