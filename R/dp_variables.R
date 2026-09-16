#' Browse or filter D-PLACE cultural variables
#'
#' @param var_id Optional character vector of variable IDs to filter to.
#'   Also accepts a data frame/tibble with a `var_id` column (e.g. an
#'   earlier `dp_variables()` result passed straight through), from which
#'   the column is used automatically.
#' @param category Optional character vector of categories to filter to
#'   (matched exactly; see `unique(dplace_variables$category)` for valid
#'   values), or [contains()] for a partial/regex match. Many `category`
#'   values are several topics joined with `", "` (e.g.
#'   `"Economy, Property, Subsistence"`), so an exact match like
#'   `category = "Subsistence"` misses those -- use
#'   `category = contains("Subsistence")` instead to match any category
#'   string that mentions the term.
#' @param type Optional character vector restricting to variable type(s):
#'   `"Categorical"`, `"Ordinal"`, and/or `"Continuous"`. Does not support
#'   [contains()].
#' @param search Optional keyword. If given, only variables whose `name` or
#'   `description` contains this string (case-insensitive) are returned.
#'
#' @return A tibble of variables (see [dplace_variables] for column
#'   definitions).
#'
#' @examples
#' dp_variables(category = "Subsistence")
#' dp_variables(category = contains("Subsistence"))
#' dp_variables(search = "descent")
#'
#' @export
dp_variables <- function(var_id = NULL, category = NULL, type = NULL,
                          search = NULL) {
  .gs_reject_contains(type, "type", "it only accepts a fixed vocabulary of variable types")
  var_id <- .gs_coerce_ids(var_id, "var_id", "var_id")
  if (!is.null(var_id) && !is.character(var_id)) {
    stop(
      "`var_id` must be a character vector of variable IDs, or a data ",
      "frame/tibble with a `var_id` column, not a ", class(var_id)[1], ".",
      call. = FALSE
    )
  }

  out <- dplace_variables

  if (!is.null(var_id)) {
    out <- out[out$var_id %in% var_id, , drop = FALSE]
  }
  if (!is.null(category)) {
    out <- out[.gs_match_column(out$category, category, "category"), , drop = FALSE]
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
