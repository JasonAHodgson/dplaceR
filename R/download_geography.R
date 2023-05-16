#' Function to download D-PLACE geography data flat files and load it as a dataframe
#'
#' 
#'
#' @returns a dataframe object
#' @export


elevation_data_url <- "https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/GMTED2010/data.csv"
elevation_variables_url <- "https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/GMTED2010/variables.csv"
dist_to_coast_data_url <- "https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/GSHHS/data.csv"
dist_to_coast_variables_url <- "https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/GSHHS/variables.csv"

download_geography <- function() {
  elevation_data <- read.csv(elevation_data_url, header=TRUE)
  return(elevation_data)
}