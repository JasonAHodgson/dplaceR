test_that("get_society_meta validates `data`", {
  expect_error(get_society_meta(c("B72", "B73")), "must be a data frame")
})

test_that("no metadata requested returns `data` unchanged, with a message", {
  d <- tibble::tibble(soc_id = c("B72", "B73"))
  expect_message(out <- get_society_meta(d), "No metadata columns selected")
  expect_equal(out, tibble::as_tibble(d))
})

test_that("auto-detects a single `soc_id` column and appends unsuffixed metadata", {
  d <- tibble::tibble(soc_id = c("B72", "B73", "B79"), distance_km = c(1, 2, 3))
  out <- get_society_meta(d, name = TRUE, region = TRUE)

  expect_named(out, c("soc_id", "distance_km", "name", "region"))
  expect_equal(out$name, c("!Kung", "Naron", "/Xam"))
  expect_equal(out$region, rep("Southern Africa", 3))
  # original column and row order preserved
  expect_equal(out$distance_km, c(1, 2, 3))
})

test_that("auto-detects `soc_id_1`/`soc_id_2` and suffixes appended metadata", {
  d <- tibble::tibble(soc_id_1 = "B72", soc_id_2 = "B73", distance_km = 5)
  out <- get_society_meta(d, latitude = TRUE, longitude = TRUE)

  expect_named(out, c("soc_id_1", "soc_id_2", "distance_km",
                       "latitude_1", "longitude_1", "latitude_2", "longitude_2"))
  expect_equal(out$latitude_1, -20)
  expect_equal(out$longitude_1, 21.2, tolerance = 0.01)
  expect_equal(out$latitude_2, -21.6, tolerance = 0.01)
  expect_equal(out$longitude_2, 21.6, tolerance = 0.01)
})

test_that("errors if no ID column is found and `id_cols` isn't given", {
  d <- tibble::tibble(x = "B72")
  expect_error(get_society_meta(d, name = TRUE), "Could not find a society ID column")
})

test_that("`id_cols` can name a custom column, suffixing metadata with its name", {
  d <- tibble::tibble(society = c("B72", "B73"))
  out <- get_society_meta(d, id_cols = "society", name = TRUE)
  expect_named(out, c("society", "name_society"))
  expect_equal(out$name_society, c("!Kung", "Naron"))

  expect_error(
    get_society_meta(d, id_cols = "not_a_col", name = TRUE),
    "`id_cols` not found"
  )
})

test_that("unmatched IDs get NA metadata, with a warning", {
  d <- tibble::tibble(soc_id = c("B72", "not-a-real-soc", NA))
  expect_warning(
    out <- get_society_meta(d, name = TRUE),
    "did not match a known society ID"
  )
  expect_equal(out$name, c("!Kung", NA, NA))
})

test_that("overwriting an existing column warns", {
  d <- tibble::tibble(soc_id = "B72", name = "placeholder")
  expect_warning(
    out <- get_society_meta(d, name = TRUE),
    "already exists"
  )
  expect_equal(out$name, "!Kung")
})

test_that("all ten metadata columns can be requested at once", {
  d <- tibble::tibble(soc_id = "B72")
  out <- get_society_meta(
    d, name = TRUE, latitude = TRUE, longitude = TRUE, glottocode = TRUE,
    iso_code = TRUE, region = TRUE, type = TRUE, main_focal_year = TRUE,
    language_level_glottocodes = TRUE, contribution_id = TRUE
  )
  expect_named(out, c(
    "soc_id", "name", "latitude", "longitude", "glottocode", "iso_code",
    "region", "type", "main_focal_year", "language_level_glottocodes",
    "contribution_id"
  ))
})
