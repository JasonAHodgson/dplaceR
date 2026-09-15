# Fixtures: B65 (Mbuti, glottocode bila1255), B62 (Bambote, holo1240), B63
# (Baka, baka1272), CARNEIRO4_009 (Fon, fonn1241), CARNEIRO4_011 (Ganda,
# gand1255) -- all resolve to tips on the same bundled tree (atla1278), with
# confirmed real branch-length distances (arbitrary Glottolog classification
# depth for this tree, not time -- see the units caveat in the docs).
# B72, B73 and B79 each resolve to a tip on a DIFFERENT tree from one
# another, so any pair drawn from them is a genuine cross-tree case.
# B284 has a glottocode ((quil1240) that isn't a tip in any bundled tree, so
# it's a genuine "no match" case (distinct from an unknown society ID).

test_that("get_pairwise_language_distance requires `cross_tree` to be supplied explicitly", {
  expect_error(
    get_pairwise_language_distance(c("B65", "B62")),
    "`cross_tree` must be supplied"
  )
})

test_that("get_pairwise_language_distance rejects an unknown `cross_tree`", {
  expect_error(
    get_pairwise_language_distance(c("B65", "B62"), cross_tree = "foo"),
    "should be one of"
  )
})

test_that("get_pairwise_language_distance errors informatively for cross_tree = \"join_root\" (not implemented)", {
  expect_error(
    get_pairwise_language_distance(c("B65", "B62"), cross_tree = "join_root"),
    "not implemented yet"
  )
})

test_that("get_pairwise_language_distance validates its inputs", {
  expect_error(get_pairwise_language_distance("B65", cross_tree = "na"), "at least two")
  expect_error(
    get_pairwise_language_distance(c("B65", "B65"), cross_tree = "na"),
    "duplicate"
  )
})

test_that("get_pairwise_language_distance drops unknown society IDs with a warning", {
  expect_warning(
    out <- get_pairwise_language_distance(c("B65", "B62", "not-a-real-soc-id"), cross_tree = "na"),
    "Society ID\\(s\\) not found, dropped: not-a-real-soc-id"
  )
  expect_equal(nrow(out), 1)
})

test_that("get_pairwise_language_distance drops societies whose language can't be matched to any tree", {
  expect_warning(
    tryCatch(
      get_pairwise_language_distance(c("B65", "B284"), cross_tree = "na"),
      error = function(e) NULL
    ),
    "language could not be matched to any bundled tree.*B284"
  )
  expect_error(
    suppressWarnings(get_pairwise_language_distance(c("B65", "B284"), cross_tree = "na")),
    "Fewer than two"
  )
})

test_that("get_pairwise_language_distance returns correct branch-length distances for societies on the same tree", {
  ids <- c("B65", "B62", "B63", "CARNEIRO4_009", "CARNEIRO4_011")
  out <- get_pairwise_language_distance(ids, cross_tree = "na")

  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), choose(length(ids), 2))
  expect_true(all(c("soc_id_1", "soc_id_2", "language_distance") %in% names(out)))
  expect_true(all(!is.na(out$language_distance)))

  get_d <- function(a, b) {
    out$language_distance[
      (out$soc_id_1 == a & out$soc_id_2 == b) | (out$soc_id_1 == b & out$soc_id_2 == a)
    ]
  }
  expect_equal(get_d("B65", "B62"), 15)
  expect_equal(get_d("B65", "B63"), 25)
  expect_equal(get_d("B65", "CARNEIRO4_009"), 21)
  expect_equal(get_d("B65", "CARNEIRO4_011"), 18)
  expect_equal(get_d("B62", "B63"), 16)
  expect_equal(get_d("B62", "CARNEIRO4_009"), 12)
  expect_equal(get_d("B62", "CARNEIRO4_011"), 7)
  expect_equal(get_d("B63", "CARNEIRO4_009"), 14)
  expect_equal(get_d("B63", "CARNEIRO4_011"), 19)
  expect_equal(get_d("CARNEIRO4_009", "CARNEIRO4_011"), 15)
})

test_that("get_pairwise_language_distance records NA (with a warning) for pairs on different trees, without failing the whole call", {
  # B72, B73 and B79 each resolve to a tip on a different tree, so all three
  # pairs among them are cross-tree.
  expect_warning(
    out <- get_pairwise_language_distance(c("B72", "B73", "B79"), cross_tree = "na"),
    "3 pair\\(s\\) of societies have languages on different trees"
  )
  expect_equal(nrow(out), 3)
  expect_true(all(is.na(out$language_distance)))
})

test_that("get_pairwise_language_distance handles a mix of same-tree and cross-tree pairs in one call", {
  ids <- c("B65", "B62", "B63", "B72")
  expect_warning(
    out <- get_pairwise_language_distance(ids, cross_tree = "na"),
    "pair\\(s\\) of societies have languages on different trees"
  )
  expect_equal(nrow(out), choose(length(ids), 2))

  get_d <- function(a, b) {
    out$language_distance[
      (out$soc_id_1 == a & out$soc_id_2 == b) | (out$soc_id_1 == b & out$soc_id_2 == a)
    ]
  }
  # Pairs within the atla1278 trio are still resolved normally.
  expect_equal(get_d("B65", "B62"), 15)
  expect_equal(get_d("B65", "B63"), 25)
  expect_equal(get_d("B62", "B63"), 16)
  # Anything paired with B72 (a different tree) is NA.
  expect_true(is.na(get_d("B65", "B72")))
  expect_true(is.na(get_d("B62", "B72")))
  expect_true(is.na(get_d("B63", "B72")))
})
