test_that(".gs_coerce_ids passes through NULL and non-data-frame input unchanged", {
  expect_null(.gs_coerce_ids(NULL, "soc_id", "soc_id"))
  expect_identical(.gs_coerce_ids(c("B72", "B296"), "soc_id", "soc_id"), c("B72", "B296"))
})

test_that(".gs_coerce_ids extracts the named column from a data frame/tibble", {
  df <- data.frame(soc_id = c("B72", "B296"), other = 1:2)
  expect_identical(.gs_coerce_ids(df, "soc_id", "soc_id"), c("B72", "B296"))

  tbl <- tibble::tibble(var_id = c("B001", "B004"))
  expect_identical(.gs_coerce_ids(tbl, "var_id", "var_id"), c("B001", "B004"))
})

test_that(".gs_coerce_ids errors clearly if the data frame lacks the expected column", {
  df <- data.frame(name = c("a", "b"))
  expect_error(.gs_coerce_ids(df, "soc_id", "soc_id"), "no `soc_id` column")
  expect_error(.gs_coerce_ids(df, "soc_id", "soc_id"), "soc_id = your_data\\$soc_id")
})

test_that("dp_societies accepts a data frame/tibble for soc_id, using its soc_id column", {
  socs <- dp_societies(region = "Southern Africa")
  out_df <- dp_societies(soc_id = socs)
  out_vec <- dp_societies(soc_id = socs$soc_id)
  expect_identical(out_df, out_vec)
  expect_setequal(out_df$soc_id, socs$soc_id)
})

test_that("dp_societies errors clearly if soc_id is a data frame with no soc_id column", {
  no_id_col <- data.frame(name = c("a", "b"))
  expect_error(dp_societies(soc_id = no_id_col), "no `soc_id` column")
})

test_that("get_cult_distance accepts data frames/tibbles for soc_id and var_id", {
  socs <- dp_societies(soc_id = c("B72", "B296", "B76"))
  vars <- dp_variables(category = contains("Subsistence"))

  out_df <- suppressWarnings(get_cult_distance(soc_id = socs, var_id = vars, modal = TRUE))
  out_vec <- suppressWarnings(get_cult_distance(soc_id = socs$soc_id, var_id = vars$var_id, modal = TRUE))
  expect_identical(out_df, out_vec)
})

test_that("get_cultural_FST accepts data frames/tibbles for soc_id and var_id", {
  socs <- dp_societies(lang_family = c("Indo-European", "Afro-Asiatic"))
  vars <- dp_variables(category = contains("Subsistence"))

  out_df <- suppressWarnings(get_cultural_FST(soc_id = socs, group = "lang_family", var_id = vars))
  out_vec <- suppressWarnings(get_cultural_FST(soc_id = socs$soc_id, group = "lang_family", var_id = vars$var_id))
  expect_identical(out_df, out_vec)
})
