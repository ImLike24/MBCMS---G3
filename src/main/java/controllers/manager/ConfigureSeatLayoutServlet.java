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
import java.util.List;

@WebServlet("/branch-manager/configure-seat-layout")
public class ConfigureSeatLayoutServlet extends HttpServlet {

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
                request.getRequestDispatcher("/pages/manager/configure-seat-layout.jsp").forward(request, response);
                return;
            }

            // Determine selected branch (from param or default to first)
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
            ScreeningRoom selectedRoom = null;
            List<Seat> existingSeats = null;

            if (roomIdParam != null && !roomIdParam.isEmpty()) {
                try {
                    int roomId = Integer.parseInt(roomIdParam);
                    selectedRoom = seatService.getRoomById(roomId);

                    // Verify room belongs to this branch
                    if (selectedRoom != null && selectedRoom.getBranchId() == branch.getBranchId()) {
                        existingSeats = seatService.getSeatsByRoom(roomId);
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
            request.setAttribute("existingSeats", existingSeats);

            request.getRequestDispatcher("/pages/manager/configure-seat-layout.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading seat layout: " + e.getMessage());
            request.getRequestDispatcher("/pages/manager/configure-seat-layout.jsp").forward(request, response);
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

        // Get action parameter
        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect(
                    request.getContextPath() + "/branch-manager/configure-seat-layout?error=Invalid request");
            return;
        }

        try {
            // Resolve the target branch from POST param, verified against managed list
            String branchIdStr = request.getParameter("branchId");
            List<CinemaBranch> managedBranches = seatService.getManagedBranches(currentUser.getUserId());
            if (managedBranches == null || managedBranches.isEmpty()) {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/configure-seat-layout?error=You are not assigned to any branch");
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

            if ("generate".equals(action)) {
                String roomIdStr = request.getParameter("roomId");
                String rowsStr = request.getParameter("rows");
                String columnsStr = request.getParameter("columns");

                if (roomIdStr == null || rowsStr == null || columnsStr == null) {
                    redirectWithError(request, response, selectedBranchId, roomIdStr, "Invalid parameters");
                    return;
                }

                try {
                    int roomId = Integer.parseInt(roomIdStr);
                    int rows = Integer.parseInt(rowsStr);
                    int columns = Integer.parseInt(columnsStr);

                    String msg = seatService.generateSeatLayout(selectedBranchId, roomId, rows, columns);
                    redirectWithSuccess(request, response, selectedBranchId, roomIdStr, msg);

                } catch (NumberFormatException e) {
                    redirectWithError(request, response, selectedBranchId, roomIdStr, "Invalid number format");
                } catch (RuntimeException e) {
                    redirectWithError(request, response, selectedBranchId, roomIdStr, e.getMessage());
                }

            } else if ("clear".equals(action)) {
                String roomIdStr = request.getParameter("roomId");

                if (roomIdStr == null) {
                    redirectWithError(request, response, selectedBranchId, null, "Invalid parameters");
                    return;
                }

                try {
                    int roomId = Integer.parseInt(roomIdStr);
                    String msg = seatService.clearSeatLayout(selectedBranchId, roomId);
                    redirectWithSuccess(request, response, selectedBranchId, roomIdStr, msg);

                } catch (NumberFormatException e) {
                    redirectWithError(request, response, selectedBranchId, roomIdStr, "Invalid room ID");
                } catch (RuntimeException e) {
                    redirectWithError(request, response, selectedBranchId, roomIdStr, e.getMessage());
                }
            } else {
                response.sendRedirect(
                        request.getContextPath() + "/branch-manager/configure-seat-layout?branchId=" + selectedBranchId + "&error=Invalid action");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(
                    request.getContextPath() + "/branch-manager/configure-seat-layout?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }

    private void redirectWithSuccess(HttpServletRequest request, HttpServletResponse response, int branchId, String roomIdStr, String message) throws IOException {
        response.sendRedirect(request.getContextPath() + "/branch-manager/configure-seat-layout?branchId="
                + branchId + "&roomId=" + roomIdStr + "&success=" + java.net.URLEncoder.encode(message, "UTF-8"));
    }

    private void redirectWithError(HttpServletRequest request, HttpServletResponse response, int branchId, String roomIdStr, String message) throws IOException {
        String url = request.getContextPath() + "/branch-manager/configure-seat-layout?branchId=" + branchId + "&error=" + java.net.URLEncoder.encode(message, "UTF-8");
        if (roomIdStr != null) {
            url += "&roomId=" + roomIdStr;
        }
        response.sendRedirect(url);
    }
}
