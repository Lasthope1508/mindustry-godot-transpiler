"""Register the anonymous ConsumeItemFilter.build() ammo-filter UI in ItemTurret.init() (N2431).

Anonymous ConsumeItemFilter.build(Building build, Table
table) inside ItemTurret.init() (ItemTurret.java:70-80,
`content.items().each(i -> filter.get(i) &&
i.unlockedNow(),` / `item -> image.add(new ReqImage(new
Image(item.uiIcon),` / `() -> build instanceof
ItemTurretBuild it && !it.ammo.isEmpty() &&
((ItemEntry)it.ammo.peek()).item == item)));`) keeps
only items passing the filter and unlockedNow, adding
one ReqImage per kept item whose Boolp is true exactly
when the build is an ItemTurretBuild with non-empty
ammo and the peeked ItemEntry item is this item. One
statement in joined form, registered as its 3 verbatim
lines (the joined single-line form is NOT verbatim in
the Java file -- N2428 opener precedent). The 3 lines
are 0-hit in both the local and the remote ledger
(re-probed at base d73ffef3, remote origin/main
308b9f00). N1463 owns the BASE
ConsumeItemFilter.build() each() call (`content.items
().each(i -> filter.get(i) && i.unlockedNow() &&
!i.hidden, item -> image.add(new ReqImage(
StatValues.stack(item, 1), ...` + `() -> build.items
.has(item))));`) -- a different statement (hidden
filter + StatValues.stack + items.has), NOT this
ItemTurret override (uiIcon image + ItemTurretBuild
peek check). N2396 owns the PayloadAmmoTurret PAT twin
(`image.add(new ReqImage(new Image(content.uiIcon), ()
-> build instanceof PayloadTurretBuild it &&
!it.payloads.isEmpty() && it.currentAmmo() ==
content));`) -- a different expr. N1463 + N1504 own
the neighbouring `:74 MultiReqImage` + `:79
table.add` lines -- neither is re-registered here.
N1177 owns ItemTurret.init() but NOT this build leg;
N2419 owns the efficiency leg in the same method. One
pure function on SourceItemTurretBuildPortBridge.gd
(the ItemTurret file, NOT a new file -- N2416 ctor
precedent). The owner is PortGame.* (this file is a
PortBridge -- N2358/N2384/N2396/N2419 precedent), NOT
the file class name. `((ItemEntry)it.ammo.peek()).item`
is the peeked ItemEntry item (ItemTurret.java:226,
`public class ItemEntry extends AmmoEntry{`),
`it.ammo.isEmpty()` is the non-empty ammo gate, both
arrive as explicit params, no live engine is called.
The result is frame data (one req_images Array); no
Draw is ported. One new result symbol: req_images. One
slice source: ItemTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_item_turret_efficiency import DEFERRED as N2419_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
ITEM_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java'
PROOF = '/root/C07ItemTurretInitAmmoFilterProof'
AMMO_FILTER_OWNER = 'PortGame.source_item_turret_init_ammo_filter_state'
TESTS = ['test_c07_item_turret_init_ammo_filter_registration', 'test_all_c07_item_turret_init_ammo_filter_input_evidence_is_exact', 'test_item_turret_init_ammo_filter_state', 'test_reference_graph_and_actual_c07_item_turret_init_ammo_filter']
# The 1 slice source the N2431 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java',
]
EXACT_EXPRS = [
    'content.items().each(i -> filter.get(i) && i.unlockedNow(),',
    'item -> image.add(new ReqImage(new Image(item.uiIcon),',
    '() -> build instanceof ItemTurretBuild it && !it.ammo.isEmpty() && ((ItemEntry)it.ammo.peek()).item == item)));',
]

# DEFERRED is carried from the N2419 register script via import --
# never retyped. Nothing in it closes here: N2431 ports the
# ItemTurret anonymous ConsumeItemFilter.build() ammo-filter UI
# leg, which no N2419 entry lists. One entry is added: the N2431
# Windows Godot proof debt (GOAL.md section 5).
DEFERRED = list(N2419_DEFERRED) + [
    'ItemTurret anonymous ConsumeItemFilter.build() ammo-filter UI N2431 Windows Godot proof -- debt in GOAL.md section 5, same as N2419: the N2431 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=ITEM_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    ammo_filter_inputs = {
        'items': a('Array', 'content.items().each(i -> filter.get(i) && i.unlockedNow(),', 'The content item list (ItemTurret.java:76, `content.items().each(i -> filter.get(i) && i.unlockedNow(),`): one Dictionary per item {"item", "ui_icon", "filter_pass", "unlocked_now"} -- filter_pass is the `filter.get(i)` call-site and unlocked_now is `i.unlockedNow()`, both passed as explicit bools.'),
        'is_item_turret_build': a('bool', '() -> build instanceof ItemTurretBuild it && !it.ammo.isEmpty() && ((ItemEntry)it.ammo.peek()).item == item)));', 'Whether the build is an ItemTurretBuild (ItemTurret.java:78, `() -> build instanceof ItemTurretBuild it && !it.ammo.isEmpty() && ((ItemEntry)it.ammo.peek()).item == item)));`): the `build instanceof ItemTurretBuild it` pattern guard, passed as an explicit bool param.'),
        'ammo_empty': a('bool', '() -> build instanceof ItemTurretBuild it && !it.ammo.isEmpty() && ((ItemEntry)it.ammo.peek()).item == item)));', 'Whether the ammo seq is empty (ItemTurret.java:78, `() -> build instanceof ItemTurretBuild it && !it.ammo.isEmpty() && ((ItemEntry)it.ammo.peek()).item == item)));`): `!it.ammo.isEmpty()` -- the non-empty ammo gate, passed as an explicit bool param; the peeked item is only meaningful when this is false.'),
        'peek_item': a('Variant', '() -> build instanceof ItemTurretBuild it && !it.ammo.isEmpty() && ((ItemEntry)it.ammo.peek()).item == item)));', 'The peeked ItemEntry item (ItemTurret.java:78, `() -> build instanceof ItemTurretBuild it && !it.ammo.isEmpty() && ((ItemEntry)it.ammo.peek()).item == item)));`): `((ItemEntry)it.ammo.peek()).item` -- the ItemEntry item (ItemTurret.java:226, `public class ItemEntry extends AmmoEntry{`), passed as an explicit Variant param.'),
    }
    ammo_filter_outputs = {
        'req_images': a('Array', 'item -> image.add(new ReqImage(new Image(item.uiIcon),', 'The ReqImage descriptors (ItemTurret.java:77, `item -> image.add(new ReqImage(new Image(item.uiIcon),`): one {"ui_icon", "valid"} per kept item, in content.items() order -- valid exactly when the build is an ItemTurretBuild with non-empty ammo and the peeked item is this item.'),
    }
    return ammo_filter_inputs, ammo_filter_outputs


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
    ammo_filter_inputs, ammo_filter_outputs = definitions()

    entries = [
        ('N2431', AMMO_FILTER_OWNER, 'source_item_turret_init_ammo_filter_state', ITEM_TURRET, 'mindustry.world.blocks.defense.turrets.ItemTurret', 'ItemTurret.init() ConsumeItemFilter.build(Building build, Table table)', ammo_filter_inputs, ammo_filter_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ItemTurret anonymous ConsumeItemFilter.build() ammo-filter UI state from ItemTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ItemTurret anonymous ConsumeItemFilter.build() ammo-filter UI state from ItemTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the req_images only.
    by_slice['N2431'] = [
        'source_item_turret_init_ammo_filter_state_result.req_images',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2431', dict(status='done', java_source=ITEM_TURRET, java_class='mindustry.world.blocks.defense.turrets.ItemTurret', java_method='ItemTurret.init() ConsumeItemFilter.build(Building build, Table table)', godot_owner=AMMO_FILTER_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2431'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
