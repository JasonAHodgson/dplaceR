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

test_that("dp_societies supports contains() on region/soc_id/glottocode", {
  expect_equal(nrow(dp_societies(region = "Africa")), 0) # no exact-match region called "Africa"

  out <- dp_societies(region = contains("Africa"))
  expect_true(nrow(out) > 0)
  expect_true(all(grepl("Africa", out$region)))

  out2 <- dp_societies(soc_id = contains("^CARNEIRO4_00"))
  expect_true(nrow(out2) > 0)
  expect_true(all(grepl("^CARNEIRO4_00", out2$soc_id)))
})

test_that("dp_societies rejects contains() on type", {
  expect_error(dp_societies(type = contains("society")), "doesn't support contains")
})

test_that("dp_societies filters by xd_id (with contains() support)", {
  # !Kung: B72, Aa1, SCCS2 all share xd1 across three datasets.
  out <- dp_societies(xd_id = "xd1")
  expect_setequal(out$soc_id, c("B72", "Aa1", "SCCS2"))

  out2 <- dp_societies(xd_id = contains("^xd1$"))
  expect_setequal(out2$soc_id, c("B72", "Aa1", "SCCS2"))

  expect_equal(nrow(dp_societies(xd_id = "not-a-real-xd-id")), 0)
})

test_that("dp_societies filters by lang_family/lang_family_id (with contains() support)", {
  out <- dp_societies(lang_family = "Indo-European")
  expect_true(nrow(out) > 0)
  expect_true(all(out$lang_family == "Indo-European"))
  expect_true(all(out$lang_family_id == "indo1319"))

  out2 <- dp_societies(lang_family_id = "indo1319")
  expect_identical(sort(out$soc_id), sort(out2$soc_id))

  out3 <- dp_societies(lang_family = contains("Austro"))
  expect_setequal(out3$lang_family, c("Austroasiatic", "Austronesian"))

  # An isolate is its own top-level family.
  out4 <- dp_societies(lang_family = "Zuni")
  expect_true(nrow(out4) > 0)
  expect_true(all(out4$lang_family_id == "zuni1245"))

  expect_equal(nrow(dp_societies(lang_family = "not-a-real-family")), 0)
})
