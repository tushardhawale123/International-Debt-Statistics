/*
International Debt Statistics - Sample Data Insert Script
Author: tushardhawale123
Created: 2025-04-20
*/

USE InternationalDebtStats;
GO

-- Clear existing data
DELETE FROM dbo.DebtStatistics;
DELETE FROM dbo.Countries;
DELETE FROM dbo.Regions;
GO

-- Reset identity columns
DBCC CHECKIDENT ('dbo.DebtStatistics', RESEED, 0);
GO

-- Insert regions
INSERT INTO dbo.Regions (RegionID, RegionName, RegionCode) VALUES
(1, 'North America', 'NAM'),
(2, 'Europe & Central Asia', 'ECA'),
(3, 'East Asia & Pacific', 'EAP'),
(4, 'Latin America & Caribbean', 'LAC'),
(5, 'South Asia', 'SAS'),
(6, 'Sub-Saharan Africa', 'SSA'),
(7, 'Middle East & North Africa', 'MNA');
GO

-- Insert countries (sample subset)
INSERT INTO dbo.Countries (CountryID, CountryName, CountryCode, RegionID, IncomeGroup) VALUES
-- North America
(1, 'United States', 'USA', 1, 'High income'),
(2, 'Canada', 'CAN', 1, 'High income'),
(3, 'Mexico', 'MEX', 1, 'Upper middle income'),

-- Europe & Central Asia
(11, 'Germany', 'DEU', 2, 'High income'),
(12, 'United Kingdom', 'GBR', 2, 'High income'),
(13, 'France', 'FRA', 2, 'High income'),
(14, 'Italy', 'ITA', 2, 'High income'),
(15, 'Russia', 'RUS', 2, 'Upper middle income'),

-- East Asia & Pacific
(21, 'China', 'CHN', 3, 'Upper middle income'),
(22, 'Japan', 'JPN', 3, 'High income'),
(23, 'South Korea', 'KOR', 3, 'High income'),
(24, 'Indonesia', 'IDN', 3, 'Lower middle income'),

-- Latin America & Caribbean
(31, 'Brazil', 'BRA', 4, 'Upper middle income'),
(32, 'Argentina', 'ARG', 4, 'Upper middle income'),
(33, 'Colombia', 'COL', 4, 'Upper middle income'),

-- South Asia
(41, 'India', 'IND', 5, 'Lower middle income'),
(42, 'Pakistan', 'PAK', 5, 'Lower middle income'),
(43, 'Bangladesh', 'BGD', 5, 'Lower middle income'),

-- Sub-Saharan Africa
(51, 'Nigeria', 'NGA', 6, 'Lower middle income'),
(52, 'South Africa', 'ZAF', 6, 'Upper middle income'),
(53, 'Kenya', 'KEN', 6, 'Lower middle income'),

-- Middle East & North Africa
(61, 'Saudi Arabia', 'SAU', 7, 'High income'),
(62, 'Egypt', 'EGY', 7, 'Lower middle income'),
(63, 'Turkey', 'TUR', 7, 'Upper middle income');
GO

-- Insert sample debt statistics for multiple years (2020-2024)
-- United States
INSERT INTO dbo.DebtStatistics (CountryID, Year, DebtAmount, GDPAmount, DebtServiceRatio, ExternalDebtAmount) VALUES
(1, 2020, 21000000000000, 22300000000000, 3.2, 7200000000000),
(1, 2021, 23000000000000, 23500000000000, 3.4, 7500000000000),
(1, 2022, 24100000000000, 24800000000000, 3.6, 7800000000000),
(1, 2023, 25800000000000, 26100000000000, 3.8, 8200000000000),
(1, 2024, 27500000000000, 27300000000000, 4.0, 8600000000000);

-- Canada
INSERT INTO dbo.DebtStatistics (CountryID, Year, DebtAmount, GDPAmount, DebtServiceRatio, ExternalDebtAmount) VALUES
(2, 2020, 1900000000000, 1700000000000, 2.1, 1200000000000),
(2, 2021, 2100000000000, 1900000000000, 2.2, 1300000000000),
(2, 2022, 2200000000000, 2100000000000, 2.3, 1400000000000),
(2, 2023, 2300000000000, 2200000000000, 2.4, 1500000000000),
(2, 2024, 2400000000000, 2400000000000, 2.5, 1600000000000);

-- Mexico
INSERT INTO dbo.DebtStatistics (CountryID, Year, DebtAmount, GDPAmount, DebtServiceRatio, ExternalDebtAmount) VALUES
(3, 2020, 710000000000, 1090000000000, 4.5, 450000000000),
(3, 2021, 740000000000, 1150000000000, 4.7, 470000000000),
(3, 2022, 780000000000, 1200000000000, 4.8, 490000000000),
(3, 2023, 810000000000, 1260000000000, 5.0, 510000000000),
(3, 2024, 850000000000,
