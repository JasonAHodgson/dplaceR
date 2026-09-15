#' Find other societies coded from the same real-world group
#'
#' D-PLACE assigns a cross-dataset identifier (`xd_id`, see
#' [dplace_societies]) to societies that different contributed datasets have
#' independently coded from the same real-world place -- for example, the
#' !Kung are coded separately by Binford's dataset, the Ethnographic Atlas,
#' and the Standard Cross-Cultural Sample, and all three share
#' `xd_id = "xd1"`. `get_related_societies()` looks up the given
#' society/societies' `xd_id` and returns every OTHER society sharing it, so
#' you can find and potentially combine independent codings of the same
#' group. Most societies (roughly 70% of the bundled snapshot) have no
#' `xd_id` at all -- they haven't been cross-referenced to another dataset.
#'
#' @param soc_id Character vector of one or more D-PLACE society IDs (see
#'   [dp_societies()]).
#'
#' @return A tibble with one row per (queried society, related society)
#'   pair: `soc_id` (the society you asked about), `xd_id`, `related_soc_id`,
#'   `related_name`, `related_contribution_id` (which dataset the related
#'   society comes from). A queried society with no `xd_id`, or whose
#'   `xd_id` currently has no other society sharing it, contributes no rows
#'   (with a warning explaining why in each case).
#'
#' @examples
#' \dontrun{
#' get_related_societies("B72") # !Kung, coded by Binford -- also in EA and SCCS
#' get_related_societies(c("B72", "B73"))
#' }
#'
#' @export
get_related_societies <- function(soc_id) {
  if (length(soc_id) < 1) {
    stop("`soc_id` must contain at least one society ID.", call. = FALSE)
  }
  if (anyDuplicated(soc_id)) {
    stop("`soc_id` contains duplicate values.", call. = FALSE)
  }

  soc <- dplace_societies[dplace_societies$soc_id %in% soc_id, c("soc_id", "xd_id")]
  missing_soc <- setdiff(soc_id, soc$soc_id)
  if (length(missing_soc) > 0) {
    warning(
      "Society ID(s) not found, dropped: ", paste(missing_soc, collapse = ", "),
      call. = FALSE
    )
  }
  if (nrow(soc) < 1) {
    stop("None of the requested society IDs were found.", call. = FALSE)
  }

  no_xd_id <- soc$soc_id[is.na(soc$xd_id)]
  if (length(no_xd_id) > 0) {
    warning(
      "Society(ies) with no cross-dataset ID (not linked to any other ",
      "coding), skipped: ", paste(no_xd_id, collapse = ", "), call. = FALSE
    )
  }
  soc <- soc[!is.na(soc$xd_id), , drop = FALSE]
  if (nrow(soc) < 1) {
    stop("None of the requested societies have a cross-dataset ID.", call. = FALSE)
  }

  all_soc <- dplace_societies[, c("soc_id", "name", "contribution_id", "xd_id")]

  out_rows <- lapply(seq_len(nrow(soc)), function(i) {
    this_soc_id <- soc$soc_id[i]
    this_xd_id <- soc$xd_id[i]
    related <- all_soc[
      !is.na(all_soc$xd_id) & all_soc$xd_id == this_xd_id & all_soc$soc_id != this_soc_id,
      , drop = FALSE
    ]
    if (nrow(related) == 0) {
      return(NULL)
    }
    tibble::tibble(
      soc_id = this_soc_id,
      xd_id = this_xd_id,
      related_soc_id = related$soc_id,
      related_name = related$name,
      related_contribution_id = related$contribution_id
    )
  })

  no_siblings <- soc$soc_id[vapply(out_rows, is.null, logical(1))]
  if (length(no_siblings) > 0) {
    warning(
      "Society(ies) whose cross-dataset ID currently has no other society ",
      "sharing it: ", paste(no_siblings, collapse = ", "), call. = FALSE
    )
  }

  out_rows <- out_rows[!vapply(out_rows, is.null, logical(1))]
  if (length(out_rows) == 0) {
    return(tibble::tibble(
      soc_id = character(0), xd_id = character(0), related_soc_id = character(0),
      related_name = character(0), related_contribution_id = character(0)
    ))
  }

  tibble::as_tibble(do.call(rbind, out_rows))
}
