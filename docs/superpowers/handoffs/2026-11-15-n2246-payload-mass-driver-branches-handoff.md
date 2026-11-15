# N2246 PayloadMassDriver State Branches — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-5, coordinator lượt 5).

## What this slice did

- PayloadMassDriver accepting + shooting branches as a pure advance in `SourcePayloadMassDriverBuildState.gd` (PayloadMassDriver.java:236-332): accepting bail/align, shooting load/fire gate, charge + transfer with partner write-back.
- 21 result symbols (11 self + 9 partner write-back + `fired`). The driver writes both frames back (N2237 precedent).

## Key facts for the next agent

- **updateTile ends :332** — the worker's :342 cites were corrected at integration (verified against upstream: :332 is the closing brace; :341+ is updatePayload()). Branch ranges: accepting :236-248, shooting :249-270, fire gate :272-294, charge+transfer :295-332.
- **Angles.within is `<=`** (unlike Angles.near STRICT `<`, N2237) — the port uses shared source_angles_within. **handlePayload's writes are overwritten the same tick by :307-308** — the net transfer is payload + :307-310 values. **Charge is NOT reset on transfer.** `recPayload` is set :303 then cleared :314 in the same tick (NOT a result key). `hasArrived` = `len2() < margin`.
- **The branches read pay_vector as a Vector2** (N2233 precedent) while the frame stores the dict form (N2245) — the tick wiring converts at the boundary (2 helpers added at integration). Helpers `_to_short` / `_point2_pack` / `_point2_unpack` deduped with N2245's copies (one copy kept).
- Integration was a 13-hunk hand merge (commit `39b16e35`); both pure functions are verbatim from their branches (N2245 first, N2246 second, Java order).
- Register: 107 exact exprs, 0 missing. DEFERRED: 284 (updateTile advance entry resolved + 2 new: transfer effects/sound/shake, updatePayload live positioning). **Payload shard CHANGED**.
- Slice commit `107c2ad6` (branch `slice/N2246-payload-mass-driver-branches`, đã push 19:51); integration cherry-pick `39b16e35` (hand merge); SSOT gộp `9296c64f` (11706/1698/1620/3031).

## Godot debt (this slice)

- `C07PayloadMassDriverBranchesProof` — 6 keys (`accepting_bails_without_shooter`, `accepting_aligns_to_shooter`, `shooting_bails_without_link`, `load_advances_to_length`, `fire_gate_requires_queue_and_angles`, `transfer_resets_both_sides`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
