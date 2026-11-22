"""Register the Drill updateTile() effect legs slice (N2420).

DrillBuild.updateTile() (Drill.java:287-327, `public void
updateTile(){`) -- this slice is ONLY the 3 effect lines:
`if(Mathf.chanceDelta(updateEffectChance * warmup))`
(:307), `updateEffect.at(x + Mathf.range(size * 2f), y +
Mathf.range(size * 2f));` (:308), and `if(wasVisible &&
Mathf.chanceDelta(drillEffectChance * warmup))
drillEffect.at(x + Mathf.range(drillEffectRnd), y +
Mathf.range(drillEffectRnd), dominantItem.color);`
(:323).

NOT this slice: the items/efficiency gate
`if(items.total() < itemCapacity && dominantItems > 0 &&
efficiency > 0){` (N693), `progress %= delay` (N696),
`offload(dominantItem)` (N2022), `float delay =
getDrillTime(dominantItem);` (N693/N2022), `warmup =
Mathf.approachDelta(...)` (N692/N703). The 3
distinguishing exprs are 0-hit in both the local and the
remote ledger (re-probed at base 9cd7239f, remote
origin/main eafdfdb4). One pure function on
SourceDrillRuntimePortBridge.gd (the Drill file,
non-static func -- the PortGame-era style of this file).
The owner is PortGame.* (the N691/N692/N693/N696/N697/
N701/N703 precedent for the other updateTile legs in
this file).

Mathf.chanceDelta(d) is `rand.nextFloat() < d *
Time.delta` (arc Mathf.java:236-238), so each chance roll
arrives as an explicit float param in [0, 1) and is
compared against chance * warmup * source_delta here.
Mathf.range(r) is `random(-range, range)`
(Mathf.java:220-222), and random(start, end) is `start +
rand.nextFloat() * (end - start)` (Mathf.java:285-287),
so each range call arrives as an explicit float roll in
[0, 1) and maps to (2 * roll - 1) * amount here.
updateEffect.at / drillEffect.at arrive as explicit
Callables (the N2398 precedent), guarded with
is_valid(). `size`, `x`, `y`, `wasVisible`,
`drillEffectRnd` and `dominantItem.color` arrive as
explicit params. `drillEffectRnd` arrives already
resolved (Drill.java:96 `if(drillEffectRnd < 0)
drillEffectRnd = size;` is NOT this slice). Drill field
defaults: updateEffectChance 0.02f / drillEffectChance
0.02f (Drill.java:57, :63). Nine new result symbols:
update_effect, update_effect_x, update_effect_y,
update_effect_called, drill_effect, drill_effect_x,
drill_effect_y, drill_effect_color, drill_effect_called.
Slice sources: Drill.java + Mathf.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_item_turret_efficiency import DEFERRED as N2419_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
MATHF = 'arc-core/src/arc/math/Mathf.java'
PROOF = '/root/C07DrillUpdateTileEffectsProof'
EFFECTS_OWNER = 'PortGame.source_drill_update_tile_effects_state'
TESTS = ['test_c07_drill_update_tile_effects_registration', 'test_all_c07_drill_update_tile_effects_input_evidence_is_exact', 'test_drill_update_tile_effects_state', 'test_reference_graph_and_actual_c07_drill_update_tile_effects']
# The 2 slice sources the N2420 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/Drill.java',
    'arc-core/src/arc/math/Mathf.java',
]
EXACT_EXPRS = [
    'if(Mathf.chanceDelta(updateEffectChance * warmup))',
    'updateEffect.at(x + Mathf.range(size * 2f), y + Mathf.range(size * 2f));',
    'if(wasVisible && Mathf.chanceDelta(drillEffectChance * warmup)) drillEffect.at(x + Mathf.range(drillEffectRnd), y + Mathf.range(drillEffectRnd), dominantItem.color);',
]
CHANCE_GUARD = 'if(Mathf.chanceDelta(updateEffectChance * warmup))'
UPDATE_AT = 'updateEffect.at(x + Mathf.range(size * 2f), y + Mathf.range(size * 2f));'
DRILL_AT = 'if(wasVisible && Mathf.chanceDelta(drillEffectChance * warmup)) drillEffect.at(x + Mathf.range(drillEffectRnd), y + Mathf.range(drillEffectRnd), dominantItem.color);'
CHANCE_DELTA = 'return rand.nextFloat() < d * Time.delta;'
RANGE_CALL = 'return random(-range, range);'

# DEFERRED is carried from the N2419 register script via import --
# never retyped. This slice resolves NONE of the carried entries
# (the updateTile effect legs are not the ItemTurret
# efficiency leg, the items/efficiency gate (N693),
# `progress %= delay` (N696), `offload(dominantItem)`
# (N2022), or the warmup approach (N692/N703)), so all are
# carried verbatim. One entry is added: N2420's Windows
# proof debt.
DEFERRED = list(N2419_DEFERRED) + [
    'Drill updateTile() effect legs Windows Godot proof -- debt in GOAL.md section 5, same as N2419: the N2420 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    effects_inputs = {
        'update_effect_chance': a('float', CHANCE_GUARD, 'The update effect chance (Drill.java:307, `if(Mathf.chanceDelta(updateEffectChance * warmup))`): the Drill field (`public float updateEffectChance = 0.02f;`, Drill.java:63) -- the chanceDelta threshold factor, passed explicitly because the roll comparison happens in the pure function.'),
        'warmup': a('float', CHANCE_GUARD, 'The drill warmup before this tick (Drill.java:307, `if(Mathf.chanceDelta(updateEffectChance * warmup))`): the DrillBuild warmup (approached by N692/N703, NOT re-ported here) -- scales both chanceDelta thresholds, passed explicitly.'),
        'update_effect_roll': a('float', CHANCE_DELTA, 'The update effect chance roll (Mathf.java:236-238, `return rand.nextFloat() < d * Time.delta;` inside `Mathf.chanceDelta`): a uniform float in [0, 1) standing in for `rand.nextFloat()` -- the update effect fires exactly when this roll is below updateEffectChance * warmup * source_delta.', source=MATHF),
        'source_delta': a('float', CHANCE_DELTA, 'Time.delta (Mathf.java:237, `return rand.nextFloat() < d * Time.delta;` inside `Mathf.chanceDelta`): the frame delta chanceDelta scales the chance by -- passed explicitly as source_delta (the file-wide convention), NOT read from the engine.', source=MATHF),
        'size': a('float', UPDATE_AT, 'The block size (Drill.java:308, `updateEffect.at(x + Mathf.range(size * 2f), y + Mathf.range(size * 2f));`): the Block.size in tiles -- the Mathf.range amount for the update effect offsets is size * 2f, passed explicitly.'),
        'x': a('float', UPDATE_AT, 'The build x position (Drill.java:308, `updateEffect.at(x + Mathf.range(size * 2f), y + Mathf.range(size * 2f));`): the Building x in world units -- the base the range offsets add to, passed explicitly.'),
        'y': a('float', UPDATE_AT, 'The build y position (Drill.java:308, `updateEffect.at(x + Mathf.range(size * 2f), y + Mathf.range(size * 2f));`): the Building y in world units -- the base the range offsets add to, passed explicitly.'),
        'was_visible': a('bool', DRILL_AT, 'Whether the build was visible (Drill.java:323, `if(wasVisible && Mathf.chanceDelta(drillEffectChance * warmup)) drillEffect.at(...`): the BuildingComp wasVisible flag -- the drill effect fires only when it is true, passed explicitly.'),
        'drill_effect_chance': a('float', DRILL_AT, 'The drill effect chance (Drill.java:323, `if(wasVisible && Mathf.chanceDelta(drillEffectChance * warmup)) drillEffect.at(...`): the Drill field (`public float drillEffectChance = 0.02f;`, Drill.java:57) -- the chanceDelta threshold factor for the drill effect, passed explicitly.'),
        'drill_effect_roll': a('float', CHANCE_DELTA, 'The drill effect chance roll (Mathf.java:236-238, `return rand.nextFloat() < d * Time.delta;` inside `Mathf.chanceDelta`): a uniform float in [0, 1) standing in for `rand.nextFloat()` -- the drill effect fires exactly when wasVisible and this roll is below drillEffectChance * warmup * source_delta.', source=MATHF),
        'drill_effect_rnd': a('float', DRILL_AT, 'The drill effect random radius (Drill.java:323, `... drillEffect.at(x + Mathf.range(drillEffectRnd), y + Mathf.range(drillEffectRnd), dominantItem.color);`): the Drill field (`public float drillEffectRnd = -1f;`, Drill.java:55) -- arrives already resolved (Drill.java:96 `if(drillEffectRnd < 0) drillEffectRnd = size;` is NOT this slice), passed explicitly.'),
        'dominant_item_color': a('Variant', DRILL_AT, 'The dominant item color (Drill.java:323, `... drillEffect.at(x + Mathf.range(drillEffectRnd), y + Mathf.range(drillEffectRnd), dominantItem.color);`): `dominantItem.color` -- the third drillEffect.at argument, passed explicitly as a Variant (a GDScript Color in the proof).'),
        'update_effect_range_roll_x': a('float', RANGE_CALL, 'The update effect x range roll (Mathf.java:220-222, `return random(-range, range);` inside `Mathf.range`): a uniform float in [0, 1) standing in for `rand.nextFloat()` in random(start, end) (`start + roll * (end - start)`, Mathf.java:285-287) -- maps to (2 * roll - 1) * size * 2f for the x offset.', source=MATHF),
        'update_effect_range_roll_y': a('float', RANGE_CALL, 'The update effect y range roll (Mathf.java:220-222, `return random(-range, range);` inside `Mathf.range`): a uniform float in [0, 1) -- maps to (2 * roll - 1) * size * 2f for the y offset.', source=MATHF),
        'drill_effect_range_roll_x': a('float', RANGE_CALL, 'The drill effect x range roll (Mathf.java:220-222, `return random(-range, range);` inside `Mathf.range`): a uniform float in [0, 1) -- maps to (2 * roll - 1) * drillEffectRnd for the x offset.', source=MATHF),
        'drill_effect_range_roll_y': a('float', RANGE_CALL, 'The drill effect y range roll (Mathf.java:220-222, `return random(-range, range);` inside `Mathf.range`): a uniform float in [0, 1) -- maps to (2 * roll - 1) * drillEffectRnd for the y offset.', source=MATHF),
        'update_effect_at': a('Callable', UPDATE_AT, 'The updateEffect.at delegate (Drill.java:308, `updateEffect.at(x + Mathf.range(size * 2f), y + Mathf.range(size * 2f));`): the Effect engine API (`updateEffect`, Drill.java:61, `public Effect updateEffect = Fx.pulverizeSmall;`) -- NOT re-ported here: it arrives as an explicit Callable param (the N2398 precedent: guarded with is_valid(), invoked with .call(x, y)); an invalid callable is reported via update_effect_called false.'),
        'drill_effect_at': a('Callable', DRILL_AT, 'The drillEffect.at delegate (Drill.java:323, `... drillEffect.at(x + Mathf.range(drillEffectRnd), y + Mathf.range(drillEffectRnd), dominantItem.color);`): the Effect engine API (`drillEffect`, Drill.java:53, `public Effect drillEffect = Fx.mine;`) -- NOT re-ported here: it arrives as an explicit Callable param (the N2398 precedent: guarded with is_valid(), invoked with .call(x, y, color)); an invalid callable is reported via drill_effect_called false.'),
    }
    effects_outputs = {
        'update_effect': a('bool', CHANCE_GUARD, 'Whether the update effect fires this tick (Drill.java:307, `if(Mathf.chanceDelta(updateEffectChance * warmup))`): true exactly when the update effect roll is below updateEffectChance * warmup * source_delta.'),
        'update_effect_x': a('float', UPDATE_AT, 'The update effect x position (Drill.java:308, `updateEffect.at(x + Mathf.range(size * 2f), y + Mathf.range(size * 2f));`): x + (2 * roll - 1) * size * 2f.'),
        'update_effect_y': a('float', UPDATE_AT, 'The update effect y position (Drill.java:308, `updateEffect.at(x + Mathf.range(size * 2f), y + Mathf.range(size * 2f));`): y + (2 * roll - 1) * size * 2f.'),
        'update_effect_called': a('bool', UPDATE_AT, 'Whether the updateEffect.at delegate was invoked (Drill.java:308, `updateEffect.at(x + Mathf.range(size * 2f), y + Mathf.range(size * 2f));`): true when the update effect fires and the update_effect_at Callable is valid, false otherwise (the N2398 _called precedent).'),
        'drill_effect': a('bool', DRILL_AT, 'Whether the drill effect fires this tick (Drill.java:323, `if(wasVisible && Mathf.chanceDelta(drillEffectChance * warmup)) drillEffect.at(...`): true exactly when wasVisible and the drill effect roll is below drillEffectChance * warmup * source_delta.'),
        'drill_effect_x': a('float', DRILL_AT, 'The drill effect x position (Drill.java:323, `... drillEffect.at(x + Mathf.range(drillEffectRnd), y + Mathf.range(drillEffectRnd), dominantItem.color);`): x + (2 * roll - 1) * drillEffectRnd.'),
        'drill_effect_y': a('float', DRILL_AT, 'The drill effect y position (Drill.java:323, `... drillEffect.at(x + Mathf.range(drillEffectRnd), y + Mathf.range(drillEffectRnd), dominantItem.color);`): y + (2 * roll - 1) * drillEffectRnd.'),
        'drill_effect_color': a('Variant', DRILL_AT, 'The drill effect color (Drill.java:323, `... drillEffect.at(x + Mathf.range(drillEffectRnd), y + Mathf.range(drillEffectRnd), dominantItem.color);`): dominantItem.color, passed through to the drillEffect.at call and the result.'),
        'drill_effect_called': a('bool', DRILL_AT, 'Whether the drillEffect.at delegate was invoked (Drill.java:323, `... drillEffect.at(x + Mathf.range(drillEffectRnd), y + Mathf.range(drillEffectRnd), dominantItem.color);`): true when the drill effect fires and the drill_effect_at Callable is valid, false otherwise (the N2398 _called precedent).'),
    }
    return effects_inputs, effects_outputs


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
    inputs_outputs = [definitions()]
    total = len(EXACT_EXPRS)
    for keys in inputs_outputs:
        for pair in keys:
            total += len(pair)
            for field, meta in pair.items():
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
    effects_inputs, effects_outputs = definitions()

    entries = [
        ('N2420', EFFECTS_OWNER, 'source_drill_update_tile_effects_state', DRILL, 'mindustry.world.blocks.production.Drill.DrillBuild', 'DrillBuild.updateTile()', effects_inputs, effects_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Drill updateTile() effect legs state from Drill.java + Mathf.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Drill updateTile() effect legs state from Drill.java + Mathf.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: update_effect,
    # update_effect_x, update_effect_y,
    # update_effect_called, drill_effect, drill_effect_x,
    # drill_effect_y, drill_effect_color,
    # drill_effect_called.
    by_slice['N2420'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2420', dict(status='done', java_source=DRILL, java_class='mindustry.world.blocks.production.Drill.DrillBuild', java_method='DrillBuild.updateTile()', godot_owner=EFFECTS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2420'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
