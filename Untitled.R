library(Boruta)

lungCancerDataSet <- read.csv("survey_lung_cancer.csv", header = TRUE, sep=',')
boruta <- Boruta(LUNG_CANCER ~ ., data = lungCancerDataSet, doTrace = 2, maxRuns = 100)
final.boruta <- TentativeRoughFix(boruta)
# print(final.boruta)

#Plot the finalized feature selection result
# plot(final.boruta, las = 2, cex.axis = 0.5)

#Extract the selected features
selectedFeatures <- getSelectedAttributes(final.boruta)
selectedFeatures <- as.vector(selectedFeatures)
print(selectedFeatures)
