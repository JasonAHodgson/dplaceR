test_that("dp_codes returns codes ordered by ord", {
  out <- dp_codes("B035")
  expect_s3_class(out, "tbl_df")
  expect_true(nrow(out) > 0)
  expect_equal(out$ord, sort(out$ord))
})

test_that("dp_codes warns for variables with no codes", {
  expect_warning(dp_codes("not-a-real-var-id"), "No codes found")
})

test_that("dp_codes handles a mix of valid and invalid var_id", {
  expect_warning(out <- dp_codes(c("B035", "not-a-real-var-id")), "No codes found")
  expect_true(all(out$var_id == "B035"))
})
