#chisq.R

'''
This creates a function to find chi-square values for each ngram, testing the hypothesis
that Democrats and Republicans are equally as likely to use that term. This will help
narrow the list of potential variables to those with the highest predictive power.

total number of times phrase p of legth l is spoken by R & D respectively: = freq of
phrase for R (f2r) and D (f2d)

Total occurrences of length-l phrases that are NOT phrase p spoken by R & D respectively:
= total freq(all phrases) minus freq(phrase p) for R (notf2r) and D (notf2d)

The goal is to create a list with the 500 most predictive bigrams and trigrams for
Republicans and Democrats, respectively.
'''

#############################

## Creating bigrams

# First, load the subset of bigrams for each party and merge into one dataframe

library(plyr)

bi_R <- read.csv("bi_R.csv")
bi_R <- subset(bi_R, select=c("bigramsR", "Freq"))
bi_R <- rename(bi_R, c("bigramsR" = "bigram", "Freq" = "Freq_R"))

bi_D <- read.csv("bi_D.csv")
bi_D <- subset(bi_D, select=c("bigramsD", "Freq"))
bi_D <- rename(bi_D, c("bigramsD" = "bigram", "Freq" = "Freq_D"))

bi_total <- merge(bi_R, bi_D, by="bigram")
View(bi_total)
write.csv(bi_total, "bi_total.csv")

# Define the chi.sq() function

f2r <- bi_total$Freq_R
f2d <- bi_total$Freq_D

notf2r <- as.numeric((length(bi_total))-f2r)
notf2d <- as.numeric((length(bi_total))-f2d)

chi.sq <- function() {
    num <- ( ( (f2r*notf2d) - (f2d*notf2r) )^2)
    denom <- ((f2r+f2d)*(f2r+notf2r)*(f2d+notf2d)*(notf2r+notf2d))
    return(num/denom)
}

chi.sq()

# Now add the chi square values to the ngrams

bi_chi.sq <- cbind(bi_total,chi.sq())

# Sort ascending here because highest value is ~ 0
bi_chi.sq_sort <- bi_chi.sq[order(chi.sq()),]

View(bi_chi.sq_sort)

# Subset the top 500 bigrams for Republicans and Democrats
top_bi_R <- subset(bi_chi.sq_sort, Freq_R > Freq_D)
top_bi_R <- top_bi_R[1:500, ]
top_bi_D <- subset(bi_chi.sq_sort, Freq_D > Freq_R)
top_bi_D <- top_bi_D[1:500, ]

View(top_bi_R)
View(top_bi_D)

write.csv(top_bi_R, "top_bi_R.csv")
write.csv(top_bi_D, "top_bi_D.csv")

top_bi <- merge(top_bi_R, top_bi_D, by="bigram", all=TRUE)
top_bi <- top_bi$bigram
View(top_bi)
write.csv(top_bi, "top_bi.csv")

#############################

## Creating trigrams

tri_R <- read.csv("tri_R.csv")
tri_R <- subset(tri_R, select=c("trigramsR", "Freq"))
tri_R <- rename(tri_R, c("trigramsR" = "trigram", "Freq" = "Freq_R"))

tri_D <- read.csv("tri_D.csv")
tri_D <- subset(tri_D, select=c("trigramsD", "Freq"))
tri_D <- rename(tri_D, c("trigramsD" = "trigram", "Freq" = "Freq_D"))

tri_total <- merge(tri_R, tri_D, by="trigram")
View(tri_total)
write.csv(tri_total, "tri_total.csv")

f3r <- tri_total$Freq_R
f3d <- tri_total$Freq_D

notf3r <- as.numeric((length(tri_total))-f3r)
notf3d <- as.numeric((length(tri_total))-f3d)

chi.sq <- function() {
    num <- ( ( (f3r*notf3d) - (f3d*notf3r) )^2)
    denom <- ((f3r+f3d)*(f3r+notf3r)*(f3d+notf3d)*(notf3r+notf3d))
    return(num/denom)
}

chi.sq()

# Now add the chi square values to the ngrams

tri_chi.sq <- cbind(tri_total,chi.sq())

# Sort ascending here because highest value is ~ 0
tri_chi.sq_sort <- tri_chi.sq[order(chi.sq()),]

View(tri_chi.sq_sort)

# Subset the top 500 trigrams for Republicans and Democrats
top_tri_R <- subset(tri_chi.sq_sort, Freq_R > Freq_D)
top_tri_R <- top_tri_R[1:500, ]
top_tri_D <- subset(tri_chi.sq_sort, Freq_D > Freq_R)
top_tri_D <- top_tri_D[1:500, ]

View(top_tri_R)
View(top_tri_D)

write.csv(top_tri_R, "top_tri_R.csv")
write.csv(top_tri_D, "top_tri_D.csv")

top_tri <- merge(top_tri_R, top_tri_D, by="trigram", all=TRUE)
top_tri <- top_tri$trigram
View(top_tri)
write.csv(top_tri, "top_tri.csv")
