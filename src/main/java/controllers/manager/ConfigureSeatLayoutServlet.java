package controllers.manager;

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

@WebServlet("/branch-manager/configure-seat-layout")
public class ConfigureSeatLayoutServlet extends HttpServlet {

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

        // Get all branches managed by this manager
        try {
            CinemaBranches branchesRepo = new CinemaBranches();
            ScreeningRooms roomsRepo = new ScreeningRooms();
            Seats seatsRepo = new Seats();

            List<CinemaBranch> managedBranches = branchesRepo.findListByManagerId(currentUser.getUserId());

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
            List<ScreeningRoom> rooms = roomsRepo.getAllRoomsByBranch(branch.getBranchId());

            // Get selected room if any
            String roomIdParam = request.getParameter("roomId");
            ScreeningRoom selectedRoom = null;
            List<Seat> existingSeats = null;

            if (roomIdParam != null && !roomIdParam.isEmpty()) {
                try {
                    int roomId = Integer.parseInt(roomIdParam);
                    selectedRoom = roomsRepo.getRoomById(roomId);

                    // Verify room belongs to this branch
                    if (selectedRoom != null && selectedRoom.getBranchId() == branch.getBranchId()) {
                        existingSeats = seatsRepo.getSeatsByRoom(roomId);
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
                    request.getContextPath() + "/branch-manager/configure-seat-layout?error=Invalid request");
            return;
        }

        try {
            CinemaBranches branchesRepo = new CinemaBranches();
            ScreeningRooms roomsRepo = new ScreeningRooms();
            Seats seatsRepo = new Seats();

            // Resolve the target branch from POST param, verified against managed list
            String branchIdStr = request.getParameter("branchId");
            List<CinemaBranch> managedBranches = branchesRepo.findListByManagerId(currentUser.getUserId());
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

            boolean success = false;
            String message = "";

            if ("generate".equals(action)) {
                String roomIdStr = request.getParameter("roomId");
                String rowsStr = request.getParameter("rows");
                String columnsStr = request.getParameter("columns");

                if (roomIdStr == null || rowsStr == null || columnsStr == null) {
                    message = "Invalid parameters";
                } else {
                    try {
                        int roomId = Integer.parseInt(roomIdStr);
                        int rows = Integer.parseInt(rowsStr);
                        int columns = Integer.parseInt(columnsStr);

                        // Validate input
                        if (rows < 1 || rows > 26 || columns < 1 || columns > 50) {
                            message = "Invalid layout: Rows must be 1-26 (A-Z), Columns must be 1-50";
                        } else {
                            ScreeningRoom room = roomsRepo.getRoomById(roomId);

                            if (room == null || room.getBranchId() != branch.getBranchId()) {
                                message = "Room not found or access denied";
                            } else {
                                // Delete existing seats
                                seatsRepo.deleteSeatsByRoom(roomId);

                                // Generate new seats
                                List<Seat> newSeats = new ArrayList<>();
                                for (int row = 0; row < rows; row++) {
                                    String rowLetter = String.valueOf((char) ('A' + row));
                                    for (int col = 1; col <= columns; col++) {
                                        Seat seat = new Seat();
                                        seat.setRoomId(roomId);
                                        seat.setSeatCode(rowLetter + col);
                                        seat.setSeatType("NORMAL");
                                        seat.setRowNumber(rowLetter);
                                        seat.setSeatNumber(col);
                                        seat.setStatus("AVAILABLE");
                                        newSeats.add(seat);
                                    }
                                }

                                // Bulk insert seats
                                success = seatsRepo.insertSeatsInBatch(newSeats);

                                if (success) {
                                    // Update room total seats
                                    room.setTotalSeats(newSeats.size());
                                    roomsRepo.updateRoom(room);
                                    message = "Seat layout generated successfully: " + rows + " rows × " + columns
                                            + " columns = " + newSeats.size() + " seats";
                                } else {
                                    message = "Failed to generate seat layout";
                                }
                            }
                        }
                    } catch (NumberFormatException e) {
                        message = "Invalid number format";
                    }
                }

                if (success) {
                    response.sendRedirect(request.getContextPath() + "/branch-manager/configure-seat-layout?branchId="
                            + selectedBranchId + "&roomId=" + request.getParameter("roomId") + "&success=" + message);
                } else {
                    response.sendRedirect(request.getContextPath() + "/branch-manager/configure-seat-layout?branchId="
                            + selectedBranchId + "&roomId=" + request.getParameter("roomId") + "&error=" + message);
                }
            } else if ("clear".equals(action)) {
                String roomIdStr = request.getParameter("roomId");

                if (roomIdStr == null) {
                    message = "Invalid parameters";
                } else {
                    try {
                        int roomId = Integer.parseInt(roomIdStr);
                        ScreeningRoom room = roomsRepo.getRoomById(roomId);

                        if (room == null || room.getBranchId() != branch.getBranchId()) {
                            message = "Room not found or access denied";
                        } else {
                            // Delete all seats
                            success = seatsRepo.deleteSeatsByRoom(roomId);

                            if (success) {
                                // Update room total seats
                                room.setTotalSeats(0);
                                roomsRepo.updateRoom(room);
                                message = "Seat layout cleared successfully";
                            } else {
                                message = "Failed to clear seat layout";
                            }
                        }
                    } catch (NumberFormatException e) {
                        message = "Invalid room ID";
                    }
                }

                if (success) {
                    response.sendRedirect(request.getContextPath() + "/branch-manager/configure-seat-layout?branchId="
                            + selectedBranchId + "&roomId=" + request.getParameter("roomId") + "&success=" + message);
                } else {
                    response.sendRedirect(request.getContextPath() + "/branch-manager/configure-seat-layout?branchId="
                            + selectedBranchId + "&roomId=" + request.getParameter("roomId") + "&error=" + message);
                }
            } else {
                response.sendRedirect(
                        request.getContextPath() + "/branch-manager/configure-seat-layout?branchId=" + selectedBranchId + "&error=Invalid action");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(
                    request.getContextPath() + "/branch-manager/configure-seat-layout?error=" + e.getMessage());
        }
    }
}
