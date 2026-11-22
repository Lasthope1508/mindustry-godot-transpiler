"""Register ContinuousTurretBuild.useAmmo()+shouldConsume()+peekAmmo()+activeSoundVolume() (N2421).

ContinuousTurretBuild.useAmmo()
(ContinuousTurret.java:54-57) returns shootType
(the ContinuousTurret block field, :15, default
Bullets.placeholder) with the comment `//nothing
used directly`. ContinuousTurretBuild.shouldConsume()
(ContinuousTurret.java:65-67) returns isShooting
(the TurretBuild field, Turret.java:292).
ContinuousTurretBuild.peekAmmo()
(ContinuousTurret.java:70-72) returns shootType.
ContinuousTurretBuild.activeSoundVolume()
(ContinuousTurret.java:171-173) returns 1f. The
four methods share one concern (ContinuousTurretBuild
ammo one-liners) and each carries only one
distinguishing expr, so they are one slice
(grouping approved by the main thread; N2330/N2367/
N2381/N2384/N2386/N2389 precedent). One slice
entry, one owner
(PortGame.source_continuous_turret_build_ammo_one_liners_state),
one pure function, ONE contract (the N2418
precedent: LaserTurret activeSoundVolume +
shouldActiveSound share one owner/function for the
same reason). The function lives in the existing
PortBridge file (opened by N2355), following the
PortBridge precedent (N2362/N2366/N2367/N2370/
N2375).

RED decisions (resolved at RED): (1) The two
distinguishing exprs are `return shootType;`
(useAmmo + peekAmmo share the one line) and
`return isShooting;` (shouldConsume); `return 1f;`
(activeSoundVolume) is generic. All four
java_methods are 0-hit in both ledgers at probe
time. (2) `return shootType;` is twin-registered
HERE -- PowerTurretBuild.useAmmo/peekAmmo own it
(N1170/N1172, both ledgers) -- and `return
isShooting;` is twin-registered HERE -- TurretBuild
.isShooting (N2343) + LaserTurretBuild.shouldConsume
(N2360) own it locally. The main thread approved
this third twin registration (N1199/N1223, N2389,
N2418 precedent) because the four java_methods are
new. (3) `//nothing used directly` is registered
as evidence (the N2360 precedent) -- it is twin-
owned by N1170. (4) shootType arrives as an
explicit Variant param (the N2330 param precedent;
the twin N1170/N1172 take the same Variant shape)
-- BulletType is NOT ported. isShooting arrives as
an explicit bool param. (5) hasAmmo()
(ContinuousTurret.java:60-62) is NOT in this slice
-- already owned by N2389. (6) NO driver line:
one pure function the setup/tick reads, not
per-tick writes. (7) One owner, NOT one owner per
method: activeSoundVolume takes no inputs, so it
cannot own a schema alone -- the SSOT validator
rejects an input schema with empty keys
(`keys must be a non-empty object`); the first
four-owner draft failed the register with exactly
that error and its partial writes were reset
before this rewrite. Four new result symbols:
use_ammo, should_consume, peek_ammo,
active_sound_volume. Slice source:
ContinuousTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_continuous_turret_version_write_read import DEFERRED as N2375_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
CONTINUOUS_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java'
PROOF = '/root/C07ContinuousTurretAmmoOneLinersProof'
AMMO_ONE_LINERS_OWNER = 'PortGame.source_continuous_turret_build_ammo_one_liners_state'
TESTS = ['test_c07_continuous_turret_ammo_one_liners_registration', 'test_all_c07_continuous_turret_ammo_one_liners_input_evidence_is_exact', 'test_continuous_turret_ammo_one_liners_state', 'test_reference_graph_and_actual_c07_continuous_turret_ammo_one_liners']
# The 1 slice source the N2421 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
]
EXACT_EXPRS = [
    'public class ContinuousTurretBuild extends TurretBuild{',
    'public BulletType shootType = Bullets.placeholder;',
    '@Override',
    'public BulletType useAmmo(){',
    '//nothing used directly',
    'return shootType;',
    'public boolean shouldConsume(){',
    'return isShooting;',
    'public BulletType peekAmmo(){',
    'public float activeSoundVolume(){',
    'return 1f;',
]

# DEFERRED is carried from the N2375 register script via import --
# never retyped. All N2375 entries are carried verbatim (the
# Turret chain, the B/C notes, and N2355/N2362/N2366/N2367/N2370/
# N2375's own Windows proof debt -- none of them is resolved by
# this slice). One entry is added: N2421's Windows proof debt.
DEFERRED = list(N2375_DEFERRED) + [
    'ContinuousTurret useAmmo + shouldConsume + peekAmmo + activeSoundVolume Windows Godot proof -- debt in GOAL.md section 5, same as N2375: the N2421 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=CONTINUOUS_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    use_ammo_line = 'return shootType;'
    should_consume_line = 'return isShooting;'
    active_sound_volume_line = 'return 1f;'
    ammo_one_liners_inputs = {
        'shoot_type': a('Variant', use_ammo_line, 'The shoot type, shootType (ContinuousTurret.java:15, `public BulletType shootType = Bullets.placeholder;`, returned at :56 and :71, `return shootType;`): the ContinuousTurret block field -- BulletType is NOT ported, so the type arrives as an explicit Variant (the N2330 param precedent; the twin N1170/N1172 take the same Variant shape).'),
        'is_shooting': a('bool', should_consume_line, 'Whether the build is shooting, isShooting (ContinuousTurret.java:66, `return isShooting;`): the TurretBuild field (Turret.java:292) -- true while the turret is firing, false otherwise.'),
    }
    ammo_one_liners_outputs = {
        'use_ammo': a('Variant', use_ammo_line, 'The ammo type to use (ContinuousTurret.java:56, `return shootType;`): useAmmo returns the shoot type unchanged -- nothing is consumed directly (ContinuousTurret.java:55, `//nothing used directly`).'),
        'should_consume': a('bool', should_consume_line, 'Whether the build should consume (ContinuousTurret.java:66, `return isShooting;`): true exactly while shooting -- the consume gate follows the firing state.'),
        'peek_ammo': a('Variant', use_ammo_line, 'The peeked ammo type (ContinuousTurret.java:71, `return shootType;`): peekAmmo returns the shoot type unchanged, without consuming it.'),
        'active_sound_volume': a('float', active_sound_volume_line, 'The active-sound volume (ContinuousTurret.java:172, `return 1f;`): a constant 1f -- the loop always plays at full volume while it sounds.'),
    }
    return (ammo_one_liners_inputs, ammo_one_liners_outputs)


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
    (ammo_one_liners_inputs, ammo_one_liners_outputs) = definitions()

    entries = [
        ('N2421', AMMO_ONE_LINERS_OWNER, 'source_continuous_turret_build_ammo_one_liners_state', CONTINUOUS_TURRET, 'mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', 'ContinuousTurretBuild.useAmmo(); ContinuousTurretBuild.shouldConsume(); ContinuousTurretBuild.peekAmmo(); ContinuousTurretBuild.activeSoundVolume()', ammo_one_liners_inputs, ammo_one_liners_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ContinuousTurretBuild.useAmmo()+shouldConsume()+peekAmmo()+activeSoundVolume() state from ContinuousTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ContinuousTurretBuild.useAmmo()+shouldConsume()+peekAmmo()+activeSoundVolume() state from ContinuousTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: use_ammo, should_consume,
    # peek_ammo, active_sound_volume.
    by_slice['N2421'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2421', dict(status='done', java_source=CONTINUOUS_TURRET, java_class='mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', java_method='ContinuousTurretBuild.useAmmo(); ContinuousTurretBuild.shouldConsume(); ContinuousTurretBuild.peekAmmo(); ContinuousTurretBuild.activeSoundVolume()', godot_owner=AMMO_ONE_LINERS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2421'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
