# Report N2460 — PayloadMassDriver link / config rows

**Slice:** N2460 — PayloadMassDriver config(Point2/Integer) +
onConfigureBuildTapped() + linkValid(): three pure-only pures
model the link validity, the config transition, and the tap-to-link
behaviour. **Wave:** advances-30. **Commit:** `0b916453b` on
`slice/N2460-pmd-link-config-rows` (base `4e4dc1a7c`). **Files:** 5,
+871/−1.

## Source

**The DEFERRED #3 entry cites were WRONG on both counts** — `:64-65`
are constructor flags, `:321-350` are sense()/updatePayload()/draw().
**Real line numbers** (PayloadMassDriver.java, 528 lines — found by
grep, as the brief directed): config Point2 **:70**, config Integer
**:71** (comment `//point2 is relative` :69); `onConfigureBuildTapped`
**:443–460**; `linkValid` **:466–468**; `config()` **:471–474**;
`public int link = -1;` **:133**; `configurable = true;` **:60**.
config(Point2): `tile.link = Point2.pack(point.x + tile.tileX(),
point.y + tile.tileY())` (relative); config(Integer): `tile.link =
point` (absolute). onConfigureBuildTapped: self → deselect if link
== −1 + configure(−1), return false; link == other.pos() →
configure(−1), false; `other.block instanceof PayloadMassDriver`
&& dst <= range && team → configure(other.pos()), false; else true.
linkValid: 5 conjuncts in one return (link != −1, world.build(link)
is a PMD build, block matches, team matches, within range) — no
early `if(link == -1) return false;`, no state/shooter condition.
config(): null tile → null, else `unpack(link).sub(tile.x, tile.y)`.
Point2 pack/unpack (arc Point2.java:35-42): unpack(−1) = (−1,−1).
`within` is STRICT dst2 < range² (Position.java:44-46).

## Implementation

Three pure-only pures (no tick wiring — the link is a PACKED INT,
not a Vector2i; all world lookups caller-supplied, the N2435
precedent):
- `source_payload_mass_driver_link_valid_state(link,
  other_is_pmd_build, other_block_matches, other_team_matches,
  within_range)` → `{link_valid}`.
- `source_payload_mass_driver_config_state(action, point, tile_x,
  tile_y, current_link)` → `{link, config_value}`. Action ∈
  {"point2", "integer", "clear", "none"} (the N2449 precedent).
  "clear" = configure(−1) via the Integer handler — PMD does NOT
  register configClear (−1 comes from `configure(-1)` in
  onConfigureBuildTapped, :446/:452). config_value of a cleared
  link = {−1−tile_x, −1−tile_y} (unpack(−1) = (−1,−1), Java-exact
  — config() has no special case for −1). "point2" with a null tile
  → link unchanged (the Java handler dereferences tile.tileX(), so
  it never reaches pack with a null tile); an unknown action →
  like "none".
- `source_payload_mass_driver_configure_tapped_state(is_self, link,
  other_pos, other_block_matches, other_dst, range,
  other_team_matches)` → `{link_after, deselect_called, handled}`.
  **`handled` INVERTS the Java return:** the Java return means
  "should deselect" (BuildingComp.java:1690 `@return whether this
  block should be deselected.`; InputHandler.java:1992/2002 switch/
  hide config when true). `handled=true` ⟺ a configure ran
  (self-tap / unlink / link).

**Verify-first findings (the brief's 5 questions, answered):**
- (a) PMD **HAS** config Integer (:71) — the "integer" action is
  kept. (b) onConfigureBuildTapped **DIFFERS from MassDriver at 1
  gate**: PMD :455 uses `other.block instanceof PayloadMassDriver`,
  MassDriver :274 uses `other.block == block` → **a small PMD can
  link with a large PMD**. `other_block_matches` is the instanceof
  verdict (documented in docstring + register rule). (c) linkValid
  has **no PMD-specific gates**. (d) config() is **identical to
  MassDriver**. (e) Point2 unpack(−1) = (−1,−1); within is STRICT.
- **shooterValid: NO new DEFERRED entry** — PMD has NO shooterValid
  method (only MassDriver :342–344 has one, already ported as a
  private helper); PMD's inline check (:199–202) is already ported
  as private `_payload_mass_driver_shooter_valid` in the driver.
  Nothing to defer.

## Commits

- Slice: `0b916453b` (5 files, +871/−1).
- Integration cherry-pick: `31b4eb30f` (clean).

## Tests

Targeted (new module
`tests.test_c07_payload_mass_driver_link_config_rows`): 3/4 PASS
(registration, exact-evidence 24/24 exprs verbatim, row-state) +
proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). RED confirmed
first (2 failures + 2 errors).
Full gate (wave advances-30 integration, PID 1777, from 22:30): Ran 6818 tests in 1589.793s, FAILED (failures=379, skipped=5), 0 errors — 379/379 Godot-absent (372 inherited + 7 new proof tests N2455–N2461; Ran 6818 = 6790 + 28 new tests, exact arithmetic; run 1 PID 13870 killed by VM restart #16 ~22:29, no footer).

## SSOT / DEFERRED

SSOT single-slice **+6/+1/+3/+6** → 12318/1872/1815/3422 (exactly
as estimated). Shards changed: `payload_api_contracts.json`,
`payload_slices.json` (+ 4 canonical JSON). DEFERRED **#3
RESOLVED** (253→252, by entry TEXT; the MassDriver link/config
entry stays).

## Godot debt

- NEW proof `C07PayloadMassDriverLinkConfigRowsProof` (6 keys:
  `link_valid_true`, `link_valid_minus_one`, `link_valid_range`,
  `config_point2_relative`, `config_clear`, `tapped_link` — incl.
  the boundary dst == range links, self-tap deselect only when
  link == −1, unpack(−1) = (−1,−1)) — written but NEVER run; debt
  in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
