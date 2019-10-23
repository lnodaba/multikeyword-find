
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lorand Noda
-- Create date: 19 October 2019
-- Description:	Based on the Keywords it will generate the full text search Condition for queries
-- =============================================
CREATE OR ALTER FUNCTION dbo.udf_FullTextSearchHelper_KeywordsToCondition
(
	@Keywords NVARCHAR(MAX)
	,@WordCount INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @First NVARCHAR(MAX);
	DECLARE @Last NVARCHAR(MAX);
	DECLARE @KeyWordsTbl TABLE (chunk NVARCHAR(MAX), RowNr int)
	DECLARE @InBeweeen TABLE (chunk NVARCHAR(MAX), RowNr int)
	DECLARE @FirstKeywords TABLE (Word NVARCHAR(MAX), RowNr int)
	DECLARE @SecondKeyWords TABLE (Word NVARCHAR(MAX), RowNr int)
	DECLARE @InBetweenStr VARCHAR(MAX) = '';

	INSERT INTO @KeyWordsTbl 
	SELECT *
	FROM dbo.SplitString(',', @Keywords);

	
	---------------------------------------
	----------Set Up Variables-------------
	---------------------------------------

	SELECT TOP 1 @First = chunk
	FROM @KeyWordsTbl

	SELECT TOP 1 @Last = chunk
	FROM @KeyWordsTbl
	ORDER BY RowNr DESC;

	------------------------------------------------------------------------------------------
	--- CREATE ENCHANCED KEYWORDS table "|" separator means some of them should appear -------
	------------------------------------------------------------------------------------------
	INSERT INTO @FirstKeywords  
	SELECT * 
	FROM dbo.SplitString('|', @First);

	INSERT INTO @SecondKeyWords  
	SELECT * 
	FROM dbo.SplitString('|', @Last);

	INSERT INTO @InBeweeen
	SELECT *
	FROM @KeyWordsTbl
	WHERE chunk NOT IN (
			@First
			,@Last
			);

	SET  @InBetweenStr = SUBSTRING(@Keywords,LEN(@First) + 2,LEN(@Keywords) - 2 - LEN(@First) - LEN(@Last))

	DECLARE @Condition NVARCHAR(MAX) = '';
	SELECT @Condition =@Condition + 
		CONCAT('NEAR((',T1.Word,',',@InBetweenStr,',',T2.Word,'),',CAST(@WordCount AS NVARCHAR),')',' OR ')
	FROM @FirstKeywords as T1
	CROSS JOIN @SecondKeyWords as T2;
	
	RETURN LEFT(@Condition,LEN(@Condition) - 3);
END
GO 

SELECT dbo.udf_FullTextSearchHelper_KeywordsToCondition('assign|temporary,rights,whole',14);
