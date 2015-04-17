#######################################################################################

#### Kathryn Zickuhr
#### Assignment 3

#######################################################################################

### Step 1: Download Congressional speech data 

Downloaded Congressional speech data via Sunlight Foundation, using G. Sood's python script `capitol speech fetch.py`. I chose to use data from the 113th Congress because data for the ideology views of the 114th Congress was not yet available from VoteView.

### Step 2: Pre-process Congressional speech data

Pre-process Congressional speech data using G. Sood's python script `preprocessingData.py`. This step punctuation, numbers, and stop words, and reduces words to their stems:

```
python preprocessingData.py -c speaking capitolwords113.csv -o cleaned113.csv
```

### Step 3: Clean up Congressional speech data

Clean up Congressional speech data (could be automated in the future):
1. Deleted administrative rows (where `speaker_raw` = recorder, the clerk, the president pro tempore, the speaker pro tempore, etc.)
2. Added party and bioguide_id rows where missing for substantial number of rows (>5)
3. Deleted rows that were all speaking text (errors)
4. Deleted rows where chamber = `extensions`

Create a new file with only `bioguide_ID`, `party`, and `speaking` columns.

### Step 4: Download DW-NOMINATE information

Download DW-NOMINATE csv files (for dynamic, weighted NOMINATE) for House and Senate;
Deleted all sessions that were not 113, combined senate and house files into one csv file.

Added column headers to the csv file using information available at http://voteview.com/dwnomin.htm
Saved new csv file (`DW-NOMINATE-sm.csv`) with only `ICPSR_id` and `first_d` columns.

### Step 5: Merge speech data with DW-NOMINATE scores

Merge pre-processed Congressional speech data with DW-NOMINATE scores. To translate bioguide IDs with ICPSR IDs, downloaded `results_plus_hand_entry.csv` from https://gist.github.com/konklone/1642406, `bioguide to ICPSR.csv`. Kept only `bioguide_ID` and `ICPSR_ID` columns.

**see: [merge.R](https://github.com/kz55/Capitol-words-modeling/blob/master/merge.R)**

Final csv file contains:
columns = ideology, party, text
rows = each floor speech
There is some missing data for members elected to the 113th congress

### Step 6: Extracting ngrams from Congressional speech data

**see: [ngrams.R](https://github.com/kz55/Capitol-words-modeling/blob/master/ngrams.R)**

This step extracts bigrams and trigrams from Republican and Democratic speakers, then removes the most common ngrams from those list and those that are very rare.

### Step 7: Reduce terms with chi-square

**see: [chisq.R](https://github.com/kz55/Capitol-words-modeling/blob/master/chisq.R)**

This creates a function to find chi-square values for each ngram, testing the hypothesis that Democrats and Republicans are equally as likely to use that term. This will help narrow the list of potential variables to those with the highest predictive power.

We now have lists of the 500 most predictive bigrams and trigrams for Republicans and Democrats, respectively:

[Top 500 Republican bigrams] (https://github.com/kz55/Capitol-words-modeling/blob/master/top%20R%20bigrams.csv)

[Top 500 Republican trigrams] (https://github.com/kz55/Capitol-words-modeling/blob/master/top%20R%20trigrams.csv)


[Top 500 Democratic bigrams] (https://github.com/kz55/Capitol-words-modeling/blob/master/top%20D%20bigrams.csv)

[Top 500 Democratic trigrams] (https://github.com/kz55/Capitol-words-modeling/blob/master/top%20D%20trigrams.csv)

### Step 8: Ridge regression and Lasso model

Now that we have the most predictive variables to use from the bigrams and trigrams above, we use the glmnet package for Ridge regression, as described in ISLR. Ridge regression is very similar to least squares, except with a tuning parameter. Ridge regression has computational benefits over OLS, although unlike the Lasso model, it includes all p predictors in the final model.

**see: [modeling.R](https://github.com/kz55/Capitol-words-modeling/blob/master/modeling.R)**

We being with the Ridge regression, but see that it cannot reduce coefficients to zero, and so is not useful in helping us choose a model in this case. Using a Lasso model, we find the following coefficients for bigrams:
```
 (Intercept)    base.upon   claim.time  cut.medicar  energi.cost 
 0.051055727  0.479958431 -0.315666015 -0.020005518 -0.001177747 
```
Our model for ideology based on bigrams:
```
ideology =  0.051055727 + 0.479958431(base.upon) -0.315666015(claim.time) -0.020005518(cut.medicar) -0.001177747(energi.cost)
```

with values > 0 indicating Democratic/liberal ideology and values < 0 indicating Republican/conservative ideology. (Note: This only includes coefficients from the first ~500 rows of bigrams in the data.)

Because the ngram selection process did not remove the most common phrases (unlike the media bias paper), many "administrative" phrases, such as "claim time", were included in the analysis. 

**Still, based on the model, we see that phrases like "cut medicare" and "energy cost" are predictive of a somewhat liberal ideology.**


For trigrams, the coefficients are more numerous. They include:
```
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
```
