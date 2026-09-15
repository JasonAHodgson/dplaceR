test_that("dp_variables returns all variables with no filters", {
  out <- dp_variables()
  expect_s3_class(out, "tbl_df")
  expect_true(nrow(out) > 1000)
})

test_that("dp_variables filters by category", {
  out <- dp_variables(category = "Subsistence")
  expect_true(nrow(out) > 0)
  expect_true(all(out$category == "Subsistence"))
})

test_that("dp_variables category supports contains() for compound category strings", {
  # "category" is often several topics joined with ", ", e.g.
  # "Economy, Property, Subsistence" -- an exact match on "Property" misses
  # those, but contains("Property") should catch them.
  exact <- dp_variables(category = "Property")
  partial <- dp_variables(category = contains("Property"))
  expect_true(nrow(partial) > nrow(exact))
  expect_true(all(grepl("Property", partial$category)))
  expect_true("B001" %in% partial$var_id) # category "Economy, Property, Subsistence"
})

test_that("dp_variables rejects contains() on type", {
  expect_error(dp_variables(type = contains("Cont")), "doesn't support contains")
})

test_that("dp_variables filters by type", {
  out <- dp_variables(type = "Continuous")
  expect_true(all(out$type == "Continuous"))
})

test_that("dp_variables filters by var_id", {
  out <- dp_variables(var_id = "B035")
  expect_equal(out$var_id, "B035")
})

test_that("dp_variables search is case-insensitive and matches description", {
  out_name <- dp_variables(search = "marriage")
  expect_true(nrow(out_name) > 0)

  out_upper <- dp_variables(search = "MARRIAGE")
  expect_equal(nrow(out_name), nrow(out_upper))
})

test_that("dp_search_variables matches dp_variables(search=)", {
  expect_equal(dp_search_variables("descent"), dp_variables(search = "descent"))
})
