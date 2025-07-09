## ----statphys.abs, echo=FALSE, message=F----
# Load the necessary library
library(igraph)

# Load the graph data
# Make sure the "venice.graph.undirected.Rdata" file is in your working directory
load("venice.graph.undirected.Rdata")

# Assign colors to edges: blue for tunnels (sotoportegos), red for bridges
E(venice.graph.undirected)[ E(venice.graph.undirected)$sotoportego != FALSE ]$color <- rgb(0,0,1,.5)
E(venice.graph.undirected)[ E(venice.graph.undirected)$bridge != FALSE ]$color <- rgb(1,0,0,.5)

# Remove isolated vertices (nodes with no connections) to clean up the graph
venice.graph.undirected <- delete_vertices(venice.graph.undirected, V(venice.graph.undirected)[degree(venice.graph.undirected) == 0])

# Calculate centrality measures for vertices and edges
# This helps determine the importance of each node and path
V(venice.graph.undirected)$betweenness <- betweenness(venice.graph.undirected, directed=F)
E(venice.graph.undirected)$betweenness <- edge_betweenness(venice.graph.undirected, directed=F)


# --- START: Identify Top 5 Bridges and Tunnels ---

# Isolate the bridge and sotoportego (tunnel) edges
bridges <- E(venice.graph.undirected)[E(venice.graph.undirected)$bridge != FALSE]
sotoportegos <- E(venice.graph.undirected)[E(venice.graph.undirected)$sotoportego != FALSE]

# CORRECTED SECTION: Robustly extract edge names
# The 'name' attribute can be a list or vector for a single edge.
# We'll use sapply to process it, ensuring we get one name per edge.
bridge_names <- sapply(bridges$name, function(n) {
  if (is.null(n) || length(n) == 0) return(NA_character_)
  return(n[1]) # Take the first name if multiple exist
})

sotoportego_names <- sapply(sotoportegos$name, function(n) {
  if (is.null(n) || length(n) == 0) return(NA_character_)
  return(n[1]) # Take the first name if multiple exist
})

# Create data frames with the cleaned names
bridge_data <- data.frame(
  name = bridge_names,
  betweenness = bridges$betweenness,
  stringsAsFactors = FALSE
)
sotoportego_data <- data.frame(
  name = sotoportego_names,
  betweenness = sotoportegos$betweenness,
  stringsAsFactors = FALSE
)

# Remove any edges that might not have a name (this will now work correctly)
bridge_data <- bridge_data[!is.na(bridge_data$name) & bridge_data$name != "", ]
sotoportego_data <- sotoportego_data[!is.na(sotoportego_data$name) & sotoportego_data$name != "", ]

# Order the data frames by betweenness score in descending order and select the top 5
top_bridges <- head(bridge_data[order(-bridge_data$betweenness), ], 5)
top_sotoportegos <- head(sotoportego_data[order(-sotoportego_data$betweenness), ], 5)

# Print the names of the top edges to the console for your reference
print("Top 5 Bridges (by betweenness):")
print(top_bridges)
print("Top 5 Tunnels/Sotoportegos (by betweenness):")
print(top_sotoportegos)

# --- END: Identify Top 5 Bridges and Tunnels ---


# --- START: Generate High-Resolution Plot with Labels ---

# Define a layout for the graph. This is crucial for getting vertex coordinates for label placement.
# This step can be computationally intensive for a large graph.
cat("Calculating graph layout... This may take a few moments.\n")
graph_layout <- layout_with_fr(venice.graph.undirected)
cat("Layout calculation complete.\n")

# Set up a PNG file for the output with the specified high resolution
png("venice_graph_with_labels.png", width = 8000, height = 6000)

# Set plotting margins to zero
par(mar=c(0,0,0,0)+.1)

# Plot the main graph
plot(venice.graph.undirected,
     layout = graph_layout,
     vertex.label=NA,
     vertex.shape="none",
     edge.color=E(venice.graph.undirected)$color,
     edge.width=1+E(venice.graph.undirected)$betweenness/100000,
     edge.arrow.size=0,
     vertex.size=0,
     vertex.frame.color=NA)

# Add labels for the top 5 bridges
for (i in 1:nrow(top_bridges)) {
  edge_name <- top_bridges$name[i]
  # Find the specific edge in the graph by its name
  # We search for the name within the list-like attribute
  current_edge <- E(venice.graph.undirected)[sapply(E(venice.graph.undirected)$name, function(n) edge_name %in% n)]
  # Since a name can appear more than once, we take the first match
  if (length(current_edge) > 0) {
    current_edge <- current_edge[1]
  } else {
    next # Skip if edge not found
  }

  # Get the two vertices connected by this edge
  edge_vertices <- ends(venice.graph.undirected, current_edge)
  # Get the coordinates of these vertices from the pre-calculated layout
  v1_coords <- graph_layout[edge_vertices[1,1], ]
  v2_coords <- graph_layout[edge_vertices[1,2], ]
  # Calculate the midpoint of the edge to place the label
  label_x <- mean(c(v1_coords[1], v2_coords[1]))
  label_y <- mean(c(v1_coords[2], v2_coords[2]))
  # Add the text label to the plot
  # 'cex' controls the font size. For a high-res plot, this needs to be large.
  # We've increased it significantly. Adjust as needed.
  text(label_x, label_y, labels = edge_name, cex = 20, col = "black", font = 2)
}

# Add labels for the top 5 sotoportegos (tunnels)
for (i in 1:nrow(top_sotoportegos)) {
  edge_name <- top_sotoportegos$name[i]
  current_edge <- E(venice.graph.undirected)[sapply(E(venice.graph.undirected)$name, function(n) edge_name %in% n)]
  if (length(current_edge) > 0) {
    current_edge <- current_edge[1]
  } else {
    next # Skip if edge not found
  }

  edge_vertices <- ends(venice.graph.undirected, current_edge)
  v1_coords <- graph_layout[edge_vertices[1,1], ]
  v2_coords <- graph_layout[edge_vertices[1,2], ]
  label_x <- mean(c(v1_coords[1], v2_coords[1]))
  label_y <- mean(c(v1_coords[2], v2_coords[2]))
  # 'cex' controls the font size. For a high-res plot, this needs to be large.
  # We've increased it significantly. Adjust as needed.
  text(label_x, label_y, labels = edge_name, cex = 20, col = "black", font = 2)
}

# Finalize and save the PNG file
dev.off()

cat("High-resolution graph saved to 'venice_graph_with_labels.png'\n")

# --- END: Generate High-Resolution Plot with Labels ---


# --- Original Summary Statistics ---
graph.edges <- E(venice.graph.undirected)
number.of.edges <- length(graph.edges)
percent.bridges <- round(length(graph.edges[graph.edges$bridge == T])*100/number.of.edges,2)
percent.sotoportegos <- round(length(graph.edges[graph.edges$sotoportego != F])*100/number.of.edges,2)

# Print summary to console
cat(paste("\nTotal Edges:", number.of.edges, "\n"))
cat(paste("Percentage of Bridges:", percent.bridges, "%\n"))
cat(paste("Percentage of Tunnels/Sotoportegos:", percent.sotoportegos, "%\n"))
