import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FRACKER_STATE = ROOT / 'godot-mindustry/src/game/SourceFrackerBuildState.gd'


class C07FrackerCiteSweepTests(unittest.TestCase):
    def test_no_stale_fracker_361_cite(self):
        # N2355 sweep: the frame-sync cite points at the live
        # sync in SourceFrackerBuildState.gd, which sits at line
        # 633 now (frame["liquids"] = sprite.get_meta(...), the
        # comment explaining it spans :626-632 -- N2371 moved
        # it down 10 lines with the dump doc + write-back
        # wiring above it). The old line
        # number went stale as the driver grew, and 20 copies
        # of the stale cite had spread over 6 drivers, 6
        # registers and 5 test modules (grep-verified
        # 2026-11-16, including the full
        # SourceFrackerBuildState.gd form in the burst-drill
        # driver/register/test and 2 extra hits in the
        # wall-crafter register the brief missed). This pin
        # keeps the sweep durable so a future slice cannot
        # reintroduce the stale cite.
        #
        # Scope: drivers + registers + tests only. The
        # generated JSON copy (source_state_schema.json, fed
        # by the regen register's schema rule) is regenerated
        # at integration, and the docs copies (GOAL.md,
        # handoffs, reports, design spec) are history -- both
        # are out of scope for this pin (N2307/N2339 precedent).
        #
        # The banned strings are built by concatenation so
        # this module does not flag itself.
        stale_short = 'Fracker:' + '361'
        stale_full = 'FrackerBuildState.gd:' + '361'
        scopes = [
            ROOT / 'godot-mindustry/src/game',
            ROOT / 'tools/mindustry_godot_transpiler',
        ]
        hits = []
        for scope in scopes:
            for path in sorted(scope.rglob('*')):
                if path.suffix not in ('.gd', '.py'):
                    continue
                if 'generated' in path.parts:
                    continue
                for line_no, line in enumerate(path.read_text(encoding='utf-8').splitlines(), 1):
                    if stale_short in line or stale_full in line:
                        hits.append(f'{path.relative_to(ROOT)}:{line_no}:{line.strip()}')
        self.assertEqual(hits, [])
        # Positive pin: the real sync the cite points at is
        # still at :633, so the sweep cannot pass vacuously by
        # deleting every cite.
        lines = FRACKER_STATE.read_text(encoding='utf-8').splitlines()
        self.assertEqual(
            lines[632].strip(),
            'frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})',
        )
