# Handoff N2315 — Loader intake full-gate wiring

## What this slice did

Wired the Loader intake through the N2295 acceptPayload verdict: the tick
duplicates the incoming dict as the N2295 descriptor and evaluates the pure;
the push applies only when it accepts. A push without `block_size` gets the
rejecting default injected by the intake. 6 files, +893/−14, commit `7addcf20`
on `slice/N2315-loader-intake-gate`.

## Key facts for the next agent

- **Loader-specific deviation from N2308:** the N2295 pure defaults a missing
  `block_size` to 0 — which FITS — so the intake must inject the rejecting
  default itself (`SOURCE_PAYLOAD_LOADER_MAX_BLOCK_SIZE + 1`). N2308's pure
  defaults to rejecting, so it needed no injection.
- The N2278 drop is preserved (`frame["incoming_payload"] = null` runs either
  way). `frame["accepts_payload"]` is never overwritten (offer verdict governs
  the frame key, intake verdict decides the push alone). The pure's
  `has_payload` term subsumes the old frame null check.
- The handle pure is untouched, still passes the Loader's own size 3 as
  `block_size`.
- **The N2278 live push lives in the PROOF file**, not the test module — the
  worker updated the N2278 proof fixture (+`is_build_payload` / `block_size: 2`
  / `has_items` / `unloadable` / `item_capacity: 10`), load-bearing. → N2278
  proof is a RE-RUN. The occupied-case push was left as-is (rejects via the
  base gate regardless).
- N2295 test pins are substring `assertIn`s only — no tick-call string pin, no
  pin update needed (N2304 lesson checked first).
- Cite correction: InputHandler unit-drop is :667–669 (brief said :668–669).
- SSOT +0/+1/+0/+0 (shared ownership of the N2295 pure's 5 symbols). DEFERRED
  unchanged 325 — no entry existed (N2295 oversight). The coordinator rewrote
  DEFERRED #311 in place at the wave merge (the N2278 intake now consults the
  full gate).

## Godot debt (this slice)

- NEW proof `C07PayloadLoaderIntakeGateProof` (6 keys) — never run.
- RE-RUN of proof N2278 (`C07PayloadLoaderLiveFillProof`).
