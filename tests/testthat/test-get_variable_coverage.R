# Fixtures (checked against dplace_values directly):
# soc_id = B72, B73, B79, B100, B101 (n_total = 5)
#   B004: every one of the 5 has a real (non-sentinel) "Gathering" value
#         -> n_coded = 5, pct_coded = 100
#   B017: only B72 has a real value ("Small extended", code B017-7);
#         B73/B79/B100/B101 all carry D-PLACE's missing-data sentinel
#         (code_id "B017-NA") instead -> n_coded = 1, pct_coded = 20

fixture_soc <- c("B72", "B73", "B79", "B100", "B101")

test_that("get_variable_coverage counts real (non-sentinel) coverage correctly", {
  cov <- get_variable_coverage(fixture_soc, var_id = c("B004", "B017"))
  expect_setequal(cov$var_id, c("B004", "B017"))
  expect_equal(cov$n_total, c(5, 5))

  b004 <- cov[cov$var_id == "B004", ]
  expect_equal(b004$n_coded, 5)
  expect_equal(b004$pct_coded, 100)

  b017 <- cov[cov$var_id == "B017", ]
  expect_equal(b017$n_coded, 1)
  expect_equal(b017$pct_coded, 20)
})

test_that("get_variable_coverage sorts by decreasing coverage", {
  cov <- get_variable_coverage(fixture_soc, var_id = c("B004", "B017"))
  expect_equal(cov$var_id, c("B004", "B017"))
})

test_that("get_variable_coverage defaults to every variable when no filter is given", {
  cov_all <- get_variable_coverage(fixture_soc)
  expect_equal(nrow(cov_all), nrow(dp_variables()))
  expect_true(all(c("B004", "B017") %in% cov_all$var_id))
})

test_that("get_variable_coverage's var_id/category/type/search filters match dp_variables()", {
  cov <- get_variable_coverage(fixture_soc, category = contains("Subsistence"))
  expect_setequal(cov$var_id, dp_variables(category = contains("Subsistence"))$var_id)
})

test_that("get_variable_coverage filters by min_pct", {
  cov <- get_variable_coverage(fixture_soc, var_id = c("B004", "B017"), min_pct = 50)
  expect_equal(cov$var_id, "B004")

  cov_none <- get_variable_coverage(fixture_soc, var_id = c("B004", "B017"), min_pct = 100.1 - 0.1)
  expect_true(all(cov_none$pct_coded >= 100))
})

test_that("get_variable_coverage validates min_pct", {
  expect_error(get_variable_coverage(fixture_soc, min_pct = -1), "between 0 and 100")
  expect_error(get_variable_coverage(fixture_soc, min_pct = 101), "between 0 and 100")
  expect_error(get_variable_coverage(fixture_soc, min_pct = c(10, 20)), "single number")
  expect_error(get_variable_coverage(fixture_soc, min_pct = "a"), "single number")
})

test_that("get_variable_coverage validates soc_id", {
  expect_error(get_variable_coverage(character(0)), "at least one society")
  expect_error(
    get_variable_coverage("not-a-real-soc-id"),
    "None of the requested society IDs were found"
  )
})

test_that("get_variable_coverage drops unknown society IDs with a warning", {
  expect_warning(
    cov <- get_variable_coverage(c(fixture_soc, "not-a-real-soc-id"), var_id = "B004"),
    "Society ID\\(s\\) not found, dropped: not-a-real-soc-id"
  )
  expect_equal(cov$n_total, 5)
})

test_that("get_variable_coverage drops unknown variable IDs with a warning", {
  expect_warning(
    cov <- get_variable_coverage(fixture_soc, var_id = c("B004", "not-a-real-var")),
    "Variable ID\\(s\\) not found, dropped: not-a-real-var"
  )
  expect_equal(cov$var_id, "B004")
})

test_that("get_variable_coverage errors when no variables match the given filters", {
  expect_error(
    get_variable_coverage(fixture_soc, category = "not-a-real-category"),
    "No variables matched"
  )
})

test_that("get_variable_coverage accepts a data frame/tibble with a soc_id column", {
  soc_df <- dp_societies(soc_id = fixture_soc, type = NULL)
  cov_from_df <- get_variable_coverage(soc_df, var_id = "B004")
  cov_from_vec <- get_variable_coverage(fixture_soc, var_id = "B004")
  expect_identical(cov_from_df, cov_from_vec)
})

test_that("get_variable_coverage deduplicates soc_id", {
  cov <- get_variable_coverage(c(fixture_soc, fixture_soc), var_id = "B004")
  expect_equal(cov$n_total, 5)
})
