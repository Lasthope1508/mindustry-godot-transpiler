"""Register the BeamDrill one-liners + shouldConsume slice (N2417).

BeamDrill.outputsItems() (BeamDrill.java:98-100, `public
boolean outputsItems(){` / `return true;`) -- unconditional
true, overriding the base Block.outputsItems()
(Block.java:601-603, `return hasItems;`).

BeamDrill.rotatedOutput(int, int) (BeamDrill.java:103-105,
`public boolean rotatedOutput(int x, int y){` / `return
false;`) -- unconditional false, overriding the base
Block.rotatedOutput(int, int) (Block.java:615-617, `return
rotate;`).

BeamDrill.icons() (BeamDrill.java:108-110, `public
TextureRegion[] icons(){` / `return new
TextureRegion[]{region, topRegion};`) -- the two-element
return array, region first; the twin of BurstDrill.icons()
(N2312), which registers the same return line for
BurstDrill -- each class owns its own icons().

BeamDrillBuild.shouldConsume() (BeamDrill.java:269-272,
`public boolean shouldConsume(){` / `return items.total()
< itemCapacity && facingAmount > 0 && enabled;`) -- the
three-way gate: item-store room (`items.total()`, the
ItemModule total, under `itemCapacity`, Block.java:75,
`public int itemCapacity = 10;`, large-plasma-bore 20,
Blocks.java:3062), at least one facing tile drilled
(`facingAmount`, BeamDrill.java:228, `public int
facingAmount;`), and the build enabled (`enabled`,
BuildingComp.java:77, `transient boolean enabled = true;`).
The return line is evidence-only in N2155 (the
power-status row); N2417 is the first GD func of its own.
items.total() / facingAmount / enabled / itemCapacity
arrive as explicit params -- no live engine call (the
N2398 updateTile precedent).

NOT this slice: BeamDrill.getDrillTime()
(BeamDrill.java:216-218) -- body byte-identical with
BurstDrill.getDrillTime, already owned at N2344; the GD
already calls it through a Callable, so it is not
re-ported. NOT this slice: the shouldConsume tick wiring
-- the tick driver still runs should_consume=true when
enabled; N2417 ports only the pure predicate.

Four new result symbols: outputs_items, rotated_output,
icons, should_consume. Slice sources: BeamDrill.java +
Block.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_beam_drill_default_constructor import DEFERRED as N2401_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BEAM_DRILL = 'core/src/mindustry/world/blocks/production/BeamDrill.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07BeamDrillOutputsItemsRotatedOutputIconsShouldConsumeProof'
OUTPUTS_ITEMS_OWNER = 'SourceBeamDrillBuildState.source_beam_drill_outputs_items_state'
ROTATED_OUTPUT_OWNER = 'SourceBeamDrillBuildState.source_beam_drill_rotated_output_state'
ICONS_OWNER = 'SourceBeamDrillBuildState.source_beam_drill_icons_state'
SHOULD_CONSUME_OWNER = 'SourceBeamDrillBuildState.source_beam_drill_should_consume_state'
TESTS = ['test_c07_beam_drill_outputs_items_rotated_output_icons_should_consume_registration', 'test_all_c07_beam_drill_outputs_items_rotated_output_icons_should_consume_input_evidence_is_exact', 'test_beam_drill_outputs_items_rotated_output_icons_should_consume_state', 'test_reference_graph_and_actual_c07_beam_drill_outputs_items_rotated_output_icons_should_consume']
# The 2 slice sources the N2417 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/BeamDrill.java',
    'core/src/mindustry/world/Block.java',
]
EXACT_EXPRS = [
    'public boolean outputsItems(){',
    'return true;',
    'public boolean rotatedOutput(int x, int y){',
    'return false;',
    'public TextureRegion[] icons(){',
    'return new TextureRegion[]{region, topRegion};',
    'public @Load("@-top") TextureRegion topRegion;',
    'public TextureRegion region;',
    'public boolean shouldConsume(){',
    'return items.total() < itemCapacity && facingAmount > 0 && enabled;',
    'public class BeamDrill extends Block{',
    'public class BeamDrillBuild extends Building{',
]

# DEFERRED is carried from the N2401 register script via import --
# never retyped. One carried entry is DROPPED here, not carried:
# the BeamDrill shouldConsume gate entry -- N2417 IS the
# shouldConsume slice (the pure predicate), so carrying it would
# leave a stale "waits for its own slice" row for done work; what
# remains is only the tick wiring, carried as its own new entry.
# One entry is added: N2417's Windows proof debt.
DEFERRED = [e for e in N2401_DEFERRED if 'BeamDrill shouldConsume gate' not in e] + [
    'BeamDrill shouldConsume tick wiring -- the N2417 pure predicate exists (source_beam_drill_should_consume_state); the tick driver still runs should_consume=true when enabled and waits for a wiring slice to call it.',
    'BeamDrill outputsItems() + rotatedOutput() + icons() + shouldConsume() Windows Godot proof -- debt in GOAL.md section 5, same as N2401: the N2417 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BEAM_DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    outputs_items_inputs = {
        'frame': a('Dictionary', 'public boolean outputsItems(){', 'The beam-drill frame (BeamDrill.outputsItems, BeamDrill.java:98): the family-convention first arg (every BeamDrill pure function takes it); the override takes no state, so the frame is unused (the N2318 canPickup accessor precedent).'),
    }
    outputs_items_outputs = {
        'outputs_items': a('bool', 'return true;', 'Whether the beam drill outputs items: outputsItems() (BeamDrill.java:98-100), `return true;` -- always true, whatever the frame holds; the override flips the base Block.outputsItems() (Block.java:601-603, `return hasItems;`).'),
    }
    rotated_output_inputs = {
        'frame': a('Dictionary', 'public boolean rotatedOutput(int x, int y){', 'The beam-drill frame (BeamDrill.rotatedOutput, BeamDrill.java:103): the family-convention first arg; the override takes no state, so the frame is unused (the N2318 accessor precedent).'),
        'x': a('int', 'public boolean rotatedOutput(int x, int y){', 'The tile x asked about (BeamDrill.java:103, `rotatedOutput(int x, int y)`): an explicit param, unused by the override -- the override is unconditional (the N2318 accessor precedent).'),
        'y': a('int', 'public boolean rotatedOutput(int x, int y){', 'The tile y asked about (BeamDrill.java:103, `rotatedOutput(int x, int y)`): an explicit param, unused by the override -- the override is unconditional (the N2318 accessor precedent).'),
    }
    rotated_output_outputs = {
        'rotated_output': a('bool', 'return false;', 'Whether the beam drill has a rotated output at (x, y): rotatedOutput() (BeamDrill.java:103-105), `return false;` -- always false, whatever tile is asked about; the override flips the base Block.rotatedOutput(int, int) (Block.java:615-617, `return rotate;`).'),
    }
    icons_inputs = {
        'region': a('Variant', 'public TextureRegion region;', 'The inherited block region (Block.java:427, `public TextureRegion region;`); passed explicitly because it is per-def static state, not a live frame key (the N2212 acquire / N2220 draw-place per-def-param precedent).', source=BLOCK),
        'top_region': a('Variant', 'public @Load("@-top") TextureRegion topRegion;', 'The BeamDrill top region (BeamDrill.java:36, `public @Load("@-top") TextureRegion topRegion;`, loaded as name + "-top"); passed explicitly because it is per-def static state, not a live frame key (the N2312 BurstDrill.icons twin precedent).'),
    }
    icons_outputs = {
        'icons': a('Array', 'return new TextureRegion[]{region, topRegion};', 'The icons() return array: [region, topRegion], region first, exactly 2 elements (BeamDrill.java:109, `return new TextureRegion[]{region, topRegion};`); plasma-bore ["plasma-bore", "plasma-bore-top"] (Blocks.java:3038) and large-plasma-bore ["large-plasma-bore", "large-plasma-bore-top"] (Blocks.java:3052). The Block.icons() base (Block.java:976-980, variants/teamRegion fold) and the getGeneratedIcons cache (Block.java:986-988) are deferred (the N2312 precedent) -- only the override return array is pinned.'),
    }
    should_consume_inputs = {
        'items_total': a('int', 'return items.total() < itemCapacity && facingAmount > 0 && enabled;', 'The current item count (BeamDrill.java:271, `items.total()` inside the shouldConsume gate): the ItemModule total; the gate needs room under itemCapacity (the N2398 updateTile capacity-gate precedent).'),
        'item_capacity': a('int', 'return items.total() < itemCapacity && facingAmount > 0 && enabled;', 'The block item capacity (BeamDrill.java:271, `itemCapacity` inside the shouldConsume gate): the ItemModule cap (Block.java:75, `public int itemCapacity = 10;`, large-plasma-bore overrides it to 20, Blocks.java:3062).'),
        'facing_amount': a('int', 'return items.total() < itemCapacity && facingAmount > 0 && enabled;', 'The facing tile count (BeamDrill.java:271, `facingAmount` inside the shouldConsume gate): the BeamDrillBuild field (`public int facingAmount;`, BeamDrill.java:228), set by updateFacing (N2379); the gate needs at least one facing tile drilled.'),
        'enabled': a('bool', 'transient boolean enabled = true;', 'Whether the build is enabled (BeamDrill.java:271, `enabled` inside the shouldConsume gate): the Building field (`transient boolean enabled = true;`, BuildingComp.java:77) -- the gate needs the build enabled.', source=BUILDING_COMP),
    }
    should_consume_outputs = {
        'should_consume': a('bool', 'return items.total() < itemCapacity && facingAmount > 0 && enabled;', 'Whether the beam drill should consume: shouldConsume() (BeamDrill.java:269-272), `return items.total() < itemCapacity && facingAmount > 0 && enabled;` -- the three-way conjunction: item-store room, at least one facing tile, and enabled. The return line is evidence-only in N2155 (the power-status row); N2417 is the first GD func of its own.'),
    }
    return {
        'outputs_items': (outputs_items_inputs, outputs_items_outputs),
        'rotated_output': (rotated_output_inputs, rotated_output_outputs),
        'icons': (icons_inputs, icons_outputs),
        'should_consume': (should_consume_inputs, should_consume_outputs),
    }


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
    for pair in inputs_outputs.values():
        for keys in pair:
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
    defs = definitions()

    entries = [
        ('N2417', OUTPUTS_ITEMS_OWNER, 'source_beam_drill_outputs_items_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill', 'BeamDrill.outputsItems()', defs['outputs_items'][0], defs['outputs_items'][1], True, 'Dictionary'),
        ('N2417', ROTATED_OUTPUT_OWNER, 'source_beam_drill_rotated_output_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill', 'BeamDrill.rotatedOutput(int, int)', defs['rotated_output'][0], defs['rotated_output'][1], True, 'Dictionary'),
        ('N2417', ICONS_OWNER, 'source_beam_drill_icons_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill', 'BeamDrill.icons()', defs['icons'][0], defs['icons'][1], True, 'Dictionary'),
        ('N2417', SHOULD_CONSUME_OWNER, 'source_beam_drill_should_consume_state', BEAM_DRILL, 'mindustry.world.blocks.production.BeamDrill.BeamDrillBuild', 'BeamDrillBuild.shouldConsume()', defs['should_consume'][0], defs['should_consume'][1], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BeamDrill %s state from BeamDrill.java + Block.java.' % method))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BeamDrill %s state from BeamDrill.java + Block.java.' % method))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: outputs_items,
    # rotated_output, icons, should_consume.
    by_slice['N2417'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2417', dict(status='done', java_source=BEAM_DRILL, java_class='mindustry.world.blocks.production.BeamDrill.BeamDrillBuild', java_method='BeamDrill.outputsItems()/BeamDrill.rotatedOutput(int, int)/BeamDrill.icons()/BeamDrillBuild.shouldConsume()', godot_owner=OUTPUTS_ITEMS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2417'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
