# Author: Kirsten Gericke
# Date: July 2024
# University of Amsterdam Software Engineering Masters Thesis

# Comparing correlation results to survey results

#########################
# Correlation Data
#########################

cor_results <- read.csv("/Users/kirstengericke/Desktop/correlation to upload/survey_vs_correlations/prop_cor_results.csv")

ggplot(cor_results, aes(x = Refactoring, y = Value)) +
  geom_boxplot(fill = "grey", color = "black") +
  labs(title = "Refactoring Correlation Boxplots",
       x = "Refactoring", y = "Spearman Correlation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
        plot.title = element_text(hjust = 0.5)) +
  coord_cartesian(ylim = c(-1, 1))

ggplot(cor_results, aes(x = Metric, y = Value)) +
  geom_boxplot(fill = "grey", color = "black") +
  labs(title = "Property Correlation Boxplots",
       x = "Refactoring", y = "Spearman Correlation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
    plot.title = element_text(hjust = 0.5)) +
  coord_cartesian(ylim = c(-1, 1))


#########################
# Survey Data
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
  "Maintainability", "Architecture Quality", "Reliability",
  "Freshness", "Performance Efficiency"
))


survey_results <- normalized_data_melt

# Boxplots for each refactoring
ggplot(survey_results, aes(x = Refactoring, y = Value)) +
  geom_boxplot(fill = "grey", color = "black") +
  labs(title = "Refactoring Survey Boxplots",
       x = "Refactoring", y = "Perceived Effort") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
        plot.title = element_text(hjust = 0.5)) +
  coord_cartesian(ylim = c(-1, 1))

# Boxplots for each property
ggplot(survey_results, aes(x = Metric, y = Value)) +
  geom_boxplot(fill = "grey", color = "black") +
  labs(title = "Property Survey Boxplots",
       x = "Property", y = "Perceived Effort") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
        plot.title = element_text(hjust = 0.5)) +
  coord_cartesian(ylim = c(-1, 1))


#########################
# Combined Property boxplot
#########################


# Add a new column to indicate the dataset
cor_results$Dataset <- "Correlation"

# Get survey results from above
survey_data <- survey_results

# Add a new column to indicate the dataset
survey_data$Dataset <- "Survey"

# Combine the survey data with the correlation results
combined_data <- rbind(cor_results, survey_data)

# Ensure the Refactoring column is a factor with the levels in the desired order
combined_data$Refactoring <- factor(combined_data$Refactoring, levels = c("Convert Local Variable to Field", "Extract Local Variable", "Extract Method", 
                                                                          "Introduce Indirection", "Inline Method", "Introduce Parameter Object"))

combined_data
# Plot combined boxplots
ggplot(combined_data, aes(x = Refactoring, y = Value, fill = Dataset)) +
  geom_boxplot(color = "black") +
  scale_fill_manual(values = c("steelblue1", "lightgreen")) +
  labs(title = "Combined Refactoring Boxplots",
       x = "Refactoring", y = "Spearman Correaltion/Perceived Effort") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
        plot.title = element_text(hjust = 0.5)) +
  coord_cartesian(ylim = c(-1, 1))


#########################
# Combined Property boxplot
#########################

# Filter the combined data to include only the desired metrics
filtered_data <- combined_data %>%
  filter(Metric %in% c("Architecture Quality", "Maintainability", "Reliability", "Freshness"))

# Add the new data
new_data <- data.frame(
  Metric = rep("Freshness", 6),
  Refactoring = c("Extract Method", "Extract Local Variable", "Inline Method", "Introduce Indirection", "Introduce Parameter Object", "Convert Local Variable to Field"),
  Value = c(-0.41920795, -0.072336185, -0.17256835, -0.1181695, -0.3059565, -0.1862842),
  Dataset = rep("Correlation", 6)
)

# Combine the new data with the filtered data
filtered_data <- rbind(filtered_data, new_data)


ggplot(filtered_data, aes(x = Metric, y = Value, fill = Dataset)) +
  geom_boxplot(color = "black") +
  scale_fill_manual(values = c("steelblue1", "lightgreen")) +
  labs(title = "Combined Property Boxplots",
       x = "Metric", y = "Spearman Correaltion/Perceived Effort") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
        plot.title = element_text(hjust = 0.5)) +
  coord_cartesian(ylim = c(-1, 1))







