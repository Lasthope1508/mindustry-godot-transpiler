# Mindustry Godot M65 Mend Projector Heat Charge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source-backed `MendProjector` heat warmup so repair charge advances by warmup heat instead of full source delta from frame one.

**Architecture:** Keep existing `PortGame.gd` MendProjector simulation, add per-cell `mend_projector_heat` state, and update it with the already-ported `source_lerp_delta()` helper using source progress `0.08`. Charge then advances by `heat * source_delta`, matching Java `charge += heat * delta()` with `delta()` represented by source ticks.

**Tech Stack:** Godot 4.6 GDScript, Python unittest source-structure tests, Godot MCP LSP/runtime verification.

---

## Source Facts

- `mindustry-upstream/core/src/mindustry/world/blocks/defense/MendProjector.java` declares `public float heat, charge = Mathf.random(reload), phaseHeat, smoothEfficiency;`.
- `MendProjector.updateTile()` computes `boolean canHeal = !checkSuppression()`.
- `MendProjector.updateTile()` updates `heat = Mathf.lerpDelta(heat, efficiency > 0 && canHeal ? 1f : 0f, 0.08f)`.
- `MendProjector.updateTile()` advances `charge += heat * delta()`.
- `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java` defines `delta()` as `Time.delta * timeScale`.
- The existing Godot port represents source `Time.delta` as `source_delta = delta * SOURCE_TICK_RATE`.

## Files

- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

## Task 1: RED Test For Heat-Based Charge

- [x] **Step 1: Add failing test**

Add this test near existing MendProjector tests in `tools/mindustry_godot_transpiler/tests/test_playable.py`:

```python
    def test_port_game_advances_mend_projector_charge_with_source_heat(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var mend_projector_heat: Dictionary = {}", source)
        self.assertIn("mend_projector_heat[key] = source_lerp_delta(float(mend_projector_heat.get(key, 0.0)), 1.0, 0.08, source_delta)", source)
        self.assertIn("mend_projector_charges[key] = float(mend_projector_charges.get(key, 0.0)) + float(mend_projector_heat.get(key, 0.0)) * source_delta", source)
        self.assertNotIn("mend_projector_charges[key] = float(mend_projector_charges.get(key, 0.0)) + source_delta", source)
        self.assertIn("func mend_projector_heat_at_cell(x: int, y: int) -> float:", source)
        self.assertIn("func mend_projector_charge_at_cell(x: int, y: int) -> float:", source)
        self.assertLess(
            source.index("mend_projector_heat[key] = source_lerp_delta"),
            source.index("mend_projector_charges[key] = float(mend_projector_charges.get(key, 0.0)) + float(mend_projector_heat.get(key, 0.0)) * source_delta"),
        )
```

- [x] **Step 2: Verify RED**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_advances_mend_projector_charge_with_source_heat -v
```

Expected: FAIL because `mend_projector_heat` and heat-based charge do not exist.

## Task 2: GREEN Implementation

- [x] **Step 1: Add per-cell heat state**

In `godot-mindustry/src/game/PortGame.gd`, near existing MendProjector dictionaries, add:

```gdscript
var mend_projector_heat: Dictionary = {}
```

- [x] **Step 2: Expose heat and charge for MCP proof**

Add helpers after `mend_projector_phase_heat_at_cell()`:

```gdscript
func mend_projector_heat_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	var origin_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
	return float(mend_projector_heat.get(cell_key(origin_cell), 0.0))

func mend_projector_charge_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	var origin_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
	return float(mend_projector_charges.get(cell_key(origin_cell), 0.0))
```

- [x] **Step 3: Update heat before charge**

In `simulate_mend_projectors(delta)`, after confirming `block.implementation == "MendProjector"`, add heat update before charge, and replace full-delta charge:

```gdscript
mend_projector_heat[key] = source_lerp_delta(float(mend_projector_heat.get(key, 0.0)), 1.0, 0.08, source_delta)
```

Replace:

```gdscript
mend_projector_charges[key] = float(mend_projector_charges.get(key, 0.0)) + source_delta
```

With:

```gdscript
mend_projector_charges[key] = float(mend_projector_charges.get(key, 0.0)) + float(mend_projector_heat.get(key, 0.0)) * source_delta
```

- [x] **Step 4: Verify GREEN targeted**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_advances_mend_projector_charge_with_source_heat tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_simulates_source_mend_projector_heal_cycle -v
```

Expected: OK.

## Task 3: Verification And Docs

- [x] **Step 1: Run full tests**

```powershell
python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v
```

Expected: all tests OK.

- [x] **Step 2: Run Godot MCP checks**

Use `mcp__godot.lsp_diagnostics` on `src/game/PortGame.gd`; expected `diagnostics: []`.

Use `mcp__godot.editor_run`, `mcp__godot.runtime_status`, and runtime addon calls to prove: placed `mend-projector` with `_process` disabled reports heat `0.0` and charge `0.0`, after one `1/60s` source tick reports heat `0.08` and charge `0.08`, with debug `errors: []`.

- [x] **Step 3: Update migration spec checklist**

In `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`, change totals to `68/68/0`, add `N66` done row, and add changelog row for M65.

- [x] **Step 4: Commit explicit files only**

```powershell
git add -- docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m65-mend-projector-heat-charge.md docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md godot-mindustry/src/game/PortGame.gd tools/mindustry_godot_transpiler/tests/test_playable.py
git commit -m "feat: warm mend projector charge by heat"
```
