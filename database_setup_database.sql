/*
International Debt Statistics - Database Setup Script
Author: tushardhawale123
Created: 2025-04-20
*/

USE [master]
GO

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'InternationalDebtStatistics')
BEGIN
    CREATE DATABASE [InternationalDebtStatistics]
    CONTAINMENT = NONE
    ON PRIMARY 
    (NAME = N'InternationalDebtStatistics', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL\DATA\InternationalDebtStatistics.mdf', SIZE = 335872KB)
    LOG ON 
    (NAME = N'InternationalDebtStatistics_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL\DATA\InternationalDebtStatistics_log.ldf', SIZE = 598016KB)
    WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF;
END
GO

USE [InternationalDebtStatistics]
GO

-- Create main tables if they don't exist
IF OBJECT_ID('dbo.Countries', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Countries](
        [CountryCode ] [nvarchar](50) NOT NULL,
        [Long_Name] [nvarchar](100) NOT NULL,
        [IncomeGroup] [nvarchar](50) NULL,
        [Region] [nvarchar](50) NULL,
        [Lending_category] [nvarchar](50) NULL,
        [Other_groups] [nvarchar](50) NULL,
        [Currency_Unit] [nvarchar](50) NULL,
        [Latest_population_census] [nvarchar](150) NULL,
        [Latest_household_survey] [nvarchar](100) NULL,
        [Special_Notes] [nvarchar](1350) NULL,
        [National_accounts_base_year] [nvarchar](100) NULL,
        [National_accounts_reference_year] [smallint] NULL,
        [System_of_National_Accounts] [nvarchar](100) NULL,
        [SNA_price_valuation] [nvarchar](50) NULL,
        [PPP_survey_years] [nvarchar](200) NULL,
        [Balance_of_Payments_Manual_in_use] [nvarchar](50) NULL,
        [External_debt_Reporting_status] [nvarchar](50) NULL,
        [System_of_trade] [nvarchar](50) NULL,
        [Government_Accounting_concept] [nvarchar](50) NULL,
        [IMF_data_dissemination_standard] [nvarchar](100) NULL,
        [Source_of_most_recent_Income_and_expenditure_data] [nvarchar](100) NULL,
        [Vital_registration_complete] [nvarchar](50) NULL,
        [Latest_agricultural_census] [nvarchar](150) NULL,
        [Latest_industrial_data] [smallint] NULL,
        [Latest_trade_data] [smallint] NULL,
        [Latest_water_withdrawal_data] [smallint] NULL,
        [_2_alpha_code] [nvarchar](50) NOT NULL,
        [WB_2_code] [nvarchar](50) NOT NULL,
        [Table_Name] [nvarchar](100) NOT NULL,
        [ShortName] [nvarchar](100) NOT NULL,
     CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
    (
        [CountryCode ] ASC
    )
    );
END
GO

IF OBJECT_ID('dbo.DebtData', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[DebtData](
        [Country_Name] [nvarchar](50) NULL,
        [CountryCode] [nvarchar](50) NULL,
        [Counterpart_Area_Name] [nvarchar](50) NULL,
        [Counterpart_Area_Code] [nvarchar](50) NULL,
        [Series_Name] [nvarchar](100) NULL,
        [SeriesCode] [nvarchar](50) NULL,
        [Year] [int] NULL,
        [Value] [float] NULL
    );
END
GO

IF OBJECT_ID('dbo.Series', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Series](
        [Series_Code] [nvarchar](50) NOT NULL,
        [License_Type] [nvarchar](50) NULL,
        [Indicator] [nvarchar](100) NOT NULL,
        [Short_definition] [nvarchar](max) NULL,
        [Long_definition] [nvarchar](max) NOT NULL,
        [Source] [nvarchar](max) NOT NULL,
        [TopicName] [nvarchar](255) NULL,
        [Dataset] [nvarchar](max) NULL,
        [Periodicity] [nvarchar](max) NOT NULL,
        [Aggregation_method] [nvarchar](max) NOT NULL,
        [Limitations_and_exceptions] [nvarchar](max) NULL,
        [General_comments] [nvarchar](max) NULL,
     CONSTRAINT [PK_Series] PRIMARY KEY CLUSTERED 
    (
        [Series_Code] ASC
    )
    );
END
GO

IF OBJECT_ID('dbo.CountrySeries', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CountrySeries](
        [Type] [nvarchar](50) NOT NULL,
        [Country Code] [nvarchar](100) NOT NULL,
        [Series Code] [nvarchar](100) NOT NULL,
        [Description] [nvarchar](700) NOT NULL
    );
END
GO

IF OBJECT_ID('dbo.Footnotes', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Footnotes](
        [Type] [nvarchar](50) NOT NULL,
        [Country_Code] [nvarchar](50) NOT NULL,
        [Series_Code] [nvarchar](max) NOT NULL,
        [Time_Code] [nvarchar](50) NOT NULL,
        [Description] [nvarchar](max) NOT NULL
    );
END
GO

-- Create indexes for better performance
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Countries_Region')
    CREATE NONCLUSTERED INDEX [IX_Countries_Region] ON [dbo].[Countries]([Region] ASC);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Countries_IncomeGroup')
    CREATE NONCLUSTERED INDEX [IX_Countries_IncomeGroup] ON [dbo].[Countries]([IncomeGroup] ASC);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DebtData_CountryYear')
    CREATE NONCLUSTERED INDEX [IX_DebtData_CountryYear] ON [dbo].[DebtData]([CountryCode] ASC, [Year] ASC);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DebtData_SeriesYear')
    CREATE NONCLUSTERED INDEX [IX_DebtData_SeriesYear] ON [dbo].[DebtData]([SeriesCode] ASC, [Year] ASC);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DebtData_Year')
    CREATE NONCLUSTERED INDEX [IX_DebtData_Year] ON [dbo].[DebtData]([Year] ASC);

-- Add foreign key constraints if missing
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_DebtData_Country')
    ALTER TABLE [dbo].[DebtData] ADD CONSTRAINT [FK_DebtData_Country] FOREIGN KEY([CountryCode]) REFERENCES [dbo].[Countries] ([CountryCode ]);

PRINT 'Database schema setup completed successfully on ' + CONVERT(VARCHAR, GETDATE(), 120);
GO