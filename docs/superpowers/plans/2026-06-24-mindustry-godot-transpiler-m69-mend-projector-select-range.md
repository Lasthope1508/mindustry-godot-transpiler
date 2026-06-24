# MendProjector Select Range Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source-backed `MendProjector.drawSelect()` and `drawPlace()` range/color state into Godot runtime helpers.

**Architecture:** Keep renderer work incremental: expose exact source state first, so later visual drawing can consume verified data. Use generated `mend-projector` properties and per-cell `phaseHeat`; do not hardcode values outside source-derived registry data.

**Tech Stack:** GDScript runtime in `godot-mindustry/src/game/PortGame.gd`, Python `unittest`, Godot MCP LSP/runtime proof on port `7777`.

---

### Task 1: Source Select/Place State

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write the failing test**

Add this test to `PlayableManifestTests` after `test_port_game_exposes_mend_projector_progress_like_source_sense`:

```python
    def test_port_game_exposes_mend_projector_select_range_like_source_draw_select(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_mend_projector_select_state(mend_projector, phase_heat := 0.0) -> Dictionary:", source)
        self.assertIn('"range": source_mend_projector_range(mend_projector, phase_heat)', source)
        self.assertIn('"color": str(mend_projector.properties.get("baseColor", ""))', source)
        self.assertIn("func source_mend_projector_place_state(mend_projector) -> Dictionary:", source)
        self.assertIn('return source_mend_projector_select_state(mend_projector, 0.0)', source)
        self.assertIn("func mend_projector_select_state_at_cell(x: int, y: int) -> Dictionary:", source)
        self.assertIn("return source_mend_projector_select_state(block, mend_projector_phase_heat_at_cell(x, y))", source)
        self.assertIn("func selected_build_place_state() -> Dictionary:", source)
        self.assertIn("return source_mend_projector_place_state(selected)", source)
        self.assertIn('"selected_build_place_state": selected_build_place_state()', source)
```

- [x] **Step 2: Run test to verify RED**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_exposes_mend_projector_select_range_like_source_draw_select
```

Expected: FAIL because `source_mend_projector_select_state` does not exist.

- [x] **Step 3: Implement minimal GDScript helpers**

Add helpers near existing `MendProjector` helper functions in `PortGame.gd`:

```gdscript
func source_mend_projector_select_state(mend_projector, phase_heat := 0.0) -> Dictionary:
	if mend_projector == null:
		return {"range": 0.0, "color": ""}
	return {
		"range": source_mend_projector_range(mend_projector, phase_heat),
		"color": str(mend_projector.properties.get("baseColor", "")),
	}

func source_mend_projector_place_state(mend_projector) -> Dictionary:
	return source_mend_projector_select_state(mend_projector, 0.0)

func mend_projector_select_state_at_cell(x: int, y: int) -> Dictionary:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if block == null or block.implementation != "MendProjector":
		return {"range": 0.0, "color": ""}
	return source_mend_projector_select_state(block, mend_projector_phase_heat_at_cell(x, y))

func selected_build_place_state() -> Dictionary:
	if build_palette.is_empty():
		return {"range": 0.0, "color": ""}
	var selected = build_palette[selected_build_index]
	if selected.implementation != "MendProjector":
		return {"range": 0.0, "color": ""}
	return source_mend_projector_place_state(selected)
```

Add `"selected_build_place_state": selected_build_place_state(),` to `get_runtime_summary()`.

- [x] **Step 4: Run targeted and full tests**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_exposes_mend_projector_select_range_like_source_draw_select
python -m unittest discover -s tools/mindustry_godot_transpiler/tests
```

Expected: targeted PASS; full suite increments from `80` to `81` tests and reports `OK`.

- [x] **Step 5: Verify with Godot MCP**

Run MCP LSP diagnostics on `src/game/PortGame.gd`. Then run project and use runtime MCP calls: disable process, select `mend-projector`, read `get_runtime_summary().selected_build_place_state`, place and boost projector, step one source tick, then call `mend_projector_select_state_at_cell(2, 2)`. Expected base place state `range=85`, `color="84f491"` from `Blocks.java`; after phaseHeat `0.1`, select state `range=90`, `color="84f491"`; debug output has `errors: []`.

- [ ] **Step 6: Update checklist and commit**

Update spec summary totals from `71/71/0` to `72/72/0`, change checklist from `N49-N69` to `N49-N70`, add row `N70`, and add changelog entry `M69 source MendProjector select/place range state`. Run `git diff --check`, stage only this plan, spec, test, and `PortGame.gd`, then commit:

```powershell
git add docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m69-mend-projector-select-range.md docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md godot-mindustry/src/game/PortGame.gd tools/mindustry_godot_transpiler/tests/test_playable.py
git commit -m "feat: expose mend projector select range"
```
