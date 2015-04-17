# First, fix Java memory problems:

Sys.setenv(JAVA_HOME = '/Library/Java//Home') 
Sys.setenv(LD_LIBRARY_PATH = '$LD_LIBRARY_PATH:$JAVA_HOME/lib')
install.packages('rJava', type='source')
library(rJava)
options(java.parameters = "-Xmx8000m")

# Creating bigrams and trigrams by party

library(RWeka)
library(ngram)
mergedwords <- read.csv("mergedwords.csv")

mergedwordsR <- subset(mergedwords, speaker_party=='R')
write.csv(mergedwordsR, "mergedwordsR.csv")
speakingR <- mergedwordsR$speaking
bigramsR <- NGramTokenizer(speakingR, Weka_control(min=2, max=2))
write.csv(bigramsR, "bigramsR.csv")
trigramsR <- NGramTokenizer(speakingR, Weka_control(min=3, max=3))
write.csv(trigramsR, "trigramsR.csv")

mergedwordsD <- subset(mergedwords, speaker_party=='D')
write.csv(mergedwordsD, "mergedwordsD.csv")
speakingD <- mergedwordsD$speaking
bigramsD <- NGramTokenizer(speakingD, Weka_control(min=2, max=2))
write.csv(bigramsD, "bigramsD.csv")
trigramsD <- NGramTokenizer(speakingD, Weka_control(min=3, max=3))
write.csv(trigramsD, "trigramsD.csv")

# Removing phrases that are not used frequently. Has the option to remove the 
# most common phrases as well.

# For Republicans

bigramsR.Freq <- data.frame(table(bigramsR))
bigramsR.Freq$bigramsR <- as.character(bigramsR.Freq$bigramsR)
bigramsR.Freq <- bigramsR.Freq[order(-bigramsR.Freq$Freq), ]
rownames(bigramsR.Freq) <- 1:nrow(bigramsR.Freq)

freq <- bigramsR.Freq$Freq
summary(freq)
bi_subsetR <- subset(bigramsR.Freq, Freq >= 50)
# bi_subsetR <- subset(bigramsR.Freq, Freq >= 50 & Freq < 3000 )
write.csv(bi_subsetR, "bi_R.csv")

trigramsR.Freq <- data.frame(table(trigramsR))
trigramsR.Freq$trigramsR <- as.character(trigramsR.Freq$trigramsR)
trigramsR.Freq <- trigramsR.Freq[order(-trigramsR.Freq$Freq), ]
rownames(trigramsR.Freq) <- 1:nrow(trigramsR.Freq)

freq <- trigramsR.Freq$Freq
summary(freq)
tri_subsetR <- subset(trigramsR.Freq, Freq >= 5)
# tri_subsetR <- subset(trigramsR.Freq, Freq >= 5 & Freq < 500)
write.csv(tri_subsetR, "tri_R.csv")

# For Democrats

bigramsD.Freq <- data.frame(table(bigramsD))
bigramsD.Freq$bigramsD <- as.character(bigramsD.Freq$bigramsD)
bigramsD.Freq <- bigramsD.Freq[order(-bigramsD.Freq$Freq), ]
rownames(bigramsD.Freq) <- 1:nrow(bigramsD.Freq)

freq <- bigramsD.Freq$Freq
summary(freq)
bi_subsetD <- subset(bigramsD.Freq, Freq >= 50)
# bi_subsetD <- subset(bigramsD.Freq, Freq >= 50 & Freq < 3000 )
write.csv(bi_subsetD, "bi_D.csv")

trigramsD.Freq <- data.frame(table(trigramsD))
trigramsD.Freq$trigramsD <- as.character(trigramsD.Freq$trigramsD)
trigramsD.Freq <- trigramsD.Freq[order(-trigramsD.Freq$Freq), ]
rownames(trigramsD.Freq) <- 1:nrow(trigramsD.Freq)

freq <- trigramsD.Freq$Freq
summary(freq)
tri_subsetD <- subset(trigramsD.Freq, Freq >= 5)
# tri_subsetD <- subset(trigramsD.Freq, Freq >= 5 & Freq < 500)
write.csv(tri_subsetD, "tri_D.csv")
