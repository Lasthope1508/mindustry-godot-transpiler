import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingDamageGeneratedDelegateTests(unittest.TestCase):
    def test_source_team_damage_overload_delegates_to_canonical_state(self):
        source = GENERATED.read_text(encoding="utf-8")
        body = source.split("func java_method_damage_178", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("return source_building_damage_state.damage_delegate_state(source_team, damage_amount)", body)
        self.assertNotIn('return {"source_owner":', body)

    def test_bullet_damage_overload_delegates_to_canonical_state(self):
        source = GENERATED.read_text(encoding="utf-8")
        body = source.split("func java_method_damage_179", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("return source_building_damage_state.bullet_damage_state(bullet, source_team, damage_amount)", body)
        self.assertNotIn('return {"source_owner":', body)

    def test_parity_bridges_preserve_generated_method_metadata(self):
        source = (ROOT / "godot-mindustry/src/game/SourceBuildingDamageState.gd").read_text(encoding="utf-8")
        delegate_body = source.split("static func generated_damage_delegate_bridge_state", 1)[1].split("\nstatic func ", 1)[0]
        bullet_body = source.split("static func generated_bullet_damage_bridge_state", 1)[1].split("\nstatic func ", 1)[0]
        self.assertIn('canonical["comment"] = "/** Used to handle damage from splash damage for certain types of blocks. */"', delegate_body)
        self.assertIn('canonical["method"] = "public void damage(@Nullable Team source, float damage){"', delegate_body)
        self.assertIn('canonical["comment"] = "/** Handles splash damage with a bullet source. */"', bullet_body)
        self.assertIn('canonical["method"] = "public void damage(Bullet bullet, Team source, float damage){"', bullet_body)


if __name__ == "__main__":
    unittest.main()
