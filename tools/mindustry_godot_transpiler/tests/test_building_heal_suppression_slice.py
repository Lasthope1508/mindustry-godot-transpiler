import unittest
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[3]
class T(unittest.TestCase):
 def test_generated_apply_methods_delegate(self):
  p=(ROOT/'godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd').read_text()
  for name in ('java_method_applyHealSuppression_26','java_method_applyHealSuppression_27'):
   body=p.split('func '+name,1)[1].split('\nfunc ',1)[0]
   self.assertIn('source_building_lifecycle_state.apply_heal_suppression_state',body)
   self.assertNotIn('return null',body)
 def test_source_text_and_java(self):
  s=(ROOT/'godot-mindustry/src/game/SourceBuildingLifecycleSourceTextState.gd').read_text()
  j=(ROOT/'mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java').read_text()
  for x in ('public void applyHealSuppression(float amount){','applyHealSuppression(amount, Pal.sapBullet);','public void applyHealSuppression(float amount, Color suppressColor){','healSuppressionTime = Math.max(healSuppressionTime, Time.time + amount);','this.suppressColor = suppressColor;'):
   self.assertIn(x,j); self.assertIn(x,s)
 def test_registry_slice(self):
  g=ROOT/'godot-mindustry/src/generated'
  led=json.loads((g/'source_slice_ledger.json').read_text())['slices']
  reg=json.loads((g/'source_symbol_registry.json').read_text())['symbols']
  self.assertEqual(led['N1951']['status'],'done')
  self.assertEqual(led['N1951']['godot_owner'],'PortGame.source_building_heal_suppression_state')
  self.assertEqual(reg['building_heal_suppression.method']['godot_owner'],'PortGame.source_building_heal_suppression_state')
if __name__=='__main__': unittest.main()
