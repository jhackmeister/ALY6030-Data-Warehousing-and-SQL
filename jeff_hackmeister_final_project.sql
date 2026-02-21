CREATE DATABASE IF NOT EXISTS aly6030_final;
USE aly6030_final;

DROP TABLE IF EXISTS fact_prescription;
DROP TABLE IF EXISTS dim_member;
DROP TABLE IF EXISTS dim_drug;

# Create tables
CREATE TABLE dim_member (
    member_id         INT          NOT NULL,
    member_first_name VARCHAR(100) NOT NULL,
    member_last_name  VARCHAR(100) NOT NULL,
    member_birth_date DATE         NOT NULL,
    member_age        INT          NOT NULL,
    member_gender     CHAR(1)      NOT NULL,
    PRIMARY KEY (member_id)
);

CREATE TABLE dim_drug (
    drug_ndc                INT          NOT NULL,
    drug_name               VARCHAR(100) NOT NULL,
    drug_form_code          CHAR(2)      NOT NULL,
    drug_form_desc          VARCHAR(100) NOT NULL,
    drug_brand_generic_code INT          NOT NULL,
    drug_brand_generic_desc VARCHAR(10)  NOT NULL,
    PRIMARY KEY (drug_ndc)
);

CREATE TABLE fact_prescription (
    fill_id        INT           NOT NULL AUTO_INCREMENT,
    member_id      INT           NOT NULL,
    drug_ndc       INT           NOT NULL,
    fill_date      DATE          NOT NULL,
    copay          DECIMAL(10,2),
    insurance_paid DECIMAL(10,2),
    PRIMARY KEY (fill_id),
    FOREIGN KEY (member_id) REFERENCES dim_member(member_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (drug_ndc) REFERENCES dim_drug(drug_ndc)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

# Load data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_member.csv'
INTO TABLE dim_member
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(member_id, member_first_name, member_last_name, member_birth_date, member_age, member_gender);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_drug.csv'
INTO TABLE dim_drug
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(drug_ndc, drug_name, drug_form_code, drug_form_desc, drug_brand_generic_code, drug_brand_generic_desc);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_prescription.csv'
INTO TABLE fact_prescription
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(member_id, drug_ndc, fill_date, copay, insurance_paid);

# Verify data 
SELECT 'dim_member' AS table_name, COUNT(*) AS row_count FROM dim_member
UNION ALL
SELECT 'dim_drug', COUNT(*) FROM dim_drug
UNION ALL
SELECT 'fact_prescription', COUNT(*) FROM fact_prescription;

SELECT * FROM dim_member;
SELECT * FROM dim_drug;
SELECT * FROM fact_prescription;

# Analysis
SELECT d.drug_name, count(*) AS prescription_count
FROM fact_prescription f
JOIN dim_drug d on f.drug_ndc = d.drug_ndc
GROUP BY d.drug_name
ORDER BY prescription_count DESC;

SELECT 
    CASE 
        WHEN m.member_age >= 65 THEN 'age 65+'
        ELSE '< 65'
    END AS age_group,
    COUNT(*)                    AS total_prescriptions,
    COUNT(DISTINCT f.member_id) AS unique_members,
    SUM(f.copay)               AS total_copay,
    SUM(f.insurance_paid)      AS total_insurance_paid
FROM fact_prescription f
JOIN dim_member m ON f.member_id = m.member_id
GROUP BY 
    CASE 
        WHEN m.member_age >= 65 THEN 'age 65+'
        ELSE '< 65'
    END;
    
SELECT 
    member_id,
    member_first_name,
    member_last_name,
    drug_name,
    fill_date,
    most_recent_insurance_paid
FROM (
    SELECT 
        m.member_id,
        m.member_first_name,
        m.member_last_name,
        d.drug_name,
        f.fill_date,
        f.insurance_paid AS most_recent_insurance_paid,
        ROW_NUMBER() OVER (
            PARTITION BY f.member_id, f.drug_ndc 
            ORDER BY f.fill_date DESC
        ) AS rn
    FROM fact_prescription f
    JOIN dim_member m ON f.member_id = m.member_id
    JOIN dim_drug d ON f.drug_ndc = d.drug_ndc
) ranked
WHERE rn = 1
ORDER BY member_id, drug_name;