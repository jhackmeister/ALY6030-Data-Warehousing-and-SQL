USE project2;

#4a: Analysis for Leadership
#Query 1: Top 10 Hospitals by Total ICU or SICU License Beds
SELECT 
    b.business_name AS hospital_name,
    SUM(f.license_beds) AS total_license_beds
FROM 
    bed_fact f
JOIN 
    bed_type t ON f.bed_id = t.bed_id
JOIN 
    business b ON f.ims_org_id = b.ims_org_id
WHERE 
    t.bed_id IN (4, 15) #ICU or SICU beds
GROUP BY 
    b.business_name
ORDER BY 
    total_license_beds DESC
LIMIT 10;

#Query 2: Top 10 Hospitals by Total ICU or SICU Census Beds
SELECT 
    b.business_name AS hospital_name,
    SUM(f.census_beds) AS total_census_beds
FROM 
    bed_fact f
JOIN 
    bed_type t ON f.bed_id = t.bed_id
JOIN 
    business b ON f.ims_org_id = b.ims_org_id
WHERE 
    t.bed_id IN (4, 15) #ICU or SICU beds
GROUP BY 
    b.business_name
ORDER BY 
    total_census_beds DESC
LIMIT 10;

#Query 3: Top 10 Hospitals by Total ICU or SICU Staffed Beds
SELECT 
    b.business_name AS hospital_name,
    SUM(f.staffed_beds) AS total_staffed_beds
FROM 
    bed_fact f
JOIN 
    bed_type t ON f.bed_id = t.bed_id
JOIN 
    business b ON f.ims_org_id = b.ims_org_id
WHERE 
    t.bed_id IN (4, 15) #ICU or SICU beds
GROUP BY 
    b.business_name
ORDER BY 
    total_staffed_beds DESC
LIMIT 10;

#Query 4: 
SELECT 
    b.business_name AS hospital_name,
    SUM(f.license_beds) AS total_license_beds,
    SUM(f.census_beds) AS total_census_beds,
    SUM(f.staffed_beds) AS total_staffed_beds,    
	ROUND(
        (SUM(f.staffed_beds) / NULLIF(SUM(f.census_beds), 0)) * 100,
        2
    ) AS pct_staffed_of_census,
	ROUND(
        (SUM(f.staffed_beds) / NULLIF(SUM(f.license_beds), 0)) * 100,
        2
    ) AS pct_staffed_of_license
FROM 
    bed_fact f
JOIN 
    bed_type t ON f.bed_id = t.bed_id
JOIN 
    business b ON f.ims_org_id = b.ims_org_id
WHERE 
    t.bed_id IN (4, 15) #ICU or SICU beds
GROUP BY 
    b.business_name
ORDER BY 
    total_license_beds DESC
LIMIT 15; # expanded range


#5a: Drill Down Investigation
#Query 1: Top 10 Hospitals by Total ICU and SICU License Beds
SELECT
    b.business_name AS hospital_name,
    SUM(f.license_beds) AS total_license_beds
FROM bed_fact f
JOIN business b 
    ON f.ims_org_id = b.ims_org_id
WHERE f.bed_id IN (4, 15)   -- ICU OR SICU contribute to volume
AND EXISTS (
    SELECT 1
    FROM bed_fact f2
    WHERE f2.ims_org_id = f.ims_org_id
      AND f2.bed_id = 4    -- must have ICU
)
AND EXISTS (
    SELECT 1
    FROM bed_fact f3
    WHERE f3.ims_org_id = f.ims_org_id
      AND f3.bed_id = 15   -- must have SICU
)
GROUP BY b.business_name
ORDER BY total_license_beds DESC
LIMIT 10;

#Query 2: Top 10 Hospitals by Total ICU and SICU Census Beds
SELECT
    b.business_name AS hospital_name,
    SUM(f.census_beds) AS total_census_beds
FROM bed_fact f
JOIN business b 
    ON f.ims_org_id = b.ims_org_id
WHERE f.bed_id IN (4, 15)   -- ICU OR SICU contribute to volume
AND EXISTS (
    SELECT 1
    FROM bed_fact f2
    WHERE f2.ims_org_id = f.ims_org_id
      AND f2.bed_id = 4    -- must have ICU
)
AND EXISTS (
    SELECT 1
    FROM bed_fact f3
    WHERE f3.ims_org_id = f.ims_org_id
      AND f3.bed_id = 15   -- must have SICU
)
GROUP BY b.business_name
ORDER BY total_census_beds DESC
LIMIT 10;

#Query 3: Top 10 Hospitals by Total ICU and SICU Staffed Beds
SELECT
    b.business_name AS hospital_name,
    SUM(f.staffed_beds) AS total_staffed_beds
FROM bed_fact f
JOIN business b 
    ON f.ims_org_id = b.ims_org_id
WHERE f.bed_id IN (4, 15)   -- ICU OR SICU contribute to volume
AND EXISTS (
    SELECT 1
    FROM bed_fact f2
    WHERE f2.ims_org_id = f.ims_org_id
      AND f2.bed_id = 4    -- must have ICU
)
AND EXISTS (
    SELECT 1
    FROM bed_fact f3
    WHERE f3.ims_org_id = f.ims_org_id
      AND f3.bed_id = 15   -- must have SICU
)
GROUP BY b.business_name
ORDER BY total_staffed_beds DESC
LIMIT 10;

# Query 4: 
SELECT
    b.business_name AS hospital_name,
    SUM(f.license_beds) AS total_license_beds,
    SUM(f.census_beds) AS total_census_beds,
    SUM(f.staffed_beds) AS total_staffed_beds,
    ROUND(
        (SUM(f.staffed_beds) / NULLIF(SUM(f.license_beds), 0)) * 100,
        2
    ) AS pct_staffed_of_license,
	ROUND(
        (SUM(f.staffed_beds) / NULLIF(SUM(f.census_beds), 0)) * 100,
        2
    ) AS pct_staffed_of_census
FROM bed_fact f
JOIN business b 
    ON f.ims_org_id = b.ims_org_id
WHERE f.bed_id IN (4, 15)
AND EXISTS (
    SELECT 1
    FROM bed_fact f2
    WHERE f2.ims_org_id = f.ims_org_id
      AND f2.bed_id = 4
)
AND EXISTS (
    SELECT 1
    FROM bed_fact f3
    WHERE f3.ims_org_id = f.ims_org_id
      AND f3.bed_id = 15
)
GROUP BY b.business_name
ORDER BY
    total_license_beds DESC
LIMIT 15; # expanded range
