## ----statphys.abs, echo=FALSE, message=F, fig.height=4, fig.pos="h", fig.cap="Venice street graph. Edge color is red for bridges, blue for underpasses or passages and yellow for everything else."----
library(igraph)
load("venice.graph.undirected.Rdata")
E(venice.graph.undirected)[ E(venice.graph.undirected)$sotoportego != FALSE ]$color <- "blue"
par(mar=c(0,0,0,0)+.1)
plot(venice.graph.undirected,vertex.label=NA,vertex.shape="none", fig.pos="h!tb", edge.width=1)
graph.edges <- E(venice.graph.undirected)
number.of.edges <- length(graph.edges)
percent.bridges <- round(length(graph.edges[graph.edges$bridge == T])*100/number.of.edges,2)
percent.sotoportegos <- round(length(graph.edges[graph.edges$sotoportego != F])*100/number.of.edges,2)

