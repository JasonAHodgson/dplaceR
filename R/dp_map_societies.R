#' Plot societies on a world map
#'
#' Draws a world map (via ggplot2 and the 'maps' package's bundled
#' low-resolution world boundaries) with one point per society, optionally
#' coloured by another column -- e.g. a variable's coded value, or the
#' `geo_distance` column from [get_geo_distance()], the `cult_distance`
#' column from [get_cult_distance()], or an `n_match` column from either
#' (or their pairwise counterparts), after joining in coordinates with
#' [get_society_meta()] if needed.
#'
#' @param data Either a character vector of D-PLACE society IDs, or a data
#'   frame/tibble. If it doesn't already have `latitude`/`longitude`
#'   columns, it must have a `soc_id` column, which is used to look them up
#'   via [get_society_meta()]. Rows with missing coordinates are dropped
#'   with a warning.
#' @param color Optional; the name of a column in `data` to map to point
#'   colour (e.g. `"region"`, or a variable's value). Left plain (a single
#'   colour) if omitted.
#' @param label Logical; if `TRUE`, label each point with its `soc_id`
#'   (only if `data` has one). Default `FALSE`.
#' @param point_size Point size, passed to `ggplot2::geom_point()`. Default
#'   `2`.
#'
#' @return A `ggplot` object; print it to display, or add further
#'   `ggplot2` layers/theming to customize it.
#'
#' @examples
#' \dontrun{
#' dp_map_societies(c("B72", "B73", "B79"))
#' dp_map_societies(dp_societies(region = "Southern Africa"), color = "region")
#' }
#'
#' @export
dp_map_societies <- function(data, color = NULL, label = FALSE, point_size = 2) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop(
      "dp_map_societies() requires the 'ggplot2' package (and 'maps', for ",
      "the base map). Install them with ",
      "install.packages(c(\"ggplot2\", \"maps\")).", call. = FALSE
    )
  }
  if (!requireNamespace("maps", quietly = TRUE)) {
    stop(
      "dp_map_societies() requires the 'maps' package (used by ggplot2's ",
      "map_data() to draw the base map). Install it with ",
      "install.packages(\"maps\").", call. = FALSE
    )
  }

  if (is.character(data)) {
    data <- tibble::tibble(soc_id = data)
  }
  if (!is.data.frame(data)) {
    stop(
      "`data` must be a character vector of society IDs, or a data frame/tibble.",
      call. = FALSE
    )
  }
  data <- tibble::as_tibble(data)

  if (!all(c("latitude", "longitude") %in% names(data))) {
    if (!"soc_id" %in% names(data)) {
      stop(
        "`data` must contain `latitude`/`longitude` columns, or a `soc_id` ",
        "column to look them up.", call. = FALSE
      )
    }
    data <- get_society_meta(data, id_cols = "soc_id", latitude = TRUE, longitude = TRUE)
  }

  no_coords <- is.na(data$latitude) | is.na(data$longitude)
  if (any(no_coords)) {
    warning(sum(no_coords), " row(s) dropped: missing coordinates.", call. = FALSE)
    data <- data[!no_coords, , drop = FALSE]
  }
  if (nrow(data) < 1) {
    stop("No rows with valid coordinates to plot.", call. = FALSE)
  }

  world <- ggplot2::map_data("world")

  p <- ggplot2::ggplot() +
    ggplot2::geom_polygon(
      data = world,
      mapping = ggplot2::aes(x = long, y = lat, group = group),
      fill = "grey92", colour = "white", linewidth = 0.15
    ) +
    ggplot2::coord_quickmap() +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = NULL, y = NULL)

  if (!is.null(color)) {
    if (!color %in% names(data)) {
      stop("`color` column '", color, "' not found in `data`.", call. = FALSE)
    }
    data$.dp_color <- data[[color]]
    p <- p +
      ggplot2::geom_point(
        data = data,
        mapping = ggplot2::aes(x = longitude, y = latitude, colour = .dp_color),
        size = point_size
      ) +
      ggplot2::labs(colour = color)
  } else {
    p <- p + ggplot2::geom_point(
      data = data,
      mapping = ggplot2::aes(x = longitude, y = latitude),
      size = point_size, colour = "steelblue4"
    )
  }

  if (isTRUE(label) && "soc_id" %in% names(data)) {
    p <- p + ggplot2::geom_text(
      data = data,
      mapping = ggplot2::aes(x = longitude, y = latitude, label = soc_id),
      size = 2.5, vjust = -0.7, check_overlap = TRUE
    )
  }

  p
}
