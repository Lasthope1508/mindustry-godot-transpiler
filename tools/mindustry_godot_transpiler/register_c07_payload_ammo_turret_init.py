"""Register the PayloadAmmoTurret.init() inner ConsumePayloadFilter (N2396).

PayloadAmmoTurret.init() (PayloadAmmoTurret.java:59-93,
`public void init(){` / `consume(new
ConsumePayloadFilter(i -> ammoTypes.containsKey(i)){` /
`for(var block : content.blocks())
displayContent(build, image, block);` / `for(var unit :
content.units()) displayContent(build, image, unit);` /
`if(filter.get(content) && content.unlockedNow()){` /
`return build instanceof PayloadTurretBuild it &&
it.payloads.any() ? 1f : 0f;`) registers one
ConsumePayloadFilter whose build() lists every ammo
content (blocks then units) that passes the filter and
is unlocked, whose displayContent() gates each entry on
`filter.get(content) && content.unlockedNow()` and adds
a ReqImage with the per-entry visibility `build
instanceof PayloadTurretBuild it && !it.payloads.isEmpty()
&& it.currentAmmo() == content`, and whose efficiency()
is 1f exactly when the build is a PayloadTurretBuild
with any payload. One pure function on the PortBridge
file, following the N2358 currentAmmo / N2387 intake
precedent: the SSOT owner is PortGame (not the bridge
filename) -- PortBridge files are discovered by the
catalog validator as port_game.* (the N2355 fix). The
content blocks/units arrive as explicit Array params,
filter/unlockedNow/uiIcon as explicit Callables --
Table/MultiReqImage/ReqImage/Stats are NOT ported; the
result is frame data (the displayed list in
blocks-then-units order plus the efficiency value).

RED decisions (resolved at RED): (1) The function lives
directly in the PortBridge file: there is no
SourcePayloadAmmoTurretBuildState.gd to delegate to.
The SSOT owner is PortGame (the N2355/N2358 precedent).
(2) The filter predicate `i ->
ammoTypes.containsKey(i)` is NOT re-implemented from
ammoTypes: it arrives as the explicit filter Callable
param (the caller binds it from ammoTypes) -- the
consume() line itself is registered as the registration
expr. (3) payloads.any() and !payloads.isEmpty() are
the same fact (PayloadSeq.java:14-20, any() is total >
0, isEmpty() is total == 0), so one payloads_any bool
param stands for both the efficiency gate and the
ReqImage visibility lambda. (4) currentAmmo() (N2358)
arrives as the explicit current_ammo param, NOT
re-ported. (5) display() is a no-op comment
(`//don't display`, PayloadAmmoTurret.java:86) -- it
owns NO expr, only a note in the proof. (6) `ammoKeys =
ammoTypes.keys().toSeq().toArray(UnlockableContent.class);`
is already owned (N2358/N2363/N2368/N2371) and
`table.add(image).size(8 * 4);` is already owned
(N1463/N1504) -- neither is re-registered. (7) NO
driver line: init() registers the consumer once, it is
not a per-tick write. (8) An invalid filter or
unlocked_now callable closes that gate (the entry is
excluded); an invalid ui_icon callable yields an empty
icon string. Two new result symbols:
display_contents, efficiency. Slice source:
PayloadAmmoTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_payload_turret_payload_intake import DEFERRED as N2387_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
PAYLOAD_AMMO_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java'
PROOF = '/root/C07PayloadAmmoTurretInitProof'
INIT_OWNER = 'PortGame.source_payload_ammo_turret_init_state'
TESTS = ['test_c07_payload_ammo_turret_init_registration', 'test_all_c07_payload_ammo_turret_init_input_evidence_is_exact', 'test_payload_ammo_turret_init_state', 'test_reference_graph_and_actual_c07_payload_ammo_turret_init']
# The 1 slice source the N2396 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
]
EXACT_EXPRS = [
    'consume(new ConsumePayloadFilter(i -> ammoTypes.containsKey(i)){',
    'for(var block : content.blocks()) displayContent(build, image, block);',
    'for(var unit : content.units()) displayContent(build, image, unit);',
    'if(filter.get(content) && content.unlockedNow()){',
    'return build instanceof PayloadTurretBuild it && it.payloads.any() ? 1f : 0f;',
    'image.add(new ReqImage(new Image(content.uiIcon), () -> build instanceof PayloadTurretBuild it && !it.payloads.isEmpty() && it.currentAmmo() == content));',
    'void displayContent(Building build, MultiReqImage image, UnlockableContent content){',
    'public class PayloadAmmoTurret extends Turret{',
    'public class PayloadTurretBuild extends TurretBuild{',
    'public PayloadSeq payloads = new PayloadSeq();',
]

# DEFERRED is carried from the N2387 register script via import --
# never retyped. No deferred entry mentions init(), so this slice
# closes none; it only adds its own Windows-proof debt entry.
DEFERRED = list(N2387_DEFERRED) + [
    'PayloadAmmoTurret init() Windows Godot proof -- debt in GOAL.md section 5, same as N2353: the N2396 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=PAYLOAD_AMMO_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    init_inputs = {
        'content_blocks': a('Array', 'for(var block : content.blocks()) displayContent(build, image, block);', 'The content blocks walked by build() (PayloadAmmoTurret.java:65, `for(var block : content.blocks()) displayContent(build, image, block);`): content.blocks() arrives as an explicit Array param (the N2330 param precedent); blocks are listed before units.'),
        'content_units': a('Array', 'for(var unit : content.units()) displayContent(build, image, unit);', 'The content units walked by build() (PayloadAmmoTurret.java:66, `for(var unit : content.units()) displayContent(build, image, unit);`): content.units() arrives as an explicit Array param (the N2330 param precedent); units are listed after blocks.'),
        'filter': a('Callable', 'if(filter.get(content) && content.unlockedNow()){', 'The ConsumePayloadFilter predicate (PayloadAmmoTurret.java:72, `if(filter.get(content) && content.unlockedNow()){`): the `public Boolf<UnlockableContent> filter;` field (ConsumePayloadFilter.java) bound at construction to `i -> ammoTypes.containsKey(i)` (PayloadAmmoTurret.java:60) -- it arrives as an explicit Callable param, invoked with .call(content); an invalid callable closes the gate.'),
        'unlocked_now': a('Callable', 'if(filter.get(content) && content.unlockedNow()){', 'The per-content unlocked check (PayloadAmmoTurret.java:72, `if(filter.get(content) && content.unlockedNow()){`): `content.unlockedNow()` (UnlockableContent.java:273) arrives as an explicit Callable param, invoked with .call(content); an invalid callable closes the gate.'),
        'ui_icon': a('Callable', 'image.add(new ReqImage(new Image(content.uiIcon), () -> build instanceof PayloadTurretBuild it && !it.payloads.isEmpty() && it.currentAmmo() == content));', 'The per-content icon lookup (PayloadAmmoTurret.java:73, `image.add(new ReqImage(new Image(content.uiIcon), ...));`): `content.uiIcon` (UnlockableContent.java:46, `public TextureRegion uiIcon;`) arrives as an explicit Callable param, invoked with .call(content); an invalid callable yields an empty icon string.'),
        'is_payload_turret_build': a('bool', 'return build instanceof PayloadTurretBuild it && it.payloads.any() ? 1f : 0f;', 'Whether the build is a PayloadTurretBuild (PayloadAmmoTurret.java:81, `return build instanceof PayloadTurretBuild it && it.payloads.any() ? 1f : 0f;`): the `build instanceof PayloadTurretBuild it` pattern guard, passed as an explicit bool param.'),
        'payloads_any': a('bool', 'return build instanceof PayloadTurretBuild it && it.payloads.any() ? 1f : 0f;', 'Whether the payloads seq holds anything (PayloadAmmoTurret.java:81, `return build instanceof PayloadTurretBuild it && it.payloads.any() ? 1f : 0f;`): `it.payloads.any()` -- and the same fact as `!it.payloads.isEmpty()` in the ReqImage visibility lambda (PayloadAmmoTurret.java:73), since PayloadSeq.any() is total > 0 and isEmpty() is total == 0 (PayloadSeq.java:14-20) -- passed as one explicit bool param.'),
        'current_ammo': a('Variant', 'image.add(new ReqImage(new Image(content.uiIcon), () -> build instanceof PayloadTurretBuild it && !it.payloads.isEmpty() && it.currentAmmo() == content));', 'The live current ammo content (PayloadAmmoTurret.java:73, `... && it.currentAmmo() == content));`): currentAmmo() (N2358) arrives as an explicit param, NOT re-ported here; content refs are plain strings (content names), null when no ammo is held.'),
    }
    init_outputs = {
        'display_contents': a('Array', 'image.add(new ReqImage(new Image(content.uiIcon), () -> build instanceof PayloadTurretBuild it && !it.payloads.isEmpty() && it.currentAmmo() == content));', 'The displayed contents (PayloadAmmoTurret.java:73, `image.add(new ReqImage(new Image(content.uiIcon), ...));`): one entry per content passing filter and unlockedNow, in blocks-then-units order, each `{"content": name, "ui_icon": icon, "visible": bool}` -- visible is the ReqImage predicate `build instanceof PayloadTurretBuild it && !it.payloads.isEmpty() && it.currentAmmo() == content`; Table/MultiReqImage/ReqImage are NOT ported, this list is the frame.'),
        'efficiency': a('float', 'return build instanceof PayloadTurretBuild it && it.payloads.any() ? 1f : 0f;', 'The consumer efficiency (PayloadAmmoTurret.java:81, `return build instanceof PayloadTurretBuild it && it.payloads.any() ? 1f : 0f;`): 1.0 exactly when the build is a PayloadTurretBuild with any payload, else 0.0 -- valid when there is any ammo in the turret.'),
    }
    return (init_inputs, init_outputs)


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
    (init_inputs, init_outputs) = definitions()

    entries = [
        ('N2396', INIT_OWNER, 'source_payload_ammo_turret_init_state', PAYLOAD_AMMO_TURRET, 'mindustry.world.blocks.defense.turrets.PayloadAmmoTurret', 'PayloadAmmoTurret.init()', init_inputs, init_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PayloadAmmoTurret.init() state from PayloadAmmoTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PayloadAmmoTurret.init() state from PayloadAmmoTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: display_contents, efficiency.
    by_slice['N2396'] = [
        'source_payload_ammo_turret_init_state_result.display_contents',
        'source_payload_ammo_turret_init_state_result.efficiency',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2396', dict(status='done', java_source=PAYLOAD_AMMO_TURRET, java_class='mindustry.world.blocks.defense.turrets.PayloadAmmoTurret', java_method='PayloadAmmoTurret.init()', godot_owner=INIT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2396'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
