#' Look up codes for categorical/ordinal D-PLACE variables
#'
#' @param var_id Character vector of variable ID(s) to get codes for. Also
#'   accepts a data frame/tibble with a `var_id` column, from which the
#'   column is used automatically.
#'
#' @return A tibble of codes, ordered by `ord` within each variable (see
#'   [dplace_codes] for column definitions). Returns zero rows (with a
#'   warning) for variables that have no codes, e.g. continuous variables.
#'
#' @examples
#' dp_codes("B035")
#'
#' @export
dp_codes <- function(var_id) {
  var_id <- .gs_coerce_ids(var_id, "var_id", "var_id")
  out <- dplace_codes[dplace_codes$var_id %in% var_id, , drop = FALSE]

  missing_vars <- setdiff(var_id, out$var_id)
  if (length(missing_vars) > 0) {
    warning(
      "No codes found for variable(s): ", paste(missing_vars, collapse = ", "),
      ". They may be continuous variables, or not exist -- check dp_variables().",
      call. = FALSE
    )
  }

  out <- out[order(out$var_id, out$ord), , drop = FALSE]
  tibble::as_tibble(out)
}
