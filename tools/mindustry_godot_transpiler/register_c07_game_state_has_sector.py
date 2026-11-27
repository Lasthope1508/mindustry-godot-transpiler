"""Register GameState.hasSector() (N2483).

GameState.hasSector() (GameState.java:77-79) is one slice
(batch 53 slot 2):
    public boolean hasSector(){
        return rules.sector != null;
    }
The body is IDENTICAL to isCampaign() (:73-75) -- the two
methods sit next to each other in the real Java, this is
not a copy error. The trap is that there is NO fallback
to rules.planet -- unlike getPlanet() (N2454,
GameState.java:85-87: `return rules.sector != null ?
rules.sector.planet : rules.planet;`), sector null is
false even when rules.planet is non-null. The GD function
therefore takes rules_sector and rules_planet (signature
parity with the N2454 accessors and with isCampaign
N2474, whose rules fields arrive as separate Variant
params) and deliberately does NOT consult rules_planet --
the proof pins that with a sector-null + planet-present
case AND cross-pins hasSector against isCampaign (N2474)
on all 4 sector/planet combinations. `rules` is the
GameState input param, not an owned schema (GameState.java:35
`public Rules rules = new Rules();`); Rules.sector is
`public @Nullable Sector sector;` (Rules.java:167),
default null. The sector arrives as an opaque Variant
(null when absent, a Dictionary carrying "planet" when
present -- the N2454 precedent).

TWIN-REGISTER -- approved explicitly by the main thread
for N2483 (2026-11-27). The body literal
`return rules.sector != null;` is ALREADY an exact_expr
of N2124 (a compound UnitFactory slice), which cites it
only as dependency evidence for unlockedNowHost()
(`return !state.isCampaign() || unlockedHost();`,
register_unit_factory_should_consume.py:117-120) --
N2124 is the ORIGINAL owner of the literal and ports NO
hasSector function (its godot_owner is
SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state).
The same literal is also an exact_expr of N2474
(isCampaign -- the twin sibling, twin-registered with
its own main-thread approval 2026-11-26), which ports
isCampaign, not hasSector. N2474's deferred_exprs
anticipated exactly this ("GameState.hasSector()
(GameState.java:77-79) is NOT in this slice: it shares
the literal `return rules.sector != null;` with
isCampaign() and needs its own twin-register approval")
-- that approval is now given for N2483. java_method
`GameState.hasSector()` is 0-hit and no GD function
computes it yet, so this slice adds a real new GD
function -- NOT a duplicate like TeamData.active(),
which was permanently excluded because its behaviour
was already ported by N2074/N2075. Precedent for twin
registration with explicit main-thread approval: N2474
(`return rules.sector != null;`), N2421
(`return isShooting;`, register_c07_continuous_turret_ammo_one_liners.py),
N1199/N1223, N2389, N2418. The only `has_sector` hit
in the registry before this slice is the unrelated
TeamData symbol
source_team_data_time_destroy_state_result.has_sector.
One slice source: GameState.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
GAME_STATE = 'core/src/mindustry/core/GameState.java'
PROOF = '/root/C07GameStateHasSectorProof'
HAS_SECTOR_OWNER = 'SourceGameLoopRuntimeState.source_game_state_has_sector_state'
TESTS = ['test_c07_game_state_has_sector_registration', 'test_all_c07_game_state_has_sector_input_evidence_is_exact', 'test_game_state_has_sector_state', 'test_reference_graph_and_actual_c07_game_state_has_sector']
# The 1 slice source the N2483 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/core/GameState.java',
]
FORMULA = '        return rules.sector != null;'
EXACT_EXPRS = [
    '    public boolean hasSector(){',
    FORMULA,
    '    public Rules rules = new Rules();',
]
JAVA_METHOD = 'GameState.hasSector()'

DEFERRED = [
    'GameState.hasSector() Windows Godot proof -- debt in GOAL.md section 5: the N2483 proof runs headless on Linux here and waits for a Windows Godot run.',
    'GameState.hasSector() is a TWIN-REGISTER with explicit main-thread approval (2026-11-27): the literal `return rules.sector != null;` is also an exact_expr of N2124, which cites it only as dependency evidence for unlockedNowHost() (`return !state.isCampaign() || unlockedHost();`) and ports no hasSector function; N2124 is the original owner of the literal. The same literal is also an exact_expr of N2474 (isCampaign -- the twin sibling, twin-registered with its own approval 2026-11-26), which ports isCampaign, not hasSector. Precedent: N2474, N2421, N2389, N2418.',
    'GameState.hasSector() shares its body verbatim with isCampaign() (GameState.java:73-75, N2474); the two methods differ only by name. The proof cross-pins them: same sector/planet inputs give the same result on all 4 combinations.',
]


def definitions():
    def a(typ, expr, rule, source=GAME_STATE, **extra):
        return backed(typ, source, expr, rule, **extra)

    has_sector_inputs = {
        'rules_sector': a('Variant', FORMULA, 'The rules sector, or null (GameState.java:78, `return rules.sector != null;`): `rules` is the GameState input param, not an owned schema; the sector arrives as an opaque ref (a Dictionary carrying "planet" when present, null when absent -- the N2454 precedent).'),
        'rules_planet': a('Variant', FORMULA, 'The fallback planet (GameState.java:86, getPlanet()): received for signature parity with getPlanet() (N2454) and isCampaign() (N2474) and to pin the trap -- hasSector() does NOT consult it; sector null is false even when rules_planet is non-null. getPlanet() is a different method.'),
    }
    has_sector_outputs = {
        'has_sector': a('bool', FORMULA, 'Whether the game has a sector (GameState.java:78, `return rules.sector != null;`): true only when rules_sector is non-null -- NO fallback to rules.planet, unlike getPlanet() (N2454). Identical body to isCampaign() (N2474).'),
    }
    return has_sector_inputs, has_sector_outputs


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
    has_sector_inputs, has_sector_outputs = definitions()

    entries = [
        ('N2483', HAS_SECTOR_OWNER, 'source_game_state_has_sector_state', GAME_STATE, 'mindustry.core.GameState', JAVA_METHOD, has_sector_inputs, has_sector_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed GameState.hasSector() state from GameState.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed GameState.hasSector() state from GameState.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2483'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2483', dict(status='done', java_source=GAME_STATE, java_class='mindustry.core.GameState', java_method=JAVA_METHOD, godot_owner=HAS_SECTOR_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2483'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
