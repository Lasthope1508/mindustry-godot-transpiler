"""Register the Turret peekAmmo() pure accessor (N2329).

One pure accessor on TurretBuild (Turret.java:277,
`public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`)
in `public class Turret extends ReloadTurret{` (Turret.java:36):

- peekAmmo() (Turret.java:693-695):
  `/** @return the ammo type that will be returned if useAmmo is called. */`
  `public @Nullable BulletType peekAmmo(){`
  `return ammo.size == 0 ? null : ammo.peek().type();`
  `}`

RED decisions (resolved at RED): (1) One pure function --
`source_turret_peek_ammo_state(frame, ammo_stacks)` -- that returns
`{"peek_ammo": <BulletType name or null>}`. The ammo list is an
explicit param (the N2313 hasAmmo precedent): it arrives as an Array
of {amount, item, type} dicts (the peek_ammo_stack_state convention
-- Seq.peek() is the LAST entry). (2) AmmoEntry.type() (`public
abstract BulletType type();`, Turret.java:260) is NOT re-ported here:
for ItemEntry it resolves through the block ammoTypes map (`return
ammoTypes.get(item);`, ItemTurret.java:236-238) and the map itself is
NOT ported -- the BulletType NAME arrives as the explicit "type"
value on each entry dict, and the function returns that name (or null
when the list is empty or the peeked entry carries no type). (3)
peekAmmo() reads ONLY the peek: no amount check and no swap, unlike
hasAmmo() (N2313) -- an entry with amount 0 still returns its type,
and the input list is never mutated. (4) NO driver tick line:
peekAmmo() is a pure accessor its callers read, not a per-tick write
(the N2249/N2221 precedent) -- targetPosition() (Turret.java:454,
remote N2266) and useAmmo() (N2108) read the result; neither caller
is ported here. One new result symbol: peek_ammo. One slice source:
Turret.java only -- every expr (body + field declarations + class
lines) is in Turret.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_controlled import DEFERRED as N2324_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretPeekAmmoProof'
PEEK_AMMO_OWNER = 'SourceTurretBuildState.source_turret_peek_ammo_state'
TESTS = ['test_c07_turret_peek_ammo_registration', 'test_all_c07_turret_peek_ammo_input_evidence_is_exact', 'test_turret_peek_ammo_state', 'test_reference_graph_and_actual_c07_turret_peek_ammo']
# The 1 slice source the N2329 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = [
    'public class Turret extends ReloadTurret{',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    '/** @return the ammo type that will be returned if useAmmo is called. */',
    'public @Nullable BulletType peekAmmo(){',
    'return ammo.size == 0 ? null : ammo.peek().type();',
    'public Seq<AmmoEntry> ammo = new Seq<>();',
    'public int amount;',
    'public abstract BulletType type();',
]

# DEFERRED is carried from the N2324 register script via import --
# never retyped. Two entries are added: the N2329 Windows Godot
# proof debt (GOAL.md section 5) and the note that this slice
# closes the peekAmmo() deferred entries (the N2313 T6 entry and
# the N2301/N2319 notes that targetPosition() also needs it).
DEFERRED = N2324_DEFERRED + [
    'Turret peekAmmo() (TurretBuild.peekAmmo, Turret.java:693-695) Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2329 proof runs headless on Linux here and waits for a Windows Godot run.',
    'TurretBuild.peekAmmo() (Turret.java:693-695, `return ammo.size == 0 ? null : ammo.peek().type();`) -- CLOSED by N2329: the N2313 deferred entry ("peekAmmo() stays deferred for its own slice (T6), which targetPosition() (Turret.java:454) also needs alongside hasAmmo()") is now this slice; targetPosition() still waits for its own slice (remote N2266 dedup decision pending).',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    peek_ammo_inputs = {
        'frame': a('Dictionary', 'public @Nullable BulletType peekAmmo(){', 'The turret frame (TurretBuild.peekAmmo, Turret.java:693): the family-convention first arg every Turret pure function takes; it IS the building (`this`) the accessor reads -- peekAmmo() itself does not read frame fields (the ammo list arrives as an explicit param), so the frame is carried only for the family convention.'),
        'ammo_stacks': a('Array', 'public Seq<AmmoEntry> ammo = new Seq<>();', 'The ammo list (`ammo`, Turret.java:282): the TurretBuild field (`public Seq<AmmoEntry> ammo = new Seq<>();`, Turret.java:282) -- NOT re-ported here (AmmoEntry/Seq are not ported); it arrives as an explicit param (the N2313 hasAmmo precedent) as an Array of {amount, item, type} dicts (the peek_ammo_stack_state convention -- Seq.peek() is the last entry). The "type" value on each dict carries the `AmmoEntry.type()` result (`public abstract BulletType type();`, Turret.java:260): for ItemEntry it resolves through the block ammoTypes map (`return ammoTypes.get(item);`, ItemTurret.java:236-238) and the map itself is NOT ported, so the BulletType name arrives as explicit data.'),
    }
    peek_ammo_outputs = {
        'peek_ammo': a('String', 'return ammo.size == 0 ? null : ammo.peek().type();', 'The peeked ammo type name (Turret.java:694, `return ammo.size == 0 ? null : ammo.peek().type();`): the BulletType name carried on the peeked (last) entry\'s "type" value, or null when the ammo list is empty or the peeked entry carries no type. peekAmmo() never checks amounts and never swaps (unlike hasAmmo() N2313), and never mutates the input list.'),
    }
    return (peek_ammo_inputs, peek_ammo_outputs)


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
    peek_ammo = definitions()

    entries = [
        ('N2329', PEEK_AMMO_OWNER, 'source_turret_peek_ammo_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.peekAmmo()', peek_ammo[0], peek_ammo[1], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.peekAmmo() state from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.peekAmmo() state from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: peek_ammo.
    by_slice['N2329'] = [
        'source_turret_peek_ammo_state_result.peek_ammo',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2329', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.peekAmmo()', godot_owner=PEEK_AMMO_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2329'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
