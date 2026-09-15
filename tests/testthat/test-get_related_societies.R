test_that("get_related_societies validates its inputs", {
  expect_error(get_related_societies(character(0)), "at least one society")
  expect_error(get_related_societies(c("B72", "B72")), "duplicate")
})

test_that("get_related_societies finds societies sharing an xd_id", {
  # !Kung: B72 (Binford), Aa1 (Ethnographic Atlas), SCCS2 (SCCS) all share xd1.
  out <- get_related_societies("B72")
  expect_s3_class(out, "tbl_df")
  expect_equal(names(out), c("soc_id", "xd_id", "related_soc_id", "related_name", "related_contribution_id"))
  expect_true(all(out$soc_id == "B72"))
  expect_true(all(out$xd_id == "xd1"))
  expect_setequal(out$related_soc_id, c("Aa1", "SCCS2"))
  expect_true(all(out$related_name == "!Kung"))
})

test_that("get_related_societies warns and drops unknown society IDs", {
  # The warning and the subsequent error both fire in the same call, so
  # they must be captured together (expect_warning() alone would see the
  # error propagate past it uncaught).
  expect_warning(
    expect_error(
      get_related_societies("not-a-real-soc"),
      "None of the requested society IDs were found"
    ),
    "Society ID"
  )
})

test_that("get_related_societies warns and skips societies with no xd_id", {
  # CARNEIRO4_001 has no cross-dataset ID at all -- again a warning and an
  # error from the same call, captured together.
  expect_warning(
    expect_error(
      get_related_societies("CARNEIRO4_001"),
      "None of the requested societies have a cross-dataset ID"
    ),
    "no cross-dataset ID"
  )
})

test_that("get_related_societies warns and returns zero rows for a singleton xd_id", {
  # Ab1's xd_id (xd10) currently has no other society sharing it.
  expect_warning(
    out <- get_related_societies("Ab1"),
    "no other society"
  )
  expect_equal(nrow(out), 0)
  expect_equal(names(out), c("soc_id", "xd_id", "related_soc_id", "related_name", "related_contribution_id"))
})

test_that("get_related_societies handles a mix of linked/unlinked/singleton societies", {
  ws <- character(0)
  out <- withCallingHandlers(
    get_related_societies(c("B72", "CARNEIRO4_001", "Ab1")),
    warning = function(w) { ws <<- c(ws, conditionMessage(w)); invokeRestart("muffleWarning") }
  )
  expect_true(any(grepl("no cross-dataset ID", ws)))
  expect_true(any(grepl("no other society", ws)))
  expect_equal(nrow(out), 2) # just B72's two relatives
  expect_setequal(out$related_soc_id, c("Aa1", "SCCS2"))
})

test_that("get_related_societies is queryable per input society with multiple inputs", {
  out <- suppressWarnings(get_related_societies(c("B72", "B73")))
  expect_setequal(unique(out$soc_id), c("B72", "B73"))
  expect_equal(out$related_soc_id[out$soc_id == "B73"], "Aa7")
})
