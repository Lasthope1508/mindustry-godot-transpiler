"""Register the LaunchPad updateTile advance (N2207).

The LaunchPad's updateTile counter advance, following the N2204
ShieldWall updateTile precedent and the N2205/N2206 pure-function
precedent. LaunchPadBuild.updateTile advances the launch counter
by edelta() every tick then launches when full: `if((launchCounter
+= edelta()) >= launchTime && items.total() >= itemCapacity){`
(LaunchPad.java:146), and on launch Java consumes, sounds, spawns
the LaunchPayload entity, clears the items and resets the counter
(LaunchPad.java:148-160, `launchCounter = 0f;`). edelta() is
efficiency * delta (BuildingComp.java:1927-1929, `public float
edelta(){` with `return efficiency * delta();`, and delta() is
`Time.delta * timeScale`, BuildingComp.java:1922-1923), so a pad
with no power never advances -- its efficiency is 0. N2207 closes
the advance half of that gap with one pure function
(source_launch_pad_update_tile_state) over the frame
(`launch_counter`, `efficiency`, `items_total`) plus the per-def
launchTime and itemCapacity parameters: the function takes (frame,
delta, launch_time, item_capacity) and returns the new
`launch_counter` plus a `launched` flag, and the driver stamps
both on the frame every tick, after the consumption block
(updateConsumption runs BEFORE updateTile in Java). The launch
side effects -- consume() (LaunchPad.java:148), the launch sound
(LaunchPad.java:149), the LaunchPayload entity spawn
(LaunchPad.java:150-155), Fx.launchPod (LaunchPad.java:156),
items.clear() (LaunchPad.java:157) and Effect.shake
(LaunchPad.java:158) -- are a new subsystem with no frame state
to run on, so they wait for their own slice; the `launched` flag
is the observable signal that slice will consume. RED decisions
(pinned by this slice): (1) the advance reads `efficiency` from
the frame, absent -> 0.0 -- the transient field default
(BuildingComp.java:85, `transient float efficiency;`), the
N2192/N2204 precedent -- so the shouldConsume gate needs no
separate parameter: a false gate zeroes efficiency via
updateConsumption (BuildingComp.java:1960 + 1992-1993) and
edelta() goes to 0. (2) An absent `launch_counter` key starts at
0.0 -- the Java init default (`public float launchCounter;`
defaults to 0.0f), the N2206 decision -- and an absent
`items_total` key reads 0.0, because a fresh ItemModule totals 0
(`protected int total;`, ItemModule.java:25, with `public int
total(){` / `return total;`, ItemModule.java:174-175), so a pad
with no tracked items never launches until an inventory slice
stamps `items_total`. (3) NO clamp at launchTime: the counter
keeps growing past launchTime while the pad waits for items (the
N2192 no-clamp precedent -- Java only resets the counter on
launch, LaunchPad.java:160, `launchCounter = 0f;`), so a full
counter with too few items stays full. (4) The per-def launchTime
differs (launch-pad 1200f = 60f * 20, Blocks.java:6794;
advanced-launch-pad 1800f = 60f * 30, Blocks.java:6804; class
default 1f, LaunchPad.java:32) and itemCapacity is 100 for both
defs (Blocks.java:6793, 6803; class default 10, Block.java:75,
`public int itemCapacity = 10;`), and the catalog carries
itemCapacity (content_registry blocks launch-pad /
advanced-launch-pad properties), so the driver reads it from
block.properties and passes it in, like launchTime. Two defs
share the implementation (launch-pad, size 3, itemCapacity 100,
launchTime 60f * 20; advanced-launch-pad, size 4, itemCapacity
100, launchTime 60f * 30, liquidCapacity 40f, Blocks.java:6790-6809).
Do NOT confuse the launch gate with the shouldConsume gate
(`return launchCounter < launchTime;`, LaunchPad.java:92-94): the
gate zeroes efficiency through updateConsumption, while updateTile
itself advances by whatever edelta() the folded efficiency yields.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_launch_pad_sense_progress import DEFERRED as _N2206_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LAUNCH_PAD = 'core/src/mindustry/world/blocks/campaign/LaunchPad.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
ITEM_MODULE = 'core/src/mindustry/world/modules/ItemModule.java'
PROOF = '/root/C07LaunchPadUpdateTileProof'
OWNER = 'SourceLaunchPadBuildState.source_launch_pad_update_tile_state'
TESTS = ['test_c07_launch_pad_update_tile_registration', 'test_all_c07_launch_pad_update_tile_input_evidence_is_exact', 'test_launch_pad_update_tile_state', 'test_reference_graph_and_actual_c07_launch_pad_update_tile']
# The 5 slice sources the N2207 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files, and no expr may name a file outside them.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/world/modules/ItemModule.java',
]
EXACT_EXPRS = ['public void updateTile(){', 'if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){', 'launchCounter = 0f;', 'public float launchCounter;', 'public float launchTime = 1f;', 'public class LaunchPad extends Block{', 'public class LaunchPadBuild extends Building{', 'public float edelta(){', 'return efficiency * delta();', 'public float delta(){', 'return Time.delta * timeScale;', 'transient float efficiency;', 'potentialEfficiency = efficiency = optionalEfficiency = 0f;', 'public int itemCapacity = 10;', 'itemCapacity = 100;', 'launchTime = 60f * 20;', 'launchTime = 60f * 30;', 'protected int total;', 'public int total(){', 'return total;', 'consume();', 'items.clear();', 'LaunchPayload entity = LaunchPayload.create();', 'Fx.launchPod.at(this);', 'Effect.shake(3f, 3f, this);', 'launchSound.at(x, y, 1f + Mathf.range(launchSoundPitchRand));', 'size = 3;', 'size = 4;', 'public boolean shouldConsume(){', 'return launchCounter < launchTime;']

# DEFERRED is carried from the N2206 register script via import --
# never retyped. The N2206 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2205 import), NOT a plain
# list literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2207's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval. The
# updateTile advance itself is NOT carried as deferred: it is THIS
# slice (N2207) -- the inherited N2205/N2206 entries still name it
# as waiting, which is stale history, superseded by this slice.
DEFERRED = list(_N2206_DEFERRED) + [
    'LaunchPad updateTile launch effects (consume / launchSound / LaunchPayload entity spawn / Fx.launchPod / items.clear / Effect.shake, LaunchPad.java:148-158) -- the entity spawn is a new subsystem and the port tracks no items module for a launch pad yet; N2207 stamps the `launched` flag the launch slice will consume.',
    'LaunchPad updateTile Windows Godot proof -- debt in GOAL.md section 5, same as N2175-N2206: the N2207 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def f(typ, expr, rule, source=LAUNCH_PAD, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2207_inputs = {
        'frame': f('Dictionary', 'public float launchCounter;', 'The building frame carrying the launch_counter observation (LaunchPad.java:84, `public float launchCounter;`, stamped live by the driver every tick), the folded efficiency and the held items_total; a missing launch_counter key starts at 0.0 -- the Java init default -- and a missing items_total key reads 0.0, because a fresh ItemModule totals 0 (ItemModule.java:25 + 174-175).'),
        'delta': f('float', 'public float edelta(){', 'The tick delta the counter advances by, scaled by the frame efficiency (edelta() is efficiency * delta, BuildingComp.java:1927-1929; delta() is `Time.delta * timeScale`, BuildingComp.java:1922-1923); the driver passes its tick seconds, the N2190 driver convention.', source=BUILDING_COMP),
        'launch_time': f('float', 'public float launchTime = 1f;', 'The per-def launchTime the advanced counter runs against (LaunchPad.java:32, the class default 1f): launch-pad 1200f (Blocks.java:6794, `launchTime = 60f * 20;`) and advanced-launch-pad 1800f (Blocks.java:6804, `launchTime = 60f * 30;`); the driver selects it by block id from SOURCE_LAUNCH_PAD_LAUNCH_TIMES and passes it in.'),
        'item_capacity': f('float', 'public int itemCapacity = 10;', 'The per-def itemCapacity the held items run against (Block.java:75, the class default 10): 100 for both defs (Blocks.java:6793, 6803, `itemCapacity = 100;`); the driver reads it from block.properties -- the catalog carries it -- and passes it in.', source=BLOCK),
    }
    n2207_outputs = {
        'launch_counter': f('float', 'if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){', 'The advanced launch counter (LaunchPad.java:143-146): the old counter plus efficiency * delta, reset to 0.0 on the launch tick, unclamped past launchTime while the pad waits for items (Java only resets on launch, LaunchPad.java:160, `launchCounter = 0f;`).'),
        'launched': f('bool', 'launchCounter = 0f;', 'Whether this tick launched (LaunchPad.java:146 + 160): true exactly when the advanced counter reaches launchTime AND the held items reach itemCapacity, the tick the counter resets to 0.0; the launch side effects (consume / sound / LaunchPayload spawn / Fx / items.clear / shake, LaunchPad.java:148-158) wait for their own slice, and this flag is the signal that slice will consume.'),
    }
    return n2207_inputs, n2207_outputs


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
    inputs, outputs = definitions()
    for keys in (inputs, outputs):
        for field, meta in keys.items():
            source = meta['java_source']
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
            if meta['java_expr'] not in text:
                missing.append('%s: %s' % (field, meta['java_expr']))
    total = len(EXACT_EXPRS) + len(inputs) + len(outputs)
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    symbols = {}
    n2207_inputs, n2207_outputs = definitions()

    entries = [
        ('N2207', OWNER, 'source_launch_pad_update_tile_state', LAUNCH_PAD, 'mindustry.world.blocks.campaign.LaunchPad.LaunchPadBuild', 'LaunchPadBuild.updateTile()', n2207_inputs, n2207_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed LaunchPad updateTile advance from LaunchPad.java / BuildingComp.java / Block.java / ItemModule.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed LaunchPad updateTile advance from LaunchPad.java / BuildingComp.java / Block.java / ItemModule.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the advanced counter, then the launch flag.
    by_slice['N2207'] = [
        'source_launch_pad_update_tile_state_result.launch_counter',
        'source_launch_pad_update_tile_state_result.launched',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2207', dict(status='done', java_source=LAUNCH_PAD, java_class='mindustry.world.blocks.campaign.LaunchPad.LaunchPadBuild', java_method='LaunchPadBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2207'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
