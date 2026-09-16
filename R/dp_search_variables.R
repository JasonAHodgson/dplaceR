#' Search D-PLACE variables by keyword
#'
#' A thin, more discoverable wrapper around `dp_variables(search = keyword)`.
#'
#' @param keyword A search term matched (case-insensitively) against
#'   variable names and descriptions.
#' @param type Optional character vector restricting to variable type(s):
#'   `"Categorical"`, `"Ordinal"`, and/or `"Continuous"`. Does not support
#'   [contains()]. Passed straight to [dp_variables()].
#'
#' @return A tibble of matching variables (see [dplace_variables] for column
#'   definitions).
#'
#' @examples
#' dp_search_variables("marriage")
#' dp_search_variables("descent", type = "Categorical")
#'
#' @export
dp_search_variables <- function(keyword, type = NULL) {
  dp_variables(search = keyword, type = type)
}
