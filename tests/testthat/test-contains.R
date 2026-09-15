test_that("contains() validates its input", {
  expect_error(contains(123), "non-missing character vector")
  expect_error(contains(NA_character_), "non-missing character vector")
  expect_error(contains(character(0)), "non-missing character vector")
})

test_that("contains() returns a dplaceR_contains object carrying its options", {
  out <- contains("Africa")
  expect_s3_class(out, "dplaceR_contains")
  expect_equal(out$pattern, "Africa")
  expect_true(out$ignore.case)
  expect_false(out$fixed)

  out2 <- contains(c("Africa", "Asia"), ignore.case = FALSE, fixed = TRUE)
  expect_equal(out2$pattern, c("Africa", "Asia"))
  expect_false(out2$ignore.case)
  expect_true(out2$fixed)
})
