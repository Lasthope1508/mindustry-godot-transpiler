# M20 Generated Script Instances Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move selected generated Mindustry class scripts from loaded resources to live instantiated GDScript objects that can be inspected through Godot MCP runtime.

**Architecture:** Keep generated files read-only. `PortGame.gd` remains the integration layer: after loading selected scripts from `GeneratedClassRegistry.gd`, it calls `script.new()` safely, stores created instances by Java class name, records failures without crashing, and reports instance names through `get_runtime_summary()`. Python tests assert the integration contract, then Godot MCP LSP/runtime checks prove the running scene accepts it.

**Tech Stack:** GDScript, Python unittest, Godot 4.6.2 MCP editor/runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M20 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M20-1 | Add failing regression test for generated script instances | Targeted unittest failed because `PortGame.gd` did not define `loaded_generated_instances` yet |
| M20-2 | Implement safe generated script instantiation | `PortGame.gd` now stores instances in `loaded_generated_instances` and names in `loaded_generated_instance_names`; targeted unittest passes |
| M20-3 | Expose instance data in HUD and runtime summary | `PortGame.gd` HUD includes `Instanced generated scripts: %d (%s)` and `get_runtime_summary()` returns `loaded_generated_instance_names`; targeted unittest passes; MCP LSP diagnostics return `diagnostics: []` |
| M20-4 | Verify full Python test suite | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` reports `Ran 27 tests ... OK` |
| M20-5 | Verify Godot MCP LSP/runtime | MCP LSP diagnostics for `src/game/PortGame.gd` return `diagnostics: []`; MCP runtime status returns `connected=true` and `runtimeAddon=connected`; runtime `get_runtime_summary()` returns `loaded_generated_instance_names=[Items, Blocks, UnitTypes, Damage]`; MCP debug output returns `errors: []` |
| M20-6 | Update main ledger and commit | Design spec now includes N21 for generated script instantiation; this plan records all M20 tasks done; checkpoint is committed with message `feat: instantiate generated scripts` |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M20 task | N/A |

## Execution Steps

### Task 1: Regression Test

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`

- [ ] **Step 1: Write the failing test**

Add assertions that `PortGame.gd` defines `loaded_generated_instances`, appends successful instance names, exposes them through `get_runtime_summary()`, and displays them in the HUD.

- [ ] **Step 2: Verify red**

Run: `python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_instantiates_selected_generated_scripts -v`

Expected: FAIL because instance fields and summary output do not exist yet.

### Task 2: Runtime Integration

**Files:**
- Modify: `godot-mindustry/src/game/PortGame.gd`

- [ ] **Step 1: Add instance storage**

Add:

```gdscript
var loaded_generated_instances: Dictionary = {}
var loaded_generated_instance_names: Array[String] = []
```

- [ ] **Step 2: Instantiate selected scripts after load**

Inside `load_selected_generated_scripts()`, clear the new dictionaries and call `script.new()` for every loaded script. Store the instance only when creation succeeds.

- [ ] **Step 3: Report instances**

Add `loaded_generated_instance_names` to `get_runtime_summary()` and HUD text.

### Task 3: Verification

**Files:**
- Test: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Test: `godot-mindustry/src/game/PortGame.gd`

- [ ] **Step 1: Verify targeted green**

Run: `python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_instantiates_selected_generated_scripts -v`

Expected: OK.

- [ ] **Step 2: Verify full suite**

Run: `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v`

Expected: all tests OK.

- [ ] **Step 3: Verify Godot MCP**

Use MCP to restart `scenes/Main.tscn`, run LSP diagnostics for `src/game/PortGame.gd`, check runtime status, call `/root/Main.get_runtime_summary()`, and check debug output for no errors.

### Task 4: Documentation and Commit

**Files:**
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- Modify: `docs/superpowers/plans/2026-06-23-mindustry-godot-transpiler-m20-generated-script-instances.md`

- [ ] **Step 1: Update M20 plan counts**

Set Done to `6`, Not done to `0`, move M20 items into Done with verification evidence.

- [ ] **Step 2: Update main ledger**

Increment tracked work items by one and add `N21` for generated script instantiation.

- [ ] **Step 3: Commit**

Run:

```powershell
git add docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md docs/superpowers/plans/2026-06-23-mindustry-godot-transpiler-m20-generated-script-instances.md godot-mindustry/src/game/PortGame.gd tools/mindustry_godot_transpiler/tests/test_playable.py
git commit -m "feat: instantiate generated scripts"
```
