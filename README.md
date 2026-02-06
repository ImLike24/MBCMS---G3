# SWP391_2026
SWP391

# PROJECT NAME: Multi-branch Cinema Management System
- Phạm vi: Sẽ có nhiều chi nhánh và nhiều người quản lý

Luồng chính hiện tại:
4 Roles: Guest, Customer, Staff, Manager, Admin
Đăng ký - đăng nhập
- Mua vé: Chọn bộ phim muốn xem -> Chọn Time slots -> Chọn 1 hoặc nhiều ghế trong 1 hall tương ứng với Time Slot đó

# PACKAGE: Noi thu tu
- models: repositories - package đại diện cho cấu trúc database, tạo object java
- repositories: config(DBContext) - package chịu trách nhiệm thao tác đến cơ sở dữ liệu
- services(business): repositories, utils - tách biệt xử lý thao tác phức tạp khỏi controller, nằm giữa controller và repositories
- controller: webapp, services - cầu nối, nhận yêu cầu từ người dùng qua webapp(giao diện) và qua service để xử lý logic 
- utils: package hỗ trợ, đơn giản hóa mã nguồn