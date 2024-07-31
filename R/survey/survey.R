# author: Kirsten Gericke
# July 2024
# Univeristy of Amsterdam Masters Software Engineering

# This file visualises results from the survey conducted in for validating
# Greenability properties through percieved effort required for software refactorings

# This file contains the following:
# 1. Heatmap of results
# 2. Normalised heatmap
# 3. Heatmap Standard Deviation
# 4. Boxplots

library(ggplot2)
library(reshape2)


#########################
# Heatmap
#########################


# Create a data frame with the given data
refactoring_data <- data.frame(
  Refactoring = c("Convert Local Variable to Field", "Extract Local Variable", "Extract Method", 
                  "Introduce Indirection", "Inline Method", "Introduce Parameter Object"),
  Maintainability = c(1.48, 1.6, 1.48, 1.44, 1.56, 1.48),
  Reliability = c(1.916666667, 2.12, 1.88, 1.8, 2.041666667, 2),
  Architecture_Quality = c(1.72, 1.88, 1.6, 1.6, 1.88, 1.84),
  Freshness = c(2.52173913, 2.695652174, 2.565217391, 2.652173913, 2.47826087, 2.652173913),
  Performance_Efficiency = c(2.652173913, 2.652173913, 2.565217391, 2.608695652, 2.695652174, 2.695652174)
)

refactoring_data_melt <- melt(refactoring_data, id.vars = "Refactoring")

# Plot the data
ggplot(refactoring_data_melt, aes(x = Refactoring, y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Refactoring Metrics", x = "Refactoring", y = "Value") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_discrete(name = "Metrics") +
  coord_cartesian(ylim = c(1, 5)) +
  theme_minimal()

heatmap_data <- refactoring_data_melt

# Rename the first column in metrics_df to "Metric"
colnames(heatmap_data)[1] <- "Refactoring"
colnames(heatmap_data)[2] <- "Metric"
colnames(heatmap_data)[3] <- "Value"

heatmap_data <- heatmap_data %>%
  mutate(Metric = case_when(
    Metric == "Architecture_Quality" ~ "Architecture Quality",
    Metric == "Performance_Efficiency" ~ "Performance Efficiency",
    TRUE ~ Metric  # This line keeps any other refactorings unchanged
  ))

heatmap_data$Metric <- factor(heatmap_data$Metric, levels = c(
  "Reliability", "Maintainability", "Architecture Quality", 
  "Freshness", "Performance Efficiency"
))

# Plot heatmap for correlation values
ggplot(heatmap_data, aes(x = Refactoring, y = Metric, fill = Value)) +
  geom_tile(color = "white", size = 0.3) +  # Add color to the tiles and size for border
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 2, limit = c(1, 3), space = "Lab", 
                       name = "Effort",
                       breaks = c(1, 3, 5),
                       labels = c("1: Less Effort", "3: Equal Effort", "5: More Effort")) +
  theme_minimal(base_size = 15) +  # Increase base size for larger elements
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 10, hjust = 1),
        legend.title = element_text(size = 12),  # Change legend title size
        legend.text = element_text(size = 12)) +  # Change legend text size
  coord_fixed(ratio = 0.5) +  # Adjust the aspect ratio
  labs(x = "Effort per Refactoring", y = "Property") +
  geom_text(aes(label = sprintf("%.2f", Value)), color = "black", size = 3)  # Increase text size







#######################
# Normalised heatmap 
#######################




# Load necessary libraries
library(ggplot2)
library(reshape2)

# Create the initial data frame
refactoring_data <- data.frame(
  Refactoring = c("Convert Local Variable to Field", "Extract Local Variable", "Extract Method", 
                  "Introduce Indirection", "Inline Method", "Introduce Parameter Object"),
  Maintainability = c(1.48, 1.6, 1.48, 1.44, 1.56, 1.48),
  Reliability = c(1.916666667, 2.12, 1.88, 1.8, 2.041666667, 2),
  Architecture_Quality = c(1.72, 1.88, 1.6, 1.6, 1.88, 1.84),
  Freshness = c(2.52173913, 2.695652174, 2.565217391, 2.652173913, 2.47826087, 2.652173913),
  Performance_Efficiency = c(2.652173913, 2.652173913, 2.565217391, 2.608695652, 2.695652174, 2.695652174)
)

# Normalize the data to range from -1 to 1
normalize <- function(x) {
  return (2 * ((x - 1) / (5 - 1)) - 1)
}

# Apply normalization to all columns except the 'Refactoring' column
normalized_data <- as.data.frame(lapply(refactoring_data[ , -1], normalize))
normalized_data$Refactoring <- refactoring_data$Refactoring

# Reshape the data for plotting
normalized_data_melt <- melt(normalized_data, id.vars='Refactoring', variable.name='Metric', value.name='Value')

normalized_data_melt <- normalized_data_melt %>%
  mutate(Metric = case_when(
    Metric == "Architecture_Quality" ~ "Architecture Quality",
    Metric == "Performance_Efficiency" ~ "Performance Efficiency",
    TRUE ~ Metric  # This line keeps any other refactorings unchanged
  ))

# Set the order of the properties (metrics)
normalized_data_melt$Metric <- factor(normalized_data_melt$Metric, levels = c(
  "Reliability", "Maintainability", "Architecture Quality", 
  "Freshness", "Performance Efficiency"
))

# Plot heatmap for normalized values
ggplot(normalized_data_melt, aes(x = Refactoring, y = Metric, fill = Value)) +
  geom_tile(color = "white", size = 0.3) +  # Add color to the tiles and size for border
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1, 1), space = "Lab", 
                       name = "Effort",
                       breaks = c(-1, 0, 1),
                       labels = c("Less Effort", "Moderate Effort", "More Effort")) +
  theme_minimal(base_size = 15) +  # Increase base size for larger elements
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 10, hjust = 1),
        legend.title = element_text(size = 12),  # Change legend title size
        legend.text = element_text(size = 12)) +  # Change legend text size
  coord_fixed(ratio = 0.5) +  # Adjust the aspect ratio
  labs(x = "Effort per Refactoring", y = "Property") +
  geom_text(aes(label = sprintf("%.2f", Value)), color = "black", size = 3)  # Increase text size





###########################
# Heatmap Standard Deviation
###########################



# Create the data frame for Standard Deviation
stddev_data <- data.frame(
  Refactoring = c("Convert Local Variable to Field", "Extract Local Variable", "Extract Method", 
                  "Introduce Indirection", "Inline Method", "Introduce Parameter Object"),
  Maintainability = c(0.7702813339, 1, 1.004987562, 0.86986589, 0.9609023537, 0.9183318209),
  Reliability = c(0.8805466023, 0.9273618495, 0.8812869378, 0.8660254038, 0.9990937923, 0.7637626158),
  Architecture_Quality = c(0.8906926144, 0.8326663998, 0.8164965809, 0.8164965809, 0.9273618495, 0.9433981132),
  Freshness = c(0.845822097, 0.7029019464, 0.7877520928, 0.7140598175, 0.845822097, 0.7140598175),
  Performance_Efficiency = c(0.6472807212, 0.7140598175, 0.8434823357, 0.7827184815, 0.7029019464, 0.6349504353)
)

# Reshape the data for plotting
stddev_data_melt <- melt(stddev_data, id.vars='Refactoring', variable.name='Metric', value.name='Value')

stddev_data_melt <- stddev_data_melt %>%
  mutate(Metric = case_when(
    Metric == "Architecture_Quality" ~ "Architecture Quality",
    Metric == "Performance_Efficiency" ~ "Performance Efficiency",
    TRUE ~ Metric  # This line keeps any other refactorings unchanged
  ))

# Set the order of the properties (metrics)
stddev_data_melt$Metric <- factor(stddev_data_melt$Metric, levels = c(
  "Reliability", "Maintainability", "Architecture Quality", 
  "Freshness", "Performance Efficiency"
))

# Plot heatmap for standard deviation values
ggplot(stddev_data_melt, aes(x = Refactoring, y = Metric, fill = Value)) +
  geom_tile(color = "white", size = 0.3) +  # Add color to the tiles and size for border
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = mean(stddev_data_melt$Value), space = "Lab", 
                       name = "Standard Deviation") +
  theme_minimal(base_size = 15) +  # Increase base size for larger elements
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 10, hjust = 1),
        legend.title = element_text(size = 12),  # Change legend title size
        legend.text = element_text(size = 12)) +  # Change legend text size
  coord_fixed(ratio = 0.5) +  # Adjust the aspect ratio
  labs(x = "Effort per Refactoring", y = "Property") +
  geom_text(aes(label = sprintf("%.2f", Value)), color = "black", size = 3)  # Increase text size





#########################
# Boxplots
#########################

refactoring_data <- data.frame(
  Refactoring = c("Convert Local Variable to Field", "Extract Local Variable", "Extract Method", 
                  "Introduce Indirection", "Inline Method", "Introduce Parameter Object"),
  Maintainability = c(1.48, 1.6, 1.48, 1.44, 1.56, 1.48),
  Reliability = c(1.916666667, 2.12, 1.88, 1.8, 2.041666667, 2),
  Architecture_Quality = c(1.72, 1.88, 1.6, 1.6, 1.88, 1.84),
  Freshness = c(2.52173913, 2.695652174, 2.565217391, 2.652173913, 2.47826087, 2.652173913),
  Performance_Efficiency = c(2.652173913, 2.652173913, 2.565217391, 2.608695652, 2.695652174, 2.695652174)
)

# Reshape the data for plotting
refactoring_data_melt <- melt(refactoring_data, id.vars='Refactoring', variable.name='Metric', value.name='Value')

refactoring_data_melt <- refactoring_data_melt %>%
  mutate(Metric = case_when(
    Metric == "Architecture_Quality" ~ "Architecture Quality",
    Metric == "Performance_Efficiency" ~ "Performance Efficiency",
    TRUE ~ Metric  # This line keeps any other refactorings unchanged
  ))

# Set the order of the properties (metrics)
refactoring_data_melt$Metric <- factor(refactoring_data_melt$Metric, levels = c(
  "Maintainability", "Architecture Quality", "Reliability",
  "Freshness", "Performance Efficiency"
))

# Boxplots for each refactoring
ggplot(refactoring_data_melt, aes(x = Refactoring, y = Value)) +
  geom_boxplot(fill = "grey", color = "black") +
  labs(title = "Boxplots of Scores for Each Refactoring",
       x = "Refactoring", y = "Score") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
  coord_cartesian(ylim = c(1, 3))

# Boxplots for each property
ggplot(refactoring_data_melt, aes(x = Metric, y = Value)) +
  geom_boxplot(fill = "grey", color = "black") +
  labs(title = "Boxplots of Scores for Each Property",
       x = "Property", y = "Score") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
  coord_cartesian(ylim = c(1, 3))
