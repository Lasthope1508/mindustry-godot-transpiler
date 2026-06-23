# Mindustry to Godot GDScript Transpiler Design

**Date:** 2026-06-23
**Workspace:** `C:\Users\Admin\Documents\Game`
**Upstream source:** `C:\Users\Admin\Documents\Game\mindustry-upstream`
**Upstream commit:** `2bdedfed25932ebf11330d3584092c50e2e26d96`
**Target engine:** Godot 4.6.2
**Target language:** GDScript
**Approach chosen:** Automated transpiler pipeline

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total tracked work items | 54 |
| Done | 54 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| D1 | Clone Mindustry upstream source | `mindustry-upstream` exists and `git rev-parse HEAD` returns `2bdedfed25932ebf11330d3584092c50e2e26d96` |
| D2 | Initial source inventory | Measured `845` Java files, `801` core Java files, `2970` asset files |
| N1 | Create Godot output project | `mcp__godot.project_info` reads `Mindustry Godot Port`; main scene is `res://scenes/Main.tscn` |
| N2 | Create transpiler CLI skeleton | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` passes CLI tests |
| N3 | Build source scanner | Full run writes `source_manifest.json` and reports `801` core Java files |
| N4 | Add Java AST parser | `test_java_ast.py` passes class and enum parser fixtures; `parse --limit 20` writes `ast_manifest.json` |
| N5 | Define Java-to-GDScript mapping table | `test_mapping.py` verifies class, enum, method, field, constructor, static initializer, overload, package, import mappings |
| N6 | Emit GDScript classes | `emit` command writes `801` parseable GDScript class skeletons under `src/generated/classes`; Godot MCP project scan sees `827` scripts and representative generated class LSP diagnostics return `diagnostics: []` |
| N7 | Create compatibility runtime | Runtime stubs exist for `Seq`, `ObjectMap`, `Time`, `Mathf`, `ColorCompat`, `Vec2`, `Vars`, `Events`, `Core`; MCP project scan sees scripts |
| N8 | Port base content model | `MindustryContent`, `MindustryUnlockableContent`, `MindustryItem`, `MindustryLiquid`, `MindustryBlock`, and `MindustryContentCatalog` load generated registry objects; MCP runtime starts scene with `errors=[]` |
| N9 | Generate first content data | `content` command writes `content_registry.json` and `MindustryContentRegistry.gd`; MCP LSP diagnostics pass for generated registry; registry includes `22` items, `11` liquids, `417` source-declared block constructors |
| N10 | Build asset bridge | Full run writes `asset_manifest.json`, copies `2970` upstream assets, `mcp__godot.project_info` sees Godot asset structure |
| N11 | Add reports for unsupported Java features | `port_report.json` contains `6986` unsupported source locations with exact `path`, `line`, `feature`, and `snippet`; `port_report.md` lists `path:line` entries |
| N12 | Add regression fixtures | `test_regression_fixtures.py` compares generated `MindustryContentRegistry.gd` against checked expected fixture `expected_content_registry.gd`; full test suite reports `16` tests passing |
| N13 | Add source-derived unit registry and first wave | Registry extracts `56` unit constructors from `UnitTypes.java`; `MindustryUnitType` and catalog load generated units; playable scene spawns source-derived dagger sprites and updates wave/core HUD; Python tests pass and MCP runtime output shows `errors=[]` |
| N14 | Add source-derived turret ammo and bullets | Registry extracts `duo` reload/range/ammo from `Blocks.java`; playable scene pre-places a source-derived duo turret, targets spawned units, fires bullet sprites, applies source-derived damage, and MCP runtime output shows `errors=[]` |
| N15 | Add source-derived default waves | Registry extracts default `SpawnGroup` data from `mindustry/game/Waves.java`; playable scene uses generated wave groups and `getSpawned`-equivalent count logic instead of hardcoded dagger waves; MCP runtime output shows `errors=[]` |
| N16 | Reduce Java parser failures to zero for class skeleton emission | Parser strips method/constructor bodies before `javalang` parsing and tolerates text blocks, switch-arrow bodies, pattern `instanceof`, and `instanceof` text in comments; `emit` prints `emitted classes=801 failures=0`; Python suite reports `22` tests passing; Godot MCP LSP diagnostics return `diagnostics: []` for `Renderer.gd`, `BaseBuilderAI.gd`, and `Damage.gd` |
| N17 | Generate Godot class registry for emitted skeletons | `emit` writes `GeneratedClassRegistry.gd` with `801` class metadata entries and records `registry: GeneratedClassRegistry.gd` in `emitted_classes.json`; Python suite reports `22` tests passing; Godot MCP project scan sees `828` scripts; MCP LSP diagnostics for `src/generated/GeneratedClassRegistry.gd` return `diagnostics: []`; MCP debug output returns `errors: []` |
| N18 | Generate collision-safe method stubs for emitted classes | Per-class skeletons now emit `java_method_<name>_<index>(_args)` stubs from Java method metadata, preserving overloads through numeric suffixes; `Items.gd` exposes `java_method_load_0`; `Damage.gd` exposes `35` method stubs; Python suite reports `22` tests passing; MCP LSP diagnostics for `Items.gd` and `Damage.gd` return `diagnostics: []`; MCP debug output returns `errors: []` |
| N19 | Surface generated class registry in playable HUD | `PortGame.gd` preloads `GeneratedClassRegistry.gd`, stores `generated_class_count = GeneratedClassRegistry.count()`, and displays `Generated Java classes: %d` in the HUD; Python suite reports `23` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP launched `scenes/Main.tscn` and debug output returns `errors: []` |
| N20 | Enable Godot runtime MCP and load selected generated scripts | `godot_mcp_runtime` addon is installed and enabled as autoload; MCP runtime status returns `connected=true` and `runtimeAddon=connected` on port `7777`; `PortGame.gd` loads generated scripts for `Items`, `Blocks`, `UnitTypes`, and `Damage` from `GeneratedClassRegistry.gd`; runtime `get_runtime_summary()` returns `generated_class_count=801`, loaded generated names `[Items, Blocks, UnitTypes, Damage]`, content counts `22/11/417/56`, and MCP debug output returns `errors: []` |
| N21 | Instantiate selected generated scripts in the playable scene | `PortGame.gd` calls `script.new()` for selected generated scripts, stores live instances in `loaded_generated_instances`, reports `loaded_generated_instance_names` in HUD and `get_runtime_summary()`; Python suite reports `27` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime status returns `runtimeAddon=connected`; runtime summary returns instance names `[Items, Blocks, UnitTypes, Damage]`; MCP debug output returns `errors: []` |
| N22 | Verify block placement through Godot runtime MCP input | `_unhandled_input()` routes `InputEventMouseButton.position` into `place_selected_block_at_world()`, making runtime-injected mouse clicks place blocks; `get_runtime_summary()` reports `placed_block_count` and `selected_build_index`; Python suite reports `28` tests passing; MCP runtime sets inventory, injects key `2` and mouse click `(320, 320)`, and verifies `placed_block_count` increases from `1` to `2` with debug `errors: []` |
| N23 | Instantiate all generated class skeletons in the playable scene | `PortGame.gd` walks `GeneratedClassRegistry.all_classes()`, loads every `gdscript_path`, creates `RefCounted` instances keyed by `java_package.java_name`, and reports counts/failure arrays in HUD/runtime summary; Python suite reports `29` tests passing; MCP runtime summary returns `generated_class_count=801`, `all_generated_script_count=801`, `all_generated_instance_count=801`, and empty load/instance failure arrays; MCP debug output returns `errors: []` |
| N24 | Populate build palette with all textured source-derived blocks | `PortGame.gd` keeps six pinned blocks first, then appends every textured block from `content_catalog.get_many("block")`; `Tab`/`Shift+Tab` cycle selection and runtime summary reports `selected_build_id`; Python suite reports `30` tests passing; MCP runtime summary returns `build_palette_size=416`, injected `Tab` changes selected id from `conveyor` to `router`, and debug output returns `errors: []` |
| N25 | Select and place any build palette block by source id through MCP | `PortGame.gd` exposes `select_build_block_by_id(block_id: String) -> bool`, allowing runtime selection of non-pinned source blocks; Python suite reports `31` tests passing; MCP runtime call selects `titanium-conveyor` at palette index `237`, then places it at `Vector2(384, 320)`, increasing `placed_block_count` from `1` to `2`; MCP debug output returns `errors: []` |
| N26 | Render placed source blocks at source-derived block size | `PortGame.gd` uses `block_size`, `block_world_size`, and `configure_block_sprite` for manual placement and source blocks, and exposes `last_placed_block_id`, `last_placed_block_size`, and `last_placed_cell` in runtime summary; Python suite reports `32` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime selects `solar-panel-large`, places it at cell `(11, 10)`, returns `last_placed_block_size=3`, and debug output returns `errors: []` |
| N27 | Enforce source-sized block footprint occupancy | `PortGame.gd` tracks occupied cells separately from block origins, returns `bool` from placement, rejects overlapping and out-of-bounds source-sized blocks before spending resources, and exposes `occupied_cell_count`, `last_placed_occupied_cell_count`, and `last_place_blocked` in runtime summary; Python suite reports `33` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime places `solar-panel-large`, returns `last_placed_occupied_cell_count=9`, rejects overlap/out-of-bounds placements, keeps `occupied_cell_count=10`, and debug output returns `errors: []` |
| N28 | Populate starting world blocks from source content occupancy | `PortGame.gd` now creates starting mechanical drill, conveyors, core shard, and duo through `add_source_block()` using source content ids instead of raw sprite aliases, records `initial_world_block_count` and `initial_occupied_cell_count`, and blocks new placement over the prebuilt world footprint; Python suite reports `34` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime reports `initial_world_block_count=12`, `initial_occupied_cell_count=22`, rejects placement on conveyor/core cells with `last_place_blocked=true`, keeps counts unchanged, and debug output returns `errors: []` |
| N29 | Use all source build requirement item types | `PortGame.gd` keeps `core_inventory` as a copper alias and adds `core_items` keyed by source item id; `can_afford()` and `spend_requirements()` iterate every generated `requirements` entry instead of only copper; Python suite reports `35` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime selects `titanium-conveyor`, rejects placement with `lead=0` and `titanium=0`, accepts after setting `copper/lead/titanium=100`, and reports `core_items={copper:99, lead:99, titanium:99}` with debug `errors: []` |
| N30 | Initialize core health from source core block | `PortGame.gd` now initializes `core_max_health` and current `core_health` from `source_block_health("core-shard")` using generated `core-shard.properties.health=1100`; Python suite reports `36` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; restarted MCP runtime summary returns `core_max_health=1100` and debug output returns `errors: []` |
| N31 | Use source unit weapon damage against core | `content_registry.py` extracts `UnitType` first weapon reload and `BasicBulletType` speed/damage/lifetime into `properties.weapons`; generated `dagger` has bullet damage `9`; `PortGame.gd` subtracts `source_unit_weapon_damage(unit_type)` instead of hardcoded `15.0` when units reach the core; Python suite reports `37` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; restarted MCP runtime summary returns `selected_enemy_weapon_damage=9` and debug output returns `errors: []` |
| N32 | Use source bullet sprite assets | `content_registry.py` records `BasicBulletType` sprite ids for block ammo and unit weapons, defaulting two-argument constructors to source sprite `bullet`; generated `duo` ammo and `dagger` weapon bullets include `sprite="bullet"`; `PortGame.gd` loads turret bullet textures from `res://assets/core/assets-raw/sprites/effects/%s.png` instead of using the item icon; Python suite reports `38` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; runtime MCP resolves `source_bullet_texture("bullet")` to `res://assets/core/assets-raw/sprites/effects/bullet.png` with debug `errors: []` |
| N33 | Enforce source core item capacity | `content_registry.py` extracts block `itemCapacity`, generated `core-shard.properties.itemCapacity=4000` from `Blocks.java`, and `PortGame.gd` initializes `core_item_capacity` from `source_block_item_capacity("core-shard")`; core item setters clamp item counts through `clamp_core_item_amount`; Python suite reports `39` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime summary returns `core_item_capacity=4000`, `set_core_item_count("copper", 9999)` clamps to `core_items.copper=4000` and `core_inventory=4000`, with debug `errors: []` |
| N34 | Use source mechanical drill rate | `content_registry.py` extracts block `tier` and `drillTime`, generated `mechanical-drill.properties` includes `tier=2` and `drillTime=600`, and `PortGame.gd` computes drill output from `Drill.getDrillTime(item)` source formula `drillTime + 50 * item.hardness`; Python suite reports `40` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime summary returns `drill_output_item_id="copper"`, `drill_ore_cell_count=2`, and `drill_output_rate=0.184615384615385` from `120/650`, with debug `errors: []` |
| N35 | Use source conveyor speed for item motion | `content_registry.py` extracts block `speed` and `displayedSpeed`, generated `conveyor.properties` includes `speed=0.03` and `displayedSpeed=4.2`, and `PortGame.gd` advances item sprite transport with source `ConveyorBuild` movement formula `speed * tilesize * 55`; Python suite reports `41` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime summary returns `conveyor_world_speed=52.8` and `conveyor_path_progress_rate=0.183333333333333`, with debug `errors: []` |
| N36 | Use source bullet lifetime | `PortGame.gd` converts generated bullet `lifetime` frames to seconds with `lifetime / 60.0`, stores `lifetime_remaining` on turret bullets, removes expired bullets, and exposes `selected_turret_ammo_lifetime_seconds`; Python suite reports `42` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime summary returns `selected_turret_ammo_lifetime_seconds=1` from generated duo copper bullet `lifetime=60`, with debug `errors: []` |
| N37 | Use source bullet speed | `BulletType.java` defines bullet `speed` as units/tick and `BulletComp.java` exposes speed stats as `type.speed * 60f / tilesize`; generated duo copper ammo has `speed=2.5`; `PortGame.gd` converts bullet movement to world pixels/second with `speed * 60.0`, exposes `selected_turret_ammo_world_speed`, and removes the previous `speed * tile_size * 4.0` runtime constant; Python suite reports `43` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime summary returns `selected_turret_ammo_world_speed=150`, with debug `errors: []` |
| N38 | Use source unit speed | `UnitComp.java` returns `type.speed` for base unit speed and `UnitType.java` exposes speed stats as `speed * 60f / tilesize`; generated dagger has `speed=0.5`; `PortGame.gd` converts unit movement to world pixels/second with `speed * 60.0`, exposes `selected_enemy_world_speed`, and removes the previous `max(20.0, speed * tile_size * 5.0)` runtime constant; Python suite reports `44` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime summary returns `selected_enemy_world_speed=30`, with debug `errors: []` |
| N39 | Use source unit hit size for sprite scale | `UnitType.java` defines `hitSize` as the size of one side of the unit hitbox; `UnitTypes.java` sets dagger `hitSize=8f`; generated dagger has `hitSize=8`; `PortGame.gd` scales enemy unit sprites from `source_unit_hit_size(unit_type)` instead of one tile, exposes `selected_enemy_hit_size`, and keeps generic terrain/item sprite scaling unchanged; Python suite reports `45` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime summary returns `selected_enemy_hit_size=8`, with debug `errors: []` |
| N40 | Use source turret reload | `ReloadTurret.java` defaults `reload=10f`; `Blocks.java` sets duo `reload=20f`; generated duo has `reload=20`; `PortGame.gd` converts turret reload frames to seconds with `reload / 60.0`, uses it for turret cooldowns, exposes `selected_turret_reload_seconds`, and removes the previous `max(0.1, reload / 60.0)` runtime guard; Python suite reports `46` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime summary returns `selected_turret_reload_seconds=0.333333333333333`, with debug `errors: []` |
| N41 | Use source turret range | `BaseTurret.java` defaults `range=80f`; `Blocks.java` sets duo `range=160`; generated duo has `range=160`; `PortGame.gd` reads turret range through `source_turret_range(turret)` for targeting and exposes `selected_turret_range`; Python suite reports `47` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime summary returns `selected_turret_range=160`, with debug `errors: []` |
| N42 | Use source bullet dimensions | `Blocks.java` sets duo copper `BasicBulletType.width=7f` and `height=9f`; `content_registry.py` extracts block ammo width/height into generated duo ammo; `PortGame.gd` scales turret bullet sprites through `source_bullet_scale(data, texture_size)` and exposes `selected_turret_ammo_dimensions`; Python suite reports `48` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime summary returns `selected_turret_ammo_dimensions={width:7,height:9}`, with debug `errors: []` |
| N43 | Use source bullet hit size | `BulletType.java` defaults `hitSize=4` and `BulletType.create()` assigns `bullet.hitSize=hitSize`; `content_registry.py` extracts explicit block ammo `hitSize` assignments where source provides them; `PortGame.gd` stores bullet `hit_size` from `source_bullet_hit_size(data)` and uses it for projectile collision instead of `6.0`; Python suite reports `49` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime summary returns `selected_turret_ammo_hit_size=4`, with debug `errors: []` |
| N44 | Use source bullet damage helper | `BulletType.java` defaults `damage=1f` and `BulletType(float speed, float damage)` assigns constructor damage; generated duo copper ammo has `damage=9`; `PortGame.gd` stores bullet damage through `source_bullet_damage(data)` and exposes `selected_turret_ammo_damage`; Python suite reports `50` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime summary returns `selected_turret_ammo_damage=9`, with debug `errors: []` |
| N45 | Use source unit health for spawned units | `UnitType.java` defaults `health=200f`; `UnitTypes.java` sets dagger `health=150`; `PortGame.gd` initializes spawned enemy health through `source_unit_health(unit_type)` instead of `100.0` fallback and exposes `selected_enemy_health`; Python suite reports `51` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime summary returns `selected_enemy_health=150`, with debug `errors: []` |
| N46 | Extract full source duo ammo list | `Blocks.java` defines duo ammo entries for `Items.copper`, `Items.graphite`, and `Items.silicon`; `content_registry.py` now extracts every `Items.x, new BasicBulletType(...)` pair in the turret initializer instead of only the first `ammo(...)` pair; generated duo ammo contains `3` entries with source speed/damage/dimensions; `PortGame.gd` exposes `selected_turret_ammo_count`; Python suite reports `52` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime summary returns `selected_turret_ammo_count=3`, with debug `errors: []` |
| N47 | Extract source bullet ammo multiplier | `BulletType.java` defaults `ammoMultiplier=2f`; `Blocks.java` sets duo copper `ammoMultiplier=2`, graphite `ammoMultiplier=4`, and silicon `ammoMultiplier=5`; `content_registry.py` extracts `ammoMultiplier` from each BasicBulletType body; generated duo ammo contains `2/4/5`; `PortGame.gd` exposes `selected_turret_ammo_multiplier`; Python suite reports `53` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime summary returns `selected_turret_ammo_multiplier=2`, with debug `errors: []` |
| N48 | Extract source item turret ammo storage defaults | `Turret.java` defines default `maxAmmo=30`, `ammoPerShot=1`, and `consumeAmmoOnce=true`; duo does not override these in `Blocks.java`; `content_registry.py` records these defaults for ItemTurret blocks only when source has no assignment for that key, avoiding false defaults for unsupported expressions; `PortGame.gd` exposes selected turret ammo storage fields; Python suite reports `54` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime summary returns `selected_turret_max_ammo=30`, `selected_turret_ammo_per_shot=1`, and `selected_turret_consume_ammo_once=true`, with debug `errors: []` |
| N49 | Port source item turret ammo stack load/use logic | `ItemTurretBuild.handleItem()` adds `type.ammoMultiplier` to the matching item stack and moves that stack to the right; `TurretBuild.useAmmo()` subtracts `ammoPerShot`, pops empty stacks, and returns the peeked ammo type; `PortGame.gd` now keeps per-cell `turret_ammo_stacks` and `turret_total_ammo`, exposes `load_selected_turret_ammo()` and `use_selected_turret_ammo_once()` for MCP verification, and reports loaded ammo state in runtime summary; Python suite reports `55` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime loads two copper items into duo (`total=4` from source `ammoMultiplier=2`) then uses one shot (`total=3`, bullet damage `9`), with debug `errors: []` |
| N50 | Fire source item turrets from loaded ammo stack | `TurretBuild.updateShooting()`/`shoot()` only fires when ammo exists and `useAmmo()` supplies the bullet type; `PortGame.gd` now calls `use_turret_ammo(cell, duo)` before spawning a turret bullet, does not fall back to `duo.properties.ammo[0]`, and records `turret_shot_count`, `last_turret_fired_ammo_item`, and `last_turret_fired_damage` in runtime summary for MCP proof; Python suite reports `56` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; MCP runtime loads three copper items (`selected_turret_total_ammo=6`), observes one fired shot with `last_turret_fired_ammo_item="copper"`, `last_turret_fired_damage=9`, `turret_shot_count=1`, and remaining total ammo `5`, with debug `errors: []` |
| N51 | Extract and use source bullet reload multiplier | `BulletType.java` defines default `reloadMultiplier=1f` and `TurretBuild.ammoReloadMultiplier()` returns `peekAmmo().reloadMultiplier`; `Blocks.java` sets duo graphite `reloadMultiplier=0.8f` and silicon `reloadMultiplier=1.5f`; `content_registry.py` now extracts bullet `reloadMultiplier`, regenerated content registry carries those source values, and `PortGame.gd` uses `source_turret_reload_seconds(turret) / source_bullet_reload_multiplier(data)` after firing loaded ammo; Python suite reports `57` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; deterministic MCP runtime disables `_process`, loads two silicon items (`selected_turret_total_ammo=10` from source `ammoMultiplier=5`), manually calls `simulate_turrets(0.0)`, then reports `last_turret_fired_reload_multiplier=1.5`, `selected_turret_cooldown_seconds=0.222222222222222`, and `selected_turret_total_ammo=9`, with debug `errors: []` |
| N52 | Add source-parity anti-fabrication gate and ammo rangeChange | `source_parity.py` reads `mindustry-upstream/core/src/mindustry/content/Blocks.java` directly and compares generated duo `reload`, `range`, `health`, and ammo fields against `godot-mindustry/src/generated/content_registry.json`, so fabricated or stale values fail `test_source_parity.py`; `Blocks.java` sets duo graphite `rangeChange=16f`, `Turret.java` computes turret range as base `range + peekAmmo().rangeChange`, `content_registry.py` now extracts bullet `rangeChange`, and `PortGame.gd` peeks loaded ammo before targeting so graphite fires at `160 + 16 = 176`; Python suite reports `58` tests passing; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []`; deterministic MCP runtime disables `_process`, loads one graphite item (`selected_turret_total_ammo=4` from source `ammoMultiplier=4`), calls `simulate_turrets(0.0)`, then reports `last_turret_fired_ammo_item="graphite"`, `last_turret_fired_damage=18`, `last_turret_fired_reload_multiplier=0.8`, `last_turret_fired_range=176`, and remaining total ammo `3`, with debug `errors: []` |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open tracked item | Add new tracked work before next milestone |
## Scope

This project does not attempt a blind one-shot conversion of all Java source into working Godot gameplay. It builds a repeatable transpiler pipeline that gradually converts Mindustry source into a Godot 4.6.2 GDScript project while preserving traceability back to upstream files.

The first milestone is a Godot project that loads without parse errors and contains generated GDScript for a small content subset. Gameplay accuracy comes after the generator, runtime shims, and asset bridge are stable.

## Non-Negotiable Accuracy Rules

1. No item moves from `Not Done` to `Done` without fresh verification output.
2. No generated source is called valid until Godot parses it.
3. No parser feature is called supported until it has at least one fixture test.
4. No unsupported Java construct may disappear silently. It must appear in a report with file path and line number.
5. No manual gameplay rewrite is mixed into generated files. Handwritten Godot runtime code lives separately from generated output.
6. GPL-3.0 source lineage must be preserved. Generated Godot derivative must keep license and modified-source notice.

## Architecture

### 1. Source Scanner

The scanner walks `mindustry-upstream/core/src` and records source facts into a manifest. It does not transform code. It records packages, imports, top-level classes, enums, interfaces, inheritance, and file hashes.

Output example:

```json
{
  "source_root": "mindustry-upstream/core/src",
  "files": [
    {
      "path": "core/src/mindustry/content/Items.java",
      "package": "mindustry.content",
      "types": ["Items"],
      "sha256": "computed_file_hash"
    }
  ]
}
```

### 2. Java AST Parser

The parser must use a real Java parser. Preferred options are `tree-sitter-java` in Node/Python or JavaParser through a small Java CLI. Regex-only parsing is forbidden for class/method bodies.

Required extracted nodes:

- class declarations
- enum declarations
- fields
- constructors
- methods
- static initializers
- imports
- inheritance and interfaces
- method calls
- object creation
- lambda and anonymous-class unsupported reports

### 3. Godot Emitter

The emitter converts parsed Java AST into GDScript files under `res://src/mindustry/<package_path>/`.

Mapping rules:

| Java | GDScript |
| --- | --- |
| `package mindustry.content` | `src/mindustry/content/` folder |
| `public class Items` | `class_name Items` |
| constructor | `_init` with matching parameter list |
| static field | class-level `static var` when legal, otherwise registry singleton |
| method overload | suffix with type/count hash, then add dispatcher if needed |
| enum | generated constants plus lookup dictionary |
| Java arrays/list literals | `Array` or typed compatibility wrapper |
| Arc `Seq` | handwritten runtime `Seq.gd` |

Generated files include a header:

```gdscript
# Generated from Mindustry upstream.
# Source: core/src/mindustry/content/Items.java
# Upstream commit: 2bdedfed25932ebf11330d3584092c50e2e26d96
# Do not edit by hand.
```

### 4. Compatibility Runtime

Runtime code is handwritten GDScript that mimics enough Arc/Mindustry APIs for generated code to load.

Initial runtime files:

- `godot/src/runtime/Seq.gd`
- `godot/src/runtime/ObjectMap.gd`
- `godot/src/runtime/Mathf.gd`
- `godot/src/runtime/Time.gd`
- `godot/src/runtime/Events.gd`
- `godot/src/runtime/Core.gd`
- `godot/src/runtime/Vars.gd`
- `godot/src/runtime/ColorCompat.gd`
- `godot/src/runtime/Vec2.gd`

### 5. Content Runtime

Mindustry content classes need lightweight base models before full gameplay exists.

Initial content base:

- `Content.gd`
- `ContentType.gd`
- `UnlockableContent.gd`
- `Item.gd`
- `Liquid.gd`
- `Block.gd`
- `UnitType.gd`
- `BulletType.gd`

These classes only need enough behavior to instantiate generated content safely in milestone 1.

### 6. Asset Bridge

The bridge copies supported assets from upstream into the Godot project and writes a registry file.

Supported first:

- `.png`
- `.ogg`
- `.woff`
- `.ttf`
- `.frag`
- `.vert`

The bridge must preserve relative source path in metadata so each Godot asset can be traced back.

## Output Layout

```text
C:\Users\Admin\Documents\Game
  mindustry-upstream\
  godot-mindustry\
    project.godot
    addons\
    assets\
    src\
      runtime\
      mindustry\
      generated\
  tools\
    mindustry_godot_transpiler\
      scanner\
      parser\
      emitter\
      reports\
      fixtures\
  docs\
    superpowers\
      specs\
      plans\
```

## Milestones

| Milestone | Goal | Done criteria |
| --- | --- | --- |
| M1 | Loadable Godot project with generated content subset | Godot opens project, generated files parse, report shows unsupported constructs |
| M2 | Broader content generation | `Items`, `Liquids`, selected `Blocks`, selected `Bullets` instantiate |
| M3 | Map/world data structures | Tiles, world grid, block placement data model loads |
| M4 | Minimal simulation runtime | Drill, conveyor, item storage, core inventory update in Godot |
| M5 | Visual asset rendering | Generated content references sprites and sounds through registry |
| M6 | Continuous regression suite | Fixture and Godot parse tests run from one command |

## Risks

| Risk | Control |
| --- | --- |
| Generated `mindustry.gen` code missing from source | Build or stub generated API explicitly; record every missing generated dependency |
| Java semantics do not map cleanly to GDScript | Use compatibility runtime and unsupported-feature reports |
| Static initialization order breaks content | Add deterministic registry load order and tests around `Items`, `Liquids`, `Blocks` |
| Overloads conflict in GDScript | Generate unique names plus dispatchers where required |
| Arc/LibGDX APIs are too broad | Implement only APIs reached by selected milestone source files |
| GPL compliance missed | Copy license and source notice into generated project before distribution |

## Verification Plan

Every phase must produce terminal evidence.

Required checks:

```powershell
git -C mindustry-upstream rev-parse HEAD
godot --headless --path godot-mindustry --quit
python tools/mindustry_godot_transpiler/transpile.py scan
python tools/mindustry_godot_transpiler/transpile.py emit --subset content-core
python tools/mindustry_godot_transpiler/transpile.py report
```

When Godot CLI is not on `PATH`, use the configured MCP Godot path from `C:\Users\Admin\.codex\config.toml`.

## Change Log

| Date | Change |
| --- | --- |
| 2026-06-23 | Created design spec. Cloned upstream. Chose GDScript and automated transpiler pipeline. |
| 2026-06-23 | M1 pipeline created: Godot project, MCP-verified scene, runtime stubs, source scan, full asset bridge, manifests, report. |
| 2026-06-23 | M2 parser started: javalang parser, parse CLI, AST manifest, Java-to-GDScript mapping table. |
| 2026-06-23 | M3 playable slice: generated playable content manifest, attached `PortGame.gd`, MCP run_project starts scene with zero runtime errors. |
| 2026-06-23 | M4 content registry: generated source-derived `Items`, `Liquids`, and declared `Blocks` registry; `PortGame.gd` HUD reads generated registry counts; MCP diagnostics and runtime output show zero errors. |
| 2026-06-23 | M5 content model: added Godot content classes and catalog loader; generated registry now instantiates live item/liquid/block objects; MCP runtime output shows zero errors. |
| 2026-06-23 | M6 block texture registry: generated block registry now resolves copied sprite textures for `416/417` block entries; `air` remains intentionally textureless; MCP runtime output shows zero errors. |
| 2026-06-23 | M7 build placement: generator extracts block category/size/health from `Blocks.java`; playable scene has source-derived block palette, keyboard selection, and mouse placement using copied textures; MCP runtime output shows zero errors. |
| 2026-06-23 | M8 build economy: generator extracts `with(Items.x, n)` requirements for `231` blocks; placement now checks and spends core copper using source-derived build costs; MCP runtime output shows zero errors. |
| 2026-06-23 | M9 unit wave: generator extracts `56` units from `UnitTypes.java` without full-file Java parsing; `MindustryContentCatalog` loads units; `PortGame.gd` spawns source-derived dagger enemies that move toward the core; MCP runtime output shows zero errors. |
| 2026-06-23 | M10 turret bullets: generator extracts turret `reload`, `range`, and first `BasicBulletType` ammo data; `PortGame.gd` pre-places source-derived duo, fires copper bullets at source-derived enemy units, and MCP runtime output shows zero errors. |
| 2026-06-23 | M11 source waves: generator extracts `waveVersion` and `SpawnGroup` unit timing/count fields from `Waves.java`; `PortGame.gd` spawns waves from generated groups with Mindustry-equivalent count formula; MCP runtime output shows zero errors. |
| 2026-06-23 | M12 unsupported report: report generation now scans upstream Java source for unsupported lambdas and anonymous double-brace initializers with exact source path, line number, feature name, and snippet; generated report records `6986` locations. |
| 2026-06-23 | M13 regression fixtures: generated `MindustryContentRegistry.gd` output is compared against a checked expected GDScript fixture; full test suite now has `16` passing tests. |
| 2026-06-23 | M14 class emitter: added `emit` command that generates `612` GDScript class skeletons from parseable Java AST metadata; full test suite has `18` passing tests and Godot MCP LSP diagnostics pass for representative generated classes. |
| 2026-06-23 | M15 parser failure reduction: Java preprocessing now strips callable bodies and handles modern Java syntax blockers; `emit` increases generated class skeletons from `612` to `801` and reduces skipped parser failures from `189` to `0`; full test suite has `22` passing tests and Godot MCP diagnostics pass for newly generated files. |
| 2026-06-23 | M16 generated class registry: `emit` now writes `GeneratedClassRegistry.gd` with `801` source-linked class entries, lookup helpers, and manifest registry metadata; Godot MCP project scan sees `828` scripts and registry diagnostics pass. |
| 2026-06-23 | M17 method stubs: emitted class skeletons now include collision-safe `java_method_*` stubs for parsed Java methods, making method metadata callable from Godot while preserving overload traceability; tests and MCP diagnostics pass. |
| 2026-06-23 | M18 playable registry HUD: playable scene now reads `MindustryGeneratedClassRegistry.count()` and displays generated Java class count in HUD; Python tests, MCP LSP, and MCP runtime launch report no errors. |
| 2026-06-23 | M19 runtime MCP and generated script loading: installed/enabled `godot_mcp_runtime`, verified port `7777` through MCP runtime, loaded selected generated scripts in `PortGame.gd`, and exposed `get_runtime_summary()` for live MCP verification. |
| 2026-06-23 | M20 generated script instances: `PortGame.gd` now instantiates selected generated scripts, reports instance names in HUD/runtime summary, and MCP runtime verifies live instances without errors. |
| 2026-06-23 | M21 MCP placement input: runtime-injected key/mouse events now place source-derived blocks, and runtime summary exposes placement counters for MCP verification. |
| 2026-06-23 | M22 all generated instances: playable scene now loads and instantiates all `801` generated class skeletons, with MCP runtime proving zero load/instance failures. |
| 2026-06-23 | M23 source-wide build palette: playable scene now exposes `416` textured source-derived blocks in the build palette and MCP input verifies palette cycling. |
| 2026-06-23 | M24 build selection by id: MCP runtime can now select and place non-pinned source-derived blocks such as `titanium-conveyor` by content id. |
| 2026-06-23 | M25 source block size rendering: placed/source block sprites now scale and center from source `size`; MCP runtime verifies `solar-panel-large` places with `last_placed_block_size=3`. |
| 2026-06-23 | M26 footprint occupancy: source-sized blocks now occupy all cells in their footprint and MCP runtime verifies overlap/out-of-bounds placement rejection. |
| 2026-06-23 | M27 source world occupancy: starting block layer now uses source content ids and MCP runtime verifies prebuilt conveyor/core cells reject placement. |
| 2026-06-23 | M28 source requirement inventory: placement affordability and spending now use every source-derived requirement item id; MCP runtime verifies `titanium-conveyor` needs copper, lead, and titanium. |
| 2026-06-23 | M29 source core health: playable runtime now initializes core max health from generated `core-shard.health=1100` instead of a handwritten constant. |
| 2026-06-23 | M30 source unit weapon damage: registry now extracts first unit weapon bullet damage and runtime uses dagger damage `9` against the core instead of handwritten `15.0`. |
| 2026-06-23 | M31 source bullet sprite assets: turret bullets now use generated BasicBulletType sprite ids and copied `effects/bullet.png` instead of the item icon. |
| 2026-06-23 | M32 source core item capacity: registry now extracts block `itemCapacity` and runtime clamps core item storage to generated `core-shard.itemCapacity=4000`. |
| 2026-06-23 | M33 source mechanical drill rate: registry now extracts drill `tier/drillTime` and runtime computes copper drill output from source `Drill.getDrillTime(item)` formula instead of hardcoded `0.45`. |
| 2026-06-23 | M34 source conveyor speed: registry now extracts conveyor `speed/displayedSpeed` and item sprite transport uses source `speed * tilesize * 55` instead of sharing drill production progress. |
| 2026-06-23 | M35 source bullet lifetime: turret bullets now use generated `BasicBulletType.lifetime` seconds and expire instead of living until hit/target removal only. |
| 2026-06-23 | M36 source bullet speed: turret bullets now use generated `BasicBulletType.speed` as units/tick converted to world pixels/second with `speed * 60.0`. |
| 2026-06-23 | M37 source unit speed: enemy units now use generated `UnitType.speed` as units/tick converted to world pixels/second with `speed * 60.0`. |
| 2026-06-23 | M38 source unit hit size: enemy unit sprites now scale from generated `UnitType.hitSize` instead of one tile. |
| 2026-06-23 | M39 source turret reload: duo turret cooldown now uses generated `ReloadTurret.reload` frames converted to seconds with `reload / 60.0`. |
| 2026-06-23 | M40 source turret range: duo turret targeting range now flows through generated `BaseTurret.range` data and runtime summary exposes `selected_turret_range=160`. |
| 2026-06-23 | M41 source bullet dimensions: duo copper ammo now carries generated `BasicBulletType.width/height`, and turret bullet sprites scale from `width=7`, `height=9` instead of a tile-size constant. |
| 2026-06-23 | M42 source bullet hit size: turret bullet collision now uses source `BulletType.hitSize` default `4` and generated explicit ammo `hitSize` values instead of hardcoded `6.0`. |
| 2026-06-23 | M43 source bullet damage helper: turret bullets now store damage through `source_bullet_damage()` and runtime summary exposes generated duo ammo damage `9`. |
| 2026-06-23 | M44 source unit health: spawned enemy health now comes from generated `UnitType.health`, with dagger runtime summary reporting `150`. |
| 2026-06-23 | M45 source turret ammo list: duo now carries all source `BasicBulletType` ammo entries for copper, graphite, and silicon, and runtime summary exposes `selected_turret_ammo_count=3`. |
| 2026-06-23 | M46 source bullet ammo multiplier: generated duo ammo now includes source `ammoMultiplier` values `2/4/5`, and runtime summary exposes selected copper ammo multiplier `2`. |
| 2026-06-23 | M47 source item turret ammo storage defaults: generated duo now carries source `maxAmmo=30`, `ammoPerShot=1`, and `consumeAmmoOnce=true`, exposed through MCP runtime summary. |
| 2026-06-23 | M48 source item turret ammo stack logic: runtime now ports `handleItem()`/`useAmmo()` stack behavior for item turrets and verifies load/use through MCP. |
| 2026-06-23 | M49 source-loaded ammo firing: duo turret now consumes loaded ammo through `use_turret_ammo()` before spawning bullets and exposes fired ammo counters for MCP verification. |
| 2026-06-23 | M50 source bullet reload multiplier: generated ammo now includes `reloadMultiplier`, and turret cooldown uses source `reload / 60 / reloadMultiplier` for loaded ammo. |
| 2026-06-23 | M51 source parity and ammo range change: source-parity tests read `Blocks.java` directly to catch fabricated duo values, generated ammo now includes graphite `rangeChange=16`, and runtime targeting uses loaded ammo range `176`. |
