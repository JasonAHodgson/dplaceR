test_that("get_geo_distance requires `method` to be supplied explicitly", {
  expect_error(get_geo_distance("B72", "B73"), "`method` must be supplied")
})

test_that("get_geo_distance rejects an unknown `method`", {
  expect_error(get_geo_distance("B72", "B73", method = "as_the_crow_flies"), "should be one of")
})

test_that("get_geo_distance validates its inputs before requiring geoGraph", {
  expect_error(get_geo_distance("B72", character(0), method = "great_circle"), "at least one society")
  expect_error(
    get_geo_distance(c(longitude = 1), "B73", method = "great_circle"),
    "must be either a single D-PLACE society ID"
  )
  expect_error(
    get_geo_distance(c(1, 2), "B73", method = "great_circle"), # unnamed -- ambiguous lon/lat order, rejected
    "must be either a single D-PLACE society ID"
  )
  expect_error(
    get_geo_distance("not-a-real-soc", "B73", method = "great_circle"),
    "`point` society ID not found"
  )
})

test_that("get_geo_distance errors informatively without geoGraph, only for graph-based methods", {
  skip_if(requireNamespace("geoGraph", quietly = TRUE),
          "geoGraph is installed; this tests the absent-package path")
  expect_error(
    get_geo_distance("B72", c("B73", "B79"), method = "migration"),
    "requires the 'geoGraph' package"
  )
  expect_error(
    get_geo_distance("B72", c("B73", "B79"), method = "land_route_km"),
    "requires the 'geoGraph' package"
  )
  # great_circle needs no graph at all, so it should work even without geoGraph.
  out <- get_geo_distance("B72", c("B73", "B79"), method = "great_circle")
  expect_true(all(out$geo_distance >= 0))
})

test_that("get_geo_distance great_circle needs no geoGraph and has no connectivity restrictions", {
  # B72 (Southern Africa) and WNAI8 (Western Canada) have no land route
  # between them once sea-crossing edges are removed, but a straight-line
  # great-circle distance is always computable regardless.
  out <- get_geo_distance("B72", c("B73", "WNAI8"), method = "great_circle")
  expect_s3_class(out, "tbl_df")
  expect_named(out, c("soc_id", "geo_distance"))
  expect_equal(sort(out$soc_id), c("B73", "WNAI8"))
  expect_true(all(out$geo_distance > 0))
  # WNAI8 is much further from B72 than B73 is (both roughly Southern Africa).
  expect_true(
    out$geo_distance[out$soc_id == "WNAI8"] > out$geo_distance[out$soc_id == "B73"]
  )
})

test_that("get_geo_distance great_circle matches an independently computed haversine distance", {
  soc <- dp_societies(soc_id = c("B72", "B79"), type = NULL)
  b72 <- soc[soc$soc_id == "B72", ]
  b79 <- soc[soc$soc_id == "B79", ]

  # Independent haversine reference computation (IUGG mean radius), written
  # fresh here rather than reusing any of the package's own internals, so
  # this is a genuine check of get_geo_distance()'s arithmetic.
  R <- 6371.0088
  to_rad <- pi / 180
  lat1 <- b72$latitude * to_rad
  lat2 <- b79$latitude * to_rad
  dlat <- lat2 - lat1
  dlon <- (b79$longitude - b72$longitude) * to_rad
  a <- sin(dlat / 2)^2 + cos(lat1) * cos(lat2) * sin(dlon / 2)^2
  expected_km <- R * 2 * atan2(sqrt(a), sqrt(1 - a))

  out <- get_geo_distance("B72", "B79", method = "great_circle")
  expect_equal(out$geo_distance, expected_km, tolerance = 1e-6)
})

test_that("get_geo_distance returns one row per society, from a society point (migration)", {
  skip_if_not_installed("geoGraph")
  out <- get_geo_distance("B72", c("B73", "B79"), method = "migration")
  expect_s3_class(out, "tbl_df")
  expect_named(out, c("soc_id", "geo_distance"))
  expect_equal(sort(out$soc_id), c("B73", "B79"))
  expect_true(all(out$geo_distance >= 0))
})

test_that("get_geo_distance (migration) from a society point matches get_pairwise_geo_distance (migration)", {
  skip_if_not_installed("geoGraph")
  pairwise <- get_pairwise_geo_distance(c("B72", "B73", "B79"), method = "migration")
  one_vs_many <- get_geo_distance("B72", c("B73", "B79"), method = "migration")

  expect_equal(
    one_vs_many$geo_distance[one_vs_many$soc_id == "B73"],
    pairwise$geo_distance[pairwise$soc_id_1 == "B72" & pairwise$soc_id_2 == "B73"]
  )
  expect_equal(
    one_vs_many$geo_distance[one_vs_many$soc_id == "B79"],
    pairwise$geo_distance[pairwise$soc_id_1 == "B72" & pairwise$soc_id_2 == "B79"]
  )
})

test_that("get_geo_distance matches get_pairwise_geo_distance for a larger set (single-source path, migration)", {
  skip_if_not_installed("geoGraph")
  # get_geo_distance() uses geoGraph's single-source dijkstraFrom() rather
  # than get_pairwise_geo_distance()'s all-pairs dijkstraBetween() -- this
  # cross-checks that the two independent code paths agree, across enough
  # societies to exercise dijkstraFrom()'s internal node reordering.
  ids <- c("B72", "B73", "B79", "B74", "B75", "B76", "B77", "B78")
  pairwise <- get_pairwise_geo_distance(ids, method = "migration")
  one_vs_many <- get_geo_distance("B72", setdiff(ids, "B72"), method = "migration")

  expect_equal(nrow(one_vs_many), length(ids) - 1)
  for (id in setdiff(ids, "B72")) {
    expect_equal(
      one_vs_many$geo_distance[one_vs_many$soc_id == id],
      pairwise$geo_distance[
        (pairwise$soc_id_1 == "B72" & pairwise$soc_id_2 == id) |
          (pairwise$soc_id_1 == id & pairwise$soc_id_2 == "B72")
      ],
      info = paste("mismatch for", id)
    )
  }
})

test_that("get_geo_distance drops societies with no land route to `point`, with a warning (migration)", {
  skip_if_not_installed("geoGraph")
  skip_if_not_installed("RBGL")
  # B72 (Southern Africa) and WNAI8 (Western Canada) are on landmasses with
  # no land route between them once sea-crossing edges are removed -- this
  # is the scenario that used to make the whole call error out with
  # geoGraph's own "Not all nodes are connected by the graph."
  expect_warning(
    out <- get_geo_distance("B72", c("B73", "WNAI8"), method = "migration"),
    "no land route to.*WNAI8"
  )
  expect_equal(out$soc_id, "B73")
})

test_that("get_geo_distance errors when `point` has no land route to any requested society (migration)", {
  skip_if_not_installed("geoGraph")
  skip_if_not_installed("RBGL")
  expect_error(
    suppressWarnings(get_geo_distance("B72", "WNAI8", method = "migration")),
    "no land route to any"
  )
})

test_that("get_geo_distance accepts an arbitrary coordinate point (migration)", {
  skip_if_not_installed("geoGraph")
  # B79 is well clear of B72's own coordinates -- at worldgraph.10k's
  # resolution, B72 and B73 actually snap to the same graph node (see the
  # dedicated same-node test below), so B79 is used here to keep this a
  # plain, uncomplicated "point vs a distinct society" check.
  out <- get_geo_distance(c(longitude = 21.2, latitude = -20), c("B72", "B79"), method = "migration")
  expect_equal(nrow(out), 2)
  expect_true(all(out$geo_distance >= 0))
  # B72 itself is at (21.2, -20) -- distance from that point to B72 should be ~0
  expect_equal(out$geo_distance[out$soc_id == "B72"], 0, tolerance = 1)
})

test_that("get_geo_distance records distance 0 (with a warning) for societies sharing `point`'s graph node (migration)", {
  skip_if_not_installed("geoGraph")
  # At worldgraph.10k's resolution, B72 and B73 snap to the same graph node
  # (confirmed against a live geoGraph install), while B79 snaps to a
  # distinct one -- a real example of the same-node case, not a contrived
  # one, exercising both branches (same-node and normal dijkstraFrom lookup)
  # in a single call.
  expect_warning(
    out <- get_geo_distance("B72", c("B73", "B79"), method = "migration"),
    "snapped to the same graph node as: B73"
  )
  expect_equal(out$geo_distance[out$soc_id == "B73"], 0)
  expect_true(out$geo_distance[out$soc_id == "B79"] > 0)
})

test_that("get_geo_distance land_route_km returns real km, at least as large as great_circle", {
  skip_if_not_installed("geoGraph")
  ids <- c("B73", "B79", "WNAI8")
  gc <- get_geo_distance("B72", ids, method = "great_circle")
  lr <- suppressWarnings(get_geo_distance("B72", ids, method = "land_route_km"))

  # WNAI8 has no land route to B72 and is dropped by land_route_km but not
  # by great_circle -- restrict the comparison to what both returned.
  common <- intersect(gc$soc_id, lr$soc_id)
  expect_true(length(common) > 0)
  for (id in common) {
    expect_gte(
      lr$geo_distance[lr$soc_id == id],
      gc$geo_distance[gc$soc_id == id] - 1e-6 # a land route can't be shorter than a straight line
    )
  }
})

test_that("get_geo_distance land_route_km reflects real distance, not 0, even when point shares a society's graph node", {
  skip_if_not_installed("geoGraph")
  # B72 and B73 share a graph node at worldgraph.10k's resolution -- for
  # method = "migration" that means routed distance 0 (see the dedicated
  # same-node test above), but they are NOT at identical real-world
  # coordinates, so method = "land_route_km" should reflect their actual
  # (small but nonzero) separation via each endpoint's snap distance, rather
  # than collapsing to 0 the way the routed distance alone would.
  expect_warning(
    lr <- get_geo_distance("B72", c("B73", "B79"), method = "land_route_km"),
    "snapped to the same graph node as: B73"
  )
  gc <- get_geo_distance("B72", c("B73", "B79"), method = "great_circle")

  expect_true(lr$geo_distance[lr$soc_id == "B73"] > 0)
  expect_gte(
    lr$geo_distance[lr$soc_id == "B73"],
    gc$geo_distance[gc$soc_id == "B73"] - 1e-6
  )
})

test_that("get_geo_distance land_route_km never leaves a modified graph in the global environment", {
  skip_if_not_installed("geoGraph")
  had_before <- exists("worldgraph.10k", envir = globalenv(), inherits = FALSE)
  before <- if (had_before) get("worldgraph.10k", envir = globalenv(), inherits = FALSE) else NULL

  invisible(get_geo_distance("B72", c("B73", "B79"), method = "land_route_km"))

  expect_equal(exists("worldgraph.10k", envir = globalenv(), inherits = FALSE), had_before)
  if (had_before) {
    expect_identical(get("worldgraph.10k", envir = globalenv(), inherits = FALSE), before)
  }
})
