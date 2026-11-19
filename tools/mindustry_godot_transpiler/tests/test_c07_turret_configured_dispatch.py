import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_CONFIGURED_DISPATCH_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretConfiguredDispatchProof.gd'


class C07TurretConfiguredDispatchTests(unittest.TestCase):
    def test_c07_turret_configured_dispatch_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2268']['godot_owner'], 'SourceTurretBuildState.source_turret_configured_dispatch_state')
        # BuildingComp.configured() (BuildingComp.java:1414-1432) is
        # what the super.control() config case calls
        # (BuildingComp.java:2161, `configured(null, p1);`, via
        # the :2159 guard pinned by N2267). The type is resolved
        # first:
        # `//null is of type void.class; anonymous classes use
        # their superclass.`
        # `Class<?> type = value == null ? void.class :
        # value.getClass().isAnonymousClass() ?
        # value.getClass().getSuperclass() : value.getClass();`
        # (:1415-1416), then the instanceof overrides pin the
        # four content kinds:
        # `if(value instanceof Item) type = Item.class;`
        # `if(value instanceof Block) type = Block.class;`
        # `if(value instanceof Liquid) type = Liquid.class;`
        # `if(value instanceof UnitType) type =
        # UnitType.class;`
        # (:1418-1421). A player builder stamps last access:
        # `if(builder != null && builder.isPlayer()){`
        # `updateLastAccess(builder.getPlayer());`
        # `}` (:1423-1425), where updateLastAccess is
        # `public void updateLastAccess(Player player){`
        # `lastAccessed = player.coloredName();`
        # `}` (:1437-1439) and the field is `transient String
        # lastAccessed;` (:70). isPlayer is `public boolean
        # isPlayer(){` `return controller instanceof Player;`
        # `}` (UnitComp.java:949-950). Then the dispatch:
        # `if(block.configurations.containsKey(type)){`
        # `block.configurations.get(type).get(this, value);`
        # `}else if(value instanceof Building build){`
        # `//copy config of another building`
        # `var conf = build.config();`
        # `if(conf != null && !(conf instanceof Building)){`
        # `configured(builder, conf);`
        # `}`
        # `}` (:1427-1435) -- a registered handler runs for
        # the resolved type, otherwise a Building value copies
        # the other building's config recursively (at most one
        # level: the guard rejects a Building conf, so the
        # recursive call can never take the copy branch again).
        # The configurations map is `public ObjectMap<Class<?>,
        # Cons2> configurations = new ObjectMap<>();`
        # (Block.java:402), filled by `public <T, E extends
        # Building> void config(Class<T> type, Cons2<E, T>
        # config){` `configurations.put(type, config);` (:926-929)
        # and by `public <E extends Building> void
        # configClear(Cons<E> cons){` `configurations.put
        # (void.class, (tile, value) -> cons.get((E)tile));`
        # (:921-924, the void.class handler for a null value).
        # `config()` itself is `public Object config(){`
        # `return null;` (BuildingComp.java:2024-2027) by
        # default. Duo registers no configuration at all (no
        # `config(` in ItemTurret.java, Turret.java,
        # ReloadTurret.java or BaseTurret.java), so its
        # configurations map is empty: no handler ever applies
        # and config() returns null, so the copy branch never
        # recurses either -- configured() is a noop for duo.
        # There is NO driver tick: configured() is event-driven
        # (called from control(), the N2248 precedent,
        # N2264/N2266/N2267) -- the logic executor does not
        # exist in the driver yet, so the pure function is
        # called directly by the proof. Four new result
        # symbols: resolved_type, handler_applied,
        # config_copied, last_access_updated.
        self.assertEqual(
            ledger['N2268']['source_symbols'],
            [
                'source_turret_configured_dispatch_state_result.resolved_type',
                'source_turret_configured_dispatch_state_result.handler_applied',
                'source_turret_configured_dispatch_state_result.config_copied',
                'source_turret_configured_dispatch_state_result.last_access_updated',
            ],
        )
        for name in ledger['N2268']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_configured_dispatch_state_result.resolved_type': 'SourceTurretBuildState.source_turret_configured_dispatch_state',
                    'source_turret_configured_dispatch_state_result.handler_applied': 'SourceTurretBuildState.source_turret_configured_dispatch_state',
                    'source_turret_configured_dispatch_state_result.config_copied': 'SourceTurretBuildState.source_turret_configured_dispatch_state',
                    'source_turret_configured_dispatch_state_result.last_access_updated': 'SourceTurretBuildState.source_turret_configured_dispatch_state',
                }[name])
        self.assertEqual(ledger['N2268']['runtime_proof'], '/root/C07TurretConfiguredDispatchProof')
        self.assertEqual(
            ledger['N2268']['tests'],
            [
                'test_c07_turret_configured_dispatch_registration',
                'test_all_c07_turret_configured_dispatch_input_evidence_is_exact',
                'test_turret_configured_dispatch_state',
                'test_reference_graph_and_actual_c07_turret_configured_dispatch',
            ],
        )
        self.assertTrue(ledger['N2268']['deferred_exprs'])

    def test_all_c07_turret_configured_dispatch_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2268']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_configured_dispatch_state_result.resolved_type': 'SourceTurretBuildState.source_turret_configured_dispatch_state',
                    'source_turret_configured_dispatch_state_result.handler_applied': 'SourceTurretBuildState.source_turret_configured_dispatch_state',
                    'source_turret_configured_dispatch_state_result.config_copied': 'SourceTurretBuildState.source_turret_configured_dispatch_state',
                    'source_turret_configured_dispatch_state_result.last_access_updated': 'SourceTurretBuildState.source_turret_configured_dispatch_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/comp/UnitComp.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2268']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_configured_dispatch_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # BuildingComp.configured() (BuildingComp.java:1414-1432)
        # resolves the value's type first (:1415-1416, the
        # void.class / anonymous-superclass comment and the
        # ternary), pins the four content kinds with instanceof
        # overrides (:1418-1421), stamps last access for a player
        # builder (:1423-1425, updateLastAccess at :1437-1439,
        # `transient String lastAccessed;` at :70, isPlayer at
        # UnitComp.java:949-950), then dispatches: a registered
        # handler for the resolved type (:1427-1428), otherwise
        # a Building value copies the other building's config
        # recursively (:1429-1435, `var conf = build.config();`
        # with the non-null non-Building guard, `public Object
        # config(){` defaulting to null at :2024-2027). The
        # configurations map is `public ObjectMap<Class<?>,
        # Cons2> configurations = new ObjectMap<>();`
        # (Block.java:402), filled by `config(` (:926-929) and
        # `configClear(` (:921-924, the void.class handler).
        # Duo registers no configuration, so its map is empty
        # and configured() is a noop for duo. The pure function
        # takes the value kind, the anonymous flag, the
        # superclass kind, whether a handler is registered for
        # the resolved type, the copied building's config kind
        # and the player-builder flag, and returns the four keys
        # `{"resolved_type": .., "handler_applied": ..,
        # "config_copied": .., "last_access_updated": ..}`.
        # There is NO driver tick: configured() is event-driven
        # (the N2248 precedent, N2264/N2266/N2267), the logic
        # executor does not exist in the driver yet.
        self.assertIn('static func source_turret_configured_dispatch_state(value_kind: String, value_is_anonymous: bool, superclass_kind: String, has_handler: bool, building_config_kind: String, builder_is_player: bool) -> Dictionary:', turret)
        self.assertIn('return {"resolved_type": resolved_type, "handler_applied": handler_applied, "config_copied": config_copied, "last_access_updated": last_access_updated}', turret)
        self.assertIn('public void configured(@Nullable Unit builder, @Nullable Object value){', turret)
        self.assertIn('//null is of type void.class; anonymous classes use their superclass.', turret)
        self.assertIn('Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();', turret)
        self.assertIn('if(value instanceof Item) type = Item.class;', turret)
        self.assertIn('if(value instanceof Block) type = Block.class;', turret)
        self.assertIn('if(value instanceof Liquid) type = Liquid.class;', turret)
        self.assertIn('if(value instanceof UnitType) type = UnitType.class;', turret)
        self.assertIn('if(builder != null && builder.isPlayer()){', turret)
        self.assertIn('updateLastAccess(builder.getPlayer());', turret)
        self.assertIn('public void updateLastAccess(Player player){', turret)
        self.assertIn('lastAccessed = player.coloredName();', turret)
        self.assertIn('transient String lastAccessed;', turret)
        self.assertIn('return controller instanceof Player;', turret)
        self.assertIn('if(block.configurations.containsKey(type)){', turret)
        self.assertIn('block.configurations.get(type).get(this, value);', turret)
        self.assertIn('}else if(value instanceof Building build){', turret)
        self.assertIn('//copy config of another building', turret)
        self.assertIn('var conf = build.config();', turret)
        self.assertIn('if(conf != null && !(conf instanceof Building)){', turret)
        self.assertIn('configured(builder, conf);', turret)
        self.assertIn('public Object config(){', turret)
        self.assertIn('public ObjectMap<Class<?>, Cons2> configurations = new ObjectMap<>();', turret)
        self.assertIn('public <T, E extends Building> void config(Class<T> type, Cons2<E, T> config){', turret)
        self.assertIn('configurations.put(type, config);', turret)
        self.assertIn('configurations.put(void.class, (tile, value) -> cons.get((E)tile));', turret)
        # The proof's keys drive configured() through the pure
        # function: an Item value with a registered handler
        # applies it / a Block value with a handler applies it
        # / a Liquid value with a handler applies it / a
        # UnitType value with a handler applies it / a null
        # value resolves to void and applies the void handler
        # / an anonymous value resolves to its superclass / a
        # Building value with no handler copies a non-Building
        # config / a Building value does not copy when the
        # other config is null / a Building value does not copy
        # when the other config is itself a Building / a
        # handler beats the Building copy branch / a player
        # builder stamps last access / the duo live case is a
        # noop (no configurations, config() null).
        proof = TURRET_CONFIGURED_DISPATCH_PROOF.read_text(encoding='utf-8')
        for key in [
            'configured_item_handler',
            'configured_block_handler',
            'configured_liquid_handler',
            'configured_unit_type_handler',
            'configured_null_void_handler',
            'configured_anonymous_uses_superclass',
            'configured_building_copies_config',
            'configured_building_no_copy_when_config_null',
            'configured_building_no_copy_when_config_building',
            'configured_handler_beats_building_copy',
            'configured_player_updates_last_access',
            'configured_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_configured_dispatch(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretConfiguredDispatchProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_CONFIGURED_DISPATCH_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'configured_item_handler',
            'configured_block_handler',
            'configured_liquid_handler',
            'configured_unit_type_handler',
            'configured_null_void_handler',
            'configured_anonymous_uses_superclass',
            'configured_building_copies_config',
            'configured_building_no_copy_when_config_null',
            'configured_building_no_copy_when_config_building',
            'configured_handler_beats_building_copy',
            'configured_player_updates_last_access',
            'configured_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
