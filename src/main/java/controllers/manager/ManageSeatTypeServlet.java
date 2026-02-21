package controllers.manager;

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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/branch-manager/manage-seat-type")
public class ManageSeatTypeServlet extends HttpServlet {

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
            Roles rolesRepo = new Roles();
            Role userRole = rolesRepo.getRoleById(currentUser.getRoleId());
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
            CinemaBranches branchesRepo = new CinemaBranches();
            ScreeningRooms roomsRepo = new ScreeningRooms();
            Seats seatsRepo = new Seats();
            SeatTypeSurcharges surchargesRepo = new SeatTypeSurcharges();

            CinemaBranch branch = branchesRepo.getBranchByManagerId(currentUser.getUserId());

            if (branch == null) {
                request.setAttribute("error", "You are not assigned to any branch");
                request.getRequestDispatcher("/pages/manager/manage-seat-type.jsp").forward(request, response);
                return;
            }

            // Surcharge configs for this branch (map: seatType -> rate)
            List<SeatTypeSurcharge> surchargeList = surchargesRepo.getSurchargesByBranch(branch.getBranchId());
            Map<String, Double> surchargeMap = new HashMap<>();
            for (SeatTypeSurcharge s : surchargeList) {
                surchargeMap.put(s.getSeatType(), s.getSurchargeRate());
            }
            // Defaults if not set yet
            surchargeMap.putIfAbsent("NORMAL", 0.0);
            surchargeMap.putIfAbsent("VIP", 0.0);
            surchargeMap.putIfAbsent("COUPLE", 0.0);

            // Rooms
            List<ScreeningRoom> rooms = roomsRepo.getAllRoomsByBranch(branch.getBranchId());

            // Selected room
            String roomIdParam = request.getParameter("roomId");
            ScreeningRoom selectedRoom = null;
            List<Seat> seats = null;

            if (roomIdParam != null && !roomIdParam.isEmpty()) {
                try {
                    int roomId = Integer.parseInt(roomIdParam);
                    selectedRoom = roomsRepo.getRoomById(roomId);
                    if (selectedRoom != null && selectedRoom.getBranchId() == branch.getBranchId()) {
                        seats = seatsRepo.getSeatsByRoom(roomId);
                    } else {
                        selectedRoom = null;
                    }
                } catch (NumberFormatException e) {
                    /* ignore */ }
            }

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
            CinemaBranches branchesRepo = new CinemaBranches();
            CinemaBranch branch = branchesRepo.getBranchByManagerId(currentUser.getUserId());

            if (branch == null) {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-seat-type?error=You+are+not+assigned+to+any+branch");
                return;
            }

            // ── Action: updateSurcharge ──────────────────────────────────────────
            if ("updateSurcharge".equals(action)) {
                String[] seatTypes = { "NORMAL", "VIP", "COUPLE" };
                String[] rateParamKeys = { "rateNORMAL", "rateVIP", "rateCOUPLE" };

                SeatTypeSurcharges surchargesRepo = new SeatTypeSurcharges();
                int updated = 0;
                for (int i = 0; i < seatTypes.length; i++) {
                    String rateStr = request.getParameter(rateParamKeys[i]);
                    if (rateStr == null)
                        continue;
                    try {
                        double rate = Double.parseDouble(rateStr);
                        if (rate < 0)
                            continue;
                        if (surchargesRepo.upsertSurcharge(branch.getBranchId(), seatTypes[i], rate))
                            updated++;
                    } catch (NumberFormatException e) {
                        /* skip */ }
                }
                if (updated > 0) {
                    response.sendRedirect(request.getContextPath()
                            + "/branch-manager/manage-seat-type?success=Surcharge+rates+updated+successfully");
                } else {
                    response.sendRedirect(request.getContextPath()
                            + "/branch-manager/manage-seat-type?error=No+surcharge+rates+updated");
                }
                return;
            }

            // ── Action: updateBulk ───────────────────────────────────────────────
            String roomIdStr = request.getParameter("roomId");
            if (roomIdStr == null) {
                response.sendRedirect(request.getContextPath() + "/branch-manager/manage-seat-type?error=Missing+room");
                return;
            }
            int roomId = Integer.parseInt(roomIdStr);

            ScreeningRooms roomsRepo = new ScreeningRooms();
            ScreeningRoom room = roomsRepo.getRoomById(roomId);
            if (room == null || room.getBranchId() != branch.getBranchId()) {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-seat-type?error=Room+not+found+or+access+denied");
                return;
            }

            Seats seatsRepo = new Seats();
            boolean success = false;
            String message = "";

            if ("updateBulk".equals(action)) {
                String[] seatIds = request.getParameterValues("seatIds[]");
                String seatType = request.getParameter("seatType");

                if (seatIds == null || seatIds.length == 0 || seatType == null) {
                    message = "No seats selected or invalid seat type";
                } else if (!seatType.equals("NORMAL") && !seatType.equals("VIP") && !seatType.equals("COUPLE")) {
                    message = "Invalid seat type";
                } else {
                    List<Integer> idList = new ArrayList<>();
                    for (String id : seatIds) {
                        try {
                            idList.add(Integer.parseInt(id));
                        } catch (NumberFormatException ignore) {
                        }
                    }
                    if (!idList.isEmpty()) {
                        success = seatsRepo.updateSeatTypesInBatch(idList, seatType);
                        message = success ? "Updated " + idList.size() + " seat(s) to " + seatType
                                : "Failed to update seat types";
                    } else {
                        message = "No valid seats selected";
                    }
                }

            } else if ("updateSingle".equals(action)) {
                String seatIdStr = request.getParameter("seatId");
                String seatType = request.getParameter("seatType");
                if (seatIdStr == null || seatType == null) {
                    message = "Invalid parameters";
                } else if (!seatType.equals("NORMAL") && !seatType.equals("VIP") && !seatType.equals("COUPLE")) {
                    message = "Invalid seat type";
                } else {
                    int seatId = Integer.parseInt(seatIdStr);
                    Seat seat = seatsRepo.getSeatById(seatId);
                    if (seat == null || seat.getRoomId() != roomId) {
                        message = "Seat not found or access denied";
                    } else {
                        success = seatsRepo.updateSeatType(seatId, seatType);
                        message = success ? "Seat type updated to " + seatType : "Failed to update seat type";
                    }
                }
            } else {
                message = "Invalid action";
            }

            if (success) {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-seat-type?roomId=" + roomId + "&success=" + message);
            } else {
                response.sendRedirect(request.getContextPath()
                        + "/branch-manager/manage-seat-type?roomId=" + roomId + "&error=" + message);
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-seat-type?error=Invalid+ID+format");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath()
                    + "/branch-manager/manage-seat-type?error=" + e.getMessage());
        }
    }
}
