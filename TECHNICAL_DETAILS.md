# International Debt Statistics Dashboard - Technical Documentation

## Database Schema

The solution is built on a SQL Server database with the following structure:

### Core Tables

#### Countries
Contains metadata about countries including their regional groupings and economic classifications.
- **CountryCode** (PK): Unique identifier for each country
- **Long_Name**: Full country name
- **ShortName**: Abbreviated country name
- **Region**: Geographic region (e.g., "East Asia & Pacific")
- **IncomeGroup**: Economic classification (e.g., "High income")
- Plus additional metadata fields

#### DebtData
Core fact table containing all debt-related statistics.
- **Country_Name**: Name of the country
- **CountryCode** (FK): Foreign key to Countries table
- **Series_Name**: Name of the debt indicator
- **SeriesCode**: Code representing the debt indicator (e.g., "DT.DOD.DECT.CD" for total external debt)
- **Year**: Year of the debt data
- **Value**: Actual debt value

#### Series
Contains metadata about the different debt metrics and indicators.
- **Series_Code** (PK): Unique identifier for each indicator
- **Indicator**: Short description of the indicator
- **Short_definition**: Brief explanation of what the indicator measures
- **Long_definition**: Comprehensive explanation of the indicator
- Plus additional fields like source, periodicity, etc.

### Key Views

#### vw_RegionalDebtComparison
Provides aggregated debt metrics at the regional level.
```sql
CREATE VIEW [dbo].[vw_RegionalDebtComparison] AS
WITH LatestYear AS (
    SELECT MAX(Year) AS Year
    FROM DebtData
    WHERE SeriesCode = 'DT.DOD.DECT.CD' AND Value IS NOT NULL
)
SELECT
    r.Region,
    ly.Year AS DataYear,
    COUNT(DISTINCT c.CountryCode) AS CountryCount,
    
    -- Total External Debt
    SUM(CASE WHEN d.SeriesCode = 'DT.DOD.DECT.CD' THEN d.Value ELSE 0 END) AS TotalExternalDebt,
    
    -- Average Debt to GNI ratio
    AVG(CASE WHEN d.SeriesCode = 'DT.DOD.DECT.GN.ZS' THEN d.Value END) AS AvgDebtToGNIRatio,
    
    -- Average Debt Service Ratio
    AVG(CASE WHEN d.SeriesCode = 'DT.TDS.DECT.EX.ZS' THEN d.Value END) AS AvgDebtServiceRatio
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
```

#### vw_DebtDashboard
Comprehensive view that consolidates all key debt metrics for the most recent year.

#### vw_TotalExternalDebtByCountry
Focused view specifically for total external debt by country and year.

#### vw_DebtServiceRatio
Focused view for debt service ratios.

### Stored Procedures

#### sp_RegionalDebtComparison
Generates a comprehensive regional comparison for a specified year.

#### sp_RegionalDebtTrend
Provides historical trend data for regional debt metrics.

#### sp_CountryDebtTrend
Returns historical debt data for a specific country.

#### sp_CompareWithPeers
Compares a country's debt metrics with regional and income group averages.

## Power BI Implementation

### Data Model Architecture
- **Direct Query**: Main tables use Direct Query mode for real-time data access
- **Import**: Some reference tables use Import mode for better performance
- **Composite Model**: Combination of Direct Query and Import modes

### DAX Measures
The dashboard includes numerous DAX measures for analysis:

```dax
// Total Regional Debt
Total Regional Debt = 
CALCULATE(
    SUM(DebtData[Value]), 
    DebtData[SeriesCode]="DT.DOD.DECT.CD", 
    ALLEXCEPT(DebtData, DebtData[CountryCode])
)

// Regional Debt to GNI Ratio
Regional Debt to GNI Ratio = 
DIVIDE(
    CALCULATE(SUM(DebtData[Value]), DebtData[SeriesCode]="DT.DOD.DECT.CD"),
    CALCULATE(SUM(DebtData[Value]), DebtData[SeriesCode]="NY.GNP.ATLS.CD"),
    0
)

// YoY Growth Rate
Regional Debt YoY Growth = 
VAR CurrentYear = MAX(DebtData[Year])
VAR CurrentYearDebt = CALCULATE(
    SUM(DebtData[Value]), 
    DebtData[SeriesCode]="DT.DOD.DECT.CD", 
    DebtData[Year] = CurrentYear
)
VAR PreviousYearDebt = CALCULATE(
    SUM(DebtData[Value]), 
    DebtData[SeriesCode]="DT.DOD.DECT.CD", 
    DebtData[Year] = CurrentYear - 1
)
RETURN DIVIDE(CurrentYearDebt - PreviousYearDebt, PreviousYearDebt, 0)

// Average Debt Service Ratio
Avg Regional Debt Service Ratio = 
CALCULATE(
    AVERAGE(DebtData[Value]),
    DebtData[SeriesCode]="DT.TDS.DECT.EX.ZS"
)

// Debt Concentration Ratio
Debt Concentration Ratio = 
VAR Top3Debt = CALCULATE(
    SUM(DebtData[Value]),
    DebtData[SeriesCode]="DT.DOD.DECT.CD",
    TOPN(3, VALUES(Countries[ShortName]), 
        CALCULATE(SUM(DebtData[Value]), DebtData[SeriesCode]="DT.DOD.DECT.CD"),
        DESC
    )
)
VAR TotalDebt = CALCULATE(
    SUM(DebtData[Value]),
    DebtData[SeriesCode]="DT.DOD.DECT.CD"
)
RETURN DIVIDE(Top3Debt, TotalDebt, 0)

// Regional Debt Rank
Region Debt Rank = 
RANKX(
    VALUES(Countries[Region]), 
    CALCULATE(SUM(DebtData[Value]), DebtData[SeriesCode]="DT.DOD.DECT.CD"),, 
    DESC
)
```

## Visual Components

### Regional Comparison Page

#### Map Visual
- Uses Filled Map visual with gradient coloring based on debt amount
- Tooltips show additional region metrics
- Regions clickable for filtering other visuals

#### KPI Cards
- Show key metrics: Total Debt, Debt/GDP Ratio, Avg. Debt Service Ratio, External Debt %
- Include sparklines for historical trend context
- Use conditional formatting for visual indicators

#### Regional Debt Bar Chart
- Compares total debt by region
- Uses consistent color scheme with map
- Includes data labels for precise values

#### Debt Trend Lines
- Shows multi-year trend for each region
- Uses line chart with markers at data points
- Allows selection of different metrics

#### Detailed Data Table
- Comprehensive matrix with all key metrics by region
- Includes sorting and conditional formatting
- Supports export functionality

### Technical Optimizations

#### Performance Enhancements
1. **Query Folding**: DAX measures designed to enable query folding where possible
2. **Aggregation Tables**: Pre-calculated aggregations for common regional metrics
3. **Indexed Views**: Database-level optimizations for frequently accessed data
4. **Incremental Refresh Policy**: Set up for large historical datasets

#### Security Implementation
- Row-level security configured for multi-user deployments
- Separate roles for analysts and viewers
- Custom security groups aligned with organizational structure

## Deployment Architecture
The solution is designed for flexible deployment:
- Power BI Service publishing with scheduled refreshes
- Direct connectivity to on-premises SQL Server through gateway
- Optional Azure SQL Database deployment for cloud-based implementation

## Development Best Practices
- Source control integration with GitHub
- Documentation of DAX measures and data transformations
- Consistent naming conventions across database and Power BI objects
- Standardized color palette and visual formatting