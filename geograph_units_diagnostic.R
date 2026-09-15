# Diagnostic: what units is worldgraph.10k's default edge cost actually in?
# Not part of the package -- run this once, paste back the console output.

library(geoGraph)

cat("=== hasCosts(worldgraph.10k) ===\n")
print(hasCosts(worldgraph.10k))

cat("\n=== worldgraph.10k@meta$costs (the cost rules baked into the bundled object) ===\n")
print(worldgraph.10k@meta$costs)

cat("\n=== A sample of raw edge weights from the graph itself ===\n")
ew <- graph::edgeWeights(geoGraph::getGraph(worldgraph.10k))
sample_w <- unlist(ew[1:20])
print(sample_w)
cat("\nRange of ALL edge weights in worldgraph.10k:\n")
print(range(unlist(ew), na.rm = TRUE))
cat("\nMost common edge weight values (table of a random sample of 5000):\n")
set.seed(1)
print(table(sample(unlist(ew), min(5000, length(unlist(ew))))))

cat("\n=== For comparison: real great-circle distance for one edge, via fields::rdist.earth ===\n")
# Take the first edge with weight 1 (a land-land edge) and compute its real
# great-circle distance directly, to see what a "cost of 1" corresponds to in km.
coords <- geoGraph::getCoords(worldgraph.10k)
E <- geoGraph::getEdges(worldgraph.10k, res.type = "matNames")
xy1 <- coords[E[1, 1], , drop = FALSE]
xy2 <- coords[E[1, 2], , drop = FALSE]
cat("Edge:", E[1, 1], "->", E[1, 2], "\n")
cat("Coords:\n"); print(rbind(xy1, xy2))
if (requireNamespace("fields", quietly = TRUE)) {
  cat("fields::rdist.earth (default, miles = TRUE):", fields::rdist.earth(xy1, xy2), "\n")
  cat("fields::rdist.earth (miles = FALSE, i.e. km):", fields::rdist.earth(xy1, xy2, miles = FALSE), "\n")
} else {
  cat("fields not installed -- skipping direct comparison\n")
}
