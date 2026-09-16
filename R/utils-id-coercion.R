# Shared helper for every function that accepts a `soc_id`/`var_id`
# argument: accepts either a plain vector of IDs, or a data frame/tibble
# with an `id_col` column -- e.g. a dp_societies()/dp_variables() result
# passed straight through instead of indexing into its `soc_id`/`var_id`
# column, a natural and common mistake (silently matching nothing
# otherwise, since a whole data frame doesn't equal any single ID). Returns
# a plain vector either way, or `x` unchanged if it's `NULL` or not a data
# frame (further validation, e.g. that it's actually a character vector,
# is left to the caller).
.gs_coerce_ids <- function(x, id_col, arg_name) {
  if (is.null(x) || !is.data.frame(x)) {
    return(x)
  }
  if (!id_col %in% names(x)) {
    stop(
      "`", arg_name, "` is a data frame/tibble with no `", id_col, "` column ",
      "-- pass its `", id_col, "` column instead: `", arg_name, " = your_data$",
      id_col, "`.", call. = FALSE
    )
  }
  x[[id_col]]
}
