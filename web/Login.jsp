<%-- 
    Document   : Login
    Created on : Oct 22, 2025, 7:16:09 PM
    Author     : biacb
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <h1>Welcome to Web</h1>
        <form action="Login" method="POST">
        <table>
            <tbody>
                <tr>
                    <td>StudentId : </td>
                    <td>Name : </td>
                </tr>
                <tr>
                    <td><input type="text" name="id" value=""></td>
                    <td><input type="text" name="name" value=""></td>
                </tr>
            </tbody>
        </table>
        <input type="submit" value="LOGIN" />
        </form>
    </body>
</html>
