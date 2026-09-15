#' List every topic used in D-PLACE's variable categories
#'
#' A quick way to see what's available before filtering by
#' [dp_topics()]/[dp_variables()]'s `topic`/`category` -- equivalent to
#' `sort(unique(dp_topics()$topic))`, but without building the full
#' variable/topic table yourself.
#'
#' @return A sorted character vector of every distinct topic (see
#'   [dp_topics()] for how topics are derived, including its note on
#'   near-duplicate spellings that aren't merged here either).
#'
#' @examples
#' dp_topic_list()
#'
#' @export
dp_topic_list <- function() {
  sort(unique(dp_topics()$topic))
}
