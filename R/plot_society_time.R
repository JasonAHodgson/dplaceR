#' Plot societies through time, one point per society
#'
#' Plots each society along the x axis at its D-PLACE `main_focal_year` --
#' the (ethnographic) year the society's coded data mainly reflects (see
#' [dplace_societies]). Points are jittered vertically by default (the y
#' axis carries no meaning either way) purely so societies sharing a focal
#' year don't sit exactly on top of each other. Optionally coloured by any
#' column in `data`, e.g. `region` or `lang_family`, or -- via the
#' variable-aware [plot_variable_time()] -- a D-PLACE variable's coded
#' value.
#'
#' @param data Either a character vector of D-PLACE society IDs, or a data
#'   frame/tibble. If it doesn't already have a `main_focal_year` column,
#'   it must have a `soc_id` column, which is used to look it up via
#'   [get_society_meta()]. Rows with an unknown focal year are dropped
#'   with a warning.
#' @param color Optional; the name of a column in `data` to map to point
#'   colour (e.g. `"region"`, `"lang_family"`, or a variable's value).
#'   Left plain (a single colour) if omitted.
#' @param jitter Logical; if `TRUE` (the default), points are jittered
#'   vertically so societies sharing a focal year remain distinguishable.
#'   Set `FALSE` to plot them exactly on the axis line instead.
#' @param jitter_seed A random seed used only for the vertical jitter, so
#'   repeated calls on the same data produce the same layout. Default
#'   `42`; change it for a different (but still reproducible) layout.
#' @param label Logical; if `TRUE`, label each point with its `soc_id`
#'   (only if `data` has one). Default `FALSE`.
#' @param point_size Point size, passed to `ggplot2::geom_point()`.
#'   Default `2`.
#'
#' @return A `ggplot` object; print it to display, or add further
#'   `ggplot2` layers/theming to customize it.
#'
#' @examples
#' \dontrun{
#' plot_society_time(c("B72", "B73", "B79"))
#' plot_society_time(dp_societies(region = "Southern Africa"), color = "lang_family")
#' }
#'
#' @export
plot_society_time <- function(data, color = NULL, jitter = TRUE, jitter_seed = 42,
                               label = FALSE, point_size = 2) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop(
      "plot_society_time() requires the 'ggplot2' package. Install it with ",
      "install.packages(\"ggplot2\").", call. = FALSE
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

  if (!"main_focal_year" %in% names(data)) {
    if (!"soc_id" %in% names(data)) {
      stop(
        "`data` must contain a `main_focal_year` column, or a `soc_id` ",
        "column to look it up.", call. = FALSE
      )
    }
    data <- get_society_meta(data, id_cols = "soc_id", main_focal_year = TRUE)
  }

  no_year <- is.na(data$main_focal_year)
  if (any(no_year)) {
    warning(sum(no_year), " row(s) dropped: unknown main_focal_year.", call. = FALSE)
    data <- data[!no_year, , drop = FALSE]
  }
  if (nrow(data) < 1) {
    stop("No rows with a known main_focal_year to plot.", call. = FALSE)
  }

  data$.pst_y <- 0
  posn <- if (isTRUE(jitter)) {
    ggplot2::position_jitter(width = 0, height = 0.35, seed = jitter_seed)
  } else {
    ggplot2::position_identity()
  }

  p <- ggplot2::ggplot() +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = "Main focal year", y = NULL) +
    ggplot2::theme(
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank(),
      panel.grid.minor.y = ggplot2::element_blank()
    ) +
    ggplot2::coord_cartesian(ylim = c(-1, 1))

  if (!is.null(color)) {
    if (!color %in% names(data)) {
      stop("`color` column '", color, "' not found in `data`.", call. = FALSE)
    }
    data$.dp_color <- data[[color]]
    p <- p +
      ggplot2::geom_point(
        data = data,
        mapping = ggplot2::aes(x = main_focal_year, y = .pst_y, colour = .dp_color),
        size = point_size, position = posn
      ) +
      ggplot2::labs(colour = color)
  } else {
    p <- p + ggplot2::geom_point(
      data = data,
      mapping = ggplot2::aes(x = main_focal_year, y = .pst_y),
      size = point_size, colour = "steelblue4", position = posn
    )
  }

  if (isTRUE(label) && "soc_id" %in% names(data)) {
    p <- p + ggplot2::geom_text(
      data = data,
      mapping = ggplot2::aes(x = main_focal_year, y = .pst_y, label = soc_id),
      size = 2.5, vjust = -0.9, check_overlap = TRUE, position = posn
    )
  }

  p
}
