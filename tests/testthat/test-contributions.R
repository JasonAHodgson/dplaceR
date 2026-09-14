test_that("dp_contributions returns all rows with no filters", {
  out <- dp_contributions()
  expect_s3_class(out, "tbl_df")
  expect_true(nrow(out) > 0)
})

test_that("dp_contributions filters by contribution_id", {
  out <- dp_contributions(contribution_id = "dplace-dataset-binford")
  expect_equal(out$contribution_id, "dplace-dataset-binford")
})

test_that("dp_citation prints and returns dplace_meta invisibly", {
  expect_output(result <- dp_citation(), "D-PLACE")
  expect_equal(result, dplace_meta)
})
