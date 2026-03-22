package services;

import models.ScreeningRoom;
import repositories.ScreeningRooms;
import java.util.List;

public class RoomService {
    private final ScreeningRooms roomDao = new ScreeningRooms();

    public List<ScreeningRoom> getRoomsWithFilter(int branchId, String search, String status, int page, int pageSize) {
        return roomDao.getRoomsByBranchWithFilterAndPagination(branchId, search, status, page, pageSize);
    }

    public int countRoomsWithFilter(int branchId, String search, String status) {
        return roomDao.countRoomsByBranchWithFilter(branchId, search, status);
    }

    public ScreeningRoom getRoomById(int id) {
        return roomDao.getRoomById(id);
    }

    public void createRoom(ScreeningRoom room) throws Exception {
        validateRoom(room, null); // null vì tạo mới không có exclude ID
        roomDao.insertRoom(room);
    }

    public void updateRoom(ScreeningRoom room) throws Exception {
        if (roomDao.getRoomById(room.getRoomId()) == null) {
            throw new Exception("Phòng chiếu không tồn tại.");
        }
        validateRoom(room, room.getRoomId()); // truyền ID vào để bỏ qua chính nó khi check trùng
        roomDao.updateRoom(room);
    }

    public void deleteRoom(int id) {
        roomDao.deleteRoom(id);
    }

    // --- LOGIC VALIDATION ---
    private void validateRoom(ScreeningRoom room, Integer excludeRoomId) throws Exception {
        if (room.getRoomName() == null || room.getRoomName().trim().isEmpty()) {
            throw new Exception("Tên phòng không được để trống.");
        }

        // Gọi hàm kiểm tra trùng tên trong cùng 1 rạp
        if (roomDao.roomNameExistsInBranch(room.getRoomName(), room.getBranchId(), excludeRoomId)) {
            throw new Exception("Tên phòng chiếu '" + room.getRoomName() + "' đã tồn tại trong chi nhánh này. Vui lòng chọn tên khác.");
        }
    }
}