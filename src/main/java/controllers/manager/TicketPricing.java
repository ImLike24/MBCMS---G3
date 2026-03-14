package controllers.manager;

import models.CinemaBranch;
import models.TicketPrice;
import models.User;
import repositories.CinemaBranches;
import services.TicketPriceService; // IMPORT SERVICE MỚI
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "TicketPricingController", urlPatterns = {"/manager/ticket-prices"})
public class TicketPricing extends HttpServlet {

    private final TicketPriceService priceService = new TicketPriceService();
    private final CinemaBranches branchDao = new CinemaBranches();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<CinemaBranch> managedBranches = branchDao.findListByManagerId(user.getUserId());
        if (managedBranches == null || managedBranches.isEmpty()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập, hoặc chưa được gán quản lý chi nhánh nào.");
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

        session.setAttribute("selectedBranchId", selectedBranchId);
        request.setAttribute("managedBranches", managedBranches);
        request.setAttribute("selectedBranchId", selectedBranchId);

        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "create":
                    request.getRequestDispatcher("/pages/manager/ticket-price/form.jsp").forward(request, response);
                    break;
                case "view":
                case "edit":
                    int id = Integer.parseInt(request.getParameter("id"));
                    // GỌI SERVICE
                    TicketPrice price = priceService.getPriceById(id);
                    request.setAttribute("priceObj", price);
                    request.setAttribute("isViewMode", "view".equals(action));
                    request.getRequestDispatcher("/pages/manager/ticket-price/form.jsp").forward(request, response);
                    break;
                case "deactivate":
                    int deactId = Integer.parseInt(request.getParameter("id"));
                    // GỌI SERVICE
                    priceService.deactivateTicketPrice(deactId);
                    response.sendRedirect("ticket-prices?message=deactivated");
                    break;
                case "delete":
                    int delId = Integer.parseInt(request.getParameter("id"));
                    // GỌI SERVICE
                    priceService.deleteTicketPrice(delId);
                    response.sendRedirect("ticket-prices?message=deleted");
                    break;
                default:
                    listPrices(request, response, selectedBranchId);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("ticket-prices?error=true");
        }
    }

    private void listPrices(HttpServletRequest request, HttpServletResponse response, int branchId) throws ServletException, IOException {
        String search = request.getParameter("search");
        String dayType = request.getParameter("dayType");
        String status = request.getParameter("status");

        int page = 1;
        int pageSize = 10;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            page = Integer.parseInt(pageParam);
        }

        // GỌI SERVICE
        int totalRecords = priceService.countPricesWithFilter(branchId, search, dayType, status);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        List<TicketPrice> prices = priceService.getPricesWithFilterAndPagination(branchId, search, dayType, status, page, pageSize);

        request.setAttribute("prices", prices);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);

        request.setAttribute("searchQuery", search);
        request.setAttribute("dayTypeFilter", dayType);
        request.setAttribute("statusFilter", status);

        request.getRequestDispatcher("/pages/manager/ticket-price/list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        HttpSession session = request.getSession();
        Integer selectedBranchId = (Integer) session.getAttribute("selectedBranchId");
        String action = request.getParameter("action");

        TicketPrice p = new TicketPrice();

        try {
            p.setBranchId(selectedBranchId);
            p.setTicketType(request.getParameter("ticketType"));
            p.setDayType(request.getParameter("dayType"));
            p.setTimeSlot(request.getParameter("timeSlot"));
            p.setPrice(new BigDecimal(request.getParameter("price")));
            p.setEffectiveFrom(LocalDate.parse(request.getParameter("effectiveFrom")));

            String effTo = request.getParameter("effectiveTo");
            if(effTo != null && !effTo.isEmpty()) {
                p.setEffectiveTo(LocalDate.parse(effTo));
            }

            p.setActive(request.getParameter("isActive") != null);

            if ("create".equals(action)) {
                priceService.createTicketPrice(p);
                response.sendRedirect("ticket-prices?message=created");
            } else if ("update".equals(action)) {
                p.setPriceId(Integer.parseInt(request.getParameter("priceId")));
                priceService.updateTicketPrice(p);
                response.sendRedirect("ticket-prices?message=updated");
            }

        } catch (Exception e) {
            e.printStackTrace();

            request.setAttribute("errorMessage", e.getMessage());

            request.setAttribute("priceObj", p);
            request.getRequestDispatcher("/pages/manager/ticket-price/form.jsp").forward(request, response);
        }
    }
}