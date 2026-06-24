# CanOverdrive Metadata Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract source `Block.canOverdrive` metadata into generated Godot content and expose it at runtime.

**Architecture:** Parse `Block.java` for default `canOverdrive=true`, scan `world/blocks/**/*.java` class constructors for explicit `canOverdrive = false/true`, then apply those implementation defaults while still allowing block initializer overrides. Runtime reads generated `properties.canOverdrive` instead of assuming all blocks can be boosted.

**Tech Stack:** Python content registry generator/tests, generated JSON/GDScript registry, GDScript runtime in `PortGame.gd`, Godot MCP LSP/runtime proof.

---

### Task 1: Source CanOverdrive Metadata

**Files:**
- Modify: `tools/mindustry_godot_transpiler/mindustry_port/content_registry.py`
- Modify: `tools/mindustry_godot_transpiler/mindustry_port/source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_content_registry.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/generated/content_registry.json`
- Modify: `godot-mindustry/src/generated/MindustryContentRegistry.gd`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write failing tests**

Add tests requiring generator extraction, source parity for `overdrive-projector`, and runtime summary `selected_build_can_overdrive`.

- [x] **Step 2: Run RED tests**

Run targeted tests. Expected: FAIL because `canOverdrive` extraction/runtime keys do not exist.

- [x] **Step 3: Implement generator and runtime**

Implement source scan:

```python
def _can_overdrive_defaults(upstream_root: Path) -> dict[str, bool]:
    defaults = {"Block": True}
    for source_path in (upstream_root / "core" / "src" / "mindustry" / "world" / "blocks").rglob("*.java"):
        source = source_path.read_text(encoding="utf-8", errors="replace")
        class_match = re.search(r"class\s+([A-Za-z_]\w*)", source)
        assignment = _boolean_assignment(source, "canOverdrive")
        if class_match and assignment is not None:
            defaults[class_match.group(1)] = assignment
    return defaults
```

Apply default from implementation, then initializer override if present. Add `selected_build_can_overdrive()` to `PortGame.gd` and include it in runtime summary.

- [x] **Step 4: Regenerate content**

Run content generation so `content_registry.json` and `MindustryContentRegistry.gd` carry `canOverdrive`.

- [x] **Step 5: Run tests**

Run targeted tests, then full suite. Expected: full suite reports `92` tests passing.

- [x] **Step 6: Verify with Godot MCP**

Run MCP LSP diagnostics on `MindustryContentRegistry.gd` and `PortGame.gd`. Run project, select `overdrive-projector` and verify `selected_build_can_overdrive=false`; select `conveyor` and verify `selected_build_can_overdrive=true`; debug `errors: []`, stop `finalErrors: []`.

- [x] **Step 7: Update checklist and commit**

Update spec totals from `81/81/0` to include this item, add row/changelog, run `git diff --check`, stage only related files, and commit `feat: extract can overdrive metadata`.
