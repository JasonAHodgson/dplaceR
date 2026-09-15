test_that("get_pairwise_cult_distance validates its inputs", {
  expect_error(get_pairwise_cult_distance("B72", var_id = "B004"), "at least two")
  expect_error(get_pairwise_cult_distance(c("B72", "B72"), var_id = "B004"), "duplicate")
  expect_error(get_pairwise_cult_distance(c("B72", "B73"), var_id = character(0)),
               "at least one variable")
  expect_error(get_pairwise_cult_distance(c("B72", "B73"), var_id = c("B004", "B004")),
               "duplicate")
})

test_that("unknown society/variable IDs are dropped with a warning", {
  expect_warning(
    out <- get_pairwise_cult_distance(c("B72", "B73", "not-a-real-soc"), var_id = c("B004", "B005")),
    "Society ID"
  )
  expect_equal(nrow(out), 1)

  expect_warning(
    get_pairwise_cult_distance(c("B72", "B73"), var_id = c("B004", "not-a-real-var")),
    "Variable ID"
  )
})

test_that("a single variable warns that distance is only 0/1", {
  expect_warning(
    get_pairwise_cult_distance(c("B72", "B73"), var_id = "B004"),
    "one variable"
  )
})

# Pair order (which society lands in soc_id_1 vs soc_id_2) isn't guaranteed,
# but the metrics are symmetric, so look rows up regardless of orientation.
pair_row <- function(df, a, b) {
  df[(df$soc_id_1 == a & df$soc_id_2 == b) | (df$soc_id_1 == b & df$soc_id_2 == a), ]
}

# Hand-worked scenario used throughout:
#   SCCS202: SCCS11 = Flexible, SCCS12 = Rigid, SCCS3 = <missing>
#   SCCS10:  SCCS11 = Small Mammals, SCCS12 = Large Game, SCCS3 = Large Game

test_that("missing = 'pairwise' (default) only compares variables both societies have", {
  out <- get_pairwise_cult_distance(
    c("SCCS11", "SCCS12", "SCCS3"), var_id = c("SCCS202", "SCCS10"), metric = "both"
  )

  # SCCS11-SCCS12: both variables compared, mismatch on both
  r <- pair_row(out, "SCCS11", "SCCS12")
  expect_equal(r$n_compared, 2)
  expect_equal(r$n_match, 0)
  expect_equal(r$cult_distance, 1)

  # SCCS11-SCCS3: SCCS202 excluded (SCCS3 missing it), only SCCS10 compared (mismatch)
  r <- pair_row(out, "SCCS11", "SCCS3")
  expect_equal(r$n_compared, 1)
  expect_equal(r$n_match, 0)
  expect_equal(r$cult_distance, 1)

  # SCCS12-SCCS3: SCCS202 excluded, only SCCS10 compared (match: both Large Game)
  r <- pair_row(out, "SCCS12", "SCCS3")
  expect_equal(r$n_compared, 1)
  expect_equal(r$n_match, 1)
  expect_equal(r$cult_distance, 0)
})

test_that("missing = 'complete' drops societies with any missing variable", {
  expect_warning(
    out <- get_pairwise_cult_distance(
      c("SCCS11", "SCCS12", "SCCS3"), var_id = c("SCCS202", "SCCS10"),
      missing = "complete", metric = "both"
    ),
    "SCCS3"
  )
  expect_equal(nrow(out), 1)
  expect_equal(sort(c(out$soc_id_1, out$soc_id_2)), c("SCCS11", "SCCS12"))
  expect_equal(out$n_compared, 2)
  expect_equal(out$n_match, 0)
  expect_equal(out$cult_distance, 1)
})

test_that("missing = 'match' treats missingness as its own state", {
  out <- get_pairwise_cult_distance(
    c("SCCS11", "SCCS12", "SCCS3"), var_id = c("SCCS202", "SCCS10"),
    missing = "match", metric = "both"
  )

  r <- pair_row(out, "SCCS11", "SCCS12")
  expect_equal(r$n_compared, 2)
  expect_equal(r$n_match, 0)
  expect_equal(r$cult_distance, 1)

  # SCCS11-SCCS3: SCCS202 mismatch (present vs missing), SCCS10 mismatch -> 0/2
  r <- pair_row(out, "SCCS11", "SCCS3")
  expect_equal(r$n_compared, 2)
  expect_equal(r$n_match, 0)
  expect_equal(r$cult_distance, 1)

  # SCCS12-SCCS3: SCCS202 mismatch (present vs missing), SCCS10 match -> 1/2
  r <- pair_row(out, "SCCS12", "SCCS3")
  expect_equal(r$n_compared, 2)
  expect_equal(r$n_match, 1)
  expect_equal(r$cult_distance, 0.5)
})

test_that("metric controls which columns are returned", {
  out_prop <- get_pairwise_cult_distance(c("B72", "B73", "B79"), var_id = c("B004", "B005"))
  expect_named(out_prop, c("soc_id_1", "soc_id_2", "cult_distance"))

  out_sum <- get_pairwise_cult_distance(
    c("B72", "B73", "B79"), var_id = c("B004", "B005"), metric = "sum"
  )
  expect_named(out_sum, c("soc_id_1", "soc_id_2", "n_match"))

  out_both <- get_pairwise_cult_distance(
    c("B72", "B73", "B79"), var_id = c("B004", "B005"), metric = "both"
  )
  expect_named(out_both, c("soc_id_1", "soc_id_2", "n_match", "n_compared", "cult_distance"))

  # B004: B72 = B73 = B79 = Gathering (all match)
  # B005: B72 = B79 = B005-1, B73 = B005-2 (B73 mismatches the other two)
  expect_equal(pair_row(out_both, "B72", "B73")$n_match, 1)
  expect_equal(pair_row(out_both, "B72", "B79")$n_match, 2)
  expect_equal(pair_row(out_both, "B73", "B79")$n_match, 1)
  expect_equal(pair_row(out_both, "B72", "B73")$cult_distance, 0.5)
  expect_equal(pair_row(out_both, "B72", "B79")$cult_distance, 0)
  expect_equal(pair_row(out_both, "B73", "B79")$cult_distance, 0.5)
})

test_that("type_aware = FALSE (default) uses exact match even for continuous variables", {
  # B001: B72 = "67", B73 = "67", B79 = "70" (raw strings)
  out <- get_pairwise_cult_distance(c("B72", "B73", "B79"), var_id = "B001", metric = "sum")
  expect_equal(pair_row(out, "B72", "B73")$n_match, 1) # match
  expect_equal(pair_row(out, "B72", "B79")$n_match, 0) # mismatch
  expect_equal(pair_row(out, "B73", "B79")$n_match, 0) # mismatch
})

test_that("type_aware = TRUE scales ordinal variables by rank and range", {
  # B033 (ord range 1-4): B1 = 1, B294 = 2, B160 = 4
  out <- get_pairwise_cult_distance(
    c("B1", "B294", "B160"), var_id = "B033", metric = "sum", type_aware = TRUE
  )
  expect_equal(pair_row(out, "B1", "B294")$n_match, 2 / 3, tolerance = 1e-8)
  expect_equal(pair_row(out, "B1", "B160")$n_match, 0, tolerance = 1e-8)
  expect_equal(pair_row(out, "B294", "B160")$n_match, 1 / 3, tolerance = 1e-8)
})

test_that("type_aware = TRUE scales continuous variables by value and range", {
  # B001 (range 0.01-90.3): B72 = 67, B73 = 67, B79 = 70
  rng <- 90.3 - 0.01
  out <- get_pairwise_cult_distance(
    c("B72", "B73", "B79"), var_id = "B001", metric = "sum", type_aware = TRUE
  )
  expect_equal(pair_row(out, "B72", "B73")$n_match, 1, tolerance = 1e-8)
  expect_equal(pair_row(out, "B72", "B79")$n_match, 1 - 3 / rng, tolerance = 1e-8)
  expect_equal(pair_row(out, "B73", "B79")$n_match, 1 - 3 / rng, tolerance = 1e-8)
})

test_that("type_aware = TRUE leaves categorical variables as simple match/mismatch", {
  rng <- 90.3 - 0.01
  out <- get_pairwise_cult_distance(
    c("B72", "B73", "B79"), var_id = c("B004", "B001"), metric = "sum", type_aware = TRUE
  )
  # B004 contributes 1 (always matches); B001 contributes the scaled similarity
  expect_equal(pair_row(out, "B72", "B73")$n_match, 2, tolerance = 1e-8)
  expect_equal(pair_row(out, "B72", "B79")$n_match, 1 + (1 - 3 / rng), tolerance = 1e-8)
  expect_equal(pair_row(out, "B73", "B79")$n_match, 1 + (1 - 3 / rng), tolerance = 1e-8)
})

test_that("duplicate society/variable observations are collapsed with a warning", {
  expect_warning(
    out <- get_pairwise_cult_distance(c("B1", "B10"), var_id = c("B016", "B004")),
    "duplicate"
  )
  expect_equal(nrow(out), 1)
})

test_that("pairs with no variable in common get NA distance and a warning", {
  expect_warning(
    out <- get_pairwise_cult_distance(c("SCCS11", "SCCS3"), var_id = "SCCS202"),
    "No requested variable had data"
  )
  expect_true(is.na(out$cult_distance))
})
