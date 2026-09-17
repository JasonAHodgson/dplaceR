# See which cultural variables have data for a given set of societies

Answers "what can I actually do with these societies?": for a chosen
subset of societies, returns one row per D-PLACE variable with how many
of them have a genuinely coded (non-missing) observation for it. Unlike
\[dp_variables()\] (which browses the full variable catalogue regardless
of coverage) or \[dp_values()\]/\[get_society_data()\] (which return raw
observations, one row per society/variable pair, with no summary), this
rolls coverage up to one row per variable so you can see at a glance
which variables are well populated for your specific societies and which
are mostly empty – e.g. before choosing which to pass to
\[get_cult_distance()\]/\[get_pairwise_cult_distance()\]/
\[get_cultural_FST()\].

## Usage

``` r
get_variable_coverage(
  soc_id,
  var_id = NULL,
  category = NULL,
  type = NULL,
  search = NULL,
  min_pct = 0
)
```

## Arguments

- soc_id:

  Character vector of D-PLACE society IDs to check coverage for. Also
  accepts a data frame/tibble with a \`soc_id\` column, from which the
  column is used automatically.

- var_id, category, type, search:

  Optional filters narrowing which variables to report on, passed
  straight to \[dp_variables()\] (see its documentation) and combined
  with AND. Unlike
  \[get_cult_distance()\]/\[get_pairwise_cult_distance()\]/
  \[get_cultural_FST()\], none is required here – with all four left
  \`NULL\` (the default), every variable in the catalogue is reported
  on, which is the point of an exploratory coverage check.

- min_pct:

  Only return variables with at least this percentage of \`soc_id\`
  coded (\`0\`-\`100\`). Default \`0\` (no filtering – includes
  variables with zero coverage for this subset, which is itself useful
  to know).

## Value

A tibble with one row per matching variable, sorted by decreasing
coverage: \`var_id\`, \`name\`, \`category\`, \`type\`, \`n_coded\` (how
many of \`soc_id\` have a coded observation), \`n_total\` (the number of
valid \`soc_id\` checked), and \`pct_coded\`.

## Details

As in \[get_cult_distance()\] and friends, D-PLACE's dedicated "no data"
sentinel code for categorical/ordinal variables (e.g. \`"B017-NA"\` for
variable \`B017\`) is not counted as a real observation – a society
explicitly coded "missing" does not count towards \`n_coded\`.

## Examples

``` r
if (FALSE) { # \dontrun{
get_variable_coverage(dp_societies(region = "Southern Africa")$soc_id)
get_variable_coverage(
  dp_societies(region = "Southern Africa")$soc_id,
  category = contains("Subsistence"), min_pct = 80
)
} # }
```
