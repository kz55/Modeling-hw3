# lasso.R

#########################################################

# Getting the data in the right format

'''
This section will create a matrix of bigrams with 0s and 1s for the presence of ngrams in each row of speaking text (each floor speech):

For instance:

ideology	speech						bi1	bi2	bi3 
.5			climat chang tea parti		0	1	0
-.8			tax increas al qaeda 		0	0	1
.3			comprehens immigr food 		1	1	0
'''

#########################################################

library(plyr)
# Note: had some errors that required downgrading to plyr 1.7

# Loading the merged data from earlier with the ideology score and speaking text of each floor speech
merged_data <- read.csv("mergedwords.csv", head=TRUE, stringsAsFactors=FALSE)
merged_data <- subset(merged_data,select=c(first_d,speaking), stringsAsFactors=FALSE)
colnames(merged_data) <- c("ideology","speaking")

top_bi <- read.csv("top_bi.csv", head=TRUE)
top_bi <- subset(top_bi,select=x)
top_tri <- read.csv("top_tri.csv", head=TRUE)
top_tri <- subset(top_tri,select=x)

ideology <- merged_data$ideology
speaking <- merged_data$speaking
bi_data <- cbind(ideology,speaking)

# Creating a new bi_data frame, with columns for each top bigram dummy variable
empty <- matrix(0,nrow=nrow(bi_data),ncol=500)
bi_data <- cbind(bi_data,empty)
top_bigram <- t(matrix(top_bi[,1]))

bi_data <- na.omit(bi_data)
top_bigram <- na.omit(top_bigram)

# Start with 500 observations to test

for (i in 1:500) {
  if (i==1) { names <- c(toString(top_bigram[i])) }
  else { names <- c(names,toString(top_bigram[i])) }
}
colnames(bi_data) <- c("ideology","speaking",names)

# Populating the bigram dummy variable columns (=1 if the bigram is present in the "speaking" column, aka was said in that floor speech)
# NOTE: remember to change 1:100 to however many rows you have above

for (i in sample(1:nrow(bi_data), 200, replace=FALSE)){
  for (j in 1:400) { 
    if (grepl(names[j],toString(speaking[i]), ignore.case = TRUE, perl = FALSE, fixed = FALSE, useBytes = FALSE) == TRUE)
    { bi_data[i,j] <- 1}
    else 
    { bi_data[i,j] <- 0 }
  }
}

write.csv(bi_data,"bi_data_m.csv")

## Same for trigrams

library(plyr)
# Note: had some errors that required downgrading to plyr 1.7

# Loading the merged data from earlier with the ideology score and speaking text of each floor speech
merged_data <- read.csv("mergedwords.csv", head=TRUE, stringsAsFactors=FALSE)
merged_data <- subset(merged_data,select=c(first_d,speaking), stringsAsFactors=FALSE)
colnames(merged_data) <- c("ideology","speaking")

top_tri <- read.csv("top_tri.csv", head=TRUE)
top_tri <- subset(top_tri,select=x)
top_tri <- read.csv("top_tri.csv", head=TRUE)
top_tri <- subset(top_tri,select=x)

ideology <- merged_data$ideology
speaking <- merged_data$speaking
tri_data <- cbind(ideology,speaking)

# Creating a new tri_data frame, with columns for each top trigram dummy variable
empty <- matrix(0,nrow=nrow(tri_data),ncol=500)
tri_data <- cbind(tri_data,empty)
top_trigram <- t(matrix(top_tri[,1]))

tri_data <- na.omit(tri_data)
top_trigram <- na.omit(top_trigram)

# Start with 500 observations to test

for (i in 1:500) {
  if (i==1) { names <- c(toString(top_trigram[i])) }
  else { names <- c(names,toString(top_trigram[i])) }
}
colnames(tri_data) <- c("ideology","speaking",names)

# Populating the trigram dummy variable columns (=1 if the trigram is present in the "speaking" column, aka was said in that floor speech)
# NOTE: remember to change 1:100 to however many rows you have above

for (i in sample(1:nrow(tri_data), 200, replace=FALSE)){
  for (j in 1:400) { 
    if (grepl(names[j],toString(speaking[i]), ignore.case = TRUE, perl = FALSE, fixed = FALSE, useBytes = FALSE) == TRUE)
    { tri_data[i,j] <- 1}
    else 
    { tri_data[i,j] <- 0 }
  }
}

write.csv(tri_data,"tri_data_m.csv")

#########################################################

## Modeling

library(leaps)
library(glmnet)

bi_data_m <- read.csv("bi_data_m.csv")
bi_data_m <- subset(bi_data_m,select=-c(X))

ideology <- bi_data_m[,"ideology"]

x=model.matrix(ideology~.,data=bi_data_m)
y=ideology

as.vector(x, mode = "any")

set.seed(1)
train=sample(c(TRUE,FALSE), nrow(bi_data_m),rep=TRUE)
test=(!train)
regfit.best=regsubsets(ideology~.,data=bi_data_m[train,],nvmax=8,really.big=T)

# [best subset selection]

# Lasso model

lasso.mod=glmnet(x[train,],y[train],alpha=1,lambda=grid)
plot(lasso.mod)
set.seed(1)
cv.out=cv.glmnet(x[train,],y[train],alpha=1)
plot(cv.out)
bestlam=cv.out$lambda.min
lasso.pred=predict(lasso.mod,s=bestlam,newx=x[test,])
mean((lasso.pred-y.test)^2)
out=glmnet(x,y,alpha=1,lambda=grid)
lasso.coef=predict(out,type="coefficients",s=bestlam)[1:20,]
lasso.coef
lasso.coef[lasso.coef!=0]
