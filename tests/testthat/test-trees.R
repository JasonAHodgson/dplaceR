test_that("dp_trees lists tree metadata without the nexus column", {
  out <- dp_trees()
  expect_s3_class(out, "tbl_df")
  expect_true(nrow(out) > 0)
  expect_false("nexus" %in% names(out))
})

test_that("dp_trees filters by tree_id and contribution_id", {
  out <- dp_trees(tree_id = "abkh1242")
  expect_equal(out$tree_id, "abkh1242")

  out2 <- dp_trees(contribution_id = "dplace-phylogeny-atkinson2006")
  expect_true(nrow(out2) > 0)
})

test_that("dp_tree errors for unknown or multiple tree_id", {
  expect_error(dp_tree("not-a-real-tree"), "No tree found")
  expect_error(dp_tree(c("abkh1242", "surm1244")), "single tree ID")
})

test_that("dp_tree(raw = TRUE) returns NEXUS text without requiring ape", {
  raw <- dp_tree("abkh1242", raw = TRUE)
  expect_type(raw, "character")
  expect_match(raw, "#NEXUS")
})

test_that("dp_tree() returns a parsed phylo object", {
  skip_if_not_installed("ape")
  tr <- dp_tree("abkh1242")
  expect_s3_class(tr, "phylo")
  expect_true(length(tr$tip.label) >= 2)
})
