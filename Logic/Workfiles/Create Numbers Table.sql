/*It creates a simple Dictionary tables for the words */
DECLARE @End INT = 4;

WITH T1 (number)
AS (
    Select 1 as Number
        union all
	Select Number + 1
	from T1
        where Number < @end
	)
	,T2 (number)
AS (
	SELECT 1
	FROM T1 AS a
	CROSS JOIN T1 AS b
	)
	,T3 (number)
AS (
	SELECT 1
	FROM T2 AS a
	CROSS JOIN T2 AS b
	)
	,T4 (number)
AS (
	SELECT 1
	FROM T3 AS a
	CROSS JOIN T3 AS b
	)
	,Nums (number)
AS (
	SELECT ROW_NUMBER() OVER (
			ORDER BY (
					SELECT NULL
					)
			)
	FROM T4
	)
SELECT TOP 10000 * INTO Numbers
FROM Nums