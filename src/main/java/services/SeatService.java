package services;

import models.CinemaBranch;
import models.ScreeningRoom;
import models.Seat;
import models.SeatTypeSurcharge;
import repositories.CinemaBranches;
import repositories.ScreeningRooms;
import repositories.Seats;
import repositories.SeatTypeSurcharges;

import java.util.ArrayList;
import java.util.List;

public class SeatService {
    
    private final CinemaBranches branchesRepo = new CinemaBranches();
    private final ScreeningRooms roomsRepo = new ScreeningRooms();
    private final Seats seatsRepo = new Seats();
    private final SeatTypeSurcharges surchargesRepo = new SeatTypeSurcharges();
    
    public List<CinemaBranch> getManagedBranches(int managerId) {
        return branchesRepo.findListByManagerId(managerId);
    }
    
    public List<ScreeningRoom> getRoomsByBranch(int branchId) {
        return roomsRepo.getAllRoomsByBranch(branchId);
    }
    
    public ScreeningRoom getRoomById(int roomId) {
        return roomsRepo.getRoomById(roomId);
    }
    
    public List<Seat> getSeatsByRoom(int roomId) {
        return seatsRepo.getSeatsByRoom(roomId);
    }
    
    public List<Seat> getSeatsByRoomAndStatus(int roomId, String status) {
        return seatsRepo.getSeatsByRoomAndStatus(roomId, status);
    }
    
    public Seat getSeatById(int seatId) {
        return seatsRepo.getSeatById(seatId);
    }
    

    
    public List<SeatTypeSurcharge> getSurchargesByBranch(int branchId) {
        return surchargesRepo.getSurchargesByBranch(branchId);
    }
    
    public String generateSeatLayout(int branchId, int roomId, int rows, int columns) throws Exception {
        // Validate layout bounds
        if (rows < 1 || rows > 26 || columns < 1 || columns > 50) {
            throw new IllegalArgumentException("Invalid layout: Rows must be 1-26 (A-Z), Columns must be 1-50");
        }
        
        // Check room and branch access
        ScreeningRoom room = roomsRepo.getRoomById(roomId);
        if (room == null || room.getBranchId() != branchId) {
            throw new IllegalArgumentException("Room not found or access denied");
        }
        
        // Clear existing seats
        seatsRepo.deleteSeatsByRoom(roomId);
        
        // Generate new seats list
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
        
        // Insert seats in batch
        boolean success = seatsRepo.insertSeatsInBatch(newSeats);
        if (success) {
            // Update total seats in room
            room.setTotalSeats(newSeats.size());
            roomsRepo.updateRoom(room);
            return "Seat layout generated successfully: " + rows + " rows × " + columns + " columns = " + newSeats.size() + " seats";
        } else {
            throw new RuntimeException("Failed to generate seat layout");
        }
    }
    
    public String clearSeatLayout(int branchId, int roomId) throws Exception {
        // Check room and branch access
        ScreeningRoom room = roomsRepo.getRoomById(roomId);
        if (room == null || room.getBranchId() != branchId) {
            throw new IllegalArgumentException("Room not found or access denied");
        }
        
        // Delete all seats for the room
        boolean success = seatsRepo.deleteSeatsByRoom(roomId);
        if (success) {
            // Reset total seats in room
            room.setTotalSeats(0);
            roomsRepo.updateRoom(room);
            return "Seat layout cleared successfully";
        } else {
            throw new RuntimeException("Failed to clear seat layout");
        }
    }
    
    public String updateSeatStatusesBulk(int branchId, int roomId, List<Integer> seatIds, String status) throws Exception {
        // Validate inputs
        if (seatIds == null || seatIds.isEmpty()) {
            throw new IllegalArgumentException("No valid seats selected");
        }
        if (!status.equals("AVAILABLE") && !status.equals("BROKEN") && !status.equals("MAINTENANCE")) {
            throw new IllegalArgumentException("Invalid seat status");
        }
        
        // Check room and branch access
        ScreeningRoom room = roomsRepo.getRoomById(roomId);
        if (room == null || room.getBranchId() != branchId) {
            throw new IllegalArgumentException("Room not found or access denied");
        }
        
        // Update statuses in batch
        boolean success = seatsRepo.updateSeatStatusesInBatch(seatIds, status);
        if (success) {
            return "Updated " + seatIds.size() + " seat(s) to " + status;
        } else {
            throw new RuntimeException("Failed to update seat statuses");
        }
    }
    
    public String updateSeatStatusSingle(int branchId, int roomId, int seatId, String status) throws Exception {
        // Validate input
        if (!status.equals("AVAILABLE") && !status.equals("BROKEN") && !status.equals("MAINTENANCE")) {
            throw new IllegalArgumentException("Invalid seat status");
        }
        
        // Verify seat belongs to room
        Seat seat = seatsRepo.getSeatById(seatId);
        if (seat == null || seat.getRoomId() != roomId) {
            throw new IllegalArgumentException("Seat not found or access denied");
        }
        
        // Check room and branch access
        ScreeningRoom room = roomsRepo.getRoomById(roomId);
        if (room == null || room.getBranchId() != branchId) {
            throw new IllegalArgumentException("Room not found or access denied");
        }
        
        // Update single seat status
        boolean success = seatsRepo.updateSeatStatus(seatId, status);
        if (success) {
            return "Seat status updated to " + status;
        } else {
            throw new RuntimeException("Failed to update seat status");
        }
    }
    
    public int updateSurcharges(int branchId, String normalRateStr, String vipRateStr, String coupleRateStr) {
        String[] seatTypes = { "NORMAL", "VIP", "COUPLE" };
        String[] rates = { normalRateStr, vipRateStr, coupleRateStr };
        int updated = 0;
        
        // Parse and update each valid surcharge rate
        for (int i = 0; i < seatTypes.length; i++) {
            if (rates[i] == null) continue;
            try {
                double rate = Double.parseDouble(rates[i]);
                if (rate < 0) continue;
                
                // Upsert surcharge to database
                if (surchargesRepo.upsertSurcharge(branchId, seatTypes[i], rate)) {
                    updated++;
                }
            } catch (NumberFormatException e) {
                // Ignore invalid number format and continue
            }
        }
        return updated;
    }
    
    public String updateSeatTypesBulk(int branchId, int roomId, List<Integer> seatIds, String seatType) throws Exception {
        // Validate inputs
        if (seatIds == null || seatIds.isEmpty()) {
            throw new IllegalArgumentException("No valid seats selected");
        }
        if (!seatType.equals("NORMAL") && !seatType.equals("VIP") && !seatType.equals("COUPLE")) {
            throw new IllegalArgumentException("Invalid seat type");
        }
        
        // Check room and branch access
        ScreeningRoom room = roomsRepo.getRoomById(roomId);
        if (room == null || room.getBranchId() != branchId) {
            throw new IllegalArgumentException("Room not found or access denied");
        }
        
        // Update seat types in batch
        boolean success = seatsRepo.updateSeatTypesInBatch(seatIds, seatType);
        if (success) {
            return "Updated " + seatIds.size() + " seat(s) to " + seatType;
        } else {
            throw new RuntimeException("Failed to update seat types");
        }
    }
    
    public String updateSeatTypeSingle(int branchId, int roomId, int seatId, String seatType) throws Exception {
        // Validate input
        if (!seatType.equals("NORMAL") && !seatType.equals("VIP") && !seatType.equals("COUPLE")) {
            throw new IllegalArgumentException("Invalid seat type");
        }
        
        // Verify seat belongs to room
        Seat seat = seatsRepo.getSeatById(seatId);
        if (seat == null || seat.getRoomId() != roomId) {
            throw new IllegalArgumentException("Seat not found or access denied");
        }
        
        // Check room and branch access
        ScreeningRoom room = roomsRepo.getRoomById(roomId);
        if (room == null || room.getBranchId() != branchId) {
            throw new IllegalArgumentException("Room not found or access denied");
        }
        
        // Update single seat type
        boolean success = seatsRepo.updateSeatType(seatId, seatType);
        if (success) {
            return "Seat type updated to " + seatType;
        } else {
            throw new RuntimeException("Failed to update seat type");
        }
    }
}
