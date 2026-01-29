package services;

import models.CinemaBranch;
import repositories.CinemaBranches;
import java.util.List;

public class BranchService {
    private final CinemaBranches branchDao = new CinemaBranches();

    public List<CinemaBranch> getAllBranches() {
        return branchDao.findAll();
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