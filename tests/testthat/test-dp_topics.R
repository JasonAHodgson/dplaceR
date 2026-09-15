test_that("dp_topics splits every variable's category into one row per topic", {
  out <- dp_topics()
  expect_s3_class(out, "tbl_df")
  expect_equal(names(out), c("var_id", "var_name", "topic"))

  # Matches manually summing the comma-separated topic counts across every
  # variable with a non-NA category.
  vars <- dplace_variables[!is.na(dplace_variables$category), ]
  expect_equal(nrow(out), sum(lengths(strsplit(vars$category, ","))))
})

test_that("dp_topics drops variables with no recorded category", {
  na_var <- dplace_variables$var_id[is.na(dplace_variables$category)]
  expect_true(length(na_var) > 0) # currently true of the bundled snapshot
  expect_false(any(na_var %in% dp_topics()$var_id))
})

test_that("dp_topics(var_id=) returns that variable's individual topics", {
  # B001's category is "Economy, Property, Subsistence".
  out <- dp_topics(var_id = "B001")
  expect_setequal(out$topic, c("Economy", "Property", "Subsistence"))
  expect_true(all(out$var_id == "B001"))
})

test_that("dp_topics(topic=) filters to variables carrying that exact topic", {
  out <- dp_topics(topic = "Subsistence")
  expect_true(nrow(out) > 0)
  expect_true(all(out$topic == "Subsistence"))
  # Cross-check against the raw (compound) category column.
  expect_true(all(grepl(
    "Subsistence", dplace_variables$category[match(out$var_id, dplace_variables$var_id)]
  )))
})

test_that("dp_topics topic supports contains() to merge near-duplicate spellings", {
  # D-PLACE's raw category text has both "Wealth Transactions" and
  # "Wealth transactions" -- contains() is case-insensitive by default, so
  # this merges them into one query.
  out <- dp_topics(topic = contains("Wealth"))
  expect_setequal(unique(out$topic), c("Wealth Transactions", "Wealth transactions"))

  exact <- dp_topics(topic = "Wealth Transactions")
  expect_true(nrow(out) > nrow(exact))
})

test_that("dp_topics combines var_id and topic with AND", {
  out <- dp_topics(var_id = c("B001", "B033"), topic = "Property")
  expect_equal(nrow(out), 2)
  expect_setequal(out$var_id, c("B001", "B033"))
  expect_true(all(out$topic == "Property"))
})

test_that("dp_topics returns zero rows for an unmatched topic", {
  expect_equal(nrow(dp_topics(topic = "not-a-real-topic")), 0)
})
