package controllers.branchmanager;

import config.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.*;
import repositories.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/branch-manager/manage-seat-status")
public class ManageSeatStatusServlet extends HttpServlet {

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
                request.setAttribute("error", "You are not assigned to any branch");
                request.getRequestDispatcher("/pages/manager/manage-seat-status.jsp").forward(request, response);
                return;
            }

            // Get all screening rooms for this branch
            List<ScreeningRoom> rooms = roomsRepo.getAllRoomsByBranch(branch.getBranchId());

            // Get selected room if any
            String roomIdParam = request.getParameter("roomId");
            String statusFilter = request.getParameter("statusFilter");
            ScreeningRoom selectedRoom = null;
            List<Seat> seats = null;

            if (roomIdParam != null && !roomIdParam.isEmpty()) {
                try {
                    int roomId = Integer.parseInt(roomIdParam);
                    selectedRoom = roomsRepo.getRoomById(roomId);

                    // Verify room belongs to this branch
                    if (selectedRoom != null && selectedRoom.getBranchId() == branch.getBranchId()) {
                        if (statusFilter != null && !statusFilter.isEmpty()) {
                            seats = seatsRepo.getSeatsByRoomAndStatus(roomId, statusFilter);
                        } else {
                            seats = seatsRepo.getSeatsByRoom(roomId);
                        }
                    } else {
                        selectedRoom = null;
                    }
                } catch (NumberFormatException e) {
                    // Invalid room ID
                }
            }

            // Set attributes for JSP
            request.setAttribute("branch", branch);
            request.setAttribute("rooms", rooms);
            request.setAttribute("selectedRoom", selectedRoom);
            request.setAttribute("seats", seats);
            request.setAttribute("statusFilter", statusFilter);

            request.getRequestDispatcher("/pages/manager/manage-seat-status.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading seat status: " + e.getMessage());
            request.getRequestDispatcher("/pages/manager/manage-seat-status.jsp").forward(request, response);
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

        // Get parameters
        String action = request.getParameter("action");
        String roomIdStr = request.getParameter("roomId");

        if (action == null || roomIdStr == null) {
            response.sendRedirect(
                    request.getContextPath() + "/branch-manager/manage-seat-status?error=Invalid request");
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
                        + "/branch-manager/manage-seat-status?error=You are not assigned to any branch");
                return;
            }

            int roomId = Integer.parseInt(roomIdStr);
            ScreeningRoom room = roomsRepo.getRoomById(roomId);

            if (room == null || room.getBranchId() != branch.getBranchId()) {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-seat-status?error=Room not found or access denied");
                return;
            }

            boolean success = false;
            String message = "";

            if ("updateBulk".equals(action)) {
                String[] seatIds = request.getParameterValues("seatIds[]");
                String status = request.getParameter("status");

                if (seatIds == null || seatIds.length == 0 || status == null) {
                    message = "No seats selected or invalid status";
                } else {
                    // Validate status
                    if (!status.equals("AVAILABLE") && !status.equals("BROKEN") && !status.equals("MAINTENANCE")) {
                        message = "Invalid seat status";
                    } else {
                        List<Integer> seatIdList = new ArrayList<>();
                        for (String seatIdStr : seatIds) {
                            try {
                                seatIdList.add(Integer.parseInt(seatIdStr));
                            } catch (NumberFormatException e) {
                                // Skip invalid IDs
                            }
                        }

                        if (seatIdList.isEmpty()) {
                            message = "No valid seats selected";
                        } else {
                            success = seatsRepo.updateSeatStatusesInBatch(seatIdList, status);
                            message = success ? "Updated " + seatIdList.size() + " seat(s) to " + status
                                    : "Failed to update seat statuses";
                        }
                    }
                }
            } else if ("updateSingle".equals(action)) {
                String seatIdStr = request.getParameter("seatId");
                String status = request.getParameter("status");

                if (seatIdStr == null || status == null) {
                    message = "Invalid parameters";
                } else {
                    // Validate status
                    if (!status.equals("AVAILABLE") && !status.equals("BROKEN") && !status.equals("MAINTENANCE")) {
                        message = "Invalid seat status";
                    } else {
                        int seatId = Integer.parseInt(seatIdStr);
                        Seat seat = seatsRepo.getSeatById(seatId);

                        if (seat == null || seat.getRoomId() != roomId) {
                            message = "Seat not found or access denied";
                        } else {
                            success = seatsRepo.updateSeatStatus(seatId, status);
                            message = success ? "Seat status updated to " + status : "Failed to update seat status";
                        }
                    }
                }
            } else {
                message = "Invalid action";
            }

            if (success) {
                response.sendRedirect(request.getContextPath() + "/branch-manager/manage-seat-status?roomId=" + roomId
                        + "&success=" + message);
            } else {
                response.sendRedirect(request.getContextPath() + "/branch-manager/manage-seat-status?roomId=" + roomId
                        + "&error=" + message);
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(
                    request.getContextPath() + "/branch-manager/manage-seat-status?error=Invalid ID format");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(
                    request.getContextPath() + "/branch-manager/manage-seat-status?error=" + e.getMessage());
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
