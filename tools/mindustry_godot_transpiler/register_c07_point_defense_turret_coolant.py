"""Register the PointDefenseTurret live coolant state (N2248).

N2241 built the cooling pure function taking coolant_efficiency as
a parameter and returning the reload boost, but nothing in the port
computed that efficiency from live liquids, nothing picked the
consumed coolant liquid, nothing subtracted it, and the coolEffect
chance key was missing (ReloadTurret.java:28-38,
`updateCooling()`). One new pure function closes that mechanism:
the ConsumeCoolant filter (ConsumeCoolant.java:14, `liquid.coolant
&& (this.allowLiquid && !liquid.gas || this.allowGas &&
liquid.gas) && liquid.temperature <= maxTemp && liquid.flammability
< maxFlammability`, defaults allowLiquid=true, allowGas=false)
over the live liquids dict, then the ConsumeLiquidFilter
getConsumed pick (ConsumeLiquidFilter.java:63-79, current liquid
first if the filter passes and its amount is > 0, else the first
liquid in content order passing the filter with amount > 0), the
efficiency (ConsumeLiquidFilter.java:50-56, `min(liquids.get(liq) /
(amount * ed * multiplier), 1f)`, 0 when ed <= 1e-8 or no liquid),
the update removal (ConsumeLiquidFilter.java:44-49,
`liquids.remove(liq, amount * edelta * multiplier)` -- the
consumer amount field, NOT the efficiency-scaled local amount),
the consumed liquid's heatCapacity (ReloadTurret.java:30, the
ConsumeLiquidFilter filter branch), and the coolEffect chance key
(`Mathf.chance(0.06 * amount)`, ReloadTurret.java:35, a random
visual -- the N2240 precedent: the pure function returns the
chance, it never rolls). NO driver tick line: the only
PointDefenseTurret def, segment (Blocks.java:3835-3846), defines NO
coolant consumer, so BaseTurret.init leaves coolant null
(`coolant = findConsumer(c -> c instanceof ConsumeCoolant);`,
BaseTurret.java:50-52) and the driver call stays the faithful
no-op -- and the live driver wiring is BLOCKED on catalog capture
anyway (the catalog records consumeCoolant for NO block, not even
salvo which defines `coolant = consumeCoolant(0.2f);` at
Blocks.java:3831, and its liquid rows carry heatCapacity only,
none of coolant / gas / temperature / flammability). Seven new
result symbols: consumed_liquid / consumed_index / checked_liquids
/ coolant_efficiency / heat_capacity / remove_amount /
cool_effect_chance. SSOT expected after GREEN: symbols +7, Done
+1, contracts +1, schema +2; defense shard slices 176 -> 177.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_point_defense_turret_hit_size_removal import DEFERRED as N2247_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
POINT_DEFENSE = 'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java'
CONSUME_COOLANT = 'core/src/mindustry/world/consumers/ConsumeCoolant.java'
CONSUME_LIQUID_FILTER = 'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
LIQUIDS = 'core/src/mindustry/content/Liquids.java'
LIQUID = 'core/src/mindustry/type/Liquid.java'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
PROOF = '/root/C07PointDefenseTurretCoolantProof'
COOLANT_OWNER = 'SourcePointDefenseTurretBuildState.source_point_defense_turret_coolant_state'
TESTS = ['test_c07_point_defense_turret_coolant_registration', 'test_all_c07_point_defense_turret_coolant_input_evidence_is_exact', 'test_point_defense_turret_coolant', 'test_reference_graph_and_actual_c07_point_defense_turret_coolant']
# The 9 slice sources the N2248 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/consumers/ConsumeCoolant.java',
    'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java',
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/content/Liquids.java',
    'core/src/mindustry/type/Liquid.java',
    'core/src/mindustry/world/consumers/Consume.java',
]
EXACT_EXPRS = ['liquid.coolant && (this.allowLiquid && !liquid.gas || this.allowGas && liquid.gas) && liquid.temperature <= maxTemp && liquid.flammability < maxFlammability', 'if(filter.get(build.liquids.current()) && build.liquids.currentAmount() > 0){', 'if(filter.get(liq) && build.liquids.get(liq) > 0){', 'if(ed <= 0.00000001f) return 0f;', 'return liq != null ? Math.min(build.liquids.get(liq) / (amount * ed * multiplier.get(build)), 1f) : 0f;', 'build.liquids.remove(liq, amount * build.edelta() * multiplier.get(build));', 'float capacity = coolant instanceof ConsumeLiquidFilter filter ? filter.getConsumed(this).heatCapacity : (coolant.consumes(liquids.current()) ? liquids.current().heatCapacity : 0.4f);', 'float amount = coolant.amount * coolant.efficiency(this);', 'if(Mathf.chance(0.06 * amount)){', 'coolant = findConsumer(c -> c instanceof ConsumeCoolant);', 'segment = new PointDefenseTurret("segment"){{', 'coolant = consumeCoolant(0.2f);', 'public Floatf<Building> multiplier = b -> 1f;', 'public boolean coolant = true;', 'public boolean gas = false;', 'public float temperature = 0.5f;', 'public float flammability;', 'public float heatCapacity = 0.5f;']

# DEFERRED is carried from the N2247 register script via import --
# never retyped. Nothing is dropped here: the lumped
# PointDefenseTurret updateTile advance entry still waits for
# the live coolant wiring + the real effect/sound spawn, and the
# TractorBeam half is untouched. Only the N2248 Windows-proof
# debt entry is appended.
DEFERRED = list(N2247_DEFERRED) + [
    'PointDefenseTurret live coolant state Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2247: the N2248 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=CONSUME_LIQUID_FILTER, **extra):
        return backed(typ, source, expr, rule, **extra)

    coolant_inputs = {
        'liquids': a('Dictionary', 'build.liquids.current()', 'The live liquid inventory Java reads every coolant tick (ConsumeLiquidFilter.java:63-79, `filter.get(build.liquids.current())` / `build.liquids.get(liq)`): the port passes the SourceLiquidModuleState-shaped dict ({"liquids": Array[float] by liquid id, "current": int id, "flow": null}); the PointDefenseTurret driver does not read it yet, so the pure function takes it as a parameter (the N2241 synthetic-inputs precedent).'),
        'liquid_rows': a('Array', 'var liqs = content.liquids();', 'The liquid rows in content order Java scans for the fallback pick (ConsumeLiquidFilter.java:67-79, `var liqs = content.liquids();` then `for(int i = 0; i < liqs.size; i++){`): the port passes synthetic rows ({id, name, coolant, gas, temperature, flammability, heat_capacity}) because the catalog cannot supply them -- its liquid entries carry heatCapacity only, and coolant / gas / temperature / flammability are Java class defaults (Liquid.java:50 / :28 / :40 / :38).'),
        'coolant_amount': a('float', 'this.amount = amount;', 'The ConsumeCoolant consumer amount field (ConsumeCoolant.java:12, `this.amount = amount;`, the (float) constructor default 1f, ConsumeCoolant.java:18-20): the removal and the efficiency denominator use this field, NOT the efficiency-scaled local amount.', source=CONSUME_COOLANT),
        'edelta': a('float', 'float ed = build.edelta();', 'The per-tick efficiency-scaled delta Java reads for the efficiency guard and the removal (ConsumeLiquidFilter.java:51, `float ed = build.edelta();`; `edelta()` is `efficiency * delta()`, BuildingComp.java:1927-1929, passed in precomputed).'),
        'multiplier': a('float', 'public Floatf<Building> multiplier = b -> 1f;', 'The consumer cost multiplier (Consume.java:18, `public Floatf<Building> multiplier = b -> 1f;`), the 1f default, passed in precomputed like the N2240 block_damage_multiplier precedent.', source=CONSUME),
    }
    coolant_outputs = {
        'consumed_liquid': a('Variant', 'return build.liquids.current();', 'The consumed coolant liquid (ConsumeLiquidFilter.java:63-79, `return build.liquids.current();` for the current-first pick, `return liq;` for the content-order fallback): the row name, null when no liquid passes the filter with amount > 0.'),
        'consumed_index': a('int', 'var liq = liqs.get(i);', 'The content id of the consumed liquid (ConsumeLiquidFilter.java:67-71, `var liq = liqs.get(i);` in the content-order scan): -1 when no liquid is consumed.'),
        'checked_liquids': a('int', 'for(int i = 0; i < liqs.size; i++){', 'How many liquid rows the filter evaluated (ConsumeLiquidFilter.java:67, `for(int i = 0; i < liqs.size; i++){`): the current row once when present, then the content-order scan until a passing liquid with amount > 0 is found.'),
        'coolant_efficiency': a('float', 'return liq != null ? Math.min(build.liquids.get(liq) / (amount * ed * multiplier.get(build)), 1f) : 0f;', 'The ConsumeLiquidFilter efficiency (ConsumeLiquidFilter.java:50-56, `return liq != null ? Math.min(build.liquids.get(liq) / (amount * ed * multiplier.get(build)), 1f) : 0f;`): 0 when ed <= 1e-8 (`if(ed <= 0.00000001f) return 0f;`) or no liquid -- the input the N2241 cooling state takes as a parameter.'),
        'heat_capacity': a('float', 'float capacity = coolant instanceof ConsumeLiquidFilter filter ? filter.getConsumed(this).heatCapacity : (coolant.consumes(liquids.current()) ? liquids.current().heatCapacity : 0.4f);', 'The consumed liquid heatCapacity (ReloadTurret.java:30, `float capacity = coolant instanceof ConsumeLiquidFilter filter ? filter.getConsumed(this).heatCapacity : (coolant.consumes(liquids.current()) ? liquids.current().heatCapacity : 0.4f);`, the filter branch applies because ConsumeCoolant extends ConsumeLiquidFilter), defaulting to the Liquid.java 0.5f class default when the row omits it.', source=RELOAD_TURRET),
        'remove_amount': a('float', 'build.liquids.remove(liq, amount * build.edelta() * multiplier.get(build));', 'The Java-exact removal the update applies (ConsumeLiquidFilter.java:44-49, `build.liquids.remove(liq, amount * build.edelta() * multiplier.get(build));`): the consumer amount field times edelta times multiplier, NOT the efficiency-scaled local amount the N2241 cooling state returns as coolant_consumed; 0.0 when no liquid is consumed.'),
        'cool_effect_chance': a('float', 'if(Mathf.chance(0.06 * amount)){', 'The coolEffect chance key (ReloadTurret.java:35, `if(Mathf.chance(0.06 * amount)){`, with `amount = coolant.amount * coolant.efficiency(this)`, ReloadTurret.java:31): `0.06 * coolant_amount * coolant_efficiency`, returned as a key, never rolled (the N2240 precedent).', source=RELOAD_TURRET),
    }
    return coolant_inputs, coolant_outputs


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
    coolant_inputs, coolant_outputs = definitions()

    entries = [
        ('N2248', COOLANT_OWNER, 'source_point_defense_turret_coolant_state', POINT_DEFENSE, 'mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', 'PointDefenseBuild.updateTile()', coolant_inputs, coolant_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret live coolant state from ConsumeCoolant.java + ConsumeLiquidFilter.java + ReloadTurret.java + BaseTurret.java + Blocks.java + Liquid.java + Consume.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret live coolant state from ConsumeCoolant.java + ConsumeLiquidFilter.java + ReloadTurret.java + BaseTurret.java + Blocks.java + Liquid.java + Consume.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: consumed_liquid, consumed_index,
    # checked_liquids, coolant_efficiency, heat_capacity,
    # remove_amount, cool_effect_chance.
    by_slice['N2248'] = [
        'source_point_defense_turret_coolant_state_result.consumed_liquid',
        'source_point_defense_turret_coolant_state_result.consumed_index',
        'source_point_defense_turret_coolant_state_result.checked_liquids',
        'source_point_defense_turret_coolant_state_result.coolant_efficiency',
        'source_point_defense_turret_coolant_state_result.heat_capacity',
        'source_point_defense_turret_coolant_state_result.remove_amount',
        'source_point_defense_turret_coolant_state_result.cool_effect_chance',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2248', dict(status='done', java_source=POINT_DEFENSE, java_class='mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', java_method='PointDefenseBuild.updateTile()', godot_owner=COOLANT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2248'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
