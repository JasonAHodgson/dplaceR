# Fixtures (same as test-plot_variable_map.R, checked against
# dplace_values/dplace_codes directly):
# soc_id = B72, B73, B79, B100, B101
#   B035 (Categorical, "Community marriage organization"): all 5 have a
#     real, non-sentinel value -- no missing data at all.
#   B017 (Categorical, "Domestic organization"): only B72 has a real value
#     ("Small extended"); B73/B79/B100/B101 all carry the missing-data
#     sentinel (code_id "B017-NA") instead.
#   B033 (Ordinal, "Use of money", levels Absent < Rarely used < Commonly
#     used < Many convertible items, plus an unused "Missing data"
#     sentinel at ord = 99): all 5 are coded "Absent".
#   B001 (Continuous, "Subsistence economy: Gathering"): all 5 have a
#     numeric value (B72/B73 = 67, B79 = 70, B100/B101 = 60).
# main_focal_year (checked against dplace_societies directly): B72 = 1950,
# B73 = 1910, B79 = 1970, B100 = 1930, B101 = 1934 -- all known.

fixture_soc <- c("B72", "B73", "B79", "B100", "B101")

point_layer_data <- function(p) {
  for (l in p$layers) {
    if (inherits(l$geom, "GeomPoint")) return(l$data)
  }
  NULL
}

test_that("plot_variable_time plots a categorical variable with full coverage", {
  p <- plot_variable_time(fixture_soc, "B035")
  expect_s3_class(p, "ggplot")
  d <- point_layer_data(p)
  expect_equal(nrow(d), 5)
  expect_setequal(d$soc_id, fixture_soc)
  expect_true("main_focal_year" %in% names(d))
  expect_equal(p$labels$colour, "Community marriage organization")
})

test_that("plot_variable_time excludes the missing-data sentinel, dropping societies that only have it (drop_na = TRUE, the default)", {
  expect_warning(
    p <- plot_variable_time(fixture_soc, "B017"),
    "4 society\\(ies\\) dropped"
  )
  d <- point_layer_data(p)
  expect_equal(d$soc_id, "B72")
})

test_that("plot_variable_time's drop_na = FALSE keeps sentinel-only societies as NA instead", {
  expect_warning(
    p <- plot_variable_time(fixture_soc, "B017", drop_na = FALSE),
    "4 society\\(ies\\) have no usable coded value"
  )
  d <- point_layer_data(p)
  expect_equal(nrow(d), 5)
  expect_equal(d$B017[d$soc_id == "B72"], "Small extended")
  expect_true(all(is.na(d$B017[d$soc_id != "B72"])))
})

test_that("plot_variable_time errors when every society lacks a usable value", {
  expect_error(
    suppressWarnings(plot_variable_time(setdiff(fixture_soc, "B72"), "B017")),
    "No societies with a usable coded value"
  )
})

test_that("plot_variable_time orders an Ordinal variable's colour scale by ord, excluding the sentinel level", {
  p <- plot_variable_time(fixture_soc, "B033")
  d <- point_layer_data(p)
  expect_true(is.ordered(d$B033))
  expect_equal(
    levels(d$B033),
    c("Absent", "Rarely used", "Commonly used", "Many convertible items")
  )
  expect_false("Missing data" %in% levels(d$B033))
})

test_that("plot_variable_time coerces a Continuous variable to numeric", {
  p <- plot_variable_time(fixture_soc, "B001")
  d <- point_layer_data(p)
  expect_true(is.numeric(d$B001))
  expect_equal(d$B001[d$soc_id == "B79"], 70)
})

test_that("plot_variable_time requires a single var_id", {
  expect_error(
    plot_variable_time(fixture_soc, c("B001", "B004")),
    "must be a single variable ID"
  )
})

test_that("plot_variable_time errors on an unknown var_id", {
  expect_error(plot_variable_time(fixture_soc, "not-a-real-var"), "not found")
})

test_that("plot_variable_time validates soc_id", {
  expect_error(plot_variable_time(character(0), "B001"), "at least one society")
  expect_error(
    plot_variable_time("not-a-real-soc-id", "B001"),
    "None of the requested society IDs were found"
  )
})

test_that("plot_variable_time drops unknown society IDs with a warning", {
  expect_warning(
    p <- plot_variable_time(c(fixture_soc, "not-a-real-soc-id"), "B001"),
    "Society ID\\(s\\) not found, dropped: not-a-real-soc-id"
  )
  expect_equal(nrow(point_layer_data(p)), 5)
})

test_that("plot_variable_time's label argument is passed through to plot_society_time", {
  p_labelled <- plot_variable_time(fixture_soc, "B001", label = TRUE)
  p_unlabelled <- plot_variable_time(fixture_soc, "B001", label = FALSE)
  expect_equal(length(p_labelled$layers), length(p_unlabelled$layers) + 1)
})

test_that("plot_variable_time's jitter argument is passed through to plot_society_time", {
  p_jittered <- plot_variable_time(fixture_soc, "B001")
  p_flat <- plot_variable_time(fixture_soc, "B001", jitter = FALSE)
  y_jittered <- ggplot2::ggplot_build(p_jittered)$data[[1]]$y
  y_flat <- ggplot2::ggplot_build(p_flat)$data[[1]]$y
  expect_true(any(y_jittered != 0))
  expect_true(all(y_flat == 0))
})
