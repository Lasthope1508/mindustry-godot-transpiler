"""Register the Turret getAmmoContent() + getAmmoFraction() (N2348).

TurretBuild.getAmmoContent() (Turret.java:319-321,
`@Nullable` / `public UnlockableContent getAmmoContent(){`
/ `return null;` / `}`) and TurretBuild.getAmmoFraction()
(Turret.java:324-326, `/** @return ammo as a fraction of
capacity; used for direct turret control HUD */` /
`public float getAmmoFraction(){` / `return 1f;` / `}`)
are two pure constant functions on
SourceTurretBuildState.gd next to the N2329 peekAmmo
accessor. Both are BASE-class defaults: the base
TurretBuild has no ammo content (null) and counts as
full (1f). The subclass overrides own their own bodies
and are NOT touched here -- ItemTurretBuild (N1180/N1181),
LiquidTurretBuild (N1197/N1198),
ContinuousLiquidTurretBuild (N1220/N1221), PowerTurretBuild
(N1168). NO @Override on the base: the base overrides
nothing.

RED decisions (resolved at RED): (1) One slice entry for
the two methods, following the N2345/N2346 precedent (one
ledger entry per method group, one function per method) --
getAmmoContent keeps its own function and getAmmoFraction
keeps its own. (2) Both functions take only the frame
(the isShooting :429 precedent -- the frame is the
family-convention first arg, kept even when the function
reads nothing from it); there is no live input -- both
bodies are constants. (3) ammo_content is Variant: the
base returns null and GD has no UnlockableContent mapping
(the subclass overrides map real content). (4) NO driver
line: both are pure defaults the callers read, not
per-tick writes -- updateTile :495 reads getAmmoFraction()
and DrawTurret :108-112 reads getAmmoContent(); neither
caller is ported here (the shouldTurn/isShooting
precedent). (5) Evidence, not ownership: the body
`return null;` / `return 1f;` never appears in any other
Turret.java slice (the scope probe greps every slice with
java_source ending in turrets/Turret.java) -- the two
constants are new. Two new result symbols: one per
function. Slice source: Turret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_active_sound_volume import DEFERRED as N2346_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretGetAmmoContentFractionProof'
CONTENT_OWNER = 'SourceTurretBuildState.source_turret_get_ammo_content_state'
FRACTION_OWNER = 'SourceTurretBuildState.source_turret_get_ammo_fraction_state'
TESTS = ['test_c07_turret_get_ammo_content_fraction_registration', 'test_all_c07_turret_get_ammo_content_fraction_input_evidence_is_exact', 'test_turret_get_ammo_content_fraction_state', 'test_reference_graph_and_actual_c07_turret_get_ammo_content_fraction']
# The 1 slice source the N2348 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = [
    'public class Turret extends ReloadTurret{',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    '@Nullable',
    'public UnlockableContent getAmmoContent(){',
    'return null;',
    '/** @return ammo as a fraction of capacity; used for direct turret control HUD */',
    'public float getAmmoFraction(){',
    'return 1f;',
]

# DEFERRED is carried from the N2346 register script via import --
# never retyped. All N2346 entries are carried verbatim (the
# N2337 chain, the B/C notes, and N2346's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2348's Windows proof debt.
DEFERRED = list(N2346_DEFERRED) + [
    'Turret getAmmoContent/getAmmoFraction Windows Godot proof -- debt in GOAL.md section 5, same as N2346: the N2348 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    content_inputs = {
        'frame': a('Dictionary', 'public UnlockableContent getAmmoContent(){', 'The turret frame (TurretBuild.getAmmoContent, Turret.java:319): the family-convention first arg every Turret pure function takes; it carries no tracked key for this accessor -- the base default is a constant null, so the live value is not read from the frame (the isShooting :429 precedent).'),
    }
    content_outputs = {
        'ammo_content': a('Variant', 'return null;', 'The ammo content (Turret.java:320, `return null;`): the base TurretBuild has no ammo content -- null. GD has no UnlockableContent mapping; the subclass overrides (N1180/N1197/N1220) map real content.'),
    }
    fraction_inputs = {
        'frame': a('Dictionary', 'public float getAmmoFraction(){', 'The turret frame (TurretBuild.getAmmoFraction, Turret.java:324): the family-convention first arg every Turret pure function takes; it carries no tracked key for this accessor -- the base default is a constant 1f, so the live value is not read from the frame (the isShooting :429 precedent).'),
    }
    fraction_outputs = {
        'ammo_fraction': a('float', 'return 1f;', 'The ammo fraction (Turret.java:325, `return 1f;`): the base TurretBuild counts as full -- ammo as a fraction of capacity, used for direct turret control HUD (the javadoc, Turret.java:323).'),
    }
    return (content_inputs, content_outputs, fraction_inputs, fraction_outputs)


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
    (content_inputs, content_outputs, fraction_inputs, fraction_outputs) = definitions()

    entries = [
        ('N2348', CONTENT_OWNER, 'source_turret_get_ammo_content_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.getAmmoContent()', content_inputs, content_outputs, True, 'Dictionary'),
        ('N2348', FRACTION_OWNER, 'source_turret_get_ammo_fraction_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.getAmmoFraction()', fraction_inputs, fraction_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.getAmmoContent()/getAmmoFraction() state from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.getAmmoContent()/getAmmoFraction() state from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: ammo_content, ammo_fraction.
    by_slice['N2348'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2348', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.getAmmoContent(); TurretBuild.getAmmoFraction()', godot_owner=CONTENT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2348'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
