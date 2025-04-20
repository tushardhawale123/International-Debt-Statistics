/*
International Debt Statistics - Regional Analysis Script
Author: tushardhawale123
Created: 2025-04-20
*/

USE [InternationalDebtStatistics]
GO

-- Create view for regional comparison if it doesn't exist
IF OBJECT_ID('dbo.vw_RegionalDebtComparison', 'V') IS NULL
EXEC('
CREATE VIEW [dbo].[vw_RegionalDebtComparison] AS
WITH LatestYear AS (
    SELECT MAX(Year) AS Year
    FROM DebtData
    WHERE SeriesCode = ''DT.DOD.DECT.CD'' AND Value IS NOT NULL
),
RegionalData AS (
    SELECT
        c.Region,
        d.Year,
        d.SeriesCode,
        COUNT(DISTINCT c.CountryCode) AS CountryCount,
        SUM(d.Value) AS TotalValue,
        AVG(d.Value) AS AvgValue
    FROM
        DebtData d
    JOIN
        Countries c ON d.CountryCode = c.CountryCode
    WHERE
        c.Region IS NOT NULL
    GROUP BY
        c.Region, d.Year, d.SeriesCode
)
SELECT
    r.Region,
    ly.Year AS DataYear,
    COUNT(DISTINCT c.CountryCode) AS CountryCount,
    
    -- Total External Debt
    SUM(CASE WHEN d.SeriesCode = ''DT.DOD.DECT.CD'' THEN d.Value ELSE 0 END) AS TotalExternalDebt,
    
    -- Total GDP (GNI can be used as proxy if needed)
    SUM(CASE WHEN d.SeriesCode = ''NY.GDP.MKTP.CD'' THEN d.Value ELSE 0 END) AS TotalGDP,
    
    -- Calculate Debt to GDP ratio at regional level
    CASE 
        WHEN SUM(CASE WHEN d.SeriesCode = ''NY.GDP.MKTP.CD'' THEN d.Value ELSE 0 END) > 0 
        THEN SUM(CASE WHEN d.SeriesCode = ''DT.DOD.DECT.CD'' THEN d.Value ELSE 0 END) / 
             SUM(CASE WHEN d.SeriesCode = ''NY.GDP.MKTP.CD'' THEN d.Value ELSE 0 END)
        ELSE NULL
    END AS DebtToGDPRatio,
    
    -- Average Debt Service Ratio across countries in region
    AVG(CASE WHEN d.SeriesCode = ''DT.TDS.DECT.EX.ZS'' THEN d.Value END) AS AvgDebtServiceRatio,
    
    -- Average External Debt to GNI ratio
    AVG(CASE WHEN d.SeriesCode = ''DT.DOD.DECT.GN.ZS'' THEN d.Value END) AS AvgDebtToGNIRatio
FROM
    Countries c
CROSS JOIN
    LatestYear ly
LEFT JOIN
    DebtData d ON c.CountryCode = d.CountryCode AND d.Year = ly.Year
WHERE
    c.Region IS NOT NULL
GROUP BY
    c.Region, ly.Year;
')
GO

-- Create stored procedure for detailed regional comparison
IF OBJECT_ID('dbo.sp_RegionalDebtComparison', 'P') IS NULL
EXEC('
CREATE PROCEDURE [dbo].[sp_RegionalDebtComparison]
    @Year INT = NULL
AS
BEGIN
    -- If year is not provided, use latest available
    IF @Year IS NULL
    BEGIN
        SELECT @Year = MAX(Year)
        FROM DebtData
        WHERE SeriesCode = ''DT.DOD.DECT.CD''
    END

    -- Get regional debt summary
    SELECT
        c.Region,
        COUNT(DISTINCT c.CountryCode) AS CountryCount,
        SUM(CASE WHEN d.SeriesCode = ''DT.DOD.DECT.CD'' THEN d.Value ELSE 0 END) AS TotalExternalDebt,
        AVG(CASE WHEN d.SeriesCode = ''DT.DOD.DECT.GN.ZS'' THEN d.Value END) AS AvgDebtToGNIRatio,
        AVG(CASE WHEN d.SeriesCode = ''DT.TDS.DECT.EX.ZS'' THEN d.Value END) AS AvgDebtServiceRatio,
        
        -- Concentration Analysis - % of total regional debt held by top 3 countries
        (SELECT TOP 1
            SUM(TopCountries.Value) / NULLIF(SUM(d2.Value), 0) * 100
         FROM
            (SELECT TOP 3
                d1.Value
             FROM
                DebtData d1
             JOIN
                Countries c1 ON d1.CountryCode = c1.CountryCode
             WHERE
                d1.Year = @Year
                AND d1.SeriesCode = ''DT.DOD.DECT.CD''
                AND c1.Region = c.Region
             ORDER BY
                d1.Value DESC
            ) AS TopCountries
         CROSS JOIN
            DebtData d2
         JOIN
            Countries c2 ON d2.CountryCode = c2.CountryCode
         WHERE
            d2.Year = @Year
            AND d2.SeriesCode = ''DT.DOD.DECT.CD''
            AND c2.Region = c.Region
        ) AS DebtConcentrationRatio
    FROM
        DebtData d
    JOIN
        Countries c ON d.CountryCode = c.CountryCode
    WHERE
        d.Year = @Year
        AND c.Region IS NOT NULL
        AND d.SeriesCode IN (''DT.DOD.DECT.CD'', ''DT.DOD.DECT.GN.ZS'', ''DT.TDS.DECT.EX.ZS'')
    GROUP BY
        c.Region
    ORDER BY
        TotalExternalDebt DESC;

    -- Get top countries by debt in each region
    WITH RankedCountries AS (
        SELECT
            c.Region,
            c.ShortName,
            d.Value AS ExternalDebt,
            ROW_NUMBER() OVER (PARTITION BY c.Region ORDER BY d.Value DESC) AS RankInRegion
        FROM
            DebtData d
        JOIN
            Countries c ON d.CountryCode = c.CountryCode
        WHERE
            d.Year = @Year
            AND d.SeriesCode = ''DT.DOD.DECT.CD''
            AND c.Region IS NOT NULL
    )
    SELECT
        Region,
        ShortName AS CountryName,
        ExternalDebt,
        RankInRegion
    FROM
        RankedCountries
    WHERE
        RankInRegion <= 3
    ORDER BY
        Region, RankInRegion;
END
')
GO

-- Create stored procedure for historical regional trend analysis
IF OBJECT_ID('dbo.sp_RegionalDebtTrend', 'P') IS NULL
EXEC('
CREATE PROCEDURE [dbo].[sp_RegionalDebtTrend]
    @StartYear INT = 2010,
    @EndYear INT = NULL
AS
BEGIN
    -- If end year is not provided, use latest available
    IF @EndYear IS NULL
    BEGIN
        SELECT @EndYear = MAX(Year)
        FROM DebtData
        WHERE SeriesCode = ''DT.DOD.DECT.CD''
    END

    -- Get yearly regional debt metrics
    SELECT
        c.Region,
        d.Year,
        SUM(CASE WHEN d.SeriesCode = ''DT.DOD.DECT.CD'' THEN d.Value ELSE 0 END) AS TotalExternalDebt,
        AVG(CASE WHEN d.SeriesCode = ''DT.DOD.DECT.GN.ZS'' THEN d.Value END) AS AvgDebtToGNIRatio,
        AVG(CASE WHEN d.SeriesCode = ''DT.TDS.DECT.EX.ZS'' THEN d.Value END) AS AvgDebtServiceRatio
    FROM
        DebtData d
    JOIN
        Countries c ON d.CountryCode = c.CountryCode
    WHERE
        d.Year BETWEEN @StartYear AND @EndYear
        AND c.Region IS NOT NULL
        AND d.SeriesCode IN (''DT.DOD.DECT.CD'', ''DT.DOD.DECT.GN.ZS'', ''DT.TDS.DECT.EX.ZS'')
    GROUP BY
        c.Region, d.Year
    ORDER BY
        c.Region, d.Year;
END
')
GO

PRINT 'Regional analysis objects created successfully on ' + CONVERT(VARCHAR, GETDATE(), 120);
GO
