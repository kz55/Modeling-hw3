# Step 1: Add ICPSR IDs to Congressional speech data by bioguide ID
# Note: bioguide_id must be first column

conversion = read.csv("bioguide to ICPSR.csv")
cleaned = read.csv("cleaned113-cleaner.csv")

mergedIDs <- merge(conversion,cleaned,by="bioguide_id")
write.csv(mergedIDs, "mergedIDs.csv")

# Step 2: Add VoteView scores to Congressional speech data by ICPSR ID
# Note: ICPSR_id must be first column

dw = read.csv("DW-NOMINATE-sm.csv")
mergedIDs = read.csv("mergedIDs.csv")
mergedwords <- merge(dw,mergedIDs,by="ICPSR_id")
View(mergedwords)
write.csv(mergedwords, "mergedwords.csv")