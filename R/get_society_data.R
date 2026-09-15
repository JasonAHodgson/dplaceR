#' Search and assemble a table of societies' cultural measurements
#'
#' The variable-selection counterpart to [get_society_meta()] (which adds
#' society metadata to a table you already have): this builds a table of
#' D-PLACE's coded cultural data for a chosen set of societies and a chosen
#' set of variables -- named explicitly with `var_id`, or found by
#' searching with `category`, `type`, and/or `search` (all passed straight
#' to [dp_variables()] and combined with AND, like there). At least one of
#' `var_id`, `category`, `type`, or `search` must be supplied, so you don't
#' accidentally build a table across all several thousand bundled
#' variables -- use [dp_variables()] or [dp_search_variables()] to see
#' what's available first.
#'
#' @details
#' # Output shape (`format`)
#' \describe{
#'   \item{`"long"` (default)}{One row per society/variable *observation*
#'     -- the same shape as [dp_variable_data()], with variable metadata
#'     (`var_name`, `var_category`, `var_type`) added so search results are
#'     self-describing. Every recorded observation is kept, including more
#'     than one per society/variable where D-PLACE has them (see
#'     [dp_values()]).}
#'   \item{`"wide"`}{One row per society, one column per variable (named by
#'     `var_id`) -- ready to use directly as a data frame for analysis.
#'     Where a society has more than one recorded observation for a
#'     variable, the most recent one (by `year`, or the first recorded if
#'     tied/unknown) is kept, with a warning -- see [dp_values()] yourself
#'     for full control over this. A `"Continuous"` variable's column is
#'     numeric; `"Categorical"`/`"Ordinal"` columns hold the human-readable
#'     code label (see [dp_codes()]) rather than the raw code_id.}
#' }
#'
#' @param soc_id Optional character vector of society ID(s) to include (see
#'   [dp_societies()]). Defaults to every society with coded cultural data
#'   (`type = "society"`).
#' @param var_id,category,type,search Optional variable-selection criteria,
#'   passed straight to [dp_variables()] and combined with AND -- see its
#'   documentation for what each means (including [contains()] support for
#'   `category`). At least one must be supplied.
#' @param format One of `"long"` (default) or `"wide"` -- see Details.
#' @param society_info Logical; if `TRUE` (the default), join in society
#'   `name` (as `society_name`), `latitude`, `longitude`, `glottocode`, and
#'   `region`.
#'
#' @return A tibble -- see Details for the two possible shapes.
#'
#' @examples
#' \dontrun{
#' get_society_data(soc_id = c("B72", "B73"), var_id = c("B001", "B004"))
#' get_society_data(category = contains("Subsistence"), format = "wide")
#' get_society_data(search = "descent", type = "Categorical")
#' }
#'
#' @export
get_society_data <- function(soc_id = NULL, var_id = NULL, category = NULL,
                              type = NULL, search = NULL,
                              format = c("long", "wide"),
                              society_info = TRUE) {
  format <- match.arg(format)

  if (is.null(var_id) && is.null(category) && is.null(type) && is.null(search)) {
    stop(
      "Supply at least one of `var_id`, `category`, `type`, or `search` to ",
      "select which variables to include -- see dp_variables() or ",
      "dp_search_variables() to browse what's available first.", call. = FALSE
    )
  }

  vars <- dp_variables(var_id = var_id, category = category, type = type, search = search)
  if (is.character(var_id)) {
    missing_var <- setdiff(var_id, vars$var_id)
    if (length(missing_var) > 0) {
      warning(
        "var_id value(s) not present in the matched variable set: ",
        paste(missing_var, collapse = ", "), call. = FALSE
      )
    }
  }
  if (nrow(vars) < 1) {
    stop("No variables matched the given criteria.", call. = FALSE)
  }

  soc <- dp_societies(soc_id = soc_id)
  if (is.character(soc_id)) {
    missing_soc <- setdiff(soc_id, soc$soc_id)
    if (length(missing_soc) > 0) {
      warning(
        "soc_id value(s) not found: ", paste(missing_soc, collapse = ", "),
        call. = FALSE
      )
    }
  }
  if (nrow(soc) < 1) {
    stop("No societies matched `soc_id`.", call. = FALSE)
  }

  vals <- dp_values(var_id = vars$var_id, soc_id = soc$soc_id)

  codes <- dplace_codes[, c("code_id", "name")]
  names(codes)[names(codes) == "name"] <- "code_label"
  vals <- merge(vals, codes, by = "code_id", all.x = TRUE, sort = FALSE)

  var_meta <- vars[, c("var_id", "name", "category", "type")]
  names(var_meta) <- c("var_id", "var_name", "var_category", "var_type")
  vals <- merge(vals, var_meta, by = "var_id", all.x = TRUE, sort = FALSE)

  if (format == "long") {
    out <- vals[, c(
      "soc_id", "var_id", "var_name", "var_category", "var_type",
      "value", "code_id", "code_label", "year", "source"
    )]
    if (isTRUE(society_info)) {
      soc_info <- soc[, c("soc_id", "name", "latitude", "longitude", "glottocode", "region")]
      names(soc_info)[names(soc_info) == "name"] <- "society_name"
      out <- merge(out, soc_info, by = "soc_id", all.x = TRUE, sort = FALSE)
    }
    return(tibble::as_tibble(out))
  }

  # format == "wide" -- a society may have more than one recorded
  # observation for a variable; collapse to one before pivoting.
  vals <- .cult_dist_collapse_duplicates(vals)

  var_ids <- vars$var_id
  soc_ids <- soc$soc_id
  is_continuous <- stats::setNames(!is.na(vars$type) & vars$type == "Continuous", vars$var_id)

  wide <- matrix(
    NA_character_, nrow = length(soc_ids), ncol = length(var_ids),
    dimnames = list(soc_ids, var_ids)
  )
  if (nrow(vals) > 0) {
    idx <- cbind(match(vals$soc_id, soc_ids), match(vals$var_id, var_ids))
    wide[idx] <- ifelse(is_continuous[vals$var_id], vals$value, vals$code_label)
  }

  out <- tibble::tibble(soc_id = soc_ids)
  if (isTRUE(society_info)) {
    idx <- match(soc_ids, soc$soc_id)
    out$society_name <- soc$name[idx]
    out$latitude <- soc$latitude[idx]
    out$longitude <- soc$longitude[idx]
    out$glottocode <- soc$glottocode[idx]
    out$region <- soc$region[idx]
  }
  for (v in var_ids) {
    col <- unname(wide[, v])
    if (isTRUE(is_continuous[[v]])) {
      col <- suppressWarnings(as.numeric(col))
    }
    out[[v]] <- col
  }

  out
}
