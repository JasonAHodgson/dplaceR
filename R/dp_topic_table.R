#' Count how many variables carry each topic
#'
#' A two-column summary of [dp_topic_list()]: how many variables (see
#' [dp_topics()]) are tagged with each topic, so you can see at a glance
#' which topics are broad and which are narrow before filtering by one.
#'
#' @param type Optional character vector restricting to variable type(s):
#'   `"Categorical"`, `"Ordinal"`, and/or `"Continuous"`. Passed straight to
#'   [dp_topics()]/[dp_topic_list()] -- see there for what it means to
#'   filter topics by type. Topics with no variable of the given type(s)
#'   are dropped entirely rather than shown with `n_variables = 0`.
#'
#' @return A tibble with one row per topic, in the same order as
#'   [dp_topic_list()]: `topic` and `n_variables` (the number of variables
#'   whose `category` includes that topic -- see [dp_topics()], including
#'   its note on near-duplicate topic spellings that are counted separately
#'   here too).
#'
#' @examples
#' dp_topic_table()
#' # most common topics first
#' dp_topic_table()[order(-dp_topic_table()$n_variables), ]
#' dp_topic_table(type = "Continuous")
#'
#' @export
dp_topic_table <- function(type = NULL) {
  topics <- dp_topic_list(type = type)
  counts <- table(dp_topics(type = type)$topic)

  tibble::tibble(
    topic = topics,
    n_variables = as.integer(counts[topics])
  )
}
