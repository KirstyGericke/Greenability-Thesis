# Author: Kirsten Gericke
# Date: July 2024
# University of Amsterdam Software Engineering Masters Thesis

# Correlation Heat Map Greenability Metrics vs Refactoring Churn

# This file performs the following actions:
# 1. Get Data
# 2. Reshape Data
# 3. Correlation Tests
# 4. Separate Metrics and Properties
# 5. Rename labels
# 6. Save correlation results to CSV
# 7. Produce 6 Heatmaps:
#      - Heat map 1: Metric Correlations
#      - Heat map 2: Metric Correlations p values
#      - Heat map 3: Metric Correlations p value < 0.05
#      - Heat map 4: Property Correlations
#      - Heat map 5: Property Correlations p values
#      - Heat map 6: Property Correlations p value < 0.05

# Load necessary libraries
install.packages("dplyr")
install.packages("tidyr")
install.packages("ggplot2")
install.packages("corrplot")
library(dplyr)
library(tidyr)
library(ggplot2)
library(corrplot)

##########################
# Get data
##########################

# Load data
churn_df <- read.csv("/Users/kirstengericke/Desktop/correlation to upload/correlation/churn.csv")
metrics_df <- read.csv("/Users/kirstengericke/Desktop/correlation to upload/correlation/metrics.csv")

# select only volume in PM churn column
churn_df<- data.frame(System = churn_df$System,
                      Refactoring = churn_df$Refactoring,
                      Churn = churn_df$average.totalNewVolumeInMonths)

##########################
# Reshape Data
##########################

# pivot churn
churn_df <- churn_df %>%
  select(System, Refactoring, Churn) %>%
  spread(key = System, value = Churn)

#write.csv(churn_df, file = "churn_df.csv", row.names = TRUE)

# Inspect the structure of the data frames
str(metrics_df)
str(churn_df)

# Print the first few rows of each dataframe
head(metrics_df)
head(churn_df)

# Rename the first column in metrics_df to "Metric"
colnames(metrics_df)[1] <- "Metric"

# Reshape metrics_df to long format for easier processing
metrics_long <- metrics_df %>%
  pivot_longer(cols = -Metric, names_to = "System", values_to = "MetricValue")

# Reshape churn_df to long format
churn_long <- churn_df %>%
  pivot_longer(cols = -Refactoring, names_to = "System", values_to = "Churn")

# Check the first few rows to ensure correct transformation
head(metrics_long)
head(churn_long)

# Combine metrics with churn data
combined_data <- metrics_long %>%
  inner_join(churn_long, by = "System", relationship = "many-to-many")

# Check the first few rows to ensure correct combination
head(combined_data)

##########################
# Correlation Tests
##########################

# Calculate Spearman correlation for each metric against each refactoring's churn values
cor_results <- combined_data %>%
  group_by(Metric, Refactoring) %>%
  summarise(cor_value = cor(MetricValue, Churn, method = "spearman"),
            p_value = cor.test(MetricValue, Churn, method = "spearman")$p.value, 
            .groups = 'drop')

##########################
# Separate Metrics and Properties
##########################

# select properties from list
prop_cor_results <- cor_results %>%
  filter(Metric %in% c("maintainability", "architecture", "reliability"))

#calculate overall osh property cor and p
osh <- cor_results %>%
  filter(Metric %in% c("Activity Risk", "Freshness Risk", "Management Risk"))

osh_avg <- osh %>%
  group_by(Refactoring) %>%
  summarise(
    cor_value = mean(cor_value, na.rm = TRUE),
    p_value = mean(p_value, na.rm = TRUE)
  ) %>%
  mutate(Metric = "osh")

#add osh to property correlation results
prop_cor_results <- bind_rows(prop_cor_results, osh_avg)

#remove property values so its just metrics
cor_results <- cor_results %>%
  filter(!Metric %in% c("maintainability", "architecture", "reliability"))

##########################
# Rename labels
##########################

prop_cor_results <- prop_cor_results %>%
  mutate(Refactoring = case_when(
    Refactoring == "extractmethod" ~ "Extract Method",
    Refactoring == "extractvariable" ~ "Extract Local Variable",
    Refactoring == "variabletofield" ~ "Convert Local Variable to Field",
    Refactoring == "introduceindirection" ~ "Introduce Indirection",
    Refactoring == "inline" ~ "Inline Method",
    Refactoring == "introducepo" ~ "Introduce Parameter Object",
    TRUE ~ Refactoring  # This line keeps any other refactorings unchanged
  ))

cor_results <- cor_results %>%
  mutate(Refactoring = case_when(
    Refactoring == "extractmethod" ~ "Extract Method",
    Refactoring == "extractvariable" ~ "Extract Local Variable",
    Refactoring == "variabletofield" ~ "Convert Local Variable to Field",
    Refactoring == "introduceindirection" ~ "Introduce Indirection",
    Refactoring == "inline" ~ "Inline Method",
    Refactoring == "introducepo" ~ "Introduce Parameter Object",
    TRUE ~ Refactoring  # This line keeps any other refactorings unchanged
  ))

prop_cor_results <- prop_cor_results %>%
  mutate(Metric = case_when(
    Metric == "maintainability" ~ "Maintainability",
    Metric == "architecture" ~ "Architecture Quality",
    Metric == "osh" ~ "Open Source Health",
    Metric == "reliability" ~ "Reliability",
    TRUE ~ Metric  # This line keeps any other metrics unchanged
  ))

cor_results <- cor_results %>%
  mutate(Metric = case_when(
    Metric == "volume" ~ "Volume",
    Metric == "unitSize" ~ "Unit Size",
    Metric == "unitInterfacing" ~ "Unit Interfacing",
    Metric == "unitComplexity" ~ "Unit Complexity",
    Metric == "testCodeRatio" ~ "Test Code Ratio",
    Metric == "technologyPrevalence" ~ "Technology Prevalence",
    Metric == "moduleCoupling" ~ "Module Coupling",
    Metric == "duplication" ~ "Duplication",
    Metric == "componentCoupling" ~ "Component Coupling",
    Metric == "componentCohesion" ~ "Component Cohesion",
    Metric == "communicationCentralization" ~ "Communication Centralization",
    Metric == "codeReuse" ~ "Code Reuse",
    Metric == "codeBreakdown" ~ "Code Breakdown",
    TRUE ~ Metric  # This line keeps any other metrics unchanged
  ))


##########################
# Save correlation results to CSV
##########################

# write file of metric results
write.csv(cor_results, file = "metric_correlation_results.csv", row.names = TRUE)

# write file of property results
write.csv(prop_cor_results, file = "property_correlation_results.csv", row.names = TRUE)


##########################
# Heat map 1: Metric Correlations
##########################

# Plot heatmap for correlation values
ggplot(cor_results, aes(x = Refactoring, y = Metric, fill = cor_value)) +
  geom_tile(color = "white", size = 0.3) +  # Add color to the tiles and size for border
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1, 1), space = "Lab", 
                       name = "Spearman\nCorrelation") +
  theme_minimal(base_size = 15) +  # Increase base size for larger elements
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 10, hjust = 1),
        legend.title = element_text(size = 12),  # Change legend title size
        legend.text = element_text(size = 12)) +  # Change legend text size
  coord_fixed(ratio = 0.5) +  # Adjust the aspect ratio
  labs(x = "Effort per Refactoring", y = "Metric") +
  geom_text(aes(label = sprintf("%.2f", cor_value)), color = "black", size = 3)  # Increase text size

##########################
# Heat map 2: Metric Correlations p values
##########################

ggplot(cor_results, aes(x = Refactoring, y = Metric, fill = p_value)) +
  geom_tile(color = "white", size = 0.3) +  # Add color to the tiles and size for border
  scale_fill_gradient(low = "green", high = "red", 
                      limit = c(0, 1),
                      name = "p-value") +
  theme_minimal(base_size = 15) +  # Increase base size for larger elements
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 10, hjust = 1),
        legend.title = element_text(size = 15),  # Change legend title size
        legend.text = element_text(size = 12)) +  # Change legend text size
  coord_fixed(ratio = 0.5) +  # Adjust the aspect ratio
  labs(x = "Effort per Refactoring", y = "Metric") +
  geom_text(aes(label = sprintf("%.3f", p_value)), color = "black", size = 3)  # Increase text size


##########################
# Heat map 3: Metric Correlations p value < 0.05
##########################

# Create a custom color scale to highlight p-values < 0.05 in green
ggplot(cor_results, aes(x = Refactoring, y = Metric, fill = p_value)) +
  geom_tile(color = "white", size = 0.3) +  # Add color to the tiles and size for border
  scale_fill_gradientn(colors = c("green", "red"),
                       values = scales::rescale(c(0, 0.049, 0.05, 1)),
                       breaks = c(0, 0.05, 1),
                       labels = c("0", "<0.05", "1"),
                       name = "p-value") +
  theme_minimal(base_size = 15) +  # Increase base size for larger elements
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 10, hjust = 1),
        legend.title = element_text(size = 15),  # Change legend title size
        legend.text = element_text(size = 12)) +  # Change legend text size
  coord_fixed(ratio = 0.5) +  # Adjust the aspect ratio
  labs(x = "Effort per Refactoring", y = "Metric") +
  geom_text(aes(label = sprintf("%.3f", p_value)), color = "black", size = 3)  # Increase text size



##########################
# Heat map 4: Property Correlations
##########################



# Plot heatmap for correlation values
ggplot(prop_cor_results, aes(x = Refactoring, y = Metric, fill = cor_value)) +
  geom_tile(color = "white", size = 0.3) +  # Add color to the tiles and size for border
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1, 1), space = "Lab", 
                       name = "Spearman\nCorrelation") +
  theme_minimal(base_size = 15) +  # Increase base size for larger elements
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 10, hjust = 1),
        legend.title = element_text(size = 12),  # Change legend title size
        legend.text = element_text(size = 12)) +  # Change legend text size
  coord_fixed(ratio = 0.5) +  # Adjust the aspect ratio
  labs(x = "Effort per Refactoring", y = "Property") +
  geom_text(aes(label = sprintf("%.2f", cor_value)), color = "black", size = 3)  # Increase text size

##########################
# Heat map 5: Property Correlations p values
##########################

ggplot(prop_cor_results, aes(x = Refactoring, y = Metric, fill = p_value)) +
  geom_tile(color = "white", size = 0.3) +  # Add color to the tiles and size for border
  scale_fill_gradient(low = "green", high = "red", 
                      limit = c(0, 1),
                      name = "p-value") +
  theme_minimal(base_size = 15) +  # Increase base size for larger elements
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 10, hjust = 1),
        legend.title = element_text(size = 15),  # Change legend title size
        legend.text = element_text(size = 12)) +  # Change legend text size
  coord_fixed(ratio = 0.5) +  # Adjust the aspect ratio
  labs(x = "Effort per Refactoring", y = "Metric") +
  geom_text(aes(label = sprintf("%.3f", p_value)), color = "black", size = 3)  # Increase text size


##########################
# Heat map 6: Property Correlations p value < 0.05
##########################

# Create a custom color scale to highlight p-values < 0.05 in green
ggplot(prop_cor_results, aes(x = Refactoring, y = Metric, fill = p_value)) +
  geom_tile(color = "white", size = 0.3) +  # Add color to the tiles and size for border
  scale_fill_gradientn(colors = c("green", "red"),
                       values = scales::rescale(c(0, 0.049, 0.05, 1)),
                       breaks = c(0, 0.05, 1),
                       labels = c("0", "<0.05", "1"),
                       name = "p-value") +
  theme_minimal(base_size = 15) +  # Increase base size for larger elements
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 10, hjust = 1),
        legend.title = element_text(size = 15),  # Change legend title size
        legend.text = element_text(size = 12)) +  # Change legend text size
  coord_fixed(ratio = 0.5) +  # Adjust the aspect ratio
  labs(x = "Effort per Refactoring", y = "Metric") +
  geom_text(aes(label = sprintf("%.3f", p_value)), color = "black", size = 3)  # Increase text size




