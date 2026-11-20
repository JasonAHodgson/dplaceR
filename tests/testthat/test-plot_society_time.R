test_that("plot_society_time validates its input", {
  skip_if_not_installed("ggplot2")
  expect_error(plot_society_time(list(a = 1)), "must be a character vector")
  expect_error(
    plot_society_time(tibble::tibble(x = "B72")),
    "must contain a .main_focal_year. column"
  )
})

test_that("plot_society_time errors informatively without ggplot2", {
  skip_if(requireNamespace("ggplot2", quietly = TRUE),
          "ggplot2 is installed; this tests the absent-package path")
  expect_error(plot_society_time(c("B72", "B73")), "requires the")
})

test_that("plot_society_time accepts a plain soc_id vector and returns a ggplot", {
  skip_if_not_installed("ggplot2")
  p <- plot_society_time(c("B72", "B73", "B79"))
  expect_s3_class(p, "ggplot")
  expect_length(p$layers, 1)
  expect_s3_class(p$layers[[1]]$geom, "GeomPoint")
  d <- p$layers[[1]]$data
  expect_setequal(d$soc_id, c("B72", "B73", "B79"))
  expect_true(all(c("main_focal_year", ".pst_y") %in% names(d)))
})

test_that("plot_society_time accepts a soc_id-only tibble and looks up main_focal_year", {
  skip_if_not_installed("ggplot2")
  d <- tibble::tibble(soc_id = c("B72", "B73"))
  p <- plot_society_time(d)
  expect_s3_class(p, "ggplot")
  expect_equal(sort(p$layers[[1]]$data$main_focal_year), c(1910, 1950))
})

test_that("plot_society_time uses an existing main_focal_year column without a soc_id lookup", {
  skip_if_not_installed("ggplot2")
  d <- tibble::tibble(main_focal_year = c(1900, 1950))
  p <- plot_society_time(d)
  expect_s3_class(p, "ggplot")
})

test_that("plot_society_time drops rows with unknown main_focal_year, with a warning", {
  skip_if_not_installed("ggplot2")
  expect_warning(
    p <- plot_society_time(c("B72", "not-a-real-soc")),
    "unknown main_focal_year"
  )
  expect_equal(nrow(p$layers[[1]]$data), 1)
})

test_that("an unknown `color` column errors", {
  skip_if_not_installed("ggplot2")
  expect_error(
    plot_society_time(c("B72", "B73"), color = "not_a_column"),
    "not found in `data`"
  )
})

test_that("label = TRUE adds a text layer using soc_id", {
  skip_if_not_installed("ggplot2")
  p <- plot_society_time(c("B72", "B73"), label = TRUE)
  expect_length(p$layers, 2)
  expect_s3_class(p$layers[[2]]$geom, "GeomText")
})

test_that("jitter = TRUE (the default) is reproducible across calls, and jitter = FALSE puts every point on the axis", {
  skip_if_not_installed("ggplot2")
  p1 <- plot_society_time(c("B72", "B73", "B79"))
  p2 <- plot_society_time(c("B72", "B73", "B79"))
  y1 <- ggplot2::ggplot_build(p1)$data[[1]]$y
  y2 <- ggplot2::ggplot_build(p2)$data[[1]]$y
  expect_identical(y1, y2)
  expect_true(any(y1 != 0))

  p3 <- plot_society_time(c("B72", "B73", "B79"), jitter = FALSE)
  y3 <- ggplot2::ggplot_build(p3)$data[[1]]$y
  expect_true(all(y3 == 0))
})

test_that("plot_society_time colours by an arbitrary column", {
  skip_if_not_installed("ggplot2")
  d <- dp_societies(region = "Southern Africa")
  p <- plot_society_time(d, color = "lang_family")
  expect_true(".dp_color" %in% names(p$layers[[1]]$data))
  expect_equal(p$labels$colour, "lang_family")
})
