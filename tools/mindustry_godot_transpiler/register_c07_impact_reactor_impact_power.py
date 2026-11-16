"""Register the ImpactReactor impactPower event (N2216).

N2182 folded the consumer-side power.status row for the impact
reactor, N2186 modeled the warmup advance + the live production
read, N2187 the fuel burn -- but the first-production event waited
for its own slice: ImpactReactorBuild.updateTile fires the
achievement trigger the first tick production exceeds the requested
power (`if(!prevOut && consPower != null && (getPowerProduction() >
consPower.requestedPower(this))){` / `Events.fire(Trigger.
impactPower);`, ImpactReactor.java:87-88, computed from `boolean
prevOut = consPower != null && getPowerProduction() <=
consPower.requestedPower(this);`, ImpactReactor.java:80). The event
itself has no game-state effect beyond the achievement trigger
(`trigger(Trigger.impactPower, powerupImpactReactor);`,
GameService.java:383, `impactPower,`, EventType.java:26), and the
port has no Events / achievement system to fire into -- so the
observable fact is the stamp: one pure function (frame ->
{"impact_power_fired"}) on the same family file N2182/N2186/N2187
built, called by the SAME driver
(source_impact_reactor_tick_buildings_state, the placed-reactor
tick) after the consumption fold, stamped onto the same frame -- no
new file, no new driver.

RED decisions (resolved at RED): (1) NO delta parameter -- the Java
lines :80/:87-88 use no time at all (unlike the N2186 warmup advance
and the N2187 consume timer, which take delta). (2) The KEY SUBTLETY:
productionEfficiency is only reassigned at ImpactReactor.java:100,
AFTER the event check at :87-88, so both getPowerProduction() calls
(:80 and :87) read the SAME previous-tick productionEfficiency --
the driver MUST call the event function BEFORE the N2186 production
step, which overwrites frame["production_efficiency"] with the new
value (Java order: prevOut -> warmup advance -> event check ->
consume timer -> totalProgress -> productionEfficiency). (3)
requestedPower is read exactly (ConsumePower.java:56-60): the
reactor's consPower is plain -- consumePower(25f) registers `new
ConsumePower(powerPerTick, 0.0f, false)` (Block.java:1140-1142),
buffered=false, capacity=0 -- so requested = 25.0 * (shouldConsume
? 1 : 0), and ImpactReactorBuild has NO shouldConsume override, so
the BuildingComp default (`return enabled;`, BuildingComp.java:755-756)
applies: requested = 25.0 if enabled else 0.0. (4) The event check
sits INSIDE the warmup hard gate (ImpactReactor.java:79) -- no fire
when the gate fails, however high production is. (5) The condition
is kept two-step exactly like Java (prevOut, then !prevOut &&
production > requested) instead of collapsing it. (6) This is the
FIRST stamp of frame["impact_power_fired"]. Single def
(impact-reactor, powerProduction 130f, Blocks.java:2636; consumePower
25f, Blocks.java:2642). No family split: the impact reactor is the
ONLY ImpactReactor def (Blocks.java:2632).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_impact_reactor_consume import DEFERRED as N2187_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
IMPACT_REACTOR = 'core/src/mindustry/world/blocks/power/ImpactReactor.java'
POWER_GENERATOR = 'core/src/mindustry/world/blocks/power/PowerGenerator.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
EVENT_TYPE = 'core/src/mindustry/game/EventType.java'
GAME_SERVICE = 'core/src/mindustry/service/GameService.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07ImpactReactorImpactPowerProof'
OWNER = 'SourceImpactReactorBuildState.source_impact_reactor_impact_power_state'
TESTS = ['test_c07_impact_reactor_impact_power_registration', 'test_all_c07_impact_reactor_impact_power_input_evidence_is_exact', 'test_impact_reactor_impact_power_state', 'test_reference_graph_and_actual_c07_impact_reactor_impact_power']
# The 8 slice sources the N2216 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files, and no expr may name a file outside them.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/power/ImpactReactor.java',
    'core/src/mindustry/world/blocks/power/PowerGenerator.java',
    'core/src/mindustry/world/consumers/ConsumePower.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/game/EventType.java',
    'core/src/mindustry/service/GameService.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
]
EXACT_EXPRS = ['public class ImpactReactor extends PowerGenerator{', 'public class ImpactReactorBuild extends GeneratorBuild{', 'public void updateTile(){', 'if(efficiency >= 0.9999f && power.status >= 0.99f){', 'boolean prevOut = consPower != null && getPowerProduction() <= consPower.requestedPower(this);', 'warmup = Mathf.lerpDelta(warmup, 1f, warmupSpeed * timeScale);', 'if(Mathf.equal(warmup, 1f, 0.001f)){', 'warmup = 1f;', 'if(!prevOut && consPower != null && (getPowerProduction() > consPower.requestedPower(this))){', 'Events.fire(Trigger.impactPower);', 'if(timer(timerUse, itemDuration / timeScale)){', 'consume();', 'totalProgress += warmup * Time.delta;', 'productionEfficiency = Mathf.pow(warmup, 5f);', 'public float warmup, totalProgress;', 'public float getPowerProduction(){', 'return enabled ? powerProduction * productionEfficiency : 0f;', 'public float productionEfficiency = 0.0f;', 'public float powerProduction;', 'public float requestedPower(Building entity){', 'return buffered ?', '(1f - entity.power.status) * capacity :', 'usage * (entity.shouldConsume() ? 1f : 0f);', 'public ConsumePower consumePower(float powerPerTick){', 'return consume(new ConsumePower(powerPerTick, 0.0f, false));', 'powerProduction = 130f;', 'consumePower(25f);', 'impactPower,', 'trigger(Trigger.impactPower, powerupImpactReactor);', 'public boolean shouldConsume(){', 'return enabled;']

# DEFERRED is carried from the N2187 register script via import --
# never retyped. The N2187 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2186 import), NOT a plain
# list literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2216's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval.
DEFERRED = list(N2187_DEFERRED) + [
    'ImpactReactor impactPower achievement completion (powerupImpactReactor, GameService.java:383, trigger(Trigger.impactPower, powerupImpactReactor)) has no port-side effect beyond the frame stamp: the port has no Events / achievement system to fire into, so the observable fact is frame["impact_power_fired"]; completing the achievement waits for an Events / achievement slice if one is ever built.',
    'ImpactReactor impactPower Windows Godot proof -- debt in GOAL.md section 5, same as N2182-N2187: the N2216 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=IMPACT_REACTOR, **extra):
        return backed(typ, source, expr, rule, **extra)

    impact_power_inputs = {
        'frame': a('Dictionary', 'if(efficiency >= 0.9999f && power.status >= 0.99f){', 'The impact-reactor frame carrying the folded efficiency (set by update_consumption_state earlier in the same tick), the live power.status (stamped by the N2142 graph update), enabled, and the PREVIOUS tick\'s production_efficiency (stamped by N2186 last tick; absent reads 0.0, the PowerGenerator.java:96 default) -- the event check reads the previous tick\'s productionEfficiency because ImpactReactor.java:100 reassigns it only after the :87-88 check.'),
    }
    impact_power_outputs = {
        'impact_power_fired': a('bool', 'Events.fire(Trigger.impactPower);', 'Whether the impactPower trigger fired this tick (ImpactReactor.java:88, `Events.fire(Trigger.impactPower);`): true when the warmup hard gate holds (ImpactReactor.java:79) and production first exceeds the requested power (ImpactReactor.java:87, production 130f x previous-tick productionEfficiency vs requested 25f x shouldConsume), false otherwise -- at/below the requested power, at exact equality, when disabled, or when the gate fails.'),
    }
    return impact_power_inputs, impact_power_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    inputs_outputs = definitions()
    total = len(EXACT_EXPRS)
    for keys in inputs_outputs:
        total += len(keys)
        for field, meta in keys.items():
            source = meta['java_source']
            text = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
            if meta['java_expr'] not in text:
                missing.append('%s: %s' % (field, meta['java_expr']))
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    symbols = {}
    impact_power_inputs, impact_power_outputs = definitions()

    entries = [
        ('N2216', OWNER, 'source_impact_reactor_impact_power_state', IMPACT_REACTOR, 'mindustry.world.blocks.power.ImpactReactor.ImpactReactorBuild', 'ImpactReactorBuild.updateTile()', impact_power_inputs, impact_power_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ImpactReactor impactPower first-production event from ImpactReactor.java / PowerGenerator.java / ConsumePower.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ImpactReactor impactPower first-production event from ImpactReactor.java / PowerGenerator.java / ConsumePower.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: impact_power_fired only.
    by_slice['N2216'] = [
        'source_impact_reactor_impact_power_state_result.impact_power_fired',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2216', dict(status='done', java_source=IMPACT_REACTOR, java_class='mindustry.world.blocks.power.ImpactReactor.ImpactReactorBuild', java_method='ImpactReactorBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2216'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {definition[1] for definition in entries}
    for name, module in modules.items():
        if module.get('canonical_module') == 'api_contracts':
            selected = source_ssot.build_extension_shard(GODOT, name)[module['root_key']]
            if new_owners.intersection(selected):
                optional = module.setdefault('optional_mirror_fields', [])
                if 'return_type' not in optional:
                    optional.append('return_type')
    source_ssot.write_registered_json(GODOT, 'module_manifest', manifest)
    for canonical in ['slice_ledger', 'api_contracts', 'state_schema', 'registry', 'audit_report', 'module_manifest']:
        for name, module in modules.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    if '--verify' in sys.argv:
        sys.exit(verify())
    main()
