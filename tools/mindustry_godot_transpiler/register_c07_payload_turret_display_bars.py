"""Register the PayloadTurret displayBars()+updateTile()+getPayloads() group (N2381).

PayloadTurretBuild.displayBars()+updateTile()+getPayloads()
(PayloadAmmoTurret.java:143-145/:165-168/:171-177,
`public PayloadSeq getPayloads(){` / `return payloads;` /
`public void updateTile(){` / `totalAmmo = payloads.total();` /
`super.updateTile();` / `public void displayBars(Table bars){` /
`super.displayBars(bars);` /
`bars.add(new Bar("stat.ammo", Pal.ammo, () -> (float)totalAmmo / maxAmmo)).growX();` /
`bars.row();`)
is one grouped pure-function slice on the existing
SourcePayloadAmmoTurretBuildPortBridge.gd (created by N2358
for currentAmmo), following the grouped multi-function
precedent (N2330, `Drill.canPlaceOn(Tile tile, Team team,
int rotation)/Drill.setBars()/Drill.drawPlanConfig(BuildPlan
plan, Eachable<BuildPlan> list)` -- one slice record, one
owner per function, several java_method entries joined by
"/") and the grouped version/write/read precedent (N2375).

RED decisions (resolved at RED): (1) The functions live
in the existing PortBridge file: there is no
SourcePayloadAmmoTurretBuildState.gd to delegate to.
The SSOT owners are PortGame (not the bridge filename):
PortBridge files are discovered by the catalog validator
as port_game.* (source_symbols._discover_godot_owner_functions
forces class_name "port_game" for *PortBridge.gd), the same
as every other PortBridge contract (e.g. N1181
PortGame.source_item_turret_build_get_ammo_fraction_state,
N2355 PortGame.source_continuous_turret_build_get_ammo_fraction_state,
N2358 PortGame.source_payload_ammo_turret_build_current_ammo_state,
N2363 PortGame.source_payload_ammo_turret_build_use_ammo_state,
N2368 PortGame.source_payload_ammo_turret_build_get_ammo_content_state,
N2371 PortGame.source_payload_turret_build_peek_ammo_state,
N2376 PortGame.source_payload_ammo_turret_build_write_read_state).
Registering the bridge filename as owner breaks
implementation_linkage validation (gate batch 9: 9 failures)
-- fixed here, owner PortGame. The slice record owner is
the displayBars owner
(PortGame.source_payload_ammo_turret_build_display_bars_state);
updateTile and getPayloads each carry their own owner and
contract, exactly like N2330's three owners -- one contract
per owner, because contracts are keyed by owner and a
single contract could not carry the three functions'
return keys (the N2378 lesson: contract name == function
name).
(2) getPayloads and updateTile stand alone are each one
distinguishing line (`return payloads;` /
`totalAmmo = payloads.total();`), so they group with
displayBars (two distinguishing lines) into one slice of
five distinguishing exprs, same file, same `payloads` /
`totalAmmo` fields -- the N2330 grouping precedent, main
thread approved as batch 18 slot 3.
(3) `payloads` (PayloadSeq, PayloadAmmoTurret.java:95)
arrives as the explicit payload_contents param (one entry
per payload unit, the N2330 param precedent);
`PayloadSeq.total()` is the running sum of added amounts
(PayloadSeq.java:22-24, `public int total(){` /
`return total;` `}`), so updateTile's
`totalAmmo = payloads.total();` is exactly
payload_contents.size(). `bars` (arc Table,
PayloadAmmoTurret.java:171) arrives as the explicit bars
param: an Array of rows, each row an Array of bar-spec
dicts -- Table is row-based, so `bars.add(...)` appends
the ammo bar spec to the current (last) row and
`bars.row();` opens a new empty row after it.
`totalAmmo` (TurretBuild frame field, Turret.java:283,
`public int totalAmmo;`) and `maxAmmo` (Turret.java:47,
`public int maxAmmo = 30;`) arrive as explicit int params.
`Pal.ammo` / Table / Bar are NOT ported: the bar spec
carries label + fraction only, no Pal.ammo color (task
pins this for this slice, unlike N2330's setBars spec
which carries the Pal.ammo color literal).
(4) `super.updateTile();` / `super.displayBars(bars);`
are callee/context -- NOT distinguishing exprs.
`super.updateTile();` is already owned by N1222/N1417/
N2103/N2108/N2110/N2153/N2362. The distinguishing lines
are `return payloads;`, `totalAmmo = payloads.total();`,
`bars.add(new Bar("stat.ammo", Pal.ammo, () -> (float)totalAmmo / maxAmmo)).growX();`
and `bars.row();` (all 0-hit in both ledgers at HEAD
4f53d70e, re-probed at the new base).
(5) Content refs are plain strings (content names);
the displayBars result carries exactly two keys, the
updateTile and getPayloads results exactly one key each.
NO driver line: updateTile only syncs the frame field,
displayBars is a UI spec, getPayloads is a pure accessor
-- the caller wiring waits for its own slice.
(6) Evidence, not ownership: `@Override` also appears
at PayloadAmmoTurret.java:144/:166/:172 and on every
other override in the file. Four new result symbols:
bars, ammo_fraction, total_ammo, payloads. Slice sources:
PayloadAmmoTurret.java + Turret.java (maxAmmo field only).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_payload_turret_write_read import DEFERRED as N2376_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
PAYLOAD_AMMO_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07PayloadTurretDisplayBarsProof'
DISPLAY_BARS_OWNER = 'PortGame.source_payload_ammo_turret_build_display_bars_state'
UPDATE_TILE_OWNER = 'PortGame.source_payload_ammo_turret_build_update_tile_state'
GET_PAYLOADS_OWNER = 'PortGame.source_payload_ammo_turret_build_get_payloads_state'
TESTS = ['test_c07_payload_turret_display_bars_registration', 'test_all_c07_payload_turret_display_bars_input_evidence_is_exact', 'test_payload_turret_display_bars_update_tile_get_payloads_state', 'test_reference_graph_and_actual_c07_payload_turret_display_bars']
# The 2 slice sources the N2381 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files. The maxAmmo field lives in Turret.java
# but is NOT an exact_expr (only an input java_expr, checked
# against its own java_source by verify()).
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
]
EXACT_EXPRS = [
    'public class PayloadAmmoTurret extends Turret{',
    'public class PayloadTurretBuild extends TurretBuild{',
    'public PayloadSeq payloads = new PayloadSeq();',
    '@Override',
    'public PayloadSeq getPayloads(){',
    'return payloads;',
    'public void updateTile(){',
    'totalAmmo = payloads.total();',
    'super.updateTile();',
    'public void displayBars(Table bars){',
    'super.displayBars(bars);',
    'bars.add(new Bar("stat.ammo", Pal.ammo, () -> (float)totalAmmo / maxAmmo)).growX();',
    'bars.row();',
]

# DEFERRED is carried from the N2376 register script via import --
# never retyped. This slice closes none of the carried entries;
# it only adds its own Windows-proof debt entry.
DEFERRED = list(N2376_DEFERRED) + [
    'PayloadTurret displayBars/updateTile/getPayloads Windows Godot proof -- debt in GOAL.md section 5, same as N2353: the N2381 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=PAYLOAD_AMMO_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    display_bars_inputs = {
        'bars': a('Array', 'bars.add(new Bar("stat.ammo", Pal.ammo, () -> (float)totalAmmo / maxAmmo)).growX();', 'The table\'s current rows (PayloadAmmoTurret.java:174, `bars.add(new Bar("stat.ammo", Pal.ammo, () -> (float)totalAmmo / maxAmmo)).growX();`): an Array of rows, each row an Array of bar-spec dicts -- Table is row-based, so `bars.add(...)` appends to the current (last) row and `bars.row();` (PayloadAmmoTurret.java:175) opens a new empty row after it; Table itself is NOT ported, its rows arrive as an explicit param (the N2330 param precedent).'),
        'total_ammo': a('int', '() -> (float)totalAmmo / maxAmmo', 'The frame totalAmmo field (PayloadAmmoTurret.java:174, `() -> (float)totalAmmo / maxAmmo`): the Bar fraction lambda reads it -- the TurretBuild field (`public int totalAmmo;`, Turret.java:283) synced by updateTile() (`totalAmmo = payloads.total();`, PayloadAmmoTurret.java:166); arrives as an explicit int param.'),
        'max_ammo': a('int', 'public int maxAmmo = 30;', 'The TurretBuild maxAmmo field (Turret.java:47, `public int maxAmmo = 30;`): the Bar fraction lambda divides by it (`() -> (float)totalAmmo / maxAmmo`, PayloadAmmoTurret.java:174); arrives as an explicit int param.', source=TURRET),
    }
    display_bars_outputs = {
        'bars': a('Array', 'bars.add(new Bar("stat.ammo", Pal.ammo, () -> (float)totalAmmo / maxAmmo)).growX();', 'The updated table rows (PayloadAmmoTurret.java:174, `bars.add(new Bar("stat.ammo", Pal.ammo, () -> (float)totalAmmo / maxAmmo)).growX();`): the input rows with the ammo bar spec `{"label": "stat.ammo", "fraction": (float)totalAmmo / maxAmmo}` appended to the current (last) row, plus a new empty row opened by `bars.row();` (PayloadAmmoTurret.java:175) -- a fresh deep copy, the input is never mutated.'),
        'ammo_fraction': a('float', '() -> (float)totalAmmo / maxAmmo', 'The ammo bar fraction (PayloadAmmoTurret.java:174, `() -> (float)totalAmmo / maxAmmo`): float(totalAmmo) / float(maxAmmo); maxAmmo 0 never divides by zero -- the guard reports 0.0 (a Bar clamps its fraction anyway, Bar.java:31-33).'),
    }
    update_tile_inputs = {
        'payload_contents': a('Array', 'totalAmmo = payloads.total();', 'The contents currently held in the payloads seq (PayloadAmmoTurret.java:166, `totalAmmo = payloads.total();`): the `public PayloadSeq payloads = new PayloadSeq();` field (PayloadAmmoTurret.java:95) reduced to its contents, one entry per payload unit -- the payloads.total() call itself is NOT ported, its contents arrive as an explicit param (the N2330 param precedent).'),
    }
    update_tile_outputs = {
        'total_ammo': a('int', 'totalAmmo = payloads.total();', 'The synced frame totalAmmo (PayloadAmmoTurret.java:166, `totalAmmo = payloads.total();`): `PayloadSeq.total()` is the running sum of added amounts (PayloadSeq.java:22-24), so with one entry per payload unit it is exactly payload_contents.size().'),
    }
    get_payloads_inputs = {
        'payload_contents': a('Array', 'return payloads;', 'The contents currently held in the payloads seq (PayloadAmmoTurret.java:144, `return payloads;`): the `public PayloadSeq payloads = new PayloadSeq();` field (PayloadAmmoTurret.java:95) reduced to its contents -- the payloads seq itself is NOT ported, its contents arrive as an explicit param (the N2330 param precedent).'),
    }
    get_payloads_outputs = {
        'payloads': a('Array', 'return payloads;', 'The held payload contents (PayloadAmmoTurret.java:144, `return payloads;`): a copy of the payload_contents input, in order -- the caller\'s seq is never aliased.'),
    }
    return (display_bars_inputs, display_bars_outputs), (update_tile_inputs, update_tile_outputs), (get_payloads_inputs, get_payloads_outputs)


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
    inputs_outputs = list(definitions())
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
    (display_bars_inputs, display_bars_outputs), (update_tile_inputs, update_tile_outputs), (get_payloads_inputs, get_payloads_outputs) = definitions()

    entries = [
        ('N2381', DISPLAY_BARS_OWNER, 'source_payload_ammo_turret_build_display_bars_state', PAYLOAD_AMMO_TURRET, 'mindustry.world.blocks.defense.turrets.PayloadAmmoTurret.PayloadTurretBuild', 'PayloadTurretBuild.displayBars(Table)', display_bars_inputs, display_bars_outputs, True, 'Dictionary'),
        ('N2381', UPDATE_TILE_OWNER, 'source_payload_ammo_turret_build_update_tile_state', PAYLOAD_AMMO_TURRET, 'mindustry.world.blocks.defense.turrets.PayloadAmmoTurret.PayloadTurretBuild', 'PayloadTurretBuild.updateTile()', update_tile_inputs, update_tile_outputs, True, 'Dictionary'),
        ('N2381', GET_PAYLOADS_OWNER, 'source_payload_ammo_turret_build_get_payloads_state', PAYLOAD_AMMO_TURRET, 'mindustry.world.blocks.defense.turrets.PayloadAmmoTurret.PayloadTurretBuild', 'PayloadTurretBuild.getPayloads()', get_payloads_inputs, get_payloads_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PayloadTurretBuild.displayBars()+updateTile()+getPayloads() state from PayloadAmmoTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PayloadTurretBuild.displayBars()+updateTile()+getPayloads() state from PayloadAmmoTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: bars, ammo_fraction,
    # total_ammo, payloads.
    by_slice['N2381'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2381', dict(status='done', java_source=PAYLOAD_AMMO_TURRET, java_class='mindustry.world.blocks.defense.turrets.PayloadAmmoTurret.PayloadTurretBuild', java_method='PayloadTurretBuild.displayBars(Table); PayloadTurretBuild.updateTile(); PayloadTurretBuild.getPayloads()', godot_owner=DISPLAY_BARS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2381'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
