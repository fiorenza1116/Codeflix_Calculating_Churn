-- Calculating Churn Rates:
--	Four months into launching Codeflix, management asks you to look into subscription churn rates. It’s early on in the business and people are excited to know how the company is doing.

--	The marketing department is particularly interested in how the churn compares between two segments of users. 
--	They provide you with a dataset containing subscription data for users who were acquired through two distinct channels.
--	
--	The dataset provided to you contains one SQL table, 'subscriptions'. 
--	Within the table, there are 4 columns:
--	
--				id - the subscription id
--				subscription_start - the start date of the subscription
--				subscription_end - the end date of the subscription
--				segment - this identifies which segment the subscription owner belongs to
--
--	Codeflix requires a minimum subscription length of 31 days, so a user can never start and end their subscription in the same month.



-- Part 1
--	You’ll be calculating the churn rate for both segments (87 and 30) over the first 3 months of 2017 (you can’t calculate it for December, since there are no subscription_end values yet). 
--	To get started, create a temporary table of months.

SELECT '2017-01-01' first_day,
	'2017-01-31' last_day
UNION
SELECT '2017-02-01' first_day,
	'2017-02-28' last_day
UNION
SELECT '2017-03-01' first_day,
	'2017-03-31' last_day;


-- Part 2
--	Create a temporary table, cross_join, from subscriptions and your months. Be sure to SELECT every column.

WITH months AS (
	SELECT '2017-01-01' first_day,
		'2017-01-31' last_day
	UNION
	SELECT '2017-02-01' first_day,
		'2017-02-28' last_day
	UNION
	SELECT '2017-03-01' first_day,
		'2017-03-31' last_day
		),
cross_join AS (
	SELECT *
	FROM subscriptions
	CROSS JOIN months
	)

SELECT * 
FROM cross_join;


-- Part 3
--	Create a temporary table, 'status', from the cross_join table you created. This table should contain:
--		- id selected from cross_join
--		- month as an alias of first_day
--		- is_active_87 created using a CASE WHEN to find any users from segment 87 who existed prior to the beginning of the month. This is 1 if true and 0 otherwise.
--		- is_active_30 created using a CASE WHEN to find any users from segment 30 who existed prior to the beginning of the month. This is 1 if true and 0 otherwise.	


WITH months AS (
	SELECT '2017-01-01' first_day,
		'2017-01-31' last_day
	UNION
	SELECT '2017-02-01' first_day,
		'2017-02-28' last_day
	UNION
	SELECT '2017-03-01' first_day,
		'2017-03-31' last_day
		),
cross_join AS (
	SELECT *
	FROM subscriptions
	CROSS JOIN months
	),
status AS (
	SELECT id,
		first_day month,
		CASE
			WHEN segment = 87
			 AND subscription_start < first_day
			 AND (subscription_end > first_day
			 OR subscription_end IS NULL)
			THEN 1
			ELSE 0
		END is_active_87,
		CASE
			WHEN segment = 30
			 AND subscription_start < first_day
			 AND (subscription_end > first_day
			 OR subscription_end IS NULL)
			THEN 1
			ELSE 0
		END is_active_30
	FROM cross_join
	)
SELECT *
FROM status;




-- Part 4
--	Add an is_canceled_87 and an is_canceled_30 column to the status temporary table. This should be 1 if the subscription is canceled during the month and 0 otherwise.


WITH months AS (
	SELECT '2017-01-01' first_day,
		'2017-01-31' last_day
	UNION
	SELECT '2017-02-01' first_day,
		'2017-02-28' last_day
	UNION
	SELECT '2017-03-01' first_day,
		'2017-03-31' last_day
		),
cross_join AS (
	SELECT *
	FROM subscriptions
	CROSS JOIN months
	),
status AS (
	SELECT id,
		first_day month,
		CASE
			WHEN segment = 87
			 AND subscription_start < first_day
			 AND (subscription_end > first_day
			 OR subscription_end IS NULL)
			THEN 1
			ELSE 0
		END is_active_87,
		CASE
			WHEN segment = 30
			 AND subscription_start < first_day
			 AND (subscription_end > first_day
			 OR subscription_end IS NULL)
			THEN 1
			ELSE 0
		END is_active_30,
		CASE 
			WHEN segment = 87
			 AND subscription_end BETWEEN first_day AND last_day
			THEN 1
			ELSE 0
		END is_canceled_87,
		CASE 
			WHEN segment = 30
			 AND subscription_end BETWEEN first_day AND last_day
			THEN 1
			ELSE 0
		END is_canceled_30
	FROM cross_join
	)
SELECT *
FROM status;



-- Part 5
--	Create a status_aggregate temporary table that is a SUM of the active and canceled subscriptions for each segment, for each month.
--	
--	The resulting columns should be:
--		- sum_active_87
--		- sum_active_30
--		- sum_canceled_87
--		- sum_canceled_30

WITH months AS (
	SELECT '2017-01-01' first_day,
		'2017-01-31' last_day
	UNION
	SELECT '2017-02-01' first_day,
		'2017-02-28' last_day
	UNION
	SELECT '2017-03-01' first_day,
		'2017-03-31' last_day
		),
cross_join AS (
	SELECT *
	FROM subscriptions
	CROSS JOIN months
	),
status AS (
	SELECT id,
		first_day month,
		CASE
			WHEN segment = 87
			 AND subscription_start < first_day
			 AND (subscription_end > first_day
			 OR subscription_end IS NULL)
			THEN 1
			ELSE 0
		END is_active_87,
		CASE
			WHEN segment = 30
			 AND subscription_start < first_day
			 AND (subscription_end > first_day
			 OR subscription_end IS NULL)
			THEN 1
			ELSE 0
		END is_active_30,
		CASE 
			WHEN segment = 87
			 AND subscription_end BETWEEN first_day AND last_day
			THEN 1
			ELSE 0
		END is_canceled_87,
		CASE 
			WHEN segment = 30
			 AND subscription_end BETWEEN first_day AND last_day
			THEN 1
			ELSE 0
		END is_canceled_30
	FROM cross_join
	),
status_aggregate AS (
	SELECT month,
		SUM(is_active_87) sum_active_87,
		SUM(is_active_30) sum_active_30,
		SUM(is_canceled_87) sum_canceled_87,
		SUM(is_canceled_30) sum_canceled_30
	FROM status
	GROUP BY month
	)
SELECT *
FROM status_aggregate;



-- Part 6
--	Calculate the churn rates for the two segments over the three month period. Which segment has a lower churn rate?

WITH months AS (
	SELECT '2017-01-01' first_day,
		'2017-01-31' last_day
	UNION
	SELECT '2017-02-01' first_day,
		'2017-02-28' last_day
	UNION
	SELECT '2017-03-01' first_day,
		'2017-03-31' last_day
		),
cross_join AS (
	SELECT *
	FROM subscriptions
	CROSS JOIN months
	),
status AS (
	SELECT id,
		first_day month,
		CASE
			WHEN segment = 87
			 AND subscription_start < first_day
			 AND (subscription_end > first_day
			 OR subscription_end IS NULL)
			THEN 1
			ELSE 0
		END is_active_87,
		CASE
			WHEN segment = 30
			 AND subscription_start < first_day
			 AND (subscription_end > first_day
			 OR subscription_end IS NULL)
			THEN 1
			ELSE 0
		END is_active_30,
		CASE 
			WHEN segment = 87
			 AND subscription_end BETWEEN first_day AND last_day
			THEN 1
			ELSE 0
		END is_canceled_87,
		CASE 
			WHEN segment = 30
			 AND subscription_end BETWEEN first_day AND last_day
			THEN 1
			ELSE 0
		END is_canceled_30
	FROM cross_join
	),
status_aggregate AS (
	SELECT month,
		SUM(is_active_87) sum_active_87,
		SUM(is_active_30) sum_active_30,
		SUM(is_canceled_87) sum_canceled_87,
		SUM(is_canceled_30) sum_canceled_30
	FROM status
	GROUP BY month
	)
SELECT month,
1.0 * sum_canceled_87 / sum_active_87 churn_rate_87,
1.0 * sum_canceled_30 / sum_active_30 churn_rate_30
FROM status_aggregate;

-- Results are as follows:
-- month	churn_rate_87	churn_rate_30
-- 2017-01-01	0.251798561151	0.075601374570
-- 2017-02-01	0.320346320346	0.073359073359
-- 2017-03-01	0.485875706214	0.117318435754
-- It is clear that the 30 segment has significantly lower churn rates month over month.


--*******************************************************************************
--*******************************************************************************
-- BONUS:
--	How would you modify this code to support a large number of segments?

--**********
--ANSWER:
--The key to solving this bonus question is by replacing any manual inputs for segments. This is easy to do using the GROUP BY function.
--**********
WITH months AS (
	SELECT '2017-01-01' first_day,
		'2017-01-31' last_day
	UNION
	SELECT '2017-02-01' first_day,
		'2017-02-28' last_day
	UNION
	SELECT '2017-03-01' first_day,
		'2017-03-31' last_day
		),
cross_join AS (
	SELECT *
	FROM subscriptions
	CROSS JOIN months
	),
status AS (
	SELECT id,
		first_day month,
		segment,
		CASE
			WHEN subscription_start < first_day
			 AND (subscription_end > first_day
			 OR subscription_end IS NULL)
			THEN 1
			ELSE 0
		END is_active,
		CASE 
			WHEN subscription_end BETWEEN first_day AND last_day
			THEN 1
			ELSE 0
		END is_canceled
	FROM cross_join
	),
status_aggregate AS (
	SELECT month,
		segment,
		SUM(is_active) sum_active,
		SUM(is_canceled) sum_canceled
	FROM status
	GROUP BY month, segment
	)
SELECT month,
	segment,
	1.0 * sum_canceled / sum_active churn_rate
FROM status_aggregate
ORDER BY month, segment;


--*******************************************************************************
--*******************************************************************************
