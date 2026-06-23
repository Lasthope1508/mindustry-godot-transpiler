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
| Total tracked work items | 14 |
| Done | 11 |
| Not done | 3 |
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
| N7 | Create compatibility runtime | Runtime stubs exist for `Seq`, `ObjectMap`, `Time`, `Mathf`, `ColorCompat`, `Vec2`, `Vars`, `Events`, `Core`; MCP project scan sees scripts |
| N8 | Port base content model | `MindustryContent`, `MindustryUnlockableContent`, `MindustryItem`, `MindustryLiquid`, `MindustryBlock`, and `MindustryContentCatalog` load generated registry objects; MCP runtime starts scene with `errors=[]` |
| N9 | Generate first content data | `content` command writes `content_registry.json` and `MindustryContentRegistry.gd`; MCP LSP diagnostics pass for generated registry; registry includes `22` items, `11` liquids, `417` source-declared block constructors |
| N10 | Build asset bridge | Full run writes `asset_manifest.json`, copies `2970` upstream assets, `mcp__godot.project_info` sees Godot asset structure |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| N6 | Emit GDScript classes | Generated `.gd` files pass Godot parse check |
| N11 | Add reports for unsupported Java features | Report lists unsupported syntax with exact source path and line number |
| N12 | Add regression fixtures | Fixtures compare generated output against checked expected `.gd` files |
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
