package controllers.manager;

import config.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.*;
import services.SeatService;
import services.UserService;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/branch-manager/manage-seat-status")
public class ManageSeatStatusServlet extends HttpServlet {

    private final SeatService seatService = new SeatService();
    private final UserService userService = new UserService();

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
            Role userRole = userService.getRoleById(currentUser.getRoleId());

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

        try {
            List<CinemaBranch> managedBranches = seatService.getManagedBranches(currentUser.getUserId());

            if (managedBranches == null || managedBranches.isEmpty()) {
                request.setAttribute("error", "You are not assigned to any branch");
                request.getRequestDispatcher("/pages/manager/manage-seat-status.jsp").forward(request, response);
                return;
            }

            // Determine selected branch
            String branchIdParam = request.getParameter("branchId");
            CinemaBranch branch = managedBranches.get(0);
            if (branchIdParam != null && !branchIdParam.isEmpty()) {
                try {
                    int bId = Integer.parseInt(branchIdParam);
                    for (CinemaBranch b : managedBranches) {
                        if (b.getBranchId() == bId) { branch = b; break; }
                    }
                } catch (NumberFormatException ignored) {}
            }

            // Get all screening rooms for selected branch
            List<ScreeningRoom> rooms = seatService.getRoomsByBranch(branch.getBranchId());

            // Get selected room if any
            String roomIdParam = request.getParameter("roomId");
            String statusFilter = request.getParameter("statusFilter");
            ScreeningRoom selectedRoom = null;
            List<Seat> seats = null;

            if (roomIdParam != null && !roomIdParam.isEmpty()) {
                try {
                    int roomId = Integer.parseInt(roomIdParam);
                    selectedRoom = seatService.getRoomById(roomId);

                    // Verify room belongs to this branch
                    if (selectedRoom != null && selectedRoom.getBranchId() == branch.getBranchId()) {
                        if (statusFilter != null && !statusFilter.isEmpty()) {
                            seats = seatService.getSeatsByRoomAndStatus(roomId, statusFilter);
                        } else {
                            seats = seatService.getSeatsByRoom(roomId);
                        }
                    } else {
                        selectedRoom = null;
                    }
                } catch (NumberFormatException e) {
                    // Invalid room ID
                }
            }

            // Set attributes for JSP
            request.setAttribute("managedBranches", managedBranches);
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
            Role userRole = userService.getRoleById(currentUser.getRoleId());

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

        try {
            // Resolve target branch from POST param, verified against managed list
            String branchIdStr = request.getParameter("branchId");
            List<CinemaBranch> managedBranches = seatService.getManagedBranches(currentUser.getUserId());
            if (managedBranches == null || managedBranches.isEmpty()) {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-seat-status?error=You are not assigned to any branch");
                return;
            }
            CinemaBranch branch = managedBranches.get(0);
            if (branchIdStr != null && !branchIdStr.isEmpty()) {
                try {
                    int bId = Integer.parseInt(branchIdStr);
                    for (CinemaBranch b : managedBranches) {
                        if (b.getBranchId() == bId) { branch = b; break; }
                    }
                } catch (NumberFormatException ignored) {}
            }
            final int selectedBranchId = branch.getBranchId();
            int roomId = Integer.parseInt(roomIdStr);

            String message = "";
            boolean success = true;

            if ("updateBulk".equals(action)) {
                String[] seatIds = request.getParameterValues("seatIds[]");
                String status = request.getParameter("status");

                List<Integer> seatIdList = new ArrayList<>();
                if (seatIds != null) {
                    for (String seatIdStr : seatIds) {
                        try {
                            seatIdList.add(Integer.parseInt(seatIdStr));
                        } catch (NumberFormatException e) {}
                    }
                }

                try {
                    message = seatService.updateSeatStatusesBulk(selectedBranchId, roomId, seatIdList, status);
                } catch (Exception e) {
                    success = false;
                    message = e.getMessage();
                }
            } else if ("updateSingle".equals(action)) {
                String seatIdStr = request.getParameter("seatId");
                String status = request.getParameter("status");

                if (seatIdStr == null || status == null) {
                    success = false;
                    message = "Invalid parameters";
                } else {
                    try {
                        int seatId = Integer.parseInt(seatIdStr);
                        message = seatService.updateSeatStatusSingle(selectedBranchId, roomId, seatId, status);
                    } catch (Exception e) {
                        success = false;
                        message = e.getMessage();
                    }
                }
            } else {
                success = false;
                message = "Invalid action";
            }

            if (success) {
                response.sendRedirect(request.getContextPath() + "/branch-manager/manage-seat-status?branchId=" + selectedBranchId
                        + "&roomId=" + roomId + "&success=" + java.net.URLEncoder.encode(message, "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/branch-manager/manage-seat-status?branchId=" + selectedBranchId
                        + "&roomId=" + roomId + "&error=" + java.net.URLEncoder.encode(message, "UTF-8"));
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(
                    request.getContextPath() + "/branch-manager/manage-seat-status?error=Invalid ID format");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(
                    request.getContextPath() + "/branch-manager/manage-seat-status?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }
}
