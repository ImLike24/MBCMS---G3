package repositories;

import config.DBContext;
import models.StaffSchedule;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class StaffSchedules extends DBContext {

    private StaffSchedule mapRow(ResultSet rs) throws SQLException {
        StaffSchedule s = new StaffSchedule();
        s.setScheduleId(rs.getInt("schedule_id"));
        s.setStaffId(rs.getInt("staff_id"));
        s.setBranchId(rs.getInt("branch_id"));
        if (rs.getDate("work_date") != null)
            s.setWorkDate(rs.getDate("work_date").toLocalDate());
        s.setShift(rs.getString("shift"));
        s.setStatus(rs.getString("status"));
        s.setNote(rs.getString("note"));
        int cb = rs.getInt("created_by");
        if (!rs.wasNull()) s.setCreatedBy(cb);
        if (rs.getTimestamp("created_at") != null)
            s.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        if (rs.getTimestamp("updated_at") != null)
            s.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        try { s.setStaffName(rs.getString("staff_name")); } catch (SQLException ignored) {}
        try { s.setBranchName(rs.getString("branch_name")); } catch (SQLException ignored) {}
        try { s.setCreatedByName(rs.getString("created_by_name")); } catch (SQLException ignored) {}
        return s;
    }

    /** Lấy tất cả lịch của một staff trong tuần (weekStart -> weekStart+6) */
    public List<StaffSchedule> getByStaffAndWeek(int staffId, LocalDate weekStart) {
        String sql = """
            SELECT ss.*, u.fullName as staff_name, b.branch_name, m.fullName as created_by_name
            FROM staff_schedules ss
            JOIN users u ON ss.staff_id = u.user_id
            JOIN cinema_branches b ON ss.branch_id = b.branch_id
            LEFT JOIN users m ON ss.created_by = m.user_id
            WHERE ss.staff_id = ? AND ss.work_date >= ? AND ss.work_date <= ?
            ORDER BY ss.work_date, ss.shift
            """;
        List<StaffSchedule> list = new ArrayList<>();
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, staffId);
            st.setDate(2, Date.valueOf(weekStart));
            st.setDate(3, Date.valueOf(weekStart.plusDays(6)));
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /** Lấy tất cả lịch theo branch trong tuần — dùng cho manager xem tổng quan */
    public List<StaffSchedule> getByBranchAndWeek(int branchId, LocalDate weekStart) {
        String sql = """
            SELECT ss.*, u.fullName as staff_name, b.branch_name, m.fullName as created_by_name
            FROM staff_schedules ss
            JOIN users u ON ss.staff_id = u.user_id
            JOIN cinema_branches b ON ss.branch_id = b.branch_id
            LEFT JOIN users m ON ss.created_by = m.user_id
            WHERE ss.branch_id = ? AND ss.work_date >= ? AND ss.work_date <= ?
            ORDER BY ss.work_date, ss.shift, u.fullName
            """;
        List<StaffSchedule> list = new ArrayList<>();
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setDate(2, Date.valueOf(weekStart));
            st.setDate(3, Date.valueOf(weekStart.plusDays(6)));
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /** Tạo lịch làm việc mới */
    public boolean insert(StaffSchedule s) {
        String sql = """
            INSERT INTO staff_schedules (staff_id, branch_id, work_date, shift, status, note, created_by)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """;
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, s.getStaffId());
            st.setInt(2, s.getBranchId());
            st.setDate(3, Date.valueOf(s.getWorkDate()));
            st.setString(4, s.getShift());
            st.setString(5, s.getStatus() != null ? s.getStatus() : "SCHEDULED");
            st.setString(6, s.getNote());
            if (s.getCreatedBy() != null) st.setInt(7, s.getCreatedBy());
            else st.setNull(7, Types.INTEGER);
            return st.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    /** Hủy lịch làm việc */
    public boolean cancel(int scheduleId) {
        String sql = "UPDATE staff_schedules SET status = 'CANCELLED' WHERE schedule_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, scheduleId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    /** Xóa lịch làm việc */
    public boolean delete(int scheduleId) {
        String sql = "DELETE FROM staff_schedules WHERE schedule_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, scheduleId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    /** Kiểm tra trùng ca (cùng staff, ngày, ca) */
    public boolean existsDuplicate(int staffId, LocalDate workDate, String shift, Integer excludeId) {
        String sql = """
            SELECT 1 FROM staff_schedules
            WHERE staff_id = ? AND work_date = ? AND shift = ? AND status != 'CANCELLED'
            """ + (excludeId != null ? " AND schedule_id != ?" : "");
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, staffId);
            st.setDate(2, Date.valueOf(workDate));
            st.setString(3, shift);
            if (excludeId != null) st.setInt(4, excludeId);
            try (ResultSet rs = st.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public StaffSchedule findById(int scheduleId) {
        String sql = """
            SELECT ss.*, u.fullName as staff_name, b.branch_name, m.fullName as created_by_name
            FROM staff_schedules ss
            JOIN users u ON ss.staff_id = u.user_id
            JOIN cinema_branches b ON ss.branch_id = b.branch_id
            LEFT JOIN users m ON ss.created_by = m.user_id
            WHERE ss.schedule_id = ?
            """;
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, scheduleId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }
}
