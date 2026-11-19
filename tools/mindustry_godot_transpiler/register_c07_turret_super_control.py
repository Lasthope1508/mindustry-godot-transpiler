"""Register the BuildingComp super.control() enabled/config cases (N2267).

TurretBuild.control() ends both overloads with a super.control()
call (Turret.java:388/:402, `super.control(type, p1, p2, p3, p4);`),
so the BuildingComp cases run for every logic control
instruction the turret does not handle itself. The double
overload (BuildingComp.java:2150-2155) only handles enabled:
`public void control(LAccess type, double p1, double p2, double p3, double p4){`
`if(type == LAccess.enabled){`
`enabled = !Mathf.zero((float)p1);`
`}`
`}` -- the field is `transient boolean enabled = true;`
(:77), the flag the shouldConsume / efficiency folds read
(frame["enabled"], default true). The Object overload
(:2157-2162) only handles config:
`public void control(LAccess type, Object p1, double p2, double p3, double p4){`
`//don't execute configure instructions that copy logic building configures; this can cause extreme lag`
`if(type == LAccess.config && block.logicConfigurable && !(p1 instanceof LogicBuild)){`
`//change config only if it's new`
`configured(null, p1);`
`}`
`}`. LAccess pins the two types: `enabled("to"), //"to" is
standard for single parameter access` (LAccess.java:80) and
`config(true, "to"),` (:83) -- enabled takes the double
overload, config the Object overload. Mathf.zero is `return
Math.abs(value) <= FLOAT_ROUNDING_ERROR;` (arc Mathf.java:522-524)
with `public static final float FLOAT_ROUNDING_ERROR =
0.000001f; // 32 bits` (:10), so a p1 of 0.0000005 reads zero
(disabled) and a p1 of 0.00001 reads non-zero (enabled).
`logicConfigurable` is `public boolean logicConfigurable =
false;` (Block.java:270) and only becomes true in init()
(:1463-1466) when some configuration key is an
UnlockableContent -- duo registers no configuration at all
(no `config(` in ItemTurret.java, Turret.java,
ReloadTurret.java or BaseTurret.java), so for duo the
config guard never fires and configured() is never called.

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_super_control_state(control_type, p1, enabled,
logic_configurable, p1_is_logic_build), returning
`{"enabled": .., "config_applied": ..}` -- "enabled" sets
enabled to !zero(p1); "config" reports config_applied true
only when the :2159 guard holds (logic_configurable and the
arg is not a LogicBuild); any other type returns both inputs
unchanged. (2) No driver tick: control() is event-driven
(called by the logic executor) and no logic executor exists
in the driver yet -- the N2248 precedent, N2264/N2266 --
so the proof calls the pure function directly. (3) The
configured(null, p1) handler dispatch is NOT modeled here:
config_applied only reports that Java would call it; the
dispatch needs the block's configurations map, which is
empty for duo. SSOT expected after GREEN: symbols +2, Done
+1, contracts +1, schema +2, 11628/1716/1650/3091 ->
11630/1717/1651/3093; defense shard slices 195 -> 196,
contracts 194 -> 195.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_target_position import DEFERRED as N2266_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
LACCESS = 'core/src/mindustry/logic/LAccess.java'
BLOCK = 'core/src/mindustry/world/Block.java'
MATHF = 'arc-core/src/arc/math/Mathf.java'
PROOF = '/root/C07TurretSuperControlProof'
SUPER_CONTROL_OWNER = 'SourceTurretBuildState.source_turret_super_control_state'
TESTS = ['test_c07_turret_super_control_registration', 'test_all_c07_turret_super_control_input_evidence_is_exact', 'test_turret_super_control_state', 'test_reference_graph_and_actual_c07_turret_super_control']
# The slice sources the N2267 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/logic/LAccess.java',
    'core/src/mindustry/world/Block.java',
    'arc-core/src/arc/math/Mathf.java',
]
EXACT_EXPRS = ['public void control(LAccess type, double p1, double p2, double p3, double p4){', 'if(type == LAccess.enabled){', 'enabled = !Mathf.zero((float)p1);', 'public void control(LAccess type, Object p1, double p2, double p3, double p4){', "//don't execute configure instructions that copy logic building configures; this can cause extreme lag", 'if(type == LAccess.config && block.logicConfigurable && !(p1 instanceof LogicBuild)){', "//change config only if it's new", 'configured(null, p1);', 'transient boolean enabled = true;', 'public boolean logicConfigurable = false;', 'return Math.abs(value) <= FLOAT_ROUNDING_ERROR;', 'public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits', 'enabled("to"), //"to" is standard for single parameter access', 'config(true, "to"),', 'super.control(type, p1, p2, p3, p4);']

# DEFERRED is carried from the N2266 register script via import --
# never retyped. The super.control() enabled/config cases are
# done by this slice (they were the next item named in the N2266
# handoff); the configured() dispatch effect, the calculateHeat
# live proximity scan, the efficiency fold for defs other than
# duo, the maxHealth/health re-sync, the set(tile) world
# position, the cross-tick queuedBullets counter,
# effects/sound, findTarget / the other ItemTurret defs still
# wait.
DEFERRED = list(N2266_DEFERRED) + [
    'Turret super.control() Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2266: the N2267 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BuildingComp super.control() enabled/config cases (BuildingComp.java:2150-2161) -- DONE by this slice (N2267); they were the next item named in the N2266 handoff.',
    'Turret super.control() configured() dispatch effect -- the config case only reports config_applied (the guard at BuildingComp.java:2159-2160); the configured(null, p1) handler dispatch waits for its own slice: it needs the block configurations map (duo has none -- no config( registration in ItemTurret/Turret/ReloadTurret/BaseTurret, so logicConfigurable stays false for duo).',
    'Turret control() for defs other than duo -- the pure function takes control_type / params as inputs; no driver tick exists yet (control() is event-driven, no logic executor in the driver).',
]


def definitions():
    def a(typ, expr, rule, source=BUILDING_COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    super_control_inputs = {
        'control_type': a('String', 'enabled("to"), //"to" is standard for single parameter access', 'The logic access type of the control call (LAccess.java:80: enabled takes ("to") on the double overload; :83: config(true, "to") takes the Object overload; any other type changes nothing.', source=LACCESS),
        'p1': a('float', 'enabled = !Mathf.zero((float)p1);', 'The first param (BuildingComp.java:2152: the enabled flag for the double overload, cast to float; unused by the config overload, where the Object arg arrives via p1_is_logic_build).'),
        'enabled': a('bool', 'transient boolean enabled = true;', 'The enabled flag before this control call (BuildingComp.java:77, the field default is true -- the flag the shouldConsume / efficiency folds read).'),
        'logic_configurable': a('bool', 'public boolean logicConfigurable = false;', 'Whether the block is logic-configurable (Block.java:270, the field default is false; init() :1463-1466 only sets it true when some configuration key is an UnlockableContent -- duo registers none, so false for duo).', source=BLOCK),
        'p1_is_logic_build': a('bool', 'if(type == LAccess.config && block.logicConfigurable && !(p1 instanceof LogicBuild)){', 'Whether the config Object arg is a LogicBuild (BuildingComp.java:2159: a LogicBuild arg is never configured -- executing copies of logic configures can cause extreme lag, :2158).'),
    }
    super_control_outputs = {
        'enabled': a('bool', 'enabled = !Mathf.zero((float)p1);', 'The enabled flag after this control call (BuildingComp.java:2152 -- !zero(p1) for the enabled type; unchanged otherwise).'),
        'config_applied': a('bool', 'configured(null, p1);', 'Whether Java would call configured(null, p1) here (BuildingComp.java:2161 -- true only for the config type with logic_configurable and a non-LogicBuild arg; the dispatch effect itself waits for its own slice).'),
    }
    return super_control_inputs, super_control_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
        upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
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
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
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
    super_control_inputs, super_control_outputs = definitions()

    entries = [
        ('N2267', SUPER_CONTROL_OWNER, 'source_turret_super_control_state', BUILDING_COMP, 'mindustry.entities.comp.BuildingComp', 'BuildingComp.control()', super_control_inputs, super_control_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BuildingComp super.control() enabled/config cases from BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BuildingComp super.control() enabled/config cases from BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: enabled, config_applied.
    by_slice['N2267'] = [
        'source_turret_super_control_state_result.enabled',
        'source_turret_super_control_state_result.config_applied',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2267', dict(status='done', java_source=BUILDING_COMP, java_class='mindustry.entities.comp.BuildingComp', java_method='BuildingComp.control()', godot_owner=SUPER_CONTROL_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2267'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
