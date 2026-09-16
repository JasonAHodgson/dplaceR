#' Look up raw coded values
#'
#' Filter the long-format D-PLACE data table ([dplace_values]) by variable
#' and/or society. For an analysis-ready table that also joins in society
#' information and (for categorical/ordinal variables) code labels, use
#' [dp_variable_data()] instead.
#'
#' @param var_id Optional character vector of variable ID(s) to filter to.
#'   Also accepts a data frame/tibble with a `var_id` column, from which the
#'   column is used automatically.
#' @param soc_id Optional character vector of society ID(s) to filter to.
#'   Also accepts a data frame/tibble with a `soc_id` column, from which the
#'   column is used automatically.
#'
#' @return A tibble of values (see [dplace_values] for column definitions).
#'
#' @examples
#' dp_values(var_id = "EA202", soc_id = "Sa1")
#'
#' @export
dp_values <- function(var_id = NULL, soc_id = NULL) {
  var_id <- .gs_coerce_ids(var_id, "var_id", "var_id")
  soc_id <- .gs_coerce_ids(soc_id, "soc_id", "soc_id")

  out <- dplace_values

  if (!is.null(var_id)) {
    out <- out[out$var_id %in% var_id, , drop = FALSE]
  }
  if (!is.null(soc_id)) {
    out <- out[out$soc_id %in% soc_id, , drop = FALSE]
  }

  tibble::as_tibble(out)
}
