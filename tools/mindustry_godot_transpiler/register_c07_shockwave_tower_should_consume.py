"""Register the ShockwaveTower shouldConsume gate (N2193).

The ShockwaveTower's shouldConsume gate, following the N2177
pure-row pattern and the N2191 shouldConsume precedent. N2177
folded power-only: a pure power row over the stamped frame value,
folded by the shared machinery into the min efficiency
(BuildingComp.java:1969-1976, ConsumePower.efficiency is
build.power.status) -- but ShockwaveTowerBuild DOES override
shouldConsume: `return reloadCounter < reload;`
(ShockwaveTower.java:122), and updateConsumption forces
efficiency to zero when the gate is false
(BuildingComp.java:1960, `boolean update = shouldConsume() &&
productionValid();` + 1992-1993, `if(!update){` / `efficiency =
optionalEfficiency = 0f;`). N2177 deferred the gate with a
documented limit (the PointDefenseTurret N2151 precedent): the
port tracked no live reload counter on any placed-building frame,
so with a fully charged tower power.status reads 1.0 while Java
efficiency is 0. N2192 stamped the prerequisite counter: the
charge advance is the ONLY writer of `reload_counter`
(ShockwaveTower.java:73, `if(potentialEfficiency > 0 &&
(reloadCounter += edelta()) >= reload && timer(timerCheck,
checkInterval)){`), and the driver stamps it every tick after
apply_update_consumption_state. N2193 closes that gap with one
pure function (source_shockwave_tower_should_consume_state) over
that one frame key (`reload_counter`, float): the gate is the
same expression over the observed counter, `reloadCounter <
reload`, read as `float(reload_counter) < 80.0 and enabled`
against the per-def reload 80f (Blocks.java:2044, overriding the
class default `60f * 1.5f`, ShockwaveTower.java:26). RED decision
(pinned by this slice -- the N2191 `targets_count` precedent):
when the frame carries NO `reload_counter` key, preserve the
N2177 behavior (`should_consume = enabled`) -- null means "no
observation yet", not "fully charged", because the N2192 charge
stamps `reload_counter` only after the first consumption stamp
each tick, and defaulting absent to false would zero efficiency
for every live shockwave tower before its first charge tick, a
live regression against N2177 GREEN. It also matches the Java
init: `reloadCounter = Mathf.random(reload);`
(ShockwaveTower.java:67) is always < reload, so at Java init the
gate is true when enabled. The driver change is one line in the
existing source_shockwave_tower_tick_buildings_state: the
pure-function call replaces `var should_consume: bool =
bool(frame.get("enabled", true))` BEFORE the consumption setup --
the Java order (updateConsumption :2274 reads shouldConsume() at
:1960), reading the `reload_counter` the previous tick's charge
stamped; the setup / power row / `update_consumption_state` /
`apply_update_consumption_state` / charge calls are unchanged.
No new frame meta key, no SOURCE_CONSUMER_FRAME_META_KEYS
change, no simulate_factory wiring change. Shard note: like
N2192, ShockwaveTower.java IS selected by the defense_slices
shard (java_source contains /world/blocks/defense/) and its
owner by defense_api_contracts, so the GREEN register run is
expected to mirror N2193 into both defense shards (the N2177 /
N2192 precedent).

Composition, not re-implementation: the shared efficiency
machinery (SourceBuildingEfficiencyState.update_consumption_state,
via update_consumption_non_optional_pass_state) already zeroes
efficiency when should_consume is false. N2193 does not touch
it. N2193 supplies the missing pure gate + the one-line driver
change; no new consumer rows. The shockwave tower's power draw
stays STATIC (consumePower 100f/60f, Blocks.java:2042 -- a plain
ConsumePower, not the RepairTurret-style conditional draw), so
the folded efficiency is the min over the *modeled* consumers
(power only); the cyanogen liquid consumer (consumeLiquids
cyanogen 1.5f/60f, Blocks.java:2041) is the second pass and waits
for its own slice. No fire gate: the bullet scan / wave damage /
heat=1 / reloadCounter=0 reset (ShockwaveTower.java:74-103), the
heat decay (:104), sense (LAccess.progress) (:110), warmup()
(:117) and the draw modeling (:126-134) wait for their own
slices; the proof carries no fire/heat/sense/warmup keys. Single
def (shockwave-tower, size 3, range 170f, reload 80f,
Blocks.java:2038-2044).
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_shockwave_tower_charge import DEFERRED as _N2192_DEFERRED

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
SHOCKWAVE_TOWER = 'core/src/mindustry/world/blocks/defense/ShockwaveTower.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07ShockwaveTowerShouldConsumeProof'
OWNER = 'SourceShockwaveTowerBuildState.source_shockwave_tower_should_consume_state'
TESTS = ['test_c07_shockwave_tower_should_consume_registration', 'test_all_c07_shockwave_tower_should_consume_input_evidence_is_exact', 'test_shockwave_tower_should_consume_state', 'test_reference_graph_and_actual_c07_shockwave_tower_should_consume']
EXACT_EXPRS = ['if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', 'public float reloadCounter = Mathf.random(reload);', 'public float heat = 0f;', 'public float reload = 60f * 1.5f;', 'public float range = 110f;', 'public float checkInterval = 8f;', 'public float cooldownMultiplier = 1f;', 'public class ShockwaveTower extends Block{', 'public class ShockwaveTowerBuild extends Building{', 'return reloadCounter < reload;', 'public boolean shouldConsume(){', 'if(sensor == LAccess.progress) return reloadCounter / reload;', 'heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);', 'return heat;', 'public void updateTile(){', 'heat = 1f;', 'reloadCounter = 0f;', 'float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);', 'public float bulletDamage = 160;', 'public float falloffCount = 20f;', 'public float shake = 2f;', 'public int timerCheck = timers ++;', 'update = true;', 'solid = true;', 'return efficiency * delta();', 'return potentialEfficiency > 0;', 'public boolean canConsume(){', 'potentialEfficiency = efficiency;', 'boolean update = shouldConsume() && productionValid();', 'if(!update){', 'efficiency = optionalEfficiency = 0f;', 'return enabled;', 'consumePower(100f / 60f);', 'consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));', 'range = 170f;', 'reload = 80f;', 'size = 3;', 'return build.power.status;', 'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', 'hasConsumers = consumers.length > 0;']

# DEFERRED is carried from the N2192 register script via import --
# never retyped. The N2192 script's DEFERRED is a computed
# expression (list(_N2191_DEFERRED) + [...]), NOT a plain list
# literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node, ast.Call); the import
# recovers the runtime value verbatim. NOTE for the next slice:
# N2193's DEFERRED is likewise a computed list(...) + [...]
# expression, so carry it forward by import too, not by
# ast.literal_eval. Chain gap, recorded 2026-11-15 at N2192 RED
# and still true: the inherited 160-entry list contains NO
# ShockwaveTower entries -- N2177's register script added them
# as a literal, but the chain forked between N2185 and N2190 and
# the later slices carried the pre-N2177 list forward, so the
# N2177 ShockwaveTower deferred items (fire gate / shouldConsume
# gate / liquid / sense-warmup / draw / shape-timer / trigger /
# per-def) live only in the N2177 ledger row, not in this carried
# list. The new entries below re-pin the still-deferred
# ShockwaveTower follow-ups from N2193's own standpoint instead
# of retyping the old list. The shouldConsume gate itself is NOT
# carried as deferred: it is THIS slice (N2193) -- the inherited
# N2192 entry still names it as waiting, which is stale history,
# superseded by this slice.
DEFERRED = list(_N2192_DEFERRED) + [
    'ShockwaveTower shouldConsume Windows Godot proof -- debt in GOAL.md section 5, same as N2182-N2192: the N2193 proof runs headless on Linux here and waits for a Windows Godot run.',
    'ShockwaveTower fire gate after the shouldConsume gate (ShockwaveTower.java:74-103 bullet scan / wave damage / heat=1 / reloadCounter=0 reset, :104 heat decay, :110 sense(LAccess.progress), :117 warmup(), cyanogen liquid consumer Blocks.java:2041, draw :126-134) -- N2193 lands ONLY the shouldConsume gate `return reloadCounter < reload;` over the N2192 live counter; the fire gate, heat decay, sense, warmup, liquid and draw wait for their own slices.',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=SHOCKWAVE_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2193_inputs = {
        'frame': f('Dictionary', 'return reloadCounter < reload;', 'The building frame carrying the reload_counter observation (ShockwaveTower.java:67, `public float reloadCounter = Mathf.random(reload);`, stamped by the N2192 charge every tick after apply_update_consumption_state) plus enabled; a missing reload_counter key means no observation yet (N2177 behavior preserved), not fully charged. The per-def reload is 80f (Blocks.java:2044), overriding the class default `60f * 1.5f` (ShockwaveTower.java:26).', source=BUILDING_COMP),
    }
    n2193_outputs = {
        'should_consume': f('bool', 'return reloadCounter < reload;', 'The shouldConsume gate (ShockwaveTower.java:121-122): float(reload_counter) < 80.0 and enabled when a counter observation is present, enabled when the frame carries no reload_counter key (the N2177 behavior); false gates efficiency to 0 via updateConsumption (BuildingComp.java:1960 + 1992-1993).'),
    }

    entries = [
        ('N2193', OWNER, 'source_shockwave_tower_should_consume_state', SHOCKWAVE_TOWER, 'mindustry.world.blocks.defense.ShockwaveTower.ShockwaveTowerBuild', 'ShockwaveTowerBuild.shouldConsume()', n2193_inputs, n2193_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ShockwaveTower shouldConsume gate from ShockwaveTower.java / BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ShockwaveTower shouldConsume gate from ShockwaveTower.java / BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the gate, its only result key.
    by_slice['N2193'] = [
        'source_shockwave_tower_should_consume_state_result.should_consume',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2193', dict(status='done', java_source=SHOCKWAVE_TOWER, java_class='mindustry.world.blocks.defense.ShockwaveTower.ShockwaveTowerBuild', java_method='ShockwaveTowerBuild.shouldConsume()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2193'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
