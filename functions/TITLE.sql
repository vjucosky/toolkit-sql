SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================
-- Authors:     victor.jucosky (2022-07-18)
-- Description: this function returns a titlecased version of
--              the string where words start with an uppercase
--              character and the remaining characters are
--              lowercase, similar to Python's str.title()
--              method.
-- See more:    https://docs.python.org/3/library/stdtypes.html
-- ============================================================

CREATE FUNCTION TITLE (@String AS nvarchar(4000))
RETURNS nvarchar(4000)
AS
BEGIN
    DECLARE @Output AS nvarchar(4000)
    DECLARE @Char AS nchar(1)
    DECLARE @Pattern AS nchar(8) = '[A-Za-z]'
    DECLARE @Index AS smallint = 1
    DECLARE @Length AS smallint = LEN(@String)
    DECLARE @isFirstLetter AS bit = 1

    WHILE @Index <= @Length
    BEGIN
        SET @Char = SUBSTRING(@String, @Index, 1)

        IF @isFirstLetter = 1
        BEGIN
            SET @Output = CONCAT(@Output, UPPER(@Char))
            SET @isFirstLetter = 0
        END
        ELSE
        BEGIN
            SET @Output = CONCAT(@Output, LOWER(@Char))
        END

        IF @Char NOT LIKE @Pattern SET @isFirstLetter = 1

        SET @Index = @Index + 1
    END

    RETURN COALESCE(@Output, @String)
END
GO
