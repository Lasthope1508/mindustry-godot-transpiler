# Handoff N2300 — BeamDrill N2195 proof fix (FIX slice)

## What this slice did

Fixed the STALE `C07BeamDrillUpdateTileProof` (N2195): the live tick asserted
multiplier 1.75 / time 0.875 with no hydrogen, but since N2256 the booster row folds
optionalEfficiency to 0 → real values 1.0 / 0.5. Updated the live tick, rewrote the
comments, ADDED a hydrogen-seeded case pinning 1.75/0.875, and stamped
`facing_amount = 1` for both drills (required — the N2202 gate closes otherwise).
Commit `0ae8a739` (`slice/N2300-beam-drill-n2195-proof-fix`). 1 file only.

## Key facts for the next agent

- **:55/:60 were NOT changed — deliberately.** Those keys call the pure advance
  directly with explicit optional_efficiency; 1.75/2.5 + 0.875/1.75 are correct pure
  math. Only the LIVE tick was stale. Do not "fix" them.
- The register docstring line 18 ("with no optional rows modeled yet") was fixed at
  integration (commit `c36b0563`, docstring-only).
- **No new pure, no new ledger entry, no new proof test — SSOT +0.** DEFERRED
  unchanged.
- The proof now has 7 keys (6 original + `live_tick_with_hydrogen_pins_boost_values`).

## Godot debt (this slice)

Debt is a RE-RUN of `C07BeamDrillUpdateTileProof` (N2195) with the UPDATED scene —
the third re-run alongside N2196 and N2280. See GOAL.md §5. Run targeted test
`tests.test_c07_beam_drill_update_tile` with Godot 4.6.2 on PATH, port 7777 free.
