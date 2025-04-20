/*
International Debt Statistics - Views Creation Script
Author: tushardhawale123
Created: 2025-04-20
*/

USE [InternationalDebtStatistics]
GO

-- Create key views for the dashboard if they don't exist already
-- Create view for debt to GNI ratio if it doesn't exist
IF OBJECT_ID('dbo.vw_DebtToGNIRatio', 'V') IS NULL
EXEC('
CREATE VIEW [dbo].[vw_DebtToGNIRatio] AS
SELECT 
    c.CountryCode, 
    c.ShortName AS CountryName, 
    c.Region, 
    c.IncomeGroup, 
    d.Year, 
    d.Value AS DebtToGNIRatio
FROM 
    DebtData d
JOIN 
    Countries c ON d.CountryCode = c.CountryCode
WHERE 
    d.SeriesCode = ''DT.DOD.DECT.GN.ZS'' -- External debt stocks (% of GNI)
    AND d.Value IS NOT NULL;
')
GO

-- Create view for debt composition if it doesn't exist
IF OBJECT_ID('dbo.vw_DebtComposition', 'V') IS NULL
EXEC('
CREATE VIEW [dbo].[vw_DebtComposition] AS
SELECT 
    c.CountryCode, 
    c.ShortName AS CountryName, 
    c.Region, 
    d.Year, 
    s.Series_Code, 
    s.Indicator, 
    d.Value
FROM 
    DebtData d
JOIN 
    Countries c ON d.CountryCode = c.CountryCode
JOIN 
    Series s ON d.SeriesCode = s.Series_Code
WHERE 
    d.SeriesCode IN (
        ''DT.DOD.BLAT.CD'',  -- Bilateral debt
        ''DT.DOD.MLAT.CD'',  -- Multilateral debt
        ''DT.DOD.PCBK.CD'',  -- Commercial bank loans
        ''DT.DOD.PBND.CD''   -- Bonds
    )
    AND d.Value IS NOT NULL;
')
GO

-- Create view for debt service ratio if it doesn't exist
IF OBJECT_ID('dbo.vw_DebtServiceRatio', 'V') IS NULL
EXEC('
CREATE VIEW [dbo].[vw_DebtServiceRatio] AS
SELECT 
    c.CountryCode, 
    c.ShortName AS CountryName, 
    c.Region, 
    c.IncomeGroup, 
    d.Year, 
    d.Value AS DebtServiceRatio
FROM 
    DebtData d
JOIN 
    Countries c ON d.CountryCode = c.CountryCode
WHERE 
    d.SeriesCode = ''DT.TDS.DECT.EX.ZS'' -- Total debt service (% of exports)
    AND d.Value IS NOT NULL;
')
GO

-- Create view for total external debt by country if it doesn't exist
IF OBJECT_ID('dbo.vw_TotalExternalDebtByCountry', 'V') IS NULL
EXEC('
CREATE VIEW [dbo].[vw_TotalExternalDebtByCountry] AS
SELECT 
    c.CountryCode, 
    c.ShortName AS CountryName, 
    c.Region, 
    c.IncomeGroup, 
    d.Year, 
    d.Value AS TotalExternalDebt
FROM 
    DebtData d
JOIN 
    Countries c ON d.CountryCode = c.CountryCode
WHERE 
    d.SeriesCode = ''DT.DOD.DECT.CD'' -- Total external debt stocks
    AND d.Value IS NOT NULL;
')
GO

-- Create comprehensive debt dashboard view if it doesn't exist
IF OBJECT_ID('dbo.vw_DebtDashboard', 'V') IS NULL
EXEC('
CREATE VIEW [dbo].[vw_DebtDashboard] AS
WITH LatestYear AS (
    SELECT MAX(Year) AS Year
    FROM DebtData
    WHERE SeriesCode = ''DT.DOD.DECT.CD'' AND Value IS NOT NULL
)
SELECT
    c.CountryCode,
    c.ShortName AS Country_Name,
    c.Region,
    c.IncomeGroup,
    ly.Year AS DataYear,
    
    -- Total External Debt
    MAX(CASE WHEN d.SeriesCode = ''DT.DOD.DECT.CD'' THEN d.Value END) AS TotalExternalDebt,
    
    -- Debt as % of GNI
    MAX(CASE WHEN d.SeriesCode = ''DT.DOD.DECT.GN.ZS'' THEN d.Value END) AS DebtToGNIRatio,
    
    -- Debt Service Ratio
    MAX(CASE WHEN d.SeriesCode = ''DT.TDS.DECT.EX.ZS'' THEN d.Value END) AS DebtServiceRatio,
    
    -- Short-term to Total Debt
    MAX(CASE WHEN d.SeriesCode = ''DT.DOD.DSTC.ZS'' THEN d.Value END) AS ShortTermDebtRatio,
    
    -- Interest Payments
    MAX(CASE WHEN d.SeriesCode = ''DT.INT.DECT.CD'' THEN d.Value END) AS InterestPayments,
    
    -- Interest to Exports Ratio
    MAX(CASE WHEN d.SeriesCode = ''DT.INT.DECT.EX.ZS'' THEN d.Value END) AS InterestToExportsRatio,
    
    -- Reserves to Debt Ratio
    MAX(CASE WHEN d.SeriesCode = ''DT.DOD.DRES.CD'' THEN d.Value END) AS ReservesToDebtRatio,
    
    -- Multilateral Debt
    MAX(CASE WHEN d.SeriesCode = ''DT.DOD.MLAT.CD'' THEN d.Value END) AS MultilateralDebt,
    
    -- Bilateral Debt
    MAX(CASE WHEN d.SeriesCode = ''DT.DOD.BLAT.CD'' THEN d.Value END) AS BilateralDebt,
    
    -- Commercial Debt
    MAX(CASE WHEN d.SeriesCode = ''DT.DOD.PCBK.CD'' THEN d.Value END) AS CommercialDebt,
    
    -- Use of IMF Credit
    MAX(CASE WHEN d.SeriesCode = ''DT.DOD.DIMF.CD'' THEN d.Value END) AS IMFCredit
FROM
    Countries c
CROSS JOIN
    LatestYear ly
LEFT JOIN
    DebtData d ON c.CountryCode = d.CountryCode AND d.Year = ly.Year
GROUP BY
    c.CountryCode,
    c.ShortName,
    c.Region,
    c.IncomeGroup,
    ly.Year;
')
GO

PRINT 'Views created successfully on ' + CONVERT(VARCHAR, GETDATE(), 120);
GO