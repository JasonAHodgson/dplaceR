# Reuses the same fixtures as test-get_language_distance.R: B65 (Mbuti,
# bila1255), B62 (Bambote, holo1240), CARNEIRO4_011 (Ganda, gand1255) are all
# on the same bundled tree (atla1278, Atlantic-Congo); B72 is on a different
# tree; B284 has no tree match at all.

test_that("get_lang_clade returns societies for a Bantu clade defined by Zulu + Ganda", {
  out <- get_lang_clade(c("zulu1248", "gand1255"))
  expect_s3_class(out, "tbl_df")
  expect_true(nrow(out) > 0)
  expect_true(all(out$type == "society"))
  # both seeds themselves should be included
  expect_true(all(c("zulu1248", "gand1255") %in% out$glottocode))
  # a known non-Bantu Atlantic-Congo language should NOT be included
  expect_false("yoru1245" %in% out$glottocode)
})

test_that("get_lang_clade accepts a mix of society IDs and Glottocodes, with the same result", {
  by_glottocode <- get_lang_clade(c("zulu1248", "gand1255"))
  by_soc_id <- get_lang_clade(c("CARNEIRO4_011", "zulu1248"))
  expect_setequal(by_glottocode$soc_id, by_soc_id$soc_id)
})

test_that("get_lang_clade requires at least two distinct seeds", {
  expect_error(get_lang_clade("zulu1248"), "at least two distinct")
  expect_error(get_lang_clade(c("zulu1248", "zulu1248")), "at least two distinct")
})

test_that("get_lang_clade rejects a non-character `seed`", {
  expect_error(get_lang_clade(1:2), "character vector")
})

test_that("get_lang_clade errors when seeds resolve to different trees", {
  expect_error(
    get_lang_clade(c("B65", "B72")),
    "resolve to different language trees"
  )
})

test_that("get_lang_clade propagates an informative error for a seed with no tree match", {
  expect_error(get_lang_clade(c("B65", "B284")), "no language classification")
})

test_that("get_lang_clade warns when the clade spans the seeds' entire family tree", {
  tr <- dp_tree("atla1278")
  extreme_seeds <- c(tr$tip.label[1], tr$tip.label[length(tr$tip.label)])
  expect_warning(
    out <- get_lang_clade(extreme_seeds),
    "spans the seeds' entire top-level family tree"
  )
  expect_true(nrow(out) > 0)
})

test_that("get_lang_clade's `type` argument is passed through to dp_societies", {
  out_default <- get_lang_clade(c("zulu1248", "gand1255"))
  out_all <- get_lang_clade(c("zulu1248", "gand1255"), type = NULL)
  expect_true(all(out_default$type == "society"))
  expect_true(nrow(out_all) >= nrow(out_default))
})
