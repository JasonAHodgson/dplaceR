# Find other societies coded from the same real-world group

D-PLACE assigns a cross-dataset identifier (\`xd_id\`, see
\[dplace_societies\]) to societies that different contributed datasets
have independently coded from the same real-world place – for example,
the !Kung are coded separately by Binford's dataset, the Ethnographic
Atlas, and the Standard Cross-Cultural Sample, and all three share
\`xd_id = "xd1"\`. \`get_related_societies()\` looks up the given
society/societies' \`xd_id\` and returns every OTHER society sharing it,
so you can find and potentially combine independent codings of the same
group. Most societies (roughly 70 \`xd_id\` at all – they haven't been
cross-referenced to another dataset.

## Usage

``` r
get_related_societies(soc_id)
```

## Arguments

- soc_id:

  Character vector of one or more D-PLACE society IDs (see
  \[dp_societies()\]).

## Value

A tibble with one row per (queried society, related society) pair:
\`soc_id\` (the society you asked about), \`xd_id\`, \`related_soc_id\`,
\`related_name\`, \`related_contribution_id\` (which dataset the related
society comes from). A queried society with no \`xd_id\`, or whose
\`xd_id\` currently has no other society sharing it, contributes no rows
(with a warning explaining why in each case).

## Examples

``` r
if (FALSE) { # \dontrun{
get_related_societies("B72") # !Kung, coded by Binford -- also in EA and SCCS
get_related_societies(c("B72", "B73"))
} # }
```
