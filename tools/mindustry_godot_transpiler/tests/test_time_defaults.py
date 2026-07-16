import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.emitter import emit_gdscript_classes


class TimeDefaultsEmitterTests(unittest.TestCase):
    def test_tractor_beam_turret_set_stats_uses_source_tick_rate_default(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "mindustry"
            turret_path = source_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.java"
            turret_path.parent.mkdir(parents=True, exist_ok=True)
            turret_path.write_text(
                """
package mindustry.world.blocks.defense.turrets;

import mindustry.world.meta.*;

public class TractorBeamTurret extends BaseTurret{
    public float damage = 0f;
    public boolean targetAir = true, targetGround = false;

    @Override
    public void setStats(){
        super.setStats();

        stats.add(Stat.targetsAir, targetAir);
        stats.add(Stat.targetsGround, targetGround);
        if(damage > 0) stats.add(Stat.damage, damage * 60f, StatUnit.perSecond);
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "world" / "blocks" / "defense" / "turrets" / "TractorBeamTurret.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_setStats_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn('const SourceTimeDefaults := preload("res://src/game/SourceTimeDefaults.gd")', source_text)
            self.assertIn("const SOURCE_TICK_RATE := SourceTimeDefaults.TICK_RATE", source_text)
            self.assertIn("var source_tick_rate: float = float(_args[3] if _args.size() > 3 else SOURCE_TICK_RATE)", source_text)
            self.assertNotIn("var source_tick_rate: float = float(_args[3] if _args.size() > 3 else 60.0)", source_text)
            self.assertIn("var damage_per_second: float = damage * source_tick_rate", source_text)


if __name__ == "__main__":
    unittest.main()
