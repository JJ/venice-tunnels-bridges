## ----statphys.abs, echo=FALSE, message=F, fig.height=4, fig.pos="h", fig.cap="Venice street graph. Edge color is red for bridges, blue for underpasses or passages and yellow for everything else."----
library(igraph)
library(stringr)

process_name_vector <- function(name_vector) {
  parsed_strings <- sapply(name_vector, function(x) {
    # 1. Remove leading and trailing brackets
    x_clean <- str_remove_all(x, "^\\[|\\]$")

    # 2. Split by comma
    elements <- unlist(str_split(x_clean, ",\\s*"))

    # 3. Remove surrounding single or double quotes (escaped or unescaped)
    elements_clean <- str_replace_all(elements, "^(\"|')|(\"|')$", "")

    # 4. Trim any residual whitespace
    elements_clean <- str_trim(elements_clean)

    # 5. Concatenate with →
    paste(elements_clean, collapse = " → ")
  })

  # 6. Concatenate with " - " if multiple strings
  paste(parsed_strings, collapse = " -\n")
}


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
E(venice.graph.undirected)[top5_soto]$label <- paste(" 🛤️ ",
  sapply(E(venice.graph.undirected)[top5_soto]$name, process_name_vector))

E(venice.graph.undirected)[top5_bridge]$label <- paste( "🔺",
  sapply(E(venice.graph.undirected)[top5_bridge]$name, process_name_vector))


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
     edge.label.cex = 5,      # Large enough for 8000x6000
     edge.label.color = E(venice.graph.undirected)$label.color,
     edge.label.family = "sans")

edge_betweenness_bridges <- E(venice.graph.undirected)[E(venice.graph.undirected)$bridge == TRUE]$betweenness
edge_betweenness_sotoportegos <- E(venice.graph.undirected)[E(venice.graph.undirected)$sotoportego != FALSE]$betweenness
edge_betweenness_everything_else <- E(venice.graph.undirected)[E(venice.graph.undirected)$bridge == FALSE & E(venice.graph.undirected)$sotoportego == FALSE]$betweenness

library(ggplot2)

# reorder betweenness in descending order
bridges_bw_df <- data.frame(
  rank = 1:length(edge_betweenness_bridges),
  betweenness = sort(edge_betweenness_bridges, decreasing = TRUE)
)
sotoportegos_bw_df <- data.frame(
  rank = 1:length(edge_betweenness_sotoportegos),
  betweenness = sort(edge_betweenness_sotoportegos, decreasing = TRUE)
)
everything_else_bw_df <- data.frame(
  rank = 1:length(edge_betweenness_everything_else),
  betweenness = sort(edge_betweenness_everything_else, decreasing = TRUE)
)

ggplot() +
  geom_line(data = bridges_bw_df, aes(x = rank, y = betweenness), color = "red", size = 1) +
  geom_line(data = sotoportegos_bw_df, aes(x = rank, y = betweenness), color = "blue", size = 1) +
  geom_line(data = everything_else_bw_df, aes(x = rank, y = betweenness), color = "yellow", size = 1) +
  scale_y_log10() + scale_x_log10()+
  labs(title = "Betweenness Centrality of Bridges and Sotoportegos in Venice",
       x = "Rank (by Betweenness)",
       y = "Betweenness Centrality (log scale)") +
  theme_minimal()

# Repeat with only x axis going from 1 to 20
ggplot() +
  geom_line(data = bridges_bw_df[1:20, ], aes(x = rank, y = betweenness), color = "red", size = 1) +
  geom_line(data = sotoportegos_bw_df[1:20, ], aes(x = rank, y = betweenness), color = "blue", size = 1) +
  geom_line(data = everything_else_bw_df[1:20, ], aes(x = rank, y = betweenness), color = "yellow", size = 1) +
  labs(title = "Betweenness Centrality of Bridges and Sotoportegos in Venice (Top 20)",
       x = "Rank (by Betweenness)",
       y = "Betweenness Centrality") +
  theme_minimal()

all_bw_df <- rbind(
  data.frame(type = "Bridge", betweenness = edge_betweenness_bridges),
  data.frame(type = "Sotoportego", betweenness = edge_betweenness_sotoportegos),
  data.frame(type = "Everything Else", betweenness = edge_betweenness_everything_else)
)

ggplot(all_bw_df, aes(x = betweenness, fill = type)) +
  geom_density(alpha = 0.5) +
  scale_x_log10() +
  labs(title = "Edge Betweenness Distribution",
       x = "Edge Betweenness (log scale)",
       y = "Density") +
  theme_minimal()
