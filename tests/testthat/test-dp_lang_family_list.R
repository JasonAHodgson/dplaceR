test_that("dp_lang_family_list returns a sorted vector of every distinct family", {
  out <- dp_lang_family_list()
  expect_type(out, "character")
  expect_false(anyDuplicated(out) > 0)
  expect_identical(out, sort(out))
  expect_identical(out, sort(unique(dp_societies()$lang_family)))
  expect_false(anyNA(out))

  # Spot-check a couple of well-known families are present.
  expect_true(all(c("Indo-European", "Austronesian", "Afro-Asiatic") %in% out))
  # An isolate is its own top-level family.
  expect_true("Zuni" %in% out)
})
