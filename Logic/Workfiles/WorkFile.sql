--SET STATISTICS TIME,IO ON;

DECLARE @String NVARCHAR(MAX) = 'B INCH DMXTER WITH A PLASTC CAP. MARKED 15-4624'', FROM WHICH TX NORTHVEST CORNER Of SAID SECTION 15, WONUMENTED MTH A MBAR. 5/8 INCH DIAMETER';

SELECT *
	,SUBSTRING(@String,StartPosition,LEN(Number)) CheckifCorrect
FROM dbo.udf_TextHelper_ExtractNumberAndPositions(@String);