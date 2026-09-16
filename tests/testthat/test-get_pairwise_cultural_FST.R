test_that("get_pairwise_cultural_FST validates its inputs", {
  expect_error(
    get_pairwise_cultural_FST("B72", group = "region", var_id = "B004"), "at least two society"
  )
  expect_error(
    get_pairwise_cultural_FST(c("B72", "B72"), group = "region", var_id = "B004"), "duplicate"
  )
  expect_error(
    get_pairwise_cultural_FST(c("B72", "B73"), group = "region"),
    "Supply at least one of `var_id`, `category`, `type`, or `search`"
  )
  expect_error(
    get_pairwise_cultural_FST(c("B72", "B73"), group = c("x", "x"), var_id = "B004"),
    "At least two groups"
  )
})

# Three-group scenario for B004 (Categorical):
#   X = {B1, B10, B72}: all "B004-2"
#   Y = {B73, B79}:      all "B004-2"
#   Z = {B160, B294}:    all "B004-3"
# X and Y are internally uniform AND share the same state -> no diversity at
# all between them (Gst NA). X and Z (and Y and Z) are each internally
# uniform but share NO state -> complete differentiation (Gst = 1).
soc7 <- c("B1", "B10", "B72", "B73", "B79", "B160", "B294")
group_xyz <- c(
  B1 = "X", B10 = "X", B72 = "X", B73 = "Y", B79 = "Y", B160 = "Z", B294 = "Z"
)

pair_row <- function(df, g1, g2) {
  df[(df$group_1 == g1 & df$group_2 == g2) | (df$group_1 == g2 & df$group_2 == g1), ]
}

test_that("Gst matches a hand-worked three-group categorical example", {
  out <- suppressWarnings(get_pairwise_cultural_FST(soc7, group = group_xyz, var_id = "B004"))
  expect_equal(nrow(out$by_variable), 3) # X-Y, X-Z, Y-Z

  r_xy <- pair_row(out$by_variable, "X", "Y")
  expect_true(is.na(r_xy$value))

  r_xz <- pair_row(out$by_variable, "X", "Z")
  expect_equal(r_xz$value, 1, tolerance = 1e-8)

  r_yz <- pair_row(out$by_variable, "Y", "Z")
  expect_equal(r_yz$value, 1, tolerance = 1e-8)

  expect_equal(out$overall$value[out$overall$group_1 == "X" & out$overall$group_2 == "Z"], 1,
               tolerance = 1e-8)
})

test_that("each pair reproduces what get_cultural_FST() gives for just those two groups", {
  out_pair <- suppressWarnings(
    get_pairwise_cultural_FST(soc7, group = group_xyz, var_id = c("B004", "B001"))
  )

  for (pair in list(c("X", "Y"), c("X", "Z"), c("Y", "Z"))) {
    keep <- group_xyz %in% pair
    single <- suppressWarnings(get_cultural_FST(
      names(group_xyz)[keep], group = group_xyz[keep], var_id = c("B004", "B001")
    ))
    row <- pair_row(out_pair$by_variable, pair[1], pair[2])
    row <- row[order(row$var_id), c("var_id", "type", "method", "n_groups", "n_societies", "value")]
    single_sorted <- single$by_variable[order(single$by_variable$var_id), ]
    expect_equal(as.data.frame(row), as.data.frame(single_sorted), tolerance = 1e-8)
  }
})

test_that("the returned lists have the documented column names", {
  out <- suppressWarnings(
    get_pairwise_cultural_FST(soc7, group = group_xyz, var_id = c("B004", "B001"))
  )
  expect_named(
    out$by_variable,
    c("group_1", "group_2", "var_id", "type", "method", "n_groups", "n_societies", "value")
  )
  expect_named(out$overall, c("group_1", "group_2", "method", "n_variables", "value"))
})

test_that("unknown society/variable IDs and ungrouped societies are dropped with a warning", {
  ws <- character(0)
  out <- withCallingHandlers(
    get_pairwise_cultural_FST(
      c(soc7, "not-a-real-soc"), group = c(group_xyz, "not-a-real-soc" = "W"),
      var_id = c("B004", "not-a-real-var")
    ),
    warning = function(w) { ws <<- c(ws, conditionMessage(w)); invokeRestart("muffleWarning") }
  )
  expect_true(any(grepl("Society ID.*not found", ws)))
  expect_true(any(grepl("Variable ID.*not found", ws)))
  expect_true(all(out$by_variable$n_societies <= 7))
})
