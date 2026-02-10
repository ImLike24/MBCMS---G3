package services;

import models.ScreeningRoom;
import repositories.ScreeningRooms;

import java.util.List;

public class RoomService {
    private final ScreeningRooms roomDao = new ScreeningRooms();

    public List<ScreeningRoom> getRoomsByBranch(int branchId) {
        return roomDao.getAllRoomsByBranch(branchId);
    }

    public ScreeningRoom getRoomById(int id) {
        return roomDao.getRoomById(id);
    }

    public void createRoom(ScreeningRoom room) throws Exception {
        if (room.getRoomName() == null || room.getRoomName().trim().isEmpty()) {
            throw new Exception("Tên phòng không được để trống");
        }
        roomDao.insertRoom(room);
    }

    public void updateRoom(ScreeningRoom room) throws Exception {
        if (roomDao.getRoomById(room.getRoomId()) == null) {
            throw new Exception("Phòng chiếu không tồn tại");
        }
<<<<<<< HEAD
        if (!roomDao.updateRoom(room)) {
            throw new Exception("Failed to update room");
        }
    }

    public void deleteRoom(int id) {
        if (!roomDao.deleteRoom(id)) {
            // Maybe throw exception, but original doesn't
        }
=======
        roomDao.updateRoom(room);
    }

    public void deleteRoom(int id) {
        roomDao.deleteRoom(id);
>>>>>>> e2689a2b20958094300a4d048b38a472aab3ad85
    }
}