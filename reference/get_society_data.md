# Search and assemble a table of societies' cultural measurements

The variable-selection counterpart to \[get_society_meta()\] (which adds
society metadata to a table you already have): this builds a table of
D-PLACE's coded cultural data for a chosen set of societies and a chosen
set of variables – named explicitly with \`var_id\`, or found by
searching with \`category\`, \`type\`, and/or \`search\` (all passed
straight to \[dp_variables()\] and combined with AND, like there). At
least one of \`var_id\`, \`category\`, \`type\`, or \`search\` must be
supplied, so you don't accidentally build a table across all several
thousand bundled variables – use \[dp_variables()\] or
\[dp_search_variables()\] to see what's available first.

## Usage

``` r
get_society_data(
  soc_id = NULL,
  var_id = NULL,
  category = NULL,
  type = NULL,
  search = NULL,
  format = c("long", "wide"),
  society_info = TRUE
)
```

## Arguments

- soc_id:

  Optional character vector of society ID(s) to include (see
  \[dp_societies()\]). Defaults to every society with coded cultural
  data (\`type = "society"\`).

- var_id, category, type, search:

  Optional variable-selection criteria, passed straight to
  \[dp_variables()\] and combined with AND – see its documentation for
  what each means (including \[contains()\] support for \`category\`).
  At least one must be supplied.

- format:

  One of \`"long"\` (default) or \`"wide"\` – see Details.

- society_info:

  Logical; if \`TRUE\` (the default), join in society \`name\` (as
  \`society_name\`), \`latitude\`, \`longitude\`, \`glottocode\`, and
  \`region\`.

## Value

A tibble – see Details for the two possible shapes.

## Details

\# Output shape (\`format\`)

- \`"long"\` (default):

  One row per society/variable \*observation\* – the same shape as
  \[dp_variable_data()\], with variable metadata (\`var_name\`,
  \`var_category\`, \`var_type\`) added so search results are
  self-describing. Every recorded observation is kept, including more
  than one per society/variable where D-PLACE has them (see
  \[dp_values()\]).

- \`"wide"\`:

  One row per society, one column per variable (named by \`var_id\`) –
  ready to use directly as a data frame for analysis. Where a society
  has more than one recorded observation for a variable, the most recent
  one (by \`year\`, or the first recorded if tied/unknown) is kept, with
  a warning – see \[dp_values()\] yourself for full control over this. A
  \`"Continuous"\` variable's column is numeric;
  \`"Categorical"\`/\`"Ordinal"\` columns hold the human-readable code
  label (see \[dp_codes()\]) rather than the raw code_id.

## Examples

``` r
if (FALSE) { # \dontrun{
get_society_data(soc_id = c("B72", "B73"), var_id = c("B001", "B004"))
get_society_data(category = contains("Subsistence"), format = "wide")
get_society_data(search = "descent", type = "Categorical")
} # }
```
