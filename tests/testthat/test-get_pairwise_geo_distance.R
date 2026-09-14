test_that("get_pairwise_geo_distance validates its inputs", {
  expect_error(get_pairwise_geo_distance("B72"), "at least two")
  expect_error(get_pairwise_geo_distance(c("B72", "B72")), "duplicate")
})

test_that("get_pairwise_geo_distance errors informatively without geoGraph", {
  skip_if(requireNamespace("geoGraph", quietly = TRUE),
          "geoGraph is installed; this tests the absent-package path")
  expect_error(
    get_pairwise_geo_distance(c("B72", "B73")),
    "requires the 'geoGraph' package"
  )
})

test_that("get_pairwise_geo_distance drops unknown IDs and missing coordinates", {
  skip_if_not_installed("geoGraph")
  expect_warning(
    expect_warning(
      out <- get_pairwise_geo_distance(c("B72", "B73", "not-a-real-soc-id")),
      "not found"
    )
  )
})

test_that("get_pairwise_geo_distance returns a tibble of pairwise distances", {
  skip_if_not_installed("geoGraph")
  ids <- c("B72", "B73", "B79")
  out <- get_pairwise_geo_distance(ids)

  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), choose(length(ids), 2))
  expect_true(all(c("soc_id_1", "soc_id_2", "distance_km") %in% names(out)))
  expect_true(all(out$distance_km >= 0))
})

test_that("get_pairwise_geo_distance errors when fewer than two valid societies remain", {
  skip_if_not_installed("geoGraph")
  expect_error(
    suppressWarnings(get_pairwise_geo_distance(c("B72", "not-a-real-soc-id"))),
    "Fewer than two"
  )
})
