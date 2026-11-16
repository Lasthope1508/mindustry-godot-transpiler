# Handoff N2460 — PMD link/config rows

## What this slice did

Three pure-only pures (no tick wiring): link_valid + config
(point2/integer/clear/none) + configure_tapped. The link is a
PACKED INT. 5 files, +871/−1, commit `0b916453b` on
`slice/N2460-pmd-link-config-rows`.

## Key facts for the next agent

- **Entry #3 cites were WRONG both:** real lines are config :70–71,
  tapped :443–460, linkValid :466–468, config() :471–474.
- **PMD tapped differs from MassDriver at 1 gate:** instanceof
  PayloadMassDriver (small links large) vs `== block`.
- **handled INVERTS the Java return** (Java return = "should
  deselect"). **"clear" = configure(−1)** via the Integer handler
  — PMD registers no configClear. **unpack(−1) = (−1,−1)**.
- **shooterValid: no new entry** — PMD has no such method; the
  inline check is already a private helper.
- SSOT +6/+1/+3/+6 (exact est). DEFERRED #3 resolved (253→252).

## Godot debt (this slice)

- NEW proof `C07PayloadMassDriverLinkConfigRowsProof` (6 keys) —
  never run.
