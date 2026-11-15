"""Register the ShockwaveTower charge advance (N2192).

The ShockwaveTower's reload-counter charge, following the N2177
pure-row pattern and the N2190 refresh precedent. N2177 folded
power-only: a pure power row over the stamped frame value, folded
by the shared machinery into the min efficiency
(BuildingComp.java:1969-1976, ConsumePower.efficiency is
build.power.status) -- but ShockwaveTowerBuild.updateTile charges
a reload counter by edelta() before it can fire:
`if(potentialEfficiency > 0 && (reloadCounter += edelta()) >=
reload && timer(timerCheck, checkInterval)){`
(ShockwaveTower.java:73), and edelta() is efficiency * delta
(BuildingComp.java:1927-1929, `return efficiency * delta();`).
N2177 deferred the whole updateTile advance with a documented
limit (the PointDefenseTurret N2151 precedent): the port tracked
no live reload counter on any placed-building frame, so the tower
could never charge and never fire. N2192 lands ONLY the charge
advance -- the prerequisite for the shouldConsume gate (`return
reloadCounter < reload;`, ShockwaveTower.java:121-122), which
needs a live counter to read. The charge is one pure function
(source_shockwave_tower_charge_state) over the frame keys the
N2177 machinery stamps (`potential_efficiency` and `efficiency`,
via apply_update_consumption_state): the gate reads
potentialEfficiency, the increment reads efficiency * delta.
RED decision (pinned by this slice -- the N2190 RepairTower
refresh precedent): when the frame carries NO `reload_counter`
key, start from deterministic 0.0 -- Java inits `reloadCounter =
Mathf.random(reload);` (ShockwaveTower.java:67), but the port
takes the deterministic 0.0 start, never `randf` in game code
(the C06DefenseProof lesson: seeded RNG only in proof scenes).
RED decision (pinned by this slice): NO clamp at reload -- Java
keeps accumulating past reload until a successful fire resets
the counter to 0 (ShockwaveTower.java:83, `reloadCounter =
0f;`), so a counter past reload stays, with no reset without
fire. The driver change is one call in the existing
source_shockwave_tower_tick_buildings_state, after
apply_update_consumption_state, passing the tick's `seconds` as
the delta (the N2190 driver convention) and stamping the frame
key. The per-def reload is 80f (Blocks.java:2044), overriding
the class default `60f * 1.5f` (ShockwaveTower.java:26), so the
charge threshold the counter runs against is 80f. No new frame
meta key, no SOURCE_CONSUMER_FRAME_META_KEYS change, no
simulate_factory wiring change. Shard note: unlike N2191 (units
path, no shard selects it), ShockwaveTower.java IS selected by
the defense_slices shard (java_source contains
/world/blocks/defense/) and its owner by defense_api_contracts,
so the GREEN register run is expected to mirror N2192 into both
defense shards (the N2177 precedent: N2177 is in both shards).

Composition, not re-implementation: the shared efficiency
machinery (SourceBuildingEfficiencyState.update_consumption_state,
via update_consumption_non_optional_pass_state) already folds
the power row into the min efficiency and stamps
potential_efficiency / efficiency on the frame. N2192 does not
touch it. N2192 supplies the missing pure charge + the one-line
driver call; no new consumer rows. The shockwave tower's power
draw stays STATIC (consumePower 100f/60f, Blocks.java:2042 -- a
plain ConsumePower, not the RepairTurret-style conditional
draw), so the folded efficiency is the min over the *modeled*
consumers (power only); the cyanogen liquid consumer
(consumeLiquids cyanogen 1.5f/60f, Blocks.java:2041) is the
second pass and waits for its own slice. No fire gate: the bullet
scan / wave damage / heat=1 / reloadCounter=0 reset
(ShockwaveTower.java:74-103), the heat decay (:104), sense
(LAccess.progress) (:110), warmup() (:117) and the shouldConsume
gate (:121-122) wait for their own slices; the proof carries no
fire/heat/sense/warmup/gate keys. Single def (shockwave-tower,
size 3, range 170f, reload 80f, Blocks.java:2038-2044).
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_repair_tower_should_consume import DEFERRED as _N2191_DEFERRED

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
SHOCKWAVE_TOWER = 'core/src/mindustry/world/blocks/defense/ShockwaveTower.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07ShockwaveTowerChargeProof'
OWNER = 'SourceShockwaveTowerBuildState.source_shockwave_tower_charge_state'
TESTS = ['test_c07_shockwave_tower_charge_registration', 'test_all_c07_shockwave_tower_charge_input_evidence_is_exact', 'test_shockwave_tower_charge_state', 'test_reference_graph_and_actual_c07_shockwave_tower_charge']
EXACT_EXPRS = ['if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', 'public float reloadCounter = Mathf.random(reload);', 'public float heat = 0f;', 'public float reload = 60f * 1.5f;', 'public float range = 110f;', 'public float checkInterval = 8f;', 'public float cooldownMultiplier = 1f;', 'public class ShockwaveTower extends Block{', 'public class ShockwaveTowerBuild extends Building{', 'return reloadCounter < reload;', 'public boolean shouldConsume(){', 'if(sensor == LAccess.progress) return reloadCounter / reload;', 'heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);', 'return heat;', 'public void updateTile(){', 'heat = 1f;', 'reloadCounter = 0f;', 'float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);', 'public float bulletDamage = 160;', 'public float falloffCount = 20f;', 'public float shake = 2f;', 'public int timerCheck = timers ++;', 'update = true;', 'solid = true;', 'return efficiency * delta();', 'return potentialEfficiency > 0;', 'public boolean canConsume(){', 'potentialEfficiency = efficiency;', 'boolean update = shouldConsume() && productionValid();', 'if(!update){', 'efficiency = optionalEfficiency = 0f;', 'return enabled;', 'consumePower(100f / 60f);', 'consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));', 'range = 170f;', 'reload = 80f;', 'size = 3;', 'return build.power.status;', 'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', 'hasConsumers = consumers.length > 0;']

# DEFERRED is carried from the N2191 register script via import --
# never retyped. The N2191 script's DEFERRED is a computed
# expression (list(_N2190_DEFERRED) + [...]), NOT a plain list
# literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node, ast.Call); the import
# recovers the runtime value verbatim. NOTE for the next slice:
# N2192's DEFERRED is likewise a computed list(...) + [...]
# expression, so carry it forward by import too, not by
# ast.literal_eval. Chain gap, recorded 2026-11-15 at N2192 RED:
# the inherited 158-entry list contains NO ShockwaveTower
# entries -- N2177's register script added them as a literal, but
# the chain forked between N2185 and N2190 and the later slices
# carried the pre-N2177 list forward, so the N2177 ShockwaveTower
# deferred items (fire gate / shouldConsume gate / liquid /
# sense-warmup / draw / shape-timer / trigger / per-def) live
# only in the N2177 ledger row, not in this carried list. The new
# entry below re-pins the still-deferred ShockwaveTower follow-ups
# from N2192's own standpoint instead of retyping the old list.
DEFERRED = list(_N2191_DEFERRED) + [
    'ShockwaveTower charge Windows Godot proof -- debt in GOAL.md section 5, same as N2182-N2191: the N2192 proof runs headless on Linux here and waits for a Windows Godot run.',
    'ShockwaveTower fire gate / shouldConsume gate after the charge (ShockwaveTower.java:74-103 bullet scan / wave damage / heat=1 / reloadCounter=0 reset, :104 heat decay, :110 sense(LAccess.progress), :117 warmup(), :121-122 shouldConsume `return reloadCounter < reload;`) -- N2192 lands ONLY the charge `reloadCounter += edelta()` gated on `potentialEfficiency > 0`; the fire gate and the shouldConsume gate itself wait for their own slices, as do the cyanogen liquid consumer (Blocks.java:2041) and the draw modeling (:126-134).',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=SHOCKWAVE_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2192_inputs = {
        'frame': f('Dictionary', 'return efficiency * delta();', 'The building frame carrying the reload_counter observation (ShockwaveTower.java:67, `public float reloadCounter = Mathf.random(reload);`, deterministic 0.0 start in the port) plus the potential_efficiency / efficiency the N2177 machinery stamps each tick via apply_update_consumption_state (BuildingComp.java:1989, `potentialEfficiency = efficiency;`); a missing reload_counter key starts at 0.0, a missing potential_efficiency means no advance before the first consumption stamp.', source=BUILDING_COMP),
    }
    n2192_outputs = {
        'reload_counter': f('float', 'if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', 'The charged reload counter (ShockwaveTower.java:73): reload_counter + efficiency * delta when potentialEfficiency > 0, unchanged otherwise; no clamp at reload (per-def 80f, Blocks.java:2044) and no reset without fire -- Java resets only on a successful fire (ShockwaveTower.java:83, `reloadCounter = 0f;`).'),
    }

    entries = [
        ('N2192', OWNER, 'source_shockwave_tower_charge_state', SHOCKWAVE_TOWER, 'mindustry.world.blocks.defense.ShockwaveTower.ShockwaveTowerBuild', 'ShockwaveTowerBuild.updateTile()', n2192_inputs, n2192_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ShockwaveTower charge advance from ShockwaveTower.java / BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ShockwaveTower charge advance from ShockwaveTower.java / BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the charged counter, its only result key.
    by_slice['N2192'] = [
        'source_shockwave_tower_charge_state_result.reload_counter',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2192', dict(status='done', java_source=SHOCKWAVE_TOWER, java_class='mindustry.world.blocks.defense.ShockwaveTower.ShockwaveTowerBuild', java_method='ShockwaveTowerBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2192'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
    main()
