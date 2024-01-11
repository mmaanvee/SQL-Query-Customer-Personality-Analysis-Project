# Question 1
-- How do the cumulative campaign acceptances change with the birth years of customers, 
-- and what is the trend in the total customer count over the years?
SELECT Year_Birth,
    SUM(AcceptedCmp1 + AcceptedCmp2 + AcceptedCmp3 + AcceptedCmp4 + AcceptedCmp5) 
        OVER(ORDER BY Year_Birth ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalCampaignAcceptance,
    COUNT(*) OVER(ORDER BY Year_Birth ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalCustomers
FROM Customer
INNER JOIN PromotionResponse ON Customer.ID = PromotionResponse.ID
ORDER BY Year_Birth;

# Question 2
-- How does the average income within each age group differ from the overall average income across 
-- all age groups?
SELECT DISTINCT Age_Group,
    AVG(Income) OVER(PARTITION BY Age_Group) AS AvgIncomeByAgeGroup,
    AVG(Income) OVER() AS OverallAvgIncome,
	(AVG(Income) OVER(PARTITION BY Age_Group)) - (SELECT AVG(Income) FROM Customer) AS IncomeDifferenceFromOverallAvg
FROM Customer
INNER JOIN demographics ON Customer.ID = demographics.ID
ORDER BY Age_Group;

# Question 3
-- What is the average number of store purchases based on different education levels and marital 
-- statuses, grouped into specific categories?
SELECT DISTINCT(demographics.Education),
    AVG(shoppingbehavior.NumStorePurchases) AS AvgStorePurchases,
    CASE WHEN demographics.Education = 'Graduation' AND demographics.Marital_Status = 'Married' THEN 'Group A'
         WHEN demographics.Education = 'Basic' AND demographics.Marital_Status = 'Single' THEN 'Group B'
         ELSE 'Others' END AS GroupComparison
FROM demographics
INNER JOIN Customer ON demographics.ID = Customer.ID
INNER JOIN shoppingbehavior ON Customer.ID = shoppingbehavior.ID
GROUP BY GroupComparison, demographics.Education;

# Question 4 
-- What is the average trend of web purchases for customers over a five-year period after their 
-- enrollment, grouped by the year they joined?
SELECT DISTINCT sb.ID, demographics.Age_Group, Dt_Customer, NumWebPurchases,
    AVG(sb.NumWebPurchases) OVER (
        PARTITION BY YEAR(pf.Dt_Customer) 
        ORDER BY pf.Dt_Customer 
        ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
    ) AS AvgWebPurchases5Years
FROM ShoppingBehavior sb
INNER JOIN Customer c ON sb.ID = c.ID
INNER JOIN demographics ON sb.ID = demographics.ID
INNER JOIN purchasefrequency pf ON sb.ID = pf.ID;

# Question 5
-- What is the average number of deals purchased  based on different
-- income segments among customers who responded to promotions?
SELECT Customer.Income,
    AVG(PromotionResponse.NumDealsPurchases) AS AvgDealsPurchased,
    CASE 
        WHEN Customer.Income > 50000 THEN 'High'
        WHEN Customer.Income BETWEEN 30000 AND 50000 THEN 'Medium'
        ELSE 'Low'
    END AS IncomeSegment
FROM Customer
INNER JOIN PromotionResponse ON Customer.ID = PromotionResponse.ID
GROUP BY Income, IncomeSegment;

# Question 6
-- What are the web purchasing behaviors of customers who have registered complaints?
SELECT 
    pr.ID,
    sb.NumWebPurchases,
    c.Complain,
    c.Marital_Status,
    c.Education
FROM 
    PromotionResponse pr
JOIN 
    ShoppingBehavior sb ON pr.ID = sb.ID
JOIN 
    Customer c ON pr.ID = c.ID
WHERE 
    c.Complain = 1;

# Question 7 
-- Who is the customer with the highest total combined purchases across various categories 
-- (web, catalog, store, and web visits), and what are their income and education level?
SELECT c.ID, c.Income, c.Education,
       (sb.NumWebPurchases + sb.NumCatalogPurchases + sb.NumStorePurchases + sb.NumWebVisitsMonth) AS TotalPurchases
FROM Customer c
JOIN ShoppingBehavior sb ON c.ID = sb.ID
WHERE (sb.NumWebPurchases + sb.NumCatalogPurchases + sb.NumStorePurchases + sb.NumWebVisitsMonth) = (
    SELECT MAX(TotalPurchases)
    FROM (
        SELECT (sb.NumWebPurchases + sb.NumCatalogPurchases + sb.NumStorePurchases + sb.NumWebVisitsMonth) AS TotalPurchases
        FROM ShoppingBehavior sb
    ) AS CombinedPurchases
);

# Question 8 
-- What is the total number of deals purchased by each unique customer based on the database? 
-- Is there any pattern worth attention?
SELECT pp.MntWines + pp.MntFruits + pp.MntMeatProducts + pp.MntFishProducts + pp.MntSweetProducts + pp.MntGoldProds AS TotalPurchases,
       pr.Response
FROM ProductPurchases pp
INNER JOIN promotionresponse pr ON pp.ID = pr.ID
HAVING TotalPurchases > 1500 AND RESPONSE = 1;

# Question 9 
-- Among customers who have made total purchases (across various product categories) exceeding 1500, 
-- what are their response statuses to promotions?
SELECT promotionresponse.ID,
    SUM(promotionresponse.NumDealsPurchases) AS TotalDealsPurchased,
    Customer.Marital_Status
FROM promotionresponse 
INNER JOIN Customer ON promotionresponse.ID = Customer.ID
GROUP BY promotionresponse.ID, Customer.Marital_Status;

