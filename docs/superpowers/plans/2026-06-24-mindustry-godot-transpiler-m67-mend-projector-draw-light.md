# Mend Projector Draw Light Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source-backed `MendProjector.drawLight()` data and runtime light-state math into Godot/GDScript.

**Architecture:** Extract `emitLight`, `lightRadius`, and `baseColor` from the Java source instead of hardcoding runtime values. Keep actual runtime proof deterministic by exposing a `mend_projector_light_state_at_cell()` helper that computes the same radius/alpha/color values that source `Drawf.light(...)` uses from `smoothEfficiency`.

**Tech Stack:** Python content registry/parity tests, generated Godot content JSON/GDScript, Godot 4 GDScript, Godot MCP LSP/runtime.

---

### Task 1: Source-Grounded RED Tests

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_content_registry.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Read: `mindustry-upstream/core/src/mindustry/world/blocks/defense/MendProjector.java`

- [x] **Step 1: Confirm source light facts**

Read `MendProjector.java` and verify these exact facts:

```java
public Color baseColor = Color.valueOf("84f491");
emitLight = true;
lightRadius = 50f;
Drawf.light(x, y, lightRadius * smoothEfficiency, baseColor, 0.7f * smoothEfficiency);
```

- [x] **Step 2: Add content registry RED assertions**

Add these assertions to the existing MendProjector fixture test in `test_content_registry.py`:

```python
self.assertEqual(registry["blocks"][0]["properties"].get("baseColor"), "84f491")
self.assertEqual(registry["blocks"][0]["properties"].get("emitLight"), True)
self.assertEqual(registry["blocks"][0]["properties"].get("lightRadius"), 50.0)
```

Also add these lines to the test fixture Java block body:

```java
baseColor = Color.valueOf("84f491");
emitLight = true;
lightRadius = 50f;
```

- [x] **Step 3: Add source parity RED test**

Add a new test in `test_source_parity.py`:

```python
def test_generated_mend_projector_light_matches_upstream_source(self):
    self.assertTrue(hasattr(source_parity, "verify_mend_projector_light_parity"))
    report = source_parity.verify_mend_projector_light_parity(ROOT / "mindustry-upstream", ROOT / "godot-mindustry")

    self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/MendProjector.java")
    self.assertEqual(report["block"], "mend-projector")
    self.assertEqual(report["mismatches"], [])
    self.assertEqual(report["checked"], {"baseColor": "84f491", "emitLight": True, "lightRadius": 50.0})
```

- [x] **Step 4: Add playable RED test**

Add a new test in `test_playable.py` near other MendProjector tests:

```python
def test_port_game_computes_mend_projector_light_state_like_source(self):
    port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
    source = port_game.read_text(encoding="utf-8")

    self.assertIn("func source_mend_projector_light_state(mend_projector, smooth_efficiency: float) -> Dictionary:", source)
    self.assertIn('"color": str(mend_projector.properties.get("baseColor", ""))', source)
    self.assertIn('"radius": float(mend_projector.properties.get("lightRadius", 0.0)) * smooth_efficiency', source)
    self.assertIn('"alpha": 0.7 * smooth_efficiency', source)
    self.assertIn("func mend_projector_light_state_at_cell(x: int, y: int) -> Dictionary:", source)
    self.assertIn("return source_mend_projector_light_state(block, mend_projector_smooth_efficiency_at_cell(x, y))", source)
```

- [x] **Step 5: Run RED tests**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_content_registry.ContentRegistryTests.test_build_registry_computes_block_health_from_scaled_health -v
python -m unittest tools.mindustry_godot_transpiler.tests.test_source_parity.SourceParityTests.test_generated_mend_projector_light_matches_upstream_source -v
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_computes_mend_projector_light_state_like_source -v
```

Expected: all fail because `baseColor`/`emitLight`/`lightRadius`, parity helper, and runtime helper do not exist yet.

### Task 2: Minimal Registry and Runtime Implementation

**Files:**
- Modify: `tools/mindustry_godot_transpiler/mindustry_port/content_registry.py`
- Modify: `tools/mindustry_godot_transpiler/mindustry_port/source_parity.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`

- [x] **Step 1: Extract light fields**

In `_block_properties(...)`, include `lightRadius` in numeric extraction, include `emitLight` through `_boolean_assignment(...)`, and include `baseColor` through a new color-value helper.

```python
color = _color_value_assignment(initializer, "baseColor")
if color is not None:
    properties["baseColor"] = color
emit_light = _boolean_assignment(initializer, "emitLight")
if emit_light is not None:
    properties["emitLight"] = emit_light
```

Helper:

```python
def _color_value_assignment(source: str, key: str) -> str | None:
    match = re.search(rf"\b{key}\s*=\s*Color\.valueOf\(\s*\"([0-9A-Fa-f]+)\"\s*\)\s*;", source)
    return match.group(1).lower() if match else None
```

- [x] **Step 2: Add MendProjector light defaults/parity**

In `source_parity.py`, add `verify_mend_projector_light_parity(...)` that reads `MendProjector.java` for defaults and compares generated `mend-projector` properties. Expected checked dict:

```python
{"baseColor": "84f491", "emitLight": True, "lightRadius": 50.0}
```

- [x] **Step 3: Add runtime light helpers**

Add to `PortGame.gd` near MendProjector helpers:

```gdscript
func source_mend_projector_light_state(mend_projector, smooth_efficiency: float) -> Dictionary:
    if mend_projector == null or not bool(mend_projector.properties.get("emitLight", false)):
        return {"color": "", "radius": 0.0, "alpha": 0.0}
    return {
        "color": str(mend_projector.properties.get("baseColor", "")),
        "radius": float(mend_projector.properties.get("lightRadius", 0.0)) * smooth_efficiency,
        "alpha": 0.7 * smooth_efficiency,
    }

func mend_projector_light_state_at_cell(x: int, y: int) -> Dictionary:
    var sprite = block_sprite_at_cell(Vector2i(x, y))
    var block = block_from_sprite(sprite)
    if block == null or block.implementation != "MendProjector":
        return {"color": "", "radius": 0.0, "alpha": 0.0}
    return source_mend_projector_light_state(block, mend_projector_smooth_efficiency_at_cell(x, y))
```

### Task 3: Regenerate, Verify, Document, Commit

**Files:**
- Regenerate: `godot-mindustry/src/generated/content_registry.json`
- Regenerate: `godot-mindustry/src/generated/MindustryContentRegistry.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- Modify: `docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m67-mend-projector-draw-light.md`

- [x] **Step 1: Regenerate content**

Run the existing content generation command used by this repo so generated registry carries the new fields:

```powershell
python -m mindustry_godot_transpiler.cli content --upstream mindustry-upstream --godot godot-mindustry
```

- [x] **Step 2: Run targeted and full tests**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_content_registry.ContentRegistryTests.test_build_registry_computes_block_health_from_scaled_health -v
python -m unittest tools.mindustry_godot_transpiler.tests.test_source_parity.SourceParityTests.test_generated_mend_projector_light_matches_upstream_source -v
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_computes_mend_projector_light_state_like_source -v
python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v
```

Expected: targeted tests pass; full suite passes.

- [x] **Step 3: Run Godot MCP checks**

Run `mcp__godot.lsp_diagnostics` for `src/game/PortGame.gd` and expect `diagnostics: []`.

Start project with `mcp__godot.editor_run`, connect runtime MCP, disable `_process`, build a source-cost `mend-projector`, step `1.0 / 60.0`, call `mend_projector_light_state_at_cell(2, 2)`, and verify `{color:"84f491", radius:4.0, alpha:0.056}`.

- [x] **Step 4: Update checklist/spec**

Update totals from `69/69/0` to `70/70/0`. Add `N68` row and `M67` changelog entry for source `MendProjector.drawLight()` state.

- [x] **Step 5: Fresh final verification**

Run:

```powershell
python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v
git diff --check
```

Expected: tests pass; diff check exits `0`.

- [x] **Step 6: Commit explicit files only**

Stage only changed source/docs/generated registry/test files, no `.uid` files. Commit:

```powershell
git commit -m "feat: port mend projector light state"
```
