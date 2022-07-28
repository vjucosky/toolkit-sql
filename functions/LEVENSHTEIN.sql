SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================
-- Authors:     Sten Hjelmqvist (2012-03-26),
--              hatchet - done with SOverflow (2014-01-20),
--              victor.jucosky (2022-05-16)
-- Description: this function computes and returns the
--              Levenshtein edit distance between two strings,
--              i.e. the number of insertion, deletion, and
--              sustitution edits required to transform one
--              string to the other, or NULL if @Limit is
--              exceeded. Comparisons use the case-sensitivity
--              configured in SQL Server (case-insensitive by
--              default).
-- See more:    https://stackoverflow.com/a/27734606
-- ============================================================

CREATE FUNCTION LEVENSHTEIN (@Source AS nvarchar(4000), @Target AS nvarchar(4000), @Limit AS int)
RETURNS int
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @Distance AS int = 0           -- Return variable
    DECLARE @Scratchpad AS nvarchar(4000)  -- Running scratchpad for storing computed distances
    DECLARE @StartIndex AS int = 1         -- Index (1 based) of first non-matching character between the two strings
    DECLARE @SourceCounter AS int          -- Loop counter for @Source string
    DECLARE @TargetCounter AS int          -- Loop counter for @Target string
    DECLARE @DiagonalDistance AS int       -- Distance in cell diagonally above and left if we were using an M by N matrix
    DECLARE @LeftDistance AS int           -- Distance in cell to the left if we were using an M by N matrix
    DECLARE @SourceChar AS nchar(1)        -- Character at index i from @Source string
    DECLARE @TemporaryTargetCounter AS int -- Temporary storage of @TargetCounter to allow combining
    DECLARE @TargetOffset AS int           -- Offset used to calculate starting value for @Target loop
    DECLARE @TargetEnd AS int              -- Ending value for @Target loop (stopping point for processing a column)

    -- Get input string lengths including any trailing spaces (which SQL Server would otherwise ignore).
    DECLARE @SourceLength AS int = DATALENGTH(@Source) / DATALENGTH(LEFT(LEFT(@Source, 1) + '.', 1)) -- Length of @Source string
    DECLARE @TargetLength AS int = DATALENGTH(@Target) / DATALENGTH(LEFT(LEFT(@Target, 1) + '.', 1)) -- Length of @Target string
    DECLARE @LengthDifference AS int                                                                 -- Difference in length between the two strings

    -- If strings of different lengths, ensure shorter string is in @Source, temporarily using @Scratchpad for swap.
    -- This can result in a little faster speed by spending more time spinning just the inner loop during the main processing.
    IF @SourceLength > @TargetLength
    BEGIN
        SET @Scratchpad = @Source
        SET @SourceCounter = @SourceLength
        SET @Source = @Target
        SET @SourceLength = @TargetLength
        SET @Target = @Scratchpad
        SET @TargetLength = @SourceCounter
    END

    SET @Limit = ISNULL(@Limit, @TargetLength)
    SET @LengthDifference = @TargetLength - @SourceLength

    IF @LengthDifference > @Limit RETURN NULL

    -- Suffixes common to both strings can be ignored.
    WHILE @SourceLength > 0 AND SUBSTRING(@Source, @SourceLength, 1) = SUBSTRING(@Target, @TargetLength, 1)
    BEGIN
        SET @SourceLength = @SourceLength - 1
        SET @TargetLength = @TargetLength - 1
    END

    IF @SourceLength = 0 RETURN @TargetLength

    -- Prefixes common to both strings can be ignored.
    WHILE @StartIndex < @SourceLength AND SUBSTRING(@Source, @StartIndex, 1) = SUBSTRING(@Target, @StartIndex, 1)
    BEGIN
        SET @StartIndex = @StartIndex + 1
    END

    IF @StartIndex > 1
    BEGIN
        SET @SourceLength = @SourceLength - (@StartIndex - 1)
        SET @TargetLength = @TargetLength - (@StartIndex - 1)

        -- If all of shorter string matches prefix and/or suffix of longer string, then edit distance is just the delete of additional characters present in longer string.
        IF @SourceLength <= 0 RETURN @TargetLength

        SET @Source = SUBSTRING(@Source, @StartIndex, @SourceLength)
        SET @Target = SUBSTRING(@Target, @StartIndex, @TargetLength)
    END

    -- Initialize @Scratchpad array of distances.
    SET @Scratchpad = ''
    SET @TargetCounter = 1

    WHILE @TargetCounter <= @TargetLength
    BEGIN
        SET @Scratchpad = @Scratchpad + CASE
            WHEN @TargetCounter > @Limit THEN nchar(@Limit)
            ELSE nchar(@TargetCounter)
        END

        SET @TargetCounter = @TargetCounter + 1
    END

    SET @TargetOffset = @Limit - @LengthDifference
    SET @SourceCounter = 1

    WHILE @SourceCounter <= @SourceLength
    BEGIN
        SET @Distance = @SourceCounter
        SET @DiagonalDistance = @SourceCounter - 1
        SET @SourceChar = SUBSTRING(@Source, @SourceCounter, 1)

        -- No need to look beyond window of upper left diagonal @SourceCounter + @Limit cells and the lower right diagonal (@SourceCounter - @LengthDifference) - @Limit cells.
        SET @TargetCounter = CASE
            WHEN @SourceCounter <= @TargetOffset THEN 1
            ELSE @SourceCounter - @TargetOffset
        END

        SET @TargetEnd = CASE
            WHEN @SourceCounter + @Limit >= @TargetLength THEN @TargetLength
            ELSE @SourceCounter + @Limit
        END

        WHILE @TargetCounter <= @TargetEnd
        BEGIN
            -- At this point, @Distance holds the previous value (the cell above if we were using an M by N matrix).
            SET @LeftDistance = UNICODE(SUBSTRING(@Scratchpad, @TargetCounter, 1))
            SET @TemporaryTargetCounter = @TargetCounter

            SET @Distance = CASE
                WHEN @SourceChar = SUBSTRING(@Target, @TargetCounter, 1) THEN @DiagonalDistance                     -- Match, no change
                ELSE 1 + CASE
                    WHEN @DiagonalDistance < @LeftDistance AND @DiagonalDistance < @Distance THEN @DiagonalDistance -- Substitution
                    WHEN @LeftDistance < @Distance THEN @LeftDistance                                               -- Insertion
                    ELSE @Distance                                                                                  -- Deletion
                END
            END

            SET @Scratchpad = STUFF(@Scratchpad, @TemporaryTargetCounter, 1, nchar(@Distance))
            SET @DiagonalDistance = @LeftDistance

            SET @TargetCounter = CASE
                WHEN @Distance > @Limit AND @TemporaryTargetCounter = @SourceCounter + @LengthDifference THEN @TargetEnd + 2
                ELSE @TemporaryTargetCounter + 1
            END
        END

        SET @SourceCounter = CASE
            WHEN @TargetCounter > @TargetEnd + 1 THEN @SourceLength + 1
            ELSE @SourceCounter + 1
        END
    END

    RETURN CASE
        WHEN @Distance <= @Limit THEN @Distance
        ELSE NULL
    END
END
GO
