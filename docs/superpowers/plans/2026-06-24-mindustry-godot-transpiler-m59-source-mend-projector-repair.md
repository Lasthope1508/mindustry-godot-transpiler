# M59 Source Mend Projector Repair Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract source `MendProjector` repair parameters so Godot content carries upstream healing behavior data.

**Architecture:** `source_parity.py` reads `mendProjector = new MendProjector("mend-projector")` from `Blocks.java`, applies `MendProjector.java` defaults for omitted values, and compares generated registry fields. `content_registry.py` extracts `healPercent`, `phaseBoost`, and `phaseRangeBoost`, applying defaults only to `MendProjector` implementations when source omits an assignment. `PortGame.gd` exposes selected build repair fields through runtime summary so MCP can select `mend-projector` and verify source-derived values live.

**Source facts:** `mindustry-upstream/core/src/mindustry/world/blocks/defense/MendProjector.java` defines defaults `healPercent = 12f`, `phaseBoost = 12f`, and `phaseRangeBoost = 50f`; stats and update use those values in repair calculations. `mindustry-upstream/core/src/mindustry/content/Blocks.java` sets `mender` `healPercent = 4f`, `phaseBoost = 4f`, `phaseRangeBoost = 20f`; it sets `mendProjector` `healPercent = 11f` and `phaseBoost = 15f`, with no `phaseRangeBoost` override, so generated `mend-projector.phaseRangeBoost` must be default `50.0`.

**Tech Stack:** Python source-parity tests, Python content generator, GDScript runtime summary checks, Godot 4.6.2 MCP LSP/runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M59 tasks | 9 |
| Done | 9 |
| Not done | 0 |
| Blocked | 0 |

## Execution Checklist

- [x] M59-1 Read exact upstream Java facts for `MendProjector` repair parameters.
- [x] M59-2 Add failing source-parity test for `mend-projector` repair params.
- [x] M59-3 Add failing generator fixture test for explicit/default `MendProjector` repair params.
- [x] M59-4 Add failing playable runtime test for selected build repair summary.
- [x] M59-5 Implement source-backed repair parameter extraction and defaults.
- [x] M59-6 Regenerate Godot content registry.
- [x] M59-7 Verify targeted and full tests.
- [x] M59-8 Verify MCP LSP/runtime behavior.
- [x] M59-9 Update docs total/done/not done and commit.

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M59-1 | Read exact upstream Java facts for `MendProjector` repair parameters | Read `MendProjector.java` defaults and repair usage plus `Blocks.java` `mender` and `mendProjector` initializers. |
| M59-2 | Add failing source-parity test for `mend-projector` repair params | RED run failed because `verify_mend_projector_repair_parity` was missing before implementation. |
| M59-3 | Add failing generator fixture test for explicit/default `MendProjector` repair params | RED run failed because generated fixture properties omitted `healPercent`, `phaseBoost`, and `phaseRangeBoost`. |
| M59-4 | Add failing playable runtime test for selected build repair summary | RED run failed because `PortGame.gd` lacked selected build repair summary helpers. |
| M59-5 | Implement source-backed repair parameter extraction and defaults | Targeted test run passes with `healPercent=11.0`, `phaseBoost=15.0`, and `phaseRangeBoost=50.0` for `mend-projector`. |
| M59-6 | Regenerate Godot content registry | `python tools/mindustry_godot_transpiler/transpile.py content --upstream mindustry-upstream --godot godot-mindustry` reports `content items=22 liquids=11 blocks=417 units=56`. |
| M59-7 | Verify targeted and full tests | Targeted unittest command passes `3` tests; full `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` reports `Ran 68 tests` and `OK`. |
| M59-8 | Verify MCP LSP/runtime behavior | MCP LSP diagnostics for `src/game/PortGame.gd` return `[]`; MCP runtime selects `mend-projector` and reports `selected_build_heal_percent=11`, `selected_build_phase_boost=15`, `selected_build_phase_range_boost=50`, with debug `errors: []`. |
| M59-9 | Update docs total/done/not done and commit | Spec updated to `62/62`; explicit staging excludes generated `.uid` files before commit. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M59 item | Add next source-backed migration item after this commit. |
