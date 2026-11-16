# Handoff N2385 — Fix latent cursor_after pins (N2284 + N2371 proofs)

## What this slice did

Serial (coordinator): fixed 7 latent `cursor_after` pins
(1 → 0) in the N2284 Fracker proof (4 pins) + N2371 write-back
proof (3 pins) + 3 misleading comments. 2 files, +15/−12,
commit `9740859b5`.

## Key facts for the next agent

- **Liquid dump is a FULL cycle:** N neighbours = N incrementDump
  calls, so the cursor wraps back to its start value — a
  1-neighbour scan from cdump 0 ends at (0+1)%1 = 0, NOT 1.
  (BuildingComp.java:894 + :1116-1121; the N2285/N2286/N2287
  register rules all document this.)
- **Item dump is different:** the cursor moves per neighbour
  CHECKED until success — do not "fix" item-path pins (Unloader
  item phase, WallCrafter, timerDump family) with the liquid
  rule.
- Repo-wide audit: all other liquid-dump cursor pins are
  correct (early-return keeps the start cursor; N2287 stale 5→2
  over 3 neighbours).
- SSOT +0, proof-only fix.

## Godot debt (this slice)

- **2 RE-RUNS:** N2284 + N2371 proofs (pinned values changed).
