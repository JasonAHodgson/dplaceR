# --- diagnostic 2: paste the FULL console output back ---
library(dplaceR)

if (!exists("worldgraph.10k", envir = globalenv())) {
  utils::data(list = "worldgraph.10k", package = "geoGraph", envir = globalenv())
}

soc3 <- dp_societies(soc_id = c("B72", "B73", "B79"), type = NULL)
coords3 <- as.matrix(soc3[, c("longitude", "latitude")])
rownames(coords3) <- soc3$soc_id
point_g_data <- methods::new("gData", coords = coords3["B72", , drop = FALSE], gGraph.name = "worldgraph.10k")
point_node <- geoGraph::getNodes(point_g_data)

cat("=== SCENARIO A: dijkstraFrom with a SINGLE finish node (the actual get_geo_distance bug) ===\n")
query1 <- methods::new("gData", coords = coords3["B79", , drop = FALSE], gGraph.name = "worldgraph.10k")
query1_node_ids <- geoGraph::getNodes(query1)
cat("query1_node_ids:\n"); print(query1_node_ids)
path1 <- geoGraph::dijkstraFrom(query1, start = point_node)
cat("length(path1):", length(path1), "\n")
cat("names(path1):\n"); print(names(path1))
d1 <- geoGraph::gPath2dist(path1)
cat("class(d1):", class(d1), "\n")
cat("names(d1):\n"); print(names(d1))
print(d1)

cat("\n\n=== SCENARIO B: dijkstraBetween on the 8-society set (the get_pairwise_geo_distance bug) ===\n")
ids <- c("B72", "B73", "B79", "B74", "B75", "B76", "B77", "B78")
soc8 <- dp_societies(soc_id = ids, type = NULL)
coords8 <- as.matrix(soc8[, c("longitude", "latitude")])
rownames(coords8) <- soc8$soc_id
g_data8 <- methods::new("gData", coords = coords8, gGraph.name = "worldgraph.10k")
node_ids8 <- geoGraph::getNodes(g_data8)
cat("node_ids8:\n"); print(node_ids8)
cat("any duplicated nodes among the 8?", anyDuplicated(node_ids8) > 0, "\n")

path2 <- geoGraph::dijkstraBetween(g_data8)
cat("length(path2):", length(path2), "\n")
cat("expected length (choose(8,2)):", choose(8, 2), "\n")
cat("names(path2):\n"); print(names(path2))

pairs_idx8 <- utils::combn(seq_len(nrow(soc8)), 2)
expected_names8 <- paste0(node_ids8[pairs_idx8[1, ]], ":", node_ids8[pairs_idx8[2, ]])
cat("expected_names8:\n"); print(expected_names8)
cat("identical(names(path2), expected_names8)?", identical(unname(names(path2)), expected_names8), "\n")

d2 <- geoGraph::gPath2dist(path2)
cat("class(d2):", class(d2), "\n")
cat("length(d2):", length(d2), "\n")
cat("names(d2):\n"); print(names(d2))
print(d2)
