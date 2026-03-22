package controllers.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.User;
import models.UserVoucher;
import models.Voucher;
import models.LoyaltyConfig;
import repositories.LoyaltyConfigs;
import repositories.UserVouchers;
import repositories.Users;
import repositories.Vouchers;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "PromotionServlet", urlPatterns = {"/customer/promotions"})
public class PromotionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User sessionUser = (User) session.getAttribute("user");

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Users userRepo = new Users();
        Vouchers voucherRepo = new Vouchers();
        UserVouchers userVoucherRepo = new UserVouchers();
        LoyaltyConfigs configRepo = new LoyaltyConfigs();

        User user = userRepo.getUserById(sessionUser.getUserId());
        List<Voucher> loyaltyVouchers = voucherRepo.getLoyaltyVouchers();
        List<Voucher> publicVouchers = voucherRepo.getPublicVouchers();
        List<UserVoucher> myVouchers = userVoucherRepo.getAvailableVouchersByUserId(user.getUserId());
        LoyaltyConfig loyaltyConfig = configRepo.getConfig();

        request.setAttribute("user", user);
        request.setAttribute("loyaltyVouchers", loyaltyVouchers);
        request.setAttribute("publicVouchers", publicVouchers);
        request.setAttribute("myVouchers", myVouchers);
        request.setAttribute("loyaltyConfig", loyaltyConfig);

        request.getRequestDispatcher("/pages/customer/promotion.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User sessionUser = (User) session.getAttribute("user");

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("redeem".equals(action)) {
            try {
                int voucherId = Integer.parseInt(request.getParameter("voucherId"));
                Vouchers voucherRepo = new Vouchers();
                UserVouchers userVoucherRepo = new UserVouchers();
                Users userRepo = new Users();

                Voucher voucher = voucherRepo.getVoucherById(voucherId);
                User user = userRepo.getUserById(sessionUser.getUserId());
                LoyaltyConfigs configRepo = new LoyaltyConfigs();
                LoyaltyConfig config = configRepo.getConfig();

                if (voucher != null && user != null && config != null) {
                    if (user.getPoints() < config.getMinRedeemPoints()) {
                        session.setAttribute("toastMessage", "Bạn cần đạt tối thiểu " + config.getMinRedeemPoints() + " điểm để dùng đổi quà!");
                        session.setAttribute("toastType", "warning");
                    } else if (user.getPoints() >= voucher.getPointsCost()) {
                        boolean success = userVoucherRepo.redeemVoucher(user.getUserId(), voucher);
                        if (success) {
                            session.setAttribute("toastMessage", "Đổi voucher thành công!");
                            session.setAttribute("toastType", "success");
                        } else {
                            session.setAttribute("toastMessage", "Đổi voucher thất bại. Vui lòng thử lại!");
                            session.setAttribute("toastType", "error");
                        }
                    } else {
                        session.setAttribute("toastMessage", "Bạn không đủ điểm để đổi voucher này!");
                        session.setAttribute("toastType", "warning");
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else if ("savePublic".equals(action)) {
            try {
                int voucherId = Integer.parseInt(request.getParameter("voucherId"));
                Vouchers voucherRepo = new Vouchers();
                UserVouchers userVoucherRepo = new UserVouchers();

                Voucher voucher = voucherRepo.getVoucherById(voucherId);
                if (voucher != null && "PUBLIC".equals(voucher.getVoucherType())) {
                    boolean success = userVoucherRepo.savePublicVoucher(sessionUser.getUserId(), voucher);
                    if (success) {
                        session.setAttribute("toastMessage", "Lưu voucher công khai thành công!");
                        session.setAttribute("toastType", "success");
                    } else {
                        session.setAttribute("toastMessage", "Bạn đã sở hữu voucher này hoặc voucher đã hết lượt dùng!");
                        session.setAttribute("toastType", "warning");
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/customer/promotions");
    }
}
