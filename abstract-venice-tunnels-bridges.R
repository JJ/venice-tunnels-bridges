## ----statphys.abs, echo=FALSE, message=F, fig.height=4, fig.pos="h", fig.cap="Venice street graph. Edge color is red for bridges, blue for underpasses or passages and yellow for everything else."----
library(igraph)
load("venice.graph.undirected.Rdata")
E(venice.graph.undirected)[ E(venice.graph.undirected)$sotoportego != FALSE ]$color <- rgb(0,0,1,.5)
E(venice.graph.undirected)[ E(venice.graph.undirected)$bridge != FALSE ]$color <- rgb(1,0,0,.5)
venice.graph.undirected <- delete_vertices(venice.graph.undirected, V(venice.graph.undirected)[degree(venice.graph.undirected) == 0])

V(venice.graph.undirected)$betweenness <- betweenness(venice.graph.undirected, directed=F)
E(venice.graph.undirected)$betweenness <- edge_betweenness(venice.graph.undirected, directed=F)
par(mar=c(0,0,0,0)+.1)
plot(venice.graph.undirected,vertex.label=NA, vertex.shape="none",
     edge.color=E(venice.graph.undirected)$color,
     edge.width=1+E(venice.graph.undirected)$betweenness/100000,
     edge.arrow.size=0, vertex.size=0,
     vertex.frame.color=NA)

graph.edges <- E(venice.graph.undirected)
number.of.edges <- length(graph.edges)
percent.bridges <- round(length(graph.edges[graph.edges$bridge == T])*100/number.of.edges,2)
percent.sotoportegos <- round(length(graph.edges[graph.edges$sotoportego != F])*100/number.of.edges,2)


eb <- E(venice.graph.undirected)$betweenness

# Identify sotoportego and bridge edges
soto_edges <- E(venice.graph.undirected)[E(venice.graph.undirected)$sotoportego != FALSE]
bridge_edges <- E(venice.graph.undirected)[E(venice.graph.undirected)$bridge != FALSE]

# Get top 5 betweenness in each
top5_soto <- soto_edges[order(E(venice.graph.undirected)[soto_edges]$betweenness, decreasing = TRUE)[1:5]]
top5_bridge <- bridge_edges[order(E(venice.graph.undirected)[bridge_edges]$betweenness, decreasing = TRUE)[1:5]]

# Initialize all labels empty
E(venice.graph.undirected)$label <- NA

# Assign labels to the selected edges
E(venice.graph.undirected)[top5_soto]$label <- E(venice.graph.undirected)[top5_soto]$name
E(venice.graph.undirected)[top5_bridge]$label <- E(venice.graph.undirected)[top5_bridge]$name

# Plot with labels visible at high resolution
par(mar=c(0,0,0,0)+.1)
plot(venice.graph.undirected,
     vertex.label=NA,
     vertex.shape="none",
     edge.color=E(venice.graph.undirected)$color,
     edge.width=1 + E(venice.graph.undirected)$betweenness / 100000,
     edge.arrow.size=0,
     vertex.size=0,
     vertex.frame.color=NA,
     edge.label = E(venice.graph.undirected)$label,
     edge.label.cex = 8,      # Large enough for 8000x6000
     edge.label.color = "black",
     edge.label.family = "sans")
