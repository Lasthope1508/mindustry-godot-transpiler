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
| Total tracked work items | 29 |
| Done | 29 |
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
