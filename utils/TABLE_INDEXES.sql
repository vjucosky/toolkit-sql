DECLARE @Table AS varchar(128) = '...'

SELECT
    I.[object_id],
    I.[name],
    I.[type_desc] AS [description],
    C.[name] AS [column],
    T.[name] AS [type],
    C.max_length,
    I.fill_factor,
    I.is_disabled,
    I.is_hypothetical,
    I.is_ignored_in_optimization,
    I.is_padded,
    I.is_primary_key,
    I.is_unique,
    I.is_unique_constraint,
    I.has_filter,
    IC.is_descending_key,
    IC.is_included_column
FROM sys.indexes AS I WITH (NOLOCK)
INNER JOIN sys.index_columns AS IC WITH (NOLOCK)
    ON
        I.[object_id] = IC.[object_id]
        AND I.index_id = IC.index_id
INNER JOIN sys.columns AS C WITH (NOLOCK)
    ON
        IC.[object_id] = C.[object_id]
        AND IC.column_id = C.column_id
INNER JOIN sys.types AS T WITH (NOLOCK)
    ON C.system_type_id = T.system_type_id
WHERE
    IC.[object_id] = (
        SELECT [object_id]
        FROM sys.objects WITH (NOLOCK)
        WHERE [name] = @Table
    )
