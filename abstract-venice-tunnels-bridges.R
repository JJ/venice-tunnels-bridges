## ----statphys.abs, echo=FALSE, message=F, fig.height=4, fig.pos="h", fig.cap="Venice street graph. Edge color is red for bridges, blue for underpasses or passages and yellow for everything else."----
library(igraph)
load("venice.graph.undirected.Rdata")
E(venice.graph.undirected)[ E(venice.graph.undirected)$sotoportego != FALSE ]$color <- "blue"
V(venice.graph.undirected)$betweenness <- betweenness(venice.graph.undirected, directed=F)
E(venice.graph.undirected)$betweenness <- edge_betweenness(venice.graph.undirected, directed=F)
par(mar=c(0,0,0,0)+.1)
plot(venice.graph.undirected,vertex.label=NA, edge.width=1, vertex.shape="none",
     edge.color=E(venice.graph.undirected)$color,
     edge.width=E(venice.graph.undirected)$betweenness/200,
     edge.arrow.size=0, vertex.size=0,
     vertex.frame.color=NA)
graph.edges <- E(venice.graph.undirected)
number.of.edges <- length(graph.edges)
percent.bridges <- round(length(graph.edges[graph.edges$bridge == T])*100/number.of.edges,2)
percent.sotoportegos <- round(length(graph.edges[graph.edges$sotoportego != F])*100/number.of.edges,2)

