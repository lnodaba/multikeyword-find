CREATE FUNCTION [dbo].[udf_GetKeywordPositions]
(
	@First NVARCHAR(MAX)
	,@Last NVARCHAR(MAX)
	,@Paragraph NVARCHAR(MAX)
)
RETURNS @returntable TABLE
(
	FirstPosition int,
	LastPosition int,
	n int,
	LenFirst int,
	LenLast int
)
AS
BEGIN
	;WITH CTE /* Let's position the keywords */
	AS (
		SELECT CHARINDEX(@First, @Paragraph, 0) AS FirstPosition
			,CHARINDEX(@Last, @Paragraph, CHARINDEX(@First, @Paragraph, 0)) AS LastPosition
			,1 as n
		UNION ALL
	
		SELECT CHARINDEX(@First, @Paragraph, FirstPosition + LEN(@First)) AS FirstPosition
			,CHARINDEX(@Last, @Paragraph, CHARINDEX(@First, @Paragraph, FirstPosition + LEN(@First))) AS LastPosition
			,n + 1 AS n
		FROM CTE
		WHERE FirstPosition <> 0 AND LastPosition <> 0
		)
	INSERT @returntable
	SELECT FirstPosition
		,LastPosition
		,n
		,LEN(@First) AS LenFirst
		,LEN(@Last) AS LenLast
	FROM CTE
	WHERE FirstPosition <> 0
		AND LastPosition <> 0;
	RETURN;
END
