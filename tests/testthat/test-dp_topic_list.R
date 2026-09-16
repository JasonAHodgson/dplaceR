test_that("dp_topic_list returns a sorted vector of every distinct topic", {
  out <- dp_topic_list()
  expect_type(out, "character")
  expect_false(anyDuplicated(out) > 0)
  expect_identical(out, sort(out))
  expect_identical(out, sort(unique(dp_topics()$topic)))

  # Spot-check a couple of known topics are present.
  expect_true(all(c("Subsistence", "Kinship", "Gender") %in% out))
})

test_that("dp_topic_list(type=) matches sort(unique(dp_topics(type=)$topic))", {
  out <- dp_topic_list(type = "Continuous")
  expect_identical(out, sort(unique(dp_topics(type = "Continuous")$topic)))
  expect_true(length(out) < length(dp_topic_list()))
})
