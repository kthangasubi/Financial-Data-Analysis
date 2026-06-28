#Step 1 read in file annual reports named AR
library(haven)
AR<-data.frame(read_sas("C:/Users/kthan/Downloads/annualreports(2).sas7bdat"))
AR
#Step 2 get rid of attributes
AR[]<-lapply(AR,function(x) {attributes(x)<-NULL;x})
AR
#Step 3 Convert fiscal year variable
AR$FiscalYearDate
#Added this library to make sure the ymd function worked
library(lubridate)
AR$FiscalYearDate<-ymd(AR$FiscalYearDate)
AR$FiscalYearDate

#Step 4 Get year of fiscal Year
AR$FiscalYear<-year(AR$FiscalYearDate)
AR$FiscalYear

#Step 5 Eliminating financial reports after fiscal year 2013
AR<-AR[AR$FiscalYear <= 2013,]
AR

#'Step 6 Containing records of Sector Consumer Servic 
#' and Industry Department/Specialty
AR<-AR[AR$Sector=="Consumer Servic" 
    & AR$Industry=='Department/Specialty',]
AR

#Step 7 Remove Duplicates
library(dplyr)
AR<-AR %>% distinct(Symbol, FiscalYear,.keep_all=TRUE)
AR

#Step 8 but technically Step 9 Make a table

TickerTable<-data.frame(table(AR$Name))
TickerTable

#Step 9 Sort Tickers from Most to Least Count
TickerTable<-TickerTable[order(-TickerTable$Freq),]
TickerTable


#Step 10 Get Top 4 Companies
TopFour<-AR[AR$Name=="Costco Wholesale Corporation"|
            AR$Name=="Family Dollar Stores, Inc."|
            AR$Name=="Big Lots, Inc." | 
            AR$Name=="Dillard&#39;s, Inc." ,]
TopFour$Name

#Step 11 Remove certain characters
library(stringr)#Library to remove certain characters
TopFour$NewName<-str_remove_all(TopFour$Name,"[.(),#-;]")
TopFour$NewName


#Step 12 Dummy Cols

library(fastDummies)
TopFour<-dummy_cols(TopFour,select_columns=c("NewName")
               ,remove_selected_columns = TRUE)
TopFour


#Step 13 Convert character to numeric/ANOVA
TopFour$SalesToIndustry
TopFour$StoI<-as.numeric(TopFour$SalesToIndustry)
TopFour$StoI
res_aov<-aov(StoI~Symbol,data = TopFour)
summary(res_aov)

#Step 14 Read in options file and adjust dates
options<-data.frame(read_sas("C:/Users/kthan/Downloads/optionsfile(1).sas7bdat"))
options[]<-lapply(options,function(x) {attributes(x)<-NULL;x})
options
options$expdate<-as.Date(options$expdate, origin='1970-01-01')
options$capturedate<-as.Date(options$capturedate, origin='1970-01-01')
options
#Step 15 Old and New Dates
options <- options[options$expdate > as.Date("2013-03-01") & 
                   options$expdate < as.Date("2013-11-30"),]
options

#Step 16 AR Files containing unique symbols
MySymbols<-distinct(AR,Symbol,.keep_all = TRUE)
MySymbols<-subset(MySymbols,select=c(Symbol))

#Step 17 Match Companies
MergeCompanies<-merge(MySymbols,options,by.x="Symbol",by.y="underlying",all.x=TRUE)
MergeCompanies

#Step 18 Tally Gross number of different options
Options_table<- data.frame(table(MergeCompanies$Symbol))
Options_table

#Step 19 Calculations for Average Strike Price
AvgStrikePrice<-data.frame(
  MergeCompanies%>%group_by(Symbol,type)%>%
  summarise(
    AvgStrikePrice=mean(strike,na.rm=TRUE)
  ))
AvgStrikePrice

#Step 20 Read in Dividends file 
dividends<-data.frame(read_sas("C:/Users/kthan/Downloads/divfile(1).sas7bdat"))

#Step 21 Remove nuisance attributes
dividends[]<-lapply(dividends,function(x) {attributes(x)<-NULL;x})

#Step 22 Reduce Records with the Date range
dividends$date<-as.Date(dividends$date, origin='1970-01-01')
dividends <- dividends[dividends$date > as.Date("2013-03-01") & 
                      dividends$date < as.Date("2013-11-30"),]
dividends
#Step 23 Match to list of tickers
MergeDividends<-merge(MySymbols,dividends,by.x="Symbol",by.y="tic",all.x=TRUE)
MergeDividends


#Step 24 Sum up of total dividends
TotalDividends<-data.frame(
  MergeDividends%>%group_by(Symbol)%>%
    summarise(
      TotalDividends=sum(DivAmount,na.rm=TRUE)
    ))
TotalDividends

#Step 25 Read in Price file
Price<-data.frame(read_sas("C:/Users/kthan/Downloads/pricesrevised(1).sas7bdat"))

#Step 26 Year of Dates in files
Price$year<-year(Price$date)
Price$year

#Step 27 Reduce Data to Beginning Year of Dividend Field
Price<- Price[Price$year == 2012,]
Price

#Step 28 Match to list of tickers
MergePrice<-merge(MySymbols,Price,by.x="Symbol",by.y="tic",all.x=TRUE)
MergePrice

#Step 29 Open Price
OpenPrice<-MergePrice %>% 
  group_by(Symbol) %>%
  filter(date == min(date))
OpenPrice

#Step 30 Merge Open Price and Total Dividends
MergeOPTD<-merge(OpenPrice,TotalDividends,by.x="Symbol",all.x=TRUE)
MergeOPTD

#Step 31 Divide Share Price for each company with open price
MergeOPTD$TotalYield<-MergeOPTD$TotalDividends/MergeOPTD$open
MergeOPTD$TotalYield

#Step 32 Read in Splits Data file
Splits<-data.frame(read_sas("C:/Users/kthan/Downloads/splits(1).sas7bdat"))

#Step 33 Remove nuisance attributes
Splits[]<-lapply(Splits,function(x) {attributes(x)<-NULL;x})

#Step 34 Convert date from character to date
Splits$Date<-ymd(Splits$Date)
Splits$Date

#Step 35 Isolate records after 1999
Splits<-Splits[Splits$Date>=as.Date('1999-01-01'),]
Splits

#Step 36 Merge with your tickers
MergeSplits<-merge(MySymbols,Splits,by.x="Symbol",by.y="tic",all.x=TRUE)
MergeSplits

#Step 37 Determine max and min split
SplitsMaxMin<-data.frame(
  MergeSplits%>%group_by(Symbol)%>%
  summarise(MaxPop=max(Split,na.rm=TRUE),
            MinPop=min(Split,na.rm=TRUE)))
SplitsMaxMin

#Step 38 Summary/More of Options file and Make Big file
library(tidyr)#Used for the spread function
library(purrr)#Used for the reduce function
OptionsWide = AvgStrikePrice %>% 
  spread(type, AvgStrikePrice)
list_df = list(OptionsWide,TotalDividends,SplitsMaxMin)
df2 <- list_df %>% reduce(left_join, by='Symbol')
df2


