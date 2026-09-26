Use AdventureWorks2019;
--- 01/Explore the Database
Select * From HumanResources.Employee;
Select * From HumanResources.Department;
Select * From HumanResources.EmployeeDepartmentHistory;
Select * From HumanResources.EmployeePayHistory;
Select * From HumanResources.[Shift];
Select * From Person.Person;
--- 02/DATA QUALITY
-- 1/Nulls Check
Select * 
From HumanResources.Employee
Where BusinessEntityID Is Null;
--
Select * 
From HumanResources.Employee
Where BirthDate Is Null
Or Gender Is Null Or SalariedFlag Is Null;
--
Select * 
From HumanResources.Department
Where DepartmentID Is Null;
-- 
Select * 
From HumanResources.EmployeeDepartmentHistory
Where BusinessEntityID Is Null;
-- 
Select * 
From HumanResources.EmployeePayHistory
Where BusinessEntityID Is Null;
-- 
Select * 
From HumanResources.[Shift]
Where ShiftID Is Null;
-- 
Select * 
From Person.Person
Where BusinessEntityID Is Null;
--2/Duplicates Check
Select BusinessEntityID,Count(*) Count_Employee
From HumanResources.Employee
Group By BusinessEntityID
Having Count(*)>1;
--
Select DepartmentID, Count(*) Count_Department
From HumanResources.Department
Group By DepartmentID
Having Count(*)>1 ;
--- 03/Invalid Value Check
-- 1/Categorical Values
Select Distinct Gender
From HumanResources.Employee;
-- 
Select Distinct MaritalStatus
From HumanResources.Employee;
--
Select Distinct JobTitle
From HumanResources.Employee;
-- 2/Numeric Values
Select *
From HumanResources.EmployeePayHistory
Where Rate <0;
-- 
Select *
From HumanResources.Employee
Where VacationHours<0 ;
--- 3/Date Values
Select *
From HumanResources.Employee
Where BirthDate>Getdate() ;
-- 
Select *
From HumanResources.Employee
Where HireDate<BirthDate;
-- 
Select *
From HumanResources.EmployeeDepartmentHistory
Where EndDate < StartDate;
--- VIEW:-
USE AdventureWorks2019;
GO

CREATE OR ALTER VIEW dbo.vw_Employee_Analytics AS
SELECT 
    e.BusinessEntityID AS EmployeeID,
    CONCAT(p.FirstName, ' ', ISNULL(p.MiddleName + ' ', ''), p.LastName) AS [Full Name],
    e.JobTitle,
    e.Gender,
    e.MaritalStatus,
    e.BirthDate,

    DATEDIFF(YEAR, e.BirthDate, GETDATE())
    - CASE
        WHEN DATEADD(YEAR, DATEDIFF(YEAR, e.BirthDate, GETDATE()), e.BirthDate) > GETDATE()
        THEN 1 ELSE 0
      END AS Age,

    e.HireDate,

    DATEDIFF(YEAR, e.HireDate, GETDATE())
    - CASE
        WHEN DATEADD(YEAR, DATEDIFF(YEAR, e.HireDate, GETDATE()), e.HireDate) > GETDATE()
        THEN 1 ELSE 0
      END AS YearsOfService,

    e.VacationHours,
    e.SickLeaveHours,
    d.DepartmentID,
    d.[Name] AS Department_Name,
    d.GroupName,
    sh.ShiftID,
    sh.[Name] AS ShiftName,
    pay.Rate,
    pay.PayFrequency

FROM HumanResources.Employee e
INNER JOIN Person.Person p
    ON e.BusinessEntityID = p.BusinessEntityID

LEFT JOIN HumanResources.EmployeeDepartmentHistory ed
    ON e.BusinessEntityID = ed.BusinessEntityID
    AND ed.EndDate IS NULL

LEFT JOIN HumanResources.Department d
    ON ed.DepartmentID = d.DepartmentID

LEFT JOIN HumanResources.[Shift] sh
    ON ed.ShiftID = sh.ShiftID

OUTER APPLY (
    SELECT TOP 1 Rate, PayFrequency
    FROM HumanResources.EmployeePayHistory
    WHERE BusinessEntityID = e.BusinessEntityID
    ORDER BY RateChangeDate DESC
) pay;
GO

SELECT TOP 10 *
FROM dbo.vw_Employee_Analytics;