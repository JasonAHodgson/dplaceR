#' Plot a coded variable on a map, one point per society
#'
#' A variable-aware companion to [dp_map_societies()]: given a chosen
#' subset of societies and a single D-PLACE variable, plots each society
#' on a world map coloured by its coded value for that variable -- e.g.
#' community marriage organization (`"B035"`) across a set of societies.
#' Where [dp_map_societies()] colours by any column you already have,
#' `plot_variable_map()` looks the variable's data up for you and handles
#' the details specific to D-PLACE's coded data: collapsing a society's
#' more than one recorded observation to a single value (as in
#' [get_society_data()]'s `format = "wide"`), excluding D-PLACE's
#' dedicated "no data" sentinel code from counting as a real observation
#' (as in [get_cult_distance()] and friends), and, for an `"Ordinal"`
#' variable, ordering the color scale by the codes' rank (`ord`, see
#' [dp_codes()]) rather than alphabetically.
#'
#' @param soc_id Character vector of D-PLACE society IDs to plot. Also
#'   accepts a data frame/tibble with a `soc_id` column, from which the
#'   column is used automatically.
#' @param var_id A single D-PLACE variable ID (see [dp_variables()] or
#'   [dp_search_variables()] to find one) -- one map, one variable; call
#'   this again for another.
#' @param drop_na Logical; societies in `soc_id` with no usable coded
#'   value for `var_id` (either genuinely uncoded, or only carrying
#'   D-PLACE's missing-data sentinel) are always identified, with a
#'   warning naming how many. If `TRUE` (the default), they're then
#'   dropped from the plot entirely; if `FALSE`, they're kept and shown as
#'   `NA` (grey, by ggplot2's default), which can itself be useful to see
#'   where your selection's coverage gaps are.
#' @param label Logical; if `TRUE`, label each point with its `soc_id`.
#'   Passed straight to [dp_map_societies()]. Default `FALSE`.
#' @param point_size Point size, passed to [dp_map_societies()] (and on to
#'   `ggplot2::geom_point()`). Default `2`.
#' @param zoom Logical; passed straight to [dp_map_societies()]. If `TRUE`
#'   (the default), the map is cropped to a padded bounding box around the
#'   plotted societies rather than always showing the whole world -- so a
#'   selection of societies all in, say, Madagascar produces a map of
#'   Madagascar rather than a world map with a tiny cluster of points.
#'   Set to `FALSE` to always show the whole world.
#'
#' @return A `ggplot` object; print it to display, or add further
#'   `ggplot2` layers/theming to customize it (e.g. a different colour
#'   scale via `+ ggplot2::scale_colour_manual(...)`).
#'
#' @examples
#' \dontrun{
#' plot_variable_map(dp_societies(region = "Southern Africa")$soc_id, "B035")
#' plot_variable_map(
#'   dp_societies(region = "Southern Africa")$soc_id, "B035", label = TRUE
#' )
#' }
#'
#' @export
plot_variable_map <- function(soc_id, var_id, drop_na = TRUE, label = FALSE,
                               point_size = 2, zoom = TRUE) {
  soc_id <- .gs_coerce_ids(soc_id, "soc_id", "soc_id")
  var_id <- .gs_coerce_ids(var_id, "var_id", "var_id")
  if (length(soc_id) < 1) {
    stop("`soc_id` must contain at least one society ID.", call. = FALSE)
  }
  if (length(var_id) != 1) {
    stop(
      "`var_id` must be a single variable ID -- plot_variable_map() maps one variable ",
      "at a time; call it again for another.",
      call. = FALSE
    )
  }
  soc_id <- unique(soc_id)

  soc <- dp_societies(soc_id = soc_id)
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

  var_meta <- dp_variables(var_id = var_id)
  if (nrow(var_meta) < 1) {
    stop("Variable '", var_id, "' not found; see dp_variables() to browse what's available.", call. = FALSE)
  }
  var_type <- var_meta$type

  vals <- dp_values(var_id = var_id, soc_id = soc_id)
  vals <- .cult_dist_drop_missing_sentinel(vals)
  vals <- .cult_dist_collapse_duplicates(vals)

  codes <- dplace_codes[dplace_codes$var_id == var_id, c("code_id", "name", "ord")]
  names(codes)[names(codes) == "name"] <- "code_label"

  vals <- merge(vals[, c("soc_id", "value", "code_id")], codes, by = "code_id", all.x = TRUE, sort = FALSE)

  soc_info <- soc[, c("soc_id", "name", "latitude", "longitude")]
  names(soc_info)[names(soc_info) == "name"] <- "society_name"
  out <- merge(soc_info, vals[, c("soc_id", "value", "code_label", "ord")], by = "soc_id", all.x = TRUE, sort = FALSE)

  is_continuous <- !is.na(var_type) && var_type == "Continuous"
  if (is_continuous) {
    out$.pvm_value <- suppressWarnings(as.numeric(out$value))
  } else {
    out$.pvm_value <- out$code_label
    if (!is.na(var_type) && var_type == "Ordinal") {
      # exclude the missing-data sentinel code from the level set itself --
      # not just from the data -- so it can't appear as a (nonsensical)
      # highest-ranked ordinal level
      codes_real <- codes[!.cult_dist_is_missing_sentinel(codes$code_id), , drop = FALSE]
      lvl <- unique(codes_real$code_label[order(codes_real$ord)])
      out$.pvm_value <- factor(out$.pvm_value, levels = lvl, ordered = TRUE)
    }
  }

  n_missing <- sum(is.na(out$.pvm_value))
  if (n_missing > 0) {
    if (isTRUE(drop_na)) {
      warning(
        n_missing, " society(ies) dropped: no usable coded value for '", var_id,
        "' (either uncoded, or only D-PLACE's missing-data sentinel). Pass ",
        "drop_na = FALSE to keep and show them as NA instead.",
        call. = FALSE
      )
      out <- out[!is.na(out$.pvm_value), , drop = FALSE]
    } else {
      warning(
        n_missing, " society(ies) have no usable coded value for '", var_id,
        "' and will show as NA on the map.",
        call. = FALSE
      )
    }
  }
  if (nrow(out) < 1) {
    stop("No societies with a usable coded value for '", var_id, "' remain to plot.", call. = FALSE)
  }

  out <- out[, c("soc_id", "society_name", "latitude", "longitude", ".pvm_value")]
  names(out)[names(out) == ".pvm_value"] <- var_id
  out <- tibble::as_tibble(out)

  p <- dp_map_societies(out, color = var_id, label = label, point_size = point_size, zoom = zoom)
  p + ggplot2::labs(colour = var_meta$name, title = var_meta$name)
}
