package repositories;

import config.DBContext;
import models.User;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

public class Users extends DBContext {

    // Helper map ResultSet to User Object
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setRoleId(rs.getInt("role_id"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setFullName(rs.getString("fullName"));

        if (rs.getTimestamp("birthday") != null)
            u.setBirthday(rs.getTimestamp("birthday").toLocalDateTime());

        u.setPhone(rs.getString("phone"));
        u.setAvatarUrl(rs.getString("avatarURL"));
        u.setStatus(rs.getString("status"));
        u.setPoints(rs.getInt("points"));

        if (rs.getTimestamp("created_at") != null)
            u.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        if (rs.getTimestamp("updated_at") != null)
            u.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        if (rs.getTimestamp("last_login") != null)
            u.setLastLogin(rs.getTimestamp("last_login").toLocalDateTime());

        return u;
    }

    public User findByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, username);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next())
                    return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public User findByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, email);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next())
                    return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public User findByPhone(String phone) {
        String sql = "SELECT * FROM users WHERE phone = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, phone);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next())
                    return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insert(User u) {
        String sql = "INSERT INTO users (role_id, username, email, password, fullName, birthday, phone, status, points) "
                +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, u.getRoleId());
            st.setString(2, u.getUsername());
            st.setString(3, u.getEmail());
            st.setString(4, u.getPassword());
            st.setString(5, u.getFullName());

            if (u.getBirthday() != null)
                st.setTimestamp(6, Timestamp.valueOf(u.getBirthday()));
            else
                st.setNull(6, java.sql.Types.TIMESTAMP);

            st.setString(7, u.getPhone());
            st.setString(8, u.getStatus());
            st.setInt(9, u.getPoints());

            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public void updateLastLogin(int userId) {
        String sql = "UPDATE users SET last_login = SYSDATETIME() WHERE user_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, userId);
            st.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Admin User Management Methods

    public java.util.List<User> getAllUsers() {
        String sql = "SELECT * FROM users ORDER BY created_at DESC";
        java.util.List<User> users = new java.util.ArrayList<>();
        try (PreparedStatement st = connection.prepareStatement(sql);
                ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    public java.util.List<User> getUsersByRole(int roleId) {
        String sql = "SELECT * FROM users WHERE role_id = ? ORDER BY created_at DESC";
        java.util.List<User> users = new java.util.ArrayList<>();
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, roleId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    users.add(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    public java.util.List<User> getUsersByStatus(String status) {
        String sql = "SELECT * FROM users WHERE status = ? ORDER BY created_at DESC";
        java.util.List<User> users = new java.util.ArrayList<>();
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, status);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    users.add(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    public java.util.List<User> searchUsers(String keyword) {
        String sql = "SELECT * FROM users WHERE username LIKE ? OR email LIKE ? OR fullName LIKE ? ORDER BY created_at DESC";
        java.util.List<User> users = new java.util.ArrayList<>();
        String searchPattern = "%" + keyword + "%";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, searchPattern);
            st.setString(2, searchPattern);
            st.setString(3, searchPattern);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    users.add(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    public boolean updateUserStatus(int userId, String status) {
        String sql = "UPDATE users SET status = ? WHERE user_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, status);
            st.setInt(2, userId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public User getUserById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, userId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next())
                    return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean checkUsernameExists(String username) {
        return findByUsername(username) != null;
    }

    public boolean checkEmailExists(String email) {
        return findByEmail(email) != null;
    }

    public boolean checkPhoneExists(String phone) {
        return findByPhone(phone) != null;
    }

    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM users WHERE user_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, userId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Get available branch managers (not assigned to any branch)
    public java.util.List<User> getAvailableBranchManagers() {
        java.util.List<User> managers = new java.util.ArrayList<>();
        String sql = "SELECT u.* FROM users u " +
                "INNER JOIN roles r ON u.role_id = r.role_id " +
                "WHERE r.role_name = 'BRANCH_MANAGER' " +
                "AND u.user_id NOT IN (SELECT manager_id FROM cinema_branches WHERE manager_id IS NOT NULL) " +
                "AND u.status = 'ACTIVE' " +
                "ORDER BY u.fullName ASC";
        try (PreparedStatement st = connection.prepareStatement(sql);
                ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                managers.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return managers;
    }

    // Get all branch managers (including assigned ones)
    public java.util.List<User> getAllBranchManagers() {
        java.util.List<User> managers = new java.util.ArrayList<>();
        String sql = "SELECT u.* FROM users u " +
                "INNER JOIN roles r ON u.role_id = r.role_id " +
                "WHERE r.role_name = 'BRANCH_MANAGER' " +
                "AND u.status = 'ACTIVE' " +
                "ORDER BY u.fullName ASC";
        try (PreparedStatement st = connection.prepareStatement(sql);
                ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                managers.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return managers;
    }
}