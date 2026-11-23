"""Register the anonymous ConsumeItemFilter.efficiency() in ItemTurret.init() (N2419).

Anonymous ConsumeItemFilter.efficiency(Building build) inside
ItemTurret.init() (ItemTurret.java:83-88,
`public float efficiency(Building build){` /
`//valid when it can shoot` /
`return build instanceof ItemTurretBuild it && it.ammo.size > 0
&& (it.ammo.peek().amount >= ammoPerShot || it.cheating()) ? 1f
: 0f;`) is 1.0 exactly when the build is an ItemTurretBuild
with ammo and the peeked entry holds at least ammoPerShot --
or the build is cheating -- else 0.0. Valid when it can shoot.
The 1 distinguishing return expr is 0-hit in both the local
and the remote ledger (re-probed at base 3de1786d, remote
origin/main 50bde34b); the comment is 0-hit in both; the
signature `public float efficiency(Building build){` is generic
(15 ledger records) and is registered per the N2318 precedent.
N1177 owns ItemTurret.init() but NOT this efficiency leg;
N1467 owns the base ConsumeItemFilter.efficiency() body
(`return build.consumeTriggerValid() || getConsumed(build) !=
null ? 1f : 0f;`); the PAT twin (`return build instanceof
PayloadTurretBuild it && it.payloads.any() ? 1f : 0f;`) is
N2396-owned -- none is re-registered here. One pure function
on SourceItemTurretBuildPortBridge.gd (the ItemTurret file,
NOT a new file -- N2416 ctor precedent). The owner is
PortGame.* (this file is a PortBridge -- N2358/N2384/N2396
precedent), NOT the file class name. `it.ammo.peek().amount`
is the peeked ItemEntry amount (ItemTurret.java:226,
`public class ItemEntry extends AmmoEntry{`), `ammoPerShot`
is the Turret field (Turret.java:49, `public int ammoPerShot
= 1;`), `it.cheating()` is the BuildingComp call-site -- all
arrive as explicit params, no live engine is called. The
result is frame data (one float); no Draw is ported. One new
result symbol: efficiency. One slice source: ItemTurret.java
only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_payload_ammo_turret_default_constructor import DEFERRED as N2416_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
ITEM_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java'
PROOF = '/root/C07ItemTurretEfficiencyProof'
EFFICIENCY_OWNER = 'PortGame.source_item_turret_efficiency_state'
TESTS = ['test_c07_item_turret_efficiency_registration', 'test_all_c07_item_turret_efficiency_input_evidence_is_exact', 'test_item_turret_efficiency_state', 'test_reference_graph_and_actual_c07_item_turret_efficiency']
# The 1 slice source the N2419 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java',
]
EXACT_EXPRS = [
    'return build instanceof ItemTurretBuild it && it.ammo.size > 0 && (it.ammo.peek().amount >= ammoPerShot || it.cheating()) ? 1f : 0f;',
    'public float efficiency(Building build){',
    '//valid when it can shoot',
]

# DEFERRED is carried from the N2416 register script via import --
# never retyped. Nothing in it closes here: N2419 ports the
# ItemTurret anonymous ConsumeItemFilter.efficiency() leg, which
# no N2416 entry lists. One entry is added: the N2419 Windows
# Godot proof debt (GOAL.md section 5).
DEFERRED = list(N2416_DEFERRED) + [
    'ItemTurret anonymous ConsumeItemFilter.efficiency() N2419 Windows Godot proof -- debt in GOAL.md section 5, same as N2416: the N2419 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=ITEM_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    efficiency_inputs = {
        'is_item_turret_build': a('bool', 'return build instanceof ItemTurretBuild it && it.ammo.size > 0 && (it.ammo.peek().amount >= ammoPerShot || it.cheating()) ? 1f : 0f;', 'Whether the build is an ItemTurretBuild (ItemTurret.java:86, `return build instanceof ItemTurretBuild it && it.ammo.size > 0 && (it.ammo.peek().amount >= ammoPerShot || it.cheating()) ? 1f : 0f;`): the `build instanceof ItemTurretBuild it` pattern guard, passed as an explicit bool param.'),
        'ammo_size': a('int', 'return build instanceof ItemTurretBuild it && it.ammo.size > 0 && (it.ammo.peek().amount >= ammoPerShot || it.cheating()) ? 1f : 0f;', 'The ammo seq size (ItemTurret.java:86, `return build instanceof ItemTurretBuild it && it.ammo.size > 0 && (it.ammo.peek().amount >= ammoPerShot || it.cheating()) ? 1f : 0f;`): `it.ammo.size > 0` -- the build holds ammo only when the seq is non-empty, passed as an explicit int param; the peeked amount is only read when this is positive.'),
        'peek_amount': a('int', 'return build instanceof ItemTurretBuild it && it.ammo.size > 0 && (it.ammo.peek().amount >= ammoPerShot || it.cheating()) ? 1f : 0f;', 'The peeked entry amount (ItemTurret.java:86, `return build instanceof ItemTurretBuild it && it.ammo.size > 0 && (it.ammo.peek().amount >= ammoPerShot || it.cheating()) ? 1f : 0f;`): `it.ammo.peek().amount` -- the ItemEntry amount (ItemTurret.java:226, `public class ItemEntry extends AmmoEntry{`), passed as an explicit int param.'),
        'ammo_per_shot': a('int', 'return build instanceof ItemTurretBuild it && it.ammo.size > 0 && (it.ammo.peek().amount >= ammoPerShot || it.cheating()) ? 1f : 0f;', 'The ammo per shot (ItemTurret.java:86, `return build instanceof ItemTurretBuild it && it.ammo.size > 0 && (it.ammo.peek().amount >= ammoPerShot || it.cheating()) ? 1f : 0f;`): `ammoPerShot` -- the Turret field (Turret.java:49, `public int ammoPerShot = 1;`), passed as an explicit int param.'),
        'cheating': a('bool', 'return build instanceof ItemTurretBuild it && it.ammo.size > 0 && (it.ammo.peek().amount >= ammoPerShot || it.cheating()) ? 1f : 0f;', 'Whether the build is cheating (ItemTurret.java:86, `return build instanceof ItemTurretBuild it && it.ammo.size > 0 && (it.ammo.peek().amount >= ammoPerShot || it.cheating()) ? 1f : 0f;`): `it.cheating()` -- the BuildingComp call-site, passed as an explicit bool param, NOT re-ported here.'),
    }
    efficiency_outputs = {
        'efficiency': a('float', 'return build instanceof ItemTurretBuild it && it.ammo.size > 0 && (it.ammo.peek().amount >= ammoPerShot || it.cheating()) ? 1f : 0f;', 'The consumer efficiency (ItemTurret.java:86, `return build instanceof ItemTurretBuild it && it.ammo.size > 0 && (it.ammo.peek().amount >= ammoPerShot || it.cheating()) ? 1f : 0f;`): 1.0 exactly when the build is an ItemTurretBuild with ammo and the peeked entry holds at least ammoPerShot -- or the build is cheating -- else 0.0 -- valid when it can shoot.'),
    }
    return efficiency_inputs, efficiency_outputs


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
    efficiency_inputs, efficiency_outputs = definitions()

    entries = [
        ('N2419', EFFICIENCY_OWNER, 'source_item_turret_efficiency_state', ITEM_TURRET, 'mindustry.world.blocks.defense.turrets.ItemTurret', 'ItemTurret.init() ConsumeItemFilter.efficiency(Building build)', efficiency_inputs, efficiency_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ItemTurret anonymous ConsumeItemFilter.efficiency() state from ItemTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ItemTurret anonymous ConsumeItemFilter.efficiency() state from ItemTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the efficiency only.
    by_slice['N2419'] = [
        'source_item_turret_efficiency_state_result.efficiency',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2419', dict(status='done', java_source=ITEM_TURRET, java_class='mindustry.world.blocks.defense.turrets.ItemTurret', java_method='ItemTurret.init() ConsumeItemFilter.efficiency(Building build)', godot_owner=EFFICIENCY_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2419'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
