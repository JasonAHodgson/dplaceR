test_that("get_cultural_FST validates its inputs", {
  expect_error(get_cultural_FST("B72", group = "region", var_id = "B004"), "at least two society")
  expect_error(
    get_cultural_FST(c("B72", "B72"), group = "region", var_id = "B004"), "duplicate"
  )
  expect_error(
    get_cultural_FST(c("B72", "B73"), group = "region", var_id = character(0)),
    "at least one variable"
  )
  expect_error(
    get_cultural_FST(c("B72", "B73"), group = "region", var_id = c("B004", "B004")),
    "duplicate"
  )
  expect_error(
    get_cultural_FST(c("B72", "B73"), group = "region"),
    "Supply at least one of `var_id`, `category`, `type`, or `search`"
  )
  expect_error(
    get_cultural_FST(c("B72", "B73"), group = "not-a-column", var_id = "B004"),
    "\"region\", \"lang_family\", or \"lang_family_id\""
  )
  expect_error(
    get_cultural_FST(c("B72", "B73", "B79"), group = c("x", "y"), var_id = "B004"),
    "same length"
  )
  expect_error(
    get_cultural_FST(
      c("B72", "B73"), group = c(B72 = "x"), var_id = "B004"
    ),
    "missing entries"
  )
  expect_error(
    get_cultural_FST(c("B72", "B73"), group = c("x", "x"), var_id = "B004"),
    "At least two groups"
  )
})

# Hand-worked scenario: B004 across B1, B10, B72, B73, B79, B160, B294
#   B1 = B10 = B72 = B73 = B79 = "B004-2"; B160 = B294 = "B004-3"
# Group X = {B1, B10, B72} (all "B004-2", Hg = 0)
# Group Y = {B73, B79, B160, B294} (2x "B004-2", 2x "B004-3", Hg = 0.5)
# n_X = 3, n_Y = 4, n = 7
#   Hs = (3*0 + 4*0.5) / 7 = 2/7
#   Ht = 1 - ((5/7)^2 + (2/7)^2) = 20/49
#   Gst = (Ht - Hs) / Ht = (20/49 - 14/49) / (20/49) = 6/20 = 0.3
soc7 <- c("B1", "B10", "B72", "B73", "B79", "B160", "B294")
group_xy <- c(
  B1 = "X", B10 = "X", B72 = "X", B73 = "Y", B79 = "Y", B160 = "Y", B294 = "Y"
)

test_that("Gst matches a hand-worked categorical example", {
  out <- get_cultural_FST(soc7, group = group_xy, var_id = "B004")
  expect_equal(out$by_variable$method, "Gst")
  expect_equal(out$by_variable$type, "Categorical")
  expect_equal(out$by_variable$n_groups, 2)
  expect_equal(out$by_variable$n_societies, 7)
  expect_equal(out$by_variable$value, 0.3, tolerance = 1e-8)
  expect_equal(out$overall$method, "Gst")
  expect_equal(out$overall$n_variables, 1)
  expect_equal(out$overall$value, 0.3, tolerance = 1e-8)
})

test_that("an unnamed group vector is assigned by position, matching a named one", {
  out_named <- get_cultural_FST(soc7, group = group_xy, var_id = "B004")
  out_positional <- get_cultural_FST(
    soc7, group = unname(group_xy[soc7]), var_id = "B004"
  )
  expect_equal(out_named, out_positional)
})

test_that("group = \"region\" resolves groups from dp_societies()", {
  # B72, B73, B79 are all Southern Africa; the rest are each their own region
  # (see dp_societies(soc_id = soc7)) -- so this is equivalent to supplying
  # the region vector directly.
  soc_meta <- dp_societies(soc_id = soc7, type = NULL)
  region_vec <- stats::setNames(soc_meta$region, soc_meta$soc_id)[soc7]
  out_builtin <- get_cultural_FST(soc7, group = "region", var_id = "B004")
  out_explicit <- get_cultural_FST(soc7, group = region_vec, var_id = "B004")
  expect_equal(out_builtin, out_explicit)
  expect_equal(out_builtin$by_variable$n_groups, 5) # 5 distinct regions
})

# Second variable for the multi-variable overall-Gst combination below:
# B005 across the same 7 societies:
#   Group X = {B1, B10, B72}: B005-2, B005-2, B005-1 -> Hg_X = 1-((2/3)^2+(1/3)^2) = 4/9
#   Group Y = {B73, B79, B160, B294}: B005-2, B005-1, B005-1, B005-1 -> Hg_Y = 3/8
#   Hs = (3*4/9 + 4*3/8)/7 = 17/42
#   Ht = 1 - ((3/7)^2 + (4/7)^2) = 24/49
#   Gst_B005 = (24/49 - 17/42) / (24/49) = 25/144
test_that("the overall Gst combines variables by summed components, not averaged ratios", {
  out <- get_cultural_FST(soc7, group = group_xy, var_id = c("B004", "B005"))
  expect_equal(nrow(out$by_variable), 2)
  expect_equal(out$by_variable$value[out$by_variable$var_id == "B004"], 0.3, tolerance = 1e-8)
  expect_equal(out$by_variable$value[out$by_variable$var_id == "B005"], 25 / 144, tolerance = 1e-8)

  diff_b004 <- 6 / 49
  diff_b005 <- 25 / 294
  ht_b004 <- 20 / 49
  ht_b005 <- 24 / 49
  expected_overall <- (diff_b004 + diff_b005) / (ht_b004 + ht_b005)
  expect_equal(out$overall$value, expected_overall, tolerance = 1e-8)
  expect_equal(out$overall$n_variables, 2)
})

# Hand-worked Qst scenario: B001 (continuous) with Group A = {B72, B73}
# (values 67, 67 -- identical, no within-group variance) and Group B =
# {B79, B160} (values 70, 35).
#   Grand mean = 59.75; Vb = (2*(67-59.75)^2 + 2*(52.5-59.75)^2)/4 = 52.5625
#   Vw = (0 + (70-52.5)^2 + (35-52.5)^2)/4 = 153.125
#   Qst = 52.5625 / (52.5625 + 153.125)
test_that("Qst matches a hand-worked continuous example", {
  group_ab <- c(B72 = "A", B73 = "A", B79 = "B", B160 = "B")
  out <- get_cultural_FST(names(group_ab), group = group_ab, var_id = "B001")
  expect_equal(out$by_variable$method, "Qst")
  expect_equal(out$by_variable$type, "Continuous")
  expected_qst <- 52.5625 / (52.5625 + 153.125)
  expect_equal(out$by_variable$value, expected_qst, tolerance = 1e-8)
  expect_equal(out$overall$method, "Qst")
})

# Ordinal variables: default (type_aware = FALSE) uses Gst on the coded
# states; type_aware = TRUE uses Qst on `ord` instead. B033: B1 = ord 1
# (code B033-1), B294 = ord 2 (code B033-2), B160 = ord 4 (code B033-4) --
# three distinct codes.
# Gst (Group A = {B1}, Group B = {B294, B160}, all-distinct states):
#   Hg_A = 0, Hg_B = 0.5, Hs = (1*0 + 2*0.5)/3 = 1/3
#   Ht = 1 - 3*(1/3)^2 = 2/3; Gst = (2/3 - 1/3)/(2/3) = 0.5
# Qst (same groups, using ord 1, 2, 4 as the quantity):
#   Grand mean = 7/3; Vb = (1*(1-7/3)^2 + 2*(3-7/3)^2)/3 = 8/9
#   Vw = (0 + (2-3)^2 + (4-3)^2)/3 = 2/3; Qst = (8/9)/(8/9+2/3) = 4/7
test_that("ordinal variables use Gst by default and Qst with type_aware = TRUE", {
  group_ab <- c(B1 = "A", B294 = "B", B160 = "B")

  out_gst <- get_cultural_FST(names(group_ab), group = group_ab, var_id = "B033")
  expect_equal(out_gst$by_variable$method, "Gst")
  expect_equal(out_gst$by_variable$value, 0.5, tolerance = 1e-8)

  out_qst <- get_cultural_FST(
    names(group_ab), group = group_ab, var_id = "B033", type_aware = TRUE
  )
  expect_equal(out_qst$by_variable$method, "Qst")
  expect_equal(out_qst$by_variable$value, 4 / 7, tolerance = 1e-8)
})

test_that("unknown society/variable IDs and ungrouped societies are dropped with a warning", {
  ws <- character(0)
  out <- withCallingHandlers(
    get_cultural_FST(
      c(soc7, "not-a-real-soc"), group = c(group_xy, "not-a-real-soc" = "Z"),
      var_id = c("B004", "not-a-real-var")
    ),
    warning = function(w) { ws <<- c(ws, conditionMessage(w)); invokeRestart("muffleWarning") }
  )
  expect_true(any(grepl("Society ID.*not found", ws)))
  expect_true(any(grepl("Variable ID.*not found", ws)))
  expect_equal(out$by_variable$n_societies, 7)
})

test_that("societies with no group assigned are dropped with a warning", {
  group_with_na <- group_xy
  group_with_na["B72"] <- NA_character_
  expect_warning(
    out <- get_cultural_FST(soc7, group = group_with_na, var_id = "B004"),
    "no group assigned"
  )
  expect_equal(out$by_variable$n_societies, 6)
})

# D-PLACE gives every variable a dedicated "missing data" code (code_id
# ending "-NA") -- excluded before the calculation, exactly as in
# get_cult_distance(). EA113: Aa1 = Aa5 = "EA113-2" (real match);
# Aa2 = Aa3 = only the sentinel.
test_that("the missing-data sentinel doesn't count as a real shared state", {
  group_pq <- c(Aa1 = "P", Aa2 = "P", Aa3 = "Q", Aa5 = "Q")
  expect_warning(
    out <- get_cultural_FST(names(group_pq), group = group_pq, var_id = "EA113"),
    "value is NA"
  )
  # Aa2 and Aa3 (sentinel-only) are excluded -- only Aa1 and Aa5 remain, both
  # with the same real state, so there's no diversity left to measure (Gst
  # is NA, not spuriously 0 from the sentinel counting as a shared match).
  expect_equal(out$by_variable$n_societies, 2)
  expect_true(is.na(out$by_variable$value))
})

test_that("the returned lists have the documented column names", {
  out <- get_cultural_FST(soc7, group = group_xy, var_id = c("B004", "B001"))
  expect_named(out$by_variable, c("var_id", "type", "method", "n_groups", "n_societies", "value"))
  expect_named(out$overall, c("method", "n_variables", "value"))
})
