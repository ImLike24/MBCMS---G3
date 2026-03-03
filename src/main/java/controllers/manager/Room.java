package controllers.manager;

import models.CinemaBranch;
import models.ScreeningRoom;
import models.User;
import repositories.CinemaBranches;
import services.RoomService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ManagerRoomController", urlPatterns = { "/manager/rooms" })
public class Room extends HttpServlet {

    private final RoomService roomService = new RoomService();
    private final CinemaBranches branchDao = new CinemaBranches();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) return;

        List<CinemaBranch> managedBranches = branchDao.findListByManagerId(user.getUserId());
        if (managedBranches == null || managedBranches.isEmpty()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không quản lý chi nhánh nào.");
            return;
        }

        Integer selectedBranchId = null;
        String branchIdParam = request.getParameter("branchId");

        if (branchIdParam != null && !branchIdParam.isEmpty()) {
            selectedBranchId = Integer.parseInt(branchIdParam);
        } else if (session.getAttribute("selectedBranchId") != null) {
            selectedBranchId = (Integer) session.getAttribute("selectedBranchId");
        } else {
            selectedBranchId = managedBranches.get(0).getBranchId();
        }

        // Check xem branchId đang chọn có thực sự thuộc quyền của Manager này không
        final Integer finalSelectedId = selectedBranchId;
        boolean isValidBranch = managedBranches.stream().anyMatch(b -> b.getBranchId().equals(finalSelectedId));
        if (!isValidBranch) {
            selectedBranchId = managedBranches.get(0).getBranchId();
        }

        session.setAttribute("selectedBranchId", selectedBranchId);

        request.setAttribute("managedBranches", managedBranches);
        request.setAttribute("selectedBranchId", selectedBranchId);

        // Xử lý Action
        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "create":
                showForm(request, response, null, selectedBranchId);
                break;
            case "edit":
                int id = Integer.parseInt(request.getParameter("id"));
                showForm(request, response, roomService.getRoomById(id), selectedBranchId);
                break;
            case "delete":
                deleteRoom(request, response);
                break;
            default:
                listRooms(request, response, selectedBranchId);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        Integer selectedBranchId = (Integer) session.getAttribute("selectedBranchId");
        if (selectedBranchId == null) {
            response.sendRedirect("rooms");
            return;
        }

        String action = request.getParameter("action");

        try {
            ScreeningRoom room = extractFromRequest(request);
            room.setBranchId(selectedBranchId); // Gán đúng chi nhánh đang chọn

            if ("create".equals(action)) {
                roomService.createRoom(room);
                response.sendRedirect("rooms?message=created");
            } else if ("update".equals(action)) {
                room.setRoomId(Integer.parseInt(request.getParameter("roomId")));
                roomService.updateRoom(room);
                response.sendRedirect("rooms?message=updated");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            request.setAttribute("room", extractFromRequest(request));
            request.getRequestDispatcher("/pages/manager/screening-room/form.jsp").forward(request, response);
        }
    }

    // --- Helpers ---

    private void listRooms(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws ServletException, IOException {

        int page = 1;
        int pageSize = 10;

        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        int totalRooms = roomService.countRoomsByBranch(branchId);
        int totalPages = (int) Math.ceil((double) totalRooms / pageSize);

        List<ScreeningRoom> list = roomService.getRoomsByBranchWithPagination(branchId, page, pageSize);

        request.setAttribute("rooms", list);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher("/pages/manager/screening-room/list.jsp").forward(request, response);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response, ScreeningRoom room, int branchId)
            throws ServletException, IOException {
        if (room != null) request.setAttribute("room", room);

        List<CinemaBranch> branches = (List<CinemaBranch>) request.getAttribute("managedBranches");
        if(branches == null) {
            User user = (User) request.getSession().getAttribute("user");
            branches = branchDao.findListByManagerId(user.getUserId());
        }
        String branchName = branches.stream().filter(b -> b.getBranchId() == branchId).findFirst().get().getBranchName();
        request.setAttribute("currentBranchName", branchName);

        request.getRequestDispatcher("/pages/manager/screening-room/form.jsp").forward(request, response);
    }

    private void deleteRoom(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        roomService.deleteRoom(id);
        response.sendRedirect("rooms?message=deleted");
    }

    private ScreeningRoom extractFromRequest(HttpServletRequest request) {
        ScreeningRoom r = new ScreeningRoom();
        r.setRoomName(request.getParameter("roomName"));
        String seats = request.getParameter("totalSeats");
        r.setTotalSeats((seats != null && !seats.isEmpty()) ? Integer.parseInt(seats) : 0);
        r.setStatus(request.getParameter("status"));
        return r;
    }
}