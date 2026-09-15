# See test-get_pairwise_language_distance.R for the fixtures this file
# reuses (B65/B62/B63/CARNEIRO4_009/CARNEIRO4_011 on the same tree; B72/B73/
# B79 each on a different tree from one another; B284 a genuine
# no-tree-match case).

test_that("get_language_distance requires `cross_tree` to be supplied explicitly", {
  expect_error(get_language_distance("B65", "B62"), "`cross_tree` must be supplied")
})

test_that("get_language_distance rejects an unknown `cross_tree`", {
  expect_error(
    get_language_distance("B65", "B62", cross_tree = "foo"),
    "should be one of"
  )
})

test_that("get_language_distance errors informatively for cross_tree = \"join_root\" (not implemented)", {
  expect_error(
    get_language_distance("B65", "B62", cross_tree = "join_root"),
    "not implemented yet"
  )
})

test_that("get_language_distance validates its inputs", {
  expect_error(
    get_language_distance("B65", character(0), cross_tree = "na"),
    "at least one society"
  )
  expect_error(
    get_language_distance(c("a", "b"), "B62", cross_tree = "na"),
    "`point` must be either a single D-PLACE society ID"
  )
  expect_error(
    get_language_distance("not-a-real-soc-id", "B62", cross_tree = "na"),
    "matched neither"
  )
})

test_that("get_language_distance drops unknown society IDs with a warning", {
  expect_warning(
    out <- get_language_distance("B65", c("B62", "not-a-real-soc-id"), cross_tree = "na"),
    "Society ID\\(s\\) not found, dropped: not-a-real-soc-id"
  )
  expect_equal(out$soc_id, "B62")
})

test_that("get_language_distance drops societies whose language can't be matched to any tree", {
  expect_warning(
    tryCatch(
      get_language_distance("B65", "B284", cross_tree = "na"),
      error = function(e) NULL
    ),
    "language could not be matched to any bundled tree.*B284"
  )
  expect_error(
    suppressWarnings(get_language_distance("B65", "B284", cross_tree = "na")),
    "No societies with a matchable language"
  )
})

test_that("get_language_distance returns correct branch-length distances from a society point", {
  out <- get_language_distance("B65", c("B62", "B63", "CARNEIRO4_009", "CARNEIRO4_011"), cross_tree = "na")

  expect_s3_class(out, "tbl_df")
  expect_named(out, c("soc_id", "language_distance"))
  expect_equal(nrow(out), 4)
  expect_true(all(!is.na(out$language_distance)))

  expect_equal(out$language_distance[out$soc_id == "B62"], 15)
  expect_equal(out$language_distance[out$soc_id == "B63"], 25)
  expect_equal(out$language_distance[out$soc_id == "CARNEIRO4_009"], 21)
  expect_equal(out$language_distance[out$soc_id == "CARNEIRO4_011"], 18)
})

test_that("get_language_distance accepts a bare Glottocode as `point`, matching the society-ID result", {
  by_soc_id <- get_language_distance("B65", c("B62", "B63", "CARNEIRO4_009", "CARNEIRO4_011"), cross_tree = "na")
  by_glottocode <- get_language_distance("bila1255", c("B62", "B63", "CARNEIRO4_009", "CARNEIRO4_011"), cross_tree = "na")

  expect_equal(by_glottocode$soc_id, by_soc_id$soc_id)
  expect_equal(by_glottocode$language_distance, by_soc_id$language_distance)
})

test_that("get_language_distance matches get_pairwise_language_distance for the same societies", {
  ids <- c("B65", "B62", "B63", "CARNEIRO4_009", "CARNEIRO4_011")
  pairwise <- get_pairwise_language_distance(ids, cross_tree = "na")
  one_vs_many <- get_language_distance("B65", setdiff(ids, "B65"), cross_tree = "na")

  for (id in setdiff(ids, "B65")) {
    expect_equal(
      one_vs_many$language_distance[one_vs_many$soc_id == id],
      pairwise$language_distance[
        (pairwise$soc_id_1 == "B65" & pairwise$soc_id_2 == id) |
          (pairwise$soc_id_1 == id & pairwise$soc_id_2 == "B65")
      ],
      info = paste("mismatch for", id)
    )
  }
})

test_that("get_language_distance records NA (with a warning) for societies on a different tree from `point`", {
  # B72 resolves to a tip on a different tree from B65's (atla1278).
  expect_warning(
    out <- get_language_distance("B65", "B72", cross_tree = "na"),
    "1 society\\(ies\\) have a language on a different tree from `point`"
  )
  expect_true(is.na(out$language_distance))
})

test_that("get_language_distance handles a mix of same-tree and cross-tree societies in one call", {
  expect_warning(
    out <- get_language_distance("B65", c("B62", "B72"), cross_tree = "na"),
    "language on a different tree from `point`"
  )
  expect_equal(out$language_distance[out$soc_id == "B62"], 15)
  expect_true(is.na(out$language_distance[out$soc_id == "B72"]))
})
