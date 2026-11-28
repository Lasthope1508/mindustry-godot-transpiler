"""Register SpawnGroup.toString() (N2492).

SpawnGroup.toString() (SpawnGroup.java:159-170) is one slice
(batch C8 slot 2):
    public String toString(){
        return "SpawnGroup{" +
        "type=" + type +
        ", end=" + end +
        ", begin=" + begin +
        ", spacing=" + spacing +
        ", max=" + max +
        ", unitScaling=" + unitScaling +
        ", unitAmount=" + unitAmount +
        ", effect=" + effect +
        ", items=" + items +
        '}';
    }
A mechanical concatenation of exactly the 9 fields type,
end, begin, spacing, max, unitScaling, unitAmount, effect,
items, in Java order. TRAP: shields (:38) and shieldScaling
(:40) are NOT printed -- they appear in equals (N2457) and
hashCode only, so this slice must not add them. Java string
concatenation prints a null reference as "null", an object
via its toString(), and a float via Float.toString:
- type is a UnitType: MappableContent.toString()
  (MappableContent.java:16-18) is `return name;` and UnitType
  has no override, so type prints as its content name -- the
  GD input is the name string itself (the N2457 name model),
  or null.
- effect is a StatusEffect: StatusEffect.toString()
  (StatusEffect.java:244-246) returns localizedName -- the
  GD input is the print string itself (the N2457 name
  model), or null ("Null to disable", :47).
- items is a single @Nullable ItemStack (:50), NOT an
  array: ItemStack.toString() (ItemStack.java:82-84) is
  `return item + ": " + amount;` and Item.toString()
  (Item.java:114-116) returns localizedName, so GD renders
  from the N2457 Dictionary model {"item": <name>,
  "amount": <int>} as `<item>: <amount>`, or "null".
- unitScaling is a float: Float.toString semantics --
  the value is narrowed to float32, rendered with the
  shortest digit string that round-trips the float32,
  in plain notation on [1e-3, 1e7) and scientific
  notation outside it ("2.1474836E9" for the field
  default `never` = (float)Integer.MAX_VALUE, "1.0E-4"
  below 1e-3), with "0.0"/"-0.0" keeping their signs and
  whole floats keeping ".0" (GD str() would print the
  double un-narrowed and lose the float32 rounding).
The SSOT contract return_type only accepts Dictionary or
void, so the string is returned in the one-key
{"to_string": ...} envelope (the N2365 envelope precedent,
also used by the BlockPlan/TeamData toString slices). One
GD function on the existing file
SourceWaveSpawnRuntimeState.gd (home of the 4 earlier
SpawnGroup slices), placed right BEFORE
source_spawn_group_equals_state because toString()
(:159-170) comes before equals(Object) (:181-190) in
SpawnGroup.java. NOT a twin-register: the distinctive
body literals are 0-hit in ledger exact_exprs (main-thread
verified; the generic signature line `public String
toString(){` is shared with other classes' toString
methods, which is a name collision only). One slice
source: SpawnGroup.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SPAWN_GROUP = 'core/src/mindustry/game/SpawnGroup.java'
PROOF = '/root/C07SpawnGroupToStringProof'
TO_STRING_OWNER = 'SourceWaveSpawnRuntimeState.source_spawn_group_to_string_state'
TESTS = ['test_c07_spawn_group_to_string_registration', 'test_all_c07_spawn_group_to_string_input_evidence_is_exact', 'test_spawn_group_to_string_state', 'test_reference_graph_and_actual_c07_spawn_group_to_string']
# The 1 slice source the N2492 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/SpawnGroup.java',
]
FORMULA = '        return "SpawnGroup{" +'
EXACT_EXPRS = [
    '    public String toString(){',
    FORMULA,
    '        "type=" + type +',
    '        ", end=" + end +',
    '        ", begin=" + begin +',
    '        ", spacing=" + spacing +',
    '        ", max=" + max +',
    '        ", unitScaling=" + unitScaling +',
    '        ", unitAmount=" + unitAmount +',
    '        ", effect=" + effect +',
    '        ", items=" + items +',
    "        '}';",
]
JAVA_METHOD = 'SpawnGroup.toString()'

# DEFERRED is defined locally (the N2487 lesson: never
# import a DEFERRED list from another register script --
# the N2416 list had ballooned with other families'
# entries). Exactly 5 entries.
DEFERRED = [
    'SpawnGroup.hashCode() (SpawnGroup.java:193-195, `return Arrays.hashCode(new Object[]{type, end, begin, spacing, max, unitScaling, shields, shieldScaling, unitAmount, effect, items});`) is NOT in this slice: the Arrays.hashCode formula (11 fields, including the shields/shieldScaling that toString does NOT print) belongs to its own slice (backup B of the C8 batch 2).',
    'UnitType/StatusEffect content lookup is NOT ported here: type prints via MappableContent.toString() = the content name (MappableContent.java:16-18, UnitType has no toString override) and effect prints via StatusEffect.toString() = localizedName (StatusEffect.java:244-246) -- both arrive as precomputed print-string inputs (the N2457 name model); the content registry and the bundle localization behind localizedName belong to later slices.',
    'ItemStack rendering is modeled, not re-ported: ItemStack.toString() (ItemStack.java:82-84) is `return item + ": " + amount;` with Item.toString() = localizedName (Item.java:114-116) -- GD renders `<item>: <amount>` from the N2457 Dictionary model {"item": <name>, "amount": <int>}; the Item content lookup behind the name is not ported here.',
    'SpawnGroup.copy() (SpawnGroup.java:173-179, clone-based), SpawnGroup.read/write (serialization) and the unprinted fields spawn (:44), payloads (:46) and team (:52) are NOT in this slice: toString prints exactly the 9 concatenated fields and nothing else; clone/serialization behavior belongs to later slices.',
    'SpawnGroup.toString() Windows Godot proof -- debt in GOAL.md section 5: the N2492 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SPAWN_GROUP, **extra):
        return backed(typ, source, expr, rule, **extra)

    to_string_inputs = {
        'type_name': a('Variant', '    public UnitType type = UnitTypes.dagger;', 'The unit type print string (SpawnGroup.java:26, `    public UnitType type = UnitTypes.dagger;`): Java prints the UnitType via MappableContent.toString() = its content name (MappableContent.java:16-18), so the input is the name string itself (the N2457 name model); null prints as "null", as Java concatenation does for a null reference.'),
        'end': a('int', '    public int end = never;', 'The spawn end wave (SpawnGroup.java:28, `    public int end = never;`): printed decimal after ", end=", exactly as the int field reads.'),
        'begin': a('int', '    public int begin;', 'The spawn begin wave (SpawnGroup.java:30, `    public int begin;`): printed decimal after ", begin=", exactly as the int field reads.'),
        'spacing': a('int', '    public int spacing = 1;', 'The spawn spacing in waves (SpawnGroup.java:32, `    public int spacing = 1;`): printed decimal after ", spacing=", exactly as the int field reads.'),
        'max': a('int', '    public int max = 40;', 'The maximum amount of units that spawn (SpawnGroup.java:34, `    public int max = 40;`): printed decimal after ", max=", exactly as the int field reads.'),
        'unit_scaling': a('float', '    public float unitScaling = never;', 'The unit scaling (SpawnGroup.java:36, `    public float unitScaling = never;`): printed after ", unitScaling=" with Java Float.toString semantics -- float32 narrowing, shortest round-trip digits, plain notation on [1e-3, 1e7), scientific outside it; the field default `never` prints as "2.1474836E9".'),
        'unit_amount': a('int', '    public int unitAmount = 1;', 'The initial amount of enemies spawned (SpawnGroup.java:42, `    public int unitAmount = 1;`): printed decimal after ", unitAmount=", exactly as the int field reads.'),
        'effect_name': a('Variant', '    public @Nullable StatusEffect effect;', 'The status effect print string (SpawnGroup.java:48, `    public @Nullable StatusEffect effect;`): Java prints the StatusEffect via StatusEffect.toString() = localizedName (StatusEffect.java:244-246), so the input is the print string itself (the N2457 name model); null ("Null to disable") prints as "null".'),
        'items': a('Variant', '    public @Nullable ItemStack items;', 'The items the unit spawns with (SpawnGroup.java:50, `    public @Nullable ItemStack items;`): a single ItemStack modeled as a Dictionary {"item": <name>, "amount": <int>} (the N2457 model), printed via ItemStack.toString() (ItemStack.java:82-84) as `<item>: <amount>`; null ("Null to disable") prints as "null".'),
    }
    to_string_outputs = {
        'to_string': a('String', FORMULA, 'The rendered SpawnGroup string (SpawnGroup.java:160-170): "SpawnGroup{" + the 9 fields in Java order + "}", with shields/shieldScaling deliberately absent; returned in the one-key envelope because the SSOT contract return_type only accepts Dictionary or void (the N2365 precedent).'),
    }
    return to_string_inputs, to_string_outputs


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
    to_string_inputs, to_string_outputs = definitions()

    entries = [
        ('N2492', TO_STRING_OWNER, 'source_spawn_group_to_string_state', SPAWN_GROUP, 'mindustry.game.SpawnGroup', JAVA_METHOD, to_string_inputs, to_string_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2096 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SpawnGroup.toString() state from SpawnGroup.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SpawnGroup.toString() state from SpawnGroup.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2492'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2492', dict(status='done', java_source=SPAWN_GROUP, java_class='mindustry.game.SpawnGroup', java_method=JAVA_METHOD, godot_owner=TO_STRING_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2492'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
