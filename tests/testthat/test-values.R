test_that("dp_values filters by var_id and soc_id", {
  by_var <- dp_values(var_id = "B035")
  expect_true(nrow(by_var) > 0)
  expect_true(all(by_var$var_id == "B035"))

  by_both <- dp_values(var_id = "B035", soc_id = "B1")
  expect_equal(nrow(by_both), 1)
  expect_equal(by_both$soc_id, "B1")
})

test_that("dp_variable_data joins code labels and society info", {
  out <- dp_variable_data("B035")
  expect_s3_class(out, "tbl_df")
  expect_true(all(c("soc_id", "var_id", "value", "code_id", "code_label",
                     "society_name", "latitude", "longitude", "glottocode") %in% names(out)))
  expect_equal(nrow(out), nrow(dp_values(var_id = "B035")))

  b1 <- out[out$soc_id == "B1", ]
  expect_equal(b1$code_label, "Endogamous demed")
})

test_that("dp_variable_data can skip society info", {
  out <- dp_variable_data("B035", society_info = FALSE)
  expect_false("society_name" %in% names(out))
})
