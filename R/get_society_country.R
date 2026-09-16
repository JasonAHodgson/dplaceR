#' Look up a society's country from its coordinates
#'
#' Reverse-geocodes each society's recorded coordinates to a country name,
#' using the 'maps' package's bundled low-resolution world map
#' (`maps::map.where()`). D-PLACE itself doesn't record country -- only
#' world region ([dp_societies()]'s `region` column, which spans multiple
#' countries), coordinates, and language codes -- so this fills that gap.
#'
#' @details
#' Because the underlying map is low-resolution, a society very close to a
#' border, coastline, or a small/disputed territory can resolve to the
#' wrong country, to a compound name like `"UK:Great Britain"` (the part
#' before the colon is used as `country`; a few small overseas territories
#' or exclaves are named this way in the 'maps' world database), or to
#' nothing at all (`NA`, with a warning) if the point falls just outside
#' every mapped polygon (common just offshore). Treat the result as a
#' convenient approximation, not authoritative for borderline cases.
#'
#' @param soc_id Character vector of one or more D-PLACE society IDs (see
#'   [dp_societies()]). Also accepts a data frame/tibble with a `soc_id`
#'   column, from which the column is used automatically. Unknown IDs, and
#'   societies with missing coordinates, are dropped with a warning.
#'
#' @return A tibble with one row per society: `soc_id` and `country`
#'   (character; `NA` where the coordinates didn't resolve to any mapped
#'   country).
#'
#' @examples
#' \dontrun{
#' get_society_country(c("B72", "CCMCamha1245"))
#' }
#'
#' @export
get_society_country <- function(soc_id) {
  soc_id <- .gs_coerce_ids(soc_id, "soc_id", "soc_id")
  if (length(soc_id) < 1) {
    stop("`soc_id` must contain at least one society ID.", call. = FALSE)
  }

  if (!requireNamespace("maps", quietly = TRUE)) {
    stop(
      "get_society_country() requires the 'maps' package. Install it with ",
      "install.packages(\"maps\").", call. = FALSE
    )
  }

  soc <- dp_societies(soc_id = soc_id, type = NULL)
  missing_ids <- setdiff(soc_id, soc$soc_id)
  if (length(missing_ids) > 0) {
    warning(
      "Society ID(s) not found, dropped: ", paste(missing_ids, collapse = ", "),
      call. = FALSE
    )
  }
  no_coords <- is.na(soc$latitude) | is.na(soc$longitude)
  if (any(no_coords)) {
    warning(
      "Dropping society(ies) with missing coordinates: ",
      paste(soc$soc_id[no_coords], collapse = ", "), call. = FALSE
    )
    soc <- soc[!no_coords, , drop = FALSE]
  }
  if (nrow(soc) < 1) {
    stop("No societies with valid coordinates were found.", call. = FALSE)
  }

  raw <- maps::map.where(database = "world", x = soc$longitude, y = soc$latitude)
  country <- sub(":.*$", "", raw)

  unresolved <- is.na(raw)
  if (any(unresolved)) {
    warning(
      sum(unresolved), " society(ies) did not resolve to a country (may be ",
      "at sea, or too close to a coastline for this map's resolution): ",
      paste(soc$soc_id[unresolved], collapse = ", "), call. = FALSE
    )
  }

  tibble::tibble(soc_id = soc$soc_id, country = country)
}
