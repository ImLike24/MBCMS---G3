package services;

import models.CinemaBranch;
import repositories.CinemaBranches;
import java.util.List;

public class BranchService {
    private final CinemaBranches branchDao = new CinemaBranches();

    public List<CinemaBranch> getBranches(String keyword, Boolean isActive, int page, int pageSize) {
        return branchDao.findAll(keyword, isActive, page, pageSize);
    }

    // Tính tổng số trang
    public int getTotalPages(String keyword, Boolean isActive, int pageSize) {
        int totalRecords = branchDao.countAll(keyword, isActive);
        return (int) Math.ceil((double) totalRecords / pageSize);
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
}