<<<<<<< HEAD
SWP391: MBCMS - Movie Booking Cinema Management System
Techs: Netbeans 17, Spring Boot, SQL Server 20+
RUNNING PROJECT
Not Updated Yet

Note: Before running Project, ensure configuring file src/main/resources/env.properties

PACKAGES:
1. webapp
Contains the user interface (JSP/HTML/CSS/JS). Its task is to display data and send requests to the Controller. It does not handle business logic and does not access the database.

2. controllers <--- webapp
Receive requests from the webapp and coordinate the processing flow. Call the business layer to process business logic and return results to the view.

It does not contain complex business logic and does not work directly with the database.

3. business <--- controller
Contains the system's business logic. Performs condition checks, processes data, and calls repositories when needed. Plays a central role in the processing flow.

4. repositories <--- business
Performs database access (CRUD). Contains SQL/JDBC statements and returns data in model form.

It does not handle business logic.

5. model <--- repositories
=======
# SWP391: MBCMS - Movie Booking Cinema Management System

## Techs: Netbeans 17, Spring Boot, SQL Server 20+



## RUNNING PROJECT

**Not Updated Yet**

**Note**: Before running Project, ensure configuring file `src/main/resources/env.properties`




## PACKAGES: <STILL INCOMPLETED>

## 1. webapp
Contains the user interface (JSP/HTML/CSS/JS).
Its task is to display data and send requests to the Controller.
It does not handle business logic and does not access the database.

## 2. controllers <--- webapp
Receive requests from the webapp and coordinate the processing flow.
Call the business layer to process business logic and return results to the view.

It does not contain complex business logic and does not work directly with the database.

## 3. business <--- controller
Contains the system's business logic.
Performs condition checks, processes data, and calls repositories when needed.
Plays a central role in the processing flow.

## 4. repositories <--- business
Performs database access (CRUD).
Contains SQL/JDBC statements and returns data in model form.

It does not handle business logic.

## 5. model <--- repositories
>>>>>>> d5cb098c9dde3288258bac4a44fbcf290d2939de
Represents data entities in the system. Mapped to a table in the database.

Contains only attributes and getters/setters.

<<<<<<< HEAD
6. config <--- repositories
Contains system configurations. Sets up the database connection (DBContext).

Used by repositories to work with the database.

7. utils <--- controller, business, repositories
=======
## 6. config <--- repositories
Contains system configurations.
Sets up the database connection (DBContext).

Used by repositories to work with the database.

## 7. utils <--- controller, business, repositories
>>>>>>> d5cb098c9dde3288258bac4a44fbcf290d2939de
Contains utility functions used throughout the system.

Examples: string processing, password encryption, data validation, date formatting.