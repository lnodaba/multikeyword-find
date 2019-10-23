-- =============================================
-- Author:		Lorand Noda
-- Create date: 22 October 2019
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[udf_TextHelper_ExtractNumbers_CTE]
(	
	@Phrase NVARCHAR(MAX)
)
RETURNS TABLE 
AS
RETURN 
(
	WITH CTE  /*It is using a number dictionary for finding the Numbers up to 10K*/
	AS (
		SELECT Number
			,CHARINDEX(CAST(Number AS NVARCHAR),@Phrase) AS CurrentCharIndex
		FROM Numbers 
		WHERE CHARINDEX(CAST(Number AS NVARCHAR),@Phrase) <> 0
	), CTE_Partitioned AS ( /*Clean up overlapping numbers*/
		SELECT * 
			,ROW_NUMBER() OVER (PARTITION BY CurrentCharIndex ORDER BY Number DESC) AS RowNumber
		FROM CTE
	),CTE_CleanedUp AS ( /*Set the last variables for further cleanup see the extra columns*/
	SELECT Number
		,CurrentCharIndex
		,LAG(CurrentCharIndex,1)  OVER ( ORDER BY CurrentCharIndex ) LastCharIndex
		,LAG(Number,1)  OVER ( ORDER BY CurrentCharIndex ) LastNumber
	FROM CTE_Partitioned
	WHERE RowNumber = 1
	),CTE_FilterOutSubNumbers AS ( /*Now Filter out the overlapping numbers*/
		SELECT * 
			,LastCharIndex + LEN(CAST(LastNumber AS nvarchar)) AS PosibleStartPositionShouldBe
		FROM CTE_CleanedUp
		WHERE CurrentCharIndex >= ( /*The possible start position of the current number can be only after the last number*/
			LastCharIndex + LEN(CAST(LastNumber AS nvarchar))
			) OR LastCharIndex IS NULL /*The first number is not having last number*/
	)
	SELECT Number
		,CurrentCharIndex AS Char_Index
	FROM CTE_FilterOutSubNumbers
)
GO
