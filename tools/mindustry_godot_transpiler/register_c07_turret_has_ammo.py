"""Register the Turret hasAmmo() predicate (N2313).

One predicate on TurretBuild (Turret.java:277,
`public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`)
in `public class Turret extends ReloadTurret{` (Turret.java:36):

- hasAmmo() (Turret.java:698-713):
  `public boolean hasAmmo(){`
  `//skip first entry if it has less than the required amount of ammo`
  `if(ammo.size >= 2 && ammo.peek().amount < ammoPerShot){`
  `for(int i = 0; i < ammo.size; i ++){`
  `if(ammo.get(i).amount >= ammoPerShot){`
  `ammo.swap(ammo.size - 1, i);`
  `break;`
  `}`
  `}`
  `//used for "side-ammo" like gas in some turrets`
  `if(!canConsume()) return false;`
  `return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());`
  `}`

RED decisions (resolved at RED): (1) One pure function --
`source_turret_has_ammo_state(frame, ammo_stacks, ammo_per_shot, can_consume, cheating)` --
that performs the scan/swap itself and returns BOTH the bool and
the new ammo order (`{"has_ammo": ..., "ammo_stacks_after": ...}`).
The ammo list is an explicit param in/out (the main-thread brief):
it arrives as an Array of {amount, item} dicts (the
peek_ammo_stack_state convention -- Seq.peek() is the LAST entry,
arc Seq.peek() returns items[size - 1]) and the function returns a
deep copy with the swap applied. The input list is NOT mutated.
(2) The swap runs BEFORE the canConsume() gate (Java order: the
scan/swap is the first block, the gate the second), so
`ammo_stacks_after` carries the swap even when `has_ammo` is false
for can_consume. (3) canConsume() (Turret.java:624) and cheating()
are NOT ported here: their results arrive as explicit bool params
(the brief). (4) NO driver tick line: hasAmmo() is a predicate its
callers read, not a per-tick write (the N2249/N2221 precedent) --
estimateDps() (N2301) and targetPosition() (Turret.java:454) read
the result; targetPosition() still waits for peekAmmo() (T6). (5)
peekAmmo() (Turret.java:693-695) is EXPLICITLY OUT OF SCOPE: it is
a separate later slice (it reads the same ammo list, taking the
stacks as a param). Two new result symbols: has_ammo +
ammo_stacks_after. Three slice sources: Turret.java only -- every
expr (body + field declarations + class lines) is in Turret.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_unit import DEFERRED as N2307_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretHasAmmoProof'
HAS_AMMO_OWNER = 'SourceTurretBuildState.source_turret_has_ammo_state'
TESTS = ['test_c07_turret_has_ammo_registration', 'test_all_c07_turret_has_ammo_input_evidence_is_exact', 'test_turret_has_ammo_state', 'test_reference_graph_and_actual_c07_turret_has_ammo']
# The 1 slice source the N2313 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = [
    'public class Turret extends ReloadTurret{',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'public boolean hasAmmo(){',
    '//skip first entry if it has less than the required amount of ammo',
    'if(ammo.size >= 2 && ammo.peek().amount < ammoPerShot){',
    'for(int i = 0; i < ammo.size; i ++){',
    'if(ammo.get(i).amount >= ammoPerShot){',
    'ammo.swap(ammo.size - 1, i);',
    'break;',
    '//used for "side-ammo" like gas in some turrets',
    'if(!canConsume()) return false;',
    'return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());',
    'public Seq<AmmoEntry> ammo = new Seq<>();',
    'public int ammoPerShot = 1;',
]

# DEFERRED is carried from the N2307 register script via import --
# never retyped. Nothing in it closes here: hasAmmo() was not a
# deferred entry of the Turret chain (the peekAmmo() entry that
# targetPosition() also needs stays deferred -- it is the
# Turret.java:693-695 computation, not this predicate). Two entries
# are added: the N2313 Windows Godot proof debt (GOAL.md section 5)
# and the peekAmmo() note.
DEFERRED = N2307_DEFERRED + [
    'Turret hasAmmo() (TurretBuild.hasAmmo, Turret.java:698-713) Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2313 proof runs headless on Linux here and waits for a Windows Godot run.',
    'TurretBuild.peekAmmo() (Turret.java:693-695) -- NOT ported by N2313: hasAmmo() reads ammo amounts directly from the explicit ammo_stacks param (Seq.peek() is the last entry); peekAmmo() stays deferred for its own slice (T6), which targetPosition() (Turret.java:454) also needs alongside hasAmmo().',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    has_ammo_inputs = {
        'frame': a('Dictionary', 'public boolean hasAmmo(){', 'The turret frame (TurretBuild.hasAmmo, Turret.java:698): the family-convention first arg every Turret pure function takes; it IS the building (`this`) the predicate reads -- hasAmmo() itself does not read frame fields (the ammo list, per-shot cost and the two bool gates arrive as explicit params), so the frame is carried only for the family convention.'),
        'ammo_stacks': a('Array', 'public Seq<AmmoEntry> ammo = new Seq<>();', 'The ammo list (`ammo`, Turret.java:282): the TurretBuild field (`public Seq<AmmoEntry> ammo = new Seq<>();`, Turret.java:282) -- NOT re-ported here (AmmoEntry/Seq are not ported); it arrives as an explicit param (the N2311/N2261 precedent) as an Array of {amount, item} dicts (the peek_ammo_stack_state convention -- Seq.peek() is the last entry), and the function returns a deep copy with the swap applied.'),
        'ammo_per_shot': a('int', 'public int ammoPerShot = 1;', 'The per-shot ammo cost (`ammoPerShot`, Turret.java:49): the block field (`public int ammoPerShot = 1;`, Turret.java:49) -- NOT re-ported here (block fields are not ported); it arrives as an explicit param (the N2311/N2261 precedent) as an int.'),
        'can_consume': a('bool', 'if(!canConsume()) return false;', 'The canConsume() result (`canConsume()`, Turret.java:710): TurretBuild.canConsume() (Turret.java:624-628, itself a super call) is NOT ported here -- its result arrives as an explicit param (the brief), and the gate runs AFTER the scan/swap (Java order).'),
        'cheating': a('bool', 'cheating()', 'The cheating() result (`cheating()`, Turret.java:712): the team-cheat flag is NOT ported here -- its result arrives as an explicit param (the brief); a cheating turret counts as having ammo even when the peeked stack is short.'),
    }
    has_ammo_outputs = {
        'has_ammo': a('bool', 'return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());', 'Whether the turret has ammo (Turret.java:712, `return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());`): true when the list is non-empty and the peeked entry (the last entry, Seq.peek()) holds at least ammoPerShot, or when cheating is true; false when the list is empty, when no entry holds enough, or when can_consume is false.'),
        'ammo_stacks_after': a('Array', 'ammo.swap(ammo.size - 1, i);', 'The ammo list after the swap (Turret.java:703, `ammo.swap(ammo.size - 1, i);`): a deep copy of the input list in which the first entry holding at least ammoPerShot has been swapped into the peek (last) position, when the peek was short and at least two entries exist; otherwise a copy in the original order. The swap runs before the canConsume() gate, so it is carried even when has_ammo is false for can_consume.'),
    }
    return (has_ammo_inputs, has_ammo_outputs)


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
    has_ammo = definitions()

    entries = [
        ('N2313', HAS_AMMO_OWNER, 'source_turret_has_ammo_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.hasAmmo()', has_ammo[0], has_ammo[1], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.hasAmmo() state from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.hasAmmo() state from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: has_ammo, ammo_stacks_after.
    by_slice['N2313'] = [
        'source_turret_has_ammo_state_result.has_ammo',
        'source_turret_has_ammo_state_result.ammo_stacks_after',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2313', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.hasAmmo()', godot_owner=HAS_AMMO_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2313'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
