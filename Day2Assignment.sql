

 --7)create trigger to update the stock quantity table whenever new order placed in orders table
CREATE TRIGGER trg_UpdateStockOnOrder
ON sales.order_items
AFTER INSERT
AS
BEGIN
   
    UPDATE PS
    SET PS.quantity = PS.quantity - I.quantity
    FROM production.stocks PS
    INNER JOIN inserted I ON PS.product_id = I.product_id
    WHERE PS.store_id = (SELECT store_id FROM sales.orders WHERE order_id = I.order_id);

  
    IF EXISTS (SELECT 1 FROM production.stocks WHERE quantity < 0)
    BEGIN
        RAISERROR ('Insufficient stock for one or more products.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;


INSERT INTO sales.orders (customer_id, order_status, order_date, required_date, shipped_date, store_id, staff_id)
VALUES (1, 1, GETDATE(), GETDATE() + 5, NULL, 1, 1);


DECLARE @OrderID INT = (SELECT SCOPE_IDENTITY());


INSERT INTO sales.order_items (order_id, item_id, product_id, quantity, list_price, discount)
VALUES (@OrderID, 1, 101, 5, 200.00, 0);  

SELECT * 
FROM production.stocks
WHERE product_id = 101;

--8)create trigger to that prevents deletion of a customer if they have existing order
CREATE TRIGGER trg_PreventCustomerDeletion
ON sales.customers
INSTEAD OF DELETE
AS
BEGIN
  
    IF EXISTS (
        SELECT 1
        FROM sales.orders O
        INNER JOIN deleted D ON O.customer_id = D.customer_id
    )
    BEGIN
     
        RAISERROR('Cannot delete customer with existing orders.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
      
        DELETE FROM sales.customers
        WHERE customer_id IN (SELECT customer_id FROM deleted);
    END
END;

DELETE FROM sales.customers WHERE customer_id = 1;

DELETE FROM sales.customers WHERE customer_id = 3;
select * from sales.orders order by customer_id

 --9)create a trigger that logs changes to the employee table into an employee audit table
 CREATE TABLE Employee (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY, 
    FirstName NVARCHAR(50) NOT NULL,          
    HireDate DATE NOT NULL                   
);

CREATE TABLE EmployeeAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,     
    EmployeeID INT NOT NULL,                 
    AuditDate DATETIME DEFAULT GETDATE()      
	)

	create trigger tgr_logchangesinEmployeeAudit
	on employee
	after insert,update,delete
	as begin
	insert into employeeaudit(EmployeeID)
	select employeeid from inserted;

	insert into employeeaudit(EmployeeID)
	select employeeid from deleted;

	end

	insert into employee values ('Harry','2024-09-09'),('David','2024-10-25')
	select * from Employee
	select * from EmployeeAudit

	--10)create a room table with below columns, roomid,roomtype,availability, create bookings table with below 
	--columns, bookingid,roomid,customername,checkindate,checkoutdate.insert some test data with both the tables,
	--ensure both the tables are having entity relationship .write a transaction that books a room for a customer,ensuring the room is marked as unavailable

	CREATE TABLE Room (
    RoomID INT IDENTITY(1,1) PRIMARY KEY,
    RoomType NVARCHAR(50) NOT NULL,
    Availability BIT NOT NULL DEFAULT 1 
);

CREATE TABLE Bookings (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    RoomID INT NOT NULL,
    CustomerName NVARCHAR(100) NOT NULL,
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID)  
);

INSERT INTO Room (RoomType, Availability) VALUES ('Single', 1);
INSERT INTO Room (RoomType, Availability) VALUES ('Double', 0);
INSERT INTO Room (RoomType, Availability) VALUES ('Suite', 1);

BEGIN TRANSACTION;


IF EXISTS (SELECT 1 FROM Room WHERE RoomID = 1 AND Availability = 1)
BEGIN
  
    INSERT INTO Bookings (RoomID, CustomerName, CheckInDate, CheckOutDate)
    VALUES (1, 'Samantha', '2024-10-25', '2024-10-31');

 
    UPDATE Room
    SET Availability = 0
    WHERE RoomID = 1;

   
    COMMIT TRANSACTION;
    PRINT 'Room booked successfully and marked as unavailable';
END
ELSE
BEGIN
  
    ROLLBACK TRANSACTION;
    PRINT 'Room is already unavailable';
END;

select * from Room
