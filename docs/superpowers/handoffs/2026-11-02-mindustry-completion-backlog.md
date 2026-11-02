# Backlog hoàn thiện Mindustry → Godot

Ngày kiểm tra: 2026-11-02. Workspace: `C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528`. Parent của checkpoint mới nhất N2011–N2013: `295188b6`. Đọc cùng handoff kiến trúc `2026-09-23-mindustry-godot-ssot-canonical-handoff.md`; tài liệu này cập nhật việc còn thiếu, không thay thế upstream Java hay root SSOT.

## Kết luận và cách hiểu tiến độ

CP0/CP1 đã mở khóa migration. N2007–N2009 đã có adapter liquid thật và tick Drill tự động trong phạm vi không cần điện, footprint một loại quặng, liquid được cấp sẵn. Chưa có bằng chứng nghiệm thu toàn bộ domain Drill, toàn bộ vòng gameplay hay full Mindustry parity.

Ledger chỉ đếm các slice đã đăng ký. `Not done = 0` không liệt kê toàn bộ phương thức upstream chưa di cư; không dùng con số này để tuyên bố hoàn thành game. Không tính phần trăm parity từ số file parse, số test hoặc số slice.

Inventory đọc trực tiếp trong batch N2010:

| Hạng mục | Bằng chứng và giới hạn |
| --- | --- |
| Parser/report hiện lưu | 801/801 Java files, 0 failed, 2.970 assets; đây là coverage cấu trúc |
| Root SSOT sau đăng ký N2010 | 9.904 symbols, 1.465 slices, 1.348 contracts, 2.482 schemas |
| Validator trước full suite N2010 | 0 lỗi, 113 modules, 0 JSON errors |
| Scan cây `src/generated/classes` hiện có | 845 `.gd`, 6.273 hàm `java_method_*`; 5.390 body chỉ có `return null` sau bỏ comment |
| Ý nghĩa null-body | Cần phân loại source-empty/source-null/deferred/unsupported; không tự động coi cả 5.390 là bug hoặc số task còn lại |
| Unsupported report hiện lưu | 6.986 records; không phải 6.986 lỗi độc lập hoặc backlog đã được phân loại lại |
| Audit hiện lưu | legacy owners 0, owner coverage gap 0; function-record accounting gap 17 còn cần đối chiếu cách giải thích aliases/duplicates trước acceptance toàn cục |

Scan 845 file bao gồm toàn bộ cây đang có, chưa chứng minh mọi file nằm trong emission manifest đang dùng. Rà soát stale artifacts là một phần của C08/C12. Inventory và SHA256 của report nằm trong evidence N2010. Các số đếm này có thể thay đổi; chạy lại inventory thay vì sao chép chúng sang báo cáo mới.

## Quy tắc bắt buộc cho mọi task

1. Tối đa 1–3 slice mỗi batch. Chọn một capability/lifecycle thống nhất; không tạo file cho từng key hay từng dòng Java.
2. Tìm owner có sẵn trước. Root SSOT giữ dữ liệu canonical; shards chỉ được regenerate theo manifest. Không thêm registry cạnh tranh, fallback giá trị đoán, block-name allowlist hoặc công thức thứ hai.
3. RED từ hành vi thiếu → focused GREEN → cross-catalog/JSON → full suite hoàn tất → native Godot MCP → inspect/stop → editor parse → deterministic replay → checklist/report → exact stage → commit.
4. Không đổi production code/catalog khi full suite đang chạy. Nếu đổi sau gate, gate bị ảnh hưởng phải chạy lại.
5. Mỗi checkpoint nêu rõ scope, source expressions, owner/input/output, delta SSOT, cases độc lập, log/hashes và phần deferred. Không nâng state-only proof thành live gameplay proof.
6. Giữ các thay đổi có sẵn ngoài phạm vi; không stage cả thư mục generated hoặc dùng `git add .`. Bằng chứng trên working tree không thay thế clean-checkout acceptance.

## Task còn mở theo thứ tự phụ thuộc

Các dòng dưới đây là nhóm công việc, không phải cam kết mỗi nhóm chỉ tốn một slice. `Chưa nghiệm thu` nghĩa là chưa có gate đầy đủ cho cả nhóm, kể cả khi đã có một số state/delegate.

| ID | Nhóm task | Trạng thái hiện tại | Phụ thuộc |
| --- | --- | --- | --- |
| C01 | Ore selection và proximity của Drill | N2010 state và N2011–N2013 typed Item/blocked binding accepted; actual world/proximity/output còn mở | Tile facts + proximity/output |
| C02 | Output/dump/transport theo từng Building | Primary có đường composition cũ; secondary còn local fallback | C01 + Building inventory/neighbor |
| C03 | Power consumer và Drill dùng điện | Có state power riêng; chưa nối consumer thật vào Drill live path | Consumer descriptor + power graph |
| C04 | Liquid supply/flow/capacity/serialization | Kho và remove thật đã có; flow null, cấp nước sẵn trong proof | Building storage + network lifecycle |
| C05 | Complete consumer initialization và mutation | Direct single-liquid subset đã nối; mixed/inherited/dynamic chưa đóng | Block init + C03/C04 |
| C06 | Vòng factory → core → defense chạy hoàn chỉnh | Chưa nghiệm thu chuỗi gameplay đủ các điều kiện nguồn | C01–C05 |
| C07 | Unit/wave/world/campaign đầy đủ | Đã có các slice; chưa có acceptance domain toàn bộ | C06 + lifecycle/controller |
| C08 | Generated semantic coverage và unsupported ledger | Còn nhiều null-body cần phân loại/di cư | Inventory + canonical owners |
| C09 | Thu gọn facade và ownership debt | Có nhiều refactor trong working tree; cần gate theo cluster | Owner inventory + C08 |
| C10 | Save/load/network determinism | Chưa nghiệm thu vòng đời toàn bộ trạng thái mới | C02–C07 |
| C11 | Presentation/UI/audio và hiệu năng runtime | Có playable shell; chưa nghiệm thu toàn cục | Gameplay domains ổn định |
| C12 | Clean-checkout regeneration và release candidate | Working-tree gates đã có; clean reproducibility chưa đóng | C01–C11 hoặc release scope được chốt |

### C01 — hoàn thiện ore selection/proximity

- **Owner:** mở rộng `SourceDrillRuntimeState`; game wiring tại `SourceDrillConsumptionRuntimeState`, tile/content providers giữ ở domain tương ứng.
- **Đã làm trong N2010:** `source_can_mine_state` và `source_count_ore_state`: null/static/drop/tier/blocked guards; sort lowPriority → amount → numeric Item.id; chọn phần tử cuối; empty/reset và Item reference identity. Native/full acceptance của batch được ghi riêng trong report.
- **Đã làm trong N2011–N2013:** numeric Item ID theo typed registration order, effective hardness/lowPriority, metadata blockedItem/blockedItems theo source ancestry và canonical Drill.init/binding. Full/native/editor/replay accepted trong reports/2026-11-02-drill-item-blocked-binding.md.
- **Còn thiếu:** actual `Tile.drop`, `getDrop`, static block và linked footprint; `DrillBuild.onProximityUpdate` assignment/invalidation; actual dominant-item output. C01-A chưa đóng toàn bộ.
- **Không được làm:** lấy thứ tự dictionary làm Item.id; suy static từ có sprite/occupancy; default thiếu thành false/zero; dùng slug để phá hòa; tick quét map thay cho proximity lifecycle rồi gọi đó là parity.
- **Checkpoint C01-A:** typed providers có source evidence và schema; test null/static/missing fields không fabricate value.
- **Checkpoint C01-B:** live mixed-ore placement chọn đúng Item/amount khi ưu tiên, số lượng và ID xung đột; mutate footprint/proximity đổi dominant state đúng, pickup/removal reset đúng.
- **Checkpoint C01-C:** production/offload dùng actual dominant item thay cho `drill_output_item_id` toàn cục. Chứng minh primary và secondary tạo đúng item; không mở mixed-ore gameplay trước gate này.

### C02 — output và transport theo Building

- Reuse `SourceDrillInventoryRuntimeState`, `SourceDrillDumpRuntimeState`, `SourceBuildingItemState` và transport owners hiện có.
- Scope inventory, dump timer, rotation/neighbor context về đúng building origin; bỏ local fallback bằng source offload/dump composition.
- Giữ một inventory owner; không vừa frame-local vừa game-global ghi cùng amount.
- **Gate:** hai Drill, nhiều conveyor/receiver/core, đủ/thiếu/full capacity, output bị chặn, nhiều item; accounting đầu vào/đầu ra và timer đúng. Không sản xuất hai lần trong một frame.

### C03 — power consumer và live power graph

- Reuse `SourceConsumePowerState` và các placed power graph/battery/distribution owners. Descriptor phải lấy usage/capacity/buffered/condition từ source.
- Nối `efficiency(build)` với actual Building power status và `requestedPower` đúng thời điểm `shouldConsumePower`; không đánh dấu power miễn phí khi metadata thiếu.
- Chỉ đưa laser/blast vào live dispatch sau source class/defaults, power state, consumer initialization và production behavior của chúng có đủ evidence.
- **Gate:** power 0/partial/full, battery charge/discharge, connection removal/split, building disabled/full output, nhiều consumer. Đối chiếu tốc độ và resource accounting với upstream, không chỉ xem sprite hoạt động.

### C04 — liquid supply/flow/capacity và persistence

- Reuse LiquidModule frame hiện có; bind static flow cache/timers qua lifecycle source, không tạo cache rỗng giả khi flow hoạt động.
- Nối pump/conduit/Building accept/handle/move với actual storage; kiểm tra capacity, current liquid và dòng chảy giữa buildings.
- **Gate:** pump → conduit → Drill dùng nước tự động; thiếu nguồn hết booster nhưng base Drill vẫn chạy; mixed liquids/rejection/capacity đúng; save/load bảo toàn lượng và source identity.

### C05 — consumer initialization, rules và reload

- Đóng danh sách inherited/mixed/item/power/liquid consumers, filter completeness và unresolved expressions, gồm thorium-reactor.
- Nối actual source multiplier callbacks và live TeamRules cheating, thay current default-only binding đúng lifecycle.
- Descriptor/apply/adapter caches phải invalidate cùng nhau khi Block reinit/reload; không giữ adapter trỏ vào definition cũ.
- **Gate:** thay definition/rules qua lifecycle thật; giữ độc lập storage giữa buildings; classification required/optional/update/ignored đúng cả mixed consumers. Nghiệm thu CP-PO2/CP-PO3 cho toàn scope chỉ sau khi các domain liên quan đóng.

### C06 — vertical gameplay acceptance

- Content load → map → placement → resource supply → mining/crafting → transport → core → ammo/power → targeting/fire/bullet hit → damage/death/reward.
- Mỗi bước phải gọi runtime owner canonical qua game loop thật. UI/preview gọi công thức đúng chưa đủ chứng minh simulation đã nối.
- **Gate:** session thực tế nhiều buildings/units, pause/timeScale/disable/removal, nguồn cạn/output full, deterministic inputs; xác minh inventory, health, production và energy trước/sau. Đóng CP2 cho từng slice và CP3 cho domain sau inventory implemented/deferred/unsupported đầy đủ.

### C07 — units, waves, world và campaign

- Inventory lifecycle/controller/pathfinding/command/weapon/death, wave/spawn/teams, map/world transition và campaign persistence theo upstream.
- **Gate:** domain matrix gồm create/update/remove/team change; campaign reload, win/loss/restart; các trạng thái cũ không rò qua world mới. Chưa dùng số class emitted để suy coverage.

### C08 — generated semantics/unsupported

- Dùng manifest để đối chiếu 845 file thực có với emission hiện dùng; phân biệt stale/unregistered/output hợp lệ trước cleanup.
- Classify từng null-body: source thực sự empty/null, metadata-only, chưa support, hoặc cần di cư; có owner, source anchor và priority theo gameplay dependency.
- Triển khai theo capability trong emitter/metadata rồi regenerate; không sửa generated `.gd` bằng tay hoặc thêm special case cho tên block.
- **Gate:** bảng method-level implemented/deferred/unsupported nhất quán với source; Tier 0→4 có fixtures và runtime conformance; không tính số null-body giảm là semantic acceptance nếu thiếu proof.

### C09 — facade/bridge và SSOT quality

- Lập inventory owner→domain/module, đo delegate chain và duplicate wrappers từ code hiện tại. Gộp theo lifecycle, không tạo chuỗi kế thừa/facade mới chỉ để chia file.
- Đối chiếu function records, canonical aliases, duplicate records và `functionRecordAccountingGap=17` trong audit hiện lưu; xác nhận validator/report giải thích đầy đủ trước gate toàn cục, không tự coi đây là 17 behavior bugs.
- **Gate:** một canonical owner cho từng semantic behavior, wrappers mỏng, no drift/duplicate/alias cycle; existing contracts/runtime proofs còn xanh; không tăng chain debt.

### C10 — save/load/network

- Inventory mọi state mới: Building liquid/consumer bindings, Drill progress/inventory/timers, power graph, rules, units và campaign.
- Serialization chỉ persist source fields; adapter/cache/runtime object identity được rebuild theo lifecycle, không serialize con trỏ scene.
- **Gate:** round trip, revision compatibility, reconnect/world reload, deterministic tick order và authoritative mutations. Unsupported networking phải được khai báo rõ nếu release scope loại trừ nó.

### C11 — presentation, ổn định và hiệu năng

- Map/UI/HUD/input/effects/audio phải đọc canonical state, không sinh simulation riêng.
- Đo startup, memory, frame time, tải generated classes, nhiều Building/units và long-session cleanup; kiểm tra registry không bị scan nặng mỗi frame.
- Native proof hiện lưu còn 66 warnings trong scene Main của batch trước; phân loại và xử lý theo domain, không gọi chúng là zero diagnostics.
- **Gate:** startup/scene reload/stop ổn định, không actual errors/leaks; warning budget được xử lý rõ; có performance budget với workload và môi trường đo cụ thể trước CP4.

### C12 — clean reproducibility và release

- Rà từng phần dirty work có sẵn, gom các thay đổi cần thiết thành commit có review/gates. Không stage toàn bộ noise để làm sạch cây.
- Từ clean checkout: regenerate metadata/content/classes/mirrors → catalog → full tests → editor → native gameplay → build/package. Đối chiếu manifest/stale artifacts và deterministic hashes.
- Cập nhật deferred/unsupported/release scope, GPL/source lineage, asset licenses, upstream pin và instructions build.
- **Gate:** người khác làm lại từ checkout sạch được kết quả tương đương; artifact đúng platform và scope được công bố. CP5 chỉ accepted sau evidence này.

## Handoff bước tiếp theo

1. Đọc report N2010 để biết gate thực tế và commit, không suy từ status trong tài liệu kế hoạch.
2. Tiếp tục **C01-A**: actual world terrain/Tile.drop/static/linked-footprint providers. N2011–N2013 đã có typed Item ID/effective fields và blocked initialization; giữ N2010 là owner sort duy nhất. Không suy static/drop từ ore-name projection thiếu metadata.
3. **C01-B/C**: proximity lifecycle và actual dominant output item. Chỉ sau đó mở live mixed-ore gameplay và chuyển C02.
4. C03/C04/C05 theo dependency; dựng C06 end-to-end proof trước mở thêm domain lớn.
5. C08–C12 tiếp tục theo cluster, có checkpoint riêng. Không tuyên bố full game hoàn thành chỉ vì validator/full Python suite xanh.

## Checkpoint tuần tự mới nhất

N2011–N2013 accepted trong report `2026-11-02-drill-item-blocked-binding.md`. Goal C01–C12 vẫn đang thực hiện tuần tự; chưa nhóm nào được đánh dấu hoàn thiện toàn bộ chỉ từ batch prerequisite này. C01-A tiếp tục tại world tile facts.
