test_that("get_society_country validates its input", {
  expect_error(get_society_country(character(0)), "at least one society")
})

test_that("get_society_country errors informatively without 'maps'", {
  skip_if(requireNamespace("maps", quietly = TRUE),
          "maps is installed; this tests the absent-package path")
  expect_error(get_society_country("B72"), "requires the 'maps' package")
})

test_that("get_society_country resolves known societies to their countries", {
  skip_if_not_installed("maps")
  # CCMCamha1245 = Amharic, at (11.7, 39.5) -- squarely in Ethiopia
  out <- get_society_country(c("B72", "CCMCamha1245"))
  expect_s3_class(out, "tbl_df")
  expect_named(out, c("soc_id", "country"))
  expect_equal(out$country[out$soc_id == "CCMCamha1245"], "Ethiopia")
})

test_that("unknown IDs and missing coordinates are dropped with a warning", {
  skip_if_not_installed("maps")
  expect_warning(
    out <- get_society_country(c("B72", "not-a-real-soc")),
    "not found"
  )
  expect_equal(nrow(out), 1)
})

test_that("coordinates the low-res map can't resolve warn and return NA", {
  skip_if_not_installed("maps")
  # B384 (Iglulik Inuit, far northern Canada) falls just outside every
  # polygon in maps::map("world")'s resolution.
  expect_warning(
    out <- get_society_country("B384"),
    "did not resolve to a country"
  )
  expect_true(is.na(out$country))
})
