<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <title>Admin Dashboard</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
        <style>
            body {
                padding-top: 56px;
                /* Height of fixed navbar */
                overflow-x: hidden;
                background-color: #f8f9fa;
            }

            #sidebarMenu {
                height: calc(100vh - 56px);
                /* Full height minus header */
                position: fixed;
                top: 56px;
                left: 0;
                bottom: 0;
                z-index: 100;
                overflow-y: auto;
            }

            main {
                margin-left: 280px;
                /* Width of sidebar */
                padding: 20px;
                transition: margin-left 0.3s;
            }

            /* Collapsed State */
            .sidebar-collapsed #sidebarMenu {
                margin-left: -280px;
            }

            .sidebar-collapsed main {
                margin-left: 0;
            }
        </style>
    </head>

    <body>

        <!-- Header (Fixed Top) -->
        <jsp:include page="/components/layout/admin/admin_header.jsp" />

        <!-- Sidebar -->
        <jsp:include page="/components/layout/admin/admin_sidebar.jsp" />

        <!-- Main Content -->
        <main>
            <!-- Page Content -->
            <div class="container-fluid">
                <!-- Content intentionally left empty -->
            </div>
        </main>

        <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const toggleBtn = document.getElementById('sidebarToggle');
                const body = document.body;

                if (toggleBtn) {
                    toggleBtn.addEventListener('click', function () {
                        body.classList.toggle('sidebar-collapsed');
                    });
                }
            });
        </script>

    </body>

    </html>