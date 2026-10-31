# Rà soát BuildingComp.updateConsumption — 2026-10-31

> **Resolution — 2026-10-31, N1989–N1990:** consumption audit findings are addressed at the registered state/runtime boundary. Full suite: 5341 passed / 22534 subtests; validator: 0 errors / 113 modules; native proof: 21 cases match, 0 actual runtime errors (25 existing compiler warnings retained). UC-A–UC-D accepted; full Mindustry parity is not claimed. See [remediation evidence and handoff](C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/docs/superpowers/reports/2026-10-31-building-consumption-remediation.md). Historical audit/checkpoint text below is preserved.

## Kết luận và phạm vi

**Chưa đạt mục tiêu một canonical owner cho toàn bộ luồng `updateConsumption()`. Nên xử lý các checkpoint bên dưới trước khi mở gameplay slice phụ thuộc vào consumption.**

Các delegate theo từng đoạn đã tồn tại và gate cấu trúc vẫn xanh. Tuy nhiên, đường chạy đủ tham số vẫn chứa logic song song trong generated code, có lỗi runtime khi ghép các đoạn, và có một công thức canonical lệch upstream. Vì vậy, nhận định N1988 rằng generated chỉ còn chuẩn hóa input và dispatch multiplier là quá rộng.

Đây là audit cụm consumption tại HEAD `e78f31cb` cùng working tree hiện tại, không phải audit toàn bộ game. Không sửa production code, emitter, SSOT hay assertion để làm gate xanh. Không mở gameplay slice mới, không thay đổi trạng thái accepted lịch sử của CP0/CP1. Các phát hiện bổ sung giới hạn cho tuyên bố parity của cụm này.

Working tree đã có nhiều thay đổi trước audit; riêng `SourceBuildingEfficiencyState.gd` có diff `96 additions / 76 deletions` so với HEAD. Những thay đổi đó không được tạo hoặc hoàn nguyên trong audit này. Kết quả phản ánh working tree được đọc/chạy, không quy toàn bộ lỗi cho riêng commit N1988.

## Kết quả kiểm tra hiện tại

| Kiểm tra | Kết quả | Ý nghĩa |
| --- | --- | --- |
| Cross-catalog validator | 0 errors | Linkage/owner/schema metadata hợp lệ theo validator hiện tại |
| JSON mirror | 113 modules / 0 errors | Không phát hiện lỗi mirror |
| Targeted Python | 40 passed, 7 subtests passed; 2895 deselected | Gate hiện tại chưa bắt được các lỗi hành vi bên dưới |
| Existing BuildingEfficiencyStateModuleProof, khởi chạy qua Godot MCP | Artifact `matches=true`, registry valid, one headquarter per SSOT | Proof các boundary riêng lẻ vẫn xanh |
| Probe độc lập, Godot 4.6.2 headless | 9 so sánh: 2 khớp, 7 lệch; 2 SCRIPT ERROR | Tái hiện arithmetic mismatch, lỗi ghép optional rows và fallback không thống nhất |
| Full Python suite trong audit | Không chạy lại | Mốc N1988 `5337 passed / 22504 subtests` là kết quả lịch sử, không phải xác minh mới |

Existing proof tự thoát trước khi MCP debug-output được đọc; tool trả `No active Godot process`. Artifact mới được sao lưu, nhưng audit **không xác nhận empty debug errors qua MCP**. Probe độc lập là chẩn đoán headless và cố ý ghi nhận lỗi; không dùng nó làm acceptance runtime theo AGENTS.md. Exit code 0 của probe chỉ có nghĩa script chẩn đoán chạy đến cuối, không có nghĩa parity pass.

Evidence nằm trong [thư mục evidence](C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/docs/superpowers/reports/evidence/2026-10-31-building-consumption-audit): `probe.gd`, `probe.log`, `validator.log`, `focused-tests.log`, `existing-proof.json`.

## F1 — P1: potentialEfficiency bị scale sai trong canonical initial/cheating

**Vị trí:** [SourceBuildingEfficiencyState.gd:93](C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/src/game/SourceBuildingEfficiencyState.gd:93).

Upstream [BuildingComp.java:1931](C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java:1931) chỉ nhân `efficiency` và `optionalEfficiency` trong `updateEfficiencyMultiplier()`. Nhánh initial ở dòng 1945 gán `potentialEfficiency` từ enabled/productionValid rồi gọi multiplier; multiplier không thay đổi potential.

Canonical hiện trả `potential_efficiency * efficiency_scale`. Đây là lỗi hành vi trong helper, không chỉ thiếu delegation.

Với enabled=true, productionValid=true, shouldConsume=true:

| Scale | Potential theo Java | Potential thực tế | Efficiency/optional thực tế |
| --- | --- | --- | --- |
| 0 | 1 | 0 | 0 / 0 |
| 0.5 | 1 | 0.5 | 0.5 / 0.5 |
| 1 | 1 | 1 | 1 / 1 |
| 2 | 1 | 2 | 2 / 2 |

Nhánh cheating với scale=2 cũng trả potential=2 thay vì 1. Scale=0 có thể làm `can_consume_state(potential_efficiency)` trả false dù Java vẫn giữ potential=1. Audit chưa chứng minh đường mutate state gameplay trực tiếp, nên đây là ảnh hưởng tại API state đã tái hiện, chưa phải kết luận toàn bộ gameplay bị lỗi.

SSOT đã đăng ký `efficiency_scale` như input upstream `efficiencyScale()`; schema `source_building_update_consumption_initial_result.potential_efficiency` cũng trích đúng phép gán upstream. Không có cơ sở để giới hạn scale=1 nhằm tránh sửa lỗi.

## F2 — P1: optional rows đổi kiểu khi đi qua boundary, gây SCRIPT ERROR

**Vị trí:** [BuildingComp.gd:1603](C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd:1603), [emitter.py:4250](C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/tools/mindustry_godot_transpiler/mindustry_port/emitter.py:4250), [canonical optional helper:118](C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/src/game/SourceBuildingEfficiencyState.gd:118).

Canonical optional pass đọc dictionary row qua `.get("efficiency", .get("result", 1.0))`. Existing runtime proof dùng rows `[{"result": 0.75}, {"result": 0.5}]`. Callback với 8 args trả canonical kết quả đúng.

Khi tiếp tục cùng rows đó với 9 hoặc 11 args, callback chạy legacy loop `float(result)` trên dictionary. Cả hai lần Godot báo:

```text
SCRIPT ERROR: Invalid call. Nonexistent 'float' constructor.
at: java_method_updateConsumption_194 (.../BuildingComp.gd:1608)
```

Result nhận được là null. Các bridge efficiency/second-pass hiện truyền `[optional_efficiency]` hoặc `[efficiency]` dạng số nên đi qua legacy loop, che khuất lỗi ghép dictionary. Hai quy ước input này chưa tạo thành một pipeline canonical thống nhất.

**SSOT cần làm rõ:** contract hiện chỉ khai báo `Array`, schema mô tả iteration results, chưa định nghĩa rõ shape phần tử được chấp nhận. Không được chữa bằng cách tiếp tục giữ hai kiểu dữ liệu ngầm hoặc thêm alias tùy tiện. Phải chọn representation có evidence, đăng ký shape/normalization tại boundary và dùng nhất quán giữa bridge, helper, emitter, generated và proof.

## F3 — P2: toàn bộ luồng vẫn có nhiều nơi sở hữu cùng logic

**Vị trí:** [BuildingComp.gd:1591](C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd:1591), [emitter.py:4240](C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/tools/mindustry_godot_transpiler/mindustry_port/emitter.py:4240).

| Phần hành vi | Canonical hiện có | Phần vẫn inline trong generated |
| --- | --- | --- |
| Setup | `update_consumption_setup_state` | Tự tính `should_consume_state and production_valid` |
| Non-optional aggregation | `update_consumption_non_optional_pass_state` | Tự lặp consumer, tính min và power gate |
| Optional aggregation | `update_consumption_optional_pass_state` | Tự lặp, ép float bằng quy ước khác |
| Efficiency / potential / no-update | `update_consumption_efficiency_state` | Lặp lại assignment, min và zeroing khi chạy đến cuối |
| Multiplier | `update_efficiency_multiplier_state` | Dispatch đến helper đã có, nhưng initial branch còn tự nhân riêng |
| Second pass | `update_consumption_second_pass_state` | Tạo `updated_consumers` bằng vòng lặp, sau đó bỏ kết quả và gọi helper lặp lại |

Ở boundary non-optional, generated chạy vòng lặp trước rồi canonical chạy lại. Ở second-pass, generated cũng tạo trace trước rồi helper tạo lại. Chưa có bằng chứng consumer thật bị update hai lần: code hiện tạo trace dictionary, không gọi `cons.update(self())` trực tiếp. Nhưng đây là trùng owner hành vi và chi phí xử lý thừa, trái mục tiêu canonical.

Đã tái hiện một hệ quả khác: row `{"efficiency": 0.5, "is_power": false}` cho min=0.5 ở helper riêng, nhưng cho min=0 trong callback composed vì generated chỉ đọc `result`, fallback=0. SSOT chưa khai báo row alias đủ rõ, nên đây được phân loại là **bất nhất normalization/fallback**, không tự khẳng định alias `efficiency` bắt buộc phải được hỗ trợ công khai.

Registry không báo duplicate owner vì cùng hành vi bị chép trong thân hàm không đồng nghĩa với hai registration trùng canonical key. Validator xanh không chứng minh đã hết code trùng.

## F4 — P2: proof dùng cùng implementation làm expected, bỏ lọt lỗi

**Vị trí:** [bridge second-pass:252](C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/src/game/SourceBuildingEfficiencyState.gd:252), [runtime proof:12](C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/BuildingEfficiencyStateModuleProof.gd:12), [delegate tests:14](C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/tools/mindustry_godot_transpiler/tests/test_building_update_consumption_generated_delegate.py:14).

- Initial proof chỉ dùng scale=1 và so sánh generated với chính canonical helper đang được delegate. Hai bên có thể cùng sai như F1.
- Second-pass bridge đọc `result_efficiency` từ generated rồi dùng giá trị đó để tạo expected canonical. Sai min/multiplier vẫn có thể làm hai bên khớp.
- Optional dictionary chỉ được thử ở boundary 8 args; các boundary sau truyền numeric arrays khác kiểu. Không có bài kiểm tra ghép cùng dữ liệu đi xuyên suốt.
- Python delegate tests kiểm tra sự hiện diện của lệnh `return helper(...)` và vắng inline metadata, chưa cấm các vòng lặp/công thức trùng ở trước lệnh return.

Cần giữ test delegate để kiểm tra kiến trúc, đồng thời bổ sung expected độc lập dựa Java cho arithmetic, state và thứ tự side effect. Không lấy actual làm đầu vào cho expected. `matches=true` hiện chỉ đủ chứng minh các wrapper được thử khớp helper tương ứng.

## F5 — giới hạn migration: stage traces chưa phải live consumption hoàn chỉnh

**Vị trí:** [BuildingComp.gd:2025](C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd:2025), [second-pass state:134](C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/src/game/SourceBuildingEfficiencyState.gd:134).

`java_method_update_217()` tạo marker `update_consumption_called=true`, không thực sự gọi callback consumption tại vị trí này. `consume_state` và second-pass tạo trace `consumer/self`, không thực thi consumer thật.

Ở đường 11 args, generated tính `should_consume_power`, `potential_efficiency`, `optional_efficiency` nhưng return cuối chỉ giữ state second-pass. Probe no-update cho efficiency=0 và update_count=0, nhưng không có potential, optional hay power trong result cuối. Contract second-pass hiện chỉ yêu cầu traces/count; vì vậy **không tự coi thiếu các field đó là vi phạm contract second-pass**. Nó cho thấy chưa có surface tổng hợp đầy đủ để chứng minh trạng thái Java sau toàn phương thức.

Cần xác định và đăng ký rõ ranh giới giữa: pure state calculation → state application → consumer dispatch. Tái dùng module/registry hiện hữu. Nếu live dispatch chưa thuộc phạm vi, ghi deferred với evidence và acceptance riêng; không gọi marker/trace là full gameplay parity.

## Kế hoạch sửa theo module và checkpoint

Các nhãn UC-A đến UC-D dưới đây là checkpoint audit, **không tự đăng ký slice ID mới**. Agent triển khai cần chọn ID theo ledger hiện tại sau khi đọc SSOT/checklist. Không tăng số slice chỉ để tách từng dòng assignment thành helper mới.

### UC-A — Khóa ngữ nghĩa input/output và RED thực sự

Owner: domain `SourceBuildingEfficiencyState` và contracts/schema hiện có.

1. Đọc lại design, 5 SSOT roots, manifest/shards liên quan và Java 1931–2003.
2. Chốt một consumer-result row representation dựa source và existing registered contracts. Làm rõ aliases/defaults; không dùng một fallback ở helper và fallback khác ở emitter.
3. Định nghĩa boundary stage API so với kết quả toàn phương thức. Không ngầm dùng số lượng args như bằng chứng complete Java method.
4. Viết RED cho F1/F2, normalization consistency và complete-path behavior. Expected không phụ thuộc generated result.

**Checkpoint:** RED fail vì arithmetic, float(dictionary) hoặc output/state mismatch thật; không phải vì import/path. Có bản đồ input/state/consumer side effect, canonical owner duy nhất cho từng hành vi.

### UC-B — Sửa canonical domain và orchestration thành một cụm nhất quán

Owner: module domain hiện hữu; generated là adapter. Không tạo một file helper cho mỗi return boundary.

1. Sửa potential theo Java, tái dùng multiplier canonical cho đúng các field cần scale.
2. Dùng kết quả canonical setup/non-optional/optional/efficiency xuyên suốt luồng đầy đủ; truyền power/potential/optional đến đúng state boundary.
3. Xóa các vòng lặp và công thức song song khỏi emitter, rồi regenerate. Không chỉnh generated bằng tay.
4. Bỏ `updated_consumers` tính rồi vứt và các biến chết; giữ thứ tự Java: aggregate → assign potential → no-update zeroing → multiplier → second pass.
5. Nếu cần API tổng hợp mới, chỉ thêm khi thiếu abstraction thực sự; đăng ký contract/schema/owner/source evidence cùng thay đổi. Không tái sử dụng second-pass stage để giả làm complete result.

**Checkpoint:** toàn bộ pipeline dùng cùng representation; F1/F2 GREEN; không còn aggregation/no-update/consumer loop do generated tự sở hữu. Bridge và registry không sinh thêm owner đồng nghĩa.

### UC-C — Chứng minh độc lập và nêu rõ state application

Owner: runtime proof và bridge của domain; không dựng một production implementation thứ hai trong test.

Ma trận tối thiểu gồm:

| Nhóm | Trường hợp phải chứng minh |
| --- | --- |
| Initial / cheating | scale 0, 0.5, 1, 2; enabled/disabled; productionValid; shouldConsume |
| Consumer aggregation | Không consumer; một/nhiều consumer; optional thấp/cao hơn min; cùng input xuyên các boundary |
| Power | Consumer không phải power bằng 0/ở ngưỡng; power bằng 0; giữ đúng shouldConsumePower |
| No-update | shouldConsume=false hoặc productionValid=false: efficiency/optional=0, potential giữ min, không update consumer |
| Multiplier / second pass | Scale=0 ngăn second-pass dù update=true; scale khác 1 áp dụng đúng trước guard; đúng số lượng, thứ tự consumer và self |
| Integration | State application/dispatch được chạy thật, hoặc deferred được ghi rõ; marker không được tính là execution |

**Checkpoint:** expected arithmetic/state từ Java, không lấy actual làm expected; lỗi GDScript làm proof fail rõ ràng. Chạy Godot MCP trên đúng checkout, đọc debug output trước khi scene tự thoát hoặc giữ scene sống đủ để đọc; sau đó stop project, errors phải rỗng. Probe chẩn đoán hiện tại không phải test GREEN và không thay thế proof này.

### UC-D — Acceptance và handoff

1. Targeted tests, regenerate/mirror, validator toàn catalog đều xanh.
2. Full Python/JSON gate hoàn tất, lưu output mới; không dùng lại số test lịch sử để accept thay đổi mới.
3. Godot parse và MCP runtime matrix đạt, debug errors rỗng.
4. Diff gate, cập nhật checklist/ledger/report theo kết quả thực; stage đúng file của cụm, bảo toàn workspace noise.
5. Chỉ accept cụm consumption sau UC-A/B/C/D. Gameplay slice phụ thuộc chỉ bắt đầu sau acceptance; các module độc lập không mặc nhiên bị kết luận lỗi từ audit hẹp này.

## Cách tái hiện

Tại repository root:

```powershell
python -m pytest -q -p no:cacheprovider tools/mindustry_godot_transpiler/tests/test_building_update_consumption_generated_delegate.py tools/mindustry_godot_transpiler/tests/test_emitter.py tools/mindustry_godot_transpiler/tests/test_playable.py -k "update_consumption or source_building_efficiency_state_module_has_runtime_proof" --tb=short

$auditGodot = Get-Command Godot_v4.6.2-stable_win64_console.exe -CommandType Application | Select-Object -First 1 -ExpandProperty Source
& $auditGodot --headless --path godot-mindustry --script "$PWD/docs/superpowers/reports/evidence/2026-10-31-building-consumption-audit/probe.gd"

python -c "from pathlib import Path; import sys; sys.path.insert(0, 'tools/mindustry_godot_transpiler'); from mindustry_port import source_symbols; r=source_symbols.validate_source_catalog(Path('godot-mindustry')); print('errors',len(r['errors']),'modules',r['json_module_count'],'json_errors',len(r['json_errors'])); print(r['counts'])"
```

Probe chứa giá trị kỳ vọng cố định từ các phép gán Java để làm oracle chẩn đoán. Những literal này nằm trong evidence, không được chuyển thành hardcode production. Probe intentionally finish với exit 0 dù có mismatch để thu đủ các case; đọc `matches` và SCRIPT ERROR trong log.
