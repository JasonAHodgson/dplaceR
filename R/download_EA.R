#' Function to download EA D-PLACE data flat files and load it as a dataframe
#'
#' 
#'
#' @returns a dataframe object
#' @export


variables_url <- "https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/EA/variables.csv"
codes_url <- "https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/EA/codes.csv"
data_url <- "https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/EA/data.csv"
societies_url <- "https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/EA/societies.csv"

download_EA <- function(){
  data <- read.csv(data_url, header=TRUE)
}