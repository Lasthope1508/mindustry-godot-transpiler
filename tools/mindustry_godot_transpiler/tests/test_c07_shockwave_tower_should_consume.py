import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerShouldConsumeProof.gd'


class C07ShockwaveTowerShouldConsumeTests(unittest.TestCase):
    def test_c07_shockwave_tower_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2193']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_should_consume_state')
        # N2177 folded power-only for the shockwave tower: a pure
        # power row over the stamped frame value, folded by the
        # shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) in its own driver. But
        # ShockwaveTowerBuild DOES override shouldConsume:
        # `return reloadCounter < reload;`
        # (ShockwaveTower.java:122), and updateConsumption forces
        # efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992-1993,
        # `if(!update){` / `efficiency = optionalEfficiency =
        # 0f;`). N2177 deferred the gate with a documented limit
        # (the PointDefenseTurret N2151 precedent): the port
        # tracked no live reload counter on any placed-building
        # frame, so with a fully charged tower power.status reads
        # 1.0 while Java efficiency is 0 -- the observable gap is
        # efficiency 1.0 vs 0.0 when fully reloaded. N2192 stamped
        # the prerequisite counter: the charge advance is the ONLY
        # writer of `reload_counter` (ShockwaveTower.java:73,
        # `if(potentialEfficiency > 0 && (reloadCounter +=
        # edelta()) >= reload && timer(timerCheck,
        # checkInterval)){`), and the driver stamps it every tick
        # after apply_update_consumption_state. N2193 closes the
        # gap with one pure function over that one frame key
        # (`reload_counter`, float): the gate is the same
        # expression over the observed counter, `reloadCounter <
        # reload`, read as `float(reload_counter) < 80.0 and
        # enabled` against the per-def reload 80f
        # (Blocks.java:2044, overriding the class default `60f *
        # 1.5f`, ShockwaveTower.java:26). RED decision (pinned by
        # this slice, the proof's fourth key -- the N2191
        # `targets_count` precedent): when the frame carries NO
        # `reload_counter` key, preserve the N2177 behavior
        # (`should_consume = enabled`) -- null means "no
        # observation yet", not "fully charged", because the N2192
        # charge stamps `reload_counter` only after the first
        # consumption stamp each tick, and defaulting absent to
        # false would zero efficiency for every live shockwave
        # tower before its first charge tick, a live regression
        # against N2177 GREEN. It also matches the Java init:
        # `reloadCounter = Mathf.random(reload);`
        # (ShockwaveTower.java:67) is always < reload, so at Java
        # init the gate is true when enabled. The gate therefore
        # activates once the charge stamps `reload_counter` from
        # the live counter. One new result symbol: the gate
        # itself.
        self.assertEqual(
            ledger['N2193']['source_symbols'],
            [
                'source_shockwave_tower_should_consume_state_result.should_consume',
            ],
        )
        for name in ledger['N2193']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_should_consume_state_result.should_consume': 'SourceShockwaveTowerBuildState.source_shockwave_tower_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2193']['runtime_proof'], '/root/C07ShockwaveTowerShouldConsumeProof')
        self.assertEqual(
            ledger['N2193']['tests'],
            [
                'test_c07_shockwave_tower_should_consume_registration',
                'test_all_c07_shockwave_tower_should_consume_input_evidence_is_exact',
                'test_shockwave_tower_should_consume_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_should_consume',
            ],
        )
        self.assertTrue(ledger['N2193']['deferred_exprs'])

    def test_all_c07_shockwave_tower_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2193']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_should_consume_state_result.should_consume': 'SourceShockwaveTowerBuildState.source_shockwave_tower_should_consume_state',
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
        for expr in ledger['N2193']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_should_consume_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The pure shouldConsume gate lives on the shockwave-tower
        # build state: ShockwaveTowerBuild overrides shouldConsume
        # (ShockwaveTower.java:121, `public boolean
        # shouldConsume(){` with `return reloadCounter < reload;`,
        # ShockwaveTower.java:122) over the reload counter
        # (ShockwaveTower.java:67, `public float reloadCounter =
        # Mathf.random(reload);`), which the charge advance alone
        # writes (ShockwaveTower.java:73, `if(potentialEfficiency
        # > 0 && (reloadCounter += edelta()) >= reload &&
        # timer(timerCheck, checkInterval)){`), and
        # updateConsumption forces efficiency to zero when the
        # gate is false (BuildingComp.java:1960, `boolean update
        # = shouldConsume() && productionValid();` + 1992,
        # `if(!update){` + 1993, `efficiency =
        # optionalEfficiency = 0f;`). The gate matters because
        # with a fully charged tower Java efficiency is 0 while
        # the port folds power-only and reports 1.0 -- the N2177
        # gap this slice closes once the frame carries the N2192
        # stamped counter. A missing power stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`), and the
        # power consumer counts toward hasConsumers
        # (Block.java:1449, `hasConsumers = consumers.length >
        # 0;`); edelta() is efficiency * delta
        # (BuildingComp.java:1928, `return efficiency * delta();`).
        # The shockwave tower's power draw is STATIC, not
        # conditional: `consumePower(100f / 60f);`
        # (Blocks.java:2042) registers a plain ConsumePower, so
        # the row read is the plain one (ConsumePower.java:39,
        # `return build.power.status;`) -- no RepairTurret-style
        # ConsumePowerCondition adaptation. The gate reads the
        # potentialEfficiency stamped by THIS tick's
        # updateConsumption (BuildingComp.java:1989,
        # `potentialEfficiency = efficiency;`) only through the
        # charge, not directly: the shouldConsume gate reads the
        # counter the charge last stamped, so the driver calls
        # the pure gate BEFORE the consumption setup (the Java
        # order, updateConsumption :2274 reads shouldConsume() at
        # :1960) and AFTER the previous tick's charge stamped
        # `reload_counter`. The per-def reload is 80f
        # (Blocks.java:2044), overriding the class default `60f *
        # 1.5f` (ShockwaveTower.java:26), so the gate threshold
        # the counter runs against is 80f.
        self.assertIn('static func source_shockwave_tower_should_consume_state', shockwave_tower)
        # The four gate cases, pinned as the pure function's
        # decision structure: the frame carries the live counter
        # as `reload_counter` (float, stamped by the N2192 charge
        # every tick after apply_update_consumption_state); the
        # function reads it with a null default, so an absent
        # key means "no observation yet", not "fully charged".
        # reload_counter=10.0 (< 80f) with enabled passes the
        # gate (should_consume true); reload_counter=80.0 (at
        # reload, not < reload) blocks it (should_consume
        # false); reload_counter=10.0 with enabled=false blocks
        # it (should_consume false) -- all three observed cases
        # run through the one conjunction, `float(observed) <
        # 80.0 and enabled`; NO reload_counter key preserves the
        # N2177 behavior, `should_consume = enabled`.
        self.assertIn('frame.get("reload_counter", null)', shockwave_tower)
        with self.subTest(case='reload_counter=10.0 below reload passes the gate'):
            self.assertIn('float(observed) < 80.0 and enabled', shockwave_tower)
        with self.subTest(case='reload_counter=80.0 at reload blocks the gate'):
            self.assertIn('float(observed) < 80.0 and enabled', shockwave_tower)
        with self.subTest(case='reload_counter=10.0 with enabled=false blocks the gate'):
            self.assertIn('float(observed) < 80.0 and enabled', shockwave_tower)
        with self.subTest(case='no reload_counter key preserves N2177 behavior'):
            self.assertIn('return {"should_consume": enabled}', shockwave_tower)
        self.assertIn('public boolean shouldConsume(){', shockwave_tower)
        self.assertIn('return reloadCounter < reload;', shockwave_tower)
        self.assertIn('public float reloadCounter = Mathf.random(reload);', shockwave_tower)
        self.assertIn('if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', shockwave_tower)
        self.assertIn('boolean update = shouldConsume() && productionValid();', shockwave_tower)
        self.assertIn('if(!update){', shockwave_tower)
        self.assertIn('efficiency = optionalEfficiency = 0f;', shockwave_tower)
        self.assertIn('return efficiency * delta();', shockwave_tower)
        self.assertIn('return build.power.status;', shockwave_tower)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', shockwave_tower)
        self.assertIn('hasConsumers = consumers.length > 0;', shockwave_tower)
        self.assertIn('consumePower(100f / 60f);', shockwave_tower)
        self.assertIn('consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));', shockwave_tower)
        self.assertIn('range = 170f;', shockwave_tower)
        self.assertIn('reload = 80f;', shockwave_tower)
        self.assertIn('public float reload = 60f * 1.5f;', shockwave_tower)
        self.assertIn('public class ShockwaveTower extends Block{', shockwave_tower)
        self.assertIn('public class ShockwaveTowerBuild extends Building{', shockwave_tower)
        self.assertIn('public float heat = 0f;', shockwave_tower)
        self.assertIn('public void updateTile(){', shockwave_tower)
        self.assertIn('heat = 1f;', shockwave_tower)
        self.assertIn('reloadCounter = 0f;', shockwave_tower)
        self.assertIn('float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);', shockwave_tower)
        self.assertIn('heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);', shockwave_tower)
        self.assertIn('if(sensor == LAccess.progress) return reloadCounter / reload;', shockwave_tower)
        self.assertIn('return heat;', shockwave_tower)
        self.assertIn('public boolean canConsume(){', shockwave_tower)
        self.assertIn('return potentialEfficiency > 0;', shockwave_tower)
        self.assertIn('potentialEfficiency = efficiency;', shockwave_tower)
        self.assertIn('return enabled;', shockwave_tower)
        self.assertIn('source_shockwave_tower_should_consume_state(frame)', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_tick_buildings_state', shockwave_tower)
        # The proof's keys drive the pure gate (passes below
        # reload / blocks at reload / blocks when disabled /
        # absent key preserves the power fold) plus the live tick
        # (the gate overrides the power fold when fully charged /
        # passes below reload at half power). There are no fire /
        # bullet-scan / wave-damage / heat / sense / warmup keys:
        # the fire gate (ShockwaveTower.java:74-103), the heat
        # decay (:104), sense(LAccess.progress) (:110), warmup()
        # (:117) and the cyanogen liquid consumer
        # (Blocks.java:2041) wait for their own slices, and the
        # future fire slice owns the reloadCounter=0 reset (:83).
        proof = SHOCKWAVE_TOWER_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_passes_below_reload',
            'gate_blocks_at_reload',
            'gate_blocks_when_disabled',
            'gate_absent_preserves_power_fold',
            'gate_blocks_when_fully_charged',
            'gate_passes_below_reload_live',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_shockwave_tower_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_passes_below_reload',
            'gate_blocks_at_reload',
            'gate_blocks_when_disabled',
            'gate_absent_preserves_power_fold',
            'gate_blocks_when_fully_charged',
            'gate_passes_below_reload_live',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
