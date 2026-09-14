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
