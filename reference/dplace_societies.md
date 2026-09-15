# Societies in D-PLACE

One row per society (or, for a small number of rows, "languoid" – a
language variety referenced only by a phylogeny, with no coded cultural
data of its own).

## Usage

``` r
dplace_societies
```

## Format

A tibble with one row per society and the following columns:

- soc_id:

  Character. D-PLACE society identifier, e.g. \`"B72"\`. Used to join to
  \[dplace_values\].

- name:

  Character. Society name.

- latitude, longitude:

  Numeric. Approximate coordinates.

- glottocode:

  Character. Glottolog language code for this society, where known. Used
  to link to language phylogenies.

- iso_code:

  Character. ISO 639-3 code, where known.

- region:

  Character. World region.

- type:

  Character. \`"society"\` (has coded cultural data) or \`"languoid"\`
  (reference node in a phylogeny only).

- main_focal_year:

  Integer. Approximate year the ethnographic description refers to.

- language_level_glottocodes:

  Character. Glottocode(s) at the language level associated with this
  society.

- contribution_id:

  Character. Identifies the source dataset; joins to
  \[dplace_contributions\].

- xd_id:

  Character. Cross-dataset identifier, \`NA\` for most societies.
  Societies from different datasets that independently code the same
  real-world group share an \`xd_id\` – e.g. the !Kung are coded
  separately by Binford, the Ethnographic Atlas, and the SCCS, and all
  three share \`xd_id = "xd1"\`. See \[get_related_societies()\].

- lang_family_id, lang_family:

  Character. The society's top-level Glottolog language family – named
  \`lang_family\*\` (not plain \`family\`) to avoid clashing with
  D-PLACE's own "family" cultural/kinship variables, which mean
  something unrelated. \`lang_family_id\` is a stable Glottocode (e.g.
  \`"indo1319"\`), \`lang_family\` its human-readable name (e.g.
  \`"Indo-European"\`). An isolate (a language with no known relatives,
  e.g. Zuni) is its own top-level family, so
  \`lang_family\`/\`lang_family_id\` equal the language's own
  name/Glottocode in that case. \`NA\` for the ~1.5 societies with no
  \`glottocode\`. Not part of D-PLACE's own CLDF data – joined in from a
  separate Glottolog release; see \[dplace_meta\]'s
  \`glottolog_version\`. See \[dp_lang_family_list()\] and
  \[dp_lang_family_table()\] for browsing the available families.

## Source

D-PLACE CLDF dataset, <https://github.com/D-PLACE/dplace-cldf>. See
\[dplace_meta\] for the exact release bundled with this package.
\`lang_family_id\`/\`lang_family\` are instead joined in from
Glottolog's own CLDF release,
<https://github.com/glottolog/glottolog-cldf> – see \[dplace_meta\]'s
\`glottolog_version\`/\`glottolog_source_repo\`.

## See also

\[dp_societies()\], \[get_related_societies()\],
\[dp_lang_family_list()\], \[dp_lang_family_table()\]
