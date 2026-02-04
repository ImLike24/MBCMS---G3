/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controllers.users;

import java.io.IOException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.User;
import repositories.Users;

/**
 *
 * @author ImLike
 */
@WebServlet(name = "ChangeAvatar", urlPatterns = "/change-avatar")
public class ChangeAvatar extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession(false);
        User u = (User) session.getAttribute("user");

        if (u == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String avatarUrl = req.getParameter("avatarUrl");

        if (avatarUrl != null && !avatarUrl.isBlank()) {
            new Users().updateAvatar(u.getUserId(), avatarUrl);

            u.setAvatarUrl(avatarUrl);
            session.setAttribute("user", u);
        }
    }
}

