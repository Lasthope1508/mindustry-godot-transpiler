# MendProjector Draw State Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source-backed `MendProjector.draw()` state calculations into Godot runtime helpers.

**Architecture:** Keep visual migration deterministic by exposing draw state first: source time, LOD gate, heat/phaseHeat, top alpha, square stroke, and square radius. Actual drawn effects can later consume these verified values without inventing numbers.

**Tech Stack:** GDScript runtime in `godot-mindustry/src/game/PortGame.gd`, Python `unittest`, Godot MCP LSP/runtime proof on port `7777`.

---

### Task 1: Source Draw State

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write the failing test**

Add this test to `PlayableManifestTests` after `test_port_game_exposes_mend_projector_select_range_like_source_draw_select`:

```python
    def test_port_game_exposes_mend_projector_draw_state_like_source_draw(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("const SOURCE_PI2 := PI * 2.0", source)
        self.assertIn("func source_absin(value: float, scl: float, mag: float) -> float:", source)
        self.assertIn("return (sin(value / scl) * mag + mag) / 2.0", source)
        self.assertIn("func source_mend_projector_draw_state(mend_projector, heat: float, phase_heat: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:", source)
        self.assertIn("var f := 1.0 - fmod(source_time_ticks / 100.0, 1.0)", source)
        self.assertIn("if mend_projector == null or not lod_l2:", source)
        self.assertIn('"visible": false', source)
        self.assertIn('"top_alpha": heat * source_absin(source_time_ticks, 50.0 / SOURCE_PI2, 1.0) * 0.5 * lod_alpha2', source)
        self.assertIn('"square_alpha": lod_alpha2', source)
        self.assertIn('"square_stroke": (2.0 * f + 0.2) * heat', source)
        self.assertIn('"square_radius": min(1.0 + (1.0 - f) * float(block_size(mend_projector)) * float(tile_size) / 2.0, float(block_size(mend_projector)) * float(tile_size) / 2.0)', source)
        self.assertIn("func mend_projector_draw_state_at_cell(x: int, y: int, source_time_ticks := 0.0) -> Dictionary:", source)
        self.assertIn("return source_mend_projector_draw_state(block, mend_projector_heat_at_cell(x, y), mend_projector_phase_heat_at_cell(x, y), source_time_ticks)", source)
```

- [x] **Step 2: Run test to verify RED**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_exposes_mend_projector_draw_state_like_source_draw
```

Expected: FAIL because `source_mend_projector_draw_state` does not exist.

- [x] **Step 3: Implement minimal GDScript helpers**

Add `const SOURCE_PI2 := PI * 2.0` near other source constants in `PortGame.gd`.

Add helper near source math helpers:

```gdscript
func source_absin(value: float, scl: float, mag: float) -> float:
	if scl == 0.0:
		return 0.0
	return (sin(value / scl) * mag + mag) / 2.0
```

Add draw-state helpers near other `MendProjector` helpers:

```gdscript
func source_mend_projector_draw_state(mend_projector, heat: float, phase_heat: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:
	var f := 1.0 - fmod(source_time_ticks / 100.0, 1.0)
	if mend_projector == null or not lod_l2:
		return {"visible": false, "f": f, "base_color": "", "phase_color": "", "phase_heat": phase_heat, "top_alpha": 0.0, "square_alpha": 0.0, "square_stroke": 0.0, "square_radius": 0.0}
	return {
		"visible": true,
		"f": f,
		"base_color": str(mend_projector.properties.get("baseColor", "")),
		"phase_color": str(mend_projector.properties.get("phaseColor", mend_projector.properties.get("baseColor", ""))),
		"phase_heat": phase_heat,
		"top_alpha": heat * source_absin(source_time_ticks, 50.0 / SOURCE_PI2, 1.0) * 0.5 * lod_alpha2,
		"square_alpha": lod_alpha2,
		"square_stroke": (2.0 * f + 0.2) * heat,
		"square_radius": min(1.0 + (1.0 - f) * float(block_size(mend_projector)) * float(tile_size) / 2.0, float(block_size(mend_projector)) * float(tile_size) / 2.0),
	}

func mend_projector_draw_state_at_cell(x: int, y: int, source_time_ticks := 0.0) -> Dictionary:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if block == null or block.implementation != "MendProjector":
		return source_mend_projector_draw_state(null, 0.0, 0.0, source_time_ticks, false, 0.0)
	return source_mend_projector_draw_state(block, mend_projector_heat_at_cell(x, y), mend_projector_phase_heat_at_cell(x, y), source_time_ticks)
```

- [x] **Step 4: Run targeted and full tests**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_exposes_mend_projector_draw_state_like_source_draw
python -m unittest discover -s tools/mindustry_godot_transpiler/tests
```

Expected: targeted PASS; full suite increments from `81` to `82` tests and reports `OK`.

- [x] **Step 5: Verify with Godot MCP**

Run MCP LSP diagnostics on `src/game/PortGame.gd`. Then run project and use runtime MCP calls: disable process, select `mend-projector`, add source costs, place at `(2,2)`, step one `1/60s` source tick, then call `mend_projector_draw_state_at_cell(2, 2, 0.0)`. Expected state: `visible=true`, `f=1`, `top_alpha=0.02`, `square_alpha=1`, `square_stroke=0.176`, `square_radius=1`, `base_color="84f491"`, `phase_color="84f491"`, and debug output has `errors: []`.

- [ ] **Step 6: Update checklist and commit**

Update spec summary totals from `72/72/0` to `73/73/0`, change checklist from `N49-N70` to `N49-N71`, add row `N71`, and add changelog entry `M70 source MendProjector draw state`. Run `git diff --check`, stage only this plan, spec, test, and `PortGame.gd`, then commit:

```powershell
git add docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m70-mend-projector-draw-state.md docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md godot-mindustry/src/game/PortGame.gd tools/mindustry_godot_transpiler/tests/test_playable.py
git commit -m "feat: expose mend projector draw state"
```
