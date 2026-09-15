# Partial or regex matching for society search functions

Wrap a search term (or several) in \`contains()\` when passing it to an
exact-match argument of \[get_society()\] or \[dp_societies()\] –
\`soc_id\`, \`glottocode\`, \`iso_code\`, \`region\`,
\`contribution_id\`, or \`language_level_glottocodes\` – to match values
that merely contain the term (via \[grepl()\]) instead of requiring an
exact match. This is what turns \`get_society(region = "Africa")\`
(which matches nothing, since D-PLACE has no region literally called
\`"Africa"\` – see \`unique(dplace_societies\$region)\`) into
\`get_society(region = contains("Africa"))\` (which matches every region
whose name contains "Africa").

## Usage

``` r
contains(pattern, ignore.case = TRUE, fixed = FALSE)
```

## Arguments

- pattern:

  Character vector of one or more search terms. A value matches if it
  contains ANY of them (OR); each is treated as a regular expression
  unless \`fixed = TRUE\`.

- ignore.case:

  Logical; case-insensitive by default.

- fixed:

  Logical; if \`TRUE\`, \`pattern\` is matched literally rather than as
  a regular expression – useful if a search term itself contains regex
  metacharacters (e.g. \`.\` or \`(\`). Default \`FALSE\`.

## Value

An object recording \`pattern\` and the matching options, for
\[get_society()\]/\[dp_societies()\] to recognize; calling it on its own
isn't useful.

## Examples

``` r
if (FALSE) { # \dontrun{
get_society(region = contains("Africa"))
dp_societies(region = contains(c("Africa", "Asia")))
get_society(soc_id = contains("^CARNEIRO"))
} # }
```
