package services;

import models.ScreeningRoom;
import repositories.ScreeningRooms;

import java.util.List;

public class RoomService {
    private final ScreeningRooms roomDao = new ScreeningRooms();

    public List<ScreeningRoom> getRoomsByBranch(int branchId) {
        return roomDao.findByBranchId(branchId);
    }

    public ScreeningRoom getRoomById(int id) {
        return roomDao.getRoomById(id);
    }

    public void createRoom(ScreeningRoom room) throws Exception {
        if (room.getRoomName() == null || room.getRoomName().trim().isEmpty()) {
            throw new Exception("Tên phòng không được để trống");
        }
        // Có thể thêm validate status phải thuộc (ACTIVE, CLOSED, MAINTENANCE) nếu cần
        roomDao.insertRoom(room);
    }

    public void updateRoom(ScreeningRoom room) throws Exception {
        if (roomDao.getRoomById(room.getRoomId()) == null) {
            throw new Exception("Phòng chiếu không tồn tại");
        }
        roomDao.updateRoom(room);
    }

    public void deleteRoom(int id) {
        roomDao.deleteRoom(id);
    }
}