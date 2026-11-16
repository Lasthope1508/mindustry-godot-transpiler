# Handoff N2495 — StackConveyor per-def stat rows

## What this slice did

One pure-only per-def stats pure (VERIFICATION slice, N2304 /
N2442 precedent): `source_stack_conveyor_per_def_stats_state`
returns {size, speed, item_capacity, health, glow_alpha,
glow_color, requirements}; unknown def → CLASS defaults.
5 files, +855/−1, commit `2e12179c1` on
`slice/N2495-stack-conveyor-per-def-stat-rows`.

## Key facts for the next agent

- Two defs: plastanium-conveyor (Blocks.java:2084-2089:
  health 90 / speed 4f/60f / cap 10 / plastanium 1 /
  silicon 1 / graphite 1) and surge-conveyor (:2237-2253:
  health 130 / speed 5f/60f / cap 10 / surge-alloy 1 /
  tungsten 1).
- Size 1 + glow 1f/Pal.redLight are CLASS defaults
  (Block.java:215; StackConveyor.java:34-35) — neither
  def overrides them.
- **Class-fallback health is 40, not −1** (coordinator
  ACCEPTED): the −1 field (Block.java:190) is a sentinel
  that Block.init() (:1378-1394) fills to
  round(size²×scaledHealth) = 40. The proof pins 40.
  (This decision also governs N2496/N2497.)
- Catalog quirk: plastanium-conveyor hasPower true /
  consumesPower true in the catalog though the def has no
  hasPower line — flagged for a catalog slice.
- SSOT +7/+1/+1/+2 (exact est). DEFERRED #49 resolved
  (225→224).

## Godot debt (this slice)

- NEW proof `C07StackConveyorPerDefStatRowsProof` (6 keys)
  — never run. Live input feeds the N2457 stats pure
  (40 / 50 / 0 items-per-second).
