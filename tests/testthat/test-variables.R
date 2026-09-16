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

test_that("dp_variables accepts a data frame/tibble for var_id, using its var_id column", {
  # A common mistake: passing a dp_variables() result straight through
  # instead of its `var_id` column -- this used to silently match nothing;
  # now the column is used automatically.
  vars <- dp_variables(category = "Subsistence")
  out_df <- dp_variables(var_id = vars)
  out_vec <- dp_variables(var_id = vars$var_id)
  expect_identical(out_df, out_vec)
  expect_equal(nrow(out_df), nrow(vars))
})

test_that("dp_variables errors clearly if var_id is a data frame with no var_id column", {
  no_id_col <- data.frame(name = c("a", "b"))
  expect_error(dp_variables(var_id = no_id_col), "no `var_id` column")
})

test_that("dp_variables errors clearly if var_id is some other non-character type", {
  expect_error(dp_variables(var_id = 1:3), "must be a character vector")
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

test_that("dp_search_variables(type=) matches dp_variables(search=, type=)", {
  expect_equal(
    dp_search_variables("descent", type = "Categorical"),
    dp_variables(search = "descent", type = "Categorical")
  )
})

test_that("dp_search_variables rejects contains() on type", {
  expect_error(dp_search_variables("descent", type = contains("Cat")), "doesn't support contains")
})
