package services;

import models.CinemaBranch;
import models.User;
import repositories.CinemaBranches;
import repositories.Users;

import java.util.List;

public class BranchService {
    private final CinemaBranches branchDao = new CinemaBranches();
    private final Users userDao = new Users();

    public List<CinemaBranch> getAllBranches() {
        return branchDao.findAll();
    }

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
        if (branch.getBranchName() == null || branch.getBranchName().trim().isEmpty()) {
            throw new Exception("Tên chi nhánh không được để trống");
        }
        if (!branchDao.insert(branch)) {
            throw new Exception("Lỗi khi thêm mới vào database");
        }
    }

    public void updateBranch(CinemaBranch branch) throws Exception {
        if (branchDao.findById(branch.getBranchId()) == null) {
            throw new Exception("Chi nhánh không tồn tại");
        }
        if (!branchDao.update(branch)) {
            throw new Exception("Lỗi khi cập nhật database");
        }
    }

    public void deleteBranch(int id) {
        branchDao.delete(id);
    }

    public List<User> getAllManagers() {
        return userDao.getUsersByRole(4);
    }
}