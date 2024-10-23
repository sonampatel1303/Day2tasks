CREATE TABLE employee1 (
    EmployeeID INT,
    FirstName VARCHAR(50) ,
    LastName VARCHAR(50),
    HireDate DATE,
    JobTitle VARCHAR(50),
    Salary DECIMAL(10, 2)
);
INSERT INTO employee1 (EmployeeID, FirstName,LastName, HireDate, JobTitle, Salary)
VALUES 
(1,'Raj', 'Sharma', '2021-01-10', 'Software Engineer', 850000.00),
(3,'Priya', 'Verma', '2022-03-15', 'Project Manager', 1200000.00),
(5,'Amit', 'Patel', '2020-07-20', 'Business Analyst', 900000.00),
(2,'Neha', 'Gupta', '2019-11-25', 'HR Specialist', 600000.00),
(4,'Vikas', 'Reddy', '2018-06-01', 'Database Administrator', 950000.00),
(7,'Anjali', 'Nair', '2021-09-15', 'IT Support', 500000.00),
(6,'Rohit', 'Kumar', '2017-08-10', 'Network Engineer', 850000.00),
(8,'Samantha', 'Desai', '2020-12-18', 'Marketing Specialist', 700000.00),
(11,'Karan', 'Mehta', '2022-02-05', 'QA Engineer', 750000.00),
(10,'Pooja', 'Singh', '2021-04-11', 'UX Designer', 800000.00),
(9,'Suresh', 'Yadav', '2020-05-23', 'DevOps Engineer', 1100000.00),
(12,'Divya', 'Joshi', '2023-06-30', 'Front-End Developer', 850000.00);

select * from employee1

create index ix_employee_id
on employee1(EmployeeID ASC)

--Example for clustered index
--We can create only one clustered index per table
--if we have a primary key in a table automatically it will create clustered index for that table
--suppose when table is not having primary key then onlt we can create clustered index.If there are duplicate or null values ,
--then it will accept it and sort and store the data

create clustered index ix_employee_id1
on employee1(EmployeeID ASC)

drop table employee1

CREATE TABLE employe (
    EmployeeID INT primary key,
    FirstName VARCHAR(50) ,
    LastName VARCHAR(50),
    HireDate DATE,
    JobTitle VARCHAR(50),
    Salary DECIMAL(10, 2)
);

INSERT INTO employe (EmployeeID, FirstName,LastName, HireDate, JobTitle, Salary)
VALUES 
(1,'Raj', 'Sharma', '2021-01-10', 'Software Engineer', 850000.00),
(3,'Priya', 'Verma', '2022-03-15', 'Project Manager', 1200000.00),
(5,'Amit', 'Patel', '2020-07-20', 'Business Analyst', 900000.00),
(2,'Neha', 'Gupta', '2019-11-25', 'HR Specialist', 600000.00),
(4,'Vikas', 'Reddy', '2018-06-01', 'Database Administrator', 950000.00),
(7,'Anjali', 'Nair', '2021-09-15', 'IT Support', 500000.00),
(6,'Rohit', 'Kumar', '2017-08-10', 'Network Engineer', 850000.00),
(8,'Samantha', 'Desai', '2020-12-18', 'Marketing Specialist', 700000.00),
(11,'Karan', 'Mehta', '2022-02-05', 'QA Engineer', 750000.00),
(10,'Pooja', 'Singh', '2021-04-11', 'UX Designer', 800000.00),
(9,'Suresh', 'Yadav', '2020-05-23', 'DevOps Engineer', 1100000.00),
(12,'Divya', 'Joshi', '2023-06-30', 'Front-End Developer', 850000.00);

select * from employe

select * from sales.customers

--Example of unique index
create unique index idx_unique_email
on sales.customers(email)

create nonclustered index idx_name
on sales.customers(first_name,last_name)
--(or)
create index idx_name1
on sales.customers(first_name,last_name)

create table department(
Id int,
Name1 varchar(50))

insert into department values(1,'HR'),(1,'Admin'),(2,'IT'),(3,'Transport')

select * from department

create clustered index idx_dept_id
on department(id)

create view vWEmployeesByDepartment
as
select EmployeeID,FirstName,HireDate,JobTitle
from employe join Department
on employe.DeptID=Department.Dept_id

alter table employe add DeptID int

select * from vWEmployeesByDepartment
select * from Department
update vWEmployeesByDepartment set FirstName='Nadia' where EmployeeID=7

create view vWITDepartment_Employees
as
Select EmployeeID,FirstName,Salary,Dept_Name
from Employe JOIN Department on
employe.DeptID=Department.Dept_id where
employe.DeptID=1

select * from vWITDepartment_Employees

create view vWEmployeeConfidentialData
as
select FirstName,LastName,EmployeeID,Dept_Name
from employe join Department on employe.DeptID=Department.Dept_id

select * from vWEmployeeConfidentialData

create view vWEmployeeCountByDept
as
select count(DeptID) as TotalEmployees,Dept_Name,Dept_id
from employe join Department on employe.DeptID=Department.Dept_id
group by Dept_Name,Dept_id

select * from vWEmployeeCountByDept

sp_helptext vWEmployeeCountByDept

create table orders(
order_id int primary key,
customer_id int,
orderdate date);

create table order_audit(
audit_id int identity primary key,
order_id int,
customer_id int,
orderdate date,
audit_date datetime default getdate(),
audit_info varchar(max)
);

select * from orders
select * from order_audit

create trigger trgafterinsertorder
on orders
after insert
as begin
declare @auditinfo nvarchar(1000)
set @auditinfo='Data inserted'
insert into order_audit(order_id,customer_id,orderdate,audit_info)
select order_id,customer_id,orderdate,@auditinfo
from inserted
end

insert into orders values (1001,31,'10-10-2024')
insert into orders values (1002,32,'10-11-2024')

create view empdetails
as
select EmployeeID,FirstName,Dept_Name,salary 
from employe join Department
on employe.deptID=Department.Dept_id

select * from empdetails

create trigger tr_viewempdetails_insteadofinsert
on empdetails
instead of insert
as begin
declare @deptid int
select @deptid=dept_id from Department
join inserted
on inserted.Dept_Name=Department.Dept_Name
if(@deptid is null)
begin
raiserror('Invalid department',16,1)
return end
insert into employe(EmployeeID,FirstName,deptID)
select employeeid,firstname,@deptid
from inserted
end

insert empdetails values(13,'Tina','HR',5900)
insert empdetails values(14,'Tina','Banking',5900)
select * from Department
select * from employe

begin transaction
insert into sales.orders(customer_id,order_status,order_date,required_date,shipped_date,store_id,staff_id)
values(49,4,'20170228','20170301','20170302',2,6)
insert into sales.order_items(order_id,item_id,product_id,quantity,list_price,discount)
values(93,12,8,2,269.99,0.07)
if @@ERROR=0
begin
commit transaction
print 'Insertion successful..'
end
else
begin
rollback transaction
print 'somethig went wrong'
end

select * from production.products where product_id=8
select * from sales.order_items

create database transactions_demo

create table customers(
customer_id int primary key,
name varchar(100),
active bit)

create table orders(
order_id int primary key,
customer_id int foreign key references customers(customer_id),
order_status varchar(100))

insert into customers values (1,'Pam',1),
(2,'Kim',1)

insert into orders values (101,1,'Pending'),(102,2,'Pending')

--Transaction A
 begin transaction
 update customers set name='John'
 where customer_id=1

 waitfor delay '00:00:05';
 update orders set order_status='processed'
 where order_id=101
 commit transaction

 --Transaction B
 begin transaction
 update orders set order_status='Shipped'
 where order_id=101

 waitfor delay '00:00:05';

 update customers set name='Geetha'
 where customer_id=1
 commit transaction
