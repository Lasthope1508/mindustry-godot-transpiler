# Handoff N2323 — UnitCargoLoader N2234 proof fix (seed nitrogen 1.0)

## What this slice did

Fixed the stale N2234 proof: the live tick seeded no nitrogen but expected
efficiency 0.5; since the N2249 liquid row went live, an unseeded loader
folds efficiency to 0. The proof now seeds nitrogen 1.0 on the sprite
liquids meta before the first tick (N2322 pattern). 1 file, +21/−1, commit
`4d3cf69a` on `slice/N2323-ucl-n2234-proof-fix`.

## Key facts for the next agent

- UCL consumes nitrogen 10f/60f (Blocks.java:2279 — the brief said :2277).
- Two ticks at eff 0.5 consume 2 × (10/60 × 0.5) = 1/6 ≈ 0.167 nitrogen —
  the 1.0 seed has a 6× margin, no re-seed needed (`source_set_state`
  mutates the sprite meta dict in place and the driver syncs that same
  reference into the frame each tick).
- FIX slice: no driver/test/register change, no ledger entry, SSOT +0,
  DEFERRED unchanged.
- Only the LIVE tick was stale; the pure-call keys call the advance
  directly with explicit efficiency and were never stale.
- Same staleness class as N2176/N2213/N2227/N2222 (N2309–N2312), N2195
  (N2300), N2223/N2273 (N2302/N2303): a new required liquid/item row folds
  efficiency to 0 for old proofs that tick live without seeding. Fix =
  seed the liquid/item on the sprite meta before the live tick.

## Godot debt (this slice)

- RE-RUN of N2234 proof `C07UnitCargoLoaderUpdateTileProof` (fixture
  changed — nitrogen seed) — never run. No new proof.
