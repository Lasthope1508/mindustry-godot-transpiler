"""Register the Turret unit() accessor (N2307).

One accessor on TurretBuild (Turret.java:277,
`public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`)
in `public class Turret extends ReloadTurret{` (Turret.java:36):

- unit() (Turret.java:434-439):
  `public Unit unit(){`
  `unit.tile(this);`
  `unit.team(team);`
  `return (Unit)unit;`
  `}`

RED decisions (resolved at RED): (1) One pure function --
`source_turret_unit_state(frame, unit, team_id)` -- that
performs the sync itself: it copies the input unit dict,
sets `tile` to the building frame (`this`, the
family-convention frame first arg) and `team_id` to the
building's team id, and returns `{"unit": synced}`. The
unit is NOT passed in already-synced: the sync IS the
function (the main-thread brief). `unit` is the TurretBuild
field (`public BlockUnitc unit =
(BlockUnitc)UnitTypes.block.create(team);`, Turret.java:291),
created once from UnitTypes.block -- NOT re-ported here
(Unit/BlockUnitc are not ported); it arrives as an explicit
param (the N2268/N2261 precedent). `team_id` is the
building's team as an int (the tick-frame convention:
source_turret_tick_frame_state binds frame["team_id"]). (2)
NO driver tick line: unit() is a read accessor its callers
read, not a per-tick write (the N2249/N2221 precedent) --
controlled() reads the result (`unit.isPlayer()`,
Turret.java:442) and the unit is created once at build
time; both callers wait for their own slices. (3) The
stat-derivation INSIDE BlockUnitComp.tile(Building)
(`maxHealth(tile.block.health)`, `health(tile.health)`,
`hitSize(tile.block.size * tilesize * 0.7f)`, `set(tile)`,
BlockUnitComp.java:17-27) is NOT ported here: tile() is a
separate method on a different component (BlockUnitComp,
not TurretBuild) -- its body stays deferred for its own
slice. This slice records only the assignment the call
performs: the unit's tile becomes this building, its team
becomes the building's team. (4) controlled()
(Turret.java:441-443, `return unit.isPlayer();`) is
EXPLICITLY OUT OF SCOPE: it is a separate later slice (it
reads the result of unit(), taking is_player as a param).
(5) BuildTurret.BuildTurretBuild.unit()
(BuildTurret.java) is a DIFFERENT method on a different
class -- its exact_exprs appear in local N2184 only as
evidence (the scope probe verified owner + symbols); it is
NOT re-ported here and NOT in EXACT_EXPRS. One new result
symbol: unit. Three slice sources: Turret.java +
BlockUnitComp.java + TeamComp.java (+ BuildingComp.java
for the imported team field).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_micro_accessors import DEFERRED as N2297_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BLOCK_UNIT_COMP = 'core/src/mindustry/entities/comp/BlockUnitComp.java'
TEAM_COMP = 'core/src/mindustry/entities/comp/TeamComp.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07TurretUnitProof'
UNIT_OWNER = 'SourceTurretBuildState.source_turret_unit_state'
TESTS = ['test_c07_turret_unit_registration', 'test_all_c07_turret_unit_input_evidence_is_exact', 'test_turret_unit_state', 'test_reference_graph_and_actual_c07_turret_unit']
# The 4 slice sources the N2307 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/comp/BlockUnitComp.java',
    'core/src/mindustry/entities/comp/TeamComp.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
]
EXACT_EXPRS = [
    'public class Turret extends ReloadTurret{',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'public Unit unit(){',
    'unit.tile(this);',
    'unit.team(team);',
    'return (Unit)unit;',
    'public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);',
    'public void tile(Building tile){',
    '@ReadOnly transient Building tile;',
    'Team team = Team.derelict;',
    '@Import Team team;',
]

# DEFERRED is carried from the N2297 register script via import --
# never retyped. Nothing in it closes here: unit() was not a
# deferred entry of the Turret chain (the controlled() entry that
# reads the result stays deferred -- it is the Turret.java:441-443
# computation, not this accessor -- and the BlockUnitComp.tile()
# stat-derivation entry is added, not closed). Two entries are
# added: the N2307 Windows Godot proof debt (GOAL.md section 5)
# and the BlockUnitComp.tile() stat-derivation note.
DEFERRED = N2297_DEFERRED + [
    'Turret unit() (TurretBuild.unit, Turret.java:434-439) Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2307 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BlockUnitComp.tile(Building) stat derivation (maxHealth/health/hitSize/set, BlockUnitComp.java:17-27) -- NOT ported by N2307: tile() is a separate method on a different component; N2307 records only the tile/team assignment the unit() call performs. The derivation stays deferred for its own slice.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    unit_inputs = {
        'frame': a('Dictionary', 'public Unit unit(){', 'The turret frame (TurretBuild.unit, Turret.java:434): the family-convention first arg every Turret pure function takes; it IS the building (`this`) the unit is synced to -- the returned unit carries it as its tile.'),
        'unit': a('Dictionary', 'public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);', 'The block unit (`unit`, Turret.java:436-438): the TurretBuild field (`public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`, Turret.java:291, created once from UnitTypes.block) -- NOT re-ported here (Unit/BlockUnitc are not ported); it arrives as an explicit param (the N2268/N2261 precedent) as a state dict, and the function returns a synced copy of it.'),
        'team_id': a('int', '@Import Team team;', 'The building team id (`team`, Turret.java:437): the TurretBuild team (`@Import Team team;`, BuildingComp.java:62), carried as an int (the tick-frame convention: source_turret_tick_frame_state binds frame["team_id"]); the returned unit carries it as its team_id.', source=BUILDING_COMP),
    }
    unit_outputs = {
        'unit': a('Dictionary', 'return (Unit)unit;', 'The synced unit (Turret.java:438, `return (Unit)unit;`): a copy of the input unit dict with `tile` set to the building frame (`unit.tile(this);`, Turret.java:436, resolving to BlockUnitComp.tile(Building), BlockUnitComp.java:17 -- the tile field itself, `@ReadOnly transient Building tile;`, BlockUnitComp.java:14) and `team_id` set to the building team (`unit.team(team);`, Turret.java:437; the unit team field defaults to derelict, `Team team = Team.derelict;`, TeamComp.java:15). The BlockUnitComp.tile() stat derivation (maxHealth/health/hitSize/set) is NOT applied here -- it stays deferred for its own slice.'),
    }
    return (unit_inputs, unit_outputs)


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
    unit = definitions()

    entries = [
        ('N2307', UNIT_OWNER, 'source_turret_unit_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.unit()', unit[0], unit[1], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.unit() state from Turret.java + BlockUnitComp.java + TeamComp.java + BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.unit() state from Turret.java + BlockUnitComp.java + TeamComp.java + BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: unit.
    by_slice['N2307'] = [
        'source_turret_unit_state_result.unit',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2307', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.unit()', godot_owner=UNIT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2307'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
