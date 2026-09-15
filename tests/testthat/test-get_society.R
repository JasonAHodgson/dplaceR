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

test_that("xd_id filters by cross-dataset ID (with contains() support)", {
  # !Kung: B72, Aa1, SCCS2 all share xd1 across three datasets.
  out <- get_society(xd_id = "xd1")
  expect_setequal(out$soc_id, c("B72", "Aa1", "SCCS2"))

  out2 <- get_society(xd_id = contains("^xd1$"))
  expect_setequal(out2$soc_id, c("B72", "Aa1", "SCCS2"))

  expect_equal(nrow(get_society(xd_id = "not-a-real-xd-id")), 0)

  # combines with AND like the other exact-match filters
  out3 <- get_society(xd_id = "xd1", soc_id = "B72")
  expect_equal(out3$soc_id, "B72")
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

test_that("contains() switches region/soc_id/etc. to a partial match", {
  # D-PLACE has no region literally called "Africa", only sub-regions --
  # an exact match finds nothing, contains() finds all of them at once.
  expect_equal(nrow(get_society(region = "Africa")), 0)
  out <- get_society(region = contains("Africa"))
  expect_true(nrow(out) > 0)
  expect_true(all(grepl("Africa", out$region)))
  # every society matched this way must actually be a sub-region of Africa,
  # not some unrelated region that happens to contain the substring.
  expect_true(all(out$region %in% c(
    "Northern Africa", "Northeast Tropical Africa", "East Tropical Africa",
    "West Tropical Africa", "West-Central Tropical Africa",
    "South Tropical Africa", "Southern Africa"
  )))
})

test_that("contains() matches against ANY of several patterns (OR)", {
  out <- get_society(region = contains(c("Africa", "Asia")))
  expect_true(any(grepl("Africa", out$region)))
  expect_true(any(grepl("Asia", out$region, ignore.case = TRUE)))
  # contains() is case-insensitive by default, so this also picks up
  # "Papuasia" (which contains "asia" as a substring) -- a real, if
  # slightly surprising, consequence of the default rather than a bug.
  expect_true(all(grepl("Africa", out$region) | grepl("Asia", out$region, ignore.case = TRUE)))
})

test_that("contains() supports regex patterns, e.g. on soc_id", {
  out <- get_society(soc_id = contains("^CARNEIRO4_00"), type = NULL)
  expect_true(nrow(out) > 0)
  expect_true(all(grepl("^CARNEIRO4_00", out$soc_id)))
})

test_that("contains() is case-insensitive by default, and can be made case-sensitive", {
  out_default <- get_society(region = contains("africa"))
  out_ci <- get_society(region = contains("africa", ignore.case = TRUE))
  out_cs <- get_society(region = contains("africa", ignore.case = FALSE))

  expect_equal(nrow(out_default), nrow(out_ci))
  expect_true(nrow(out_ci) > 0)
  expect_equal(nrow(out_cs), 0) # D-PLACE's region values are capitalized
})

test_that("contains() combines with AND across other filters, like exact matches do", {
  out <- get_society(region = contains("Africa"), glottocode = "juho1239")
  expect_true(all(grepl("Africa", out$region)))
  expect_true(all(out$glottocode == "juho1239"))
})

test_that("contains() is rejected on arguments that don't support it", {
  expect_error(get_society(type = contains("society")), "doesn't support contains")
  expect_error(get_society(name = contains("kung")), "doesn't support contains")
  expect_error(get_society(country = contains("Ethiopia")), "doesn't support contains")
})
