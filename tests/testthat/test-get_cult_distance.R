test_that("get_cult_distance validates its inputs", {
  expect_error(get_cult_distance("B72", character(0), var_id = "B004"), "at least one society")
  expect_error(get_cult_distance("B72", c("B73", "B73"), var_id = "B004"), "duplicate")
  expect_error(get_cult_distance("B72", "B73", var_id = character(0)), "at least one variable")
  expect_error(get_cult_distance("B72", "B73", var_id = c("B004", "B004")), "duplicate")
  expect_error(get_cult_distance(NULL, "B73", var_id = "B004"), "must be supplied")
  expect_error(
    get_cult_distance("not-a-real-soc", "B73", var_id = "B004"),
    "not found"
  )
})

test_that("culture = an existing society compares its recorded states", {
  # B72: B004 = B004-2, B005 = B005-1
  out <- get_cult_distance("B72", c("B73", "B79"), var_id = c("B004", "B005"), metric = "both")

  r73 <- out[out$soc_id == "B73", ]
  expect_equal(r73$n_compared, 2)
  expect_equal(r73$n_match, 1) # B004 matches, B005 (B005-2) doesn't
  expect_equal(r73$cult_distance, 0.5)

  r79 <- out[out$soc_id == "B79", ]
  expect_equal(r79$n_compared, 2)
  expect_equal(r79$n_match, 2) # both match
  expect_equal(r79$cult_distance, 0)
})

test_that("a named vector supplies a custom culture profile", {
  out <- get_cult_distance(
    c(B004 = "B004-2", B005 = "B005-1"), c("B73", "B79"),
    var_id = c("B004", "B005"), metric = "both"
  )
  expect_equal(out$n_match[out$soc_id == "B73"], 1)
  expect_equal(out$n_match[out$soc_id == "B79"], 2)

  expect_warning(
    get_cult_distance(
      c(B004 = "B004-2", NOTAVAR = "x"), c("B73", "B79"), var_id = "B004"
    ),
    "not in `var_id`"
  )
})

# Hand-worked scenario reused from test-get_pairwise_cult_distance.R:
#   SCCS202: SCCS11 = Flexible (SCCS202-2), SCCS12 = Rigid (SCCS202-1), SCCS3 = <missing>
#   SCCS10:  SCCS11 = Small Mammals (SCCS10-2), SCCS12 = Large Game (SCCS10-3), SCCS3 = Large Game (SCCS10-3)

test_that("modal = TRUE computes the mode from soc_id by default, with a tie warning", {
  expect_warning(
    out <- get_cult_distance(
      NULL, c("SCCS11", "SCCS12", "SCCS3"), var_id = c("SCCS202", "SCCS10"),
      modal = TRUE, metric = "both"
    ),
    "tied modal state"
  )
  # Modal profile: SCCS202 tied 1-1 between SCCS11/SCCS12 -> "SCCS202-1" (alphabetically
  # first); SCCS10 -> "SCCS10-3" (2 votes: SCCS12 and SCCS3)

  r11 <- out[out$soc_id == "SCCS11", ]
  expect_equal(r11$n_compared, 2)
  expect_equal(r11$n_match, 0) # mismatches both
  expect_equal(r11$cult_distance, 1)

  r12 <- out[out$soc_id == "SCCS12", ]
  expect_equal(r12$n_compared, 2)
  expect_equal(r12$n_match, 2) # matches both
  expect_equal(r12$cult_distance, 0)

  r3 <- out[out$soc_id == "SCCS3", ]
  expect_equal(r3$n_compared, 1) # SCCS202 excluded (SCCS3 missing it)
  expect_equal(r3$n_match, 1) # SCCS10 matches
  expect_equal(r3$cult_distance, 0)
})

test_that("mode_ref_soc_id computes the mode from a separate group", {
  # Reference group SCCS12 + SCCS3 only: SCCS202 has a single voter (SCCS12 ->
  # SCCS202-1, no tie); SCCS10 has 2 votes for SCCS10-3, no tie -- so no warning.
  out <- get_cult_distance(
    NULL, "SCCS11", var_id = c("SCCS202", "SCCS10"),
    modal = TRUE, mode_ref_soc_id = c("SCCS12", "SCCS3"), metric = "both"
  )
  expect_equal(out$n_compared, 2)
  expect_equal(out$n_match, 0) # SCCS11 mismatches the mode-group's profile on both
  expect_equal(out$cult_distance, 1)
})

test_that("modal = TRUE warns if `culture` is also supplied, and ignores it", {
  expect_warning(
    out <- get_cult_distance(
      "SCCS11", c("SCCS11", "SCCS12", "SCCS3"), var_id = c("SCCS202", "SCCS10"),
      modal = TRUE
    ),
    "ignored when modal"
  )
  expect_equal(nrow(out), 3)
})

test_that("metric controls which columns are returned", {
  out_prop <- get_cult_distance("B72", c("B73", "B79"), var_id = c("B004", "B005"))
  expect_named(out_prop, c("soc_id", "cult_distance"))

  out_sum <- get_cult_distance("B72", c("B73", "B79"), var_id = c("B004", "B005"), metric = "sum")
  expect_named(out_sum, c("soc_id", "n_match"))

  out_both <- get_cult_distance("B72", c("B73", "B79"), var_id = c("B004", "B005"), metric = "both")
  expect_named(out_both, c("soc_id", "n_match", "n_compared", "cult_distance"))
})

test_that("type_aware = TRUE scales ordinal variables by rank and range", {
  # B033 (ord range 1-4): B1 = 1, B294 = 2, B160 = 4
  out <- get_cult_distance("B1", c("B294", "B160"), var_id = "B033",
                            metric = "sum", type_aware = TRUE)
  expect_equal(out$n_match[out$soc_id == "B294"], 2 / 3, tolerance = 1e-8)
  expect_equal(out$n_match[out$soc_id == "B160"], 0, tolerance = 1e-8)
})

test_that("missing = 'complete' drops variables the culture lacks, then societies missing the rest", {
  expect_warning(
    expect_warning(
      out <- get_cult_distance(
        c(SCCS202 = "SCCS202-2"), c("SCCS11", "SCCS12", "SCCS3"),
        var_id = c("SCCS202", "SCCS10"), missing = "complete", metric = "both"
      ),
      "reference culture has no state"
    ),
    "SCCS3"
  )
  expect_equal(sort(out$soc_id), c("SCCS11", "SCCS12"))
  expect_equal(out$n_compared, c(1, 1))
  expect_equal(out$n_match[out$soc_id == "SCCS11"], 1) # matches SCCS202-2
  expect_equal(out$n_match[out$soc_id == "SCCS12"], 0) # SCCS202-1 mismatches
})

test_that("missing = 'match' treats missingness on either side as its own state", {
  out <- get_cult_distance(
    c(SCCS202 = "SCCS202-2"), c("SCCS11", "SCCS12", "SCCS3"),
    var_id = c("SCCS202", "SCCS10"), missing = "match", metric = "both"
  )
  # culture has no SCCS10 state at all -> mismatches every society's SCCS10 (present)
  r11 <- out[out$soc_id == "SCCS11", ]
  expect_equal(r11$n_compared, 2)
  expect_equal(r11$n_match, 1) # SCCS202 matches, SCCS10 mismatches (culture missing)
  expect_equal(r11$cult_distance, 0.5)

  r12 <- out[out$soc_id == "SCCS12", ]
  expect_equal(r12$n_compared, 2)
  expect_equal(r12$n_match, 0)
  expect_equal(r12$cult_distance, 1)

  r3 <- out[out$soc_id == "SCCS3", ]
  expect_equal(r3$n_compared, 2)
  expect_equal(r3$n_match, 0) # SCCS202: present vs missing; SCCS10: missing vs present
  expect_equal(r3$cult_distance, 1)
})

test_that("no variable in common gives NA distance and a warning", {
  expect_warning(
    out <- get_cult_distance("SCCS11", "SCCS3", var_id = "SCCS202"),
    "no variable in common"
  )
  expect_true(is.na(out$cult_distance))
})

test_that("duplicate society/variable observations in `culture` are collapsed with a warning", {
  expect_warning(
    out <- get_cult_distance("B1", "B10", var_id = c("B016", "B004")),
    "duplicate"
  )
  expect_equal(nrow(out), 1)
})
