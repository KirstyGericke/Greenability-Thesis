# install packages
install.packages("reshape2")
install.packages("dplyr")
install.packages("tidyverse")
install.packages("ggplot2")
library(reshape2)
library(dplyr)
library(tidyverse)
library(ggplot2)

# load two csv files

churn_csv <- "~/Desktop/uploads/Sahin/correlation/churn.csv"
churn_data <- read.csv(churn_csv)

greenability_csv <- "~/Desktop/uploads/Sahin/correlation/greenability_scores.csv"
greenability_data <- read.csv(greenability_csv)

greenability_data <- greenability_data[order(greenability_data$System.Name), ]

all_metrics_csv <-"~/Desktop/uploads/Sahin/correlation/combined_systems.csv"
all_metrics <- read.csv(all_metrics_csv)

#######################

# Trying something out: ratio with averaging per system

#######################


merged_data <- churn_data %>%
  left_join(greenability_data, by = c("System" = "System.Name"))

merged_data <- merged_data %>%
  mutate(Ratio = average.totalNewVolumeInMonths / Volume..PM.)

merged_data <- data.frame(System = merged_data$System,
                          Refactoring = merged_data$Refactoring,
                          Greenability.Score = merged_data$Greenability.Score,
                          Ratio = merged_data$Ratio
                          )

average_values <- merged_data %>%
  group_by(System) %>%
  summarise(
    Avg_Greenability_Score = mean(Greenability.Score, na.rm = TRUE),
    Avg_Ratio = mean(Ratio, na.rm = TRUE)
  )

par(mfrow = c(1, 1))
plot(average_values$Avg_Ratio, 
     average_values$Avg_Greenability_Score,
     xlab="Average Ratio",
     ylab="Greenability Score"
     )
# straight line
abline(lm(Greenability.Score ~ Ratio, data = refactoring_data), col = "blue")

#curved line
poly_model <- lm(Avg_Greenability_Score ~ poly(Avg_Ratio, 2, raw = TRUE), data = average_values)
ratio_range <- seq(min(average_values$Avg_Ratio), max(average_values$Avg_Ratio), length.out = 100)
predicted_values <- predict(poly_model, newdata = data.frame(Avg_Ratio = ratio_range))
lines(ratio_range, predicted_values, col = "blue")

# correlation tests
cor_test <- cor.test(average_values$Avg_Ratio, 
                     average_values$Avg_Greenability_Score, 
                     method = "spearman")
cor_test
rho <- round(cor_test$estimate, 3)
p_value <- signif(cor_test$p.value, 3)
legend("topright", legend = paste("rho =", rho, "\np =", p_value), bty = "n")



#######################

# Trying something out: ratio with averaging per refactoring

#######################


merged_data <- churn_data %>%
  left_join(greenability_data, by = c("System" = "System.Name"))

merged_data <- merged_data %>%
  mutate(Ratio = average.totalNewVolumeInMonths / Volume..PM.)

merged_data <- data.frame(System = merged_data$System,
                          Refactoring = merged_data$Refactoring,
                          Greenability.Score = merged_data$Greenability.Score,
                          Ratio = merged_data$Ratio
)

refactoring_types <- unique(merged_data$Refactoring)
# Set up the plotting area as a 2x3 grid
par(mfrow = c(2, 3))

# Create and display a plot for each refactoring type
for(refactoring in refactoring_types) {
  refactoring_data <- filter(merged_data, Refactoring == refactoring)
  
  plot(refactoring_data$Ratio, refactoring_data$Greenability.Score,
       main = refactoring,
       xlab = "Ratio of New Volume to PM",
       ylab = "Greenability Score",
       col = "green",
       pch = 19)
  abline(lm(Greenability.Score ~ Ratio, data = refactoring_data), col = "blue")
  
  # Calculate Spearman's correlation
  cor_test <- cor.test(refactoring_data$Ratio, refactoring_data$Greenability.Score, method = "spearman")
  rho <- round(cor_test$estimate, 3)
  p_value <- signif(cor_test$p.value, 3)
  
  # Add text annotation for rho and p-value
  legend("topright", legend = paste("rho =", rho, "\np =", p_value), bty = "n")
}

# Reset plotting area to default
par(mfrow = c(1, 1))






#######################

# Trying something out: ratio without averaging 

#######################

total_churn_csv <- "~/Desktop/uploads/Sahin/correlation/total_churn.csv"
total_churn_data <- read.csv(total_churn_csv)
merged_data <- total_churn_data %>%
  left_join(greenability_data, by = c("System" = "System.Name"))
merged_data <- merged_data %>%
  mutate(Ratio = totalNewVolumeInMonths / Volume..PM.)
refactoring_types <- unique(merged_data$Refactoring)

# Set up the plotting area as a 2x3 grid
par(mfrow = c(2, 3))

# Create and display a plot for each refactoring type
for(refactoring in refactoring_types) {
  refactoring_data <- filter(merged_data, Refactoring == refactoring)
  
  plot(refactoring_data$Ratio, refactoring_data$Greenability.Score,
       main = paste("Greenability vs Ratio for", refactoring),
       xlab = "Ratio of New Volume to PM",
       ylab = "Greenability Score",
       col = "green",
       pch = 19)
  abline(lm(Greenability.Score ~ Ratio, data = refactoring_data), col = "blue")
  
  # Calculate Spearman's correlation
  cor_test <- cor.test(refactoring_data$Ratio, refactoring_data$Greenability.Score, method = "spearman")
  rho <- round(cor_test$estimate, 3)
  p_value <- signif(cor_test$p.value, 3)
  
  # Add text annotation for rho and p-value
  legend("topright", legend = paste("rho =", rho, "\np =", p_value), bty = "n")
}

# Reset plotting area to default
par(mfrow = c(1, 1))






#######################

# Trying something out: not averaging the methods 

#######################


total_churn_csv <- "~/Desktop/uploads/Sahin/correlation/total_churn.csv"
total_churn_data <- read.csv(total_churn_csv)

par(mfrow = c(2, 3))

merged_data <- total_churn_data %>%
  left_join(greenability_data, by = c("System" = "System.Name"))

write.csv(merged_data, "~/Desktop/merged_data.csv")

refactoring_types <- unique(merged_data$Refactoring)
merged_data$totalNewVolumeInMonths
par(mfrow = c(2, 3))

# Create and display a plot for each refactoring type
for(refactoring in refactoring_types) {
  refactoring_data <- filter(merged_data, Refactoring == refactoring)
  
  plot(refactoring_data$totalNewVolumeInMonths, refactoring_data$Greenability.Score,
       main = refactoring,
       xlab = "New Volume in PM",
       ylab = "Greenability Score",
       #col = "green",
       pch = 19)
  abline(lm(Greenability.Score ~ totalNewVolumeInMonths, data = refactoring_data), col = "red")
  # Calculate Spearman's correlation
  cor_test <- cor.test(refactoring_data$totalNewVolumeInMonths, refactoring_data$Greenability.Score, method = "spearman")
  rho <- round(cor_test$estimate, 3)
  p_value <- signif(cor_test$p.value, 3)
  
  # Add text annotation for rho and p-value
  legend("topright", legend = paste("rho =", rho, "\np =", p_value), bty = "n")
  
}

# Reset plotting area to default
par(mfrow = c(1, 1))

#######################

# Greenability correlation per refactoring LOC changed

#######################

loc_churn <- dcast(churn_data, 
                   System ~ Refactoring, 
                   value.var = "average.totalNewVolumeInLoc")
loc_churn <- as.data.frame(loc_churn)
loc_churn_greenability <- data.frame(System = loc_churn$System, 
                                averageLoc = rowMeans(loc_churn[, -1]),
                                GreenabilityScore = greenability_data$Greenability.Score
)
par(mfrow = c(2, 3))
for (i in 2:ncol(loc_churn)) {  # Start from the second column assuming the first column is labels
  # Create a scatter plot for each column against GreenabilityScore
  plot(loc_churn_greenability$GreenabilityScore,
       loc_churn[[i]],
       xlab = "Greenability Score",
       ylab = "Lines of Code Changed",  # Use column name as y-axis label
       main = paste("Plot of", colnames(loc_churn)[i])
  )
  
  # Optionally, add a linear regression line (line of best fit)
  fit <- lm(loc_churn[[i]] ~ loc_churn_greenability$GreenabilityScore)
  abline(fit, col = "red")
  
  # Calculate Spearman correlation and p-value
  cor_test <- cor.test(loc_churn_greenability$GreenabilityScore, loc_churn[[i]], method = "spearman")
  
  # Extract correlation coefficient and p-value
  rho <- cor_test$estimate
  p_value <- cor_test$p.value
  
  # Add correlation and p-value as text annotation
  text(x = max(loc_churn_greenability$GreenabilityScore) * 0.8, 
       y = max(loc_churn[[i]]) * 0.9, 
       labels = paste("Spearman's rho =", round(rho, 2), "\n", 
                      "p-value =", format.pval(p_value, digits = 2)),
       adj = c(0, 1), col = "blue")
}

# Reset the plot layout
par(mfrow = c(1, 1)) 


#######################

# Volume correlation per refactoring LOC changed

#######################

loc_churn <- dcast(churn_data, 
                   System ~ Refactoring, 
                   value.var = "average.totalNewVolumeInLoc")
loc_churn <- as.data.frame(loc_churn)
loc_churn_volume <- data.frame(System = loc_churn$System, 
                                averageLoc = rowMeans(loc_churn[, -1]),
                                VolumePM = greenability_data$Volume..PM.
)
par(mfrow = c(2, 3))
for (i in 2:ncol(loc_churn)) {  # Start from the second column assuming the first column is labels
  # Create a scatter plot for each column against GreenabilityScore
  plot(loc_churn_volume$VolumePM,
       loc_churn[[i]],
       xlab = "Volume in PM",
       ylab = "Lines of Code Changed",  # Use column name as y-axis label
       main = paste("Plot of", colnames(loc_churn)[i])
  )
  
  # Optionally, add a linear regression line (line of best fit)
  fit <- lm(loc_churn[[i]] ~ loc_churn_volume$VolumePM)
  abline(fit, col = "red")
  
  # Calculate Spearman correlation and p-value
  cor_test <- cor.test(loc_churn_volume$VolumePM, loc_churn[[i]], method = "spearman")
  
  # Extract correlation coefficient and p-value
  rho <- cor_test$estimate
  p_value <- cor_test$p.value
  
  # Add correlation and p-value as text annotation
  text(x = max(loc_churn_volume$VolumePM) * 0.6, 
       y = max(loc_churn[[i]]) * 0.9, 
       labels = paste("Spearman's rho =", round(rho, 2), "\n", 
                      "p-value =", format.pval(p_value, digits = 2)),
       adj = c(0, 1), col = "blue")
}

# Reset the plot layout
par(mfrow = c(1, 1)) 



#######################

# PM of system vs PM of refactoring

#######################

pm_churn <- dcast(churn_data, 
                  System ~ Refactoring, 
                  value.var = "average.totalNewVolumeInMonths")
pm_churn <- as.data.frame(pm_churn)
pm_churn_pm_system <- data.frame(System = pm_churn$System, 
                               averagePM = rowMeans(pm_churn[, -1]),
                               VolumePM = greenability_data$Volume..PM.
)

par(mfrow = c(2, 3))
for (i in 2:ncol(pm_churn)) {  # Start from the second column assuming the first column is labels
  # Create a scatter plot for each column against GreenabilityScore
  plot(pm_churn_pm_system$VolumePM,
       pm_churn[[i]],
       xlab = "System PM",
       ylab = "Refactoring PM",  # Use column name as y-axis label
       main = paste("Plot of", colnames(pm_churn)[i])
  )
  
  # Optionally, add a linear regression line (line of best fit)
  fit <- lm(pm_churn[[i]] ~ pm_churn_pm_system$VolumePM)
  abline(fit, col = "red")
  
  # Calculate Spearman correlation and p-value
  cor_test <- cor.test(pm_churn_pm_system$VolumePM, pm_churn[[i]], method = "spearman")
  
  # Extract correlation coefficient and p-value
  rho <- cor_test$estimate
  p_value <- cor_test$p.value
  
  # Add correlation and p-value as text annotation
  text(x = max(pm_churn_pm_system$VolumePM) * 0.6, 
       y = max(pm_churn[[i]]) * 0.9, 
       labels = paste("Spearman's rho =", round(rho, 2), "\n", 
                      "p-value =", format.pval(p_value, digits = 2)),
       adj = c(0, 1), col = "blue")
}

# Reset the plot layout
par(mfrow = c(1, 1)) 









###################################################################################################################



# Greenability vs average (LOC,PM,Files)



###################################################################################################################


# Define the variables for easier modification if needed
variables <- list(
  list(refactoring = "LOC", var = "average.totalNewVolumeInLoc", xlab = "Average Lines of Code Changed"),
  list(refactoring = "PM", var = "average.totalNewVolumeInMonths", xlab = "Average Person Months of Refactoring"),
  list(refactoring = "Files", var = "average.totalNewFiles", xlab = "Average No. of Files Changed")
)

# Set up the plotting grid
par(mfrow = c(1, 3))

# Loop through each test
for (test in variables) {
  # Cast the data
  churn_data_cast <- dcast(churn_data, System ~ Refactoring, value.var = test$var)
  churn_data_cast <- as.data.frame(churn_data_cast)
  
  # Calculate averages
  churn_data_average <- data.frame(
    System = churn_data_cast$System,
    averageValue = rowMeans(churn_data_cast[, -1]),
    GreenabilityScore = greenability_data$Greenability.Score
  )
  
  # Plot the data
  plot(churn_data_average$averageValue,
       churn_data_average$GreenabilityScore,
       xlab = test$xlab,
       ylab = "Greenability Score")
  
  # Fit the linear model
  fit <- lm(churn_data_average$GreenabilityScore ~ churn_data_average$averageValue)
  abline(fit, col = "red")
  
  # Perform Spearman correlation test
  cor_test <- cor.test(churn_data_average$averageValue,
                       churn_data_average$GreenabilityScore,
                       method = "spearman")
  rho <- cor_test$estimate
  p_value <- cor_test$p.value
  
  # Add correlation information to plot
  text(x = median(churn_data_average$averageValue, na.rm = TRUE),
       y = max(churn_data_average$GreenabilityScore, na.rm = TRUE),
       labels = paste("Spearman's rho =", round(rho, 2), "\n", 
                      "p-value =", round(p_value, 4)),
       adj = c(0, 1), col = "blue")
}

# Reset plotting parameters
par(mfrow = c(1, 1))









###################################################################################################################



# All Metrics (Green, Main, Measur, Volume, Rel, Freshness) vs Average (LOC,PM,Files)



###################################################################################################################





# Define the churn data variables and their corresponding labels
churn_variables <- list(
  list(var = "average.totalNewVolumeInLoc", xlab = "Average Lines of Code Changed"),
  list(var = "average.totalNewVolumeInMonths", xlab = "Average Person Months of Refactoring"),
  list(var = "average.totalNewFiles", xlab = "Average No. of Files Changed")
)

# Define the greenability data variables and their corresponding labels
greenability_variables <- c("Volume..PM." ,
                            "Maintainability.Score",
                            "Measurability.Score",
                            "Freshness.Score",
                            "Reliability.Score",
                            "Greenability.Score")

# Set up the plotting grid
#par(mfrow = c(length(greenability_variables), length(churn_variables)), mar = c(4, 4, 1, 1))
par(mfrow = c(3, 3))

# Loop through each greenability variable
for (green_var in greenability_variables) {
  # Extract the greenability score for the current variable
  greenability_scores <- greenability_data[[green_var]]
  greenability_scores
  
  # Loop through each churn data variable
  for (churn_var in churn_variables) {
    # Cast the churn data
    churn_data_cast <- dcast(churn_data, System ~ Refactoring, value.var = churn_var$var)
    churn_data_cast <- as.data.frame(churn_data_cast)
    
    # Calculate averages
    churn_data_average <- data.frame(
      System = churn_data_cast$System,
      averageValue = rowMeans(churn_data_cast[, -1]),
      GreenabilityScore = greenability_scores
    )
    
    # Plot the data
    plot(churn_data_average$averageValue,
         churn_data_average$GreenabilityScore,
         xlab = churn_var$xlab,
         ylab = green_var)
    
    # Fit the linear model
    fit <- lm(churn_data_average$GreenabilityScore ~ churn_data_average$averageValue)
    abline(fit, col = "red")
    
    # Perform Spearman correlation test
    cor_test <- cor.test(churn_data_average$averageValue,
                         churn_data_average$GreenabilityScore,
                         method = "spearman")
    rho <- cor_test$estimate
    p_value <- cor_test$p.value
    
    # Add correlation information to plot
    text(x = median(churn_data_average$averageValue, na.rm = TRUE),
         y = max(churn_data_average$GreenabilityScore, na.rm = TRUE),
         labels = paste("Spearman's rho =", round(rho, 2), "\n", 
                        "p-value =", round(p_value, 4)),
         adj = c(0, 1), col = "blue")
  }
}

# Reset plotting parameters
par(mfrow = c(1, 1))








