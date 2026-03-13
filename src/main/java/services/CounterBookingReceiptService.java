package services;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Chunk;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.draw.LineSeparator;
import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import models.CounterTicket;
import models.Seat;
import models.Showtime;
import repositories.CounterTickets;
import repositories.Showtimes;

/**
 * Business logic for generating counter booking receipt PDFs.
 */
public class CounterBookingReceiptService {

    private static final Font FONT_TITLE = new Font(Font.FontFamily.HELVETICA, 24, Font.BOLD);
    private static final Font FONT_HEADER = new Font(Font.FontFamily.HELVETICA, 14, Font.BOLD);
    private static final Font FONT_NORMAL = new Font(Font.FontFamily.HELVETICA, 11, Font.NORMAL);
    private static final Font FONT_SMALL = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL);
    private static final BaseColor COLOR_PRIMARY = new BaseColor(217, 108, 44); // #d96c2c

    public void generateReceipt(String ticketCode, OutputStream out)
            throws IOException, DocumentException {

        CounterTickets counterTicketsRepo = null;
        Showtimes showtimesRepo = null;
        try {
            counterTicketsRepo = new CounterTickets();
            showtimesRepo = new Showtimes();

            List<CounterTicket> tickets = counterTicketsRepo.getCounterTicketsByCode(ticketCode);
            if (tickets.isEmpty()) {
                throw new IllegalArgumentException("Tickets not found for code: " + ticketCode);
            }

            CounterTicket firstTicket = tickets.get(0);
            Map<String, Object> showtimeDetails = showtimesRepo.getShowtimeDetails(firstTicket.getShowtimeId());
            if (showtimeDetails.isEmpty()) {
                throw new IllegalArgumentException("Showtime not found for ticket code: " + ticketCode);
            }

            generateReceiptPDF(out, tickets, showtimeDetails, showtimesRepo);

        } finally {
            if (counterTicketsRepo != null) {
                counterTicketsRepo.closeConnection();
            }
            if (showtimesRepo != null) {
                showtimesRepo.closeConnection();
            }
        }
    }

    private void generateReceiptPDF(OutputStream out, List<CounterTicket> tickets,
                                    Map<String, Object> showtimeDetails, Showtimes showtimesRepo)
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

            document.add(new Paragraph(new Chunk(new LineSeparator(1, 100, COLOR_PRIMARY, Element.ALIGN_CENTER, -2))));
            document.add(Chunk.NEWLINE);

            Paragraph title = new Paragraph("COUNTER BOOKING RECEIPT", FONT_HEADER);
            title.setAlignment(Element.ALIGN_CENTER);
            title.setSpacingAfter(20);
            document.add(title);

            PdfPTable infoTable = new PdfPTable(2);
            infoTable.setWidthPercentage(100);
            infoTable.setSpacingAfter(20);

            addInfoRow(infoTable, "Ticket Code:", firstTicket.getTicketCode(), true);
            addInfoRow(infoTable, "Date:",
                    LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")), false);
            addInfoRow(infoTable, "Payment Method:", firstTicket.getPaymentMethod(), false);

            if (firstTicket.getCustomerName() != null && !firstTicket.getCustomerName().isEmpty()) {
                addInfoRow(infoTable, "Customer Name:", firstTicket.getCustomerName(), false);
            }
            if (firstTicket.getCustomerPhone() != null && !firstTicket.getCustomerPhone().isEmpty()) {
                addInfoRow(infoTable, "Customer Phone:", firstTicket.getCustomerPhone(), false);
            }

            document.add(infoTable);

            Paragraph movieHeader = new Paragraph("MOVIE INFORMATION", FONT_HEADER);
            movieHeader.setSpacingBefore(10);
            movieHeader.setSpacingAfter(10);
            document.add(movieHeader);

            PdfPTable movieTable = new PdfPTable(2);
            movieTable.setWidthPercentage(100);
            movieTable.setSpacingAfter(20);

            addInfoRow(movieTable, "Movie:", movieTitle, true);
            addInfoRow(movieTable, "Date:",
                    showtime.getShowDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")), false);
            addInfoRow(movieTable, "Time:",
                    showtime.getStartTime().format(DateTimeFormatter.ofPattern("HH:mm")), false);
            addInfoRow(movieTable, "Room:", roomName, false);

            document.add(movieTable);

            Paragraph ticketsHeader = new Paragraph("TICKETS", FONT_HEADER);
            ticketsHeader.setSpacingBefore(10);
            ticketsHeader.setSpacingAfter(10);
            document.add(ticketsHeader);

            PdfPTable ticketsTable = new PdfPTable(new float[] { 1, 2, 2, 2, 3 });
            ticketsTable.setWidthPercentage(100);
            ticketsTable.setSpacingAfter(20);

            addTableHeader(ticketsTable, "No.");
            addTableHeader(ticketsTable, "Seat");
            addTableHeader(ticketsTable, "Seat Type");
            addTableHeader(ticketsTable, "Ticket Type");
            addTableHeader(ticketsTable, "Price (VND)");

            BigDecimal totalAmount = BigDecimal.ZERO;
            int index = 1;

            for (CounterTicket ticket : tickets) {
                List<Map<String, Object>> seatsWithStatus = showtimesRepo
                        .getSeatsWithBookingStatus(ticket.getShowtimeId());
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

            PdfPTable totalTable = new PdfPTable(2);
            totalTable.setWidthPercentage(100);
            totalTable.setSpacingBefore(10);

            PdfPCell labelCell = new PdfPCell(new Phrase("TOTAL AMOUNT:", FONT_HEADER));
            labelCell.setBorder(PdfPCell.NO_BORDER);
            labelCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
            labelCell.setPaddingRight(10);
            totalTable.addCell(labelCell);

            PdfPCell amountCell = new PdfPCell(new Phrase(formatCurrency(totalAmount), FONT_HEADER));
            amountCell.setBorder(PdfPCell.NO_BORDER);
            amountCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
            totalTable.addCell(amountCell);

            document.add(totalTable);

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

            Paragraph barcodeText = new Paragraph(firstTicket.getTicketCode(),
                    new Font(Font.FontFamily.COURIER, 14, Font.BOLD));
            barcodeText.setAlignment(Element.ALIGN_CENTER);
            document.add(barcodeText);

            Paragraph scanNote = new Paragraph("Scan this code at entrance", FONT_SMALL);
            scanNote.setAlignment(Element.ALIGN_CENTER);
            scanNote.setSpacingBefore(5);
            document.add(scanNote);

        } finally {
            document.close();
        }
    }

    private static void addInfoRow(PdfPTable table, String label, String value, boolean bold) {
        Font labelFont = bold ? FONT_HEADER : FONT_NORMAL;
        PdfPCell labelCell = new PdfPCell(new Phrase(label, labelFont));
        labelCell.setBorder(PdfPCell.NO_BORDER);
        labelCell.setPaddingBottom(5);

        PdfPCell valueCell = new PdfPCell(new Phrase(value != null ? value : "", FONT_NORMAL));
        valueCell.setBorder(PdfPCell.NO_BORDER);
        valueCell.setPaddingBottom(5);

        table.addCell(labelCell);
        table.addCell(valueCell);
    }

    private static void addTableHeader(PdfPTable table, String header) {
        PdfPCell cell = new PdfPCell(new Phrase(header, FONT_HEADER));
        cell.setBackgroundColor(COLOR_PRIMARY);
        cell.setPadding(5);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        table.addCell(cell);
    }

    private static void addTableCell(PdfPTable table, String text) {
        PdfPCell cell = new PdfPCell(new Phrase(text, FONT_NORMAL));
        cell.setPadding(5);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        table.addCell(cell);
    }

    private static String formatCurrency(BigDecimal amount) {
        if (amount == null) {
            return "0";
        }
        return String.format("%,.0f", amount);
    }
}

