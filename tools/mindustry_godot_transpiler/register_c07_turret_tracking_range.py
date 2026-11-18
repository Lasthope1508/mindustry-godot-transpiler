"""Register the TurretBuild.trackingRange() accessor (N2273).

TurretBuild.trackingRange() (Turret.java:349-351, `public
float trackingRange(){` / `return range() +
trackingRange - range;`) over the TurretBuild.range()
result (Turret.java:342-345, `public float range(){` /
`return range + peekAmmo().rangeChange;` when peekAmmo()
is non-null (Turret.java:693, `public @Nullable
BulletType peekAmmo(){`), else `return range;`), the
Turret def trackingRange field (Turret.java:72, `public
float trackingRange = 0f;`, "Range at which it finds and
locks on to the target, but does not shoot.") and the
BaseTurret def range (BaseTurret.java:21, `public float
range = 80f;`). The peeked bullet's rangeChange is
BulletType.java:157, `public float rangeChange = 0f;`,
default 0f. init() clamps the field (Turret.java:217,
`trackingRange = Math.max(range, trackingRange);`), so
after init trackingRange() >= range(). The range() result
arrives as an explicit param (the N2270 precedent):
range() itself is not a live SourceTurretBuildState row
(the old N739/N740 rows live in PortGame) and reads
peekAmmo(), which the tick frame does not track. No
driver line: trackingRange() is a load-time accessor
findTarget reads at Turret.java:652 (`float trackRange =
trackingRange(), range = range();`), not a per-tick write
(the N2268/N2249 accessor precedent). One new result
symbol: tracking_range. Slice sources: Turret.java +
BaseTurret.java + BulletType.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_find_target import DEFERRED as N2270_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
PROOF = '/root/C07TurretTrackingRangeProof'
TRACKING_RANGE_OWNER = 'SourceTurretBuildState.source_turret_tracking_range_state'
TESTS = ['test_c07_turret_tracking_range_registration', 'test_all_c07_turret_tracking_range_input_evidence_is_exact', 'test_turret_tracking_range_state', 'test_reference_graph_and_actual_c07_turret_tracking_range']
# The 3 slice sources the N2273 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/entities/bullet/BulletType.java',
]
EXACT_EXPRS = [
    'public float trackingRange(){',
    'return range() + trackingRange - range;',
    'public float range(){',
    'return range + peekAmmo().rangeChange;',
    'return range;',
    'public float trackingRange = 0f;',
    'trackingRange = Math.max(range, trackingRange);',
    'public float range = 80f;',
    'public float rangeChange = 0f;',
    'public @Nullable BulletType peekAmmo(){',
    'float trackRange = trackingRange(), range = range();',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'public class BaseTurret extends Block{',
]

# DEFERRED is carried from the N2270 register script via import --
# never retyped. This slice closes the trackingRange part of the
# N2270 follow-up entry (trackingRange is now ported; range()
# stays an explicit value and hasAmmo()/peekAmmo() stay their
# own slices), so that entry is replaced by a corrected one.
# One entry is added: the N2273 Windows Godot proof debt
# (GOAL.md section 5).
DEFERRED = [e for e in N2270_DEFERRED if 'trackingRange() (Turret.java:349-351)' not in e] + [
    'Port TurretBuild.range() (Turret.java:342-345, N740) as an explicit value; N2273 ports trackingRange() and takes the range() result as an explicit float, same as N2270. Port TurretBuild.hasAmmo() (Turret.java:698-712, ammo-swap side effect) and peekAmmo() (Turret.java:693-695) as their own slices; N2270/N2273 take no ammo flags.',
    'Turret trackingRange() Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2273 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    tracking_range_inputs = {
        'frame': a('Dictionary', 'public float trackingRange(){', 'The turret frame (accepted for the family call shape; this leg reads no live frame key -- all live values arrive as explicit params, the N2188 per-def-param precedent, because the tick frame tracks only cheating/enabled/power_status/efficiency).'),
        'range_value': a('float', 'public float range(){', 'The TurretBuild.range() result in world pixels: range + peekAmmo().rangeChange when peekAmmo() is non-null, else range (Turret.java:342-345); passed explicitly because range() reads peekAmmo() (Turret.java:693, `public @Nullable BulletType peekAmmo(){`) and the tick frame tracks no ammo state yet -- range() itself is not a live SourceTurretBuildState row (the old N739/N740 rows live in PortGame).'),
        'tracking_range': a('float', 'public float trackingRange = 0f;', 'The Turret def trackingRange field in world pixels: "Range at which it finds and locks on to the target, but does not shoot." (Turret.java:72), default 0f; init() clamps it (`trackingRange = Math.max(range, trackingRange);`, Turret.java:217), so after init it is at least the def range; passed explicitly because it is per-def static state, not a live frame key.'),
        'range': a('float', 'public float range = 80f;', 'The def range in world pixels: BaseTurret.range (BaseTurret.java:21), default 80f, the subtrahend of the trackingRange() formula (Turret.java:350, `return range() + trackingRange - range;`); passed explicitly because it is per-def static state, not a live frame key.', source=BASE_TURRET),
    }
    tracking_range_outputs = {
        'tracking_range': a('float', 'return range() + trackingRange - range;', 'The live tracking range in world pixels: range() + trackingRange - range (Turret.java:349-351); read by findTarget at Turret.java:652 (`float trackRange = trackingRange(), range = range();`); after init() the field is clamped so the result is at least range().'),
    }
    return tracking_range_inputs, tracking_range_outputs


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
    tracking_range_inputs, tracking_range_outputs = definitions()

    entries = [
        ('N2273', TRACKING_RANGE_OWNER, 'source_turret_tracking_range_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.trackingRange()', tracking_range_inputs, tracking_range_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.trackingRange() state from Turret.java + BaseTurret.java + BulletType.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.trackingRange() state from Turret.java + BaseTurret.java + BulletType.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: tracking_range.
    by_slice['N2273'] = [
        'source_turret_tracking_range_state_result.tracking_range',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2273', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.trackingRange()', godot_owner=TRACKING_RANGE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2273'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
