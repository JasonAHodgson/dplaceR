test_that("get_pairwise_geo_distance requires `method` to be supplied explicitly", {
  expect_error(get_pairwise_geo_distance(c("B72", "B73")), "`method` must be supplied")
})

test_that("get_pairwise_geo_distance rejects an unknown `method`", {
  expect_error(
    get_pairwise_geo_distance(c("B72", "B73"), method = "as_the_crow_flies"),
    "should be one of"
  )
})

test_that("get_pairwise_geo_distance validates its inputs", {
  expect_error(get_pairwise_geo_distance("B72", method = "great_circle"), "at least two")
  expect_error(get_pairwise_geo_distance(c("B72", "B72"), method = "great_circle"), "duplicate")
})

test_that("get_pairwise_geo_distance errors informatively without geoGraph, only for graph-based methods", {
  skip_if(requireNamespace("geoGraph", quietly = TRUE),
          "geoGraph is installed; this tests the absent-package path")
  expect_error(
    get_pairwise_geo_distance(c("B72", "B73"), method = "migration"),
    "requires the 'geoGraph' package"
  )
  expect_error(
    get_pairwise_geo_distance(c("B72", "B73"), method = "land_route_km"),
    "requires the 'geoGraph' package"
  )
  # great_circle needs no graph at all, so it should work even without geoGraph.
  out <- get_pairwise_geo_distance(c("B72", "B73"), method = "great_circle")
  expect_true(all(out$distance >= 0))
})

test_that("get_pairwise_geo_distance great_circle needs no geoGraph and has no connectivity restrictions", {
  # B72 (Southern Africa) and WNAI8 (Western Canada) have no land route
  # between them once sea-crossing edges are removed, but a straight-line
  # great-circle distance is always computable regardless -- so, unlike
  # "migration"/"land_route_km", nothing here should be NA.
  out <- get_pairwise_geo_distance(c("B72", "B73", "WNAI8"), method = "great_circle")
  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 3)
  expect_true(all(!is.na(out$distance)))
  expect_true(all(out$distance >= 0))
})

test_that("get_pairwise_geo_distance great_circle matches an independently computed haversine distance", {
  soc <- dp_societies(soc_id = c("B72", "B79"), type = NULL)
  b72 <- soc[soc$soc_id == "B72", ]
  b79 <- soc[soc$soc_id == "B79", ]

  # Independent haversine reference computation (IUGG mean radius), written
  # fresh here rather than reusing any of the package's own internals, so
  # this is a genuine check of get_pairwise_geo_distance()'s arithmetic.
  R <- 6371.0088
  to_rad <- pi / 180
  lat1 <- b72$latitude * to_rad
  lat2 <- b79$latitude * to_rad
  dlat <- lat2 - lat1
  dlon <- (b79$longitude - b72$longitude) * to_rad
  a <- sin(dlat / 2)^2 + cos(lat1) * cos(lat2) * sin(dlon / 2)^2
  expected_km <- R * 2 * atan2(sqrt(a), sqrt(1 - a))

  out <- get_pairwise_geo_distance(c("B72", "B79"), method = "great_circle")
  expect_equal(out$distance, expected_km, tolerance = 1e-6)
})

test_that("get_pairwise_geo_distance drops unknown IDs and missing coordinates", {
  skip_if_not_installed("geoGraph")
  expect_warning(
    expect_warning(
      out <- get_pairwise_geo_distance(c("B72", "B73", "not-a-real-soc-id"), method = "migration"),
      "not found"
    )
  )
})

test_that("get_pairwise_geo_distance returns a tibble of pairwise distances (migration)", {
  skip_if_not_installed("geoGraph")
  ids <- c("B72", "B73", "B79")
  out <- get_pairwise_geo_distance(ids, method = "migration")

  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), choose(length(ids), 2))
  expect_true(all(c("soc_id_1", "soc_id_2", "distance") %in% names(out)))
  expect_true(all(out$distance >= 0))
})

test_that("get_pairwise_geo_distance returns NA (with a warning) for pairs with no land route, without failing the whole call (migration)", {
  skip_if_not_installed("geoGraph")
  skip_if_not_installed("RBGL")
  # B72 (Southern Africa) and WNAI8 (Western Canada) are on landmasses with
  # no land route between them once sea-crossing edges are removed -- this
  # is the scenario that used to make the whole call error out with
  # geoGraph's own "Not all nodes are connected by the graph."
  expect_warning(
    out <- get_pairwise_geo_distance(c("B72", "B73", "WNAI8"), method = "migration"),
    "no land route between them"
  )
  expect_equal(nrow(out), 3)
  b72_b73 <- out$distance[
    (out$soc_id_1 == "B72" & out$soc_id_2 == "B73") |
      (out$soc_id_1 == "B73" & out$soc_id_2 == "B72")
  ]
  expect_true(!is.na(b72_b73) && b72_b73 >= 0)
  cross_continent <- out$distance[
    out$soc_id_1 == "WNAI8" | out$soc_id_2 == "WNAI8"
  ]
  expect_true(all(is.na(cross_continent)))
})

test_that("get_pairwise_geo_distance handles a set spanning multiple distinct origin nodes (migration)", {
  skip_if_not_installed("geoGraph")
  # gPath2dist() returns a `dist` object (no names) rather than a named
  # vector once the requested pairs span more than one distinct origin node
  # -- the normal case for 3+ societies with genuinely different locations.
  # These 8 societies (and their real geoGraph output, including B72/B73
  # sharing a graph node at this resolution) are used as a concrete
  # regression anchor for that code path.
  ids <- c("B72", "B73", "B79", "B74", "B75", "B76", "B77", "B78")
  out <- get_pairwise_geo_distance(ids, method = "migration")

  expect_equal(nrow(out), choose(length(ids), 2))
  expect_true(all(!is.na(out$distance)))
  expect_true(all(out$distance >= 0))
  # B72 and B73 share a graph node at this resolution -- distance 0.
  expect_equal(
    out$distance[
      (out$soc_id_1 == "B72" & out$soc_id_2 == "B73") |
        (out$soc_id_1 == "B73" & out$soc_id_2 == "B72")
    ],
    0
  )
})

test_that("get_pairwise_geo_distance errors when fewer than two valid societies remain", {
  skip_if_not_installed("geoGraph")
  expect_error(
    suppressWarnings(get_pairwise_geo_distance(c("B72", "not-a-real-soc-id"), method = "migration")),
    "Fewer than two"
  )
})

test_that("get_pairwise_geo_distance land_route_km returns real km, at least as large as great_circle", {
  skip_if_not_installed("geoGraph")
  ids <- c("B72", "B73", "B79")
  gc <- get_pairwise_geo_distance(ids, method = "great_circle")
  lr <- suppressWarnings(get_pairwise_geo_distance(ids, method = "land_route_km"))

  merged <- merge(gc, lr, by = c("soc_id_1", "soc_id_2"), suffixes = c("_gc", "_lr"))
  expect_true(nrow(merged) > 0)
  # A land route can never be shorter than a straight line between the same
  # two points.
  expect_true(all(merged$distance_lr >= merged$distance_gc - 1e-6))
})

test_that("get_pairwise_geo_distance land_route_km reflects real distance, not 0, for a same-node pair", {
  skip_if_not_installed("geoGraph")
  # B72 and B73 share a graph node at worldgraph.10k's resolution -- their
  # routed distance is exactly 0 for method = "migration" (see the
  # multi-origin-nodes test above), but they are NOT at identical
  # real-world coordinates, so method = "land_route_km" should reflect
  # their actual (small but nonzero) separation via each society's snap
  # distance, rather than collapsing to 0 the way the routed distance
  # alone would.
  ids <- c("B72", "B73", "B79")
  lr <- suppressWarnings(get_pairwise_geo_distance(ids, method = "land_route_km"))
  gc <- get_pairwise_geo_distance(ids, method = "great_circle")

  b72_b73_lr <- lr$distance[
    (lr$soc_id_1 == "B72" & lr$soc_id_2 == "B73") |
      (lr$soc_id_1 == "B73" & lr$soc_id_2 == "B72")
  ]
  b72_b73_gc <- gc$distance[
    (gc$soc_id_1 == "B72" & gc$soc_id_2 == "B73") |
      (gc$soc_id_1 == "B73" & gc$soc_id_2 == "B72")
  ]
  expect_true(b72_b73_lr > 0)
  expect_gte(b72_b73_lr, b72_b73_gc - 1e-6)
})

test_that("get_pairwise_geo_distance land_route_km never leaves a modified graph in the global environment", {
  skip_if_not_installed("geoGraph")
  had_before <- exists("worldgraph.10k", envir = globalenv(), inherits = FALSE)
  before <- if (had_before) get("worldgraph.10k", envir = globalenv(), inherits = FALSE) else NULL

  invisible(get_pairwise_geo_distance(c("B72", "B73", "B79"), method = "land_route_km"))

  expect_equal(exists("worldgraph.10k", envir = globalenv(), inherits = FALSE), had_before)
  if (had_before) {
    expect_identical(get("worldgraph.10k", envir = globalenv(), inherits = FALSE), before)
  }
})
