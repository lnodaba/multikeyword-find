CREATE OR ALTER FUNCTION [dbo].[udf_TextHelper_ExtractNumbers] 
(
    @stringInput VARCHAR(max)
)
RETURNS VARCHAR(max)
AS
BEGIN
    SET @stringInput = REPLACE(@stringInput,',','')
     
    DECLARE @intAlpha INT = PATINDEX('%[^0-9,]%', @stringInput) /*First non number*/
    DECLARE @intNumber INT = PATINDEX('%[0-9,]%', @stringInput) /*First number or comma*/ 
 
    IF @stringInput IS NULL OR @intNumber = 0
        RETURN '';
 
    WHILE @intAlpha > 0  /*There is string (not number) left to cut out*/
    BEGIN
        IF (@intAlpha > @intNumber)
        BEGIN
            SET @intNumber = PATINDEX('%[0-9,]%', SUBSTRING(@stringInput, @intAlpha, LEN(@stringInput)) )
            SELECT @intNumber = CASE WHEN @intNumber = 0 THEN LEN(@stringInput) ELSE @intNumber END
        END
 
        SET @stringInput = STUFF(@stringInput, @intAlpha, @intNumber - 1,',' );
             
        SET @intAlpha = PATINDEX('%[^0-9,]%', @stringInput )
        SET @intNumber = PATINDEX('%[0-9,]%', SUBSTRING(@stringInput, @intAlpha, LEN(@stringInput)) )
        SELECT @intNumber = CASE WHEN @intNumber = 0 THEN LEN(@stringInput) ELSE @intNumber END
    END
     
	/* Clean up the string from the ,commas */
    IF (RIGHT(@stringInput, 1) = ',')
        SET @stringInput = LEFT(@stringInput, LEN(@stringInput) - 1)
 
    IF (LEFT(@stringInput, 1) = ',')
        SET @stringInput = RIGHT(@stringInput, LEN(@stringInput) - 1)
 
    RETURN ISNULL(@stringInput,0)
END
