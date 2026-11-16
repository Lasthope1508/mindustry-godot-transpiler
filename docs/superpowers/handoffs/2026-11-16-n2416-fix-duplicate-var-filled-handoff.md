# Handoff N2416 — Fix duplicate `var filled` redeclarations

## What this slice did

Fixed the SECOND real Godot parse error (user reviewing wave-23):
duplicate `var filled` in the same tick function — Fracker x3 (:802
linked-tiles, :806 proximity, :853 dump-liquid), BeamDrill x2 (:1161
facing-tiles, :1226 dump neighbour), SolidPump x2 (:616 proximity,
:664 dump neighbour). Kept the first declaration, renamed the rest
(`fraction_filled` / `dump_filled`) + their write-back `.get(...)`
uses. Driver diff is renames only. Whole-repo sweep: 16 files have
`var filled`, only those 3 functions violated; 0 after the fix. New
static sweep test (3 tests, RED→GREEN). 9 files, +180/−21, commit
`038b47a7a` on `slice/N2416-fix-duplicate-var-filled`.

## Key facts for the next agent

- **5 test files needed pin updates** (8 pins on `filled.get(...)`
  strings) — without them 5 modules FAIL non-Godot. String-only
  pin changes, no assertion-logic change.
- **Backport done by the main agent:** `bbcd71e88` on the wave-23
  integration branch (Fracker :785→fraction_filled, :832→
  dump_filled, BeamDrill :1226→dump_filled + pins). Do NOT
  cherry-pick 038b47a7a onto wave-23 — it touches N2414/N2411
  code that isn't there.
- SSOT +0. DEFERRED unchanged.

## Godot debt (this slice)

- None (no new proof, no re-run — the fix only unblocks parsing).
