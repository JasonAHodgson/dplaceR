# Get societies belonging to a language clade (e.g. Bantu)

Glottolog groupings below the top-level language family (e.g. "Narrow
Bantu", a branch of Atlantic-Congo) aren't stored as their own column –
\[dplace_societies\]'s \`lang_family\`/\`lang_family_id\` only track the
top-level family (see \[dp_societies()\]). \`get_lang_clade()\` finds
such a group anyway, using D-PLACE's bundled Glottolog classification
trees (see \[dp_trees()\]/\[dp_tree()\]): give it two or more
societies/Glottocodes you know belong to the group you want (e.g. Zulu
and Ganda for Bantu), and it returns every society whose language falls
within the smallest clade containing all of them – their most recent
common ancestor (MRCA) in the relevant tree.

## Usage

``` r
get_lang_clade(seed, type = "society")
```

## Arguments

- seed:

  A character vector of two or more D-PLACE society IDs and/or
  Glottocodes (may be mixed) known to belong to the clade of interest –
  at least two \*distinct\* languages are needed to define an ancestor
  node. See Details for how to choose good seeds.

- type:

  As in \[dp_societies()\]; which row types to include in the result.
  Defaults to \`"society"\`.

## Value

A tibble of societies (as \[dp_societies()\]), for every society whose
language is a descendant of, or is, the identified clade – including the
seed(s) themselves.

## Details

This works by finding an ancestor node, not by looking up a named group,
so the seeds you pick matter: they should "bracket" the group as tightly
as possible. A seed that's only distantly related pulls in every
language classified between it and the rest – if that happens, the
returned clade will span (suspiciously close to) the seeds' entire
top-level family, and a warning says so. When in doubt, sanity-check the
result (e.g. its size, or \`unique(result\$region)\`) against what you'd
expect before relying on it.

All seeds must resolve to tips of the \*same\* bundled tree – in
practice, the same top-level language family (see
\[dp_lang_family_list()\]). Seeds from different families have no shared
ancestor to compute here, and the function errors rather than guessing.

## Examples

``` r
if (FALSE) { # \dontrun{
# every Bantu-speaking society -- Zulu and Ganda bracket Narrow Bantu
# within Atlantic-Congo
get_lang_clade(c("zulu1248", "gand1255"))
} # }
```
