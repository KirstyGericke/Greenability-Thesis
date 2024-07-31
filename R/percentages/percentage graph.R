# Author: Kirsten Gericke
# Date: July 2024
# University of Amsterdam Software Engineering Masters Thesis

# This file produces 3 graphs:
# 1: Total LOC vs. Average Percentage Changed per System
# 2: Total LOC vs. Average LOC Changed per System
# 3: Average LOC changed vs. Average %  Changed per Refactoring

# Load necessary libraries
install.packages("ggrepel")
library(ggplot2)
library(dplyr)
library(scales)
library(ggrepel)

###################################
# Graph 1: Total LOC vs. Average Percentage Changed
###################################

# load data
data <- data.frame(
  System = c("Commons Beanutils", "Commons CLI", "Commons Collections", "Commons IO", 
             "Commons Lang", "Commons Math", "Joda-Convert", "Joda-Time", "Sudoku"),
  Total_LoC = c(31538, 4739, 63852, 25663, 55626, 135796, 1317, 67590, 497),
  Average_Percentage_Change = c(1.35, 2.92, 1.18, 1.54, 1.41, 0.70, 12.33, 0.97, 19.16)
)

# Perform Pearson correlation test
cor_test <- cor.test(data$Total_LoC, data$Average_Percentage_Change, method = "pearson")
correlation <- cor_test$estimate
p_value <- cor_test$p.value

# Plot the graph
p <- ggplot(data, aes(x = Total_LoC, y = Average_Percentage_Change, label = System)) +
  geom_point(color = "black", size = 2) +
  geom_text_repel(size=3) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  scale_x_continuous(labels = comma) +
  scale_y_continuous(labels = scales::percent_format(scale = 1), limits = c(0, max(data$Average_Percentage_Change) * 1.1)) +
  theme_minimal() +
  labs(title = "Total LOC vs. Average Percentage Change",
       x = "Total LOC",
       y = "Average Percentage Change (%)") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1)) +
  annotate("text", x = max(data$Total_LoC) * 0.8, y = max(data$Average_Percentage_Change) * 0.9,
           label = paste("Pearson's r =", round(correlation, 2), "\n p-value =", round(p_value, 4)))

# Print the plot
print(p)


###################################
# Graph 2: Total LOC vs. Average LOC Changed
###################################



# Data
data <- data.frame(
  System = c("Commons Beanutils", "Commons CLI", "Commons Collections", "Commons IO", 
             "Commons Lang", "Commons Math", "Joda-Convert", "Joda-Time", "Sudoku"),
  Total_LoC = c(31538, 4739, 63852, 25663, 55626, 135796, 1317, 67590, 497),
  Extract_Method = c(402.75, 143.50, 308.75, 254.25, 853.50, 710.50, 215.50, 422.50, 182.50),
  Extract_Local_Variable = c(343.50, 0.00, 923.00, 197.00, 744.00, 472.25, 0.00, 291.33, 0.00),
  Inline_Method = c(592.00, 243.75, 521.25, 1220.75, 213.50, 2888.75, 283.50, 400.25, 111.50),
  Introduce_Indirection = c(965.25, 171.00, 2116.00, 107.00, 2684.75, 1083.00, 268.75, 1494.50, 181.00),
  Introduce_Parameter_Object = c(162.75, 87.50, 107.50, 203.00, 52.00, 368.75, 6.75, 853.25, 7.00),
  Convert_Local_Variable_to_Field = c(80.50, 185.00, 533.25, 385.25, 153.00, 182.00, 199.50, 463.00, 89.50)
)
data$Average_LOC_Changed <- rowMeans(data[, 3:8], na.rm = TRUE)

# Perform Pearson correlation test
cor_test <- cor.test(data$Total_LoC, data$Average_LOC_Changed, method = "pearson")
correlation <- cor_test$estimate
p_value <- cor_test$p.value

# Plot the graph
p <- ggplot(data, aes(x = Total_LoC, y = Average_LOC_Changed, label = System)) +
  geom_point(color = "black", size = 3) +
  geom_text_repel(size = 3) +  # Adjust the size parameter to make the labels smaller
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  scale_x_continuous(labels = comma) +
  theme_minimal() +
  labs(title = "Total LOC vs. Average LOC Changed",
       x = "Total LOC",
       y = "Average LOC Changed") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1)) +
  annotate("text", x = max(data$Total_LoC) * 0.85, y = max(data$Average_LOC_Changed) * 0.3,
           label = paste("Pearson's r =", round(correlation, 2), "\n p-value =", round(p_value, 4)))

# Print the plot
print(p)


###################################
# Graph 3: Average LOC changed vs. Average %  Changed per Refactoring
###################################

data <- data.frame(
  Refactoring = c("Extract Method","Extract Local Variable",
                  "Inline Method","Introduce Indirection",
                  "Introduce Parameter Object","Convert Local Variable to Field"),
  Churn = c(388.08,274.12,608.58,1030.92,205.17,252.67),
  Percentage = c(6.84,0.60,6.63,8.34,0.76,4.53)
)

cor_test <- cor.test(data$Churn, data$Percentage, method = "pearson")
correlation <- cor_test$estimate
p_value <- cor_test$p.value

# Plot the graph
ggplot(data, aes(x = Churn, y = Percentage, label = Refactoring)) +
  geom_point(color = "black", size = 3) +
  geom_text_repel(size = 3) +  # Adjust the size parameter to make the labels smaller
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  scale_x_continuous(labels = comma) +
  theme_minimal() +
  labs(title = "",
       x = "Average LOC changed",
       y = "Average Percentage (%) Changed") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1)) +
  coord_cartesian(ylim = c(0, 9)) +
  annotate("text", x = max(data$Churn) * 0.85, y = max(data$Percentage) * 0.3,
           label = paste("Pearson's r =", round(correlation, 2), "\n p-value =", round(p_value, 4)))



