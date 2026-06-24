# Mend Projector Progress Sense Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source `MendProjector.MendBuild.sense(LAccess.progress)` into Godot runtime helpers so MCP can read source-equivalent progress.

**Architecture:** Keep implementation inside `PortGame.gd`, using existing per-cell `mend_projector_charges` and generated block `reload`. Source truth is `mindustry-upstream/core/src/mindustry/world/blocks/defense/MendProjector.java`; progress equals clamped `charge / reload`.

**Tech Stack:** Godot 4 GDScript, Python `unittest`, Godot MCP LSP/runtime.

---

### Task 1: Source-Grounded RED Test

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Read: `mindustry-upstream/core/src/mindustry/world/blocks/defense/MendProjector.java`

- [x] **Step 1: Confirm Java source facts**

Read `MendProjector.java` and verify this exact source behavior:

```java
public double sense(LAccess sensor){
    if(sensor == LAccess.progress) return Mathf.clamp(charge / reload);
    return super.sense(sensor);
}
```

- [x] **Step 2: Write failing test**

Add this test near other MendProjector tests in `PlayableManifestTests`:

```python
def test_port_game_exposes_mend_projector_progress_like_source_sense(self):
    port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
    source = port_game.read_text(encoding="utf-8")

    self.assertIn("func source_mend_projector_progress(mend_projector, charge: float) -> float:", source)
    self.assertIn('var reload := float(mend_projector.properties.get("reload", 0.0))', source)
    self.assertIn("return clamp(charge / reload, 0.0, 1.0)", source)
    self.assertIn("func mend_projector_progress_at_cell(x: int, y: int) -> float:", source)
    self.assertIn("return source_mend_projector_progress(block, mend_projector_charge_at_cell(x, y))", source)
```

- [x] **Step 3: Run test to verify RED**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_exposes_mend_projector_progress_like_source_sense -v
```

Expected: `FAIL` because the progress helpers do not exist.

### Task 2: Minimal Godot Port

**Files:**
- Modify: `godot-mindustry/src/game/PortGame.gd`

- [x] **Step 1: Add source progress helper**

Add near existing MendProjector source helpers:

```gdscript
func source_mend_projector_progress(mend_projector, charge: float) -> float:
    if mend_projector == null:
        return 0.0
    var reload := float(mend_projector.properties.get("reload", 0.0))
    if reload <= 0.0:
        return 0.0
    return clamp(charge / reload, 0.0, 1.0)
```

- [x] **Step 2: Add cell helper**

Add near `mend_projector_charge_at_cell(...)`:

```gdscript
func mend_projector_progress_at_cell(x: int, y: int) -> float:
    var sprite = block_sprite_at_cell(Vector2i(x, y))
    var block = block_from_sprite(sprite)
    if block == null or block.implementation != "MendProjector":
        return 0.0
    return source_mend_projector_progress(block, mend_projector_charge_at_cell(x, y))
```

### Task 3: Verification and Documentation

**Files:**
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- Modify: `docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m68-mend-projector-progress-sense.md`

- [x] **Step 1: Run targeted and full tests**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_exposes_mend_projector_progress_like_source_sense -v
python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v
```

Expected: targeted test passes; full suite passes.

- [x] **Step 2: Run Godot MCP checks**

Run `mcp__godot.lsp_diagnostics` for `src/game/PortGame.gd` and expect `diagnostics: []`.

Start project with `mcp__godot.editor_run`, connect runtime MCP, disable `_process`, build a source-cost `mend-projector`, step `1.0 / 60.0`, call `mend_projector_progress_at_cell(2, 2)`, and verify progress `0.00032` from `charge=0.08` and generated `reload=250`.

- [x] **Step 3: Update checklist/spec**

Update totals from `70/70/0` to `71/71/0`. Add `N69` row and `M68` changelog entry for source `MendProjector.sense(LAccess.progress)`.

- [x] **Step 4: Fresh final verification**

Run:

```powershell
python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v
git diff --check
```

Expected: tests pass; diff check exits `0`.

- [x] **Step 5: Commit explicit files only**

Stage only:

```powershell
git add docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m68-mend-projector-progress-sense.md docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md godot-mindustry/src/game/PortGame.gd tools/mindustry_godot_transpiler/tests/test_playable.py
```

Commit:

```powershell
git commit -m "feat: expose mend projector progress"
```
