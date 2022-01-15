
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(corrplot)
library(heatmaply)
library(corrgram)
library(caret)
library(Boruta)
library(InformationValue)
library(ggplot2)
library(plot.matrix)
library(brglm)
library(pheatmap)
library(plotly)  
library(knitr)

#Read the survey_lung_cancer.csv file to be examined
lungCancerDataSet <- read.csv("survey_lung_cancer.csv", header = TRUE, sep',')


#separate into positive and negative class, the lung_cancer_positive &
#lung_cancer_negative are used for data analysis
lung_cancer_positive = lungCancerDataSet[lungCancerDataSet$LUNG_CANCER==1]
lung_cancer_negative = lungCancerDataSet[lungCancerDataSet$LUNG_CANCER==0]
nrow(lung_cancer_positive)
nrow(lung_cancer_negative)
# View(lung_cancer_negative)


#Examination of the  data
lungCancerNum <- length(lung_cancer_positive$Class)
notLungCancerNum <- length(lung_cancer_negative$Class)
# print(list(lungCancerNum, notLungCancerNum))



plotdata <- data.frame(
    Count <- c(lungCancerNum, notLungCancerNum),
    Group <- c("Lung Cancer", "Not Lung Cancer")
)


par(mfrow = c(1, 1))
means <- matrix(0, nrow = ncol(lungCancerDataSet) - 1, ncol = 2)
colnames(means) = c("positive", "negative")

for(i in 1:(ncol(lungCancerDataSet) - 1)){
    means[i, 1] = mean(lung_cancer_positive[[i]])
    means[i, 2] = mean(lung_cancer_negative[[i]])
}

meanDifference <- means[, 1] -  means[, 2]


bigDifference <- which(meanDifference > 3)
# bigDifference
smallDifference <- which(meanDifference < 2)
# smallDifference

#Feature selection part
boruta <- Boruta(Class ~ ., data = lungCancerDataSet, doTrace = 2, maxRuns = 100)
# print(boruta)

#Plot the initial result of feature selection
# plot(boruta, las = 2, cex.axis = 0.5)

#Finalize the feature selection
final.boruta <- TentativeRoughFix(boruta)
# print(final.boruta)

#Plot the finalized feature selection result
# plot(final.boruta, las = 2, cex.axis = 0.5)

#Extract the selected features
selectedFeatures <- getSelectedAttributes(final.boruta)
selectedFeatures <- as.vector(selectedFeatures)

#Select the top 5 most significant features

#################################################################################################################
#################################################################################################################
selectedFeatures <- selectedFeatures[selectedFeatures %in% c("SMOKING", "FATIGUE", "ALCOHOL_CONSUMING", "COUGHING", "SWALLOWING_DIFFICULTY")]
#################################################################################################################
#################################################################################################################


#Creating the traning and testing set
sample <- sample(c(TRUE, FALSE),nrow(lungCancerDataSet), replace = TRUE, prob = c(0.7, 0.3))
train <- lungCancerDataSet[sample, ]
test <- lungCancerDataSet[!sample, ]

#Train the logistic regression model
model <- brglm(LUNG_CANCER~SMOKING + FATIGUE  + ALCOHOL_CONSUMING + COUGHING + SWALLOWING_DIFFICULTY , family = binomial, data = train)

# summary(model)

#Accesing model fit using McFadden's R Square metric, value is between 0 and 1, the higher the value better
pscl::pR2(model)["McFadden"]

#Test the model using one testing set below
couple <- data.frame(SMOKING = 4, FATIGUE = 4, ALCOHOL_CONSUMING = 1, COUGHING = 3, SWALLOWING_DIFFICULTY = 2)
predict(model, couple, type = "response")

#Test the model using whole testing set
predicted <- predict(model, test, type = "response")
predicted

#Find the optimal probability to use to maximize the accuracy of our model
#Any probability higher than optimal cut off will be predicted to divorced,
#lower will be predicted to marriage
optimal <- optimalCutoff(test$LUNG_CANCER, predicted)[1]
optimal

#Confusion Matrix to visualize the accuracy of our model
confusionMatrix(test$LUNG_CANCER, predicted)
# View(confusionMatrix(test$Class, predicted))

#get the sensitivity rate of our model (true positive rate)
sensitivity(test$LUNG_CANCER, predicted)

#get the specificity rate of our model (true negative rate)
specificity(test$LUNG_CANCER, predicted)

#calculate total misclassification error rate
misClassError(test$LUNG_CANCER, predicted, threshold = optimal)


#Add row number as a column
lungcancer1 = lungCancerDataSet
rows <- sample(nrow(lungcancer1))
lungcancer1.1 <- lungcancer1[rows, ]
lungcancer1.1$Index = as.numeric(row.names(lungcancer1))


lungCancerNum <- sum(lungCancerDataSet$Class == 1)
nonLungCancerNum <- sum(lungCancerDataSet$Class == 0)

plotdata <- data.frame(
    Count <- c(lungCancerNum, nonLungCancerNum),
    Group <- c("Lung Cancer", "Not Lung Cancer")
)



col1 <- confusionMatrix(test$LUNG_CANCER, predicted)[, 1]
col2 <- confusionMatrix(test$LUNG_CANCER, predicted)[, 2]
par(mar=c(5.1, 5.1, 5.1, 5.1))













shinyServer(function(input, output) {
    lungCancerRate <- reactive({
        couple <- data.frame(SMOKING = input$SMOKING, FATIGUE = input$FATIGUE, ALCOHOL_CONSUMING =
                                 input$ALCOHOL_CONSUMING, COUGHING = input$COUGHING, SWALLOWING_DIFFICULTY = input$SWALLOWING_DIFFICULTY)

        lungCancerRate <- predict(model, couple, type = "response")
        lungCancerRate <- 1 - lungCancerRate
        names(lungCancerRate) <- NULL
        lungCancerRate
    })

    output$probability <- renderPrint({
        lungCancerRate()
    })

    output$result <- renderText({
        if(lungCancerRate() < 0.5){
            "You will keep healthy and away from the lung cancer"
        }
        else{
            "You probably will suffer from lung cancer"
        }
    })


    output$structure <- renderPrint({
        str(lungCancerDataSet)
    })

    output$summary <- renderPrint({
        summary(lungCancerDataSet)
    })

    output$bar <- renderPlot({
        divorceesNum   <- sum(divorceDataSet$Class == 1)
        nondivorceesNum <- sum(divorceDataSet$Class == 0)

        plotdata <- data.frame(
            Count <- c(divorceesNum, nondivorceesNum),
            Group <- c("Divorcees", "Non-Divorcees")
        )

        ggplot(plotdata, aes(x = Group, y = Count)) + geom_col(fill = c(" blue", "yellow"), color = "black", width = 0.5)+
            labs(title = "Number of Divorcees and Non-Divorcees") + theme(plot.title = element_text(hjust = 0.5)) +
            geom_text(aes(label = Count), vjust = -0.5, size = 5)
    })


    # KK
    output$divorcemean <- renderPlot({
        plot(x = means[, 1], y = means[, 2],ylim = c(0,4), xlim = c(0,4),
        xlab = 'Mean for Non-Divorcees',
        ylab = 'Mean for Divorcees',
             main = 'Attribute Means for Divorcees vs. Non-Divorcees')
        abline(a=0, b=1)
    })

    output$mymean <- renderPlot({
        plot(meanDifference, main = "Difference in Attribute Means for Divorcees vs
    Non-Divorcees", ylab = "Difference", xlab = "Attribute Number")
    })

    output$heatmap <- renderPlot({
        ggheatmap(divorceDataSet)
    })

    # SW
    output$initialFeatureSelection <- renderPlot({
        plot(boruta, las = 2, cex.axis = 0.5)
    })

    output$finalizedFeatureSelection <- renderPlot({
        plot(final.boruta, las = 2, cex.axis = 0.5)
    })

    output$Atr9 <- renderPlot({
        ggplot(divorce1.1, aes(x=Index, y=Atr9, col = Class))+geom_point()
    })

    output$Atr11 <- renderPlot({
        ggplot(divorce1.1, aes(x=Index, y=Atr11, col = Class))+geom_point()
    })

    output$Atr26 <- renderPlot({
        ggplot(divorce1.1, aes(x=Index, y=Atr26, col = Class))+geom_point()
    })

    output$Atr18 <- renderPlot({
        ggplot(divorce1.1, aes(x=Index, y=Atr18, col = Class))+geom_point()
    })

    output$Atr40 <- renderPlot({
        ggplot(divorce1.1, aes(x=Index, y=Atr40, col = Class))+geom_point()
    })


    # HJ
    output$confusionmatrix <- renderPrint({
        confusionMatrix(test$LUNG_CANCER, predicted)
    })

    output$sensitivity <- renderPrint({
        sensitivity(test$LUNG_CANCER, predicted)
    })

    output$specificity <- renderPrint({
        specificity(test$LUNG_CANCER, predicted)
    })

    output$mer <- renderPrint({
        misClassError(test$LUNG_CANCER, predicted, threshold = optimal)
    })

    output$roc <- renderPlot({
        plotROC(test$LUNG_CANCER, predicted)
    })

    output$cmplot <- renderPlot({
        col1 <- confusionMatrix(test$LUNG_CANCER, predicted)[, 1]
        col2 <- confusionMatrix(test$LUNG_CANCER, predicted)[, 2]
        par(mar=c(5.1, 5.1, 5.1, 5.1))
        plot(as.matrix(confusionMatrix(test$LUNG_CANCER, predicted)), main =
                 "Confusion Matrix", xlab = "Actual", ylab = "Predicted",
             cex.lab = 2, col = heat.colors, key = NULL, cex.main = 2.5, digit = 0,  text.cell = list(cex = 2), fmt.cell = "%s", breaks = 2)
    })

    output$markdown <- renderUI({
        HTML(markdown::markdownToHTML(knit('a.Rmd', quiet = TRUE)))
    })
})
