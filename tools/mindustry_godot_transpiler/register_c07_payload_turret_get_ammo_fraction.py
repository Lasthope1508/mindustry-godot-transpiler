"""Register the PayloadTurret getAmmoFraction() (N2487).

PayloadTurretBuild.getAmmoFraction()
(PayloadAmmoTurret.java:159-162, `@Override` /
`public float getAmmoFraction(){` /
`return (float)totalAmmo / maxAmmo;`) is one pure
function on the existing
SourcePayloadAmmoTurretBuildPortBridge.gd, following the
ContinuousTurret PortBridge precedent
(SourceContinuousTurretBuildPortBridge.gd, N2355) and the
ItemTurret PortBridge precedent
(SourceItemTurretBuildPortBridge.gd:23,
source_item_turret_build_get_ammo_fraction_state). It
returns the precomputed totalAmmo over maxAmmo (3, the
PayloadAmmoTurret ctor default) as a float fraction.

RED decisions (resolved at RED): (1) The function lives
directly in the existing PortBridge file: there is no
SourcePayloadAmmoTurretBuildState.gd to delegate to.
The SSOT owner is PortGame (not the bridge filename):
PortBridge files are discovered by the catalog validator
as port_game.* (source_symbols._discover_godot_owner_functions
forces class_name "port_game" for *PortBridge.gd), the same
as every other PortBridge contract (e.g. N1181
PortGame.source_item_turret_build_get_ammo_fraction_state,
N2355 PortGame.source_continuous_turret_build_get_ammo_fraction_state,
N2368 PortGame.source_payload_ammo_turret_build_get_ammo_content_state).
Registering the bridge filename as owner breaks
implementation_linkage validation (gate batch 9: 9 failures)
-- fixed here, owner PortGame.
(2) GENERIC LITERAL, NOT twin-register: the body
`return (float)totalAmmo / maxAmmo;` is ALREADY an
exact_expr of N1181 ItemTurretBuild.getAmmoFraction()
-- same body, different class, no shared owner (the
N2479 precedent: BaseTurretBuild.buildRotation() shares
its `return rotation;` body with N2233/N1839/N2223 and
needed no twin approval). N1181's deferred_exprs say
only "No maxAmmo zero guard is added because the upstream
Java return expression has no guard" -- no reservation
of a Payload port. The displayBars lambda (N2381,
PayloadAmmoTurret.java:174) repeats the same arithmetic
inside a Bar spec -- it is a DIFFERENT method and is
NOT touched here.
(3) totalAmmo is a PRECOMPUTED input (the N1181
precedent): the TurretBuild frame field (`public int
totalAmmo;`, Turret.java:283), refreshed only by
updateTile (`totalAmmo = payloads.total();`,
PayloadAmmoTurret.java:166, N2381) -- the function
never recomputes it from payloads. maxAmmo is the
ctor default (`maxAmmo = 3;`, PayloadAmmoTurret.java:29,
overriding the Turret base default 30, Turret.java:47)
and arrives as an explicit param. NO divide-by-zero
guard: upstream has none -- Java float division by
zero yields Infinity, and GDScript float division by
zero yields INF the same way (the N1181 deferred
precedent). NO clamp: a totalAmmo above maxAmmo passes
through above 1.0.
(4) NO driver line: a pure accessor the HUD caller
reads, not a per-tick write. One new result symbol:
ammo_fraction. Slice source: PayloadAmmoTurret.java
only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
PAYLOAD_AMMO_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java'
PROOF = '/root/C07PayloadTurretGetAmmoFractionProof'
FRACTION_OWNER = 'PortGame.source_payload_ammo_turret_build_get_ammo_fraction_state'
TESTS = ['test_c07_payload_turret_get_ammo_fraction_registration', 'test_all_c07_payload_turret_get_ammo_fraction_input_evidence_is_exact', 'test_payload_turret_get_ammo_fraction_state', 'test_reference_graph_and_actual_c07_payload_turret_get_ammo_fraction']
# The 1 slice source the N2487 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
]
EXACT_EXPRS = [
    'public class PayloadAmmoTurret extends Turret{',
    'public class PayloadTurretBuild extends TurretBuild{',
    '@Override',
    'public float getAmmoFraction(){',
    'return (float)totalAmmo / maxAmmo;',
]

# DEFERRED is a small focused list (the N2485/N2486
# convention). The old Payload chain register scripts
# carry a module-level DEFERRED list that has since
# grown to 400+ entries from other families (it is NOT
# what landed in those slices' ledger entries -- N2416
# records 73, N2381 records 69); importing it would
# dump unrelated entries into this slice. The chain's
# substance -- the sibling-method notes -- is carried
# here in focused form instead.
DEFERRED = [
    'PayloadTurret getAmmoFraction Windows Godot proof -- debt in GOAL.md section 5: the N2487 proof runs headless on Linux here and waits for a Windows Godot run.',
    'PayloadTurretBuild.getAmmoFraction() is a GENERIC LITERAL with N1181 ItemTurretBuild.getAmmoFraction(), verified by the main thread (2026-11-27), no twin-register needed: same body `return (float)totalAmmo / maxAmmo;`, different class, no shared owner (the N2479 precedent). N1181\'s deferred_exprs record only the no-zero-guard note; no Payload port was reserved. No GD function computes the PayloadTurretBuild override yet.',
    'PayloadTurretBuild.displayBars(Table) (PayloadAmmoTurret.java:171-177, N2381) is NOT in this slice: displayBars adds a Bar spec whose fraction lambda repeats the same arithmetic -- it is a UI spec, not this return; the proof cross-pins the two against each other for the same inputs.',
    'PayloadTurretBuild.updateTile() (PayloadAmmoTurret.java:165-168, N2381, `totalAmmo = payloads.total();`) is NOT in this slice: updateTile refreshes the totalAmmo frame field -- this slice only reads the precomputed value as an explicit input, it never recomputes it from payloads.',
    'No maxAmmo zero guard is added because the upstream Java return expression has no guard (the N1181 deferred precedent): Java float division by zero yields Infinity, and GDScript float division by zero yields INF the same way.',
]


def definitions():
    def a(typ, expr, rule, source=PAYLOAD_AMMO_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    fraction_inputs = {
        'total_ammo': a('float', 'return (float)totalAmmo / maxAmmo;', 'The precomputed totalAmmo (PayloadAmmoTurret.java:161, `return (float)totalAmmo / maxAmmo;`): the TurretBuild frame field (`public int totalAmmo;`, Turret.java:283), refreshed only by updateTile (`totalAmmo = payloads.total();`, PayloadAmmoTurret.java:166, N2381) -- the function never recomputes it from payloads (the N1181 precomputed-input precedent); arrives as an explicit param.'),
        'max_ammo': a('float', 'maxAmmo = 3;', 'The maxAmmo divisor (PayloadAmmoTurret.java:29, `maxAmmo = 3;`): the PayloadAmmoTurret ctor default, overriding the Turret base default 30 (Turret.java:47); arrives as an explicit param.'),
    }
    fraction_outputs = {
        'ammo_fraction': a('float', 'return (float)totalAmmo / maxAmmo;', 'The ammo fraction (PayloadAmmoTurret.java:161, `return (float)totalAmmo / maxAmmo;`): the precomputed totalAmmo over maxAmmo as a float -- 1.0 when full, 0.0 when empty, above 1.0 when totalAmmo exceeds maxAmmo (no clamp), Infinity when maxAmmo is zero (no guard -- Java float division by zero yields Infinity, the N1181 deferred precedent).'),
    }
    return (fraction_inputs, fraction_outputs)


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
    (fraction_inputs, fraction_outputs) = definitions()

    entries = [
        ('N2487', FRACTION_OWNER, 'source_payload_ammo_turret_build_get_ammo_fraction_state', PAYLOAD_AMMO_TURRET, 'mindustry.world.blocks.defense.turrets.PayloadAmmoTurret.PayloadTurretBuild', 'PayloadTurretBuild.getAmmoFraction()', fraction_inputs, fraction_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PayloadTurretBuild.getAmmoFraction() state from PayloadAmmoTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PayloadTurretBuild.getAmmoFraction() state from PayloadAmmoTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: ammo_fraction.
    by_slice['N2487'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2487', dict(status='done', java_source=PAYLOAD_AMMO_TURRET, java_class='mindustry.world.blocks.defense.turrets.PayloadAmmoTurret.PayloadTurretBuild', java_method='PayloadTurretBuild.getAmmoFraction()', godot_owner=FRACTION_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2487'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
