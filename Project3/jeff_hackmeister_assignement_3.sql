USE housing;

WITH ordered_inspections AS (
    SELECT
        PUBLIC_HOUSING_AGENCY_NAME AS pha_name,

        STR_TO_DATE(INSPECTION_DATE, '%m/%d/%Y') AS inspection_date,
        COST_OF_INSPECTION_IN_DOLLARS AS inspection_cost,

        LAG(STR_TO_DATE(INSPECTION_DATE, '%m/%d/%Y'))
            OVER (PARTITION BY PUBLIC_HOUSING_AGENCY_NAME
                  ORDER BY STR_TO_DATE(INSPECTION_DATE, '%m/%d/%Y')) AS prev_inspection_date,

        LAG(COST_OF_INSPECTION_IN_DOLLARS)
            OVER (PARTITION BY PUBLIC_HOUSING_AGENCY_NAME
                  ORDER BY STR_TO_DATE(INSPECTION_DATE, '%m/%d/%Y')) AS prev_inspection_cost,

        ROW_NUMBER()
            OVER (PARTITION BY PUBLIC_HOUSING_AGENCY_NAME
                  ORDER BY STR_TO_DATE(INSPECTION_DATE, '%m/%d/%Y') DESC) AS rn
    FROM public_housing_inspection_data
)

SELECT
    pha_name AS PHA_NAME,

    inspection_date AS MR_INSPECTION_DATE,
    inspection_cost AS MR_INSPECTION_COST,

    prev_inspection_date AS SECOND_MR_INSPECTION_DATE,
    prev_inspection_cost AS SECOND_MR_INSPECTION_COST,

    (inspection_cost - prev_inspection_cost) AS CHANGE_IN_COST,

    ROUND(
        ((inspection_cost - prev_inspection_cost) / prev_inspection_cost) * 100,
        2
    ) AS PERCENT_CHANGE_IN_COST

FROM ordered_inspections
WHERE
    rn = 1                              -- only most recent per PHA
    AND prev_inspection_cost IS NOT NULL   -- removes PHAs with only one inspection
    AND inspection_cost > prev_inspection_cost  -- only increases

ORDER BY PERCENT_CHANGE_IN_COST DESC;
