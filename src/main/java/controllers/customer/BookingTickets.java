package controllers.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "TicketsOfChosenMovie", urlPatterns = {"/customer/booking-tickets"})
public class BookingTickets extends HttpServlet {

    //MUA BAO NHIEU VE CHO 1 PHIM

    // nham dam bao user da dang nhap truoc khi dat ve
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if(session == null || session.getAttribute("user") == null){
            response.sendRedirect(request.getContextPath() + ("/login"));
        }


    }





}
