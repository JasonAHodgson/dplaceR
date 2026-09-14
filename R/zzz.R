.onAttach <- function(libname, pkgname) {
  meta <- tryCatch(get("dplace_meta", envir = asNamespace(pkgname)), error = function(e) NULL)
  if (is.null(meta)) return(invisible())

  packageStartupMessage(
    "dplaceR ", utils::packageVersion(pkgname),
    " -- bundled D-PLACE CLDF snapshot ", meta$cldf_version,
    " (prepared ", meta$prepared_on, ")\n",
    "Data licence: ", meta$data_license, "\n",
    "Please cite D-PLACE if you use this data -- see dp_citation() or ?dplace_meta."
  )
}
