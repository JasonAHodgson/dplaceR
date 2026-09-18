test_that("dp_map_societies validates its input", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("maps")
  expect_error(dp_map_societies(list(a = 1)), "must be a character vector")
  expect_error(
    dp_map_societies(tibble::tibble(x = "B72")),
    "must contain .latitude./.longitude. columns"
  )
})

test_that("dp_map_societies errors informatively without ggplot2/maps", {
  skip_if(requireNamespace("ggplot2", quietly = TRUE) &&
            requireNamespace("maps", quietly = TRUE),
          "both are installed; this tests the absent-package path")
  expect_error(dp_map_societies(c("B72", "B73")), "requires the")
})

test_that("dp_map_societies accepts a plain soc_id vector and returns a ggplot", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("maps")
  p <- dp_map_societies(c("B72", "B73", "B79"))
  expect_s3_class(p, "ggplot")
  # one polygon layer (the base map) + one point layer
  expect_length(p$layers, 2)
  expect_s3_class(p$layers[[2]]$geom, "GeomPoint")
})

test_that("dp_map_societies accepts a soc_id-only tibble and looks up coordinates", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("maps")
  d <- tibble::tibble(soc_id = c("B72", "B73"), distance_km = c(0, 42))
  p <- dp_map_societies(d, color = "distance_km")
  expect_s3_class(p, "ggplot")
  expect_true(".dp_color" %in% names(p$layers[[2]]$data))
})

test_that("dp_map_societies uses existing latitude/longitude columns without a soc_id lookup", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("maps")
  d <- tibble::tibble(latitude = -20, longitude = 21.2)
  p <- dp_map_societies(d)
  expect_s3_class(p, "ggplot")
})

test_that("dp_map_societies drops rows with missing coordinates, with a warning", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("maps")
  expect_warning(
    p <- dp_map_societies(c("B72", "not-a-real-soc")),
    "missing coordinates"
  )
  expect_equal(nrow(p$layers[[2]]$data), 1)
})

test_that("an unknown `color` column errors", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("maps")
  expect_error(
    dp_map_societies(c("B72", "B73"), color = "not_a_column"),
    "not found in `data`"
  )
})

test_that("label = TRUE adds a text layer using soc_id", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("maps")
  p <- dp_map_societies(c("B72", "B73"), label = TRUE)
  expect_length(p$layers, 3)
  expect_s3_class(p$layers[[3]]$geom, "GeomText")
})

test_that("zoom = TRUE (the default) crops the map to a padded box around the points", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("maps")
  p <- dp_map_societies(c("B72", "B73", "B79"))
  d <- p$layers[[2]]$data
  xlim <- p$coordinates$limits$x
  ylim <- p$coordinates$limits$y
  expect_false(is.null(xlim))
  expect_false(is.null(ylim))
  # the box must contain every point...
  expect_true(all(d$longitude >= xlim[1] & d$longitude <= xlim[2]))
  expect_true(all(d$latitude >= ylim[1] & d$latitude <= ylim[2]))
  # ...but not be the whole world
  expect_lt(diff(xlim), 360)
  expect_lt(diff(ylim), 180)
})

test_that("zoom = FALSE preserves the old whole-world behaviour", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("maps")
  p <- dp_map_societies(c("B72", "B73", "B79"), zoom = FALSE)
  expect_null(p$coordinates$limits$x)
  expect_null(p$coordinates$limits$y)
})

test_that("zoom still produces a sensible (non-degenerate) box for a single point", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("maps")
  d <- tibble::tibble(latitude = -20, longitude = 21.2)
  p <- dp_map_societies(d)
  xlim <- p$coordinates$limits$x
  ylim <- p$coordinates$limits$y
  expect_gt(diff(xlim), 0)
  expect_gt(diff(ylim), 0)
  expect_true(21.2 > xlim[1] && 21.2 < xlim[2])
  expect_true(-20 > ylim[1] && -20 < ylim[2])
})

test_that("zoom clips a box near the poles/edges to valid lon/lat bounds", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("maps")
  d <- tibble::tibble(latitude = c(-89, 89), longitude = c(-179, 179))
  p <- dp_map_societies(d)
  xlim <- p$coordinates$limits$x
  ylim <- p$coordinates$limits$y
  expect_gte(xlim[1], -180)
  expect_lte(xlim[2], 180)
  expect_gte(ylim[1], -90)
  expect_lte(ylim[2], 90)
})
