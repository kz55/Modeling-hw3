# Modeling: Ridge regression and Lasso model

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

## Ridge Regression

library(glmnet)

bi_data_m <- read.csv("bi_data_m.csv")
bi_data_m <- subset(bi_data_m,select=-c(X,speaking))

ideology <- bi_data_m[,"ideology"]

x=model.matrix(ideology~.,data=bi_data_m)
y=ideology

# Based on ISLR 6.6.1: Ridge Regression

grid=10^seq(10,-2,length=100)
ridge.mod=glmnet(x,y,alpha=0,lambda=grid)

bi_data_m<-data.frame(bi_data_m)
ridge.mod=glmnet(x,y,alpha=0,lambda=grid)

# Divide the data into test and training sets:
set.seed(1)
train=sample(1:nrow(x), nrow(x)/2)
test=(-train)
y.test=y[test]

# Use cross-validation to choose the tuning parameter lambda (λ)
set.seed(1)
cv.out=cv.glmnet(x[train ,],y[train],alpha =0)
bestlam=cv.out$lambda.min
bestlam
# The value of λ that results in the smallest cross-validation error is 0.431656

# Finding the test marginal standard error (MSE) associated with this value of λ (0.431656):
ridge.pred=predict(ridge.mod,s=bestlam,newx=x[test ,])
mean((ridge.pred-y.test)^2)
# Test MSE=0.1414037

# Finally, we refit our ridge regression model on the full data set, using the value of λ chosen by cross-validation, and examine the coefficient estimates.:
out=glmnet(x,y,alpha=0)
predict(out,type="coefficients",s=bestlam )[1:200 ,]

# However, it is hard to see best variables, because Ridge doesn't zero out any of the coefficients.

###

# Trying now with the lasso model

grid=10^seq(10,-2,length=1000)
ridge.mod=glmnet(x,y,alpha=0,lambda=grid)

bi_data_m<-data.frame(bi_data_m)
ridge.mod=glmnet(x,y,alpha=0,lambda=grid)

lasso.mod=glmnet(x[train ,],y[train],alpha=1,lambda=grid)
plot(lasso.mod)

set.seed (1)
cv.out=cv.glmnet(x[train ,],y[train],alpha=1)
plot(cv.out)
bestlam=cv.out$lambda.min
lasso.pred=predict(lasso.mod,s=bestlam ,newx=x[test,])
mean((lasso.pred-y.test)^2)
# Result: 0.1455826

out=glmnet(x,y,alpha=1,lambda=grid)
lasso.coef=predict(out,type="coefficients",s=bestlam)[1:500,]
lasso.coef

# Unlike the Ridge Regression, the Lasso model will return coefficients of 0, so we select all the non-zero coefficients:
lasso.coef[lasso.coef!=0]
'''
 (Intercept)    base.upon   claim.time  cut.medicar  energi.cost 
 0.051055727  0.479958431 -0.315666015 -0.020005518 -0.001177747 
'''

###

## Ridge Regression - for trigrams

library(glmnet)

tri_data_m <- read.csv("tri_data_m.csv")
tri_data_m <- subset(tri_data_m,select=-c(X,speaking))

ideology <- tri_data_m[,"ideology"]

x=model.matrix(ideology~.,data=tri_data_m)
y=ideology

# Based on ISLR 6.6.1: Ridge Regression

grid=10^seq(10,-2,length=100)
ridge.mod=glmnet(x,y,alpha=0,lambda=grid)

tri_data_m<-data.frame(tri_data_m)
ridge.mod=glmnet(x,y,alpha=0,lambda=grid)

# Divide the data into test and training sets:
set.seed(1)
train=sample(1:nrow(x), nrow(x)/2)
test=(-train)
y.test=y[test]

# Use cross-validation to choose the tuning parameter lambda (λ)
set.seed(1)
cv.out=cv.glmnet(x[train ,],y[train],alpha =0)
bestlam=cv.out$lambda.min
bestlam
# The value of λ that results in the smallest cross-validation error is 0.004145665

# Finding the test marginal standard error (MSE) associated with this value of λ (0.004145665):
ridge.pred=predict(ridge.mod,s=bestlam,newx=x[test ,])
mean((ridge.pred-y.test)^2)
# Test MSE=0.3150738

# Finally, we refit our ridge regression model on the full data set, using the value of λ chosen by cross-validation, and examine the coefficient estimates.:
out=glmnet(x,y,alpha=0)
predict(out,type="coefficients",s=bestlam )[1:200 ,]

# However, it is hard to see best variables, because Ridge doesn't zero out any of the coefficients.

###

# Trying now with the lasso model

grid=10^seq(10,-2,length=1000)
ridge.mod=glmnet(x,y,alpha=0,lambda=grid)

tri_data_m<-data.frame(tri_data_m)
ridge.mod=glmnet(x,y,alpha=0,lambda=grid)

lasso.mod=glmnet(x[train ,],y[train],alpha=1,lambda=grid)
plot(lasso.mod)

set.seed (1)
cv.out=cv.glmnet(x[train ,],y[train],alpha=1)
plot(cv.out)
bestlam=cv.out$lambda.min
lasso.pred=predict(lasso.mod,s=bestlam ,newx=x[test,])
mean((lasso.pred-y.test)^2)
# Result: 0.3150799

out=glmnet(x,y,alpha=1,lambda=grid)
lasso.coef=predict(out,type="coefficients",s=bestlam)[1:500,]
lasso.coef

# Unlike the Ridge Regression, the Lasso model will return coefficients of 0, so we select all the non-zero coefficients:
lasso.coef[lasso.coef!=0]

# In fact, we find many more, including:
'''
                     (Intercept)             access.birth.control           afghanistan.mr.speaker 
                    0.0472306924                    -0.0469413462                    -0.0019294075 
               agre.preambl.agre         agricultur.rural.develop               al.qaeda.terrorist 
                   -0.0238115501                    -0.0469413457                    -0.0004441319 
               allow.speak.minut                 amend.read.third              amend.senat.proceed 
                   -0.0238115248                     0.0088278773                    -0.0469413448 
            america.around.world                   american.ca.nt            american.job.american 
                   -0.0465813767                    -0.0469413457                    -0.0238121986 
               announc.last.week           articl.washington.post               ask.american.peopl 
                   -0.0238122101                    -0.0010063551                    -0.0469413453 
               ask.given.permiss               assault.weapon.ban              assist.program.snap 
                   -0.0469413453                     0.0115355350                    -0.0465373971 
             attorney.gener.eric                    back.year.ago               balanc.budget.back 
                   -0.0021895717                    -0.0232750157                    -0.0232750271 
        bipartisan.immigr.reform               budget.balanc.year            california.mr.lamalfa 
                    0.0096826696                    -0.0238119826                    -0.0067830591 
                    care.act.aca                     care.act.let             career.public.servic 
                   -0.0469413484                    -0.0068867719                    -0.0259399623 
               caus.climat.chang            chair.budget.committe          chairman.thank.chairman 
                   -0.0469413485                    -0.0001680860                    -0.0238120022 
               chanc.offer.amend             colleagu.vote.clotur                    come.long.way 
                   -0.0469413483                    -0.0061506888                    -0.0238123161 
      committe.discharg.consider         committe.feder.judiciari          committe.foreign.affair 
                   -0.0238122369                     0.0007480406                    -0.0469413477 
             committe.mr.speaker committe.transport.infrastructur             commun.mental.health 
                   -0.0006890450                    -0.0010455545                    -0.0465797436 
        comprehens.immigr.reform          congression.black.caucu                consent.bill.read 
                   -0.0238120972                    -0.0014325035                    -0.0006890446 
              consent.member.may             consent.resolut.agre                 cost.higher.educ 
                   -0.0467942226                    -0.0463315250                    -0.0232749112 
                day.revis.extend             death.famili.present           depart.inspector.gener 
                    0.0020838429                     0.0010239299                    -0.0261046468 
         discharg.consider.senat          district.court.district                 divid.usual.form 
                   -0.0467959372                     0.0002678164                    -0.0469413494 
                 done.mr.speaker             emerg.unemploy.insur             energi.effici.legisl 
                   -0.0469413494                    -0.0159534850                    -0.0232749897 
            energi.natur.resourc                enforc.immigr.law                  enforc.law.book 
                    0.0119279702                    -0.0469413493                    -0.0208054802 
                  engel.new.york              enter.countri.illeg                 enter.unit.state 
                   -0.0201503179                    -0.0468453970                    -0.0010547532 
           extend.unemploy.insur             extrem.weather.event                final.passag.bill 
                   -0.0232756729                    -0.0157100783                    -0.0469413500 
               first.amend.right                 free.syrian.armi               friend.across.aisl 
                   -0.0232752431                    -0.0154717625                     0.0100451477 
    gentleman.california.postpon            gentleman.kentucki.mr        gentleman.pennsylvania.mr 
                   -0.0232756980                    -0.0469413499                    -0.0469413499 
                   get.back.feet                 get.economi.grow                 get.social.secur 
                   -0.0469413499                     0.0003964940                     0.0005680986 
                  hard.work.done              hardearn.tax.dollar               harvard.law.school 
                   -0.0007176623                    -0.0232751290                     0.0008232710 
             health.care.employe                 health.care.like             health.insur.employe 
                   -0.0209692374                    -0.0062021843                    -0.0063502969 
            higher.interest.rate 
                   -0.0232752239 
'''
