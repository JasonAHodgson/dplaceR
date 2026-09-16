# Browse D-PLACE variables by atomic topic

A D-PLACE variable's \`category\` (see \[dplace_variables\]) is often
several topics joined together, e.g. \`"Economy, Property,
Subsistence"\` – which is why an exact match like \`category =
"Subsistence"\` in \[dp_variables()\] misses most variables that mention
it (see \[contains()\]). \`dp_topics()\` splits every variable's
\`category\` into its individual topics and returns one row per
variable/topic pair, so you can browse, count, or filter on a single
clean topic instead of the raw compound string.

## Usage

``` r
dp_topics(var_id = NULL, topic = NULL, type = NULL)
```

## Arguments

- var_id:

  Optional character vector of variable ID(s) to filter to.

- topic:

  Optional character vector of one or more topics to filter to (exact
  match against the split, trimmed topic), or \[contains()\] for a
  partial/regex match – see Details.

- type:

  Optional character vector restricting to variable type(s):
  \`"Categorical"\`, \`"Ordinal"\`, and/or \`"Continuous"\`. Does not
  support \[contains()\]. Applied before splitting \`category\` into
  topics, so it restricts which \*variables\* (and hence which
  variable/topic pairs) contribute to the result – a topic itself has no
  single type, since several variables of different types can share it.

## Value

A tibble with one row per variable/topic pair: \`var_id\`, \`var_name\`,
\`topic\`. A variable with no recorded \`category\` (currently one, in
the bundled snapshot) doesn't appear.

## Details

\# Untouched, not normalized Topics are split and trimmed but not
otherwise cleaned up – if D-PLACE's own \`category\` text has
near-duplicate topics, both spellings appear here as distinct topics
rather than being merged. As of the bundled snapshot this includes
\`"Labor"\`/\`"Labour"\`, \`"Settlement"\`/\`"Settlements"\`,
\`"Dwelling"\`/\`"Dwellings"\`, \`"Wealth Transactions"\`/\`"Wealth
transactions"\`, and \`"War"\`/\`"Warfare"\`. Run
\`sort(table(dp_topics()\$topic), decreasing = TRUE)\` to see the full
list of topics and how many variables carry each. \[contains()\] is
often the easiest way to combine near-duplicates yourself, since it's
case-insensitive by default – \`topic = contains("Wealth")\` matches
both \`"Wealth Transactions"\` and \`"Wealth transactions"\` in one
call.

## Examples

``` r
dp_topics(topic = "Subsistence")
#> # A tibble: 294 × 3
#>    var_id        var_name                                                  topic
#>    <chr>         <chr>                                                     <chr>
#>  1 B001          "Subsistence economy: Gathering"                          Subs…
#>  2 B002          "Subsistence economy: Hunting"                            Subs…
#>  3 B003          "Subsistence economy: Fishing"                            Subs…
#>  4 B004          "Subsistence economy: Most important activity"            Subs…
#>  5 B005          "Subsistence economy: Deviation from HGF at documentatio… Subs…
#>  6 B007          "Area occupied by ethnic group (square km)"               Subs…
#>  7 B008          "Population density (persons per square km) "             Subs…
#>  8 B010          "Size of smallest group that regularly cooperates for su… Subs…
#>  9 B037          "Ownership of resource locations "                        Subs…
#> 10 CARNEIRO4_001 "Agriculture present"                                     Subs…
#> # ℹ 284 more rows
dp_topics(topic = contains("Wealth")) # merges "Wealth Transactions"/"Wealth transactions"
#> # A tibble: 13 × 3
#>    var_id  var_name                                                        topic
#>    <chr>   <chr>                                                           <chr>
#>  1 B033    Use of money                                                    Weal…
#>  2 EA006   Transactions at marriage: prevailing type                       Weal…
#>  3 EA007   Transactions at marriage: alternate type                        Weal…
#>  4 EA074   Inheritance rule for real property (land)                       Weal…
#>  5 EA075   Inheritance distribution for real property (land)               Weal…
#>  6 EA076   Inheritance rule for movable property                           Weal…
#>  7 EA077   Inheritance distribution for movable property                   Weal…
#>  8 SCCS208 Transactions at marriage: prevailing type [Note, identical to … Weal…
#>  9 SCCS209 Transactions at marriage: alternate type [Note, identical to E… Weal…
#> 10 SCCS278 Inheritance rule for real property (land) [Note, identical to … Weal…
#> 11 SCCS279 Inheritance rule for movable property [Note, identical to EA07… Weal…
#> 12 SCCS280 Inheritance distribution for real property (land) [Note, ident… Weal…
#> 13 SCCS281 Inheritance distribution for movable property [Note, identical… Weal…
dp_topics(type = "Continuous") # topics carried by continuous variables only
#> # A tibble: 208 × 3
#>    var_id var_name                       topic      
#>    <chr>  <chr>                          <chr>      
#>  1 B001   Subsistence economy: Gathering Economy    
#>  2 B001   Subsistence economy: Gathering Property   
#>  3 B001   Subsistence economy: Gathering Subsistence
#>  4 B002   Subsistence economy: Hunting   Economy    
#>  5 B002   Subsistence economy: Hunting   Property   
#>  6 B002   Subsistence economy: Hunting   Subsistence
#>  7 B003   Subsistence economy: Fishing   Economy    
#>  8 B003   Subsistence economy: Fishing   Property   
#>  9 B003   Subsistence economy: Fishing   Subsistence
#> 10 B006   Population of ethnic group     Population 
#> # ℹ 198 more rows
sort(table(dp_topics()$topic), decreasing = TRUE) # topic counts, most first
#> 
#>                                 Gender                             Life cycle 
#>                                    589                                    536 
#>                                 Labour                              Household 
#>                                    480                                    381 
#>                              Childhood                                Economy 
#>                                    352                                    342 
#>                               Politics                            Subsistence 
#>                                    313                                    294 
#>                                Kinship                               Marriage 
#>                                    280                                    249 
#>                                 Ritual                               Religion 
#>                                    249                                    239 
#>                                Ecology                                Warfare 
#>                                    234                                    163 
#>                              Economics                 Political Organization 
#>                                    151                                    141 
#>                                  Death                               Mourning 
#>                                     93                                     93 
#>                 Community organization                       Material culture 
#>                                     86                                     70 
#>                            Settlements               Law and Judicial Process 
#>                                     67                                     63 
#>                           Architecture                           Data Quality 
#>                                     62                                     61 
#> Social Organization and Stratification                               Property 
#>                                     61                                     57 
#>                          Modernization                                 Health 
#>                                     56                                     53 
#>        Special Knowledge and Practices                             Technology 
#>                                     53                                     50 
#>                           Metalworking                             Settlement 
#>                                     47                                     46 
#>                                  Labor                                Infancy 
#>                                     39                                     38 
#>        Tools and Utensils and Textiles                       Ceramics and Art 
#>                                     35                                     33 
#>                                 Gossip              Watercraft and Navigation 
#>                                     33                                     26 
#>                                Housing                              Community 
#>                                     23                                     20 
#>                       Sexual practices                             Population 
#>                                     20                                     19 
#>                                    War                               Ceremony 
#>                                     19                                     18 
#>                               Clothing                                  Class 
#>                                     16                                     13 
#>                    Wealth Transactions                                Climate 
#>                                     12                                     10 
#>                             Leadership                             Demography 
#>                                      8                                      7 
#>                          Anthropometry                              Dwellings 
#>                                      4                                      3 
#>                     Physical Landscape                                  Games 
#>                                      3                                      2 
#>                               Dwelling                    Wealth transactions 
#>                                      1                                      1 
```
