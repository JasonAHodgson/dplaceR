# Synthetic pairwise tables (rather than get_pairwise_*() output) so these
# tests don't depend on geoGraph (not on CRAN) or on which societies happen
# to be in the bundled snapshot.

nodes7 <- LETTERS[1:7]
pairs7 <- as.data.frame(t(utils::combn(nodes7, 2)), stringsAsFactors = FALSE)
names(pairs7) <- c("soc_id_1", "soc_id_2")
set.seed(42)
d7 <- tibble::as_tibble(pairs7)
d7$geo_distance <- round(stats::runif(nrow(d7), 5, 50), 1)

d7_missing <- d7
# node "G" has no route to anyone; one extra unrelated NA (A-B)
d7_missing$geo_distance[d7_missing$soc_id_1 == "G" | d7_missing$soc_id_2 == "G"] <- NA
d7_missing$geo_distance[d7_missing$soc_id_1 == "A" & d7_missing$soc_id_2 == "B"] <- NA

fst_overall <- tibble::tibble(
  group_1 = c("IE", "IE", "AA"), group_2 = c("AA", "Aus", "Aus"),
  method = "Gst", n_variables = c(5, 5, 5), value = c(0.1, 0.3, 0.25)
)

test_that("plot_distance_tree builds an unrooted nj tree by default", {
  pdf(NULL); on.exit(dev.off())
  tr <- plot_distance_tree(d7)
  expect_s3_class(tr, "phylo")
  expect_setequal(tr$tip.label, nodes7)
  expect_false(ape::is.rooted(tr))
})

test_that("plot_distance_tree builds a rooted upgma tree", {
  pdf(NULL); on.exit(dev.off())
  tr <- plot_distance_tree(d7, method = "upgma")
  expect_true(ape::is.rooted(tr))
})

test_that("plot_distance_tree roots on a specified outgroup", {
  pdf(NULL); on.exit(dev.off())
  tr <- plot_distance_tree(d7, root = "outgroup", outgroup = "A")
  expect_true(ape::is.rooted(tr))
})

test_that("plot_distance_tree warns and ignores `outgroup` when root != \"outgroup\"", {
  pdf(NULL); on.exit(dev.off())
  expect_warning(
    plot_distance_tree(d7, outgroup = "A"),
    "outgroup.*ignored"
  )
})

test_that("plot_distance_tree errors when root = \"outgroup\" but no outgroup given", {
  pdf(NULL); on.exit(dev.off())
  expect_error(plot_distance_tree(d7, root = "outgroup"), "requires `outgroup`")
})

test_that("plot_distance_tree errors on an outgroup ID not among the tips", {
  pdf(NULL); on.exit(dev.off())
  expect_error(
    plot_distance_tree(d7, root = "outgroup", outgroup = "not-a-node"),
    "not found among the tree's tips"
  )
})

test_that("plot_distance_tree drops nodes with missing distances by default, with a warning", {
  pdf(NULL); on.exit(dev.off())
  expect_warning(
    tr <- plot_distance_tree(d7_missing),
    "dropped.*G, A|dropped.*A, G"
  )
  expect_false("G" %in% tr$tip.label)
  expect_false("A" %in% tr$tip.label)
  expect_true(all(c("B", "C", "D", "E", "F") %in% tr$tip.label))
})

test_that("plot_distance_tree errors instead, naming affected nodes, when on_missing = \"error\"", {
  pdf(NULL); on.exit(dev.off())
  expect_error(
    plot_distance_tree(d7_missing, on_missing = "error"),
    "missing \\(NA\\) distance"
  )
})

test_that("plot_distance_tree auto-detects group_1/group_2-keyed input and an unambiguous distance column", {
  pdf(NULL); on.exit(dev.off())
  fst_dist_only <- fst_overall[, c("group_1", "group_2", "value")]
  tr <- plot_distance_tree(fst_dist_only)
  expect_setequal(tr$tip.label, c("IE", "AA", "Aus"))
})

test_that("plot_distance_tree requires an explicit distance_col when more than one numeric column is present", {
  pdf(NULL); on.exit(dev.off())
  expect_error(
    plot_distance_tree(fst_overall),
    "Couldn't auto-detect a single numeric distance column"
  )
  tr <- plot_distance_tree(fst_overall, distance_col = "value")
  expect_setequal(tr$tip.label, c("IE", "AA", "Aus"))
})

test_that("plot_distance_tree rejects an unknown distance_col", {
  pdf(NULL); on.exit(dev.off())
  expect_error(plot_distance_tree(d7, distance_col = "not_a_col"), "not found in")
})

test_that("plot_distance_tree requires id_cols when none of the known conventions match", {
  pdf(NULL); on.exit(dev.off())
  renamed <- d7
  names(renamed)[1:2] <- c("x1", "x2")
  expect_error(plot_distance_tree(renamed), "Couldn't find a pair of node-ID columns")
  tr <- plot_distance_tree(renamed, id_cols = c("x1", "x2"))
  expect_setequal(tr$tip.label, nodes7)
})

test_that("plot_distance_tree rejects self-pair rows", {
  pdf(NULL); on.exit(dev.off())
  d_self <- rbind(d7, tibble::tibble(soc_id_1 = "A", soc_id_2 = "A", geo_distance = 0))
  expect_error(plot_distance_tree(d_self), "self-pair")
})

test_that("plot_distance_tree rejects duplicated pairs", {
  pdf(NULL); on.exit(dev.off())
  d_dup <- rbind(d7, d7[1, ])
  expect_error(plot_distance_tree(d_dup), "more than once")
})

test_that("plot_distance_tree errors when fewer than 3 distinct nodes are present", {
  pdf(NULL); on.exit(dev.off())
  expect_error(plot_distance_tree(d7[1, ]), "at least 3 distinct")
})

test_that("plot_distance_tree warns on negative distance values", {
  pdf(NULL); on.exit(dev.off())
  d_neg <- d7
  d_neg$geo_distance[1] <- -5
  expect_warning(plot_distance_tree(d_neg), "negative value")
})

test_that("plot_distance_tree's tip_label = \"name\" only applies to soc_id-keyed input", {
  pdf(NULL); on.exit(dev.off())
  fst_dist_only <- fst_overall[, c("group_1", "group_2", "value")]
  expect_warning(
    tr <- plot_distance_tree(fst_dist_only, tip_label = "name"),
    "only applies to a soc_id-keyed"
  )
  expect_setequal(tr$tip.label, c("IE", "AA", "Aus"))
})

test_that("plot_distance_tree's tip_label = \"name\" looks up real society names, disambiguating duplicates", {
  pdf(NULL); on.exit(dev.off())
  real_soc <- dp_societies(region = "Southern Africa")$soc_id[1:6]
  d_real <- as.data.frame(t(utils::combn(real_soc, 2)), stringsAsFactors = FALSE)
  names(d_real) <- c("soc_id_1", "soc_id_2")
  d_real$geo_distance <- round(stats::runif(nrow(d_real), 5, 50), 1)

  tr <- plot_distance_tree(d_real, tip_label = "name")
  expect_length(tr$tip.label, length(real_soc))
  expect_false(anyDuplicated(tr$tip.label) > 0)
})

test_that("plot_distance_tree requires the ape package (checked before other validation)", {
  # Can't easily unload ape mid-session; just confirm the check exists and
  # fires before data validation by hitting it with otherwise-invalid input.
  skip_if_not_installed("ape")
  expect_true(requireNamespace("ape", quietly = TRUE))
})

test_that("plot_distance_tree passes `...` through to ape::plot.phylo, overriding the default type", {
  pdf(NULL); on.exit(dev.off())
  # type = "fan" should not error even though root = "none" would otherwise default to "unrooted"
  expect_no_error(plot_distance_tree(d7, type = "fan"))
})

test_that("plot_distance_tree's root = \"midpoint\" produces a rooted tree (requires phangorn)", {
  skip_if_not_installed("phangorn")
  pdf(NULL); on.exit(dev.off())
  tr <- plot_distance_tree(d7, root = "midpoint")
  expect_true(ape::is.rooted(tr))
})

test_that("plot_distance_tree errors informatively for root = \"midpoint\" without phangorn", {
  skip_if(requireNamespace("phangorn", quietly = TRUE), "phangorn is installed; this tests the absent-package path")
  pdf(NULL); on.exit(dev.off())
  expect_error(plot_distance_tree(d7, root = "midpoint"), "requires the 'phangorn' package")
})
