#' Function to download Binford D-PLACE data flat files and load it as a dataframe
#'
#' 
#'
#' @returns a dataframe object
#' @export


variables_url <- "https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/Binford/variables.csv"
codes_url <- "https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/Binford/codes.csv"
societies_url <- "https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/Binford/societies.csv"
data_url <- "https://raw.githubusercontent.com/D-PLACE/dplace-data/master/datasets/Binford/data.csv"

download_Binford <- function(){
  data <- read.csv(data_url, header=TRUE)
}