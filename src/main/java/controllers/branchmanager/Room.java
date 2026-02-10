package controllers.branchmanager;

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

@WebServlet(name = "ManagerRoomController", urlPatterns = {"/manager/rooms"})
public class Room extends HttpServlet {

    private final RoomService roomService = new RoomService();
    private final CinemaBranches branchDao = new CinemaBranches();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Lấy thông tin Branch của Manager đang đăng nhập
        CinemaBranch currentBranch = getBranchOfCurrentUser(request);
        if (currentBranch == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: You are not a Branch Manager.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "create":
                showForm(request, response, null);
                break;
            case "edit":
                int id = Integer.parseInt(request.getParameter("id"));
                showForm(request, response, roomService.getRoomById(id));
                break;
            case "delete":
                deleteRoom(request, response);
                break;
            default:
                listRooms(request, response, currentBranch.getBranchId());
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        CinemaBranch currentBranch = getBranchOfCurrentUser(request);
        if (currentBranch == null) return;

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        try {
            ScreeningRoom room = extractFromRequest(request);
            room.setBranchId(currentBranch.getBranchId()); // Luôn gán vào branch của manager

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

    private CinemaBranch getBranchOfCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) return null;
        // Hàm findByManagerId này bạn nhớ thêm vào CinemaBranches.java như ở bước trước nhé
        return branchDao.findByManagerId(user.getUserId());
    }

    private void listRooms(HttpServletRequest request, HttpServletResponse response, int branchId)
            throws ServletException, IOException {
        List<ScreeningRoom> list = roomService.getRoomsByBranch(branchId);
        request.setAttribute("rooms", list);
        request.getRequestDispatcher("/pages/manager/screening-room/list.jsp").forward(request, response);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response, ScreeningRoom room)
            throws ServletException, IOException {
        if (room != null) request.setAttribute("room", room);
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

        r.setStatus(request.getParameter("status")); // ACTIVE, CLOSED, MAINTENANCE
        return r;
    }
}