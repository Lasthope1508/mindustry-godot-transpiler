import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]


class BuildingCollisionGeneratedDelegateTests(unittest.TestCase):
    def test_generated_collision_delegates_to_canonical_damage_state(self):
        source = (ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd").read_text(encoding="utf-8")
        body = source.split("func java_method_collision_177", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("return source_building_damage_state.collision_damage_state(current_health, bullet_building_damage, block_armor, bullet_pierce_armor, bullet_armor_multiplier, bullet_block_armor_multiplier)", body)
        self.assertNotIn('return {"source_owner":', body)

    def test_collision_state_keeps_generated_result_keys(self):
        source = (ROOT / "godot-mindustry/src/game/SourceBuildingDamageState.gd").read_text(encoding="utf-8")
        body = source.split("static func collision_damage_state", 1)[1].split("\nstatic func ", 1)[0]
        self.assertIn('"method": "public boolean collision(Bullet other){"', body)
        self.assertIn('"raw_damage": bullet_building_damage', body)


if __name__ == "__main__":
    unittest.main()
