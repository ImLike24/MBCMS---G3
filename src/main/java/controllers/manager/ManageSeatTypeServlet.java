package controllers.manager;

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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/branch-manager/manage-seat-type")
public class ManageSeatTypeServlet extends HttpServlet {

    private final SeatService seatService = new SeatService();
    private final UserService userService = new UserService();

    // ─── Shared auth check ─────────────────────────────────────────────────────
    private boolean isAuthorized(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        User currentUser = (User) session.getAttribute("user");
        try {
            Role userRole = userService.getRoleById(currentUser.getRoleId());
            if (userRole == null || !"BRANCH_MANAGER".equals(userRole.getRoleName())) {
                response.sendRedirect(request.getContextPath() + "/home");
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAuthorized(request, response))
            return;

        User currentUser = (User) request.getSession(false).getAttribute("user");

        try {
            List<CinemaBranch> managedBranches = seatService.getManagedBranches(currentUser.getUserId());

            if (managedBranches == null || managedBranches.isEmpty()) {
                request.setAttribute("error", "You are not assigned to any branch");
                request.getRequestDispatcher("/pages/manager/manage-seat-type.jsp").forward(request, response);
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

            // Surcharge configs for this branch (map: seatType -> rate)
            List<SeatTypeSurcharge> surchargeList = seatService.getSurchargesByBranch(branch.getBranchId());
            Map<String, Double> surchargeMap = new HashMap<>();
            for (SeatTypeSurcharge s : surchargeList) {
                surchargeMap.put(s.getSeatType(), s.getSurchargeRate());
            }
            // Defaults if not set yet
            surchargeMap.putIfAbsent("NORMAL", 0.0);
            surchargeMap.putIfAbsent("VIP", 0.0);
            surchargeMap.putIfAbsent("COUPLE", 0.0);

            // Rooms
            List<ScreeningRoom> rooms = seatService.getRoomsByBranch(branch.getBranchId());

            // Selected room
            String roomIdParam = request.getParameter("roomId");
            ScreeningRoom selectedRoom = null;
            List<Seat> seats = null;

            if (roomIdParam != null && !roomIdParam.isEmpty()) {
                try {
                    int roomId = Integer.parseInt(roomIdParam);
                    selectedRoom = seatService.getRoomById(roomId);
                    if (selectedRoom != null && selectedRoom.getBranchId() == branch.getBranchId()) {
                        seats = seatService.getSeatsByRoom(roomId);
                    } else {
                        selectedRoom = null;
                    }
                } catch (NumberFormatException e) {
                    /* ignore */ }
            }

            request.setAttribute("managedBranches", managedBranches);
            request.setAttribute("branch", branch);
            request.setAttribute("rooms", rooms);
            request.setAttribute("selectedRoom", selectedRoom);
            request.setAttribute("seats", seats);
            request.setAttribute("surchargeMap", surchargeMap);
            request.getRequestDispatcher("/pages/manager/manage-seat-type.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading page: " + e.getMessage());
            request.getRequestDispatcher("/pages/manager/manage-seat-type.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAuthorized(request, response))
            return;

        User currentUser = (User) request.getSession(false).getAttribute("user");
        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/branch-manager/manage-seat-type?error=Invalid+request");
            return;
        }

        try {
            List<CinemaBranch> managedBranches = seatService.getManagedBranches(currentUser.getUserId());
            if (managedBranches == null || managedBranches.isEmpty()) {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-seat-type?error=You+are+not+assigned+to+any+branch");
                return;
            }
            // Resolve selected branch from POST param
            String branchIdStr = request.getParameter("branchId");
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

            // ── Action: updateSurcharge ──────────────────────────────────────────
            if ("updateSurcharge".equals(action)) {
                String rateNORMAL = request.getParameter("rateNORMAL");
                String rateVIP = request.getParameter("rateVIP");
                String rateCOUPLE = request.getParameter("rateCOUPLE");

                int updated = seatService.updateSurcharges(selectedBranchId, rateNORMAL, rateVIP, rateCOUPLE);
                
                if (updated > 0) {
                    response.sendRedirect(request.getContextPath()
                            + "/branch-manager/manage-seat-type?branchId=" + selectedBranchId + "&success=Surcharge+rates+updated+successfully");
                } else {
                    response.sendRedirect(request.getContextPath()
                            + "/branch-manager/manage-seat-type?branchId=" + selectedBranchId + "&error=No+surcharge+rates+updated");
                }
                return;
            }

            // ── Action: updateBulk or updateSingle ──────────────────────────────
            String roomIdStr = request.getParameter("roomId");
            if (roomIdStr == null) {
                response.sendRedirect(request.getContextPath() + "/branch-manager/manage-seat-type?error=Missing+room");
                return;
            }
            int roomId = Integer.parseInt(roomIdStr);

            String message = "";
            boolean success = true;

            if ("updateBulk".equals(action)) {
                String[] seatIds = request.getParameterValues("seatIds[]");
                String seatType = request.getParameter("seatType");

                List<Integer> idList = new ArrayList<>();
                if (seatIds != null) {
                    for (String id : seatIds) {
                        try {
                            idList.add(Integer.parseInt(id));
                        } catch (NumberFormatException ignore) {}
                    }
                }
                
                try {
                    message = seatService.updateSeatTypesBulk(selectedBranchId, roomId, idList, seatType);
                } catch (Exception e) {
                    success = false;
                    message = e.getMessage();
                }

            } else if ("updateSingle".equals(action)) {
                String seatIdStr = request.getParameter("seatId");
                String seatType = request.getParameter("seatType");
                
                if (seatIdStr == null || seatType == null) {
                    success = false;
                    message = "Invalid parameters";
                } else {
                    try {
                        int seatId = Integer.parseInt(seatIdStr);
                        message = seatService.updateSeatTypeSingle(selectedBranchId, roomId, seatId, seatType);
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
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-seat-type?branchId=" + selectedBranchId + "&roomId=" + roomId + "&success=" + java.net.URLEncoder.encode(message, "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-seat-type?branchId=" + selectedBranchId + "&roomId=" + roomId + "&error=" + java.net.URLEncoder.encode(message, "UTF-8"));
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-seat-type?error=Invalid+ID+format");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-seat-type?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }
}
