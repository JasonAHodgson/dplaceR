# Fixtures (checked against dplace_values/dplace_codes directly):
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

fixture_soc <- c("B72", "B73", "B79", "B100", "B101")

point_layer_data <- function(p) {
  for (l in p$layers) {
    if (inherits(l$geom, "GeomPoint")) return(l$data)
  }
  NULL
}

test_that("plot_variable_map plots a categorical variable with full coverage", {
  p <- plot_variable_map(fixture_soc, "B035")
  expect_s3_class(p, "ggplot")
  d <- point_layer_data(p)
  expect_equal(nrow(d), 5)
  expect_setequal(d$soc_id, fixture_soc)
  expect_equal(p$labels$colour, "Community marriage organization")
})

test_that("plot_variable_map excludes the missing-data sentinel, dropping societies that only have it (drop_na = TRUE, the default)", {
  expect_warning(
    p <- plot_variable_map(fixture_soc, "B017"),
    "4 society\\(ies\\) dropped"
  )
  d <- point_layer_data(p)
  expect_equal(d$soc_id, "B72")
})

test_that("plot_variable_map's drop_na = FALSE keeps sentinel-only societies as NA instead", {
  expect_warning(
    p <- plot_variable_map(fixture_soc, "B017", drop_na = FALSE),
    "4 society\\(ies\\) have no usable coded value"
  )
  d <- point_layer_data(p)
  expect_equal(nrow(d), 5)
  expect_equal(d$B017[d$soc_id == "B72"], "Small extended")
  expect_true(all(is.na(d$B017[d$soc_id != "B72"])))
})

test_that("plot_variable_map errors when every society lacks a usable value", {
  expect_error(
    suppressWarnings(plot_variable_map(setdiff(fixture_soc, "B72"), "B017")),
    "No societies with a usable coded value"
  )
})

test_that("plot_variable_map orders an Ordinal variable's colour scale by ord, excluding the sentinel level", {
  p <- plot_variable_map(fixture_soc, "B033")
  d <- point_layer_data(p)
  expect_true(is.ordered(d$B033))
  expect_equal(
    levels(d$B033),
    c("Absent", "Rarely used", "Commonly used", "Many convertible items")
  )
  expect_false("Missing data" %in% levels(d$B033))
})

test_that("plot_variable_map coerces a Continuous variable to numeric", {
  p <- plot_variable_map(fixture_soc, "B001")
  d <- point_layer_data(p)
  expect_true(is.numeric(d$B001))
  expect_equal(d$B001[d$soc_id == "B79"], 70)
})

test_that("plot_variable_map collapses a society's duplicate observations, with a warning", {
  # B72's B017 has 3 raw rows (same code, different sources) in dplace_values
  raw <- dp_values(var_id = "B017", soc_id = "B72")
  expect_gt(nrow(raw), 1)
  expect_warning(
    plot_variable_map(fixture_soc, "B017"),
    "duplicate society/variable observation"
  )
})

test_that("plot_variable_map requires a single var_id", {
  expect_error(
    plot_variable_map(fixture_soc, c("B001", "B004")),
    "must be a single variable ID"
  )
})

test_that("plot_variable_map errors on an unknown var_id", {
  expect_error(plot_variable_map(fixture_soc, "not-a-real-var"), "not found")
})

test_that("plot_variable_map validates soc_id", {
  expect_error(plot_variable_map(character(0), "B001"), "at least one society")
  expect_error(
    plot_variable_map("not-a-real-soc-id", "B001"),
    "None of the requested society IDs were found"
  )
})

test_that("plot_variable_map drops unknown society IDs with a warning", {
  expect_warning(
    p <- plot_variable_map(c(fixture_soc, "not-a-real-soc-id"), "B001"),
    "Society ID\\(s\\) not found, dropped: not-a-real-soc-id"
  )
  expect_equal(nrow(point_layer_data(p)), 5)
})

test_that("plot_variable_map deduplicates soc_id", {
  p <- plot_variable_map(c(fixture_soc, fixture_soc), "B001")
  expect_equal(nrow(point_layer_data(p)), 5)
})

test_that("plot_variable_map accepts a data frame/tibble with a soc_id column", {
  soc_df <- dp_societies(soc_id = fixture_soc)
  p_from_df <- plot_variable_map(soc_df, "B001")
  p_from_vec <- plot_variable_map(fixture_soc, "B001")
  expect_identical(point_layer_data(p_from_df), point_layer_data(p_from_vec))
})

test_that("plot_variable_map's label argument is passed through to dp_map_societies", {
  p_labelled <- plot_variable_map(fixture_soc, "B001", label = TRUE)
  p_unlabelled <- plot_variable_map(fixture_soc, "B001", label = FALSE)
  expect_equal(length(p_labelled$layers), length(p_unlabelled$layers) + 1)
})

test_that("plot_variable_map's zoom argument is passed through to dp_map_societies", {
  p_zoomed <- plot_variable_map(fixture_soc, "B001")
  expect_false(is.null(p_zoomed$coordinates$limits$x))
  p_world <- plot_variable_map(fixture_soc, "B001", zoom = FALSE)
  expect_null(p_world$coordinates$limits$x)
})
