SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================
-- Authors:     victor.jucosky (2022-07-27)
-- Description: this function returns a string with its first
--              character capitalized and the rest lowercased,
--              similar to Python's str.capitalize() method.
-- See more:    https://docs.python.org/3/library/stdtypes.html
-- ============================================================

CREATE FUNCTION CAPITALIZE (@String AS nvarchar(4000))
RETURNS nvarchar(4000)
AS
BEGIN
    RETURN UPPER(LEFT(@String, 1)) + LOWER(SUBSTRING(@String, 2, 3999))
END
GO
