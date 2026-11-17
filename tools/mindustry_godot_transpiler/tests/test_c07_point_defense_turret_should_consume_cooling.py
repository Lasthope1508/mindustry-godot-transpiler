import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
POINT_DEFENSE_STATE = ROOT / 'godot-mindustry/src/game/SourcePointDefenseTurretBuildState.gd'
POINT_DEFENSE_SHOULD_CONSUME_COOLING_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretShouldConsumeCoolantProof.gd'


class C07PointDefenseTurretShouldConsumeCoolingTests(unittest.TestCase):
    def test_c07_point_defense_turret_should_consume_cooling_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2241']['godot_owner'], 'SourcePointDefenseTurretBuildState.source_point_defense_turret_should_consume_state')
        # N2151 wired the power.status live read but deferred the
        # shouldConsume gate ("No shouldConsume gate --
        # PointDefenseBuild.shouldConsume()
        # (PointDefenseTurret.java:105-107, `return
        # super.shouldConsume() && target != null;`) needs live
        # bullet-target state the tick does not track yet; the
        # machinery runs with should_consume=true when enabled").
        # N2239/N2240 now stamp the live target, so the gate is
        # unblocked: super.shouldConsume() is Building.shouldConsume()
        # (BuildingComp.java:755-757, `return enabled;` -- neither
        # ReloadTurretBuild nor BaseTurretBuild overrides it), so the
        # gate is `enabled && target != null`. TurretBuild.
        # shouldConsume() (Turret.java:364, `return isShooting ||
        # reloadCounter < reload;`) is NOT in the chain --
        # PointDefenseBuild extends ReloadTurretBuild, not
        # TurretBuild. The same slice closes the other remainder
        # of updateTile: the coolant call (`if(coolant != null){
        # updateCooling(); }`, PointDefenseTurret.java:74-76), which
        # runs before the aim/shoot half (PointDefenseTurret.java:
        # 76-101) so its reloadCounter boost feeds the shoot gate.
        # updateCooling() (ReloadTurret.java:28-38) gates on
        # canReload() (`reloadCounter < reload`,
        # ReloadTurret.java:46-48) && coolant != null &&
        # coolant.efficiency(this) > 0 && efficiency > 0, then
        # `reloadCounter += amount * edelta() * capacity *
        # coolantMultiplier * ammoReloadMultiplier();` with amount
        # = coolant.amount * coolant.efficiency(this), capacity =
        # the consumed liquid's heatCapacity (ConsumeCoolant is a
        # ConsumeLiquidFilter), coolantMultiplier = 2f for
        # PointDefenseTurret (PointDefenseTurret.java:42) and
        # ammoReloadMultiplier() = 1f (ReloadTurret.java:41-43).
        # The coolant efficiency and the consumed liquid's
        # heatCapacity arrive as parameters (the N2240
        # block_damage_multiplier precedent) -- the frame carries
        # no liquid inventory, so the live getConsumed selection
        # and the coolant.update liquid removal wait for a later
        # wiring slice. The only PointDefenseTurret def, segment
        # (Blocks.java:3835-3845), defines NO coolant consumer, so
        # BaseTurret.init (BaseTurret.java:50-52) leaves coolant
        # null and the driver call is a faithful no-op for segment.
        # Two pure functions on SourcePointDefenseTurretBuildState.gd,
        # plus two driver tick lines (the shouldConsume gate in the
        # consumption branch, the cooling call before aim/shoot).
        # Four new result symbols: should_consume +
        # reload_counter + cooling_applied + coolant_consumed.
        self.assertEqual(
            ledger['N2241']['source_symbols'],
            [
                'source_point_defense_turret_should_consume_state_result.should_consume',
                'source_point_defense_turret_cooling_state_result.reload_counter',
                'source_point_defense_turret_cooling_state_result.cooling_applied',
                'source_point_defense_turret_cooling_state_result.coolant_consumed',
            ],
        )
        for name in ledger['N2241']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
                    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
                    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java',
                    'core/src/mindustry/world/consumers/ConsumeCoolant.java',
                    'core/src/mindustry/world/consumers/Consume.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_point_defense_turret_should_consume_state_result.should_consume': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_should_consume_state',
                    'source_point_defense_turret_cooling_state_result.reload_counter': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_cooling_state',
                    'source_point_defense_turret_cooling_state_result.cooling_applied': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_cooling_state',
                    'source_point_defense_turret_cooling_state_result.coolant_consumed': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_cooling_state',
                }[name])
        self.assertEqual(ledger['N2241']['runtime_proof'], '/root/C07PointDefenseTurretShouldConsumeCoolantProof')
        self.assertEqual(
            ledger['N2241']['tests'],
            [
                'test_c07_point_defense_turret_should_consume_cooling_registration',
                'test_all_c07_point_defense_turret_should_consume_cooling_input_evidence_is_exact',
                'test_point_defense_turret_should_consume_cooling_state',
                'test_reference_graph_and_actual_c07_point_defense_turret_should_consume_cooling',
            ],
        )
        self.assertTrue(ledger['N2241']['deferred_exprs'])

    def test_all_c07_point_defense_turret_should_consume_cooling_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2241']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
                    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
                    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java',
                    'core/src/mindustry/world/consumers/ConsumeCoolant.java',
                    'core/src/mindustry/world/consumers/Consume.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_point_defense_turret_should_consume_state_result.should_consume': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_should_consume_state',
                    'source_point_defense_turret_cooling_state_result.reload_counter': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_cooling_state',
                    'source_point_defense_turret_cooling_state_result.cooling_applied': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_cooling_state',
                    'source_point_defense_turret_cooling_state_result.coolant_consumed': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_cooling_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java',
            'core/src/mindustry/world/consumers/ConsumeCoolant.java',
            'core/src/mindustry/world/consumers/Consume.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2241']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_point_defense_turret_should_consume_cooling_state(self):
        point_defense = POINT_DEFENSE_STATE.read_text(encoding='utf-8')
        # shouldConsume() (PointDefenseTurret.java:105-107,
        # `return super.shouldConsume() && target != null;`):
        # the super chain is PointDefenseBuild ->
        # ReloadTurretBuild -> BaseTurretBuild -> Building, and
        # neither ReloadTurretBuild nor BaseTurretBuild overrides
        # shouldConsume, so super.shouldConsume() is
        # Building.shouldConsume() (BuildingComp.java:755-757,
        # `return enabled;`, with `transient boolean enabled =
        # true;`, BuildingComp.java:77). TurretBuild.shouldConsume()
        # (Turret.java:364, `return isShooting || reloadCounter <
        # reload;`) is NOT in the chain -- TurretBuild is a sibling
        # branch, PointDefenseBuild extends ReloadTurretBuild
        # directly -- so GREEN must NOT use it. The gate is
        # `enabled && target != null`, read from the frame keys
        # the tick (enabled, default true) and N2239 (target,
        # null when no target is stamped) already carry.
        # updateCooling() (ReloadTurret.java:28-38, called from
        # PointDefenseTurret.java:74-76 `if(coolant != null){
        # updateCooling(); }` before the aim/shoot half): the gate
        # (`if(canReload() && coolant != null &&
        # coolant.efficiency(this) > 0 && efficiency > 0){`,
        # ReloadTurret.java:29) uses canReload() =
        # `reloadCounter < reload` (ReloadTurret.java:46-48);
        # capacity is the consumed liquid's heatCapacity
        # (`float capacity = coolant instanceof
        # ConsumeLiquidFilter filter ? filter.getConsumed(this)
        # .heatCapacity : (coolant.consumes(liquids.current()) ?
        # liquids.current().heatCapacity : 0.4f);`,
        # ReloadTurret.java:30 -- ConsumeCoolant extends
        # ConsumeLiquidFilter, so the filter branch applies);
        # amount = `coolant.amount * coolant.efficiency(this)`
        # (ReloadTurret.java:31); `coolant.update(this);`
        # (ReloadTurret.java:32) removes `amount * edelta() *
        # multiplier` (ConsumeLiquidFilter.java:44-49, multiplier
        # default 1f, Consume.java:18) -- the pure function
        # returns that as coolant_consumed for a later wiring
        # slice to apply, since the frame carries no liquid
        # inventory; the reload boost is `reloadCounter += amount
        # * edelta() * capacity * coolantMultiplier *
        # ammoReloadMultiplier();` (ReloadTurret.java:33) with
        # coolantMultiplier = 2f for PointDefenseTurret
        # (PointDefenseTurret.java:42; the BaseTurret class
        # default is 5f) and ammoReloadMultiplier() = 1f
        # (ReloadTurret.java:41-43). The coolEffect chance
        # (`if(Mathf.chance(0.06 * amount)){`,
        # ReloadTurret.java:35) is a random visual, NOT in the
        # pure function (the N2240 random-pitch precedent).
        # Coolant efficiency (ConsumeLiquidFilter.java:50-56) is
        # `min(liquids.get(liq) / (amount * ed * multiplier), 1)`
        # over the getConsumed liquid, 0 when none -- passed in
        # as a parameter, like N2240's block_damage_multiplier.
        # The segment def (Blocks.java:3835-3845) defines NO
        # coolant consumer, so BaseTurret.init
        # (`coolant = findConsumer(c -> c instanceof
        # ConsumeCoolant);`, BaseTurret.java:50-52) leaves coolant
        # null: the driver passes has_coolant=false and the call
        # is a faithful no-op for the only def. The result is a
        # 1-key dict for shouldConsume (`should_consume`) and a
        # 3-key dict for cooling (`reload_counter` after the
        # boost, unchanged when the gate fails; `cooling_applied`;
        # `coolant_consumed`, 0.0 when the gate fails).
        # The driver stamps the cooling result into
        # frame["reload_counter"] BEFORE the aim/shoot call, so
        # aim reads the boosted counter (Java order :74-76
        # before :77-101).
        self.assertIn('static func source_point_defense_turret_should_consume_state(frame: Dictionary) -> Dictionary:', point_defense)
        self.assertIn('var should_consume: bool = bool(frame.get("enabled", true)) and frame.get("target", null) != null', point_defense)
        self.assertIn('return {"should_consume": should_consume}', point_defense)
        self.assertIn('static func source_point_defense_turret_cooling_state(frame: Dictionary, has_coolant: bool, coolant_amount: float, coolant_efficiency: float, heat_capacity: float, coolant_multiplier: float, reload: float, edelta: float) -> Dictionary:', point_defense)
        self.assertIn('var reload_counter: float = float(frame.get("reload_counter", 0.0))', point_defense)
        self.assertIn('var efficiency: float = float(frame.get("efficiency", 1.0))', point_defense)
        self.assertIn('if has_coolant and reload_counter < reload and coolant_efficiency > 0.0 and efficiency > 0.0:', point_defense)
        self.assertIn('var amount: float = coolant_amount * coolant_efficiency', point_defense)
        self.assertIn('coolant_consumed = amount * edelta', point_defense)
        self.assertIn('reload_counter += amount * edelta * heat_capacity * coolant_multiplier', point_defense)
        self.assertIn('cooling_applied = true', point_defense)
        self.assertIn('return {"reload_counter": reload_counter, "cooling_applied": cooling_applied, "coolant_consumed": coolant_consumed}', point_defense)
        self.assertIn('var should_consume: bool = bool(source_point_defense_turret_should_consume_state(frame).get("should_consume", false))', point_defense)
        self.assertIn('var cooling: Dictionary = source_point_defense_turret_cooling_state(frame, false, 0.0, 0.0, 0.0, 2.0, 8.0, edelta)', point_defense)
        self.assertIn('frame["reload_counter"] = cooling.get("reload_counter", 0.0)', point_defense)
        self.assertIn('return super.shouldConsume() && target != null;', point_defense)
        self.assertIn('public boolean shouldConsume(){', point_defense)
        self.assertIn('return enabled;', point_defense)
        self.assertIn('transient boolean enabled = true;', point_defense)
        self.assertIn('if(coolant != null){', point_defense)
        self.assertIn('updateCooling();', point_defense)
        self.assertIn('coolantMultiplier = 2f;', point_defense)
        self.assertIn('if(canReload() && coolant != null && coolant.efficiency(this) > 0 && efficiency > 0){', point_defense)
        self.assertIn('float capacity = coolant instanceof ConsumeLiquidFilter filter ? filter.getConsumed(this).heatCapacity : (coolant.consumes(liquids.current()) ? liquids.current().heatCapacity : 0.4f);', point_defense)
        self.assertIn('float amount = coolant.amount * coolant.efficiency(this);', point_defense)
        self.assertIn('coolant.update(this);', point_defense)
        self.assertIn('reloadCounter += amount * edelta() * capacity * coolantMultiplier * ammoReloadMultiplier();', point_defense)
        self.assertIn('if(Mathf.chance(0.06 * amount)){', point_defense)
        self.assertIn('return reloadCounter < reload;', point_defense)
        self.assertIn('build.liquids.remove(liq, amount * build.edelta() * multiplier.get(build));', point_defense)
        self.assertIn('return liq != null ? Math.min(build.liquids.get(liq) / (amount * ed * multiplier.get(build)), 1f) : 0f;', point_defense)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', point_defense)
        self.assertIn('coolant = findConsumer(c -> c instanceof ConsumeCoolant);', point_defense)
        self.assertIn('return efficiency * delta();', point_defense)
        self.assertIn('segment = new PointDefenseTurret("segment"){{', point_defense)
        self.assertIn('consumePower(8f);', point_defense)
        self.assertIn('reload = 8f;', point_defense)
        # The proof's keys drive the gate and the cooling through
        # the real driver (should_consume true only when enabled
        # with a target / false without a target / false when
        # disabled; cooling boosts reload_counter / is skipped
        # when reloaded, without coolant, or with zero coolant
        # efficiency / reports the coolant consumed).
        proof = POINT_DEFENSE_SHOULD_CONSUME_COOLING_PROOF.read_text(encoding='utf-8')
        for key in [
            'should_consume_true_when_enabled_with_target',
            'should_consume_false_without_target',
            'should_consume_false_when_disabled',
            'cooling_boosts_reload_counter',
            'cooling_skipped_when_reloaded',
            'cooling_skipped_without_coolant',
            'cooling_skipped_when_coolant_efficiency_zero',
            'cooling_reports_coolant_consumed',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_point_defense_turret_should_consume_cooling(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PointDefenseTurretShouldConsumeCoolantProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_POINT_DEFENSE_TURRET_SHOULD_CONSUME_COOLANT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'should_consume_true_when_enabled_with_target',
            'should_consume_false_without_target',
            'should_consume_false_when_disabled',
            'cooling_boosts_reload_counter',
            'cooling_skipped_when_reloaded',
            'cooling_skipped_without_coolant',
            'cooling_skipped_when_coolant_efficiency_zero',
            'cooling_reports_coolant_consumed',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
