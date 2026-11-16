# Handoff N2446 — BuildTurret icons rows (amend N2431)

## What this slice did

AMEND slice (fix precedent N2416/N2424, no new pure/ledger/proof):
added `icon_regions` = ["baseRegion", "region"] to the N2431 draw
pure + amended the N2431 register in place + fixed the stale
driver line :129 (draw live N2431 + icons N2446, sense live
N2437, write/read :259-278 wait). 3 files, +58/−39, commit
`179a6597e` on `slice/N2446-build-turret-icons-rows`.

## Key facts for the next agent

- **Register amended IN PLACE** (upsert REPLACES the entry — a
  new register would have wiped the N2431 schema). DEFERRED list
  replaced with the merged 266 base minus #266 (279 → 265).
- **No test pinned the :129 phrase**; the new text avoids the
  N2437 sense test's assertNotIn phrase. test_source_symbols has
  no N2431 pins.
- **Ledger snapshot consequence:** 15 stale DEFERRED entries
  leave the N2431 snapshot at SSOT merge (resolved by
  advances-26/27) — expected rebase effect, not a scope change.
- SSOT +1/+0/+0/+0 (exact est). DEFERRED #266 resolved (266→265).

## Godot debt (this slice)

- NO new proof, NO re-run (the N2431 proof file is untouched).
