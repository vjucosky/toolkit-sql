DECLARE @SearchTerm AS nvarchar(4000) = '...'
DECLARE @ProcedureName AS varchar(128) = '...'

SELECT
    P.[object_id],
    P.[name],
    P.[type_desc] AS [description],
    S.[name] AS [schema],
    OBJECT_DEFINITION([object_id]) AS content,
    P.create_date,
    P.modify_date
FROM sys.procedures AS P WITH (NOLOCK)
INNER JOIN sys.schemas AS S WITH (NOLOCK)
    ON P.[schema_id] = S.[schema_id]
WHERE OBJECT_DEFINITION([object_id]) LIKE CONCAT('%', @SearchTerm, '%')

EXECUTE sp_helptext @ProcedureName
