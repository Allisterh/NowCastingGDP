

# Notes:
#
#  1) Didn't round figures
#  2) Will add code later that will exclude variables that are rates or are MoM/QoQ/YoY from being transformed
#  3) Will add code for function error handling (if necessary)
#  4) Report any issues

# Install and load packages -------------------------------------------

source("./scripts/00_load_packages.R")

# Import Raw Data -----------------------------------------------------

# Main (Bloomberg) Data. Start Data Import From 4th Row
main_raw_data <- read_xlsx("./data/data_main.xlsx",
  sheet = "data", range = cell_rows(c(4, NA))
)

# BER Data. Change path as needed
ber_raw_data <- read_xlsx("./data/data_ber.xlsx",
  sheet = "South Africa"
)

# Thomson Reuters Data for November. Start Data Import From 17th Row
reuters_raw_data <- read_xlsx("./data/data_vehicle_sales.xlsx",
  sheet = "Historical Values",
  range = cell_rows(c(17, NA))
)

# Prepping Data -------------------------------------------------------

# Remove Redundant Rows
main_raw_data_new <- main_raw_data[-c(1:2), ]                                    

# head(main_raw_data_new)                                                          

# Check whether there are Missing Headers or Other Header Issues
# colnames(main_raw_data_new)                                                            
# Get Column Names
Colnames <- colnames(main_raw_data_new)

Colnames[1] <- "Date"                                                                  # Add Column Name for Dates Column
Colnames <- str_replace(Colnames,"\\.\\.\\.[0-9]+","")                                 # Replace Nonsense in Headers
colnames(Main_Raw_Data_New) <- Colnames                                                # Re-assign Column Names
colnames(Main_Raw_Data_New)                                                            # Have a Quick Look at Column Names Again
length(colnames(Main_Raw_Data_New))                                                    # Check Number of Columns

any(duplicated(Colnames))                                                              # Check for duplicated Columns
Colnames[duplicated(Colnames)]                                                         # View Duplicated Columns (if any)
Main_Raw_Data_New <- Main_Raw_Data_New[!duplicated(Colnames)]                          # Remove Duplicate Columns from Dataset (if any)
any(duplicated(colnames(Main_Raw_Data_New)))                                           # Check if any Duplicates Remain (if applicable)
length(colnames(Main_Raw_Data_New))
head(Main_Raw_Data_New) 

## Remove Data for Invalid Bloomberg Codes 
Columns_Invalid_Bloomberg_Codes <- which(str_detect(Main_Raw_Data_New[1,],"#N/A Invalid Security")) # Bloomberg Gives the Quoted Error when Codes are Not Valid
Columns_Invalid_Bloomberg_Codes                                                                     # Check which Columns are Invalid
Main_Raw_Data_New <- Main_Raw_Data_New[,-Columns_Invalid_Bloomberg_Codes]                           # Remove Problematic Columns
head(Main_Raw_Data_New)                                                                             # Quick Look at the Data
dim(Main_Raw_Data_New)                                                                              # Check new Data Dimensions

### Prepping BER Raw Data
## Getting Relevant Rows/Columns
BER_Raw_Data_New <- BER_Raw_Data[-c(1),]                                                            # Remove Redundant Rows
Colnames <- colnames(BER_Raw_Data_New)                                                              # Get Column Names
Colnames[1] <- "Date"                                                                               # Add Column Name for Dates Column
colnames(BER_Raw_Data_New) <- Colnames                                                              # Re-assign Column Names
BER_Raw_Data_New <- na.omit(BER_Raw_Data_New)                                                       # Note: Don't have to use this Line of Code
head(BER_Raw_Data_New)                                                                              # Quick Look at the Data

## Change Date Format
BER_Raw_Data_New_Date_Formatted <- BER_Raw_Data_New %>% transmute( Date=sub("Q1", "-03-31", Date),get(colnames(BER_Raw_Data_New)[2]))                               # Change e.g. 2020Q1 to 2020-03-31 
BER_Raw_Data_New_Date_Formatted <- BER_Raw_Data_New_Date_Formatted %>% transmute(Date=sub("Q2", "-06-30", Date),get(colnames(BER_Raw_Data_New_Date_Formatted)[2]))  # Change e.g. 2020Q2 to 2020-06-30 
BER_Raw_Data_New_Date_Formatted <- BER_Raw_Data_New_Date_Formatted %>% transmute(Date=sub("Q3", "-09-30", Date),get(colnames(BER_Raw_Data_New_Date_Formatted)[2]))  # Change e.g. 2020Q3 to 2020-09-30 
BER_Raw_Data_New_Date_Formatted <- BER_Raw_Data_New_Date_Formatted %>% transmute(Date=sub("Q4", "-12-31", Date),get(colnames(BER_Raw_Data_New_Date_Formatted)[2]))  # Change e.g. 2020Q4 to 2020-12-31

Colnames <- colnames(BER_Raw_Data_New_Date_Formatted)                                                    # Get Column Names
Colnames[2] <- "Composite Business Confidence"                                                           # Re-Add Column Name for Index Column
colnames(BER_Raw_Data_New_Date_Formatted) <- Colnames                                                    # Re-assign Column Names
head(BER_Raw_Data_New_Date_Formatted)                                                                    # Quick Look at the Data
BER_Raw_Data_New_Date_Formatted$Date <- as.POSIXct(BER_Raw_Data_New_Date_Formatted$Date, tz="UTC")       # Change Date Format to Agree with Bloomberg Dates

### Prepping Thomson Reuters Raw Data
## Getting Relevant Rows/Columns
Colnames <- Reuters_Raw_Data[2,]                                                              # Get Row with Text We Will use as Column Names
Reuters_Raw_Data_New <- Reuters_Raw_Data[-c(1:2),]                                            # Remove Redundant Rows
Colnames[1] <- "Date"                                                                         # Add Column Name for Dates Column
colnames(Reuters_Raw_Data_New) <- Colnames                                                    # Re-assign Column Names
Reuters_Raw_Data_New <- na.omit(Reuters_Raw_Data_New)                                         # Note: Don't have to use this Line of Code
head(Reuters_Raw_Data_New)                                                                    # Quick Look at the Data
Reuters_Raw_Data_New$Date <- excel_numeric_to_date(as.numeric(Reuters_Raw_Data_New$Date))     # Change Numeric Excel Dates to Date Class
Reuters_Raw_Data_New$Date <- as.POSIXct(as.character(Reuters_Raw_Data_New$Date), tz="UTC")    # Change Date Format to Agree with Bloomberg Dates

#### Merging Datasets
Merged_Data <- full_join(Main_Raw_Data_New, BER_Raw_Data_New_Date_Formatted,by="Date")    # Full Outer Join - Merge Main Data and BER Data
Merged_Data <- full_join(Merged_Data, Reuters_Raw_Data_New,by="Date")                     # Full Outer Join - Merged the Merged Data with Thomson Reuters Data
Merged_Data_New <- Merged_Data %<>%  mutate_if(is.character,as.numeric)                   # Change Numerical Data from Character class to Numeric; Assign to New Name 
head(Merged_Data_New)                                                                     # Quick Look at the Data

#### Clean Merged Data
### Doing Inspection
colnames(Merged_Data_New)                                                                # Looking at Column Names to See if Cleaning is Required
dim(Merged_Data_New)                                                                     # Check Dimensions of Data if any Issues
describe(Merged_Data_New)                                                                # Look at Data Statistics
str(Merged_Data_New)                                                                     # Look at Structure of Data
glimpse(Merged_Data_New)                                                                 # Look at Structure of Data
summary(Merged_Data_New)                                                                 # Look at Data Statistics

### Make Adjustments/Doing Cleaning
## Remove Empty Rows + Cols
Merged_Data_New <- Merged_Data_New %>% remove_empty(which=c("rows", "cols"))             # Remove any Empty Rows or Columns
dim(Merged_Data_New)                                                                     # Check New Dimensions of the Data
describe(Merged_Data_New)                                                                # Look at Data Statistics

## Tidy Headers
colnames(Merged_Data_New)                                                                # Have a look at Column Names
Merged_Data_New <- clean_names(Merged_Data_New)                                          # Tidying Headers for Easier Use
colnames(Merged_Data_New)                                                                # Have a look at new Column Names
Colnames <- colnames(Merged_Data_New)                                                    # Some Column Names Need Fixing; Get Column Names
Colnames[length(Colnames)] <- "azavehaap"                                                # Make fix
colnames(Merged_Data_New) <- Colnames                                                    # re-assign Column Names
Cleaned_Data <- Merged_Data_New                                                          # Assign Data to New Name for Subsequent Debugging

#### Transformations + Create Lags
### Transformation
Cleaned_Data_New <- Cleaned_Data                                                         # Create New Name to Use in the Loop
for (i in (2: ncol(Cleaned_Data))){                                                      # Set the Parameters of the Loop to run over all Columns Except Date Column
  Column_Name_Temp <- as.name(colnames(Cleaned_Data)[[i]])                               # Getting the Variable Name we are Mutating
  Variable_Name_Temp <- as.name(colnames(Cleaned_Data)[[i]])                             # Set Initial Variable Name After Which the New Variables Should be Added to
  Variable_Name <- paste0(colnames(Cleaned_Data)[[i]], "_QPC")                                                                           # Create the Name of the New Variable (Transformation 1)
  Variable_Name_1 <- paste0(colnames(Cleaned_Data)[[i]], "_QPC_Annualized")                                                              # Create the Name of the New Variable (Transformation 2)
    Cleaned_Data_New <- mutate(Cleaned_Data_New, !!Variable_Name:= (((eval(Column_Name_Temp) /lag(eval(Column_Name_Temp),3))-1)*100), .after=Variable_Name_Temp)        # Add the Lagged Variable to the Data after its non-lagged Counterpart
    Variable_Name_Temp <- Variable_Name                                                                                                  # Update the Variable Name After Which the New Variable Should be Added to
    Cleaned_Data_New <- mutate(Cleaned_Data_New, !!Variable_Name_1:= ((((eval(Column_Name_Temp) /lag(eval(Column_Name_Temp),3))^4)-1)*100), .after=Variable_Name_Temp)        # Add the Lagged Variable to the Data after its non-lagged Counterpart
  }

### Lags
## Create Function To Determine Freq of Data in Any Col
Find_Freq <- function(Data, Column_Number){                                              # Create Function that Determines the frequency of the Data in a Column (for a given column number); Assign to Name
if (length(Column_Number)>1){                                                            # Ensure only one Column is Provided; More Error Handling to be Added.
  warning("Not a single column number was provided!")
} else {
    
  }

Temp <- na.omit(Data[,c(1,Column_Number)])                                               # Create Dataset with only Date and Relevant Data Column; Remove missing Values Reduced Dataset; Assign to Name 
Last_Row <- nrow(na.omit(Data[,Column_Number]))-0                                        # Find Last Row
Second_Last_Row <- nrow(na.omit(Data[,Column_Number]))-1                                 # Find Second Last Row
Third_Last_Row <- nrow(na.omit(Data[, Column_Number]))-2                                 # Find Third Last Row
Last_Row_Date <- Temp[Last_Row,1]                                                        # Get Date of the Last Row in the Reduced Dataset
Second_Last_Row_Date <- Temp[Second_Last_Row,1]                                          # Get Date of the Second last Row in the Reduced Dataset
Third_Last_Row_Date <- Temp[Third_Last_Row,1]                                            # Get the Date of the Third Last Row in the Reduced Dataset

Interval_1 <- interval((Second_Last_Row_Date[[1]]) , Last_Row_Date[[1]]) %>%             # Get the Interval Between the Last and Second Last Date in Terms of Days
  as.numeric('days')

Interval_2 <- interval(Third_Last_Row_Date[[1]] , Second_Last_Row_Date[[1]]) %>%         # Get the Interval Between the Second Last and Third Last Date in terms of Days
  as.numeric('days')

if (Interval_1 <40 | Interval_2<40){                                                    # The Frequency is Considered Monthly if Atleast One of the Two Intervals are Shorter then 40Days
  Temp2 <- "Monthly"
  } else if  (Interval_1 >40 & Interval_1 <100 | Interval_2 >40 & Interval_2 <100 ) {   # The Frequency is Considered  Quarterly if Atleast One of the Two Intervals are Shorter then 1000Days but Longer than 40 Days
  Temp2 <- "Quarterly"
  } else{
  Temp2 <- "Annually"                                                                    # The Frequency is Considered Annual if No Conditions are met.
  }
return(Temp2)
}

## Create Lags Using Loop
Number_Of_Lags <- 1                                                                                               # Set Number of Lags
Test_Data <- Cleaned_Data_New                                                                                     # Create New Name to Use in the loop
  
for (i in (2: ncol(Cleaned_Data_New))){                                                                           # Set the Parameters of the Loop to run over all Columns Except Date Column
  tryCatch({
Freq <- Find_Freq(Cleaned_Data_New, i)                                                                            # Assign function that determines Frequency to New Name for Subsequent Debugging
if (Freq=="Monthly"){
  Lag_Multiple <- 1                                                                                               # Observations need to shift one row for each lag for monthly data
} else if (Freq=="Quarterly"){
  Lag_Multiple <- 3                                                                                               # Observations need to shift three rows for each lag for quarterly data
  } else {
  Lag_Multiple <- 12                                                                                              # Observations need to shift twelve rows for each lag for annual data
}

Column_Name_Temp <- as.name(colnames(Cleaned_Data_New)[[i]])                                                      # Getting the Variable Name we are Mutating (lagging)
Variable_Name_Temp <- as.name(colnames(Cleaned_Data_New)[[i]])                                                    # Set Initial Variable Name After Which the New Variables Should be Added to
for (j in (seq(1*Lag_Multiple,Number_Of_Lags*Lag_Multiple,by=Lag_Multiple))){                                     # Set the Parameters of the Loop
Variable_Name <- paste0(colnames(Cleaned_Data_New)[[i]], "_L", j)                                                 # Create the Name of the New Lagged Variable
Test_Data <- mutate(Test_Data, !!Variable_Name:= lag(eval(Column_Name_Temp),j), .after=Variable_Name_Temp)        # Add the Lagged Variable to the Data after its non-lagged Counterpart
Variable_Name_Temp <- Variable_Name                                                                               # Update the Variable Name After Which the New Variable Should be Added to
}
}, error=function(e){})
}

Cleaned_Data_Augmented <- Test_Data                                                                               # Assign Data to New Name for Subsequent Debugging

#### Filter Data
#Cleaned_Data_Augmented_Filtered <- Cleaned_Data_Augmented %>% select() %>% filter()                               # Filter Data to Correct Sample

#### Final Data
Final_Data <- Cleaned_Data_Augmented_Filtered                                                                     # Assign Data to New Name for Potential use in Subsequent Analysis/Wrangling
#write.csv(Final_Data, "Data/Nowcasting_Final_Cleaned_Data.csv")                                                       # Write a .csv file with the Data for Further Analysis in a Different Script or Software


  