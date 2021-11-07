# The function wrap all the arguments of the gtrendR::trends function
# And return only the interest_over_time (you can change that)
# Available series within trends are:
#   "interest_over_time"  "interest_by_country" "interest_by_region"
#   "interest_by_dma"     "interest_by_city"    "related_topics"
#   "related_queries"
GetGoogleTrendsData <- function(keywords) {
  # Set the geographic region - South Africa - ZA
  # Time - start of data to current day
  # Google Product - Web Searches
  country <- c("ZA")
  time <- paste0("2004-01-01 ", format(Sys.time(), "%Y-%m-%d"))
  product <- "web"
  
  trends <- gtrendsR::gtrends(
    keywords,
    gprop = product,
    geo = country,
    time = time
  )
  
  results <- trends$interest_over_time
}