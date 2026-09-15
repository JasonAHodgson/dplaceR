# Metadata about the bundled D-PLACE snapshot

A one-row tibble describing exactly which D-PLACE CLDF release is
bundled with this version of dplaceR, when it was prepared, and how to
cite it.

## Usage

``` r
dplace_meta
```

## Format

A tibble with columns \`cldf_version\`, \`source_repo\`,
\`glottolog_version\`, \`glottolog_source_repo\` (the separate Glottolog
CLDF release \[dplace_societies\]'s \`lang_family\`/\`lang_family_id\`
columns are joined from – D-PLACE's own CLDF data has no language family
classification), \`prepared_on\`, \`citation\`, and \`data_license\`.

## See also

\[dp_citation()\]
