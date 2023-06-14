SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================
-- Authors:     Roman Pekar (2019-03-30),
--              victor.jucosky (2023-06-07)
-- Description: this function parses a JSON array containing
--              range intervals into a SQL table, useful for
--              JOIN-like operations.
--              Input example: [1,2,[3,5],[7,9]]
-- See more:    https://stackoverflow.com/a/55429404
-- ============================================================

CREATE FUNCTION ID_RANGE_PARSER (@Range AS nvarchar(4000))
RETURNS table
AS
RETURN
    SELECT
        CASE
            WHEN [Type] = 4 THEN JSON_VALUE([Value], '$[0]')
            ELSE [Value]
        END AS StartID,
        CASE
            WHEN [Type] = 4 THEN JSON_VALUE([Value], '$[1]')
            ELSE [Value]
        END AS EndID
    FROM OPENJSON(@Range)
GO
