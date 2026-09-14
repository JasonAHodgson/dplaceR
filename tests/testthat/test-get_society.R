test_that("get_society defaults to type = 'society' and no filters returns all societies", {
  out <- get_society()
  expect_equal(nrow(out), nrow(get_society(type = "society")))
  expect_true(all(out$type == "society"))
})

test_that("exact-match filters work and combine with AND", {
  out <- get_society(soc_id = c("B72", "B73"))
  expect_equal(sort(out$soc_id), c("B72", "B73"))

  # glottocode alone isn't unique -- several society records (from different
  # contributions/datasets) can share one glottocode (e.g. several !Kung
  # codings all point at glottocode "juho1239"). soc_id + glottocode
  # together narrow to a single row.
  out <- get_society(soc_id = "B72", glottocode = "juho1239")
  expect_equal(out$soc_id, "B72")

  out <- get_society(region = "Southern Africa", glottocode = "juho1239")
  expect_true("B72" %in% out$soc_id)
  expect_true(all(out$region == "Southern Africa"))
  expect_true(all(out$glottocode == "juho1239"))

  out <- get_society(region = "not-a-real-region")
  expect_equal(nrow(out), 0)
})

test_that("name does a case-insensitive partial match", {
  out <- get_society(name = "kung")
  expect_true("B72" %in% out$soc_id)
  expect_true(all(grepl("kung", out$name, ignore.case = TRUE)))
})

test_that("numeric args accept a single exact value or a c(min, max) range", {
  out <- get_society(main_focal_year = 1950)
  expect_true(all(out$main_focal_year == 1950))
  expect_true("B72" %in% out$soc_id)

  out <- get_society(latitude = c(-25, -15), longitude = c(15, 25))
  expect_true("B72" %in% out$soc_id)
  expect_true(all(out$latitude >= -25 & out$latitude <= -15))

  expect_error(get_society(latitude = c(1, 2, 3)), "single numeric value or")
})

test_that("country filters via get_society_country(), applied after other filters", {
  skip_if_not_installed("maps")
  # Run on the whole default (type = "society") set of 2599 societies, so
  # get_society_country() is expected to warn about the ~89 that don't
  # resolve to any mapped country (Arctic/remote coordinates etc.) --
  # that's the documented, expected behaviour of the underlying helper,
  # not something this test is checking.
  out <- suppressWarnings(get_society(country = "Ethiopia"))
  expect_true(nrow(out) > 0)
  expect_true(all(out$country == "Ethiopia"))
  expect_true("CCMCamha1245" %in% out$soc_id)

  # combined with another filter -- narrows further, still AND semantics.
  # glottocode "amha1245" (Amharic) matches 3 society records, and they're
  # all in Ethiopia, so soc_id narrows to a single one instead.
  out2 <- suppressWarnings(get_society(country = "Ethiopia", soc_id = "CCMCamha1245"))
  expect_equal(out2$soc_id, "CCMCamha1245")

  out3 <- suppressWarnings(get_society(country = "not-a-real-country"))
  expect_equal(nrow(out3), 0)
})

test_that("country matching is case-insensitive", {
  skip_if_not_installed("maps")
  out <- suppressWarnings(get_society(country = "ethiopia", soc_id = "CCMCamha1245"))
  expect_equal(out$soc_id, "CCMCamha1245")
})

test_that("country errors informatively without 'maps'", {
  skip_if(requireNamespace("maps", quietly = TRUE),
          "maps is installed; this tests the absent-package path")
  expect_error(get_society(country = "Ethiopia"), "requires the 'maps' package")
})
