import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
STACK_ROUTER_STATE = ROOT / 'godot-mindustry/src/game/SourceStackRouterBuildState.gd'
STACK_ROUTER_LIVE_PROXIMITY_QUERY_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackRouterLiveProximityQueryProof.gd'
STACK_ROUTER_LIVE_PROXIMITY_QUERY_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackRouterLiveProximityQueryProof.tscn'
BUILDING_COMP_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java'
EDGES_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/Edges.java'
DUCT_ROUTER_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/distribution/DuctRouter.java'
STACK_ROUTER_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/distribution/StackRouter.java'
BLOCK_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/Block.java'
MATHF_JAVA = ROOT / 'arc-upstream/arc-core/src/arc/math/Mathf.java'
GEOMETRY_JAVA = ROOT / 'arc-upstream/arc-core/src/arc/math/geom/Geometry.java'


class C07StackRouterLiveProximityQueryTests(unittest.TestCase):
    def test_c07_stack_router_live_proximity_query_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2472']['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_proximity_neighbours_live_fill_state')
        # N2324 ported the target() live proximity selection
        # (DuctRouter.target(), DuctRouter.java:139-157) as a
        # pure over the frame proximity_neighbours input --
        # but no live proximity query filled that frame input
        # yet, so a live surge-router with no stamped
        # neighbours passed an empty list and no live handoff
        # happened. N2472 is the live query: the tick scans
        # the Edges proximity ring live from frame
        # ["world_tiles"] (Edges.getEdges(size), Edges.java:
        # 23-40, angle-sorted; size 1: east / north / west /
        # south = rel 0/1/2/3) BEFORE the N2240 advance and
        # stamps frame["proximity_neighbours"] with the
        # neighbour Dicts {id, rel, team, accepts_item} in
        # ring order (supplied lists win; a previously
        # live-filled frame refreshes every tick). One new
        # symbol: the filled proximity-neighbours array.
        self.assertEqual(
            ledger['N2472']['source_symbols'],
            [
                'source_stack_router_proximity_neighbours_live_fill_state_result.proximity_neighbours',
            ],
        )
        for name in ledger['N2472']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/Edges.java',
                    'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
                    'core/src/mindustry/world/blocks/distribution/StackRouter.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_proximity_neighbours_live_fill_state')
        self.assertEqual(ledger['N2472']['runtime_proof'], '/root/C07StackRouterLiveProximityQueryProof')
        self.assertEqual(
            ledger['N2472']['tests'],
            [
                'test_c07_stack_router_live_proximity_query_registration',
                'test_all_c07_stack_router_live_proximity_query_input_evidence_is_exact',
                'test_stack_router_live_proximity_query_state',
                'test_reference_graph_and_actual_c07_stack_router_live_proximity_query',
            ],
        )
        self.assertTrue(ledger['N2472']['deferred_exprs'])
        # QUERY HALF ONLY (the N2459 precedent): the #210
        # entry covers the query + the handleItem
        # application. This slice ports ONLY the query, so
        # the entry is REWRITTEN IN PLACE to record the
        # query live since N2472 + the handleItem
        # application still waiting -- the DEFERRED count
        # does NOT decrease (238 stays 238). No new entry:
        # the live tile-producer gap (no producer stamps
        # frame["world_tiles"] / frame["team_by_tile"] /
        # frame["accepts_item_by_tile"] yet) is a
        # follow-through note, not a deferral -- the pure +
        # frame inputs work with seeded maps.
        self.assertEqual(len(ledger['N2472']['deferred_exprs']), 238)
        query = [entry for entry in ledger['N2472']['deferred_exprs'] if entry.startswith('StackRouter live proximity query + handleItem application (')]
        self.assertEqual(len(query), 1)
        self.assertIn('the live proximity query is live since N2472', query[0])
        self.assertIn('the handleItem application waits for its own slice', query[0])
        self.assertNotIn('the live query + application wait for their own slices', query[0])
        self.assertNotIn('no live proximity query fills that frame input yet', query[0])
        self.assertTrue(any(entry.startswith('StackRouter acceptItem live fill (') for entry in ledger['N2472']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter read/write rows (') for entry in ledger['N2472']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('WallCrafter updateTile live fill (') for entry in ledger['N2472']['deferred_exprs']))

    def test_all_c07_stack_router_live_proximity_query_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2472']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_proximity_neighbours_live_fill_state')
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Edges.java',
            'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'core/src/mindustry/world/blocks/distribution/StackRouter.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The angle sort + the d4 order live in Arc, not
        # Mindustry: Mathf.java / Geometry.java under
        # arc-upstream (the N2191 precedent).
        upstream['arc-core/src/arc/math/Mathf.java'] = MATHF_JAVA.read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/geom/Geometry.java'] = GEOMETRY_JAVA.read_text(encoding='utf-8')
        for expr in ledger['N2472']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_stack_router_live_proximity_query_state(self):
        stack_router = STACK_ROUTER_STATE.read_text(encoding='utf-8')
        # The live proximity query (N2472, DEFERRED #210,
        # QUERY HALF ONLY): the tick fills frame
        # ["proximity_neighbours"] from the live Edges ring
        # BEFORE the N2324 target list reads it. Java builds
        # proximity in updateProximity() (BuildingComp.java:
        # 1879-1903 -- NOT onProximityUpdate, :1154-1156,
        # which is just noSleep()): it scans Edges.getEdges
        # (block.size) (:1883), looks up world.build(tile.x
        # + point.x, tile.y + point.y) (:1885), and keeps
        # same-team buildings only (`if(other == null ||
        # other.team != team) continue;`, :1887) -- so the
        # fill needs the router team as an input and the
        # N2324 same-team gate never fires on a filled list
        # (it stays as defence for caller-supplied lists).
        # The ring comes from the Edges static block
        # (Edges.java:23-40): bot/top from the size, 4*size
        # edge points, sorted by Mathf.angle -- and
        # Mathf.angle NORMALIZES to [0, 360) (arc Mathf.java:
        # 98-102, `if(result < 0) result += 360f;`), so the
        # size-1 ring is east / north / west / south = rel
        # 0/1/2/3, the Geometry.d4 order (arc Geometry.java:
        # 9-14) -- NOT the shared helper order (the helper
        # sorts unnormalized atan2 and puts south first, so
        # the fill generates the ring inline, Java-exact).
        # rel is relativeTo(Building) (BuildingComp.java:
        # 530-540) in tile-offset form: |dx| > |dy| picks
        # east/west (0/2), otherwise the y branch picks
        # north/south (1/3) -- a diagonal ring point takes
        # the y branch (ties go to y). Keep each Java expr
        # on ONE comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_stack_router_proximity_neighbours_live_fill_state(world_tiles: Dictionary, cell: Vector2i, size: int, team: int, team_map: Dictionary, accepts_map: Dictionary) -> Dictionary:', stack_router)
        self.assertIn('public void updateProximity(){', stack_router)
        self.assertIn('Point2[] nearby = Edges.getEdges(block.size);', stack_router)
        self.assertIn('Building other = world.build(tile.x + point.x, tile.y + point.y);', stack_router)
        self.assertIn('if(other == null || other.team != team) continue;', stack_router)
        self.assertIn('other.proximity.addUnique(self());', stack_router)
        self.assertIn('//using a set to prevent duplicates', stack_router)
        self.assertIn('proximity.add(tile);', stack_router)
        self.assertIn('transient Seq<Building> proximity = new Seq<>(true, 6, Building.class);', stack_router)
        self.assertIn('static final ObjectSet<Building> tmpTiles = new ObjectSet<>();', stack_router)
        self.assertIn('public byte relativeTo(Building build){', stack_router)
        self.assertIn('if(Math.abs(x - build.x) > Math.abs(y - build.y)){', stack_router)
        self.assertIn('if(x <= build.x - 1) return 0;', stack_router)
        self.assertIn('if(x >= build.x + 1) return 2;', stack_router)
        self.assertIn('if(y <= build.y - 1) return 1;', stack_router)
        self.assertIn('if(y >= build.y + 1) return 3;', stack_router)
        self.assertIn('int bot = -(int)(i / 2f) - 1;', stack_router)
        self.assertIn('int top = (int)(i / 2f + 0.5f) + 1;', stack_router)
        self.assertIn('edges[i][idx++] = new Point2(bot + 1 + j, bot);', stack_router)
        self.assertIn('edges[i][idx++] = new Point2(bot + 1 + j, top);', stack_router)
        self.assertIn('edges[i][idx++] = new Point2(bot, bot + j + 1);', stack_router)
        self.assertIn('edges[i][idx++] = new Point2(top, bot + j + 1);', stack_router)
        self.assertIn('Arrays.sort(edges[i], (e1, e2) -> Float.compare(Mathf.angle(e1.x, e1.y), Mathf.angle(e2.x, e2.y)));', stack_router)
        self.assertIn('public static Point2[] getEdges(int size){', stack_router)
        self.assertIn('public static float angle(float x, float y){', stack_router)
        self.assertIn('float result = atan2(x, y) * radDeg;', stack_router)
        self.assertIn('if(result < 0) result += 360f;', stack_router)
        self.assertIn('public Building target(){', stack_router)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', stack_router)
        self.assertIn('int rel = relativeTo(other);', stack_router)
        self.assertIn('if(!(sortItem != null && (current == sortItem) != (rel == rotation)) && !(rel == (rotation + 2) % 4) && other.team == team && other.acceptItem(this, current)){', stack_router)
        self.assertIn('var target = target();', stack_router)
        self.assertIn('while(target != null && items.get(current) > 0){', stack_router)
        self.assertIn('target.handleItem(this, current);', stack_router)
        self.assertIn('public int size = 1;', stack_router)
        # DESIGN DECISIONS (verified, not guessed): the
        # BeamDrill world_tiles convention carries {solid,
        # wall_drop} per tile (SourceBeamDrillBuildState.gd:
        # 392) and NO team or acceptItem field -- so the
        # team + accepts answers ride caller-supplied maps
        # (the N2459 wall_attribute_by_tile precedent):
        # team_map Dict "x,y" -> team (its presence IS the
        # building signal -- a team only exists on a placed
        # building) and accepts_map Dict "x,y" -> bool (the
        # neighbour acceptItem(this, current) answer for the
        # router's current item; a missing key rejects).
        # A ring tile yields an entry only when the tile is
        # known (world_tiles Dict entry -- a missing key is
        # a null tile, the BeamDrill precedent) AND a
        # building stands there (team_map key) AND its team
        # matches the router (the Java same-team filter).
        # The id is the ring tile's "x,y" key (the port
        # cell_key format, SourceWorldGrid.gd). The fill
        # never reads the solid flag (a neighbour building
        # is not a wall tile).
        self.assertIn('team_map', stack_router)
        self.assertIn('accepts_map', stack_router)
        self.assertIn('team_by_tile', stack_router)
        self.assertIn('accepts_item_by_tile', stack_router)
        self.assertIn('tile producer', stack_router)
        # The fill generates the Edges ring inline (bot/top
        # + 4*size points, normalized-angle sort -- the
        # shared helper sorts unnormalized atan2 and puts
        # south first, Java puts east first), walks it in
        # ring order, applies the null-tile / building /
        # same-team gates, computes rel from the ring
        # offset, and builds one N2324-shaped dict per
        # neighbour -- only neighbours that pass all three
        # gates are listed (an empty ring yields []).
        self.assertIn('var ring_index: int = size - 1', stack_router)
        self.assertIn('var bot: int = -int(float(ring_index) / 2.0) - 1', stack_router)
        self.assertIn('var top: int = int(float(ring_index) / 2.0 + 0.5) + 1', stack_router)
        self.assertIn('offsets.append(Vector2i(bot + 1 + j, bot))', stack_router)
        self.assertIn('offsets.append(Vector2i(bot + 1 + j, top))', stack_router)
        self.assertIn('offsets.append(Vector2i(bot, bot + j + 1))', stack_router)
        self.assertIn('offsets.append(Vector2i(top, bot + j + 1))', stack_router)
        self.assertIn('rad_to_deg(atan2(float(a.y), float(a.x)))', stack_router)
        self.assertIn('angle_a += 360.0', stack_router)
        self.assertIn('angle_b += 360.0', stack_router)
        self.assertIn('var key: String = str(rx) + "," + str(ry)', stack_router)
        self.assertIn('world_tiles.get(key, null)', stack_router)
        self.assertIn('team_map.has(key)', stack_router)
        self.assertIn('if neighbour_team != team:', stack_router)
        self.assertIn('if abs(dx) > abs(dy):', stack_router)
        self.assertIn('rel = 0 if dx > 0 else 2', stack_router)
        self.assertIn('{"id": key, "rel": rel, "team": neighbour_team, "accepts_item": bool(accepts_map.get(key, false))}', stack_router)
        self.assertIn('"proximity_neighbours": proximity_neighbours', stack_router)
        self.assertIn('if size < 1:', stack_router)
        # The fill is called exactly once (its definition
        # plus the one tick call site), with the frame tile
        # map, the origin cell inline (cell is bound after
        # the enabled block, the N2363 note), the catalog
        # size, the live team_id, and the caller-supplied
        # team / accepts maps. The local is
        # neighbours_filled -- NOT `filled` (the N2416
        # duplicate-var lesson: the driver already binds
        # `filled` nowhere here, but the name stays distinct
        # by rule).
        self.assertEqual(stack_router.count('source_stack_router_proximity_neighbours_live_fill_state('), 2)
        self.assertIn('source_stack_router_proximity_neighbours_live_fill_state(fill_world_tiles, fill_cell, int(block.properties.get("size", 1)), team_id, fill_team_map, fill_accepts_map)', stack_router)
        self.assertIn('var neighbours_filled: Dictionary = source_stack_router_proximity_neighbours_live_fill_state(', stack_router)
        # The tick wires the fill BEFORE the N2324 target
        # list reads the frame array: frame["world_tiles"],
        # frame["team_by_tile"] and frame["accepts_item_by_
        # tile"] default to {} (an empty map fills an empty
        # list, preserving the no-fill behavior). A supplied
        # list WINS (the N2381 precedent -- the N2324 proof
        # seeds proximity_neighbours by hand, so a fill
        # there would overwrite the seed), and a previously
        # live-filled frame (proximity_neighbours_live --
        # port bookkeeping, not Java state, the N2394
        # precedent) refreshes every tick. The existing
        # neighbours read still follows the fill, so the
        # target list reads the filled array.
        self.assertIn('has_supplied_proximity_neighbours', stack_router)
        self.assertIn('frame.get("world_tiles", {})', stack_router)
        self.assertIn('frame.get("team_by_tile", {})', stack_router)
        self.assertIn('frame.get("accepts_item_by_tile", {})', stack_router)
        self.assertIn('frame["proximity_neighbours_live"] = true', stack_router)
        self.assertIn('bool(frame.get("proximity_neighbours_live", false))', stack_router)
        self.assertIn('frame["proximity_neighbours"] = neighbours_filled.get("proximity_neighbours", [])', stack_router)
        self.assertLess(
            stack_router.index('source_stack_router_proximity_neighbours_live_fill_state(fill_world_tiles, fill_cell, int(block.properties.get("size", 1)), team_id, fill_team_map, fill_accepts_map)'),
            stack_router.index('source_stack_router_target_list_state(neighbours, target_current, frame.get("sort_item", null), rotation, team_id, int(frame.get("cdump", 0)), handoff_count)'),
        )
        self.assertLess(
            stack_router.index('frame["proximity_neighbours"] = neighbours_filled.get("proximity_neighbours", [])'),
            stack_router.index('source_stack_router_target_list_state(neighbours, target_current, frame.get("sort_item", null), rotation, team_id, int(frame.get("cdump", 0)), handoff_count)'),
        )
        # The N2324/N2240 pins still hold: the call, the
        # frame-input read, the advance call, the cdump
        # stamp-on-handoff, and the doc strings.
        self.assertIn('frame.get("proximity_neighbours", [])', stack_router)
        self.assertIn('source_stack_router_target_list_state(neighbours, target_current, frame.get("sort_item", null), rotation, team_id, int(frame.get("cdump", 0)), handoff_count)', stack_router)
        self.assertIn('source_stack_router_update_tile_advance_state(frame, SOURCE_STACK_ROUTER_SPEED, SOURCE_STACK_ROUTER_BASE_EFFICIENCY, SOURCE_STACK_ROUTER_ITEM_CAPACITY, targets, item_order)', stack_router)
        self.assertIn('frame["cdump"]', stack_router)
        self.assertIn('target() selection live (N2324)', stack_router)
        self.assertIn('updateTile advance live (N2240)', stack_router)
        self.assertIn('static func source_stack_router_target_list_state', stack_router)
        self.assertIn('static func source_stack_router_update_tile_advance_state', stack_router)
        self.assertIn('static func source_stack_router_accept_item_state', stack_router)
        self.assertIn('static func source_stack_router_tick_buildings_state', stack_router)
        # The documented limits now record the live
        # proximity query as live (N2472).
        self.assertIn('live proximity query is live since N2472', stack_router)
        # Scope pins, by Java line number: updateProximity
        # (BuildingComp.java:1879-1903), relativeTo (:530-
        # 540), the proximity/tmpTiles fields (:67/:55), the
        # Edges ring generation (:23-40) + getEdges (:75),
        # the target gate (DuctRouter.java:139-148), the
        # unload loop (StackRouter.java:47-52 -- the trailing
        # target() call is :52, not :51: line 51 is blank),
        # the angle normalization (arc Mathf.java:98-102),
        # the d4 order (arc Geometry.java:9-14/23-24) and
        # the Block size default (Block.java:215).
        building_comp_lines = BUILDING_COMP_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(building_comp_lines[54].strip(), 'static final ObjectSet<Building> tmpTiles = new ObjectSet<>();')
        self.assertEqual(building_comp_lines[66].strip(), 'transient Seq<Building> proximity = new Seq<>(true, 6, Building.class);')
        self.assertEqual(building_comp_lines[529].strip(), 'public byte relativeTo(Building build){')
        self.assertEqual(building_comp_lines[530].strip(), 'if(Math.abs(x - build.x) > Math.abs(y - build.y)){')
        self.assertEqual(building_comp_lines[531].strip(), 'if(x <= build.x - 1) return 0;')
        self.assertEqual(building_comp_lines[532].strip(), 'if(x >= build.x + 1) return 2;')
        self.assertEqual(building_comp_lines[534].strip(), 'if(y <= build.y - 1) return 1;')
        self.assertEqual(building_comp_lines[535].strip(), 'if(y >= build.y + 1) return 3;')
        self.assertEqual(building_comp_lines[1878].strip(), 'public void updateProximity(){')
        self.assertEqual(building_comp_lines[1882].strip(), 'Point2[] nearby = Edges.getEdges(block.size);')
        self.assertEqual(building_comp_lines[1884].strip(), 'Building other = world.build(tile.x + point.x, tile.y + point.y);')
        self.assertEqual(building_comp_lines[1886].strip(), 'if(other == null || other.team != team) continue;')
        self.assertEqual(building_comp_lines[1888].strip(), 'other.proximity.addUnique(self());')
        self.assertEqual(building_comp_lines[1893].strip(), '//using a set to prevent duplicates')
        self.assertEqual(building_comp_lines[1895].strip(), 'proximity.add(tile);')
        edges_lines = EDGES_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(edges_lines[22].strip(), 'int bot = -(int)(i / 2f) - 1;')
        self.assertEqual(edges_lines[23].strip(), 'int top = (int)(i / 2f + 0.5f) + 1;')
        self.assertEqual(edges_lines[30].strip(), 'edges[i][idx++] = new Point2(bot + 1 + j, bot);')
        self.assertEqual(edges_lines[32].strip(), 'edges[i][idx++] = new Point2(bot + 1 + j, top);')
        self.assertEqual(edges_lines[34].strip(), 'edges[i][idx++] = new Point2(bot, bot + j + 1);')
        self.assertEqual(edges_lines[36].strip(), 'edges[i][idx++] = new Point2(top, bot + j + 1);')
        self.assertEqual(edges_lines[39].strip(), 'Arrays.sort(edges[i], (e1, e2) -> Float.compare(Mathf.angle(e1.x, e1.y), Mathf.angle(e2.x, e2.y)));')
        self.assertEqual(edges_lines[74].strip(), 'public static Point2[] getEdges(int size){')
        duct_router_lines = DUCT_ROUTER_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(duct_router_lines[138].strip(), 'public Building target(){')
        self.assertEqual(duct_router_lines[144].strip(), 'Building other = proximity.get((i + dump) % proximity.size);')
        self.assertEqual(duct_router_lines[145].strip(), 'int rel = relativeTo(other);')
        self.assertEqual(duct_router_lines[147].strip(), 'if(!(sortItem != null && (current == sortItem) != (rel == rotation)) && !(rel == (rotation + 2) % 4) && other.team == team && other.acceptItem(this, current)){')
        stack_router_lines = STACK_ROUTER_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(stack_router_lines[46].strip(), 'var target = target();')
        self.assertEqual(stack_router_lines[48].strip(), 'target.handleItem(this, current);')
        self.assertEqual(stack_router_lines[51].strip(), 'target = target();')
        mathf_lines = MATHF_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(mathf_lines[97].strip(), 'public static float angle(float x, float y){')
        self.assertEqual(mathf_lines[98].strip(), 'float result = atan2(x, y) * radDeg;')
        self.assertEqual(mathf_lines[99].strip(), 'if(result < 0) result += 360f;')
        geometry_lines = GEOMETRY_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(geometry_lines[8].strip(), 'public final static Point2[] d4 = {')
        self.assertEqual(geometry_lines[22].strip(), 'public final static int[] d4x = {1, 0, -1, 0};')
        self.assertEqual(geometry_lines[23].strip(), 'public final static int[] d4y = {0, 1, 0, -1};')
        block_lines = BLOCK_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(block_lines[214].strip(), 'public int size = 1;')
        # The proof's keys drive the fill (ring order at
        # size 1 + size 2, rel values incl. the diagonal
        # y-branch rule, the same-team gate, the accepts
        # map + the N2324 composition, supplied-wins) plus
        # the live tick (a live surge-router with seeded
        # ring maps hands 10 copper off in target-list
        # order and stamps cdump).
        proof = STACK_ROUTER_LIVE_PROXIMITY_QUERY_PROOF.read_text(encoding='utf-8')
        for key in [
            'query_ring_order',
            'query_rel_values',
            'query_team_gate',
            'query_accepts_map',
            'query_supplied_wins',
            'query_live_tick',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        for line in proof.splitlines():
            if 'preload("res://' in line:
                res_path = line.split('preload("res://', 1)[1].split('"', 1)[0]
                with self.subTest(preload=res_path):
                    self.assertTrue((ROOT / 'godot-mindustry' / res_path).is_file(), res_path)
        self.assertIn('preload("res://src/game/SourceStackRouterBuildState.gd")', proof)
        self.assertTrue(STACK_ROUTER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('stack_router_build_state.source_stack_router_proximity_neighbours_live_fill_state(', proof)
        self.assertIn('stack_router_build_state.source_stack_router_target_list_state(', proof)
        self.assertIn('stack_router_build_state.source_stack_router_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = STACK_ROUTER_LIVE_PROXIMITY_QUERY_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07StackRouterLiveProximityQueryProof.gd', scene)
        self.assertIn('C07StackRouterLiveProximityQueryProof', scene)

    def test_reference_graph_and_actual_c07_stack_router_live_proximity_query(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07StackRouterLiveProximityQueryProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_STACK_ROUTER_LIVE_PROXIMITY_QUERY_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'query_ring_order',
            'query_rel_values',
            'query_team_gate',
            'query_accepts_map',
            'query_supplied_wins',
            'query_live_tick',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
