#' See which cultural variables have data for a given set of societies
#'
#' Answers "what can I actually do with these societies?": for a chosen
#' subset of societies, returns one row per D-PLACE variable with how many
#' of them have a genuinely coded (non-missing) observation for it. Unlike
#' [dp_variables()] (which browses the full variable catalogue regardless
#' of coverage) or [dp_values()]/[get_society_data()] (which return raw
#' observations, one row per society/variable pair, with no summary), this
#' rolls coverage up to one row per variable so you can see at a glance
#' which variables are well populated for your specific societies and
#' which are mostly empty -- e.g. before choosing which to pass to
#' [get_cult_distance()]/[get_pairwise_cult_distance()]/
#' [get_cultural_FST()].
#'
#' As in [get_cult_distance()] and friends, D-PLACE's dedicated "no data"
#' sentinel code for categorical/ordinal variables (e.g. `"B017-NA"` for
#' variable `B017`) is not counted as a real observation -- a society
#' explicitly coded "missing" does not count towards `n_coded`.
#'
#' @param soc_id Character vector of D-PLACE society IDs to check coverage
#'   for. Also accepts a data frame/tibble with a `soc_id` column, from
#'   which the column is used automatically.
#' @param var_id,category,type,search Optional filters narrowing which
#'   variables to report on, passed straight to [dp_variables()] (see its
#'   documentation) and combined with AND. Unlike
#'   [get_cult_distance()]/[get_pairwise_cult_distance()]/
#'   [get_cultural_FST()], none is required here -- with all four left
#'   `NULL` (the default), every variable in the catalogue is reported on,
#'   which is the point of an exploratory coverage check.
#' @param min_pct Only return variables with at least this percentage of
#'   `soc_id` coded (`0`-`100`). Default `0` (no filtering -- includes
#'   variables with zero coverage for this subset, which is itself useful
#'   to know).
#'
#' @return A tibble with one row per matching variable, sorted by
#'   decreasing coverage: `var_id`, `name`, `category`, `type`, `n_coded`
#'   (how many of `soc_id` have a coded observation), `n_total` (the
#'   number of valid `soc_id` checked), and `pct_coded`.
#'
#' @examples
#' \dontrun{
#' get_variable_coverage(dp_societies(region = "Southern Africa")$soc_id)
#' get_variable_coverage(
#'   dp_societies(region = "Southern Africa")$soc_id,
#'   category = contains("Subsistence"), min_pct = 80
#' )
#' }
#'
#' @export
get_variable_coverage <- function(soc_id, var_id = NULL, category = NULL,
                                   type = NULL, search = NULL, min_pct = 0) {
  soc_id <- .gs_coerce_ids(soc_id, "soc_id", "soc_id")
  if (length(soc_id) < 1) {
    stop("`soc_id` must contain at least one society ID.", call. = FALSE)
  }
  soc_id <- unique(soc_id)
  if (!is.numeric(min_pct) || length(min_pct) != 1 || is.na(min_pct) ||
        min_pct < 0 || min_pct > 100) {
    stop("`min_pct` must be a single number between 0 and 100.", call. = FALSE)
  }

  soc <- dp_societies(soc_id = soc_id, type = NULL)
  missing_soc <- setdiff(soc_id, soc$soc_id)
  if (length(missing_soc) > 0) {
    warning(
      "Society ID(s) not found, dropped: ", paste(missing_soc, collapse = ", "),
      call. = FALSE
    )
  }
  soc_id <- soc$soc_id
  if (length(soc_id) < 1) {
    stop("None of the requested society IDs were found.", call. = FALSE)
  }

  vars <- dp_variables(var_id = var_id, category = category, type = type, search = search)
  if (!is.null(var_id)) {
    missing_var <- setdiff(var_id, vars$var_id)
    if (length(missing_var) > 0) {
      warning(
        "Variable ID(s) not found, dropped: ", paste(missing_var, collapse = ", "),
        call. = FALSE
      )
    }
  }
  if (nrow(vars) < 1) {
    stop("No variables matched the given var_id/category/type/search filters.", call. = FALSE)
  }

  vals <- dp_values(var_id = vars$var_id, soc_id = soc_id)
  vals <- .cult_dist_drop_missing_sentinel(vals)

  n_total <- length(soc_id)
  n_coded_by_var <- tapply(vals$soc_id, vals$var_id, function(x) length(unique(x)))

  out <- vars[, c("var_id", "name", "category", "type")]
  out$n_coded <- as.integer(n_coded_by_var[out$var_id])
  out$n_coded[is.na(out$n_coded)] <- 0L
  out$n_total <- n_total
  out$pct_coded <- round(100 * out$n_coded / n_total, 1)

  out <- out[out$pct_coded >= min_pct, , drop = FALSE]
  out <- out[order(-out$pct_coded, out$var_id), , drop = FALSE]
  rownames(out) <- NULL

  tibble::as_tibble(out)
}
