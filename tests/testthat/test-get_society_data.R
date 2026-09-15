test_that("get_society_data requires at least one variable-selection criterion", {
  expect_error(
    get_society_data(soc_id = "B72"),
    "Supply at least one of `var_id`, `category`, `type`, or `search`"
  )
})

test_that("get_society_data errors on unmatched soc_id/var_id with nothing left", {
  # A wholly-unmatched soc_id/var_id also warns (see the next test); silence
  # that here since it's not what this test is checking.
  expect_error(
    suppressWarnings(get_society_data(soc_id = "NOPE", var_id = "B001")),
    "No societies matched"
  )
  expect_error(
    suppressWarnings(get_society_data(soc_id = "B72", var_id = "NOPE")),
    "No variables matched"
  )
})

test_that("get_society_data warns on unmatched but non-empty soc_id/var_id", {
  expect_warning(
    get_society_data(soc_id = c("B72", "NOPE"), var_id = "B001"),
    "soc_id value\\(s\\) not found: NOPE"
  )
  expect_warning(
    get_society_data(soc_id = "B72", var_id = c("B001", "NOPE2")),
    "var_id value\\(s\\) not present in the matched variable set: NOPE2"
  )
})

test_that("get_society_data long format matches dp_variable_data-style values", {
  out <- get_society_data(soc_id = c("B72", "B73", "B79"), var_id = c("B001", "B004"))

  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 6)
  expect_true(all(c(
    "soc_id", "var_id", "var_name", "var_category", "var_type", "value",
    "code_id", "code_label", "year", "source", "society_name", "latitude",
    "longitude", "glottocode", "region"
  ) %in% names(out)))

  # B004 (categorical, "Subsistence economy: Most important activity") is
  # recorded as "Gathering" for all three societies.
  expect_true(all(out$code_label[out$var_id == "B004"] == "Gathering"))
  expect_true(all(out$var_type[out$var_id == "B004"] == "Categorical"))

  # B001 (continuous) values, checked against dp_values() directly.
  b001 <- out[out$var_id == "B001", ]
  expect_equal(b001$value[b001$soc_id == "B72"], "67")
  expect_equal(b001$value[b001$soc_id == "B73"], "67")
  expect_equal(b001$value[b001$soc_id == "B79"], "70")
})

test_that("get_society_data long format does not collapse duplicate observations", {
  # B160/B015 has two raw observations (see dp_values("B015", "B160")).
  out <- get_society_data(soc_id = "B160", var_id = "B015")
  expect_equal(nrow(out), 2)
})

test_that("get_society_data wide format: one row per society, one column per var_id", {
  out <- get_society_data(
    soc_id = c("B72", "B73", "B79"), var_id = c("B001", "B004"), format = "wide"
  )

  expect_equal(nrow(out), 3)
  expect_true(all(c("B001", "B004") %in% names(out)))

  # B001 is Continuous -> numeric column, correct values per society.
  expect_true(is.numeric(out$B001))
  expect_equal(out$B001[out$soc_id == "B72"], 67)
  expect_equal(out$B001[out$soc_id == "B73"], 67)
  expect_equal(out$B001[out$soc_id == "B79"], 70)

  # B004 is Categorical -> human-readable code label, not raw code_id.
  expect_true(is.character(out$B004))
  expect_true(all(out$B004 == "Gathering"))
})

test_that("get_society_data wide format collapses duplicates (most recent year wins)", {
  # B160/B015: value 6 @ year 1860 and value 4 @ year 1855 -- most recent wins.
  expect_warning(
    out <- get_society_data(soc_id = "B160", var_id = "B015", format = "wide"),
    "duplicate society/variable observation"
  )
  expect_equal(out$B015, 6)
})

test_that("get_society_data society_info = FALSE omits society metadata columns", {
  out <- get_society_data(soc_id = "B72", var_id = "B001", society_info = FALSE)
  expect_false(any(c("society_name", "latitude", "longitude", "glottocode", "region") %in% names(out)))

  out_wide <- get_society_data(soc_id = "B72", var_id = "B001", format = "wide", society_info = FALSE)
  expect_equal(names(out_wide), c("soc_id", "B001"))
})

test_that("get_society_data combines category (with contains()), type, and soc_id", {
  # category = contains("Property") & type = "Continuous" -> B001/B002/B003.
  out <- get_society_data(
    soc_id = c("B72", "B73"), category = contains("Property"), type = "Continuous",
    format = "wide"
  )
  var_cols <- setdiff(names(out), c("soc_id", "society_name", "latitude", "longitude", "glottocode", "region"))
  expect_setequal(var_cols, c("B001", "B002", "B003"))
})

test_that("get_society_data search restricts variables like dp_search_variables()", {
  # Only variables matching the search term are ever looked up -- SCCS1's
  # actual result is whichever of those it has recorded data for, a subset.
  out <- get_society_data(soc_id = "SCCS1", search = "descent")
  expect_true(nrow(out) > 0)
  expect_true(all(unique(out$var_id) %in% dp_search_variables("descent")$var_id))
})

test_that("get_society_data defaults to every society with coded data when soc_id is omitted", {
  out <- get_society_data(var_id = "B004", format = "wide")
  expect_equal(nrow(out), nrow(dp_societies()))
})
