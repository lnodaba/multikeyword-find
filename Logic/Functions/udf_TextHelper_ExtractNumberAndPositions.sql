-- =============================================
-- Author:		Lorand Noda
-- Create date: 22 October 2019
-- Description:	It finds all the numbers in a phrase and send the posiitons back
-- =============================================
CREATE FUNCTION dbo.udf_TextHelper_ExtractNumberAndPositions 
(
	@stringInput VARCHAR(max)
)
RETURNS @NumberAndPositions TABLE 
(
	Number NVARCHAR(MAX),
	StartPosition INT
)
AS
BEGIN
	DECLARE @Number NVARCHAR(MAX);	

	DECLARE db_cursor CURSOR FOR 
	SELECT chunk as Number
	FROM dbo.SplitString(',',dbo.udf_TextHelper_ExtractNumbers(@stringInput))

	OPEN db_cursor  
	FETCH NEXT FROM db_cursor INTO @Number

	DECLARE @StartPosition INT = 0;
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		  INSERT INTO @NumberAndPositions  VALUES(@Number,CHARINDEX(@Number,@stringInput,@StartPosition))

		  SET @StartPosition = CHARINDEX(@Number,@stringInput,@StartPosition) + LEN(@Number);
		  FETCH NEXT FROM db_cursor INTO @Number 
	END 
	CLOSE db_cursor  
	DEALLOCATE db_cursor 

	RETURN 
END
GO