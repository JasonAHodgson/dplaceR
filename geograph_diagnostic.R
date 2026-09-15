# --- diagnostic: paste the FULL console output back, including any warnings ---
library(dplaceR)

cat("=== versions ===\n")
print(packageVersion("geoGraph"))
print(packageVersion("RBGL"))

if (!exists("worldgraph.10k", envir = globalenv())) {
  utils::data(list = "worldgraph.10k", package = "geoGraph", envir = globalenv())
}
graph_obj <- worldgraph.10k

soc <- dp_societies(soc_id = c("B72", "B73", "B79"), type = NULL)
coords <- as.matrix(soc[, c("longitude", "latitude")])
rownames(coords) <- soc$soc_id

g_data <- methods::new("gData", coords = coords, gGraph.name = "worldgraph.10k")
node_ids <- geoGraph::getNodes(g_data)
cat("\n=== node_ids for B72, B73, B79 ===\n")
print(node_ids)
cat("Do B72 and B73 share a node?", node_ids[1] == node_ids[2], "\n")

# --- dijkstraFrom: single source (B72's node) to the other two ---
point_g_data <- methods::new("gData", coords = coords["B72", , drop = FALSE], gGraph.name = "worldgraph.10k")
point_node <- geoGraph::getNodes(point_g_data)
cat("\n=== point_node (B72) ===\n")
print(point_node)

query_g_data <- methods::new("gData", coords = coords[c("B73", "B79"), , drop = FALSE], gGraph.name = "worldgraph.10k")
query_node_ids <- geoGraph::getNodes(query_g_data)
cat("\n=== query_node_ids (B73, B79) ===\n")
print(query_node_ids)

cat("\n=== dijkstraFrom(query_g_data, start = point_node) ===\n")
path <- geoGraph::dijkstraFrom(query_g_data, start = point_node)
cat("class(path):\n"); print(class(path))
cat("length(path):\n"); print(length(path))
cat("names(path):\n"); print(names(path))
cat("str(path, max.level = 1):\n"); str(path, max.level = 1)

cat("\n=== gPath2dist(path) ===\n")
d <- geoGraph::gPath2dist(path)
cat("class(d):\n"); print(class(d))
cat("names(d):\n"); print(names(d))
print(d)

# --- dijkstraBetween: all pairs among B72, B73, B79 ---
cat("\n\n=== dijkstraBetween(g_data) for B72,B73,B79 ===\n")
path2 <- geoGraph::dijkstraBetween(g_data)
cat("names(path2):\n"); print(names(path2))
d2 <- geoGraph::gPath2dist(path2)
cat("class(d2):\n"); print(class(d2))
cat("names(d2):\n"); print(names(d2))
print(d2)
