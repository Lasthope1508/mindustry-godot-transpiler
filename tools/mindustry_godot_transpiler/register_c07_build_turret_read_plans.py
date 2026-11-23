"""Register the BuildTurretBuild read() plans restore slice (N2429).

BuildTurretBuild.read() (BuildTurret.java:266-278, `public
void read(Reads read, byte revision){`) -- this slice is
ONLY the null-guard + restore loop (:273-275) after
`TypeIO.readPlans(read)` (:272, owned at N2184):

- `if(reqs != null){` (:273)
- `for(var req : reqs){` (:274)
- `unit.plans().add(req);` (:275)

NOT this slice: `super.read(read, revision);` (:268,
generic, owned in many slices), `rotation = read.f();`
(:269, N2184), `unit.rotation(rotation);` (:270, N2184),
`unit.plans().clear();` (:271, N2184 -- do not confuse
with :275 `unit.plans().add(req);`), `var reqs =
TypeIO.readPlans(read);` (:272, N2184). The 3 exprs are
0-hit in BOTH ledgers at RED (exact + strip +
normalize), and `java_method`
BuildTurretBuild.read(Reads, byte) is 0-hit in both.
One pure function on SourceBuildTurretBuildState.gd (the
BuildTurret file, static func -- the N2184/N2201/N2423/
N2426 convention for this file, NOT PortGame.*). The
caller passes the already-read plans Array (`reqs`) plus
an explicit `reqs_null` bool for `reqs != null`; the
function returns the plans to add back, in Java order
(duplicates kept, like the Java loop). Slice source:
BuildTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_build_turret_init_unit_type import DEFERRED as N2426_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILD_TURRET = 'core/src/mindustry/world/blocks/defense/BuildTurret.java'
PROOF = '/root/C07BuildTurretReadPlansProof'
READ_OWNER = 'SourceBuildTurretBuildState.source_build_turret_read_plans_state'
TESTS = ['test_c07_build_turret_read_plans_registration', 'test_all_c07_build_turret_read_plans_input_evidence_is_exact', 'test_build_turret_read_plans_state', 'test_reference_graph_and_actual_c07_build_turret_read_plans']
# The 1 slice source the N2429 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/BuildTurret.java',
]
EXACT_EXPRS = [
    'if(reqs != null){',
    'for(var req : reqs){',
    'unit.plans().add(req);',
]

# DEFERRED is carried from the N2426 register script via import --
# never retyped. This slice resolves NONE of the carried entries
# (the read plans restore is not the init UnitType fields,
# the updateTile plan legs, the Units.nearby mimic query,
# the driver call site, or the timer evaluation), so all are
# carried verbatim. One entry is added: N2429's Windows proof
# debt.
DEFERRED = list(N2426_DEFERRED) + [
    'BuildTurretBuild read() plans restore Windows Godot proof -- debt in GOAL.md section 5, same as N2184-N2201/N2423/N2426: the N2429 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BUILD_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    read_inputs = {
        'reqs_null': a('bool', 'if(reqs != null){', 'Whether the read plans are null (BuildTurret.java:273, `if(reqs != null){`): TypeIO.readPlans returns null when no plans were written, so nothing is restored.'),
        'reqs': a('Array', 'for(var req : reqs){', 'The plans read back by TypeIO.readPlans (BuildTurret.java:272, `var reqs = TypeIO.readPlans(read);`, owned at N2184) iterated by the restore loop (BuildTurret.java:274, `for(var req : reqs){`): plan Dictionaries with x, y, rotation, block, config (the N2423 plan-Dictionary precedent).'),
    }
    read_outputs = {
        'plans_to_add': a('Array', 'unit.plans().add(req);', 'The plans to add back to the unit plan queue, in Java order (BuildTurret.java:275, `unit.plans().add(req);`): every req from the loop, duplicates kept.'),
    }
    return read_inputs, read_outputs


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
    inputs_outputs = [definitions()]
    total = len(EXACT_EXPRS)
    for pair in inputs_outputs:
        for keys in pair:
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
    (read_inputs, read_outputs) = definitions()

    entries = [
        ('N2429', READ_OWNER, 'source_build_turret_read_plans_state', BUILD_TURRET, 'mindustry.world.blocks.defense.BuildTurret', 'BuildTurretBuild.read(Reads, byte)', read_inputs, read_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BuildTurretBuild read() plans restore from BuildTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BuildTurretBuild read() plans restore from BuildTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: plans_to_add.
    by_slice['N2429'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2429', dict(status='done', java_source=BUILD_TURRET, java_class='mindustry.world.blocks.defense.BuildTurret', java_method='BuildTurretBuild.read(Reads, byte)', godot_owner=READ_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2429'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
