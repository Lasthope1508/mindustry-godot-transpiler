# Handoff N2307 — Cite cleanup (CLEANUP slice)

## What this slice did

Fixed three wrong cites (all grep-verified): PayloadBlock fields :94/:95/:96 →
:92/:94/:95 (payload :92, payVector :94, payRotation :95); Pump dump :180-182 →
:178-180; UAM acceptsPayload :27 → :28. 7 files, +14/−14, 0 test files, commit
`2ee51c70` on `slice/N2307-cite-cleanup`.

## Key facts for the next agent

- 7 files, not 4–6: the Pump cite also lived in a proof comment + the N2088/N2089
  registers. No test pinned the old cites (0 hits in tests/).
- The coordinator re-ran the 3 touched registers at integration + a
  follow-through fix (d516af80) for the UAM register docstring stale note, the
  spec (N2088/N2090/N2291), and the GOAL advances-8 bullet.
- **Pre-existing drift:** re-running the deconstructor register adds
  `optional_mirror_fields: ["return_type"]` + mirrors `return_type` into
  payload_api_contracts.json — the register code does it, committed state lacked
  it. It does NOT change the 4 SSOT totals. Recorded in SSOT commit 479625e9.
- SSOT +0/+0/+0/+0; DEFERRED unchanged in count (text changes only).

## Godot debt (this slice)

None — cleanup slice.
