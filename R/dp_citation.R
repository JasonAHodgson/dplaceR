#' How to cite dplaceR, D-PLACE, and the bundled data snapshot
#'
#' Prints (and invisibly returns) how to cite dplaceR itself, alongside the
#' citation for D-PLACE and the version/licence of the CLDF snapshot bundled
#' with this package. Cite the individual source dataset(s) too -- see
#' [dp_contributions()] for their citations.
#'
#' @return Invisibly, the one-row [dplace_meta] tibble.
#'
#' @examples
#' dp_citation()
#'
#' @export
dp_citation <- function() {
  cat(
    "dplaceR:\n  Please cite the package itself alongside D-PLACE -- see\n",
    "  citation(\"dplaceR\") (Jason A. Hodgson, package author).\n\n",
    "D-PLACE:\n  ", dplace_meta$citation, "\n\n",
    "Bundled snapshot: D-PLACE CLDF ", dplace_meta$cldf_version,
    " (", dplace_meta$source_repo, "), prepared ", dplace_meta$prepared_on, "\n",
    "Data licence: ", dplace_meta$data_license, "\n",
    "Language family classification: Glottolog CLDF ", dplace_meta$glottolog_version,
    " (", dplace_meta$glottolog_source_repo, ") -- see dplace_societies's ",
    "`lang_family`/`lang_family_id` columns.\n\n",
    "Please also cite the specific source dataset(s) your variables come ",
    "from -- see dp_contributions() for per-dataset citations.\n",
    sep = ""
  )
  invisible(dplace_meta)
}
