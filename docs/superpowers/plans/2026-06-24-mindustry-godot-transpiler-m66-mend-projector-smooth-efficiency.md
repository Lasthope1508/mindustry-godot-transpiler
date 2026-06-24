# Mend Projector Smooth Efficiency Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port Mindustry `MendProjector.MendBuild.smoothEfficiency` from Java to Godot/GDScript so runtime state follows source `Mathf.lerpDelta` behavior.

**Architecture:** Keep the migration narrow inside existing `PortGame.gd` mend projector simulation. Source truth is `mindustry-upstream/core/src/mindustry/world/blocks/defense/MendProjector.java`; Godot uses existing `source_lerp_delta(...)` and `SOURCE_TICK_RATE` mapping.

**Tech Stack:** Godot 4 GDScript, Python `unittest`, Godot MCP LSP/runtime, local Mindustry Java source.

---

### Task 1: Source-Grounded Test

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Read: `mindustry-upstream/core/src/mindustry/world/blocks/defense/MendProjector.java`

- [x] **Step 1: Confirm Java source facts**

Read `MendProjector.java` and verify these exact facts:

```java
public float heat, charge = Mathf.random(reload), phaseHeat, smoothEfficiency;
smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);
heat = Mathf.lerpDelta(heat, efficiency > 0 && canHeal ? 1f : 0f, 0.08f);
Drawf.light(x, y, lightRadius * smoothEfficiency, baseColor, 0.7f * smoothEfficiency);
```

- [x] **Step 2: Write failing test**

Add this test to `PlayableManifestTests` near other mend projector tests:

```python
def test_port_game_lerps_mend_projector_smooth_efficiency_like_source(self):
    source = self.port_game.read_text(encoding="utf-8")
    self.assertIn("var mend_projector_smooth_efficiency: Dictionary = {}", source)
    self.assertIn("func mend_projector_smooth_efficiency_at_cell(x: int, y: int) -> float:", source)
    self.assertIn("mend_projector_smooth_efficiency[key] = source_lerp_delta(float(mend_projector_smooth_efficiency.get(key, 0.0)), 1.0, 0.08, source_delta)", source)
    self.assertLess(
        source.index("mend_projector_smooth_efficiency[key] = source_lerp_delta"),
        source.index("mend_projector_heat[key] = source_lerp_delta"),
    )
```

- [x] **Step 3: Run test to verify RED**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_lerps_mend_projector_smooth_efficiency_like_source -v
```

Expected: `FAIL` because `mend_projector_smooth_efficiency` does not exist yet.

### Task 2: Minimal Godot Port

**Files:**
- Modify: `godot-mindustry/src/game/PortGame.gd`

- [x] **Step 1: Add state dictionary**

Add beside existing mend projector dictionaries:

```gdscript
var mend_projector_smooth_efficiency: Dictionary = {}
```

- [x] **Step 2: Add runtime helper**

Add near `mend_projector_heat_at_cell(...)`:

```gdscript
func mend_projector_smooth_efficiency_at_cell(x: int, y: int) -> float:
    var sprite = block_sprite_at_cell(Vector2i(x, y))
    if not is_instance_valid(sprite):
        return 0.0
    var origin_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
    return float(mend_projector_smooth_efficiency.get(cell_key(origin_cell), 0.0))
```

- [x] **Step 3: Update simulation order**

Inside `simulate_mend_projectors(delta)`, update smooth efficiency before heat:

```gdscript
mend_projector_smooth_efficiency[key] = source_lerp_delta(float(mend_projector_smooth_efficiency.get(key, 0.0)), 1.0, 0.08, source_delta)
mend_projector_heat[key] = source_lerp_delta(float(mend_projector_heat.get(key, 0.0)), 1.0, 0.08, source_delta)
```

### Task 3: Verification and Documentation

**Files:**
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- Modify: `docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m66-mend-projector-smooth-efficiency.md`

- [x] **Step 1: Run targeted and full tests**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_lerps_mend_projector_smooth_efficiency_like_source -v
python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v
```

Expected: targeted passes; full suite passes.

- [x] **Step 2: Run Godot MCP checks**

Run `mcp__godot.lsp_diagnostics` for `src/game/PortGame.gd` and expect `diagnostics: []`.

Start project with `mcp__godot.editor_run`, connect runtime MCP, disable `_process`, build a source-cost `mend-projector`, step `1.0 / 60.0`, and verify smooth efficiency changes from `0.0` to `0.08`.

- [x] **Step 3: Update checklist/spec**

Update totals from `68/68/0` to `69/69/0`. Add M66/N67 row for MendProjector `smoothEfficiency` port.

- [x] **Step 4: Fresh final verification**

Run:

```powershell
python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v
git diff --check
```

Expected: tests pass; diff check has no output.

- [x] **Step 5: Commit explicit files only**

Stage only:

```powershell
git add docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m66-mend-projector-smooth-efficiency.md docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md godot-mindustry/src/game/PortGame.gd tools/mindustry_godot_transpiler/tests/test_playable.py
```

Commit:

```powershell
git commit -m "feat: smooth mend projector efficiency"
```
