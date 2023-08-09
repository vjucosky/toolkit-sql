DECLARE @RoundIncrement AS int = 500

SELECT
    AmountToRound,
    @RoundIncrement AS RoundIncrement,
    CEILING(AmountToRound / @RoundIncrement) * @RoundIncrement AS RoundedAmount
FROM (VALUES
    (0.00),
    (0.01),
    (499.99),
    (500.00),
    (500.01),
    (1499.99),
    (1500.00),
    (1500.01)
) AS T(AmountToRound)
