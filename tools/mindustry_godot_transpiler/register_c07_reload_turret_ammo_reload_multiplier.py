"""Register ReloadTurretBuild.ammoReloadMultiplier() (N2481).

ReloadTurretBuild.ammoReloadMultiplier() (ReloadTurret.java:41-43)
is one slice (batch 52 slot 3):
    protected float ammoReloadMultiplier(){
        return 1f;
    }
on `public class ReloadTurretBuild extends BaseTurretBuild{`
(ReloadTurret.java:25). The override returns the CONSTANT
1f and reads NO state: no ammo, no coolant, no efficiency.
It "turns off" the parent's ammo multiplier entirely --
updateCooling() still calls it by virtual dispatch
(`reloadCounter += amount * edelta() * capacity *
coolantMultiplier * ammoReloadMultiplier();`,
ReloadTurret.java:35), but the override always contributes
the factor 1. It takes no params, so no input schema is
upserted (the N2422 zero-param contract precedent:
`source_laser_turret_build_placed_state_result` exists
with no `_input` schema; 82 contracts in the ledger have 0
params). One new result symbol: ammo_reload_multiplier.

TRAP: this is NOT TurretBuild.ammoReloadMultiplier()
(N746, Turret.java:727-729, `return hasAmmo() ?
peekAmmo().reloadMultiplier : 1f;` -- the parent-class
method that follows the loaded ammo): a port returning
`peekAmmo().reloadMultiplier` is WRONG -- that is N746's
body, and an ammo with reloadMultiplier 2.5 returns 2.5
there but 1.0 here. N746 registers the parent method as
part of `TurretBuild.updateReload()/ammoReloadMultiplier()`
(its GD owner is the PortGame-era bridge
PortGame.source_turret_reload_seconds_for_ammo, not a pure
function), and it ports NO ReloadTurretBuild override --
this slice adds a real new GD function. TRAP: this is NOT
baseReloadSpeed() (N2476, ReloadTurret.java:45-47,
`return efficiency;`) and NOT canReload() (N2473, :49-51,
`return reloadCounter < reload;`) -- the three consecutive
methods :41/:45/:49 are three separate slices, and this
slice completes the ReloadTurretBuild accessor trio
(updateCooling :28-40 is already N2525). Java order:
ammoReloadMultiplier (:41-43) stands BEFORE
baseReloadSpeed (:45-47, N2476) in the same class, so the
GD function sits before
source_reload_turret_base_reload_speed_state in
SourceTurretBuildState.gd.

CLEAN -- verified by the main thread for N2481
(2026-11-27), no twin-register needed: java_method
`ReloadTurretBuild.ammoReloadMultiplier()` is 0-hit; the
declaration literal `protected float
ammoReloadMultiplier(){` is also an exact_expr of N746,
but that is the shared Java override SIGNATURE, not a
shared body -- N746's body is the ternary on peekAmmo
(Turret.java:727-729) while this body is the constant
`return 1f;` (a generic constant line, 13 exact_expr
hits across slices, all other methods -- NOT twin
evidence). The registry has 0 `ammo_reload_multiplier`
symbols before this slice, and no GD function computes
the ReloadTurretBuild override yet. This is NOT a
duplicate like TeamData.active(), which was permanently
excluded because its behaviour was already ported by
N2074/N2075. One slice source: ReloadTurret.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
PROOF = '/root/C07ReloadTurretAmmoReloadMultiplierProof'
AMMO_RELOAD_OWNER = 'SourceTurretBuildState.source_reload_turret_ammo_reload_multiplier_state'
TESTS = ['test_c07_reload_turret_ammo_reload_multiplier_registration', 'test_all_c07_reload_turret_ammo_reload_multiplier_input_evidence_is_exact', 'test_reload_turret_ammo_reload_multiplier_state', 'test_reference_graph_and_actual_c07_reload_turret_ammo_reload_multiplier']
# The 1 slice source the N2481 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
]
FORMULA = '            return 1f;'
EXACT_EXPRS = [
    '        protected float ammoReloadMultiplier(){',
    FORMULA,
    '    public class ReloadTurretBuild extends BaseTurretBuild{',
]
JAVA_METHOD = 'ReloadTurretBuild.ammoReloadMultiplier()'

DEFERRED = [
    'ReloadTurretBuild.ammoReloadMultiplier() Windows Godot proof -- debt in GOAL.md section 5: the N2481 proof runs headless on Linux here and waits for a Windows Godot run.',
    'ReloadTurretBuild.ammoReloadMultiplier() is CLEAN, verified by the main thread (2026-11-27), no twin-register needed: java_method `ReloadTurretBuild.ammoReloadMultiplier()` is 0-hit and the registry has 0 `ammo_reload_multiplier` symbols before this slice. The declaration literal `protected float ammoReloadMultiplier(){` is also an exact_expr of N746 (TurretBuild.updateReload()/ammoReloadMultiplier()), but that is the shared Java override SIGNATURE, not a shared body -- N746 ports the parent method whose body is the ternary `return hasAmmo() ? peekAmmo().reloadMultiplier : 1f;` (Turret.java:727-729), while this body is the constant `return 1f;` (a generic constant line, 13 exact_expr hits across slices, all other methods). N746 ports NO ReloadTurretBuild override function (its GD owner is the PortGame-era bridge PortGame.source_turret_reload_seconds_for_ammo).',
    'TurretBuild.ammoReloadMultiplier() (Turret.java:727-729, N746, `return hasAmmo() ? peekAmmo().reloadMultiplier : 1f;`) is NOT in this slice: it is the parent-class method whose result follows the loaded ammo -- an ammo with reloadMultiplier 2.5 returns 2.5 there and 1.0 here; the proof pins the cross-trap by evaluating the parent ternary from locals (N746 exposes no pure GD function to call).',
    'ReloadTurretBuild.baseReloadSpeed() (ReloadTurret.java:45-47, N2476, `return efficiency;`) is NOT in this slice: baseReloadSpeed reads the Building efficiency field, ammoReloadMultiplier reads nothing and returns the constant 1f.',
    'ReloadTurretBuild.canReload() (ReloadTurret.java:49-51, N2473, `return reloadCounter < reload;`) is NOT in this slice: canReload gates on the reload counter, ammoReloadMultiplier is an unconditional constant.',
    'ReloadTurretBuild.updateCooling() (ReloadTurret.java:28-40, N2525) consumes this value: `reloadCounter += amount * edelta() * capacity * coolantMultiplier * ammoReloadMultiplier();` (ReloadTurret.java:35) calls the override by virtual dispatch -- the call site belongs to N2525, only the constant factor itself is this slice.',
]


def definitions():
    def a(typ, expr, rule, source=RELOAD_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    # Zero params: ammoReloadMultiplier() takes no state -- no input schema
    # is registered (the N2422 zero-param contract precedent).
    ammo_reload_inputs = {}
    ammo_reload_outputs = {
        'ammo_reload_multiplier': a('float', FORMULA, 'The ammo reload multiplier (ReloadTurret.java:41-43, `return 1f;`): the ReloadTurretBuild override returns the constant 1f and reads no ammo, no coolant, no efficiency -- it "turns off" the parent TurretBuild.ammoReloadMultiplier() (N746, `return hasAmmo() ? peekAmmo().reloadMultiplier : 1f;`), so an ammo with reloadMultiplier 2.5 still contributes the factor 1.0 here.'),
    }
    return ammo_reload_inputs, ammo_reload_outputs


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
    ammo_reload_inputs, ammo_reload_outputs = definitions()

    entries = [
        ('N2481', AMMO_RELOAD_OWNER, 'source_reload_turret_ammo_reload_multiplier_state', RELOAD_TURRET, 'mindustry.world.blocks.defense.turrets.ReloadTurret.ReloadTurretBuild', JAVA_METHOD, ammo_reload_inputs, ammo_reload_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            # Zero params: skip the input schema entirely (the
            # N2422 precedent) -- an empty keys object fails
            # state-schema validation.
            if not keys:
                continue
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ReloadTurretBuild.ammoReloadMultiplier() state from ReloadTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ReloadTurretBuild.ammoReloadMultiplier() state from ReloadTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2481'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2481', dict(status='done', java_source=RELOAD_TURRET, java_class='mindustry.world.blocks.defense.turrets.ReloadTurret.ReloadTurretBuild', java_method=JAVA_METHOD, godot_owner=AMMO_RELOAD_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2481'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
