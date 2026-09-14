#' Build an analysis-ready table for one or more variables
#'
#' Joins the coded values for the given variable(s) to society information
#' (name, coordinates, glottocode) and, for categorical/ordinal variables,
#' to human-readable code labels.
#'
#' @param var_id Character vector of variable ID(s).
#' @param society_info Logical; if `TRUE` (the default), join in `name`,
#'   `latitude`, `longitude`, `glottocode`, and `region` from
#'   [dplace_societies].
#'
#' @return A tibble with one row per society/variable value, including:
#'   `soc_id`, `var_id`, `value` (raw), `code_id`, `code_label` (`NA` for
#'   continuous variables), `year`, `source`, and (if `society_info = TRUE`)
#'   `society_name`, `latitude`, `longitude`, `glottocode`, `region`.
#'
#' @examples
#' dp_variable_data("B035")
#'
#' @export
dp_variable_data <- function(var_id, society_info = TRUE) {
  vals <- dp_values(var_id = var_id)

  codes <- dplace_codes[, c("code_id", "var_id", "name")]
  names(codes)[names(codes) == "name"] <- "code_label"
  codes <- codes[, c("code_id", "code_label")]

  out <- merge(vals, codes, by = "code_id", all.x = TRUE, sort = FALSE)

  if (isTRUE(society_info)) {
    soc <- dplace_societies[, c("soc_id", "name", "latitude", "longitude",
                                 "glottocode", "region")]
    names(soc)[names(soc) == "name"] <- "society_name"
    out <- merge(out, soc, by = "soc_id", all.x = TRUE, sort = FALSE)
  }

  out <- out[, c(
    "soc_id", "var_id", "value", "code_id", "code_label", "year", "source",
    setdiff(names(out), c("soc_id", "var_id", "value", "code_id", "code_label",
                           "year", "source", "id", "admin_comment"))
  )]

  tibble::as_tibble(out)
}
