# data-raw/prepare-data.R
#
# Downloads a pinned release of the D-PLACE CLDF dataset
# (https://github.com/D-PLACE/dplace-cldf) and processes it into the tidy
# tables bundled with dplaceR (societies, variables, codes, values,
# contributions, trees). Re-run this script (and bump DPLACE_CLDF_VERSION)
# to refresh the bundled snapshot to a newer D-PLACE release.
#
# This script is NOT run when the package is installed -- it only needs to
# be run by a package maintainer when the bundled data needs updating.

library(tibble)
library(dplyr)

DPLACE_CLDF_VERSION <- "v3.3.0"
DPLACE_CLDF_REPO <- "https://raw.githubusercontent.com/D-PLACE/dplace-cldf"
base_url <- file.path(DPLACE_CLDF_REPO, DPLACE_CLDF_VERSION, "cldf")

message("Building dplaceR data from D-PLACE CLDF ", DPLACE_CLDF_VERSION)

download_csv <- function(name) {
  url <- file.path(base_url, name)
  message("  downloading ", name)
  tmp <- tempfile(fileext = ".csv")
  utils::download.file(url, tmp, quiet = TRUE, mode = "wb")
  readr_like <- utils::read.csv(
    tmp,
    stringsAsFactors = FALSE,
    na.strings = c("", "NA"),
    encoding = "UTF-8",
    check.names = FALSE
  )
  unlink(tmp)
  tibble::as_tibble(readr_like)
}

## ---- Societies --------------------------------------------------------

dplace_societies <- download_csv("societies.csv") %>%
  transmute(
    soc_id = ID,
    name = Name,
    latitude = suppressWarnings(as.numeric(Latitude)),
    longitude = suppressWarnings(as.numeric(Longitude)),
    glottocode = Glottocode,
    iso_code = ISO639P3code,
    region = region,
    type = type,
    main_focal_year = suppressWarnings(as.integer(main_focal_year)),
    language_level_glottocodes = Language_Level_Glottocodes,
    contribution_id = Contribution_ID
  )

## ---- Variables ---------------------------------------------------------

dplace_variables <- download_csv("variables.csv") %>%
  transmute(
    var_id = ID,
    name = Name,
    description = Description,
    category = category,
    type = type,
    unit = unit,
    contribution_id = Contribution_ID
  )

## ---- Codes ---------------------------------------------------------

dplace_codes <- download_csv("codes.csv") %>%
  transmute(
    code_id = ID,
    var_id = Var_ID,
    name = Name,
    description = Description,
    ord = suppressWarnings(as.integer(ord))
  )

## ---- Contributions -------------------------------------------------

dplace_contributions <- download_csv("contributions.csv") %>%
  transmute(
    contribution_id = ID,
    name = Name,
    description = Description,
    contributor = Contributor,
    citation = Citation,
    doi = DOI,
    type = type
  )

## ---- Values (the big Data table) ------------------------------------

dplace_values <- download_csv("data.csv") %>%
  transmute(
    id = ID,
    soc_id = Soc_ID,
    var_id = Var_ID,
    value = Value,
    code_id = Code_ID,
    year = suppressWarnings(as.integer(year)),
    source = Source,
    admin_comment = admin_comment
  )

## ---- Trees / phylogenies ---------------------------------------------

dplace_trees_meta <- download_csv("trees.csv") %>%
  transmute(
    tree_id = ID,
    name = Name,
    is_rooted = Tree_Is_Rooted,
    tree_type = Tree_Type,
    branch_length_unit = Tree_Branch_Length_Unit,
    media_id = Media_ID,
    source = Source,
    contribution_id = Contribution_ID
  )

dplace_media <- download_csv("media.csv") %>%
  transmute(
    media_id = ID,
    media_type = Media_Type,
    download_url = Download_URL
  )

message("  downloading ", nrow(dplace_media), " tree files")
tree_text <- vapply(dplace_media$download_url, function(u) {
  # Download_URL looks like "file:/trees/<id>.trees", relative to cldf/
  rel <- sub("^file:/?", "", u)
  full_url <- file.path(base_url, rel)
  tryCatch(
    paste(readLines(full_url, warn = FALSE, encoding = "UTF-8"), collapse = "\n"),
    error = function(e) NA_character_
  )
}, character(1), USE.NAMES = FALSE)

dplace_trees <- dplace_trees_meta %>%
  left_join(
    tibble::tibble(media_id = dplace_media$media_id, nexus = tree_text),
    by = "media_id"
  ) %>%
  select(-media_id)

failed <- sum(is.na(dplace_trees$nexus))
if (failed > 0) message("  warning: ", failed, " tree files failed to download")

## ---- Package metadata about the bundled snapshot ----------------------

dplace_meta <- tibble::tibble(
  cldf_version = DPLACE_CLDF_VERSION,
  source_repo = "D-PLACE/dplace-cldf",
  prepared_on = as.character(Sys.Date()),
  citation = paste(
    "Kirby, K.R., Gray, R.D., Greenhill, S.J., Jordan, F.M., Gomes-Ng, S.,",
    "Bibiko, H-J., Blasi, D.E., Botero, C.A., Bowern, C., Ember, C.R., Leehr, D.,",
    "Low, B.S., McCarter, J., Divale, W., Gavin, M.C. (2016).",
    "D-PLACE: A Global Database of Cultural, Linguistic and Environmental Diversity.",
    "PLoS ONE 11(7): e0158391."
  ),
  data_license = "CC-BY-NC-4.0 (D-PLACE data; see https://d-place.org)"
)

## ---- Save as internal package data ------------------------------------

usethis::use_data(
  dplace_societies,
  dplace_variables,
  dplace_codes,
  dplace_values,
  dplace_contributions,
  dplace_trees,
  dplace_meta,
  overwrite = TRUE,
  compress = "xz"
)

message("Done. Bundled data written to data/*.rda")
