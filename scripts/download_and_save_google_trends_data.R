
# Prepare Packages and Functions ------------------------------------------

# Install and load packages
source("./scripts/00_load_packages.R")

# load keywords list
# Can simply add a keywords to this csv file and it will be downloaded
keywords <- readLines("./data/google_trends/keywords.csv")
todaySavePath <- format(Sys.time(), "%Y%m%d")
savePath <- paste0("./data/google_trends/keyword_trends_", today, ".csv")


source("./scripts/functions/google_trends_get_google_trends_data.R")

# loop for all keywords and data export -----------------------------------

# for loop to try googleTrendsData function
# and return error message in console when encountered
output <- data.frame()
# change 1 to whichever number when daily quota has been reached
for (i in c(1:length(keywords))) {
  try({
    output_new <- map_dfr(
      .x = keywords[i],
      .f = GetGoogleTrendsData
    ) %>%
      data.frame()
    output <- rbind(output, output_new)
  })
}

# export dataframe as csv
# this is a relative path to the R project
# Can out this at end of for loop for slower execution, but data will be
#   there up to the series on which it failed
write.csv(output, savePath)
