# M60 Source Mend Projector Repair Amount Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port the source `MendProjector` repair amount formula into Godot runtime helpers with source-parity checks.

**Architecture:** `source_parity.py` reads `Blocks.java` `mendProjector` values and generated registry health to verify non-phase repair amount. `PortGame.gd` exposes `source_mend_projector_repair_amount()` using the Java formula `other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency`, then reports a source-backed `mend-projector` self-repair amount in runtime summary for MCP proof.

**Source facts:** `MendProjector.java` heals with `other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency)`. `Blocks.java` sets `mendProjector.healPercent = 11f`, `phaseBoost = 15f`, and `scaledHealth = 80`; `Block.init()` from prior milestone gives generated health `320`, so non-phase `phaseHeat=0`, `efficiency=1` repair amount is `320 * 11 / 100 = 35.2`.

**Tech Stack:** Python source-parity tests, GDScript runtime helpers, Godot 4.6.2 MCP LSP/runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M60 tasks | 8 |
| Done | 8 |
| Not done | 0 |
| Blocked | 0 |

## Execution Checklist

- [x] M60-1 Read exact upstream Java formula and source values.
- [x] M60-2 Add failing source-parity test for non-phase repair amount.
- [x] M60-3 Add failing playable runtime test for repair amount helpers and summary.
- [x] M60-4 Implement source-backed repair amount parity helper.
- [x] M60-5 Implement Godot runtime repair amount helpers.
- [x] M60-6 Verify targeted and full tests.
- [x] M60-7 Verify MCP LSP/runtime behavior.
- [x] M60-8 Update docs total/done/not done and commit.

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M60-1 | Read exact upstream Java formula and source values | Read `MendProjector.java` heal formula plus `Blocks.java` `mendProjector` initializer; derived non-phase amount `35.2` from generated `health=320` and source `healPercent=11`. |
| M60-2 | Add failing source-parity test for non-phase repair amount | RED targeted run failed because `verify_mend_projector_repair_amount_parity` was missing. |
| M60-3 | Add failing playable runtime test for repair amount helpers and summary | RED targeted run failed because `PortGame.gd` lacked `source_mend_projector_repair_amount()` and summary field. |
| M60-4 | Implement source-backed repair amount parity helper | Targeted source-parity test passes and checks `repairAmount=35.2`. |
| M60-5 | Implement Godot runtime repair amount helpers | Targeted playable test passes and runtime source contains formula using `healPercent`, `phaseBoost`, `phase_heat`, and `efficiency`. |
| M60-6 | Verify targeted and full tests | Targeted unittest command passes `2` tests; full `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` reports `Ran 70 tests` and `OK`. |
| M60-7 | Verify MCP LSP/runtime behavior | MCP LSP diagnostics for `src/game/PortGame.gd` return `[]`; MCP runtime selects `mend-projector` and reports `selected_build_repair_amount=35.2`, with debug `errors: []`. |
| M60-8 | Update docs total/done/not done and commit | Spec updated to `63/63`; explicit staging excludes generated `.uid` files before commit. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M60 item | Add next source-backed migration item after this commit. |
