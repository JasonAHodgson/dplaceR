#' Browse or filter D-PLACE cultural variables
#'
#' @param var_id Optional character vector of variable IDs to filter to.
#' @param category Optional character vector of categories to filter to
#'   (matched exactly; see `unique(dplace_variables$category)` for valid
#'   values).
#' @param type Optional character vector restricting to variable type(s):
#'   `"Categorical"`, `"Ordinal"`, and/or `"Continuous"`.
#' @param search Optional keyword. If given, only variables whose `name` or
#'   `description` contains this string (case-insensitive) are returned.
#'
#' @return A tibble of variables (see [dplace_variables] for column
#'   definitions).
#'
#' @examples
#' dp_variables(category = "Subsistence")
#' dp_variables(search = "descent")
#'
#' @export
dp_variables <- function(var_id = NULL, category = NULL, type = NULL,
                          search = NULL) {
  out <- dplace_variables

  if (!is.null(var_id)) {
    out <- out[out$var_id %in% var_id, , drop = FALSE]
  }
  if (!is.null(category)) {
    out <- out[!is.na(out$category) & out$category %in% category, , drop = FALSE]
  }
  if (!is.null(type)) {
    out <- out[!is.na(out$type) & out$type %in% type, , drop = FALSE]
  }
  if (!is.null(search)) {
    hit <- grepl(search, out$name, ignore.case = TRUE) |
      (!is.na(out$description) & grepl(search, out$description, ignore.case = TRUE))
    out <- out[hit, , drop = FALSE]
  }

  tibble::as_tibble(out)
}
