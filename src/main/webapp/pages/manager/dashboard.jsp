<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <title>Branch Manager Dashboard</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/font-awesome.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/manager-layout.css">
        <style>
            body {
                padding-top: 56px;
                overflow-x: hidden;
                background-color: #f8f9fa;
            }

            main {
                margin-left: 280px;
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

        <!-- Header -->
        <jsp:include page="/components/layout/dashboard/dashboard_header.jsp" />

        <!-- Sidebar -->
        <jsp:include page="/components/layout/dashboard/manager_sidebar.jsp" />

        <!-- Main Content -->
        <main>
            <div class="container-fluid">
                <h2>Welcome Branch Manager</h2>
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