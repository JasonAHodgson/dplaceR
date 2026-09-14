test_that("get_geo_distance validates its inputs before requiring geoGraph", {
  expect_error(get_geo_distance("B72", character(0)), "at least one society")
  expect_error(
    get_geo_distance(c(longitude = 1), "B73"),
    "must be either a single D-PLACE society ID"
  )
  expect_error(
    get_geo_distance(c(1, 2), "B73"), # unnamed -- ambiguous lon/lat order, rejected
    "must be either a single D-PLACE society ID"
  )
  expect_error(
    get_geo_distance("not-a-real-soc", "B73"),
    "`point` society ID not found"
  )
})

test_that("get_geo_distance errors informatively without geoGraph", {
  skip_if(requireNamespace("geoGraph", quietly = TRUE),
          "geoGraph is installed; this tests the absent-package path")
  expect_error(
    get_geo_distance("B72", c("B73", "B79")),
    "requires the 'geoGraph' package"
  )
})

test_that("get_geo_distance returns one row per society, from a society point", {
  skip_if_not_installed("geoGraph")
  out <- get_geo_distance("B72", c("B73", "B79"))
  expect_s3_class(out, "tbl_df")
  expect_named(out, c("soc_id", "distance_km"))
  expect_equal(sort(out$soc_id), c("B73", "B79"))
  expect_true(all(out$distance_km >= 0))
})

test_that("get_geo_distance from a society point matches get_pairwise_geo_distance", {
  skip_if_not_installed("geoGraph")
  pairwise <- get_pairwise_geo_distance(c("B72", "B73", "B79"))
  one_vs_many <- get_geo_distance("B72", c("B73", "B79"))

  expect_equal(
    one_vs_many$distance_km[one_vs_many$soc_id == "B73"],
    pairwise$distance_km[pairwise$soc_id_1 == "B72" & pairwise$soc_id_2 == "B73"]
  )
  expect_equal(
    one_vs_many$distance_km[one_vs_many$soc_id == "B79"],
    pairwise$distance_km[pairwise$soc_id_1 == "B72" & pairwise$soc_id_2 == "B79"]
  )
})

test_that("get_geo_distance accepts an arbitrary coordinate point", {
  skip_if_not_installed("geoGraph")
  out <- get_geo_distance(c(longitude = 21.2, latitude = -20), c("B72", "B73"))
  expect_equal(nrow(out), 2)
  expect_true(all(out$distance_km >= 0))
  # B72 itself is at (21.2, -20) -- distance from that point to B72 should be ~0
  expect_equal(out$distance_km[out$soc_id == "B72"], 0, tolerance = 1)
})
