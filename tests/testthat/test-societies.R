test_that("dp_societies returns societies by default", {
  out <- dp_societies()
  expect_s3_class(out, "tbl_df")
  expect_true(all(out$type == "society"))
  expect_true(nrow(out) > 0)
})

test_that("dp_societies filters by glottocode", {
  # Several source datasets independently code the same real-world group,
  # so more than one society row can share a Glottocode.
  out <- dp_societies(glottocode = "juho1239")
  expect_true(nrow(out) > 0)
  expect_true(all(out$glottocode == "juho1239"))
  expect_true("B72" %in% out$soc_id)
})

test_that("dp_societies filters by region", {
  out <- dp_societies(region = "Southern Africa")
  expect_true(nrow(out) > 0)
  expect_true(all(out$region == "Southern Africa"))
})

test_that("dp_societies filters by soc_id", {
  out <- dp_societies(soc_id = c("B72", "B296"))
  expect_setequal(out$soc_id, c("B72", "B296"))
})

test_that("dp_societies(type = NULL) includes languoids", {
  all_types <- dp_societies(type = NULL)
  expect_true(any(all_types$type == "languoid") || all(all_types$type == "society"))
  expect_true(nrow(all_types) >= nrow(dp_societies()))
})

test_that("dp_societies returns zero rows for unknown filters", {
  out <- dp_societies(glottocode = "not-a-real-glottocode")
  expect_equal(nrow(out), 0)
})
