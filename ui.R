#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(knitr)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Lung Cancer Prediction"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel( 
            radioButtons("SMOKING", "1. Smoking", 
                        choices = list("Choice 1" = "Yes", "Choice 2" = "No",), selected = "Yes")),
            
            
            radioButtons("FATIGUE", "2. Fatigue", 
                        choices = list("Choice 1" = "Yes", "Choice 2" = "No",), selected = "Yes")),
            
            
            radioButtons("ALCOHOL_CONSUMING", "3. Alcohol Consuming", 
                        choices = list("Choice 1" = "Yes", "Choice 2" = "No",), selected = "Yes")),
           
            radioButtons("COUGHING", "4. Coughing", 
                        choices = list("Choice 1" = "Yes", "Choice 2" = "No",), selected = "Yes")),
           
            
            radioButtons("SWALLOWING_DIFFICULTY", "5. Swallowing Difficulty", 
                        choices = list("Choice 1" = "Yes", "Choice 2" = "No",), selected = "Yes")),
            
            helpText("Note: Choose Yes if you have these symptoms."),
            helpText("Note: Choose No if you don't have these symptoms."),
            
            submitButton("Submit"),
            
            p("Submit your choices and see your result!")
        ),

        mainPanel(
           tabsetPanel(type = "tabs",
                       
        tabPanel('Documentation',
                                h3('Introduction'),
                                'Welcome to Lung Cancer Risk Self-Assessment applications developed by Chiew Kian Khoon, Ooi Xie Gee, Low Jin Seng and Chong Jia Ying. 
        In our application, we developed a simple interface for users to navigate easily.',
                                h3('User Input'),
                                "In our application, we used a switch widgets for the users to input their value either YES or NO for each question. 

        The questions are  based on the features we have selected using Boruta package (for more details, please view Feature Selection tabset). There is a submit button widget below the questions for users to submit their inputs.
        Please click the submit button in order to see your risk of getting lung cancer. 
        We also included tabsetPanel widget to display our findings and results for our project.",
                                h3('Result and Findings'),
                                'To see your probability of getting lung cancer, please click the Prediction Model tabPanel.
        If you wish to see the summary, structure, exploratory data analysis and feature selection of our dataset, please click the tabpanel accordingly.',
                                h3('Summary & Structure'),
                                'The "Summary of Lung Cancer Survey dataset" provides the Mininum, 1st Quartile, Median, Mean, 3rd Quartile and the Maximum values for each attribute.',
                                'The "Structure of Lung Cancer Dataset" provides the number of observations, number of variables(attributes) and data type for each attribute.',
                                h3('Exploratory Data Analysis'),
                                'In this tabset, you will be able to view a few visualization plots. ', 
                                '
        The 1st plot is a Heat Map of all our attributes in our dataset.',
                                '
        The 2nd plot is a Bar Chart that shows the number of people getting lung cancer and not getting it in our dataset.',
                                'The 3rd plot is a Scatter Plot which shows attribute means for the people getting lung cancer against who does not.',
                                'The 4th plot is a Scatter Plot which shows the difference in attribute means for the people getting lung cancer against who does not.',
                                h3('Feature Selection'),
                                'In this tabset, you will be able to view the Initial & Finalized Feature Selection.
        We have selected the top 5 most significant factors affecting lung cancer 
                                rate based on the box plot for each attribute in our dataset.',
                                h5('Question 1 corresponds to attribute Smoking).'),
                                h5('Question 2 corresponds to attribute Fatigue.'),
                                h5('Question 3 corresponds to attribute Alcohol Consuming.'),
                                h5('Question 4 corresponds to attribute Coughing.'),
                                h5('Question 5 corresponds to attribute Swallowing Difficulty.'),
                                'To prove how well-separated the data are, we have plotted each attribute vs. the distribution of the classes they belong to.',
                                
                                h3('Prediction Model'),
                                h5('The 1st part is Prediction.'),
                                h5('	You can answer the questions asked accordingly, submit them and view your rate of getting lung cancer.'),
                                h5('The 2nd part is Confusion Matrix. '),
                                h5('	The accuracy of our logistic regression model is represented in the form of confusion matrix.'),
                                h5('The 3rd & 4th part are the Sensitivity Rate and Specificity Rate respectively. '),
                                h5('The 5th part is Total Misclassification Error Rate.'),
                                h5('The 6th part is Receiver Operating Characteristic(ROC) curve.')
                                ),
                        
                        tabPanel("Summary & Structure",
                                h3("Summary of Lung Cancer Survey Dataset"),
                                verbatimTextOutput("summary"),
                                h3("Structure of Lung Cancer Survey Dataset"),
                                verbatimTextOutput("structure")
                                ),

                         tabPanel("Exploratory Data Analysis",
                                
                                h3('Bar chart'),
                                plotOutput("bar"),
                                
                                h3("Heat Map"),
                                plotOutput('heatmap'),
                                
                                h3("Mean of lung cancer positive"),
                                plotOutput("lungCancerMean"),
                                
                                h3("Difference in Mean for each attribute"),
                                plotOutput("mymean"),
                                ),

                       tabPanel("Feature Selection",
                                h3('Initial Feature Selection', align='center'),
                                plotOutput('initialFeatureSelection'),

                                h3('Finalized Feature Selection', align='center'),
                                plotOutput('finalizedFeatureSelection'),

                                h3('Attribute value vs Class', align='center'),
                                h4('Smoking' , align='center'), plotOutput('SMOKING'),
                                h4('Fatigue', align='center'), plotOutput('FATIGUE'),
                                h4('Alcohol Consuming', align='center'), plotOutput('ALCOHOL_CONSUMING'),
                                h4('Coughing', align='center'), plotOutput('COUGHING'),
                                h4('Swalloing Difficulty', align='center'), plotOutput('SWALLOWING_DIFFICULTY')
                                ),

                       tabPanel("Prediction Model",
                                h3('Prediction'),
                                h4("Your lung cancer positive rate is: "),
                                verbatimTextOutput("probability"),
                                verbatimTextOutput("result"),
                                h3("Model Accuracy"),


                                h3("Confusion Matrix"), verbatimTextOutput("confusionmatrix"),
                                h3("The sensitivity rate of our model (true positive rate)"), verbatimTextOutput("sensitivity"),
                                h3("The specificity rate of our model (true negative rate)"), verbatimTextOutput("specificity"),
                                h3("Total misclassification error rate"), verbatimTextOutput("mer"),
                                h3("The ROC curve"), plotOutput("roc"),
                                h3("The Confusion Matrix plot"), plotOutput("cmplot")
                                )
                       )
        )
    )
))

