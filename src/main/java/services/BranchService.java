package services;

import java.util.List;

import models.CinemaBranch;
import models.User;
import repositories.CinemaBranches;
import repositories.Users;

public class BranchService {
    private final CinemaBranches branchDao = new CinemaBranches();
    private final Users userDao = new Users();

    public List<CinemaBranch> getAllBranches(String keyword, Boolean isActive, int page, int pageSize) {
        return branchDao.findAll(keyword, isActive, page, pageSize);
    }

    public int countBranches(String keyword, Boolean isActive) {
        return branchDao.countAll(keyword, isActive);
    }

    public CinemaBranch getBranchById(int id) {
        return branchDao.findById(id);
    }

    public void createBranch(CinemaBranch branch) throws Exception {
        validateBranch(branch);
        if (!branchDao.insert(branch)) {
            throw new Exception("Lỗi khi thêm mới vào database");
        }
    }

    public void updateBranch(CinemaBranch branch) throws Exception {
        if (branchDao.findById(branch.getBranchId()) == null) {
            throw new Exception("Chi nhánh không tồn tại");
        }
        validateBranch(branch);
        if (!branchDao.update(branch)) {
            throw new Exception("Lỗi khi cập nhật database");
        }
    }

    public void deleteBranch(int id) {
        branchDao.delete(id);
    }

    public List<User> getAllManagers() {
        return userDao.getAllBranchManagers();
    }

    private void validateBranch(CinemaBranch branch) throws Exception {
        if (branch.getBranchName() == null || branch.getBranchName().trim().isEmpty()) {
            throw new Exception("Tên chi nhánh không được để trống.");
        }

        // Validate Email
        if (branch.getEmail() != null && !branch.getEmail().trim().isEmpty()) {
            if (!branch.getEmail().matches("^[A-Za-z0-9+_.-]+@gmail\\.com$")) {
                throw new Exception("Email không đúng định dạng.");
            }
        }

        // Validate Số điện thoại (Đầu số VN 03, 05, 07, 08, 09 + 8 số)
        if (branch.getPhone() != null && !branch.getPhone().trim().isEmpty()) {
            if (!branch.getPhone().matches("^(84|0[3|5|7|8|9])+([0-9]{8})$")) {
                throw new Exception("Số điện thoại không hợp lệ (Phải là SĐT Việt Nam 10 số).");
            }
        }
    }
}