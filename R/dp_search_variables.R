#' Search D-PLACE variables by keyword
#'
#' A thin, more discoverable wrapper around `dp_variables(search = keyword)`.
#'
#' @param keyword A search term matched (case-insensitively) against
#'   variable names and descriptions.
#'
#' @return A tibble of matching variables (see [dplace_variables] for column
#'   definitions).
#'
#' @examples
#' dp_search_variables("marriage")
#'
#' @export
dp_search_variables <- function(keyword) {
  dp_variables(search = keyword)
}
