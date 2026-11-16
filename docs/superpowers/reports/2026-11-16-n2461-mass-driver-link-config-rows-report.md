# Report N2461 — MassDriver link / config rows

**Slice:** N2461 — MassDriver config(Point2/Integer) +
onConfigureBuildTapped() + linkValid(): three pure-only pures
model the link validity, the config transition, and the tap-to-link
behaviour. **Wave:** advances-30. **Commit:** `7fa4cf5f5` on
`slice/N2461-mass-driver-link-config-rows` (base `4e4dc1a7c`).
**Files:** 5, +1023/−1, driver +114/−1.

## Source

config(Point2) (MassDriver.java:58): `tile.link = Point2.pack(
point.x + tile.tileX(), point.y + tile.tileY())` (relative);
config(Integer) (:59): `tile.link = point` (absolute).
onConfigureBuildTapped (:266-282): self → deselect if link == −1 +
configure(−1), return false; link == other.pos() → configure(−1),
false; other.block == block && other.dst(tile) <= range && team →
configure(other.pos()), false; else true. linkValid (:346-349):
link == −1 → false; world.build(link) instanceof MassDriverBuild &&
block == block && team == team && within(other, range). config()
(:351-355): tile null → null; `Point2.unpack(link).sub(tile.x,
tile.y)` (relative). `link = -1` (:116); `range` (:28, 440f,
Blocks.java:2172). Point2 pack `(((short)x) << 16) | (((short)y) &
0xFFFF)`, unpack `(short)(pos >>> 16), (short)(pos & 0xFFFF)` (arc
Point2.java:35-42); unpack(−1) = (−1,−1). `within` is STRICT dst2 <
range² (Position.java:44-46). `other.pos()` = `Point2.pack(x, y)`
(Tile.java:73-75); `deselect()` = BuildingComp.java:394-397 (CALL
flag, hide itself not modeled).

## Implementation

Three pure-only pures (no tick wiring — the link is a PACKED INT;
all world lookups caller-supplied, the N2435 precedent):
- `source_mass_driver_link_valid_state(link,
  other_is_mass_driver_build, other_block_matches,
  other_team_matches, within_range)` → `{link_valid}`. The public
  pure DELEGATES to the existing private `_mass_driver_link_valid`
  helper (exists = other_is_mass_driver_build; instanceof implies
  non-null), so the conjunction stays single-sourced with
  tick/acceptItem.
- `source_mass_driver_config_state(action, point, tile,
  current_link)` → `{link, config_value}`. Action ∈ {"point2",
  "integer", "clear", "none"} (the N2449 precedent). **Deviation
  from the brief (Java-driven):** the brief said `tile_x/tile_y`
  ints, but int params cannot express the null tile that Java's
  `config()` checks (`if(tile == null) return null;`) — the pure
  takes `tile: Variant` (Dictionary {x, y} or null) instead.
  "point2" with a null tile leaves the link untouched (no defined
  Java outcome — the handler dereferences `tile.tileX()`);
  config_value is null whenever tile is null, for every action.
  A cleared link reads config_value (−1−tx, −1−ty) — pinned in the
  proof ((−11,−21) at tile (10,20)).
- `source_mass_driver_configure_tapped_state(is_self, link,
  other_pos, other_block_matches, other_dst, range_value,
  other_team_matches)` → `{link_after, deselect_called, handled}`.
  Exactly :266-282. **`range` was renamed `range_value`** (the
  N2396 precedent) to avoid shadowing GDScript's builtin `range()`.

**Verify-first findings:**
- **Tap vs within use DIFFERENT metrics:** the tap uses
  `other.dst(tile) <= range` INCLUSIVE (:274); linkValid uses
  strict within. The boundary dst == range LINKS on tap but FAILS
  within — pinned in the proof (`tapped_link` boundary case).
- **shooterValid: NO new DEFERRED entry needed** — already ported
  as private `_mass_driver_shooter_valid`, live in the N2237 tick.
  The brief's conditional ("if unported anywhere") does not
  trigger.
- Draw pures (N2396) NOT rewired, per brief.

## Commits

- Slice: `7fa4cf5f5` (5 files, +1023/−1).
- Integration cherry-pick: `522773818` (clean).

## Tests

Targeted (new module
`tests.test_c07_mass_driver_link_config_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM
(user order 2026-11-15). RED confirmed before GREEN (failures=2,
errors=2). Proof arithmetic verified by Python simulation of the
pack/unpack logic.
Full gate (wave advances-30 integration, PID 1777, from 22:30): Ran 6818 tests in 1589.793s, FAILED (failures=379, skipped=5), 0 errors — 379/379 Godot-absent (372 inherited + 7 new proof tests N2455–N2461; Ran 6818 = 6790 + 28 new tests, exact arithmetic; run 1 PID 13870 killed by VM restart #16 ~22:29, no footer).

## SSOT / DEFERRED

SSOT single-slice **+6/+1/+3/+6** → 12318/1872/1815/3422 (exactly
as estimated). Symbols: `link_valid` (1) + `link`, `config_value`
(2) + `link_after`, `deselect_called`, `handled` (3). DEFERRED
**#34 RESOLVED** (253→252, by entry TEXT — verified at index 33
before removal; no new entry).

## Godot debt

- NEW proof `C07MassDriverLinkConfigRowsProof` (6 keys:
  `link_valid_true`, `link_valid_minus_one`, `link_valid_range`,
  `config_point2_relative`, `config_integer`, `tapped_link`) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
