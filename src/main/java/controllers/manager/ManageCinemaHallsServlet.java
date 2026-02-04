package controllers.branchmanager;

import config.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Role;
import models.ScreeningRoom;
import models.User;
import models.CinemaBranch;
import repositories.Roles;
import repositories.ScreeningRooms;
import repositories.Seats;
import repositories.CinemaBranches;

import java.io.IOException;
import java.util.List;

@WebServlet("/branch-manager/manage-cinema-halls")
public class ManageCinemaHallsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check authentication and authorization
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // Check if user is Branch Manager
        DBContext dbContext = null;
        try {
            dbContext = new DBContext();
            Roles rolesRepo = new Roles();
            Role userRole = rolesRepo.getRoleById(currentUser.getRoleId());

            if (userRole == null || !"BRANCH_MANAGER".equals(userRole.getRoleName())) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        } finally {
            if (dbContext != null) {
                dbContext.closeConnection();
            }
        }

        // Get branch manager's assigned branch
        DBContext branchDbContext = null;
        DBContext roomsDbContext = null;
        try {
            branchDbContext = new DBContext();
            roomsDbContext = new DBContext();

            CinemaBranches branchesRepo = new CinemaBranches();
            ScreeningRooms roomsRepo = new ScreeningRooms();

            // Get branch where this user is the manager
            CinemaBranch branch = branchesRepo.getBranchByManagerId(currentUser.getUserId());

            if (branch == null) {
                request.setAttribute("error", "You are not assigned to any branch");
                request.getRequestDispatcher("/pages/manager/manage-cinema-halls.jsp").forward(request, response);
                return;
            }

            // Get all screening rooms for this branch
            List<ScreeningRoom> rooms = roomsRepo.getAllRoomsByBranch(branch.getBranchId());

            // Set attributes for JSP
            request.setAttribute("branch", branch);
            request.setAttribute("rooms", rooms);

            request.getRequestDispatcher("/pages/manager/manage-cinema-halls.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading screening rooms: " + e.getMessage());
            request.getRequestDispatcher("/pages/manager/manage-cinema-halls.jsp").forward(request, response);
        } finally {
            if (branchDbContext != null) {
                branchDbContext.closeConnection();
            }
            if (roomsDbContext != null) {
                roomsDbContext.closeConnection();
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check authentication and authorization
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // Check if user is Branch Manager
        DBContext dbContext = null;
        try {
            dbContext = new DBContext();
            Roles rolesRepo = new Roles();
            Role userRole = rolesRepo.getRoleById(currentUser.getRoleId());

            if (userRole == null || !"BRANCH_MANAGER".equals(userRole.getRoleName())) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        } finally {
            if (dbContext != null) {
                dbContext.closeConnection();
            }
        }

        // Get action parameter
        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect(
                    request.getContextPath() + "/branch-manager/manage-cinema-halls?error=Invalid request");
            return;
        }

        DBContext branchDbContext = null;
        DBContext roomsDbContext = null;
        DBContext seatsDbContext = null;

        try {
            branchDbContext = new DBContext();
            roomsDbContext = new DBContext();
            seatsDbContext = new DBContext();

            CinemaBranches branchesRepo = new CinemaBranches();
            ScreeningRooms roomsRepo = new ScreeningRooms();
            Seats seatsRepo = new Seats();

            // Get branch where this user is the manager
            CinemaBranch branch = branchesRepo.getBranchByManagerId(currentUser.getUserId());

            if (branch == null) {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-cinema-halls?error=You are not assigned to any branch");
                return;
            }

            boolean success = false;
            String message = "";

            switch (action) {
                case "create":
                    String roomName = request.getParameter("roomName");

                    if (roomName == null || roomName.trim().isEmpty()) {
                        message = "Room name is required";
                        break;
                    }

                    // Check if room name already exists in this branch
                    if (roomsRepo.roomNameExistsInBranch(roomName.trim(), branch.getBranchId(), null)) {
                        message = "Room name already exists in this branch";
                        break;
                    }

                    ScreeningRoom newRoom = new ScreeningRoom();
                    newRoom.setBranchId(branch.getBranchId());
                    newRoom.setRoomName(roomName.trim());
                    newRoom.setTotalSeats(0);
                    newRoom.setStatus("ACTIVE");

                    success = roomsRepo.insertRoom(newRoom);
                    message = success ? "Screening room created successfully" : "Failed to create screening room";
                    break;

                case "update":
                    String roomIdStr = request.getParameter("roomId");
                    String updatedRoomName = request.getParameter("roomName");

                    if (roomIdStr == null || updatedRoomName == null || updatedRoomName.trim().isEmpty()) {
                        message = "Invalid parameters";
                        break;
                    }

                    int roomId = Integer.parseInt(roomIdStr);
                    ScreeningRoom existingRoom = roomsRepo.getRoomById(roomId);

                    if (existingRoom == null || existingRoom.getBranchId() != branch.getBranchId()) {
                        message = "Room not found or access denied";
                        break;
                    }

                    // Check if room name already exists (excluding current room)
                    if (roomsRepo.roomNameExistsInBranch(updatedRoomName.trim(), branch.getBranchId(), roomId)) {
                        message = "Room name already exists in this branch";
                        break;
                    }

                    existingRoom.setRoomName(updatedRoomName.trim());
                    success = roomsRepo.updateRoom(existingRoom);
                    message = success ? "Screening room updated successfully" : "Failed to update screening room";
                    break;

                case "delete":
                    String deleteRoomIdStr = request.getParameter("roomId");

                    if (deleteRoomIdStr == null) {
                        message = "Invalid parameters";
                        break;
                    }

                    int deleteRoomId = Integer.parseInt(deleteRoomIdStr);
                    ScreeningRoom roomToDelete = roomsRepo.getRoomById(deleteRoomId);

                    if (roomToDelete == null || roomToDelete.getBranchId() != branch.getBranchId()) {
                        message = "Room not found or access denied";
                        break;
                    }

                    // Delete all seats first
                    seatsRepo.deleteSeatsByRoom(deleteRoomId);

                    // Then delete the room
                    success = roomsRepo.deleteRoom(deleteRoomId);
                    message = success ? "Screening room deleted successfully" : "Failed to delete screening room";
                    break;

                case "changeStatus":
                    String statusRoomIdStr = request.getParameter("roomId");
                    String newStatus = request.getParameter("status");

                    if (statusRoomIdStr == null || newStatus == null) {
                        message = "Invalid parameters";
                        break;
                    }

                    int statusRoomId = Integer.parseInt(statusRoomIdStr);
                    ScreeningRoom roomToUpdate = roomsRepo.getRoomById(statusRoomId);

                    if (roomToUpdate == null || roomToUpdate.getBranchId() != branch.getBranchId()) {
                        message = "Room not found or access denied";
                        break;
                    }

                    // Validate status
                    if (!newStatus.equals("ACTIVE") && !newStatus.equals("MAINTENANCE")
                            && !newStatus.equals("CLOSED")) {
                        message = "Invalid status";
                        break;
                    }

                    success = roomsRepo.updateRoomStatus(statusRoomId, newStatus);
                    message = success ? "Room status updated successfully" : "Failed to update room status";
                    break;

                default:
                    message = "Invalid action";
            }

            if (success) {
                response.sendRedirect(
                        request.getContextPath() + "/branch-manager/manage-cinema-halls?success=" + message);
            } else {
                response.sendRedirect(
                        request.getContextPath() + "/branch-manager/manage-cinema-halls?error=" + message);
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(
                    request.getContextPath() + "/branch-manager/manage-cinema-halls?error=Invalid room ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(
                    request.getContextPath() + "/branch-manager/manage-cinema-halls?error=" + e.getMessage());
        } finally {
            if (branchDbContext != null) {
                branchDbContext.closeConnection();
            }
            if (roomsDbContext != null) {
                roomsDbContext.closeConnection();
            }
            if (seatsDbContext != null) {
                seatsDbContext.closeConnection();
            }
        }
    }
}
