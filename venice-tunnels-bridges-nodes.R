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
    paste(elements_clean, collapse = " | ")
  })

  # 6. Concatenate with " - " if multiple strings
  paste(parsed_strings, collapse = "- \n")
}


load("venice.graph.undirected.Rdata")
graph.edges <- E(venice.graph.undirected)
number.of.edges <- length(graph.edges)
percent.bridges <- round(length(graph.edges[graph.edges$bridge == T])*100/number.of.edges,2)
percent.sotoportegos <- round(length(graph.edges[graph.edges$sotoportego != F])*100/number.of.edges,2)


## ----statphys.graph, echo=FALSE, message=F, fig.height=4, fig.pos="h!tbp", fig.cap="Venice street graph. Edge color is red for bridges, blue for underpasses or passages and yellow for everything else.", cache = T----
E(venice.graph.undirected)[ E(venice.graph.undirected)$sotoportego != FALSE ]$color <- rgb(0,0,1,.5)
E(venice.graph.undirected)[ E(venice.graph.undirected)$bridge != FALSE ]$color <- rgb(1,0,0,.5)
venice.graph.undirected <- delete_vertices(venice.graph.undirected, V(venice.graph.undirected)[degree(venice.graph.undirected) == 0])

V(venice.graph.undirected)$betweenness <- betweenness(venice.graph.undirected)
V(venice.graph.undirected)$size <- 0
V(venice.graph.undirected)[ V(venice.graph.undirected)$betweenness >= 2448976.1 ]$size <- V(venice.graph.undirected)[ V(venice.graph.undirected)$betweenness >= 2448976.1 ]$betweenness /500000
V(venice.graph.undirected)[ V(venice.graph.undirected)$betweenness >= 2448976.1 ]$color <- "red"

V(venice.graph.undirected)$closeness <- closeness(venice.graph.undirected)
V(venice.graph.undirected)[ V(venice.graph.undirected)$closeness >= 4.095256e-06 ]$size <- V(venice.graph.undirected)[ V(venice.graph.undirected)$closeness >= 4.095256e-06 ]$closeness * 1000000
V(venice.graph.undirected)[ V(venice.graph.undirected)$closeness >= 4.095256e-06 ]$color <- "blue"

E(venice.graph.undirected)$betweenness <- edge_betweenness(venice.graph.undirected, directed=F)
par(mar=c(0,0,0,0)+.1)
plot(venice.graph.undirected,vertex.label=NA, vertex.shape="none",
     edge.color=E(venice.graph.undirected)$color,
     edge.width=2, vertex.size=0,
     vertex.frame.color=NA)

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
E(venice.graph.undirected)[top5_soto]$label <- paste0("S", 1:5)
#  sapply(E(venice.graph.undirected)[top5_soto]$name, process_name_vector))

E(venice.graph.undirected)[top5_bridge]$label <- paste0( "B", 1:5)
#  sapply(E(venice.graph.undirected)[top5_bridge]$name, process_name_vector))


# Plot with labels visible at high resolution
par(mar=c(0,0,0,0)+.1)

plot(venice.graph.undirected,
     vertex.label=NA,
     layout=layout_with_mds,
     vertex.shape="circle",
     vertex.size=V(venice.graph.undirected)$size,
     edge.color=E(venice.graph.undirected)$color,
     edge.width=1 + E(venice.graph.undirected)$betweenness / 500000,
     edge.arrow.size=0,
     vertex.frame.color=NA,
     edge.label = E(venice.graph.undirected)$label,
     edge.label.cex = 0.4,
     edge.label.family = "sans")



## ----statphys.edge.bw.table.sp, echo=FALSE, message=F, fig.pos="h!tb"------------------------------------------------------------------------------
top5_sotoportegos <- data.frame(
  name = sapply(E(venice.graph.undirected)[top5_soto]$name, process_name_vector),
  betweenness = E(venice.graph.undirected)[top5_soto]$betweenness
)
top5_bridges <- data.frame(
  name = sapply(E(venice.graph.undirected)[top5_bridge]$name, process_name_vector),
  betweenness = E(venice.graph.undirected)[top5_bridge]$betweenness
)

library(kableExtra)
knitr::kable(top5_sotoportegos,
  caption="Top 5 sotoportego edges by edge betweenness centrality.",
  col.names = c("Name", "Edge Betweenness"), "latex", booktabs = T, fullwidth=F
) %>% column_spec(1, width = "30em", latex_column_spec = "p{32em}") %>% column_spec(2, width = "5em", latex_column_spec = "p{4em}") %>% kable_styling(latex_options = c("striped","hold_position"))


## ----statphys.edge.bw.table.bridges, echo=FALSE, message=F, fig.pos="h!tb"-------------------------------------------------------------------------
knitr::kable(top5_bridges,
  caption="Top 5 bridge edges by edge betweenness centrality.",
  col.names = c("Name", "Edge Betweenness"), "latex", booktabs = T
)


## ----statphys.edgebw.density, echo=FALSE, message=F, warning=F, fig.height=3, fig.pos="h!tbp", fig.cap="Edge betweenness density graph for sotoportegos, bridges and everything else; colors as usual."----
edge_betweenness_bridges <- E(venice.graph.undirected)[E(venice.graph.undirected)$bridge == TRUE]$betweenness
edge_betweenness_sotoportegos <- E(venice.graph.undirected)[E(venice.graph.undirected)$sotoportego != FALSE]$betweenness
edge_betweenness_everything_else <- E(venice.graph.undirected)[E(venice.graph.undirected)$bridge == FALSE & E(venice.graph.undirected)$sotoportego == FALSE]$betweenness

library(ggplot2)
all_bw_df <- rbind(
  data.frame(type = "Bridge", betweenness = edge_betweenness_bridges),
  data.frame(type = "Sotoportego", betweenness = edge_betweenness_sotoportegos),
  data.frame(type = "Everything Else", betweenness = edge_betweenness_everything_else)
)

# use red for bridges, blue for sotoportegos, and yellow for everything else
all_bw_df$type <- factor(all_bw_df$type, levels = c("Bridge", "Sotoportego", "Everything Else"))
usual_colors <- c("red", "blue", "lightyellow")

ggplot(all_bw_df, aes(x = betweenness, fill = type)) +
  geom_density(alpha = 0.5) +
  scale_x_log10() +
  labs( x = "Edge Betweenness (log scale)",
       y = "Kernel Density Estimation") +
  theme_minimal() + scale_fill_manual(values = usual_colors)


## ----statphys.edgebw, echo=FALSE, message=F, warning=F, fig.height=3, fig.pos="h", fig.cap="Overall edge betweenness centrality values for bridges, sotoportegos and everything else."----

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

# normalize rank by dividing by the number of elements in the data frame
bridges_bw_df$normalized_rank <- bridges_bw_df$rank / nrow(bridges_bw_df)
sotoportegos_bw_df$normalized_rank <- sotoportegos_bw_df$rank / nrow(sotoportegos_bw_df)
everything_else_bw_df$normalized_rank <- everything_else_bw_df$rank / nrow(everything_else_bw_df)


ggplot() +
  geom_line(data = bridges_bw_df, aes(x = normalized_rank, y = betweenness), color = "red", linewidth = 1) +
  geom_line(data = sotoportegos_bw_df, aes(x = normalized_rank, y = betweenness), color = "blue", linewidth = 1) +
  geom_line(data = everything_else_bw_df, aes(x = normalized_rank, y = betweenness), color = "yellow", linewidth = 1) +
  scale_y_log10() + scale_x_log10()+
  labs( x = "Rank (by betweenness)",
       y = "Betweenness Centrality (log scale)") +
  theme_minimal()


## ----statphys.all.betweenness, echo=FALSE, message=F, warning=F, fig.height=3, fig.pos="h!tbp", fig.cap="Ranked edge betweenness centrality for bridges (red), sotoportegos (blue) and everything else (light yellow)."----

all_betweenness_df <- data.frame(
  type = ifelse(E(venice.graph.undirected)$bridge == TRUE, "Bridge",
    ifelse(E(venice.graph.undirected)$sotoportego != FALSE, "Sotoportego", "Regular")),
  betweenness = E(venice.graph.undirected)$betweenness
)

sorted_all_betweenness <- all_betweenness_df[order(all_betweenness_df$betweenness, decreasing = TRUE), ]
sorted_all_betweenness$rank <- 1:nrow(sorted_all_betweenness)
# use color blue for bridges, red for sotoportegos and yellow for everything else
sorted_all_betweenness$color <- ifelse(sorted_all_betweenness$type == "Bridge", "red",
  ifelse(sorted_all_betweenness$type == "Sotoportego", "blue", "lightyellow"))

ggplot(sorted_all_betweenness, aes(x=rank , y = betweenness)) +
  geom_bar(colour=sorted_all_betweenness$color,stat="identity") +
  scale_y_log10() +
  labs(x = "Rank",
       y = "Betweenness centrality") +
  theme_minimal()

