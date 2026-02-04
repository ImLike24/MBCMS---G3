package services;

import repositories.Roles;
import repositories.Users;
import models.Role;
import models.User;
import utils.Password;
import java.time.LocalDate;

public class AuthService {

    private final Users usersDao = new Users();
    private final Roles rolesDao = new Roles();

    public void registerUser(String username, String fullName, String email, String phone,
                             String rawPassword, String birthdayStr) throws Exception {

        // Check duplicate
        if (usersDao.findByUsername(username) != null) {
            throw new IllegalArgumentException("Username is already taken.");
        }
        if (usersDao.findByEmail(email) != null) {
            throw new IllegalArgumentException("Email is already registered.");
        }
        if (usersDao.findByPhone(phone) != null) {
            throw new IllegalArgumentException("Phone number is already used.");
        }

        // Get role default
        Integer roleId = rolesDao.getRoleIdByName("CUSTOMER");
        if (roleId == null) {
            throw new RuntimeException("System Error: Role 'CUSTOMER' not found.");
        }

        // Create object
        User u = new User();
        u.setRoleId(roleId);
        u.setUsername(username);
        u.setFullName(fullName);
        u.setEmail(email);
        u.setPhone(phone);
        u.setPassword(Password.hashPassword(rawPassword));
        u.setStatus("ACTIVE");
        u.setPoints(0);

        // Xử lí ngày sinh
        if (birthdayStr != null && !birthdayStr.isEmpty()) {
            try {
                u.setBirthday(LocalDate.parse(birthdayStr).atStartOfDay());
            } catch (Exception e) {
                System.err.println(e.getMessage());
            }
        }

        // Insert to DB
        boolean isInserted = usersDao.insert(u);
        if (!isInserted) {
            throw new RuntimeException("Registration failed due to database error.");
        }
    }

    public User loginUser(String username, String password) throws Exception {
        // Find user
        User user = usersDao.findByUsername(username);

        // Validate Password
        if (user == null || !Password.verifyPassword(password, user.getPassword())) {
            throw new IllegalArgumentException("Invalid username or password.");
        }

        // Check Status
        if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            throw new IllegalArgumentException("Your account is " + user.getStatus() + ". Please contact admin.");
        }

        // Update Last Login
        usersDao.updateLastLogin(user.getUserId());

        return user;
    }

    // Seed default users if not exists
    public void seedDefaultUsersIfNotExists() throws Exception {
        // Seed ADMIN
        seedUserIfNotExists("admin", "ADMIN", "admin@mbcms.com", "Administrator", "0123456789", "admin123");

        // Seed BRANCH_MANAGER
        seedUserIfNotExists("manager", "BRANCH_MANAGER", "manager@mbcms.com", "Branch Manager", "0987654321", "manager123");

        // Seed CINEMA_STAFF
        seedUserIfNotExists("staff", "CINEMA_STAFF", "staff@mbcms.com", "Cinema Staff", "0912345678", "staff123");
    }

    private void seedUserIfNotExists(String username, String roleName, String email, String fullName, String phone, String rawPassword) throws Exception {
        // Check if user exists
        User existingUser = usersDao.findByUsername(username);
        if (existingUser != null) {
            return; // User already exists
        }

        // Get role ID
        Integer roleId = rolesDao.getRoleIdByName(roleName);
        if (roleId == null) {
            throw new RuntimeException(roleName + " role not found. Please run database setup.");
        }

        // Create user
        User user = new User();
        user.setRoleId(roleId);
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(Password.hashPassword(rawPassword));
        user.setFullName(fullName);
        user.setPhone(phone);
        user.setStatus("ACTIVE");
        user.setPoints(0);

        // Insert user
        boolean inserted = usersDao.insert(user);
        if (!inserted) {
            throw new RuntimeException("Failed to insert user: " + username);
        }
    }

    // Helper function: get role's name
    public String getRoleName(int roleId) {
        Role role = rolesDao.getRoleById(roleId);
        return (role != null) ? role.getRoleName().toUpperCase() : "GUEST";
    }
}