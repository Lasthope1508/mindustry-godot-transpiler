# Mục tiêu sau cùng — Mindustry Java → Godot GDScript

Tài liệu này là la bàn cho mọi agent làm việc trên repo này. Đọc nó trước khi
làm bất cứ slice nào. Nếu một quyết định đi ngược tài liệu này, dừng lại và
hỏi user.

## 1. Mục tiêu sau cùng

Port **toàn bộ hành vi Java của Mindustry sang GDScript/Godot một cách chính
xác (faithful)**, chơi được, kiểm chứng được, và phát hành được. Nghĩa là đi
hết **C01–C12** trong
`docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md`, kết
thúc ở **C12: clean-checkout regeneration + release candidate**.

Đích đến không phải "nhiều slice xong" mà là: game chạy đúng như Java gốc,
gate đầy đủ xanh, checkout sạch regenerate được, và có bản release.

## 2. Không phải mục tiêu (đã chốt với user, 2026-11-13)

**Không** biến repo này thành thư viện component generic để tách ra làm nhiều
game khác. Đó là một hướng khác, cần thiết kế lại từ đầu (interface ổn định
có version, cắt coupling với game object/frame system, trừu tượng hóa
semantics riêng của Mindustry thành mô hình chung). Chỉ xem xét hướng đó
**sau khi** port xong và nghiệm thu xong. Trong lúc port, không hy sinh
fidelity để lấy reusability.

## 3. Kế hoạch — C01–C12 (backlog)

| Chương | Nội dung | Trạng thái (2026-11-13) |
| --- | --- | --- |
| C01 | Ore selection / proximity (Drill) | Đường chính chạy được; complete lifecycle còn mở |
| C02 | Output / dump / transport theo Building | Primary có đường composition cũ; secondary còn local fallback |
| C03 | Power consumer và Drill dùng điện | Có state power riêng; đang nối consumer thật vào live path (C07 tiếp nối) |
| C04 | Liquid supply / flow / capacity / persistence | Kho và remove thật đã có; flow null |
| C05 | Consumer initialization, rules và reload | Direct single-liquid subset đã nối; mixed/inherited/dynamic chưa đóng |
| C06 | Vòng factory → core → defense chạy hoàn chỉnh | **ĐÓNG** (N2139) |
| C07 | Units, waves, world và campaign | **ĐANG LÀM** — power.status live read, family by family |
| C08 | Generated semantics / unsupported ledger | Chưa bắt đầu (5.390 hàm null-body chưa phân loại — xem §6) |
| C09 | Facade / bridge và SSOT quality | Chưa bắt đầu |
| C10 | Save / load / network | Chưa bắt đầu |
| C11 | Presentation, ổn định và hiệu năng | Chưa bắt đầu (có playable shell) |
| C12 | Clean reproducibility và release | Chưa bắt đầu |

Thứ tự làm việc: theo backlog và mục "Next" trong handoff mới nhất
(`docs/superpowers/handoffs/`). Khi trống task, tự làm slice tiếp theo, không
đợi user giao.

## 4. Tiến độ hiện tại (2026-11-13 ~11:52 +07)

- Main trên fork ở `a3c01eb` (N2149 BurstDrill power.status DONE + PUSHED).
- **N2150 SolidPump power.status (water-extractor): GREEN xong** (targeted
  4/4, Godot proof 9 key xanh, SSOT 11310/1601/1522/2835 trên disk) — đang
  chờ neighbours xanh rồi launch gate, sau đó mới commit + push.
- Sau N2150: PointDefenseTurret (segment) / TractorBeamTurret (parallax)
  power.status, rồi các mục deferred (spawn_occupied, allow_update,
  moveOutPayload, net drone sync, turret ammo/nitrogen rows, shouldConsume
  gates, updateTile advances).
- Repo làm việc là fork `Lasthope1508/mindustry-godot-transpiler`
  (`origin` = fork, `upstream` = `duynguyen16689/mindustry-godot-transpiler`).
  Local worktree: `~/workspace/mindustry-godot-transpiler`.

## 5. Quy trình slice (bắt buộc, theo `AGENTS.md`)

Đọc design spec + 5 file SSOT + manifest/shards + upstream Java chính xác →
RED tests → GREEN → targeted → neighbours → Godot proof → full gate → report
+ spec + handoff → `git diff --check` → stage đúng file của slice → commit
theo mẫu 3 commit (slice / docs / handoff-hash) → push lên origin main.

Một slice chỉ được push khi **tests + Godot proof + gate đều xanh**. Không
commit/push slice chưa đủ điều kiện.

## 6. Những điều không được hiểu sai

- **Ledger không phải tiến độ tổng.** Ledger chỉ đếm slice đã đăng ký
  (`Done 1600 / Not done 0` không liệt kê phương thức upstream chưa di cư).
  **Không tính % parity từ số file parse, số test hoặc số slice** (backlog
  cấm điều này). Muốn ước lượng phần còn lại thì phải chạy inventory C08:
  quét lại 5.390 hàm null-body, phân loại source-empty / deferred / việc
  thật — làm sau N2150 hoặc khi user yêu cầu, không làm giữa slice.
- **Game giữ nguyên như nó vốn có.** Chỉ sửa proof/test harness để proof
  không fail về mặt kỹ thuật/code; không bao giờ đụng gameplay.
- **Báo cáo 15 phút 1 lần** bằng tiếng Việt, ngắn gọn, số liệu đã kiểm chứng.
  Khi không có thay đổi thì báo ngắn gọn là không có thay đổi, đừng bịa tiến
  độ.
- **Port 7777:** không chạy proof scene song song với gate hay với agent
  khác đang dùng Godot; check port trống trước mỗi proof run. Port bận sẽ
  in `ERROR:` vào output scene và làm fail proof test — đó là lỗi môi
  trường, không phải lỗi code.
- **VM restart xóa javalang** (cài system-wide, `/usr/local` là tmpfs):
  sau restart phải cài lại (`pip install --break-system-packages -r
  tools/mindustry_godot_transpiler/requirements.txt` từ repo root) trước mọi
  gate.
- **Gate chỉ launch từ main thread** (backgrounded `&&` chain, `setsid
  nohup`): gate launch từ worker/cron session **chết khi session end** (đã
  xảy ra ở N2146, N2147, N2149). Sau khi launch, ghi PID + attempt vào
  handoff ngay.
- **Không stage:** `*.gd.uid`, `godot-mindustry/project.godot`,
  `arc-upstream/`, `mindustry-upstream/`, proof `.json`, gate logs
  (`full-suite-*.log`, `targeted-env-fix.log`). Không bao giờ `git add .`.
- **Browser login dùng Chrome của user**, không dùng in-app browser.
- **Worker/cron báo cáo có thể sai hoặc cũ** so với trạng thái live: luôn
  kiểm chứng số liệu quyết định (ps, log tail/mtime, git log/status, SSOT,
  proof JSON, FAIL/ERROR counts) trên worktree thật trước khi báo cáo.

## 7. Đọc trước khi làm

- Tài liệu này (`docs/superpowers/GOAL.md`).
- `AGENTS.md` (house rules).
- Design spec:
  `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`.
- Backlog: `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md`.
- Handoff mới nhất trong `docs/superpowers/handoffs/` (mục "Next" + "Deferred").
- 5 file SSOT + manifest `source_ssot_modules.json` + shards
  (`godot-mindustry/src/generated/`).
- Upstream Java chính xác trong `mindustry-upstream/` (không đoán tên,
  default, hay công thức).
