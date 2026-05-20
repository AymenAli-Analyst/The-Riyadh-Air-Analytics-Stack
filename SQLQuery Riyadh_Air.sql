SELECT * FROM [dbo].[Riyadh_Air_Employees_Data]

SELECT * FROM [dbo].[Riyadh_Air_Flights_Data]

SELECT Flight_ID,
Aircraft_Model,
Departure_Airport,
Arrival_Airport,
Flight_Status,
Passengers_Count,
Ticket_Class,
Delay_Minutes,
 -- Financial Calculations
Flight_Revenue_SAR,
Total_Flight_Cost_SAR,
(Flight_Revenue_SAR - Total_Flight_Cost_SAR) AS Net_Profit_SAR,
ROUND(((Flight_Revenue_SAR - Total_Flight_Cost_SAR) / NULLIF(Flight_Revenue_SAR, 0)) * 100, 2) AS Profit_Margin_Percentage,
 -- Operational Efficiency
CASE 
WHEN Delay_Minutes = 0 THEN 'On-Time'
WHEN Delay_Minutes <= 15 THEN 'Slight Delay'
WHEN Delay_Minutes <= 60 THEN 'Moderate Delay'
ELSE 'Severe Delay'
END AS Delay_Severity
FROM [dbo].[Riyadh_Air_Flights_Data]



SELECT Departure_Airport,Arrival_Airport,Aircraft_Model,
COUNT(Flight_ID) AS Total_Flights,
SUM(Passengers_Count) AS Total_Passengers,
SUM(Flight_Revenue_SAR) AS Total_Revenue,
SUM(Fuel_Cost_SAR) AS Total_Fuel_Cost,
-- Efficiency Metrics
ROUND(SUM(Fuel_Cost_SAR) / NULLIF(SUM(Passengers_Count), 0), 2) AS Fuel_Cost_Per_Passenger,
ROUND(SUM(Flight_Revenue_SAR) / NULLIF(SUM(Passengers_Count), 0), 2) AS Average_Revenue_Per_Passenger
FROM [dbo].[Riyadh_Air_Flights_Data]
GROUP BY Departure_Airport, Arrival_Airport, Aircraft_Model
ORDER BY Total_Revenue DESC


SELECT Department,Position,
COUNT(Employee_ID) AS Total_Employees,
ROUND(AVG(Monthly_Salary_SAR), 2) AS Avg_Monthly_Salary,
ROUND(AVG(Performance_Score), 2) AS Avg_Performance_Score,
SUM(Overtime_Hours) AS Total_Overtime_Hours, -- Evaluating Overtime Impact on Performance
ROUND(SUM(Overtime_Hours) / NULLIF(COUNT(Employee_ID), 0), 1) AS Avg_Overtime_Per_Employee,
ROUND(AVG(Vacation_Days_Used), 1) AS Avg_Vacation_Days_Used
FROM [dbo].[Riyadh_Air_Employees_Data]
GROUP BY Department, Position
ORDER BY Avg_Performance_Score DESC

SELECT Ticket_Class,
COUNT(Flight_ID) AS Total_Flights,
SUM(Passengers_Count) AS Total_Passengers,
ROUND(AVG(Average_Ticket_Price_SAR), 2) AS Avg_Ticket_Price,
ROUND(AVG(Discount_Percentage), 2) AS Avg_Discount_Given,
SUM(Flight_Revenue_SAR) AS Total_Gross_Revenue, -- Estimating revenue lost due to discounts
SUM(Flight_Revenue_SAR * (Discount_Percentage / 100.0)) AS Estimated_Discount_Cost
FROM [dbo].[Riyadh_Air_Flights_Data]
GROUP BY Ticket_Class
ORDER BY Total_Gross_Revenue DESC

SELECT Aircraft_Model,
COUNT(Flight_ID) AS Total_Flights,
SUM(Fuel_Cost_SAR) AS Total_Fuel_Cost,
SUM(Crew_Cost_SAR) AS Total_Crew_Cost,
SUM(Maintenance_Cost_SAR) AS Total_Maintenance_Cost,
SUM(Airport_Fees_SAR) AS Total_Airport_Fees,
SUM(Total_Flight_Cost_SAR) AS Total_Operating_Costs,
-- Percentage of Fuel from Total Cost
ROUND((SUM(Fuel_Cost_SAR) / NULLIF(SUM(Total_Flight_Cost_SAR), 0)) * 100, 2) AS Fuel_Cost_Share_Percentage
FROM [dbo].[Riyadh_Air_Flights_Data]
GROUP BY Aircraft_Model
ORDER BY Total_Operating_Costs DESC


SELECT FORMAT(Departure_Date, 'yyyy-MM') AS Flight_Month,
COUNT(Flight_ID) AS Total_Flights,
SUM(Passengers_Count) AS Total_Passengers,
SUM(Flight_Revenue_SAR) AS Monthly_Revenue,
AVG(Delay_Minutes) AS Avg_Delay_Minutes
FROM [dbo].[Riyadh_Air_Flights_Data]
GROUP BY FORMAT(Departure_Date, 'yyyy-MM')
ORDER BY Flight_Month ASC

SELECT Departure_Airport,
Arrival_Airport,
COUNT(Flight_ID) AS Total_Flights,
SUM(CASE WHEN Flight_Status = 'Delayed' THEN 1 ELSE 0 END) AS Delayed_Flights_Count,
ROUND((SUM(CASE WHEN Flight_Status = 'Delayed' THEN 1 ELSE 0 END) * 100.0) / COUNT(Flight_ID), 2) AS Delay_Rate_Percentage,
SUM(Delay_Minutes) AS Total_Delay_Minutes,
AVG(Delay_Minutes) AS Avg_Delay_Minutes_Per_Flight
FROM [dbo].[Riyadh_Air_Flights_Data]
GROUP BY Departure_Airport, Arrival_Airport
HAVING COUNT(Flight_ID) > 0
ORDER BY Delay_Rate_Percentage DESC


WITH RankedEmployees AS (
SELECT 
Employee_ID, Full_Name, Department,
Position,Performance_Score,
Monthly_Salary_SAR,
ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Performance_Score DESC) AS Performance_Rank
FROM [dbo].[Riyadh_Air_Employees_Data]
)
SELECT 
    Employee_ID,
    Full_Name,
    Department,
    Position,
    Performance_Score,
    Monthly_Salary_SAR
FROM RankedEmployees
WHERE Performance_Rank <= 3; -- Triggers top 3 employees per department


SELECT Employee_ID,
Full_Name,Department,
Position,
Performance_Score,
(Monthly_Salary_SAR * 12) + Annual_Bonus_SAR AS Total_Annual_Compensation_SAR,
-- Productivity Index: Higher score means more cost-effective performance
ROUND((Performance_Score / NULLIF(((Monthly_Salary_SAR * 12) + Annual_Bonus_SAR), 0)) * 100000, 2) AS Productivity_Cost_Index
FROM [dbo].[Riyadh_Air_Employees_Data]
WHERE Performance_Score IS NOT NULL
ORDER BY Productivity_Cost_Index DESC


SELECT YEAR(Hire_Date) AS Hire_Year,
Employment_Type,
COUNT(Employee_ID) AS New_Hires_Count,
ROUND(AVG(Monthly_Salary_SAR), 2) AS Avg_Starting_Salary
FROM [dbo].[Riyadh_Air_Employees_Data]
GROUP BY YEAR(Hire_Date), Employment_Type
ORDER BY Hire_Year DESC