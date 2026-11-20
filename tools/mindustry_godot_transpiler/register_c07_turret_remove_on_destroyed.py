"""Register the Turret remove() + onDestroyed() (N2350).

TurretBuild.remove() (Turret.java:303-308,
`@Override` / `public void remove(){` / `super.remove();`
/ `if(soundLoop != null){` / `soundLoop.stop();` / `}`
/ `}`) and TurretBuild.onDestroyed()
(Turret.java:311-317, `@Override` /
`public void onDestroyed(){` / `super.onDestroyed();` /
`if(soundLoop != null){` / `soundLoop.stop();` / `}`
/ `}`) are two pure lifecycle functions on
SourceTurretBuildState.gd next to the N2348
getAmmoContent/getAmmoFraction accessors. Both stop the
sound loop when it is non-null and do nothing when it is
null; the two bodies differ only in the super call.
soundLoop is the TurretBuild field (Turret.java:298,
`public @Nullable SoundLoop soundLoop = (loopSound ==
Sounds.none ? null : new SoundLoop(loopSound,
loopSoundVolume));`). NO SoundLoop playback in this slice
(the N2346 precedent -- the updateTile tick at :499 only
updates the loop; removal/destruction only ever stops
it, and the stop itself is returned as a flag, never
executed).

RED decisions (resolved at RED): (1) One slice entry for
the two methods, following the N2345/N2346/N2348 precedent
(one ledger entry per method group, one function per
method) -- remove keeps its own function and onDestroyed
keeps its own. (2) The null check arrives as the explicit
bool has_sound_loop (the minRange has_ammo precedent --
a null check carried as an explicit bool; GDScript has no
SoundLoop object here); the frame is the family-convention
first arg, kept even when the function reads nothing from
it (the isShooting :429 precedent). (3) Each function
returns one key, `sound_loop_stopped`: true when a live
loop is stopped, false when the loop is null (a no-op).
(4) super.remove()/super.onDestroyed() are the Building
base -- deferred, not ported (the N2348 super-call
precedent). (5) NO driver line: the engine lifecycle
calls remove()/onDestroyed(); no call site is ported
here (the shouldTurn/isShooting precedent). (6) Evidence,
not ownership: the body `super.onDestroyed();` already
appears in N921 (PowerGenerator, a different class with
the same one-line super call) and `super.remove();` is
0-hit local -- neither owns TurretBuild.remove() or
TurretBuild.onDestroyed(). Two new result symbols: one
per function. Slice source: Turret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_get_ammo_content_fraction import DEFERRED as N2348_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretRemoveOnDestroyedProof'
REMOVE_OWNER = 'SourceTurretBuildState.source_turret_remove_state'
DESTROYED_OWNER = 'SourceTurretBuildState.source_turret_on_destroyed_state'
TESTS = ['test_c07_turret_remove_on_destroyed_registration', 'test_all_c07_turret_remove_on_destroyed_input_evidence_is_exact', 'test_turret_remove_on_destroyed_state', 'test_reference_graph_and_actual_c07_turret_remove_on_destroyed']
# The 1 slice source the N2350 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = [
    'public class Turret extends ReloadTurret{',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'public @Nullable SoundLoop soundLoop = (loopSound == Sounds.none ? null : new SoundLoop(loopSound, loopSoundVolume));',
    '@Override',
    'public void remove(){',
    'super.remove();',
    'if(soundLoop != null){',
    'soundLoop.stop();',
    'public void onDestroyed(){',
    'super.onDestroyed();',
]

# DEFERRED is carried from the N2348 register script via import --
# never retyped. All N2348 entries are carried verbatim (the
# N2346 chain, the B/C notes, and N2348's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2350's Windows proof debt.
DEFERRED = list(N2348_DEFERRED) + [
    'Turret remove/onDestroyed Windows Godot proof -- debt in GOAL.md section 5, same as N2348: the N2350 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    remove_inputs = {
        'frame': a('Dictionary', 'public void remove(){', 'The turret frame (TurretBuild.remove, Turret.java:303): the family-convention first arg every Turret pure function takes; it carries no tracked key for this lifecycle method -- the live value arrives as an explicit param (the isShooting :429 precedent).'),
        'has_sound_loop': a('bool', 'if(soundLoop != null){', 'Whether the turret has a live sound loop (`soundLoop != null`, Turret.java:305): the TurretBuild field (`public @Nullable SoundLoop soundLoop = (loopSound == Sounds.none ? null : new SoundLoop(loopSound, loopSoundVolume));`, Turret.java:298); arrives as an explicit bool param -- the null check is folded into this param (the minRange has_ammo precedent; GDScript has no SoundLoop object here).'),
    }
    remove_outputs = {
        'sound_loop_stopped': a('bool', 'soundLoop.stop();', 'Whether the sound loop was stopped (Turret.java:306, `soundLoop.stop();`): true when the loop is non-null (the stop is issued), false when it is null (a no-op). Returned as a flag only -- no real audio is stopped here.'),
    }
    destroyed_inputs = {
        'frame': a('Dictionary', 'public void onDestroyed(){', 'The turret frame (TurretBuild.onDestroyed, Turret.java:311): the family-convention first arg every Turret pure function takes; it carries no tracked key for this lifecycle method -- the live value arrives as an explicit param (the isShooting :429 precedent).'),
        'has_sound_loop': a('bool', 'if(soundLoop != null){', 'Whether the turret has a live sound loop (`soundLoop != null`, Turret.java:313): the TurretBuild field (`public @Nullable SoundLoop soundLoop = (loopSound == Sounds.none ? null : new SoundLoop(loopSound, loopSoundVolume));`, Turret.java:298); arrives as an explicit bool param -- the null check is folded into this param (the minRange has_ammo precedent; GDScript has no SoundLoop object here).'),
    }
    destroyed_outputs = {
        'sound_loop_stopped': a('bool', 'soundLoop.stop();', 'Whether the sound loop was stopped (Turret.java:314, `soundLoop.stop();`): true when the loop is non-null (the stop is issued), false when it is null (a no-op). Returned as a flag only -- no real audio is stopped here.'),
    }
    return (remove_inputs, remove_outputs, destroyed_inputs, destroyed_outputs)


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
    (remove_inputs, remove_outputs, destroyed_inputs, destroyed_outputs) = definitions()

    entries = [
        ('N2350', REMOVE_OWNER, 'source_turret_remove_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.remove()', remove_inputs, remove_outputs, True, 'Dictionary'),
        ('N2350', DESTROYED_OWNER, 'source_turret_on_destroyed_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.onDestroyed()', destroyed_inputs, destroyed_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.remove()/onDestroyed() state from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.remove()/onDestroyed() state from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: remove, on_destroyed.
    by_slice['N2350'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2350', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.remove(); TurretBuild.onDestroyed()', godot_owner=REMOVE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2350'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
