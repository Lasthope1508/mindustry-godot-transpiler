"""Register the BuildingComp configured() dispatch effect (N2268).

BuildingComp.configured() (BuildingComp.java:1414-1432) is what
the super.control() config case calls (BuildingComp.java:2161,
`configured(null, p1);`, via the :2159 guard pinned by N2267).
The type is resolved first:
`//null is of type void.class; anonymous classes use their superclass.`
`Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();`
(:1415-1416), then the instanceof overrides pin the four
content kinds:
`if(value instanceof Item) type = Item.class;`
`if(value instanceof Block) type = Block.class;`
`if(value instanceof Liquid) type = Liquid.class;`
`if(value instanceof UnitType) type = UnitType.class;`
(:1418-1421). A player builder stamps last access:
`if(builder != null && builder.isPlayer()){`
`updateLastAccess(builder.getPlayer());`
`}` (:1423-1425), where updateLastAccess is
`public void updateLastAccess(Player player){`
`lastAccessed = player.coloredName();`
`}` (:1437-1439) and the field is `transient String lastAccessed;`
(:70). isPlayer is `public boolean isPlayer(){`
`return controller instanceof Player;` `}` (UnitComp.java:949-950).
Then the dispatch:
`if(block.configurations.containsKey(type)){`
`block.configurations.get(type).get(this, value);`
`}else if(value instanceof Building build){`
`//copy config of another building`
`var conf = build.config();`
`if(conf != null && !(conf instanceof Building)){`
`configured(builder, conf);`
`}`
`}` (:1427-1435) -- a registered handler runs for the resolved
type, otherwise a Building value copies the other building's
config recursively (at most one level: the guard rejects a
Building conf, so the recursive call can never take the copy
branch again). The configurations map is
`public ObjectMap<Class<?>, Cons2> configurations = new ObjectMap<>();`
(Block.java:402), filled by `public <T, E extends Building> void config(Class<T> type, Cons2<E, T> config){`
`configurations.put(type, config);` (:926-929) and by
`public <E extends Building> void configClear(Cons<E> cons){`
`configurations.put(void.class, (tile, value) -> cons.get((E)tile));`
(:921-924, the void.class handler for a null value). `config()`
itself is `public Object config(){` `return null;`
(BuildingComp.java:2024-2027) by default. Duo registers no
configuration at all (no `config(` in ItemTurret.java, Turret.java,
ReloadTurret.java or BaseTurret.java), so its configurations map
is empty: no handler ever applies and config() returns null, so
the copy branch never recurses either -- configured() is a noop
for duo.

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_configured_dispatch_state(value_kind,
value_is_anonymous, superclass_kind, has_handler,
building_config_kind, builder_is_player), returning
`{"resolved_type": .., "handler_applied": .., "config_copied": .., "last_access_updated": ..}` -- resolved_type is void for
a null value, the instanceof class for the four content kinds,
the superclass for an anonymous value, else the value's own
kind; handler_applied is whether block.configurations holds
the resolved type; config_copied is true only when no handler
applies, the value is a Building, and the other building's
config is non-null and not itself a Building; last_access_updated
is whether the builder is a player. (2) No driver tick:
configured() is event-driven (called from control()) and no
logic executor exists in the driver yet -- the N2248 precedent,
N2264/N2266/N2267 -- so the proof calls the pure function
directly. (3) The handler body itself is not modeled: the
handler is a block-registered Cons2 closure (Block.config),
and duo has no handler to run. SSOT expected after GREEN:
symbols +4, Done +1, contracts +1, schema +2, 11630/1717/1651/3093
-> 11634/1718/1652/3095; comp shard slices 556 -> 557,
contracts 460 -> 461.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_super_control import DEFERRED as N2267_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
UNIT_COMP = 'core/src/mindustry/entities/comp/UnitComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
PROOF = '/root/C07TurretConfiguredDispatchProof'
CONFIGURED_DISPATCH_OWNER = 'SourceTurretBuildState.source_turret_configured_dispatch_state'
TESTS = ['test_c07_turret_configured_dispatch_registration', 'test_all_c07_turret_configured_dispatch_input_evidence_is_exact', 'test_turret_configured_dispatch_state', 'test_reference_graph_and_actual_c07_turret_configured_dispatch']
# The slice sources the N2268 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/entities/comp/UnitComp.java',
    'core/src/mindustry/world/Block.java',
]
EXACT_EXPRS = ['public void configured(@Nullable Unit builder, @Nullable Object value){', '//null is of type void.class; anonymous classes use their superclass.', 'Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();', 'if(value instanceof Item) type = Item.class;', 'if(value instanceof Block) type = Block.class;', 'if(value instanceof Liquid) type = Liquid.class;', 'if(value instanceof UnitType) type = UnitType.class;', 'if(builder != null && builder.isPlayer()){', 'updateLastAccess(builder.getPlayer());', 'public void updateLastAccess(Player player){', 'lastAccessed = player.coloredName();', 'transient String lastAccessed;', 'public boolean isPlayer(){', 'return controller instanceof Player;', 'if(block.configurations.containsKey(type)){', 'block.configurations.get(type).get(this, value);', '}else if(value instanceof Building build){', '//copy config of another building', 'var conf = build.config();', 'if(conf != null && !(conf instanceof Building)){', 'configured(builder, conf);', 'public Object config(){', 'public ObjectMap<Class<?>, Cons2> configurations = new ObjectMap<>();', 'public <T, E extends Building> void config(Class<T> type, Cons2<E, T> config){', 'configurations.put(type, config);', 'configurations.put(void.class, (tile, value) -> cons.get((E)tile));']

# DEFERRED is carried from the N2267 register script via import --
# never retyped. The configured() dispatch effect is done by
# this slice (it was the next item named in the N2267 handoff);
# the calculateHeat live proximity scan, the efficiency fold for
# defs other than duo, the maxHealth/health re-sync, the set(tile)
# world position, the cross-tick queuedBullets counter,
# effects/sound, findTarget / the other ItemTurret defs still
# wait.
DEFERRED = list(N2267_DEFERRED) + [
    'Turret configured() dispatch Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2267: the N2268 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BuildingComp configured() dispatch effect (BuildingComp.java:1414-1432) -- DONE by this slice (N2268); it was the next item named in the N2267 handoff.',
    'Turret configured() handler bodies -- the handler is a block-registered Cons2 closure (Block.config, Block.java:926-929); the dispatch only reports that it runs. Duo has no handler, so no body exists to model for duo.',
]


def definitions():
    def a(typ, expr, rule, source=BUILDING_COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    configured_dispatch_inputs = {
        'value_kind': a('String', 'Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();', 'The runtime class kind of the configured value (BuildingComp.java:1416 -- null resolves to void.class, an anonymous value to its superclass, else its own class; the instanceof overrides at :1418-1421 then pin Item/Block/Liquid/UnitType).'),
        'value_is_anonymous': a('bool', 'value.getClass().isAnonymousClass()', 'Whether the value is an anonymous class (BuildingComp.java:1416 -- an anonymous value resolves to its superclass, unless an instanceof override at :1418-1421 pins it to a content kind).'),
        'superclass_kind': a('String', 'value.getClass().getSuperclass()', 'The superclass kind of an anonymous value (BuildingComp.java:1416 -- the resolved type when the value is anonymous and no instanceof override applies).'),
        'has_handler': a('bool', 'if(block.configurations.containsKey(type)){', 'Whether block.configurations holds a handler for the resolved type (BuildingComp.java:1427 -- the dispatch branch; the map is Block.java:402, filled by config( :926-929) and configClear( :921-924).', source=BUILDING_COMP),
        'building_config_kind': a('String', 'var conf = build.config();', 'The kind of the other building config when the value is a Building (BuildingComp.java:1431 -- conf from build.config(), which defaults to null at :2024-2027; "null" when there is none, "Building" when it is itself a Building).'),
        'builder_is_player': a('bool', 'if(builder != null && builder.isPlayer()){', 'Whether the configuring builder is a player unit (BuildingComp.java:1423 -- isPlayer is UnitComp.java:949-950, controller instanceof Player; a player builder stamps last access via updateLastAccess :1437-1439).'),
    }
    configured_dispatch_outputs = {
        'resolved_type': a('String', 'Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();', 'The resolved handler key (BuildingComp.java:1416-1421 -- "void" for a null value, the instanceof class for Item/Block/Liquid/UnitType, the superclass for an anonymous value, else the value kind itself).'),
        'handler_applied': a('bool', 'block.configurations.get(type).get(this, value);', 'Whether the registered handler ran for the resolved type (BuildingComp.java:1428 -- true only when block.configurations contains the resolved type).'),
        'config_copied': a('bool', 'configured(builder, conf);', 'Whether the Building copy branch recursed (BuildingComp.java:1429-1434 -- true only when no handler applies, the value is a Building, and the other building config is non-null and not itself a Building; at most one level, the guard rejects a Building conf).'),
        'last_access_updated': a('bool', 'lastAccessed = player.coloredName();', 'Whether last access was stamped (BuildingComp.java:1438 -- true only for a player builder, via updateLastAccess :1437-1439).'),
    }
    return configured_dispatch_inputs, configured_dispatch_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
        upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
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
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
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
    configured_dispatch_inputs, configured_dispatch_outputs = definitions()

    entries = [
        ('N2268', CONFIGURED_DISPATCH_OWNER, 'source_turret_configured_dispatch_state', BUILDING_COMP, 'mindustry.entities.comp.BuildingComp', 'BuildingComp.configured()', configured_dispatch_inputs, configured_dispatch_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BuildingComp configured() dispatch effect from BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BuildingComp configured() dispatch effect from BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: resolved_type, handler_applied, config_copied, last_access_updated.
    by_slice['N2268'] = [
        'source_turret_configured_dispatch_state_result.resolved_type',
        'source_turret_configured_dispatch_state_result.handler_applied',
        'source_turret_configured_dispatch_state_result.config_copied',
        'source_turret_configured_dispatch_state_result.last_access_updated',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2268', dict(status='done', java_source=BUILDING_COMP, java_class='mindustry.entities.comp.BuildingComp', java_method='BuildingComp.configured()', godot_owner=CONFIGURED_DISPATCH_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2268'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
