"""Register the Turret controlled() read accessor (N2324).

One read accessor on TurretBuild (Turret.java:277,
`public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`)
in `public class Turret extends ReloadTurret{` (Turret.java:36):

- controlled() (Turret.java:441-443):
  `public boolean controlled(){`
  `return unit.isPlayer();`
  `}`

RED decisions (resolved at RED): (1) One pure function --
`source_turret_controlled_state(frame, is_player)` -- that returns
`{"controlled": is_player}` as-is. (2) unit is the TurretBuild
field (`public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`,
Turret.java:291), synced by unit() (N2307): controlled() reads the
result of unit() (`unit.isPlayer();`, Turret.java:442). isPlayer()
itself (`public boolean isPlayer(){` / `return controller instanceof
Player;`, UnitComp.java:949-951) is NOT re-ported here (Unit/
BlockUnitc are not ported): its result arrives as an explicit bool
param (the N2311/N2261 precedent). (3) NO driver tick line:
controlled() is a read accessor its callers read, not a per-tick
write (the N2249/N2221 precedent) -- validateTarget() reads it
(Turret.java:632) and updateTile's player-control branch reads it
(Turret.java:494); both callers wait for their own slices. (4)
NOT control() (Turret.java:384-394, remote N2264): a different
method -- it sets logicControlTime and the player controller, it
does not read unit.isPlayer(). One new result symbol: controlled.
One slice source: Turret.java only -- every expr (body + field
declaration + class lines) is in Turret.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_has_ammo import DEFERRED as N2313_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretControlledProof'
CONTROLLED_OWNER = 'SourceTurretBuildState.source_turret_controlled_state'
TESTS = ['test_c07_turret_controlled_registration', 'test_all_c07_turret_controlled_input_evidence_is_exact', 'test_turret_controlled_state', 'test_reference_graph_and_actual_c07_turret_controlled']
# The 1 slice source the N2324 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = [
    'public class Turret extends ReloadTurret{',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'public boolean controlled(){',
    'return unit.isPlayer();',
    'public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);',
]

# DEFERRED is carried from the N2313 register script via import --
# never retyped. Two entries are added: the N2324 Windows Godot
# proof debt (GOAL.md section 5) and the note that this slice
# closes the N2297 deferred controlled() entry (the main thread
# decided it becomes its own slice -- this one).
DEFERRED = N2313_DEFERRED + [
    'Turret controlled() (TurretBuild.controlled, Turret.java:441-443) Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2324 proof runs headless on Linux here and waits for a Windows Godot run.',
    'TurretBuild.controlled() (Turret.java:441-443, `return unit.isPlayer();`) -- CLOSED by N2324: the N2297 deferred entry ("the main thread decides separately whether it becomes its own slice") is now this slice.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    controlled_inputs = {
        'frame': a('Dictionary', 'public boolean controlled(){', 'The turret frame (TurretBuild.controlled, Turret.java:441): the family-convention first arg every Turret pure function takes; it IS the building (`this`) the accessor reads -- controlled() itself does not read frame fields (the unit/player result arrives as an explicit param), so the frame is carried only for the family convention.'),
        'is_player': a('bool', 'return unit.isPlayer();', 'Whether the turret unit is player-controlled (`unit.isPlayer()`, Turret.java:442): the unit is the TurretBuild field (`public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`, Turret.java:291), synced by unit() (N2307); isPlayer() itself (`public boolean isPlayer(){` / `return controller instanceof Player;`, UnitComp.java:949-951) is NOT re-ported here -- its result arrives as an explicit param (the N2311/N2261 precedent).'),
    }
    controlled_outputs = {
        'controlled': a('bool', 'return unit.isPlayer();', 'Whether a player controls the turret (Turret.java:442, `return unit.isPlayer();`): true while the turret unit controller is a Player, false otherwise.'),
    }
    return (controlled_inputs, controlled_outputs)


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
    controlled = definitions()

    entries = [
        ('N2324', CONTROLLED_OWNER, 'source_turret_controlled_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.controlled()', controlled[0], controlled[1], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.controlled() state from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.controlled() state from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: controlled.
    by_slice['N2324'] = [
        'source_turret_controlled_state_result.controlled',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2324', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.controlled()', godot_owner=CONTROLLED_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2324'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
