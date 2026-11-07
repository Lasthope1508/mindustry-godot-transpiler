# Mindustry Godot Transpiler — WIP

Bản source đang phát triển: chuyển hành vi Java của Mindustry sang GDScript/Godot theo từng phần, với registry, schema, hợp đồng API và kiểm thử đối chiếu source.

Đây là bản lưu công việc đang dang dở ngày **2026-11-07**, chưa phải bản phát hành hoàn chỉnh. Bản lưu gồm cả thay đổi chưa được kiểm thử hoàn tất; việc sao lưu lên GitHub không xác nhận mọi test hoặc gameplay đều chạy thành công.

## Cấu trúc

- `godot-mindustry/`: project Godot, scene, asset, runtime GDScript, dữ liệu sinh và công cụ kiểm chứng.
- `tools/mindustry_godot_transpiler/`: công cụ Python và bộ kiểm thử.
- `docs/superpowers/`: thiết kế, kế hoạch, báo cáo, bằng chứng và bàn giao.
- `AGENTS.md`: quy tắc làm việc với source và dữ liệu chuẩn (SSOT).

## Mở project

1. Cài Godot **4.6** và Python 3.
2. Mở `godot-mindustry/project.godot` bằng Godot Editor để import asset và đăng ký UID.
3. Chạy scene chính `res://scenes/Main.tscn` bằng F6, hoặc chạy project bằng F5.

Các addon Godot MCP có trong source. Cache `.godot/` không được lưu; Godot sẽ tạo lại khi import. Các file `.gd.uid` được lưu cùng script.

## Source upstream cho công cụ và kiểm thử

Các checkout upstream được loại khỏi repo này. Từ thư mục gốc, lấy đúng revision đang dùng:

```sh
git clone https://github.com/Anuken/Mindustry.git mindustry-upstream
git -C mindustry-upstream checkout 2bdedfed25932ebf11330d3584092c50e2e26d96
git clone https://github.com/Anuken/Arc.git arc-upstream
git -C arc-upstream checkout f30acd23ece4b626b755660d56c1b0d4aaf46aed
python -m pip install -r tools/mindustry_godot_transpiler/requirements.txt
python -m unittest discover -s tools/mindustry_godot_transpiler/tests
```

Một số công cụ kiểm chứng có cấu hình đường dẫn tuyệt đối hoặc cần Godot/MCP đang chạy; cần chỉnh theo máy sử dụng. Xem `AGENTS.md` và tài liệu trong `docs/superpowers/` trước khi tiếp tục port.

Source và asset có nguồn gốc từ [Mindustry](https://github.com/Anuken/Mindustry) và [Arc](https://github.com/Anuken/Arc); tham khảo giấy phép và thông báo bản quyền tương ứng của upstream.
