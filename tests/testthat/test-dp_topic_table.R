test_that("dp_topic_table returns one row per topic, in dp_topic_list() order", {
  out <- dp_topic_table()
  expect_s3_class(out, "tbl_df")
  expect_equal(names(out), c("topic", "n_variables"))
  expect_identical(out$topic, dp_topic_list())
})

test_that("dp_topic_table counts match dp_topics() row counts per topic", {
  out <- dp_topic_table()
  expect_equal(sum(out$n_variables), nrow(dp_topics()))
  expect_equal(
    out$n_variables[out$topic == "Subsistence"],
    nrow(dp_topics(topic = "Subsistence"))
  )
  expect_equal(
    out$n_variables[out$topic == "Anthropometry"],
    nrow(dp_topics(topic = "Anthropometry"))
  )
})

test_that("dp_topic_table(type=) matches dp_topic_list(type=)/dp_topics(type=)", {
  out <- dp_topic_table(type = "Continuous")
  expect_identical(out$topic, dp_topic_list(type = "Continuous"))
  expect_equal(sum(out$n_variables), nrow(dp_topics(type = "Continuous")))
})
