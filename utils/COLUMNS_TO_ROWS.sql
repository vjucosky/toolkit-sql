SELECT
    T.ID,
    N.C.value('local-name(.)', 'nvarchar(128)') AS [Column],
    N.C.value('.', 'nvarchar(max)') AS [Value]
FROM (
    SELECT
        ID,
        (
            SELECT S.*
            FOR XML RAW('row'), TYPE
        ) AS Content
    FROM dbo.HugeTable AS S
    WHERE ID = 1
) AS T
OUTER APPLY T.data.nodes('row/@*') AS N(C)
ORDER BY T.ID
