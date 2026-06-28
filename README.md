# Financial-Data-Analysis

# Overview
This project analyzes financial data across 4 large retail companies in the Consumer Services/Department Sector using R.
It uses 5 different datasets annual reports, options, dividends, stock prices, and stocks splits to produce a financial summary.

# Companies analyzed
The companies that were analyzed in this project were:
Costco Wholesale Corporation,
Family Dollar Stores, Inc.,
Big Lots, Inc., 
Dillard's, Inc.

# Datasets used
annualreports.sas7bdat : Fiscal Year Financials and sector/industry classifications

optionsfile.sas7bdat : Options contracts with strike prices and expiration dates

divfile.sas7bdat : Dividend payment records

pricesrevised.sas7bdat : Historical daily stock prices

splits.sas7bdat : split history since 1999

# Libraries Used
haven       : Reading SAS files

lubridate   : Date parsing and extraction

dplyr       : Data manipulation and summarization

stringr     : String cleaning

fastDummies : Creating dummy variables

tidyr       : Reshaping data (spread)

purrr       : Joining multiple data frames (reduce)

# Summary
1. Annual Reports


Loaded and cleaned SAS data; stripped attributes and parsed fiscal year dates
Filtered records to fiscal years ≤ 2013 in the Consumer Services / Department/Specialty sector
Removed duplicates by company ticker and fiscal year
Ran a one-way ANOVA on Sales-to-Industry ratios across the top four companies


2. Options

Filtered contracts with expiration dates between March and November 2013
Merged with the company ticker list
Calculated average strike price by company and option type (call/put)


3. Dividends
   
Filtered dividend payments within the same March–November 2013 window
Merged with company tickers and summed total dividends per company


4. Stock Prices

Extracted 2012 opening prices (earliest date per ticker)
Computed dividend yield = Total Dividends / Opening Price


5. Stock Splits
   
Filtered splits from 1999 onward
Calculated max and min split ratios per company


6. Final Dataset

Combined options (wide format), dividends, and split summaries into a single wide table using reduce(left_join)

# Key Metrics Produced

Sales-to-Industry ratio (with ANOVA results)

Average call and put strike prices

Total dividend payout per company

Dividend yield (dividends / 2012 open price)

Maximum and minimum stock split ratios


