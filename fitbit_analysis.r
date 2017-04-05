# Project author: Steve Delor
# Date: November 27th, 2016
# Multivariate Analysis - Team Project Fitbit 
# Analysis with R

#########################################################################################

# EXPLORATION OF THE DATSET
#
# Saturday December 3rd
# We have our Fitbit dataset on 60 users
# each row of the data set represents the activity of one specific user for one day
# We have 2 months worth of data per user
# PROBLEM !!!! => some days the user did not wear his fitbit. We know this because the value
# of steps  equal 0 (we assume that a user doesnot spend a whole day in his bed)
# so we want to get rid of these few innacurate rows i
#
# resources: 
#     - http://www.sthda.com/french/wiki/matrice-de-correlation-guide-simple-pour-analyser-formater-et-visualiser#cest-quoi-une-matrice-de-correlation
#
#########################################################################################
library(lattice)
dataset <- read.csv("/Users/dessty/Stevens/Multivariate\ Analysis/fitbit/datasets/fitbit_pca.csv", header= TRUE)

fitbit <- data.frame(
  calories = dataset["Activity.Calories"],
  distance = dataset["Distance"],
  steps = dataset["Steps"],
  caloriesBurned = dataset["Calories.Burned"],
  minutesSedentary = dataset["Minutes.Sedentary"],
  dayOfWeek = dataset["Day.of.Week"],
  weekday = dataset["Weekday"]
)

# import the csv into a dataframe
fitbit = read.csv("/Users/dessty/Stevens/Multivariate\ Analysis/fitbit/datasets/FITBIT_december03.csv", header = TRUE )
transform(fitbit, Minutes.Sedentary = as.numeric(Minutes.Sedentary))

summary(fitbit)

# let's explore the data to get a visual impression of whether there is a 
# corroleation between distance travelled and the calories
#-----------------------------------------------------------------
xyplot(Activity.Calories ~ Distance, fitbit,
       xlab = "Distance (miles)",ylab = "Activity Calories (cal)",main = "Correlation Model")
model.activityCaloriesByDistance <- lm(Activity.Calories ~ Distance, data = fitbit)
summary(model.activityCaloriesByDistance)
#-----------------------------------------------------------------
xyplot(Activity.Calories ~ Steps, fitbit,
       xlab = "Steps",ylab = "Activity Calories (cal)",main = "Correlation Model")
model.activityCaloriesBySteps <- lm(Activity.Calories ~ Steps, data = fitbit)
summary(model.activityCaloriesBySteps)
#-----------------------------------------------------------------
xyplot(Activity.Calories ~ Day.Of.Week, fitbit,
       xlab = "Day of the Week (Sunday=1)",ylab = "Activity Calories (cal)",main = "Correlation Model")
model.activityCaloriesByDayOfWeek <- lm(Activity.Calories ~ Day.Of.Week, data = fitbit)
summary(model.activityCaloriesByDayOfWeek)
#-----------------------------------------------------------------
xyplot(Activity.Calories ~ Weekday, fitbit,
       xlab = "Day of the Week (Weekend=0)",ylab = "Activity Calories (cal)",main = "Correlation Model")
model.activityCaloriesByWeekday <- lm(Activity.Calories ~ Weekday, data = fitbit)
summary(model.activityCaloriesByWeekday)
#-----------------------------------------------------------------
xyplot(Activity.Calories ~ Calories.Burned, fitbit,
       xlab = "Total Calories burned (cal)",ylab = "Activity Calories (cal)",main = "Correlation Model")
model.activityCaloriesByCaloriesBurned <- lm(Activity.Calories ~ Calories.Burned, data = fitbit)
summary(model.activityCaloriesByCaloriesBurned)
#-----------------------------------------------------------------
xyplot(Activity.Calories ~ Minutes.Sedentary, fitbit,
       xlab = "Minutes Sedentary",ylab = "Activity Calories (cal)",main = "Correlation Model")
model.activityCaloriesByMinutesSedentary <- lm(Activity.Calories ~ Minutes.Sedentary, data = fitbit)
summary(model.activityCaloriesByMinutesSedentary)
#-----------------------------------------------------------------
xyplot(Distance ~ Steps, fitbit,
       xlab = "Steps took",ylab = "Distance traveled (miles)",main = "Correlation Model")
model.distanceBySteps <- lm(Distance ~ Steps, data = fitbit)
summary(model.distanceBySteps)
#-----------------------------------------------------------------
xyplot(Distance ~ Minutes.Sedentary, fitbit,
       xlab = "Minutes Sedentary",ylab = "Distance traveled (miles)",main = "Correlation Model")
model.DistanceByMinutesSedentary <- lm(Distance ~ Minutes.Sedentary, data = fitbit)
summary(model.DistanceByMinutesSedentary)
#-----------------------------------------------------------------
xyplot(Distance ~ Calories.Burned, fitbit,
       xlab = "Total Calories Burned (cal)",ylab = "Distance traveled (miles)",main = "Correlation Model")
model.DistanceByCaloriesBurned <- lm(Distance ~ Calories.Burned, data = fitbit)
summary(model.DistanceByCaloriesBurned)
#-----------------------------------------------------------------
xyplot(Distance ~ Day.of.Week, fitbit,
       xlab = "Day of the Week (Sunday=1)",ylab = "Distance traveled (miles)",main = "Correlation Model")
model.DistanceByDayofWeek <- lm(Activity.Calories ~ Day.of.Week, data = fitbit)
summary(model.DistanceByDayofWeek)
#-----------------------------------------------------------------
xyplot(Distance ~ Weekday, fitbit,
       xlab = "Weeday",ylab = "Distance traveled (miles)",main = "Correlation Model")
model.DistanceByMinutesWeekday <- lm(Activity.Calories ~ Weekday, data = fitbit)
summary(model.DistanceByMinutesWeekday)
#-----------------------------------------------------------------


#
# simple linear regression model and save the fitted model to an object for further analysis
#
model.stepsByDistance <- lm(Steps ~ Distance, data = fitbit)
summary(model.stepsByDistance)

model.caloriesByDistance <- lm(Activity.Calories ~ Distance, data = fitbit)
summary(model.caloriesByDistance)

#
# determine whether there are any systematic patterns, such as over estimation for most of 
# the large values or increasing spread as the model fitted values increase.
#
xyplot(resid(model.stepsByDistance) ~ fitted(model.stepsByDistance),
       xlab = "Fitted Values",
       ylab = "Residuals",
       main = "Residual Diagnostic Plot",
       panel= function(x, y, ...)
          {
            panel.grid(h = -1, v = -1)
            panel.abline(h = 0)
            panel.xyplot(x, y, ...)
          }
       )
#
# The function resid extracts the model residuals from the fitted model object
# We would hope that this plot showed something approaching a straight line to 
# support the model assumption about the distribution of the residuals
#
qqmath( ~ resid(model.caloriesByDistance),
        xlab = "Theoretical Quantiles",
        ylab = "Residuals"
)

qqmath( ~ resid(model.stepsByDistance),
        xlab = "Theoretical Quantiles",
        ylab = "Residuals"
)

#########################################################################################
# CORRELATION MATRIX 
#########################################################################################
install.packages("PerformanceAnalytics")
library(PerformanceAnalytics)

setwd("/Users/dessty/Stevens/R_HOME_DIR")
fitbit <- read.csv("fitbit_pca_weekday_weekend.csv") # let's load the new data set
# let's clean the data, by getting rid of row with na values and rows with some 0 values when 
# we know a different value should have been present
fitbit <- fitbit[complete.cases(fitbit),]  #na
fitbit <- fitbit[apply(fitbit, 1, function(row) all(row!=0)),] #0s

summary(fitbit)
# we take label and weekday/weekend column
chart.Correlation(fitbit[3:15], histogram=TRUE, pch=19)



#########################################################################################
#
# SATURDAY DECEMBER 10th
# using FactomineR module to calculate PCA and maybe factor analysis :) if time to get it
# Alright, this is the second part you want to present 
# Using FactominR
#
#########################################################################################
source("http://factominer.free.fr/install-facto.r")
install.packages("FactoMineR")
library(FactoMineR)
# ==========================================================================================
# PART 1
# ==========================================================================================
res.pca = PCA(fitbit[,c(3:15)], 
              scale.unit=TRUE,
              ncp=5, 
              quanti.sup = c(4,6,7,8,10,11,12),
              graph=TRUE)
# it looks like we need 3 components to explain 95% of the variation
summary(res.pca)
res.pca
components <- as.data.frame(res.pca$eig)
plot(res.pca$eig$`percentage of variance`, type = 'o', xlab = "Dimensions", ylab = "Variance")
barplot(res.pca$eig$eigenvalue)
biplot(res.pcax)
# ==========================================================================================
# PART 2
# ==========================================================================================
# Quality of representation 

# cosinus au carreé de l'angle entre une variable et projeteé sur le plan
# seuls les elements bien projete sont interpretable. Le reste, tu ne peux rien en deduire!!!
quality_of_projection <- round(res.pca$var$cos2, 2)
factor <- dimdesc(res.pca)
factor.1 <- factor$Dim.1$quanti
factor.2 <- factor$Dim.2$quanti
factor.3 <- factor$Dim.3$quanti




#########################################################################################
# KMEANS: if you have time, run a quick kmeans to see if there is anything interesting
#########################################################################################
# a quick K-Means Cluster Analysis just for curiosity
fitbit_ <- scale(fitbit) # let's standarize the variables
fit <- kmeans(fitbit_, 3) # 3 cluster solution
# get cluster means 
aggregate(fitbit_,by=list(fit$cluster),FUN=mean)
# append cluster assignment
fitbit_ <- data.frame(fitbit_, fit$cluster)
#visualize the clustering results
layout(1)
library(cluster) 
clusplot(fitbit_, fit$cluster, color=TRUE, shade=TRUE, labels=2, lines=0)



# code from Harshita, cleaning the dataset. 
# TODO : :: need to change the url and check the code. But it simply does:
# - extract row with steps = 0
# - split dataset in 2 sub datasets "weekend" and "weekday"

rm(list=ls())
fitbit<-read.csv("fitbit.csv")

install.packages("dplyr")
library(dplyr)

head(fitbit)
summary(fitbit)

dim(fitbit)

fitbit <- fitbit %>% filter(!Steps==0)

fitbit2<- tbl_df(fitbit)
fitbit <- subset( fitbit, select = -c(Date,Day.of.Week) )


fitbit_day = split(fitbit,fitbit$Weekday)[['1']]
fitbit_end = split(fitbit,fitbit$Weekday!='1')[['TRUE']]


install.packages("plyr")
library(plyr)
impute.mean <- function(x) replace(x, is.na(x), mean(x, na.rm = TRUE))
fitbit_day <- ddply(fitbit_day, ~ Name, transform, Calories.Burned = impute(Calories.Burned,mean()))

      