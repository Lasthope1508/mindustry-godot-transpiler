# Report N2399 — RegenProjector heal application

**Slice:** N2399 — RegenProjector heal application: the
`mendMap` flush (N2228) now applies its heals to live targets
through the world, capped at max health. **Wave:** advances-22.
**Commit:** `4eacbb73d` on
`slice/N2399-regen-projector-heal-application` (base
`78a74e152`). **Files:** 5, +1042/−10.

## Source

Java: RegenProjector.java (the heal application after the
`mendMap` flush, N2228). **Brief premise CORRECTED:** NO family
frame carries health — health lives on sprite metas
`source_block_health` / `source_block_max_health`, so the helper
edits meta directly through the shared `repair_sprite`; there is
no no_frame outcome — the analogue is no_sprite (`World.build`
null).

## Implementation

New pure `source_regen_projector_heal_application_state` →
`{applications, applied_count, skipped_count, recently_healed:
false}`; the tick wires it AFTER the flush write-back. Heal is
capped at max health. `recentlyHealed()` DEFERS (the tick has
no time input — PortGame does not expose elapsed/Time.time).
**Deviation, documented in DEFERRED:** frame targets keep their
pre-heal health snapshot until the next scan `tile_changes`.

## Commits

- Slice: `4eacbb73d` (5 files, +1042/−10).
- Integration cherry-pick: `a54e25ae8` (clean).

## Tests

Targeted (new module
`tests.test_c07_regen_projector_heal_application`): 3/4 PASS +
proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15).
Full gate (wave advances-22 integration, PID 7151, from 14:50):
Ran 6602 tests in 1564.685s, FAILED (failures=326, skipped=5), 0 errors — 326/326 Godot-absent `AssertionError: unexpectedly None` (319 inherited + 7 new proof tests N2394–N2400; N2401 adds no test)..

## SSOT / DEFERRED

SSOT single-slice **+4/+1/+1/+2** → 12072/1820/1750/3292 (brief
estimated +2 symbols — the pure returns 4 keys). Audit stays
1336. DEFERRED **#274 RESOLVED** + **#273 REWRITTEN IN PLACE**
+ **2 NEW entries** (recentlyHealed timestamp + targets health
snapshot refresh → register list 302).

## Godot debt

- NEW proof `C07RegenProjectorHealApplicationProof` (6 keys:
  `heal_application_decodes_pos_to_cell`,
  `heal_application_applies_amount_to_target`,
  `heal_application_caps_at_max_health`,
  `heal_application_no_sprite_reports_no_sprite`,
  `live_tick_applies_flush_after_advance`,
  `recently_healed_deferred_without_time_input`) — written but
  NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
- Follow-through: `recentlyHealed()` needs a time input the tick
  does not have; the targets health snapshot refresh is a
  separate slice.
