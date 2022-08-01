SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================
-- Authors:     victor.jucosky (2022-08-01)
-- Description: this function returns the number of occurrences
--              of @Pattern in @String, similar to Python's
--              str.count() method.
-- See more:    https://docs.python.org/3/library/stdtypes.html
-- ============================================================

CREATE FUNCTION STRING_COUNT (@String AS nvarchar(4000), @Pattern AS nvarchar(4000))
RETURNS smallint
AS
BEGIN
    RETURN (LEN(@String) - LEN(REPLACE(@String, @Pattern, ''))) / LEN(@Pattern)
END
GO
