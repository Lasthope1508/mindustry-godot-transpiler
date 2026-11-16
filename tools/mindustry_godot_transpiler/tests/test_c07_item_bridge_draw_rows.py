import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ITEM_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceItemBridgeBuildState.gd'
ITEM_BRIDGE_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeDrawRowsProof.gd'
ITEM_BRIDGE_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeDrawRowsProof.tscn'


class C07ItemBridgeDrawRowsTests(unittest.TestCase):
    def test_c07_item_bridge_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2429']['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_draw_state')
        # The ItemBridge tick is live (N2225 advance +
        # N2288 doDump + N2321 timerCheckMoved + N2404
        # dump neighbour live fill) but NOTHING modeled
        # draw(): the draw warmup `float warmup =
        # hasPower ? this.warmup : 1f;` (ItemBridge.java:
        # 387), the bridge ends + line + moving arrows
        # (:371-420), drawSelect (:223-231) /
        # drawInput (:233-266) / drawConfigure
        # (:269-281). N2429 ports the whole draw family
        # as ONE pure-only draw pure, the N2421
        # precedent: draw is never called by the tick,
        # so the pure takes caller-supplied inputs (the
        # frame warmup / time, Time.time as time_value,
        # Renderer.bridgeOpacity, the Lod flags, the
        # link verdict + the caller-evaluated incoming /
        # configure candidates) and returns the draw
        # calls as data. The warmup APPROACH (:345) is
        # updateTile logic, NOT draw logic -- it is
        # already live since N2225, so this slice ports
        # only the draw warmup (:387) + the draw family.
        # One pure, seven new result symbols: the draw
        # warmup, the bridge draw call, the moving
        # arrows, the pulse color, the select call, the
        # input calls, the configure call. ItemBridge
        # has NO icons() override (no "icon" line in
        # ItemBridge.java at all), so no icons key.
        self.assertEqual(
            ledger['N2429']['source_symbols'],
            [
                'source_item_bridge_draw_state_result.warmup_value',
                'source_item_bridge_draw_state_result.draw_call',
                'source_item_bridge_draw_state_result.arrow_calls',
                'source_item_bridge_draw_state_result.pulse_call',
                'source_item_bridge_draw_state_result.select_call',
                'source_item_bridge_draw_state_result.input_call',
                'source_item_bridge_draw_state_result.configure_call',
            ],
        )
        for name in ledger['N2429']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/distribution/ItemBridge.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceItemBridgeBuildState.source_item_bridge_'))
        self.assertEqual(ledger['N2429']['runtime_proof'], '/root/C07ItemBridgeDrawRowsProof')
        self.assertEqual(
            ledger['N2429']['tests'],
            [
                'test_c07_item_bridge_draw_rows_registration',
                'test_all_c07_item_bridge_draw_rows_input_evidence_is_exact',
                'test_item_bridge_draw_rows_state',
                'test_reference_graph_and_actual_c07_item_bridge_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2429']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #57 AND #109
        # (1-based in the merged advances-25 DEFERRED
        # base, 280 entries): the two entries cover the
        # SAME Java -- #109 (drawSelect / drawInput /
        # drawConfigure :223-296; draw :371-394; draw
        # warmup :387) is a subset of #57 (warmup
        # approach :345; draw warmup :387; draw /
        # drawSelect / drawConfigure / drawInput
        # :216-296, :375-394). Both entries are
        # REMOVED: the draw family is live now, the
        # warmup approach was already live since N2225
        # (updateTile, not draw), and the playerPlaced
        # tail + onConfigureBuildTapped inside #57's
        # :216-296 range were already live since N2199
        # / N2197 -- so nothing of either entry
        # remains. Net 280 - 2 = 278.
        self.assertFalse(any(entry.startswith('ItemBridge warmup / draw rows (') for entry in ledger['N2429']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('ItemBridge draw / config UI rows (') for entry in ledger['N2429']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge drawPlace / drawPlanConfigTop link preview (') for entry in ledger['N2429']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge per-def stat rows (') for entry in ledger['N2429']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge handlePlacementLine (') for entry in ledger['N2429']['deferred_exprs']))
        self.assertEqual(len(ledger['N2429']['deferred_exprs']), 278)

    def test_all_c07_item_bridge_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2429']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceItemBridgeBuildState.source_item_bridge_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/world/Tile.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/graphics/Lod.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2429']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_item_bridge_draw_rows_state(self):
        item_bridge = ITEM_BRIDGE_STATE.read_text(encoding='utf-8')
        # The draw rows (ItemBridgeBuild.draw(),
        # ItemBridge.java:371-420): `super.draw();` +
        # `Draw.z(Layer.power);` + the linkValid /
        # bridgeOpacity early returns + `int i =
        # relativeTo(other.x, other.y);` + the pulse
        # color (`Draw.color(Color.white, Color.black,
        # Mathf.absin(Time.time, 6f, 0.07f));` -- LIVE
        # for the phase-conveyor, `pulse = true;`,
        # Blocks.java:2124) + the draw warmup `float
        # warmup = hasPower ? this.warmup : 1f;`
        # (:387) + the fadeIn alpha floor 0.25f + the
        # endRegion rects at i * 90 + 90 / + 270 + the
        # bridgeRegion line (Tmp.v1 setLength
        # tilesize/2f, scl(-1f)) + `int dist =
        # Math.max(...) - 1;` + the Lod.l1 moving
        # arrows (count (int)(dist * tilesize /
        # arrowSpacing), alpha absin(a - time /
        # arrowTimeScl, arrowPeriod, 1f) * warmup *
        # bridgeOpacity * Lod.alpha1). drawSelect
        # (:223-231) draws the link input + one
        # drawInput per incoming pos, then
        # Draw.reset(). drawInput (:233-266): the
        # linkValid(..., false) early return, `boolean
        # linked = other.pos() == link;`, the trns
        # offset, the pulsing alpha `Math.abs((linked
        # ? 100 : 0)-(Time.time * 2f) % 100f) / 100f;`,
        # the lerp arrow at rel * 90, the gray
        # background + place/accent foreground.
        # drawConfigure (:269-281): the self select +
        # one select per linkValid candidate in the
        # 1..range x 4 scan, linked ? Pal.place :
        # Pal.breakInvalid, the unlinked radius
        # pulsing by absin(Time.time, 4f, 1f). The
        # warmup approach (:345) is updateTile logic
        # already live since N2225 -- NOT ported here.
        # ItemBridge has NO icons() override and
        # moveArrows is a dead field (declared :34,
        # never read in draw()). Pure-only: the tick
        # never calls draw (draw is called by the
        # renderer, drawSelect/drawConfigure by the
        # UI). Keep each Java expr on ONE comment line
        # (the N2148 lesson: a split line fails this
        # test).
        self.assertIn('static func source_item_bridge_draw_state', item_bridge)
        self.assertIn('public int range;', item_bridge)
        self.assertIn('public @Load("@-end") TextureRegion endRegion;', item_bridge)
        self.assertIn('public @Load("@-bridge") TextureRegion bridgeRegion;', item_bridge)
        self.assertIn('public @Load("@-arrow") TextureRegion arrowRegion;', item_bridge)
        self.assertIn('public boolean fadeIn = true;', item_bridge)
        self.assertIn('public boolean pulse = false;', item_bridge)
        self.assertIn('public float arrowSpacing = 4f, arrowOffset = 2f, arrowPeriod = 0.4f;', item_bridge)
        self.assertIn('public float arrowTimeScl = 6.2f;', item_bridge)
        self.assertIn('public float bridgeWidth = 6.5f;', item_bridge)
        self.assertIn('hasPower = true;', item_bridge)
        self.assertIn('public float warmup;', item_bridge)
        self.assertIn('public float time = -8f, timeSpeed;', item_bridge)
        self.assertIn('warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);', item_bridge)
        self.assertIn('public void drawSelect(){', item_bridge)
        self.assertIn('if(linkValid(tile, world.tile(link))){', item_bridge)
        self.assertIn('drawInput(world.tile(link));', item_bridge)
        self.assertIn('incoming.each(pos -> drawInput(world.tile(pos)));', item_bridge)
        self.assertIn('private void drawInput(Tile other){', item_bridge)
        self.assertIn('if(!linkValid(tile, other, false)) return;', item_bridge)
        self.assertIn('boolean linked = other.pos() == link;', item_bridge)
        self.assertIn('Tmp.v2.trns(tile.angleTo(other), 2f);', item_bridge)
        self.assertIn('float tx = tile.drawx(), ty = tile.drawy();', item_bridge)
        self.assertIn('float ox = other.drawx(), oy = other.drawy();', item_bridge)
        self.assertIn('float alpha = Math.abs((linked ? 100 : 0)-(Time.time * 2f) % 100f) / 100f;', item_bridge)
        self.assertIn('float x = Mathf.lerp(ox, tx, alpha);', item_bridge)
        self.assertIn('float y = Mathf.lerp(oy, ty, alpha);', item_bridge)
        self.assertIn('Tile otherLink = linked ? other : tile;', item_bridge)
        self.assertIn('int rel = (linked ? tile : other).absoluteRelativeTo(otherLink.x, otherLink.y);', item_bridge)
        self.assertIn('Draw.color(Pal.gray);', item_bridge)
        self.assertIn('Lines.stroke(2.5f);', item_bridge)
        self.assertIn('Lines.square(ox, oy, 2f, 45f);', item_bridge)
        self.assertIn('Lines.line(tx + Tmp.v2.x, ty + Tmp.v2.y, ox - Tmp.v2.x, oy - Tmp.v2.y);', item_bridge)
        self.assertIn('float color = (linked ? Pal.place : Pal.accent).toFloatBits();', item_bridge)
        self.assertIn('Lines.stroke(1f);', item_bridge)
        self.assertIn('Draw.mixcol(color);', item_bridge)
        self.assertIn('Draw.rect(arrowRegion, x, y, rel * 90);', item_bridge)
        self.assertIn('Draw.mixcol();', item_bridge)
        self.assertIn('public void drawConfigure(){', item_bridge)
        self.assertIn('Drawf.select(x, y, tile.block().size * tilesize / 2f + 2f, Pal.accent);', item_bridge)
        self.assertIn('for(int i = 1; i <= range; i++){', item_bridge)
        self.assertIn('for(int j = 0; j < 4; j++){', item_bridge)
        self.assertIn('Tile other = tile.nearby(Geometry.d4[j].x * i, Geometry.d4[j].y * i);', item_bridge)
        self.assertIn('if(linkValid(tile, other)){', item_bridge)
        self.assertIn('Drawf.select(other.drawx(), other.drawy(),', item_bridge)
        self.assertIn('other.block().size * tilesize / 2f + 2f + (linked ? 0f : Mathf.absin(Time.time, 4f, 1f)), linked ? Pal.place : Pal.breakInvalid);', item_bridge)
        self.assertIn('public void draw(){', item_bridge)
        self.assertIn('super.draw();', item_bridge)
        self.assertIn('Draw.z(Layer.power);', item_bridge)
        self.assertIn('Tile other = world.tile(link);', item_bridge)
        self.assertIn('if(!linkValid(tile, other)) return;', item_bridge)
        self.assertIn('if(Mathf.zero(Renderer.bridgeOpacity)) return;', item_bridge)
        self.assertIn('int i = relativeTo(other.x, other.y);', item_bridge)
        self.assertIn('if(pulse){', item_bridge)
        self.assertIn('Draw.color(Color.white, Color.black, Mathf.absin(Time.time, 6f, 0.07f));', item_bridge)
        self.assertIn('float warmup = hasPower ? this.warmup : 1f;', item_bridge)
        self.assertIn('Draw.alpha((fadeIn ? Math.max(warmup, 0.25f) : 1f) * Renderer.bridgeOpacity);', item_bridge)
        self.assertIn('Draw.rect(endRegion, x, y, i * 90 + 90);', item_bridge)
        self.assertIn('Draw.rect(endRegion, other.drawx(), other.drawy(), i * 90 + 270);', item_bridge)
        self.assertIn('Lines.stroke(bridgeWidth);', item_bridge)
        self.assertIn('Tmp.v1.set(x, y).sub(other.worldx(), other.worldy()).setLength(tilesize/2f).scl(-1f);', item_bridge)
        self.assertIn('Lines.line(bridgeRegion,', item_bridge)
        self.assertIn('int dist = Math.max(Math.abs(other.x - tile.x), Math.abs(other.y - tile.y)) - 1;', item_bridge)
        self.assertIn('if(Lod.l1){', item_bridge)
        self.assertIn('int arrows = (int)(dist * tilesize / arrowSpacing), dx = Geometry.d4x(i), dy = Geometry.d4y(i);', item_bridge)
        self.assertIn('Draw.alpha(Mathf.absin(a - time / arrowTimeScl, arrowPeriod, 1f) * warmup * Renderer.bridgeOpacity * Lod.alpha1);', item_bridge)
        self.assertIn('Draw.rect(arrowRegion,', item_bridge)
        self.assertIn('x + dx * (tilesize / 2f + a * arrowSpacing + arrowOffset),', item_bridge)
        self.assertIn('y + dy * (tilesize / 2f + a * arrowSpacing + arrowOffset),', item_bridge)
        self.assertIn('i * 90f);', item_bridge)
        self.assertIn('public byte relativeTo(int cx, int cy){', item_bridge)
        self.assertIn('return tile.absoluteRelativeTo(cx, cy);', item_bridge)
        self.assertIn('public byte absoluteRelativeTo(int cx, int cy){', item_bridge)
        self.assertIn('public static boolean l1 = true;', item_bridge)
        self.assertIn('public static float alpha1 = 1f;', item_bridge)
        self.assertIn('public static final int tilesize = 8;', item_bridge)
        self.assertIn('range = 12;', item_bridge)
        self.assertIn('arrowPeriod = 0.9f;', item_bridge)
        self.assertIn('arrowTimeScl = 2.75f;', item_bridge)
        self.assertIn('pulse = true;', item_bridge)
        # The documented limits record the draw rows as
        # live.
        self.assertIn('Draw rows live (N2429)', item_bridge)
        # The proof's keys drive the draw pure (the
        # draw warmup with hasPower true/false, the
        # linked draw incl. the pulse color + the
        # moving arrows, the unlinked / zero-opacity
        # early returns, drawSelect's link + incoming
        # inputs, drawConfigure's self + candidate
        # selects, the drawInput geometry incl. the
        # pulsing alpha + the rel rotation).
        proof = ITEM_BRIDGE_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_warmup',
            'draw_linked',
            'draw_unlinked',
            'draw_select',
            'draw_configure',
            'draw_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceItemBridgeBuildState.gd")', proof)
        self.assertTrue(ITEM_BRIDGE_STATE.exists())
        self.assertTrue(ITEM_BRIDGE_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07ItemBridgeDrawRowsProof.gd', ITEM_BRIDGE_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_item_bridge_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ItemBridgeDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ITEM_BRIDGE_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_warmup',
            'draw_linked',
            'draw_unlinked',
            'draw_select',
            'draw_configure',
            'draw_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
