#' Append D-PLACE society metadata to a tibble
#'
#' Looks up one or more D-PLACE society ID columns in `data` against
#' [dplace_societies] and appends the requested metadata column(s), in
#' `data`'s original row order. Designed to enrich the output of this
#' package's other functions (e.g. [get_geo_distance()],
#' [get_pairwise_cult_distance()]) with society details like name or region,
#' without having to look them up separately.
#'
#' @details
#' Each metadata column is its own logical argument (default `FALSE`), so
#' you only get the columns you ask for -- see [dplace_societies] for what
#' each one means.
#'
#' `data` may have one society ID column (e.g. `soc_id`, as in
#' [get_geo_distance()]'s or [get_cult_distance()]'s output) or two (e.g.
#' `soc_id_1`/`soc_id_2`, as in [get_pairwise_geo_distance()]'s or
#' [get_pairwise_cult_distance()]'s output) -- by default, `get_society_meta()`
#' looks for columns named `soc_id`, `soc_id_1`, and/or `soc_id_2` and
#' appends metadata for each one it finds, suffixed to match (`name` for
#' `soc_id`, `name_1`/`name_2` for `soc_id_1`/`soc_id_2`). Use `id_cols` to
#' specify different column name(s) instead; appended columns are then
#' suffixed with `_<id_col>`.
#'
#' Society IDs in `data` that aren't found in [dplace_societies] get `NA`
#' for the appended metadata, with a warning; appending a column that would
#' overwrite one already in `data` also warns.
#'
#' @param data A data frame or tibble containing one or more society ID
#'   column(s).
#' @param id_cols Optional character vector naming the society ID column(s)
#'   in `data` to look up. If omitted, any of `soc_id`, `soc_id_1`, and
#'   `soc_id_2` present in `data` are used automatically.
#' @param name,latitude,longitude,glottocode,iso_code,region,type,main_focal_year,language_level_glottocodes,contribution_id
#'   Logical; append this column of [dplace_societies]? Default `FALSE` for
#'   all.
#'
#' @return `data` as a tibble, with the requested metadata column(s)
#'   appended (one set per matched ID column, suffixed as described in
#'   Details). Returned unchanged (with a message) if no metadata column is
#'   requested.
#'
#' @examples
#' \dontrun{
#' geo <- get_geo_distance("B72", c("B73", "B79"))
#' get_society_meta(geo, name = TRUE, region = TRUE)
#'
#' pw <- get_pairwise_geo_distance(c("B72", "B73", "B79"))
#' get_society_meta(pw, name = TRUE)
#' }
#'
#' @export
get_society_meta <- function(data, id_cols = NULL,
                              name = FALSE, latitude = FALSE, longitude = FALSE,
                              glottocode = FALSE, iso_code = FALSE, region = FALSE,
                              type = FALSE, main_focal_year = FALSE,
                              language_level_glottocodes = FALSE,
                              contribution_id = FALSE) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame or tibble.", call. = FALSE)
  }

  requested_flags <- c(
    name = name, latitude = latitude, longitude = longitude,
    glottocode = glottocode, iso_code = iso_code, region = region,
    type = type, main_focal_year = main_focal_year,
    language_level_glottocodes = language_level_glottocodes,
    contribution_id = contribution_id
  )
  requested <- names(requested_flags)[requested_flags]

  out <- tibble::as_tibble(data)

  if (length(requested) == 0) {
    message(
      "No metadata columns selected (all arguments are FALSE); returning ",
      "`data` unchanged."
    )
    return(out)
  }

  if (is.null(id_cols)) {
    id_cols <- intersect(c("soc_id", "soc_id_1", "soc_id_2"), names(data))
    if (length(id_cols) == 0) {
      stop(
        "Could not find a society ID column in `data` (looked for `soc_id`, ",
        "`soc_id_1`, `soc_id_2`). Specify `id_cols` explicitly.", call. = FALSE
      )
    }
  } else {
    unknown_cols <- setdiff(id_cols, names(data))
    if (length(unknown_cols) > 0) {
      stop(
        "`id_cols` not found in `data`: ", paste(unknown_cols, collapse = ", "),
        call. = FALSE
      )
    }
  }

  original_names <- names(data)

  for (id_col in id_cols) {
    if (id_col == "soc_id") {
      suffix <- ""
    } else if (grepl("^soc_id", id_col)) {
      suffix <- sub("^soc_id", "", id_col)
    } else {
      suffix <- paste0("_", id_col)
    }

    idx <- match(out[[id_col]], dplace_societies$soc_id)
    n_missing <- sum(is.na(idx) & !is.na(out[[id_col]]))
    if (n_missing > 0) {
      warning(
        n_missing, " value(s) in `", id_col, "` did not match a known ",
        "society ID; their metadata will be NA.", call. = FALSE
      )
    }

    for (col in requested) {
      new_col <- paste0(col, suffix)
      if (new_col %in% original_names) {
        warning(
          "Column '", new_col, "' already exists in `data` and will be ",
          "overwritten.", call. = FALSE
        )
      }
      out[[new_col]] <- dplace_societies[[col]][idx]
    }
  }

  out
}
