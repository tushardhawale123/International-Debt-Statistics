/*
International Debt Statistics - Data Extraction Queries
Author: tushardhawale123
Created: 2025-04-20
*/

USE [InternationalDebtStatistics]
GO

-- Get region list for dashboard filters
SELECT DISTINCT Region
FROM Countries
WHERE Region IS NOT NULL
ORDER BY Region;

-- Get latest available data year
SELECT MAX(Year) AS LatestYear
FROM DebtData
WHERE SeriesCode = 'DT.DOD.DECT.CD';

-- Get regional debt snapshot for most recent year
DECLARE @LatestYear INT = (SELECT MAX(Year) FROM DebtData WHERE SeriesCode = 'DT.DOD.DECT.CD');

SELECT
    c.Region,
    COUNT(DISTINCT c.CountryCode) AS CountryCount,
    SUM(CASE WHEN d.SeriesCode = 'DT.DOD.DECT.CD' THEN d.Value ELSE 0 END) AS TotalExternalDebt,
    AVG(CASE WHEN d.SeriesCode = 'DT.DOD.DECT.GN.ZS' THEN d.Value END) AS AvgDebtToGNIRatio,
    AVG(CASE WHEN d.SeriesCode = 'DT.TDS.DECT.EX.ZS' THEN d.Value END) AS AvgDebtServiceRatio
FROM
    DebtData d
JOIN
    Countries c ON d.CountryCode = c.CountryCode
WHERE
    d.Year = @LatestYear
    AND c.Region IS NOT NULL
    AND d.SeriesCode IN ('DT.DOD.DECT.CD', 'DT.DOD.DECT.GN.ZS', 'DT.TDS.DECT.EX.ZS')
GROUP BY
    c.Region
ORDER BY
    TotalExternalDebt DESC;

-- Get 10-year regional debt trend (2013-2022)
SELECT
    c.Region,
    d.Year,
    SUM(CASE WHEN d.SeriesCode = 'DT.DOD.DECT.CD' THEN d.Value ELSE 0 END) AS TotalExternalDebt,
    AVG(CASE WHEN d.SeriesCode = 'DT.DOD.DECT.GN.ZS' THEN d.Value END) AS AvgDebtToGNIRatio,
    AVG(CASE WHEN d.SeriesCode = 'DT.TDS.DECT.EX.ZS' THEN d.Value END) AS AvgDebtServiceRatio
FROM
    DebtData d
JOIN
    Countries c ON d.CountryCode = c.CountryCode
WHERE
    d.Year BETWEEN 2013 AND 2022
    AND c.Region IS NOT NULL
    AND d.SeriesCode IN ('DT.DOD.DECT.CD', 'DT.DOD.DECT.GN.ZS', 'DT.TDS.DECT.EX.ZS')
GROUP BY
    c.Region, d.Year
ORDER BY
    c.Region, d.Year;

-- Get top 3 most indebted countries in each region
WITH RankedCountries AS (
    SELECT
        c.Region,
        c.ShortName AS CountryName,
        d.Value AS ExternalDebt,
        ROW_NUMBER() OVER (PARTITION BY c.Region ORDER BY d.Value DESC) AS RankInRegion
    FROM
        DebtData d
    JOIN
        Countries c ON d.CountryCode = c.CountryCode
    WHERE
        d.Year = (SELECT MAX(Year) FROM DebtData WHERE SeriesCode = 'DT.DOD.DECT.CD')
        AND d.SeriesCode = 'DT.DOD.DECT.CD'
        AND c.Region IS NOT NULL
)
SELECT
    Region,
    CountryName,
    ExternalDebt,
    RankInRegion
FROM
    RankedCountries
WHERE
    RankInRegion <= 3
ORDER BY
    Region, RankInRegion;

-- Get income group comparison - average debt metrics by income group
SELECT
    c.IncomeGroup,
    COUNT(DISTINCT c.CountryCode) AS CountryCount,
    SUM(CASE WHEN d.SeriesCode = 'DT.DOD.DECT.CD' THEN d.Value ELSE 0 END) AS TotalExternalDebt,
    AVG(CASE WHEN d.SeriesCode = 'DT.DOD.DECT.GN.ZS' THEN d.Value END) AS AvgDebtToGNIRatio,
    AVG(CASE WHEN d.SeriesCode = 'DT.TDS.DECT.EX.ZS' THEN d.Value END) AS AvgDebtServiceRatio
FROM
    DebtData d
JOIN
    Countries c ON d.CountryCode = c.CountryCode
WHERE
    d.Year = (SELECT MAX(Year) FROM DebtData WHERE SeriesCode = 'DT.DOD.DECT.CD')
    AND c.IncomeGroup IS NOT NULL
    AND d.SeriesCode IN ('DT.DOD.DECT.CD', 'DT.DOD.DECT.GN.ZS', 'DT.TDS.DECT.EX.ZS')
GROUP BY
    c.IncomeGroup
ORDER BY
    TotalExternalDebt DESC;
GO