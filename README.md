# International Debt Statistics Dashboard

A comprehensive Power BI dashboard for analyzing and visualizing international debt statistics across different regions and countries.

![Dashboard Preview](screenshots/dashboard-preview.png)

## Project Overview

This project provides interactive visualizations and analysis tools for international debt statistics. It enables users to compare regional debt metrics, track debt trends over time, and analyze various debt indicators across countries and regions.

### Key Features

- **Regional Comparison Dashboard**: Compare debt metrics across different global regions
- **Country-Level Analysis**: Drill down into specific countries for detailed debt analysis
- **Trend Analysis**: Track debt changes over time with interactive line charts
- **Key Performance Indicators**: Monitor critical debt metrics including debt-to-GDP ratio and debt service ratios
- **Interactive Filtering**: Filter data by region, year, and other dimensions
- **Responsive Design**: Optimized layout for various screen sizes

## Technical Architecture

### Data Source
The dashboard uses SQL Server as the backend data store, with a well-structured dimensional model to represent debt statistics across countries and regions.

### Technology Stack
- **Database**: Microsoft SQL Server
- **Data Visualization**: Microsoft Power BI
- **Data Processing**: T-SQL for data preparation and aggregation
- **Version Control**: Git/GitHub

### Data Model
The solution is built on a star schema with:
- Fact table: DebtStatistics (debt amounts, GDP figures, debt service ratios)
- Dimension tables: Countries, Regions, Time

## Dashboard Components

### Regional Comparison Page
- Geographic map visualization of regional debt
- Key debt metrics by region
- Comparative bar charts for regional analysis
- Trend analysis for historical context
- Detailed tables with debt metrics

### Country Detail Page
- Country-specific debt analysis
- Historical debt trends
- Debt composition breakdown
- Comparative metrics against regional averages

## Implementation Details

### DAX Measures
The dashboard utilizes several custom DAX measures including:

```
// Total Regional Debt
Total Regional Debt = 
CALCULATE(SUM(DebtStatistics[DebtAmount]), ALLEXCEPT(DebtStatistics, DebtStatistics[RegionID]))

// Regional Debt to GDP Ratio
Regional Debt to GDP Ratio = 
DIVIDE([Total Regional Debt], SUM(DebtStatistics[GDPAmount]), 0)
```

### SQL Queries
Core data preparation is handled through SQL, including:

```sql
-- Total debt by region and year
SELECT 
    r.RegionName,
    ds.Year,
    SUM(ds.DebtAmount) as TotalRegionalDebt,
    SUM(ds.GDPAmount) as TotalRegionalGDP
FROM 
    dbo.DebtStatistics ds
JOIN 
    dbo.Countries c ON ds.CountryID = c.CountryID
JOIN 
    dbo.Regions r ON c.RegionID = r.RegionID
GROUP BY 
    r.RegionName, ds.Year
```

## Setup and Usage

### Prerequisites
- Power BI Desktop (latest version recommended)
- SQL Server 2019 or later (for database components)

### Installation
1. Clone this repository
2. Restore the database from `database/DebtStatistics_DB.bak`
3. Open the `InternationalDebtDashboard.pbix` file in Power BI Desktop
4. Update the data source connection to point to your SQL Server instance
5. Refresh the data

### Usage Guide
1. Use the filters at the top to select regions and time periods
2. Click on regions in the map for detailed information
3. Use the tabs at the top to navigate between different dashboard pages
4. Export data or generate reports using Power BI's built-in export functionality

## Future Enhancements
- Integration with live data sources for real-time updates
- Machine learning forecasting for debt trend prediction
- Additional metrics including sustainability indicators
- Mobile-optimized view for on-the-go analysis

## Screenshots
![Country Details](screenshots/country-details.png)
![Trend Analysis](screenshots/trend-analysis.png)

## Author
- [Tushar Dhawale](https://github.com/tushardhawale123)

## License
This project is licensed under the MIT License - see the LICENSE file for details.
