test_that("get_pairwise_cult_distance validates its inputs", {
  expect_error(get_pairwise_cult_distance("B72", var_id = "B004"), "at least two")
  expect_error(get_pairwise_cult_distance(c("B72", "B72"), var_id = "B004"), "duplicate")
  expect_error(get_pairwise_cult_distance(c("B72", "B73"), var_id = character(0)),
               "at least one variable")
  expect_error(get_pairwise_cult_distance(c("B72", "B73"), var_id = c("B004", "B004")),
               "duplicate")
  expect_error(
    get_pairwise_cult_distance(c("B72", "B73")),
    "Supply at least one of `var_id`, `category`, `type`, or `search`"
  )
})

test_that("get_pairwise_cult_distance selects variables via category/type/search", {
  # category = contains("Property") & type = "Continuous" -> B001/B002/B003
  # (see dp_variables(category = contains("Property"), type = "Continuous")).
  via_search <- get_pairwise_cult_distance(
    c("B72", "B73", "B79"), category = contains("Property"), type = "Continuous", metric = "both"
  )
  via_var_id <- get_pairwise_cult_distance(
    c("B72", "B73", "B79"),
    var_id = dp_variables(category = contains("Property"), type = "Continuous")$var_id,
    metric = "both"
  )
  expect_identical(via_search, via_var_id)
  expect_true(all(via_search$n_compared == 3))
})

test_that("unknown society/variable IDs are dropped with a warning", {
  expect_warning(
    out <- get_pairwise_cult_distance(c("B72", "B73", "not-a-real-soc"), var_id = c("B004", "B005")),
    "Society ID"
  )
  expect_equal(nrow(out), 1)

  # Dropping "not-a-real-var" leaves a single variable, which also warns
  # (see "a single variable warns that distance is only 0/1" below) --
  # collect every warning rather than just the first.
  ws <- character(0)
  withCallingHandlers(
    get_pairwise_cult_distance(c("B72", "B73"), var_id = c("B004", "not-a-real-var")),
    warning = function(w) { ws <<- c(ws, conditionMessage(w)); invokeRestart("muffleWarning") }
  )
  expect_true(any(grepl("Variable ID", ws)))
  expect_true(any(grepl("one variable", ws)))
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

# D-PLACE gives every variable a dedicated "missing data" code (code_id
# ending "-NA", e.g. "EA113-NA") -- a real code_id, but not a real observed
# state. EA113 (Categorical): Aa1 = Aa5 = "EA113-2" (a genuine match);
# Aa2 = Aa3 = "EA113-NA" (both only have the sentinel).
test_that("the missing-data sentinel code isn't treated as a real observed state", {
  ws <- character(0)
  out <- withCallingHandlers(
    get_pairwise_cult_distance(c("Aa1", "Aa2", "Aa3", "Aa5"), var_id = "EA113", metric = "both"),
    warning = function(w) { ws <<- c(ws, conditionMessage(w)); invokeRestart("muffleWarning") }
  )

  # A genuine shared state still matches normally.
  r <- pair_row(out, "Aa1", "Aa5")
  expect_equal(r$n_compared, 1)
  expect_equal(r$n_match, 1)

  # Both only "missing data" -- NOT a match (would incorrectly be one before
  # the fix, since "EA113-NA" == "EA113-NA" as plain strings).
  r <- pair_row(out, "Aa2", "Aa3")
  expect_equal(r$n_compared, 0)
  expect_true(is.na(r$cult_distance))

  # One real, one sentinel -- also not comparable.
  r <- pair_row(out, "Aa1", "Aa2")
  expect_equal(r$n_compared, 0)
  expect_true(is.na(r$cult_distance))

  expect_true(any(grepl("had data for both", ws)))
})

test_that("the missing-data sentinel doesn't inflate an ordinal variable's range", {
  # EA036's real codes run ord 1-6 ("No taboo" .. "More than two years"); its
  # sentinel code ("EA036-NA") has ord = 99, which must NOT leak into the
  # range used for type_aware scaling.
  expect_equal(dplaceR:::.cult_dist_var_range("EA036", "Ordinal"), 5)

  # Aa1 = Aa2 = Aa3 = "EA036-3" (ord 3); Aa5 = "EA036-5" (ord 5);
  # Aa4 = only the sentinel ("EA036-NA").
  out <- suppressWarnings(get_pairwise_cult_distance(
    c("Aa1", "Aa4", "Aa5"), var_id = "EA036", metric = "both", type_aware = TRUE
  ))
  # Aa1-Aa4: Aa4 has no usable state -- excluded, not scored against ord 99.
  r <- pair_row(out, "Aa1", "Aa4")
  expect_equal(r$n_compared, 0)
  # Aa1-Aa5: a real, moderate scaled difference (|3-5|/5), not swamped by a
  # spurious sentinel-driven range.
  r <- pair_row(out, "Aa1", "Aa5")
  expect_equal(r$n_compared, 1)
  expect_equal(r$n_match, 1 - 2 / 5, tolerance = 1e-8)
})
