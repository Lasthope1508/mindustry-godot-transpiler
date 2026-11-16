import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
IMPACT_REACTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceImpactReactorBuildState.gd'
IMPACT_REACTOR_IMPACT_POWER_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorImpactPowerProof.gd'


class C07ImpactReactorImpactPowerTests(unittest.TestCase):
    def test_c07_impact_reactor_impact_power_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2216']['godot_owner'], 'SourceImpactReactorBuildState.source_impact_reactor_impact_power_state')
        # N2182 folded the consumer-side power.status row for the
        # impact reactor and N2186 modeled the warmup advance +
        # the live production read and N2187 the fuel burn -- but
        # the first-production event waited for its own slice:
        # ImpactReactorBuild.updateTile fires the achievement
        # trigger the first tick production exceeds the requested
        # power (`if(!prevOut && consPower != null &&
        # (getPowerProduction() > consPower.requestedPower(this))){`
        # / `Events.fire(Trigger.impactPower);`,
        # ImpactReactor.java:87-88, computed from `boolean prevOut
        # = consPower != null && getPowerProduction() <=
        # consPower.requestedPower(this);`,
        # ImpactReactor.java:80). The event itself has no
        # game-state effect beyond the achievement trigger
        # (`trigger(Trigger.impactPower, powerupImpactReactor);`,
        # GameService.java:383, `impactPower,`,
        # EventType.java:26), and the port has no Events /
        # achievement system to fire into -- so the observable fact
        # is the stamp: one pure function (frame ->
        # {"impact_power_fired"}) on the same family file
        # N2182/N2186/N2187 built, called by the SAME driver
        # (source_impact_reactor_tick_buildings_state, the
        # placed-reactor tick) after the consumption fold, stamped
        # onto the same frame -- no new file, no new driver. RED
        # decisions (resolved at RED, recorded in the register
        # docstring): (1) NO delta parameter -- the Java lines
        # :80/:87-88 use no time at all (unlike the N2186 warmup
        # advance and the N2187 consume timer, which take delta).
        # (2) The KEY SUBTLETY: productionEfficiency is only
        # reassigned at ImpactReactor.java:100, AFTER the event
        # check at :87-88, so both getPowerProduction() calls
        # (:80 and :87) read the SAME previous-tick
        # productionEfficiency -- the driver MUST call the event
        # function BEFORE the N2186 production step, which
        # overwrites frame["production_efficiency"] with the new
        # value (Java order: prevOut -> warmup advance -> event
        # check -> consume timer -> totalProgress ->
        # productionEfficiency). (3) requestedPower is read exactly
        # (ConsumePower.java:56-60): the reactor's consPower is
        # plain -- consumePower(25f) registers `new
        # ConsumePower(powerPerTick, 0.0f, false)` (Block.java:1140-1142),
        # buffered=false, capacity=0 -- so requested = 25.0 *
        # (shouldConsume ? 1 : 0), and ImpactReactorBuild has NO
        # shouldConsume override, so the BuildingComp default
        # (`return enabled;`, BuildingComp.java:755-756) applies:
        # requested = 25.0 if enabled else 0.0. (4) The event check
        # sits INSIDE the warmup hard gate (ImpactReactor.java:79)
        # -- no fire when the gate fails, however high production
        # is. (5) The condition is kept two-step exactly like Java
        # (prevOut, then !prevOut && production > requested) instead
        # of collapsing it. (6) This is the FIRST stamp of
        # frame["impact_power_fired"]. Single def -- impact-reactor
        # only (size 4, health 900, powerProduction 130f,
        # itemDuration 140f, liquidCapacity 80f, lead 500 / silicon
        # 300 / graphite 400 / thorium 100 / surge-alloy 250 /
        # metaglass 250, Blocks.java:2632-2645). One new result
        # symbol: impact_power_fired.
        self.assertEqual(
            ledger['N2216']['source_symbols'],
            [
                'source_impact_reactor_impact_power_state_result.impact_power_fired',
            ],
        )
        for name in ledger['N2216']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/power/ImpactReactor.java',
                    'core/src/mindustry/world/blocks/power/PowerGenerator.java',
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/game/EventType.java',
                    'core/src/mindustry/service/GameService.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceImpactReactorBuildState.source_impact_reactor_impact_power_state')
        self.assertEqual(ledger['N2216']['runtime_proof'], '/root/C07ImpactReactorImpactPowerProof')
        self.assertEqual(
            ledger['N2216']['tests'],
            [
                'test_c07_impact_reactor_impact_power_registration',
                'test_all_c07_impact_reactor_impact_power_input_evidence_is_exact',
                'test_impact_reactor_impact_power_state',
                'test_reference_graph_and_actual_c07_impact_reactor_impact_power',
            ],
        )
        self.assertTrue(ledger['N2216']['deferred_exprs'])

    def test_all_c07_impact_reactor_impact_power_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2216']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceImpactReactorBuildState.source_impact_reactor_impact_power_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/power/ImpactReactor.java',
            'core/src/mindustry/world/blocks/power/PowerGenerator.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/game/EventType.java',
            'core/src/mindustry/service/GameService.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2216']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_impact_reactor_impact_power_state(self):
        impact_reactor = IMPACT_REACTOR_STATE.read_text(encoding='utf-8')
        # The first-production event lives on the same
        # impact-reactor build state N2182/N2186/N2187 built: the
        # pure function checks, INSIDE the warmup hard gate
        # (ImpactReactor.java:79, `if(efficiency >= 0.9999f &&
        # power.status >= 0.99f){`, keep on ONE comment line, the
        # N2148 shootWarmup lesson: a split line fails this test),
        # whether production first exceeds the requested power
        # (`boolean prevOut = consPower != null &&
        # getPowerProduction() <= consPower.requestedPower(this);`,
        # ImpactReactor.java:80, then `if(!prevOut && consPower !=
        # null && (getPowerProduction() >
        # consPower.requestedPower(this))){` with
        # `Events.fire(Trigger.impactPower);`,
        # ImpactReactor.java:87-88). The KEY SUBTLETY:
        # productionEfficiency is only reassigned at
        # ImpactReactor.java:100 (`productionEfficiency =
        # Mathf.pow(warmup, 5f);`), AFTER the event check, so both
        # getPowerProduction() calls read the SAME previous-tick
        # productionEfficiency -- Java order inside updateTile is
        # prevOut (:80) -> warmup advance (`warmup =
        # Mathf.lerpDelta(warmup, 1f, warmupSpeed * timeScale);`,
        # ImpactReactor.java:82, snapped by `if(Mathf.equal(warmup,
        # 1f, 0.001f)){` / `warmup = 1f;`, :83-84) -> event check
        # (:87-88) -> consume timer (`if(timer(timerUse,
        # itemDuration / timeScale)){` / `consume();`, :91-92) ->
        # `totalProgress += warmup * Time.delta;` (:98) ->
        # productionEfficiency (:100) -- so the driver MUST call
        # the event function BEFORE the N2186 production step,
        # which overwrites frame["production_efficiency"] with the
        # new value. getPowerProduction() is `public float
        # getPowerProduction(){` / `return enabled ?
        # powerProduction * productionEfficiency : 0f;`
        # (PowerGenerator.java:156-158) with `powerProduction =
        # 130f;` (Blocks.java:2636) and `public float
        # productionEfficiency = 0.0f;` (PowerGenerator.java:96),
        # so production = 130.0 * production_efficiency if enabled
        # else 0.0. requestedPower is `public float
        # requestedPower(Building entity){` / `return buffered ?`
        # / `(1f - entity.power.status) * capacity :` / `usage *
        # (entity.shouldConsume() ? 1f : 0f);`
        # (ConsumePower.java:56-60): the reactor's consPower is
        # plain -- `consumePower(25f);` (Blocks.java:2642) ->
        # `public ConsumePower consumePower(float powerPerTick){` /
        # `return consume(new ConsumePower(powerPerTick, 0.0f,
        # false));` (Block.java:1140-1142), buffered=false,
        # capacity=0 -- so requested = 25.0 * (shouldConsume ? 1 :
        # 0), and ImpactReactorBuild has NO shouldConsume override,
        # so the BuildingComp default applies (`public boolean
        # shouldConsume(){` / `return enabled;`,
        # BuildingComp.java:755-756): requested = 25.0 if enabled
        # else 0.0. The event is the achievement trigger
        # (`impactPower,`, EventType.java:26, with
        # `trigger(Trigger.impactPower, powerupImpactReactor);`,
        # GameService.java:383) -- the port has no Events /
        # achievement system to fire into, so the stamp
        # frame["impact_power_fired"] is the observable fact that
        # it fired this tick. The driver calls the event check
        # BEFORE the N2186 production step in the same tick (the
        # Java order: prevOut -> warmup advance -> event check ->
        # consume timer -> totalProgress -> productionEfficiency).
        # This is the FIRST stamp of frame["impact_power_fired"].
        self.assertIn('static func source_impact_reactor_impact_power_state(frame: Dictionary) -> Dictionary:', impact_reactor)
        self.assertIn('var efficiency: float = float(frame.get("efficiency", 1.0))', impact_reactor)
        self.assertIn('var power_status: float = float(frame.get("power_status", 1.0))', impact_reactor)
        self.assertIn('var enabled: bool = bool(frame.get("enabled", true))', impact_reactor)
        self.assertIn('var production_efficiency: float = float(frame.get("production_efficiency", 0.0))', impact_reactor)
        self.assertIn('var power_production: float = 130.0 * production_efficiency if enabled else 0.0', impact_reactor)
        self.assertIn('var requested_power: float = 25.0 if enabled else 0.0', impact_reactor)
        self.assertIn('var prev_out: bool = power_production <= requested_power', impact_reactor)
        self.assertIn('if not prev_out and power_production > requested_power:', impact_reactor)
        self.assertIn('return {"impact_power_fired": impact_power_fired}', impact_reactor)
        self.assertIn('source_impact_reactor_impact_power_state(frame)', impact_reactor)
        self.assertIn('frame["impact_power_fired"]', impact_reactor)
        # The event call must come BEFORE the N2186 production
        # call in the driver: the production step overwrites
        # frame["production_efficiency"] with the new value, while
        # the event check must read the previous tick's value
        # (ImpactReactor.java:100 reassigns productionEfficiency
        # only after the :87-88 check).
        self.assertLess(
            impact_reactor.index('source_impact_reactor_impact_power_state(frame)'),
            impact_reactor.index('source_impact_reactor_power_production_state(frame, seconds)'),
        )
        for expr in [
            'if(efficiency >= 0.9999f && power.status >= 0.99f){',
            'boolean prevOut = consPower != null && getPowerProduction() <= consPower.requestedPower(this);',
            'warmup = Mathf.lerpDelta(warmup, 1f, warmupSpeed * timeScale);',
            'if(Mathf.equal(warmup, 1f, 0.001f)){',
            'warmup = 1f;',
            'if(!prevOut && consPower != null && (getPowerProduction() > consPower.requestedPower(this))){',
            'Events.fire(Trigger.impactPower);',
            'if(timer(timerUse, itemDuration / timeScale)){',
            'consume();',
            'totalProgress += warmup * Time.delta;',
            'productionEfficiency = Mathf.pow(warmup, 5f);',
            'public float getPowerProduction(){',
            'return enabled ? powerProduction * productionEfficiency : 0f;',
            'public float productionEfficiency = 0.0f;',
            'powerProduction = 130f;',
            'public float requestedPower(Building entity){',
            'return buffered ?',
            '(1f - entity.power.status) * capacity :',
            'usage * (entity.shouldConsume() ? 1f : 0f);',
            'public ConsumePower consumePower(float powerPerTick){',
            'return consume(new ConsumePower(powerPerTick, 0.0f, false));',
            'consumePower(25f);',
            'public boolean shouldConsume(){',
            'return enabled;',
            'impactPower,',
            'trigger(Trigger.impactPower, powerupImpactReactor);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, impact_reactor)
        # The proof's keys drive the pure function with synthetic
        # frames (no long live tick: productionEfficiency is the
        # previous tick's stamp, so the event fires the tick
        # production first crosses the 25f requested power): fires
        # when production exceeds requested / no fire when below /
        # no fire at exact equality / no fire when disabled / no
        # fire when the efficiency gate fails / no fire when the
        # power.status gate fails / fires just above threshold / no
        # fire when cold. There are no consume-timer / net-bar /
        # persistence keys: the burn is N2187, the bar is display,
        # the persistence waits for its own slice.
        proof = IMPACT_REACTOR_IMPACT_POWER_PROOF.read_text(encoding='utf-8')
        for key in [
            'impact_power_fires_when_production_exceeds_requested',
            'impact_power_no_fire_when_production_below_requested',
            'impact_power_no_fire_at_exact_equality',
            'impact_power_no_fire_when_disabled',
            'impact_power_no_fire_when_efficiency_gate_fails',
            'impact_power_no_fire_when_power_status_gate_fails',
            'impact_power_fires_just_above_threshold',
            'impact_power_no_fire_when_cold',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_impact_reactor_impact_power(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ImpactReactorImpactPowerProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_IMPACT_REACTOR_IMPACT_POWER_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'impact_power_fires_when_production_exceeds_requested',
            'impact_power_no_fire_when_production_below_requested',
            'impact_power_no_fire_at_exact_equality',
            'impact_power_no_fire_when_disabled',
            'impact_power_no_fire_when_efficiency_gate_fails',
            'impact_power_no_fire_when_power_status_gate_fails',
            'impact_power_fires_just_above_threshold',
            'impact_power_no_fire_when_cold',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
