package controllers.staff;

import models.CounterTicket;
import models.Showtime;
import models.Seat;
import repositories.CounterTickets;
import repositories.Showtimes;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import com.itextpdf.text.pdf.draw.LineSeparator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@WebServlet(name = "counterBookingReceipt", urlPatterns = {"/staff/counter-booking-receipt"})
public class CounterBookingReceipt extends HttpServlet {

    private static final Font FONT_TITLE = new Font(Font.FontFamily.HELVETICA, 24, Font.BOLD);
    private static final Font FONT_HEADER = new Font(Font.FontFamily.HELVETICA, 14, Font.BOLD);
    private static final Font FONT_NORMAL = new Font(Font.FontFamily.HELVETICA, 11, Font.NORMAL);
    private static final Font FONT_SMALL = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL);
    private static final BaseColor COLOR_PRIMARY = new BaseColor(217, 108, 44); // #d96c2c

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not authenticated");
            return;
        }

        // Check role
        String role = (String) session.getAttribute("role");
        if (!"CINEMA_STAFF".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        // Get ticket code
        String ticketCode = request.getParameter("ticketCode");
        if (ticketCode == null || ticketCode.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ticket code required");
            return;
        }

        CounterTickets counterTicketsRepo = null;
        Showtimes showtimesRepo = null;
        
        try {
            counterTicketsRepo = new CounterTickets();
            showtimesRepo = new Showtimes();

            // Get tickets by code
            List<CounterTicket> tickets = counterTicketsRepo.getCounterTicketsByCode(ticketCode);
            
            if (tickets.isEmpty()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Tickets not found");
                return;
            }

            // Get showtime details
            CounterTicket firstTicket = tickets.get(0);
            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(firstTicket.getShowtimeId());
            
            if (showtimeDetails.isEmpty()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Showtime not found");
                return;
            }

            // Generate PDF
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=Receipt_" + ticketCode + ".pdf");
            
            generateReceiptPDF(response.getOutputStream(), tickets, showtimeDetails, showtimesRepo);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating receipt: " + e.getMessage());
        } finally {
            if (counterTicketsRepo != null) {
                counterTicketsRepo.closeConnection();
            }
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }

    private void generateReceiptPDF(OutputStream out, List<CounterTicket> tickets, Map<String, Object> showtimeDetails, Showtimes showtimesRepo) 
            throws DocumentException, IOException {
        
        Document document = new Document(PageSize.A4, 50, 50, 50, 50);
        PdfWriter.getInstance(document, out);
        document.open();

        try {
            CounterTicket firstTicket = tickets.get(0);
            Showtime showtime = (Showtime) showtimeDetails.get("showtime");
            String movieTitle = (String) showtimeDetails.get("movieTitle");
            String roomName = (String) showtimeDetails.get("roomName");
            String branchName = (String) showtimeDetails.get("branchName");
            String branchAddress = (String) showtimeDetails.get("branchAddress");

            // Header - Cinema Logo & Name
            Paragraph header = new Paragraph("MBCMS CINEMA", FONT_TITLE);
            header.setAlignment(Element.ALIGN_CENTER);
            header.setSpacingAfter(5);
            document.add(header);

            Paragraph branchInfo = new Paragraph(branchName, FONT_HEADER);
            branchInfo.setAlignment(Element.ALIGN_CENTER);
            branchInfo.setSpacingAfter(3);
            document.add(branchInfo);

            Paragraph address = new Paragraph(branchAddress, FONT_SMALL);
            address.setAlignment(Element.ALIGN_CENTER);
            address.setSpacingAfter(20);
            document.add(address);

            // Line separator
            document.add(new Paragraph(new Chunk(new LineSeparator(1, 100, COLOR_PRIMARY, Element.ALIGN_CENTER, -2))));
            document.add(Chunk.NEWLINE);

            // Title
            Paragraph title = new Paragraph("COUNTER BOOKING RECEIPT", FONT_HEADER);
            title.setAlignment(Element.ALIGN_CENTER);
            title.setSpacingAfter(20);
            document.add(title);

            // Receipt Info
            PdfPTable infoTable = new PdfPTable(2);
            infoTable.setWidthPercentage(100);
            infoTable.setSpacingAfter(20);

            addInfoRow(infoTable, "Ticket Code:", firstTicket.getTicketCode(), true);
            addInfoRow(infoTable, "Date:", LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")), false);
            addInfoRow(infoTable, "Payment Method:", firstTicket.getPaymentMethod(), false);
            
            if (firstTicket.getCustomerName() != null && !firstTicket.getCustomerName().isEmpty()) {
                addInfoRow(infoTable, "Customer Name:", firstTicket.getCustomerName(), false);
            }
            if (firstTicket.getCustomerPhone() != null && !firstTicket.getCustomerPhone().isEmpty()) {
                addInfoRow(infoTable, "Customer Phone:", firstTicket.getCustomerPhone(), false);
            }

            document.add(infoTable);

            // Movie & Showtime Info
            Paragraph movieHeader = new Paragraph("MOVIE INFORMATION", FONT_HEADER);
            movieHeader.setSpacingBefore(10);
            movieHeader.setSpacingAfter(10);
            document.add(movieHeader);

            PdfPTable movieTable = new PdfPTable(2);
            movieTable.setWidthPercentage(100);
            movieTable.setSpacingAfter(20);

            addInfoRow(movieTable, "Movie:", movieTitle, true);
            addInfoRow(movieTable, "Date:", showtime.getShowDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")), false);
            addInfoRow(movieTable, "Time:", showtime.getStartTime().format(DateTimeFormatter.ofPattern("HH:mm")), false);
            addInfoRow(movieTable, "Room:", roomName, false);

            document.add(movieTable);

            // Tickets Table
            Paragraph ticketsHeader = new Paragraph("TICKETS", FONT_HEADER);
            ticketsHeader.setSpacingBefore(10);
            ticketsHeader.setSpacingAfter(10);
            document.add(ticketsHeader);

            PdfPTable ticketsTable = new PdfPTable(new float[]{1, 2, 2, 2, 3});
            ticketsTable.setWidthPercentage(100);
            ticketsTable.setSpacingAfter(20);

            // Table headers
            addTableHeader(ticketsTable, "No.");
            addTableHeader(ticketsTable, "Seat");
            addTableHeader(ticketsTable, "Seat Type");
            addTableHeader(ticketsTable, "Ticket Type");
            addTableHeader(ticketsTable, "Price (VND)");

            // Table data
            BigDecimal totalAmount = BigDecimal.ZERO;
            int index = 1;
            
            for (CounterTicket ticket : tickets) {
                // Get seat info
                List<Map<String, Object>> seatsWithStatus = showtimesRepo.getSeatsWithBookingStatus(ticket.getShowtimeId());
                String seatCode = "";
                for (Map<String, Object> seatInfo : seatsWithStatus) {
                    Seat seat = (Seat) seatInfo.get("seat");
                    if (seat.getSeatId().equals(ticket.getSeatId())) {
                        seatCode = seat.getSeatCode();
                        break;
                    }
                }

                addTableCell(ticketsTable, String.valueOf(index++));
                addTableCell(ticketsTable, seatCode);
                addTableCell(ticketsTable, ticket.getSeatType());
                addTableCell(ticketsTable, ticket.getTicketType());
                addTableCell(ticketsTable, formatCurrency(ticket.getPrice()));

                totalAmount = totalAmount.add(ticket.getPrice());
            }

            document.add(ticketsTable);

            // Total Amount
            PdfPTable totalTable = new PdfPTable(2);
            totalTable.setWidthPercentage(100);
            totalTable.setSpacingBefore(10);

            PdfPCell labelCell = new PdfPCell(new Phrase("TOTAL AMOUNT:", FONT_HEADER));
            labelCell.setBorder(Rectangle.NO_BORDER);
            labelCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
            labelCell.setPaddingRight(10);
            totalTable.addCell(labelCell);

            PdfPCell amountCell = new PdfPCell(new Phrase(formatCurrency(totalAmount), FONT_HEADER));
            amountCell.setBorder(Rectangle.NO_BORDER);
            amountCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
            totalTable.addCell(amountCell);

            document.add(totalTable);

            // Footer
            document.add(Chunk.NEWLINE);
            document.add(Chunk.NEWLINE);
            
            Paragraph footer1 = new Paragraph("Thank you for your business!", FONT_NORMAL);
            footer1.setAlignment(Element.ALIGN_CENTER);
            footer1.setSpacingAfter(5);
            document.add(footer1);

            Paragraph footer2 = new Paragraph("Please keep this receipt for your records", FONT_SMALL);
            footer2.setAlignment(Element.ALIGN_CENTER);
            footer2.setSpacingAfter(20);
            document.add(footer2);

            // Barcode-like ticket code
            Paragraph barcodeText = new Paragraph(firstTicket.getTicketCode(), 
                new Font(Font.FontFamily.COURIER, 14, Font.BOLD));
            barcodeText.setAlignment(Element.ALIGN_CENTER);
            document.add(barcodeText);

            Paragraph scanNote = new Paragraph("Scan this code at entrance", FONT_SMALL);
            scanNote.setAlignment(Element.ALIGN_CENTER);
            document.add(scanNote);

        } finally {
            document.close();
        }
    }

    private void addInfoRow(PdfPTable table, String label, String value, boolean bold) {
        Font labelFont = bold ? FONT_HEADER : FONT_NORMAL;
        Font valueFont = bold ? FONT_HEADER : FONT_NORMAL;

        PdfPCell labelCell = new PdfPCell(new Phrase(label, labelFont));
        labelCell.setBorder(Rectangle.NO_BORDER);
        labelCell.setPaddingBottom(5);
        table.addCell(labelCell);

        PdfPCell valueCell = new PdfPCell(new Phrase(value, valueFont));
        valueCell.setBorder(Rectangle.NO_BORDER);
        valueCell.setPaddingBottom(5);
        table.addCell(valueCell);
    }

    private void addTableHeader(PdfPTable table, String text) {
        PdfPCell cell = new PdfPCell(new Phrase(text, FONT_HEADER));
        cell.setBackgroundColor(new BaseColor(240, 240, 240));
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setPadding(8);
        table.addCell(cell);
    }

    private void addTableCell(PdfPTable table, String text) {
        PdfPCell cell = new PdfPCell(new Phrase(text, FONT_NORMAL));
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setPadding(6);
        table.addCell(cell);
    }

    private String formatCurrency(BigDecimal amount) {
        return String.format("%,.0f", amount);
    }
}
