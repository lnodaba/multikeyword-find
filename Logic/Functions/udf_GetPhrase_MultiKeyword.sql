CREATE FUNCTION [dbo].[udf_GetPhrase_MultiKeyword]
(
	@Paragraph NVARCHAR(MAX),
	@KeyWords NVARCHAR(MAX),
	@MaxWordCountBeetween  INT,
	@MaintainOrder  INT
)
RETURNS @Result TABLE 
(
	FirstPosition INT,
	LastPosition INT,
	Phrase NVARCHAR(MAX),
	WordCount INT,	
	InBetweenKeywordsAreInOrder INT,
	KeyWordCount INT
)
AS
BEGIN

	DECLARE @First NVARCHAR(MAX);
	DECLARE @Last NVARCHAR(MAX);
	DECLARE @KeyWordsTbl TABLE (chunk NVARCHAR(MAX), RowNr int)
	DECLARE @InBeweeen TABLE (chunk NVARCHAR(MAX), RowNr int)
	DECLARE @FirstKeywords TABLE (Word NVARCHAR(MAX), RowNr int)
	DECLARE @SecondKeyWords TABLE (Word NVARCHAR(MAX), RowNr int)

	INSERT INTO @KeyWordsTbl 
	SELECT *
	FROM dbo.SplitString(',', @Keywords);

	---------------------------------------
	-----Validate Number of KeyWords-------
	---------------------------------------

	IF (SELECT COUNT(1) FROM @KeyWordsTbl) < 2
		INSERT INTO @Result(Phrase,WordCount) VALUES('Error.',CAST('You should provide minimum 2 keywors.' AS INT));
	
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
	
	---------------------------------------
	----------Set Up the positions---------
	---------------------------------------
	
	;WITH CTE /* Let's position the keywords */
	AS (	
		SELECT [first].Word AS FirstWord
			,[first].RowNr AS FirstRowNr
			,[second].Word AS SecondWord
			,[second].RowNr AS SecondRowNr
			,x.FirstPosition
			,x.LastPosition
			,x.LenFirst
			,x.LenLast
			,x.n
		FROM @FirstKeywords AS [first]
		CROSS JOIN @SecondKeyWords AS [second]
		CROSS APPLY [dbo].[udf_GetKeywordPositions]([first].Word, [second].Word, @Paragraph) x
		)

		,CTE_Normalized /*Get the Phrase based on the keywords positions*/
	AS (
		SELECT *
			,SUBSTRING(@Paragraph, FirstPosition, LastPosition - FirstPosition + LenLast) AS Phrase
		FROM CTE
		WHERE FirstPosition != 0
			AND LastPosition != 0

		),CTE_InBetweenDecorated /*Get the position of the in-between keywords*/
	AS (
		SELECT * 
		 ,ROW_NUMBER() OVER (PARTITION BY FirstWord,SecondWord,Phrase ORDER BY FirstPosition) AS PhaseNr
		 ,CHARINDEX(chunk, Phrase, 0) AS ChunkIndex
		FROM CTE_Normalized
		CROSS APPLY (
			SELECT COUNT(1) AS WordCount
			FROM dbo.SplitString(' ', REPLACE(Phrase, '.', '. '))
			) AS WordCount
		LEFT JOIN @InBeweeen ON 1 = 1
		WHERE WordCount < @MaxWordCountBeetween
	)
	,CTE_CheckForInBetweenOrder /* Enhance the result with the last position in order to compare them*/
	AS (
	SELECT *
		,LAG(ChunkIndex,1) OVER(PARTITION BY LastPosition,Phrase ORDER BY FirstPosition) AS LastChunkIndex 
	FROM CTE_InBetweenDecorated

	), CTE_DetermineTheOrder  /*Set up the flag to mark if the order is okay or not */
	AS (
	SELECT *
		,IIF(ISNULL(LastChunkIndex,0) <= ChunkIndex,1,0) AS InOrder
	FROM CTE_CheckForInBetweenOrder 
	),  CTE_SetUpVariables AS  /*Set InBetweenKeywordsAreInOrder and KeyWordCount*/
	(
		SELECT FirstPosition
			,LastPosition
			,Phrase
			,WordCount
			,IIF(COUNT(1) = SUM(InOrder), 1 , 0) AS InBetweenKeywordsAreInOrder 
			,SUM(IIF(ChunkIndex > 0,1,0)) AS KeyWordCount 
		FROM CTE_DetermineTheOrder
		GROUP BY FirstWord
			,SecondWord
			,FirstPosition
			,LastPosition
			,Phrase
			,WordCount
	)
	INSERT INTO @Result
	SELECT * FROM CTE_SetUpVariables 
	WHERE KeyWordCount = (SELECT COUNT(1) FROM @InBeweeen) 
		AND (@MaintainOrder = 0 OR InBetweenKeywordsAreInOrder = @MaintainOrder) /*Now you can test the optional parameter*/
	OPTION (MAXRECURSION 1000);
	RETURN
END
