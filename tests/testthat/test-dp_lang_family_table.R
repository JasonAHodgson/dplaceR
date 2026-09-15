test_that("dp_lang_family_table returns one row per family, in dp_lang_family_list() order", {
  out <- dp_lang_family_table()
  expect_s3_class(out, "tbl_df")
  expect_equal(names(out), c("lang_family", "n_societies"))
  expect_identical(out$lang_family, dp_lang_family_list())
})

test_that("dp_lang_family_table counts match dp_societies() row counts per family", {
  out <- dp_lang_family_table()
  # Societies with no lang_family (no glottocode) aren't counted anywhere
  # here, so the total can be slightly less than the full society count.
  expect_equal(sum(out$n_societies), sum(!is.na(dp_societies()$lang_family)))
  expect_equal(
    out$n_societies[out$lang_family == "Indo-European"],
    nrow(dp_societies(lang_family = "Indo-European"))
  )
  expect_equal(
    out$n_societies[out$lang_family == "Zuni"],
    nrow(dp_societies(lang_family = "Zuni"))
  )
})
